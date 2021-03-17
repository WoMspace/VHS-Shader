#define BLUR_STEPS 33.0 // How high quality the blur should be. [15.0 33.0 99.0]

uniform float near;
uniform float far;
uniform float centerDepthSmooth;
uniform float viewWidth;
uniform float viewHeight;

float hPixelOffset = 1/viewWidth;
float vPixelOffset = 1/viewHeight;

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


/* Lets do an actual gaussian blur this time ( ͡° ͜ʖ ͡°) */
// https://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/

//uniform float weight[5] = float[](0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162);
//uniform float weight[7] = float[](0.1766522545, 0.1605929586, 0.120444719, 0.07411982705, 0.03705991353, 0.01482396541, 0.004632489191);
//uniform float weight[16] = float[](0.279847742,	0.246924479,	0.192052372,	0.131404255,	0.078842553,	0.04129848,	0.018772036,	0.007345579,	0.002448526,	0.000685587,	0.000158212,	2.92986E-05,	4.18552E-06,	4.32984E-07,	2.88656E-08,	9.31149E-10);
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

/* Bokeh blur????????? */

vec3 bokehBlur(sampler2D gcolor, vec2 uv, float blurAmount)
{
    vec3 retColor = vec3(0.0);
    for(int angle = 0; angle < BLUR_STEPS; angle++)
    {
        for(int dist = 0; dist < blurAmount; dist++)
        {
            retColor += texture2D(gcolor, vec2(uv.x + (dist * cos(angle) * hPixelOffset), uv.y + (dist * sin(angle) * vPixelOffset))).rgb / BLUR_STEPS;
        }
    }
    return retColor;
}



/* For posterity: my first gaussian blur :>

vec3 fakeGaussianHorizontal(sampler2D gcolor, vec2 uv, float blurAmount, float height)
{//not actually a gaussian blur
    vec3 color = vec3(0.0);
    blurAmount = ceil(blurAmount);
    float vPixelOffset = 1 / height;
    for(float i = -blurAmount; i < blurAmount; i += (blurAmount * 2) / BLUR_STEPS)
    {
        color += texture2D(gcolor, vec2(uv.x, uv.y + i*vPixelOffset)).rgb / BLUR_STEPS;
    }
    return color;
}

vec3 fakeGaussianVertical(sampler2D gcolor, vec2 uv, float blurAmount, float width)
{//not actually a gaussian blur
    vec3 color = vec3(0.0);
    blurAmount = ceil(blurAmount);
    float hPixelOffset = 1 / width;
    for(float i = -blurAmount; i < blurAmount; i += (blurAmount * 2) / BLUR_STEPS)
    {
        color += texture2D(gcolor, vec2(uv.x + i*hPixelOffset, uv.y)).rgb / BLUR_STEPS;
    }
    return color;
} */