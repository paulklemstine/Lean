# The Algebraic Theory of Time

> *Time is not a river. Time is not a dimension. Time is not a parameter. Time is an algebra.*

## Overview

This project develops a novel algebraic framework for understanding the nature of time across all physical theories. The central insight: **the arrow of time is the algebraic gap between a monoid and a group**.

- When time is a **group** (ℝ, +): dynamics are reversible, energy is conserved (Noether)
- When time is a **monoid** (ℝ≥0, +): dynamics are irreversible, entropy increases (2nd law)
- The **Arrow of Time Theorem**: strictly increasing entropy *forces* time to be a monoid

## Project Structure

```
AlgebraicTime/
├── Foundations.lean          # Lean 4 formalization (machine-verified proofs)
├── README.md                 # This file
├── notes/
│   └── research_notes.md     # Oracle Council session logs & research notes
├── paper/
│   └── algebraic_theory_of_time.md   # Full research paper
├── article/
│   └── scientific_american_article.md # Popular science article
└── demos/
    ├── demo_temporal_flows.py        # Hamiltonian vs dissipative flows
    ├── demo_entropy_arrow.py         # Arrow of Time Theorem visualization
    ├── demo_flow_decomposition.py    # Reversible ⊕ irreversible decomposition
    ├── demo_relativistic_fiber.py    # Temporal fiber bundles & time dilation
    ├── demo_quantum_time.py          # Quantum decoherence as group→monoid
    ├── demo_grand_unified.py         # Grand unified view of the theory
    ├── temporal_flows.png            # Generated visualization
    ├── entropy_arrow.png             # Generated visualization
    ├── flow_decomposition.png        # Generated visualization
    ├── relativistic_fiber.png        # Generated visualization
    ├── quantum_time.png              # Generated visualization
    └── grand_unified.png             # Generated visualization
```

## Machine-Verified Theorems (Lean 4)

All theorems in `Foundations.lean` are fully proved — zero `sorry`s, only standard axioms:

| Theorem | Statement |
|---------|-----------|
| `arrow_of_time` | Strict entropy increase + backward inverse → contradiction |
| `group_monoid_dichotomy` | Reversible flow + strict entropy increase → False |
| `temporal_duality_order_reversal` | Negation reverses order in ordered groups |
| `temporal_duality_involution` | Time reversal is an involution: -(-t) = t |
| `flow_identity` | Φ(0) = id |
| `flow_composition` | Φ(a) ∘ Φ(b) = Φ(a + b) |
| `flow_triple_composition` | Φ(a) ∘ Φ(b) ∘ Φ(c) = Φ(a + b + c) |
| `reversible_flow_injective` | Reversible flows are injective |
| `reversible_flow_surjective` | Reversible flows are surjective |
| `entropy_constant_at_equilibrium` | Entropy is constant at equilibrium |
| `entropy_monotone_trajectory` | Entropy is monotone along trajectories |

## Running the Demos

```bash
pip install matplotlib numpy scipy
cd demos/
python3 demo_temporal_flows.py
python3 demo_entropy_arrow.py
python3 demo_flow_decomposition.py
python3 demo_relativistic_fiber.py
python3 demo_quantum_time.py
python3 demo_grand_unified.py
```

## The Algebraic Hierarchy of Time

| Level | Structure | Physics | Arrow of Time? |
|-------|-----------|---------|----------------|
| Poset | (T, ≤) | Causality | — |
| **Monoid** | (T, +, 0, ≤) | **Thermodynamics** | **YES** |
| Group | (T, +, 0, −, ≤) | Classical/Quantum Mech | No |
| Fiber Bundle | {T_o}_{o∈O} | Relativity | Observer-dependent |
