Shader "Custom/ToonShader"
{
    Properties
    {
      _Color("Color", Color) = (1, 1, 1, 1)
	  _RampTex("Ramp Texture", 2D) = "white" {}
	  _MainTex("Diffuse", 2D) = "white" {}
	  _Outline("Outline Width", Range(0.001, 1.0)) = 0.05
	  _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
	}
		SubShader
	{
		CGPROGRAM
		#pragma surface surf ToonRamp


		float4 _Color;
		sampler2D _RampTex;
		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
		};

		float4 LightingToonRamp(SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, half atten)
		{
			float diff = dot(s.Normal, lightDir);
			float h = diff * 0.5 + 0.5;
			float2 rh = h;
			float3 ramp = tex2D(_RampTex, rh).rgb;

			float4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			c.a = s.Alpha;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
		}

        ENDCG


		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
			};

			float _Outline;
			float4 _OutlineColor;

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(norm.xy);

				o.pos.xy += offset * o.pos.z * _Outline;
				o.color = _OutlineColor;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
