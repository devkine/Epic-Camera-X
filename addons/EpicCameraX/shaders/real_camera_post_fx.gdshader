shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D lut_texture : source_color, repeat_disable, filter_linear;

// -------------------------
// TOGGLES
// -------------------------
uniform bool enable_vignette = true;
uniform bool enable_chromatic_aberration = true;
uniform bool enable_distortion = true;
uniform bool enable_grain = true;
uniform bool enable_color_grading = true;
uniform bool enable_highlight_bloom = true;
uniform bool enable_lut = false;
uniform bool enable_halation = true;

// -------------------------
// VIGNETTE
// size = where darkening starts
// smoothness = feather amount
// -------------------------
uniform float vignette_intensity : hint_range(0.0, 2.0, 0.01) = 0.35;
uniform float vignette_size : hint_range(0.0, 2.5, 0.01) = 0.75;
uniform float vignette_smoothness : hint_range(0.001, 2.0, 0.01) = 0.35;
uniform float vignette_roundness : hint_range(0.25, 4.0, 0.01) = 1.0;

// -------------------------
// CHROMATIC ABERRATION
// ca_blur adds a cheap soft blur to the fringe
// -------------------------
uniform float chromatic_aberration : hint_range(0.0, 8.0, 0.01) = 1.2;
uniform float ca_edge_start : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float ca_blur : hint_range(0.0, 4.0, 0.01) = 0.65;

// -------------------------
// DISTORTION
// positive = barrel, negative = pincushion
// -------------------------
uniform float distortion : hint_range(-1.0, 1.0, 0.001) = 0.035;
uniform float distortion_cubic : hint_range(-1.0, 1.0, 0.001) = 0.015;
uniform float distortion_overscan : hint_range(1.0, 2.0, 0.001) = 1.08;
uniform vec2 distortion_center = vec2(0.5, 0.5);


// -------------------------
// FILM GRAIN
// overall grain_strength is global multiplier
// shadows / mids / highlights let you bias by luma
// -------------------------
uniform bool enable_rgb_digital_noise = false;
uniform float grain_strength : hint_range(0.0, 1.0, 0.001) = 0.02;
uniform float grain_size : hint_range(0.25, 8.0, 0.01) = 1.5;
uniform float grain_speed : hint_range(0.0, 20.0, 0.01) = 6.0;
uniform float grain_shadows : hint_range(0.0, 4.0, 0.01) = 1.2;
uniform float grain_mids : hint_range(0.0, 4.0, 0.01) = 1.0;
uniform float grain_highlights : hint_range(0.0, 4.0, 0.01) = 0.6;

// -------------------------
// BASIC COLOR GRADING
// -------------------------
uniform float exposure : hint_range(0.0, 3.0, 0.01) = 1.0;
uniform float contrast : hint_range(0.0, 2.0, 0.01) = 1.05;
uniform float saturation : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float temperature : hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform float tint : hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform vec3 lift : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 gamma : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 gain : source_color = vec3(1.0, 1.0, 1.0);

// -------------------------
// HIGHLIGHT BLOOM
// separate from base grading
// -------------------------
uniform float bloom_intensity : hint_range(0.0, 3.0, 0.01) = 0.35;
uniform float bloom_threshold : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float bloom_softness : hint_range(0.001, 2.0, 0.01) = 0.35;
uniform float bloom_radius : hint_range(0.0, 12.0, 0.01) = 4.0;
uniform vec3 bloom_tint : source_color = vec3(1.0, 1.0, 1.0);

// -------------------------
// LUT GRADING
// expects a 2D strip LUT:
// width = lut_size * lut_size
// height = lut_size
// -------------------------
uniform float lut_size : hint_range(2.0, 65.0, 1.0) = 33.0;
uniform float lut_strength : hint_range(0.0, 1.0, 0.01) = 1.0;

// -------------------------
// HALATION
// red/orange highlight bleed
// -------------------------
uniform float halation_intensity : hint_range(0.0, 3.0, 0.01) = 0.22;
uniform float halation_threshold : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float halation_softness : hint_range(0.001, 2.0, 0.01) = 0.35;
uniform float halation_radius : hint_range(0.0, 16.0, 0.01) = 5.5;
uniform vec3 halation_color : source_color = vec3(1.0, 0.35, 0.12);

