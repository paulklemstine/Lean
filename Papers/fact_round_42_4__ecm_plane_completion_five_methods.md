# Computational evidence — ECM-plane completion (exp 490 follow-up)

All numbers below were produced with plain double-precision arithmetic before the Lean
formalisation, purely to check that the intended theorems are *true* and non-vacuous.
They are **not** verified artefacts; every claim that survives into the `.lean` files is
proved there from first principles. Where a numeric fact is used inside a theorem it is
restated as an exact rational/`Real` inequality and discharged by `norm_num` or by an
`rpow` monotonicity argument (see `ecm_calibration_at_twenty_bits`,
`common_currency_within_one_bit`, `batched_gcd_erases_sqrt_law`).

## 1. The measured plane (input data, exp 490, seed 20260921)

| arm | regime | α | intercept |
|---|---|---|---|
| trial division | uniform | 1.00 | c_td |
| trial division | balanced | 1.14 | c_td' |
| Fermat | both | 0.50 | – |
| Pollard rho (per-iteration gcd) | both | 0.512 | c_ρ |
| ECM, B₁ = 50 | both | 0.761 | c_ρ + 3.04 |
| ECM, B₁ = 250 | both | 0.718 | c_ρ + d |

## 2. Collinearity of the ECM columns with rho (drives `ecm250_never_leads_of_overhead`)

```
t = 43/249 = 0.1726907...,  1 - t = 206/249 = 0.8273092...
t·0.512 + (1-t)·0.761 = 0.718000...   (exact: (43·512 + 206·761)/249000 = 0.718)
threshold  d* = 3.04 · 206/249 = 2.51502...
```
So the three exponents `0.512, 0.718, 0.761` are **exactly** collinear with rational
weights, and the `B₁ = 250` column is a Newton-polygon vertex iff its overhead over rho is
below `≈ 2.515` bits. This is the falsifiable prediction formalised in
`ECMHull.ecm250_never_leads_of_overhead`.

## 3. Common currency vs wall time (H3)

```
log2(10.29) = 3.36317...,   measured bit gap = 3.04,   |3.04 − 3.363| = 0.323 < 1
8 = 2^3 < 10.29 < 2^4 = 16
```
Formalised as `ECMPlane.common_currency_within_one_bit`.

## 4. Calibration `B ≥ p^{1−α}/2` at α = 0.761

| k = log₂ p | forced lower bound on B₁ |
|---|---|
| 16 | 7.08 |
| 20 | 13.74 |
| 24 | 26.65 |
| 32 | 100.3 |
| 64 | 20115 |

At the experiment's largest size (`k = 20`) the bound is `13.7 ≤ 50`: the measured slope is
consistent with `B₁ = 50`, and the same slope at `k = 32` would already be inconsistent
with a *fixed* `B₁ = 50`. The `k = 20` instance is proved in
`ECMPlane.ecm_calibration_at_twenty_bits` (via `2^{20·0.239} ≤ 2^5 = 32`, so the bound is
`≤ 16 ≤ 50`).

## 5. Batched-gcd quantisation (ledger)

```
k = 16: √p = 256   → batch(2048, 256)  = 2048
k = 20: √p = 1024  → batch(2048, 1024) = 2048
measured chord slope: (log2 2048 − log2 2048)/(20−16) = 0
per-iteration gcd  : (log2 1024 − log2 256)/(20−16) = (10−8)/4 = 0.5
```
Exactly the ledger entry ("batched gcd erased the √p law; per-iteration gcd restored
α = 0.512"). Formalised in `ECMPlane.batched_gcd_erases_sqrt_law` /
`ECMPlane.per_iteration_gcd_keeps_sqrt_law` and generalised by `ECMPlane.batch_dichotomy`.

## 6. Counterexample hunt: does a *fixed* exponent ever fit the true ECM cost?

For `L(p) = exp(c √(log p · log log p))` with `c = 1`, in bits:

| k = log₂ p | log₂ L | fitted slope log₂L/k | chord slope over [k, 2k] |
|---|---|---|---|
| 16 | 7.45 | 0.466 | 0.282 |
| 20 | 8.71 | 0.436 | 0.257 |
| 32 | 11.96 | 0.374 | 0.211 |
| 64 | 18.71 | 0.292 | 0.157 |
| 256 | 43.73 | 0.171 | 0.086 |
| 1024 | 98.48 | 0.096 | 0.047 |
| 16384 | 469.80 | 0.029 | 0.013 |

No fixed positive exponent fits: both the fitted slope and the two-point chord slope decay
monotonically towards `0`, which is what
`ECMSubexp.subexp_exponent_tendsto_zero` and `ECMSubexp.subexp_doubling_slope_tendsto_zero`
prove. Note also the honest caveat this table forces: at the experiment's own window
(`k = 16..20`) the pure `L(1/2)` model would predict a chord slope near `0.26`, *not*
`0.761`. The measured `0.761` is therefore explained by the **fixed** stage-one bound
(`α = 1 − β` with `β ≈ 0.239`, section 3 of `ECMPlaneCompletion.lean`), not by the
asymptotic subexponential law — the two explanations occupy different scales, and the
theorems are stated so that both are simultaneously true.

## 7. OEIS

No integer sequence is central here; the one integer-valued object,
`batch m T = m⌈T/m⌉`, is a standard ceiling-quantisation and was not searched.
