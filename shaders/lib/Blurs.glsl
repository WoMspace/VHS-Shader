#ifndef BLUR_STEPS
    #define BLUR_STEPS 100.0
#endif

vec3 gaussianV(sampler2D gcolor, vec2 uv, float blurAmount, float height)
{//not actually a gaussian blur
    vec3 color = vec3(0.0);
    blurAmount = ceil(blurAmount);
    float vPixelOffset = uv.y / height;
    for(float i = -blurAmount; i < blurAmount; i += (blurAmount * 2) / BLUR_STEPS)
    {
        color += texture2D(gcolor, vec2(uv.x, uv.y + i*vPixelOffset)).rgb / BLUR_STEPS;
    }
    return color;
}

vec3 gaussianH(sampler2D gcolor, vec2 uv, float blurAmount, float width)
{//not actually a gaussian blur
    vec3 color = vec3(0.0);
    blurAmount = ceil(blurAmount);
    float hPixelOffset = uv.x / width;
    for(float i = -blurAmount; i < blurAmount; i += (blurAmount * 2) / BLUR_STEPS)
    {
        color += texture2D(gcolor, vec2(uv.x + i*hPixelOffset, uv.y)).rgb / BLUR_STEPS;
    }
    return color;
}