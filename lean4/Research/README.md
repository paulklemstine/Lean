# EML–Pythagorean Tree Research Package

## Overview

This package contains machine-verified proofs, computational demos, visualizations, and research papers exploring the Berggren ternary tree of primitive Pythagorean triples and its connections to the EML operator, Lorentz geometry, and beyond.

## Contents

### Lean 4 Formalization
- **`BerggrenPythagoreanCore.lean`** — 35+ machine-verified theorems with zero sorries, including:
  - Pythagorean preservation (all three Berggren matrices)
  - Lorentz form preservation (ring identity)
  - Determinant asymmetry: det(B₁) = det(B₃) = 1, det(B₂) = -1
  - Forward-inverse cancellation (all six directions)
  - **Primitivity preservation** (NEW): gcd(a,b)=1 preserved by all matrices
  - Pell recurrence and strict monotonicity for B-branch
  - Path correctness: any tree path yields a Pythagorean triple
  - Binary tree leaf counting theorem
  - Euclid parametrization and quadruple extension

### Python Demos (`demos/`)
- **`berggren_tree_explorer.py`** — Complete interactive demo: tree generation, verification, angle distribution, Pell recurrence, parent descent, EML operator, Gaussian connection
- **`angle_distribution.py`** — Angle distribution analysis up to depth 10
- **`pell_and_growth.py`** — Pell recurrence verification and growth rate classification
- **`parent_descent_and_completeness.py`** — Exhaustive completeness test for c ≤ 1000
- **`eml_operator_demo.py`** — EML fixed points, Lambert W connection, iteration dynamics

### SVG Visualizations (`visuals/`)
- **`berggren_tree.svg`** — The Berggren tree with first three levels and all verified properties
- **`lorentz_null_cone.svg`** — Pythagorean triples as lattice points on the Lorentz null cone
- **`eml_bifurcation.svg`** — EML fixed-point bifurcation diagram with Lambert W connection
- **`pell_recurrence.svg`** — B-branch Pell recurrence sequence visualization

### Research Papers (`papers/`)
- **`EML_Pythagorean_Research_Paper.md`** — Full technical paper with all verified results
- **`Scientific_American_Article.md`** — Accessible article for general scientific audience
- **`Future_Research_Directions_v5.md`** — Comprehensive catalog of 50+ research directions

## Running the Demos

```bash
# From the project root:
python3 Research/demos/berggren_tree_explorer.py
python3 Research/demos/parent_descent_and_completeness.py
python3 Research/demos/pell_and_growth.py
python3 Research/demos/eml_operator_demo.py
python3 Research/demos/angle_distribution.py
```

## Building the Lean Proofs

```bash
lake build Research.BerggrenPythagoreanCore
```

All 35+ theorems compile with zero sorries and only standard axioms (propext, Classical.choice, Quot.sound).

## Key Results Summary

| Result | Status | Method |
|--------|--------|--------|
| Pythagorean preservation (A,B,C) | ✅ Verified | nlinarith |
| Lorentz form preservation | ✅ Verified | ring |
| det(B₁)=1, det(B₂)=-1, det(B₃)=1 | ✅ Verified | native_decide |
| Forward-inverse cancellation | ✅ Verified | ring |
| Primitivity preservation | ✅ Verified | prime contradiction |
| Hypotenuse growth | ✅ Verified | nlinarith |
| Pell recurrence exactness | ✅ Verified | rfl |
| B-branch monotonicity | ✅ Verified | induction |
| Path correctness | ✅ Verified | list induction |
| Binary tree leaf counting | ✅ Verified | structural induction |
| Quadruple zero-extension | ✅ Verified | unfolding |
| Berggren completeness | 🔴 Open | All prerequisites done |
| Free group conjecture | 🟡 Open | Computational evidence |
