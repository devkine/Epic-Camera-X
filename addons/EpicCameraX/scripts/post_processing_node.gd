@tool
class_name PostProcessingNode
extends Node

const MAX_FLARES: int = 12
const POST_QUAD_NAME: String = "CameraPostFXQuad"
const FLARE_LAYER_NAME: String = "LensFlareCanvasLayer"
const FLARE_RECT_NAME: String = "LensFlareRect"

const DEFAULT_POST_SHADER_PATH: String = "res://addons/EpicCameraX/shaders/real_camera_post_fx.gdshader"
const DEFAULT_FLARE_SHADER_PATH: String = "res://addons/EpicCameraX/shaders/ue_like_lens_flare.gdshader"



@export_group("Setup")
@export var target_camera: Camera3D
@export var auto_find_camera: bool = true
@export var post_shader: Shader
@export var flare_shader: Shader
@export var sun_light: DirectionalLight3D
@export var enable_sun_flare: bool = true


@export_group("Setup: Post Quad")
@export_range(0.01, 5.0, 0.01) var quad_distance_offset: float = 1.4
@export_range(1.0, 1.2, 0.001) var quad_overscan: float = 1.02

@export_group("Vignette")
@export var enable_vignette: bool = true
@export_range(0.0, 2.0, 0.01) var vignette_intensity: float = 0.2
@export_range(0.0, 2.5, 0.01) var vignette_size: float = 1.0
@export_range(0.001, 2.0, 0.01) var vignette_smoothness: float = 1.0
@export_range(0.25, 4.0, 0.01) var vignette_roundness: float = 1.0

@export_group("Chromatic Aberration")
@export var enable_chromatic_aberration: bool = true
@export_range(0.0, 8.0, 0.01) var chromatic_aberration: float = 2.85
@export_range(0.0, 1.0, 0.01) var ca_edge_start: float = 0.55
@export_range(0.0, 4.0, 0.01) var ca_blur: float = 2.55

@export_group("Lens Distortion")
@export var enable_distortion: bool = true
@export_range(-1.0, 1.0, 0.001) var distortion: float = 0.035
@export_range(-1.0, 1.0, 0.001) var distortion_cubic: float = 0.015
@export_range(1.0, 2.0, 0.001) var distortion_overscan: float = 1.08
@export var distortion_center: Vector2 = Vector2(0.5, 0.5)

@export_group("Film Grain")
@export var enable_grain: bool = true
@export var rgb_digital_noise: bool = true
@export_range(0.0, 1.0, 0.001) var grain_strength: float = 0.01
@export_range(0.25, 8.0, 0.01) var grain_size: float = 2.0
@export_range(0.0, 20.0, 0.01) var grain_speed: float = 6.0
@export_range(0.0, 4.0, 0.01) var grain_shadows: float = 0.75
@export_range(0.0, 4.0, 0.01) var grain_mids: float = 2.0
@export_range(0.0, 4.0, 0.01) var grain_highlights: float = 3.0

@export_group("Highlight Bloom")
@export var enable_highlight_bloom: bool = true
@export_range(0.0, 3.0, 0.01) var bloom_intensity: float = 0.35
@export_range(0.0, 2.0, 0.01) var bloom_threshold: float = 1.0
@export_range(0.001, 2.0, 0.01) var bloom_softness: float = 0.35
@export_range(0.0, 12.0, 0.01) var bloom_radius: float = 4.0
@export var bloom_tint: Color = Color(1, 1, 1, 1)

@export_group("Halation")
@export var enable_halation: bool = true
@export_range(0.0, 3.0, 0.01) var halation_intensity: float = 0.80
@export_range(0.0, 2.0, 0.01) var halation_threshold: float = 1.0
@export_range(0.001, 2.0, 0.01) var halation_softness: float = 0.25
@export_range(0.0, 16.0, 0.01) var halation_radius: float = 6.1
@export var halation_color: Color = Color(1.0, 0.35, 0.12, 1.0)

@export_group("Color Grading")
@export var enable_color_grading: bool = true
@export_range(0.0, 3.0, 0.01) var exposure: float = 1.0
@export_range(0.0, 2.0, 0.01) var contrast: float = 1.05
@export_range(0.0, 2.0, 0.01) var saturation: float = 1.0
@export_range(-1.0, 1.0, 0.001) var temperature: float = 0.0
@export_range(-1.0, 1.0, 0.001) var tint: float = 0.0
@export var lift: Color = Color(0, 0, 0, 1)
@export var gamma_color: Color = Color(1, 1, 1, 1)
@export var gain: Color = Color(1, 1, 1, 1)

