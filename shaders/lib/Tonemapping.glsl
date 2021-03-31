
vec3 reinhard(vec3 color)
{
    return color/(1+color);
}

vec3 hejlBurgess(vec3 color)
{//no idea if it works (:
    //color *= 16;
    color = max(vec3(0), color - 0.004);
    color = (color*(6.2*color+.5))/(color*(6.2*color+1.7)+0.06);
    return color;
}