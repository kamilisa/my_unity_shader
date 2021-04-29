Shader "kerry/k15_3s_caculate"
{
    Properties
    {
        _mainColor("基础颜色",Color) = (1.0,0.0,0.0,1.0)
        _cubeMap("Cube Map", Cube) = "_Skybox" {}
        _cubeRotate("Cube Rotate", Range(0,360)) = 0
        _fresnelIns("菲涅尔范围", float) = 1
        _fresnelIntensity("菲涅尔强度",float) = 1
        _noiseIns("表面扭曲", float) = 1
        _sssThick ("3S厚度图", 2D) = "white" {}
        _sssThickMapIns("3S厚度图强度", float) = 1
        _sssPower("3S范围pow", float) = 3
        _sssScale("3S亮度", float) = 1
        _sssColor("3S颜色倾向",Color) = (1.0,0.0,0.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "kami_utility.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 pos_ws : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            float4 _mainColor;
            sampler2D _sssThick;
            float4 _sssThick_ST;
            float _sssThickMapIns;
            samplerCUBE _cubeMap;
            float4 _cubeMap_HDR;
            float _cubeRotate;
            float _fresnelIns;
            float _fresnelIntensity;
            // float4 _LightColor0; //头文件带的光线颜色变量，需要先定义再使用
            float _noiseIns;
            float _sssPower;
            float _sssScale;
            float4 _sssColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _sssThick);
                o.pos_ws = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //准备向量
                half3 normal_dir = normalize(i.normal);
                half3 pos_dir = normalize(i.pos_ws);
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_ws);
                half3 reflect_dir = reflect(-view_dir,normal_dir);
                //菲涅尔
                half fresnel = max(0,1 - pow(dot(view_dir,normal_dir),_fresnelIns)) *_fresnelIntensity;

                //兰伯特
                half lambert = max(0,dot(normal_dir,light_dir));
                half3 diffuse_layer = _mainColor.rgb * lambert;

                //3S caculate
                float thick_map = max(0,(1 - tex2D(_sssThick,i.uv).r) + _sssThickMapIns);
                half3 noise_light = normalize(light_dir + normal_dir * _noiseIns); //利用物体表面法线，对灯光方向进行一个扰动
                half black_sss = max(0,dot(-view_dir,noise_light));
                half3 sss_layer = max(0,pow(black_sss,_sssPower)) * _sssScale * _sssColor * thick_map;

                //CubeMap
                reflect_dir = rotateAngleByArc(_cubeRotate,reflect_dir);
                float4 cubemap = texCUBE(_cubeMap,reflect_dir);
                float3 cubemap_de = DecodeHDR(cubemap,_cubeMap_HDR);
                float3 cube_layer = cubemap_de * fresnel;

                //ambient color
                half3 ambient_color = ShadeSH9(float4(normal_dir,1.0)) * _mainColor.rgb;

                //最终输出
                half3 final = diffuse_layer + cube_layer + sss_layer + ambient_color;
                return float4(max(0,final.xyz),1.0);
            }
            ENDCG
        }

    }
    FallBack "Diffuse"  //重要，有该句才能对全局声明执行绘制shadowmap操作
}
