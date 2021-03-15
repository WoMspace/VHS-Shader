#version 130

// #define USE_INTERLACING // An interlacing effect. With help from Sir Bird.
#define INTERLACING_SIZE 4.0 // How big the interlaced lines are. Good for HiDPI displays. [2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 15.0 20.0 30.0 40.0 50.0]
// #define USE_GHOSTING // Ghosting effect.
#define GHOSTING_STRENGTH 0.7 // The strength of the ghosting. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]

uniform sampler2D gcolor;

varying vec2 texcoord;
varying vec4 gl_FragCoord;

#ifdef USE_INTERLACING
    uniform sampler2D colortex3;
    const bool colortex3Clear = false;

    uniform float viewHeight;
    uniform float viewWidth;

    uniform int frameCounter;
#endif
#ifdef USE_GHOSTING
    const bool colortex4Clear = false;
    uniform sampler2D colortex4;
#endif



void main()
{
    vec3 color = texture2D(gcolor, texcoord).rgb;
    
    vec3 color2ElectricBoogaloo = color;
    vec3 color3PlzShootMe = color;

    
    #ifdef USE_INTERLACING
        //if (sin(viewHeight*texcoord.y)*(mod(float(frameCounter),2.)*2.-1.) < 0.) //sir bird's version
        if(mod(gl_FragCoord.y, INTERLACING_SIZE) > (INTERLACING_SIZE - 1)*0.5)
        {
            color = texture2D(colortex3, texcoord).rgb;
        }
    #endif
    #ifdef USE_GHOSTING
        color3PlzShootMe = texture2D(colortex4, texcoord).rgb;
        color3PlzShootMe = mix(color3PlzShootMe, color, 1 - GHOSTING_STRENGTH);
        color = (color + color3PlzShootMe)*0.5;
    #endif
    /* DRAWBUFFERS:034 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
    gl_FragData[1] = vec4(color2ElectricBoogaloo, 1.0); //colortex3
    gl_FragData[2] = vec4(color3PlzShootMe, 1.0); //colortex4
}