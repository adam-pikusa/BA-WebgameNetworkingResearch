shader_type spatial;

uniform vec3 water_color: source_color;
uniform sampler2D water_noise_tex1: filter_nearest;
uniform sampler2D water_noise_tex2: filter_nearest;

uniform sampler2D depth_tex: hint_depth_texture;
uniform sampler2D screen_texture: hint_screen_texture;

uniform float depth_distance: hint_range(0.0, 100.0, 0.1) = 0.5;
uniform float beers_law: hint_range(0.0, 100.0, 0.1) = 3.0;
uniform float water_opacity: hint_range(0.0, 1.0, 0.1) = 0.7;

uniform float normal_scale: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float roughness_scale: hint_range(0.0, 1.0, 0.1) = 0.2;
uniform float time_scale: hint_range(0.0, 10.0, 0.1) = 5.0;
uniform float scale: hint_range(0.0, 100.0, 0.1) = 0.3;
uniform float wave_travel: hint_range(0.0, 0.03, 0.001) = 0.05;

void fragment() {
	vec2 uv = UV * scale;

	uv.x += sin(TIME * time_scale + (uv.x + uv.y)) * wave_travel;
	uv.y += cos(TIME * time_scale + (uv.x - uv.y)) * wave_travel;

	float depth_r = textureLod(depth_tex, SCREEN_UV, 0.0).r;
	vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_r, 1.0);
	world.xyz /= world.w;
	float depth_blend = 1.0 - smoothstep(world.z + depth_distance, world.z, VERTEX.z);
	depth_blend = exp(depth_blend * -beers_law);

	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

	ALBEDO = mix(screen * depth_blend, water_color, water_opacity);
	NORMAL_MAP = mix(
		texture(water_noise_tex1, uv).rgb,
		texture(water_noise_tex2, uv).rgb,
		(sin(TIME * time_scale) + 1.0) / 2.0);
	NORMAL *= normal_scale;
	ROUGHNESS = roughness_scale;
}
