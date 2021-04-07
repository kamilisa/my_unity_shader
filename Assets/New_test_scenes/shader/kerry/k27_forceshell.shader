// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k27_forceshell"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_FlowLight("FlowLight", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_DesolveRamp("DesolveRamp", 2D) = "white" {}
		_NoiseDisolveMap("NoiseDisolveMap", 2D) = "white" {}
		_RimPower("RimPower", Float) = 2
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimColor("RimColor", Color) = (1,0,0,0)
		_RimColorIntensity("RimColorIntensity", Float) = 1
		_FlowSpeed("FlowSpeed", Float) = 0
		_FlowStrength("FlowStrength", Vector) = (0.2,0.2,0,0)
		_DepthDistance("DepthDistance", Float) = 0
		_DepthPower("DepthPower", Float) = 1
		_DesolvePoint("DesolvePoint", Vector) = (0,0,0,0)
		_DesolveEdgeIntensity("DesolveEdgeIntensity", Float) = 1
		_DesolveOffset("DesolveOffset", Range( 0 , 1)) = 0
		_Noise_tilling("Noise_tilling", Float) = 1
		_NoiseScale("NoiseScale", Float) = 1
		_Triplanar_falloff("Triplanar_falloff", Float) = 0
		_Size("Size", Range( 0 , 10)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float _CullMode;
		uniform float4 _RimColor;
		uniform float _RimColorIntensity;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthDistance;
		uniform float _DepthPower;
		uniform sampler2D _FlowLight;
		uniform float4 _FlowLight_ST;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float2 _FlowStrength;
		uniform float _FlowSpeed;
		uniform sampler2D _DesolveRamp;
		uniform float3 _DesolvePoint;
		uniform float _DesolveOffset;
		uniform sampler2D _NoiseDisolveMap;
		uniform float _Triplanar_falloff;
		uniform float _Noise_tilling;
		uniform float _NoiseScale;
		uniform float _DesolveEdgeIntensity;


		inline float4 TriplanarSampling76( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 switchResult105 = (((i.ASEVFace>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV1 = dot( normalize( switchResult105 ), ase_worldViewDir );
			float fresnelNode1 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV1 , 0.0001 ), _RimPower ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth33 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth33 = abs( ( screenDepth33 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthDistance ) );
			float clampResult44 = clamp( ( ( 1.0 - distanceDepth33 ) * _DepthPower ) , 0.0 , 1.0 );
			float clampResult13 = clamp( ( fresnelNode1 + clampResult44 ) , 0.0 , 1.0 );
			float fresnelLayer6 = clampResult13;
			float2 uv_FlowLight = i.uv_texcoord * _FlowLight_ST.xy + _FlowLight_ST.zw;
			float2 temp_output_4_0_g1 = (( uv_FlowLight / _Size )).xy;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float2 temp_output_41_0_g1 = ( (tex2D( _FlowMap, uv_FlowMap )).rg + 0.5 );
			float2 temp_output_17_0_g1 = _FlowStrength;
			float mulTime22_g1 = _Time.y * _FlowSpeed;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _FlowLight, temp_output_11_0_g1 ) , tex2D( _FlowLight, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float4 temp_cast_0 = (fresnelLayer6).xxxx;
			float smoothstepResult27 = smoothstep( 0.8 , 1.0 , i.uv_texcoord.y);
			float4 lerpResult28 = lerp( lerpResult9_g1 , temp_cast_0 , smoothstepResult27);
			float4 FlowMapLayer24 = lerpResult28;
			float3 objToWorld48 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult99 = clamp( ( distance( _DesolvePoint , ( ase_worldPos - objToWorld48 ) ) - (-1.0 + (_DesolveOffset - 0.0) * (3.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
			float3 objToWorld80 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float4 triplanar76 = TriplanarSampling76( _NoiseDisolveMap, ( ( ase_worldPos - objToWorld80 ) * _Noise_tilling ), ase_worldNormal, _Triplanar_falloff, float2( 1,1 ), 1.0, 0 );
			float Noise_layer92 = triplanar76.x;
			float smoothstepResult101 = smoothstep( 0.9 , 1.0 , ( 1.0 - ( clampResult99 - ( Noise_layer92 * _NoiseScale ) ) ));
			float clampResult55 = clamp( smoothstepResult101 , 0.0 , 1.0 );
			float2 appendResult63 = (float2(clampResult55 , 0.5));
			float temp_output_71_0 = ( tex2D( _DesolveRamp, appendResult63 ).r * _DesolveEdgeIntensity );
			float desolveEdge35 = temp_output_71_0;
			float4 temp_output_68_0 = ( ( fresnelLayer6 * FlowMapLayer24 ) + desolveEdge35 );
			o.Emission = ( ( _RimColor * _RimColorIntensity ) * temp_output_68_0 ).rgb;
			float grayscale32 = Luminance(temp_output_68_0.rgb);
			float desolveAlpha64 = clampResult55;
			float clampResult12 = clamp( ( grayscale32 * desolveAlpha64 ) , 0.0 , 1.0 );
			o.Alpha = clampResult12;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
-92;178;1920;615;2787.366;-1313.614;1.256454;True;True
Node;AmplifyShaderEditor.CommentaryNode;89;-2372.026,2234.357;Inherit;False;1549.895;645.198;Noise_layer;9;76;78;77;87;84;83;81;80;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;80;-2322.026,2655.688;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;81;-2292.906,2497.772;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-2074.272,2497.092;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;73;-3372.755,1479.98;Inherit;False;2973.346;702.9103;DisolveLayer;23;64;74;35;71;72;61;63;55;101;57;95;99;96;97;51;91;100;50;49;52;45;48;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-2027.182,2714.428;Inherit;False;Property;_Noise_tilling;Noise_tilling;17;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;48;-3327.817,1889.79;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;5;-3176.545,0.4593272;Inherit;False;2161.156;589.3081;rimLight;16;6;13;42;44;1;2;41;3;4;38;40;33;34;104;105;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1826.223,2497.372;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1831.214,2631.227;Inherit;False;Property;_Triplanar_falloff;Triplanar_falloff;19;0;Create;True;0;0;0;False;0;False;0;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;46;-3299.34,1739.239;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;77;-1854.375,2284.357;Inherit;True;Property;_NoiseDisolveMap;NoiseDisolveMap;4;0;Create;True;0;0;0;False;0;False;None;21c84ce4fe00b584ab3fd51310dbfdaa;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector3Node;45;-3291.985,1575.351;Inherit;False;Property;_DesolvePoint;DesolvePoint;14;0;Create;True;0;0;0;False;0;False;0,0,0;0.082,-0.27,1.487;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;76;-1574.856,2479.605;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-3272.88,2044.972;Inherit;False;Property;_DesolveOffset;DesolveOffset;16;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-3112.466,1812.556;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2776.449,433.8879;Inherit;False;Property;_DepthDistance;DepthDistance;12;0;Create;True;0;0;0;False;0;False;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;104;-3139.425,57.23834;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DepthFade;33;-2573.875,309.0944;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;100;-2946.211,1735.17;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;50;-2909.256,1582.543;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-1110.654,2493.899;Inherit;False;Noise_layer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-2768.329,1813.109;Inherit;False;92;Noise_layer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;106;-2920.425,146.2383;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2394.128,411.5081;Inherit;False;Property;_DepthPower;DepthPower;13;0;Create;True;0;0;0;False;0;False;1;2.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;38;-2327.254,310.0037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-2747.49,1896.672;Inherit;False;Property;_NoiseScale;NoiseScale;18;0;Create;True;0;0;0;False;0;False;1;0.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2747.876,1656.961;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-2578.154,1818.009;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2776.202,341.2301;Inherit;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;0;False;0;False;2;4.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2775.202,260.2301;Inherit;False;Property;_RimScale;RimScale;6;0;Create;True;0;0;0;False;0;False;1;3.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2165.391,310.0966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2773.202,180.2303;Inherit;False;Property;_RimBias;RimBias;7;0;Create;True;0;0;0;False;0;False;0;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;105;-2740.425,52.23834;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;99;-2580.412,1657.067;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-3042.366,620.1904;Inherit;False;2028.229;798.6491;FlowMap_layer;13;21;22;26;17;20;23;18;19;29;14;27;28;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;44;-2021.637,308.9645;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-2516.429,50.45934;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-2417.416,1672.953;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;57;-2255.652,1672.073;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1866.244,57.62241;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2992.366,1026.995;Inherit;False;0;22;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;101;-2080.835,1673.262;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.9;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;13;-1616.031,59.67249;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-2744.337,998.9953;Inherit;True;Property;_FlowMap;FlowMap;2;0;Create;True;0;0;0;False;0;False;22;None;5b53cc2b11fe83f488c1ea8c8527d344;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-2395.846,1302.839;Inherit;False;Property;_FlowSpeed;FlowSpeed;10;0;Create;True;0;0;0;False;0;False;0;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;20;-2428.149,670.1904;Inherit;True;Property;_FlowLight;FlowLight;1;0;Create;True;0;0;0;False;0;False;None;39d451e269cd4e847931f587388efae7;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-1330.931,53.11391;Inherit;False;fresnelLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;23;-2415.365,1000.995;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1964.006,1132.217;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-2416.583,870.2659;Inherit;False;0;20;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;55;-1892.677,1670.897;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;17;-2406.94,1173.194;Inherit;False;Property;_FlowStrength;FlowStrength;11;0;Create;True;0;0;0;False;0;False;0.2,0.2;-0.4,0.32;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;27;-1693.006,1180.217;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-1717.229,1077.802;Inherit;False;6;fresnelLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;14;-2066.096,942.9122;Inherit;False;Flow;20;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,50,0,51,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-1255.082,1831.982;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1037.697,2000.563;Inherit;False;Property;_DesolveEdgeIntensity;DesolveEdgeIntensity;15;0;Create;True;0;0;0;False;0;False;1;1.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;-1470.455,998.6263;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;61;-1105.508,1805.484;Inherit;True;Property;_DesolveRamp;DesolveRamp;3;0;Create;True;0;0;0;False;0;False;-1;None;256d86d8496a4e0f947100121f1fafb2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1238.137,991.8293;Inherit;False;FlowMapLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-782.0315,1833.556;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-593.0876,1900.499;Inherit;False;desolveEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-919.4686,110.0326;Inherit;False;24;FlowMapLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-907.5334,23.7984;Inherit;False;6;fresnelLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-699.6838,53.69719;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-767.8414,197.7584;Inherit;False;35;desolveEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1273.004,1581.238;Inherit;False;desolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-541.5007,51.96251;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;-703.6984,-245.5849;Inherit;False;Property;_RimColor;RimColor;8;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0.5345085,0.4103774,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-694.6984,-66.58487;Inherit;False;Property;_RimColorIntensity;RimColorIntensity;9;0;Create;True;0;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-329.3776,204.6041;Inherit;False;64;desolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;32;-323.672,122.2372;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;103;-875.543,744.0345;Inherit;False;215;166;Comment;1;102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-458.6982,-150.5849;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-124.299,171.6546;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-298.6982,-112.5849;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;12;41.24158,171.4007;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-594.6835,1768.432;Inherit;False;test;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-825.543,794.0345;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-32.29675,431.4309;Inherit;False;74;test;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;316.6148,-118.9165;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;k27_forceshell;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;102;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;83;0;81;0
WireConnection;83;1;80;0
WireConnection;87;0;83;0
WireConnection;87;1;84;0
WireConnection;76;0;77;0
WireConnection;76;9;87;0
WireConnection;76;4;78;0
WireConnection;49;0;46;0
WireConnection;49;1;48;0
WireConnection;33;0;34;0
WireConnection;100;0;52;0
WireConnection;50;0;45;0
WireConnection;50;1;49;0
WireConnection;92;0;76;1
WireConnection;106;0;104;0
WireConnection;38;0;33;0
WireConnection;51;0;50;0
WireConnection;51;1;100;0
WireConnection;96;0;91;0
WireConnection;96;1;97;0
WireConnection;41;0;38;0
WireConnection;41;1;40;0
WireConnection;105;0;104;0
WireConnection;105;1;106;0
WireConnection;99;0;51;0
WireConnection;44;0;41;0
WireConnection;1;0;105;0
WireConnection;1;1;2;0
WireConnection;1;2;3;0
WireConnection;1;3;4;0
WireConnection;95;0;99;0
WireConnection;95;1;96;0
WireConnection;57;0;95;0
WireConnection;42;0;1;0
WireConnection;42;1;44;0
WireConnection;101;0;57;0
WireConnection;13;0;42;0
WireConnection;22;1;21;0
WireConnection;6;0;13;0
WireConnection;23;0;22;0
WireConnection;55;0;101;0
WireConnection;27;0;26;2
WireConnection;14;5;20;0
WireConnection;14;2;19;0
WireConnection;14;18;23;0
WireConnection;14;17;17;0
WireConnection;14;24;18;0
WireConnection;63;0;55;0
WireConnection;28;0;14;0
WireConnection;28;1;29;0
WireConnection;28;2;27;0
WireConnection;61;1;63;0
WireConnection;24;0;28;0
WireConnection;71;0;61;1
WireConnection;71;1;72;0
WireConnection;35;0;71;0
WireConnection;31;0;7;0
WireConnection;31;1;25;0
WireConnection;64;0;55;0
WireConnection;68;0;31;0
WireConnection;68;1;69;0
WireConnection;32;0;68;0
WireConnection;10;0;9;0
WireConnection;10;1;11;0
WireConnection;66;0;32;0
WireConnection;66;1;65;0
WireConnection;8;0;10;0
WireConnection;8;1;68;0
WireConnection;12;0;66;0
WireConnection;74;0;71;0
WireConnection;0;2;8;0
WireConnection;0;9;12;0
ASEEND*/
//CHKSM=6E3F1CEB0F05BF07E94D44A55D4243C9F91BFB92