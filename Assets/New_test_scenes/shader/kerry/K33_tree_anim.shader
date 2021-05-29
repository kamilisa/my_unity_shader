// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k33_tree_anim"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BaseMap_leaf("BaseMap_leaf", 2D) = "white" {}
		_NormalMap_leaf("NormalMap_leaf", 2D) = "bump" {}
		_BaseMap_branch("BaseMap_branch", 2D) = "white" {}
		_NormalMap_branch("NormalMap_branch", 2D) = "bump" {}
		_Roughness("Roughness", Range( 0 , 1)) = 1
		_SSSintensity("SSSintensity", Float) = 1
		_SSSColor("SSSColor", Color) = (0.1970897,0.9716981,0.5767594,0)
		_SSSdistort("SSSdistort", Float) = 1
		_GlobalWindSpeed("GlobalWindSpeed", Float) = 0
		_WindDirection("WindDirection", Vector) = (0,1,0,0)
		_Windintensity("Windintensity", Float) = 1
		_smallWindSpeed("smallWindSpeed", Float) = 1
		_smallWindDir("smallWindDir", Vector) = (0,0,0,0)
		_smallIntensity("smallIntensity", Float) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "DisableBatching" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
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
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
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

		uniform float _GlobalWindSpeed;
		uniform float _Windintensity;
		uniform float3 _WindDirection;
		uniform float3 _smallWindDir;
		uniform float _smallWindSpeed;
		uniform float _smallIntensity;
		uniform sampler2D _BaseMap_leaf;
		uniform float4 _BaseMap_leaf_ST;
		uniform sampler2D _BaseMap_branch;
		uniform float4 _BaseMap_branch_ST;
		uniform sampler2D _NormalMap_leaf;
		uniform float4 _NormalMap_leaf_ST;
		uniform sampler2D _NormalMap_branch;
		uniform float4 _NormalMap_branch_ST;
		uniform float _SSSdistort;
		uniform float4 _SSSColor;
		uniform float _SSSintensity;
		uniform float _Roughness;
		uniform float _Cutoff = 0.5;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_55_0 = ( ( _GlobalWindSpeed * _Time.y ) * UNITY_PI );
			float temp_output_61_0 = ( _Windintensity * 0.01 );
			float3 temp_output_7_0_g1 = _smallWindDir;
			float3 RotateAxis34_g1 = cross( temp_output_7_0_g1 , float3(0,1,0) );
			float3 wind_direction31_g1 = temp_output_7_0_g1;
			float3 wind_speed40_g1 = ( ( _Time.y * _smallWindSpeed ) * float3(0.5,-0.5,-0.5) );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_148_0_g1 = 1.0;
			float3 temp_cast_0 = (1.0).xxx;
			float3 temp_output_22_0_g1 = abs( ( ( frac( ( ( ( wind_direction31_g1 * wind_speed40_g1 ) + ( ase_worldPos / ( 10.0 * temp_output_148_0_g1 ) ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
			float3 temp_cast_1 = (3.0).xxx;
			float dotResult30_g1 = dot( ( ( temp_output_22_0_g1 * temp_output_22_0_g1 ) * ( temp_cast_1 - ( temp_output_22_0_g1 * 2.0 ) ) ) , wind_direction31_g1 );
			float BigTriangleWave42_g1 = dotResult30_g1;
			float3 temp_cast_2 = (1.0).xxx;
			float3 temp_output_59_0_g1 = abs( ( ( frac( ( ( wind_speed40_g1 + ( ase_worldPos / ( 2.0 * temp_output_148_0_g1 ) ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
			float3 temp_cast_3 = (3.0).xxx;
			float SmallTriangleWave52_g1 = distance( ( ( temp_output_59_0_g1 * temp_output_59_0_g1 ) * ( temp_cast_3 - ( temp_output_59_0_g1 * 2.0 ) ) ) , float3(0,0,0) );
			float3 rotatedValue72_g1 = RotateAroundAxis( ( ase_worldPos - float3(0,0.1,0) ), ase_worldPos, normalize( RotateAxis34_g1 ), ( ( BigTriangleWave42_g1 + SmallTriangleWave52_g1 ) * ( 2.0 * UNITY_PI ) ) );
			float3 worldToObj81_g1 = mul( unity_WorldToObject, float4( rotatedValue72_g1, 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 WindVertexLayer59 = ( ( ( sin( temp_output_55_0 ) * temp_output_61_0 ) * _WindDirection * v.color.r ) + ( _WindDirection * ( cos( temp_output_55_0 ) * temp_output_61_0 ) * v.color.g ) + ( v.color.g * ( worldToObj81_g1 - ase_vertex3Pos ) * _smallIntensity ) );
			v.vertex.xyz += WindVertexLayer59;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_BaseMap_leaf = i.uv_texcoord * _BaseMap_leaf_ST.xy + _BaseMap_leaf_ST.zw;
			float4 tex2DNode2 = tex2D( _BaseMap_leaf, uv_BaseMap_leaf );
			float lerpResult15 = lerp( tex2DNode2.a , 1.0 , i.vertexColor.a);
			float AlphaLerp16 = lerpResult15;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseMap_branch = i.uv_texcoord * _BaseMap_branch_ST.xy + _BaseMap_branch_ST.zw;
			float4 lerpResult8 = lerp( tex2DNode2 , tex2D( _BaseMap_branch, uv_BaseMap_branch ) , i.vertexColor.a);
			float4 BaseColorLayer35 = lerpResult8;
			s1.Albedo = BaseColorLayer35.rgb;
			float2 uv_NormalMap_leaf = i.uv_texcoord * _NormalMap_leaf_ST.xy + _NormalMap_leaf_ST.zw;
			float3 tex2DNode3 = UnpackNormal( tex2D( _NormalMap_leaf, uv_NormalMap_leaf ) );
			float3 appendResult19 = (float3(tex2DNode3.r , tex2DNode3.g , -tex2DNode3.b));
			float3 switchResult18 = (((i.ASEVFace>0)?(tex2DNode3):(appendResult19)));
			float2 uv_NormalMap_branch = i.uv_texcoord * _NormalMap_branch_ST.xy + _NormalMap_branch_ST.zw;
			float3 lerpResult11 = lerp( switchResult18 , UnpackNormal( tex2D( _NormalMap_branch, uv_NormalMap_branch ) ) , i.vertexColor.a);
			float3 normalLayer40 = lerpResult11;
			s1.Normal = WorldNormalVector( i , normalLayer40 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult22 = normalize( ( ase_worldlightDir + ( (WorldNormalVector( i , normalLayer40 )) * _SSSdistort ) ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult24 = dot( -normalizeResult22 , ase_worldViewDir );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 SSScolor39 = ( ( max( ( dotResult24 * ( 1.0 - i.vertexColor.a ) * i.vertexColor.b ) , 0.0 ) * _SSSColor * _SSSintensity * BaseColorLayer35 * float4( ase_lightColor.rgb , 0.0 ) ) * (ase_lightAtten*0.5 + 0.5) );
			s1.Emission = SSScolor39.rgb;
			s1.Metallic = 0.0;
			s1.Smoothness = _Roughness;
			s1.Occlusion = 1.0;

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
			clip( AlphaLerp16 - _Cutoff );
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
0;313;1920;534;2791.256;386.2491;1.429834;True;True
Node;AmplifyShaderEditor.CommentaryNode;13;-2112.748,412.7617;Inherit;False;1298.822;728.817;normalregion;8;11;18;19;20;12;10;3;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;3;-2097.748,461.7619;Inherit;True;Property;_NormalMap_leaf;NormalMap_leaf;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;20;-1805.857,612.6786;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-1678.857,546.6786;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwitchByFaceNode;18;-1545.857,470.6783;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;12;-1949.927,867.5795;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-2097.926,669.5795;Inherit;True;Property;_NormalMap_branch;NormalMap_branch;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;11;-1367.205,660.0917;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1139.77,668.9862;Inherit;False;normalLayer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2764.921,1164.332;Inherit;False;2335.219;762.1558;viewSSSregion;23;39;36;37;29;28;27;26;48;24;50;25;23;49;22;46;21;44;43;45;42;72;73;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-2743.996,1410.788;Inherit;False;40;normalLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;43;-2561.996,1414.788;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;45;-2525.996,1570.788;Inherit;False;Property;_SSSdistort;SSSdistort;8;0;Create;True;0;0;0;False;0;False;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;21;-2669.683,1245.22;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2369.337,1412.748;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-2265.882,1295.416;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;60;-2141.28,1966.775;Inherit;False;1725.109;1044.345;vertexAnimWind;23;68;61;62;63;66;57;69;70;59;71;64;58;54;55;56;52;51;53;75;76;79;80;81;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;22;-2132.921,1293.957;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;9;-2108.934,-302.7592;Inherit;False;1100.23;693.1984;basemapRegion;7;8;16;15;7;2;6;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;25;-2028.498,1369.332;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;49;-2191.793,1578.523;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;51;-2091.28,2016.775;Inherit;False;Property;_GlobalWindSpeed;GlobalWindSpeed;9;0;Create;True;0;0;0;False;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;53;-2063.28,2099.774;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-2058.935,-48.37604;Inherit;True;Property;_BaseMap_branch;BaseMap_branch;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;6;-1975.59,153.1968;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;23;-1951.56,1238.693;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-2058.823,-252.7591;Inherit;True;Property;_BaseMap_leaf;BaseMap_leaf;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1828.28,2047.775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;56;-1876.28,2170.774;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;-1604.935,-125.376;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;50;-1969.022,1672.823;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;24;-1808.334,1251.191;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2017.621,2498.954;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1646.498,1383.653;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1695.28,2101.774;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1385.965,-117.4203;Inherit;False;BaseColorLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2038.274,2387.808;Inherit;False;Property;_Windintensity;Windintensity;11;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1764.227,2652.352;Inherit;False;Property;_smallWindSpeed;smallWindSpeed;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1405.498,1512.332;Inherit;False;Property;_SSSintensity;SSSintensity;6;0;Create;True;0;0;0;False;0;False;1;10.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1438.493,1612.67;Inherit;False;35;BaseColorLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;26;-1505.182,1234.931;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;54;-1541.28,2097.774;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;-1442.498,1334.332;Inherit;False;Property;_SSSColor;SSSColor;7;0;Create;True;0;0;0;False;0;False;0.1970897,0.9716981,0.5767594,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;37;-1393.186,1728.763;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1800.074,2430.207;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;69;-1577.954,2317.563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;73;-1172.7,1493.329;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;79;-1740.597,2739.56;Inherit;False;Property;_smallWindDir;smallWindDir;13;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;58;-1418.855,2200.803;Inherit;False;Property;_WindDirection;WindDirection;10;0;Create;True;0;0;0;False;0;False;0,1,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;74;-923.8457,1493.329;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1174.498,1231.332;Inherit;False;5;5;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1371.923,2086.659;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-1407.029,2352.223;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-1377.469,2533.24;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1393.472,2885.101;Inherit;False;Property;_smallIntensity;smallIntensity;14;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;-1518.188,2661.966;Inherit;True;SimpleGrassWind;-1;;1;eb6b5a71d4f47f64ab6869a5d5d0a9be;0;5;148;FLOAT;1;False;85;FLOAT;0;False;86;FLOAT;1;False;1;FLOAT;1;False;7;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1174.138,2627.705;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-851.2184,1281.858;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1151.28,2076.374;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1156.641,2330.127;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;15;-1640.334,134.144;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-663.9456,1234.17;Inherit;False;SSScolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-908.0053,2301.478;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-446.7291,434.8038;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-582.5094,534.8374;Inherit;False;Property;_Roughness;Roughness;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-481.0693,267.991;Inherit;False;40;normalLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-494.5096,182.5237;Inherit;False;35;BaseColorLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-474.218,353.1101;Inherit;False;39;SSScolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1458.925,134.3283;Inherit;False;AlphaLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-657.9233,2180.503;Inherit;False;WindVertexLayer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;-231.4944,290.0285;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;77.57788,361.4383;Inherit;False;59;WindVertexLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;112.1166,248.0208;Inherit;False;16;AlphaLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;384,48;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;k33_tree_anim;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;3;3
WireConnection;19;0;3;1
WireConnection;19;1;3;2
WireConnection;19;2;20;0
WireConnection;18;0;3;0
WireConnection;18;1;19;0
WireConnection;11;0;18;0
WireConnection;11;1;10;0
WireConnection;11;2;12;4
WireConnection;40;0;11;0
WireConnection;43;0;42;0
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;46;0;21;0
WireConnection;46;1;44;0
WireConnection;22;0;46;0
WireConnection;23;0;22;0
WireConnection;52;0;51;0
WireConnection;52;1;53;0
WireConnection;8;0;2;0
WireConnection;8;1;7;0
WireConnection;8;2;6;4
WireConnection;50;0;49;4
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;48;0;24;0
WireConnection;48;1;50;0
WireConnection;48;2;49;3
WireConnection;55;0;52;0
WireConnection;55;1;56;0
WireConnection;35;0;8;0
WireConnection;26;0;48;0
WireConnection;54;0;55;0
WireConnection;61;0;62;0
WireConnection;61;1;63;0
WireConnection;69;0;55;0
WireConnection;74;0;73;0
WireConnection;27;0;26;0
WireConnection;27;1;28;0
WireConnection;27;2;29;0
WireConnection;27;3;36;0
WireConnection;27;4;37;1
WireConnection;64;0;54;0
WireConnection;64;1;61;0
WireConnection;68;0;69;0
WireConnection;68;1;61;0
WireConnection;75;1;76;0
WireConnection;75;7;79;0
WireConnection;80;0;66;2
WireConnection;80;1;75;0
WireConnection;80;2;81;0
WireConnection;72;0;27;0
WireConnection;72;1;74;0
WireConnection;57;0;64;0
WireConnection;57;1;58;0
WireConnection;57;2;66;1
WireConnection;70;0;58;0
WireConnection;70;1;68;0
WireConnection;70;2;66;2
WireConnection;15;0;2;4
WireConnection;15;2;6;4
WireConnection;39;0;72;0
WireConnection;71;0;57;0
WireConnection;71;1;70;0
WireConnection;71;2;80;0
WireConnection;16;0;15;0
WireConnection;59;0;71;0
WireConnection;1;0;31;0
WireConnection;1;1;41;0
WireConnection;1;2;47;0
WireConnection;1;3;5;0
WireConnection;1;4;14;0
WireConnection;0;10;17;0
WireConnection;0;13;1;0
WireConnection;0;11;67;0
ASEEND*/
//CHKSM=D57C1F7ACDFA77756CCDFD39AC7BAC6838002659