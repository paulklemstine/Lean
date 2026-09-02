# Computational evidence — EXTENDED-DIAL-ABSENT (round-51 #1, exp 515)

All numbers below are exact rationals; every one of them is re-derived inside Lean by
`norm_num` in `Catalog/Combinatorics/ExtendedDial*.lean`, so this file is a *record of the
search*, not the verification. Verification is the Lean build (0 sorries, axioms
`propext, Classical.choice, Quot.sound` only).

## 1. The recorded readings

Per-seed `R²(augmented)` at `u = 3.5`, seeds 20261060–64:

| seed | R² | ≥ 0.55? |
|---|---|---|
| 20261060 | 0.490 | no |
| 20261061 | 0.555 | **yes** |
| 20261062 | 0.428 | no |
| 20261063 | 0.532 | no |
| 20261064 | 0.508 | no |

Mean `= 2513/5000 = 0.5026 < 0.55`; exactly `1/5` clear the target
(`observed_mean`, `observed_exactly_one_above_target`).

Binomial tail check for the "≥ 80% of populations clear the target" hypothesis:
`P[X ≤ 1] = (1−q)^5 + 5q(1−q)^4 = 5t^4 − 4t^5` with `t = 1−q ≤ 1/5`, which is increasing in
`t`, hence `≤ 21/3125 ≈ 0.00672` (`replication_tail_bound`). The recorded 1/5 therefore
rejects an 80% replication rate at the 0.7% level.

## 2. Small-case search for a non-replication pair

Population template: four keys, uniform draws, footprint `w = (1,2,3,4)`, prime-power
indicator `pp = (1,1,0,0)`. Rate profiles are `y = w + r` with `r` in the two-dimensional
space orthogonal (weighted) to `1` and `w`, spanned by `s = (1,−1,−1,1)` and
`u = (1,−3,3,−1)`. Writing `r = αs + βu`:

* `‖r‖²_p = α² + 5β²` and `⟨r, pp⟩_p = −β/2`.

Rational points on `α² + 5β² = 1` give equal-energy residuals with different `⟨r, pp⟩`:

| (α, β) | r | ⟨r,pp⟩ | raw gain | base R² |
|---|---|---|---|---|
| (2/7, 3/7) | (5/7, −11/7, 1, −1/7) | −3/14 | 9/98 | 5/9 |
| (1, 0) | (1, −1, −1, 1) | 0 | 0 | 5/9 |

So populations **A** and **B** share the base variance share `5/9` exactly, and differ in
the prime-power increment: raw `ΔR² = 2/49 ≈ 0.041` vs `0`; partialled (true multiple-`R²`)
increment `20/49 ≈ 0.408` vs `0`. Partialled feature: `p̃p = (−1/10, 3/10, −3/10, 1/10)`,
`‖p̃p‖² = 1/20`.

## 3. Marginal-vs-incremental search

Requirement: `pp` comonotone with the rate (so its marginal dial is positive in *every*
draw regime) while `⟨r, pp⟩ = 0`. Solving `r = (s, −s, t, −t)`, `y = w₂ + r`,
`⟨r, w₂⟩ = s − 2s² + t − 2t² = 0` gives `s = 1/2, t = 0`:

* `w₂ = (7/2, 7/2, 1, 0)`, `y₂ = (4, 3, 1, 0)`, `r₂ = (1/2, −1/2, 0, 0)`,
* base `R²(w₂, y₂) = 19/20 < 1` (model not saturated), residual energy `1/8 > 0`,
* `Cov(pp, y₂) = 3/4 > 0` and `pp`, `y₂` comonotone, yet `ΔR²(pp) = 0` exactly.

## 4. Suppression pair (identical marginals, opposite increments)

Same `w`, `pp`; slope `b = 1/10`; residuals `r_B = (3/5)s` and `r_C = (2/5)s − (1/5)u`,
which have **equal** energy `9/25`:

| | σ_xy | σ_yy | σ_zy | R²(w,y) | R²(pp,y) | ΔR²(pp) |
|---|---|---|---|---|---|---|
| B | 1/8 | 149/400 | −1/20 | 5/149 | 4/149 | **0** |
| C | 1/8 | 149/400 | +1/20 | 5/149 | 4/149 | **80/149 ≈ 0.537** |

Every marginal reading coincides; only the sign of `σ_zy` differs. `B` sits exactly on the
absence quadric `σ_zy·σ_xx = σ_xy·σ_xz` (`−1/20 · 5/4 = 1/8 · (−1/2)`), `C` does not.

## 5. Counterexample hunt against the general claims

* *Is the increment determined by the marginal `R²` triple?* No — item 4 is the
  counterexample, and `increment_determined_by_moments` shows the correct sufficient
  statistic is the signed second-moment vector `(σ_xx, σ_xy, σ_xz, σ_zy, σ_zz)`.
* *Can regime re-weighting create the increment?* No: `gain_le_of_nearby_zero_regime`
  bounds it by `(M·‖p−q‖₁)²/‖z‖²`; a search over unbalanced regimes `(0.7,0.1,0.1,0.1)` on
  population B confirmed the numerator stays small.
* *Is `ΔR²(pp) = 0` an artefact of measuring the raw gain?* No — the partialled statistic
  gives the same zero (`extended_dial_nonreplication_partial`, `pp_partial_incremental_absent`).
* *Attenuation:* with noise-to-signal `ρ = Var u / Var x`, slope `= 1/(1+ρ)`; the reported
  `0.898` corresponds to `ρ ≈ 0.1136`, inside the proved band `[5/6, 1)` for `ρ ≤ 1/5`.

## 6. No OEIS sequence

No integer sequence arises: the objects here are rational second-moment vectors of
four-key populations, not a counting sequence, so an OEIS lookup is not applicable.