// Helios-inspired veil + halo
uniform float lens_flare_veil_intensity : hint_range(0.0, 3.0, 0.01) = 0.45;
uniform float lens_flare_halo_intensity : hint_range(0.0, 3.0, 0.01) = 0.4;
uniform float lens_flare_halo_radius : hint_range(0.0, 2.0, 0.01) = 0.55;
uniform float lens_flare_halo_softness : hint_range(0.001, 1.0, 0.01) = 0.12;

// Helios-like tint controls
uniform vec3 helios_warm_tint : source_color = vec3(1.0, 0.78, 0.55);
uniform vec3 helios_green_tint : source_color = vec3(0.72, 1.0, 0.78);
uniform vec3 helios_magenta_tint : source_color = vec3(1.0, 0.62, 0.92);

uniform bool enable_lens_flare = true;

// Filled from the camera script
uniform vec2 lens_flare_source_uv = vec2(0.5, 0.5);
uniform float lens_flare_source_visible = 0.0;
uniform float lens_flare_source_energy : hint_range(0.0, 16.0, 0.01) = 2.0;

// Main flare controls
uniform float lens_flare_intensity : hint_range(0.0, 4.0, 0.01) = 0.55;
uniform float lens_flare_threshold : hint_range(0.0, 4.0, 0.01) = 1.0;
uniform float lens_flare_softness : hint_range(0.001, 2.0, 0.01) = 0.35;
uniform float lens_flare_scale : hint_range(0.01, 1.5, 0.001) = 0.18;
uniform float lens_flare_ghost_intensity : hint_range(0.0, 4.0, 0.01) = 0.8;

// Optional custom flare texture
uniform float custom_lens_flare_intensity : hint_range(0.0, 4.0, 0.01) = 1.0;
uniform float custom_lens_flare_scale : hint_range(0.01, 2.0, 0.001) = 1.0;
uniform vec3 custom_lens_flare_tint : source_color = vec3(1.0, 1.0, 1.0);


uniform sampler2D custom_lens_flare_texture : source_color, repeat_disable, filter_linear;

uniform bool enable_custom_lens_flare = false;





uniform float lens_flare_blur : hint_range(0.1, 4.0, 0.01) = 1.15;
uniform float lens_flare_ca : hint_range(0.0, 1.0, 0.001) = 0.14;
uniform float lens_flare_imperfection : hint_range(0.0, 1.0, 0.01) = 0.35;


uniform float lens_flare_ray_intensity : hint_range(0.0, 4.0, 0.01) = 0.14;
uniform float lens_flare_ray_count : hint_range(4.0, 16.0, 1.0) = 7.0;

uniform vec3 flare_warm_tint : source_color = vec3(1.0, 0.78, 0.58);
uniform vec3 flare_green_tint : source_color = vec3(0.76, 1.0, 0.86);
uniform vec3 flare_magenta_tint : source_color = vec3(1.0, 0.72, 0.94);

