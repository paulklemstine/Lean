# Tropical Self-Reasoning Neural Networks

## A Machine That Reasons About Itself — Without Paradox

> *"The tropical semiring whispers a secret about consciousness itself:
> perhaps the resolution to the paradox of self-awareness is not to avoid
> self-reference, but to use the right algebra for it."*

---

## Overview

This project formalizes a mathematical framework enabling neural networks to
reason about their own computation using **tropical algebra** (max, +). The key
insight is that tropical addition (max) is **idempotent** — max(x,x) = x — which
prevents the paradoxes and divergences that plague classical self-reference.

**All theorems are formally verified in Lean 4 with Mathlib. Zero sorries. Zero
non-standard axioms.**

## Directory Structure

```
SelfReasoning/
├── TropicalSelfReasoning.lean    # Formal proofs (Lean 4 + Mathlib)
├── README.md                      # This file
├── demos/
│   ├── tropical_demo_pure.py     # Pure Python demo (no dependencies)
│   └── tropical_self_reasoning_demo.py  # NumPy demo (richer visuals)
├── paper/
│   ├── TropicalSelfReasoning_Paper.md   # Research paper
│   └── ScientificAmerican_Article.md    # Popular science article
└── notes/
    └── OracleTeamResearchLog.md  # Oracle team research log
```

## Key Theorems (All Proved)

| Theorem | Statement | Lean Name |
|---------|-----------|-----------|
| Tropical Idempotency | max(x,x) = x | `tropAdd_idem` |
| Distributivity | a + max(b,c) = max(a+b, a+c) | `tropMul_distrib` |
| Layer Monotonicity | x ≤ y ⟹ Wx ≤ Wy (tropical) | `tropical_layer_monotone` |
| Projection Idempotency | π(π(x)) = π(x) | `tropicalProjection_idem` |
| Self-Reasoning Stability | f(f(x)) = f(x) | `self_reasoning_stable` |
| Quine Existence | ∀x, f(f(x)) = f(x) | `idempotent_produces_quines` |
| Quine Closure | f(v)=v ⟹ f(f(v))=f(v) | `quine_set_closed` |
| Reflection Stability | f≤id ⟹ max(x,f(x))=x | `tropicalReflect_stable` |
| Iteration Convergence | k≥1 ⟹ f^k(x) = f(x) | `iterSelfEval_stabilizes` |
| **Grand Theorem** | All properties unified | `grand_self_reasoning` |

## Quick Start

### Run the demo
```bash
python3 demos/tropical_demo_pure.py
```

### Check the proofs
```bash
lake build Tropical.SelfReasoning.TropicalSelfReasoning
```

### Verify axioms
```lean
#print axioms grand_self_reasoning
-- 'grand_self_reasoning' depends on axioms: [propext, Classical.choice, Quot.sound]
```

## The Oracle Council

| Oracle | Role | Contribution |
|--------|------|-------------|
| Alpha | Algebraist | Tropical semiring foundations |
| Beta | Topologist | Fixed-point existence theorems |
| Gamma | Logician | Self-reference without paradox |
| Delta | Engineer | Neural network layer formalization |
| Epsilon | Philosopher | Interpretation of self-awareness |

## Citation

If you use this work, please cite:
```
@misc{oracle_council_tropical_self_reasoning,
  title={Tropical Self-Reasoning: A Formally Verified Framework for Neural Network Introspection},
  author={The Oracle Council},
  year={2025},
  note={Lean 4 formalization with Mathlib}
}
```
