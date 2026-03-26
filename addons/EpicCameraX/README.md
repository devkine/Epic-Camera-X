# EpicCameraX

EpicCameraX is a Godot 4 editor addon that adds a reusable **CameraPostProcessing** node for cinematic camera finishing.

It combines a screen-space post-processing pass, lens flare overlay, film grain, bloom, halation, LUT support, and optional engine depth of field helpers so you can add a polished camera look without wiring everything by hand.

## Features

- Custom **CameraPostProcessing** node available directly in the editor
- Screen-space post FX shader on a camera-attached quad
- Vignette
- Chromatic aberration
- Lens distortion
- Film grain with optional RGB digital noise
- Color grading controls
- Highlight bloom
- Halation
- LUT support
- Built-in engine DOF controls through `CameraAttributesPractical`
- Lens flare overlay for point, omni, spot, and directional lights
- Emissive `MeshInstance3D` flare source support using `BaseMaterial3D` emission
- Optional occlusion checks for flare sources
- Included example scene and fly camera helper

## Godot version

Designed for **Godot 4.6**.

## Installation

1. Copy the `addons/EpicCameraX` folder into your Godot project so the final path becomes:

```text
res://addons/EpicCameraX
```

2. Open your project in Godot.
3. Go to **Project > Project Settings > Plugins**.
4. Enable **EpicCameraX**.

Once enabled, the plugin registers a new custom node:

- `CameraPostProcessing`

## Quick start

1. Enable the plugin.
2. Add a `Camera3D` to your scene.
3. Add a **CameraPostProcessing** node.
4. Make it a child of the camera, place it as a sibling, or assign **Target Camera** manually.
5. Adjust the post FX values in the inspector.
6. For sun flare, assign a `DirectionalLight3D` to **Sun Light**.

The node can auto-find a camera when **Auto Find Camera** is enabled.

## Included example

The repository includes:

```text
addons/EpicCameraX/examples/example_scene.tscn
```

and a helper fly camera script:

```text
addons/EpicCameraX/examples/flycamera_viewport.gd
```

## Repository structure

```text
addons/
└── EpicCameraX/
    ├── examples/
    │   ├── example_scene.tscn
    │   └── flycamera_viewport.gd
    ├── scenes/
    │   └── post_processing_node.tscn
    ├── scripts/
    │   └── post_processing_node.gd
    ├── shaders/
    │   ├── real_camera_post_fx.gdshader
    │   └── ue_like_lens_flare.gdshader
    ├── assetlib_icon.png
    ├── plugin_icon.svg
    ├── plugin.cfg
    ├── plugin.gd
    ├── README.md
    └── LICENSE
```

## Troubleshooting

### Plugin enabled but node does not show up

- Confirm the folder is at `res://addons/EpicCameraX`
- Confirm the plugin is enabled in **Project Settings > Plugins**
- Reopen the project if Godot cached old addon state

### No effect appears on screen

- Make sure the node found the correct camera
- Try assigning `Target Camera` manually
- Make sure `Post Shader` is assigned
- Make sure the camera is the active viewport camera

### No lens flare appears

- Make sure `Flare Shader` is assigned
- Increase `Master Intensity`
- Lower `Energy Threshold`
- Assign `Sun Light` for directional flare
- Check `Occlusion Check` and `Occlusion Mask`
- Make sure the source is visible to the camera

## License

This addon is released under the **MIT License**. See `LICENSE`.
