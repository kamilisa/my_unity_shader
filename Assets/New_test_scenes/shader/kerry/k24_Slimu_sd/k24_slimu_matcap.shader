// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k24_slimu_matcap"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_matcap("matcap", 2D) = "white" {}
		_baseMap("baseMap", 2D) = "white" {}
		_EmissiveMap("EmissiveMap", 2D) = "black" {}
		_norMal_Map("norMal_Map", 2D) = "bump" {}
		_fresnel_Color("fresnel_Color", Color) = (1,1,1,0)
		_fresnel_bias("fresnel_bias", Float) = 0
		_fresnel_scale("fresnel_scale", Float) = 1
		_fresnel_power("fresnel_power", Float) = 2.21
		_ProJect_Map("ProJect_Map", 2D) = "white" {}
		_Proj_ABS_pow("Proj_ABS_pow", Float) = 0
		_noise_tilling("noise_tilling", Float) = 1
		_FlowSpeed("FlowSpeed", Vector) = (0,0,0,0)
		_VertexAnimNoiseMap("VertexAnimNoiseMap", 2D) = "white" {}
		_directionTest("directionTest", Vector) = (0,-0.2,0,0)
		_anim_noise_tilling("anim_noise_tilling", Float) = 1
		_anim_FlowSpeed("anim_FlowSpeed", Vector) = (0,0,0,0)
		_vertexAnimReduce("vertexAnimReduce", Float) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _VertexAnimNoiseMap;
		uniform float _anim_noise_tilling;
		uniform float2 _anim_FlowSpeed;
		uniform float _vertexAnimReduce;
		uniform float3 _directionTest;
		uniform sampler2D _baseMap;
		uniform float4 _baseMap_ST;
		uniform sampler2D _matcap;
		uniform sampler2D _norMal_Map;
		uniform float4 _norMal_Map_ST;
		uniform float _Proj_ABS_pow;
		uniform sampler2D _ProJect_Map;
		uniform float _noise_tilling;
		uniform float2 _FlowSpeed;
		uniform sampler2D _EmissiveMap;
		uniform float4 _EmissiveMap_ST;
		uniform float _fresnel_bias;
		uniform float _fresnel_scale;
		uniform float _fresnel_power;
		uniform float4 _fresnel_Color;
		uniform float _EdgeLength;


		inline float4 TriplanarSampling108( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float4 ASESafeNormalize(float4 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 objToWorld100 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float4 triplanar108 = TriplanarSampling108( _VertexAnimNoiseMap, ( ( ( ase_worldPos - objToWorld100 ) * _anim_noise_tilling ) + float3( ( _Time.y * _anim_FlowSpeed ) ,  0.0 ) ), ase_worldNormal, 1.0, float2( 1,1 ), 1.0, 0 );
			float dotResult119 = dot( ase_worldNormal , _directionTest );
			float clampResult120 = clamp( dotResult119 , 0.0 , 1.0 );
			float4 animThreePlane110 = ( ( triplanar108 * float4( ase_worldNormal , 0.0 ) ) * _vertexAnimReduce * v.color.r * ( clampResult120 + 1.0 ) );
			v.vertex.xyz += animThreePlane110.xyz;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_baseMap = i.uv_texcoord * _baseMap_ST.xy + _baseMap_ST.zw;
			float2 uv_norMal_Map = i.uv_texcoord * _norMal_Map_ST.xy + _norMal_Map_ST.zw;
			float3 normalMap95 = UnpackNormal( tex2D( _norMal_Map, uv_norMal_Map ) );
			float3 newWorldNormal48 = (WorldNormalVector( i , normalMap95 ));
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_cast_0 = (_Proj_ABS_pow).xxx;
			float3 temp_output_77_0 = pow( abs( ase_worldNormal ) , temp_cast_0 );
			float3 break88 = temp_output_77_0;
			float3 break84 = ( temp_output_77_0 * ( break88.x + break88.y + break88.z ) );
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld32 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_43_0 = ( ( ( ase_worldPos - objToWorld32 ) * _noise_tilling ) + float3( ( _Time.y * _FlowSpeed ) ,  0.0 ) );
			float4 threePlaneProject60 = ( ( break84.z * tex2D( _ProJect_Map, (temp_output_43_0).xy ) ) + ( break84.x * tex2D( _ProJect_Map, (temp_output_43_0).yz ) ) + ( break84.y * tex2D( _ProJect_Map, (temp_output_43_0).xz ) ) );
			float4 break92 = threePlaneProject60;
			float4 appendResult57 = (float4(( newWorldNormal48.x + break92.r ) , ( newWorldNormal48.y + break92.g ) , newWorldNormal48.z , 0.0));
			float4 normalizeResult94 = ASESafeNormalize( appendResult57 );
			float4 noise_layer58 = normalizeResult94;
			float4 matcap_layer15 = tex2D( _matcap, ((mul( UNITY_MATRIX_V, noise_layer58 )).xy*0.5 + 0.5) );
			float2 uv_EmissiveMap = i.uv_texcoord * _EmissiveMap_ST.xy + _EmissiveMap_ST.zw;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV17 = dot( normalize( (WorldNormalVector( i , normalMap95 )) ), ase_worldViewDir );
			float fresnelNode17 = ( _fresnel_bias + _fresnel_scale * pow( 1.0 - fresnelNdotV17, _fresnel_power ) );
			float4 rimColor_Layer28 = ( tex2D( _EmissiveMap, uv_EmissiveMap ) * ( fresnelNode17 * _fresnel_Color ) );
			o.Emission = ( ( tex2D( _baseMap, uv_baseMap ) * matcap_layer15 ) + rimColor_Layer28 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				vertexDataFunc( v );
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
0;100;1920;843;3115.332;-493.4462;1.305321;True;True
Node;AmplifyShaderEditor.CommentaryNode;93;-3235.37,-2084.307;Inherit;False;2342.179;1017.858;threePlaneProj_layer;22;32;31;38;39;41;33;61;42;43;82;67;34;65;86;85;69;87;60;63;66;68;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;82;-2951.398,-2034.307;Inherit;False;1196.58;307.5161;world_normal_abs;8;84;90;80;89;88;77;71;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;70;-2931.203,-1976.135;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;32;-3185.37,-1462.085;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;31;-3156.251,-1620;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;71;-2738.391,-1975.95;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2921.867,-1832.373;Inherit;False;Property;_Proj_ABS_pow;Proj_ABS_pow;14;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;77;-2605.634,-1976.647;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2746.201,-1446.052;Inherit;False;Property;_noise_tilling;noise_tilling;15;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-2935.618,-1579.681;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;39;-2896.985,-1369.173;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;41;-2888.152,-1296.222;Inherit;False;Property;_FlowSpeed;FlowSpeed;16;0;Create;True;0;0;0;False;0;False;0,0;0.4,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-2720.799,-1368.635;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;88;-2448.738,-1861.942;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2582.571,-1580.401;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-2323.311,-1861.942;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2421.127,-1421.667;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;34;-2223.76,-1490.235;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-2169.324,-1979.917;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;67;-2225.809,-1293.043;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;65;-2226.215,-1390.366;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;64;-2303.788,-1691.837;Inherit;True;Property;_ProJect_Map;ProJect_Map;13;0;Create;True;0;0;0;False;0;False;None;58ad53cdc4389c04895c75f17349ca41;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.BreakToComponentsNode;84;-1969.884,-1979.076;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;68;-2012.427,-1296.449;Inherit;True;Property;_TextureSample2;Texture Sample 2;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;63;-2013.172,-1693.232;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;36b9e5bdc59a3ed4081e4853098f04ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;66;-2014.706,-1495.429;Inherit;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1614.774,-1516.366;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;97;-3561.172,-39.27355;Inherit;False;611.2595;280.1687;normalMap;2;26;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1618.43,-1310.671;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1613.153,-1713.509;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-1392.034,-1543.092;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;26;-3511.172,10.89519;Inherit;True;Property;_norMal_Map;norMal_Map;8;0;Create;True;0;0;0;False;0;False;-1;None;dbe58c3e443952347aaef9a939e2c3a6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-3173.913,10.72645;Inherit;False;normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;44;-2148.307,-1025.285;Inherit;False;1298.986;426.5757;noise_layer;9;58;94;57;54;55;92;48;91;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1134.191,-1547.846;Inherit;False;threePlaneProject;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-2122.289,-955.3926;Inherit;False;60;threePlaneProject;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-2130.357,-797.9812;Inherit;False;95;normalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;92;-1874.652,-950.8059;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WorldNormalVector;48;-1933.449,-794.5027;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1594.984,-869.213;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-1594.342,-973.0435;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;-1378.175,-911.7521;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;94;-1229.272,-911.9425;Inherit;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;116;-2947.882,578.4254;Inherit;False;2103.281;770.7017;vertex_anim_layer;22;110;114;113;117;115;112;108;109;107;105;106;103;102;101;104;100;99;118;119;120;121;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;-2248.56,-547.0977;Inherit;False;1362.629;279.2476;matCap;7;59;15;8;7;6;5;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-1060.854,-916.9872;Inherit;False;noise_layer;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;27;-2665.806,-212.1335;Inherit;False;1786.065;701.4901;Rim_Color_layer;12;25;24;13;17;23;20;21;19;22;18;28;96;;1,0.7122642,0.8676633,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;100;-2897.882,796.7758;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;99;-2868.763,638.8605;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;3;-2152.089,-455.0975;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-2211.936,-373.8664;Inherit;False;58;noise_layer;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;102;-2772.579,1018.126;Inherit;False;Property;_anim_FlowSpeed;anim_FlowSpeed;20;0;Create;True;0;0;0;False;0;False;0,0;0.4,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-2650.13,638.1795;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2635.713,858.8087;Inherit;False;Property;_anim_noise_tilling;anim_noise_tilling;19;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2008.089,-454.0974;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-2539.935,38.31174;Inherit;False;95;normalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;104;-2752.497,940.6876;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;112;-1896.476,973.1601;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;21;-2091.752,210.8395;Inherit;False;Property;_fresnel_scale;fresnel_scale;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2081.752,131.8394;Inherit;False;Property;_fresnel_bias;fresnel_bias;10;0;Create;True;0;0;0;False;0;False;0;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;18;-2283.61,42.45986;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;118;-1880.425,1128.611;Inherit;False;Property;_directionTest;directionTest;18;0;Create;True;0;0;0;False;0;False;0,-0.2,0;0,-8.16,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;6;-1864.089,-459.0975;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-2576.311,941.2256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2097.752,290.8394;Inherit;False;Property;_fresnel_power;fresnel_power;12;0;Create;True;0;0;0;False;0;False;2.21;0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-2402.083,638.4595;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;19;-2255.036,192.2769;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;109;-2209.516,628.4254;Inherit;True;Property;_VertexAnimNoiseMap;VertexAnimNoiseMap;17;0;Create;True;0;0;0;False;0;False;None;61d984baa07a0ff4ead6a9e7752a64fc;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ScaleAndOffsetNode;7;-1706.953,-456.2319;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-2207.508,832.7398;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;23;-1766.42,271.9619;Inherit;False;Property;_fresnel_Color;fresnel_Color;9;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;17;-1852.929,45.59994;Inherit;True;Standard;WorldNormal;ViewDir;True;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;119;-1680.829,1092.51;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;120;-1539.413,1094.533;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1483.695,-486.2234;Inherit;True;Property;_matcap;matcap;5;0;Create;True;0;0;0;False;0;False;-1;None;3ee849bb81f113d4fa5cc2cd74838794;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-1534.482,1223.87;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;108;-1954.067,731.1173;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-1667.482,-162.1335;Inherit;True;Property;_EmissiveMap;EmissiveMap;7;0;Create;True;0;0;0;False;0;False;-1;None;90dfcd91b02f60c44881dd4aa6750bb8;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1510.42,101.9621;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1314.16,-9.455006;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1098.909,-484.2217;Inherit;False;matcap_layer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;117;-1534.25,923.7075;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-1531.752,731.811;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-1379.704,1094.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1533.828,840.1615;Inherit;False;Property;_vertexAnimReduce;vertexAnimReduce;21;0;Create;True;0;0;0;False;0;False;0.1;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-209.6049,-124.0906;Inherit;False;15;matcap_layer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-313.535,-346.5174;Inherit;True;Property;_baseMap;baseMap;6;0;Create;True;0;0;0;False;0;False;-1;None;3ab1d390925f9f646807b86d3ed94db5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1227.227,796.5839;Inherit;False;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1121.671,-16.56258;Inherit;False;rimColor_Layer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-31.51318,-44.41196;Inherit;False;28;rimColor_Layer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;34.3833,-177.2598;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-1074.544,790.6736;Inherit;False;animThreePlane;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;186.0829,155.3188;Inherit;False;110;animThreePlane;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;225.8701,-174.9357;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;522.3525,-225.2615;Float;False;True;-1;6;ASEMaterialInspector;0;0;Unlit;k24_slimu_matcap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;71;0;70;0
WireConnection;77;0;71;0
WireConnection;77;1;80;0
WireConnection;33;0;31;0
WireConnection;33;1;32;0
WireConnection;42;0;39;0
WireConnection;42;1;41;0
WireConnection;88;0;77;0
WireConnection;61;0;33;0
WireConnection;61;1;38;0
WireConnection;89;0;88;0
WireConnection;89;1;88;1
WireConnection;89;2;88;2
WireConnection;43;0;61;0
WireConnection;43;1;42;0
WireConnection;34;0;43;0
WireConnection;90;0;77;0
WireConnection;90;1;89;0
WireConnection;67;0;43;0
WireConnection;65;0;43;0
WireConnection;84;0;90;0
WireConnection;68;0;64;0
WireConnection;68;1;67;0
WireConnection;63;0;64;0
WireConnection;63;1;34;0
WireConnection;66;0;64;0
WireConnection;66;1;65;0
WireConnection;85;0;84;0
WireConnection;85;1;66;0
WireConnection;86;0;84;1
WireConnection;86;1;68;0
WireConnection;69;0;84;2
WireConnection;69;1;63;0
WireConnection;87;0;69;0
WireConnection;87;1;85;0
WireConnection;87;2;86;0
WireConnection;95;0;26;0
WireConnection;60;0;87;0
WireConnection;92;0;91;0
WireConnection;48;0;98;0
WireConnection;55;0;48;2
WireConnection;55;1;92;1
WireConnection;54;0;48;1
WireConnection;54;1;92;0
WireConnection;57;0;54;0
WireConnection;57;1;55;0
WireConnection;57;2;48;3
WireConnection;94;0;57;0
WireConnection;58;0;94;0
WireConnection;101;0;99;0
WireConnection;101;1;100;0
WireConnection;5;0;3;0
WireConnection;5;1;59;0
WireConnection;18;0;96;0
WireConnection;6;0;5;0
WireConnection;106;0;104;0
WireConnection;106;1;102;0
WireConnection;105;0;101;0
WireConnection;105;1;103;0
WireConnection;7;0;6;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;17;0;18;0
WireConnection;17;4;19;0
WireConnection;17;1;20;0
WireConnection;17;2;21;0
WireConnection;17;3;22;0
WireConnection;119;0;112;0
WireConnection;119;1;118;0
WireConnection;120;0;119;0
WireConnection;8;1;7;0
WireConnection;108;0;109;0
WireConnection;108;9;107;0
WireConnection;24;0;17;0
WireConnection;24;1;23;0
WireConnection;25;0;13;0
WireConnection;25;1;24;0
WireConnection;15;0;8;0
WireConnection;113;0;108;0
WireConnection;113;1;112;0
WireConnection;121;0;120;0
WireConnection;121;1;122;0
WireConnection;114;0;113;0
WireConnection;114;1;115;0
WireConnection;114;2;117;1
WireConnection;114;3;121;0
WireConnection;28;0;25;0
WireConnection;10;0;9;0
WireConnection;10;1;16;0
WireConnection;110;0;114;0
WireConnection;12;0;10;0
WireConnection;12;1;29;0
WireConnection;2;2;12;0
WireConnection;2;11;111;0
ASEEND*/
//CHKSM=857466D2CB6AC80F5004CFC9800547A5BE9B6EFA