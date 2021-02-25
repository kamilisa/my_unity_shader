Shader "AP01/L17/backgroundNoise" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2d) = "gray"{}
        _Opacity ("透明度", range(0, 1)) = 0.5
        _wrapMidVar("扰动补全值",range(0,1)) = 0.5
        _wrapInt("扰动强度",range(0,1)) = 0.2
    }
    SubShader {
        Tags {
            "Queue"="Transparent"               // 调整渲染顺序
            "RenderType"="Transparent"          // 对应改为Cutout
            "ForceNoShadowCasting"="True"       // 关闭阴影投射
            "IgnoreProjector"="True"            // 不响应投射器
        }

        GrabPass{

            "_BGTex"
        }

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One OneMinusSrcAlpha          // 修改混合方式One/SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            // 输入参数
            sampler2D _MainTex;
            sampler2D _BGTex;
            half _Opacity;
            half _wrapMidVar;
            half _wrapInt;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
                float4 grabPos : TEXCOORD1;     // grab需要存储的位置
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                    o.pos = UnityObjectToClipPos( v.vertex);    // 顶点位置 OS>CS
                    o.uv = v.uv;       // UV信息 支持TilingOffset
                    o.grabPos = ComputeGrabScreenPos(o.pos); //传入裁剪空间的顶点位置计算后面的抓取背景
                return o;
            }
            // 输出结构>>>像素
            half4 frag(VertexOutput i) : COLOR {
                half4 var_MainTex = tex2D(_MainTex, i.uv);      // 采样贴图 RGB颜色 A透贴
                i.grabPos += (var_MainTex.b - _wrapMidVar) * _wrapInt * _Opacity;
                half3 var_bgTex = tex2Dproj(_BGTex,i.grabPos);  //采样存储的背景映射图
                half3 finalRGB = var_MainTex.rgb * var_bgTex;
                half opacity = var_MainTex.a * _Opacity;
                return half4(finalRGB * opacity,opacity);                // 返回值
            }
            ENDCG
        }
    }
}