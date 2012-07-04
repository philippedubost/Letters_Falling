
float4x4 tW: WORLD;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

texture Src1 <string uiname="Source1";>;
sampler Src1Samp = sampler_state
{
    Texture   = (Src1);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture Src2 <string uiname="Source2";>;
sampler Src2Samp = sampler_state
{
    Texture   = (Src2);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture Mask<string uiname="Control";>;
sampler MaskSamp = sampler_state
{
    Texture   = (Mask);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Source1 Transform";>;
float4x4 tTex2: TEXTUREMATRIX <string uiname="Source2 Transform";>;
float4x4 tMask: TEXTUREMATRIX <string uiname="Ctrl Transform";>;

struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
    float2 Tex2Cd : TEXCOORD1;
    float2 MaskCd : TEXCOORD2;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float4 TexCd : TEXCOORD0,
    float2 Tex2Cd : TEXCOORD1,
    float2 MaskCd : TEXCOORD2)
{
    vs2ps Out = (vs2ps)0;
    Out.Pos = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.Tex2Cd = mul(TexCd, tTex2);
    Out.MaskCd = mul(TexCd, tMask);
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 psFade(vs2ps In): COLOR
{
    float4 sc1 = tex2D(Src1Samp, In.TexCd);
    float4 sc2 = tex2D(Src2Samp, In.Tex2Cd);
    float4 ctrl = tex2D(MaskSamp, In.MaskCd);
    float4 outColor = sc1 * (1-ctrl) + sc2 * (ctrl);
    return outColor;
}

float4 psinvFade(vs2ps In): COLOR
{
    float4 sc1 = tex2D(Src1Samp, In.TexCd);
    float4 sc2 = tex2D(Src2Samp, In.Tex2Cd);
    float4 ctrl = tex2D(MaskSamp, In.MaskCd);
    float4 outColor = sc1 * (ctrl) + sc2 * (1-ctrl);
    return outColor;
}

//show Source1 only
float4 psVS1(vs2ps In): COLOR
{
    float4 sc1 = tex2D(Src1Samp, In.TexCd);
    return sc1;
}

//show Source2 only
float4 psVS2(vs2ps In): COLOR
{
    float4 sc2 = tex2D(Src2Samp, In.Tex2Cd);
    return sc2;
}

//show control only
float4 psVSct(vs2ps In): COLOR
{
    float4 ctrl = tex2D(MaskSamp, In.MaskCd);
    return ctrl;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique Fade
{
    pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_1_0 psFade();
    }
}

technique invFade
{
    pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_1_0 psinvFade();
    }
}

technique ViewSource1
{
    pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_1_0 psVS1();
    }
}

technique ViewSource2
{
    pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_1_0 psVS2();
    }
}

technique ViewControl
{
    pass P0
    {
        VertexShader = compile vs_1_0 VS();
        PixelShader  = compile ps_1_0 psVSct();
    }
}

technique TFixedFunction
{
    pass P0
    {
        //transforms
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        //texturing
        Sampler[0] = (Src1Samp);
        TextureTransform[0] = (tTex);
        TexCoordIndex[0] = 0;
        TextureTransformFlags[0] = COUNT2;
        //Wrap0 = U;  // useful when mesh is round like a sphere
        
        Lighting       = FALSE;

        //shaders
        VertexShader = NULL;
        PixelShader  = NULL;
    }
}
