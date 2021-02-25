Shader "Hidden/k22_ACES_tonemapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off 
        ZWrite Off 
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"                
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            //ACES_ToneMapping
            float3 ACES_Tonemapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                float3 encode_color = saturate((x*(a*x + b)) / (x*(c*x + d) + e));
                return encode_color;
            }

            half4 frag (v2f_img i) : SV_Target
            {
                float4 color = tex2D(_MainTex,i.uv);
                float3 colorLine = pow(color.rgb,2.2);
                float3 ACES = ACES_Tonemapping(colorLine);
                float3 colorDecode = pow(ACES,1.0/2.2);
                return float4(colorDecode,1.0);
            }

            ENDCG
        }
    }
}
