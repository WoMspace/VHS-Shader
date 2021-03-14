#version 330

//#include "lib/noiseFuncs.glsl"

#define CHROMA_SAMPLING_SIZE 4.0// How big the chroma subsampling should be. Larger number = bigger artefacting.[1.0 2.0 3.0 4.0 5.0]
#define CHROMA_SAMPLING_ENABLED // Should the chroma sub-sampling effect be used.

#define SCANLINE_DISTANCE 5 // How many pixels between each line. [1 2 3 4 5 6 7 8 9 10 20 30 40 50 100 200]
#define SCANLINE_STRENGTH 0.1 // How strong the scanline effect is. [0.01 0.05 0.1 0.2 0.3 0.4 0.5]
#define SCANLINE_THICKNESS 1 // How thick the lines are. [1 2 3 4 5 6 7 8 9 10]
#define SCANLINE_MODE 1 // Which Scanline effect to use. [0 1 2 3]
// #define CRT_SCANLINE // Simulate individual pixels. Replaces the scanlines.
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


uniform sampler2D gcolor;
uniform sampler2D noisetex;
uniform sampler2D depthtex0;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 fogColor;
uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform int isEyeInWater; //0 = air, 1 = water, 2 = lava

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;

	#ifdef CHROMA_SAMPLING_ENABLED
		vec3 chroma = normalize(textureLod(gcolor, texcoord, CHROMA_SAMPLING_SIZE).rgb);
		float luma = (color.r + color.g + color.b / 3.0);
		color = chroma * luma * 0.9;
	#endif

	#ifdef ROUND_FOG_ENABLED
		vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
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
		if(texture2D(depthtex0, texcoord).r != 1.0)
		{
			color = mix(color, fogColor, clamp((length(viewPos)-fogNearValue)/fogFarValue, 0.0, 1.0));
		}
		
	#endif

	#ifdef GRAIN_ENABLED	
		float noiseSeed = frameCounter * 0.11;
		vec2 noiseCoord = texcoord + vec2(sin(noiseSeed), cos(noiseSeed));
		color -= texture2D(noisetex, noiseCoord).rgb*GRAIN_STRENGTH;
	#endif

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

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}