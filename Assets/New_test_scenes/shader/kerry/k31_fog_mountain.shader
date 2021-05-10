// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k31_fog_moutain"
{
	Properties
	{
		_FogColor("Fog Color", Color) = (1,1,1,0)
		_FogDistanceStart("Fog Distance Start", Float) = 200
		_FogDistanceEnd("Fog Distance End", Float) = 700
		_FogHeightStart("Fog Height Start", Float) = 200
		_FogHeightEnd("Fog Height End", Float) = 700
		_SunFogColor("Sun Fog Color", Color) = (1,0.5806912,0.25,0)
		_SunFogintensity("Sun Fog intensity", Float) = 1
		_SunFogrange("Sun Fog range", Float) = 10
		_BaseColor("BaseColor", Color) = (0.5,0.5,0.5,0)
		_SmoothNess("SmoothNess", Range( 0 , 1)) = 0
		_FogIntensity("Fog Intensity", Range( 0 , 1)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
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

		uniform float _SmoothNess;
		uniform float4 _BaseColor;
		uniform float4 _FogColor;
		uniform float4 _SunFogColor;
		uniform float _SunFogrange;
		uniform float _SunFogintensity;
		uniform float _FogIntensity;
		uniform float _FogDistanceEnd;
		uniform float _FogDistanceStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldNormal = i.worldNormal;
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( _SmoothNess, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular1 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g1 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult39 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult44 = clamp( pow( (dotResult39*0.5 + 0.5) , _SunFogrange ) , 0.0 , 1.0 );
			float SunFog47 = ( clampResult44 * _SunFogintensity );
			float4 lerpResult51 = lerp( _FogColor , _SunFogColor , SunFog47);
			float temp_output_11_0_g5 = _FogDistanceEnd;
			float clampResult8_g5 = clamp( ( ( temp_output_11_0_g5 - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( temp_output_11_0_g5 - _FogDistanceStart ) ) , 0.0 , 1.0 );
			float FogDistance20 = ( 1.0 - clampResult8_g5 );
			float temp_output_11_0_g4 = _FogHeightEnd;
			float clampResult8_g4 = clamp( ( ( temp_output_11_0_g4 - ase_worldPos.y ) / ( temp_output_11_0_g4 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float FogHeight31 = ( 1.0 - clampResult8_g4 );
			float4 lerpResult17 = lerp( ( float4( indirectSpecular1 , 0.0 ) * _BaseColor ) , ( lerpResult51 * _FogIntensity ) , ( _FogIntensity * ( FogDistance20 * FogHeight31 ) ));
			c.rgb = lerpResult17.rgb;
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
0;30;1920;989;1635.487;-401.9618;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;49;-903.5636,1190.649;Inherit;False;1503.809;415.3921;Sun fog;11;36;40;37;39;41;43;42;46;44;45;47;;1,0.5821822,0,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;36;-797.9645,1240.649;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;37;-853.5636,1414.041;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;40;-596.7829,1247.899;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;39;-447.5636,1338.041;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2214.237,734.2964;Inherit;False;1027.52;428.2493;Fog distance;7;7;8;9;10;19;20;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-299.5636,1480.041;Inherit;False;Property;_SunFogrange;Sun Fog range;7;0;Create;True;0;0;0;False;0;False;10;43.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;41;-311.5636,1339.041;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2219.54,1194.903;Inherit;False;1027.52;428.2493;Fog height;5;31;30;28;27;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;7;-2111.128,784.2964;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;42;-96.5636,1342.041;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;8;-2164.238,979.5451;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;10;-1851.611,816.6027;Inherit;False;Property;_FogDistanceEnd;Fog Distance End;2;0;Create;True;0;0;0;False;0;False;700;439.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1859.789,1028.169;Inherit;False;Property;_FogDistanceStart;Fog Distance Start;1;0;Create;True;0;0;0;False;0;False;200;77.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;22.4364,1490.041;Inherit;False;Property;_SunFogintensity;Sun Fog intensity;6;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;44;66.4364,1344.041;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;26;-2062.43,1335.903;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;28;-1865.088,1488.776;Inherit;False;Property;_FogHeightStart;Fog Height Start;3;0;Create;True;0;0;0;False;0;False;200;187.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1872.91,1277.21;Inherit;False;Property;_FogHeightEnd;Fog Height End;4;0;Create;True;0;0;0;False;0;False;700;-82.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-1855.037,908.1022;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;19;-1651.888,874.6022;Inherit;False;FogLiner;-1;;5;d1d983e3ea7ac6e44a7faa9d7c332820;0;3;11;FLOAT;700;False;12;FLOAT;0;False;13;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;230.4364,1345.041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;30;-1657.186,1335.209;Inherit;False;FogLiner;-1;;4;d1d983e3ea7ac6e44a7faa9d7c332820;0;3;11;FLOAT;700;False;12;FLOAT;0;False;13;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;6;-1976.774,281.8343;Inherit;False;791.7098;382.542;IBL_spec;4;1;2;4;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1410.718,871.1392;Inherit;False;FogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;376.245,1340.04;Inherit;False;SunFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1416.017,1331.746;Inherit;False;FogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-948.7607,480.3303;Inherit;False;Property;_FogColor;Fog Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.4156863,0.4235294,0.8745099,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;32;-915.4636,1032.972;Inherit;False;31;FogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;-938.5447,665.852;Inherit;False;Property;_SunFogColor;Sun Fog Color;5;0;Create;True;0;0;0;False;0;False;1,0.5806912,0.25,0;1,0.6745098,0.6117647,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;21;-924.2117,940.9535;Inherit;False;20;FogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1926.774,349.9355;Inherit;False;Property;_SmoothNess;SmoothNess;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-911.433,850.2681;Inherit;False;47;SunFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;-653.8616,586.7083;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectSpecularLight;1;-1638.559,331.8345;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;2;-1630.222,452.3769;Inherit;False;Property;_BaseColor;BaseColor;8;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5,0;0.6886792,0.6886792,0.6886792,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-651.701,956.1557;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-672.5022,797.6237;Inherit;False;Property;_FogIntensity;Fog Intensity;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1347.064,376.7471;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-463.5022,634.6237;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-459.5022,890.6237;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-236.2981,545.9545;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;49,5;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;k31_fog_moutain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;0;36;0
WireConnection;39;0;40;0
WireConnection;39;1;37;0
WireConnection;41;0;39;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;44;0;42;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;19;11;10;0
WireConnection;19;12;11;0
WireConnection;19;13;9;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;30;11;27;0
WireConnection;30;12;28;0
WireConnection;30;13;26;2
WireConnection;20;0;19;0
WireConnection;47;0;45;0
WireConnection;31;0;30;0
WireConnection;51;0;18;0
WireConnection;51;1;50;0
WireConnection;51;2;48;0
WireConnection;1;1;5;0
WireConnection;35;0;21;0
WireConnection;35;1;32;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;52;0;51;0
WireConnection;52;1;53;0
WireConnection;54;0;53;0
WireConnection;54;1;35;0
WireConnection;17;0;4;0
WireConnection;17;1;52;0
WireConnection;17;2;54;0
WireConnection;0;13;17;0
ASEEND*/
//CHKSM=22DB3892E88A5E06BE29A099F8051FE5A317B513