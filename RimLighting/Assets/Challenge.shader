Shader "Holistic/Challenge"
{
	Properties
	{
		_myDiffuse("Diffuse Texture", 2D) = "white" {}
		_myStripeSize("Stripe Size", Range(1.0, 5.0)) = 1.0
		_myRimPow("Rim Power", Range(1.0, 10.0)) = 1.0
	}

	SubShader
	{
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _myDiffuse;
		half _myStripeSize;
		half _myRimPow;

		struct Input
		{
			float2 uv_myDiffuse;
			float3 viewDir;
			float3 worldPos;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_myDiffuse, IN.uv_myDiffuse).rgb;
			half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
			rim = pow(rim, _myRimPow);
			o.Emission = frac(IN.worldPos.y * (10.0 - _myStripeSize)* 0.5 ) > 0.4 ? float3(1, 0, 0) * rim : float3(0, 1, 0) * rim;
		}
		ENDCG
	}

	Fallback "Diffuse"
}
