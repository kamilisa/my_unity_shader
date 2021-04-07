// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "K19_ase_fire"
{
	Properties
	{
		_Noise_Tex("Noise_Tex", 2D) = "white" {}
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		_Speed("Speed", Vector) = (0,0,0,0)
		_fallof("fallof", Range( 0 , 1)) = 0
		_SecondFire_Color_offset("SecondFire_Color_offset", Float) = 0
		_mask("mask", 2D) = "white" {}
		_Float1("Float 1", Float) = 0.03
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _MainColor;
		uniform float _SecondFire_Color_offset;
		uniform sampler2D _Noise_Tex;
		uniform float2 _Speed;
		uniform float4 _Noise_Tex_ST;
		uniform float _fallof;
		uniform sampler2D _mask;
		uniform float4 _mask_ST;
		uniform float _Float1;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break47 = _MainColor;
			float reverse_Alpha42 = ( 1.0 - i.uv_texcoord.y );
			float2 uv_Noise_Tex = i.uv_texcoord * _Noise_Tex_ST.xy + _Noise_Tex_ST.zw;
			float2 panner15 = ( 1.0 * _Time.y * _Speed + uv_Noise_Tex);
			float4 tex2DNode6 = tex2D( _Noise_Tex, panner15 );
			float MainAlpha33 = i.uv_texcoord.y;
			float smoothstepResult19 = smoothstep( tex2DNode6.r , ( tex2DNode6.r - _fallof ) , MainAlpha33);
			float UV_flow39 = smoothstepResult19;
			float4 appendResult48 = (float4(break47.r , ( ( break47.g + _SecondFire_Color_offset ) * reverse_Alpha42 * UV_flow39 ) , break47.b , break47.a));
			o.Emission = appendResult48.xyz;
			float2 uv_mask = i.uv_texcoord * _mask_ST.xy + _mask_ST.zw;
			o.Alpha = ( tex2D( _mask, ( uv_mask + ( UV_flow39 * _Float1 ) ) ).a * UV_flow39 * MainAlpha33 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

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
Version=18800
-61;358;1920;1533;1399.453;940.1284;1.064525;True;False
Node;AmplifyShaderEditor.CommentaryNode;43;-1649.181,-542.576;Inherit;False;998.1811;419.0417;Comment;5;3;9;33;26;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;40;-2052.379,-47.97696;Inherit;False;1544.094;377.5093;Comment;9;14;18;15;6;22;34;21;19;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1599.181,-424.6313;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-2002.379,29.5762;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;18;-1961.604,165.5324;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;0;False;0;False;0,0;0,-0.66;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;15;-1730.05,34.38992;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;9;-1345.639,-378.214;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1532.9,2.023041;Inherit;True;Property;_Noise_Tex;Noise_Tex;0;0;Create;True;0;0;0;False;0;False;-1;829bcf8eb3a7e0442b3e948797317efc;829bcf8eb3a7e0442b3e948797317efc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-1503.737,206.9037;Inherit;False;Property;_fallof;fallof;3;0;Create;True;0;0;0;False;0;False;0;0.6705883;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1115.295,-239.5344;Inherit;False;MainAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-1187.933,10.80028;Inherit;False;33;MainAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-1166.753,115.2763;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;-1002.37,63.42331;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-732.2855,93.6606;Inherit;False;UV_flow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-385.0673,44.55068;Inherit;False;Property;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;0.03;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-1093.788,-486.5672;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-423.6011,-164.8502;Inherit;True;39;UV_flow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-443.4042,-876.5036;Inherit;False;Property;_MainColor;MainColor;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;102.7558,32.27929,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-277.8802,-601.0983;Inherit;False;Property;_SecondFire_Color_offset;SecondFire_Color_offset;4;0;Create;True;0;0;0;False;0;False;0;35.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;47;-182.5384,-862.6466;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-217.5361,-102.4957;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-874.9998,-492.576;Inherit;False;reverse_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-428.8796,-295.0951;Inherit;False;0;54;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-127.5299,-272.593;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;12.18816,-531.5865;Inherit;False;42;reverse_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;86.24774,-643.6516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;35.82182,-443.4689;Inherit;False;39;UV_flow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;102.6584,89.64359;Inherit;True;33;MainAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;85.59477,-318.179;Inherit;True;Property;_mask;mask;5;0;Create;True;0;0;0;False;0;False;-1;b3b9066b79d8ad64db46b657e2295860;b3b9066b79d8ad64db46b657e2295860;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;41;102.8707,-120.6127;Inherit;True;39;UV_flow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;242.5108,-627.601;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;479.8182,-184.8776;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;473.7118,-861.5582;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;796.2856,-555.8005;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;K19_ase_fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;14;0
WireConnection;15;2;18;0
WireConnection;9;0;3;2
WireConnection;6;1;15;0
WireConnection;33;0;9;0
WireConnection;21;0;6;1
WireConnection;21;1;22;0
WireConnection;19;0;34;0
WireConnection;19;1;6;1
WireConnection;19;2;21;0
WireConnection;39;0;19;0
WireConnection;26;0;9;0
WireConnection;47;0;11;0
WireConnection;71;0;70;0
WireConnection;71;1;72;0
WireConnection;42;0;26;0
WireConnection;63;0;61;0
WireConnection;63;1;71;0
WireConnection;50;0;47;1
WireConnection;50;1;49;0
WireConnection;54;1;63;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;51;2;53;0
WireConnection;60;0;54;4
WireConnection;60;1;41;0
WireConnection;60;2;73;0
WireConnection;48;0;47;0
WireConnection;48;1;51;0
WireConnection;48;2;47;2
WireConnection;48;3;47;3
WireConnection;2;2;48;0
WireConnection;2;9;60;0
ASEEND*/
//CHKSM=A8BFA6B5A94E5F850126A3F63666C51F2933C439