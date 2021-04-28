Shader "kerry/k29_toon_girl_eye"
{
    Properties
    {
        [Header(Maps_Region)]
        _BaseTex ("DiffuseMap", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _Parallax("Parallax", float) = -0.1
        _DecalMap ("DecalMap", 2D) = "white" {}
        [Header(Rim_Region)]
        _EnvMap("Env Map", Cube) = "_Skybox" {}
        _EnvRotate("Env rotate",range(0,360)) = 0
        _Envintensity("Env intensity",range(0,1)) = 0
        _Roughness("EnvRoughness",Range(0,7)) = 0

    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" } //声明pass作用类型，前向渲染基本层，或平行光作用层
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //开启多线程编译模式 - 光照标配
            #pragma multi_compile_fwdbase_fullshadows
            //导入光照相关方法头文件
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "kami_utility.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
                float4 color : COLOR;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_ws : TEXCOORD1;
                float3 tangent_ws : TEXCOORD2;
                float3 binormal_ws : TEXCOORD3;
                float4 pos_ws : TEXCOORD4;
                float4 vertexColor : TEXCOORD5;
            };

            sampler2D _BaseTex;
            sampler2D _NormalMap;
            sampler2D _DecalMap;
            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            half _Envintensity;
            half _EnvRotate;
            half _Roughness;
            float _Parallax;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex);
                o.normal_ws = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangent_ws = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.binormal_ws = normalize(cross(o.normal_ws,o.tangent_ws)) * v.tangent.w;  // tangent的w分量规定了次切线的朝向
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertexColor = v.color;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //准备向量
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 normal_Dir = normalize(i.normal_ws);
                half3 tangent_Dir = normalize(i.tangent_ws);
                half3 binormal_Dir = normalize(i.binormal_ws);
                half3 view_Dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);
                half3 halfPhone_Dir = normalize(light_Dir + view_Dir);

                // 采样贴图
                half4 decal_Color = tex2D(_DecalMap, i.uv);
                half3 normal_data = UnpackNormal(tex2D(_NormalMap,i.uv));   // normal贴图load加解包
                float3x3 TBN = float3x3(tangent_Dir,binormal_Dir,normal_Dir);
                normal_Dir = normalize(mul(normal_data.xyz,TBN)); //最终法线向量
                normal_data.xy = -normal_data.xy;
                float3 normalDir_iris = normalize(mul(normal_data.xyz,TBN)); //最终法线向量
                half3 reflect_Dir = normalize(reflect(-view_Dir,normal_Dir));  //视线方向表面反弹向
                half3 tanView_Dir = normalize(mul(TBN,view_Dir));
                float parallax_depth = smoothstep(1.0,0.5,saturate(distance(i.uv, float2(0.5,0.5)) / 0.2));  //利用UV中心点的距离算一个mask
                float2 parallax_offset = (tanView_Dir.xy / (tanView_Dir.z + 0.42f)) * _Parallax * parallax_depth;
                half3 baseColor = tex2D(_BaseTex, i.uv + parallax_offset).rgb; // 利用视差偏移UV

                //常用光照模型
                half NdotL = dot(normal_Dir,light_Dir);
                half NdotH = dot(normal_Dir,halfPhone_Dir);
                half TdotH = dot(tangent_Dir,halfPhone_Dir);
                half NdotV = dot(normal_Dir,view_Dir);
                half half_lambert = (NdotL + 1.0) * 0.5;
                half BdotH = dot(binormal_Dir,halfPhone_Dir);

                //翻转虹膜法线光照模型
                half NdotL_iris = max(0,dot(normalDir_iris,light_Dir)); //修复光背面阴影发黑的问题必须max
                half half_lambert_iris = (NdotL_iris + 1.0) * 0.5;
   
                //漫反射
                half3 final_diffuse = baseColor * half_lambert_iris;
                half3 line_final_diffuse = pow(final_diffuse,2.2);

                //边缘光
                reflect_Dir = rotateAngleByArc(_EnvRotate,reflect_Dir);
                float roughness = lerp(0.0,0.95,saturate(_Roughness));
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_Dir,mip_level));
                half3 env_color = DecodeHDR(color_cubemap,_EnvMap_HDR) * _Envintensity; // 高清解码，确保适配移动平台
                half env_lumin = dot(env_color, float3(0.299f,0.587f,0.114f)); //提取明度
                env_color = env_color * env_lumin; //提升对比度
                half3 line_env_color = pow(env_color,2.2);

                half3 final_layer = line_final_diffuse + line_env_color + decal_Color.rgb;
                half3 aces_layer = pow(ACESFilm(final_layer),1/2.2);

                return half4(aces_layer,1.0);
            }
            ENDCG
        }

    }
    FallBack "Diffuse"  //重要，有该句才能对全局声明执行绘制shadowmap操作
}
