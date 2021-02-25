Shader "kerry/k09_stencil_mirror"
{
    Properties
    {
        _mainColor ("MainColor", Color) = (1.0,0.0,0.0,0.0)
        _alpha_tex("tex",2D) = "white" {}

    }
    SubShader
    {
        Tags { "Queue"="AlphaTest+10" }  // 修改渲染队列为 2460  2450为alpha test段
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off   // 深度写入 关闭 ，不对深度遮挡占位
            // ColorMask 0  // 色彩蒙版，rgb关闭，不输出色彩
            Stencil{      // 模板测试 ，id1 对比方法 总是  通过后执行 覆盖写入模板测试
                Ref 1
                Comp Always
                pass replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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

            float4 _mainColor;
            sampler2D _alpha_tex;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;  // 贴图offset插槽计算关联
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float alpha = tex2D(_alpha_tex,i.uv).r;
                return float4(_mainColor.rgb,alpha);
            }
            ENDCG
        }
    }
}
