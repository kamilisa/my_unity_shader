// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k33_mat_blend_moutain"
{
	Properties
	{
		_BlendMAP("BlendMAP", 2D) = "white" {}
		_Layer1_baseColor("Layer1_baseColor", 2D) = "white" {}
		_Layer2_baseColor("Layer2_baseColor", 2D) = "white" {}
		_Layer3_baseColor("Layer3_baseColor", 2D) = "white" {}
		_Layer1_HRA("Layer1_HRA", 2D) = "white" {}
		_Layer2_HRA("Layer2_HRA", 2D) = "white" {}
		_Layer3_HRA("Layer3_HRA", 2D) = "white" {}
		_Layer1_Normal("Layer1_Normal", 2D) = "bump" {}
		_Layer2_Normal("Layer2_Normal", 2D) = "bump" {}
		_Layer3_Normal("Layer3_Normal", 2D) = "bump" {}
		_layer1_tilling("layer1_tilling", Float) = 1
		_layer2_tilling("layer2_tilling", Float) = 1
		_layer3_tilling("layer3_tilling", Float) = 1
		_BlendWeightContrast("BlendWeightContrast", Range( 0 , 1)) = 0.1
		_SlopePower("SlopePower", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float2 uv2_texcoord2;
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

		uniform sampler2D _Layer1_baseColor;
		uniform float _layer1_tilling;
		uniform sampler2D _Layer1_HRA;
		uniform sampler2D _BlendMAP;
		uniform sampler2D _Layer2_HRA;
		uniform float _layer2_tilling;
		uniform sampler2D _Layer3_HRA;
		uniform float _layer3_tilling;
		uniform float _BlendWeightContrast;
		uniform sampler2D _Layer2_baseColor;
		uniform sampler2D _Layer3_baseColor;
		uniform float _SlopePower;
		uniform sampler2D _Layer1_Normal;
		uniform sampler2D _Layer2_Normal;
		uniform sampler2D _Layer3_Normal;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 UV6 = ( i.uv_texcoord * 0.01 );
			float2 temp_output_9_0 = ( UV6 * _layer1_tilling );
			float4 layer1_baseColor14 = tex2D( _Layer1_baseColor, temp_output_9_0 );
			float4 tex2DNode3 = tex2D( _Layer1_HRA, temp_output_9_0 );
			float layer1_heightmap34 = tex2DNode3.r;
			float4 tex2DNode167 = tex2D( _BlendMAP, i.uv2_texcoord2 );
			float2 temp_output_25_0 = ( UV6 * _layer2_tilling );
			float4 tex2DNode26 = tex2D( _Layer2_HRA, temp_output_25_0 );
			float layer2_heightmap35 = tex2DNode26.r;
			float2 temp_output_108_0 = ( UV6 * _layer3_tilling );
			float4 tex2DNode109 = tex2D( _Layer3_HRA, temp_output_108_0 );
			float layer3_heightmap110 = tex2DNode109.r;
			float3 appendResult162 = (float3(( layer1_heightmap34 + tex2DNode167.r ) , ( layer2_heightmap35 + tex2DNode167.g ) , ( layer3_heightmap110 + tex2DNode167.b )));
			float3 WeightheightFactor163 = appendResult162;
			float3 break166 = WeightheightFactor163;
			float temp_output_84_0 = ( max( max( break166.x , break166.y ) , break166.z ) - _BlendWeightContrast );
			float temp_output_89_0 = max( ( break166.x - temp_output_84_0 ) , 0.0 );
			float temp_output_90_0 = max( ( break166.y - temp_output_84_0 ) , 0.0 );
			float temp_output_91_0 = max( ( break166.z - temp_output_84_0 ) , 0.0 );
			float3 appendResult92 = (float3(temp_output_89_0 , temp_output_90_0 , temp_output_91_0));
			float3 BlendWeight95 = ( appendResult92 / ( temp_output_89_0 + temp_output_90_0 + temp_output_91_0 ) );
			float3 break100 = BlendWeight95;
			float4 layer2_baseColor30 = tex2D( _Layer2_baseColor, temp_output_25_0 );
			float4 layer3_baseColor115 = tex2D( _Layer3_baseColor, temp_output_108_0 );
			float4 blendWeight_baseColor120 = ( ( layer1_baseColor14 * break100.x ) + ( layer2_baseColor30 * break100.y ) + ( layer3_baseColor115 * break100.z ) );
			float temp_output_9_0_g2 = 0.0;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float dotResult190 = dot( float3(0,1,0) , ase_normWorldNormal );
			float clampResult192 = clamp( dotResult190 , 0.0 , 1.0 );
			float clampResult8_g2 = clamp( ( ( pow( ( 1.0 - clampResult192 ) , _SlopePower ) - 1.0 ) + ( 0.0 * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g2 = lerp( ( 0.0 - temp_output_9_0_g2 ) , ( temp_output_9_0_g2 + 1.0 ) , clampResult8_g2);
			float clampResult13_g2 = clamp( lerpResult12_g2 , 0.0 , 1.0 );
			float SlopeMask200 = clampResult13_g2;
			float4 lerpResult201 = lerp( blendWeight_baseColor120 , layer2_baseColor30 , SlopeMask200);
			s1.Albedo = lerpResult201.rgb;
			float3 layer1_normal15 = UnpackNormal( tex2D( _Layer1_Normal, temp_output_9_0 ) );
			float3 break135 = BlendWeight95;
			float3 layer2_normal31 = UnpackNormal( tex2D( _Layer2_Normal, temp_output_25_0 ) );
			float3 layer3_normal116 = UnpackNormal( tex2D( _Layer3_Normal, temp_output_108_0 ) );
			float3 blendWeight_normal143 = ( ( layer1_normal15 * break135.x ) + ( layer2_normal31 * break135.y ) + ( layer3_normal116 * break135.z ) );
			float3 lerpResult204 = lerp( blendWeight_normal143 , layer2_normal31 , SlopeMask200);
			s1.Normal = WorldNormalVector( i , lerpResult204 );
			s1.Emission = float3( 0,0,0 );
			s1.Metallic = 0.0;
			float layer1_roughness12 = tex2DNode3.g;
			float3 break146 = BlendWeight95;
			float layer2_roughness29 = tex2DNode26.g;
			float layer3_roughness111 = tex2DNode109.g;
			float blendWeight_roughness154 = ( ( layer1_roughness12 * break146.x ) + ( layer2_roughness29 * break146.y ) + ( layer3_roughness111 * break146.z ) );
			float lerpResult206 = lerp( ( 1.0 - blendWeight_roughness154 ) , ( 1.0 - layer2_roughness29 ) , SlopeMask200);
			s1.Smoothness = lerpResult206;
			float layer1_AO13 = tex2DNode3.b;
			float3 break124 = BlendWeight95;
			float layer2_AO32 = tex2DNode26.b;
			float layer3_AO114 = tex2DNode109.b;
			float blendWeight_AO132 = ( ( layer1_AO13 * break124.x ) + ( layer2_AO32 * break124.y ) + ( layer3_AO114 * break124.z ) );
			float lerpResult209 = lerp( blendWeight_AO132 , layer2_AO32 , SlopeMask200);
			s1.Occlusion = lerpResult209;

			data.light = gi.light;

			UnityGI gi1 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( s1.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
			gi1 = UnityGlobalIllumination( data, s1.Occlusion, s1.Normal, g1 );
			#endif

			float3 surfResult1 = LightingStandard ( s1, viewDir, gi1 ).rgb;
			surfResult1 += s1.Emission;

			#ifdef UNITY_PASS_FORWARDADD//1
			surfResult1 -= s1.Emission;
			#endif//1
			c.rgb = surfResult1;
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
				float4 customPack1 : TEXCOORD1;
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
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
131;307;1920;540;6644.284;-855.9073;3.310756;True;True
Node;AmplifyShaderEditor.CommentaryNode;7;-3112.644,-71.98146;Inherit;False;799;242;uv_region;4;6;5;173;174;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-3061.644,-30.98151;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;174;-2994.884,87.61237;Inherit;False;Constant;_Float2;Float 2;15;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-2712.884,-5.387634;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;105;-2960.938,1771.586;Inherit;False;1062.408;678.5378;layer3;11;115;114;116;113;111;112;110;109;108;107;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;11;-2943.521,352.4442;Inherit;False;1040.796;680.9394;layer1;11;14;13;15;2;4;12;34;3;9;10;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-3062.057,1066.648;Inherit;False;1160.867;676.1365;layer2;11;31;32;30;28;29;27;35;26;25;23;24;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-2545.644,-22.9815;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2893.521,633.4316;Inherit;False;Property;_layer1_tilling;layer1_tilling;10;0;Create;True;0;0;0;False;0;False;1;12.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3012.057,1347.636;Inherit;False;Property;_layer2_tilling;layer2_tilling;11;0;Create;True;0;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-3012.057,1263.636;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-2910.938,2052.576;Inherit;False;Property;_layer3_tilling;layer3_tilling;12;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-2910.938,1968.575;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-2893.521,549.4318;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-2719.939,1990.575;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2821.058,1285.636;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-2702.52,571.4318;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;109;-2537.198,2029.587;Inherit;True;Property;_Layer3_HRA;Layer3_HRA;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-2638.317,1324.648;Inherit;True;Property;_Layer2_HRA;Layer2_HRA;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-2519.78,610.4438;Inherit;True;Property;_Layer1_HRA;Layer1_HRA;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;161;-6210.846,1869.99;Inherit;False;1464.668;674.4569;heightFactor;10;167;163;162;160;158;156;157;159;155;172;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-2251.528,1286.162;Inherit;False;layer2_heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;-6190.684,2022.008;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-2147.527,2012.713;Inherit;False;layer3_heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-2150.371,590.7443;Inherit;False;layer1_heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-5536.674,2040.217;Inherit;False;35;layer2_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-5538.674,2150.218;Inherit;False;110;layer3_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-5532.328,1919.99;Inherit;False;34;layer1_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;167;-5893.66,1994.889;Inherit;True;Property;_BlendMAP;BlendMAP;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-5284.674,2035.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-5285.674,2153.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-5287.674,1919.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-5140.253,2008.869;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;96;-4717.142,1876.485;Inherit;False;1613.068;777;blendWeightregion;16;82;88;95;93;92;94;90;89;91;86;87;84;85;83;164;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-4981,2000.728;Inherit;False;WeightheightFactor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-4693.504,1969.646;Inherit;False;163;WeightheightFactor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;166;-4442.833,1975.669;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;82;-4387.847,2225.624;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-4447.165,2499.379;Inherit;False;Property;_BlendWeightContrast;BlendWeightContrast;14;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;83;-4244.605,2337.612;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-4084.93,2444.544;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;-3971.075,2159.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-3977.075,1927.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-3975.075,2044.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;90;-3816.33,2054.506;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;89;-3816.33,1931.506;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;91;-3814.33,2166.506;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;-3642.073,1986.485;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-3633.073,2169.485;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;196;-1786.203,2664.77;Inherit;False;1730.205;562.5808;Sloperegion;11;192;190;188;186;195;193;194;197;198;199;200;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;93;-3453.072,2016.485;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-3311.072,2010.485;Inherit;False;BlendWeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;186;-1725.434,2968.967;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;144;-1788.323,1698.109;Inherit;False;1228.764;445.4836;blendweight_normal;10;154;153;152;151;150;149;148;147;146;145;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;188;-1697.474,2811.692;Inherit;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;190;-1488.939,2861.787;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-2151.949,2093.12;Inherit;False;layer3_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;112;-2538.198,2242.588;Inherit;True;Property;_Layer3_Normal;Layer3_Normal;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-2635.317,1116.648;Inherit;True;Property;_Layer2_baseColor;Layer2_baseColor;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-2149.265,670.3494;Inherit;False;layer1_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;122;-1790.721,755.2946;Inherit;False;1228.764;445.4836;blendweight_ao;10;132;131;130;129;128;127;126;125;124;123;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1738.323,1748.109;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-2249.068,1389.181;Inherit;False;layer2_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-2520.78,823.444;Inherit;True;Property;_Layer1_Normal;Layer1_Normal;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;113;-2534.198,1821.586;Inherit;True;Property;_Layer3_baseColor;Layer3_baseColor;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-2516.78,402.444;Inherit;True;Property;_Layer1_baseColor;Layer1_baseColor;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-2639.317,1537.648;Inherit;True;Property;_Layer2_Normal;Layer2_Normal;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;133;-1786.411,1228.901;Inherit;False;1228.764;445.4836;blendweight_normal;10;143;142;141;140;139;138;137;136;135;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;121;-1794.521,275.5134;Inherit;False;1228.764;445.4836;blendweight_base;10;99;100;101;102;117;118;103;104;119;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1382.94,1871.224;Inherit;False;29;layer2_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-1379.559,1994.592;Inherit;False;111;layer3_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-2153.029,2172.734;Inherit;False;layer3_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;192;-1350.229,2860.189;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2146.99,846.9008;Inherit;False;layer1_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;146;-1539.94,1754.224;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;152;-1377.94,1751.224;Inherit;False;12;layer1_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-2252.207,1117.132;Inherit;False;layer2_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-1740.721,805.2946;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2147.265,757.3494;Inherit;False;layer1_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2248.148,1465.794;Inherit;False;layer2_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2120.99,407.9008;Inherit;False;layer1_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-2151.087,1822.07;Inherit;False;layer3_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-2151.381,2261.512;Inherit;False;layer3_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-1736.411,1278.901;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-1744.521,325.5134;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-2251.5,1556.572;Inherit;False;layer2_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-1377.647,1525.384;Inherit;False;116;layer3_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-1390.757,576.9971;Inherit;False;115;layer3_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1128.559,2008.592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;135;-1538.028,1285.016;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;139;-1381.028,1402.016;Inherit;False;31;layer2_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;193;-1199.369,2861.899;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-1384.138,328.6292;Inherit;False;14;layer1_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;100;-1546.138,331.6292;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-1133.94,1756.224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-1207.328,2982.916;Inherit;False;Property;_SlopePower;SlopePower;15;0;Create;True;0;0;0;False;0;False;1;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-1376.028,1282.016;Inherit;False;15;layer1_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-1385.338,928.4102;Inherit;False;32;layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;124;-1542.338,811.4103;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;127;-1383.957,1050.778;Inherit;False;114;layer3_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-1130.94,1880.224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-1389.138,448.6292;Inherit;False;30;layer2_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-1380.338,808.4103;Inherit;False;13;layer1_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;194;-984.0223,2855.765;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-1132.028,1287.016;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1129.028,1411.016;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1137.138,457.6292;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1130.957,1065.778;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1133.338,937.4102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1126.647,1539.384;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1140.138,333.6292;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1134.757,585.9971;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-957.559,1849.592;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-1136.338,813.4103;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-959.9572,906.7782;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-828.5593,1845.592;Inherit;False;blendWeight_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;197;-692.2682,2857.927;Inherit;False;HeightLerp;-1;;2;b0664893e7b17cd48b1e05fd8f7c6713;0;3;5;FLOAT;0;False;1;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-963.7573,426.9971;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-955.647,1380.384;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-839.7573,422.9971;Inherit;False;blendWeight_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-389.0071,2854.299;Inherit;False;SlopeMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-835.9572,902.7782;Inherit;False;blendWeight_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-827.8737,22.78021;Inherit;False;154;blendWeight_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-831.6471,1376.384;Inherit;False;blendWeight_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-796.692,114.7956;Inherit;False;29;layer2_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-574.811,28.24888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;208;-573.692,121.7956;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-895.9988,-337.1146;Inherit;False;200;SlopeMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-575.8737,-198.2198;Inherit;False;143;blendWeight_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-542.9386,-110.5273;Inherit;False;31;layer2_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-580.874,-517.2196;Inherit;False;120;blendWeight_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;98;-2808.639,2481.719;Inherit;False;914.8675;1444.251;old_func;4;68;74;62;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-543.8128,-436.1602;Inherit;False;30;layer2_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-380.7852,381.2289;Inherit;False;132;blendWeight_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;-349.4382,461.9;Inherit;False;32;layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-343.0384,558.4005;Inherit;False;200;SlopeMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;204;-195.9386,-176.5273;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;40;-3963.351,1400.187;Inherit;False;858.7;434;blendFactor;5;36;38;37;33;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2751.39,3575.182;Inherit;False;821.9878;320.0246;blend_roughness;5;79;78;77;76;75;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-160.8737,225.7802;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2758.639,2531.719;Inherit;False;827.4876;323.7136;blend_baseColor;5;44;43;42;46;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;206;-178.9994,46.04488;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;201;-180.8125,-456.1604;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2756.542,2877.274;Inherit;False;821.9878;320.0246;blend_AO;5;67;66;65;64;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2754.042,3220.766;Inherit;False;821.9878;320.0246;blend_normal;5;73;72;71;70;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;209;-68.43826,386.8001;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1786.417,2171.053;Inherit;False;1228.764;445.4836;blendweight_heightMap;10;185;184;183;182;181;180;179;178;177;176;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-3917.352,1628.187;Inherit;False;35;layer2_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-2672.541,2924.274;Inherit;False;13;layer1_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-2707.638,2581.719;Inherit;False;14;layer1_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-2180.941,3661.556;Inherit;False;blend_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;33;-3623.326,1587.619;Inherit;False;HeightLerp;-1;;3;b0664893e7b17cd48b1e05fd8f7c6713;0;3;5;FLOAT;0;False;1;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2188.191,2618.094;Inherit;False;blend_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-2186.094,2963.649;Inherit;False;blend_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-2704.042,3350.778;Inherit;False;31;layer2_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;80.33649,84.0253;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-2671.385,3782.205;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;-2381.651,2624.007;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-2687.037,3429.79;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;73;-2377.054,3313.053;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-2708.639,2661.732;Inherit;False;30;layer2_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-2697.39,3701.193;Inherit;False;29;layer2_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-2703.041,3270.766;Inherit;False;15;layer1_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;36;-3864.352,1450.188;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-3329.653,1583.387;Inherit;True;BlendFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;-931.0031,3050.134;Inherit;False;Property;_SlopeContrast;SlopeContrast;16;0;Create;True;0;0;0;False;0;False;0;2.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2674.542,3001.287;Inherit;False;32;layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;185;-826.653,2318.536;Inherit;False;blendWeight_heightMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-1736.417,2221.053;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-1381.034,2344.168;Inherit;False;35;layer2_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3887.352,1726.187;Inherit;False;Property;_BlendContrast;BlendContrast;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-1377.653,2467.536;Inherit;False;110;layer3_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;177;-1540.034,2228.168;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;180;-1376.034,2224.168;Inherit;False;34;layer1_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-1126.653,2481.536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-1129.034,2353.168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1132.034,2229.168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-955.6527,2322.536;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-1003.802,2956.965;Inherit;False;185;blendWeight_heightMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;79;-2374.402,3667.469;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2183.594,3307.14;Inherit;False;blend_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;67;-2379.554,2969.562;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-2678.634,2738.744;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2700.389,3624.182;Inherit;False;12;layer1_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2676.538,3084.299;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;422,-112;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;k33_mat_blend_moutain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;173;0;5;0
WireConnection;173;1;174;0
WireConnection;6;0;173;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;109;1;108;0
WireConnection;26;1;25;0
WireConnection;3;1;9;0
WireConnection;35;0;26;1
WireConnection;110;0;109;1
WireConnection;34;0;3;1
WireConnection;167;1;172;0
WireConnection;158;0;157;0
WireConnection;158;1;167;2
WireConnection;160;0;159;0
WireConnection;160;1;167;3
WireConnection;156;0;155;0
WireConnection;156;1;167;1
WireConnection;162;0;156;0
WireConnection;162;1;158;0
WireConnection;162;2;160;0
WireConnection;163;0;162;0
WireConnection;166;0;164;0
WireConnection;82;0;166;0
WireConnection;82;1;166;1
WireConnection;83;0;82;0
WireConnection;83;1;166;2
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;88;0;166;2
WireConnection;88;1;84;0
WireConnection;86;0;166;0
WireConnection;86;1;84;0
WireConnection;87;0;166;1
WireConnection;87;1;84;0
WireConnection;90;0;87;0
WireConnection;89;0;86;0
WireConnection;91;0;88;0
WireConnection;92;0;89;0
WireConnection;92;1;90;0
WireConnection;92;2;91;0
WireConnection;94;0;89;0
WireConnection;94;1;90;0
WireConnection;94;2;91;0
WireConnection;93;0;92;0
WireConnection;93;1;94;0
WireConnection;95;0;93;0
WireConnection;190;0;188;0
WireConnection;190;1;186;0
WireConnection;111;0;109;2
WireConnection;112;1;108;0
WireConnection;27;1;25;0
WireConnection;12;0;3;2
WireConnection;29;0;26;2
WireConnection;4;1;9;0
WireConnection;113;1;108;0
WireConnection;2;1;9;0
WireConnection;28;1;25;0
WireConnection;114;0;109;3
WireConnection;192;0;190;0
WireConnection;15;0;4;0
WireConnection;146;0;145;0
WireConnection;30;0;27;0
WireConnection;13;0;3;3
WireConnection;32;0;26;3
WireConnection;14;0;2;0
WireConnection;115;0;113;0
WireConnection;116;0;112;0
WireConnection;31;0;28;0
WireConnection;148;0;153;0
WireConnection;148;1;146;2
WireConnection;135;0;134;0
WireConnection;193;0;192;0
WireConnection;100;0;99;0
WireConnection;147;0;152;0
WireConnection;147;1;146;0
WireConnection;124;0;123;0
WireConnection;150;0;149;0
WireConnection;150;1;146;1
WireConnection;194;0;193;0
WireConnection;194;1;195;0
WireConnection;137;0;136;0
WireConnection;137;1;135;0
WireConnection;140;0;139;0
WireConnection;140;1;135;1
WireConnection;104;0;103;0
WireConnection;104;1;100;1
WireConnection;128;0;127;0
WireConnection;128;1;124;2
WireConnection;130;0;129;0
WireConnection;130;1;124;1
WireConnection;138;0;142;0
WireConnection;138;1;135;2
WireConnection;102;0;101;0
WireConnection;102;1;100;0
WireConnection;118;0;117;0
WireConnection;118;1;100;2
WireConnection;151;0;147;0
WireConnection;151;1;150;0
WireConnection;151;2;148;0
WireConnection;126;0;125;0
WireConnection;126;1;124;0
WireConnection;131;0;126;0
WireConnection;131;1;130;0
WireConnection;131;2;128;0
WireConnection;154;0;151;0
WireConnection;197;1;194;0
WireConnection;119;0;102;0
WireConnection;119;1;104;0
WireConnection;119;2;118;0
WireConnection;141;0;137;0
WireConnection;141;1;140;0
WireConnection;141;2;138;0
WireConnection;120;0;119;0
WireConnection;200;0;197;0
WireConnection;132;0;131;0
WireConnection;143;0;141;0
WireConnection;19;0;18;0
WireConnection;208;0;207;0
WireConnection;204;0;17;0
WireConnection;204;1;205;0
WireConnection;204;2;202;0
WireConnection;206;0;19;0
WireConnection;206;1;208;0
WireConnection;206;2;202;0
WireConnection;201;0;16;0
WireConnection;201;1;203;0
WireConnection;201;2;202;0
WireConnection;209;0;20;0
WireConnection;209;1;211;0
WireConnection;209;2;210;0
WireConnection;75;0;79;0
WireConnection;33;1;36;1
WireConnection;46;0;41;0
WireConnection;63;0;67;0
WireConnection;1;0;201;0
WireConnection;1;1;204;0
WireConnection;1;3;21;0
WireConnection;1;4;206;0
WireConnection;1;5;209;0
WireConnection;41;0;42;0
WireConnection;41;1;43;0
WireConnection;41;2;44;0
WireConnection;73;0;70;0
WireConnection;73;1;71;0
WireConnection;73;2;72;0
WireConnection;39;0;33;0
WireConnection;185;0;184;0
WireConnection;177;0;176;0
WireConnection;183;0;179;0
WireConnection;183;1;177;2
WireConnection;182;0;178;0
WireConnection;182;1;177;1
WireConnection;181;0;180;0
WireConnection;181;1;177;0
WireConnection;184;0;181;0
WireConnection;184;1;182;0
WireConnection;184;2;183;0
WireConnection;79;0;76;0
WireConnection;79;1;77;0
WireConnection;79;2;78;0
WireConnection;69;0;73;0
WireConnection;67;0;64;0
WireConnection;67;1;65;0
WireConnection;67;2;66;0
WireConnection;0;13;1;0
ASEEND*/
//CHKSM=ED39A254F07DB20602D167770A2E5C6B37D59712