@export_group("LUT")
@export var enable_lut: bool = false
@export var lut_texture: Texture2D
@export_range(2, 65, 1) var lut_size: int = 33
@export_range(0.0, 1.0, 0.01) var lut_strength: float = 1.0

@export_group("Engine DOF")
@export var dof_enabled: bool = false
@export_range(0.0, 1.0, 0.01) var dof_blur_amount: float = 0.1
@export var dof_near_enabled: bool = false
@export_range(0.01, 100.0, 0.01) var dof_near_distance: float = 2.0
@export_range(-20.0, 20.0, 0.01) var dof_near_transition: float = 1.0
@export var dof_far_enabled: bool = true
@export_range(0.01, 500.0, 0.01) var dof_far_distance: float = 10.0
@export_range(-50.0, 50.0, 0.01) var dof_far_transition: float = 5.0

@export_group("Light Selection")
@export var include_all_lights: bool = true
@export var light_group: StringName = &"lens_flare_source"
@export_range(0.0, 100.0, 0.01) var energy_threshold: float = 2.0
@export_range(1, MAX_FLARES, 1) var max_flares: int = 8
@export var directional_flip: bool = true
@export_range(10.0, 100000.0, 1.0) var directional_distance: float = 5000.0

@export_group("Occlusion")
@export var occlusion_check: bool = true
@export_flags_3d_physics var occlusion_mask: int = 1

@export_group("Flare Look")
@export_range(0.0, 8.0, 0.01) var master_intensity: float = 0.2
@export_range(0.0, 8.0, 0.01) var blur_amount: float = 1.80
@export_range(0.0, 0.05, 0.0001) var chroma_amount: float = 0.02
@export_range(0.0, 4.0, 0.01) var halo_intensity: float = 0.0
@export_range(0.0, 4.0, 0.01) var ghost_intensity: float = 2.3
@export_range(0.0, 4.0, 0.01) var ray_intensity: float = 0.0
@export_range(0.0, 1.0, 0.01) var imperfection: float = 0.38
@export_range(4.0, 16.0, 1.0) var ray_count: float = 7.0
@export_range(0.2, 4.0, 0.01) var ray_length: float = 1.65
@export_range(0.1, 3.0, 0.01) var ghost_spread: float = 1.0
@export_range(0.1, 4.0, 0.01) var source_bloom_scale: float = 1.25

@export_group("Flare: Transition")
@export_range(0.0, 0.5, 0.001) var screen_entry_margin: float = 0.08
@export_range(0.0, 0.25, 0.001) var screen_edge_softness: float = 0.03
@export_range(0.0, 1.0, 0.01) var edge_presence_strength: float = 0.20
@export var enable_temporal_flare_smoothing: bool = true
@export_range(0.1, 60.0, 0.01) var flare_fade_in_speed: float = 50.0
@export_range(0.1, 60.0, 0.01) var flare_fade_out_speed: float = 42.0

@export_group("Flare: Sun Flare")
@export_range(0.0, 8.0, 0.01) var sun_intensity_multiplier: float = 1.80
@export_range(0.1, 4.0, 0.01) var sun_size_multiplier: float = 3.0

@export_group("Flare: Emissive Sources")
@export var include_emissive_meshes: bool = true
@export_range(0.0, 100.0, 0.01) var emissive_threshold: float = 1.0

@export_group("Flare: Bokeh")
@export var use_bokeh_texture: bool = true
@export var bokeh_texture: Texture2D

@export_group("Flare: Sizing")
@export_range(0.001, 0.25, 0.001) var base_flare_size: float = 0.055
@export_range(0.0, 10.0, 0.01) var distance_falloff: float = 1.0

@export_group("Flare: Update")
@export_range(0.01, 5.0, 0.01) var rescan_interval: float = 0.5

var _camera: Camera3D
var _quad: MeshInstance3D
var _canvas_layer: CanvasLayer
var _rect: ColorRect
var _post_mat: ShaderMaterial
var _flare_mat: ShaderMaterial
var _flare_history: Dictionary = {}
var _known_lights: Array = []
var _known_emissives: Array = []
var _rescan_t: float = 0.0

func _assign_default_resources() -> void:
	if post_shader == null and ResourceLoader.exists(DEFAULT_POST_SHADER_PATH):
		post_shader = load(DEFAULT_POST_SHADER_PATH)
	if flare_shader == null and ResourceLoader.exists(DEFAULT_FLARE_SHADER_PATH):
		flare_shader = load(DEFAULT_FLARE_SHADER_PATH)

