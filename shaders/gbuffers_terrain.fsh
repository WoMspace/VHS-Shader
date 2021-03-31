#version 130

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform vec3 fogColor;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	//color *= texture2D(lightmap, lmcoord) * 2.0;
	vec3 blocklight = lmcoord.x * 2.0 * vec3(0.5, 0.35, 0.02);
	vec3 skylight = lmcoord.y * fogColor * 5.0 + 0.1;
	color.rgb *= blocklight + skylight;


/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}