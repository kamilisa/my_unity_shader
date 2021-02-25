Shader "kerry/k17_kajiyaK"
{
    Properties
    {
        [Header(TEX)]
        _MainTex ("Texture", 2D) = "black" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _NormalMap("NormalMap" ,2D) = "bump" {}
        _FlowMap("FlowMap",2D) = "white"{}
        [Header(Spec_attr)]
        _MainColor("Main Color",Color) = (0.0,0.0,0.0,1.0)
        _ShadowIns("ShadowIns",float) = 0

        _SpecColor("SpecColor",Color) = (1.0,1.0,1.0,1.0)
        _SpecRoughness ("SpecRoughness",range(0,1)) = 99
        _SpecNoise("SpecNoise",float) = 1
        _SpecOffset("SpecOffset",float) = 0

        [Header(Check state)]
        [Toggle(_FLOWMAP_ON)] _FlowCheck("FlowMap On",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" } //声明pass作用类型，前向渲染基本层，或平行光作用层
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //开启多线程编译模式 - 光照标配
            #pragma multi_compile_fwdbase_fullshadows
            #pragma shader_feature _FLOWMAP_ON
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "/Assets/kami_lib.cginc"
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_ws: TEXCOORD1;
                float3 tangent_ws : TEXCOORD2;
                float3 binormal_ws : TEXCOORD3;
                float3 pos_ws: TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            float4 _ShadowIns;
            float4 _LightColor0; //头文件带的光线颜色变量，需要先定义再使用
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _SpecColor;
            half _SpecRoughness;
            float _SpecNoise;
            float _SpecOffset;
            sampler2D _NormalMap;
            sampler2D _FlowMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_ws = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangent_ws = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.binormal_ws = normalize(cross(o.normal_ws,o.tangent_ws)) * v.tangent.w;  // tangent的w分量规定了次切线的朝向
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //shadow
                float atte = LIGHT_ATTENUATION(i);

                //准备向量
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 normal_Dir = normalize(i.normal_ws);
                half3 tangent_Dir = normalize(i.tangent_ws);
                half3 binormal_Dir = normalize(i.binormal_ws);
                half3 view_Dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);
                half3 half_Dir = normalize(light_Dir + view_Dir);

                //准备贴图
                half2 uv_shift = i.uv * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                half shift_map = tex2D(_NoiseTex,uv_shift).r;
                half3 dif_color = tex2D(_MainTex,i.uv).rgb;
                half3 normal_data = UnpackNormal(tex2D(_NormalMap,i.uv));   // normal贴图load加解包
                float3x3 TBN = float3x3(tangent_Dir,binormal_Dir,normal_Dir);
                normal_Dir = normalize(mul(normal_data.xyz,TBN));

                half2 flow_map = tex2D(_FlowMap,i.uv).rg;
                flow_map = flow_map * 2 - 1;  //解码flow map，将其从 0-1区间，变为 -1 - 1，以便于构造向量
                #ifdef _FLOWMAP_ON
                binormal_Dir = normalize(tangent_Dir * flow_map.g + binormal_Dir * flow_map.r);
                #else
                binormal_Dir = normalize(i.binormal_ws);
                #endif

                //常用点乘
                half NdotL = max(0,dot(normal_Dir,light_Dir)); //兰伯特
                half half_lambert = max(0,(NdotL + 1) * 0.5);  //半兰伯特
                half NdotV = max(0,dot(normal_Dir,view_Dir));  //菲涅尔

                // //Kajiya K 各向异性 or 称呼其为直接光镜面反射层
                // //扰动
                // shift_map = (shift_map * 2.0 - 1.0) * _SpecNoise; //采一张图以便于后续直接作为控制法线扰动强度的乘值
                // half3 binormal_offset = normal_Dir * (shift_map + _SpecOffset); //给法线偏转程度通过一张贴图叠加强度值
                // binormal_Dir = normalize(binormal_Dir + binormal_offset); //将次法线通过法线向量给予一个扰动
                // half BdotH = dot(binormal_Dir,half_Dir); //B dot H 点积结果
                // half sinH =  max(0,sqrt(1 - BdotH * BdotH));  // kajiya-K核心公式
                // half3 spec_color = pow(sinH,_SpecRoughness) * _LightColor0.xyz * _SoecColor;
                // half3 spec_layer = spec_color;

                //special 各向异性 or 称呼其为直接光镜面反射层
                half3 spec_aniso = SpecialAnisotropicLight(_SpecNoise,_SpecOffset,_SpecRoughness,shift_map,tangent_Dir,binormal_Dir,normal_Dir,half_Dir);  //新的各向异性公式，据说比KK好
                half3 spec_color = _SpecColor.rgb;
                half aniso_atten = saturate(sqrt(max(0,half_lambert / NdotV))) * atte; //特殊阴影衰减，控制高光在阴影区间衰减
                half3 spec_layer = spec_aniso * aniso_atten * spec_color * _LightColor0.xyz;

                //直接光漫反射
                half3 dif_layer = dif_color * _MainColor * _LightColor0.xyz * atte;

                //间接光漫反射
                half3 ambient_layer = ShadeSH9(float4(normal_Dir,1.0)) * dif_color;


                //最终输出
                half3 final_layer = dif_layer + spec_layer + ambient_layer;

                return float4(final_layer,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"  //重要，有该句才能对全局声明执行绘制shadowmap操作
}
