Shader "Custom/Wall"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normal Map", 2D) = "white" {}
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1)
		_Spec("Specular", Range(0, 5.0)) = 1.0
		_Gloss("Gloss", Range(0, 5.0)) = 1.0
	}
		SubShader
		{
			Tags{"Queue" = "Geometry"}

		Stencil
		{
			Ref 1
			Comp notequal
			Pass keep
		}

		CGPROGRAM
		#pragma surface surf BlinnPhong

		sampler2D _MainTex;
		sampler2D _NormalTex;
		half _Spec;
		half _Gloss;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_NormalTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Specular = _Spec;
			o.Gloss = _Gloss;
			o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
		}

        ENDCG
    }
    FallBack "Diffuse"
}
