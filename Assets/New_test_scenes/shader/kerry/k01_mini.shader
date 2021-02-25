// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "kerry/test" {
    Properties{
        _float_a("float",float) = 0.0
        _range_a("slider",range(0.0,99.0)) = 0.0
        _vector_a("vector",vector) = (1,1,1)
        _color_a("color",Color) = (1.0,0.0,0.0,0.0)
        _tex_a("tex",2D) = "white" {}
    }
    SubShader {
        pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            float4 _color_a;
            sampler2D _tex_a;
            float4 _tex_a_ST;

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
                o.pos = UnityObjectToClipPos(v.vertex); 
                o.uv = v.uv * _tex_a_ST.xy + _tex_a_ST.zw;
                return o;
            }

            float4 frag (v2f i) : SV_TARGET
            {
                float4 tex_map = tex2D(_tex_a,i.uv);
                return tex_map;
            }

            ENDCG
        }
    }
}