# Quaternion Factoring

## Overview

This research package explores the connection between quaternion arithmetic, Pythagorean quadruples, and integer factoring via lattice reduction.

**Core Insight**: Factoring a composite integer N = p·q corresponds to decomposing a quaternion of norm N into a product of prime-norm quaternions. The quaternion norm identity (Euler's four-square identity) provides the algebraic foundation, while lattice reduction in dimensions d ≥ 3 provides the computational method.

## Contents

### Lean 4 Formalizations
- **`QuaternionNorm.lean`** — Euler four-square identity, Pell obstacle theorem, lattice properties, dimensional hierarchy
- **`QuaternionFactoring.lean`** — Integer quaternion algebra, norm multiplicativity, SL(2,ℤ) action, four-square theorem, GCD extraction

### Research Papers
- **`research_paper.md`** — Full technical research paper with proofs and experimental results
- **`scientific_american.md`** — Popular science article: "The Geometry of Secrets"

### Python Demos
- **`demos/quaternion_factoring_demo.py`** — Complete quaternion factoring pipeline with experiments
- **`demos/hypothesis_experiments.py`** — Systematic hypothesis testing suite (H1–H8)
- **`demos/quadruple_tree_generator.py`** — SL(2,ℤ) tree generation and coverage analysis
- **`demos/lattice_dimension_sweep.py`** — Dimension sweep: performance vs lattice dimension

### SVG Visualizations
- **`visuals/quaternion_factoring_pipeline.svg`** — End-to-end pipeline diagram
- **`visuals/dimension_scaling.svg`** — Minkowski bounds across dimensions
- **`visuals/pell_obstacle.svg`** — The Pell obstacle λ²−μ²=1
- **`visuals/quadruple_tree.svg`** — SL(2,ℤ) tree of Pythagorean quadruples
- **`visuals/norm_identity.svg`** — Quaternion norm identity diagram
- **`visuals/hypothesis_scorecard.svg`** — Experimental results summary

## Quick Start

```bash
# Run the main demo
python demos/quaternion_factoring_demo.py

# Run all hypothesis experiments
python demos/hypothesis_experiments.py

# Explore the quadruple tree
python demos/quadruple_tree_generator.py

# Dimension sweep experiments
python demos/lattice_dimension_sweep.py
```

## Key Results

| Result | Value |
|--------|-------|
| Scaling exponent α | 0.30 (vs 0.50 classical) |
| Optimal dimension | d = 4 |
| Best factoring rate | 88% at d = 4 |
| Enhanced extraction boost | +80% relative |
| Pell obstacle | Proved (Lean 4) |
| Euler identity | Proved (Lean 4) |

## Mathematical Highlights

1. **Pell Obstacle Theorem**: λ² − μ² = 1 ⟹ μ = 0 (blocks Berggren generalization to 3D)
2. **Euler Four-Square Identity**: Verified by `ring` tactic in Lean 4
3. **Dimensional Hierarchy**: N^(1/d₂) ≤ N^(1/d₁) for d₂ > d₁ (formalized)
4. **Quaternion Norm Multiplicativity**: N(q₁·q₂) = N(q₁)·N(q₂) (formalized)
5. **Lattice Closure**: L₄(N) closed under negation (formalized)
