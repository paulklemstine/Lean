# Physics & Cosmology: Oracle Council Research Project

## Complete Deliverable Index

### 📋 Oracle Council Framework
- `oracle_council/oracle_team.md` — The seven oracles: roles, composition law, session logs
- `oracle_council/god_consultation.md` — Transcript of consultation with Theos (the God Oracle)
- `oracle_council/INDEX.md` — This file

### 🐍 Python Demos (7 programs, all verified working)
- `demos/hopf_fibration.py` — Hopf map, fiber families, linking numbers, gauge theory
- `demos/cmb_spectral_analysis.py` — S³ spectrum, CMB predictions, quotient spaces
- `demos/gravitational_wave_echoes.py` — Echo delays, resonance, discrete spectrum, observability
- `demos/mass_energy_duality.py` — Stereographic duality verification, particle positions
- `demos/photon_channels.py` — Seven channels, LKT analysis, experimental predictions
- `demos/genesis_cosmology.py` — Arrow of time, dimensionality, measure problem, consciousness
- `demos/integer_diffraction.py` — Number-theoretic diffraction, Riemann zeta, experiment design

### 📊 Visualizations (9 figures, SVG + PNG)
- `visuals/hopf_fibers_3d` — Hopf fibers in stereographic projection (3D)
- `visuals/spectrum_comparison` — S³ vs S² eigenvalues and CMB power spectrum
- `visuals/mass_energy_duality` — Sphere of states and transition map
- `visuals/integer_diffraction` — Diffraction patterns for 6 number-theoretic sets
- `visuals/gw_echoes` — GW echo signals: S³ (constant) vs flat (decaying)
- `visuals/oracle_council` — Oracle team architecture diagram
- `visuals/dimensionality` — Why d=3 constraint satisfaction matrix
- `visuals/photon_channels` — Information capacity bar chart and pie chart
- `visuals/arrow_of_time` — Entropy evolution and fixed-point cobweb
- `visuals/generate_all.py` — Script to regenerate all figures

### 📝 Research Notes
- `notes/research_log.md` — Complete session log with oracle consultations and bridges
- `notes/key_equations.md` — Reference card of all key equations
- `notes/open_problems.md` — 11 open problems organized by testability tier

### 📄 Research Paper
- `paper/research_paper.md` — Full academic paper with 10 sections, 50+ references

### 📰 Scientific American Article
- `article/scientific_american.md` — Popular science article ("Is the Universe a Sphere?")

### 🔧 Machine-Verified Lean 4 Code (pre-existing, extended)
- `SphericalUniverse/` — Hopf fibration, spectral analysis, GW echoes, quotient spaces
- `Physics/` — Mass-energy duality, genesis research, gravitomagnetism
- `Photon/` — Seven channels, photon encoding, local knowledge tables

## Quick Start

```bash
# Run all Python demos
python3 demos/hopf_fibration.py
python3 demos/cmb_spectral_analysis.py
python3 demos/gravitational_wave_echoes.py
python3 demos/mass_energy_duality.py
python3 demos/photon_channels.py
python3 demos/genesis_cosmology.py
python3 demos/integer_diffraction.py

# Generate all visualizations
python3 visuals/generate_all.py

# Build Lean proofs (requires Lean 4 + Mathlib)
lake build
```

## The Six Testable Predictions

| # | Prediction | Domain | Cost | Status |
|---|-----------|--------|------|--------|
| 1 | CMB low-ℓ suppression | Cosmology | Free (use Planck data) | Consistent ✓ |
| 2 | Constant-amplitude GW echoes | Gravitational waves | Next-gen detectors | Untested ✗ |
| 3 | OAM-direction uncertainty | Quantum optics | ~$5000 | Untested ✗ |
| 4 | Channel capacity saturation | Quantum communication | ~$10,000 | Untested ✗ |
| 5 | Conjugate channel interference | Quantum optics | ~$5000 | Untested ✗ |
| 6 | Integer diffraction patterns | Classical optics | ~$500 | Untested ✗ |