func _ready() -> void:
	_assign_default_resources()
	_resolve_camera()
	_ensure_post_quad()
	_update_post_quad_transform()
	_apply_params()
	_apply_engine_dof()

	if flare_shader != null:
		_ensure_overlay()
		_refresh_lights()

	set_process(true)
	update_configuration_warnings()

func _process(delta: float) -> void:
	if !_resolve_camera():
		_hide_overlay()
		return

	_ensure_post_quad()
	_update_post_quad_transform()
	_apply_params()
	_apply_engine_dof()

	if flare_shader != null:
		_ensure_overlay()
		_rescan_t -= delta

		if _rescan_t <= 0.0:
			_refresh_lights()
			_rescan_t = rescan_interval

		_apply_static_shader_params()
		_update_flare_uniforms(delta)
	else:
		_hide_overlay()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()

	if target_camera == null and !_has_parent_or_sibling_camera():
		warnings.append("No Camera3D found. Make PostProcessingNode a child/sibling of a camera, or assign Target Camera.")

	if post_shader == null:
		warnings.append("Post Shader is empty.")

	return warnings

func _has_parent_or_sibling_camera() -> bool:
	if get_parent() is Camera3D:
		return true

	var p: Node = get_parent()
	if p == null:
		return false

	for child in p.get_children():
		if child is Camera3D:
			return true

	return false

func _resolve_camera() -> bool:
	if is_instance_valid(target_camera):
		_camera = target_camera
		return true

	if is_instance_valid(_camera):
		return true

	if !auto_find_camera:
		return false

	if get_parent() is Camera3D:
		_camera = get_parent() as Camera3D
		return true

	var p: Node = get_parent()
	if p != null:
		for child in p.get_children():
			if child is Camera3D:
				_camera = child as Camera3D
				return true

	var viewport_camera: Camera3D = get_viewport().get_camera_3d()
	if is_instance_valid(viewport_camera):
		_camera = viewport_camera
		return true

	return false

func _set_scene_owner(node: Node) -> void:
	if !Engine.is_editor_hint():
		return

	var edited_root: Node = get_tree().edited_scene_root
	if edited_root == null:
		return

	node.owner = edited_root

func _hide_overlay() -> void:
	if _rect != null and is_instance_valid(_rect):
		_rect.visible = false

func _ensure_post_quad() -> void:
	if !is_instance_valid(_camera):
		return

	if _quad != null and is_instance_valid(_quad) and _quad.get_parent() == _camera:
		if _post_mat == null:
			_post_mat = _quad.material_override as ShaderMaterial
			if _post_mat == null:
				_post_mat = ShaderMaterial.new()
				_quad.material_override = _post_mat
		_quad.visible = post_shader != null
		return

	_quad = _camera.get_node_or_null(POST_QUAD_NAME)
	if _quad == null:
		_quad = MeshInstance3D.new()
		_quad.name = POST_QUAD_NAME

		var quad_mesh: QuadMesh = QuadMesh.new()
		quad_mesh.size = Vector2(2.0, 2.0)
		quad_mesh.flip_faces = true

		_quad.mesh = quad_mesh
		_quad.extra_cull_margin = 100000.0
		_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		_camera.add_child(_quad)
		_set_scene_owner(_quad)

	if _post_mat == null:
		_post_mat = ShaderMaterial.new()

	_post_mat.shader = post_shader
	_quad.material_override = _post_mat
	_quad.visible = post_shader != null

func _update_post_quad_transform() -> void:
	if !is_instance_valid(_camera):
		return
	if !is_instance_valid(_quad):
		return

	var quad_mesh: QuadMesh = _quad.mesh as QuadMesh
	if quad_mesh == null:
		return

	var viewport_size: Vector2 = _camera.get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var aspect: float = viewport_size.x / viewport_size.y
	var distance: float = max(_camera.near + quad_distance_offset, 0.05)

	var width: float
	var height: float

	if _camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
		var half_height: float = tan(deg_to_rad(_camera.fov) * 0.5) * distance
		height = half_height * 2.0
		width = height * aspect
	else:
		if _camera.keep_aspect == Camera3D.KEEP_WIDTH:
			width = _camera.size
			height = width / aspect
		else:
			height = _camera.size
			width = height * aspect

	width *= quad_overscan
	height *= quad_overscan

	quad_mesh.size = Vector2(width, height)
	_quad.position = Vector3(0.0, 0.0, -distance)
	_quad.rotation = Vector3.ZERO
	_quad.scale = Vector3.ONE
	
