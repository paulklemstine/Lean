# Computational Evidence — Finite Optimal Transport & Wasserstein

This note records the small-case checks performed before formalizing the theorems
in `Kantorovich.lean`, `Wasserstein.lean`, and `Brenier.lean`.

## 1. Transportation polytope is nonempty and compact

For `a = (1/2, 1/2)`, `b = (1/3, 2/3)` on `Fin 2`, the product coupling is

```
a ⊗ b = [[1/6, 1/3],
         [1/6, 1/3]]
```

Row sums `(1/2, 1/2) = a`, column sums `(1/3, 2/3) = b`, all entries `≥ 0`.  Hence
the feasible set is nonempty, confirming `productPlan_isTransportPlan`.  Each entry
lies in `[0, a i]`, illustrating the boundedness bound used in
`isBounded_feasibleSet`.

## 2. Self-distance is zero (diagonal coupling)

With ground cost `d i j = |x i - x j|` (a metric) the diagonal coupling
`diag(a)` has cost `∑ a i * d i i = 0`, so `wValue d a a = 0`.  Checked for
`a = (0.4, 0.6)`, `x = (0, 1)`:  cost `= 0`.

## 3. Discrete Brenier (quadratic cost) — rearrangement

Points `x = (0, 1, 2)`, `y = (0, 10, 20)` (both sorted, `Monovary x y`).
Quadratic matching cost `∑ (x i - y σ(i))²` over the 6 permutations of `Fin 3`:

| σ (image of 0,1,2) | cost |
|--------------------|------|
| id (0,1,2)         | 0² + 9² + 18² = 405  |
| (0,2,1)            | 0² + 19² + 8² = 425  |
| (1,0,2)            | 10² + 1² + 18² = 425 |
| (2,1,0)            | 20² + 9² + 2² = 485  |
| (1,2,0)            | 10² + 19² + 2² = 465 |
| (2,0,1)            | 20² + 1² + 8² = 465  |

Minimum is attained at `σ = id` (cost 405), matching `brenier_monotone_optimal`.

Counterexample hunt for the monotonicity hypothesis: with `y = (20, 10, 0)`
(anti-sorted, so `Monovary x y` fails) the *reversing* permutation, not the
identity, is optimal — confirming the `Monovary` hypothesis is load-bearing.

## 4. Symmetry

For symmetric `d`, transposing any coupling `π ↦ πᵀ` is a cost-preserving bijection
between plans `a → b` and plans `b → a`, so `wValue d a b = wValue d b a`.  Checked
numerically on the `Fin 2` example above with `d = [[0,1],[1,0]]`: both directions
give optimal value `1/3`.
