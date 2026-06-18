# EML–Pythagorean Bridge: Research Package

## Overview

This directory contains a comprehensive research package exploring the connection between the EML (Exp-Minus-Log) operator and the Berggren tree of primitive Pythagorean triples. It includes machine-verified Lean 4 proofs, Python computational demos, SVG visualizations, research papers, and a Scientific American-style article.

## Contents

### Lean 4 Formalizations (all compile without `sorry`)

| File | Key Results |
|------|-------------|
| `PrimitivityPreservation.lean` | Lorentz form preservation, Pythagorean preservation for all 3 Berggren matrices, Brahmagupta-Fibonacci identity, hypotenuse product theorem, determinant properties |
| `GaussianBridge.lean` | Gaussian integer connection, Brahmagupta as norm multiplicativity, Pythagorean primes, Euclid parametrization via Gaussian squaring, rotation/negation preserve triples |
| `HyperbolicGeometry.lean` | Berggren matrices as Lorentz isometries, determinant structure (det B₁ = det B₃ = 1, det B₂ = -1), hyperbolic angle and depth definitions, dominant eigenvalue 3+2√2 |
| `BerggrenCompleteness.lean` | Tree generation, depth computation, Pell recurrence verification, inverse Berggren (parent) maps, tree enumeration at multiple depths |
| `FixedPointTheory.lean` | exp(x) > x for all x ∈ ℝ, EML fixed-point bifurcation at y = e, tangency verification, exp derivative at 0, EML iteration dynamics |

### Python Demos

| File | Description |
|------|-------------|
| `demos/berggren_tree_explorer.py` | Comprehensive demo: tree generation, angle distribution analysis, B-branch growth rates, Pell recurrence, EML operator demonstration, Gaussian integer connection, hyperbolic geometry |
| `demos/eml_dynamics.py` | EML as universal function generator, fixed-point bifurcation analysis, stability analysis, iteration dynamics, Lambert W connection |
| `demos/hyperbolic_visualization.py` | Generates SVG visualizations: Poincaré disk projection of the Berggren tree and angle histogram |

### SVG Visualizations

| File | Description |
|------|-------------|
| `visuals/berggren_tree.svg` | The Berggren tree to depth 2 with angles, colors by branch type, and key properties panel |
| `visuals/eml_pythagorean_bridge.svg` | Overview diagram showing the bridge between number theory, algebra, analysis, and computation |
| `visuals/research_roadmap.svg` | Research roadmap with 8 themes, status indicators, and open questions |
| `visuals/poincare_disk.svg` | Generated: Berggren tree projected onto the Poincaré disk model |
| `visuals/angle_histogram.svg` | Generated: Histogram of angle distribution with statistics |

### Papers

| File | Description |
|------|-------------|
| `papers/research_paper.md` | Full research paper with verified theorems, computational experiments, and new conjectures |
| `papers/scientific_american_article.md` | Popular science article explaining the EML–Pythagorean bridge for general audiences |
| `papers/future_research_directions.md` | Updated v4 catalog of 40+ research directions with status, timeline, and priority matrix |
| `papers/applications_brainstorm.md` | 15 application ideas spanning cryptography, neural networks, signal processing, financial math, robotics, and more |

## Running the Demos

```bash
# Full tree exploration with statistics
python3 demos/berggren_tree_explorer.py

# EML dynamics and fixed-point analysis
python3 demos/eml_dynamics.py

# Generate SVG visualizations
python3 demos/hyperbolic_visualization.py
```

## Key Discoveries

1. **Determinant asymmetry:** det(B₁) = det(B₃) = 1, but det(B₂) = -1 — B₂ includes a hidden reflection
2. **EML saddle-node bifurcation:** The EML operator undergoes a bifurcation at y = e, with 0/1/2 fixed points
3. **Non-uniform angle distribution:** Mean angle → 45° but std dev ≈ 17.5° (below uniform value of 26°)
4. **Pell recurrence exactness:** B-branch hypotenuses exactly satisfy c_{n+1} = 6c_n - c_{n-1}
5. **Lambert W connection:** EML fixed points satisfy x = -W(-1/y) - ln(y)

## Verified Theorem Count

**30+ machine-verified theorems** across number theory, linear algebra, real analysis, and combinatorics — all without `sorry`.
