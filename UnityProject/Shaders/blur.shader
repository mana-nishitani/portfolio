Shader "Hidden/blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;


            fixed4 frag (v2f i) : SV_Target
            {
                float weight [5] = { 0.22702703, 0.19459459, 0.12162162, 0.05405405, 0.01621622 };
                float offset [5] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
                // float depth = tex2D(_CameraDepthTexture, i.uv).r;
                // depth = Linear01Depth(depth);
                float2 size = _MainTex_TexelSize;
                fixed4 col = tex2D(_MainTex, i.uv) * weight[0];
                for (int j = 1; j < 5; j++)
                {
                    col += tex2D(_MainTex, i.uv + float2(1,0)*offset[j] * size) * weight[j];
                    col += tex2D(_MainTex, i.uv - float2(1,0)*offset[j] * size) * weight[j];
                }
                return col;
            }
            ENDCG
        }

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float2 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                float weight [5] = { 0.22702703, 0.19459459, 0.12162162, 0.05405405, 0.01621622 };
                float offset [5] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
                // float depth = tex2D(_CameraDepthTexture, i.uv).r;
                // depth = Linear01Depth(depth);
                // depth = 0;
                float2 size = _MainTex_TexelSize;
                fixed4 col = tex2D(_MainTex, i.uv) * weight[0];
                for (int j = 1; j < 5; j++)
                {
                    col += tex2D(_MainTex, i.uv + float2(0,1)*offset[j] * size) * weight[j];
                    col += tex2D(_MainTex, i.uv - float2(0,1)*offset[j] * size) * weight[j];
                }
                return col;
            }
            ENDCG
        }
    }
}
