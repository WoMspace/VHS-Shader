#version 130

// #define USE_INTERLACING // An interlacing effect. With help from Sir Bird.

uniform sampler2D gcolor;

varying vec2 texcoord;
varying vec4 gl_FragCoord;

#ifdef USE_INTERLACING
    uniform sampler2D colortex4;

    const bool colortex0MipmapEnabled = true;
    const bool colortex4Clear = false;
    uniform float viewHeight;
    uniform float viewWidth;

    uniform int frameCounter;
#endif

void main()
{
    vec2 offset = vec2(0.0, 0.0);
    vec3 color = texture2D(gcolor, texcoord + offset).rgb;
    #ifdef USE_INTERLACING
        //color += texture2DLod(gcolor, texcoord + offset, 2.0).rgb;
        //color *= 0.5;
        //if (sin(viewHeight*texcoord.y)*(mod(float(frameCounter),2.)*2.-1.) < 0.)//mod(frameCounter, 2.0) > 0.0 ^^ mod(gl_FragCoord.y, 2.0) > 0.0)
        if(mod(gl_FragCoord.y, 4.0) > 1.5)
        {
            color = texture2D(colortex4, texcoord).rgb;
            //color = vec3(1.0, 0.0, 0.0);
        }
    #endif

    /* DRAWBUFFERS:01234 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
    gl_FragData[4] = vec4(color, 1.0); //gcolor
}