Shader "kerry/k28_toon_gbvs"
{
    Properties
    {
        [Header(Maps)]
        _BaseMap ("BaseMap", 2D) = "white" {}
        _SSSMap ("SSSMap", 2D) = "black" {}
        _ILM("LightMap",2D) = "grey" {}
        _DetailMap("DetailMap",2D) = "white" {}
        [Header(Attr)]
        _ToonthresHold("ToonthresHold",range(0,1)) = 0.5
        _ToonHardness("ToonHardness",Float) = 20
        _spec_size_value("SpecSizeValue",range(0,1)) = 0.5
        [Header(Rim)]
        _RimHold("RimHold", range(0,1)) = 0.18
        _RimHardness("RimHardness",Float) = 20
        _Rim_Color_weight("Rim_Color_weight", range(0,2)) = 1
        [Header(OutLine)]
        _Outline("Outlinewidth",Float) = 0.001
        _OutLineColor("OutLineColor",Color) = (1,1,1,1)

        [Header(Check Area)]
        [Toggle(_RIMLIGHT_ON)] _RimCheck("RimLight check",float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //Main pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma shader_feature _RIMLIGHT_ON
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 color : COLOR;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 normal_ws: TEXCOORD1;
                float3 pos_ws: TEXCOORD2;
                float4 vertex_color : TEXCOORD3;
            };

            sampler2D _BaseMap;
            sampler2D _SSSMap;
            sampler2D _ILM;
            sampler2D _DetailMap;
            half _ToonHardness;
            half _ToonthresHold;
            half _spec_size_value;
            half _RimHold;
            half _RimHardness;
            half _Rim_Color_weight;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_ws = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.vertex_color.rgb = v.color;
                o.uv = float4(v.uv,v.uv1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // uv set
                half2 uv1 = i.uv.xy;
                half2 uv2 = i.uv.zw;

                // sample the texture
                half4 basemap = tex2D(_BaseMap, uv1);
                half4 sssmap = tex2D(_SSSMap, uv1);
                half4 ILM_map = tex2D(_ILM, uv1);
                half4 detailmap = tex2D(_DetailMap, uv2); //更细一级的内描线是画在uv2上的

                // ILM split
                half spec_inc = ILM_map.r;
                half shadow_offset = ILM_map.g;
                half spec_size = ILM_map.b;
                half inner_line = ILM_map.a;

                // AO
                half ao = i.vertex_color.r;  //存放于顶点色通道的AO

                // vector
                half3 light_Dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 normal_Dir = normalize(i.normal_ws);
                half3 view_Dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);

                // dot
                half NdotL = dot(normal_Dir,light_Dir); // lambert,不要max函数，否则后续半兰伯特会暴白
                half NdotV = dot(normal_Dir,view_Dir); //fresnel

                // 漫反射
                half half_lambert = (NdotL + 1.0) * 0.5;
                shadow_offset = shadow_offset * 2.0- 1.0; //将中灰度原始结果缩放到0-1区间
                half lambert_edit = half_lambert * ao + shadow_offset; //叠加了AO的半兰伯特，且进行了阴影偏移
                // half toon_light = step(0.5,half_lambert);
                half toon_light = saturate((lambert_edit - _ToonthresHold) * _ToonHardness);
                half3 final_color = lerp(sssmap.rgb,basemap.rgb,toon_light);

                //高光
                half spec_offset = NdotV * ao + shadow_offset;
                half spec_term = half_lambert * 0.7 + spec_offset * 0.3;
                half toon_spec = saturate((spec_term - (1.0 - _spec_size_value * spec_size)) * 500);
                toon_spec = toon_spec * spec_inc;
                half3 final_spec = basemap.rgb * toon_spec;

                //RimLight边缘光
                half rim_fresnel = 1 - saturate((NdotV - _RimHold) * _RimHardness);
                half rim_light = rim_fresnel * max(0,NdotL) * ao;
                half3 rim_color = basemap.rgb * rim_light.xxx * _Rim_Color_weight;

                //描线
                half3 line_color = inner_line.xxx * detailmap.xyz;

                //合并层
                #ifdef _RIMLIGHT_ON
                half3 final_layer = (final_color + final_spec + rim_color) * line_color;
                #else
                half3 final_layer = (final_color + final_spec) * line_color;
                #endif

                return float4(final_layer,1.0);
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
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _BaseMap;
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
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // uv set
                half2 uv1 = i.uv;

                // sample the texture
                half3 basemap = tex2D(_BaseMap, uv1).rgb;
                half maxComponent = max(max(basemap.r,basemap.g),basemap.b) - 0.004;
                half3 saturatedColor = step(maxComponent.rrr,basemap) * basemap;
                saturatedColor = lerp(basemap.rgb,saturatedColor,0.6);
                half3 outLineColor = 0.8 * saturatedColor * basemap * _OutLineColor.xyz;

                return float4(outLineColor,1.0);
            }
            ENDCG
        }

    }
}
