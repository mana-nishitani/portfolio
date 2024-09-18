Shader "Unlit/Aurora"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white"
        _ViewPhaseMax ("ViewPhase Max", float) = 1
        _ViewPhaseSen ("ViewPhase Sensivity", float) = 1
        _S ("S", float) = 1
        _V ("V", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {

            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase  nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewdir : TEXCOORD1;
                fixed diff : COLOR0;
                fixed ambient: COLOR1;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float _ViewPhaseMax;
            float _ViewPhaseSen;
            float _S;
            float _V;

            float3 HSVtoRGB (float3 hsv)
            {
                float c = hsv.z * hsv.y;
                float x = c * (1 - abs((hsv.x * 6) % 2 - 1));
                float3 rgb = hsv.z - c;
                if (hsv.x * 6 < 1)
                {
                    rgb += float3(c, x, 0);
                } else if (hsv.x * 6 < 2)
                {
                    rgb += float3(x, c, 0);
                } else if (hsv.x * 6 < 3)
                {
                    rgb += float3(0, c, x);
                } else if (hsv.x * 6 < 4)
                {
                    rgb += float3(0, x, c);
                } else if (hsv.x * 6 < 5)
                {
                    rgb += float3(x, 0, c);
                } else if (hsv.x * 6 < 6)
                {
                    rgb += float3(c, 0, x);
                }
                return rgb;
            }

            float4 calcColor (float noise, float phase)
            {
                float3 hsv;
                hsv.x = (5 * noise + phase) % 1;
                hsv.y = _S;
                hsv.z = _V;
                return float4(HSVtoRGB(hsv),1);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                float nl = max(0, dot(o.normal, _WorldSpaceLightPos0.xyz));
                o.diff = nl*1;
                o.ambient = dot(ShadeSH9(float4(o.normal, 1)),ShadeSH9(float4(o.normal, 1)));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewdir = normalize(WorldSpaceViewDir(v.vertex));
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 CameraPos = _WorldSpaceCameraPos;
                float noise = tex2D(_NoiseTex, i.uv);
                float noise2 = tex2D(_NoiseTex, -i.uv+float2(CameraPos.x+0.5*CameraPos.z, CameraPos.y+0.5*CameraPos.z) + (0.05*_Time.y)%1);
                float noise3 = tex2D(_NoiseTex, -i.uv+float2(CameraPos.y-0.5*CameraPos.z, CameraPos.x-0.5*CameraPos.z) + (0.1*_Time.y)%1);
                float viewphase = _ViewPhaseSen*(noise2 + noise3);
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed lighting = i.diff * shadow + i.ambient;
                float a = 1 - 2 * abs(lighting-0.5);
                float4 texcol = tex2D(_MainTex, i.uv);
                fixed4 col = (1-a) * texcol + a * calcColor(noise, viewphase);
                return calcColor(noise, viewphase);
                // return (_Time.y)%1;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
