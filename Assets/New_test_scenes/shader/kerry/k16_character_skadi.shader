Shader "kerry/k16_character_skadi"
{
    Properties
    {
        [Header(Color_maps)]
        _difTex ("diffuse", 2D) = "white" {}
        _compTex("compTex(RO)",2D) = "white"{}
        _NormalMap("NormalMap" ,2D) = "bump" {}
        _specIntensity("SpecRadios", range(1,99)) = 1
        [Header(Env)]
        _cubeMap("Cube Map", Cube) = "_Skybox" {}
        _cubeMapMip("Cube Map smooth", Range(0,7)) = 0
        _cubeRotate("Map rotate",Range(0,360)) = 0
        [Header(SSS)]
        _sssLUT("SSS_lut",2D) = "white" {}
        _sssOffset("SSS_offset",range(0,1)) = 0.5

        [Header(Check Area)]
        [Toggle(_DIFCHECK_ON)] _DifCheck("Diffuse check",float) = 1
        [Toggle(_SPECCHECK_ON)] _SpecCheck("Specular check",float) = 1
        [Toggle(_SDRFCHECK_ON)] _SDRFCheck("SDRF_ambient check",float) = 1
        [Toggle(_IBLCHECK_ON)] _IBLCheck("IBL_reflection check",float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" } //声明pass作用类型，前向渲染基本层，或平行光作用层
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _DIFCHECK_ON
            #pragma shader_feature _SPECCHECK_ON
            #pragma shader_feature _SDRFCHECK_ON
            #pragma shader_feature _IBLCHECK_ON
            //开启多线程编译模式 - 光照标配
            #pragma multi_compile_fwdbase_fullshadows
            #include "UnityCG.cginc"
            //导入光照相关方法头文件
            #include "AutoLight.cginc"
            #include "kami_utility.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
                float4 tangent : TANGENT;
            };
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 normal_ws: TEXCOORD1;
                float3 pos_ws: TEXCOORD2;
                float3 tangent_ws : TEXCOORD3;
                float3 binormal_ws : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };
            
            sampler2D _difTex;
            float4 _difTex_ST;
            float4 _LightColor0; //头文件带的光线颜色变量，需要先定义再使用
            sampler2D _NormalMap;
            sampler2D _compTex;
            float _specIntensity;

            samplerCUBE _cubeMap;
            float4 _cubeMap_HDR;
            float _cubeMapMip;
            float _cubeRotate;

            sampler2D _sssLUT;
            float _sssOffset;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_difTex);   //特殊uv和贴图绑定方法，能快速映射所有贴图的tilling
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_ws = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangent_ws = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.binormal_ws = normalize(cross(o.normal_ws,o.tangent_ws)) * v.tangent.w;  // tangent的w分量规定了次切线的朝向
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                //shadow
                float atte = LIGHT_ATTENUATION(i);

                //准备贴图
                half4 dif_tex_gamma = tex2D(_difTex,i.uv);
                half4 abedo_color = pow(dif_tex_gamma,2.2);
                half4 comp_tex = tex2D(_compTex,i.uv);
                half metal = comp_tex.g;  //提取金属度通道
                half roughness = comp_tex.r; //粗糙度
                half smoothness = 1 - roughness; // 金属度
                half skinArea = comp_tex.b; //皮肤和物件mask区域
                half3 base_color = abedo_color.rgb * (1-metal);  //利用金属度值区分物体表面类型，如为0，则乘值表示该像素金属，着黑色
                half3 specular_color = lerp(0.03,abedo_color.rgb,metal); //利用金属度贴图从abedo上拿取金属物体高光颜色
                half3 normal_data = UnpackNormal(tex2D(_NormalMap,i.uv));   // normal贴图load加解包

                //准备向量
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 normal_Dir = normalize(i.normal_ws);
                half3 tangent_Dir = normalize(i.tangent_ws);
                half3 binormal_Dir = normalize(i.binormal_ws);
                half3 view_Dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);
                half3 halfPhone_Dir = normalize(light_Dir + view_Dir);
                float3x3 TBN = float3x3(tangent_Dir,binormal_Dir,normal_Dir);
                normal_Dir = normalize(mul(normal_data.xyz,TBN));
                half3 reflect_Dir = normalize(reflect(-light_Dir,normal_Dir));  //求灯光镜像向量，计算高，必须放到法线贴图后算

                //常用点乘
                half NdotL = max(0,dot(normal_Dir,light_Dir)); // lambert
                half RdotV = max(0,dot(reflect_Dir,view_Dir)); // phone
                half NdotH = max(0,dot(normal_Dir,halfPhone_Dir)); //blinn phone
                half halfLambert = (NdotL + 1) * 0.5; // half lambert

                //SSS模拟
                half2 sss_uv = half2(NdotL * atte + _sssOffset,1.0);
                half3 sss_lut_gamma = tex2D(_sssLUT,sss_uv);
                // half3 sss_lut = pow(sss_lut_gamma,2.2);
                half3 sss_layer = sss_lut_gamma * base_color * _LightColor0.xyz;

                //直接光漫反射
                half3 dif_layer = NdotL * base_color * _LightColor0.xyz * atte;
                // blend sss with lambert

                //宏检查
                #ifdef _DIFCHECK_ON
                dif_layer = lerp(dif_layer,sss_layer,skinArea);
                #else
                dif_layer = half3(0.0,0.0,0.0);
                #endif

                //直接光镜面反射
                half shininess = lerp(1,_specIntensity,smoothness); //利用粗糙度来取一个值区间，这个操作很迷
                half spec_term = pow(NdotH,shininess); // 用值区间输出的最终值对布林冯进行强度Pow
                half3 spec_skin_color = lerp(specular_color,0.0,skinArea);   //利用皮肤mask稍微增加一些skin的直接光镜面高光

                #ifdef _SPECCHECK_ON
                half3 spec_layer = spec_term * spec_skin_color * _LightColor0.xyz * atte;
                #else
                half3 spec_layer = half3(0.0,0.0,0.0);
                #endif

                //间接光漫反射
                // half3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * dif_tex.rgb;  //unity内置全局环境光获取方法
                #ifdef _SDRFCHECK_ON
                half3 ambient_layer = ShadeSH9(float4(normal_Dir,1.0)) * base_color * halfLambert;
                #else
                half3 ambient_layer = half3(0.0,0.0,0.0);
                #endif

                //间接光镜面反射
                reflect_Dir = rotateAngleByArc(_cubeRotate,reflect_Dir);
                float4 cube_map = texCUBElod(_cubeMap,float4(reflect_Dir,_cubeMapMip)); //用法复杂，第二个参数需要填入视线镜像向量以及mipmap采样值
                half3 cube_map_de = DecodeHDR(cube_map,_cubeMap_HDR); // 高清解码，确保适配移动平台
                // //unity reflection probe 
                // float4 unity_env_map = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,reflect_view_dr);
                // half3 unity_env_map_de = DecodeHDR(unity_env_map,unity_SpecCube0_HDR); // 高清解码，确保适配移动平台

                #ifdef _IBLCHECK_ON
                half3 cube_layer = cube_map_de * specular_color * halfLambert * (1 - skinArea);
                #else
                half3 cube_layer = half3(0.0,0.0,0.0);
                #endif


                //最终输出
                half3 final_layer = dif_layer + spec_layer + ambient_layer + cube_layer;
                // final_layer = ACES_Tonemapping(final_layer);
                final_layer = pow(final_layer,1.0/2.2);

                return half4(final_layer,1.0);
           
            }
            ENDCG
            
        }

    }
    FallBack "Diffuse"  //重要，有该句才能对全局声明执行绘制shadowmap操作
}
