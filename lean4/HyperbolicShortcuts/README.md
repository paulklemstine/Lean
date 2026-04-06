# Hyperbolic Shortcuts Through the Berggren Tree

## Overview

This directory contains the complete deliverables for the research project on factoring integers via hyperbolic shortcuts through the Berggren tree of primitive Pythagorean triples.

## Contents

### Formal Verification (Lean 4)
- **`../Pythagorean/Pythagorean__HyperbolicShortcutFactoring.lean`** — Machine-verified proofs of 40+ theorems including Lorentz preservation, shortcut composition, Chebyshev recurrence, inverse matrices, factoring via difference-of-squares, and more. Zero `sorry` statements, standard axioms only.

### Python Demos
- **`demo_factoring.py`** — Interactive demo of factoring via Pythagorean triples, hyperbolic shortcuts, tree ascent, and Lorentz geometry. Run: `python3 demo_factoring.py [number]`
- **`demo_visualization.py`** — Terminal visualization of the Berggren tree and Chebyshev recurrence. Run: `python3 demo_visualization.py`

### SVG Visualizations
- **`berggren_tree.svg`** — The Berggren tree structure with all three branches, factoring examples, and legend
- **`lorentz_geometry.svg`** — The Lorentz geometry connection: null cone, difference of squares, Chebyshev recurrence, and O(2,1;ℤ)
- **`factoring_pipeline.svg`** — The complete factoring pipeline from input through tree navigation to GCD extraction

### Written Materials
- **`research_paper.md`** — Full research paper with mathematical framework, proofs, examples, and formalization details
- **`scientific_american_article.md`** — Popular science article explaining the work for a general audience
- **`applications.md`** — 10 novel applications including quantum algorithms, error-correcting codes, ML features, and more
- **`research_team.md`** — Proposed research team with PI, 5 core scientists, 2 postdocs, and 3 PhD students

## Key Results

1. **Lorentz Preservation:** B₁ᵀQB₁ = B₂ᵀQB₂ = B₃ᵀQB₃ = Q (machine-verified)
2. **Factoring 21:** B₂·(3,4,5) = (21,20,29) → gcd(9,21) = 3, gcd(49,21) = 7 (machine-verified)
3. **Chebyshev Recurrence:** Hypotenuses 5, 29, 169, 985, ... satisfy c_{n+1} = 6c_n - c_{n-1} (machine-verified)
4. **Shortcut Composition:** pathMat(p ++ q) = pathMat(p) · pathMat(q) (machine-verified)
5. **Lorentz Adjoint:** B⁻¹ = Q·Bᵀ·Q with Q² = I (machine-verified)
