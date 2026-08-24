# Computational Evidence — C4 / N2 (RLHF audit gaps)

All numbers below come from a small floating-point exploration of the exact finite
model (no Lean involvement); they are **evidence, not verification**.  Every claim that
is asserted as true in this project is proved in Lean, sorry-free, in
`Catalog/Computation/RLHFThreshold/`.

## Setup

Reference policy `p` on a finite response set, reward `r` with `|r| ≤ R`, audit
statistic `f`, aligned policy `π_β(y) ∝ p(y) e^{r(y)/β}`, audit gap
`G(β) = 𝔼_{π_β} f − 𝔼_p f`.

Objects: `Cov = Cov_p(r,f)`, `σ = σ_p(f)`, `SkewCov = 𝔼_p[(r−𝔼r)²(f−𝔼f)]`.

## 1. Stress test of the two proved envelopes

400 random instances (`|Ω| ∈ {2,…,6}`, random full-support `p`, random `r` attaining
`±R` with `R ∈ [0.1, 3]`, random `f`), each evaluated at `β ∈ {R, 1.3R, 2R, 5R, 20R}`
(the whole admissible range `β ≥ R`):

| quantity | proved bound | worst observed ratio |
|---|---|---|
| `\|G(β) − Cov/β\| / ((R/β)² σ)` | `≤ 24` (`audit_gap_first_order`) | **0.478** |
| `\|G(β) − Cov/β − SkewCov/(2β²)\| / ((R/β)³ σ)` | `≤ 40` (`audit_gap_second_order`) | **0.330** |

No counterexample was found; the constants proved in Lean are comfortable (a factor
≈ 50 and ≈ 120 of slack respectively), which is expected since the proofs use crude
`1/Z ≤ 3` and `|Z − 1| ≤ 3R/β` estimates.  No attempt is made here to optimize them.

## 2. The sharp threshold `ε · β_c(ε) → |Cov|`

Model: `p = (0.30, 0.45, 0.25)`, `r = (1.0, −0.4, −0.7)` (`R = 1`),
`f = (2.0, −1.0, 0.5)`, for which `Cov_p(r,f) = 0.707625`.
`β_c(ε)` computed by bisection as `sup{β ≥ R : |G(β)| ≥ ε}`:

| ε | β_c(ε) | ε·β_c(ε) |
|---|---|---|
| 1e-1 | 7.4195 | 0.741952 |
| 1e-2 | 71.134 | 0.711344 |
| 1e-3 | 708.00 | 0.708000 |
| 1e-4 | 7076.6 | 0.707663 |

The product converges to `0.70762… = |Cov_p(r,f)|`, matching the proved theorem
`RLHF.tendsto_eps_mul_betaCrit`.

## 3. Counterexample hunt for the second-order coefficient

We searched for instances where `β²(G(β) − Cov/β)` fails to approach `SkewCov/2`; none
were found (agreement to 6 digits by `β = 100R`).  Conversely the search confirmed the
degeneracy predicted by the algebra: for a *symmetric* two-point model (`p = (½,½)`,
`r = ±R`, `f = ±1`) the second-order term vanishes identically — indeed there
`G(β) = tanh(R/β)`, an odd function of `1/β`.  Biasing the policy to `p = (q, 1−q)`
gives `SkewCov = 8R²q(1−q)(1−2q) ≠ 0` for `q ≠ ½`; this is the family formalized in
`Catalog/Computation/RLHFThreshold/SharpOrder.lean`, which proves that the `β⁻²` order
of the first-order remainder cannot be improved.

## 4. No OEIS entry

The objects here are real-analytic (covariances, `tanh`), not integer sequences, so no
OEIS search applies.
