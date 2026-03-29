# ECSTASIS — Infinite Algorithmic Dance Music Engine

## Quick Start

1. Open `index.html` in any modern web browser (Chrome, Firefox, Edge, Safari)
2. Select a genre
3. Press the ▶ play button
4. Put on headphones for full effect
5. The music never stops. Each moment is generated fresh.

## Features

### 🎵 10 Electronic Genres
- **House** (120-130 BPM) — Warm, soulful, four-on-the-floor grooves
- **Techno** (128-145 BPM) — Dark, hypnotic, machine-precision rhythms
- **Dubstep** (140 BPM) — Heavy half-time bass, aggressive drops
- **Phonk** (130-160 BPM) — Dark Memphis-influenced beats, cowbell-driven
- **Wave** (140-160 BPM) — Ethereal, melancholic, reverb-drenched atmospheres
- **EBM** (110-140 BPM) — Industrial, martial, motorik rhythms
- **EDM** (126-132 BPM) — Festival-ready euphoric anthems
- **Trance** (136-150 BPM) — Euphoric builds, transcendent melodies
- **Drum & Bass** (170-180 BPM) — Breakbeat-derived high-energy patterns
- **Ambient Techno** (100-122 BPM) — Gentle, cosmic, meditative pulses

### 🎛 Real-Time Controls
- **Filter** — Low-pass filter cutoff and resonance
- **Effects** — Reverb, delay, distortion
- **Mix** — Individual level control for kick, snare, hats, bass, melody, pads, arp, FX
- **Swing** — Adjustable groove feel
- **Complexity** — Controls density of arrangement

### 🧠 Psychoacoustic Features
- **Binaural Beats** — Theta-range entrainment (7 Hz) for trance-state induction
- **Shepard Tones** — Endlessly ascending pitch illusion during builds
- **Brainwave Entrainment** — Rhythmic patterns calibrated to target neural frequencies

### 🎛 Auto DJ Mode
Automatically transitions between genres, creating an infinite multi-genre journey.

## Technical Architecture

### Algorithms Used
- **Euclidean Rhythms** (Bjorklund algorithm) — All drum patterns
- **Markov Chains** — Melodic generation with genre-specific transition probabilities
- **Perlin Noise** — Continuous parameter automation (filter, effects)
- **L-System inspired structures** — Section-level arrangement
- **Probabilistic State Machine** — Song structure and section transitions

### Music Theory
- 14 scales/modes (minor, Dorian, Phrygian, Lydian, etc.)
- 10 chord types (min, maj, min7, maj7, dom7, sus2, sus4, etc.)
- Genre-specific chord progressions
- Key modulation between sections

### Synthesis
- All sounds synthesized from scratch using Web Audio API
- Kick: Sine oscillator with pitch envelope + noise transient
- Snare: Filtered noise + triangle body
- Hi-hat: Filtered noise with variable envelope
- Bass: Oscillator through resonant filter with sub-bass layer
- Melody: Detuned oscillator pair
- Pads: Multi-voice detuned oscillators
- Arp: Filtered sawtooth with envelope

### No Dependencies
Zero external libraries. Pure JavaScript + Web Audio API.
Runs entirely in the browser. No server required.
No data collection. No accounts. Just math.

## Research

See the `/research` directory for:
- `00_oracle_council_notes.md` — Oracle Council research notes
- `01_research_paper.md` — Full research paper
- `02_scientific_american_article.md` — Popular science article
