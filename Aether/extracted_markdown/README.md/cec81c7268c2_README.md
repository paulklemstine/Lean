This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Idempotent Lens

**Inverse stereographic projection as the universal bridge between concrete and abstract spaces.**

> *"Inverse stereographic projection is the idempotent lens that turns reality into ideas. Momentum and energy, it is all a conversion from one space into the other."*

---

## Project Overview

This project formalizes, proves, demonstrates, and applies the idea that stereographic projection — and its inverse — form a universal mathematical "lens" connecting flat (Euclidean) spaces to curved (spherical) spaces. This lens is **idempotent**: applying it twice is the same as applying it once, because applying it once is already the identity.

The same structural pattern — a conformal bijection between complementary spaces — appears in:
- **Geometry**: ℝⁿ ↔ Sⁿ (Euclidean space ↔ sphere)
- **Physics**: momentum ↔ energy (via the mass shell)
- **Analysis**: position ↔ frequency (via the Fourier transform)
- **Topology**: X ↔ X ∪ {∞} (one-point compactification)
- **Complex analysis**: ℂ ↔ Riemann sphere

## Contents

### 📐 Formal Proofs (Lean 4 + Mathlib)

| File | Content |
|------|---------|
| `RequestProject/StereographicLens.lean` | Circle case: 11 formally verified theorems |
| `RequestProject/HigherDimensional.lean` | General case: 7 formally verified theorems |

**18 theorems, 0 sorries, all machine-verified.**

Key theorems proved:
- Round-trip identity: σ ∘ σ⁻¹ = id and σ⁻¹ ∘ σ = id
- Idempotent lens: L² = L (both directions)
- σ⁻¹ lands on the circle: ‖σ⁻¹(t)‖ = 1
- Antipodal duality: σ(-p) = -1/σ(p)
- Fixed point classification: exactly 3 self-referential points
- Conformal factor: positivity, exact values at south pole and equator
- One-point compactification: compactness and connectedness
- Stereographic denominator positivity
- Möbius identity

### 📄 Papers

| File | Description |
|------|-------------|
| `papers/research_paper.md` | Full research paper with formal verification |
| `papers/scientific_american.md` | Accessible article for general audience |

### 🐍 Python Demos

| File | Description |
|------|-------------|
| `python_demos/demo1_stereographic_visualization.py` | Interactive visualization + round-trip verification |
| `python_demos/demo2_sphere_projection.py` | 3D visualization: S² → ℝ² |
| `python_demos/demo3_energy_momentum.py` | Fourier transform + energy-momentum duality |
| `python_demos/demo4_mobius_symmetry.py` | Möbius transformations as lens symmetries |
| `python_demos/demo5_applications.py` | 7 applications + 3 hypothesis tests |

### 🖼️ Generated Figures

| File | Description |
|------|-------------|
| `python_demos/stereographic_lens.png` | 4-panel visualization of the stereographic lens |
| `python_demos/sphere_projection_3d.png` | 3D sphere projection with latitude circles |
| `python_demos/energy_momentum_duality.png` | 6-panel energy-momentum analysis |
| `python_demos/mobius_symmetry.png` | 6 Möbius transformation examples |
| `python_demos/applications.png` | Applications dashboard |

## Running

### Lean proofs
```bash
lake build RequestProject.StereographicLens
lake build RequestProject.HigherDimensional
```

### Python demos
```bash
pip install numpy matplotlib
python python_demos/demo1_stereographic_visualization.py
python python_demos/demo2_sphere_projection.py
python python_demos/demo3_energy_momentum.py
python python_demos/demo4_mobius_symmetry.py
python python_demos/demo5_applications.py
```

## Hypotheses Tested

| # | Hypothesis | Result |
|---|-----------|--------|
| 1 | Conformal factor encodes information density | ✓ Partially confirmed (correlation -0.51) |
| 2 | Stereographic compression preserves SNR better than sigmoid | ✗ Not confirmed (both comparable) |
| 3 | Möbius dynamics classification (elliptic/hyperbolic/parabolic/loxodromic) | ✓ Confirmed |

## Applications Proposed

1. **Signal Processing** — Dynamic range compression via stereographic mapping
2. **Computer Vision** — Fisheye lens correction as inverse stereographic projection
3. **Machine Learning** — Hyperspherical embeddings for data representation
4. **Robotics** — Gimbal-lock-free orientation via stereographic coordinates on S³
5. **Complex Analysis** — Riemann sphere as the natural domain for meromorphic functions
6. **Physics** — Conformal compactification (Penrose diagrams), energy-momentum duality
7. **Cartography** — All conformal map projections as variations of the stereographic lens

## License

Research and educational use.
