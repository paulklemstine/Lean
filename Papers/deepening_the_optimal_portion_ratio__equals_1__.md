# Computational evidence

## Small-case calculations

The bridge is controlled by the equations

- `ρ³ + ρ² = 1`,
- `p = 1/ρ`, hence `p³ = p + 1`,
- `μ = 1 + ρ = p²`.

Decimal iteration gives the following stable values:

| quantity | approximate value |
|---|---:|
| `ρ` | 0.7548776662 |
| `p = 1/ρ` | 1.3247179572 |
| `μ = 1+ρ = p²` | 1.7548776662 |

For the Padovan recurrence `a(n+3)=a(n+1)+a(n)` with initial values `1,1,1`, the first terms are
`1, 1, 1, 2, 2, 3, 4, 5, 7, 9, 12, 16, 21, 28, 37, 49`.
Successive ratios approach `p`; for example `49/37 ≈ 1.324324`.

## OEIS search result

The displayed integer sequence is the Padovan sequence (OEIS A000931, up to the conventional choice of initial indexing). Its exponential growth factor is the plastic number.

## Counterexample hunt

The exact identities were checked numerically at the displayed approximations:
`ρ³+ρ² ≈ 1`, `p³-p-1 ≈ 0`, and `p²-(1+ρ) ≈ 0`. No counterexample is possible once `ρ` is constrained by the exact cubic and positivity; the Lean proof establishes these identities symbolically rather than relying on floating-point calculations.

The broader assertion that this candidate equals the infimum over all infinite cutting strategies was not computationally tested here: a faithful finite encoding of arbitrary infinite strategies is not present in the supplied development. The formal contribution is the exact cross-domain algebraic and spectral bridge for the candidate constant.
