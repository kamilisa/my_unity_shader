Shader "kerry/k08_growtree"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _grow ("grow", Range(-2.0,2.0)) = 0 
        _growStart ("growStart", float) = 0.77
        _growEnd ("growEnd",float) = 1.0
        _endMin ("endMin", float) = 0.77
        _endMax ("endMax",float) = 1.0
        _expand ("Expand",float) = 1.0
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
            };

            sampler2D _MainTex;
            float _grow;
            float _growStart;
            float _growEnd;
            float _expand;
            float _endMin;
            float _endMax;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                half growMask = smoothstep(_growStart,_growEnd,(v.uv.y - _grow));
                half EndMask = smoothstep(_endMin,_endMax,v.uv.y);
                half3 vertex_offset = v.normal * max(growMask,EndMask) * _expand;
                v.vertex.xyz = v.vertex.xyz + vertex_offset;  // important!!! because v.vertex is float4，so get xyz
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(1 - (i.uv.y - _grow));
                float4 maintex = tex2D(_MainTex,i.uv);
                return maintex;
            }
            ENDCG
        }
    }
}
