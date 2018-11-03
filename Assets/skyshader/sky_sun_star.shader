// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "sky_sun_star"
{
	Properties
	{
		_Color0("Color 0", Color) = (0.745283,0.2214756,0.2214756,0)
		_Color1("Color 1", Color) = (0,0,0,0)
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "black" {}
		_speed2("speed2", Float) = 0.1
		_speed("speed", Float) = 0.1
		_size1("size1", Float) = 1
		_size2("size2", Float) = 1
		_cloudcol("cloudcol", Color) = (0,0,0,0)
		_starcolor("starcolor", Color) = (0.509434,0.509434,0.509434,0)
		_suncol("suncol", Color) = (0.509434,0.509434,0.509434,0)
		_suntex("suntex", 2D) = "black" {}
		_startex("startex", 2D) = "black" {}
		_sunbrightness("sunbrightness", Range( 0 , 3)) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="LightweightPipeline" }
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		Pass
		{
			Tags { "LightMode"="LightweightForward" }
			Name "Base"
			
			Blend One Zero
			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		    #pragma exclude_renderers d3d11_9x
		
		    #pragma vertex vert
		    #pragma fragment frag
		
			

		    // Lighting include is needed because of GI
		    #include "LWRP/ShaderLibrary/Core.hlsl"
		    #include "LWRP/ShaderLibrary/Lighting.hlsl"
		    #include "CoreRP/ShaderLibrary/Color.hlsl"
		    #include "LWRP/ShaderLibrary/InputSurfaceUnlit.hlsl"
		    #include "ShaderGraphLibrary/Functions.hlsl"
			
			uniform sampler2D _startex;
			uniform float4 _startex_ST;
			uniform float4 _starcolor;
			uniform float4 _Color1;
			uniform float4 _Color0;
			uniform sampler2D _TextureSample0;
			uniform float _speed;
			uniform float _size1;
			uniform sampler2D _TextureSample1;
			uniform float _speed2;
			uniform float _size2;
			uniform float4 _cloudcol;
			uniform sampler2D _suntex;
			uniform float4 _suntex_ST;
			uniform float4 _suncol;
			uniform float _sunbrightness;
					
			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
	
		    struct GraphVertexOutput
		    {
		        float4 position : POSITION;
		        UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
		    };
		
		    GraphVertexOutput vert (GraphVertexInput v )
			{
		        GraphVertexOutput o = (GraphVertexOutput)0;
		        UNITY_SETUP_INSTANCE_ID(v);
		        UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				v.vertex.xyz +=  float3( 0, 0, 0 ) ;
		        o.position = TransformObjectToHClip(v.vertex.xyz);
		        return o;
			}
		
		    half4 frag (GraphVertexOutput IN) : SV_Target
		    {
		        UNITY_SETUP_INSTANCE_ID(IN);
				float2 uv_startex = IN.ase_texcoord.xy * _startex_ST.xy + _startex_ST.zw;
				float4 lerpResult16 = lerp( _Color1 , _Color0 , IN.ase_texcoord1.xyz.y);
				float mulTime36 = _Time.y * _speed;
				float2 uv40 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float mulTime45 = _Time.y * _speed2;
				float2 uv42 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 blendOpSrc30 = tex2D( _TextureSample0, ( mulTime36 + ( uv40 * _size1 ) ) );
				float4 blendOpDest30 = tex2D( _TextureSample1, ( mulTime45 + ( uv42 * _size2 ) ) );
				float2 uv_suntex = IN.ase_texcoord.xy * _suntex_ST.xy + _suntex_ST.zw;
				
		        float3 Color = ( ( tex2D( _startex, uv_startex ) * _starcolor ) + lerpResult16 + ( ( saturate( 	max( blendOpSrc30, blendOpDest30 ) )) * _cloudcol ) + ( tex2D( _suntex, uv_suntex ) * _suncol * _sunbrightness ) ).rgb;
		        float Alpha = 1;
		        float AlphaClipThreshold = 0;
		#if _AlphaClip
		        clip(Alpha - AlphaClipThreshold);
		#endif
		    	return half4(Color, Alpha);
		    }
		    ENDHLSL
		}
		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			Cull Back

			HLSLPROGRAM
			#pragma prefer_hlslcc gles
    
			#pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment frag

			#include "LWRP/ShaderLibrary/Core.hlsl"
			
			
			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct GraphVertexOutput
			{
				float4 clipPos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			GraphVertexOutput vert (GraphVertexInput v)
			{
				GraphVertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				

				v.vertex.xyz +=  float3(0,0,0) ;
				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag (GraphVertexOutput IN ) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);

				

				float Alpha = 1;
				float AlphaClipThreshold = AlphaClipThreshold;
				
				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif
				return Alpha;
				return 0;
		    }
			ENDHLSL
		}
	}
	
	FallBack "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=15305
