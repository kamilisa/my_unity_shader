Shader "kerry/rim_light" {
    Properties{
        _tex_a("tex",2D) = "" {}
        _color_a("Main Color",Color) = (1.0,0.0,0.0,0.0)
        _emiss("Emissive",float) = 1
        _power("Power",float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode",float) = 2
    }
    SubShader {
        Tags {"Queue" = "Transparent"}

        pass {
            Cull Off
            ZWrite On
            ColorMask 0
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _Color_pre;

            float4 vert (float4 VertexPos : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(VertexPos);
            }

            float4 frag (void) : COLOR {
                return _Color_pre;
            }

            ENDCG
        }

        pass {
            Cull [_CullMode]  //背面裁切模式
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha
            Blend SrcAlpha One

            CGPROGRAM   // 万物起始之处
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            float4 _color_a;
            sampler2D _tex_a;
            float _emiss;
            float _power;

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD;
                float3 normal : NORMAL;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_ws : TEXCOORD1;
                float3 camera_v : TEXCOORD2;
            };


            v2f vert (appdata v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);   // 新版 mvp集合
                o.normal_ws = normalize(UnityObjectToWorldNormal(v.normal));  // 局部normal转世界normal
                float3 pos_ws = mul(unity_ObjectToWorld,v.vertex);  
                o.camera_v = normalize(_WorldSpaceCameraPos.xyz - pos_ws); // 获取相机向量
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
                //准备向量
                float3 nromal_ws = normalize(i.normal_ws);
                float3 camera_ws = normalize(i.camera_v);

                //点乘
                float NdotV = saturate(dot(nromal_ws,camera_ws)) ;
                float3 color = _color_a.xyz * _emiss;
                float pow_ac = pow(1 - NdotV,_power);
                float alpha = saturate(pow_ac * _emiss);

                return float4(color,alpha);
            }
            ENDCG
        }
    }
}