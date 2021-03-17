// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "kerry/k21_ase_crystal"
{
	Properties
	{
		_Normal_map("Normal_map", 2D) = "white" {}
		_Gap_map("Gap_map", 2D) = "black" {}
		_Inner_map("Inner_map", 2D) = "white" {}
		_Tilling_offset("Tilling_offset", Vector) = (1,1,0,0)
		_UV_distort("UV_distort", Float) = 0
		_Reflect_Map("Reflect_Map", CUBE) = "white" {}
		_Reflect_radius("Reflect_radius", Float) = 3.7
		_Reflect_scale("Reflect_scale", Range( 0 , 2)) = 1
		_fresnel_pow("fresnel_pow", Float) = 3
		_fresnel_scale("fresnel_scale", Float) = 1
		_Fresnel_Color("Fresnel_Color", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
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
			float2 uv_texcoord;
			float3 worldRefl;
		};

		uniform sampler2D _Normal_map;
		uniform float4 _Normal_map_ST;
		uniform float _fresnel_scale;
		uniform float _fresnel_pow;
		uniform sampler2D _Gap_map;
		uniform float4 _Gap_map_ST;
		uniform float4 _Fresnel_Color;
		uniform samplerCUBE _Reflect_Map;
		uniform float _Reflect_scale;
		uniform float _Reflect_radius;
		uniform sampler2D _Inner_map;
		uniform float4 _Tilling_offset;
		uniform float _UV_distort;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_Normal_map = i.uv_texcoord * _Normal_map_ST.xy + _Normal_map_ST.zw;
			float4 tex2DNode7 = tex2D( _Normal_map, uv_Normal_map );
			float3 world_normal21 = normalize( (WorldNormalVector( i , tex2DNode7.rgb )) );
			float fresnelNdotV4 = dot( world_normal21, ase_worldViewDir );
			float fresnelNode4 = ( 0.0 + _fresnel_scale * pow( max( 1.0 - fresnelNdotV4 , 0.0001 ), _fresnel_pow ) );
			float2 uv_Gap_map = i.uv_texcoord * _Gap_map_ST.xy + _Gap_map_ST.zw;
			float temp_output_14_0 = ( fresnelNode4 + tex2D( _Gap_map, uv_Gap_map ).r );
			float4 RimColor16 = ( temp_output_14_0 * _Fresnel_Color );
			float4 normalMap32 = tex2DNode7;
			float dotResult27 = dot( (WorldNormalVector( i , normalMap32.rgb )) , ase_worldViewDir );
			float clampResult28 = clamp( ( 1.0 - dotResult27 ) , 0.0 , 1.0 );
			float4 reflect_layer35 = ( texCUBE( _Reflect_Map, normalize( WorldReflectionVector( i , normalMap32.rgb ) ) ) * _Reflect_scale * pow( clampResult28 , _Reflect_radius ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView47 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView58 = mul( UNITY_MATRIX_MV, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 worldToViewDir65 = mul( UNITY_MATRIX_V, float4( world_normal21, 0 ) ).xyz;
			float4 InnerMap45 = tex2D( _Inner_map, ( float3( ( ( (( objToView47 - objToView58 )).xy * (_Tilling_offset).xy ) + (_Tilling_offset).zw ) ,  0.0 ) + ( worldToViewDir65 * _UV_distort ) ).xy );
			o.Emission = ( RimColor16 + reflect_layer35 + InnerMap45 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
0;60;1920;959;514.799;77.75488;1;True;False
Node;AmplifyShaderEditor.SamplerNode;7;-1633.887,-346.1425;Inherit;True;Property;_Normal_map;Normal_map;0;0;Create;True;0;0;0;False;0;False;-1;None;fc4c4b2f95cb8354eb373ef3d4fa96d6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;63;-1935.866,1278.651;Inherit;False;1999.886;751.6052;Inner_map;17;46;58;47;51;57;52;48;59;62;54;53;56;61;60;44;45;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;46;-1885.866,1345.055;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;43;-1724.295,509.3669;Inherit;False;1800.885;694.332;fresnel_layer;14;42;26;40;27;23;29;28;20;31;19;30;24;25;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1313.624,-429.7688;Inherit;False;normalMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1674.295,833.0789;Inherit;False;32;normalMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;5;-1304.725,-339.3138;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;47;-1668.111,1340.192;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;58;-1667.714,1515.401;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1078.962,-344.2155;Inherit;False;world_normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;40;-1453.441,839.8201;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;26;-1441.706,1015.699;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-1409.714,1350.401;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;51;-1422.756,1630.897;Inherit;False;Property;_Tilling_offset;Tilling_offset;3;0;Create;True;0;0;0;False;0;False;1,1,0,0;1.09,0.58,0.45,0.43;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;18;-2071.745,-125.9972;Inherit;False;1754.188;614.3751;Comment;11;6;8;9;4;13;14;10;12;16;22;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;48;-1160.052,1334.385;Inherit;True;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-1420.177,1834.464;Inherit;False;21;world_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;27;-1186.81,879.1254;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;52;-1128.254,1610.797;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1603.503,229.6069;Inherit;False;Property;_fresnel_pow;fresnel_pow;8;0;Create;True;0;0;0;False;0;False;3;2.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;54;-1122.336,1710.556;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;65;-1177.489,1831.239;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-964.2555,1518.797;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1610.503,312.9369;Inherit;False;Property;_fresnel_scale;fresnel_scale;9;0;Create;True;0;0;0;False;0;False;1;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-1033.809,874.1254;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1414.27,628.4705;Inherit;False;32;normalMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1620.48,-67.11019;Inherit;False;21;world_normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;6;-1593.742,18.27513;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;62;-955.6102,1924.256;Inherit;False;Property;_UV_distort;UV_distort;4;0;Create;True;0;0;0;False;0;False;0;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-818.3373,1599.256;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;4;-1345.858,-37.32243;Inherit;True;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-808.6102,1826.256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldReflectionVector;20;-1152.656,636.9674;Inherit;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;31;-858.2925,997.5176;Inherit;False;Property;_Reflect_radius;Reflect_radius;6;0;Create;True;0;0;0;False;0;False;3.7;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-1335.466,258.378;Inherit;True;Property;_Gap_map;Gap_map;1;0;Create;True;0;0;0;False;0;False;-1;None;7b604225aa92e7642b1ea31ad12520c4;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;28;-828.3571,871.7241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-984.9507,221.6813;Inherit;False;Property;_Fresnel_Color;Fresnel_Color;10;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.6037736,0.3332147,0.4961605,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1023.054,-36.42261;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;-644.2925,875.5173;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-588.1772,1653.464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;19;-869.8145,559.3669;Inherit;True;Property;_Reflect_Map;Reflect_Map;5;0;Create;True;0;0;0;False;0;False;-1;None;0f85885515559e6408ac8bc345ccf5b6;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-846.354,761.6685;Inherit;False;Property;_Reflect_scale;Reflect_scale;7;0;Create;True;0;0;0;False;0;False;1;0.52;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-724.2574,-37.13115;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;-502.1451,1332.158;Inherit;True;Property;_Inner_map;Inner_map;2;0;Create;True;0;0;0;False;0;False;-1;None;480f997e79e5cd14b9380f3cbdcc04fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-418.1122,583.9453;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-159.9817,1328.651;Inherit;False;InnerMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-532.6033,-37.27001;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-147.4105,578.4775;Inherit;False;reflect_layer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;181.2539,49.93349;Inherit;False;35;reflect_layer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;188.3501,144.5774;Inherit;False;45;InnerMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;191.155,-45.92472;Inherit;False;16;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-981.6741,116.9961;Inherit;False;fresnel_mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;537.4734,-17.69797;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;967.5173,3.708097;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;kerry/k21_ase_crystal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;7;0
WireConnection;5;0;7;0
WireConnection;47;0;46;0
WireConnection;21;0;5;0
WireConnection;40;0;42;0
WireConnection;57;0;47;0
WireConnection;57;1;58;0
WireConnection;48;0;57;0
WireConnection;27;0;40;0
WireConnection;27;1;26;0
WireConnection;52;0;51;0
WireConnection;54;0;51;0
WireConnection;65;0;59;0
WireConnection;53;0;48;0
WireConnection;53;1;52;0
WireConnection;29;0;27;0
WireConnection;56;0;53;0
WireConnection;56;1;54;0
WireConnection;4;0;22;0
WireConnection;4;4;6;0
WireConnection;4;2;9;0
WireConnection;4;3;8;0
WireConnection;61;0;65;0
WireConnection;61;1;62;0
WireConnection;20;0;23;0
WireConnection;28;0;29;0
WireConnection;14;0;4;0
WireConnection;14;1;13;1
WireConnection;30;0;28;0
WireConnection;30;1;31;0
WireConnection;60;0;56;0
WireConnection;60;1;61;0
WireConnection;19;1;20;0
WireConnection;12;0;14;0
WireConnection;12;1;10;0
WireConnection;44;1;60;0
WireConnection;25;0;19;0
WireConnection;25;1;24;0
WireConnection;25;2;30;0
WireConnection;45;0;44;0
WireConnection;16;0;12;0
WireConnection;35;0;25;0
WireConnection;68;0;14;0
WireConnection;34;0;17;0
WireConnection;34;1;36;0
WireConnection;34;2;49;0
WireConnection;2;2;34;0
ASEEND*/
//CHKSM=102090A3A90453BD67E4412A24C2CEAF686F9ED1