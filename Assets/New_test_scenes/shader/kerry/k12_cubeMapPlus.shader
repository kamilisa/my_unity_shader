Shader "kerry/k12_cubeMapPlus"
{
    Properties
    {
        _cubeMap("Cube Map", Cube) = "_Skybox" {}
        _roughMap("RoughMap", 2D) = "black" {}
        _roughContrast("roughContrast",float) = 1
        _roughintensity("roughIntensity",float) = 1
        _roughMin("roughLerp_min",float) = 0
        _roughMax("roughLerp_max",float) = 10
        _cubeRotate("Map rotate",Range(0,360)) = 0
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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

            samplerCUBE _cubeMap;
            float4 _cubeMap_HDR;
            sampler2D _normalMap;
            sampler2D _ambientMap;
            float _cubeRotate;
            float4 _mainColor;
            float _expose;
            sampler2D _roughMap;
            float _roughContrast;
            float _roughintensity;
            float _roughMin;
            float _roughMax;

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
                float3 reflect_view_dr = reflect(-camera_vector,normal_vector_ws); //相对于法线贴图结果的视线镜像向量

                //弧度计算
                reflect_view_dr = rotateAngleByArc(_cubeRotate,reflect_view_dr);

                //cubeMap
                float roughMap = tex2D(_roughMap,i.uv);
                roughMap = saturate(pow(roughMap,_roughContrast)) * _roughintensity;
                roughMap = lerp(_roughMin,_roughMax,roughMap);
                half mip_level = roughMap * 7;
                float4 cube_map = texCUBElod(_cubeMap,float4(reflect_view_dr,mip_level)); //用法复杂，第二个参数需要填入视线镜像向量以及mipmap采样值
                half3 cube_map_de = DecodeHDR(cube_map,_cubeMap_HDR); // 高清解码，确保适配移动平台

                //unity reflection probe 
                // float4 unity_env_map = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflect_view_dr);
                // half3 unity_env_map_de = DecodeHDR(unity_env_map,unity_SpecCube0_HDR); // 高清解码，确保适配移动平台

                //ao
                float3 ambient = tex2D(_ambientMap,i.uv).xyz;

                //final_ex
                float3 final = cube_map_de * _mainColor.rgb * ambient * _expose;

                return float4 (final,1.0);
            }
            ENDCG
        }
    }
}
