#ifndef _CRT_CONSUMER_COLORS
#define _CRT_CONSUMER_COLORS

#include "ReShade.fxh"
#include "shared-components.fxh"

/*

   From RetroArch Lib,
   Ported by TheNeoDriver.

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

uniform float warpx <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.12;
    ui_step = 0.01;
	ui_label = "Curvature X [CRT-Consumer]";
> = 0.03;

uniform float warpy <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.12;
    ui_step = 0.01;
	ui_label = "Curvature Y [CRT-Consumer]";
> = 0.04;

uniform float corner <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.10;
    ui_step = 0.01;
	ui_label = "Corner size [CRT-Consumer]";
> = 0.02;

uniform float smoothness <
    ui_type = "slider";
	ui_min = 25.0;
	ui_max = 600.0;
    ui_step = 5.0;
	ui_label = "Border Smoothness [CRT-Consumer]";
> = 400.0;

uniform float brightboost1 <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 3.0;
    ui_step = 0.05;
	ui_label = "Bright boost dark pixels [CRT-Consumer]";
> = 1.1;

uniform float brightboost2 <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 3.0;
    ui_step = 0.05;
	ui_label = "Bright boost dark pixels [CRT-Consumer]";
> = 1.05;

uniform float gamma_out <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 4.0;
    ui_step = 0.1;
	ui_label = "Gamma Out [CRT-Consumer]";
> = 2.2;

uniform float glow <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 0.5;
    ui_step = 0.01;
	ui_label = "Glow Strength [CRT-Consumer]";
> = 0.05;

uniform float Size <
    ui_type = "slider";
	ui_min = 0.1;
	ui_max = 4.0;
    ui_step = 0.05;
	ui_label = "Glow Size [CRT-Consumer]";
> = 1.0;

uniform float sat <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 2.0;
    ui_step = 0.05;
	ui_label = "Saturation [CRT-Consumer]";
> = 1.35;

uniform float contrast <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 2.0;
    ui_step = 0.05;
	ui_label = "Contrast, 1.0:Off [CRT-Consumer]";
> = 0.80;

uniform float nois <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 32.0;
    ui_step = 1.0;
	ui_label = "Noise [CRT-Consumer]";
> = 1.0;

uniform float vignette <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
    ui_step = 1.0;
	ui_label = "Vignette On/Off [CRT-Consumer]";
> = 1.0;

uniform float vpower <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
    ui_step = 0.01;
	ui_label = "Vignette Power [CRT-Consumer]";
> = 0.2;

uniform float vstr <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 50.0;
    ui_step = 1.0;
	ui_label = "Vignette strength [CRT-Consumer]";
> = 40.0;

uniform int framecount <source = "framecount";>;

float iTime() {return (float(framecount) / 2.0);}
float iTimer() {return (float(framecount) / 60.0);}

float fractt(float x)
{
    return x - floor(x);
}

float2 Warp(float2 pos)
{
    pos  = pos * 2.0 - 1.0;    
    pos *= float2(1.0 + (pos.y * pos.y) * warpx, 1.0 + (pos.x * pos.x) * warpy);
    return pos * 0.5 + 0.5;
}


float4x4 contrastMatrix(float contrast)
{   
    float t = (1.0 - contrast) / 2.0;
    
    return float4x4(contrast, 0,               0,               0,
                    0,        contrast,        0,               0,
                    0,               0,        contrast,        0,
                    t,               t,               t,        1);
}


float3x3 vign(float l, float2 vpos)
{
    vpos *= 1.0 - vpos.xy;
    
    float vig = vpos.x * vpos.y * vstr;
    vig = min(pow(vig, vpower), 1.0); 
    if (vignette == 0.0) vig = 1.0;
   
    return float3x3(vig, 0,   0,
                    0,   vig, 0,
                    0,   0,   vig);
}


float3 saturation(float3 textureColor)
{
    float luminance = length(textureColor.rgb) * 0.5775;

    float3 luminanceWeighting = float3(0.4, 0.5, 0.1);
    if (luminance < 0.5) luminanceWeighting.rgb = (luminanceWeighting.rgb * luminanceWeighting.rgb) 
                                                + (luminanceWeighting.rgb * luminanceWeighting.rgb);

    luminance = dot(textureColor.rgb, luminanceWeighting);
    float3 greyScaleColor = float3(luminance, luminance, luminance);

    float3 res = float3(lerp(greyScaleColor, textureColor.rgb, sat));
    return res;
}


float3 glow0 (float2 texcoord, float3 col)
{
   float sum = float3(0.0, 0.0, 0.0);
   float blurSize = Size / 1024.0;

   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - 2.0 * blurSize, texcoord.y)).rgb * 0.1;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - blurSize,       texcoord.y)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x,                  texcoord.y)).rgb * 0.16;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + blurSize,       texcoord.y)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + 2.0 * blurSize, texcoord.y)).rgb * 0.1;

   //sum += texture(Source, vec2(texcoord.x - 2.0 * blurSize, texcoord.y - 2.0 * blurSize)) * 0.1;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - 2.0 * blurSize, texcoord.y - blurSize)).rgb * 0.1;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - blurSize,       texcoord.y - 2.0 * blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - blurSize,       texcoord.y - blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + blurSize,       texcoord.y + blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + blurSize,       texcoord.y + 2.0 * blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + 2.0 * blurSize, texcoord.y + blurSize)).rgb * 0.1;
   
   //sum += texture(Source, vec2(texcoord.x + 2.0 * blurSize, texcoord.y + 2.0 * blurSize)) * 0.1;
   //sum += texture(Source, vec2(texcoord.x - 2.0 * blurSize, texcoord.y + 2.0 * blurSize)) * 0.1;
   
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - 2.0 * blurSize, texcoord.y + blurSize)).rgb * 0.1;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - blurSize,       texcoord.y + 2.0 * blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x - blurSize,       texcoord.y + blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + blurSize,       texcoord.y - blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + blurSize,       texcoord.y - 2.0 * blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x + 2.0 * blurSize, texcoord.y - blurSize)).rgb * 0.1;
   
   //sum += texture(Source, vec2(texcoord.x + 2.0 * blurSize,  texcoord.y - 2.0 * blurSize)) * 0.1;

   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y - 2.0 * blurSize)).rgb * 0.1;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y - blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y + blurSize)).rgb * 0.13;
   sum += tex2D(ReShade::BackBuffer, float2(texcoord.x, texcoord.y + 2.0 * blurSize)).rgb * 0.1;
  
   return sum * glow; 
}


float noise(float2 co)
{
    return fractt(sin(iTimer() * dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}


float corner0(float2 coord)
{
    coord = (coord - float2(0.5, 0.5)) * 1.0 + float2(0.5, 0.5);
    coord = min(coord, float2(1.0, 1.0) - coord) * float2(1.0, 1.0);
    
    float2 cdist = float2(corner, corner);
    coord = (cdist - min(coord, cdist));
    float dist = sqrt(dot(coord, coord));

    return clamp((cdist.x - dist) * smoothness, 0.0, 1.0);
}


float4 PixelCRTConsumerColors(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
    float2 SourceSize = float2(BUFFER_WIDTH, BUFFER_HEIGHT);

    float2 position = Warp(texcoord.xy);
    float2 tex_size = SourceSize;

    float2 pC4 = (position + 0.5 / tex_size.xy);

    float4 res = float4(1.0, 1.0, 1.0, 1.0);

    float3 color = tex2D(ReShade::BackBuffer, pC4).rgb;
    float lum = color.r * 0.4 + color.g * 0.5 + color.b * 0.1;

    color *= lerp(brightboost1, brightboost2, max(max(color.r, color.g), color.b));    

    color = pow(color,float3(1.0 / gamma_out, 1.0 / gamma_out, 1.0 / gamma_out));

    if (glow   != 0.0) color += glow0(pC4,color);
    if (sat    != 1.0) color  = saturation(color);
    if (corner != 0.0) color *= corner0(pC4);
    if (nois   != 0.0) color *= 1.0 + noise(pC4 * 2.0) / nois;
        
    res = float4(color, 1.0);
    if (contrast != 1.0) res = mul(contrastMatrix(contrast), res);
    if (inter > 0.5 && SourceSize.y > 400.0 && fractt(iTime()) < 0.5) res = res * 0.95;
    res.rgb = mul(res.rgb, vign(lum, texcoord));

    return res;
}

#endif