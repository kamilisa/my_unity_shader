Shader "AP01/L17/ScreenProjection" {
    Properties {
        _MainTex ("RGB：颜色 A：透贴", 2d) = "gray"{}
        _Mask("流动透贴",2D) = "white"{}
        _Opacity ("透明度", range(0, 1)) = 0.5

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
            Blend One OneMinusSrcAlpha          // 修改混合方式One/SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            // 输入参数
            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
            uniform half _Opacity;
            uniform sampler2D _Mask; 
            uniform float4 _Mask_ST;
            // 输入结构
            struct VertexInput {
                float4 vertex : POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
            };
            // 输出结构
            struct VertexOutput {
                float4 pos : SV_POSITION;       // 顶点位置 总是必要
                float2 uv : TEXCOORD0;          // UV信息 采样贴图用
                float2 screenUV : TEXCOORD1;    // 屏幕空间UV
            };
            // 输入结构>>>顶点Shader>>>输出结构
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                    o.pos = UnityObjectToClipPos( v.vertex);    // 顶点位置 OS>CS
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);       // UV信息 支持TilingOffset
                    float3 posVS = UnityObjectToViewPos(v.vertex).xyz;      // 顶点位置 OS>VS
                    float origendict = UnityObjectToViewPos(float3(0.0,0.0,0.0)).z;     // 原点位置 OS>VS
                    o.screenUV = posVS.xy / posVS.z;            // VS空间畸变校正
                    o.screenUV *= origendict;                   // 纹理大小按距离锁定
                    o.screenUV = o.screenUV * _Mask_ST.xy + frac(_Time.y * _Mask_ST.zw);    // 启用屏幕纹理ST
                return o;
            }
            // 输出结构>>>像素
            half4 frag(VertexOutput i) : COLOR {
                half var_mask = tex2D(_Mask,i.screenUV).r;       // 投射贴图
                half4 var_MainTex = tex2D(_MainTex, i.uv);      // 采样贴图 RGB颜色 A透贴
                half opacity = var_MainTex.a * _Opacity * var_mask.r;
                return half4(var_MainTex.rgb * opacity,opacity); //必须rgb预乘alpha，否则透贴无效
            }
            ENDCG
        }
    }
}