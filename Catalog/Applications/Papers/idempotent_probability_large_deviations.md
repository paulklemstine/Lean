# Computational Evidence — Idempotent Probability: Large Deviations

All claims below were checked with exact rational arithmetic (`ℚ`) inside Lean
(`#eval`) before being formalized over `ℝ`. The point of the exact checks is to
make sure the *strict* duality gap is real and not a floating-point artefact.

## 1. The adversarial idempotent law on `Fin 3`

* values `val = (0, 1, 2)`
* weights `w = (0, -2, 0)`  ⇒  rate function `I = -w = (0, 2, 0)`

`I` is a "spike up" at the middle point, so it is **non-convex**: the chord from
`(0,0)` to `(2,0)` lies strictly below `I(1) = 2`.

## 2. Idempotent cumulant generating function `Λ(λ) = max_i (λ·val i + w i)`

`Λ(λ) = max(λ·0+0, λ·1−2, λ·2+0) = max(0, λ−2, 2λ)`.

Tabulating `λ`, `Λ(λ)` and the Legendre summand `λ·1 − Λ(λ)` (the term whose
supremum over `λ` is `lfBiconj` at the middle value `a = 1`):

| λ  | Λ(λ) | λ·1 − Λ(λ) |
|----|------|------------|
| −4 |  0   |  −4        |
| −3 |  0   |  −3        |
| −2 |  0   |  −2        |
| −1 |  0   |  −1        |
|  0 |  0   |   0        |  ← supremum
|  1 |  2   |  −1        |
|  2 |  4   |  −2        |
|  3 |  6   |  −3        |
|  4 |  8   |  −4        |

The supremum of the last column is `0`, attained at `λ = 0`. Hence
`lfBiconj(1) = 0`, while `I(1) = 2`.

## 3. The duality gap

```
gap = I(1) − lfBiconj(1) = 2 − 0 = 2.
```

This equals exactly the height of the non-convex spike above its chord. The double
Legendre–Fenchel transform produces the **convex lower envelope** of `I`, which here
is the flat chord `≡ 0`, losing the spike entirely.

These numbers are reproduced exactly by the Lean theorems `gap_lfBiconj_mid`,
`gapRate_mid`, `strict_duality_gap`, and `duality_gap_value`.

## 4. Counterexample hunt for the main lemmas

* **`idempotentCGF_add` (CGF additivity under independence).** Tested on random
  small `ℚ`-valued products `Fin 2 × Fin 2`; equality held in every case. It is
  robust because the product weight is the *sum* of marginal weights and the
  observable is additive, so the finite sup over the product separates.
* **`idempotent_chernoff` (LDP upper bound).** The hypothesis `0 ≤ λ` is essential:
  for `λ < 0` the tabulated `λ·1 − Λ(λ)` line shows the bound would be reversed.
* **`lfBiconj_le_rate` (weak duality).** The strict example in §3 shows the
  inequality cannot be upgraded to equality without convexity — so the lemma is
  exactly as strong as it can be, and `lfBiconj_eq_rate_of_support` records the
  precise (supporting-line) condition for equality.
