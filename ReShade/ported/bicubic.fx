#include "ReShade.fxh"

/*
   Copyright (C) 2010 Team XBMC
   http://www.xbmc.org
   Copyright (C) 2011 Stefanos A.
   http://www.opentk.com

   Ported by TheNeoDriver.

This Program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This Program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with XBMC; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
http://www.gnu.org/copyleft/gpl.html
*/

// Default to Mitchel-Netravali coefficients for best psychovisual result
// bicubic-sharp is B = 0.1 and C = 0.5
// bicubic-sharper is B = 0.0 and C = 0.75
uniform float B <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
    ui_step = 0.01;
	ui_label = "B coefficient [Bicubic]";
> = 0.33;

uniform float C <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_label = "C coefficient [Bicubic]";
> = 0.33;

uniform int ScaleX <
    ui_type = "slider";
    ui_min = 1;
    ui_max = BUFFER_WIDTH;
    ui_step = 1;
    ui_label = "Game scale X [Bicubic]";
> = 854;

uniform int ScaleY <
    ui_type = "slider";
    ui_min = 1;
    ui_max = BUFFER_HEIGHT;
    ui_step = 1;
    ui_label = "Game scale Y [Bicubic]";
> = 480;



float weight(float x)
{
	float ax = abs(x);

	if (ax < 1.0)
	{
		return
			(
			 pow(x, 2.0) * ((12.0 - 9.0 * B - 6.0 * C) * ax + (-18.0 + 12.0 * B + 6.0 * C)) +
			 (6.0 - 2.0 * B)
			) / 6.0;
	}
	else if ((ax >= 1.0) && (ax < 2.0))
	{
		return
			(
			 pow(x, 2.0) * ((-B - 6.0 * C) * ax + (6.0 * B + 30.0 * C)) +
			 (-12.0 * B - 48.0 * C) * ax + (8.0 * B + 24.0 * C)
			) / 6.0;
	}
	else
	{
		return 0.0;
	}
}


float4 weight4(float x)
{
	return float4(
		    weight(x - 2.0),
			weight(x - 1.0),
			weight(x),
			weight(x + 1.0));
}


float3 pixel(float xpos, float ypos)
{
	return tex2D(ReShade::BackBuffer, float2(xpos, ypos)).rgb;
}


float3 line_run(float ypos, float4 xpos, float4 linetaps)
{
	return
		pixel(xpos.r, ypos) * linetaps.r +
		pixel(xpos.g, ypos) * linetaps.g +
		pixel(xpos.b, ypos) * linetaps.b +
		pixel(xpos.a, ypos) * linetaps.a;
}

float4 PixelBicubic(float4 pos : SV_Position, float2 texcoord : TEXCOORD0) : SV_TARGET
{
    float2 stepxy = float2(1.0/ScaleX, 1.0/ScaleY);
    float2 position = texcoord + stepxy * 0.5;
    float2 f = (position / stepxy) - floor(position / stepxy);
		
	float4 linetaps = weight4(1.0 - f.x);
	float4 columntaps = weight4(1.0 - f.y);

	//make sure all taps added together is exactly 1.0, otherwise some (very small) distortion can occur
	linetaps /= linetaps.r + linetaps.g + linetaps.b + linetaps.a;
	columntaps /= columntaps.r + columntaps.g + columntaps.b + columntaps.a;

	float2 xystart = (-1.5 - f) * stepxy + position;
	float4 xpos = float4(xystart.x, xystart.x + stepxy.x, xystart.x + stepxy.x * 2.0, xystart.x + stepxy.x * 3.0);


    // final sum and weight normalization
    float4 final = float4(line_run(xystart.y, xpos, linetaps) * columntaps.r +
                        line_run(xystart.y + stepxy.y, xpos, linetaps) * columntaps.g +
                        line_run(xystart.y + stepxy.y * 2.0, xpos, linetaps) * columntaps.b +
                        line_run(xystart.y + stepxy.y * 3.0, xpos, linetaps) * columntaps.a, 1);

   return final;
}


technique bicubic {
    pass bicubic {
        VertexShader = PostProcessVS;
		PixelShader = PixelBicubic;
    }
}