float luma(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec2 get_screen_pixel_size() {
	return 1.0 / vec2(textureSize(screen_texture, 0));
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float hash12_seed(vec2 p, float seed) {
	return hash12(p + vec2(seed * 0.123, seed * 0.456));
}

float signed_noise(vec2 p, float seed) {
	return hash12_seed(p, seed) * 2.0 - 1.0;
}

float gaussianish_noise(vec2 p, float seed) {
	float n = 0.0;
	n += signed_noise(p, seed + 0.0);
	n += signed_noise(p, seed + 11.7);
	n += signed_noise(p, seed + 23.4);
	n += signed_noise(p, seed + 37.1);
	return n * 0.25;
}


float approx_gauss(vec2 p, float seed) {
	float n = 0.0;
	n += hash12_seed(p, seed + 0.0);
	n += hash12_seed(p, seed + 1.0);
	n += hash12_seed(p, seed + 2.0);
	n += hash12_seed(p, seed + 3.0);
	return (n * 0.25 - 0.5) * 2.0;
}

vec3 digital_camera_rgb_noise(vec2 p, vec3 color_srgb) {
	// Approximate linear signal from display color
	vec3 signal = pow(clamp(color_srgb, vec3(0.0), vec3(1.0)), vec3(2.2));
	float lum = luma(signal);

	// Frame index changes the value, not the position
	float frame = floor(TIME * max(grain_speed, 0.001) * 12.0);

	// Stable fixed-pattern sensor texture
	vec3 fixed_pattern = vec3(
		gaussianish_noise(p, 101.0),
		gaussianish_noise(p, 211.0),
		gaussianish_noise(p, 307.0)
	);

	// Temporal luminance noise
	float luma_temporal = gaussianish_noise(p, frame + 1.0);

	// Temporal RGB channel noise
	vec3 chroma_temporal = vec3(
		gaussianish_noise(p, frame + 13.0),
		gaussianish_noise(p, frame + 29.0),
		gaussianish_noise(p, frame + 47.0)
	);

	// Bayer-ish channel bias:
	// green cleaner, blue a bit noisier
	chroma_temporal *= vec3(1.00, 0.72, 1.18);
	fixed_pattern *= vec3(0.28, 0.18, 0.34);

	// Mix mostly luma noise with some RGB separation
	vec3 noise = vec3(luma_temporal) * 0.62
		+ chroma_temporal * 0.38
		+ fixed_pattern;

	// Stronger in darker regions, softer in highlights
	float shadow_boost = mix(1.55, 0.72, smoothstep(0.0, 1.0, lum));

	// Relative noise feel:
	// darker = more visible noise
	// brighter = still present, but cleaner
	vec3 signal_response = mix(
		vec3(1.10, 1.00, 1.15),
		vec3(0.72, 0.62, 0.78),
		clamp(signal, vec3(0.0), vec3(1.0))
	);

	return noise * signal_response * shadow_boost;
}

vec2 distort_uv(vec2 uv) {
	if (!enable_distortion) {
		return uv;
	}
	
	uv = (uv - distortion_center) / distortion_overscan + distortion_center;

	vec2 p = (uv - distortion_center) * 2.0;
	float r2 = dot(p, p);

	float k = 1.0 + distortion * r2 + distortion_cubic * r2 * r2;
	p *= k;

	return distortion_center + p * 0.5;
}

float edge_factor(vec2 uv) {
	vec2 p = uv * 2.0 - 1.0;
	float r = length(p);
	return smoothstep(ca_edge_start, 1.0, r);
}

vec3 sample_screen(vec2 uv) {
	return textureLod(screen_texture, clamp(uv, vec2(0.0), vec2(1.0)), 0.0).rgb;
}

vec3 sample_scene_base(vec2 uv) {
	return sample_screen(distort_uv(uv));
}

vec3 sample_scene_ca(vec2 uv) {
	vec2 duv = clamp(distort_uv(uv), vec2(0.0), vec2(1.0));

	if (!enable_chromatic_aberration || chromatic_aberration <= 0.0001) {
		return sample_screen(duv);
	}

	vec2 center_dir = uv - vec2(0.5);
	float len_dir = length(center_dir);
	vec2 dir = len_dir > 0.00001 ? center_dir / len_dir : vec2(0.0);
	vec2 tangent = vec2(-dir.y, dir.x);

	float edge = edge_factor(uv);
	vec2 px = get_screen_pixel_size();
	vec2 base_offset = dir * px * chromatic_aberration * edge;

	float blur_amt = max(ca_blur, 0.0);
	vec2 blur_side = tangent * px * blur_amt * edge;

	float r0 = sample_screen(duv + base_offset * 0.75).r;
	float r1 = sample_screen(duv + base_offset * 1.15 + blur_side).r;
	float r2 = sample_screen(duv + base_offset * 1.55 - blur_side).r;

	float g0 = sample_screen(duv).g;
	float g1 = sample_screen(duv + blur_side * 0.5).g;
	float g2 = sample_screen(duv - blur_side * 0.5).g;

	float b0 = sample_screen(duv - base_offset * 0.75).b;
	float b1 = sample_screen(duv - base_offset * 1.15 + blur_side).b;
	float b2 = sample_screen(duv - base_offset * 1.55 - blur_side).b;

	return vec3(
		(r0 + r1 + r2) / 3.0,
		(g0 + g1 + g2) / 3.0,
		(b0 + b1 + b2) / 3.0
	);
}

vec3 threshold_color(vec3 c, float threshold, float softness) {
	float m = smoothstep(threshold, threshold + max(softness, 0.0001), luma(c));
	return c * m;
}

vec3 blur_highlights(vec2 uv, float radius_px, float threshold, float softness) {
	vec2 px = get_screen_pixel_size() * radius_px;

	vec3 acc = vec3(0.0);
	float w = 0.0;

	vec2 o0  = vec2(0.0, 0.0);
	vec2 o1  = vec2( 1.0,  0.0) * px;
	vec2 o2  = vec2(-1.0,  0.0) * px;
	vec2 o3  = vec2( 0.0,  1.0) * px;
	vec2 o4  = vec2( 0.0, -1.0) * px;
	vec2 o5  = vec2( 0.7071,  0.7071) * px * 1.4;
	vec2 o6  = vec2(-0.7071,  0.7071) * px * 1.4;
	vec2 o7  = vec2( 0.7071, -0.7071) * px * 1.4;
	vec2 o8  = vec2(-0.7071, -0.7071) * px * 1.4;
	vec2 o9  = vec2( 2.0,  0.0) * px;
	vec2 o10 = vec2(-2.0,  0.0) * px;
	vec2 o11 = vec2( 0.0,  2.0) * px;
	vec2 o12 = vec2( 0.0, -2.0) * px;

	acc += threshold_color(sample_scene_base(uv + o0), threshold, softness) * 2.0; w += 2.0;
	acc += threshold_color(sample_scene_base(uv + o1), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o2), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o3), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o4), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o5), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o6), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o7), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o8), threshold, softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + o9), threshold, softness) * 0.75; w += 0.75;
	acc += threshold_color(sample_scene_base(uv + o10), threshold, softness) * 0.75; w += 0.75;
	acc += threshold_color(sample_scene_base(uv + o11), threshold, softness) * 0.75; w += 0.75;
	acc += threshold_color(sample_scene_base(uv + o12), threshold, softness) * 0.75; w += 0.75;

	return acc / max(w, 0.0001);
}

