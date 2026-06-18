# Arithmetic Photons 🌟

## Pythagorean Quadruples as Discrete Light Rays in Integer Spacetime

The equation $a^2 + b^2 + c^2 = d^2$ is simultaneously a Diophantine equation
and the **null cone** of $(3+1)$-dimensional Minkowski spacetime. Solutions are
*arithmetic photons*: whole-number paths through spacetime at light speed.

---

## Contents

### 📐 Formal Proofs (Lean 4 + Mathlib)
- **`Basic.lean`** — 30+ formally verified theorems including:
  - Null cone equivalence (`pythQuad_iff_null`)
  - Parametrization validity (`quadParam_valid`)
  - Euler four-square identity (`euler_four_square`)
  - Stereographic projection on sphere (`invStereo2_on_sphere`)
  - Universal hypotenuse property (`every_d_is_hypotenuse`)
  - Photon graph symmetry (`photon_connected_symm`)
  - Lorentz form properties (homogeneity, additivity, evenness)
  - Causal classification theorem
  - All 6 spatial symmetries (3 permutations + 3 negations)

### 🐍 Python Demonstrations (with visualizations)
- **`demos/01_null_cone_visualization.py`** — 3D scatter of null cone points, shell structure, energy spectrum
- **`demos/02_celestial_sphere.py`** — Rational points on S², stereographic projection, density heatmap
- **`demos/03_photon_graph.py`** — Light propagation graph on integer lattice, connectivity analysis, causal diamond
- **`demos/04_quaternion_hopf.py`** — Hopf fiber structure, quaternion multiplication, parameter space
- **`demos/05_causal_census.py`** — Null/timelike/spacelike classification, dark matter ratio
- **`demos/06_dimensional_bridges.py`** — Dimensional ladder, Legendre's theorem, projection lifting

### 📝 Research Documents
- **`research_notes.md`** — Oracle Council session notes: 5 rounds of research, hypothesizing, experimenting, validating, and iterating
- **`paper.md`** — Full research paper: *"Arithmetic Photons: Pythagorean Quadruples as Discrete Light Rays in Integer Spacetime"*
- **`sciam_article.md`** — Scientific American article: *"When Numbers Travel at Light Speed"*

### 🖼️ Generated Visualizations (17 images)
Run the Python demos to generate PNG visualizations in the `demos/` directory.

---

## Five Bridges Discovered

| Bridge | Connects | Key Object |
|--------|----------|------------|
| **Lorentz–Gauss** | Number Theory ↔ Relativity | O(3,1;ℤ) |
| **Hopf** | Topology ↔ Algebra | S³ → S² fibration |
| **Partition** | Combinatorics ↔ Physics | θ₃(q)³ modular form |
| **Rational Point** | Geometry ↔ Cryptography | Stereographic map |
| **Circle Method** | Analysis ↔ Number Theory | Singular series |

---

## Key Insight

> *3+1 dimensions are algebraically special because quaternions exist.
> The Hopf fibration S³ → S² governs the parametrization of arithmetic photons.
> The arithmetic universe is mostly dark matter — photons are vanishingly rare.*
