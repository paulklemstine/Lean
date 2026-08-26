import Mathlib

/-!
# What a maximal control `|z|` of `2.53` over `128` strata can and cannot say

Fourth component of the round-85 resolution.  The control arm reported, over
`128` moduli, per-`N` first-decile share `z`-scores with mean `−0.223`,
sd `0.945` and `absmax = 2.53`.  The claim entered in the ledger is
"controls clean".  This file proves the precise statement behind that claim and
— just as importantly — its limit.

* `Spike.Control.measure_exists_exceed_le` : the multiplicity-corrected
  (Bonferroni) union bound for a finite family of control statistics.
* `Spike.Control.measure_exists_exceed_le_subgaussian` : specialised to a
  sub-Gaussian null, `P(max_i |Z i| ≥ t) ≤ 2 m exp(−t²/2)`.
* `Spike.Control.bonferroni_bound_vacuous_at_2_53` : at `m = 128, t = 2.53`
  that bound *exceeds* `1`.  A maximal `|z|` of `2.53` over `128` strata is
  therefore entirely unremarkable — the correct reading of "controls clean" is
  the absence of an exceedance, not the presence of evidence for the null.
* `Spike.Control.threshold_gt_four` : any threshold that clears a `5 %`
  Bonferroni bar over `128` strata must exceed `4`; `2.53` is far below it.
* `Spike.Control.observed_absmax_below_threshold` : consequently no control
  stratum reaches significance.
-/

namespace Spike.Control

open MeasureTheory

section UnionBound

variable {Ω ι : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (S : Finset ι)

/-- **Multiplicity (Bonferroni) bound.**  If each of `m` control statistics
exceeds the threshold with probability at most `q`, then the probability that
*some* control exceeds it is at most `m q`. -/
theorem measure_exists_exceed_le (A : ι → Set Ω) (q : ENNReal)
    (h : ∀ i ∈ S, μ (A i) ≤ q) :
    μ (⋃ i ∈ S, A i) ≤ S.card * q := by
  refine le_trans (measure_biUnion_finset_le S A) ?_
  refine le_trans (Finset.sum_le_sum h) ?_
  simp [Finset.sum_const, nsmul_eq_mul]

/-- Sub-Gaussian specialisation: with `P(|Z i| ≥ t) ≤ 2 exp(−t²/2)` for each
control, the chance that any of the `m` controls reaches `t` is at most
`2 m exp(−t²/2)`. -/
theorem measure_exists_exceed_le_subgaussian (Z : ι → Ω → ℝ) (t : ℝ)
    (h : ∀ i ∈ S, μ {ω | t ≤ |Z i ω|} ≤ ENNReal.ofReal (2 * Real.exp (-t ^ 2 / 2))) :
    μ (⋃ i ∈ S, {ω | t ≤ |Z i ω|})
      ≤ S.card * ENNReal.ofReal (2 * Real.exp (-t ^ 2 / 2)) :=
  measure_exists_exceed_le μ S _ _ h

end UnionBound

/-! ### Numerics of the reported control arm -/

/-- `exp 8 < 2981`. -/
theorem exp_eight_lt : Real.exp 8 < 2981 := by
  have h1 : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
  have h0 : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
  have hpow : Real.exp 8 = Real.exp 1 ^ (8 : ℕ) := by
    rw [Real.exp_one_pow]; norm_num
  rw [hpow]
  calc Real.exp 1 ^ (8:ℕ) < 2.7182818286 ^ (8:ℕ) := by gcongr
    _ < 2981 := by norm_num

/-- `exp 4 < 55`. -/
theorem exp_four_lt : Real.exp 4 < 55 := by
  have h1 : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
  have h0 : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
  have hpow : Real.exp 4 = Real.exp 1 ^ (4 : ℕ) := by
    rw [Real.exp_one_pow]; norm_num
  rw [hpow]
  calc Real.exp 1 ^ (4:ℕ) < 2.7182818286 ^ (4:ℕ) := by gcongr
    _ < 55 := by norm_num

/-- **The observed maximum is uninformative.**  At `m = 128` controls and
`t = 2.53` the Bonferroni bound `2 m exp(−t²/2)` exceeds `1`: it does not
constrain the null at all.  "Controls clean" therefore means "no exceedance was
produced", not "the null was confirmed". -/
theorem bonferroni_bound_vacuous_at_2_53 :
    1 < 2 * 128 * Real.exp (-(2.53:ℝ) ^ 2 / 2) := by
  have hmono : Real.exp (-(2.53:ℝ) ^ 2 / 2) ≥ Real.exp (-4) := by
    apply Real.exp_le_exp.mpr
    norm_num
  have hexp : Real.exp (-4) = 1 / Real.exp 4 := by
    rw [Real.exp_neg]; ring
  have h4 : Real.exp 4 < 55 := exp_four_lt
  have hpos : 0 < Real.exp 4 := Real.exp_pos 4
  have : (1:ℝ) / 55 < 1 / Real.exp 4 := by
    apply one_div_lt_one_div_of_lt hpos h4
  have hge : Real.exp (-(2.53:ℝ) ^ 2 / 2) > 1 / 55 := by
    rw [hexp] at hmono
    linarith
  linarith

/-- **The Bonferroni threshold over `128` controls exceeds `4`.**  Any `t ≥ 0`
whose multiplicity-corrected tail bound clears the `5 %` bar satisfies `t > 4`.
The observed `absmax = 2.53` is far below. -/
theorem threshold_gt_four {t : ℝ} (ht : 0 ≤ t)
    (h : 2 * 128 * Real.exp (-t ^ 2 / 2) ≤ 0.05) : 4 < t := by
  by_contra hcon
  push_neg at hcon
  have hsq : t ^ 2 ≤ 16 := by nlinarith
  have hmono : Real.exp (-(8:ℝ)) ≤ Real.exp (-t ^ 2 / 2) := by
    apply Real.exp_le_exp.mpr
    linarith
  have hexp : Real.exp (-(8:ℝ)) = 1 / Real.exp 8 := by
    rw [Real.exp_neg]; ring
  have hpos : 0 < Real.exp 8 := Real.exp_pos 8
  have hlt : (1:ℝ) / 2981 < 1 / Real.exp 8 := one_div_lt_one_div_of_lt hpos exp_eight_lt
  have : (1:ℝ) / 2981 < Real.exp (-t ^ 2 / 2) := by
    rw [hexp] at hmono
    linarith
  nlinarith

/-- Consequently the reported control maximum does not reach the corrected
threshold: no control stratum is significant at the `5 %` Bonferroni level. -/
theorem observed_absmax_below_threshold {t : ℝ} (ht : 0 ≤ t)
    (h : 2 * 128 * Real.exp (-t ^ 2 / 2) ≤ 0.05) : (2.53 : ℝ) < t :=
  lt_trans (by norm_num) (threshold_gt_four ht h)

end Spike.Control