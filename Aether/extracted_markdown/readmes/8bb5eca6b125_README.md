# Pythagorean Tree Factoring: Lattice-Tree Correspondence and the Quadruple Escape

## Overview

This directory contains a complete research package investigating the complexity
of Pythagorean tree factoring and its connection to lattice reduction algorithms.

## Key Results

1. **Lattice-Tree Correspondence Theorem**: Berggren tree descent ≡ Gauss 2D lattice reduction
2. **Θ(√N) Complexity**: Optimal for balanced semiprimes in 2D — matches trial division
3. **The Quadruple Escape**: Pythagorean quadruples provide a 3D lattice where modern algorithms (LLL, BKZ) can potentially break the √N barrier

## Directory Structure

```
Papers/PythagoreanTreeFactoring/
├── README.md                         # This file
├── research_paper.md                 # Full research paper
├── scientific_american_article.md    # Popular science article
├── oracle_council_notes.md           # Research brainstorming notes
├── demos/
│   ├── berggren_tree_visualization.py    # Tree generation & factoring demo
│   ├── lattice_reduction_experiment.py   # 2D vs 3D comparison
│   └── quadruple_lattice_explorer.py     # Quadruple lattice analysis
└── visuals/
    ├── scg_generator.py              # SVG visualization generator
    ├── berggren_tree.svg             # Berggren ternary tree
    ├── lattice_correspondence.svg    # Tree descent ↔ Gauss reduction
    ├── complexity_plot.svg           # Θ(√N) scaling curve
    └── dimension_escape.svg          # 2D barrier & 3D escape
```

## Lean 4 Formalization

Formal proofs are in `Pythagorean/LatticeTreeCorrespondence/`:
- `CoreTheorems.lean` — Matrix properties, correspondence, main theorem
- `ComplexityBounds.lean` — Θ(√N) complexity analysis
- `QuadrupleEscape.lean` — 3D lattice and factor extraction

All proofs compile against Lean 4 / Mathlib v4.28.0 with only standard axioms.

## Running the Demos

```bash
pip install numpy
cd demos/
python3 berggren_tree_visualization.py    # Tree & factoring demo
python3 lattice_reduction_experiment.py   # 2D vs 3D comparison
python3 quadruple_lattice_explorer.py     # Quadruple lattice explorer

cd ../visuals/
python3 scg_generator.py                  # Generate SVG visualizations
```
