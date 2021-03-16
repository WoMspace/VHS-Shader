
vec3 reinhard(vec3 color)
{
    return color/(1+color);
}

/*vec3 hejlBurgess(vec4 gcolor, vec2 uv)
{//no idea if it works (:
    vec3 color = texture2D(gcolor, uv).rgb * 16.0;
    color = max(0, color - 0.004);
    color = (color*(6.2*color+.5))/(color*(6.2*color+1.7)+0.06);
    return color;
}*/


/* =======  BROKEN ACES!!!!! ======= */

const highp mat3 AP0_2_sRGB = {
    { 2.52169, -1.13413, -0.38756 },
    { -0.27648, 1.37272, -0.09624 },
    { -0.01538, -0.15298, 1.16835 }
};

const highp mat3 sRGB_2_AP0 = {
    { 0.4397010, 0.3829780, 0.1773350 },
    { 0.0897923, 0.8134230, 0.0967616 },
    { 0.0175440, 0.1115440, 0.8707040 }
};

vec3 sRGB_to_ACES(vec3 x)
{
    x = sRGB_2_AP0 * x;
    return x;
}

vec3 ACES_to_sRGB(vec3 x)
{
    x = AP0_2_sRGB * x;
    return x;
}