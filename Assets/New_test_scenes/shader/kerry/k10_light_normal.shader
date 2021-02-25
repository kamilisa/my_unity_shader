Shader "kerry/light_normal"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        _specMask("SpecularMask",2D) = "white"{}
        _specPow ("SpecularPow", float) = 1
        _specIntensity ("SpecularIntensity", float) = 1
        _NormalMap("NormalMap" ,2D) = "bump" {}
        _NormalIntensity("NormalIntensity",float) = 1
        _aotex   ("AO_tex", 2D) = "white" { }
        _aoIntensity ("AO_intensity",float) = 1
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
            //开启多线程编译模式 - 光照标配
            #pragma multi_compile_fwdbase_fullshadows
            #include "UnityCG.cginc"
            //导入光照相关方法头文件
            #include "AutoLight.cginc"
            
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
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LightColor0; //头文件带的光线颜色变量，需要先定义再使用
            float _specPow;
            float _specIntensity;
            sampler2D _aotex;
            float4 _aotex_ST;
            float _aoIntensity;
            sampler2D _NormalMap;
            float _NormalIntensity;
            sampler2D _specMask;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);   //特殊uv和贴图绑定方法，能快速映射所有贴图的tilling
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
                half4 dif_tex = tex2D(_MainTex,i.uv);
                half4 ao_tex = tex2D(_aotex,i.uv) * _aoIntensity;
                half4 normal_tex = tex2D(_NormalMap,i.uv);   // normal层，新知识点
                half3 normal_data = UnpackNormal(normal_tex); //解码被执行过normal压缩格式的normal图
                half4 spec_mask = tex2D(_specMask,i.uv);

                //准备向量
                #if defined (DIRECTIONAL)
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz);
                half attuenation = 1.0;
                #elif defined (POINT)
                //point light
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz - i.pos_ws);
                half3 distance = length(_WorldSpaceLightPos0.xyz - i.pos_ws);
                half range_value = 1.0 / unity_WorldToLight[0][0];
                half attuenation = 1/1+pow(distance,2);   //点光源衰减定义
                #endif
                half3 normal_Dir = normalize(i.normal_ws);
                half3 tangent_Dir = normalize(i.tangent_ws);
                half3 binormal_Dir = normalize(i.binormal_ws);
                half3 view_Dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);
                half3 reflect_Dir = normalize(reflect(-light_Dir,normal_Dir));  //求灯光镜像向量，计算高
                half3 halfPhone_Dir = normalize(light_Dir + view_Dir);
                // float3x3 TBN = float3x3(tangent_Dir,binormal_Dir,normal_Dir);
                // normal_Dir = normalize(mul(normal_data.xyz,TBN));
                normal_Dir = normalize(tangent_Dir * normal_data.x * _NormalIntensity + binormal_Dir * normal_data.y *_NormalIntensity + normal_Dir * normal_data.z);

                //常用点乘
                half NdotL = max(0,dot(normal_Dir,light_Dir)); // lambert
                half RdotV = max(0,dot(reflect_Dir,view_Dir)); // phone spec
                half NdotH = max(0,dot(normal_Dir,halfPhone_Dir)); //half specular

                //基础层和阴影混合
                half NdotL_shadow = min(atte,NdotL);

                //准备层
                half3 dif_layer = NdotL_shadow * dif_tex.xyz * _LightColor0.xyz * attuenation;
                half3 spec_layer = pow(NdotH,_specPow) * NdotL_shadow * _specIntensity * spec_mask.rgb * _LightColor0.xyz * attuenation;
                // half3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * dif_tex.rgb;  //unity内置全局环境光获取方法
                half3 ambient_color = ShadeSH9(float4(normal_Dir,1.0)) * dif_tex.rgb;

                //输出层
                half3 final_layer = (dif_layer + spec_layer + ambient_color) * ao_tex;   // 点光源pass要去掉其中的环境光影响

                return half4(final_layer,1.0);
           
            }
            ENDCG
            
        }

        //第二pass，补全多光源环境的计算，主要应对点光源
        Pass
        {
            Blend One One
            Tags { "LightMode" = "ForwardAdd" } //声明pass作用类型，前向渲染基本层，或平行光作用层
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            //开启多线程编译模式 - 光照标配
            #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            //导入光照相关方法头文件
            #include "AutoLight.cginc"
            
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
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LightColor0; //头文件带的光线颜色变量，需要先定义再使用
            float _specPow;
            float _specIntensity;
            sampler2D _aotex;
            float4 _aotex_ST;
            float _aoIntensity;
            sampler2D _NormalMap;
            float _NormalIntensity;
            sampler2D _specMask;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);   //特殊uv和贴图绑定方法，能快速映射所有贴图的tilling
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_ws = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangent_ws = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.binormal_ws = normalize(cross(o.normal_ws,o.tangent_ws)) * v.tangent.w;
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                //shadow
                float atte = LIGHT_ATTENUATION(i);


                //准备贴图
                half4 dif_tex = tex2D(_MainTex,i.uv);
                half4 ao_tex = tex2D(_aotex,i.uv) * _aoIntensity;
                half4 normal_tex = tex2D(_NormalMap,i.uv);   // normal层，新知识点
                half3 normal_data = UnpackNormal(normal_tex); //解码被执行过normal压缩格式的normal图
                half4 spec_mask = tex2D(_specMask,i.uv);

                //准备向量
                #if defined (DIRECTIONAL)
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz);
                half attuenation = 1.0;
                #elif defined (POINT)
                //point light
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz - i.pos_ws);
                half3 distance = length(_WorldSpaceLightPos0.xyz - i.pos_ws);
                half range_value = 1.0 / unity_WorldToLight[0][0];
                half attuenation = saturate(1/(1+pow(distance,2)));   //点光源衰减定义
                #endif
                half3 normal_Dir = normalize(i.normal_ws);
                half3 tangent_Dir = normalize(i.tangent_ws);
                half3 binormal_Dir = normalize(i.binormal_ws);
                half3 view_Dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);
                half3 reflect_Dir = normalize(reflect(-light_Dir,normal_Dir));  //求灯光镜像向量，计算高
                half3 halfPhone_Dir = normalize(light_Dir + view_Dir);
                // float3x3 TBN = float3x3(tangent_Dir,binormal_Dir,normal_Dir);
                // normal_Dir = normalize(mul(normal_data.xyz,TBN));
                normal_Dir = normalize(tangent_Dir * normal_data.x * _NormalIntensity + binormal_Dir * normal_data.y *_NormalIntensity + normal_Dir * normal_data.z);

                //常用点乘
                half NdotL = max(0,dot(normal_Dir,light_Dir)); // lambert
                half RdotV = max(0,dot(reflect_Dir,view_Dir)); // phone spec
                half NdotH = max(0,dot(normal_Dir,halfPhone_Dir)); //half specular

                //基础层和阴影混合
                half NdotL_shadow = min(atte,NdotL);   

                //准备层
                half3 dif_layer = NdotL_shadow * dif_tex.xyz * _LightColor0.xyz * attuenation;
                half3 spec_layer = pow(NdotH,_specPow) * NdotL_shadow * _specIntensity * spec_mask.rgb * _LightColor0.xyz * attuenation;
                // half3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * dif_tex.rgb;  //unity内置全局环境光获取方法

                //输出层
                half3 final_layer = (dif_layer + spec_layer) * ao_tex;   // 点光源pass要去掉其中的环境光影响

                return half4(final_layer,1.0);
           
            }
            ENDCG
            
        }


    }
    FallBack "Diffuse"  //重要，有该句才能对全局声明执行绘制shadowmap操作
}