1976;106;1857;1025;963.7284;1196.98;1.684834;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-38.16504,858.0441;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;49.56292,1012.123;Float;False;Property;_size2;size2;7;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;255.502,779.0404;Float;False;Property;_speed2;speed2;4;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-513.3721,436.4181;Float;False;Property;_size1;size1;6;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-428.6089,804.12;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;34;-308.8688,203.3352;Float;False;Property;_speed;speed;5;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;45;488.8535,759.5817;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;290.1359,905.5297;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-274.2349,329.8245;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;-75.5173,183.8765;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;482.9981,965.7558;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-81.37268,390.0505;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;47;671.6088,777.5119;Float;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;32;127.3592,371.9382;Float;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;18;-638.7778,74.53238;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;51;239.3667,-24.6991;Float;False;Property;_cloudcol;cloudcol;8;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;12;-700.5,-167.5;Float;False;Property;_Color0;Color 0;0;0;Create;True;0;0;False;0;0.745283,0.2214756,0.2214756,0;0.745283,0.2214756,0.2214756,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;54;-462.9276,-892.4865;Float;True;Property;_startex;startex;12;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;30;808.6976,181.9926;Float;False;Lighten;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-590.5,-459.5;Float;False;Property;_Color1;Color 1;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-237.8276,-631.4866;Float;False;Property;_starcolor;starcolor;9;0;Create;True;0;0;False;0;0.509434,0.509434,0.509434,0;0.509434,0.509434,0.509434,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;135.9775,-545.946;Float;False;Property;_sunbrightness;sunbrightness;13;0;Create;True;0;0;False;0;2;2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;36.2515,-1038.744;Float;True;Property;_suntex;suntex;11;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;56;286.0515,-792.9439;Float;False;Property;_suncol;suncol;10;0;Create;True;0;0;False;0;0.509434,0.509434,0.509434,0;0.509434,0.509434,0.509434,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;16;-83.5,-349.5;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;470.6991,-65.48692;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;629.9515,-823.5439;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;58.67239,-713.2866;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;672.6801,-399.6125;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;29;-188.5665,-38.28521;Float;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;998.0482,-111.7523;Float;False;True;2;Float;ASEMaterialInspector;0;2;sky_sun_star;e2514bdcf5e5399499a9eb24d175b9db;0;0;Base;4;False;False;False;False;False;False;False;False;True;3;RenderType=Opaque;Queue=Geometry;RenderPipeline=LightweightPipeline;True;2;0;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;0;0;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;2;Float;ASEMaterialInspector;0;2;ASETemplateShaders/LightWeightSRPUnlit;e2514bdcf5e5399499a9eb24d175b9db;0;1;DepthOnly;0;False;False;False;False;False;False;False;False;True;3;RenderType=Opaque;Queue=Geometry;RenderPipeline=LightweightPipeline;True;2;0;0;0;False;False;True;0;False;-1;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
WireConnection;45;0;43;0
WireConnection;44;0;42;0
WireConnection;44;1;41;0
WireConnection;37;0;40;0
WireConnection;37;1;35;0
WireConnection;36;0;34;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;47;1;46;0
WireConnection;32;1;38;0
WireConnection;30;0;32;0
WireConnection;30;1;47;0
WireConnection;16;0;13;0
WireConnection;16;1;12;0
WireConnection;16;2;18;2
WireConnection;50;0;30;0
WireConnection;50;1;51;0
WireConnection;55;0;57;0
WireConnection;55;1;56;0
WireConnection;55;2;60;0
WireConnection;52;0;54;0
WireConnection;52;1;53;0
WireConnection;48;0;52;0
WireConnection;48;1;16;0
WireConnection;48;2;50;0
WireConnection;48;3;55;0
WireConnection;29;0;18;2
WireConnection;0;0;48;0
ASEEND*/
//CHKSM=D666DE9A9A4C86D51296D97E98A0D3DFD651BA30