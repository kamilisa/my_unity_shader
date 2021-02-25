Shader "kerry/k09_skybox_stencil"
{
    Properties
    {
        _mainColor ("MainColor", Color) = (1.0,0.0,0.0,0.0)

    }
    
    SubShader
    {
        Tags { "Queue"="AlphaTest+15" }  // 修改渲染队列为 2460  2450为alpha test段
        LOD 100
        Pass
        {
            ZTest Always
            Stencil{      // 模板测试 ，id1 对比方法 
                Ref 1
                Comp Equal
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float4 _mainColor;


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _mainColor;
            }
            ENDCG
        }
    }
}
