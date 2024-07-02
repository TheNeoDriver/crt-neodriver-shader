#include "ReShade.fxh"

// crt-neodriver: this is a version crt-neodriver
// crafted by TheNeoDriver originally for RetroArch.

#include "shaders/shared-components.fxh"
#include "shaders/re-texturer.fxh"
#include "shaders/sgenpt-mix.fxh"
#include "shaders/bicubic.fxh"
#include "shaders/crt-consumer-mask.fxh"
#include "shaders/crt-consumer-colors.fxh"

technique CRT_Neodriver
{
    pass TextureDownscale
    {
        VertexShader = PostProcessVS;
		PixelShader = TextureDownscalePixelShader;
    }

    pass SGen_Mix
    {
        VertexShader = PostProcessVS;
		PixelShader = PS_SGENPT;
    }

    pass Bicubic
    {
        VertexShader = PostProcessVS;
		PixelShader = PixelBicubic;
    }

    pass CRT_ConsumerMask
    {
        VertexShader = PostProcessVS;
		PixelShader = PixelCRTConsumerMask;
    }

    pass TextureUpcale
    {
        VertexShader = PostProcessVS;
		PixelShader = TextureUpscalePixelShader;
    }
    
    pass CRT_ConsumerColors
    {
        VertexShader = PostProcessVS;
		PixelShader = PixelCRTConsumerColors;
    }

}