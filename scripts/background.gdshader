shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded, shadows_disabled;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear, repeat_enable;

float interleavedGradientNoise(ivec2 co){
	return fract(52.9829189 * fract(dot(vec2(co), vec2(0.06711056, 0.00583715))));
}

float random(ivec2 co) {
	return fract(dot(vec2(co), vec2(3,8)) * dot(vec2(co.yx), vec2(7,5)) * 0.03);
}

void vertex() {
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	//// poor man's blur
	//ivec2 viewPx = ivec2(UV * vec2(textureSize(texture_albedo, 0)));
	//float factor = interleavedGradientNoise(viewPx) * 1.1 / vec2(textureSize(texture_albedo, 0)).x;
	//float factor2 = random(viewPx);
	//factor2 = mix(0.5, 0.9, factor2);
	//vec3 sum = vec3(0);
	//sum += texture(texture_albedo, UV + vec2(-2, 0) * factor).rgb;
	//sum += texture(texture_albedo, UV + vec2(-1, 1) * factor).rgb * 2.0;
	//sum += texture(texture_albedo, UV + vec2(0,  2) * factor).rgb;
	//sum += texture(texture_albedo, UV + vec2(1,  1) * factor).rgb * 2.0;
	//sum += texture(texture_albedo, UV + vec2(2,  0) * factor).rgb;
	//sum += texture(texture_albedo, UV + vec2(1, -1) * factor).rgb * 2.0;
	//sum += texture(texture_albedo, UV + vec2(0, -2) * factor).rgb;
	//sum += texture(texture_albedo, UV + vec2(-1,-1) * factor).rgb * 2.0;
	//ALBEDO = albedo.rgb * mix(albedo_tex.rgb, sum * 0.0833333333333, factor2); // 1/12
}
