# Computational Evidence — Chromatic Polynomial Theory

All values below were computed in Lean (`#eval`) and match the formal theorems in
`Catalog/Algebra/ChromaticPolynomial.lean` and `Catalog/Algebra/GraphColoringBounds.lean`.

## 1. Complete graph `Kₙ`: `P(Kₙ, q) = q.descFactorial n` (falling factorial)

Triangle `K₃`, `P(K₃, q) = q(q−1)(q−2)` for `q = 0..5`:

```
[0, 0, 0, 6, 24, 60]
```

Edge `K₂`, `P(K₂, q) = q(q−1)` for `q = 0..5`:

```
[0, 0, 2, 6, 12, 20]
```

Note `P(K₃, q) = 0` for `q < 3` and `P(K₂, q) = 0` for `q < 2`: a graph with clique
number `ω` has no proper coloring with fewer than `ω` colors.  This is exactly the
formal result `chromaticFn_eq_zero_of_lt_cliqueNum`.

## 2. Edgeless graph on `n = 3` vertices: `P(⊥, q) = q³`

`q = 0..5`:

```
[0, 1, 8, 27, 64, 125]
```

This matches `chromaticFn_bot : P(⊥, q) = q ^ |V|`.

## 3. Deletion–contraction sanity check

Take `G = K₂` (one edge `uv` on two vertices).  Then:
* `G − uv` is edgeless on 2 vertices, `P(G − uv, q) = q²`;
* `P(G, q) = q(q−1)`;
* the contraction `G / uv` is a single vertex, `P(G / uv, q) = q`.

The identity `P(G − uv, q) = P(G, q) + P(G / uv, q)` predicts `q² = q(q−1) + q`.
Computed pairs `(q², q(q−1)+q)` for `q = 0..5`:

```
[(0,0), (1,1), (4,4), (9,9), (16,16), (25,25)]
```

Both columns agree, confirming `deletion_contraction`.

## 4. Brooks sandwich `ω ≤ χ ≤ Δ + 1`

* `Kₙ₊₁`: `ω = χ = n + 1`, `Δ = n`, so `χ = Δ + 1` — the greedy bound is **tight**
  (`completeGraph_chromaticNumber_eq_maxDegree_add_one`).  Brooks' improvement
  `χ ≤ Δ` fails here.
* Odd cycle `C₂ₖ₊₁` (Mathlib `chromaticNumber_cycleGraph_of_odd`): `χ = 3`, `Δ = 2`,
  again `χ = Δ + 1`.  These are precisely the two Brooks exception families.

No counterexample to any stated theorem was found in the sampled range.
