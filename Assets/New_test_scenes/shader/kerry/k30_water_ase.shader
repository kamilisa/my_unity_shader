// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k30_water_ase"
{
	Properties
	{
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_waterNormal("waterNormal", 2D) = "bump" {}
		_NormalIntensity("NormalIntensity", Float) = 1
		_NormalTilling_a("NormalTilling_a", Float) = 0
		_noiseIntensity("noiseIntensity", Float) = 1
		_UnderTilling("UnderTilling", Float) = 0
		_waterSpeed("waterSpeed", Float) = 1
		_SpecSmoothness("SpecSmoothness", Range( 0.1 , 1)) = 0
		_SpecTint("SpecTint", Color) = (1,1,1,0)
		_SpecIntensity("SpecIntensity", Range( 1 , 3)) = 1
		_SpecEnd("SpecEnd", Float) = 200
		_UnderWater("UnderWater", 2D) = "white" {}
		_underDepth("underDepth", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 screenPos;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _ReflectionTex;
		uniform sampler2D _waterNormal;
		uniform float _NormalTilling_a;
		uniform float _waterSpeed;
		uniform float _NormalIntensity;
		uniform float _noiseIntensity;
		uniform sampler2D _UnderWater;
		uniform float _UnderTilling;
		uniform float _underDepth;
		uniform float _SpecSmoothness;
		uniform float4 _SpecTint;
		uniform float _SpecIntensity;
		uniform float _SpecEnd;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_5_0 = ( (ase_worldPos).xz / _NormalTilling_a );
			float temp_output_11_0 = ( _Time.y * 0.1 * _waterSpeed );
			float3 temp_output_22_0 = ( UnpackScaleNormal( tex2D( _waterNormal, ( temp_output_5_0 + temp_output_11_0 ) ), _NormalIntensity ) + UnpackScaleNormal( tex2D( _waterNormal, ( ( temp_output_5_0 * 1.5 ) + ( temp_output_11_0 * -1.0 ) ) ), _NormalIntensity ) );
			float2 temp_output_23_0 = ( (temp_output_22_0).xy * 0.5 );
			float2 break31 = temp_output_23_0;
			float dotResult26 = dot( temp_output_23_0 , temp_output_23_0 );
			float3 appendResult30 = (float3(break31.x , break31.y , sqrt( ( 1.0 - dotResult26 ) )));
			float3 waterNormal33 = normalize( (WorldNormalVector( i , appendResult30 )) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos41 = UnityObjectToClipPos( ase_vertex3Pos );
			float2 temp_output_36_0 = ( ( (waterNormal33).xz / ( 1.0 + unityObjectToClipPos41.w ) ) * _noiseIntensity );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 temp_output_3_0 = (ase_screenPosNorm).xy;
			float4 reflection47 = tex2D( _ReflectionTex, ( temp_output_36_0 + temp_output_3_0 ) );
			float2 waterNormalComplit98 = temp_output_36_0;
			float2 paralaxOffset99 = ParallaxOffset( 0 , _underDepth , i.viewDir );
			float4 underbutton86 = tex2D( _UnderWater, ( ( ( (ase_worldPos).xz / _UnderTilling ) + waterNormalComplit98 ) + paralaxOffset99 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult89 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult90 = clamp( dotResult89 , 0.0 , 1.0 );
			float4 lerpResult92 = lerp( reflection47 , underbutton86 , clampResult90);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult52 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult54 = dot( waterNormal33 , normalizeResult52 );
			float clampResult77 = clamp( ( ( _SpecEnd - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( _SpecEnd - 0.0 ) ) , 0.0 , 1.0 );
			float4 SpecLayer65 = ( ( ( pow( max( dotResult54 , 0.0 ) , ( _SpecSmoothness * 256.0 ) ) * _SpecTint ) * _SpecIntensity ) * clampResult77 );
			c.rgb = ( lerpResult92 + SpecLayer65 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 screenPos : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
398;250;1920;873;472.011;400.8897;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;38;-3288.416,-985.6684;Inherit;False;2748.008;620.1498;wateNormalRegion;29;4;10;7;6;12;11;18;20;5;17;19;21;9;13;16;22;24;14;23;26;27;28;31;30;32;33;39;104;109;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;4;-3170.274,-930.9122;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;39;-3236.249,-553.1266;Inherit;False;Property;_waterSpeed;waterSpeed;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-3238.416,-713.809;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;6;-2974.56,-935.6682;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-3007.059,-808.0681;Inherit;False;Property;_NormalTilling_a;NormalTilling_a;3;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-3221.918,-633.869;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-3040.037,-708.499;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2892.697,-587.1256;Inherit;False;Constant;_NormalTilling_b;NormalTilling_b;3;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2873.231,-481.5183;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;5;-2798.559,-874.6682;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-2708.429,-502.1185;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2644.155,-604.3358;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-2625.146,-736.5247;Inherit;False;Property;_NormalIntensity;NormalIntensity;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-2633.946,-872.9382;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-2486.866,-602.9298;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;13;-2371.442,-907.7932;Inherit;True;Property;_waterNormal;waterNormal;1;0;Create;True;0;0;0;False;0;False;-1;None;8abe15f31ceb931428becabf9c2d8a3e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-2306.294,-635.1793;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;13;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-2022.89,-779.9738;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;14;-1870.149,-784.7913;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1870.877,-697.593;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1702.877,-779.593;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;26;-1540.876,-670.593;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-1412.876,-671.593;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;28;-1254.876,-670.593;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;31;-1543.095,-795.7109;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;30;-1132.095,-793.7109;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;46;-2507.337,-318.9275;Inherit;False;1929.001;558.8893;ReflectMirror;16;47;1;15;3;2;36;40;37;43;35;34;45;41;42;98;110;;0.2122642,1,0.9644188,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;32;-968.0948,-793.8748;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-767.4078,-798.3035;Inherit;False;waterNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;42;-2441.337,-99.28979;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;-2176.337,-181.2895;Inherit;False;Constant;_Float3;Float 3;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2500.7,270.1204;Inherit;False;1986.644;833.7274;SpecRegion;27;65;78;77;76;75;74;73;72;70;69;71;63;64;61;62;57;59;56;60;58;54;52;55;51;49;50;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;41;-2235.337,-99.28979;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;34;-2234.433,-268.9276;Inherit;False;33;waterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;35;-2037.503,-268.9276;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2012.336,-167.2898;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;50;-2450.7,518.1205;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;49;-2402.48,332.4979;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-1840.336,-262.2895;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-2193.7,437.1204;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;103;-2021.377,1154.986;Inherit;False;1500.425;672.342;underRegion;12;81;82;86;84;83;93;95;102;101;100;99;85;;0.5377358,0.4388969,0.08370417,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1746.33,-154.8846;Inherit;False;Property;_noiseIntensity;noiseIntensity;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;84;-1971.377,1205.742;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;52;-2047.699,437.1204;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2092.699,320.1204;Inherit;False;33;waterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1559.996,-259.5762;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1872.699,618.1205;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;0;False;0;False;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;54;-1858.699,368.1204;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-1387.685,-262.1361;Inherit;False;waterNormalComplit;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1788.162,1288.586;Inherit;False;Property;_UnderTilling;UnderTilling;5;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2002.699,525.1205;Inherit;False;Property;_SpecSmoothness;SpecSmoothness;7;0;Create;True;0;0;0;False;0;False;0;0.41;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;71;-2078.369,932.2742;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;69;-2013.971,789.4691;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;81;-1766.663,1204.986;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;70;-1793.368,857.2741;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1787.368,770.2741;Inherit;False;Property;_SpecEnd;SpecEnd;10;0;Create;True;0;0;0;False;0;False;200;115;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;56;-1687.699,371.1204;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1853.597,1362.102;Inherit;True;98;waterNormalComplit;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;100;-1803.725,1639.328;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;82;-1572.662,1212.986;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1787.368,961.2737;Inherit;False;Constant;_SpecStart;SpecStart;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;2;-1769.897,-1.704893;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1702.699,528.1205;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-1787.725,1557.328;Inherit;False;Property;_underDepth;underDepth;12;0;Create;True;0;0;0;False;0;False;0;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;99;-1597.946,1541.585;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;62;-1540.618,526.1479;Inherit;False;Property;_SpecTint;SpecTint;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0.5252485,0.1273585,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;75;-1572.368,941.2747;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-1573.368,783.2741;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-1417.375,1217.043;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;57;-1511.699,370.1204;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;3;-1555.923,-2.685052;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-1232.035,1284.363;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1280.618,371.1478;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-1285.026,-180.1542;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1321.77,519.2318;Inherit;False;Property;_SpecIntensity;SpecIntensity;9;0;Create;True;0;0;0;False;0;False;1;1;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;76;-1414.368,784.2741;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1141.404,-207.823;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;0;Create;True;0;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;77;-1258.368,783.2741;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1078.618,371.1478;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;88;-319.5515,-152.3841;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;85;-1091.262,1255.608;Inherit;True;Property;_UnderWater;UnderWater;11;0;Create;True;0;0;0;False;0;False;-1;None;51e33924a9b407c47a51975c248f15fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;87;-343.5514,-299.3841;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;89;-103.5514,-236.3841;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-811.4467,-209.4832;Inherit;False;reflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-744.9512,1256.104;Inherit;False;underbutton;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-955.4459,651.9859;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-3.747101,-317.5345;Inherit;False;86;underbutton;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;90;36.2012,-234.7223;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-774.4546,647.6273;Inherit;False;SpecLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;3.546204,-403.4263;Inherit;False;47;reflection;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;276.4933,-130.9548;Inherit;False;65;SpecLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;92;300.2198,-336.3615;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-1868.347,-928.251;Inherit;False;kamiDebug_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;539.7963,-149.0307;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-1347.014,66.511;Inherit;False;kamiDebug_screen;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-917.3429,789.0511;Inherit;False;Fog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;489.2281,-37.32965;Inherit;False;110;kamiDebug_screen;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;753.9821,-386.6991;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;k30_water_ase;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;4;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;11;2;39;0
WireConnection;5;0;6;0
WireConnection;5;1;7;0
WireConnection;19;0;11;0
WireConnection;19;1;20;0
WireConnection;17;0;5;0
WireConnection;17;1;18;0
WireConnection;9;0;5;0
WireConnection;9;1;11;0
WireConnection;21;0;17;0
WireConnection;21;1;19;0
WireConnection;13;1;9;0
WireConnection;13;5;104;0
WireConnection;16;1;21;0
WireConnection;16;5;104;0
WireConnection;22;0;13;0
WireConnection;22;1;16;0
WireConnection;14;0;22;0
WireConnection;23;0;14;0
WireConnection;23;1;24;0
WireConnection;26;0;23;0
WireConnection;26;1;23;0
WireConnection;27;0;26;0
WireConnection;28;0;27;0
WireConnection;31;0;23;0
WireConnection;30;0;31;0
WireConnection;30;1;31;1
WireConnection;30;2;28;0
WireConnection;32;0;30;0
WireConnection;33;0;32;0
WireConnection;41;0;42;0
WireConnection;35;0;34;0
WireConnection;43;0;45;0
WireConnection;43;1;41;4
WireConnection;40;0;35;0
WireConnection;40;1;43;0
WireConnection;51;0;49;0
WireConnection;51;1;50;0
WireConnection;52;0;51;0
WireConnection;36;0;40;0
WireConnection;36;1;37;0
WireConnection;54;0;55;0
WireConnection;54;1;52;0
WireConnection;98;0;36;0
WireConnection;81;0;84;0
WireConnection;70;0;69;0
WireConnection;70;1;71;0
WireConnection;56;0;54;0
WireConnection;82;0;81;0
WireConnection;82;1;83;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;99;1;101;0
WireConnection;99;2;100;0
WireConnection;75;0;72;0
WireConnection;75;1;73;0
WireConnection;74;0;72;0
WireConnection;74;1;70;0
WireConnection;95;0;82;0
WireConnection;95;1;93;0
WireConnection;57;0;56;0
WireConnection;57;1;59;0
WireConnection;3;0;2;0
WireConnection;102;0;95;0
WireConnection;102;1;99;0
WireConnection;61;0;57;0
WireConnection;61;1;62;0
WireConnection;15;0;36;0
WireConnection;15;1;3;0
WireConnection;76;0;74;0
WireConnection;76;1;75;0
WireConnection;1;1;15;0
WireConnection;77;0;76;0
WireConnection;63;0;61;0
WireConnection;63;1;64;0
WireConnection;85;1;102;0
WireConnection;89;0;87;0
WireConnection;89;1;88;0
WireConnection;47;0;1;0
WireConnection;86;0;85;0
WireConnection;78;0;63;0
WireConnection;78;1;77;0
WireConnection;90;0;89;0
WireConnection;65;0;78;0
WireConnection;92;0;48;0
WireConnection;92;1;80;0
WireConnection;92;2;90;0
WireConnection;109;0;22;0
WireConnection;67;0;92;0
WireConnection;67;1;68;0
WireConnection;110;0;3;0
WireConnection;79;0;77;0
WireConnection;0;13;67;0
ASEEND*/
//CHKSM=6FA7599C84BADB827B2BF942CA396965EE79F0D6