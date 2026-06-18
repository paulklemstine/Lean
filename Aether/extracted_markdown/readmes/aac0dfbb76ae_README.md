# Pythagorean Tree Factoring

A comprehensive research package exploring integer factorization via descent in the Berggren Pythagorean triple tree.

## Overview

Given an odd composite N, this approach factors N by:
1. Constructing the trivial Pythagorean triple `(N, (N²-1)/2, (N²+1)/2)`
2. Ascending the Berggren tree toward root (3,4,5) via inverse matrices
3. At each ancestor, checking `gcd(leg, N)` for non-trivial factors

## Contents

### Lean 4 Formalization (`Core.lean`)
Machine-verified proofs of all core theorems:
- Trivial triple construction
- Difference-of-squares identity: N² = (c-b)(c+b)
- Inverse Berggren matrices preserve Pythagorean property
- Descent termination: 0 < c' < c at each step
- Forward-inverse round-trip identities
- GCD factor extraction
- Lorentz form preservation

All 17 theorems verified with no `sorry` — only standard axioms used.

### Python Demos (`demos/`)
- `pythagorean_tree_factoring.py` — Core algorithm with worked examples
- `oracle_council_research.py` — Five-oracle research team brainstorming
- `generate_visuals.py` — SVG visualization generator

### SVG Visualizations (`visuals/`)
- `berggren_tree.svg` — The Berggren ternary tree structure
- `descent_path_143.svg` — Factoring N=143=11×13 step by step
- `factor_mechanism.svg` — Algebraic factor discovery mechanism
- `complexity_comparison.svg` — Descent depth: primes vs composites
- `algorithm_flowchart.svg` — Complete algorithm flowchart

### Papers (`papers/`)
- `research_paper.md` — Full technical paper with proofs and analysis
- `scientific_american_article.md` — Popular science exposition
- `oracle_research_notes.md` — Research council findings and hypotheses

## Running the Demos

```bash
# Core factoring algorithm
python3 demos/pythagorean_tree_factoring.py

# Oracle council research
python3 demos/oracle_council_research.py

# Generate SVG visualizations
python3 demos/generate_visuals.py
```

## Building the Lean Formalization

```bash
lake build Pythagorean.TreeFactoring.Core
```
