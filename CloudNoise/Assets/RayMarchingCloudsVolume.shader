﻿Shader "custom/RayMarchingCloudsVolume"
{
    Properties
    {
        _Scale("Scale", Range(0.1, 10.0)) = 2.0
		_StepScale("Step Scale", Range(0.1, 100.0)) = 1.0
		_Steps("Steps", Range(1, 200)) = 60
		_MinHeight("Min Height", Range(0.0, 5.0)) = 0.0
		_MaxHeight("Max Height", Range(6.0, 10.0)) = 10.0
		_FadeDist("Fade Distance", Range(0.0, 10.0)) = 0.5
		_SunDirection("Sun direction", Vector) = (1, 0, 0, 0)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off
		ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float3 viewDir : TEXCOORD0;
				float4 projPos : TEXCOORD1;
				float3 wPos : TEXCOORD2;
            };

			float _MinHeight;
			float _MaxHeight;
			float _FadeDist;
			float _Scale;
			float _StepScale;
			float _Steps;
			float4 _SunDirection;
			sampler2D _CameraDepthTexture;


			float random(float3 value, float3 dotDir)
			{
				float3 smallV = sin(value);
				float random = dot(smallV, dotDir);
				random = frac(sin(random) * 13212.425);
				return random;
			}

			float3 random3d(float3 value)
			{
				return float3(random(value, float3(102.85, 68.5, 55.3)), 
						random(value, float3(29.85, 92.5, 35.3)),
						random(value, float3(70.85, 28.5, 85.3)));
			}

			float noise3d(float3 value)
			{
				value *= _Scale * _Time.x;
				float3 interp = frac(value);
				interp = smoothstep(0.0, 1.0, interp);
				
				float3 ZValues[2];
				for (int z = 0; z < 2; z++)
				{
					float3 YValues[2];
					for (int y = 0; y < 2; y++)
					{
						float XValues[2];
						for (int x = 0; x < 2; x++)
						{
							float3 cell = floor(value) + float3(x, y, z);
							XValues[x] = random3d(cell);
						}
						YValues[y] = lerp(XValues[0], XValues[1], interp.x);
					}
					ZValues[z] = lerp(YValues[0], YValues[1], interp.y);
				}

				float noise = -1.0 + 2.0 * lerp(ZValues[0], ZValues[1], interp.z);
				return noise;
			}

			fixed4 integrate(fixed4 sum, float diffuse, float density, fixed4 bgcol, float t)
			{
				fixed3 lighting = fixed3(0.8, 0.8, 0.8) * 1.3 + 0.5 * fixed3(0.7, 0.5, 0.3) * diffuse;
				fixed3 colrgb = lerp(fixed3(1.0, 0.95, 0.8), fixed3(0.65, 0.65, 0.65), density);
				fixed4 col = fixed4(colrgb.r, colrgb.g, colrgb.b, density);
				col.rgb *= lighting;
				col.rgb = lerp(col.rgb, bgcol, 1.0 - exp(-0.003*t*t));
				col.a *= 0.5;
				col.rgb *= col.a;
				return sum + col * (1.0 - sum.a);
			}



			#define MARCH(steps, noiseMap, cameraPos, viewDir, bgcol, sum, depth, t) { \
                for (int i = 0; i < steps  + 1; i++) \
                { \
                    if(t > depth) \
                        break; \
                    float3 pos = cameraPos + t * viewDir; \
                    if (pos.y < _MinHeight || pos.y > _MaxHeight || sum.a > 0.99) \
                    {\
                        t += max(0.1, 0.02*t); \
                        continue; \
                    }\
                    \
                    float density = noiseMap(pos); \
                    if (density > 0.01) \
                    { \
                        float diffuse = clamp((density - noiseMap(pos + 0.3 * _SunDirection)) / 0.6, 0.0, 1.0);\
                        sum = integrate(sum, diffuse, density, bgcol, t); \
                    } \
                    t += max(0.1, 0.02 * t); \
                } \
            } 
			

			#define NOISEPROC(N, P)  1.75 * N * saturate((_MaxHeight - P.y) / _FadeDist)

			float map3(float q)
			{
				float3 p = q;
				float f;

				f = 0.7 * noise3d(q);
				q = q * 1.2;
				f += 0.35 * noise3d(q);
				q = q * 2.4;
				f += 0.12 * noise3d(q);
				q = q * 4.8;

				return NOISEPROC(f, p);
			}

			float map2(float3 q)
			{
				float3 p = q;
				float f;

				f = 0.8 * noise3d(q);
				q = q * 1.5;
				f += 0.4 * noise3d(q);
				q = q * 3.5;
				f += 0.2 * noise3d(q);

				return NOISEPROC(f, p);
			}


			float map1(float3 q)
			{
				float3 p = q;
				float f;

				f = 0.5 * noise3d(q);
				q = q * 2;
				f += 0.25 * noise3d(q);
				q = q * 4;
				f += 0.15 * noise3d(q);

				return NOISEPROC(f, p);
			}


			fixed4 Raymarch(float3 cameraPos, float3 viewDir, fixed4 bgCol, float depth)
			{
				fixed4 col = fixed4(0, 0, 0, 0);
				float ct = 0;

				MARCH(_Steps, map1, cameraPos, viewDir, bgCol, col, depth, ct);
				MARCH(_Steps, map2, cameraPos, viewDir, bgCol, col, depth, ct);
				MARCH(_Steps, map3, cameraPos, viewDir, bgCol, col, depth, ct);

				return clamp(col, 0.0, 1.0);
			}

            v2f vert (appdata v)
            {
                v2f o;
				o.wPos = mul(unity_ObjectToWorld, v.vertex.xyz);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.viewDir = o.wPos - _WorldSpaceCameraPos;
				o.projPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float depth = 1;
				depth *= length(i.viewDir);
				fixed4 col = fixed4(1, 1, 1, 0);
				fixed4 clouds = Raymarch(_WorldSpaceCameraPos, normalize(i.viewDir) * _StepScale, col, depth);
				fixed3 mixedCol = col * (1.0 - clouds.a) + clouds.rgb;
				return fixed4(mixedCol, clouds.a);
            }
            ENDCG
        }
    }
}
