# Three Roads from Pythagoras

## Tree Sieves, Lattice Reduction, and Learned Heuristics for Integer Factoring via the Berggren Tree

---

### Overview

This directory contains the complete research program exploring integer factoring through the Berggren ternary tree of primitive Pythagorean triples. It includes:

- **Machine-verified Lean 4 proofs** (4 files, 40+ theorems, 0 `sorry` statements)
- **Python experiment scripts** (6 scripts, 6 experiments)
- **SVG visualizations** (7 publication-quality figures)
- **Research papers** (full technical paper + Scientific American article)
- **Oracle Council research notes** (brainstorming, hypotheses, iteration log)

### Structure

```
ThreeRoads/
├── Foundations.lean          # Core theorems (Brahmagupta-Fibonacci, Lorentz form, etc.)
├── NewTheorems.lean          # Coprimality preservation, parity, monotonicity
├── AdvancedTheorems.lean     # Bijection, Euclid parametrization, composition
├── OpenProblems.lean         # Partial results on open problems
├── python/
│   ├── berggren_tree.py      # Tree generation and exploration
│   ├── tree_sieve.py         # Tree sieve factoring algorithm
│   ├── lattice_reduction.py  # Hyperbolic geometry / theta group approach
│   ├── neural_search.py      # Neural network guided search
│   ├── experiments.py        # Complete experiment suite
│   └── scg_visuals.py        # SVG visualization generator
├── visuals/
│   ├── berggren_tree.svg     # Berggren tree (4 levels)
│   ├── poincare_disk.svg     # Triples in Poincaré disk model
│   ├── smooth_density.svg    # Smooth density comparison chart
│   ├── depth_regression.svg  # Depth vs ln(N) regression
│   ├── hypotenuse_growth.svg # Hypotenuse growth along branches
│   ├── factoring_pipeline.svg # Three roads pipeline diagram
│   └── oracle_council.svg    # Oracle Council architecture
├── papers/
│   ├── research_paper.md     # Full technical paper
│   └── scientific_american_article.md  # Popular science article
├── oracle_council/
│   └── research_notes.md     # Brainstorming, hypotheses, iteration log
└── README.md                 # This file
```

### Quick Start

```bash
# Run all experiments
cd python && python3 experiments.py

# Generate all visualizations
python3 scg_visuals.py

# Individual scripts
python3 berggren_tree.py      # Explore the Berggren tree
python3 tree_sieve.py         # Test the tree sieve factoring
python3 lattice_reduction.py  # Lattice reduction experiments
python3 neural_search.py      # Neural guided search

# Verify Lean proofs
lake build Pythagorean
```

### Key Results

| Result | Value |
|--------|-------|
| Machine-verified theorems | 40+ |
| Remaining `sorry` | 0 |
| Smooth density advantage | 246–463,631× |
| Factoring success rate | 100% (N ≤ 600) |
| Depth vs ln(N) R² | 0.9116 |
| B₂ spectral radius | 3+2√2 ≈ 5.828 |
| SVG visualizations | 7 |
| Python experiments | 6 |

### Open Problems (Status)

1. **Smooth Density Persistence** (Conjecture 1): Open. Partial results proved (leg product bound, integer gap).
2. **Polynomial CVP** (Conjecture 2): Open. Experimental R² = 0.91 supports O(log N) depth.
3. **Quantum Speedups**: Open. Structural bounds formalized.
4. **Quadratic Sieve Connection**: Partially formalized (quadratic connection theorem).
