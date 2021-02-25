Shader "Hidden/K18_post_shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorShift("ColorShift",float) = 0
        _Brightness("Brightness",float) = 1
        _Saturation("Saturation",float) = 1
        _Contrast("Contrast",float) = 1
        _VignetteIntensity("VignetteIntensity",range(0.05,3.0)) = 1.5
        _VignetteRoundness("VignetteRoundness",range(1.0,6.0)) = 5.0
        _VignetteSmoothness("VignetteSmoothness",range(0.05,5.0)) = 5.0
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
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _ColorShift;
            float _Brightness;
            float _Saturation;
            float _Contrast;
            float _VignetteIntensity;
            float _VignetteRoundness;
            float _VignetteSmoothness;


			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                half3 finalColor = col.rgb;
                //色相偏移
                float3 hsv = RGBToHSV(finalColor);
                hsv.r = hsv.r + _ColorShift;
                finalColor = HSVToRGB(hsv);
                //亮度
                finalColor = finalColor * _Brightness;
                //饱和度
                float lumin = dot(finalColor,float3(0.22,0.707,0.071));
                finalColor = lerp(lumin,finalColor,_Saturation);
                //对比度
                float3 midpoint = float3(0.5,0.5,0.5);
                finalColor = lerp(midpoint,finalColor,_Contrast);
                //暗角/晕影
                float2 d = abs(i.uv - half2(0.5,0.5)) * _VignetteIntensity;
                d = pow(saturate(d),_VignetteRoundness);
                float dist = length(d);
                float vfactor = pow(saturate(1.0 - dist * dist),_VignetteSmoothness);
                finalColor = finalColor * vfactor;

                return float4(finalColor,col.a);
            }
            ENDCG
        }
    }
}
