# ⚡ The Algebraic Theory of Electricity

A unified algebraic framework from Ohm's law to quantum electrodynamics.

## Overview

This project develops the **Algebraic Theory of Electricity**: a unified mathematical
framework revealing that all electrical phenomena — from DC circuits to quantum
electrodynamics — are governed by a nested hierarchy of algebraic structures, with the
unitary group U(1) at its core.

## Contents

### 📄 Formal Proofs (Lean 4 + Mathlib)

- **`AlgebraicElectricity.lean`** — 11 formally verified theorems:
  - Impedance Field Theorem (parallel = harmonic addition in ℂ)
  - Parallel combination commutativity & self-parallel formula
  - Three-phase symmetry (ω³ = 1 and 1 + ω + ω² = 0)
  - Gauge invariance (d² = 0 → Bianchi identity)
  - Kirchhoff's Current Law as kernel of incidence matrix
  - Thévenin-Norton duality involution
  - Ohm's law linearity & power non-negativity
  - Betti number formulas for circuit topology

### 🐍 Python Demos (with visualizations)

- **`demos/demo1_impedance_field.py`** — Complex impedance space, series/parallel geometry, RLC frequency response
- **`demos/demo2_kirchhoff_homology.py`** — Wheatstone bridge chain complex, cycle space, graph Laplacian
- **`demos/demo3_maxwell_forms.py`** — Maxwell's equations as differential forms, E and B fields
- **`demos/demo4_gauge_symmetry.py`** — U(1) gauge theory, fiber bundles, charge quantization, three-phase power
- **`demos/demo5_clifford_em.py`** — Clifford algebra implementation, F = E + IB unification
- **`demos/demo6_grand_unified.py`** — Complete map of algebraic structures across all scales

### 📰 Publications

- **`paper/algebraic_theory_of_electricity.md`** — Full research paper (10 sections, references)
- **`paper/scientific_american_article.md`** — Popular science article

### 📓 Research Process

- **`ORACLE_CONSULTATION.md`** — Initial oracle team consultation and findings
- **`RESEARCH_NOTES.md`** — Detailed research notes from 6 sessions

## The Key Insight

> *Electricity IS algebra. Every electrical phenomenon is a representation of U(1).*

| Scale | Algebra | Physics |
|-------|---------|---------|
| DC circuits | ℝ (real field) | V = IR |
| AC circuits | ℂ (complex field) | V = IZ |
| Circuit topology | Chain complex | Kirchhoff's laws |
| Classical EM | de Rham complex | dF = 0, d★F = J |
| Gauge theory | U(1) bundle | Charge conservation |
| Relativistic EM | Cl(1,3) | ∇F = J/ε₀ |
| Quantum EM | Symmetric algebra | Fock space, QED |

## Running

```bash
# Run Python demos (generates PNG visualizations)
cd demos
pip install numpy matplotlib networkx
python3 demo1_impedance_field.py
python3 demo2_kirchhoff_homology.py
python3 demo3_maxwell_forms.py
python3 demo4_gauge_symmetry.py
python3 demo5_clifford_em.py
python3 demo6_grand_unified.py

# Build Lean proofs
lake build Electricity.AlgebraicElectricity
```