func _apply_params() -> void:
	if _quad == null or !is_instance_valid(_quad):
		return

	if _post_mat == null:
		_post_mat = _quad.material_override as ShaderMaterial
		if _post_mat == null:
			_post_mat = ShaderMaterial.new()
			_quad.material_override = _post_mat

	if _post_mat.shader != post_shader:
		_post_mat.shader = post_shader

	if _post_mat.shader == null:
		return

	_post_mat.set_shader_parameter("enable_vignette", enable_vignette)
	_post_mat.set_shader_parameter("enable_chromatic_aberration", enable_chromatic_aberration)
	_post_mat.set_shader_parameter("enable_distortion", enable_distortion)
	_post_mat.set_shader_parameter("enable_grain", enable_grain)
	_post_mat.set_shader_parameter("enable_color_grading", enable_color_grading)

	_post_mat.set_shader_parameter("vignette_intensity", vignette_intensity)
	_post_mat.set_shader_parameter("vignette_size", vignette_size)
	_post_mat.set_shader_parameter("vignette_smoothness", vignette_smoothness)
	_post_mat.set_shader_parameter("vignette_roundness", vignette_roundness)

	_post_mat.set_shader_parameter("chromatic_aberration", chromatic_aberration)
	_post_mat.set_shader_parameter("ca_edge_start", ca_edge_start)
	_post_mat.set_shader_parameter("ca_blur", ca_blur)

	_post_mat.set_shader_parameter("distortion", distortion)
	_post_mat.set_shader_parameter("distortion_cubic", distortion_cubic)
	_post_mat.set_shader_parameter("distortion_overscan", distortion_overscan)
	_post_mat.set_shader_parameter("distortion_center", distortion_center)

	_post_mat.set_shader_parameter("grain_strength", grain_strength)
	_post_mat.set_shader_parameter("grain_size", grain_size)
	_post_mat.set_shader_parameter("grain_speed", grain_speed)
	_post_mat.set_shader_parameter("grain_shadows", grain_shadows)
	_post_mat.set_shader_parameter("grain_mids", grain_mids)
	_post_mat.set_shader_parameter("grain_highlights", grain_highlights)
	_post_mat.set_shader_parameter("enable_rgb_digital_noise", rgb_digital_noise)

	_post_mat.set_shader_parameter("enable_highlight_bloom", enable_highlight_bloom)
	_post_mat.set_shader_parameter("bloom_intensity", bloom_intensity)
	_post_mat.set_shader_parameter("bloom_threshold", bloom_threshold)
	_post_mat.set_shader_parameter("bloom_softness", bloom_softness)
	_post_mat.set_shader_parameter("bloom_radius", bloom_radius)
	_post_mat.set_shader_parameter("bloom_tint", Vector3(bloom_tint.r, bloom_tint.g, bloom_tint.b))

	_post_mat.set_shader_parameter("enable_halation", enable_halation)
	_post_mat.set_shader_parameter("halation_intensity", halation_intensity)
	_post_mat.set_shader_parameter("halation_threshold", halation_threshold)
	_post_mat.set_shader_parameter("halation_softness", halation_softness)
	_post_mat.set_shader_parameter("halation_radius", halation_radius)
	_post_mat.set_shader_parameter("halation_color", Vector3(halation_color.r, halation_color.g, halation_color.b))

	_post_mat.set_shader_parameter("exposure", exposure)
	_post_mat.set_shader_parameter("contrast", contrast)
	_post_mat.set_shader_parameter("saturation", saturation)
	_post_mat.set_shader_parameter("temperature", temperature)
	_post_mat.set_shader_parameter("tint", tint)

	_post_mat.set_shader_parameter("enable_lut", enable_lut and lut_texture != null)
	_post_mat.set_shader_parameter("lut_size", float(lut_size))
	_post_mat.set_shader_parameter("lut_strength", lut_strength)

	if lut_texture != null:
		_post_mat.set_shader_parameter("lut_texture", lut_texture)

	_post_mat.set_shader_parameter("lift", Vector3(lift.r, lift.g, lift.b))
	_post_mat.set_shader_parameter("gamma", Vector3(gamma_color.r, gamma_color.g, gamma_color.b))
	_post_mat.set_shader_parameter("gain", Vector3(gain.r, gain.g, gain.b))

