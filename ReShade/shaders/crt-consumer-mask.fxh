#ifndef _CRT_CONSUMER_MASK
#define _CRT_CONSUMER_MASK

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

uniform float blurx <
    ui_type = "slider";
	ui_min = -2.0;
	ui_max = 2.0;
    ui_step = 0.05;
	ui_label = "Convergence X [CRT-Consumer]";
> = 0.80;

uniform float blury <
    ui_type = "slider";
	ui_min = -2.0;
	ui_max = 2.0;
    ui_step = 0.05;
	ui_label = "Convergence Y [CRT-Consumer]";
> = -0.80;

uniform float scanlow <
    ui_type = "slider";
	ui_min = 1.0;
	ui_max = 15.0;
    ui_step = 1.0;
	ui_label = "Beam low [CRT-Consumer]";
> = 6.0;

uniform float scanhigh <
    ui_type = "slider";
	ui_min = 1.0;
	ui_max = 15.0;
    ui_step = 1.0;
	ui_label = "Bean high [CRT-Consumer]";
> = 8.0;

uniform float beamlow <
    ui_type = "slider";
	ui_min = 0.5;
	ui_max = 2.5;
    ui_step = 0.05;
	ui_label = "Scanlines dark [CRT-Consumer]";
> = 1.35;

uniform float beamhigh <
    ui_type = "slider";
	ui_min = 0.5;
	ui_max = 2.5;
    ui_step = 0.05;
	ui_label = "Scanlines bright [CRT-Consumer]";
> = 1.05;

uniform float Shadowmask <
    ui_type = "slider";
	ui_min = -1.0;
	ui_max = 8.0;
    ui_step = 1.0;
	ui_label = "Mask Type [CRT-Consumer]";
> = 5.0;

uniform float masksize <
    ui_type = "slider";
	ui_min = 1.0;
	ui_max = 3.0;
    ui_step = 1.0;
	ui_label = "Mask size [CRT-Consumer]";
> = 1.0;

uniform float MaskDark <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 2.0;
    ui_step = 0.1;
	ui_label = "Mask dark [CRT-Consumer]";
> = 0.5;

uniform float MaskLight <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 2.0;
    ui_step = 0.1;
	ui_label = "Mask light [CRT-Consumer]";
> = 1.5;

uniform float slotmask <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
    ui_step = 0.05;
	ui_label = "Slot Mask Strength [CRT-Consumer]";
> = 0.0;

uniform float slotwidth <
    ui_type = "slider";
	ui_min = 1.0;
	ui_max = 6.0;
    ui_step = 0.5;
	ui_label = "Slot Mask Width [CRT-Consumer]";
> = 2.0;

uniform float double_slot <
    ui_type = "slider";
	ui_min = 1.0;
	ui_max = 2.0;
    ui_step = 1.0;
	ui_label = "Slot Mask Height: 2x1 or 4x1 [CRT-Consumer]";
> = 1.0;

uniform float slotms <
    ui_type = "slider";
	ui_min = 1.0;
	ui_max = 2.0;
    ui_step = 1.0;
	ui_label = "Slot Mask Size [CRT-Consumer]";
> = 1.0;

uniform float gamma_in <
    ui_type = "slider";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.1;
    ui_label = "Gamma In [CRT-Consumer]";
> = 2.5;

uniform float WP <
    ui_type = "slider";
	ui_min = -100.0;
	ui_max = 100.0;
    ui_step = 5.0;
	ui_label = "Color Temperature % [CRT-Consumer]";
> = 0.0;

uniform float inter <
    ui_type = "slider";
	ui_min = 0.0;
	ui_max = 1.0;
    ui_step = 1.0;
	ui_label = "Interlacing Toggle [CRT-Consumer]";
> = 1.0;


float fract(float x)
{
    return x - floor(x);
}

float2 fract(float2 x)
{
    return x - floor(x);
}

float mod(float x, float y)
{
    return x - y * floor(x/y);
}


float sw(float3 x, float3 color)
{
    float scan = lerp(scanlow, scanhigh, x.y);
    float3 tmp = lerp(float3(beamlow, beamlow, beamlow), 
                   float3(beamhigh, beamhigh, beamhigh), 
                   color);
    float3 ex = x * tmp;
    return exp2(-scan * ex.y * ex.y);
}

