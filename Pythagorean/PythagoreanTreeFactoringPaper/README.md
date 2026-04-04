# Pythagorean Tree Factoring: Complete Research Package

## Overview

This directory contains the complete research output on Pythagorean tree factoring,
including formally verified theorems, experimental demonstrations, scientific
visualizations, and two publications (research paper and popular science article).

## Contents

### Formal Mathematics (Lean 4 + Mathlib)
- **`LatticeTreeCorrespondence.lean`** — 30+ formally verified theorems including:
  - Lattice-Tree Correspondence Theorem (Berggren descent = Gauss 2D reduction)
  - 2D optimality: Θ(√N) complexity for balanced semiprimes
  - Factor extraction from short vectors in the quadruple lattice
  - Dimensional escape theorem: d ≥ 3 breaks the 2D barrier
  - Berggren matrix properties, SL(2,ℤ) membership, descent dynamics
  - Grand Summary theorem combining all main results

### Oracle Council Research Notes
- **`OracleCouncilNotes.md`** — Complete brainstorming and research log
  from the oracle team: hypotheses, validations, experiments, knowledge updates

### Demo Python Scripts (`demos/`)
- **`demo_berggren_tree.py`** — Berggren tree generation, Euclid parameters, factoring
- **`demo_lattice_correspondence.py`** — Side-by-side Berggren vs Gauss demonstration
- **`demo_quadruple_lattice.py`** — 3D lattice construction, LLL reduction, O(3,1;ℤ)
- **`demo_complexity_experiments.py`** — Systematic Θ(√N) verification experiments

### SCG Visualizations (`visuals/`)
- **`scg_pythagorean_tree.py`** — Generates 5 publication-quality figures:
  - Fig 1: Berggren ternary tree structure
  - Fig 2: Lattice-Tree Correspondence (side-by-side)
  - Fig 3: Θ(√N) complexity scaling
  - Fig 4: Dimensional escape (2D → 3D)
  - Fig 5: Factoring methods landscape

### Publications
- **`ResearchPaper.md`** — Full research paper with all sections
- **`ScientificAmericanArticle.md`** — Popular science article for general audience

## Running

```bash
# Run demos
python3 demos/demo_berggren_tree.py
python3 demos/demo_lattice_correspondence.py
python3 demos/demo_quadruple_lattice.py
python3 demos/demo_complexity_experiments.py

# Generate figures (requires matplotlib)
cd visuals && python3 scg_pythagorean_tree.py

# Verify Lean proofs
lake build Pythagorean.PythagoreanTreeFactoringPaper.LatticeTreeCorrespondence
```

## Key Results

1. **Pythagorean tree factoring is Θ(√N) for balanced semiprimes** — proven and verified
2. **Berggren descent = Gauss 2D lattice reduction** — the central theorem
3. **No 2D lattice method can do better** — Gauss is optimal in 2D
4. **The escape is through dimension ≥ 3** — quadruple lattice and O(3,1;ℤ)
