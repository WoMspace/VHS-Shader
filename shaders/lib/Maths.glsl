vec2 clip(vec2 p)
{
    p = (p*2.0) - 1.0;//clip space
    return p;
}
vec2 unclip(vec2 p)
{
    p = (p+1.0)*0.5;//unclip space
	return p;
}

vec2 distort(vec2 temptexcoord, float strength) //THANKYOU JustTech#2594 from sLABS!
{//converts UVs to polar coordinates and back again. FOV dependant :D
    vec2 clipcoord = temptexcoord - vec2(0.5);
    float polarAngle = atan(clipcoord.x, clipcoord.y);
    float polarDistance = length(clipcoord);
    float distortAmount = strength * (-1.0);
    polarDistance = polarDistance * (1.0 + distortAmount * polarDistance * polarDistance);
    vec2 distortedUVs = vec2(0.5) + vec2(sin(polarAngle), cos(polarAngle)) * polarDistance;
    return distortedUVs;
}

float average(vec3 incolor)
{
    return (incolor.r + incolor.g + incolor.b) / 3;
}

float threshold(float color, float threshold)
{
    float tmp = clamp(color - threshold, 0.0, 1.0);
    tmp *= threshold * 10.0;
    return tmp;
}

vec3 threshold(vec3 color, float threshold)
{
    vec3 tmp = clamp(color - threshold, 0.0, 1.0);
    //tmp *= threshold * 10.0;
    return tmp;
}

float generateNoise(vec2 pos, float temporal)
{
    float noise = fract(sin(dot(pos, vec2(12.9898, 78.233 * temporal))) * 43758.5453);
    return noise;
}

vec2 generateNoiseV2(vec2 pos, float temporal)
{
    vec2 noise = vec2(fract(sin(dot(pos, vec2(12.9898, temporal))) * 18381.132313), fract(sin(dot(pos, vec2(12.9898, temporal))) * 18381.132313));
    return noise;
}

vec2 GetV2Noise(vec2 coord) {
    return vec2(
        fract(sin(dot(coord.xy, vec2(12.9898, 78.233))) * 43758.5453),
        fract(cos(dot(coord.xy, vec2(11.9898, 58.233))) * 43758.5453)
    );
}