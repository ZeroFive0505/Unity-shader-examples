Shader "Custom/ToonDiffuse"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_ToonRamp("Toon Ramp", 2D) = "white" {}

		_SRef("Stencil Ref", Float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _SComp("Stencil Comp", Float) = 8
		[Enum(UnityEngine.Rendering.StencilOp)] _SOp("Stencil Op", Float) = 2
	}
		SubShader
	{

		Stencil
		{
			Ref[_SRef]
			Comp[_SComp]
			Pass[_SOp]
		}

		CGPROGRAM
		#pragma surface surf ToonDiffuse

		sampler2D _MainTex;
		sampler2D _ToonRamp;

		struct Input
		{
			float2 uv_MainTex;
		};

		float4 LightingToonDiffuse(SurfaceOutput s, float3 lightDir, float atten)
		{
			float diff = dot(s.Normal, lightDir);
			float h = diff * 0.5 + 0.5;
			float2 nh = h;
			
			float3 ramp = tex2D(_ToonRamp, nh).rgb;

			float4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			c.a = s.Alpha;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		}

        ENDCG
    }
    FallBack "Diffuse"
}
