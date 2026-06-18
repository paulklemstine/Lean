# ECSTASIS — Audio-Visual Psychedelic Transport System

## Overview

ECSTASIS is a browser-based system that combines algorithmic music generation with neuroscience-informed psychedelic visuals to create immersive altered-state experiences.

## Components

### `index.html` — The Audio Engine
Infinite algorithmic electronic dance music generation across 10 genres using:
- Euclidean rhythms (Bjorklund algorithm)
- Markov chain melodies
- Perlin noise automation
- Psychoacoustic techniques (binaural beats, Shepard tones, entrainment)

### `visuals.html` — The Visual Transport System ✨ NEW
Audio-reactive psychedelic visual engine with six modes:

| Mode | Inspiration | Visual Character |
|------|------------|-----------------|
| **LSD** | Breathing Room | Flowing conformal maps, rainbow cycling, organic warping |
| **DMT** | Chrysanthemum Palace | Kaleidoscopic IFS, electric geometry, recursive embedding |
| **Psilocybin** | Mycelial Network | Reaction-diffusion, organic growth, warm earth tones |
| **Mescaline** | Crystal Desert | Angular tessellation, Voronoi crystallography, saturated color |
| **Cosmic** | Space Ocean | Nebulae, gravitational lensing, star fields, warp tunnels |
| **Geometry** | Pure Math | Conformal maps, Mandelbrot iteration, Möbius transformations |

Features:
- **Real-time WebGL rendering** at 60fps via GLSL fragment shaders
- **Audio-reactive**: Connects to microphone, internal synth, or any audio source
- **Feedback loop**: Ping-pong framebuffer for trails, echoes, visual persistence
- **Neural entrainment**: Subtle alpha-frequency brightness oscillation
- **Post-processing**: Bloom, chromatic aberration, vignette, film grain
- **Hypnotic staging**: Designed for progressive deepening over 30-50 minute sessions
- **Photosensitivity safeguards**: Warning screen, ESC emergency blackout

### Controls

| Key | Action |
|-----|--------|
| `1-6` | Switch visual mode |
| `H` | Toggle UI visibility |
| `F` | Toggle fullscreen |
| `ESC` | Emergency blackout (instant) |

Sliders:
- **Intensity**: Visual complexity and effect strength
- **Feedback**: Trail/echo persistence (higher = more psychedelic)
- **Speed**: Animation rate

Audio sources:
- **♪ Audio**: Internal drone synthesizer demo
- **🎤 Mic**: Microphone input (for live music reactivity)

## Usage

1. Open `visuals.html` in a modern browser (Chrome, Firefox, Edge)
2. Accept the photosensitivity warning
3. Click "♪ Audio" for built-in sound, or "🎤 Mic" to react to external music
4. Select a visual mode
5. Press `F` for fullscreen, then `H` to hide UI
6. Surrender to the geometry

## Best Practices

- **Use headphones** for maximum audio-visual coupling
- **Dim the room** for peripheral vision engagement
- **Fullscreen only** for immersive effect
- **30-50 minute sessions** for full hypnotic depth staging
- **Let your gaze soften** — peripheral vision is the gateway

## Technical Requirements

- Modern browser with WebGL 2.0 support
- GPU recommended (integrated graphics OK for most modes)
- No installation, no dependencies, no server required
