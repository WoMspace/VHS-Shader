#version 130

/* THIS FILE IS FOR PRE-SCREEN EFFECTS
- Fog
- Dof pass 1
- Bloom pass 1
*/

#include "lib/Maths.glsl"
#include "lib/Blurs.glsl"

#define SHADER_FOG_ENABLED // Should the fog effect be used.
#define FOG_END far // How far away the fog should end. [32 64 128 far]
#define FOG_NEAR 32 // How far away the fog should start. [0 2 4 8 16 32 64]
#define WATER_FOG_R 0.1// Red channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_FOG_G 0.2// Green channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_FOG_B 0.5// Blue channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_FOG_DISTANCE 32.0 // How far the water fog should go. [16.0 32.0 64.0]
#define LAVA_FOG_R 1.0// Red channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LAVA_FOG_G 0.5// Green channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LAVA_FOG_B 0.0// Blue channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LAVA_FOG_DISTANCE 2.0 // How far the lava fog should go. [1.0 2.0 4.0 8.0]
#define pi 3.14159 //pi babey

// #define DOF_ENABLED // Adds Depth of Field
#define DOF_MIP 0 // Really low quality. Really fast.
#define DOF_GAUSSIAN 1 // Higher quality. Pretty fast.
#define DOF_BOKEH 2 // Very high quality. Slowest.
#define DOF_MODE DOF_BOKEH // Mipmap is REALLY fast, but low quality. Gaussian is pretty fast, but a lot higher quality. Bokeh is slowest, but REALLY high quality. [DOF_MIP DOF_GAUSSIAN DOF_BOKEH]
#define DOF_STRENGTH 0.2 // How strong the blur should be. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.8 2.4 3.0 4.0]
#define DOF_AUTOFOCUS -1
#define DOF_DISTANCE DOF_AUTOFOCUS // How should the focus be handled. [DOF_AUTOFOCUS 0 2 4 8 16 32 64 128 256 512]
const float centerDepthHalflife = 0.5; // How fast the focus should move. In seconds. [0.0 0.25 0.5 0.75 1.0 1.5 2.0]

// #define BLOOM_ENABLED // Should the bloom effect be used. Makes the image softer.
#define BLOOM_STRENGTH 1.0 // How strong should the bloom effect be. [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define BLOOM_THRESHOLD 0.1 // Minimum brightness for the bloom effect to work. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOOM_QUALITY 1.0 // Quality of the bloom effect. [2.0 1.0 0.5 0.2]

uniform sampler2D gcolor;
uniform int isEyeInWater;
uniform vec3 fogColor;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjectionInverse;
const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;

    #ifdef SHADER_FOG_ENABLED
		vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
		vec3 clipPos = screenPos * 2.0 - 1.0;
		vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
		vec3 viewPos = tmp.xyz / tmp.w;

		vec3 customFogColor;
		float fogNearValue;
		float fogFarValue;

		switch(isEyeInWater)
		{
			case 0: //air
				customFogColor = fogColor;
				fogNearValue = FOG_NEAR;
				fogFarValue = FOG_END;
				break;
			case 1: //water
				customFogColor = vec3(WATER_FOG_R, WATER_FOG_G, WATER_FOG_B);
				fogNearValue = 0.0;
				fogFarValue = WATER_FOG_DISTANCE;
				break;
			case 2: //lava
				customFogColor = vec3(LAVA_FOG_R, LAVA_FOG_G, LAVA_FOG_B);
				fogNearValue = 0.0;
				fogFarValue = LAVA_FOG_DISTANCE;
				break;
		}
		
		//float fogDensity = exp(-FOG_END * length(viewPos));
		if(texture2D(depthtex0, texcoord).r != 1.0)
		{
			color = mix(color, fogColor, clamp(((length(viewPos)-fogNearValue)/fogFarValue), 0.0, 1.0));
		}
	#endif

    #ifdef DOF_ENABLED
        float fragDistance = fragDepth(depthtex1, texcoord, gbufferProjectionInverse);
        
        fragDistance = abs((near * far) / (fragDistance * (near - far) + far));
        /*fragDistance = fragDistance * (near - far) + far;
        fragDistance = (near * far) / fragDistance;
        fragDistance = abs(fragDistance);*/

        fragDistance = clamp(fragDistance, 0.0, far);
        float cursorDistance;
        #if DOF_DISTANCE == -1
            cursorDistance = cursorDepth(gbufferProjectionInverse);
            cursorDistance = clamp(cursorDistance, 0.0, far);
        #else
            cursorDistance = DOF_DISTANCE;
        #endif
        float blurAmount = abs(fragDistance - cursorDistance);
        #if DOF_MODE == 0 //mip blur
            color = textureLod(gcolor, texcoord, clamp(blurAmount * DOF_STRENGTH * 2.0, 0.0, 4.0)).rgb;
        #endif
        #if DOF_MODE == 1 //GAUSSIAN_BLUR pass 1
            blurAmount = blurAmount * DOF_STRENGTH * 0.03;
            color = gaussianHorizontal(gcolor, texcoord, blurAmount);
        #endif
        #if DOF_MODE == 2 // Bokeh Blur
            //blurAmount = clamp(blurAmount * DOF_STRENGTH, 0.0, 10.0);
            blurAmount = blurAmount * DOF_STRENGTH * 0.05;
            color = bokehBlur(gcolor, texcoord, blurAmount);
        #endif
    #endif

    #ifdef BLOOM_ENABLED
    //color += threshold(gaussianHorizontal(gcolor, texcoord, BLOOM_SIZE) * BLOOM_STRENGTH, BLOOM_THRESHOLD);
    vec3 bloom = vec3(0.0);
    for(float i = 1.0; i < 11; i += BLOOM_QUALITY)
    {
        bloom += texture2DLod(gcolor, texcoord, i/2).rgb;
    }

    bloom = (bloom / (10 / BLOOM_QUALITY)) * BLOOM_STRENGTH;
    color += threshold(bloom, BLOOM_THRESHOLD);
    #endif

    //color = texture2DLod(gcolor, texcoord, 7.0).rgb;
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}