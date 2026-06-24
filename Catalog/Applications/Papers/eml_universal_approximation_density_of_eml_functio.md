# Computational Evidence — Finite-Family Log-Sum-Exp Rate `τ·log n`

This evidence supports `EMLFinsetLSE.abs_lse_sub_max_le`:
`|τ·log(∑ exp(fᵢ/τ)) − maxᵢ fᵢ| ≤ τ·log(card s)`.

## 1. Small-case calculations (constant inputs, the extremal case)

When all `n` inputs equal `c`, `lse = τ·log(n·exp(c/τ)) = c + τ·log n`, so the
gap `lse − max = τ·log n` exactly — the bound is attained.

| n | τ   | predicted bound `τ·log n` | actual gap (constant input) |
|---|-----|---------------------------|-----------------------------|
| 1 | 1.0 | 0.0000                    | 0.0000                      |
| 2 | 1.0 | 0.6931                    | 0.6931                      |
| 3 | 1.0 | 1.0986                    | 1.0986                      |
| 4 | 0.5 | 0.6931                    | 0.6931                      |
| 8 | 0.25| 0.5199                    | 0.5199                      |

## 2. Non-extremal inputs stay strictly below the bound

For `f = (0, 1, 2)` (spread out), `τ = 1`: `lse = log(1+e+e²) ≈ 2.4076`,
`max = 2`, gap `≈ 0.4076 < log 3 ≈ 1.0986`. The further apart the inputs, the
smaller the gap — consistent with saturation only at coincident inputs
(Future Direction 1).

## 3. Counterexample hunt

Tested the lower bound `max ≤ lse` and the upper bound `lse ≤ max + τ·log n`
across random families (varying `n ≤ 12`, `τ ∈ {0.1,…,2}`, values in `[-5,5]`).
No violation found; both bounds held in every sample, matching the formal proof.

## 4. Dequantization limit

Fixing inputs and shrinking `τ`, the gap `τ·log n → 0`, so `lse → max`. This is
the quantitative content of `exists_temp_approx`: pick `τ = ε/(log n + 1)`.

## Note on OEIS
No integer sequence is intrinsic to this continuous-analysis result; the only
discrete parameter is the width `n`, entering through `log n`. No OEIS lookup
applies.
