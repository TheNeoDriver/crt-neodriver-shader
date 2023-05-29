# Retroarch CRT-Neodriver Shader Preset
A simple CRT preset that allows you to look at older games the way they were designed to be played
while enjoying the colorful and vibrant visuals of your favorite video game.

This preset used some of the retroarch built-in shaders:
* Bicubic Shader;
* SGEN MIX Dithering;
* CRT-Consumer Shader (a little modified version to includ a custom background that you can replace).

From here you can obtain the preset for GLSL output configurations and SLANG configurations.
Additionaly, I made a profile preset for [ShaderGlass](https://github.com/mausimus/ShaderGlass) tool.
Is not too the same thing that you can obtain for RetroArch but is very similar.

# Licensing
This project can be used in the way you want in a totally free way.
However, this project has used some shaders that can be found in the [libreto shaders](https://github.com/libretro/slang-shaders/tree/master/crt).
Each one has its own license, so check each one for more detail.

# Context
I've created this shader preset with the intention of having a way to play old games just as I remembered them.
Old games were made to be played in old CRT TVs.

In the past, game consoles were not powerful enough to display many colors on the screen or to handle image transparency.
For this reason, at that time the technique known as Dithering was frequently used. It is based on drawing patterns of pixels that,
when them were mixed with the light dots of the old televisions, allowed a fluid blend of images. It was possible to
display images much more complex than what the console could actually display!

Today, we can generally play retro games and really see the pixel art they had, which while not bad,
is not the way a lot of games were actually intended to be played.

The most classic example is found in the waterfall of Sonic 1:

![Alt text](https://github.com/TheNeoDriver/crt-neodriver-shader/blob/main/images/comparison-2-1.jpg)

The art isn't bad, but looking closely at that waterfall... look like drops of water falling. Not really a waterfall.
Instead, in a CRT TV this should look like this:

![Alt text](https://github.com/TheNeoDriver/crt-neodriver-shader/blob/main/images/comparison-2-2.jpg)

Now we are talking. Look at that simulated transparency.
Well, this is just one example, but you can certainly discover much more in other different games.
I'll show you more examples of what this preset looks like in other parts of this game.

![Alt text](https://github.com/TheNeoDriver/crt-neodriver-shader/blob/main/images/comparison-1-1.jpg)
![Alt text](https://github.com/TheNeoDriver/crt-neodriver-shader/blob/main/images/comparison-1-2.jpg)


![Alt text](https://github.com/TheNeoDriver/crt-neodriver-shader/blob/main/images/comparison-3-1.jpg)
![Alt text](https://github.com/TheNeoDriver/crt-neodriver-shader/blob/main/images/comparison-3-2.jpg)

How I say before, you can replace the background.png with the whatever image you want. Even you can change Brightness of the border
in shader parameters. If you dont want a background, you can simply reduce the brightness to the minimum value.

Lastly, you can see an example of that waterfall animation in this youtube video:
[![Alt text](https://img.youtube.com/vi/m3OgrQE3h6U/0.jpg)](https://www.youtube.com/watch?v=m3OgrQE3h6U)