float3 mask(float2 x, float3 col, float l)
{
    x = floor(x / masksize);        
  
    if (Shadowmask == 0.0)
    {
        float m = fract(x.x * 0.4999);
        if (m < 0.4999) return float3(1.0, MaskDark, 1.0);
        else            return float3(MaskDark, 1.0, MaskDark);
    }
   
    else if (Shadowmask == 1.0)
    {
        float3 Mask = float3(MaskDark, MaskDark, MaskDark);
        float line = MaskLight;
        float odd  = 0.0;

        if (fract(x.x / 6.0) < 0.5) odd = 1.0;
        if (fract((x.y + odd) / 2.0) < 0.5) line = MaskDark;

        float m = fract(x.x / 3.0);
        if      (m < 0.333) Mask.b = MaskLight;
        else if (m < 0.666) Mask.g = MaskLight;
        else                Mask.r = MaskLight;
        
        Mask *= line; 
        return Mask; 
    } 
    
    else if (Shadowmask == 2.0)
    {
        float m = fract(x.x*0.3333);
        if (m < 0.3333) return float3(MaskDark,  MaskDark,  MaskLight);
        if (m < 0.6666) return float3(MaskDark,  MaskLight, MaskDark);
        else            return float3(MaskLight, MaskDark,  MaskDark);
    }

    if (Shadowmask == 3.0)
    {
        float m = fract(x.x * 0.5);
        if (m < 0.5) return float3(1.0, 1.0, 1.0);
        else         return float3(MaskDark, MaskDark, MaskDark);
    }
   
    else if (Shadowmask == 4.0)
    {   
        float3 Mask = float3(col.rgb);
        float line = MaskLight;
        float odd  = 0.0;

        if (fract(x.x / 4.0) < 0.5) odd = 1.0;
        if (fract((x.y + odd) / 2.0) < 0.5) line = MaskDark;

        float m = fract(x.x / 2.0);
        if  (m < 0.5) { Mask.r = 1.0; Mask.b = 1.0; }
        else  Mask.g = 1.0;   

        Mask *= line;  
        return Mask;
    } 

    else if (Shadowmask == 5.0)
    {
        float3 Mask = float3(1.0, 1.0, 1.0);

        if (fract(x.x / 4.0) < 0.5)   
        {
            if (fract(x.y / 3.0) < 0.666)
            {
                if (fract(x.x / 2.0) < 0.5) Mask = float3(1.0, MaskDark, 1.0);
                else                        Mask = float3(MaskDark, 1.0, MaskDark);
            }
            else Mask *= l;
        }
        else if (fract(x.x / 4.0) >= 0.5)   
        {
            if (fract(x.y / 3.0) > 0.333) 
            {
                if (fract(x.x / 2.0) < 0.5) Mask = float3(1.0, MaskDark, 1.0); 
                else                        Mask = float3(MaskDark, 1.0, MaskDark);
            }
            else Mask *= l;
        }

        return Mask;
    }

    else if (Shadowmask == 6.0)
    {
        float3 Mask = float3(MaskDark, MaskDark, MaskDark);
        if (fract(x.x / 6.0) < 0.5)   
        {
            if (fract(x.y / 4.0) < 0.75)  
            {
                if      (fract(x.x / 3.0) < 0.3333) Mask.r = MaskLight; 
                else if (fract(x.x / 3.0) < 0.6666) Mask.g = MaskLight; 
                else                                Mask.b = MaskLight;
            }
            else Mask * l * 0.9;
        }
        else if (fract(x.x / 6.0) >= 0.5)   
        {
            if (fract(x.y / 4.0) >= 0.5 || fract(x.y / 4.0) < 0.25)  
            {
                if      (fract(x.x / 3.0) < 0.3333) Mask.r = MaskLight; 
                else if (fract(x.x / 3.0) < 0.6666) Mask.g = MaskLight;
                else                                Mask.b = MaskLight;
            }
            else Mask * l * 0.9;
        }
        return Mask;
    }

    else if (Shadowmask == 7.0)
    {
        float m = fract(x.x * 0.3333);

        if (m < 0.3333) return float3(MaskDark, MaskLight, MaskLight * col.b); //Cyan
        if (m < 0.6666) return float3(MaskLight * col.r, MaskDark, MaskLight); //Magenta
        else            return float3(MaskLight, MaskLight * col.g, MaskDark); //Yellow
    }

    else if (Shadowmask == 8.0)
    {
        float3 Mask = float3(MaskDark, MaskDark, MaskDark);

        float bright = MaskLight;
        float left   = 0.0;
        if (fract(x.x / 6.0) < 0.5) left = 1.0;
             
        float m = fract(x.x / 3.0);
        if      (m < 0.333) Mask.b = 0.9;
        else if (m < 0.666) Mask.g = 0.9;
        else                Mask.r = 0.9;
        
        if (mod(x.y, 2.0) == 1.0 && left == 1.0 || mod(x.y, 2.0) == 0.0 && left == 0.0) 
            Mask *= bright; 
      
        return Mask; 
    } 
    
    else return float3(1.0, 1.0, 1.0);
}


