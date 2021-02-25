Shader "Hidden/k21_customBloom"
{
    CGINCLUDE

    #include "UnityCG.cginc"                
    sampler2D _MainTex;
    sampler2D _BloomTex;
    float4 _MainTex_TexelSize;
    float _threshold;
    float _intensity;

    half4 frag_prefilter (v2f_img i) : SV_Target
    {
        half4 color = tex2D(_MainTex,i.uv);
        float br = max(max(color.r,color.g),color.b);
        br = max(0.0f,(br - _threshold)) / max(br,0.0000001f);
        color.rgb *= br;
        return color;
    }

    half4 frag_reduceBlur (v2f_img i) : SV_Target
    {
        half4 d = _MainTex_TexelSize.xyxy * half4(-1,-1,1,1);
        half4 s = 0;
        s += tex2D(_MainTex,i.uv + d.xy);
        s += tex2D(_MainTex,i.uv + d.zy);
        s += tex2D(_MainTex,i.uv + d.xw);
        s += tex2D(_MainTex,i.uv + d.zw);
        s *= 0.25;
        return s;
    }

    half4 frag_extendBlur (v2f_img i) : SV_Target
    {
        half4 d = _MainTex_TexelSize.xyxy * half4(-1,-1,1,1);
        half4 color = 0;
        color += tex2D(_MainTex,i.uv + d.xy);
        color += tex2D(_MainTex,i.uv + d.zy);
        color += tex2D(_MainTex,i.uv + d.xw);
        color += tex2D(_MainTex,i.uv + d.zw);
        color *= 0.25;
        half4 bloom = tex2D(_BloomTex,i.uv);
        return color + bloom;
    }

    half4 frag_combinePass (v2f_img i) : SV_Target
    {
        half4 color = tex2D(_MainTex,i.uv);
        half4 bloom = tex2D(_BloomTex,i.uv);
        half3 final = color.rgb + bloom.rgb * _intensity;
        return half4(final,1.0);
    }

    ENDCG

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _threshold("threshold",float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off 
        ZWrite Off 
        ZTest Always

        //0 pass 阈值抠出mask
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_prefilter
            ENDCG
        }

        //1 pass 降采样 模糊
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_reduceBlur
            ENDCG
        }

        //2 pass 生采样 模糊
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_extendBlur
            ENDCG
        }

        //3 pass 整体结果合并
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_combinePass
            ENDCG
        }
    }
}
