Shader "Custom/vtfSample_Fragment"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex2Dlod("Tex2DlodSample", 2D) = "white"{}
        _Scale("Scale", range(0, 10)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 texcoord : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 texcoord : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _Tex2Dlod;
            float4 _Tex2Dlod_ST;

            half _Scale;

            v2f vert (appdata v)
            {
                v2f o;

                float d = tex2Dlod(_Tex2Dlod, float4(v.texcoord.xy, 0, 0)).r;
                v.vertex.y += (d * _Scale) - _Scale/2;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
