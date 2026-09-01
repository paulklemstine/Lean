import Mathlib
import Novelty.ZeroFitDialU76
import Novelty.TDialU100RangeShape
import Novelty.TDialU100EffectiveBaseDrift

/-!
# The floor-crossing forecast: where the effective-base drift predicts the band miss

## Research context (FACT round-67 #2, exp 540, cycle 4)

Cycle 3 (`Novelty.TDialU100EffectiveBaseDrift`) showed that the recorded erosion of the
zero-fit dial is quantitatively a *drift of the effective base*: the unique base consistent
with the bitlen-76 window is `7`, the unique base consistent with the bitlen-100 window is `9`,
and the ceiling gap `7/19 − 27/91` matches the recorded drop in `ρ²` to within `0.003`.

This cycle turns that description into a **falsifiable forecast** and checks it against the
recorded rungs.  The band floor is `ρ = 0.55`, i.e. `ρ² = 121/400`.  Extending the `p`-adic
ceiling `3p/(p²+p+1)` from integer bases to a real variable gives a strictly decreasing,
everywhere continuous profile `padicLimitR`, so there is a *unique* real base at which the
ceiling equals the band floor (`floor_crossing_exists_unique`), and it is bracketed by
`8.80 < t★ < 8.81` (`floor_crossing_bracket`).  Feeding `t★` through the linear drift
calibration `76 ↦ 7`, `100 ↦ 9` (`driftBitlenR`) predicts the first band miss at bitlen

  `97.6 < driftBitlenR t★ < 97.8`,

strictly inside the observed straddle window `(96, 100)`
(`floor_crossing_inside_observed_window`).  The forecast is sharp enough to be wrong: it
excludes a first miss at bitlen `96` or earlier and at bitlen `100` or later on the rung ladder
of step `4`, and the recorded data — last clean rung `96`, first band miss `100` — is exactly
what it predicts.

The mathematics here is a small analytic bridge: an arithmetic quantity indexed by integer
bases is interpolated to a real profile, continuity plus strict monotonicity supply existence
and uniqueness of the crossing (intermediate value theorem), and the arithmetic calibration
converts the crossing into a prediction about the experiment.
-/

open Set

namespace Catalog.Novelty.TDialU100FloorCrossingForecast

open Catalog.Novelty.ZeroFitDialU76
open Catalog.Novelty.TDialU100RangeShape
open Catalog.Novelty.TDialU100EffectiveBaseDrift

/-! ## 1. The real interpolation of the `p`-adic ceiling -/

/-- The `p`-adic ceiling `3p/(p²+p+1)` interpolated to a real base. -/
noncomputable def padicLimitR (t : ℝ) : ℝ := 3 * t / (t ^ 2 + t + 1)

lemma padicLimitR_denom_pos (t : ℝ) : 0 < t ^ 2 + t + 1 := by
  nlinarith [sq_nonneg (t + 1 / 2)]

/-- The interpolation agrees with the arithmetic ceiling at every integer base. -/
lemma padicLimitR_nat (p : ℕ) : padicLimitR (p : ℝ) = ((padicLimit p : ℚ) : ℝ) := by
  have h : ((p : ℝ) ^ 2 + (p : ℝ) + 1) ≠ 0 := ne_of_gt (padicLimitR_denom_pos _)
  rw [padicLimitR, padicLimit]
  push_cast
  ring

lemma padicLimitR_continuous : Continuous padicLimitR := by
  apply Continuous.div (by fun_prop) (by fun_prop)
  exact fun t => ne_of_gt (padicLimitR_denom_pos t)

/-- The interpolated ceiling is strictly decreasing for bases `≥ 1`. -/
theorem padicLimitR_strict_anti {s t : ℝ} (hs : 1 ≤ s) (hst : s < t) :
    padicLimitR t < padicLimitR s := by
  have h1 : (0 : ℝ) < s ^ 2 + s + 1 := padicLimitR_denom_pos s
  have h2 : (0 : ℝ) < t ^ 2 + t + 1 := padicLimitR_denom_pos t
  have hst1 : (1 : ℝ) < s * t := by nlinarith
  rw [padicLimitR, padicLimitR, div_lt_div_iff₀ h2 h1]
  nlinarith [mul_pos (sub_pos.2 hst) (sub_pos.2 hst1)]

/-! ## 2. The unique real base at the band floor -/

/-- The squared band floor, `0.55² = 121/400`. -/
lemma bandFloor_sq : ((bandFloor : ℚ) : ℝ) ^ 2 = 121 / 400 := by
  rw [bandFloor]
  norm_num

/-- **The band floor is met at exactly one real base.**  Existence comes from the intermediate
value theorem applied on `[8.80, 8.81]`, uniqueness from strict antitonicity. -/
theorem floor_crossing_exists_unique :
    ∃! t : ℝ, 1 ≤ t ∧ padicLimitR t = ((bandFloor : ℚ) : ℝ) ^ 2 := by
  rw [bandFloor_sq]
  have hab : (88 : ℝ) / 10 ≤ 881 / 100 := by norm_num
  have hcont : ContinuousOn padicLimitR (Icc ((88 : ℝ) / 10) (881 / 100)) :=
    padicLimitR_continuous.continuousOn
  have hlo : padicLimitR ((881 : ℝ) / 100) ≤ 121 / 400 := by
    rw [padicLimitR, div_le_div_iff₀ (padicLimitR_denom_pos _) (by norm_num)]
    norm_num
  have hhi : (121 : ℝ) / 400 ≤ padicLimitR ((88 : ℝ) / 10) := by
    rw [padicLimitR, le_div_iff₀ (padicLimitR_denom_pos _)]
    norm_num
  have hmem : (121 : ℝ) / 400 ∈ padicLimitR '' Icc ((88 : ℝ) / 10) (881 / 100) :=
    intermediate_value_Icc' hab hcont ⟨hlo, hhi⟩
  obtain ⟨t, ht, hval⟩ := hmem
  refine ⟨t, ⟨by linarith [ht.1], hval⟩, ?_⟩
  rintro u ⟨hu1, huval⟩
  have ht1 : (1 : ℝ) ≤ t := by linarith [ht.1]
  rcases lt_trichotomy u t with h | h | h
  · exact absurd (huval.trans hval.symm) (ne_of_gt (padicLimitR_strict_anti hu1 h))
  · exact h
  · exact absurd (hval.trans huval.symm) (ne_of_gt (padicLimitR_strict_anti ht1 h))

