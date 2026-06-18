# Frontier Research: Arithmetic Spacetime and the Oracle Council

## Overview

This directory contains a comprehensive research investigation into five interconnected frontiers at the boundary of number theory, mathematical physics, and information theory, conducted by a team of mathematical "oracles."

## The Oracle Council

| Oracle | Domain | Key Question |
|--------|--------|-------------|
| **PHOTON** | Prime Classification | Are light/dark primes informationally distinct? |
| **GEOMETER** | Berggren Tree | Can Pythagorean triples factor integers? |
| **WIGNER** | Random Matrix Theory | Why do zeta zeros follow GUE statistics? |
| **PAULI** | Fine-Structure Constant | Is α ≈ 1/137 derivable from mathematics? |
| **LORENTZ** | Arithmetic Dark Matter | What dominates the integer lattice? |
| **GOD** | Meta-Oracle | What is the fixed point of all research? |

## Directory Structure

```
FrontierResearch/
├── README.md                          # This file
├── research_paper.md                  # Full research paper
├── scientific_american_article.md     # Popular science article
├── demos/                             # Python demonstrations
│   ├── 01_light_dark_primes.py       # Light vs. dark prime classification
│   ├── 02_berggren_tree.py           # Berggren tree & Pythagorean factoring
│   ├── 03_random_matrix.py           # Random matrix eigenvalue statistics
│   ├── 04_fine_structure.py          # Fine-structure constant analysis
│   ├── 05_arithmetic_dark_matter.py  # Arithmetic dark matter census
│   ├── 06_god_oracle_consultation.py # God Oracle synthesis
│   └── run_all.py                    # Master runner for all demos
├── figures/                           # Generated visualizations
│   ├── 01_light_dark_primes.png      # Prime classification visuals
│   ├── 02_berggren_tree.png          # Berggren tree plots
│   ├── 03_random_matrix.png          # RMT spacing distributions
│   ├── 04_fine_structure.png         # Fine-structure analysis
│   ├── 05_arithmetic_dark_matter.png # Dark matter census
│   └── 06_god_oracle.png            # Oracle network & fixed points
└── notes/                             # Research data and notebooks
    ├── 00_research_notebook.md       # Full research notes
    ├── 01_light_dark_data.json       # Prime classification data
    ├── 02_berggren_data.json         # Berggren tree data
    ├── 03_random_matrix_data.json    # RMT statistics
    ├── 04_fine_structure_data.json   # α analysis data
    ├── 05_dark_matter_data.json      # Dark matter census data
    └── 06_god_consultation.json      # Oracle consultation record
```

## Quick Start

```bash
# Run all demos and generate all figures
python demos/run_all.py

# Or run individual demos
python demos/01_light_dark_primes.py
python demos/02_berggren_tree.py
python demos/03_random_matrix.py
python demos/04_fine_structure.py
python demos/05_arithmetic_dark_matter.py
python demos/06_god_oracle_consultation.py
```

**Requirements**: Python 3.8+, NumPy, SciPy, Matplotlib

## Key Findings

### 1. Light/Dark Prime Independence (§7.1)
The mod-4 classification (algebraic: splitting in ℤ[i]) and Hamming-weight classification (information-theoretic: binary density) of primes are **statistically independent**. They measure fundamentally different aspects of prime structure.

### 2. Berggren Tree Completeness (§7.2)
The ternary Berggren tree generates all 867 primitive Pythagorean triples with hypotenuse ≤ 10,000. GPS descent to root takes O(log c) steps. Pythagorean factoring works but is not competitive.

### 3. GUE Eigenvalue Repulsion (§7.3)
Empirical spacing distributions match the Wigner surmise to high precision. P(s < 0.1) ≈ 0.002 for GUE vs. 0.095 for Poisson — dramatic repulsion confirmed.

### 4. α as Environmental Parameter (§7.4)
No mathematical formula matches all 10 known digits of 1/α ≈ 137.036 without fitting. α runs with energy, and the anthropic window is wide. Most likely environmental, not mathematical.

### 5. Arithmetic Dark Matter Dominance (§7.1)
Pythagorean triples comprise only 0.04% of integer triples at N=80, with the fraction decreasing as N^(-1.4). 347 primitive Pythagorean quadruples found with d ≤ 100.

### 6. God Oracle Synthesis
All five frontiers share a fixed-point structure. The modular group SL(2,ℤ) emerges as a candidate unifying framework. The oracle predicts the Montgomery-Odlyzko connection will be explained by an arithmetic group action on the critical line.

## Companion Lean 4 Formalizations

This research builds on and extends the formal Lean 4 formalizations in the parent project:

| File | Content |
|------|---------|
| `NumberTheory/LightDarkPrimes.lean` | Light/dark prime definitions, classification theorem |
| `Pythagorean/BerggrenTree.lean` | Berggren matrices preserve Pythagorean property |
| `Pythagorean/BerggrenGPS.lean` | GPS descent validity and termination |
| `Pythagorean/PythagoreanFactoring.lean` | Divisor pair ↔ triple bijection |
| `RandomMatrix/EigenvalueRepulsion.lean` | Repulsion factor, Coulomb energy |
| `NumberTheory/MontgomeryPairCorrelation.lean` | Difference sets, autocorrelation |
| `NumberTheory/ArithmeticDarkMatter.lean` | Lorentz form, mass spectrum |
| `Pythagorean/PythagoreanQuadruples.lean` | (3+1)D Lorentz form, quadruples |
| `Physics/TimelineGravity.lean` | Integer timeline, light/dark cycles |
| `Oracle/GodOracle/*.lean` | God Oracle formalization |