vec3 highlight_bloom_pass(vec2 uv) {
	if (!enable_highlight_bloom || bloom_intensity <= 0.0001 || bloom_radius <= 0.0001) {
		return vec3(0.0);
	}

	vec3 b0 = blur_highlights(uv, bloom_radius * 0.65, bloom_threshold, bloom_softness);
	vec3 b1 = blur_highlights(uv, bloom_radius, bloom_threshold, bloom_softness);
	vec3 b2 = blur_highlights(uv, bloom_radius * 1.65, bloom_threshold, bloom_softness);

	vec3 bloom = (b0 + b1 + b2) / 3.0;
	return bloom * bloom_tint * bloom_intensity;
}

vec3 halation_pass(vec2 uv) {
	if (!enable_halation || halation_intensity <= 0.0001 || halation_radius <= 0.0001) {
		return vec3(0.0);
	}

	vec3 inner = blur_highlights(uv, max(1.0, halation_radius * 0.45), halation_threshold, halation_softness);
	vec3 outer = blur_highlights(uv, max(1.0, halation_radius), halation_threshold, halation_softness);

	vec3 ring = max(outer - inner * 0.7, vec3(0.0));
	return ring * halation_color * halation_intensity;
}

float soft_disc(float r, float radius, float softness) {
	return 1.0 - smoothstep(radius, radius + softness, r);
}

float soft_ring(float r, float radius, float softness) {
	float d = abs(r - radius);
	return 1.0 - smoothstep(0.0, softness, d);
}

vec3 sample_bright_source(vec2 uv) {
	vec2 px = get_screen_pixel_size() * 2.5;

	vec3 acc = vec3(0.0);
	float w = 0.0;

	acc += threshold_color(sample_scene_base(uv), lens_flare_threshold, lens_flare_softness) * 2.0; w += 2.0;
	acc += threshold_color(sample_scene_base(uv + vec2( px.x, 0.0)), lens_flare_threshold, lens_flare_softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + vec2(-px.x, 0.0)), lens_flare_threshold, lens_flare_softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + vec2(0.0,  px.y)), lens_flare_threshold, lens_flare_softness); w += 1.0;
	acc += threshold_color(sample_scene_base(uv + vec2(0.0, -px.y)), lens_flare_threshold, lens_flare_softness); w += 1.0;

	return acc / max(w, 0.0001);
}

