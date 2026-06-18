# EML–Pythagorean Bridge: Research v6

## Overview

This directory contains the v6 research deliverables for the EML-Pythagorean bridge program, including new machine-verified theorems, computational demonstrations, visual diagrams, and research papers.

## Directory Structure

```
v6/
├── lean/                          # Machine-verified Lean 4 theorems
│   ├── BerggrenCharPoly.lean      # Direction #23: Characteristic polynomial classification
│   │                                ★ SOLVED: B₃ = S·B₁·S (leg-swap conjugacy)
│   │                                Nilpotency, Cayley-Hamilton, noncommutativity
│   ├── BerggrenParentDescent.lean # Direction #1: Parent descent infrastructure
│   │                                Forward-inverse cancellation (6/6)
│   │                                Hypotenuse growth and descent
│   │                                Parent positivity — ALL ZERO SORRIES ✅
│   └── BerggrenMarkov.lean        # Direction #27: Markov triple connection
│                                    Mutation preservation and involution
│                                    Structural comparison — ALL ZERO SORRIES ✅
├── demos/                         # Python computational demonstrations
│   ├── berggren_dynamics_explorer.py    # Tree dynamics, angles, Lyapunov, Markov
│   └── eml_pythagorean_applications.py # Signal processing, crypto, quantum, neural
├── visuals/                       # SVG diagrams
│   ├── berggren_research_roadmap_v6.svg # Complete research roadmap with status
│   ├── berggren_tree_structure.svg      # Tree structure with verified properties
│   ├── hyperbolic_connection.svg        # Poincaré disk model visualization
│   └── angle_distribution.svg           # Histogram of angle distribution
└── papers/                        # Research papers and articles
    ├── eml_pythagorean_research_v6.md   # Technical research paper
    ├── future_research_directions_v6.md # Future directions with answered questions
    └── scientific_american_v6.md        # Popular science article
```

## Key Results

### Questions Answered (7)

1. **Dir #23 (Char Poly):** B₁ ≅ B₃ via leg-swap conjugation S ∈ O(2,1;ℤ)
2. **Dir #11 (Lyapunov):** Spectrum is compact interval [0.10, 1.78], NOT Cantor set
3. **Dir #30 (Tropical):** Tree degenerates — not tropically robust
4. **Dir #27 (Markov):** No algebraic deformation; different surfaces
5. **Dir #39 (Complexity):** Path length O(log c) is optimal
6. **Dir #3 (Angles):** Bell-shaped, symmetric about 45°, σ ≈ 17.5°
7. **Dir #38 (Symbolic):** Topological entropy = log 3 (full shift)

### New Theorems Verified (15+)

All Lean files compile with **zero sorries**. Key new results:
- B₃ = S·B₁·S conjugacy (resolving the char poly mystery)
- (B₁ - I)³ = 0 nilpotency
- B₂ Cayley-Hamilton: B₂³ - 5B₂² - 5B₂ + I = 0
- Parent hypotenuse descent and positivity
- Markov mutation preservation and involution

### New Directions Proposed (7)

- Dir #41: Nilpotent quotient structure
- Dir #42: Commutator analysis
- Dir #43: Spectral radius gap
- Dir #44: Arithmetic descent complexity
- Dir #45: Ergodic theory of descent
- Dir #46: Higher genus analogues
- Dir #47: Categorical Berggren tree

## Running the Demos

```bash
# Tree dynamics, angles, Lyapunov exponents, Markov comparison
python3 demos/berggren_dynamics_explorer.py

# Applications: signal processing, crypto, quantum walks, neural nets
python3 demos/eml_pythagorean_applications.py
```

## Building the Lean Files

```bash
# From project root
lake build EML.Research.v6.lean.BerggrenCharPoly
lake build EML.Research.v6.lean.BerggrenParentDescent
lake build EML.Research.v6.lean.BerggrenMarkov
```

## Citation

If referencing this work, please cite:
- The v6 research paper: `papers/eml_pythagorean_research_v6.md`
- The Lean formalizations: `lean/*.lean`
