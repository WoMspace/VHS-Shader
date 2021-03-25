#version 130

/* THIS FILE IS FOR PLAYBACK EFFECTS
- Scanlines
- GHOSTING
- BARREL DISTORTION
*/

#include "lib/Maths.glsl"

#define SCANLINE_DISTANCE 5 // How many pixels between each line. [1 2 3 4 5 6 7 8 9 10 20 30 40 50 100 200]
#define SCANLINE_STRENGTH 0.1 // How strong the scanline effect is. [0.01 0.05 0.1 0.2 0.3 0.4 0.5]
#define SCANLINE_THICKNESS 1 // How thick the lines are. [1 2 3 4 5 6 7 8 9 10]
#define SCANLINE_MODE_OFF 0
#define SCANLINE_MODE_WOMSPACE 1
#define SCANLINE_MODE_SIRBIRD 2
#define SCANLINE_MODE_CRT 3
#define SCANLINE_MODE_CRT_TEXTURE 4
#define SCANLINE_MODE SCANLINE_MODE_WOMSPACE // Which Scanline effect to use. [SCANLINE_MODE_OFF SCANLINE_MODE_WOMSPACE SCANLINE_MODE_SIRBIRD SCANLINE_MODE_CRT]
// #define CRT_TEXTURE_ENABLED // Should the CRT texture be used. Disabling this will use a pixel perfect, but less authentic CRT mode.
#define CRT_BOOST 0.1 // Boosts the brightness a bit to make it less dark. [0.0 0.1 0.2 0.3 0.4 0.5]
#define CRT_TEXTURE_SCALE 3.0 // How small should the CRT texture be. [1.0 2.0 3.0 4.0]
#if SCANLINE_MODE == 3
	#ifdef CRT_TEXTURE_ENABLED
		uniform sampler2D colortex4;
	#endif
#endif

// #define GHOSTING_ENABLED // Ghosting effect.
#define GHOSTING_STRENGTH 0.7 // The strength of the ghosting. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]

// #define BARREL_DISTORTION_ENABLED // Causes a rounding of the image.
#define BARREL_POWER -0.5 // How strong the lens distortion should be. Negative = Barrel Distortion. Positive = Pincushion Distortion. [-1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BARREL_CLIP_BLACK 0
#define BARREL_CLIP_ZOOM 1
#define BARREL_CLIP_OFF 2
#define BARREL_CLIP_MODE BARREL_CLIP_BLACK // How should barrel distortion artefacts be fixed. Black fills in the broken areas with black. Zoom enlarges the image to hide the broken areas. [BARREL_CLIP_BLACK BARREL_CLIP_ZOOM BARREL_CLIP_OFF]

uniform sampler2D gcolor;
uniform sampler2D colortex3;
const bool colortex3Clear = false;
uniform mat4 gbufferProjection;
uniform float viewHeight;
uniform float viewWidth;
uniform int frameCounter;
varying vec2 texcoord;

void main()
{
    vec2 newtexcoord = texcoord;

    #ifdef BARREL_DISTORTION_ENABLED
        float fov = 2 * atan(1 / gbufferProjection[0][0]);
        newtexcoord = distort(newtexcoord, BARREL_POWER * fov * 0.5);
		#if BARREL_CLIP_MODE == 1 //zoom
			newtexcoord = clip(newtexcoord);
			newtexcoord *= fov * 0.3;
			newtexcoord = unclip(newtexcoord);
		#endif
    #endif

    vec3 color = texture2D(gcolor, newtexcoord).rgb;

    #if SCANLINE_MODE != 0
		#if SCANLINE_MODE == 1 // WoMspace Scanlines
			if(mod(gl_FragCoord.y, SCANLINE_DISTANCE) < SCANLINE_THICKNESS)
			{
				color -= SCANLINE_STRENGTH;
			}
		#endif
		#if SCANLINE_MODE == 2 // SirBird Scanlines
			color *= 0.92+0.08*(0.05-pow(clamp(sin(viewHeight/2.*newtexcoord.y+frameCounter/5.),0.,1.),1.5));
		#endif
        #if SCANLINE_MODE == 3 //CRT Mode
			#ifdef CRT_TEXTURE_ENABLED // CRT TEXTURE (courtesy of s o u l n a t e#3527)
				vec2 CRTtexcoord = vec2(texcoord.x * (viewWidth/1500) * CRT_TEXTURE_SCALE, texcoord.y * (viewHeight/1500) * CRT_TEXTURE_SCALE);
				color *= texture2D(colortex4, CRTtexcoord).rgb;
			#else
				float moduloPixLoc = mod(gl_FragCoord.x, 3);
				if(mod(gl_FragCoord.y, 4) > 1)
				{
					if(moduloPixLoc > 0 && moduloPixLoc < 1)
					{
						color = vec3(color.r, 0.0, 0.0);
					}
					if(moduloPixLoc > 1 && moduloPixLoc < 2)
					{
						color = vec3(0.0, color.g, 0.0);
					}
					if(moduloPixLoc > 2 && moduloPixLoc < 3)
					{
						color = vec3(0.0, 0.0, color.b);
					}
				}
				else
				{
					color = vec3(CRT_BOOST);
				}
			#endif
		#endif
	#endif

    vec3 color2 = vec3(0.0);

    #ifdef GHOSTING_ENABLED
        color2 = texture2D(colortex3, texcoord).rgb;
        color2 = mix(color2, color, 1 - GHOSTING_STRENGTH);
        color = (color + color2)*0.5;
    #endif

    #ifdef BARREL_DISTORTION_ENABLED
		#if BARREL_CLIP_MODE == 0 //black bars
		if(newtexcoord.x < 0.0 || newtexcoord.x > 1.0) { color = vec3(0.0); }
		if(newtexcoord.y < 0.0 || newtexcoord.y > 1.0) { color = vec3(0.0); }
		#endif
		#if BARREL_CLIP_MODE == 2 //off
		// :)
		#endif
	#endif

    /* DRAWBUFFERS:03 */
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(color2, 1.0);
}