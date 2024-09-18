Shader "Unlit/fur fin"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _NormTex ("Normal Texture", 2D) = "ehite" {}
        _FinStep ("Fin Step", float) = 3
        _Length ("Length", float) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #pragma multi_compile_fwdbase  nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float3 uv : TEXCOORD0;
            };

            struct v2g
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                SHADOW_COORDS(2)
                float3 viewdir : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            sampler2D _NormTex;
            float _FinStep;
            float _Length;

            v2g vert (appdata v)
            {
                v2g o;
                o.pos = v.vertex;
                o.normal = v.normal;
                o.tangent = v.tangent;
                o.uv = v.uv;
                return o;
            }

            void MakePlane(v2g input0, v2g input1, inout TriangleStream<g2f> outStream)
            {
                g2f a;
                float h;
                float4 pos;

                for (int i = 0; i < _FinStep; i++)
                {
                    h = float(i)/_FinStep;

                    pos = input0.pos;
                    a.pos = UnityObjectToClipPos(pos);
                    a.normal = UnityObjectToWorldNormal(input0.normal);
                    a.tangent = UnityObjectToWorldDir(input0.tangent.xyz);
                    a.uv = input0.uv;
                    a.uv2 = float2(0, h);
                    a.viewdir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, input0.pos).xyz));
                    TRANSFER_SHADOW(a)
                    pos.xyz += h*_Length*input0.normal;
                    a.pos = UnityObjectToClipPos(pos);
                    outStream.Append(a);

                    pos = input1.pos;
                    a.pos = UnityObjectToClipPos(pos);
                    a.normal = UnityObjectToWorldNormal(input1.normal);
                    a.tangent = UnityObjectToWorldDir(input1.tangent.xyz);
                    a.uv = input1.uv;
                    a.uv2 = float2(1, h);
                    a.viewdir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, input1.pos).xyz));
                    TRANSFER_SHADOW(a)
                    pos.xyz += h*_Length*input1.normal;
                    a.pos = UnityObjectToClipPos(pos);
                    outStream.Append(a);
                }
                outStream.RestartStrip();
            }

            [maxvertexcount(48)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                v2g mid;

                mid.pos = (input[1].pos + input[2].pos)/2;
                mid.normal = (input[1].normal + input[2].normal)/2;
                mid.tangent = (input[1].tangent + input[2].tangent)/2;
                mid.uv = (input[1].uv + input[2].uv)/2;
                MakePlane(input[0], mid, outStream);
                mid.pos = (input[2].pos + input[0].pos)/2;
                mid.normal = (input[2].normal + input[0].normal)/2;
                mid.tangent = (input[2].tangent + input[0].tangent)/2;
                mid.uv = (input[2].uv + input[0].uv)/2;
                MakePlane(input[1], mid, outStream);
                mid.pos = (input[0].pos + input[1].pos)/2;
                mid.normal = (input[0].normal + input[1].normal)/2;
                mid.tangent = (input[0].tangent + input[1].tangent)/2;
                mid.uv = (input[0].uv + input[1].uv)/2;
                MakePlane(input[2], mid, outStream);
            }

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 maskCol = tex2D(_MaskTex, i.uv);
                if (maskCol.r < 0.5) discard;

                float3 bitangent = normalize(cross(i.normal, i.tangent));
                float3 tangent = normalize(cross(i.normal, bitangent));
                float3 normCol = normalize(UnpackNormal(tex2D(_NormTex, i.uv)));
                float3 normal = normCol.r*tangent + normCol.g*bitangent + normCol.b*i.normal;

                float3 diffCol = max(0, dot(normal, _WorldSpaceLightPos0.xyz)) * _LightColor0;
                float3 ambCol = ShadeSH9(float4(normal, 1));
                float shadow = SHADOW_ATTENUATION(i);
                float layerShade = (1-(1-i.uv2.y)*0.5);
                float viewShade = 1 - max(0, dot(normal, i.viewdir));
                fixed3 shade = (shadow * diffCol + ambCol) * layerShade;
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= shade;
                return col;
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
