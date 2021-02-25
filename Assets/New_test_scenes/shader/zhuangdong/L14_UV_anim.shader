Shader "AP01/L14/UV_anim" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2d) = "gray"{}
        _NoiseTex("扰动贴图", 2D) = "gray" {}
        _Opacity ("透明度", range(0, 1)) = 0.5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendSrc ("混合源乘子", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendDst ("混合目标乘子", int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp ("混合算符", int) = 0
        _NoiseInt("扭曲强度",float) = 0.1
        _Slider_test("Slider",range(0,30)) = 1
    }
    SubShader {
        Tags {
            "Queue"="Transparent"               // 调整渲染顺序
            "RenderType"="Transparent"          // 对应改为Cutout
            "ForceNoShadowCasting"="True"       // 关闭阴影投射
            "IgnoreProjector"="True"            // 不响应投射器
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            BlendOp [_BlendOp]                  // 可自定义混合算符
            Blend [_BlendSrc] [_BlendDst]       // 可自定义混合模式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            // 输入参数
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
            uniform sampler2D _NoiseTex;
            uniform float4 _NoiseTex_ST;
            uniform half _Opacity;
            uniform half _Slider_test;
            uniform float _NoiseInt;

            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
            };

            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
                float2 uv1 : TEXCOORD1;  
            };

            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                    o.pos = UnityObjectToClipPos( v.vertex);    // 顶点位置 OS>CS
                    o.uv = v.uv; 
                    o.uv1 = TRANSFORM_TEX(v.uv, _NoiseTex);
                    o.uv1.y = o.uv1.y + frac(_Time.x * _Slider_test);
                return o;
            }

            // 输出结构>>>像素
            half4 frag(VertexOutput i) : COLOR {
                half4 noise_tex = tex2D(_NoiseTex, i.uv1); //利用带动画的UV对 noise贴图进行采样，这样一开局就带Y轴动画
                half2 uvBias = (noise_tex.rg - 0.5) * _NoiseInt; //将扰动贴图的rg通道减0.5拿到正负区间，然后乘以一个扰动强度
                half2 newUV = i.uv + uvBias; //把带动画又被扰动了的最终UV加进原始uv0，作为最终采样UV

                half4 var_MainTex = tex2D(_MainTex, newUV);      // 采样贴图 RGB颜色 A透贴不必须
                half3 finalRGB = var_MainTex.rgb;
                half opacity = var_MainTex.a * _Opacity;
                return half4(finalRGB * opacity, opacity);                // 返回值
            }
            ENDCG
        }
    }
}