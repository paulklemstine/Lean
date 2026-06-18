# EML Operator Research — V12

## Overview

This directory contains a comprehensive research package for the **EML operator** $\operatorname{eml}(x, y) = e^x - \ln y$, a Sheffer operator for the elementary function algebra. The package includes formally verified theorems, Python demonstrations, SVG visualizations, a research paper, a Scientific American-style article, and a comprehensive applications brainstorm.

## Contents

### 📐 Formal Verification (`EML/EMLFutureResearch.lean`)
**33 new theorems**, all formally verified in Lean 4.28.0 with Mathlib (zero sorries):

| Category | Theorems | Highlights |
|----------|:--------:|------------|
| Quasi-division | 4 | Right division always solvable; left division domain characterized |
| Basin of attraction | 3 | g-map positivity, fixed point existence, contraction |
| Convexity | 3 | Diagonal map strictly convex, has minimum, d(z) > z |
| Hessian geometry | 2 | Positive definite metric, negative curvature |
| Geodesics | 2 | x- and y-geodesic ODE solutions verified |
| Approximation | 3 | Constants generation, negation, subtraction |
| E-tower | 2 | Strict monotonicity, superexponential growth |
| Tropical EML | 3 | Idempotence, non-commutativity, averaging bound |
| Composition | 3 | Left composition, e-tower connection, iteration |
| Inequalities | 3 | Lower bound, strict mono in x, strict anti in y |
| Complexity | 5 | exp=1, (1-x)=2, generates e, 0, -1 |

### 🐍 Python Demos (`demos/`)
- **`eml_julia_set.py`** — Julia set computation, orbit analysis, g-map convergence, symbolic regression, tropical EML
- **`eml_dynamics_explorer.py`** — Phase portraits, cobweb diagrams, e-tower growth, Hessian geometry, quasi-division demos
- **`eml_symbolic_regression.py`** — EML tree-based symbolic regression engine with benchmarking

### 🎨 SVG Visualizations (`visuals/`)
- **`eml_research_roadmap.svg`** — 5-year research roadmap with 50 directions across 4 time horizons
- **`eml_theorem_landscape.svg`** — Complete map of verified theorems from foundations to frontiers
- **`eml_operator_anatomy.svg`** — How EML works: decomposition, generation chain, key properties
- **`eml_quasi_division.svg`** — Right vs left quasi-division comparison with domain analysis

### 📄 Papers (`papers/`)
- **`EML_Research_Paper_V12.md`** — Formal research paper with all new results
- **`EML_Future_Research_Directions_V12.md`** — Comprehensive 50-direction roadmap
- **`EML_Scientific_American_V12.md`** — Accessible article for general audiences
- **`EML_Applications_Brainstorm_V12.md`** — 50 application ideas across 6 domains

## Running the Demos

```bash
pip install numpy
python demos/eml_julia_set.py
python demos/eml_dynamics_explorer.py
python demos/eml_symbolic_regression.py
```

## Building the Lean Proofs

```bash
lake build EML.EMLFutureResearch
```

## Key Discoveries

1. **EML is a right quasigroup** — the equation eml(a,x) = b always has a unique solution x = exp(eᵃ − b)
2. **EML geometry is hyperbolic** — Gaussian curvature K = −eˣ/(4y²) < 0, with logarithmic and exponential geodesics
3. **The g-map has a globally attracting fixed point** — z* ≈ 2.0175, with |g'(z*)| < 1
4. **The diagonal map is strictly convex** — ensuring a unique minimum and orbit divergence
5. **EML generates all constants from 1** — including 0, −1, e, e², e^e via finite compositions
6. **E-tower growth is superexponential** — e↑↑(n+2) ≥ exp(2ⁿ), verified by induction
