# EpicCameraX
**OpenAI ChatGPT is used to build this plugin**

EpicCameraX is a Godot 4 editor addon that adds a reusable **CameraPostProcessing** node for cinematic camera finishing.

It combines a screen-space post FX pass with a lens flare overlay and optional engine depth of field controls, so you can quickly give a scene a more polished camera look without wiring everything by hand.

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
- Lens flare overlay for:
  - point / omni / spot lights
  - directional sun flare
  - emissive `MeshInstance3D` objects using `BaseMaterial3D` emission
- Optional occlusion checks for flare sources
- Included example scene and fly camera helper

![screenshot](https://github.com/devkine/Epic-Camera-X/blob/main/EpicCameraX-01.png?raw=true)


## Godot version

Designed for **Godot 4.x**.

## Installation

### Option 1: Install from this repository

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
4. Either:
   - make it a **child** of the camera, or
   - place it as a **sibling** of the camera, or
   - assign `Target Camera` manually in the inspector.
5. Adjust the post FX values in the inspector.
6. For sun flare, assign a `DirectionalLight3D` to **Sun Light**.

The node can auto-find a camera when `Auto Find Camera` is enabled.

## How it works

When the node runs, it creates and manages two runtime helpers:

- a **screen quad** attached to the active camera for the post-processing shader
- a **CanvasLayer + ColorRect** overlay for lens flare rendering

You usually do not need to create these manually.

## Usage

### Basic setup

The fastest setup is:

- `Camera3D`
  - `CameraPostProcessing`

That is enough for vignette, distortion, chromatic aberration, grain, bloom, halation, LUT, and DOF control.

### Manual camera assignment

If the node is not next to the camera you want to use:

- disable `Auto Find Camera`, or leave it on
- assign `Target Camera` manually

### Sun flare setup

To enable directional sun flare:

1. Add a `DirectionalLight3D`.
2. Assign it to **Sun Light**.
3. Make sure **Enable Sun Flare** is enabled.
4. Tweak:
   - `Sun Intensity Multiplier`
   - `Sun Size Multiplier`
   - flare look settings

### Selective light flare setup

By default, the addon can scan all scene lights.

If you only want specific lights to generate flares:

1. Disable **Include All Lights**.
2. Put the wanted lights into a group.
3. Set **Light Group** to that group name.

Default group name:

```text
lens_flare_source
```

### Emissive mesh flare setup

EpicCameraX can also generate flares from emissive meshes.

Requirements:

- the object must be a `MeshInstance3D`
- the material must be a `BaseMaterial3D`
- `Emission Enabled` must be on
- the emissive strength must be above `Emissive Threshold`

### Occlusion setup

If **Occlusion Check** is enabled, the addon uses a 3D physics raycast from the camera to the flare source.

Make sure the relevant colliders are on the layers covered by **Occlusion Mask**.

## Inspector groups

### Setup

- `Target Camera`
- `Auto Find Camera`
- `Post Shader`
- `Flare Shader`
- `Sun Light`
- `Enable Sun Flare`

### Setup: Post Quad

- `Quad Distance Offset`
- `Quad Overscan`

These control the full-screen quad that carries the post-processing shader.

### Vignette

Controls vignette intensity, size, smoothness, and roundness.

### Chromatic Aberration

Controls fringe intensity, edge start, and blur.

### Lens Distortion

Controls barrel / pincushion distortion and overscan.

### Film Grain

Controls grain amount, size, speed, tonal weighting, and optional RGB digital noise.

### Highlight Bloom

Controls highlight bloom intensity, threshold, softness, radius, and tint.

### Halation

Controls highlight bleed color and spread.

### Color Grading

Controls exposure, contrast, saturation, temperature, tint, lift, gamma, and gain.

### LUT

Supports a 2D strip LUT texture.

Expected format:

- width = `lut_size * lut_size`
- height = `lut_size`

### Engine DOF

Applies depth of field settings to the active camera using `CameraAttributesPractical`.

Settings include:

- near blur enable / distance / transition
- far blur enable / distance / transition
- blur amount

### Light Selection

Controls which flare sources are scanned and how many are kept.

### Occlusion

Controls whether flare sources are blocked by geometry using physics raycasts.

### Flare Look / Transition / Sizing / Update

Controls the appearance and behavior of flare sprites, ghosting, softness, fade timing, size, and scan interval.

## Included example

The repository includes:

```text
addons/EpicCameraX/examples/example_scene.tscn
```

and a helper fly camera script:

```text
addons/EpicCameraX/examples/flycamera_viewport.gd
```

### Example controls

- **Left mouse button**: look around
- **Right mouse button**: look around + move
- **W / A / S / D**: move
- **Q / E**: down / up
- **Shift**: faster movement
- **Esc**: release mouse

## Scene tree example

```text
World
├── DirectionalLight3D
├── Camera3D
│   └── CameraPostProcessing
└── Environment / meshes / lights
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

### Emissive meshes do not create flares

- Use `BaseMaterial3D`
- Enable emission on the material
- Raise emission strength or lower `Emissive Threshold`
- Confirm `Include Emissive Meshes` is enabled

### DOF changed my camera attributes

This is expected. The addon uses `CameraAttributesPractical` for its engine DOF controls and can assign it to the target camera.

## Known notes

- Lens flare is screen-space and depends on camera visibility and source detection.
- Emissive source detection currently checks `BaseMaterial3D` emission only.
- Occlusion uses physics raycasts, so collider setup matters.
- The addon creates helper nodes automatically at runtime / in-editor.

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
    ├── plugin.cfg
    ├── plugin.gd
    └── plugin_icon.svg
```

## Credits

- Author: **Diginaat, DevKine**
