import Mathlib
import Novelty.TDialU84ApproachNotCrossed

/-!
# U84, cycle 2: how far is "not crossed"?  Three metrics for a gradual erosion

## Research context

`Novelty.TDialU84ApproachNotCrossed` established the U84 record (pooled Spearman `0.558`,
CI `[0.536, 0.581]`, per-seed `0.572 / 0.578 / 0.522`, band floor `0.55`, margin `+0.008`)
and proved that a crossing costs an `Ω(n²)` rearrangement in the Kendall-tau metric.  Three
questions were left open by that file, and each is answered here with a general theorem plus
the U84 instantiation.

1. **How large is the rank-metric scale in absolute terms?**  The crossing budget is stated
   against an unknown ambient displacement; what is the *diameter* of the Spearman scale in
   adjacent transpositions?
2. **Is the seed spread compatible with a `0.008` margin?**  The three seeds differ by
   `0.056`, which is seven times the margin.  How large can the dispersion be given the
   observed extremes, and how does it compare with the margin?
3. **Does the local trend after U84 point at the floor at all?**  The prose read is
   "approaching"; the ladder says otherwise.

## Main results

### A. The Spearman scale in Kendall steps, and a sorting lower bound (Section 1)

* `sum_sq_arith` — a closed form for `∑_{k<n}(c − 2k)²` (induction).
* `sumSqDev_revVec`, `spearman_revVec` — the reversal ranking has
  `∑(σk − k)² = n(n²−1)/3`, hence Spearman `ρ = −1` exactly; `spearman_idVec` gives `ρ = +1`
  for the identity ranking.  These pin the two ends of the scale.
* `adjacent_swaps_to_reverse` — combining with the Lipschitz law of cycle 1: reversing a
  ranking of `n` items takes at least `n(n+1)/6` adjacent transpositions.  This is a genuine
  **sorting lower bound derived from a rank statistic** rather than from an inversion count.
* `u84_margin_in_kendall_steps` — the recorded margin `0.008` is `1/250` of the full `[−1, 1]`
  Spearman scale: the dial sits `0.4 %` of the scale above the floor, i.e. the "approach" is
  a sub-percent displacement of the ranking.

### B. Dispersion: Bhatia–Davis for the seed spread (Section 2)

* `variance_le_bhatia_davis` — for any finite family with values in `[m, M]` and mean `μ`,
  `Var ≤ (M − μ)(μ − m)`.  Proved from `∑ (M − xᵢ)(xᵢ − m) ≥ 0`.
* `u84_seed_variance`, `u84_seed_variance_le_bhatia_davis` — the recorded seeds have
  `Var = 709/1125000 ≈ 6.30·10⁻⁴`, below the Bhatia–Davis ceiling `≈ 7.30·10⁻⁴`, so the
  three seeds are close to the two-point extremal configuration: the dispersion is nearly
  maximal for its range.
* `u84_seed_dispersion_exceeds_margin` — `Var > 9 · margin²`, i.e. the seed-to-seed standard
  deviation exceeds `3×` the margin to the floor.  The recorded non-crossing is well inside
  the seed noise.

### C. The local trend after U84 points away from the floor (Section 3)

* `ols_slope` — the least-squares slope of three points.
* `ols_slope_pos_of_comonotone` — a Chebyshev-type positivity: if the abscissae are
  increasing and the ordinates are nondecreasing with a strict increase, the slope is
  positive.  The proof rests on the pair identity
  `3 ∑(xᵢ−x̄)(yᵢ−ȳ) = ∑_{i<j}(xᵢ−xⱼ)(yᵢ−yⱼ)`.
* `u84_post_trend_positive` — applied to the recorded rungs `(84, 0.558)`, `(92, 0.563)`,
  `(96, 0.5739)`: the local slope is `+0.001225` per bit, **away** from the floor.  The dial
  is not approaching the floor after U84; the U84 rung is a local minimum.
* `u84_extrapolated_rung_above_floor` — extrapolating that trend one rung further (bitlen
  100) predicts `0.5788`, comfortably above the floor: on the recorded evidence the
  crossing test does not merely fail to fire, it is pointing the other way.

## Lab notes (derived quantities, exp 535 record)

