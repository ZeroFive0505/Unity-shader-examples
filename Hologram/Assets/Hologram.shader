Shader "Holistic/Hologram"
{
    Properties
    {
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimPower("Rim Power", Range(1.0, 5.0)) = 1.0
    }
    SubShader
    {
		Tags{"Queue" = "Transparent"}

		Pass
		{
			Zwrite On
			ColorMask 0
			//ColorMask RGB
		}

		CGPROGRAM
		#pragma surface surf Lambert alpha:fade

		struct Input
		{
			float2 uv_MainTex;
			float3 viewDir;
		};

		float4 _RimColor;
		half _RimPower;
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
			o.Emission = _RimColor.rgb * pow(rim, _RimPower) * 10.0;
			o.Alpha = pow(rim, _RimPower);
		}
       
        ENDCG
    }
    FallBack "Diffuse"
}
