# The Quadruple Lattice

## Project Overview

This directory contains a complete research package investigating lattice-based approaches to integer factoring via sum-of-three-squares congruences.

## Contents

### Formal Proofs (Lean 4 + Mathlib)

Located in `../../Pythagorean/QuadrupleLattice/`:

- **`Basic.lean`** — Core definitions and theorems:
  - Definition of L₄(N) and proof it is NOT a lattice
  - Construction of the genuine lattice Λ(N, r₁, r₂)
  - Proof of closure under addition, negation, and zero
  - Proof that N divides x² + y² + z² for lattice vectors
  - Determinant computation (= N²)
  - Basis vectors and their membership proofs

- **`FactoringTheory.lean`** — Factoring applications:
  - GCD-based factoring criterion
  - Minkowski barrier (N^{2/3} > N^{1/2})
  - Optimal dimension theorem (only d=2 works generically)
  - Pythagorean quadruple parametrization
  - CRT for combining multiple lattices
  - Computational examples (N = 15, 91, 143)

All proofs compile with zero `sorry` statements.

### Papers

- **`research_paper.md`** — Full research paper with theorems, proofs, analysis
- **`scientific_american.md`** — Popular science article for general audience
- **`research_notes.md`** — Brainstorming, new directions, honest assessment

### Python Demos

- **`demo_lattice.py`** — Complete lattice factoring implementation:
  - Root finding for quadratic residues
  - Lattice basis construction
  - LLL reduction (pure Python implementation)
  - Factoring via short vectors
  - Statistical analysis of shortest vectors
  - Run: `python3 demo_lattice.py`

- **`demo_visuals.py`** — SVG generation for all visualizations:
  - Run: `python3 demo_visuals.py`

### SVG Visualizations

- **`lattice_2d.svg`** — 2D quadratic residue lattice with basis vectors
- **`tree_vs_forest.svg`** — Berggren tree (triples) vs quadruple forest
- **`bound_comparison.svg`** — √N vs N^{2/3} vs N^{1/3} bounds
- **`nonclosure_proof.svg`** — Visual proof that L₄(3) is not a lattice
- **`true_lattice.svg`** — The genuine lattice construction diagram

## Key Results

| Result | Status |
|--------|--------|
| L₄(N) is NOT a lattice | ✅ Formally proved |
| Λ(N,r₁,r₂) IS a lattice | ✅ Formally proved |
| det(Λ) = N² | ✅ Formally proved |
| N divides x²+y²+z² for lattice vectors | ✅ Formally proved |
| Minkowski bound > √N | ✅ Formally proved |
| GCD factoring criterion | ✅ Formally proved |
| Sub-√N factoring | ❌ Not achieved (theory says unlikely) |
