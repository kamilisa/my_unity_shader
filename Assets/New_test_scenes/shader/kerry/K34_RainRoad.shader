// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "K34_RainRoad"
{
	Properties
	{
		_BaseMap("BaseMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalIntensity("NormalIntensity", Float) = 1
		_AoMap("AoMap", 2D) = "white" {}
		_RoughnessMap("RoughnessMap", 2D) = "white" {}
		_RoughMin("RoughMin", Range( 0 , 1)) = 0
		_RoughMax("RoughMax", Range( 0 , 1)) = 1
		_HeightMap("HeightMap", 2D) = "white" {}
		_HeightContrast("HeightContrast", Range( 0 , 1)) = 1
		_WaveNormalMap("WaveNormalMap", 2D) = "bump" {}
		_WaveTilling("WaveTilling", Float) = 1
		_WaveIntensity("WaveIntensity", Range( 0 , 1)) = 1
		_WaveSpeed("WaveSpeed", Vector) = (1,1,0,0)
		_WaveRainDropMap("WaveRainDropMap", 2D) = "bump" {}
		_WaveRainDropSpeed("WaveRainDropSpeed", Float) = 25
		_WaveRainDropTilling("WaveRainDropTilling", Float) = 1
		_WaveMapColumns("WaveMapColumns", Float) = 8
		_Tilling("Tilling", Float) = 1
		_LakeColor("LakeColor", Color) = (0,0,0,0)
		_LakeColorIntensity("LakeColorIntensity", Range( 0 , 1)) = 0
		_POMPlane("POMPlane", Float) = 0
		_POMScale("POMScale", Range( -0.5 , 0.5)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _NormalMap;
		uniform float _Tilling;
		uniform sampler2D _HeightMap;
		uniform float _POMScale;
		uniform float _POMPlane;
		uniform float4 _HeightMap_ST;
		uniform float _NormalIntensity;
		uniform sampler2D _WaveNormalMap;
		uniform float _WaveTilling;
		uniform float2 _WaveSpeed;
		uniform float _WaveIntensity;
		uniform sampler2D _WaveRainDropMap;
		uniform float _WaveRainDropTilling;
		uniform float _WaveMapColumns;
		uniform float _WaveRainDropSpeed;
		uniform float _HeightContrast;
		uniform sampler2D _BaseMap;
		uniform float4 _LakeColor;
		uniform float _LakeColorIntensity;
		uniform float _RoughMin;
		uniform float _RoughMax;
		uniform sampler2D _RoughnessMap;
		uniform sampler2D _AoMap;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs.xy += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
			 	currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).r;
			 	if ( currHeight > currRayZ )
			 	{
			 	 	stepIndex = numSteps + 1;
			 	}
			 	else
			 	{
			 	 	stepIndex++;
			 	 	prevTexOffset = currTexOffset;
			 	 	prevRayZ = currRayZ;
			 	 	prevHeight = currHeight;
			 	 	currTexOffset += deltaTex;
			 	 	currRayZ -= layerHeight;
			 	}
			}
			int sectionSteps = 6;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
			 	intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
			 	finalTexOffset = prevTexOffset + intersection * deltaTex;
			 	newZ = prevRayZ - intersection * layerHeight;
			 	newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).r;
			 	if ( newHeight > newZ )
			 	{
			 	 	currTexOffset = finalTexOffset;
			 	 	currHeight = newHeight;
			 	 	currRayZ = newZ;
			 	 	deltaTex = intersection * deltaTex;
			 	 	layerHeight = intersection * layerHeight;
			 	}
			 	else
			 	{
			 	 	prevTexOffset = finalTexOffset;
			 	 	prevHeight = newHeight;
			 	 	prevRayZ = newZ;
			 	 	deltaTex = ( 1 - intersection ) * deltaTex;
			 	 	layerHeight = ( 1 - intersection ) * layerHeight;
			 	}
			 	sectionIndex++;
			}
			return uvs.xy + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 ase_tanViewDir = mul( ase_worldToTangent, ase_worldViewDir );
			float2 OffsetPOM31 = POM( _HeightMap, ( (ase_worldPos).xz * _Tilling ), ddx(( (ase_worldPos).xz * _Tilling )), ddy(( (ase_worldPos).xz * _Tilling )), ase_worldNormal, ase_worldViewDir, ase_tanViewDir, 8, 8, ( _POMScale * 0.1 ), ( _POMPlane + ( i.vertexColor.g - 1.0 ) ), _HeightMap_ST.xy, float2(0,0), 0 );
			float2 WorldUV16 = OffsetPOM31;
			float2 temp_output_71_0 = ( (ase_worldPos).xz * _WaveTilling );
			float2 temp_output_76_0 = ( _WaveSpeed * _Time.y * 0.1 );
			float3 lerpResult86 = lerp( BlendNormals( UnpackNormal( tex2D( _WaveNormalMap, ( temp_output_71_0 + temp_output_76_0 ) ) ) , UnpackNormal( tex2D( _WaveNormalMap, ( ( temp_output_71_0 * 2.0 ) + ( temp_output_76_0 * -0.5 ) ) ) ) ) , float3(0,0,1) , _WaveIntensity);
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles95 = _WaveMapColumns * _WaveMapColumns;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset95 = 1.0f / _WaveMapColumns;
			float fbrowsoffset95 = 1.0f / _WaveMapColumns;
			// Speed of animation
			float fbspeed95 = _Time[ 1 ] * _WaveRainDropSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling95 = float2(fbcolsoffset95, fbrowsoffset95);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex95 = round( fmod( fbspeed95 + 0.0, fbtotaltiles95) );
			fbcurrenttileindex95 += ( fbcurrenttileindex95 < 0) ? fbtotaltiles95 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox95 = round ( fmod ( fbcurrenttileindex95, _WaveMapColumns ) );
			// Multiply Offset X by coloffset
			float fboffsetx95 = fblinearindextox95 * fbcolsoffset95;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy95 = round( fmod( ( fbcurrenttileindex95 - fblinearindextox95 ) / _WaveMapColumns, _WaveMapColumns ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy95 = (int)(_WaveMapColumns-1) - fblinearindextoy95;
			// Multiply Offset Y by rowoffset
			float fboffsety95 = fblinearindextoy95 * fbrowsoffset95;
			// UV Offset
			float2 fboffset95 = float2(fboffsetx95, fboffsety95);
			// Flipbook UV
			half2 fbuv95 = frac( ( (ase_worldPos).xz * _WaveRainDropTilling ) ) * fbtiling95 + fboffset95;
			// *** END Flipbook UV Animation vars ***
			float3 puddleNormal85 = BlendNormals( lerpResult86 , UnpackNormal( tex2D( _WaveRainDropMap, fbuv95 ) ) );
			float temp_output_10_0_g11 = _HeightContrast;
			float4 tex2DNode43 = tex2D( _HeightMap, WorldUV16 );
			float clampResult9_g11 = clamp( ( ( tex2DNode43.r - 1.0 ) + ( i.vertexColor.b * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult14_g11 = lerp( ( 0.0 - temp_output_10_0_g11 ) , ( temp_output_10_0_g11 + 1.0 ) , clampResult9_g11);
			float clampResult15_g11 = clamp( lerpResult14_g11 , 0.0 , 1.0 );
			float BchannelLayer48 = clampResult15_g11;
			float3 lerpResult63 = lerp( UnpackScaleNormal( tex2D( _NormalMap, WorldUV16 ), _NormalIntensity ) , puddleNormal85 , ( 1.0 - BchannelLayer48 ));
			float3 NormalLayer23 = lerpResult63;
			o.Normal = NormalLayer23;
			float4 tex2DNode1 = tex2D( _BaseMap, WorldUV16 );
			float4 lerpResult50 = lerp( tex2DNode1 , _LakeColor , _LakeColorIntensity);
			float temp_output_10_0_g1 = _HeightContrast;
			float clampResult9_g1 = clamp( ( ( tex2DNode43.r - 1.0 ) + ( i.vertexColor.r * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult14_g1 = lerp( ( 0.0 - temp_output_10_0_g1 ) , ( temp_output_10_0_g1 + 1.0 ) , clampResult9_g1);
			float clampResult15_g1 = clamp( lerpResult14_g1 , 0.0 , 1.0 );
			float RchannelLayer46 = clampResult15_g1;
			float4 lerpResult53 = lerp( tex2DNode1 , lerpResult50 , ( 1.0 - RchannelLayer46 ));
			float3 gammaToLinear62 = GammaToLinearSpace( lerpResult53.rgb );
			float3 baseLayer22 = gammaToLinear62;
			o.Albedo = baseLayer22;
			o.Metallic = 0.0;
			float lerpResult12 = lerp( _RoughMin , _RoughMax , tex2D( _RoughnessMap, WorldUV16 ).r);
			float temp_output_10_0_g12 = _HeightContrast;
			float clampResult9_g12 = clamp( ( ( tex2DNode43.r - 1.0 ) + ( i.vertexColor.g * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult14_g12 = lerp( ( 0.0 - temp_output_10_0_g12 ) , ( temp_output_10_0_g12 + 1.0 ) , clampResult9_g12);
			float clampResult15_g12 = clamp( lerpResult14_g12 , 0.0 , 1.0 );
			float GchannelLayer47 = clampResult15_g12;
			float lerpResult57 = lerp( ( 1.0 - lerpResult12 ) , 1.0 , ( 1.0 - GchannelLayer47 ));
			float roughnessLayer26 = lerpResult57;
			o.Smoothness = roughnessLayer26;
			float4 AOlayer25 = tex2D( _AoMap, WorldUV16 );
			o.Occlusion = AOlayer25.r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				half4 color : COLOR0;
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
				o.color = v.color;
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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
0;18;1920;1001;5403.672;2205.39;5.668623;True;True
Node;AmplifyShaderEditor.CommentaryNode;17;-3168.596,-515.6501;Inherit;False;1158.692;1087.322;WorldUV_region;15;106;105;38;37;36;34;35;31;16;33;8;7;9;6;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-3118.596,-465.6501;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;93;-1739.588,1343.933;Inherit;False;2327.612;1231.253;WaveNormalRegion;31;85;96;94;95;86;87;84;88;69;68;81;73;82;79;71;83;76;80;92;72;77;78;75;91;97;98;99;100;101;102;103;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;106;-3050.548,347.0207;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;91;-1689.587,1393.933;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;36;-2996.932,62.74517;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-3121.932,-13.25473;Inherit;False;Property;_POMScale;POMScale;21;0;Create;True;0;0;0;False;0;False;0;-0.273;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2880.548,395.0207;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-3039.532,237.9453;Inherit;False;Property;_POMPlane;POMPlane;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2914.514,-360.5793;Inherit;False;Property;_Tilling;Tilling;17;0;Create;True;0;0;0;False;0;False;1;1.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;7;-2907.067,-463.7726;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;75;-1513.362,1677.816;Inherit;False;Property;_WaveSpeed;WaveSpeed;12;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;33;-2987.754,-208.2258;Inherit;True;Property;_HeightMap;HeightMap;7;0;Create;True;0;0;0;False;0;False;None;850937e552911f049937a921fd29bab9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;77;-1515.362,1810.816;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-2718.766,-454.1979;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1481.362,1894.816;Inherit;False;Constant;_Float4;Float 4;16;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;92;-1497.588,1397.933;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2824.932,-7.254728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1500.93,1551.427;Inherit;False;Property;_WaveTilling;WaveTilling;10;0;Create;True;0;0;0;False;0;False;1;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;-2861.932,86.74516;Inherit;False;Tangent;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-2782.578,241.9383;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;97;-1466.896,2147.554;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;31;-2521.07,-187.8741;Inherit;False;0;8;False;-1;16;False;-1;6;0.02;0;False;1,1;False;0,0;8;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;7;SAMPLERSTATE;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1276.867,1873.18;Inherit;False;Constant;_Float6;Float 6;16;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1141.145,1679.956;Inherit;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1293.93,1478.427;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1308.362,1723.816;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2239.213,-193.7485;Inherit;False;WorldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-991.674,1667.777;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1305.896,2277.554;Inherit;False;Property;_WaveRainDropTilling;WaveRainDropTilling;15;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1094.18,1816.712;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;98;-1262.467,2143.183;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;49;-3090.578,633.2382;Inherit;False;1202.235;597.4497;BlendFactor;10;40;44;43;45;39;41;42;46;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-832.882,1765.781;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-1016.316,1483.134;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-1104.153,2150.868;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-3040.578,707.1965;Inherit;False;16;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;68;-654.2444,1471.247;Inherit;True;Property;_WaveNormalMap;WaveNormalMap;9;0;Create;True;0;0;0;False;0;False;-1;None;c8d3136ea4e18804c97c18ee19310a4b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;103;-999.8955,2340.554;Inherit;False;Property;_WaveRainDropSpeed;WaveRainDropSpeed;14;0;Create;True;0;0;0;False;0;False;25;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-655.0945,1770.439;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;68;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;102;-993.8955,2246.554;Inherit;False;Property;_WaveMapColumns;WaveMapColumns;16;0;Create;True;0;0;0;False;0;False;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2897.26,1114.688;Inherit;False;Property;_HeightContrast;HeightContrast;8;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;101;-921.266,2152.554;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;43;-2804.618,683.2382;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;40;-2907.071,901.9905;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;95;-721.4648,2155.736;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;56;-1592.107,706.9871;Inherit;False;1903.778;588.439;BaseColorRegion;10;22;53;55;50;52;54;51;1;18;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;84;-317.9406,1647.395;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;39;-2444.012,760.4345;Inherit;False;HeightLerp;-1;;1;29b602d8345d5ad489ed550a3e4b3900;0;3;1;FLOAT;0;False;6;FLOAT;0;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-1875.286,194.7846;Inherit;False;1767.416;459.9192;roughnessRegion;11;14;26;57;10;61;59;12;58;5;13;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-355.4576,1931.341;Inherit;False;Property;_WaveIntensity;WaveIntensity;11;0;Create;True;0;0;0;False;0;False;1;0.843;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;87;-269.4576,1747.341;Inherit;False;Constant;_Vector1;Vector 1;16;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;94;-404.554,2124.438;Inherit;True;Property;_WaveRainDropMap;WaveRainDropMap;13;0;Create;True;0;0;0;False;0;False;-1;None;492fa49f23d570141b87ee637d6b432b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1542.107,787.969;Inherit;False;16;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2123.343,758.4904;Inherit;False;RchannelLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;86;-52.45763,1746.341;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;42;-2442.271,1051.69;Inherit;False;HeightLerp;-1;;11;29b602d8345d5ad489ed550a3e4b3900;0;3;1;FLOAT;0;False;6;FLOAT;0;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;41;-2444.271,906.6904;Inherit;False;HeightLerp;-1;;12;29b602d8345d5ad489ed550a3e4b3900;0;3;1;FLOAT;0;False;6;FLOAT;0;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-1778.699,333.1971;Inherit;False;16;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-1558.039,310.9035;Inherit;True;Property;_RoughnessMap;RoughnessMap;4;0;Create;True;0;0;0;False;0;False;-1;None;03c75ee83dffe9a499f89c94649ac3a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1234.768,312.7847;Inherit;False;Property;_RoughMax;RoughMax;6;0;Create;True;0;0;0;False;0;False;1;0.506;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1333.821,762.533;Inherit;True;Property;_BaseMap;BaseMap;0;0;Create;True;0;0;0;False;0;False;-1;None;8a6b949b4f8821d458ad03e1ba8bd7f2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;96;107.6221,1905.117;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-2112.343,907.4904;Inherit;False;GchannelLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1312.062,1133.74;Inherit;False;Property;_LakeColorIntensity;LakeColorIntensity;19;0;Create;True;0;0;0;False;0;False;0;0.601;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-956.7623,1088.432;Inherit;False;46;RchannelLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-2114.343,1045.49;Inherit;False;BchannelLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-1248.204,955.0547;Inherit;False;Property;_LakeColor;LakeColor;18;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1603774,0.07035422,0.07035422,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-1235.768,236.7846;Inherit;False;Property;_RoughMin;RoughMin;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-1590.092,-393.5708;Inherit;False;1222.92;511.0751;normalRegion;8;64;23;63;19;15;2;67;90;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;12;-946.767,286.7846;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-935.975,498.4735;Inherit;False;47;GchannelLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-2706.867,1293.772;Inherit;False;830.4157;280;Ao_region;3;21;25;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-1540.092,-334.6431;Inherit;False;16;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1531.76,-242.4055;Inherit;False;Property;_NormalIntensity;NormalIntensity;2;0;Create;True;0;0;0;False;0;False;1;0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1231.911,12.32895;Inherit;False;48;BchannelLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;354.271,1861.314;Inherit;False;puddleNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;55;-762.0999,1089.289;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;-939.0482,927.6867;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;10;-759.9619,285.1364;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;53;-597.6542,888.5748;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1322.481,-343.5707;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;77c6d995e7b810e44aed9c175fb24aca;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1232.302,-120.0854;Inherit;False;85;puddleNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;61;-690.4454,500.4175;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-763.7151,400.1417;Inherit;False;Constant;_Float3;Float 3;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;67;-1019.816,11.14372;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-2656.867,1367.395;Inherit;False;16;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-2441.608,1343.772;Inherit;True;Property;_AoMap;AoMap;3;0;Create;True;0;0;0;False;0;False;-1;None;5aaafb98fcecb6b43bc3689ae8e7621c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;57;-543.0743,344.1587;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-817.3851,-173.4957;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GammaToLinearNode;62;-366.6055,821.074;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-101.2237,878.0989;Inherit;False;baseLayer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-338.8688,285.4559;Inherit;False;roughnessLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-591.1724,-183.5238;Inherit;False;NormalLayer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-2100.452,1344.968;Inherit;False;AOlayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;31.83179,-27.41951;Inherit;False;22;baseLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-5.168213,150.5805;Inherit;False;26;roughnessLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;30.06384,383.7339;Inherit;False;85;puddleNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-152.6683,90.47621;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;23.83179,49.58049;Inherit;False;23;NormalLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;29.83179,232.5805;Inherit;False;25;AOlayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;252.2787,23.43138;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;K34_RainRoad;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;105;0;106;2
WireConnection;7;0;6;0
WireConnection;8;0;7;0
WireConnection;8;1;9;0
WireConnection;92;0;91;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;107;0;38;0
WireConnection;107;1;105;0
WireConnection;31;0;8;0
WireConnection;31;1;33;0
WireConnection;31;2;35;0
WireConnection;31;3;37;0
WireConnection;31;4;107;0
WireConnection;71;0;92;0
WireConnection;71;1;72;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;16;0;31;0
WireConnection;79;0;71;0
WireConnection;79;1;80;0
WireConnection;82;0;76;0
WireConnection;82;1;83;0
WireConnection;98;0;97;0
WireConnection;81;0;79;0
WireConnection;81;1;82;0
WireConnection;73;0;71;0
WireConnection;73;1;76;0
WireConnection;99;0;98;0
WireConnection;99;1;100;0
WireConnection;68;1;73;0
WireConnection;69;1;81;0
WireConnection;101;0;99;0
WireConnection;43;0;33;0
WireConnection;43;1;44;0
WireConnection;95;0;101;0
WireConnection;95;1;102;0
WireConnection;95;2;102;0
WireConnection;95;3;103;0
WireConnection;84;0;68;0
WireConnection;84;1;69;0
WireConnection;39;1;43;1
WireConnection;39;6;40;1
WireConnection;39;10;45;0
WireConnection;94;1;95;0
WireConnection;46;0;39;0
WireConnection;86;0;84;0
WireConnection;86;1;87;0
WireConnection;86;2;88;0
WireConnection;42;1;43;1
WireConnection;42;6;40;3
WireConnection;42;10;45;0
WireConnection;41;1;43;1
WireConnection;41;6;40;2
WireConnection;41;10;45;0
WireConnection;5;1;108;0
WireConnection;1;1;18;0
WireConnection;96;0;86;0
WireConnection;96;1;94;0
WireConnection;47;0;41;0
WireConnection;48;0;42;0
WireConnection;12;0;13;0
WireConnection;12;1;14;0
WireConnection;12;2;5;1
WireConnection;85;0;96;0
WireConnection;55;0;54;0
WireConnection;50;0;1;0
WireConnection;50;1;51;0
WireConnection;50;2;52;0
WireConnection;10;0;12;0
WireConnection;53;0;1;0
WireConnection;53;1;50;0
WireConnection;53;2;55;0
WireConnection;2;1;19;0
WireConnection;2;5;15;0
WireConnection;61;0;58;0
WireConnection;67;0;64;0
WireConnection;4;1;21;0
WireConnection;57;0;10;0
WireConnection;57;1;59;0
WireConnection;57;2;61;0
WireConnection;63;0;2;0
WireConnection;63;1;90;0
WireConnection;63;2;67;0
WireConnection;62;0;53;0
WireConnection;22;0;62;0
WireConnection;26;0;57;0
WireConnection;23;0;63;0
WireConnection;25;0;4;0
WireConnection;0;0;27;0
WireConnection;0;1;28;0
WireConnection;0;3;11;0
WireConnection;0;4;29;0
WireConnection;0;5;30;0
ASEEND*/
//CHKSM=80D120A688198ABA433DA9DFD4FE52FF2A4051F9