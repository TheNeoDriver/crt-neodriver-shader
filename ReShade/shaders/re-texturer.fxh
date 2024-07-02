#ifndef _RE_TEXTURER
#define _RE_TEXTURER

#include "ReShade.fxh"
#include "shared-components.fxh"

void TextureDownscalePixelShader(
    in float4 pos : SV_Position,
    in float2 texcoord : TEXCOORD0,
    
    out float4 color : SV_Target
) {;
    float factor = (1.0 * BUFFER_HEIGHT) / (1.0 * GameScale);
    texcoord *= factor;
    color = tex2D(ReShade::BackBuffer, texcoord);
}

void TextureUpscalePixelShader(
    in float4 pos : SV_Position,
    in float2 texcoord : TEXCOORD0,
    
    out float4 color : SV_Target
) {
    float factor = (1.0 * BUFFER_HEIGHT) / (1.0 * GameScale);
    texcoord /= factor;
    color = tex2D(ReShade::BackBuffer, texcoord);
}

#endif