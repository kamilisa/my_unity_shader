// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "k23_beer_out"
{
	Properties
	{
		_refract_matCap("refract_matCap", 2D) = "white" {}
		_refract_Color("refract_Color", Color) = (0,0,0,0)
		_refractIntensity("refractIntensity", Float) = 0
		_fresnel_smooth_min("fresnel_smooth_min", Float) = 0
		_fresnel_smooth_max("fresnel_smooth_max", Float) = 1
		_matCap("matCap", 2D) = "white" {}
		_dirtyMap("dirtyMap", 2D) = "black" {}
		_Logo_Attach("Logo_Attach", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
		};

		uniform sampler2D _matCap;
		uniform float4 _refract_Color;
		uniform sampler2D _refract_matCap;
		uniform float _fresnel_smooth_min;
		uniform float _fresnel_smooth_max;
		uniform sampler2D _dirtyMap;
		uniform float4 _dirtyMap_ST;
		uniform float _refractIntensity;
		uniform sampler2D _Logo_Attach;
		uniform float4 _Logo_Attach_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView13 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 normalizeResult14 = normalize( objToView13 );
			float3 ase_worldNormal = i.worldNormal;
			float3 break17 = cross( normalizeResult14 , mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz );
			float2 appendResult19 = (float2(-break17.y , break17.x));
			float2 matCap_New23 = (appendResult19*0.5 + 0.5);
			float4 tex2DNode41 = tex2D( _matCap, matCap_New23 );
			float dotResult32 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult33 = smoothstep( _fresnel_smooth_min , _fresnel_smooth_max , dotResult32);
			float2 uv_dirtyMap = i.uv_texcoord * _dirtyMap_ST.xy + _dirtyMap_ST.zw;
			float clampResult89 = clamp( ( ( 1.0 - smoothstepResult33 ) + tex2D( _dirtyMap, uv_dirtyMap ).a ) , 0.0 , 1.0 );
			float Fresnel45 = clampResult89;
			float4 lerpResult49 = lerp( _refract_Color , tex2D( _refract_matCap, ( ( matCap_New23 + Fresnel45 ) * _refractIntensity ) ) , Fresnel45);
			float2 uv_Logo_Attach = i.uv_texcoord * _Logo_Attach_ST.xy + _Logo_Attach_ST.zw;
			float4 tex2DNode94 = tex2D( _Logo_Attach, uv_Logo_Attach );
			float4 lerpResult93 = lerp( ( tex2DNode41 + lerpResult49 ) , tex2DNode94 , tex2DNode94.a);
			o.Emission = lerpResult93.rgb;
			float clampResult44 = clamp( ( tex2DNode94.a + max( tex2DNode41.r , Fresnel45 ) ) , 0.0 , 1.0 );
			o.Alpha = clampResult44;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
0;128;1920;891;1628.948;-368.341;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;24;-3571.812,-63.28021;Inherit;False;1873.85;487.0237;matCap_new;12;12;13;14;16;9;10;11;17;20;19;21;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;12;-3521.812,-9.235649;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;13;-3314.529,-13.28021;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;9;-3327.033,240.7435;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;10;-3255.885,147.4898;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;46;-998.5877,618.7256;Inherit;False;1876.672;1072.011;Fresnel;20;45;62;32;29;30;33;34;55;54;53;78;82;84;85;86;87;88;89;96;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-3073.88,167.7126;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;14;-3088.036,-9.235672;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-929.4716,814.5961;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;29;-952.5878,667.7255;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;96;-732.9482,836.3411;Inherit;False;Property;_fresnel_smooth_min;fresnel_smooth_min;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-731.9482,924.3411;Inherit;False;Property;_fresnel_smooth_max;fresnel_smooth_max;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;32;-721.3348,734.0861;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;16;-2887.833,104.0112;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-496.5524,735.0916;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-2701.786,104.0113;Inherit;True;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NegateNode;20;-2457.092,187.9352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;-243.5293,732.843;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;88;-364.1758,954.8461;Inherit;True;Property;_dirtyMap;dirtyMap;7;0;Create;True;0;0;0;False;0;False;-1;None;8ad78cf26f7afe146aa0b1443b53a37d;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2294.3,97.94455;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-7.721878,737.6856;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;89;380.9652,738.9153;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;21;-2139.712,99.14328;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;658.8566,732.944;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1921.964,96.00926;Inherit;False;matCap_New;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1336.705,174.1099;Inherit;False;45;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1353.535,90.46895;Inherit;False;23;matCap_New;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1137.169,94.00882;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1197.036,255.2123;Inherit;False;Property;_refractIntensity;refractIntensity;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-689.9344,-299.0933;Inherit;False;23;matCap_New;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-919.0365,93.21234;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;25;-715.6664,56.01497;Inherit;True;Property;_refract_matCap;refract_matCap;1;0;Create;True;0;0;0;False;0;False;-1;None;5461bbb75f146ef449e27262b8bf3f6b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;50;-589.4136,275.9734;Inherit;False;45;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-631.4045,-126.0075;Inherit;False;Property;_refract_Color;refract_Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5377358,0.5188075,0.2967693,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-391.5387,-320.5545;Inherit;True;Property;_matCap;matCap;6;0;Create;True;0;0;0;False;0;False;-1;None;d59ec6520cc0d494c828a37241c273b6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;52;87.57204,83.35757;Inherit;False;45;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;43;280.4024,69.27437;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;49;-345.9478,-21.39167;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;94;215.6379,-216.0587;Inherit;True;Property;_Logo_Attach;Logo_Attach;8;0;Create;True;0;0;0;False;0;False;-1;None;8dddf0077d5e5ce4ba059e7430a825b9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;95;530.9091,29.40036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;6;-2775.31,-510.9242;Inherit;False;1072.603;295.3278;matCap;6;8;7;4;3;2;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;66.95712,-315.9726;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;55;-720.3303,1308.626;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;1;-2652.618,-450.0976;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-62.19451,1383.437;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;84;-242.1946,1307.437;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;54;-967.0223,1411.935;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;44;693.2177,26.09187;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-2736.618,-370.0976;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;7;-2194.119,-428.9795;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;4;-2374.618,-434.0976;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1912.879,-424.8277;Inherit;False;matCap_node;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;82;124.4637,1383.564;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-467.1946,1533.438;Inherit;False;Property;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;0;1.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2533.618,-431.0976;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;93;613.1416,-256.8265;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-275.1946,1529.438;Inherit;False;Property;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;3.67;75.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;78;-479.5548,1308.846;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;53;-937.5272,1257.621;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;970.3735,-365.6298;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;k23_beer_out;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;12;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;14;0;13;0
WireConnection;32;0;29;0
WireConnection;32;1;30;0
WireConnection;16;0;14;0
WireConnection;16;1;11;0
WireConnection;33;0;32;0
WireConnection;33;1;96;0
WireConnection;33;2;97;0
WireConnection;17;0;16;0
WireConnection;20;0;17;1
WireConnection;34;0;33;0
WireConnection;19;0;20;0
WireConnection;19;1;17;0
WireConnection;62;0;34;0
WireConnection;62;1;88;4
WireConnection;89;0;62;0
WireConnection;21;0;19;0
WireConnection;45;0;89;0
WireConnection;23;0;21;0
WireConnection;37;0;26;0
WireConnection;37;1;47;0
WireConnection;90;0;37;0
WireConnection;90;1;91;0
WireConnection;25;1;90;0
WireConnection;41;1;39;0
WireConnection;43;0;41;1
WireConnection;43;1;52;0
WireConnection;49;0;51;0
WireConnection;49;1;25;0
WireConnection;49;2;50;0
WireConnection;95;0;94;4
WireConnection;95;1;43;0
WireConnection;40;0;41;0
WireConnection;40;1;49;0
WireConnection;55;0;53;2
WireConnection;55;1;54;2
WireConnection;86;0;84;0
WireConnection;86;1;87;0
WireConnection;84;0;78;0
WireConnection;84;1;85;0
WireConnection;44;0;95;0
WireConnection;7;0;4;0
WireConnection;4;0;3;0
WireConnection;8;0;7;0
WireConnection;82;0;86;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;93;0;40;0
WireConnection;93;1;94;0
WireConnection;93;2;94;4
WireConnection;78;0;55;0
WireConnection;0;2;93;0
WireConnection;0;9;44;0
ASEEND*/
//CHKSM=8267C8273B041828666E2946FDD31A318368E628