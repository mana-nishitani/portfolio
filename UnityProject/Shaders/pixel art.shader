Shader "Hidden/pixel art"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _N ("Resolution", float) = 1
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
            float _N;

            fixed4 frag (v2f i) : SV_Target
            {
                float u = int(i.uv.x*16*_N) / (16*_N) + 0.5*1/(16*_N);
                float v = int(i.uv.y*9*_N) / (9*_N) + 0.5*1/(9*_N);
                fixed4 col = tex2D(_MainTex, float2(u,v));
                return col;
            }
            ENDCG
        }
    }
}
