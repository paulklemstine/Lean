# Summary of changes
# SYNESTHESIA — Algorithmic Psychedelic Music Machine

I've built a complete, self-contained system spanning music generation, psychedelic visuals, and research documentation.

## Deliverables

### 1. The App (`app/index.html`)
A zero-dependency, single-file web application (~69KB) that runs in any modern browser. Features:

**Music Engine (12 Genres):**
- Techno, House, Dubstep, Phonk, Wave, EBM, EDM, Trance, Acid House, Ambient, Industrial, Drum & Bass
- Full Web Audio API synthesis: kick, snare, hi-hat, bass (with genre-specific waveshaping), lead, pads
- Effects chain: BPM-synced delay, convolution reverb, waveshaper distortion, dynamics compression
- Algorithmic composition via 4 methods:
  - **Markov chains** for melodic generation (7-state transition matrix over scale degrees)
  - **Euclidean rhythm algorithm** (Toussaint 2005) for percussion patterns
  - **Cellular automata** (Wolfram Rules 30/90/110/150) for chaotic pattern evolution
  - **L-systems** for structural variation over time
- 15 scales, 12 chord types, 10 chord progressions, genre-specific synthesis techniques (acid 303 filter sweeps, dubstep wobble LFO, phonk swing quantization)
- Binaural beat entrainment layer targeting theta/alpha/beta brainwave bands

**Visual Engine (10 Modes):**
- Fractal Tunnel, Plasma Ocean, Sacred Geometry, Waveform Matrix, Particle Storm, Hypno Spiral, DMT Gateway, Void Meditation, Kaleidoscope, Neural Network
- All GPU-accelerated WebGL fragment shaders at 60fps
- Real-time FFT audio analysis drives all visual parameters (bass/mid/high/peak)
- Based on Klüver's form constants from visual neuroscience research

**Controls:** Genre selection, Intensity, Chaos, Depth, Visual Intensity, Hypnosis sliders + keyboard shortcuts (Space, M, V, F, 1-9)

### 2. Research Paper (`research/research-paper.md`)
Full academic-style paper covering:
- Music theory foundations (scales, chords, rhythm)
- All 4 algorithmic composition methods with mathematical detail
- Psychoacoustic principles (binaural beats, missing fundamental, dopamine dynamics)
- Visual neuroscience (form constants, symmetry preference, photic driving)
- Complete system architecture diagrams
- Genre parameterization model
- Shader catalogue (all 10 modes documented)
- Oracle consultation notes and iteration log
- References to Toussaint, Wolfram, Bressloff, Klüver, Huron, Csíkszentmihályi, etc.

### 3. Scientific American Article (`research/scientific-american-article.md`)
Accessible long-form article (~3000 words) with sidebars on binaural beats and form constants, suitable for a general audience.

### 4. README (`README.md`)
Complete project documentation with quick start, feature list, controls reference, architecture diagram, and usage notes.

## How to Use
Open `app/index.html` in Chrome or Firefox, click "ENTER THE VOID", and put on headphones. Recommended: darkened room, 15+ minute sessions for full entrainment effects.