Shader "Custom/MyShader"
{
    Properties
	{
	   _MainTex("Texture", 2D) = "white" {}
	   _NormalTex("Normal", 2D) = "white" {}
	   _Bumpness("Bumpness", Range(0.5, 5.0)) = 1
	}
		SubShader
	{
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		sampler2D _NormalTex;
		half _Bumpness;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_NormalTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			o.Normal *= float3(_Bumpness, _Bumpness, 1);
		}
		ENDCG
	}

	Fallback "Diffuse"
}