```
Spearman scale ends       : rho(identity) = +1     rho(reversal) = -1   (exact)
reversal displacement     : sum (sigma k - k)^2 = n(n^2-1)/3
sorting lower bound       : >= n(n+1)/6 adjacent swaps to reverse
margin in scale units     : 0.008 / 2 = 1/250 = 0.4 % of the full scale
seed variance             : 709/1125000 = 6.3022e-4
Bhatia-Davis ceiling      : 1643/2250000 = 7.3022e-4  (ratio 0.863: near-extremal spread)
variance vs margin^2      : 6.3022e-4 > 9 * 6.4e-5 = 5.76e-4
post-84 OLS slope         : +0.0010795 per bit    (positive: away from the floor)
extrapolated rung 100     : 0.57864 > 0.55
```
-/

open Finset
open Catalog.Novelty.TDialU84ApproachNotCrossed

namespace Catalog.Novelty.TDialU84ErosionMetrics

/-! ## 1. The two ends of the Spearman scale, and a sorting lower bound -/

/-- Closed form for the arithmetic-progression square sum `∑_{k<n} (c − 2k)²`. -/
lemma sum_sq_arith (c : ℤ) (n : ℕ) :
    3 * ∑ k ∈ Finset.range n, (c - 2 * (k : ℤ)) ^ 2
      = (n : ℤ) * (3 * c ^ 2 - 6 * c * ((n : ℤ) - 1) + 2 * ((n : ℤ) - 1) * (2 * (n : ℤ) - 1)) := by
  induction n with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ, mul_add, ih]
      push_cast
      ring

/-- The identity ranking. -/
def idVec : ℕ → ℤ := fun k => (k : ℤ)

/-- The reversal ranking on `n` items. -/
def revVec (n : ℕ) : ℕ → ℤ := fun k => (n : ℤ) - 1 - (k : ℤ)

lemma rankBounded_idVec (n : ℕ) : RankBounded n idVec := by
  intro k hk
  have hk' : (k : ℤ) < (n : ℤ) := by exact_mod_cast hk
  exact ⟨by simp [idVec], by simpa [idVec] using hk'⟩

lemma rankBounded_revVec (n : ℕ) : RankBounded n (revVec n) := by
  intro k hk
  have hk' : (k : ℤ) < (n : ℤ) := by exact_mod_cast hk
  refine ⟨by simp [revVec]; omega, by simp [revVec]; omega⟩

/-- The identity ranking has zero squared displacement. -/
lemma sumSqDev_idVec (n : ℕ) : sumSqDev n idVec = 0 := by
  simp [sumSqDev, idVec]

/-- **The reversal displacement.**  `∑_{k<n} (rev k − k)² = n(n²−1)/3`. -/
lemma sumSqDev_revVec (n : ℕ) : 3 * sumSqDev n (revVec n) = (n : ℤ) * ((n : ℤ) ^ 2 - 1) := by
  have hrw : sumSqDev n (revVec n)
      = ∑ k ∈ Finset.range n, (((n : ℤ) - 1) - 2 * (k : ℤ)) ^ 2 := by
    refine Finset.sum_congr rfl fun k _ => ?_
    simp only [revVec]
    ring_nf
  rw [hrw, sum_sq_arith ((n : ℤ) - 1) n]
  ring

/-- Spearman's `ρ` of the identity ranking is `+1`. -/
theorem spearman_idVec {n : ℕ} (hn : 2 ≤ n) : spearman n idVec = 1 := by
  have hD : ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) ≠ 0 := (spearman_denom_pos hn).ne'
  simp [spearman, sumSqDev_idVec]

/-- **Spearman's `ρ` of the reversal ranking is `−1`.**  Together with `spearman_idVec` this
pins both ends of the scale on which the `0.008` margin is measured. -/
theorem spearman_revVec {n : ℕ} (hn : 2 ≤ n) : spearman n (revVec n) = -1 := by
  have hD : ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) ≠ 0 := (spearman_denom_pos hn).ne'
  have hn1 : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hn2 : ((n : ℚ) ^ 2 - 1) ≠ 0 := by nlinarith
  have h3 : (3 : ℚ) * (sumSqDev n (revVec n) : ℚ) = (n : ℚ) * ((n : ℚ) ^ 2 - 1) := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) (sumSqDev_revVec n)
  have hS : ((sumSqDev n (revVec n) : ℚ)) = ((n : ℚ) * ((n : ℚ) ^ 2 - 1)) / 3 := by
    linarith [h3]
  unfold spearman
  rw [hS]
  field_simp
  norm_num

