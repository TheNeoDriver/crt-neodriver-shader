#ifndef _SHARED_COMPONENTS
#define _SHARED_COMPONENTS

#include "ReShade.fxh"

uniform int GameScale <
    ui_type = "slider";
	ui_min = 1;
	ui_max = BUFFER_HEIGHT;
    ui_step = 12;
	ui_label = "Game Screen Scale [CRT-Consumer]";
> = BUFFER_HEIGHT;

#endif