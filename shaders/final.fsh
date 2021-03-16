#version 130

#include "lib/Tonemapping.glsl"

// #define ENABLE_ACES

uniform sampler2D gcolor;

varying vec2 texcoord;

void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;

    #ifdef ENABLE_ACES
        color = ACES_to_sRGB(color);
    #endif

    gl_FragColor = vec4(color, 1.0);
}