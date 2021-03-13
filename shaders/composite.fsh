#version 130

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

uniform sampler2D gcolor;
uniform sampler2D noisetex;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;
varying vec4 gl_FragCoord;

void main() {
	vec3 color = texture2D(gcolor, texcoord).rgb;

	#ifdef GRAIN_ENABLED	
		float noiseSeed = frameCounter * 0.11;
		vec2 noiseCoord = texcoord + vec2(noiseSeed, 1-noiseSeed);
		color -= texture2D(noisetex, noiseCoord).rgb*GRAIN_STRENGTH;
	#endif

	#ifdef CHROMA_SAMPLING_ENABLED
		vec3 chroma = normalize(textureLod(gcolor, texcoord, CHROMA_SAMPLING_SIZE).rgb);
		float luma = (color.r + color.g + color.b / 3.0);
		color = chroma * luma * 0.9;
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

/* DRAWBUFFERS:01234 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}