func _apply_engine_dof() -> void:
	if !is_instance_valid(_camera):
		return

	var attrs: CameraAttributesPractical = _camera.attributes as CameraAttributesPractical
	if attrs == null:
		attrs = CameraAttributesPractical.new()
		_camera.attributes = attrs

	if !dof_enabled:
		attrs.dof_blur_near_enabled = false
		attrs.dof_blur_far_enabled = false
		return

	attrs.dof_blur_amount = dof_blur_amount

	attrs.dof_blur_near_enabled = dof_near_enabled
	attrs.dof_blur_near_distance = dof_near_distance
	attrs.dof_blur_near_transition = dof_near_transition

	attrs.dof_blur_far_enabled = dof_far_enabled
	attrs.dof_blur_far_distance = dof_far_distance
	attrs.dof_blur_far_transition = dof_far_transition

func _ensure_overlay() -> void:
	if _canvas_layer == null or !is_instance_valid(_canvas_layer):
		_canvas_layer = get_node_or_null(FLARE_LAYER_NAME)
		if _canvas_layer == null:
			_canvas_layer = CanvasLayer.new()
			_canvas_layer.name = FLARE_LAYER_NAME
			add_child(_canvas_layer)
			_set_scene_owner(_canvas_layer)

	if _rect == null or !is_instance_valid(_rect):
		_rect = _canvas_layer.get_node_or_null(FLARE_RECT_NAME)
		if _rect == null:
			_rect = ColorRect.new()
			_rect.name = FLARE_RECT_NAME
			_rect.anchor_left = 0.0
			_rect.anchor_top = 0.0
			_rect.anchor_right = 1.0
			_rect.anchor_bottom = 1.0
			_rect.offset_left = 0.0
			_rect.offset_top = 0.0
			_rect.offset_right = 0.0
			_rect.offset_bottom = 0.0
			_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_rect.color = Color(0, 0, 0, 0)
			_canvas_layer.add_child(_rect)
			_set_scene_owner(_rect)

	if _flare_mat == null:
		_flare_mat = ShaderMaterial.new()

	if flare_shader == null:
		_rect.visible = false
		_rect.material = null
		return

	_flare_mat.shader = flare_shader
	_rect.material = _flare_mat
	_rect.visible = true

func _refresh_lights() -> void:
	_known_lights.clear()
	_known_emissives.clear()

	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		return

	if include_all_lights:
		var found_lights: Array = scene_root.find_children("*", "Light3D", true, false)
		for n in found_lights:
			if n is Light3D:
				_known_lights.append(n)
	else:
		var found_group: Array = get_tree().get_nodes_in_group(light_group)
		for n in found_group:
			if n is Light3D:
				_known_lights.append(n)

	if include_emissive_meshes:
		var found_meshes: Array = scene_root.find_children("*", "MeshInstance3D", true, false)
		for n in found_meshes:
			if n is MeshInstance3D and _mesh_has_emissive_material(n):
				_known_emissives.append(n)

