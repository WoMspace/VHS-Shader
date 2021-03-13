#version 130

#define CHROMA_SAMPLING 5.0// How big the chroma subsampling should be. Larger number = bigger artefacting.[1.0 2.0 3.0 4.0 5.0]
#define NOISE_STRENGTH 0.15 // How strong the noise is. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50]
#define SCANLINE_DISTANCE 5 // How many pixels between each line. [1 2 3 4 5 6 7 8 9 10 20 30 40 50 100 200]
#define SCANLINE_STRENGTH 0.3 // How strong the scanline effect is. [0.1 0.2 0.3 0.4 0.5]
const bool SCANLINE_ENABLED = true; // Should the scanlines effect be used. [true false]
const int noiseTextureResolution = 512; // Size of the noise texture. Smaller number = bigger noise. [64 128 256 512 1024]

uniform sampler2D gcolor;
uniform sampler2D noisetex;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;
varying vec4 gl_FragCoord;

void main() {
	float noiseSeed = frameCounter * 0.11;
	vec2 noiseCoord = texcoord + vec2(noiseSeed, 1-noiseSeed);
	vec3 color = texture2D(gcolor, texcoord).rgb;
	vec3 chroma = normalize(textureLod(gcolor, texcoord, CHROMA_SAMPLING).rgb);
	float luma = (color.r + color.g + color.b / 3.0);
	color = chroma * luma * 0.9;
	color -= texture2D(noisetex, noiseCoord).rgb*NOISE_STRENGTH;
	#ifdef SCANLINE_ENABLED
		if(mod(gl_FragCoord.y, SCANLINE_DISTANCE) < 1)
		{
			color -= SCANLINE_STRENGTH;
		}
	#endif
	//color += (1 - mod(gl_FragCoord.y, SCANLINE_DISTANCE))*SCANLINE_STRENGTH;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}