vec3 flare_ghost(vec2 uv, vec2 center_uv, float scale, vec3 flare_col, float intensity) {
	vec2 p = (uv - center_uv) / max(scale, 0.0001);
	float r = length(p);

	if (r > 1.35) {
		return vec3(0.0);
	}

	float core = exp(-r * 7.0);
	float body = soft_disc(r, 0.82, 0.32) * 0.18;
	float ring1 = soft_ring(r, 0.42, 0.08) * 0.26;
	float ring2 = soft_ring(r, 0.72, 0.10) * 0.16;

	return flare_col * (core * 0.8 + body + ring1 + ring2) * intensity;
}

vec3 flare_custom_tex(vec2 uv, vec2 center_uv, float scale, vec3 flare_col, float intensity) {
	if (!enable_custom_lens_flare) {
		return vec3(0.0);
	}

	vec2 tuv = (uv - center_uv) / max(scale, 0.0001) * 0.5 + 0.5;

	if (tuv.x < 0.0 || tuv.x > 1.0 || tuv.y < 0.0 || tuv.y > 1.0) {
		return vec3(0.0);
	}

	vec4 tex = texture(custom_lens_flare_texture, tuv);
	float a = max(tex.a, max(tex.r, max(tex.g, tex.b)));

	return tex.rgb * flare_col * a * intensity;
}

vec3 flare_veil(vec2 uv, vec2 src_uv, float radius, vec3 flare_col, float intensity) {
	float r = length(uv - src_uv) / max(radius, 0.0001);
	float haze = exp(-r * 3.2);
	float ring = soft_ring(r, 0.58, 0.24) * 0.16;
	return flare_col * (haze + ring) * intensity;
}

vec3 lens_flare_pass(vec2 uv) {
	if (!enable_lens_flare || lens_flare_source_visible < 0.5) {
		return vec3(0.0);
	}

	vec2 src_uv = lens_flare_source_uv;
	vec2 center_uv = vec2(0.5, 0.5);

	vec3 bright_col = sample_bright_source(src_uv);
	float sampled_energy = luma(bright_col);
	float energy = max(sampled_energy, lens_flare_source_energy);

	if (energy <= 0.0001) {
		return vec3(0.0);
	}

	vec2 axis = center_uv - src_uv;
	float axis_len = length(axis);
	vec2 axis_dir = axis_len > 0.0001 ? axis / axis_len : vec2(1.0, 0.0);

	float edge_boost = mix(0.75, 1.35, smoothstep(0.08, 0.95, axis_len));
	float total_intensity = lens_flare_intensity * energy * edge_boost;

	vec3 out_col = vec3(0.0);

	out_col += flare_veil(
		uv,
		src_uv,
		lens_flare_scale * 2.0,
		helios_warm_tint,
		total_intensity * lens_flare_veil_intensity
	);

	out_col += flare_veil(
		uv,
		src_uv + axis_dir * lens_flare_scale * 0.05,
		lens_flare_scale * 1.35,
		helios_green_tint,
		total_intensity * lens_flare_veil_intensity * 0.14
	);

	float halo_r = length(uv - src_uv) / max(lens_flare_scale, 0.0001);
	float halo_mask = soft_ring(halo_r, lens_flare_halo_radius, lens_flare_halo_softness);
	out_col += helios_warm_tint * halo_mask * total_intensity * lens_flare_halo_intensity;

	vec2 g1 = center_uv + (center_uv - src_uv) * 0.35;
	vec2 g2 = center_uv + (center_uv - src_uv) * 0.90;
	vec2 g3 = center_uv + (center_uv - src_uv) * 1.55;
	vec2 g4 = center_uv + (center_uv - src_uv) * 2.20;

	out_col += flare_ghost(uv, g1, lens_flare_scale * 0.42, helios_warm_tint, total_intensity * 0.90 * lens_flare_ghost_intensity);
	out_col += flare_ghost(uv, g2, lens_flare_scale * 0.28, helios_green_tint, total_intensity * 0.65 * lens_flare_ghost_intensity);
	out_col += flare_ghost(uv, g3, lens_flare_scale * 0.22, helios_magenta_tint, total_intensity * 0.48 * lens_flare_ghost_intensity);
	out_col += flare_ghost(uv, g4, lens_flare_scale * 0.36, helios_warm_tint, total_intensity * 0.38 * lens_flare_ghost_intensity);

	out_col += flare_custom_tex(uv, g1, lens_flare_scale * 0.70 * custom_lens_flare_scale, custom_lens_flare_tint, total_intensity * 0.75 * custom_lens_flare_intensity);
	out_col += flare_custom_tex(uv, g2, lens_flare_scale * 0.46 * custom_lens_flare_scale, custom_lens_flare_tint, total_intensity * 0.55 * custom_lens_flare_intensity);
	out_col += flare_custom_tex(uv, g3, lens_flare_scale * 0.34 * custom_lens_flare_scale, custom_lens_flare_tint, total_intensity * 0.35 * custom_lens_flare_intensity);

	return out_col;
}

