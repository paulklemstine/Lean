# Computational Evidence — Moment Fingerprints of Spectral Statistics

All numbers below were produced by ad-hoc floating-point exploration (numerical
quadrature and direct evaluation of the closed forms).  They are **evidence, not
verification**: every statement that is actually claimed as a result is proved in
Lean 4 in `Catalog/Algebra/MomentFingerprint*.lean`, with 0 sorries and only the
standard axioms `propext, Classical.choice, Quot.sound`.

## 1. Small-case moments

Numerical quadrature of `∫₀^∞ sᵏ p(s) ds` on `[0,25]` (trapezoid, 2·10⁵ nodes)
against the conjectured closed forms:

| k | GUE quadrature | GUE closed form | GOE quadrature | GOE closed form | GSE quadrature | GSE closed form |
|---|---|---|---|---|---|---|
| 0 | 1.000000 | 1 | 1.000000 | 1 | 1.000000 | 1 |
| 1 | 1.000000 | 1 | 1.000000 | 1 | 1.000000 | 1 |
| 2 | 1.178097 | 3π/8 = 1.178097 | 1.273240 | 4/π = 1.273240 | 1.104466 | 45π/128 = 1.104466 |
| 3 | 1.570796 | π/2 = 1.570796 | 1.909859 | — | 1.325359 | — |
| 4 | 2.313189 | 15π²/64 = 2.313189 | 3.242278 | — | 1.707784 | — |

The GUE column matches the two closed forms proved in Lean,
`M_{2m} = (2m+1)‼ (π/8)^m` and `M_{2m+1} = (m+1)! (π/4)^m`; the `β = 1, 4`
normalizations and second moments match `goeMoment_two`, `gseMoment_two`.

## 2. The moment fingerprint `M_k` versus `k!`

| k | `M_k` | `k!` | ratio `M_k/k!` | proved bound `2·2^{-⌊k/2⌋}` |
|---|---|---|---|---|
| 0 | 1.000000 | 1 | 1.000000 | 2 |
| 1 | 1.000000 | 1 | 1.000000 | 2 |
| 2 | 1.178097 | 2 | 0.589049 | 1 |
| 3 | 1.570796 | 6 | 0.261799 | 1 |
| 4 | 2.313189 | 24 | 0.096383 | 0.5 |
| 5 | 3.701102 | 120 | 0.030843 | 0.5 |
| 6 | 6.358709 | 720 | 0.008832 | 0.25 |
| 8 | 22.473533 | 40320 | 0.000557 | 0.125 |
| 10 | 97.078693 | 3628800 | 0.0000268 | 0.0625 |

Counterexample hunt for "some higher moment coincidence": scanning `k ≤ 10⁴`
found **no** `k ≥ 2` with `M_k = k!`, and the ratio is monotonically decreasing.
This is now a theorem (`gueMoment_eq_poissonMoment_iff`): agreement happens only
at `k = 0, 1`.  What *does* exist is an index-halving duality, proved in
`MomentFingerprintDuality.lean`:
`M_{2m+1}/P_{m+1} = (π/4)^m` and `M_{2m}·m! = P_{2m+1}·(π/16)^m`.

## 3. Integer sequences (OEIS)

* Even-moment coefficients `1, 3, 15, 105, 945, …` = double factorials `(2m+1)‼`,
  **OEIS A001147**.
* Odd-moment coefficients `1, 2, 6, 24, 120, …` = `(m+1)!`, **OEIS A000142**.
* The exponential-law fingerprint is `k!` itself, **OEIS A000142**.

## 4. Hankel fingerprints

`hankel3 M = det [[M₀,M₁,M₂],[M₁,M₂,M₃],[M₂,M₃,M₄]]`:

| regime | value | numeric |
|---|---|---|
| rigid (δ₁) | 0 | 0 |
| GUE | π²(9π − 28)/256 | 0.0105764 |
| Poisson | 4 | 4 |

The GUE value is positive but small; positivity is equivalent to `π > 28/9`
(proved in `hankel3_gue_pos_iff`).  Numerically `28/9 = 3.1111 < π`.

## 5. The β-ladder and the separation constants

| regime | second moment | numeric |
|---|---|---|
| rigid | 1 | 1.000000 |
| GSE (β = 4) | 45π/128 | 1.104466 |
| GUE (β = 2) | 3π/8 | 1.178097 |
| GOE (β = 1) | 4/π | 1.273240 |
| Poisson | 2 | 2.000000 |

Adjacent gaps: `0.104466, 0.073631, 0.095142, 0.726760`.  The minimum is
`3π/128 = 0.0736311`, attained by the GSE/GUE pair — this is the proved
separation constant `ladderGap`.  For the coarse three-regime problem the
constant is `sepConst = 3π/8 − 1 = 0.178097`.

Sample-size thresholds under a `C/√n` fluctuation bound with `C = 1`:
`(2/sepConst)² = 126.11`, so `n ≥ 127` suffices (`classify_of_unit_fluctuation_127`);
`(2/ladderGap)² = 737.80`, so `n ≥ 738` suffices for the five-regime ladder.
