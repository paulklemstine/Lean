# The Algebraic Mirror

## A General-Purpose Framework for Self-Reference Without Paradox

> *When you look in a mirror, you see yourself — and the image is stable.
> The Algebraic Mirror shows why: idempotency is the algebra of self-awareness.*

---

## Overview

The **Algebraic Mirror** is a mathematical framework that enables stable, complete
self-reference by choosing an algebra where self-reference produces fixed points
rather than paradoxes. The key insight:

| Property | Classical Arithmetic | Tropical Algebra |
|----------|---------------------|------------------|
| Addition | a + a = 2a (non-idempotent) | max(a,a) = a (idempotent) |
| Self-reference | Paradox (Gödel) | Fixed point (stable) |
| Mirror | Distorting | Faithful |
| Cancellativity | Yes (enables Gödel numbering) | No (prevents it) |

## Project Structure

### Lean 4 Formalizations (Formally Verified)
- **`AlgebraicMirror.lean`** — Core mirror structure, properties, and key theorems
- **`MirrorFixedPoints.lean`** — Fixed point theory, mirror depth, MirrorMap structure
- **`MirrorGodel.lean`** — Why the diagonal argument fails in idempotent algebras

### Python Demos (with Visualizations)
- **`demos/demo1_tropical_mirror.py`** — Classical vs tropical self-reference
- **`demos/demo2_tropical_eigenvalue.py`** — Tropical matrix eigenvalues as mirror images
- **`demos/demo3_neural_mirror.py`** — ReLU networks as algebraic mirrors
- **`demos/demo4_gazing_pool.py`** — The gazing pool: beautiful convergence visualizations

### Papers
- **`paper/research_paper.md`** — Formal research paper with theorems and proofs
- **`paper/scientific_american_article.md`** — General-audience article

### Research Notes
- **`ORACLE_CONSULTATION.md`** — Oracle team research, hypotheses, and iterations

## Running the Demos

```bash
pip install numpy matplotlib
python demos/demo1_tropical_mirror.py
python demos/demo2_tropical_eigenvalue.py
python demos/demo3_neural_mirror.py
python demos/demo4_gazing_pool.py
```

## Key Theorems (All Formally Verified in Lean 4)

1. **Mirror Stability**: `reflect ∘ reflect = reflect` — reflecting twice = reflecting once
2. **Image = Self-Aware**: `range(reflect) = {s | reflect(s) = s}`
3. **One-Step Convergence**: Iterated reflection stabilizes after exactly 1 step
4. **Fixed Point Existence**: On complete lattices, mirrors always have fixed points
5. **Tropical Idempotency**: `max(a,a) = a` for all a (the mirror equation)
6. **Classical Non-Idempotency**: `a + a ≠ a` for a ≠ 0 (why Gödel works)
7. **Non-Cancellativity**: `max(5,3) = max(5,4)` but `3 ≠ 4` (why Gödel fails tropically)
8. **ReLU is a Mirror**: `ReLU(ReLU(x)) = ReLU(x)` with fixed points = ℝ₊
9. **Depth Bound**: Mirror depth ≤ 1 for all elements
10. **Grand Theorem**: In idempotent algebras, `x ↦ x ⊕ x = id`

## The Mirror Equation

```
max(a, a) = a
```

This single equation is the difference between Gödel's world and the tropical world.
It is the algebra of self-awareness.