float SlotMask(float2 pos, float3 c)
{
    if (slotmask == 0.0) return 1.0;
    
    pos = floor(pos / slotms);
    float mx = pow(max(max(c.r, c.g), c.b), 1.33);
    float mlen = slotwidth * 2.0;
    float px = fract(pos.x / mlen);
    float py = floor(fract(pos.y / (2.0 * double_slot)) * 2.0 * double_slot);
    float slot_dark = lerp(1.0 - slotmask, 1.0 - 0.80 * slotmask, mx);
    float slot = 1.0 + 0.7 * slotmask * (1.0 - mx);
    
    if      (py == 0.0                && px <  0.5) slot = slot_dark; 
    else if (py == double_slot && px >= 0.5) slot = slot_dark;       
    
    return slot;
}


float4 PixelCRTConsumerMask(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
    float2 SourceSize = float2(BUFFER_WIDTH, BUFFER_HEIGHT);

    float2 position = texcoord.xy;
    float2 tex_size = SourceSize;

    float2 pC4 = (position + 0.5 / tex_size.xy);
    float2 fp = fract(position * tex_size.xy);
    if (inter > 0.5 && SourceSize.y > 400.0) fp.y = 1.0; 
    float4 res = float4(1.0, 1.0, 1.0, 1.0);
    
    
    float3 sample1 = tex2D(ReShade::BackBuffer, float2(pC4.x + blurx / 1000.0, pC4.y - blury / 1000.0)).rgb;
    float3 sample2 = tex2D(ReShade::BackBuffer, pC4).rgb;
    float3 sample3 = tex2D(ReShade::BackBuffer, float2(pC4.x - blurx / 1000.0, pC4.y + blury / 1000.0)).rgb;
        
    float3 color = float3(sample1.r * 0.5  + sample2.r * 0.5, 
                        sample1.g * 0.25 + sample2.g * 0.5 + sample3.g * 0.25,
                        sample2.b * 0.5  + sample3.b * 0.5);
       
    //COLOR TEMPERATURE FROM GUEST.R-DR.VENOM
    if (WP != 0.0)
    {
        float3x3 D65_to_XYZ = float3x3(
            0.4306190,  0.2220379,  0.0201853,
            0.3415419,  0.7066384,  0.1295504,
            0.1783091,  0.0713236,  0.9390944);

        float3x3 XYZ_to_D65 = float3x3(
            3.0628971, -0.9692660,  0.0678775,
            -1.3931791,  1.8760108, -0.2288548,
            -0.4757517,  0.0415560,  1.0693490);
           
        float3x3 D50_to_XYZ = float3x3(
            0.4552773,  0.2323025,  0.0145457,
            0.3675500,  0.7077956,  0.1049154,
            0.1413926,  0.0599019,  0.7057489);
           
        float3x3 XYZ_to_D50 = float3x3(
            2.9603944, -0.9787684,  0.0844874,
            -1.4678519,  1.9161415, -0.2545973,
            -0.4685105,  0.0334540,  1.4216174);   

        float3 warmer = mul(D50_to_XYZ, color);
        warmer = mul(XYZ_to_D65, warmer); 
            
        float3 cooler = mul(D65_to_XYZ, color);
        cooler = mul(XYZ_to_D50, cooler);
            
        float m = abs(WP) / 100.0;
        float3 comp = (WP < 0.0) ? cooler : warmer;
        comp = clamp(comp, 0.0, 1.0);   
            
        color = float3(lerp(color, comp, m));
    }

    color = pow(color, float3(gamma_in, gamma_in, gamma_in));
        
    float lum = color.r * 0.4 + color.g * 0.5 + color.b * 0.1;
        
    float f = fp.y;
    float3 f1 = float3(f, f, f); 

    color = color * sw(f1,color) + color * sw(1.0 - f1,color);

    color *= mask(pos.xy * 1.0001, color,lum);
    if (slotmask != 0.0) color *= SlotMask(pos.xy * 1.0001, color);
        
    res = float4(color, 1.0);

    return res;
}

#endif