func _mesh_has_emissive_material(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance.mesh == null:
		return false

	var surface_count: int = mesh_instance.mesh.get_surface_count()
	for i in range(surface_count):
		var mat: Material = mesh_instance.get_active_material(i)
		if _material_emissive_strength(mat) >= emissive_threshold:
			return true

	return false

func _material_emissive_strength(mat: Material) -> float:
	if mat == null:
		return 0.0

	if mat is BaseMaterial3D:
		var bm: BaseMaterial3D = mat as BaseMaterial3D
		if !bm.emission_enabled:
			return 0.0

		var lum: float = bm.emission.r * 0.2126 + bm.emission.g * 0.7152 + bm.emission.b * 0.0722
		return lum * bm.emission_energy_multiplier

	return 0.0

func _get_emissive_mesh_data(mesh_instance: MeshInstance3D) -> Dictionary:
	if mesh_instance.mesh == null:
		return {}

	var best_strength: float = 0.0
	var best_color: Color = Color.WHITE

	var surface_count: int = mesh_instance.mesh.get_surface_count()
	for i in range(surface_count):
		var mat: Material = mesh_instance.get_active_material(i)
		var strength: float = _material_emissive_strength(mat)

		if strength > best_strength:
			best_strength = strength
			if mat is BaseMaterial3D:
				best_color = (mat as BaseMaterial3D).emission

	var local_center: Vector3 = mesh_instance.get_aabb().get_center()
	var world_pos: Vector3 = mesh_instance.to_global(local_center)

	return {
		"world_pos": world_pos,
		"strength": best_strength,
		"color": best_color
	}

func _apply_static_shader_params() -> void:
	if _flare_mat == null or _flare_mat.shader == null:
		return

	_flare_mat.set_shader_parameter("use_bokeh_texture", use_bokeh_texture and bokeh_texture != null)
	if bokeh_texture != null:
		_flare_mat.set_shader_parameter("bokeh_texture", bokeh_texture)

	_flare_mat.set_shader_parameter("master_intensity", master_intensity)
	_flare_mat.set_shader_parameter("blur_amount", blur_amount)
	_flare_mat.set_shader_parameter("chroma_amount", chroma_amount)
	_flare_mat.set_shader_parameter("halo_intensity", halo_intensity)
	_flare_mat.set_shader_parameter("ghost_intensity", ghost_intensity)
	_flare_mat.set_shader_parameter("ray_intensity", ray_intensity)
	_flare_mat.set_shader_parameter("imperfection", imperfection)
	_flare_mat.set_shader_parameter("ray_count", ray_count)
	_flare_mat.set_shader_parameter("ray_length", ray_length)
	_flare_mat.set_shader_parameter("ghost_spread", ghost_spread)
	_flare_mat.set_shader_parameter("source_bloom_scale", source_bloom_scale)
	_flare_mat.set_shader_parameter("bokeh_sample_step", 0.0018)
	_flare_mat.set_shader_parameter("ghost_opacity_falloff", 1.35)
	_flare_mat.set_shader_parameter("ghost_softness", 0.65)
	_flare_mat.set_shader_parameter("source_core_intensity", 0.35)
	_flare_mat.set_shader_parameter("ghost_nearness", 1.0)
	_flare_mat.set_shader_parameter("ghost_color_boost", 1.25)

func _source_key_for_light(light: Light3D) -> String:
	return "light_%s" % str(light.get_instance_id())


func _source_key_for_emissive(mesh_instance: MeshInstance3D) -> String:
	return "emissive_%s" % str(mesh_instance.get_instance_id())


func _axis_screen_presence(v: float) -> float:
	var margin: float = max(screen_entry_margin, 0.0001)
	var softness: float = clamp(screen_edge_softness, 0.0001, margin)
	var edge_strength: float = clamp(edge_presence_strength, 0.0, 1.0)

	if v < -margin or v > 1.0 + margin:
		return 0.0

	if v < 0.0:
		return edge_strength * smoothstep(-margin, 0.0, v)

	if v > 1.0:
		return edge_strength * (1.0 - smoothstep(1.0, 1.0 + margin, v))

	var edge_dist: float = min(v, 1.0 - v)
	var t: float = smoothstep(0.0, softness, edge_dist)
	return lerp(edge_strength, 1.0, t)


func _screen_presence_fade(uv: Vector2) -> float:
	return _axis_screen_presence(uv.x) * _axis_screen_presence(uv.y)


func _smooth_flare_scalar(current: float, target: float, speed: float, delta: float) -> float:
	if !enable_temporal_flare_smoothing:
		return target

	var t: float = 1.0 - exp(-max(speed, 0.001) * delta)
	return lerp(current, target, t)


func _smooth_flare_uv(current: Vector2, target: Vector2, speed: float, delta: float) -> Vector2:
	return target



func _update_flare_uniforms(delta: float) -> void:
	if _flare_mat == null or _flare_mat.shader == null or !is_instance_valid(_camera):
		return

	var viewport_size: Vector2 = _camera.get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var raw_sources: Dictionary = {}

	# Point / spot / omni lights
	for light in _known_lights:
		if light == null or !is_instance_valid(light):
			continue
		if !light.visible:
			continue
		if light is DirectionalLight3D:
			continue

		var energy: float = float(light.light_energy)
		if energy < energy_threshold:
			continue

		var world_pos: Vector3 = _get_light_world_pos(light)

		if _camera.is_position_behind(world_pos):
			continue
		if occlusion_check and _is_occluded(world_pos):
			continue

		var screen_pos: Vector2 = _camera.unproject_position(world_pos)
		var uv: Vector2 = Vector2(screen_pos.x / viewport_size.x, screen_pos.y / viewport_size.y)
		var presence: float = _screen_presence_fade(uv)

		if presence <= 0.0:
			continue

		var dist: float = _camera.global_position.distance_to(world_pos)
		var dist_factor: float = float(clamp(1.0 / pow(max(dist, 1.0) / 12.0, distance_falloff), 0.18, 1.0))
		var energy_norm: float = float(max(energy - energy_threshold, 0.0))

		var intensity: float = float(clamp(0.45 + energy_norm * 0.20, 0.0, 8.0)) * dist_factor * master_intensity * presence
		var size: float = float(base_flare_size * (1.0 + energy_norm * 0.08))
		var c: Color = light.light_color

		raw_sources[_source_key_for_light(light)] = {
			"uv": uv,
			"size": size,
			"intensity": intensity,
			"tint": Vector4(c.r, c.g, c.b, 1.0)
		}

	# Emissive meshes
	for mesh_instance in _known_emissives:
		if mesh_instance == null or !is_instance_valid(mesh_instance):
			continue
		if !mesh_instance.visible:
			continue

		var em: Dictionary = _get_emissive_mesh_data(mesh_instance)
		if em.is_empty():
			continue

		var strength: float = float(em["strength"])
		if strength < emissive_threshold:
			continue

		var world_pos: Vector3 = em["world_pos"]

		if _camera.is_position_behind(world_pos):
			continue
		if occlusion_check and _is_occluded(world_pos):
			continue

		var screen_pos: Vector2 = _camera.unproject_position(world_pos)
		var uv: Vector2 = Vector2(screen_pos.x / viewport_size.x, screen_pos.y / viewport_size.y)
		var presence: float = _screen_presence_fade(uv)

		if presence <= 0.0:
			continue

		var dist: float = _camera.global_position.distance_to(world_pos)
		var dist_factor: float = float(clamp(1.0 / pow(max(dist, 1.0) / 12.0, distance_falloff), 0.18, 1.0))
		var strength_norm: float = float(max(strength - emissive_threshold, 0.0))

		var intensity: float = float(clamp(0.30 + strength_norm * 0.22, 0.0, 8.0)) * dist_factor * master_intensity * presence
		var size: float = float(base_flare_size * (0.85 + strength_norm * 0.07))
		var c: Color = em["color"]

		raw_sources[_source_key_for_emissive(mesh_instance)] = {
			"uv": uv,
			"size": size,
			"intensity": intensity,
			"tint": Vector4(c.r, c.g, c.b, 1.0)
		}

	# Sun flare
	if enable_sun_flare and sun_light != null and is_instance_valid(sun_light) and sun_light.visible:
		var sun_data: Dictionary = _get_sun_flare_uv(sun_light, viewport_size)
		if !sun_data.is_empty():
			var uv: Vector2 = sun_data["uv"]
			var facing: float = float(sun_data.get("facing", 1.0))
			var presence: float = _screen_presence_fade(uv)
			var facing_fade: float = pow(clamp(facing, 0.0, 1.0), 1.35)

			var energy: float = float(sun_light.light_energy)
			var c: Color = sun_light.light_color

			var intensity: float = float(max(1.0, energy * sun_intensity_multiplier) * master_intensity * presence * facing_fade)
			var size: float = float(base_flare_size * sun_size_multiplier)

			if intensity > 0.001:
				raw_sources["sun"] = {
					"uv": uv,
					"size": size,
					"intensity": intensity,
					"tint": Vector4(c.r, c.g, c.b, 1.0)
				}

	# Temporal smoothing + fade-out memory
	var candidates: Array = []
	var seen_keys: Dictionary = {}

	for source_key_variant in raw_sources.keys():
		var source_key: String = str(source_key_variant)
		seen_keys[source_key] = true

		var raw: Dictionary = raw_sources[source_key]
		var raw_uv: Vector2 = raw["uv"]
		var raw_size: float = float(raw["size"])
		var raw_intensity: float = float(raw["intensity"])
		var raw_tint: Vector4 = raw["tint"]

		var prev_intensity: float = 0.0
		var prev_size: float = raw_size
		var prev_uv: Vector2 = raw_uv
		var prev_tint: Vector4 = raw_tint

		if _flare_history.has(source_key):
			var prev: Dictionary = _flare_history[source_key]
			prev_intensity = float(prev.get("intensity", 0.0))
			prev_size = float(prev.get("size", raw_size))
			prev_uv = prev.get("uv", raw_uv)
			prev_tint = prev.get("tint", raw_tint)

		var speed: float = flare_fade_in_speed if raw_intensity >= prev_intensity else flare_fade_out_speed

		var smoothed_intensity: float = _smooth_flare_scalar(prev_intensity, raw_intensity, speed, delta)
		var smoothed_size: float = _smooth_flare_scalar(prev_size, raw_size, speed, delta)
		var smoothed_uv: Vector2 = _smooth_flare_uv(prev_uv, raw_uv, speed, delta)

		_flare_history[source_key] = {
			"uv": smoothed_uv,
			"size": smoothed_size,
			"intensity": smoothed_intensity,
			"tint": raw_tint
		}

		if smoothed_intensity > 0.001:
			candidates.append({
				"score": smoothed_intensity * smoothed_size,
				"data": Vector4(smoothed_uv.x, smoothed_uv.y, smoothed_size, smoothed_intensity),
				"tint": raw_tint
			})

	var history_keys: Array = _flare_history.keys().duplicate()
	for source_key_variant in history_keys:
		var source_key: String = str(source_key_variant)
		if seen_keys.has(source_key):
			continue

		var prev: Dictionary = _flare_history[source_key]
		var prev_uv: Vector2 = prev.get("uv", Vector2.ZERO)
		var prev_size: float = float(prev.get("size", 0.0))
		var prev_intensity: float = float(prev.get("intensity", 0.0))
		var prev_tint: Vector4 = prev.get("tint", Vector4.ONE)

		var smoothed_intensity: float = _smooth_flare_scalar(prev_intensity, 0.0, flare_fade_out_speed * 1.5, delta)

		if smoothed_intensity <= 0.01:
			_flare_history.erase(source_key)
			continue

		_flare_history[source_key] = {
			"uv": prev_uv,
			"size": prev_size,
			"intensity": smoothed_intensity,
			"tint": prev_tint
		}

		candidates.append({
			"score": smoothed_intensity * prev_size,
			"data": Vector4(prev_uv.x, prev_uv.y, prev_size, smoothed_intensity),
			"tint": prev_tint
		})

	candidates.sort_custom(func(a, b): return a["score"] > b["score"])

	var flare_data: PackedVector4Array = PackedVector4Array()
	var flare_tint: PackedVector4Array = PackedVector4Array()

	var count: int = min(max_flares, candidates.size())
	for i in range(count):
		flare_data.append(candidates[i]["data"])
		flare_tint.append(candidates[i]["tint"])

	while flare_data.size() < MAX_FLARES:
		flare_data.append(Vector4.ZERO)
		flare_tint.append(Vector4.ZERO)

	_flare_mat.set_shader_parameter("flare_count", count)
	_flare_mat.set_shader_parameter("flare_data", flare_data)
	_flare_mat.set_shader_parameter("flare_tint", flare_tint)

func _get_sun_flare_uv(light: DirectionalLight3D, viewport_size: Vector2) -> Dictionary:
	if !is_instance_valid(_camera):
		return {}

	# Visible sun-disc direction.
	# If your flare appears mirrored again, flip this sign.
	var sun_dir: Vector3 = light.global_basis.z.normalized()

	var cam_forward: Vector3 = -_camera.global_basis.z.normalized()
	var facing: float = cam_forward.dot(sun_dir)

	# Sun behind camera = no flare.
	if facing <= 0.0:
		return {}

	var safe_distance: float = float(min(directional_distance, max(10.0, _camera.far * 0.5)))
	var sun_world_pos: Vector3 = _camera.global_position + sun_dir * safe_distance

	if _camera.is_position_behind(sun_world_pos):
		return {}

	if occlusion_check and _is_occluded(sun_world_pos):
		return {}

	var sp: Vector2 = _camera.unproject_position(sun_world_pos)
	var uv: Vector2 = Vector2(sp.x / viewport_size.x, sp.y / viewport_size.y)

	if uv.x < -screen_entry_margin or uv.x > 1.0 + screen_entry_margin:
		return {}
	if uv.y < -screen_entry_margin or uv.y > 1.0 + screen_entry_margin:
		return {}

	return {
		"uv": uv,
		"facing": facing
	}

func _get_light_world_pos(light: Light3D) -> Vector3:
	if light is DirectionalLight3D and is_instance_valid(_camera):
		var light_dir: Vector3 = -light.global_basis.z.normalized()
		var safe_distance: float = float(min(directional_distance, max(10.0, _camera.far * 0.5)))
		return _camera.global_position + (-light_dir) * safe_distance

	return light.global_position

func _is_occluded(world_pos: Vector3) -> bool:
	if !is_instance_valid(_camera):
		return false

	var space: PhysicsDirectSpaceState3D = _camera.get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(_camera.global_position, world_pos)
	query.collision_mask = occlusion_mask
	query.hit_from_inside = true

	var hit: Dictionary = space.intersect_ray(query)
	return !hit.is_empty()
