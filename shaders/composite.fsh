#version 130

#define CHROMA_SAMPLING_SIZE 4.0// How big the chroma subsampling should be. Larger number = bigger artefacting.[1.0 2.0 3.0 4.0 5.0]
#define CHROMA_SAMPLING_ENABLED // Should the chroma sub-sampling effect be used.

// #define BARREL_DISTORTION // Causes a rounding of the image.
#define BARREL_POWER -0.5 // How strong the lens distortion should be. Negative = Barrel Distortion. Positive = Pincushion Distortion. [-0.5 -0.4 -0.3 -0.2 -0.1 0.1 0.2 0.3 0.4 0.5]
#define BARREL_CLIP_BLACK 0
#define BARREL_CLIP_ZOOM 1
#define BARREL_CLIP_OFF 2
#define BARREL_CLIP_MODE BARREL_CLIP_BLACK // How should barrel distortion artefacts be fixed. Black fills in the broken areas with black. Zoom enlarges the image to hide the broken areas! BROKEN! [BARREL_CLIP_BLACK BARREL_CLIP_ZOOM BARREL_CLIP_OFF]

#define SCANLINE_DISTANCE 5 // How many pixels between each line. [1 2 3 4 5 6 7 8 9 10 20 30 40 50 100 200]
#define SCANLINE_STRENGTH 0.1 // How strong the scanline effect is. [0.01 0.05 0.1 0.2 0.3 0.4 0.5]
#define SCANLINE_THICKNESS 1 // How thick the lines are. [1 2 3 4 5 6 7 8 9 10]
#define SCANLINE_MODE_OFF 0
#define SCANLINE_MODE_WOMSPACE 1
#define SCANLINE_MODE_SIRBIRD 2
#define SCANLINE_MODE_CRT 3
#define SCANLINE_MODE SCANLINE_MODE_WOMSPACE // Which Scanline effect to use. [SCANLINE_MODE_OFF SCANLINE_MODE_WOMSPACE SCANLINE_MODE_SIRBIRD SCANLINE_MODE_CRT]
#define CRT_BOOST 0.1 // Boosts the brightness a bit to make it less dark. [0.0 0.1 0.2 0.3 0.4 0.5]

const int noiseTextureResolution = 512; // Size of the noise texture. Smaller number = bigger noise. [64 128 256 512 1024]
#define GRAIN_STRENGTH 0.15 // How strong the noise is. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50]
#define GRAIN_ENABLED // Should the grain effect be used.

#define ROUND_FOG_ENABLED // Should the fog effect be used.
#define FOG_END far // How far away the fog should end. [32 64 128 far]
#define FOG_NEAR 32 // How far away the fog should start. [0 2 4 8 16 32 64]
#define WATER_FOG_R 0.1// Red channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_FOG_G 0.2// Green channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_FOG_B 0.5// Blue channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_FOG_DISTANCE 32.0 // How far the water fog should go. [16.0 32.0 64.0]
#define LAVA_FOG_R 1.0// Red channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LAVA_FOG_G 0.5// Green channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LAVA_FOG_B 0.0// Blue channel of the water fog. [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LAVA_FOG_DISTANCE 2.0 // How far the lava fog should go. [1.0 2.0 4.0 8.0]
#define pi 3.14159 //pi babey


uniform sampler2D gcolor;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 fogColor;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform int isEyeInWater; //0 = air, 1 = water, 2 = lava

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

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

void main() {

	float fov =(2 * atan(1 / gbufferProjection[0][0]));

    vec2 newtexcoord = texcoord;
    #ifdef BARREL_DISTORTION
        newtexcoord = distort(newtexcoord, BARREL_POWER * fov * 0.5);
    #endif

	vec3 color = texture2D(gcolor, newtexcoord).rgb;

	#if SCANLINE_MODE != 0
		#if SCANLINE_MODE == 1
			if(mod(gl_FragCoord.y, SCANLINE_DISTANCE) < SCANLINE_THICKNESS)
			{
				color -= SCANLINE_STRENGTH;
			}
		#endif
		#if SCANLINE_MODE == 2
			color *= 0.92+0.08*(0.05-pow(clamp(sin(viewHeight/2.*texcoord.y+frameCounter/5.),0.,1.),1.5));
		#endif
		#if SCANLINE_MODE == 3
			float moduloPixLoc = mod(gl_FragCoord.x, 3);
			if(mod(gl_FragCoord.y, 4) > 1)
			{
				if(moduloPixLoc < 1)
				{
					color = vec3(color.r, 0.0, 0.0);
				}
				if(moduloPixLoc < 2 && moduloPixLoc > 1)
				{
					color = vec3(0.0, color.g, 0.0);
				}
				if(moduloPixLoc < 3 && moduloPixLoc > 2)
				{
					color = vec3(0.0, 0.0, color.b);
				}
			}
			else
			{
				color = vec3(CRT_BOOST);
			}
		#endif
	#endif

	#ifdef CHROMA_SAMPLING_ENABLED
		vec3 chroma = normalize(textureLod(gcolor, newtexcoord, CHROMA_SAMPLING_SIZE).rgb);
		float luma = (color.r + color.g + color.b / 3.0);
		color = chroma * luma * 0.9;
	#endif

	#ifdef ROUND_FOG_ENABLED
		vec3 screenPos = vec3(newtexcoord, texture2D(depthtex0, newtexcoord).r);
		vec3 clipPos = screenPos * 2.0 - 1.0;
		vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
		vec3 viewPos = tmp.xyz / tmp.w;

		vec3 customFogColor;
		float fogNearValue;
		float fogFarValue;

		switch(isEyeInWater)
		{
			case 0: //air
				customFogColor = fogColor;
				fogNearValue = FOG_NEAR;
				fogFarValue = FOG_END;
				break;
			case 1: //water
				customFogColor = vec3(WATER_FOG_R, WATER_FOG_G, WATER_FOG_B);
				fogNearValue = 0.0;
				fogFarValue = WATER_FOG_DISTANCE;
				break;
			case 2: //lava
				customFogColor = vec3(LAVA_FOG_R, LAVA_FOG_G, LAVA_FOG_B);
				fogNearValue = 0.0;
				fogFarValue = LAVA_FOG_DISTANCE;
				break;
		}
		
		//float fogDensity = exp(-FOG_END * length(viewPos));
		if(texture2D(depthtex0, newtexcoord).r != 1.0)
		{
			color = mix(color, fogColor, clamp(((length(viewPos)-fogNearValue)/fogFarValue), 0.0, 1.0));
		}
		
	#endif

	
	#ifdef BARREL_DISTORTION
		#if BARREL_CLIP_MODE == 0 //black bars
		if(newtexcoord.x < 0.0 || newtexcoord.x > 1.0) { color = vec3(0.0); }
		if(newtexcoord.y < 0.0 || newtexcoord.y > 1.0) { color = vec3(0.0); }
		#endif
		#if BARREL_CLIP_MODE == 1 //zoom
			vec2 cliptexcoord = clip(newtexcoord);
			cliptexcoord *= 2;
			newtexcoord = unclip(cliptexcoord);//zoom in
		#endif
		#if BARREL_CLIP_MODE == 2 //off
		// :)
		#endif
	#endif

	#ifdef GRAIN_ENABLED	
		float noiseSeed = frameCounter * 0.11;
		vec2 noiseCoord = newtexcoord + vec2(sin(noiseSeed), cos(noiseSeed));
		color -= texture2D(noisetex, noiseCoord).rgb*GRAIN_STRENGTH;
	#endif

	

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}