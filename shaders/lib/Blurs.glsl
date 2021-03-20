#define BLUR_STEPS 33.0 // How high quality the blur should be. [15.0 33.0 99.0]
#define DOF_STRENGTH 0.2 // How strong the blur should be. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.8 2.4 3.0 4.0]
#define DOF_ANAMORPHIC 1.0 // Aspect ratio of the bokeh. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#ifdef MC_GL_RENDERER_RADEON
    #define DOF_BOKEH_SAMPLES 128 // How many samples to use for the bokeh. [32 64 128 256 512 1024 2048]
#else
    #define DOF_BOKEH_SAMPLES 128 // How many samples to use for the bokeh. [32 64 128 256 512]
#endif
#define DOF_AUTOFOCUS -1
#define DOF_DISTANCE DOF_AUTOFOCUS // How should the focus be handled. [DOF_AUTOFOCUS 0 2 4 8 16 32 64 128 256 512]
#define DOF_BOKEH_MIPMAP // Smoothens a low bokeh sample count. Can make the bokeh pixellated.

#include "bokeh.glsl"

uniform float near;
uniform float far;
uniform float centerDepthSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform mat4 gbufferProjectionInverse;


float hPixelOffset = 1/viewWidth;
float vPixelOffset = 1/viewHeight;

float fragDepth(sampler2D depthTex, vec2 uv)
{
    float fragDistance = texture2D(depthTex, uv).r;
    return fragDistance;
}

float fragDistance(float fragDist)
{
    fragDist = abs((near * far) / (fragDist * (near - far) + far));
    fragDist = clamp(fragDist, 0.0, far);
    return fragDist;
}

float cursorDepth()
{
    vec3 screenPos = vec3(0.5, 0.5, centerDepthSmooth);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec2 viewpos = tmp.xz / tmp.w;
    return length(viewpos);
}

float cursorDistance(float cursorDist)
{
    #if DOF_DISTANCE == -1
            cursorDist = cursorDepth();
            cursorDist = clamp(cursorDist, 0.0, far);
    #else
            cursorDist = DOF_DISTANCE;
    #endif
    return cursorDist;
}

float findBlurAmount(float fragDistance, float cursorDistance)
{
    return abs(fragDistance - cursorDistance);
}

vec3 mipDoF(sampler2D gcolor, vec2 uv, float cursorDistance, sampler2D depthmap)
{
    return vec3(1.0);
}

/* Lets do an actual gaussian blur this time ( ͡° ͜ʖ ͡°) */
// https://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/

uniform float weight[33] = float[](0.180737794,	0.175260891,	0.159796695,	0.136968596,	0.110335813,	0.083497372,	0.05932708,	0.039551387,	0.024719617,	0.01447002,	0.007924058,	0.004054169,	0.001934944,	0.000859975,	0.000355207,	0.000136037,	4.81797E-05,	1.57321E-05,	4.71964E-06,	1.29559E-06,	3.23897E-07,	7.33352E-08,	1.49387E-08,	2.71612E-09,	4.36519E-10,	6.12658E-11,	7.39415E-12,	7.51948E-13,	6.26623E-14,	4.109E-15,	1.98823E-16,	6.31183E-18,	9.86224E-20);

vec3 gaussianHorizontal(sampler2D gcolor, vec2 uv, float blurAmount)
{
    hPixelOffset *= blurAmount;
    vec3 color = vec3(0.0);
    for(int i = 0; i < 33; i++)
    {
        color += texture2D(gcolor, vec2(uv.x + (i * hPixelOffset), uv.y)).rgb * weight[i] * 0.25;
    }
    for(int i = 1; i < 33; i++)
    {
        color += texture2D(gcolor, vec2(uv.x - (i * hPixelOffset), uv.y)).rgb * weight[i] * 0.25;
    }
    return color;
}

vec3 gaussianVertical(sampler2D gcolor, vec2 uv, float blurAmount)
{
    vPixelOffset *= blurAmount;
    vec3 color = vec3(0.0);
    for(int i = 0; i < 33; i++)
    {
        color += texture2D(gcolor, vec2(uv.x, uv.y + (i * vPixelOffset))).rgb * weight[i];
    }
    for(int i = 1; i < 33; i++)
    {
        color += texture2D(gcolor, vec2(uv.x, uv.y - (i * vPixelOffset))).rgb * weight[i];
    }
    return color;
}

/* Bokeh blur!!!!! */

vec3 bokehBlur(sampler2D gcolor, vec2 uv, float blurAmount)
{
    vec3 retColor = vec3(0.0);
    for(int i = 0; i < DOF_BOKEH_SAMPLES; i++)
    {
        float hOffset = uv.x + bokehOffsets[i].x * hPixelOffset * blurAmount;
        float vOffset = uv.y + bokehOffsets[i].y * vPixelOffset * blurAmount * DOF_ANAMORPHIC;
        #ifdef DOF_BOKEH_MIPMAP
            retColor += texture2DLod(gcolor, vec2(hOffset, vOffset), clamp(blurAmount * 0.1, 0.0, 4.0)).rgb / DOF_BOKEH_SAMPLES;
        #else
            retColor += texture2D(gcolor, vec2(hOffset, vOffset)).rgb / DOF_BOKEH_SAMPLES;
        #endif
    }
    return retColor;
}

vec3 bokehBlur3PleaseShootMe(sampler2D gcolor, vec2 uv, sampler2D depthmap)
{
    float cursorDist = cursorDistance(cursorDepth());
    float fragDist = fragDistance(fragDepth(depthmap, uv));
    float blurAmount = findBlurAmount(fragDist, cursorDist) * 0.01 * DOF_STRENGTH;

    vec3 retColor = vec3(0.0);
    int samples = 0;
    int attempts = 0;
    while(samples < DOF_BOKEH_SAMPLES && attempts < DOF_BOKEH_SAMPLES)
    {
        //float hOffset = uv.x + bokehOffsets[samples].x * hPixelOffset * blurAmount;
        //float vOffset = uv.y + bokehOffsets[samples].y * vPixelOffset * blurAmount * DOF_ANAMORPHIC;
        vec2 offset = vec2(uv.x + bokehOffsets[samples].x * hPixelOffset * blurAmount, uv.y + bokehOffsets[samples].y * vPixelOffset * blurAmount * DOF_ANAMORPHIC);
        if(texture2D(depthmap, uv).r < texture2D(depthmap, offset).r && ) {
            attempts++;
            retColor += texture2D(gcolor, offset).rgb;
            }
        else
        {
            #ifdef DOF_BOKEH_MIPMAP
                retColor += texture2DLod(gcolor, offset, clamp(blurAmount * 0.1, 0.0, 4.0)).rgb;
            #else
                retColor += texture2D(gcolor, offset).rgb;
            #endif
            samples++;
        }
    }
    //retColor = bokehBlur(gcolor, uv, blurAmount);
    return retColor / (samples + attempts);
    //return vec3(blurAmount);
}