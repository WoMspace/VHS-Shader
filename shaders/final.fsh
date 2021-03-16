#version 130

//#extension GL_ARB_bindless_texture : require

#include "lib/Tonemapping.glsl"
#include "lib/Blurs.glsl"

// #define ENABLE_ACES

// #define ENABLE_DOF // Blurs things you're not looking at.
// #define DOF_MIP // Really low quality. Really fast.
#define DOF_GAUSSIAN // MUCH higher quality. Pretty fast.
#define DOF_STRENGTH 3.0 // How strong the blur should be. [1.0 2.0 3.0 4.0 5.0]
#ifndef BLUR_STEPS
    #define BLUR_STEPS 10.0 // How many blur iterations. [5.0 10.0 15.0 20.0 25.0 30.0]
#endif

uniform sampler2D gcolor;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform float centerDepthSmooth;
uniform float viewHeight;
uniform float viewWidth;
const float centerDepthHalflife = 0.5; //in seconds

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

void main()
{
    vec3 color = vec3(0.0);
    #ifndef ENABLE_DOF
        color = texture2D(gcolor, texcoord).rgb;
    #endif
    
    #ifdef ENABLE_DOF
		vec3 screenPos = vec3(texcoord, texture2D(depthtex1, texcoord).r);
		vec3 clipPos = screenPos * 2.0 - 1.0;
		vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
		vec3 viewPos = tmp.xyz / tmp.w;
        float fragDistance = length(viewPos);
        
        screenPos = vec3(0.5, 0.5, centerDepthSmooth);
		clipPos = screenPos * 2.0 - 1.0;
        tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
		viewPos = tmp.xyz / tmp.w;        
        float cursorDepth = length(viewPos);

        float blurAmount;
        if(fragDistance > cursorDepth)
        {
            blurAmount = fragDistance - cursorDepth;
        }
        else
        {
            blurAmount = (cursorDepth - fragDistance) * 2.0;
        }

        #ifdef DOF_GAUSSIAN
            blurAmount = clamp(blurAmount * DOF_STRENGTH, 0.0, DOF_STRENGTH * 10.0);
            color = gaussianV(gcolor, texcoord, blurAmount, viewHeight);
        #endif

        #ifdef DOF_MIP
            blurAmount = clamp(blurAmount * DOF_STRENGTH * 0.01, 0.0, DOF_STRENGTH);
            blurAmount = blurAmount * DOF_STRENGTH;
            color = textureLod(gcolor, texcoord, blurAmount).rgb;
        #endif
    #endif

    #ifdef ENABLE_ACES
        color = ACES_to_sRGB(color);
    #endif

    gl_FragColor = vec4(color, 1.0);
}