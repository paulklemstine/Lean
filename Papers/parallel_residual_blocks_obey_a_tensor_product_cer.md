# Computational evidence — parallel residual blocks and the tensor-product certificate

All numbers below were produced by exact rational (`ℚ`) computation inside Lean 4
(`#eval`), so they are exact, not floating point.  They are *evidence*, not proof; the
proofs are the Lean theorems in `Catalog/Algebra/` (see the summary at the end).

## Setup

A residual block with certificate `K` is `x ↦ x + r x` with `r` `K`-Lipschitz.
For the experiments we deliberately used a **nonlinear** first residual, so that the data
is not an artefact of linearity:

```
r₁(x) = K₁ · |x|      (exactly K₁-Lipschitz, not linear)
r₂(y) = K₂ · y
F(x, y) = (x + r₁(x), y + r₂(y))
```

Test set: the 81 points of the grid `{-2, -1.5, …, 2}²`, i.e. all 6480 ordered pairs of
distinct points; for each pair we computed the exact difference quotient
`dist(F p, F q) / dist(p, q)` and took the maximum.

## 1. Max product norm (L^∞): empirical sharp constant vs. conjectured bound

| `(K₁, K₂)` | empirical `max` quotient | `max (1+K₁) (1+K₂)` |
|---|---|---|
| (0, 0)     | 1    | 1   |
| (1, 0)     | 2    | 2   |
| (0, 1)     | 2    | 2   |
| (1, 2)     | 3    | 3   |
| (1/2, 3/2) | 5/2  | 5/2 |
| (2, 2)     | 3    | 3   |
| (3, 1)     | 4    | 4   |

**No pair exceeded the bound** (counterexample hunt: 0 hits in 6480 × 7 quotients), and in
every case the bound was *met exactly* — attainment already visible at the level of a
finite grid.

## 2. Sum product norm (L¹): same constant

| `(K₁, K₂)` | empirical `max` quotient (L¹) | `max (1+K₁) (1+K₂)` |
|---|---|---|
| (0, 0)     | 1   | 1   |
| (1, 0)     | 2   | 2   |
| (1, 2)     | 3   | 3   |
| (1/2, 3/2) | 5/2 | 5/2 |
| (3, 1)     | 4   | 4   |

This is what suggested the `p`-independence theorem (`residual_certificate_p_independent`):
the certificate is a property of the pair of blocks, not of the cartesian metric used to
glue them.  Formalised for `p = ∞, 1, 2`.

## 3. Laxity hunt (interleaving serial and parallel composition)

Stage 1 = `par(id, dilation 1)` (certificates `0, 1`), stage 2 = `par(dilation 1, id)`
(certificates `1, 0`).  The composite map is `(x, y) ↦ (2x, 2y)`.

* Empirical least Lipschitz constant of the composite (max norm): **2** (exact grid value).
* Certificate obtained by *parallel-first* bookkeeping:
  `serial (par 0 1) (par 1 0) = 1 + 1 + 1 = 3`, i.e. gain `1 + 3 = 4`.
* Certificate obtained by *serial-first* bookkeeping:
  `par (serial 0 1) (serial 1 0) = max 1 1 = 1`, i.e. gain `2` — sharp.

Gap `2 < 4`.  This is the experimental origin of `ResidualCert.interchange_gap` and
`ParallelResidualBlocks.certificate_laxity_gap`: the certificate assignment is a *lax*,
not strict, monoidal functor once depth is interleaved with width.

## 3b. Depth scaling of the laxity defect (alternating architecture)

Branch A has certificates `1, 0, 1, 0, …`, branch B has `0, 1, 0, 1, …`, depth `2n`:

| `n` | sharp gain `max_i ∏_j (1 + K i j)` | coarse gain `∏_j max_i (1 + K i j)` | defect |
|---|---|---|---|
| 0 | 1  | 1    | 1  |
| 1 | 2  | 4    | 2  |
| 2 | 4  | 16   | 4  |
| 3 | 8  | 64   | 8  |
| 4 | 16 | 256  | 16 |
| 5 | 32 | 1024 | 32 |

Exact rational computation; the pattern `2^n` versus `4^n` is proved in
`ParallelResidualBlocks.alternating_gains`, and the unboundedness of the defect in
`laxity_defect_unbounded`.

## 4. Sequence check

The gains along a depth-`d` stack of a certificate-`K` block are `(1+K)^d`; for `K = 1`
this is `1, 2, 4, 8, 16, …` (powers of two, OEIS A000079), and for `K = 2`,
`1, 3, 9, 27, …` (A000244).  No new integer sequence arises, which is consistent with the
theorem `ResidualCert.gainOrderIso`: the certificate monoid is isomorphic to the
multiplicative monoid `[1, ∞)`, so nothing beyond geometric growth can appear.

## Lab notes

* **Hypothesis H1** (upper bound `max (1+K₁) (1+K₂)`): survived every test, then proved —
  `parallel_lipschitz_bound`.
* **Hypothesis H2** (attainment for all `K₁, K₂ ≥ 0`): survived, then proved in the strong
  `IsLeast` form — `parallel_isLeast_lipschitz`.
* **Hypothesis H3** (the certificate calculus is a *strict* monoidal functor): **refuted**
  by experiment 3 above and then refuted formally — `certificate_laxity_gap`.  The correct
  statement is the lax inequality `interchange_lax`; experiment 3b then showed the defect
  grows like `2^n` in the depth, which is proved in `laxity_defect_unbounded`.
* **Hypothesis H4** (the constant depends on the choice of `Lᵖ` product): **refuted** by
  experiment 2 and then refuted formally — `residual_certificate_p_independent`.
* **Hypothesis H5** (inverse blocks obey a *different* rule): refuted — the inverse
  certificates obey the same max rule, `parallel_inverse_lipschitz_bound`, sharply
  (`parallel_inverse_sharp`).
