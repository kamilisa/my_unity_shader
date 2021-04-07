// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "K25_sci_transfer_shader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.3
		_Dif_map("Dif_map", 2D) = "white" {}
		_Normal_map("Normal_map", 2D) = "bump" {}
		_Light_map("Light_map", 2D) = "white" {}
		_EmissMap("EmissMap", 2D) = "black" {}
		_metallic_inc("metallic_inc", Range( -1 , 1)) = 0
		_smoothness_inc("smoothness_inc", Range( -1 , 1)) = 0
		_DisolveOffset("DisolveOffset", Float) = 0
		_DisolveAmount("DisolveAmount", Float) = 0
		_DisoleSpread("DisoleSpread", Range( 0.01 , 5)) = 1
		_Noise_Scale("Noise_Scale", Vector) = (1,1,1,0)
		_DisolveEdgeOffset("DisolveEdgeOffset", Float) = 0
		[HDR]_DisolveColor("DisolveColor", Color) = (0.2745098,0.9490196,2,0)
		_vertexOffset("vertexOffset", Float) = 0
		_vertexOffsetScale("vertexOffsetScale", Float) = 1
		_RimLightRadius("RimLightRadius", Range( 0 , 1)) = 0
		[HDR]_RimLightColor("RimLightColor", Color) = (1,0.5615011,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
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
			float3 worldPos;
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

		uniform float _DisolveAmount;
		uniform float _vertexOffset;
		uniform float _vertexOffsetScale;
		uniform float _DisolveOffset;
		uniform float _DisoleSpread;
		uniform float3 _Noise_Scale;
		uniform sampler2D _Dif_map;
		uniform float4 _Dif_map_ST;
		uniform float _RimLightRadius;
		uniform sampler2D _Normal_map;
		uniform float4 _Normal_map_ST;
		uniform float _metallic_inc;
		uniform sampler2D _Light_map;
		uniform float4 _Light_map_ST;
		uniform float _smoothness_inc;
		uniform float4 _DisolveColor;
		uniform float _DisolveEdgeOffset;
		uniform sampler2D _EmissMap;
		uniform float4 _EmissMap_ST;
		uniform float4 _RimLightColor;
		uniform float _Cutoff = 0.3;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld57 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float Disolve_anim59 = _DisolveAmount;
			float simplePerlin3D76 = snoise( ( ase_worldPos * float3(60,60,60) ) );
			simplePerlin3D76 = simplePerlin3D76*0.5 + 0.5;
			float3 worldToObj70 = mul( unity_WorldToObject, float4( ( ( max( ( ( ( ase_worldPos.y - objToWorld57.y ) + Disolve_anim59 ) - _vertexOffset ) , 0.0 ) * float3(0,1,0) * _vertexOffsetScale * simplePerlin3D76 ) + ase_worldPos ), 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 vertexOffset_Layer71 = ( worldToObj70 - ase_vertex3Pos );
			v.vertex.xyz += vertexOffset_Layer71;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld19 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_27_0 = ( ( ( ( 1.0 - ( ase_worldPos.y - objToWorld19.y ) ) - _DisolveAmount ) - _DisolveOffset ) / _DisoleSpread );
			float simplePerlin3D33 = snoise( ( ase_worldPos * _Noise_Scale ) );
			simplePerlin3D33 = simplePerlin3D33*0.5 + 0.5;
			float smoothstepResult53 = smoothstep( 0.2 , 1.0 , temp_output_27_0);
			float clampResult30 = clamp( ( ( temp_output_27_0 - simplePerlin3D33 ) + smoothstepResult53 ) , 0.0 , 1.0 );
			float Disolve_opacity_Layer25 = clampResult30;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 uv_Dif_map = i.uv_texcoord * _Dif_map_ST.xy + _Dif_map_ST.zw;
			float3 gammaToLinear12 = GammaToLinearSpace( tex2D( _Dif_map, uv_Dif_map ).rgb );
			float EmissInc95 = _RimLightRadius;
			s1.Albedo = ( gammaToLinear12 * EmissInc95 );
			float2 uv_Normal_map = i.uv_texcoord * _Normal_map_ST.xy + _Normal_map_ST.zw;
			s1.Normal = WorldNormalVector( i , UnpackNormal( tex2D( _Normal_map, uv_Normal_map ) ) );
			s1.Emission = float3( 0,0,0 );
			float2 uv_Light_map = i.uv_texcoord * _Light_map_ST.xy + _Light_map_ST.zw;
			float4 tex2DNode4 = tex2D( _Light_map, uv_Light_map );
			float clampResult7 = clamp( ( _metallic_inc + tex2DNode4.r ) , 0.0 , 1.0 );
			s1.Metallic = clampResult7;
			float clampResult11 = clamp( ( _smoothness_inc + tex2DNode4.g ) , 0.0 , 1.0 );
			s1.Smoothness = ( 1.0 - clampResult11 );
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
			float3 linearToGamma14 = LinearToGammaSpace( surfResult1 );
			float3 PBR_layer16 = linearToGamma14;
			float saferPower44 = max( ( 1.0 - distance( temp_output_27_0 , _DisolveEdgeOffset ) ) , 0.0001 );
			float smoothstepResult45 = smoothstep( 0.0 , 1.0 , pow( saferPower44 , 2.0 ));
			float4 Disolve_Color_layer31 = ( _DisolveColor * smoothstepResult45 );
			float2 uv_EmissMap = i.uv_texcoord * _EmissMap_ST.xy + _EmissMap_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult83 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult90 = clamp( ( ( 1.0 - (dotResult83*0.5 + 0.5) ) - (_RimLightRadius*2.0 + -1.0) ) , 0.0 , 1.0 );
			float4 EmissLayer98 = ( ( ( tex2D( _EmissMap, uv_EmissMap ) * clampResult90 ) + clampResult90 ) * _RimLightColor );
			c.rgb = ( float4( PBR_layer16 , 0.0 ) + Disolve_Color_layer31 + EmissLayer98 ).rgb;
			c.a = 1;
			clip( Disolve_opacity_Layer25 - _Cutoff );
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
0;245;1920;771;3000.671;440.3116;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;55;-3408.78,234.6536;Inherit;False;2545.11;909.8818;disolve_layer;28;19;18;20;29;22;24;21;28;23;42;27;41;37;40;43;38;44;33;45;36;53;46;54;47;31;30;25;59;;0.9528302,0.904349,0.4359648,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;19;-3367.881,706.8174;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;18;-3338.681,549.7029;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;103;-662.988,243.5821;Inherit;False;1849.335;614.5737;EmissLayer;16;82;81;83;85;89;86;94;95;88;90;100;102;101;91;98;93;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-3122.427,596.6439;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;81;-612.988,417.2633;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;22;-3128.385,705.7505;Inherit;False;Property;_DisolveAmount;DisolveAmount;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-2910.119,596.6973;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;80;-3234.351,1231.598;Inherit;False;2371.259;746.5422;vertexOffsetLayer;21;57;56;58;60;78;63;61;77;79;62;76;66;67;73;65;68;69;70;74;75;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;82;-588.789,576.1592;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-3133.753,831.5871;Inherit;False;Disolve_anim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;57;-3184.351,1438.713;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;24;-2727.721,702.4698;Inherit;False;Property;_DisolveOffset;DisolveOffset;7;0;Create;True;0;0;0;False;0;False;0;-1.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-2698.15,597.3676;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;56;-3151.904,1281.598;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;83;-384.8607,496.0909;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-2474.514,596.4487;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-2957.75,1442.83;Inherit;False;59;Disolve_anim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-2945.143,1328.539;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;15;-2665.615,-599.7517;Inherit;False;1800.577;781.4845;PBR_custom_layer;16;16;14;1;12;11;7;3;10;5;2;8;4;6;96;97;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;85;-230.9265,496.7393;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-315.5289,638.526;Inherit;False;Property;_RimLightRadius;RimLightRadius;15;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2512.337,706.3835;Inherit;False;Property;_DisoleSpread;DisoleSpread;9;0;Create;True;0;0;0;False;0;False;1;1.48;0.01;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-2622.296,-59.41061;Inherit;True;Property;_Light_map;Light_map;3;0;Create;True;0;0;0;False;0;False;-1;None;a7f745220fb33f946a159d308f6c7308;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-2734.437,1441.102;Inherit;False;Property;_vertexOffset;vertexOffset;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;94;13.53149,630.5592;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;78;-2852.457,1790.14;Inherit;False;Constant;_Vector1;Vector 1;14;0;Create;True;0;0;0;False;0;False;60,60,60;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;42;-2393.089,483.9714;Inherit;False;Property;_DisolveEdgeOffset;DisolveEdgeOffset;11;0;Create;True;0;0;0;False;0;False;0;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;27;-2213.184,597.2396;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;77;-2846.457,1643.14;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;8;-2301.36,8.106104;Inherit;False;Property;_smoothness_inc;smoothness_inc;6;0;Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2733.469,1327.56;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;86;-23.00852,496.6082;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-2543.023,1328.574;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-2000.498,14.46232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;197.9588,497.883;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2280.342,-144.3642;Inherit;False;Property;_metallic_inc;metallic_inc;5;0;Create;True;0;0;0;False;0;False;0;-0.06;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;41;-2040.188,466.6363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-241.6848,742.156;Inherit;False;EmissInc;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2262.484,-537.7516;Inherit;True;Property;_Dif_map;Dif_map;1;0;Create;True;0;0;0;False;0;False;-1;None;f7549f6cf82871c439168b7599da3968;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;37;-2806.044,799.0792;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2577.081,1696.19;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;40;-2798.248,956.5351;Inherit;False;Property;_Noise_Scale;Noise_Scale;10;0;Create;True;0;0;0;False;0;False;1,1,1;500,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-2005.369,-144.1524;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;73;-2337.053,1327.761;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;371.5905,497.7755;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2593.043,866.0792;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GammaToLinearNode;12;-1934.793,-532.0273;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;43;-1868.359,465.9637;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;11;-1832.429,12.99307;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1907.831,-454.249;Inherit;False;95;EmissInc;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;76;-2399.823,1692.629;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-2412.685,1590.387;Inherit;False;Property;_vertexOffsetScale;vertexOffsetScale;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;41.60324,293.5821;Inherit;True;Property;_EmissMap;EmissMap;4;0;Create;True;0;0;0;False;0;False;-1;None;668fcaed21c1ad143a5b2782b04ad025;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;66;-2370.685,1435.387;Inherit;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;7;-1881.384,-143.0736;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;44;-1679.376,465.4867;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;104;-1675.671,13.68835;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;68;-1932.413,1463.683;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;389.0346,300.0312;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;33;-2382.807,798.476;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2032.806,-338.921;Inherit;True;Property;_Normal_map;Normal_map;2;0;Create;True;0;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1663.831,-529.249;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-2076.805,1379.938;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;93;501.2919,624.4205;Inherit;False;Property;_RimLightColor;RimLightColor;16;1;[HDR];Create;True;0;0;0;False;0;False;1,0.5615011,0,0;4,2.243137,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomStandardSurface;1;-1482.4,-350.3061;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;53;-2048.801,803.3372;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-2029.693,683.798;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;585.3501,492.3853;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-1727.413,1376.683;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;46;-1529.582,284.6536;Inherit;False;Property;_DisolveColor;DisolveColor;12;1;[HDR];Create;True;0;0;0;False;0;False;0.2745098,0.9490196,2,0;3.211117,0.9568428,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-1483.19,465.1366;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-1859.023,679.0156;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1281.582,402.6536;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LinearToGammaNode;14;-1245.446,-350.1359;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;70;-1553.038,1376.173;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;743.7581,492.2639;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;74;-1526.17,1532.083;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1059.726,-342.3616;Inherit;False;PBR_layer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;962.3471,490.4681;Inherit;False;EmissLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;75;-1291.17,1382.083;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;30;-1698.245,649.8071;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1112.672,396.7709;Inherit;False;Disolve_Color_layer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-364.0261,-363.9835;Inherit;False;31;Disolve_Color_layer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-323.8519,-274.3124;Inherit;False;98;EmissLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-310.7605,-451.1374;Inherit;False;16;PBR_layer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-1109.091,1376.37;Inherit;False;vertexOffset_Layer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1493.745,643.2117;Inherit;False;Disolve_opacity_Layer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-108.575,-396.6235;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;574.2198,-507.2932;Inherit;False;25;Disolve_opacity_Layer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;587.9045,-383.0815;Inherit;False;71;vertexOffset_Layer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;900.4778,-643.1164;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;K25_sci_transfer_shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.3;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;18;2
WireConnection;20;1;19;2
WireConnection;29;0;20;0
WireConnection;59;0;22;0
WireConnection;21;0;29;0
WireConnection;21;1;22;0
WireConnection;83;0;81;0
WireConnection;83;1;82;0
WireConnection;23;0;21;0
WireConnection;23;1;24;0
WireConnection;58;0;56;2
WireConnection;58;1;57;2
WireConnection;85;0;83;0
WireConnection;94;0;89;0
WireConnection;27;0;23;0
WireConnection;27;1;28;0
WireConnection;61;0;58;0
WireConnection;61;1;60;0
WireConnection;86;0;85;0
WireConnection;62;0;61;0
WireConnection;62;1;63;0
WireConnection;10;0;8;0
WireConnection;10;1;4;2
WireConnection;88;0;86;0
WireConnection;88;1;94;0
WireConnection;41;0;27;0
WireConnection;41;1;42;0
WireConnection;95;0;89;0
WireConnection;79;0;77;0
WireConnection;79;1;78;0
WireConnection;5;0;6;0
WireConnection;5;1;4;1
WireConnection;73;0;62;0
WireConnection;90;0;88;0
WireConnection;38;0;37;0
WireConnection;38;1;40;0
WireConnection;12;0;2;0
WireConnection;43;0;41;0
WireConnection;11;0;10;0
WireConnection;76;0;79;0
WireConnection;7;0;5;0
WireConnection;44;0;43;0
WireConnection;104;0;11;0
WireConnection;102;0;100;0
WireConnection;102;1;90;0
WireConnection;33;0;38;0
WireConnection;96;0;12;0
WireConnection;96;1;97;0
WireConnection;65;0;73;0
WireConnection;65;1;66;0
WireConnection;65;2;67;0
WireConnection;65;3;76;0
WireConnection;1;0;96;0
WireConnection;1;1;3;0
WireConnection;1;3;7;0
WireConnection;1;4;104;0
WireConnection;53;0;27;0
WireConnection;36;0;27;0
WireConnection;36;1;33;0
WireConnection;101;0;102;0
WireConnection;101;1;90;0
WireConnection;69;0;65;0
WireConnection;69;1;68;0
WireConnection;45;0;44;0
WireConnection;54;0;36;0
WireConnection;54;1;53;0
WireConnection;47;0;46;0
WireConnection;47;1;45;0
WireConnection;14;0;1;0
WireConnection;70;0;69;0
WireConnection;91;0;101;0
WireConnection;91;1;93;0
WireConnection;16;0;14;0
WireConnection;98;0;91;0
WireConnection;75;0;70;0
WireConnection;75;1;74;0
WireConnection;30;0;54;0
WireConnection;31;0;47;0
WireConnection;71;0;75;0
WireConnection;25;0;30;0
WireConnection;50;0;17;0
WireConnection;50;1;48;0
WireConnection;50;2;99;0
WireConnection;0;10;26;0
WireConnection;0;13;50;0
WireConnection;0;11;72;0
ASEEND*/
//CHKSM=2D0A907242576157EE59FE5819B832AED757FCBA