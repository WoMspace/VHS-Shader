#version 130

/* THIS FILE IS FOR CAMERA ENCODING EFFECTS
- Dof pass 2
- Greyscale
- Grain
- Chroma Sub-Sampling
- INTERLACING
*/

#include "lib/Maths.glsl"
#include "lib/Blurs.glsl"

// #define DOF_ENABLED // Adds Depth of Field
#define DOF_MIP 0 // Really low quality. Really fast.
#define DOF_GAUSSIAN 1 // Higher quality. Pretty fast.
#define DOF_BOKEH 2 // Very high quality. Slowest.
#define DOF_MODE DOF_BOKEH // Mipmap is REALLY fast, but low quality. Gaussian is pretty fast, but a lot higher quality. Bokeh is slowest, but REALLY high quality. [DOF_MIP DOF_GAUSSIAN DOF_BOKEH]
#define DOF_STRENGTH 0.2 // How strong the blur should be. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define FILM_DISABLED 0
#define FILM_GREYSCALE 1 // Black and white like a film camera.
#define FILM_COLOR 2 // Color film, like a Kodak Gold film.
#define FILM_MODE FILM_DISABLED // Film emulation. [FILM_DISABLED FILM_GREYSCALE FILM_COLOR]
#if FILM_MODE != 0
#define FILM_BRIGHTNESS 0.0 // How bright the image should be. [-1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define FILM_CONTRAST 1.0 // How much contrast the film-like image should have. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#endif
#if FILM_MODE == 1
#define GREYSCALE_RED_CONTRIBUTION 1.0 // How much red should affect total luminance. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define GREYSCALE_GREEN_CONTRIBUTION 1.0 // How much green should affect total luminance. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define GREYSCALE_BLUE_CONTRIBUTION 1.0 // How much blue should affect total luminance. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#endif
#if FILM_MODE == 2
#define COLORFILM_SATURATION 1.0 // no idea how to implement this but it's important :P
#define COLORFILM_STRENGTH 1.0 // How strong the film color simulation should be. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#endif

#define GRAIN_STRENGTH 0.15 // How strong the noise is. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50]
#define GRAIN_ENABLED // Should the grain effect be used.
const int noiseTextureResolution = 512; // Size of the noise texture. Smaller number = bigger noise. [64 128 256 512 1024 2048]

#define CHROMA_SAMPLING_SIZE 4.0// How big the chroma subsampling should be. Larger number = bigger artefacting.[1.0 2.0 3.0 4.0 5.0]
#define CHROMA_SAMPLING_ENABLED // Should the chroma sub-sampling effect be used.

// #define INTERLACING_ENABLED // An interlacing effect. With help from Sir Bird.
#define INTERLACING_SIZE 4.0 // How big the interlaced lines are. Good for HiDPI displays. [2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 30.0 40.0 50.0]

uniform sampler2D gcolor;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D noisetex;
uniform sampler2D colortex2;
const bool colortex2Clear = false;
const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;

    #ifdef BLOOM_ENABLED
    // do nothing lmao
    #endif

    #ifdef DOF_ENABLED
        #if DOF_MODE == 1 //gaussian blur
            float fragDistance = fragDepth(depthtex1, texcoord, gbufferProjectionInverse);
            float cursorDistance = cursorDepth(gbufferProjectionInverse);
            fragDistance = abs((near * far) / (fragDistance * (near - far) + far));

            cursorDistance = clamp(cursorDistance, 0.0, far);
            fragDistance = clamp(fragDistance, 0.0, far);

            float blurAmount;
            if(fragDistance > cursorDistance)
            {
                blurAmount = fragDistance - cursorDistance;
            }
            else
            {
                blurAmount = cursorDistance - fragDistance;
            }
            //blurAmount = clamp(blurAmount * DOF_STRENGTH, 0.0, DOF_STRENGTH * 10.0);
            blurAmount = blurAmount * DOF_STRENGTH * 0.03;
            color = gaussianVertical(gcolor, texcoord, blurAmount);
        #endif
    #endif

    #ifdef GRAIN_ENABLED	
		float noiseSeed = float(frameCounter) * 0.11;
		vec2 noiseCoord = texcoord + vec2(sin(noiseSeed), cos(noiseSeed));
		color -= texture2D(noisetex, noiseCoord).rgb*GRAIN_STRENGTH;
	#endif

    #if FILM_MODE == 1 // B&W
        vec3 greyscaleColor;
        greyscaleColor.r = color.r * GREYSCALE_RED_CONTRIBUTION;
        greyscaleColor.g = color.g * GREYSCALE_GREEN_CONTRIBUTION;
        greyscaleColor.b = color.b * GREYSCALE_BLUE_CONTRIBUTION;

        greyscaleColor += FILM_BRIGHTNESS + 0.5;
        greyscaleColor *= FILM_CONTRAST;
        greyscaleColor -= FILM_BRIGHTNESS + 0.5;

        color = vec3((greyscaleColor.r + greyscaleColor.g + greyscaleColor.b) / 3);
    #endif
    #if FILM_MODE == 2 // Color film
        vec3 filmColorHighlights = vec3(1.5, 1.0, 1.0);
        vec3 filmColorShadows = vec3(1.0, 1.0, 1.5);
        vec3 colorFilm = color;
        colorFilm += FILM_BRIGHTNESS + 0.5;
        colorFilm *= FILM_CONTRAST;
        if(colorFilm.r > 0)
        {
            colorFilm.r *= filmColorHighlights.r * COLORFILM_STRENGTH;
        }
        if(colorFilm.g > 0)
        {
            colorFilm.g *= filmColorHighlights.g * COLORFILM_STRENGTH;
        }
        if(colorFilm.b > 0)
        {
            colorFilm.b *= filmColorHighlights.b * COLORFILM_STRENGTH;
        }

        if(colorFilm.r < 0)
        {
            colorFilm.r *= filmColorShadows.r * COLORFILM_STRENGTH;
        }
        if(colorFilm.g < 0)
        {
            colorFilm.g *= filmColorShadows.g * COLORFILM_STRENGTH;
        }
        if(colorFilm.b < 0)
        {
            colorFilm.b *= filmColorShadows.b * COLORFILM_STRENGTH;
        }
        colorFilm -= FILM_BRIGHTNESS + 0.5;
        color = colorFilm;
    #endif

    #ifdef CHROMA_SAMPLING_ENABLED
		vec3 chroma = normalize(textureLod(gcolor, texcoord, CHROMA_SAMPLING_SIZE).rgb);
		float luma = (color.r + color.g + color.b / 3.0);
		color = chroma * luma * 0.9;
	#endif

    vec3 color2 = color;
    #ifdef INTERLACING_ENABLED
        if(mod(gl_FragCoord.y, INTERLACING_SIZE) > (INTERLACING_SIZE - 1.0)*0.5)
        {
            color = texture2D(colortex2, texcoord).rgb;
        }
    #endif
    
    /* DRAWBUFFERS:02 */
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(color2, 1.0);
}