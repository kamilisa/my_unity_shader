Shader "kerry/flow_code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTexBias ("MainTexBias",float) = 4
        _RimMin ("RimMin",float) = 0
        _RimMax ("RimMax",float) = 0
        _FlowSpeed("FlowSpeed",vector) = (0.0,1.0,0.0,0.0)
        _FlowTex ("FlowTex", 2D) = "white" {}
        _RimIn("Rim In Color",Color) = (1.0,0.0,0.0,0.0)
        _RimOut("Rim Out Color",Color) = (1.0,0.0,0.0,0.0)
    }
    SubShader
    {
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

        Pass
        {
            ZWrite Off
            Blend SrcAlpha One
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
                float3 pos_ws : TEXCOORD2;
                float3 pos_pivot : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MainTexBias;
            float _RimMin;
            float _RimMax;
            float4 _FlowSpeed;
            sampler2D _FlowTex;
            float4 _FlowTex_ST;
            float4 _RimIn;
            float4 _RimOut;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_ws = normalize(UnityObjectToWorldNormal(v.normal));  // 局部normal转世界normal
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex);  
                o.pos_pivot = mul(unity_ObjectToWorld,float4(0.0,0.0,0.0,1.0));
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //准备向量
                half3 normal_vec = normalize(i.normal_ws);
                half3 pos_ws = i.pos_ws;
                half3 pivot = i.pos_pivot;
                half3 view_vec = normalize(_WorldSpaceCameraPos.xyz - pos_ws);
                // half3 pivot_sp = mul(unity_ObjectToWorld,float4(0.0,0.0,0.0,1.0));

                //菲涅尔层
                half NdotV = saturate(dot(normal_vec,view_vec));
                half fresnel = 1 - NdotV;
                fresnel = smoothstep(_RimMin,_RimMax,fresnel);
                float4 MainTex = pow(tex2D(_MainTex,i.uv),_MainTexBias);
                half fresnel_layer = saturate(fresnel + MainTex.r); 

                //流动层
                half3 pivot_offset = pos_ws - pivot;
                half2 flow_speed = pivot_offset.xy + _FlowSpeed.xy * _Time.y;
                float4 flowTex = tex2D(_FlowTex,flow_speed);

                //主体颜色
                float4 main_color_layer = lerp(_RimIn,_RimOut,fresnel_layer);
                main_color_layer = main_color_layer + flowTex;

                //ALPHA
                half alpha = saturate(fresnel_layer + flowTex.a);

                return float4(main_color_layer.rgb,alpha);
            }
            ENDCG
        }
    }
}