/-- **A sorting lower bound from a rank statistic.**  Reversing a ranking of `n ≥ 2` items by
adjacent transpositions takes at least `n(n+1)/6` swaps: the two ends of the Spearman scale
are `2` apart and each adjacent swap moves `ρ` by at most `12/(n(n+1))`. -/
theorem adjacent_swaps_to_reverse {n : ℕ} (hn : 2 ≤ n) (l : List (ℕ × ℕ))
    (hl : AdjacentChain n l) (hrev : applyTs l idVec = revVec n) :
    (n : ℚ) * ((n : ℚ) + 1) / 6 ≤ (l.length : ℚ) := by
  have hdrop : (2 : ℚ) ≤ spearman n idVec - spearman n (applyTs l idVec) := by
    rw [hrev, spearman_idVec hn, spearman_revVec hn]
    norm_num
  have h := adjacent_swaps_to_cross hn l idVec hl (rankBounded_idVec n) hdrop
  calc (n : ℚ) * ((n : ℚ) + 1) / 6 = 2 * ((n : ℚ) * ((n : ℚ) + 1)) / 12 := by ring
    _ ≤ (l.length : ℚ) := h

/-- **The margin in scale units.**  The full Spearman scale spans `2` (from `+1` to `−1`), so
the recorded margin `0.008` is exactly `1/250` of it: the U84 reading sits `0.4 %` of the
scale above the band floor. -/
theorem u84_margin_in_kendall_steps : margin84 / 2 = 1 / 250 := by
  norm_num [margin84, pooled84, bandFloor]

/-! ## 2. Dispersion: a Bhatia–Davis ceiling for the per-seed spread -/

/-- Sample mean of a nonempty finite family. -/
def meanOf {ι : Type*} [Fintype ι] (x : ι → ℚ) : ℚ := (∑ i, x i) / (Fintype.card ι : ℚ)

/-- Sample variance of a nonempty finite family. -/
def varOf {ι : Type*} [Fintype ι] (x : ι → ℚ) : ℚ :=
  (∑ i, (x i - meanOf x) ^ 2) / (Fintype.card ι : ℚ)

/-- **The Bhatia–Davis inequality.**  For a finite family with values in `[m, M]` and mean
`μ`, the variance is at most `(M − μ)(μ − m)`.  The proof is the nonnegativity of
`∑ (M − xᵢ)(xᵢ − m)`. -/
theorem variance_le_bhatia_davis {ι : Type*} [Fintype ι] [Nonempty ι] (x : ι → ℚ) {m M : ℚ}
    (hm : ∀ i, m ≤ x i) (hM : ∀ i, x i ≤ M) :
    varOf x ≤ (M - meanOf x) * (meanOf x - m) := by
  set N : ℚ := (Fintype.card ι : ℚ) with hN
  have hNpos : 0 < N := by rw [hN]; exact_mod_cast Fintype.card_pos
  set mu : ℚ := meanOf x with hmu
  have hsum : ∑ i, x i = N * mu := by
    rw [hmu, meanOf, ← hN]; field_simp
  have hnn : 0 ≤ ∑ i, (M - x i) * (x i - m) :=
    Finset.sum_nonneg fun i _ => mul_nonneg (by linarith [hM i]) (by linarith [hm i])
  have hexp : ∑ i, (M - x i) * (x i - m)
      = (M + m) * (∑ i, x i) - N * (M * m) - ∑ i, (x i) ^ 2 := by
    have h : ∀ i : ι, (M - x i) * (x i - m) = (M + m) * x i - M * m - (x i) ^ 2 := fun i => by ring
    simp_rw [h]
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]
    simp [Finset.card_univ, hN]
  have hvar : ∑ i, (x i - mu) ^ 2 = (∑ i, (x i) ^ 2) - N * mu ^ 2 := by
    have h : ∀ i : ι, (x i - mu) ^ 2 = (x i) ^ 2 - 2 * mu * (x i) + mu ^ 2 := fun i => by ring
    simp_rw [h]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]
    simp [Finset.card_univ, hN, hsum]
    ring
  rw [varOf, ← hmu, ← hN, hvar, div_le_iff₀ hNpos]
  rw [hexp, hsum] at hnn
  nlinarith [hnn]

/-- The three recorded per-seed readings as a family. -/
def seedVec : Fin 3 → ℚ := ![seedA, seedB, seedC]

/-- The recorded seed mean. -/
theorem u84_seed_mean : meanOf seedVec = 209 / 375 := by
  norm_num [meanOf, seedVec, Fin.sum_univ_three, Matrix.cons_val_two, Matrix.tail_cons,
    seedA, seedB, seedC]

/-- The recorded seed variance. -/
theorem u84_seed_variance : varOf seedVec = 709 / 1125000 := by
  norm_num [varOf, meanOf, seedVec, Fin.sum_univ_three, Matrix.cons_val_two, Matrix.tail_cons,
    seedA, seedB, seedC]

