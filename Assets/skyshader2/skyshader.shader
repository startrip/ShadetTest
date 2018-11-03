// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "skyshader"
{
	Properties
	{
		_skayscale("skayscale", Range( 10 , 500)) = 100
		_uppercolor("uppercolor", Color) = (0.745283,0.2214756,0.2214756,0)
		_lowercolor("lowercolor", Color) = (0,0,0,0)
		_cloud1("cloud1", 2D) = "black" {}
		_speed1("speed1", Vector) = (0.5,0,0,0)
		_cloud2("cloud2", 2D) = "black" {}
		_speed2("speed2", Vector) = (0.5,0,0,0)
		_cloudcol("cloudcol", Color) = (1,1,1,0)
		_cloudshade("cloudshade", Color) = (0.3584906,0.3584906,0.3584906,0)
		_cloulight("cloulight", Color) = (1,1,1,0)
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
			
			uniform float4 _lowercolor;
			uniform float4 _uppercolor;
			uniform float _skayscale;
			uniform float4 _cloudcol;
			uniform sampler2D _cloud1;
			uniform float2 _speed1;
			uniform float4 _cloudshade;
			uniform float4 _cloulight;
			uniform sampler2D _cloud2;
			uniform float2 _speed2;
					
			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
				o.ase_texcoord = v.vertex;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord1.zw = v.ase_texcoord1.xy;
				v.vertex.xyz +=  float3( 0, 0, 0 ) ;
		        o.position = TransformObjectToHClip(v.vertex.xyz);
		        return o;
			}
		
		    half4 frag (GraphVertexOutput IN) : SV_Target
		    {
		        UNITY_SETUP_INSTANCE_ID(IN);
				float clampResult67 = clamp( (-1.0 + (IN.ase_texcoord.xyz.y - 0.0) * (1.0 - -1.0) / (_skayscale - 0.0)) , 0.0 , 1.0 );
				float4 lerpResult16 = lerp( _lowercolor , _uppercolor , clampResult67);
				float2 uv81 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner80 = ( 1.0 * _Time.y * _speed1 + uv81);
				float4 tex2DNode71 = tex2D( _cloud1, panner80 );
				float4 temp_cast_0 = (tex2DNode71.g).xxxx;
				float4 blendOpSrc119 = temp_cast_0;
				float4 blendOpDest119 = _cloudshade;
				float4 lerpResult78 = lerp( lerpResult16 , ( ( _cloudcol * ( saturate( max( blendOpSrc119, blendOpDest119 ) )) ) + ( tex2DNode71.b * _cloulight ) ) , tex2DNode71.r);
				float2 uv84 = IN.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * _speed2 + uv84);
				float4 tex2DNode94 = tex2D( _cloud2, panner86 );
				float4 temp_cast_1 = (tex2DNode94.g).xxxx;
				float4 blendOpSrc121 = temp_cast_1;
				float4 blendOpDest121 = _cloudshade;
				float4 lerpResult110 = lerp( lerpResult78 , ( ( _cloudcol * ( saturate( max( blendOpSrc121, blendOpDest121 ) )) ) + ( tex2DNode94.b * _cloulight ) ) , tex2DNode94.r);
				
		        float3 Color = lerpResult110.rgb;
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
1976;56;1857;1075;2487.083;1490.322;2.927165;True;True
Node;AmplifyShaderEditor.Vector2Node;79;-1409.961,139.042;Float;False;Property;_speed1;speed1;4;0;Create;True;0;0;False;0;0.5,0;0.5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-1625.337,-55.35109;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-1387.508,854.2134;Float;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;85;-1277.131,1003.606;Float;False;Property;_speed2;speed2;6;0;Create;True;0;0;False;0;0.5,0;0.5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;80;-1171.22,-147.3211;Float;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-657.96,-749.864;Float;False;Property;_skayscale;skayscale;0;0;Create;True;0;0;False;0;100;1;10;500;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;-838.6907,462.3623;Float;False;Property;_cloudshade;cloudshade;8;0;Create;True;0;0;False;0;0.3584906,0.3584906,0.3584906,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;71;-811.7761,-243.488;Float;True;Property;_cloud1;cloud1;3;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;86;-974.5955,962.4136;Float;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;61;-414.952,-493.6663;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;51;-835.8422,151.6429;Float;False;Property;_cloudcol;cloudcol;7;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;62;3.470174,-569.44;Float;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;400;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;94;-689.1838,803.1978;Float;True;Property;_cloud2;cloud2;5;0;Create;True;0;0;False;0;None;None;True;1;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;75;-252.851,300.6582;Float;False;Property;_cloulight;cloulight;9;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;119;-133.7859,-157.0322;Float;False;Lighten;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;56.52153,-810.6933;Float;False;Property;_lowercolor;lowercolor;2;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;67;347.5108,-454.7552;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-316.0877,-860.806;Float;False;Property;_uppercolor;uppercolor;1;0;Create;True;0;0;False;0;0.745283,0.2214756,0.2214756,0;0.745283,0.2214756,0.2214756,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;223.771,-71.36243;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;175.7406,110.966;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;121;-219.0902,533.5391;Float;False;Lighten;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;520.4722,30.87842;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;312.2706,494.8115;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;317.9835,894.9766;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;559.0895,-651.2447;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;78;871.0788,-438.9609;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;588.4173,555.756;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;110;1115.808,-140.8895;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;120;-147.3502,799.014;Float;False;Screen;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;100;355.1918,278.8827;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;93;117.6529,675.4346;Float;False;False;2;Float;ASEMaterialInspector;0;2;ASETemplateShaders/LightWeightSRPUnlit;e2514bdcf5e5399499a9eb24d175b9db;0;1;DepthOnly;0;False;False;False;False;False;False;False;False;True;3;RenderType=Opaque;Queue=Geometry;RenderPipeline=LightweightPipeline;True;2;0;0;0;False;False;True;0;False;-1;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;2;Float;ASEMaterialInspector;0;2;ASETemplateShaders/LightWeightSRPUnlit;e2514bdcf5e5399499a9eb24d175b9db;0;1;DepthOnly;0;False;False;False;False;False;False;False;False;True;3;RenderType=Opaque;Queue=Geometry;RenderPipeline=LightweightPipeline;True;2;0;0;0;False;False;True;0;False;-1;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;0;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1416.656,-269.2813;Float;False;True;2;Float;ASEMaterialInspector;0;2;skyshader;e2514bdcf5e5399499a9eb24d175b9db;0;0;Base;4;False;False;False;False;False;False;False;False;True;3;RenderType=Opaque;Queue=Geometry;RenderPipeline=LightweightPipeline;True;2;0;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;0;0;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;0
WireConnection;80;0;81;0
WireConnection;80;2;79;0
WireConnection;71;1;80;0
WireConnection;86;0;84;0
WireConnection;86;2;85;0
WireConnection;62;0;61;2
WireConnection;62;2;69;0
WireConnection;94;1;86;0
WireConnection;119;0;71;2
WireConnection;119;1;73;0
WireConnection;67;0;62;0
WireConnection;106;0;51;0
WireConnection;106;1;119;0
WireConnection;77;0;71;3
WireConnection;77;1;75;0
WireConnection;121;0;94;2
WireConnection;121;1;73;0
WireConnection;74;0;106;0
WireConnection;74;1;77;0
WireConnection;108;0;51;0
WireConnection;108;1;121;0
WireConnection;91;0;94;3
WireConnection;91;1;75;0
WireConnection;16;0;13;0
WireConnection;16;1;12;0
WireConnection;16;2;67;0
WireConnection;78;0;16;0
WireConnection;78;1;74;0
WireConnection;78;2;71;1
WireConnection;95;0;108;0
WireConnection;95;1;91;0
WireConnection;110;0;78;0
WireConnection;110;1;95;0
WireConnection;110;2;94;1
WireConnection;0;0;110;0
ASEEND*/
//CHKSM=A57FBBD00CE1F0879FABF65DA754807F61856251