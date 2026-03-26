@tool
extends EditorPlugin

const ADDON_DIR := "res://addons/EpicCameraX"
const POST_SCRIPT := ADDON_DIR + "/scripts/post_processing_node.gd"
const ICON_PATH := ADDON_DIR + "/plugin_icon.svg"

var _icon: Texture2D
var _script: Script

func _enter_tree() -> void:
	_icon = load(ICON_PATH)
	_script = load(POST_SCRIPT)

	if _script != null:
		add_custom_type("CameraPostProcessing", "Node", _script, _icon)

func _exit_tree() -> void:
	remove_custom_type("CameraPostProcessing")