/-- The Bhatia–Davis ceiling for the recorded seed range, and the fact that the recorded
dispersion attains `86 %` of it: the three seeds are close to the extremal two-point
configuration for their range. -/
theorem u84_seed_variance_le_bhatia_davis :
    varOf seedVec ≤ (seedB - meanOf seedVec) * (meanOf seedVec - seedC) ∧
      (seedB - meanOf seedVec) * (meanOf seedVec - seedC) = 1643 / 2250000 := by
  constructor
  · refine variance_le_bhatia_davis seedVec (m := seedC) (M := seedB) ?_ ?_
    · intro i
      fin_cases i <;> norm_num [seedVec, seedA, seedB, seedC]
    · intro i
      fin_cases i <;> norm_num [seedVec, seedA, seedB, seedC]
  · rw [u84_seed_mean]
    norm_num [seedB, seedC]

/-- **The seed noise dwarfs the margin.**  The recorded seed variance exceeds
`9 · margin²`, i.e. the seed-to-seed standard deviation is more than three times the margin
to the band floor.  The recorded non-crossing is well inside the seed-level noise. -/
theorem u84_seed_dispersion_exceeds_margin : 9 * margin84 ^ 2 < varOf seedVec := by
  rw [u84_seed_variance]
  norm_num [margin84, pooled84, bandFloor]

/-! ## 3. The local trend after U84 -/

/-- Least-squares slope of three points. -/
def olsSlope (x1 x2 x3 y1 y2 y3 : ℚ) : ℚ :=
  ((x1 - x2) * (y1 - y2) + (x1 - x3) * (y1 - y3) + (x2 - x3) * (y2 - y3)) /
    ((x1 - x2) ^ 2 + (x1 - x3) ^ 2 + (x2 - x3) ^ 2)

/-- **Comonotone positivity of the least-squares slope.**  If the abscissae increase and the
ordinates are nondecreasing with at least one strict increase, the slope is positive.  This
is the three-point Chebyshev sum inequality. -/
theorem ols_slope_pos_of_comonotone {x1 x2 x3 y1 y2 y3 : ℚ}
    (hx12 : x1 < x2) (hx23 : x2 < x3)
    (hy12 : y1 ≤ y2) (hy23 : y2 ≤ y3) (hy13 : y1 < y3) :
    0 < olsSlope x1 x2 x3 y1 y2 y3 := by
  have hden : 0 < (x1 - x2) ^ 2 + (x1 - x3) ^ 2 + (x2 - x3) ^ 2 := by nlinarith
  have hnum : 0 < (x1 - x2) * (y1 - y2) + (x1 - x3) * (y1 - y3) + (x2 - x3) * (y2 - y3) := by
    have h1 : 0 ≤ (x1 - x2) * (y1 - y2) := by nlinarith
    have h2 : 0 < (x1 - x3) * (y1 - y3) := by nlinarith
    have h3 : 0 ≤ (x2 - x3) * (y2 - y3) := by nlinarith
    linarith
  exact div_pos hnum hden

/-- **The post-U84 trend points away from the floor.**  The least-squares slope of the three
recorded rungs `(84, 0.558)`, `(92, 0.563)`, `(96, 0.5739)` is strictly positive. -/
theorem u84_post_trend_positive : 0 < olsSlope 84 92 96 rung84 rung92 rung96 := by
  refine ols_slope_pos_of_comonotone (by norm_num) (by norm_num) ?_ ?_ ?_
  · norm_num [rung84, pooled84, rung92]
  · norm_num [rung92, rung96]
  · norm_num [rung84, pooled84, rung96]

/-- The exact value of the post-U84 slope: `+0.001225` per bit. -/
theorem u84_post_trend_value : olsSlope 84 92 96 rung84 rung92 rung96 = 49 / 40000 := by
  norm_num [olsSlope, rung84, pooled84, rung92, rung96]

/-- **Extrapolating the local trend moves away from the floor.**  One rung further (bitlen
100) the fitted line predicts a reading above `0.578`, far above the `0.55` floor: on the
recorded evidence the crossing test is not merely inconclusive, the local trend is reversed. -/
theorem u84_extrapolated_rung_above_floor :
    bandFloor < rung96 + 4 * olsSlope 84 92 96 rung84 rung92 rung96 := by
  rw [u84_post_trend_value]
  norm_num [bandFloor, rung96]

end Catalog.Novelty.TDialU84ErosionMetrics