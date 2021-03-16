#define BLUR_STEPS 33.0 // How high quality the blur should be. [15.0 33.0 99.0]

uniform float near;
uniform float far;
uniform float centerDepthSmooth;

float fragDepth(sampler2D depthTex, vec2 uv, mat4 gbufferProjectionInverse)
{
    float fragDistance = texture2D(depthTex, uv).r;
    return fragDistance;
}
float cursorDepth(mat4 gbufferProjectionInverse)
{
    vec3 screenPos = vec3(0.5, 0.5, centerDepthSmooth);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec2 viewpos = tmp.xz / tmp.w;
    float cursorDistance = length(viewpos);
    return cursorDistance;
}

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