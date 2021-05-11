// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k32_style_water"
{
	Properties
	{
		_DeepColor("DeepColor", Color) = (0,0,0,0)
		_ShallowColor("ShallowColor", Color) = (0,0,0,0)
		_DeepRange("DeepRange", Float) = 1
		_frenelPow("frenel Pow", Float) = 10
		_fresnelColor("fresnel Color", Color) = (0.5990566,0.8565045,1,0)
		_NormalMap("NormalMap", 2D) = "white" {}
		_NormalSpeed("NormalSpeed", Vector) = (0,0,0,0)
		_NormalTilling("NormalTilling", Float) = 1
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_ReflectionDistort("ReflectionDistort", Float) = 1
		_GausTex("GausTex", 2D) = "white" {}
		_GausIntensity("GausIntensity", Float) = 1
		_GausTilling("GausTilling", Float) = 1
		_GausSpeeds("GausSpeeds", Vector) = (0,0,0,0)
		_ShoreRange("ShoreRange", Float) = 1
		_ShoreRangeMin("ShoreRangeMin", Float) = 0
		_ShoreRangeMax("ShoreRangeMax", Float) = 1
		_WaveEdgeMin("WaveEdgeMin", Float) = 0
		_WaveEdgeMax("WaveEdgeMax", Float) = 0
		_WaveEdgeIntensity("WaveEdgeIntensity", Float) = 1
		_FoamRangeMin("FoamRangeMin", Float) = 0
		_FoamRangeMax("FoamRangeMax", Float) = 1
		_FoamSequence("FoamSequence", Float) = 1
		_FoamSpeed("FoamSpeed", Float) = 1
		_FoamMaskMax("FoamMaskMax", Float) = 1
		_FoamMaskMin("FoamMaskMin", Float) = 0
		_FoamNoiseSize("FoamNoiseSize", Vector) = (0,0,0,0)
		_FoamNoiseDisolve("FoamNoiseDisolve", Float) = 1
		_FoamColor("FoamColor", Color) = (0,0,0,0)
		_WaveColor("WaveColor", Color) = (1,1,1,0)
		_WaveAspeedXYSteepLength("WaveA(speedXY,Steep,Length)", Vector) = (1,1,2,50)
		_WaveB("WaveB", Vector) = (1,1,2,50)
		_WaveC("WaveC", Vector) = (1,1,2,50)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float4 _WaveAspeedXYSteepLength;
		uniform float4 _WaveB;
		uniform float4 _WaveC;
		uniform float4 _DeepColor;
		uniform float4 _ShallowColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DeepRange;
		uniform float4 _fresnelColor;
		uniform float _frenelPow;
		uniform float4 _WaveColor;
		uniform sampler2D _ReflectionTex;
		uniform sampler2D _NormalMap;
		uniform float _NormalTilling;
		uniform float2 _NormalSpeed;
		uniform float _ReflectionDistort;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _GausTex;
		uniform float _GausTilling;
		uniform float2 _GausSpeeds;
		uniform float _GausIntensity;
		uniform float _ShoreRangeMin;
		uniform float _ShoreRangeMax;
		uniform float _ShoreRange;
		uniform float _WaveEdgeMin;
		uniform float _WaveEdgeMax;
		uniform float _WaveEdgeIntensity;
		uniform float _FoamMaskMin;
		uniform float _FoamMaskMax;
		uniform float _FoamRangeMin;
		uniform float _FoamRangeMax;
		uniform float _FoamSequence;
		uniform float _FoamSpeed;
		uniform float2 _FoamNoiseSize;
		uniform float _FoamNoiseDisolve;
		uniform float4 _FoamColor;


		float3 GerstnerWave4_g4( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave6_g4( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave8_g4( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		//https://www.shadertoy.com/view/XdXGW8
		float2 GradientNoiseDir( float2 x )
		{
			const float2 k = float2( 0.3183099, 0.3678794 );
			x = x * k + k.yx;
			return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
		}
		
		float GradientNoise( float2 UV, float Scale )
		{
			float2 p = UV * Scale;
			float2 i = floor( p );
			float2 f = frac( p );
			float2 u = f * f * ( 3.0 - 2.0 * f );
			return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
					lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
					dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 temp_output_29_0_g4 = ase_worldPos;
			float3 position4_g4 = temp_output_29_0_g4;
			float3 tangent4_g4 = float3( 1,0,0 );
			float3 binormal4_g4 = float3( 0,0,1 );
			float4 wave4_g4 = _WaveAspeedXYSteepLength;
			float3 localGerstnerWave4_g4 = GerstnerWave4_g4( position4_g4 , tangent4_g4 , binormal4_g4 , wave4_g4 );
			float3 position6_g4 = temp_output_29_0_g4;
			float3 tangent6_g4 = tangent4_g4;
			float3 binormal6_g4 = binormal4_g4;
			float4 wave6_g4 = _WaveB;
			float3 localGerstnerWave6_g4 = GerstnerWave6_g4( position6_g4 , tangent6_g4 , binormal6_g4 , wave6_g4 );
			float3 position8_g4 = temp_output_29_0_g4;
			float3 tangent8_g4 = tangent6_g4;
			float3 binormal8_g4 = binormal6_g4;
			float4 wave8_g4 = _WaveC;
			float3 localGerstnerWave8_g4 = GerstnerWave8_g4( position8_g4 , tangent8_g4 , binormal8_g4 , wave8_g4 );
			float3 temp_output_9_0_g4 = ( temp_output_29_0_g4 + localGerstnerWave4_g4 + localGerstnerWave6_g4 + localGerstnerWave8_g4 );
			float3 worldToObj18_g4 = mul( unity_WorldToObject, float4( temp_output_9_0_g4, 1 ) ).xyz;
			v.vertex.xyz = worldToObj18_g4;
			v.vertex.w = 1;
			float3 normalizeResult15_g4 = normalize( cross( binormal8_g4 , tangent8_g4 ) );
			float3 worldToObjDir17_g4 = mul( unity_WorldToObject, float4( normalizeResult15_g4, 0 ) ).xyz;
			v.normal = worldToObjDir17_g4;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 In72_g1 = temp_output_46_0_g1;
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 worldDepth6 = (mul( unity_CameraToWorld, appendResult49_g1 )).xyz;
			float waterDepth9 = ( ase_worldPos.y - (worldDepth6).y );
			float4 lerpResult13 = lerp( _DeepColor , _ShallowColor , exp( ( -waterDepth9 / _DeepRange ) ));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV22 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode22 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV22 , 0.0001 ), _frenelPow ) );
			float4 lerpResult20 = lerp( lerpResult13 , _fresnelColor , fresnelNode22);
			float4 waterColorLayer24 = lerpResult20;
			float3 temp_output_29_0_g4 = ase_worldPos;
			float3 position4_g4 = temp_output_29_0_g4;
			float3 tangent4_g4 = float3( 1,0,0 );
			float3 binormal4_g4 = float3( 0,0,1 );
			float4 wave4_g4 = _WaveAspeedXYSteepLength;
			float3 localGerstnerWave4_g4 = GerstnerWave4_g4( position4_g4 , tangent4_g4 , binormal4_g4 , wave4_g4 );
			float3 position6_g4 = temp_output_29_0_g4;
			float3 tangent6_g4 = tangent4_g4;
			float3 binormal6_g4 = binormal4_g4;
			float4 wave6_g4 = _WaveB;
			float3 localGerstnerWave6_g4 = GerstnerWave6_g4( position6_g4 , tangent6_g4 , binormal6_g4 , wave6_g4 );
			float3 position8_g4 = temp_output_29_0_g4;
			float3 tangent8_g4 = tangent6_g4;
			float3 binormal8_g4 = binormal6_g4;
			float4 wave8_g4 = _WaveC;
			float3 localGerstnerWave8_g4 = GerstnerWave8_g4( position8_g4 , tangent8_g4 , binormal8_g4 , wave8_g4 );
			float3 temp_output_9_0_g4 = ( temp_output_29_0_g4 + localGerstnerWave4_g4 + localGerstnerWave6_g4 + localGerstnerWave8_g4 );
			float clampResult14_g4 = clamp( (( temp_output_9_0_g4 - ase_worldPos )).y , 0.0 , 1.0 );
			float4 waveTopColor186 = ( clampResult14_g4 * _WaveColor );
			float2 temp_output_32_0 = ( (ase_worldPos).xz / _NormalTilling );
			float2 temp_output_37_0 = ( _NormalSpeed * _Time.y * 0.01 );
			float3 waterNormalLayer48 = BlendNormals( tex2D( _NormalMap, ( temp_output_32_0 + temp_output_37_0 ) ).rgb , tex2D( _NormalMap, ( ( temp_output_32_0 * 2.0 ) + ( temp_output_37_0 * -0.5 ) ) ).rgb );
			float4 reflectionColor60 = tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( (waterNormalLayer48).xy * ( _ReflectionDistort * 0.01 ) ) ) );
			float fresnelNdotV78 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode78 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV78, 5.0 ) );
			float4 lerpResult77 = lerp( ( waterColorLayer24 + waveTopColor186 ) , reflectionColor60 , fresnelNode78);
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor69 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + float4( ( waterNormalLayer48 * 1.0 * 0.01 ) , 0.0 ) ).xy);
			float2 temp_output_86_0 = ( (worldDepth6).xz / _GausTilling );
			float2 temp_output_85_0 = ( _GausSpeeds * _Time.y * 0.01 );
			float4 GausLayer91 = ( min( tex2D( _GausTex, ( temp_output_86_0 + temp_output_85_0 ) ) , tex2D( _GausTex, ( -temp_output_86_0 + temp_output_85_0 ) ) ) * _GausIntensity );
			float clampResult95 = clamp( ( 1.0 - (lerpResult20).a ) , 0.0 , 1.0 );
			float waterAlpha27 = clampResult95;
			float4 underWaterLayer70 = ( ( screenColor69 + GausLayer91 ) * ( 1.0 - waterAlpha27 ) );
			float4 lerpResult73 = lerp( lerpResult77 , underWaterLayer70 , ( 1.0 - waterAlpha27 ));
			float4 underWaterColor121 = screenColor69;
			float temp_output_115_0 = exp( ( -waterDepth9 / _ShoreRange ) );
			float smoothstepResult108 = smoothstep( _ShoreRangeMin , _ShoreRangeMax , temp_output_115_0);
			float ShoreAlpha111 = smoothstepResult108;
			float4 lerpResult118 = lerp( lerpResult73 , underWaterColor121 , ShoreAlpha111);
			float smoothstepResult123 = smoothstep( _WaveEdgeMin , _WaveEdgeMax , temp_output_115_0);
			float WaveEdgeLayer128 = ( smoothstepResult123 * _WaveEdgeIntensity );
			float clampResult149 = clamp( exp( -waterDepth9 ) , 0.0 , 1.0 );
			float smoothstepResult158 = smoothstep( _FoamMaskMin , _FoamMaskMax , clampResult149);
			float smoothstepResult145 = smoothstep( _FoamRangeMin , _FoamRangeMax , clampResult149);
			float gradientNoise165 = GradientNoise(( i.uv_texcoord * _FoamNoiseSize ),1.0);
			gradientNoise165 = gradientNoise165*0.5 + 0.5;
			float4 FoamLayer146 = ( ( smoothstepResult158 * step( smoothstepResult145 , ( ( sin( ( ( smoothstepResult145 * _FoamSequence ) + ( _FoamSpeed * _Time.y ) ) ) + gradientNoise165 ) - _FoamNoiseDisolve ) ) ) * _FoamColor );
			o.Emission = max( ( ( lerpResult118 + WaveEdgeLayer128 ) + FoamLayer146 ) , float4( 0,0,0,0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
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
0;66;1920;953;810.8663;-1114.178;2.269635;True;True
Node;AmplifyShaderEditor.CommentaryNode;10;-1877.991,-161.5368;Inherit;False;1377.184;412.0346;waterDepth;8;7;4;8;1;2;6;3;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;1;-1827.991,39.6245;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;2;-1461.991,34.62452;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-1293.732,34.82044;Inherit;False;worldDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-1276.644,133.3133;Inherit;False;6;worldDepth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;4;-1130.329,-111.5368;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;8;-1080.009,134.4978;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;-2333.771,1083.162;Inherit;False;1839.722;554.6033;waterNormal;18;30;31;33;32;35;41;36;38;37;39;43;42;44;45;46;40;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;3;-891.853,10.01676;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-2280.771,1156.236;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-724.8066,8.269226;Inherit;False;waterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;19;-2170.102,268.5098;Inherit;False;1932.486;797.3937;waterDepth;17;95;29;24;27;26;20;22;13;21;23;11;18;12;16;17;15;14;;0,0.5847392,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2082.374,1250.107;Inherit;False;Property;_NormalTilling;NormalTilling;7;0;Create;True;0;0;0;False;0;False;1;48.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2246.477,1527.75;Inherit;False;Constant;_test;test;6;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-2153.475,665.7701;Inherit;False;9;waterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;96;-2120.17,2288.801;Inherit;False;2069.977;553.5071;GausLayer;17;91;89;88;90;100;85;86;83;81;80;84;99;87;102;103;104;105;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;38;-2263.996,1453.299;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;31;-2069.236,1154.854;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;36;-2263.027,1326.749;Inherit;False;Property;_NormalSpeed;NormalSpeed;6;0;Create;True;0;0;0;False;0;False;0,0;-20,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;87;-2094.17,2356.602;Inherit;False;6;worldDepth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1877.632,1158.139;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;15;-1940.353,670.6578;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1831.654,1332.22;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1829.465,1470.174;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1965.128,748.083;Inherit;False;Property;_DeepRange;DeepRange;2;0;Create;True;0;0;0;False;0;False;1;1.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2052.811,1338.794;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1658.665,1313.607;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1660.854,1450.466;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1914.042,2435.665;Inherit;False;Property;_GausTilling;GausTilling;12;0;Create;True;0;0;0;False;0;False;1;11.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;84;-1891.904,2356.412;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-1780.354,670.7701;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;174;-1710.851,3957.492;Inherit;False;2431.345;1018.065;FoamLayer;27;140;142;144;149;139;138;152;156;145;151;166;169;153;155;150;167;154;165;170;164;172;171;173;157;146;175;176;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1990.145,2713.308;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-1679.851,4022.495;Inherit;False;9;waterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;81;-2017.664,2632.857;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-1682.164,310.7227;Inherit;False;Property;_DeepColor;DeepColor;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.03529412,0.572549,0.9137256,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-1646.493,892.0038;Inherit;False;Property;_frenelPow;frenel Pow;3;0;Create;True;0;0;0;False;0;False;10;10.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;86;-1742.3,2364.697;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;12;-1682.851,489.3004;Inherit;False;Property;_ShallowColor;ShallowColor;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.3820755,0.9312975,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1647.708,1159.233;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;99;-2014.583,2509.419;Inherit;False;Property;_GausSpeeds;GausSpeeds;13;0;Create;True;0;0;0;False;0;False;0,0;20,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-1484.58,1427.475;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ExpOpNode;18;-1601.816,668.2079;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1790.479,2528.352;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;41;-1345.531,1407.765;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;40;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;104;-1596.35,2488.035;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;40;-1349.436,1133.162;Inherit;True;Property;_NormalMap;NormalMap;5;0;Create;True;0;0;0;False;0;False;-1;None;0336d7e3aec9ba94d8d36f364bd09bde;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;-1433.031,610.6824;Inherit;False;Property;_fresnelColor;fresnel Color;4;0;Create;True;0;0;0;False;0;False;0.5990566,0.8565045,1,0;0.3537736,1,0.7798635,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;142;-1474.729,4027.385;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;22;-1449.5,800.4969;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;13;-1381.75,448.8008;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;47;-972.9498,1288.673;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;20;-1129.429,590.4822;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-1476.35,2587.035;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-1528.129,2358.734;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ExpOpNode;144;-1317.192,4027.934;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;88;-1302.293,2335.801;Inherit;True;Property;_GausTex;GausTex;10;0;Create;True;0;0;0;False;0;False;-1;None;7ac8eaff57f0fac47a018dc860860000;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;138;-1188.978,4423.766;Inherit;False;Property;_FoamRangeMax;FoamRangeMax;21;0;Create;True;0;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;149;-1160.138,4028.822;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;61;-1836.532,1666.985;Inherit;False;1338.572;580.9972;ReflectionLayer;11;54;52;51;50;55;56;58;57;59;53;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-735.0498,1284.772;Inherit;False;waterNormalLayer;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;72;-1487.668,2876.177;Inherit;False;1790;561;underWater;14;92;97;98;69;64;63;70;94;93;66;67;68;65;121;;0.9245283,0.7336622,0.2049662,1;0;0
Node;AmplifyShaderEditor.SamplerNode;102;-1297.35,2570.035;Inherit;True;Property;_TextureSample1;Texture Sample 1;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;88;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;26;-953.3474,705.5206;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-1184.978,4341.766;Inherit;False;Property;_FoamRangeMin;FoamRangeMin;20;0;Create;True;0;0;0;False;0;False;0;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-1786.532,1955.985;Inherit;False;48;waterNormalLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1770.138,2048.98;Inherit;False;Property;_ReflectionDistort;ReflectionDistort;9;0;Create;True;0;0;0;False;0;False;1;-0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-853.293,2511.801;Inherit;False;Property;_GausIntensity;GausIntensity;11;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1433.668,3108.177;Inherit;False;48;waterNormalLayer;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;105;-966.3501,2424.035;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1373.668,3264.177;Inherit;False;Constant;_Float4;Float 4;10;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-942.199,4505.553;Inherit;False;Property;_FoamSequence;FoamSequence;22;0;Create;True;0;0;0;False;0;False;1;40.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1423.668,3185.177;Inherit;False;Constant;_UnderWaterDistort;UnderWaterDistort;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-922.9415,4589.283;Inherit;False;Property;_FoamSpeed;FoamSpeed;23;0;Create;True;0;0;0;False;0;False;1;-3.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1728.138,2131.981;Inherit;False;Constant;_Float3;Float 3;9;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;145;-918.178,4364.567;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;151;-937.9415,4668.283;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-813.4248,775.5559;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-674.293,2426.801;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;63;-1437.668,2926.177;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-739.9413,4619.283;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;50;-1688.421,1738.236;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1178.668,3126.177;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;169;-1149.039,4811.557;Inherit;False;Property;_FoamNoiseSize;FoamNoiseSize;26;0;Create;True;0;0;0;False;0;False;0,0;9.99,51;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SwizzleNode;55;-1563.532,1956.985;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-718.5988,4442.951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;95;-643.7368,775.2355;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;166;-1181.039,4685.557;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1553.138,2052.981;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;117;-1418.946,3461.677;Inherit;False;1368.933;466.3123;ShoreAlpha;15;111;108;115;109;110;112;116;123;124;125;126;127;128;147;148;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;189;940.0997,2229.474;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;182;924.9203,2451.833;Inherit;False;Property;_WaveColor;WaveColor;29;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;185;1155.442,2813.134;Inherit;False;Property;_WaveC;WaveC;32;0;Create;True;0;0;0;False;0;False;1,1,2,50;1,1,2,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;184;968.2017,2814.627;Inherit;False;Property;_WaveB;WaveB;31;0;Create;True;0;0;0;False;0;False;1,1,2,50;1,1,2,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;183;849.2017,2630.627;Inherit;False;Property;_WaveAspeedXYSteepLength;WaveA(speedXY,Steep,Length);30;0;Create;True;0;0;0;False;0;False;1,1,2,50;10.31,1,2,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1031.668,2932.177;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-1368.946,3517.18;Inherit;False;9;waterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-298.2926,2358.301;Inherit;False;GausLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1407.138,1961.982;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-574.9409,4545.283;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-935.038,4758.557;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;51;-1459.542,1739.158;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-489.3238,769.4997;Inherit;False;waterAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;112;-1170.824,3522.068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;165;-735.0379,4750.557;Inherit;False;Gradient;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;69;-878.6678,2928.177;Inherit;False;Global;_GrabScreen0;Grab Screen 0;10;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;148;-1196.01,3602.112;Inherit;False;Property;_ShoreRange;ShoreRange;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-858.5909,3125.509;Inherit;False;91;GausLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1016.607,3236.271;Inherit;False;27;waterAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;154;-433.9409,4545.283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;181;1312.851,2199.97;Inherit;False;Multy_Wave_Sweep;-1;;4;3bc98c419d767c4478f9f322071a246d;0;5;29;FLOAT3;0,0,0;False;25;COLOR;0,0,0,0;False;26;FLOAT4;1,1,2,50;False;27;FLOAT4;1,1,2,50;False;28;FLOAT4;1,1,2,50;False;3;COLOR;23;FLOAT3;24;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-1257.532,1743.985;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-924.3969,585.3467;Inherit;False;waterColorLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-587.5907,3102.509;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;1913.372,2193.433;Inherit;False;waveTopColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-362.941,4751.915;Inherit;False;Property;_FoamNoiseDisolve;FoamNoiseDisolve;27;0;Create;True;0;0;0;False;0;False;1;0.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;129;390.9926,1218.014;Inherit;False;1529.214;941.4048;MainLayer;16;180;178;130;131;118;122;119;73;75;77;76;62;28;78;25;187;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-1019.01,3529.112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;53;-1099.532,1715.985;Inherit;True;Property;_ReflectionTex;ReflectionTex;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;164;-940.9713,4002.491;Inherit;False;561.4052;307.7642;FoamMask;3;162;163;158;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;94;-766.3817,3240.109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;-284.0378,4648.557;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-722.961,1718.609;Inherit;False;reflectionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-861.2372,3844.824;Inherit;False;Property;_WaveEdgeMax;WaveEdgeMax;18;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-892.7068,4195.256;Inherit;False;Property;_FoamMaskMax;FoamMaskMax;24;0;Create;True;0;0;0;False;0;False;1;0.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-879.5701,3596.989;Inherit;False;Property;_ShoreRangeMin;ShoreRangeMin;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-890.9713,4092.016;Inherit;False;Property;_FoamMaskMin;FoamMaskMin;25;0;Create;True;0;0;0;False;0;False;0;0.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-882.5701,3677.989;Inherit;False;Property;_ShoreRangeMax;ShoreRangeMax;16;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;485.035,1350.553;Inherit;False;186;waveTopColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-859.2372,3766.824;Inherit;False;Property;_WaveEdgeMin;WaveEdgeMin;17;0;Create;True;0;0;0;False;0;False;0;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;473.6422,1266.014;Inherit;False;24;waterColorLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;171;-121.941,4706.915;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-414.0065,3218.672;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ExpOpNode;115;-873.2866,3518.618;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;123;-626.2372,3721.824;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;701.035,1294.553;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;158;-569.5659,4037.492;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-649.3552,3848.298;Inherit;False;Property;_WaveEdgeIntensity;WaveEdgeIntensity;19;0;Create;True;0;0;0;False;0;False;1;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-23.66849,2990.177;Inherit;False;underWaterLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;513.8883,1714.017;Inherit;False;27;waterAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;78;446.9924,1535.822;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;472.8073,1441.76;Inherit;False;60;reflectionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;173;-32.94084,4383.915;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;108;-621.5701,3517.989;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-419.3552,3743.298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;77;840.9926,1374.822;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-641.9154,2933.492;Inherit;False;underWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;671.309,1626.001;Inherit;False;70;underWaterLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;176;93.27938,4497.346;Inherit;False;Property;_FoamColor;FoamColor;28;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1320755,0.1320755,0.1320755,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;163.073,4358.864;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-346.0132,3514.677;Inherit;False;ShoreAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;712.309,1719.001;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;941.4333,1673.656;Inherit;False;121;underWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;73;994.3084,1527.001;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;-268.3552,3739.298;Inherit;False;WaveEdgeLayer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;340.8794,4362.744;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;972.8419,1756.459;Inherit;False;111;ShoreAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;118;1234.842,1652.458;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;1186.062,1786.965;Inherit;False;128;WaveEdgeLayer;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;508.4936,4356.004;Inherit;False;FoamLayer;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;1361.868,1881.537;Inherit;True;146;FoamLayer;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;1429.062,1696.965;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;180;1590.534,1792.681;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;132;1859.837,1790.007;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2143.705,1736.906;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;k32_style_water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;6;0;2;0
WireConnection;8;0;7;0
WireConnection;3;0;4;2
WireConnection;3;1;8;0
WireConnection;9;0;3;0
WireConnection;31;0;30;0
WireConnection;32;0;31;0
WireConnection;32;1;33;0
WireConnection;15;0;14;0
WireConnection;37;0;36;0
WireConnection;37;1;38;0
WireConnection;37;2;39;0
WireConnection;43;0;32;0
WireConnection;43;1;44;0
WireConnection;45;0;37;0
WireConnection;45;1;46;0
WireConnection;84;0;87;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;86;0;84;0
WireConnection;86;1;80;0
WireConnection;35;0;32;0
WireConnection;35;1;37;0
WireConnection;42;0;43;0
WireConnection;42;1;45;0
WireConnection;18;0;16;0
WireConnection;85;0;99;0
WireConnection;85;1;81;0
WireConnection;85;2;83;0
WireConnection;41;1;42;0
WireConnection;104;0;86;0
WireConnection;40;1;35;0
WireConnection;142;0;140;0
WireConnection;22;3;23;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;13;2;18;0
WireConnection;47;0;40;0
WireConnection;47;1;41;0
WireConnection;20;0;13;0
WireConnection;20;1;21;0
WireConnection;20;2;22;0
WireConnection;103;0;104;0
WireConnection;103;1;85;0
WireConnection;100;0;86;0
WireConnection;100;1;85;0
WireConnection;144;0;142;0
WireConnection;88;1;100;0
WireConnection;149;0;144;0
WireConnection;48;0;47;0
WireConnection;102;1;103;0
WireConnection;26;0;20;0
WireConnection;105;0;88;0
WireConnection;105;1;102;0
WireConnection;145;0;149;0
WireConnection;145;1;139;0
WireConnection;145;2;138;0
WireConnection;29;0;26;0
WireConnection;89;0;105;0
WireConnection;89;1;90;0
WireConnection;153;0;152;0
WireConnection;153;1;151;0
WireConnection;66;0;65;0
WireConnection;66;1;67;0
WireConnection;66;2;68;0
WireConnection;55;0;54;0
WireConnection;155;0;145;0
WireConnection;155;1;156;0
WireConnection;95;0;29;0
WireConnection;58;0;57;0
WireConnection;58;1;59;0
WireConnection;64;0;63;0
WireConnection;64;1;66;0
WireConnection;91;0;89;0
WireConnection;56;0;55;0
WireConnection;56;1;58;0
WireConnection;150;0;155;0
WireConnection;150;1;153;0
WireConnection;167;0;166;0
WireConnection;167;1;169;0
WireConnection;51;0;50;0
WireConnection;27;0;95;0
WireConnection;112;0;116;0
WireConnection;165;0;167;0
WireConnection;69;0;64;0
WireConnection;154;0;150;0
WireConnection;181;29;189;0
WireConnection;181;25;182;0
WireConnection;181;26;183;0
WireConnection;181;27;184;0
WireConnection;181;28;185;0
WireConnection;52;0;51;0
WireConnection;52;1;56;0
WireConnection;24;0;20;0
WireConnection;97;0;69;0
WireConnection;97;1;98;0
WireConnection;186;0;181;23
WireConnection;147;0;112;0
WireConnection;147;1;148;0
WireConnection;53;1;52;0
WireConnection;94;0;93;0
WireConnection;170;0;154;0
WireConnection;170;1;165;0
WireConnection;60;0;53;0
WireConnection;171;0;170;0
WireConnection;171;1;172;0
WireConnection;92;0;97;0
WireConnection;92;1;94;0
WireConnection;115;0;147;0
WireConnection;123;0;115;0
WireConnection;123;1;124;0
WireConnection;123;2;125;0
WireConnection;188;0;25;0
WireConnection;188;1;187;0
WireConnection;158;0;149;0
WireConnection;158;1;163;0
WireConnection;158;2;162;0
WireConnection;70;0;92;0
WireConnection;173;0;145;0
WireConnection;173;1;171;0
WireConnection;108;0;115;0
WireConnection;108;1;109;0
WireConnection;108;2;110;0
WireConnection;126;0;123;0
WireConnection;126;1;127;0
WireConnection;77;0;188;0
WireConnection;77;1;62;0
WireConnection;77;2;78;0
WireConnection;121;0;69;0
WireConnection;157;0;158;0
WireConnection;157;1;173;0
WireConnection;111;0;108;0
WireConnection;76;0;28;0
WireConnection;73;0;77;0
WireConnection;73;1;75;0
WireConnection;73;2;76;0
WireConnection;128;0;126;0
WireConnection;175;0;157;0
WireConnection;175;1;176;0
WireConnection;118;0;73;0
WireConnection;118;1;122;0
WireConnection;118;2;119;0
WireConnection;146;0;175;0
WireConnection;130;0;118;0
WireConnection;130;1;131;0
WireConnection;180;0;130;0
WireConnection;180;1;178;0
WireConnection;132;0;180;0
WireConnection;0;2;132;0
WireConnection;0;11;181;0
WireConnection;0;12;181;24
ASEEND*/
//CHKSM=1D790B2BD51DFA55DAE52D739E2B3B5D62925C7B