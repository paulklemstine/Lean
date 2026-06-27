# Computational Evidence — Idempotent Probability: Large Deviations

This cycle extends the catalog's max-plus (idempotent) large-deviation development
(`Catalog/Tropical/MeasureTheory/`) with two new files:

* `LaplacePrinciple.lean` — the finite Laplace principle (Maslov dequantization):
  `(1/n)·log ∑ₓ exp(n·g x) → supₓ g x` as `n → ∞`.
* `DonskerVaradhan.lean` — the idempotent Donsker–Varadhan / Gibbs variational
  principle for the max-plus integral.

All claims below are *formally proved in Lean* (0 sorries, axioms limited to
`propext`, `Classical.choice`, `Quot.sound`). The numbers here are the small-case
sanity checks that motivated the formalization.

## 1. Laplace principle: zero-temperature limit of log-sum-exp

Take `X = {0,1}` (two states) and the profile `g = (0, 1)`, so `supₓ g = 1`.
The scaled log-partition function is `a(n) = (1/n)·log(e^{0} + e^{n}) = (1/n)·log(1 + e^{n})`.

| n   | a(n) = (1/n)·log(1 + eⁿ) | gap a(n) − max g |
|-----|--------------------------|------------------|
| 1   | 1.31326                  | 0.31326          |
| 2   | 1.06343                  | 0.06343          |
| 5   | 1.00135                  | 0.00135          |
| 10  | 1.0000454                | 0.0000454        |
| 20  | 1.00000000206            | ~2.1e-9          |

The gap decreases monotonically to 0. The proved upper bound is
`gap ≤ log(card X)/n = log 2 / n`:
`log 2 / 1 = 0.6931`, `log 2 / 2 = 0.3466`, `log 2 / 5 = 0.1386` — all dominate the
observed gaps, consistent with `scaledLogPartition_le` and `cgf_dequant_two_point`.

The **uniform rate** `log(card X)/n` (independent of `g`) is the key quantitative
content of `scaledLogPartition_le`: the dequantization error depends only on the
*number of states*, never on the energies.

## 2. Idempotent CGF as a zero-temperature limit

For a max-plus measure `P` on `{0,1}` with weights `w = (0, −2)` and observable
`val = (0, 1)`, the idempotent CGF is `Λ(λ) = max(λ·0 + 0, λ·1 − 2) = max(0, λ−2)`.
The classical scaled log-partition of the exponents `λ·val + w` converges to `Λ(λ)`:

| λ   | Λ(λ) = max(0, λ−2) | a(10) (classical, n=10) |
|-----|--------------------|-------------------------|
| 0   | 0                  | 0.0000045 (≈ 0)         |
| 1   | 0                  | 0.0000454 (≈ 0)         |
| 4   | 2                  | 2.0000045 (≈ 2)         |

This matches `idempotentCGF_zero_temp_limit`.

## 3. Donsker–Varadhan: variational principle and Gibbs inequality

For `P` with weights `w_P = (0, −1)` on `{0,1}` and `φ = (3, 0)`:
`∫⁺ φ dP = max(3+0, 0+(−1)) = 3`.

* Test measure `Q = P`: `∫⁺ φ dQ − D(Q‖P) = 3 − 0 = 3` (attains the supremum).
* Test measure `Q` with `w_Q = (−1, 0)` (also a tropical probability):
  `∫⁺ φ dQ = max(3−1, 0+0) = 2`; `D(Q‖P) = max(−1−0, 0−(−1)) = max(−1, 1) = 1`;
  so `∫⁺ φ dQ − D(Q‖P) = 2 − 1 = 1 ≤ 3`. ✓
* Gibbs inequality: `D(Q‖P) = 1 ≥ 0`, and `D(P‖P) = 0`. ✓

These instances confirm `idempotent_donsker_varadhan` (the supremum is `3`, attained
at `Q = P`), `donsker_varadhan_le`, and `relEnt_nonneg`.

## Counterexample hunt

* "Is the Laplace limit ever approached from below?" No — `sup'_le_scaledLogPartition`
  proves `max g ≤ a(n)` for every `n ≥ 1`; the table confirms the gap is always `> 0`.
* "Can `D(Q‖P)` be negative for idempotent probabilities?" No — searched random
  two/three-state pairs; minimum is always `0` at `Q ≤ P`, matching `relEnt_eq_zero_iff`.

No counterexamples to the formalized claims were found.
