#version 130

/* THIS FILE IS FOR CAMERA ENCODING EFFECTS
- Dof pass 2
- Grain
- Chroma Sampling
- INTERLACING
*/

#include "lib/Blurs.glsl"

// #define ENABLE_DOF // Adds Depth of Field
#define DOF_MIP 0 // Really low quality. Really fast.
#define DOF_GAUSSIAN 1 // Higher quality. Pretty fast.
#define DOF_BOKEH 2 // Very high quality. Slowest.
#define DOF_MODE DOF_GAUSSIAN // Mipmap is REALLY fast, but low quality. Gaussian is pretty fast, but a lot higher quality. Bokeh is slowest, but REALLY high quality. [DOF_MIP DOF_GAUSSIAN DOF_BOKEH]
#define DOF_STRENGTH 0.2 // How strong the blur should be. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define GRAIN_STRENGTH 0.15 // How strong the noise is. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50]
#define GRAIN_ENABLED // Should the grain effect be used.
const int noiseTextureResolution = 512; // Size of the noise texture. Smaller number = bigger noise. [64 128 256 512 1024]

#define CHROMA_SAMPLING_SIZE 4.0// How big the chroma subsampling should be. Larger number = bigger artefacting.[1.0 2.0 3.0 4.0 5.0]
#define CHROMA_SAMPLING_ENABLED // Should the chroma sub-sampling effect be used.

// #define INTERLACING_ENABLED // An interlacing effect. With help from Sir Bird.
#define INTERLACING_SIZE 4.0 // How big the interlaced lines are. Good for HiDPI displays. [2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 30.0 40.0 50.0]

uniform sampler2D gcolor;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjectionInverse;
uniform float viewHeight;
uniform float viewWidth;
uniform sampler2D noisetex;
uniform sampler2D colortex2;
const bool colortex2Clear = false;
const bool colortex0MipmapEnabled = true;
uniform int frameCounter;

varying vec2 texcoord;

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;

    #ifdef ENABLE_DOF
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
        #if DOF_MODE == 1 //gaussian blur
            //blurAmount = clamp(blurAmount * DOF_STRENGTH, 0.0, DOF_STRENGTH * 10.0);
            blurAmount = blurAmount * DOF_STRENGTH * 0.5;
            color = gaussianV(gcolor, texcoord, blurAmount, viewHeight);
        #endif
    #endif

    #ifdef GRAIN_ENABLED	
		float noiseSeed = frameCounter * 0.11;
		vec2 noiseCoord = texcoord + vec2(sin(noiseSeed), cos(noiseSeed));
		color -= texture2D(noisetex, noiseCoord).rgb*GRAIN_STRENGTH;
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