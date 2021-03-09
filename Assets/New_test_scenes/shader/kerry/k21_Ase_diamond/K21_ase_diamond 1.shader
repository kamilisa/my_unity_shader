// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "K21_ase_diamond"
{
	Properties
	{
		_Color_A("Color_A", Color) = (0,0,0,0)
		_refract_map("refract_map", CUBE) = "white" {}
		_reflect_map("reflect_map", CUBE) = "white" {}
		_refractIntensity("refractIntensity", Float) = 0
		_fresnel_pow("fresnel_pow", Float) = 0
		_fresnel_scale("fresnel_scale", Float) = 1

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
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color_A;
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
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 temp_output_11_0 = reflect( -ase_worldViewDir , ase_worldNormal );
				float4 temp_output_5_0 = ( _Color_A * texCUBE( _refract_map, temp_output_11_0 ) * texCUBE( _reflect_map, temp_output_11_0 ) * _refractIntensity );
				
				
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
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color_A;
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
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
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
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 temp_output_11_0 = reflect( -ase_worldViewDir , ase_worldNormal );
				float4 temp_output_5_0 = ( _Color_A * texCUBE( _refract_map, temp_output_11_0 ) * texCUBE( _reflect_map, temp_output_11_0 ) * _refractIntensity );
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
-70;185;1920;1001;942.9561;262.5064;1;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;16;-966.3974,285.5683;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;15;-990.8072,130.214;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;-1254.208,-449.6918;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;25;-773.1989,217.0251;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-1100.73,-450.9988;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;10;-1251.759,-295.3077;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;29;-531.9561,216.4936;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-389.1023,447.7625;Inherit;False;Property;_fresnel_pow;fresnel_pow;4;0;Create;True;0;0;0;False;0;False;0;2.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-344.1992,211.0251;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;11;-940.9018,-387.466;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;3;-528.3995,-663.3;Inherit;False;Property;_Color_A;Color_A;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;28;-126.8635,209.7482;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-619.2997,-276.3001;Inherit;True;Property;_reflect_map;reflect_map;2;0;Create;True;0;0;0;False;0;False;-1;None;e91e80dab3cd5ef4cbba81f26c4c0da8;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-536.6837,-56.92142;Inherit;False;Property;_refractIntensity;refractIntensity;3;0;Create;True;0;0;0;False;0;False;0;2.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-78.10229,459.7626;Inherit;False;Property;_fresnel_scale;fresnel_scale;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-614.6998,-478.5999;Inherit;True;Property;_refract_map;refract_map;1;0;Create;True;0;0;0;False;0;False;-1;None;ed20f5d52105f5a4aaaa110c740ec079;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-176.9001,-434.1996;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;140.0439,240.4936;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;340.9962,-108.385;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;571.2104,-186.6407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;400.3899,-387.4711;Float;False;True;-1;2;ASEMaterialInspector;100;9;K21_ase_diamond;810d7bf25aae99a47989486486425258;True;Unlit;0;0;Unlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;True;0;False;-1;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;853.6407,-189.3432;Float;False;False;-1;2;ASEMaterialInspector;100;9;New Amplify Shader;810d7bf25aae99a47989486486425258;True;double;0;1;double;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-1;True;0;False;-1;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;0;False;0
WireConnection;25;0;15;0
WireConnection;25;1;16;0
WireConnection;12;0;8;0
WireConnection;29;0;25;0
WireConnection;27;0;29;0
WireConnection;11;0;12;0
WireConnection;11;1;10;0
WireConnection;28;0;27;0
WireConnection;28;1;21;0
WireConnection;7;1;11;0
WireConnection;6;1;11;0
WireConnection;5;0;3;0
WireConnection;5;1;6;0
WireConnection;5;2;7;0
WireConnection;5;3;13;0
WireConnection;30;0;28;0
WireConnection;30;1;20;0
WireConnection;18;0;5;0
WireConnection;18;1;30;0
WireConnection;22;0;5;0
WireConnection;22;1;18;0
WireConnection;1;0;5;0
WireConnection;2;0;22;0
ASEEND*/
//CHKSM=39D61D655521870F8A2ADC4C517DA167F5FCB721