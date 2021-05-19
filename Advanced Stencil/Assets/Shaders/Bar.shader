Shader "Custom/Bar"
{
    Properties
    {
	   _MainTex("Texture", 2D) = "white" {}
	   _NormalTex("Normal Map", 2D) = "white" {}
	   _SpecColor("Specular Color", Color) = (1, 1, 1, 1)
	   _Gloss("Gloss", Range(0.0, 10.0)) = 1.0
	   _Spec("Specular", Range(0.0, 10.0)) = 1.0
	}

	SubShader
	{
		 CGPROGRAM
		 #pragma surface surf BlinnPhong

		 sampler2D _MainTex;
	   sampler2D _NormalTex;
	   half _Gloss;
	   half _Spec;

	   struct Input
	   {
		   float2 uv_MainTex;
		   float2 uv_NormalTex;
	   };

	   void surf(Input IN, inout SurfaceOutput o)
	   {
		   o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		   o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
		   o.Gloss = _Gloss;
		   o.Specular = _Spec;
	   }


        ENDCG
    }
    FallBack "Diffuse"
}
