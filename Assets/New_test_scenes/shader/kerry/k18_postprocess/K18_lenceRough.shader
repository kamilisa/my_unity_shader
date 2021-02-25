﻿Shader "kerry/K18_lenceRough"
{
    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _BlurOffset;
    // float4 _MainTex_TexelSize;
    //x = 1/width  y = 1/height z = width w = height

    half4 frag_boxfilter_4tap (v2f_img i) : SV_Target
    {
        half4 d = _BlurOffset.xyxy * half4(-1,-1,1,1);
        half4 s = 0;
        s += tex2D(_MainTex,i.uv + d.xy);
        s += tex2D(_MainTex,i.uv + d.zy);
        s += tex2D(_MainTex,i.uv + d.xw);
        s += tex2D(_MainTex,i.uv + d.zw);
        s *= 0.25;
        return s;
    }

    half4 frag_boxfilter_9tap (v2f_img i) : SV_Target
    {
        half4 d = _BlurOffset.xyxy * half4(-1,-1,1,1);
        half4 s = 0;
        s = tex2D(_MainTex,i.uv);

        s += tex2D(_MainTex,i.uv + d.xy);
        s += tex2D(_MainTex,i.uv + d.zy);
        s += tex2D(_MainTex,i.uv + d.xw);
        s += tex2D(_MainTex,i.uv + d.zw);

        s += tex2D(_MainTex,i.uv + half2(0.0,d.w));
        s += tex2D(_MainTex,i.uv + half2(0.0,d.y));
        s += tex2D(_MainTex,i.uv + half2(d.z,0.0));
        s += tex2D(_MainTex,i.uv + half2(d.x,0.0));

        s = s / 9.0;
        return s;
    }

    ENDCG

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurOffset("BlurOffset",float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off 
        ZWrite Off 
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_boxfilter_4tap
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_boxfilter_9tap
            ENDCG
        }
    }
}