vec3 apply_basic_grade(vec3 color) {
	if (!enable_color_grading) {
		return color;
	}

	color *= exposure;

	color.r += temperature * 0.10;
	color.b -= temperature * 0.10;
	color.g += tint * 0.05;
	color.r += tint * 0.025;
	color.b -= tint * 0.025;

	color = (color - 0.5) * contrast + 0.5;

	float y = luma(color);
	color = mix(vec3(y), color, saturation);

	color += lift;
	color = max(color, vec3(0.0));
	color = pow(color, vec3(1.0) / max(gamma, vec3(0.001)));
	color *= gain;

	return color;
}

vec3 apply_lut_strip(vec3 color) {
	float size = max(lut_size, 2.0);
	vec3 c = clamp(color, vec3(0.0), vec3(1.0)) * (size - 1.0);

	float blue0 = floor(c.b);
	float blue1 = min(blue0 + 1.0, size - 1.0);
	float bluef = fract(c.b);

	vec2 uv0 = vec2(
		(c.r + blue0 * size + 0.5) / (size * size),
		(c.g + 0.5) / size
	);

	vec2 uv1 = vec2(
		(c.r + blue1 * size + 0.5) / (size * size),
		(c.g + 0.5) / size
	);

	vec3 lut0 = texture(lut_texture, uv0).rgb;
	vec3 lut1 = texture(lut_texture, uv1).rgb;

	return mix(lut0, lut1, bluef);
}

float grain_tone_weight(float lum) {
	float shadows = 1.0 - smoothstep(0.0, 0.45, lum);
	float highlights = smoothstep(0.55, 1.0, lum);
	float mids = max(0.0, 1.0 - shadows - highlights);

	return shadows * grain_shadows
		+ mids * grain_mids
		+ highlights * grain_highlights;
}

