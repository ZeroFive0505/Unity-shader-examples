Shader "Holistic/RimLighting"
{
	Properties
	{
		_RimColor("Rim Color", Color) = (0, 0.5, 0.5, 0.0)
		_RimPower("Rim Power", Range(0.5, 8.0)) = 3.0
	}

	SubShader
	{
		CGPROGRAM
		#pragma surface surf Lambert

		float4 _RimColor;
		half _RimPower;

		struct Input
		{
			float3 viewDir;
			float3 worldPos;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			half rim = 1 - saturate( dot(normalize(IN.viewDir), o.Normal) );
			//o.Emission = _RimColor.rgb * pow(rim, _RimPower);
			//o.Emission = _RimColor.rgb * rim > 0.5 ? rim : 0;
			//o.Emission = rim > 0.8 ? float3(0, 0.5, 0.5) : rim > 0.5 ? float3(0, 0, 0.5) : 0;
			//o.Emission = IN.worldPos.y > 1 ? float3(0, 1, 0) : float3(0, 0, 1);
			o.Emission = frac(IN.worldPos.y * 10 * 0.5) > 0.4 ? float3(0, 1, 0) * rim : float3(0, 0, 1) * rim;
		}
		ENDCG
	}
    
    FallBack "Diffuse"
}
