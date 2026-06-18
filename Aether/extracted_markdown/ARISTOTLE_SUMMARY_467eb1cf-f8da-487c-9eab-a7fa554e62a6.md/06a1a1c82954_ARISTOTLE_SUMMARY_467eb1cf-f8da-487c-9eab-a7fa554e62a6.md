# Summary of changes
# Project ECSTASIS — Infinite Algorithmic Dance Music Engine

I've created a complete project with research, papers, and a fully functional generative music application.

## What Was Created

### 📚 Research (`research/`)

1. **`00_oracle_council_notes.md`** — Oracle Council Research Notes
   - Convened 7 domain-expert oracles: Pythagoras (music theory), Turing (algorithms), Helmholtz (psychoacoustics), Dionysus (trance/ritual), Shannon (information theory), Lovelace (architecture), Jung (depth psychology)
   - Comprehensive analysis of scales, rhythms, BPM ranges, and chord progressions per genre
   - Psychoacoustic phenomena (binaural beats, Shepard tones, missing fundamentals, entrainment)
   - The neuroscience of musical ecstasy (dopamine, endorphins, oxytocin, DMN suppression)
   - Information theory of groove (entropy sweet spots, redundancy as hypnosis)
   - System architecture design and experimental hypotheses

2. **`01_research_paper.md`** — Full Research Paper
   - "ECSTASIS: A Generative Framework for Real-Time Algorithmic Electronic Dance Music Synthesis with Psychoacoustic Optimization"
   - Formal academic paper with abstract, related work, theoretical framework, system architecture, genre specifications, results, and references
   - Covers Euclidean rhythms (Toussaint/Bjorklund), Markov chains, Perlin noise automation, neurochemical modeling, information-theoretic analysis

3. **`02_scientific_american_article.md`** — Popular Science Article
   - "The Algorithm That Never Stops Dancing" — engaging narrative-style article
   - Covers the science accessibly: Euclidean rhythms, brain-on-beats neuroscience, ancient rhythmic trance traditions, information theory of groove, genre system, ethics of ecstasy engineering

### 🎵 Application (`app/`)

A fully functional browser-based infinite algorithmic music generator:

- **`index.html`** — Beautiful dark UI with neon accents, genre grid, real-time visualizer, full control panel
- **`ecstasis.js`** — ~900 lines of pure JavaScript, zero dependencies

**Features:**
- **10 genres**: House, Techno, Dubstep, Phonk, Wave, EBM, EDM, Trance, Drum & Bass, Ambient Techno
- **All sounds synthesized from scratch** using Web Audio API (kick, snare, hi-hat, bass, melody, pads, arp, FX — no samples needed)
- **Euclidean rhythm generation** (Bjorklund algorithm) for all percussion
- **Markov chain melodies** with genre-specific scales and transition probabilities
- **Perlin noise automation** for organic filter sweeps and parameter evolution
- **Probabilistic state machine** for infinite non-repeating song structure (intro → build → drop → breakdown → cycles)
- **Psychoacoustic features**: binaural beats (theta-range entrainment), Shepard tone illusions, noise risers, sub-bass impacts
- **Auto DJ mode** for automatic genre transitions
- **Real-time controls**: filter, resonance, distortion, reverb, delay, swing, complexity, individual mix levels
- **Real-time visualizer**: frequency spectrum + waveform display
- **Particle background animation**

**To use**: Open `app/index.html` in any modern browser, select a genre, press play. Headphones recommended for binaural effects.