float vignette_amount(vec2 uv) {
	vec2 size_px = vec2(textureSize(screen_texture, 0));
	float aspect = size_px.x / max(size_px.y, 0.0001);

	vec2 p = uv * 2.0 - 1.0;
	p.x *= aspect;

	p = sign(p) * pow(abs(p), vec2(vignette_roundness));
	float r = length(p);

	return smoothstep(vignette_size, vignette_size + vignette_smoothness, r);
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float flare_dirt(vec2 p) {
	vec2 cell = floor(p * 120.0);
	float n1 = hash21(cell);
	float n2 = hash21(cell + vec2(7.0, 19.0));
	return 0.82 + (n1 * 0.12 + n2 * 0.06);
}



vec3 flare_source_halo(vec2 uv, vec2 src_uv) {
	vec2 p = (uv - src_uv) / max(lens_flare_scale, 0.0001);
	float r = length(p);
	float a = atan(p.y, p.x);

	float blur = max(lens_flare_blur, 0.0001);
	float irregular = 1.0 + lens_flare_imperfection *
		(0.10 * sin(a * 7.0 + r * 9.0) + 0.07 * sin(a * 15.0 - r * 12.0));

	float dirt = mix(1.0, flare_dirt(p * 0.5 + 0.5), lens_flare_imperfection * 0.7);

	float base = exp(-r * (2.4 / blur)) * 0.55;
	float inner = soft_disc(r, 0.22 * blur, 0.20 * blur) * 0.18;

	vec3 ca_ring = vec3(
		soft_ring(r, 0.56 + lens_flare_ca * 0.10, 0.14 * blur),
		soft_ring(r, 0.55, 0.15 * blur),
		soft_ring(r, 0.54 - lens_flare_ca * 0.08, 0.16 * blur)
	) * 0.22;

	vec3 col = flare_warm_tint * (base + inner) + ca_ring;
	return col * irregular * dirt;
}

vec3 flare_rays(vec2 uv, vec2 src_uv, float strength) {
	vec2 p = uv - src_uv;
	float r = length(p) / max(lens_flare_scale * 3.0, 0.0001);

	if (r > 1.5) {
		return vec3(0.0);
	}

	float a = atan(p.y, p.x);

	float star_a = pow(max(0.0, cos(a * lens_flare_ray_count)), 24.0);
	float star_b = pow(max(0.0, cos(a * (lens_flare_ray_count * 0.5) + 0.45)), 36.0) * 0.45;
	float radial = exp(-r * 2.0);

	float irregular = 1.0 + lens_flare_imperfection * 0.12 * sin(a * 19.0 + r * 11.0);

	return flare_warm_tint * (star_a + star_b) * radial * strength * irregular;
}

vec3 flare_ghost_real(vec2 uv, vec2 center_uv, float scale, vec3 ghost_col, float strength, float seed) {
	vec2 p = (uv - center_uv) / max(scale, 0.0001);
	float r = length(p);

	if (r > 1.5) {
		return vec3(0.0);
	}

	float a = atan(p.y, p.x);
	float blur = max(lens_flare_blur, 0.0001);

	float irregular = 1.0 + lens_flare_imperfection *
		(0.08 * sin(a * 5.0 + seed * 3.7) + 0.06 * sin(a * 11.0 - r * 10.0 + seed));

	float dirt = mix(1.0, 0.86 + 0.14 * hash21(floor((p + vec2(6.0)) * 16.0 + seed * 5.0)), lens_flare_imperfection);

	float body = exp(-r * (3.0 / blur)) * 0.30;
	float core = soft_disc(r, 0.16 * blur, 0.18 * blur) * 0.10;

	vec3 ca = vec3(
		soft_ring(r, 0.58 + lens_flare_ca * 0.08, 0.10 * blur),
		soft_ring(r, 0.56, 0.11 * blur),
		soft_ring(r, 0.54 - lens_flare_ca * 0.07, 0.12 * blur)
	) * 0.16;

	return (ghost_col * (body + core) + ca) * strength * irregular * dirt;
}


void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	vec3 color = sample_scene_ca(uv);

	vec3 bloom = highlight_bloom_pass(uv);
	vec3 halation = halation_pass(uv);
	vec3 flare_color = lens_flare_pass(uv);

	color += bloom;
	color += halation;
	color += flare_color;

	color = apply_basic_grade(color);

	if (enable_lut && lut_strength > 0.0001) {
		vec3 lut_color = apply_lut_strip(color);
		color = mix(color, lut_color, lut_strength);
	}

	if (enable_vignette && vignette_intensity > 0.0001) {
		float v = vignette_amount(uv);
		color *= 1.0 - (v * vignette_intensity);
	}
if (enable_grain && grain_strength > 0.0001) {
	vec2 grain_uv = floor(FRAGCOORD.xy / max(grain_size, 0.001));
	float lum = luma(color);
	float tone_weight = grain_tone_weight(lum);

	if (enable_rgb_digital_noise) {
		vec3 rgb_noise = digital_camera_rgb_noise(grain_uv, color);
		color += rgb_noise * grain_strength * tone_weight;
	} else {
		float n = hash12(grain_uv + vec2(TIME * grain_speed, TIME * grain_speed * 0.37));
		color += (n - 0.5) * grain_strength * tone_weight;
	}
}

	ALBEDO = clamp(color, vec3(0.0), vec3(32.0));
	ALPHA = 1.0;
}