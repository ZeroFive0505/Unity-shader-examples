Shader "Custom/BasicLambert"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		CGPROGRAM
		#pragma surface surf BasicLambert
		
		half4 LightingBasicLambert(SurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = dot(lightDir, s.Normal);
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
			c.a = s.Alpha;
			return c;
		}

		float4 _Color;

		struct Input
		{
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = _Color.rgb;
		}

		ENDCG
	}
    FallBack "Diffuse"
}
