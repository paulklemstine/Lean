# Gravitomagnetism via Inverse Stereographic Projection and Arithmetic Light

## Overview

This module formalizes and explores the deep connections between gravitoelectromagnetism (GEM), inverse stereographic projection, and the arithmetic of Pythagorean triples ("arithmetic light").

## Contents

### Formal Mathematics (Lean 4)
- **`GravitomagneticStereo.lean`** — 25 machine-verified theorems, 0 sorry, standard axioms only

### Publications
- **`RESEARCH_PAPER.md`** — Comprehensive research paper with all formal results
- **`SCIENTIFIC_AMERICAN_ARTICLE.md`** — Popular science article
- **`APPLICATIONS.md`** — 7 proposed applications with TRL assessment
- **`HYPOTHESES_AND_EXPERIMENTS.md`** — 5 hypotheses tested and validated

### Python Demos
- **`demos/gem_stereographic_bridge.py`** — Core visualizations: integer gravitons, conformal factor, Berggren rotations, Lense-Thirring
- **`demos/gem_arithmetic_light.py`** — Berggren tree, spectral analysis, mass-energy duality, astrophysical applications
- **`demos/gem_hypothesis_experiments.py`** — Computational experiments for all 5 hypotheses

### Generated Figures
- `demos/gem_stereographic_bridge.png` — 4-panel core results
- `demos/gem_sphere_projection.png` — 3D sphere visualization
- `demos/gem_duality_oracle.png` — Duality, inversion, and oracle
- `demos/gem_arithmetic_light.png` — Berggren tree and spectrum
- `demos/gem_applications.png` — Astrophysical applications
- `demos/gem_warp_resonance.png` — Warp bubble and resonance
- `demos/h1_equidistribution.png` — Equidistribution test
- `demos/h4_critical_radius.png` — Warp bubble critical radius

## Key Results

| # | Result | Type |
|---|--------|------|
| 1 | Conformal factor = gravitational redshift | Formally proved |
| 2 | Pythagorean triples → unit GEM fields | Formally proved |
| 3 | Berggren rotations preserve GEM norm | Formally proved |
| 4 | Kelvin inversion = mass-energy duality | Formally proved |
| 5 | Lense-Thirring monotone in r⁻³ | Formally proved |
| 6 | Integer gravitons equidistribute on S¹ | Computationally validated |
| 7 | GEM spectral gaps encode number theory | Computationally validated |
| 8 | Warp bubble GEM peaks at wall | Computationally validated |

## Running

```bash
# Build formal proofs
lake build Gravitomagnetism

# Run demos (requires numpy, matplotlib)
python3 demos/gem_stereographic_bridge.py
python3 demos/gem_arithmetic_light.py
python3 demos/gem_hypothesis_experiments.py
```
