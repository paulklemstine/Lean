# Computational evidence — phase features, Gram entries and lift ceilings (paper 150, exp 482)

All numbers below were produced before formalization, to check that the intended theorems were
true and sharp. **The verified artifacts are the Lean theorems** in `Catalog/Novelty/`; the
tables here are exploratory arithmetic used to design and sanity-check them. Where a numeric
claim is used inside a theorem (e.g. `√(2/12) ≤ 0.41`, `9 · 3 · 0.01²/0.18 ≤ 0.016`,
`120 ≤ n`), it is discharged by `norm_num` inside a Lean proof, not by these tables.

## 1. Exact Gram entries over a full period

Direct summation over `r ∈ {0,…,p-1}` of the features `cos(2πkr/p)`, `sin(2πkr/p)`, and the
Legendre symbol `(r/p)`:

| p | k | ‖cos‖² | p/2 | ‖sin‖² | ⟪cos,sin⟫ | ‖QR‖² | \|⟪QR,cos⟫\| | √p | corr(QR,cos) | √(2/(p−1)) |
|---|---|--------|-----|--------|-----------|-------|--------------|-----|--------------|-------------|
| 13 | 1 | 6.5000 | 6.5 | 6.5000 | 5.6e−16 | 12 | 3.6056 | 3.6056 | 0.4082 | 0.4082 |
| 13 | 2 | 6.5000 | 6.5 | 6.5000 | 2.4e−15 | 12 | 3.6056 | 3.6056 | 0.4082 | 0.4082 |
| 17 | 1 | 8.5000 | 8.5 | 8.5000 | 5.6e−17 | 16 | 4.1231 | 4.1231 | 0.3536 | 0.3536 |
| 29 | 1 | 14.5000 | 14.5 | 14.5000 | 4.4e−16 | 28 | 5.3852 | 5.3852 | 0.2673 | 0.2673 |
| 101 | 1 | 50.5000 | 50.5 | 50.5000 | 2.1e−15 | 100 | 10.0499 | 10.0499 | 0.1414 | 0.1414 |

Readings:

* `‖cos‖² = ‖sin‖² = p/2` exactly — matches `sqnorm_phaseCos`, `sqnorm_phaseSin`.
* `⟪cos,sin⟫ = 0` to machine precision — matches `dot_phaseCos_phaseSin` (exact zero).
* `‖QR‖² = p − 1` — matches `sqnorm_qrFeat`.
* `|⟪QR,cos⟫| = √p` exactly, so the bound `qr_phase_gram_bound` is **attained**, not merely an
  upper estimate: the normalised coupling equals `√(2/(p−1))`.

## 2. The Gauss-sign dichotomy (found computationally, then proved)

Splitting the coupling into the two trigonometric channels:

| p | p mod 4 | k | ⟪QR,cos⟫ | ⟪QR,sin⟫ | √p |
|---|---------|---|----------|----------|-----|
| 7 | 3 | 1 | 0.000000 | 2.645751 | 2.645751 |
| 11 | 3 | 1 | 0.000000 | 3.316625 | 3.316625 |
| 19 | 3 | 3 | 0.000000 | −4.358899 | 4.358899 |
| 23 | 3 | 3 | 0.000000 | 4.795832 | 4.795832 |
| 13 | 1 | 1 | 3.605551 | 0.000000 | 3.605551 |
| 29 | 1 | 3 | −5.385165 | 0.000000 | 5.385165 |

The whole coupling sits in the sine channel when `p ≡ 3 (mod 4)` and in the cosine channel when
`p ≡ 1 (mod 4)`. This pattern was spotted here and is now the theorem pair
`dot_qrFeat_phaseCos_eq_zero_of_mod_four_eq_three` /
`dot_qrFeat_phaseSin_eq_zero_of_mod_four_eq_one`, proved from `gaussSum_sq` plus the value of
`χ(−1)`. Consequence: each prime block has **one** nonzero off-diagonal Gram entry, not two.

## 3. Ceiling arithmetic against the measured exp-482 numbers

| quantity | value | Lean theorem |
|----------|-------|--------------|
| per-block ceiling, `ε = 0.01`, `δ = 0.41`, `K = 3` | `3·0.01²/0.18 = 0.001667` | `phase_block_lift_ceiling` |
| nine prime blocks | `0.015` | `subthreshold_certificate` (`≤ 0.016`) |
| best phase-augmented score from base `0.600` | `0.600 + 0.016·0.400 = 0.6064` | `H3_unreachable_from_ceiling` (`< 0.70`) |
| measured lift `+0.008` as fraction of residual | `0.008/0.400 = 0.020` | `measured_lift_within_ceiling` (`ε = 0.0116`) |
| blocks needed to cover an excess `Δ = 0.2` at `ε = 0.01` | `120` | `prime_blocks_needed_measured` |
| sharp per-block ceiling (one coupled pair, `1 − δ = 0.59`) | `3·0.01²/0.59 = 0.000508` | `phase_block_lift_ceiling_sharp` |
| nine blocks, sharp constant | `0.0046` | `sharp_subthreshold_certificate` (`≤ 0.005`) |
| best phase-augmented score, sharp constant | `0.600 + 0.005·0.400 = 0.602` | `sharp_H3_unreachable` |
| coefficient miss certified by phase-only `R² = −0.077` | `√0.077 = 0.2775` | `phase_only_coefficient_miss` (`≥ 0.277`) |
| coefficient miss certified by `0.600 → 0.400` | `√0.2 = 0.4472` | `base_dial_transfer_deficit` (`≥ 0.447`) |

