/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Probability.TropicalSocialChoiceOligarchy

/-!
# Tropical social choice V: exponentially sharp Maslov dequantisation

`Probability.TropicalSocialChoice` proved the crude two-sided bound
`min y − log (#s)/t ≤ softMin s t y ≤ min y` for the Boltzmann aggregator
`softMin s t y = −(1/t) log ∑_{i ∈ s} exp (−t yᵢ)`, and
`Probability.TropicalSocialChoiceOligarchy` sharpened the upper bound to
`softMin s t y ≤ min y − log m / t`, where `m` is the number of *pivotal* (cost-minimising)
voters.

Conjecture 2 of `FUTURE_DIRECTIONS.md` asserted that `m`, not `#s`, controls **both** sides,
the remaining error being exponentially small in the gap `Δ` between the minimal cost and
the next one.  This file proves it.

## Main results

* `softMin_ge_of_gap` : if every non-pivotal member of the coalition has cost at least
  `min y + Δ`, then
  `min y − log m / t − (q/m)·e^{−tΔ}/t ≤ softMin s t y`, where `q = #(s \ pivotal)`.
* `softMin_sandwich_of_gap` : combining with the proved upper bound,
  `0 ≤ (min y − log m / t) − softMin s t y ≤ (q/m)·e^{−tΔ}/t`.
* `softMin_error_le_exp` : for `t ≥ 1` the error is at most `(#s)·e^{−tΔ}`, i.e. the
  conjectured form `C e^{−tΔ}` with `C` depending only on `#s`.
* `exists_gap` : the gap hypothesis is never vacuous — whenever some member of the
  coalition is not pivotal, a strictly positive `Δ` with that property exists.
* `softMin_eq_of_pivotal_eq_self` : when *all* members are pivotal the Boltzmann value is
  exactly `min y − log (#s)/t`, so the `log m / t` term of the upper bound cannot be
  improved.
* `softMin_tendsto_exp_error` : the rescaled error `e^{tΔ/2}·(error)` tends to `0`, the
  quantitative form of the zero-temperature limit.
-/

namespace TropicalSocialChoice

open Finset Filter

section Dequantisation

variable {ι : Type*} [DecidableEq ι]

/-- The gap hypothesis is satisfiable: if some coalition member is not pivotal, there is a
strictly positive `Δ` such that every non-pivotal member costs at least `min y + Δ`. -/
theorem exists_gap (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ)
    (hne : (s \ pivotal s hs y).Nonempty) :
    ∃ Δ : ℝ, 0 < Δ ∧ ∀ i ∈ s, i ∉ pivotal s hs y → s.inf' hs y + Δ ≤ y i := by
  classical
  refine ⟨(s \ pivotal s hs y).inf' hne y - s.inf' hs y, ?_, ?_⟩
  · obtain ⟨j, hj, hje⟩ := Finset.exists_mem_eq_inf' hne y
    have hjs : j ∈ s := (Finset.mem_sdiff.mp hj).1
    have hjP : j ∉ pivotal s hs y := (Finset.mem_sdiff.mp hj).2
    have hjne : y j ≠ s.inf' hs y := fun h =>
      hjP (Finset.mem_filter.mpr ⟨hjs, h⟩)
    have hjge : s.inf' hs y ≤ y j := Finset.inf'_le _ hjs
    have hlt : s.inf' hs y < y j := lt_of_le_of_ne hjge (Ne.symm hjne)
    rw [hje]
    linarith
  · intro i his hiP
    have : (s \ pivotal s hs y).inf' hne y ≤ y i :=
      Finset.inf'_le _ (Finset.mem_sdiff.mpr ⟨his, hiP⟩)
    linarith

