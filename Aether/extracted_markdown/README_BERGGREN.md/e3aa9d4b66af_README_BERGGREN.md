# Tropical Berggren Rank Factorization: Analysis, Disproof, and Cryptographic Applications

## Overview

This project provides a rigorous, machine-verified analysis of the conjecture that the tropical rank of p-adic valuation matrices derived from Berggren tree paths equals the number of distinct prime factors of the hypotenuse. **The conjecture is false**, and we prove this with machine-checked counterexamples.

We also formalize genuine properties of the Berggren tree and demonstrate cryptographic applications.

## Project Structure

### Lean 4 Formal Proofs (all sorry-free, machine-verified)

| File | Description |
|------|-------------|
| `Catalog/Cryptography/BerggrenTropical/BerggrenTree.lean` | Core infrastructure: Berggren matrices, tree paths, Pythagorean preservation, hypotenuse growth |
| `Catalog/Cryptography/BerggrenTropical/TropicalCounterexamples.lean` | Machine-verified counterexamples disproving the tropical rank conjecture |
| `Catalog/Cryptography/BerggrenTropical/CryptoProperties.lean` | Cryptographic properties: determinant preservation, security bounds, coprimality |
| `Catalog/Speculative/AutoResearch/TropicalBerggrenAnalysis.lean` | Original analysis with comprehensive documentation (reference) |

### Key Theorems Proved

- **Pythagorean preservation**: Every Berggren matrix maps Pythagorean triples to Pythagorean triples (`berggren_pythagorean`)
- **Determinant ±1**: Products of Berggren matrices always have determinant ±1 (`berggren_product_det_unit`)
- **Hypotenuse monotonicity**: The hypotenuse strictly increases along any tree path (`berggren_step_hyp_increase`)
- **Counterexample N=169**: Monge condition fails for T₁₃(169), proving tropical rank ≥ 2 > 1 = ω(169) (`conjecture_false_at_169`)
- **Counterexample N=25**: Monge condition fails for T₅(25) (`conjecture_false_at_25`)
- **Unbounded prime factors**: For every n, there exists m with at least n prime factors (`unbounded_prime_factors`)

### Python Demos

| File | Description |
|------|-------------|
| `demos/berggren_tree_demo.py` | Interactive exploration of the tree, counterexample verification, cryptographic properties |
| `demos/berggren_visualizations.py` | Publication-quality figures (tree structure, p-adic heatmaps, growth curves) |
| `demos/crypto_application.py` | Cryptographic applications: commitment scheme, one-way function, hash function |

### Research Paper

| File | Description |
|------|-------------|
| `paper/tropical_berggren_paper.md` | Full research paper with Scientific American-style discussion |

### Generated Figures

| File | Description |
|------|-------------|
| `demos/berggren_tree.png` | Berggren ternary tree visualization |
| `demos/padic_heatmap.png` | P-adic valuation matrices (counterexamples) |
| `demos/hypotenuse_growth.png` | Hypotenuse growth along different paths |
| `demos/key_space.png` | Key space analysis for cryptographic applications |

## Building

```bash
# Build all Lean files
lake build Cryptography.BerggrenTropical.BerggrenTree
lake build Cryptography.BerggrenTropical.TropicalCounterexamples
lake build Cryptography.BerggrenTropical.CryptoProperties

# Run Python demos
pip install numpy matplotlib
python3 demos/berggren_tree_demo.py
python3 demos/berggren_visualizations.py
python3 demos/crypto_application.py
```

## Requirements

- Lean 4.28.0 with Mathlib
- Python 3.x with numpy and matplotlib (for demos)
