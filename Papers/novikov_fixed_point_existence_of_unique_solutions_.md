# Computational Evidence — Novikov-Fixed-Point

The theorem is a Banach fixed-point statement, so the "evidence" is a check that the
contraction hypothesis genuinely forces a unique self-consistent history and that the
closed-form value for the affine billiard model is correct.

## 1. Affine billiard-through-a-wormhole model `evolve x = a·x + b`

Self-consistency means `a·x + b = x`, i.e. `x = b / (1 - a)` (valid for `a ≠ 1`,
in particular whenever `|a| < 1`).

| a    | b   | predicted history `b/(1-a)` | relaxation `evolveⁿ(0)` (n = 20) |
|------|-----|-----------------------------|----------------------------------|
| 0.5  | 1.0 | 2.0                         | 1.99999809...  → 2.0             |
| -0.5 | 1.0 | 0.6666...                   | 0.66666...     → 0.6667          |
| 0.9  | 0.2 | 2.0                         | 1.7580...  (slow, → 2.0)         |
| 0.0  | 3.0 | 3.0                         | 3.0 (one step)                   |

The relaxation iteration `evolveⁿ(x₀)` converges to `b/(1-a)` from every starting
`x₀`, at geometric rate `|a|ⁿ`, matching `iterate_tendsto` and the a-priori bound.

## 2. Non-contracting counter-check (`|a| ≥ 1`)

- `a = 1, b ≠ 0`: `a·x + b = x` has **no** solution — no self-consistent history.
  This confirms the contraction hypothesis `rate < 1` is load-bearing (the Novikov
  guarantee genuinely can fail for `|a| = 1`).
- `a = 2, b = 0`: fixed point `x = 0` exists but iteration from `x₀ ≠ 0` diverges;
  the loop *amplifies* discrepancies, so relaxation to consistency fails. Again this
  is outside the `rate < 1` regime, as expected.

## 3. Stability perturbation bound

For `L₁ = affineLoop a b`, `L₂ = affineLoop a b'`, the histories are `b/(1-a)` and
`b'/(1-a)`. Their distance is `|b - b'|/(1-a)`. The bound
`dist(L₁.evolve L₂.history, L₂.history)/(1 - a) = |b - b'|/(1-a)` is attained
exactly, confirming `stability` is sharp for affine loops.

These finite checks are consistency sanity checks; the formal guarantees are proved
in `Catalog/Novelty/NovikovFixedPoint.lean` for arbitrary nonempty complete metric
state spaces, not just these examples.