/-- **Bracket for the crossing base.**  Any base `≥ 1` whose ceiling equals the band floor lies
strictly between `8.80` and `8.81`. -/
theorem floor_crossing_bracket (t : ℝ) (ht : 1 ≤ t)
    (h : padicLimitR t = ((bandFloor : ℚ) : ℝ) ^ 2) : 88 / 10 < t ∧ t < 881 / 100 := by
  rw [bandFloor_sq] at h
  constructor
  · by_contra hcon
    push_neg at hcon
    have hlt : padicLimitR ((88 : ℝ) / 10) < padicLimitR t ∨ t = 88 / 10 := by
      rcases eq_or_lt_of_le hcon with h1 | h1
      · exact Or.inr h1
      · exact Or.inl (padicLimitR_strict_anti ht h1)
    rcases hlt with hlt | hlt
    · have : padicLimitR ((88 : ℝ) / 10) = 660 / 2181 := by
        rw [padicLimitR]; norm_num
      rw [this, h] at hlt
      norm_num at hlt
    · rw [hlt, padicLimitR] at h
      norm_num at h
  · by_contra hcon
    push_neg at hcon
    have h881 : (1 : ℝ) ≤ 881 / 100 := by norm_num
    have hle : padicLimitR t ≤ padicLimitR ((881 : ℝ) / 100) := by
      rcases eq_or_lt_of_le hcon with h1 | h1
      · exact le_of_eq (by rw [h1])
      · exact le_of_lt (padicLimitR_strict_anti h881 h1)
    have hval : padicLimitR ((881 : ℝ) / 100) = 264300 / 874261 := by
      rw [padicLimitR]; norm_num
    rw [h, hval] at hle
    norm_num at hle

/-! ## 3. The forecast -/

/-- The linear drift calibration: effective base `7` at bitlen `76`, base `9` at bitlen `100`,
i.e. one unit of effective base per twelve bitlens. -/
noncomputable def driftBitlenR (t : ℝ) : ℝ := 76 + 12 * (t - 7)

/-- The calibration reproduces the two measured effective bases. -/
theorem drift_calibration : driftBitlenR 7 = 76 ∧ driftBitlenR 9 = 100 := by
  constructor <;> · rw [driftBitlenR]; norm_num

/-- **The forecast.**  The drift model places the band-floor crossing between bitlen `97.6` and
bitlen `97.8`. -/
theorem floor_crossing_forecast (t : ℝ) (ht : 1 ≤ t)
    (h : padicLimitR t = ((bandFloor : ℚ) : ℝ) ^ 2) :
    976 / 10 < driftBitlenR t ∧ driftBitlenR t < 978 / 10 := by
  obtain ⟨h1, h2⟩ := floor_crossing_bracket t ht h
  rw [driftBitlenR]
  constructor <;> linarith

/-- **The forecast matches the experiment.**  The predicted crossing bitlen lies strictly inside
the observed straddle window: after bitlen `96` (last rung whose CI clears the floor from above
in the recorded ladder) and before bitlen `100` (first band miss).  On a rung ladder of step
`4` this is precisely the prediction "first miss at bitlen `100`". -/
theorem floor_crossing_inside_observed_window (t : ℝ) (ht : 1 ≤ t)
    (h : padicLimitR t = ((bandFloor : ℚ) : ℝ) ^ 2) :
    96 < driftBitlenR t ∧ driftBitlenR t < 100 := by
  obtain ⟨h1, h2⟩ := floor_crossing_forecast t ht h
  exact ⟨by linarith, by linarith⟩

/-- The crossing base is strictly between the two neighbouring integer bases `8` and `9`, so no
*integer* effective base ever sits exactly on the band floor: the dial's floor crossing is an
intrinsically non-arithmetic event in the effective-base coordinate. -/
theorem crossing_base_not_integral (t : ℝ) (ht : 1 ≤ t)
    (h : padicLimitR t = ((bandFloor : ℚ) : ℝ) ^ 2) : (8 : ℝ) < t ∧ t < 9 := by
  obtain ⟨h1, h2⟩ := floor_crossing_bracket t ht h
  exact ⟨by linarith, by linarith⟩

/-- The recorded pooled value at bitlen 100 lies below the floor, and its effective base `9`
lies above the crossing base: the two orderings agree, which is the consistency check the
forecast has to pass. -/
theorem forecast_orientation_consistent (t : ℝ) (ht : 1 ≤ t)
    (h : padicLimitR t = ((bandFloor : ℚ) : ℝ) ^ 2) :
    pooled100 < bandFloor ∧ t < 9 := by
  refine ⟨by norm_num [pooled100, bandFloor], (crossing_base_not_integral t ht h).2⟩

end Catalog.Novelty.TDialU100FloorCrossingForecast