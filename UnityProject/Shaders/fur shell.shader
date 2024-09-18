// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/fur shell"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _FurTex ("Fur Texture", 2D) = "white" {}
        _NormTex ("Normal Texture", 2D) = "white" {}
        _ShellStep ("Shell Step", float) = 5
        _Length ("Length", float) = 0.01
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
                float2 uv : TEXCOORD0;
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
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float3 viewdir : TEXCOORD3;
                float layer : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            sampler2D _FurTex;
            sampler2D _NormTex;
            float _ShellStep;
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

            void MakeLayer(v2g input[3], inout TriangleStream<g2f> outStream, int index)
            {
                float _interval = _Length / _ShellStep;
                // float3 normal, tangent, bitangent, normCol;
                
                g2f out0;
                out0.pos = UnityObjectToClipPos(input[0].pos);
                out0.uv = input[0].uv;
                out0.layer = index/_ShellStep;
                out0.normal = UnityObjectToWorldNormal(input[0].normal);
                out0.tangent = UnityObjectToWorldDir(input[0].tangent.xyz);
                out0.viewdir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, input[0].pos).xyz));
                TRANSFER_SHADOW(out0)
                out0.pos = UnityObjectToClipPos(input[0].pos + index*_interval*input[0].normal);
                outStream.Append(out0);

                g2f out1;
                out1.pos = UnityObjectToClipPos(input[1].pos);
                out1.uv = input[1].uv;
                out1.layer = index/_ShellStep;
                out1.normal = UnityObjectToWorldNormal(input[1].normal);
                out1.tangent = UnityObjectToWorldDir(input[1].tangent.xyz);
                out1.viewdir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, input[1].pos).xyz));
                TRANSFER_SHADOW(out1)
                out1.pos = UnityObjectToClipPos(input[1].pos + index*_interval*input[1].normal);
                outStream.Append(out1);

                g2f out2;
                out2.pos = UnityObjectToClipPos(input[2].pos);
                out2.uv = input[2].uv;
                out2.layer = index/_ShellStep;
                out2.normal = UnityObjectToWorldNormal(input[2].normal);
                out2.tangent = UnityObjectToWorldDir(input[2].tangent.xyz);
                out2.viewdir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, input[2].pos).xyz));
                TRANSFER_SHADOW(out2)
                out2.pos = UnityObjectToClipPos(input[2].pos + index*_interval*input[2].normal);
                outStream.Append(out2);

                outStream.RestartStrip();
            }

            [maxvertexcount(48)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                for (int i = 0; i < _ShellStep; i++)
                {
                    MakeLayer(input, outStream, i);
                }
            }

            fixed4 frag (g2f i) : SV_Target
            {
                float clipA = _ShellStep/(_ShellStep-1)-0.01;
                float4 furCol = tex2D(_FurTex, i.uv);
                if (furCol.r > 1-clipA*i.layer) discard;

                float3 bitangent = normalize(cross(i.normal, i.tangent));
                float3 tangent = normalize(cross(i.normal, bitangent));
                float3 normCol = UnpackNormal(tex2D(_NormTex, i.uv));
                float3 normal = normCol.r*tangent + normCol.g*bitangent + normCol.b*i.normal;

                fixed3 diffCol = max(0, dot(normal, _WorldSpaceLightPos0.xyz))*_LightColor0;
                fixed3 ambCol = ShadeSH9(float4(normal, 1));
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed layerShade = (1-(1-i.layer)*0.5);
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
