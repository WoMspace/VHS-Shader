#version 130

#extension GL_ARB_bindless_texture : require

#include "lib/Tonemapping.glsl"

// #define ENABLE_ACES

// #define ENABLE_DOF // Blurs things you're not looking at.
// #define DOF_MIP // Really low quality but fast blur.
#define DOF_STRENGTH 3.0 // How strong the blur should be. [1.0 2.0 3.0 4.0 5.0]

uniform sampler2D gcolor;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform float centerDepthSmooth;
const float centerDepthHalflife = 0.5; //in seconds

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

void main()
{
    vec3 color;
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
        blurAmount = clamp(blurAmount * DOF_STRENGTH * 0.01, 0.0, DOF_STRENGTH);
        
        #ifdef DOF_MIP
            color = textureLod(gcolor, texcoord, blurAmount).rgb;
        #endif
    #endif

    #ifdef ENABLE_ACES
        color = ACES_to_sRGB(color);
    #endif

    gl_FragColor = vec4(color, 1.0);
}