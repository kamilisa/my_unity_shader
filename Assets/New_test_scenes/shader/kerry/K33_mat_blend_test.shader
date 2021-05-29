// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k33_mat_blend"
{
	Properties
	{
		_Layer1_baseColor("Layer1_baseColor", 2D) = "white" {}
		_Layer2_baseColor("Layer2_baseColor", 2D) = "white" {}
		_Layer1_HRA("Layer1_HRA", 2D) = "white" {}
		_Layer2_HRA("Layer2_HRA", 2D) = "white" {}
		_Layer1_Normal("Layer1_Normal", 2D) = "bump" {}
		_Layer2_Normal("Layer2_Normal", 2D) = "bump" {}
		_layer1_tilling("layer1_tilling", Float) = 1
		_layer2_tilling("layer2_tilling", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
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
		uniform sampler2D _Layer2_baseColor;
		uniform float _layer2_tilling;
		uniform sampler2D _Layer2_HRA;
		uniform sampler2D _Layer1_Normal;
		uniform sampler2D _Layer2_Normal;
		uniform sampler2D _Layer1_HRA;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 UV6 = i.uv_texcoord;
			float2 temp_output_9_0 = ( UV6 * _layer1_tilling );
			float4 layer1_baseColor14 = tex2D( _Layer1_baseColor, temp_output_9_0 );
			float2 temp_output_25_0 = ( UV6 * _layer2_tilling );
			float4 layer2_baseColor30 = tex2D( _Layer2_baseColor, temp_output_25_0 );
			float temp_output_9_0_g1 = 0.0;
			float4 tex2DNode26 = tex2D( _Layer2_HRA, temp_output_25_0 );
			float layer2_heightmap35 = tex2DNode26.r;
			float clampResult8_g1 = clamp( ( ( layer2_heightmap35 - 1.0 ) + ( 0.0 * 2.0 ) ) , 0.0 , 1.0 );
			float lerpResult12_g1 = lerp( ( 0.0 - temp_output_9_0_g1 ) , ( temp_output_9_0_g1 + 1.0 ) , clampResult8_g1);
			float clampResult13_g1 = clamp( lerpResult12_g1 , 0.0 , 1.0 );
			float BlendFactor39 = clampResult13_g1;
			float4 lerpResult41 = lerp( layer1_baseColor14 , layer2_baseColor30 , BlendFactor39);
			float4 blend_baseColor46 = lerpResult41;
			s1.Albedo = blend_baseColor46.rgb;
			float3 layer1_normal15 = UnpackNormal( tex2D( _Layer1_Normal, temp_output_9_0 ) );
			float3 layer2_normal31 = UnpackNormal( tex2D( _Layer2_Normal, temp_output_25_0 ) );
			float3 lerpResult73 = lerp( layer1_normal15 , layer2_normal31 , BlendFactor39);
			float3 blend_normal69 = lerpResult73;
			s1.Normal = WorldNormalVector( i , blend_normal69 );
			s1.Emission = float3( 0,0,0 );
			s1.Metallic = 0.0;
			float4 tex2DNode3 = tex2D( _Layer1_HRA, temp_output_9_0 );
			float layer1_roughness12 = tex2DNode3.g;
			float layer2_roughness29 = tex2DNode26.g;
			float lerpResult79 = lerp( layer1_roughness12 , layer2_roughness29 , BlendFactor39);
			float blend_roughness75 = lerpResult79;
			s1.Smoothness = ( 1.0 - blend_roughness75 );
			float layer1_AO13 = tex2DNode3.b;
			float layer2_AO32 = tex2DNode26.b;
			float lerpResult67 = lerp( layer1_AO13 , layer2_AO32 , BlendFactor39);
			float blend_AO63 = lerpResult67;
			s1.Occlusion = blend_AO63;

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
				float2 customPack1 : TEXCOORD1;
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
0;313;1920;534;1792.238;310.5804;1.662874;True;True
Node;AmplifyShaderEditor.CommentaryNode;7;-3046.644,-19.98146;Inherit;False;527;212;uv_region;2;5;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-2996.644,33.01849;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;22;-3064.459,1054.641;Inherit;False;1182.48;781.7995;layer2;11;32;31;30;29;28;27;26;25;24;23;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-2743.644,30.0185;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3014.459,1335.629;Inherit;False;Property;_layer2_tilling;layer2_tilling;11;0;Create;True;0;0;0;False;0;False;1;2.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-3014.459,1251.629;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2823.46,1273.629;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;11;-3058.789,246.7812;Inherit;False;1182.48;781.7995;layer1;11;4;3;2;10;8;9;12;13;14;15;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;26;-2640.719,1312.641;Inherit;True;Property;_Layer2_HRA;Layer2_HRA;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;8;-3008.789,443.7689;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3008.789,527.7688;Inherit;False;Property;_layer1_tilling;layer1_tilling;10;0;Create;True;0;0;0;False;0;False;1;1.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-2252.489,1295.767;Inherit;False;layer2_heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-3963.351,1400.187;Inherit;False;858.7;434;blendFactor;5;36;38;37;33;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-2817.788,465.7689;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-3905.352,1458.187;Inherit;False;35;layer2_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;33;-3623.326,1587.619;Inherit;False;HeightLerp;-1;;1;b0664893e7b17cd48b1e05fd8f7c6713;0;3;5;FLOAT;0;False;1;FLOAT;0;False;9;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2635.048,504.781;Inherit;True;Property;_Layer1_HRA;Layer1_HRA;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;98;-2853.848,2716.74;Inherit;False;965.3475;1416.487;old_func;4;74;68;45;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-2636.048,717.7811;Inherit;True;Property;_Layer1_Normal;Layer1_Normal;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-2260.533,574.6866;Inherit;False;layer1_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-3329.653,1583.387;Inherit;True;BlendFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-2637.719,1104.641;Inherit;True;Property;_Layer2_baseColor;Layer2_baseColor;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;74;-2796.599,3810.203;Inherit;False;821.9878;320.0246;blend_roughness;5;79;78;77;76;75;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;2;-2632.048,296.7811;Inherit;True;Property;_Layer1_baseColor;Layer1_baseColor;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-2641.719,1525.641;Inherit;True;Property;_Layer2_Normal;Layer2_Normal;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-2251.47,1377.174;Inherit;False;layer2_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2262.258,741.2379;Inherit;False;layer1_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2745.598,3859.203;Inherit;False;12;layer1_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-2742.599,3936.214;Inherit;False;29;layer2_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-2253.902,1544.565;Inherit;False;layer2_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2250.55,1453.787;Inherit;False;layer2_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2236.258,302.2379;Inherit;False;layer1_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-2716.594,4017.226;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-2254.609,1105.125;Inherit;False;layer2_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2803.848,2766.74;Inherit;False;865.3475;321.1897;blend_baseColor;5;46;41;44;43;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2801.751,3112.295;Inherit;False;821.9878;320.0246;blend_AO;5;67;66;65;64;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2799.251,3455.787;Inherit;False;821.9878;320.0246;blend_normal;5;73;72;71;70;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-2256.533,648.6865;Inherit;False;layer1_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-2752.847,2816.74;Inherit;False;14;layer1_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-2717.75,3159.295;Inherit;False;13;layer1_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2721.747,3319.32;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2719.751,3236.308;Inherit;False;32;layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-2723.843,2973.765;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-2749.251,3585.799;Inherit;False;31;layer2_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;79;-2419.611,3902.49;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-2732.246,3664.811;Inherit;False;39;BlendFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-2753.848,2896.753;Inherit;False;30;layer2_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-2748.25,3505.787;Inherit;False;15;layer1_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;73;-2422.263,3548.074;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;41;-2426.86,2859.028;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;67;-2424.763,3204.583;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-2226.15,3896.577;Inherit;False;blend_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2233.4,2853.115;Inherit;False;blend_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-429.8737,283.7802;Inherit;False;75;blend_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-2231.303,3198.67;Inherit;False;blend_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2228.803,3542.161;Inherit;False;blend_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;133;-1786.411,1228.901;Inherit;False;1228.764;445.4836;blendweight_normal;10;143;142;141;140;139;138;137;136;135;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;122;-1790.721,755.2946;Inherit;False;1228.764;445.4836;blendweight_ao;10;132;131;130;129;128;127;126;125;124;123;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-172.8737,188.7802;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-1783.609,1709.108;Inherit;False;1228.764;445.4836;blendweight_normal;10;154;153;152;151;150;149;148;147;146;145;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;105;-3066.601,1877.25;Inherit;False;1182.48;781.7995;layer3;11;116;115;114;113;112;111;110;109;108;107;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-236.8737,24.78024;Inherit;False;46;blend_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-236.8737,103.7802;Inherit;False;69;blend_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-200.8737,369.7802;Inherit;False;63;blend_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-177.8737,286.7802;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;96;-4717.142,1876.485;Inherit;False;1613.068;777;blendWeightregion;16;82;88;95;93;92;94;90;89;91;86;87;84;85;83;164;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;161;-6210.846,1869.99;Inherit;False;1464.668;674.4569;heightFactor;10;167;168;163;162;160;158;156;157;159;155;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;121;-1794.521,275.5134;Inherit;False;1228.764;445.4836;blendweight_base;10;99;100;101;102;117;118;103;104;119;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-3975.075,2044.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;-4981,2000.728;Inherit;False;WeightheightFactor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-3977.075,1927.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-1740.721,805.2946;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1134.757,585.9971;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1126.647,1539.384;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-4447.165,2499.379;Inherit;False;Property;_BlendWeightContrast;BlendWeightContrast;14;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;90;-3816.33,2054.506;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-5140.253,2008.869;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;91;-3814.33,2166.506;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-3633.073,2169.485;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;-3642.073,1986.485;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;93;-3453.072,2016.485;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-3311.072,2010.485;Inherit;False;BlendWeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1123.845,2019.591;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-4135.165,2433.38;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-2257.612,2198.784;Inherit;False;layer3_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;89;-3816.33,1931.506;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;135;-1538.028,1285.016;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;136;-1376.028,1282.016;Inherit;False;15;layer1_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-1385.338,928.4102;Inherit;False;32;layer2_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-1384.138,328.6292;Inherit;False;14;layer1_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;83;-4257.165,2347.38;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-2258.692,2278.398;Inherit;False;layer3_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-5287.674,1919.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1378.226,1882.223;Inherit;False;29;layer2_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-1744.521,325.5134;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-5285.674,2153.218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;-1381.028,1402.016;Inherit;False;31;layer2_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-1383.957,1050.778;Inherit;False;114;layer3_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-1389.138,448.6292;Inherit;False;30;layer2_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-1377.647,1525.384;Inherit;False;116;layer3_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;100;-1546.138,331.6292;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;134;-1736.411,1278.901;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;124;-1542.338,811.4103;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;117;-1390.757,576.9971;Inherit;False;115;layer3_baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-1380.338,808.4103;Inherit;False;13;layer1_AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-1129.226,1767.223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-1126.226,1891.223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-1373.226,1762.223;Inherit;False;12;layer1_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-959.9572,906.7782;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1733.609,1759.108;Inherit;False;95;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;167;-5893.66,1994.889;Inherit;True;Property;_BlendMAP;BlendMAP;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;157;-5536.674,2040.217;Inherit;False;35;layer2_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-6157.185,2020.04;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1130.957,1065.778;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1140.138,333.6292;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-1129.028,1411.016;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-835.9572,902.7782;Inherit;False;blendWeight_AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-831.6471,1376.384;Inherit;False;blendWeight_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-5284.674,2035.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;-3971.075,2159.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-963.7573,426.9971;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-839.7573,422.9971;Inherit;False;blendWeight_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-823.8454,1856.591;Inherit;False;blendWeight_roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-952.8451,1860.591;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-955.647,1380.384;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-3866.352,1724.187;Inherit;False;Property;_BlendContrast;BlendContrast;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;36;-3856.352,1546.188;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;155;-5532.328,1919.99;Inherit;False;34;layer1_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-2259.639,500.0814;Inherit;False;layer1_heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;80.33649,84.0253;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;81;-5757.517,1694.325;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;166;-4442.833,1975.669;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;164;-4693.504,1969.646;Inherit;False;163;WeightheightFactor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;113;-2639.861,1927.25;Inherit;True;Property;_Layer3_baseColor;Layer3_baseColor;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;112;-2643.861,2348.252;Inherit;True;Property;_Layer3_Normal;Layer3_Normal;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;153;-1374.845,2005.591;Inherit;False;111;layer3_roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-2257.044,2367.176;Inherit;False;layer3_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-2256.75,1927.734;Inherit;False;layer3_baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;146;-1535.226,1765.223;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;82;-4375.286,2232.601;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-1132.028,1287.016;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-1136.338,813.4103;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-5538.674,2150.218;Inherit;False;110;layer3_heightmap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-3016.601,2158.24;Inherit;False;Property;_layer3_tilling;layer3_tilling;12;0;Create;True;0;0;0;False;0;False;1;4.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-3016.601,2074.239;Inherit;False;6;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-2825.602,2096.239;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;109;-2642.861,2135.251;Inherit;True;Property;_Layer3_HRA;Layer3_HRA;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1137.138,457.6292;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-2254.631,2118.377;Inherit;False;layer3_heightmap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1133.338,937.4102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;422,-112;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;k33_mat_blend;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;5;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;26;1;25;0
WireConnection;35;0;26;1
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;33;1;38;0
WireConnection;3;1;9;0
WireConnection;4;1;9;0
WireConnection;12;0;3;2
WireConnection;39;0;33;0
WireConnection;27;1;25;0
WireConnection;2;1;9;0
WireConnection;28;1;25;0
WireConnection;29;0;26;2
WireConnection;15;0;4;0
WireConnection;31;0;28;0
WireConnection;32;0;26;3
WireConnection;14;0;2;0
WireConnection;30;0;27;0
WireConnection;13;0;3;3
WireConnection;79;0;76;0
WireConnection;79;1;77;0
WireConnection;79;2;78;0
WireConnection;73;0;70;0
WireConnection;73;1;71;0
WireConnection;73;2;72;0
WireConnection;41;0;42;0
WireConnection;41;1;43;0
WireConnection;41;2;44;0
WireConnection;67;0;64;0
WireConnection;67;1;65;0
WireConnection;67;2;66;0
WireConnection;75;0;79;0
WireConnection;46;0;41;0
WireConnection;63;0;67;0
WireConnection;69;0;73;0
WireConnection;19;0;18;0
WireConnection;87;0;166;1
WireConnection;87;1;84;0
WireConnection;163;0;162;0
WireConnection;86;0;166;0
WireConnection;86;1;84;0
WireConnection;118;0;117;0
WireConnection;118;1;100;2
WireConnection;138;0;142;0
WireConnection;138;1;135;2
WireConnection;90;0;87;0
WireConnection;162;0;156;0
WireConnection;162;1;158;0
WireConnection;162;2;160;0
WireConnection;91;0;88;0
WireConnection;94;0;89;0
WireConnection;94;1;90;0
WireConnection;94;2;91;0
WireConnection;92;0;89;0
WireConnection;92;1;90;0
WireConnection;92;2;91;0
WireConnection;93;0;92;0
WireConnection;93;1;94;0
WireConnection;95;0;93;0
WireConnection;148;0;153;0
WireConnection;148;1;146;2
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;111;0;109;2
WireConnection;89;0;86;0
WireConnection;135;0;134;0
WireConnection;83;0;82;0
WireConnection;83;1;166;2
WireConnection;114;0;109;3
WireConnection;156;0;155;0
WireConnection;156;1;167;1
WireConnection;160;0;159;0
WireConnection;160;1;167;3
WireConnection;100;0;99;0
WireConnection;124;0;123;0
WireConnection;147;0;152;0
WireConnection;147;1;146;0
WireConnection;150;0;149;0
WireConnection;150;1;146;1
WireConnection;131;0;126;0
WireConnection;131;1;130;0
WireConnection;131;2;128;0
WireConnection;167;1;168;0
WireConnection;128;0;127;0
WireConnection;128;1;124;2
WireConnection;102;0;101;0
WireConnection;102;1;100;0
WireConnection;140;0;139;0
WireConnection;140;1;135;1
WireConnection;132;0;131;0
WireConnection;143;0;141;0
WireConnection;158;0;157;0
WireConnection;158;1;167;2
WireConnection;88;0;166;2
WireConnection;88;1;84;0
WireConnection;119;0;102;0
WireConnection;119;1;104;0
WireConnection;119;2;118;0
WireConnection;120;0;119;0
WireConnection;154;0;151;0
WireConnection;151;0;147;0
WireConnection;151;1;150;0
WireConnection;151;2;148;0
WireConnection;141;0;137;0
WireConnection;141;1;140;0
WireConnection;141;2;138;0
WireConnection;34;0;3;1
WireConnection;1;0;16;0
WireConnection;1;1;17;0
WireConnection;1;3;21;0
WireConnection;1;4;19;0
WireConnection;1;5;20;0
WireConnection;166;0;164;0
WireConnection;113;1;108;0
WireConnection;112;1;108;0
WireConnection;116;0;112;0
WireConnection;115;0;113;0
WireConnection;146;0;145;0
WireConnection;82;0;166;0
WireConnection;82;1;166;1
WireConnection;137;0;136;0
WireConnection;137;1;135;0
WireConnection;126;0;125;0
WireConnection;126;1;124;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;109;1;108;0
WireConnection;104;0;103;0
WireConnection;104;1;100;1
WireConnection;110;0;109;1
WireConnection;130;0;129;0
WireConnection;130;1;124;1
WireConnection;0;13;1;0
ASEEND*/
//CHKSM=74DC0909B9F64A5484474C8BD58BDF5FC2C77525