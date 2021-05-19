Shader "Custom/ToonShader"
{
    Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
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
		#pragma surface surf ToonRamp

		float4 _Color;
		sampler2D _ToonRamp;

		struct Input
		{
			float2 uv_MainTex;
		};

		float4 LightingToonRamp(SurfaceOutput s, float3 lightDir, float atten)
		{
			float diff = dot(s.Normal, lightDir);
			
			float h = diff * 0.5 + 0.5;
			float2 rh = h;

			float3 ramp = tex2D(_ToonRamp, rh).rgb;

			float4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			c.a = s.Alpha;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = _Color.rgb;
		}

        ENDCG
    }
    FallBack "Diffuse"
}
