# Computational Evidence — Rigidity gap for shallow product coins

All numbers below were produced by exhaustive/sampled enumeration in plain Python
(power iteration for the top singular value). **They are exploratory only**; the
statements that ended up in the Lean files are proved there from scratch and do not rely
on any of these computations.

## Setting

For a resonance set `R ⊆ A × B` let `M_R` be its 0/1 indicator matrix. For unit vectors
`f, g` the product-coin amplitude is `A(f ⊗ g) = fᵀ M_R g`, so

```
    max over unit product coins of ‖A(f ⊗ g)‖²  =  σ_max(M_R)² ,
    Cauchy–Schwarz optimum                       =  |R| = ‖M_R‖_F² .
```

`R` is a *combinatorial box* iff `M_R` has rank ≤ 1, i.e. iff `σ_max² = |R|`. So the
"rigidity gap" of a non-box `R` is `gap(R) = |R| − σ_max(M_R)² = Σ_{i≥2} σ_i(M_R)²`.

## 1. Small-case exhaustive enumeration

For every non-empty non-box `R` inside an `m × n` grid:

| grid | # non-boxes | min gap over all non-boxes | minimiser |
|------|-------------|----------------------------|-----------|
| 2×2  | 3           | 0.381966                   | `{(0,0),(0,1),(1,0)}` |
| 2×3  | 51          | 0.381966                   | L-shape |
| 3×3  | 495         | 0.381966                   | L-shape |
| 3×4  | 3990        | 0.381966                   | L-shape |
| 4×4  | 65310       | 0.381966                   | L-shape |
| 5×5  | 200 000 random samples | 0.381966        | an L-shape copy |

`0.381966… = (3 − √5)/2 = 2 − φ`, `φ` the golden ratio.

Minimum gap broken down by `|R|` (3×3 grid, exhaustive):

| `|R|` | min gap | crude guarantee `1/(9|R|)` |
|------|----------|-----------------------------|
| 2 | 1.000000 | 0.055556 |
| 3 | 0.381966 | 0.037037 |
| 4 | 0.585786 | 0.027778 |
| 5 | 0.438447 | 0.022222 |
| 6 | 0.951083 | 0.018519 |
| 7 | 0.627719 | 0.015873 |
| 8 | 0.535898 | 0.013889 |

**Zero violations** of the proved bound `σ_max² ≤ |R| − 1/(9|R|)` were found in any grid.

## 2. What the data suggested

The gap never decays with `|R|`; it is bounded below by a *universal* constant, attained
at the smallest non-box. This suggested replacing the `|R|`-dependent constant `1/(9|R|)`
by the absolute constant `(3 − √5)/2`, which is exactly `σ_min(!![1,0;1,1])²`.

That is precisely what `Catalog/Geometry/ShallowProductCoinGoldenGap.lean` now proves,
together with optimality (`goldenGap_optimal`).

## 3. Sequence lookup

The observed minimiser value `(3 − √5)/2 = 0.3819660112…` is `2 − φ = φ⁻²`; its decimal
expansion is A132338/A094214-adjacent (`1/φ = 0.6180339887…`, whose square is our
constant). No new integer sequence arose: the quantity of interest is an algebraic number
of degree 2, root of `x² − 3x + 1`.

## 4. Counterexample hunt

- Universal claim tested: *for every non-box `R`, `σ_max(M_R)² ≤ |R| − (3 − √5)/2`.*
- Tested on all 69 849 non-boxes in grids up to `4 × 4` and 200 000 random subsets of
  `5 × 5`. No counterexample; equality only for L-shape copies.
- Universal claim tested: *for every non-box `R`, `gap(R) ≥ 1/2`.* **Refuted** by the
  L-shape (`gap = 0.381966 < 1/2`), which is why `(3 − √5)/2` and not a rounder constant
  is the right answer.
