// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k22_Ase_FlowStar"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 1
		_RimOffset("RimOffset", Float) = 0
		_RimColor("RimColor", Color) = (1,0.7469491,0,0)
		_FlowMap("FlowMap", 2D) = "white" {}
		_FlowTillingOffset("FlowTillingOffset", Vector) = (1,1,0,0)
		_FlowLightColor("FlowLightColor", Color) = (1,0.8578519,0.4764151,0)
		_FlowLightScale("FlowLightScale", Float) = 1
		_NebulaMap("NebulaMap", 2D) = "white" {}
		_NebulaDistort("NebulaDistort", Float) = 0.1
		_StarLight("StarLight", Float) = 5
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _RimColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimPower;
		uniform float _RimScale;
		uniform float _RimOffset;
		uniform float4 _FlowLightColor;
		uniform float _FlowLightScale;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowTillingOffset;
		uniform sampler2D _NebulaMap;
		uniform float _NebulaDistort;
		uniform float _StarLight;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 Normal_World5 = normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult3 = dot( Normal_World5 , ase_worldViewDir );
			float NdotV7 = dotResult3;
			float clampResult11 = clamp( NdotV7 , 0.0 , 1.0 );
			float4 FresnelLayer53 = ( _RimColor * ( ( pow( ( 1.0 - clampResult11 ) , _RimPower ) * _RimScale ) + _RimOffset ) );
			float3 objToWorld25 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 panner27 = ( 1.0 * _Time.y * (_FlowTillingOffset).zw + ( ( (NdotV7*0.5 + 0.5) + (( ase_worldPos - objToWorld25 )).xy ) * (_FlowTillingOffset).xy ));
			float4 FlowEffect33 = tex2D( _FlowMap, panner27 );
			float4 FlowLightLayer42 = ( _FlowLightColor * ( ( ( 1.0 - NdotV7 ) * _FlowLightScale ) * FlowEffect33 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView60 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView64 = mul( UNITY_MATRIX_MV, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 objToViewDir71 = normalize( mul( UNITY_MATRIX_IT_MV, float4( Normal_World5, 0 ) ).xyz );
			float4 StarLayer61 = tex2D( _NebulaMap, ( ( (( objToView60 - objToView64 )).xy + ( (objToViewDir71).xy * _NebulaDistort ) ) * float2( 1,1 ) ) );
			o.Emission = ( FresnelLayer53 + FlowLightLayer42 + ( StarLayer61 * FlowEffect33 ) + ( pow( StarLayer61 , 5.0 ) * pow( FlowEffect33 , 5.0 ) * _StarLight ) ).rgb;
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
337;509;1920;899;1321.465;-4.245163;1.772714;True;True
Node;AmplifyShaderEditor.CommentaryNode;8;-1711.311,-787.8073;Inherit;False;816.0126;280.4045;world_normal;3;4;2;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;4;-1661.311,-737.4027;Inherit;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;2;-1326.579,-731.583;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-1119.298,-737.8073;Inherit;False;Normal_World;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;9;-1628.511,-443.6674;Inherit;False;740.5832;324.5605;NdotV;4;6;1;3;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;6;-1578.511,-393.6676;Inherit;False;5;Normal_World;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-1551.896,-307.1071;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;3;-1334.896,-386.1071;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;34;-1630.977,463.8222;Inherit;False;1605.729;821.5801;FlowEffect;14;33;32;27;31;30;29;26;28;23;25;22;36;37;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;25;-1533.433,913.4424;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;22;-1503.887,760.0333;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1111.927,-391.2693;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-1258.433,815.4424;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1300.315,632.2051;Inherit;False;7;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;-1851.042,1885.426;Inherit;False;1780.74;581.3264;NebulaLayer;15;56;70;71;60;64;72;63;73;65;74;67;75;68;69;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1706.907,2262.752;Inherit;False;5;Normal_World;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;56;-1801.042,1939.004;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;26;-1096.443,857.0463;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;28;-1283.442,1036.046;Inherit;False;Property;_FlowTillingOffset;FlowTillingOffset;6;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-1110.092,635.4648;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1636.121,-68.01455;Inherit;False;1485.012;461.7137;RimColor;12;17;19;11;13;10;16;15;18;20;14;12;53;;1,0.8409144,0.5424528,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-910.0918,750.4648;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;29;-1084.443,1032.046;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;71;-1495.907,2262.752;Inherit;False;Object;View;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;60;-1541.709,1935.426;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;64;-1545.805,2101.361;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-901.4425,906.0463;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-1586.121,153.917;Inherit;False;7;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;31;-1084.538,1128.617;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1294.907,2350.752;Inherit;False;Property;_NebulaDistort;NebulaDistort;10;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-1302.805,2018.361;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;72;-1276.907,2262.752;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1117.907,2267.752;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;65;-1140.284,2062.899;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;27;-765.4424,993.0459;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;11;-1402.773,153.8795;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;51;-1615.609,1347.265;Inherit;False;1217.356;488.4159;FlowLightColor;9;43;49;46;39;48;41;40;50;42;;0.9622642,0.75801,0.75801,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1396.789,279.7839;Inherit;False;Property;_RimPower;RimPower;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;-1239.772,155.8795;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1565.609,1567.834;Inherit;False;7;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-572.248,965.8019;Inherit;True;Property;_FlowMap;FlowMap;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;67;-957.1689,2207.384;Inherit;False;Constant;_NebulaTilling;NebulaTilling;9;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-958.9064,2087.752;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-760.9699,2088.29;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;46;-1378.581,1572.392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1068.908,278.8707;Inherit;False;Property;_RimScale;RimScale;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;13;-1072.667,157.4746;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-249.2478,964.8019;Inherit;False;FlowEffect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1406.791,1648.604;Inherit;False;Property;_FlowLightScale;FlowLightScale;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-898.5609,158.5903;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1199.581,1571.392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1240.828,1719.681;Inherit;False;33;FlowEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-901.3848,280.6992;Inherit;False;Property;_RimOffset;RimOffset;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-602.7227,2061.118;Inherit;True;Property;_NebulaMap;NebulaMap;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-294.3016,2061.56;Inherit;False;StarLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-1096.122,1397.265;Inherit;False;Property;_FlowLightColor;FlowLightColor;7;0;Create;True;0;0;0;False;0;False;1,0.8578519,0.4764151,0;1,0.8578519,0.4764151,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;20;-823.7362,-18.01454;Inherit;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;0;False;0;False;1,0.7469491,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1023.303,1572.522;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-738.8135,159.2847;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-588.1099,134.2681;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-831.1877,1547.079;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;133.2531,633.5303;Inherit;False;33;FlowEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;140.5311,548.075;Inherit;False;61;StarLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;203.5987,314.5624;Inherit;False;61;StarLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;196.3206,400.0177;Inherit;False;33;FlowEffect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;84;354.5392,749.1274;Inherit;False;Property;_StarLight;StarLight;11;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;82;350.8921,647.8026;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;5;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-623.2522,1542.163;Inherit;False;FlowLightLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-414.7565,128.7708;Inherit;False;FresnelLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;81;346.8921,545.8026;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;5;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;538.5392,572.1274;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;390.3207,336.0177;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;342.7603,147.1421;Inherit;False;53;FresnelLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;330.0162,246.2972;Inherit;False;42;FlowLightLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;654.1973,207.6609;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1016.052,139.7224;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;k22_Ase_FlowStar;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;4;0
WireConnection;5;0;2;0
WireConnection;3;0;6;0
WireConnection;3;1;1;0
WireConnection;7;0;3;0
WireConnection;23;0;22;0
WireConnection;23;1;25;0
WireConnection;26;0;23;0
WireConnection;38;0;36;0
WireConnection;37;0;38;0
WireConnection;37;1;26;0
WireConnection;29;0;28;0
WireConnection;71;0;70;0
WireConnection;60;0;56;0
WireConnection;30;0;37;0
WireConnection;30;1;29;0
WireConnection;31;0;28;0
WireConnection;63;0;60;0
WireConnection;63;1;64;0
WireConnection;72;0;71;0
WireConnection;74;0;72;0
WireConnection;74;1;73;0
WireConnection;65;0;63;0
WireConnection;27;0;30;0
WireConnection;27;2;31;0
WireConnection;11;0;10;0
WireConnection;12;0;11;0
WireConnection;32;1;27;0
WireConnection;75;0;65;0
WireConnection;75;1;74;0
WireConnection;68;0;75;0
WireConnection;68;1;67;0
WireConnection;46;0;43;0
WireConnection;13;0;12;0
WireConnection;13;1;14;0
WireConnection;33;0;32;0
WireConnection;15;0;13;0
WireConnection;15;1;16;0
WireConnection;48;0;46;0
WireConnection;48;1;49;0
WireConnection;69;1;68;0
WireConnection;61;0;69;0
WireConnection;41;0;48;0
WireConnection;41;1;39;0
WireConnection;17;0;15;0
WireConnection;17;1;18;0
WireConnection;19;0;20;0
WireConnection;19;1;17;0
WireConnection;50;0;40;0
WireConnection;50;1;41;0
WireConnection;82;0;79;0
WireConnection;42;0;50;0
WireConnection;53;0;19;0
WireConnection;81;0;80;0
WireConnection;83;0;81;0
WireConnection;83;1;82;0
WireConnection;83;2;84;0
WireConnection;78;0;62;0
WireConnection;78;1;77;0
WireConnection;55;0;52;0
WireConnection;55;1;54;0
WireConnection;55;2;78;0
WireConnection;55;3;83;0
WireConnection;0;2;55;0
ASEEND*/
//CHKSM=E4AC20D95A4E093645C46FEB64563343B7332E16