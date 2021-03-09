// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "K21_ase_gem"
{
	Properties
	{
		_Color_A("Color_A", Color) = (0,0,0,0)
		_refract_map("refract_map", CUBE) = "white" {}
		_reflect_map("reflect_map", CUBE) = "white" {}
		_refractIntensity("refractIntensity", Float) = 0
		_fresnel_pow("fresnel_pow", Float) = 0
		_fresnel_scale("fresnel_scale", Float) = 1
		_ramp_tex("ramp_tex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
	LOD 100

		
		Pass
		{
			Name "Unlit"
			Blend Off
			ZWrite On
			ZTest LEqual
			Cull Front
			// Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color_A;
			uniform sampler2D _ramp_tex;
			uniform float4 _ramp_tex_ST;
			uniform samplerCUBE _refract_map;
			uniform samplerCUBE _reflect_map;
			uniform float _refractIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_ramp_tex = i.ase_texcoord1.xyz.xy * _ramp_tex_ST.xy + _ramp_tex_ST.zw;
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 worldRefl31 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, ase_worldNormal ), dot( tanToWorld1, ase_worldNormal ), dot( tanToWorld2, ase_worldNormal ) ) );
				float4 temp_output_5_0 = ( ( _Color_A * tex2D( _ramp_tex, uv_ramp_tex ) ) * texCUBE( _refract_map, worldRefl31 ) * texCUBE( _reflect_map, worldRefl31 ) * _refractIntensity );
				
				
				finalColor = temp_output_5_0;
				return finalColor;
			}
			ENDCG
		}

		
		Pass
		{
			Name "double"
			Blend One One
			ZWrite On
			ZTest LEqual
			Cull Back

			// Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color_A;
			uniform sampler2D _ramp_tex;
			uniform float4 _ramp_tex_ST;
			uniform samplerCUBE _refract_map;
			uniform samplerCUBE _reflect_map;
			uniform float _refractIntensity;
			uniform float _fresnel_pow;
			uniform float _fresnel_scale;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_ramp_tex = i.ase_texcoord1.xyz.xy * _ramp_tex_ST.xy + _ramp_tex_ST.zw;
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 worldRefl31 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, ase_worldNormal ), dot( tanToWorld1, ase_worldNormal ), dot( tanToWorld2, ase_worldNormal ) ) );
				float4 temp_output_5_0 = ( ( _Color_A * tex2D( _ramp_tex, uv_ramp_tex ) ) * texCUBE( _refract_map, worldRefl31 ) * texCUBE( _reflect_map, worldRefl31 ) * _refractIntensity );
				float dotResult25 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult29 = clamp( dotResult25 , 0.0 , 1.0 );
				float saferPower28 = max( ( 1.0 - clampResult29 ) , 0.0001 );
				
				
				finalColor = ( temp_output_5_0 + ( temp_output_5_0 * ( pow( saferPower28 , _fresnel_pow ) * _fresnel_scale ) ) );
				return finalColor;
			}
			ENDCG
		}
		
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
63;60;1920;983;2030.381;879.9072;1.786386;True;False
Node;AmplifyShaderEditor.CommentaryNode;36;-1156.922,19.47692;Inherit;False;1919.692;495.5485;B_pass_cull_back;11;18;16;15;25;29;27;21;28;20;30;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;15;-1106.922,69.47695;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;16;-1082.513,224.8313;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;35;-1230.946,-1078.981;Inherit;False;1383.161;1043.729;A_pass_cull_front;9;32;31;3;13;34;7;33;6;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;25;-889.3147,156.2879;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;32;-1180.946,-445.9047;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;29;-648.0719,155.7565;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;31;-898.6161,-438.7056;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;3;-489.8194,-1028.982;Inherit;False;Property;_Color_A;Color_A;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-505.2185,387.0255;Inherit;False;Property;_fresnel_pow;fresnel_pow;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-460.3151,150.2879;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-577.5684,-817.5367;Inherit;True;Property;_ramp_tex;ramp_tex;6;0;Create;True;0;0;0;False;0;False;-1;None;e5b88b78aca2f93448fc279a33d5e99d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-194.2172,399.0256;Inherit;False;Property;_fresnel_scale;fresnel_scale;5;0;Create;True;0;0;0;False;0;False;1;1.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-242.9786,149.011;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-541.4581,-590.7945;Inherit;True;Property;_refract_map;refract_map;1;0;Create;True;0;0;0;False;0;False;-1;None;ed20f5d52105f5a4aaaa110c740ec079;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-544.2716,-370.6311;Inherit;True;Property;_reflect_map;reflect_map;2;0;Create;True;0;0;0;False;0;False;-1;None;e91e80dab3cd5ef4cbba81f26c4c0da8;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-189.5682,-883.6141;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-461.6556,-151.2524;Inherit;False;Property;_refractIntensity;refractIntensity;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;23.92881,179.7564;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-9.785053,-589.549;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;263.5409,128.4;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;610.7696,104.1586;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;1003.766,-190.8296;Float;False;False;-1;2;ASEMaterialInspector;100;9;New Amplify Shader;810d7bf25aae99a47989486486425258;True;double;0;1;double;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;True;0;False;-1;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;586.1737,-501.8002;Float;False;True;-1;2;ASEMaterialInspector;100;9;K21_ase_gem;810d7bf25aae99a47989486486425258;True;Unlit;0;0;Unlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;True;0;False;-1;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;2;True;True;False;;False;0
WireConnection;25;0;15;0
WireConnection;25;1;16;0
WireConnection;29;0;25;0
WireConnection;31;0;32;0
WireConnection;27;0;29;0
WireConnection;28;0;27;0
WireConnection;28;1;21;0
WireConnection;6;1;31;0
WireConnection;7;1;31;0
WireConnection;34;0;3;0
WireConnection;34;1;33;0
WireConnection;30;0;28;0
WireConnection;30;1;20;0
WireConnection;5;0;34;0
WireConnection;5;1;6;0
WireConnection;5;2;7;0
WireConnection;5;3;13;0
WireConnection;18;0;5;0
WireConnection;18;1;30;0
WireConnection;22;0;5;0
WireConnection;22;1;18;0
WireConnection;2;0;22;0
WireConnection;1;0;5;0
ASEEND*/
//CHKSM=1D0F7A2BD9F9C2BAF379F4A4E20F08C5B137EE4E