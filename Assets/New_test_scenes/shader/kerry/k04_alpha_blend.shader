// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "kerry/alpha_blend" {
    Properties{
        _tex_a("tex",2D) = "" {}
        _color_a("Main Color",Color) = (1.0,0.0,0.0,0.0)
        _emiss("Emissive",float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode",float) = 2
    }
    SubShader {
        Tags {"Queue" = "Transparent"}
        pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            //Blend SrcAlpha One
            Cull [_CullMode]  //背面裁切模式

            CGPROGRAM   // 万物起始之处
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            float4 _color_a;
            sampler2D _tex_a;
            float4 _tex_a_ST;
            float _emiss;

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert (appdata v) 
            {
                v2f o;
                // M V P 
                // float4 pos_ws = mul(unity_ObjectToWorld,v.vertex) ; //获取传入vertex局部坐标，转为世界
                // float4 pos_view = mul(UNITY_MATRIX_V,pos_ws) ; // 转换世界vertex位置到相机矩阵
                // float4 pos_clip = mul(UNITY_MATRIX_P,pos_view) ; //转换相机矩阵下的vertex投射到裁切空间
                // o.pos = pos_clip;
                o.pos = UnityObjectToClipPos(v.vertex);   // 新版 mvp集合
                o.uv = v.uv * _tex_a_ST.xy + _tex_a_ST.zw;  // 贴图offset插槽计算关联
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
                float3 col = _color_a.xyz * _emiss;
                float alpha = saturate(tex2D(_tex_a,i.uv).r * _emiss);
                return float4(col,alpha);
            }

            ENDCG
        }
    }
}