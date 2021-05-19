Shader "Unlit/PlasmaVF"
{
    Properties
    {
        _Tint("Tint Color", Color) = (1, 1, 1, 1)
		_Speed("Speed", Range(1, 100)) = 1
		_Scale1("Scale 1", Range(0.1, 10)) = 1
		_Scale2("Scale 2", Range(0.1, 10)) = 1
		_Scale3("Scale 3", Range(0.1, 10)) = 1
		_Scale4("Scale 4", Range(0.1, 10)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float4 color : COLOR0;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 color : COLOR0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Tint;
			float _Speed;
			float _Scale1;
			float _Scale2;
			float _Scale3;
			float _Scale4;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = (1, 1, 1, 1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				const float PI = 3.14159265;
				
				float t = _Time.x * _Speed;

				float xpos = i.vertex.x / 500;
				float ypos = i.vertex.y / 500;
				
				//Vertical
				float c = sin(xpos * _Scale1 + t);

				//Horizontal
				c += sin(ypos * _Scale2 + t);

				//Diagonal
				c += sin(_Scale3 * (xpos * sin(t / 2.0) + ypos * cos(t / 3.0)) + t);


				//Circular
				float c1 = pow(xpos + 0.5 * sin(t / 5.0), 2);
				float c2 = pow(ypos + 0.5 * cos(t / 3.0), 2);

				c += sin(sqrt(_Scale4 * (c1 + c2) + 1 + t));

                // sample the texture
				fixed4 col;
				col.r = sin(c / 4.0 * PI);
				col.g = sin(c / 4.0 * PI + 2.0 * PI / 4);
				col.b = sin(c / 4.0 * PI + 4.0 * PI / 4);
				return col;
            }
            ENDCG
        }
    }
}
