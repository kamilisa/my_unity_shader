Shader "kerry/k14_shEnvLight"
{
    Properties
    {
        _mainColor("Main Color",Color) = (0.0,0.0,0.0,1.0)
        _expose("expose",float) = 1
        [Normal]_normalMap("Normal Map",2D) = "bump"{}
        _ambientMap("AO",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            //球谐光照需要定义pass的光照类型
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //开启多线程编译模式 - 光照标配
            #pragma multi_compile_fwdbase
            //导入光照相关方法头文件
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "kami_utility.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_ws : TEXCOORD1;
                float3 tangent_ws : TEXCOORD2;
                float3 binormal_ws : TEXCOORD3;
                float3 pos_ws : TEXCOORD4;
            };

            sampler2D _normalMap;
            sampler2D _ambientMap;
            float4 _mainColor;
            float _expose;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal_ws = UnityObjectToWorldNormal(v.normal);
                o.tangent_ws = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.binormal_ws = normalize(cross(o.normal_ws,o.tangent_ws)) * v.tangent.w;  // tangent的w分量规定了次切线的朝向
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //法线图
                half4 normal_tex = tex2D(_normalMap,i.uv);   // normal层，新知识点
                half3 normal_data = UnpackNormal(normal_tex); //解码被执行过normal压缩格式的normal图

                //准备向量
                float3 normal_vector_ws = normalize(i.normal_ws);
                float3 tangent_ws = normalize(i.tangent_ws);
                float3 binormal_ws = normalize(i.binormal_ws);
                //法线矩阵
                float3x3 TBN = float3x3(tangent_ws,binormal_ws,normal_vector_ws);
                normal_vector_ws = normalize(mul(normal_data.xyz,TBN));
                float3 light_vector = normalize( _WorldSpaceLightPos0.xyz); // 获取灯光的世界位置 or 世界向量 根据光类型不同
                float3 camera_vector = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws); //获取相对于顶点的相机向量

                //ao
                half3 env_color = ShadeSH9(float4(normal_vector_ws,1.0));
                float3 ambient = tex2D(_ambientMap,i.uv).xyz;

                //final_ex
                float3 final = env_color * _mainColor.rgb * ambient * _expose;

                return float4 (final,1.0);
            }
            ENDCG
        }
    }
}