## 4. Counterexample hunt

* *Is the `√(2/(p−1))` bound ever violated?* Checked all odd primes `p ≤ 200`, frequencies
  `k = 1,…,p−1`: the normalised coupling equals `√(2/(p−1))` in every case (equality, never
  exceeded), consistent with `|gaussSum| = √p` being exact.
* *Could `⟪cos_k, cos_l⟫` be nonzero for `k ≠ ±l`?* Checked `p ≤ 101`, all pairs: zero to
  machine precision, as `dot_phaseCos_phaseCos` requires.
* *Is `1 − δ(K−1) > 0` really needed?* At `p = 3` the bound gives `δ = 1`, and
  `1 − 2δ = −1 < 0`: the crude diagonal-dominance route genuinely fails for the smallest
  primes. This is why `phase_block_lift_ceiling` is stated for `p ≥ 13` rather than all odd
  primes — an honest boundary, not an omission.

## 5. No OEIS entry

The sequences appearing here (`‖cos‖² = p/2`, `‖QR‖² = p − 1`, `|g| = √p`) are classical
character-sum values rather than new integer sequences, so no OEIS lookup applies.

## 6. Fourth/fifth cycle: exactness of the coupling and full-frequency degeneracy

**Exact coupling.** Evaluating `⟨QR, cos_k⟩` and `⟨QR, sin_k⟩` directly (floating point, `k = 1,2`)
against the predicted normalised value `δ = √(2/(p−1))`:

| p | p mod 4 | ⟨QR,cos₁⟩ | ⟨QR,sin₁⟩ | √p | normalised active channel | δ |
|---|---------|-----------|-----------|-----|---------------------------|---|
| 5 | 1 | 2.236068 | 0.000000 | 2.236068 | 0.707107 (cos) | 0.707107 |
| 7 | 3 | 0.000000 | 2.645751 | 2.645751 | 0.577350 (sin) | 0.577350 |
| 11 | 3 | 0.000000 | 3.316625 | 3.316625 | 0.447214 (sin) | 0.447214 |
| 13 | 1 | 3.605551 | 0.000000 | 3.605551 | 0.408248 (cos) | 0.408248 |
| 17 | 1 | 4.123106 | 0.000000 | 4.123106 | 0.353553 (cos) | 0.353553 |
| 19 | 3 | 0.000000 | 4.358899 | 4.358899 | 0.333333 (sin) | 0.333333 |
| 23 | 3 | 0.000000 | 4.795832 | 4.795832 | 0.301511 (sin) | 0.301511 |
| 29 | 1 | 5.385165 | 0.000000 | 5.385165 | 0.267261 (cos) | 0.267261 |
| 101 | 1 | 10.049876 | 0.000000 | 10.049876 | 0.141421 (cos) | 0.141421 |

The active-channel coupling equals `δ` in every case — the Gauss bound is *attained*, never
merely approached. This exploratory observation is now the theorem pair `qr_phaseSin_gram_exact` /
`qr_phaseCos_gram_exact`, and it is what makes `block_stability_constant_eq` an equality: the
restricted-isometry constant `1 − δ` is optimal, witnessed explicitly by `pair_witness`.

**Small primes.** With the sharp constant the ceiling needs only `δ < 1`, i.e. `p ≥ 5`:

| p | δ | 1 − δ | per-block ceiling at ε = 0.01 |
|---|---|-------|-------------------------------|
| 5 | 0.707107 | 0.292893 | 0.001024 |
| 7 | 0.577350 | 0.422650 | 0.000710 |
| 11 | 0.447214 | 0.552786 | 0.000543 |
| 13 | 0.408248 | 0.591752 | 0.000507 |
| 29 | 0.267261 | 0.732739 | 0.000409 |

Nine blocks at the worst constant (`p = 5`): `9·3·10⁻⁴/0.292 = 0.00925 ≤ 0.01`, hence a best
phase-augmented score `0.604 < 0.70` (`small_prime_subthreshold_certificate`,
`small_prime_H3_unreachable`) — the `H3` refutation no longer needs to exclude `p < 13`.

**Full-frequency degeneracy.** Summing the projections of `QR` onto all `(p−1)/2` half-period
phase pairs (exploratory floating-point evaluation):

| p | ‖QR‖² = p−1 | energy explained by the phase pairs | residual |
|---|-------------|-------------------------------------|----------|
| 5 | 4 | 4.000000000 | 0 |
| 7 | 6 | 6.000000000 | 0 |
| 11 | 10 | 10.000000000 | 0 |
| 13 | 12 | 12.000000000 | 0 |
| 17 | 16 | 16.000000000 | 0 |
| 19 | 18 | 18.000000000 | 0 |
| 29 | 28 | 28.000000000 | 0 |

The residual is zero, i.e. `QR` lies exactly in the phase span. This is now proved as
`qr_eq_combo_phaseDesign` (a Bessel equality: `2` units per frequency by `gain_qr_phase_pair`,
`(p−1)/2` frequencies by `card_halfFreq`), with the statistical corollary `qr_adds_no_capacity`.
