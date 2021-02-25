Shader "kerry/k07_matCap"
{
    Properties
    {
        _matCap_inner ("matcap_In", 2D) = "white" {}
        _matCap_inner_int("matcap_In_intensity",float) = 1
        _mainTex ("MainTex", 2D) = "white" {}
        _ramp_tex ("Ramp", 2D) = "white" {}
        _matCap_out ("matcap_Out", 2D) = "white" {}
        _matCap_out_int("matcap_Out_intensity",float) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_ws : TEXCOORD1;
                float4 pos_ws : TEXCOORD2;
            };

            sampler2D _matCap_inner;
            float4 _matCap_inner_ST;
            float _matCap_inner_int;
            sampler2D _mainTex;
            sampler2D _ramp_tex;
            sampler2D _matCap_out;
            float _matCap_out_int;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal_ws = normalize(mul(float4(v.normal,0.0),unity_WorldToObject));
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // prepare vector
                half NdotV = dot(normalize(i.normal_ws),normalize((_WorldSpaceCameraPos.xyz - i.pos_ws)));
                half3 view_normal = normalize(mul(UNITY_MATRIX_V,i.normal_ws));

                // matCap_in
                half2 uv_value = (view_normal.xy + 1) * 0.5;
                float4 mat_a = tex2D(_matCap_inner,uv_value);
                float4 mat_a_layer = mat_a * _matCap_inner_int;

                // main_tex
                float4 main_tex = tex2D(_mainTex, i.uv);

                //ramp tex
                float4 ramp_tex = tex2D(_ramp_tex,float2(NdotV,0.1));

                //matCap_out
                float4 mat_b = tex2D(_matCap_out,uv_value);
                float4 mat_b_layer = mat_b * _matCap_out_int;

                // final output
                float4 final_layer = mat_a_layer * main_tex * ramp_tex + mat_b_layer;

                return final_layer;
            }
            ENDCG
        }
    }
}