/-- **Exponentially sharp lower bound.**  If every non-pivotal voter in `s` is at least `Δ`
worse than the best cost, the Boltzmann aggregator exceeds the pivotal-corrected tropical
value `min y − log m / t` by no more than `(q/m)·e^{−tΔ}/t`, where `m` is the number of
pivotal voters and `q` the number of the remaining ones. -/
theorem softMin_ge_of_gap (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {t Δ : ℝ} (ht : 0 < t)
    (hgap : ∀ i ∈ s, i ∉ pivotal s hs y → s.inf' hs y + Δ ≤ y i) :
    s.inf' hs y - Real.log (pivotal s hs y).card / t
        - ((s \ pivotal s hs y).card : ℝ) * Real.exp (-(t * Δ))
          / ((pivotal s hs y).card * t) ≤ softMin s t y := by
  classical
  set mu := s.inf' hs y with hmu
  set P := pivotal s hs y with hP
  have hPs : P ⊆ s := pivotal_subset s hs y
  have hPne : P.Nonempty := pivotal_nonempty s hs y
  set p : ℝ := (P.card : ℝ) with hp
  set q : ℝ := ((s \ P).card : ℝ) with hq
  set E : ℝ := Real.exp (-(t * Δ)) with hE
  set e : ℝ := Real.exp (-(t * mu)) with he
  have hppos : 0 < p := by
    rw [hp]; exact_mod_cast Finset.card_pos.mpr hPne
  have hepos : 0 < e := Real.exp_pos _
  have hEpos : 0 < E := Real.exp_pos _
  have hqnonneg : 0 ≤ q := by rw [hq]; positivity
  -- the pivotal part of the sum
  have h1 : ∑ i ∈ P, Real.exp (-(t * y i)) = p * e := by
    rw [Finset.sum_congr rfl fun i hi => by
      rw [show y i = mu from (Finset.mem_filter.mp hi).2]]
    simp [Finset.sum_const, nsmul_eq_mul, hp, he]
  -- the non-pivotal part is exponentially smaller
  have h2 : ∑ i ∈ s \ P, Real.exp (-(t * y i)) ≤ q * (e * E) := by
    have hterm : ∀ i ∈ s \ P, Real.exp (-(t * y i)) ≤ e * E := by
      intro i hi
      obtain ⟨his, hiP⟩ := Finset.mem_sdiff.mp hi
      have hy : mu + Δ ≤ y i := hgap i his hiP
      have : -(t * y i) ≤ -(t * mu) + -(t * Δ) := by nlinarith
      calc Real.exp (-(t * y i)) ≤ Real.exp (-(t * mu) + -(t * Δ)) := Real.exp_le_exp.mpr this
        _ = e * E := by rw [Real.exp_add]
    calc ∑ i ∈ s \ P, Real.exp (-(t * y i)) ≤ ∑ _i ∈ s \ P, e * E := Finset.sum_le_sum hterm
      _ = q * (e * E) := by simp [Finset.sum_const, nsmul_eq_mul, hq]
  have hsplit : ∑ i ∈ s \ P, Real.exp (-(t * y i)) + ∑ i ∈ P, Real.exp (-(t * y i))
      = ∑ i ∈ s, Real.exp (-(t * y i)) := Finset.sum_sdiff hPs
  have hSpos : 0 < ∑ i ∈ s, Real.exp (-(t * y i)) :=
    Finset.sum_pos (fun i _ => Real.exp_pos _) hs
  have hSle : ∑ i ∈ s, Real.exp (-(t * y i)) ≤ e * (p + q * E) := by
    rw [← hsplit, h1]
    nlinarith [h2]
  -- take logarithms
  have hfac : 0 < p + q * E := by positivity
  have hlogS : Real.log (∑ i ∈ s, Real.exp (-(t * y i))) ≤ -(t * mu) + Real.log (p + q * E) := by
    have h := Real.log_le_log hSpos hSle
    rwa [Real.log_mul (ne_of_gt hepos) (ne_of_gt hfac), he, Real.log_exp] at h
  have hlogfac : Real.log (p + q * E) ≤ Real.log p + q * E / p := by
    have hfac' : p + q * E = p * (1 + q * E / p) := by field_simp
    have hx : (0 : ℝ) < 1 + q * E / p := by positivity
    have := Real.log_le_sub_one_of_pos hx
    rw [hfac', Real.log_mul (ne_of_gt hppos) (ne_of_gt hx)]
    linarith
  have hlogtot : Real.log (∑ i ∈ s, Real.exp (-(t * y i)))
      ≤ -(t * mu) + Real.log p + q * E / p := by linarith
  have hinv : (0 : ℝ) ≤ 1 / t := by positivity
  have hmul := mul_le_mul_of_nonneg_left hlogtot hinv
  have hrewrite : (1 / t) * (-(t * mu) + Real.log p + q * E / p)
      = -mu + Real.log p / t + q * E / (p * t) := by
    field_simp
  rw [hrewrite] at hmul
  simp only [softMin]
  have : -(1 / t) * Real.log (∑ i ∈ s, Real.exp (-(t * y i)))
      = -((1 / t) * Real.log (∑ i ∈ s, Real.exp (-(t * y i)))) := by ring
  rw [this]
  linarith

/-- **Conjecture 2, proved.**  Two-sided exponentially sharp dequantisation: the Boltzmann
aggregator sits below the tropical value by exactly `log m / t`, up to an error that is
exponentially small in the cost gap. -/
theorem softMin_sandwich_of_gap (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {t Δ : ℝ}
    (ht : 0 < t) (hgap : ∀ i ∈ s, i ∉ pivotal s hs y → s.inf' hs y + Δ ≤ y i) :
    0 ≤ (s.inf' hs y - Real.log (pivotal s hs y).card / t) - softMin s t y ∧
      (s.inf' hs y - Real.log (pivotal s hs y).card / t) - softMin s t y
        ≤ ((s \ pivotal s hs y).card : ℝ) * Real.exp (-(t * Δ))
            / ((pivotal s hs y).card * t) := by
  have hup := softMin_le_sub_log_card_pivotal s hs y ht
  have hlow := softMin_ge_of_gap s hs y ht hgap
  exact ⟨by linarith, by linarith⟩

/-- The conjectured form of the error bound: for `t ≥ 1` the deviation of the Boltzmann
aggregator from the pivotal-corrected tropical value is at most `C e^{−tΔ}` with
`C = #s`, a constant depending only on the size of the coalition. -/
theorem softMin_error_le_exp (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {t Δ : ℝ}
    (ht : 1 ≤ t) (hgap : ∀ i ∈ s, i ∉ pivotal s hs y → s.inf' hs y + Δ ≤ y i) :
    (s.inf' hs y - Real.log (pivotal s hs y).card / t) - softMin s t y
      ≤ (s.card : ℝ) * Real.exp (-(t * Δ)) := by
  classical
  have ht0 : (0 : ℝ) < t := lt_of_lt_of_le zero_lt_one ht
  have hmain := (softMin_sandwich_of_gap s hs y ht0 hgap).2
  set P := pivotal s hs y with hP
  have hPne : P.Nonempty := pivotal_nonempty s hs y
  have hppos : (0 : ℝ) < (P.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hPne
  have hp1 : (1 : ℝ) ≤ (P.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hPne
  have hqs : ((s \ P).card : ℝ) ≤ (s.card : ℝ) := by
    exact_mod_cast Finset.card_le_card (Finset.sdiff_subset)
  have hEpos : (0 : ℝ) < Real.exp (-(t * Δ)) := Real.exp_pos _
  have hden : (1 : ℝ) ≤ (P.card : ℝ) * t := by nlinarith
  have hstep : ((s \ P).card : ℝ) * Real.exp (-(t * Δ)) / ((P.card : ℝ) * t)
      ≤ (s.card : ℝ) * Real.exp (-(t * Δ)) := by
    rw [div_le_iff₀ (by nlinarith : (0 : ℝ) < (P.card : ℝ) * t)]
    nlinarith [mul_nonneg (Nat.cast_nonneg (s.card)) hEpos.le]
  linarith

omit [DecidableEq ι] in
/-- When every member of the coalition is pivotal (all costs tie), the Boltzmann aggregator
is *exactly* `min y − log (#s) / t`; so the upper bound
`softMin ≤ min y − log m / t` is attained and cannot be improved. -/
theorem softMin_eq_of_pivotal_eq_self (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {t : ℝ}
    (ht : 0 < t) (hall : pivotal s hs y = s) :
    softMin s t y = s.inf' hs y - Real.log s.card / t := by
  classical
  have hy : ∀ i ∈ s, y i = s.inf' hs y := by
    intro i hi
    have : i ∈ pivotal s hs y := by rw [hall]; exact hi
    exact (Finset.mem_filter.mp this).2
  have hsum : ∑ i ∈ s, Real.exp (-(t * y i)) = (s.card : ℝ) * Real.exp (-(t * s.inf' hs y)) := by
    rw [Finset.sum_congr rfl fun i hi => by rw [hy i hi]]
    simp [Finset.sum_const, nsmul_eq_mul]
  have hcard : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hs
  rw [softMin, hsum, Real.log_mul (ne_of_gt hcard) (Real.exp_ne_zero _), Real.log_exp]
  field_simp
  ring

/-- The zero-temperature limit refined: the dequantisation error, magnified by
`e^{tΔ/2}`, still tends to `0`.  This is the exponential decay asserted by Conjecture 2. -/
theorem softMin_tendsto_exp_error (s : Finset ι) (hs : s.Nonempty) (y : ι → ℝ) {Δ : ℝ}
    (hΔ : 0 < Δ) (hgap : ∀ i ∈ s, i ∉ pivotal s hs y → s.inf' hs y + Δ ≤ y i) :
    Tendsto (fun t : ℝ => Real.exp (t * Δ / 2) *
        ((s.inf' hs y - Real.log (pivotal s hs y).card / t) - softMin s t y))
      atTop (nhds 0) := by
  classical
  have hmaj : Tendsto (fun t : ℝ => (s.card : ℝ) * Real.exp (-(t * Δ / 2))) atTop (nhds 0) := by
    have h0 : Tendsto (fun t : ℝ => t * (Δ / 2)) atTop atTop :=
      Filter.Tendsto.atTop_mul_const (by positivity) Filter.tendsto_id
    have h1 : Tendsto (fun t : ℝ => -(t * Δ / 2)) atTop atBot :=
      (Filter.tendsto_neg_atTop_atBot.comp h0).congr fun t => by
        simp [Function.comp, mul_div_assoc]
    have h2 := Real.tendsto_exp_atBot.comp h1
    simpa using h2.const_mul ((s.card : ℝ))
  refine squeeze_zero' ?_ ?_ hmaj
  · filter_upwards [eventually_ge_atTop (1 : ℝ)] with t ht
    have ht0 : (0 : ℝ) < t := lt_of_lt_of_le zero_lt_one ht
    have := (softMin_sandwich_of_gap s hs y ht0 hgap).1
    positivity
  · filter_upwards [eventually_ge_atTop (1 : ℝ)] with t ht
    have herr := softMin_error_le_exp s hs y ht hgap
    have hpos : (0 : ℝ) < Real.exp (t * Δ / 2) := Real.exp_pos _
    calc Real.exp (t * Δ / 2) *
          ((s.inf' hs y - Real.log (pivotal s hs y).card / t) - softMin s t y)
        ≤ Real.exp (t * Δ / 2) * ((s.card : ℝ) * Real.exp (-(t * Δ))) := by
          exact mul_le_mul_of_nonneg_left herr hpos.le
      _ = (s.card : ℝ) * Real.exp (-(t * Δ / 2)) := by
          rw [show -(t * Δ) = -(t * Δ / 2) + -(t * Δ / 2) by ring, Real.exp_add]
          rw [show t * Δ / 2 = -(-(t * Δ / 2)) by ring, Real.exp_neg]
          field_simp

end Dequantisation

end TropicalSocialChoice