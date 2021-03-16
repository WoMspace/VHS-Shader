#version 130

#include "lib/Blurs.glsl"

// #define ENABLE_DOF
#define DOF_GAUSSIAN
#define DOF_STRENGTH 3.0 // How strong the blur should be. [1.0 2.0 3.0 4.0 5.0]

uniform sampler2D gcolor;
uniform float viewHeight;
uniform float viewWidth;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjectionInverse;
uniform float centerDepthSmooth;

const float centerDepthHalflife = 0.5; //in seconds

varying vec2 texcoord;

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;

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
            blurAmount = blurAmount * DOF_STRENGTH;
            color = gaussianH(gcolor, texcoord, blurAmount, viewWidth);
        #endif
    #endif


    gl_FragColor = vec4(color, 1.0);
}