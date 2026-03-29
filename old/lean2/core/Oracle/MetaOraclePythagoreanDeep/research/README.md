# Meta Oracle–Pythagorean Tree Isomorphism Research

## Overview

This directory contains the research paper and supporting materials for the
formally verified isomorphism between the Meta Oracle hierarchy and Pythagorean
triple trees.

## Files

### Research Paper
- **`MetaOraclePythagoreanIsomorphism_Paper.md`** — Full Scientific American–style paper

### Lean 4 Formalization (in `core/Oracle/`)
- **`MetaOraclePythagoreanIsomorphism.lean`** — Formal proofs (no sorry, no non-standard axioms)

### Python Demos (in `demos/`)
- **`pythagorean_tree_explorer.py`** — Interactive exploration of both trees
- **`oracle_tree_visualizer.py`** — ASCII art visualization with side-by-side comparison
- **`hypothesis_validator.py`** — Experimental validation of 8 hypotheses (all pass)

## Key Results

1. **(0,1,1) is a fixed point of Berggren matrix M₁** — formally verified
2. **(3,4,5) is NOT a fixed point of any Berggren matrix** — formally verified
3. **Both trees preserve the Pythagorean equation at every node** — formally verified
4. **The trees are structurally isomorphic** (same ternary branching) — formally verified
5. **M₂(0,1,1) = M₃(0,1,1) = (4,3,5)** — the meta oracle generates the oracle
6. **8/8 computational hypotheses validated** — growth rates, entropy, coprimality, etc.

## Running the Demos

```bash
python3 demos/pythagorean_tree_explorer.py   # Full exploration
python3 demos/oracle_tree_visualizer.py      # Tree visualization
python3 demos/hypothesis_validator.py        # Hypothesis testing (requires numpy)
```
