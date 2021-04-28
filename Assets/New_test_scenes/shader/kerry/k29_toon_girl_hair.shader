Shader "kerry/k29_toon_girl_hair"
{
    Properties
    {
        [Header(Maps_Region)]
        _BaseTex ("DiffuseMap", 2D) = "white" {}
        _AoTex ("AoMap", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _RampMap ("Ramp", 2D) = "white" {}
        _SpecMap ("SpecMap", 2D) = "white" {}
        [Header(Tints_Region)]
        _TintLayer1("TintLayer1",Color) = (1.0,1.0,1.0,1.0)
        _TintOffset1("TintOffset1",range(-1,1)) = 1
        _TintHardness1("TintHardness1",range(0,1)) = 0
        _TintLayer2("TintLayer2",Color) = (1.0,1.0,1.0,1.0)
        _TintOffset2("TintOffset2",range(-1,1)) = 1
        _TintHardness2("TintHardness2",range(0,1)) = 0
        _TintLayer3("TintLayer3",Color) = (1.0,1.0,1.0,1.0)
        _TintOffset3("TintOffset3",range(-1,1)) = 1
        _TintHardness3("TintHardness3",range(0,1)) = 0
        [Header(Spec_Region)]
        _SpecColor("Spec Color",Color) = (1.0,1.0,1.0,1.0)
        _SpecIntensity("Spec Intensity",float) = 1
        _SpecShininess("Spec Shininess",range(0,1)) = 0.1
        [Header(Rim_Region)]
        _EnvMap("Env Map", Cube) = "_Skybox" {}
        _EnvRotate("Env rotate",range(0,360)) = 0
        _Envintensity("Env intensity",range(0,1)) = 0
        _Roughness("EnvRoughness",Range(0,7)) = 0
        _FresnelMin("FresnelMin",float) = 0.5
        _FresnelMax("FresnelMax",float) = 1
        [Header(OutLine_Region)]
        _Outline("Outlinewidth",Float) = 0.001
        _OutLineColor("OutLineColor",Color) = (1,1,1,1)

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
            sampler2D _AoTex;
            sampler2D _NormalMap;
            sampler2D _RampMap;
            sampler2D _SpecMap;
            half3 _TintLayer1;
            half _TintOffset1;
            half _TintHardness1;
            half3 _TintLayer2;
            half _TintOffset2;
            half _TintHardness2;
            half3 _TintLayer3;
            half _TintOffset3;
            half _TintHardness3;
            float3 _SpecColor;
            half _SpecIntensity;
            half _SpecShininess;
            half _FresnelMin;
            half _FresnelMax;
            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            half _Envintensity;
            half _EnvRotate;
            half _Roughness;

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
                
                // sample the texture
                half3 baseColor = tex2D(_BaseTex, i.uv).rgb;
                half ao_Color = tex2D(_AoTex, i.uv).r;
                half4 specMap = tex2D(_SpecMap, i.uv);
                half spec_mask = specMap.a;
                half spec_smoothness = specMap.a;
                half3 normal_data = UnpackNormal(tex2D(_NormalMap,i.uv));   // normal贴图load加解包
                float3x3 TBN = float3x3(tangent_Dir,binormal_Dir,normal_Dir);
                normal_Dir = normalize(mul(normal_data.xyz,TBN)); //最终法线向量
                half3 reflect_Dir = normalize(reflect(-light_Dir,normal_Dir));  //求灯光镜像向量，计算高，必须放到法线贴图后算

                //常用光照模型
                half NdotL = dot(normal_Dir,light_Dir);
                half NdotH = dot(normal_Dir,halfPhone_Dir);
                half TdotH = dot(tangent_Dir,halfPhone_Dir);
                half NdotV = dot(normal_Dir,view_Dir);
                half half_lambert = (NdotL + 1.0) * 0.5;
                half BdotH = dot(binormal_Dir,halfPhone_Dir);
   
                //漫反射
                half diffuse_term = half_lambert * ao_Color;

                //第一层直射光阴影
                half2 uv_ramp1 = half2(saturate(diffuse_term + _TintOffset1),_TintHardness1);
                half toon_diffuse1 = tex2D(_RampMap, uv_ramp1).r;
                half3 tint_color1 = lerp(half3(1,1,1),_TintLayer1.rgb,toon_diffuse1);

                //第二层直射光阴影
                half2 uv_ramp2 = half2(saturate(diffuse_term + _TintOffset2),_TintHardness2);
                half toon_diffuse2 = tex2D(_RampMap, uv_ramp2).g;
                half3 tint_color2 = lerp(half3(1,1,1),_TintLayer2.rgb,toon_diffuse2);

                //第三层直射光阴影
                half2 uv_ramp3 = half2(saturate(diffuse_term + _TintOffset3),_TintHardness3);
                half toon_diffuse3 = tex2D(_RampMap, uv_ramp3).b;
                half3 tint_color3 = lerp(half3(1,1,1),_TintLayer3.rgb,toon_diffuse3);

                half3 final_diffuse = baseColor * tint_color1 * tint_color2 * tint_color3;

                //直射光镜面反射
                half BdotH_edit = BdotH / _SpecShininess;
                half spec_term = exp(-(TdotH * TdotH + BdotH_edit * BdotH_edit) / (1.0 + NdotH));
                float spec_atten = saturate(sqrt(max(0.0, half_lambert / NdotV)));
                half3 spec_layer = spec_term * spec_atten * _SpecColor * _SpecIntensity * spec_mask;

                //边缘光
                half fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_FresnelMin,_FresnelMax,fresnel);
                float roughness = lerp(0.0,0.95,saturate(_Roughness));
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                reflect_Dir = rotateAngleByArc(_EnvRotate,reflect_Dir);
                half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_Dir,mip_level));
                half3 env_color = DecodeHDR(color_cubemap,_EnvMap_HDR); // 高清解码，确保适配移动平台
                half3 env_layer = env_color * fresnel * _Envintensity * spec_mask;

                half3 final_layer = final_diffuse + spec_layer + env_layer;
                half final_alpha = max(0.5,i.vertexColor.a);

                return half4(final_layer,final_alpha);
            }
            ENDCG
        }


        //OutLine pass
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : TEXCOORD1;
            };

            sampler2D _BaseTex;
            float _Outline;
            float4 _OutLineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 pos_ws = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 normal_ws = UnityObjectToWorldNormal(v.normal);
                pos_ws += normal_ws * _Outline;
                o.pos = mul(UNITY_MATRIX_VP,float4(pos_ws,1.0));
                o.uv = v.uv;
                o.vertexColor = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half3 basemap = tex2D(_BaseTex, i.uv).rgb;
                half maxComponent = max(max(basemap.r,basemap.g),basemap.b) - 0.004;
                half3 saturatedColor = step(maxComponent.rrr,basemap) * basemap;
                saturatedColor = lerp(basemap.rgb,saturatedColor,0.6);
                half3 outLineColor = 0.8 * saturatedColor * basemap * _OutLineColor.xyz;
                half final_alpha = max(0.5,i.vertexColor.a);

                return float4(outLineColor,1.0);
            }
            ENDCG
        }

    }
    FallBack "Diffuse"  //重要，有该句才能对全局声明执行绘制shadowmap操作
}
