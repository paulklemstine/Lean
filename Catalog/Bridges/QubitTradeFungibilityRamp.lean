/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# QUBIT-TRADE3: the fungibility ramp and its structural saturation cap

This file formalizes the *probabilistic* half of the "ramp survives contact with factors"
experiment. Measured data (paper 86) show that the per-instance probability of extracting a
factor from `s` independent period certificates behaves like an independence ladder
`1 - (1 - p)^s`, but that the ladder saturates strictly below `1`: the ceiling is a *per-`N`
structural cap*, namely the fraction of instances whose base plays mixed roles
(`Bridges.QubitTradeFactorExtraction`: `ControlledInstance.extractable_iff_mixed`).

The theorems below make that separation exact:

* `QubitTrade.ramp_compound` — samples compound exactly as independent trials;
* `QubitTrade.ramp_lt_cap`, `QubitTrade.tendsto_ramp` — the ladder never reaches, but converges
  to, the per-instance cap;
* `QubitTrade.popRamp_le_popCap`, `QubitTrade.tendsto_popRamp` — over a population, the ramp is
  monotone in the sample budget, is capped by the mixed-role share weighted by the certification
  rate, and attains that cap only in the limit;
* `QubitTrade.popCap_eq_certRate_mul_mixedFraction` — the measured saturation factorizes as
  `cert-rate × mixed-role fraction`;
* `QubitTrade.unlucky_population_popRamp_eq_zero` — the bridge to arithmetic: if no instance in
  the population is mixed, then the ramp is identically zero for every sample budget, and indeed
  no measurement outcome whatsoever extracts a factor.

## Main definitions

* `QubitTrade.ramp` — the capped independence ladder `c * (1 - (1 - p)^s)`.
* `QubitTrade.popRamp` — the population-averaged ramp over a finite instance set.
* `QubitTrade.popCap` — the population saturation cap.
-/

import Mathlib
import Bridges.QubitTradeFactorExtraction

namespace QubitTrade

open Filter Topology Finset

/-! ### The per-instance ladder -/

/-- The capped independence ladder: with per-sample success probability `pr` and per-instance
ceiling `c`, the probability of extracting a factor from `s` samples. -/
noncomputable def ramp (c pr : ℝ) (s : ℕ) : ℝ := c * (1 - (1 - pr) ^ s)

@[simp] lemma ramp_zero (c pr : ℝ) : ramp c pr 0 = 0 := by simp [ramp]

lemma ramp_one (c pr : ℝ) : ramp c pr 1 = c * pr := by simp [ramp]

/-- The exact gain from one extra sample. -/
lemma ramp_succ_sub (c pr : ℝ) (s : ℕ) :
    ramp c pr (s + 1) - ramp c pr s = c * pr * (1 - pr) ^ s := by
  simp only [ramp, pow_succ]
  ring

/-- **Samples compound as independence.** With unit ceiling the ladder satisfies the
inclusion–exclusion law of independent trials. -/
theorem ramp_compound (pr : ℝ) (s t : ℕ) :
    ramp 1 pr (s + t) = ramp 1 pr s + ramp 1 pr t - ramp 1 pr s * ramp 1 pr t := by
  simp only [ramp, pow_add]
  ring

lemma ramp_nonneg {c pr : ℝ} (hc : 0 ≤ c) (h0 : 0 ≤ pr) (h1 : pr ≤ 1) (s : ℕ) :
    0 ≤ ramp c pr s := by
  have h : (1 - pr) ^ s ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
  have := mul_nonneg hc (sub_nonneg.mpr h)
  simpa [ramp] using this

/-- The ladder never exceeds its ceiling. -/
theorem ramp_le_cap {c pr : ℝ} (hc : 0 ≤ c) (h1 : pr ≤ 1) (s : ℕ) :
    ramp c pr s ≤ c := by
  have hpow : 0 ≤ (1 - pr) ^ s := pow_nonneg (by linarith) s
  have : 0 ≤ c * (1 - pr) ^ s := mul_nonneg hc hpow
  simp only [ramp]
  nlinarith [this]

/-- **The cap is never attained.** For a nondegenerate per-sample probability `pr < 1`, no finite
sample budget reaches the per-instance ceiling. -/
theorem ramp_lt_cap {c pr : ℝ} (hc : 0 < c) (h1 : pr < 1) (s : ℕ) :
    ramp c pr s < c := by
  have hpow : 0 < (1 - pr) ^ s := pow_pos (by linarith) s
  have : 0 < c * (1 - pr) ^ s := mul_pos hc hpow
  simp only [ramp]
  nlinarith [this]

/-- The ramp is monotone in the sample budget. -/
theorem ramp_monotone {c pr : ℝ} (hc : 0 ≤ c) (h0 : 0 ≤ pr) (h1 : pr ≤ 1) :
    Monotone (ramp c pr) := by
  refine monotone_nat_of_le_succ fun s => ?_
  have hgain : 0 ≤ c * pr * (1 - pr) ^ s :=
    mul_nonneg (mul_nonneg hc h0) (pow_nonneg (by linarith) s)
  have := ramp_succ_sub c pr s
  linarith

/-- With a strictly positive, nondegenerate per-sample probability every extra sample strictly
helps. -/
theorem ramp_strictMono {c pr : ℝ} (hc : 0 < c) (h0 : 0 < pr) (h1 : pr < 1) :
    StrictMono (ramp c pr) := by
  refine strictMono_nat_of_lt_succ fun s => ?_
  have hgain : 0 < c * pr * (1 - pr) ^ s :=
    mul_pos (mul_pos hc h0) (pow_pos (by linarith) s)
  have := ramp_succ_sub c pr s
  linarith

/-- **Diminishing returns.** The gain from the `(s+1)`-st sample is at most the gain from the
`s`-th: the ladder is concave in the sample budget. -/
theorem ramp_gain_antitone {c pr : ℝ} (hc : 0 ≤ c) (h0 : 0 ≤ pr) (h1 : pr ≤ 1) (s : ℕ) :
    ramp c pr (s + 2) - ramp c pr (s + 1) ≤ ramp c pr (s + 1) - ramp c pr s := by
  rw [ramp_succ_sub c pr (s + 1), ramp_succ_sub c pr s, pow_succ]
  have hbase : 0 ≤ (1 - pr) ^ s := pow_nonneg (by linarith) s
  have hcp : 0 ≤ c * pr := mul_nonneg hc h0
  nlinarith [mul_nonneg hcp hbase]

/-- **Linear pricing of samples (union bound).** Small budgets buy success essentially linearly:
this is the regime the measured ramp lives in. -/
theorem ramp_le_union_bound {c pr : ℝ} (hc : 0 ≤ c) (h1 : pr ≤ 1) (s : ℕ) :
    ramp c pr s ≤ c * (s * pr) := by
  have hbern : 1 + (s : ℝ) * (-pr) ≤ (1 + -pr) ^ s :=
    one_add_mul_le_pow (by linarith) s
  have : 1 - (1 - pr) ^ s ≤ (s : ℝ) * pr := by
    have h' : (1 : ℝ) - (s : ℝ) * pr ≤ (1 - pr) ^ s := by
      have : (1 : ℝ) + -pr = 1 - pr := by ring
      rw [this] at hbern
      linarith [hbern]
    linarith
  calc ramp c pr s = c * (1 - (1 - pr) ^ s) := rfl
    _ ≤ c * ((s : ℝ) * pr) := by exact mul_le_mul_of_nonneg_left this hc

/-- The ladder converges to its ceiling: the cap is the supremum of what sampling can buy. -/
theorem tendsto_ramp {c pr : ℝ} (h0 : 0 < pr) (h1 : pr ≤ 1) :
    Tendsto (ramp c pr) atTop (𝓝 c) := by
  have hpow : Tendsto (fun s : ℕ => (1 - pr) ^ s) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by linarith) (by linarith)
  have : Tendsto (fun s : ℕ => c * (1 - (1 - pr) ^ s)) atTop (𝓝 (c * (1 - 0))) := by
    exact (tendsto_const_nhds.sub hpow).const_mul c
  simpa [ramp] using this

/-! ### The population ramp and its structural cap -/

section Population

variable {ι : Type*}

open scoped Classical in
/-- The population-averaged ramp: instances that cannot split (the unlucky half) contribute
nothing at any sample budget. -/
noncomputable def popRamp (P : Finset ι) (mixed : ι → Prop) (cap pr : ι → ℝ) (s : ℕ) : ℝ :=
  (∑ i ∈ P, if mixed i then ramp (cap i) (pr i) s else 0) / P.card

open scoped Classical in
/-- The population saturation cap: the average of the per-instance ceilings over the mixed-role
instances only. -/
noncomputable def popCap (P : Finset ι) (mixed : ι → Prop) (cap : ι → ℝ) : ℝ :=
  (∑ i ∈ P, if mixed i then cap i else 0) / P.card

/-- The mixed-role share of the population. -/
noncomputable def mixedFraction (P : Finset ι) (mixed : ι → Prop) : ℝ :=
  letI := Classical.decPred mixed
  ((P.filter mixed).card : ℝ) / P.card

variable {P : Finset ι} {mixed : ι → Prop} {cap pr : ι → ℝ}

/-- **The population ramp is capped.** No sample budget can push the population success rate past
the structural cap, because the unlucky instances never contribute. -/
theorem popRamp_le_popCap (hcap : ∀ i ∈ P, 0 ≤ cap i) (h1 : ∀ i ∈ P, pr i ≤ 1) (s : ℕ) :
    popRamp P mixed cap pr s ≤ popCap P mixed cap := by
  classical
  have hsum : (∑ i ∈ P, if mixed i then ramp (cap i) (pr i) s else 0)
      ≤ ∑ i ∈ P, if mixed i then cap i else 0 := by
    refine Finset.sum_le_sum fun i hi => ?_
    by_cases h : mixed i
    · simp only [h, if_true]
      exact ramp_le_cap (hcap i hi) (h1 i hi) s
    · simp [h]
  have hcard : (0 : ℝ) ≤ (P.card : ℝ) := by positivity
  exact div_le_div_of_nonneg_right hsum hcard

/-- The population ramp is monotone in the sample budget. -/
theorem popRamp_monotone (hcap : ∀ i ∈ P, 0 ≤ cap i) (h0 : ∀ i ∈ P, 0 ≤ pr i)
    (h1 : ∀ i ∈ P, pr i ≤ 1) :
    Monotone (popRamp P mixed cap pr) := by
  classical
  intro s t hst
  have hsum : (∑ i ∈ P, if mixed i then ramp (cap i) (pr i) s else 0)
      ≤ ∑ i ∈ P, if mixed i then ramp (cap i) (pr i) t else 0 := by
    refine Finset.sum_le_sum fun i hi => ?_
    by_cases h : mixed i
    · simp only [h, if_true]
      exact ramp_monotone (hcap i hi) (h0 i hi) (h1 i hi) hst
    · simp [h]
  have hcard : (0 : ℝ) ≤ (P.card : ℝ) := by positivity
  exact div_le_div_of_nonneg_right hsum hcard

/-- **The saturation value.** Increasing the sample budget drives the population success rate to
the structural cap and no further. -/
theorem tendsto_popRamp (h0 : ∀ i ∈ P, 0 < pr i) (h1 : ∀ i ∈ P, pr i ≤ 1) :
    Tendsto (popRamp P mixed cap pr) atTop (𝓝 (popCap P mixed cap)) := by
  classical
  have hsum : Tendsto (fun s : ℕ => ∑ i ∈ P, if mixed i then ramp (cap i) (pr i) s else 0)
      atTop (𝓝 (∑ i ∈ P, if mixed i then cap i else 0)) := by
    refine tendsto_finset_sum P fun i hi => ?_
    by_cases h : mixed i
    · simpa [h] using tendsto_ramp (c := cap i) (h0 i hi) (h1 i hi)
    · simp only [h, if_false]
      exact tendsto_const_nhds
  exact hsum.div_const _

/-- **The cap factorizes.** When every mixed instance shares the same certification ceiling `C`,
the saturation value is `C × (mixed-role fraction)` — the measured
`0.53 ≈ cert-rate × ⅔` decomposition. -/
theorem popCap_eq_certRate_mul_mixedFraction (C : ℝ) (hC : ∀ i ∈ P, cap i = C) :
    popCap P mixed cap = C * mixedFraction P mixed := by
  classical
  have h : (∑ i ∈ P, if mixed i then cap i else 0) = C * ((P.filter mixed).card : ℝ) := by
    rw [← Finset.sum_filter]
    rw [Finset.sum_congr rfl (fun i hi => hC i (Finset.mem_of_mem_filter i hi))]
    simp [mul_comm]
  rw [popCap, h, mixedFraction]
  ring

/-- **Strict subsaturation.** If even one mixed instance has a nondegenerate per-sample
probability and a positive ceiling, the population success rate stays strictly below the
structural cap at *every* finite sample budget: the cap is asymptotic, never attained. -/
theorem popRamp_lt_popCap (hcap : ∀ i ∈ P, 0 ≤ cap i) (h1 : ∀ i ∈ P, pr i ≤ 1)
    {i₀ : ι} (hi₀ : i₀ ∈ P) (hmix : mixed i₀) (hc₀ : 0 < cap i₀) (hpr₀ : pr i₀ < 1) (s : ℕ) :
    popRamp P mixed cap pr s < popCap P mixed cap := by
  classical
  have hsum : (∑ i ∈ P, if mixed i then ramp (cap i) (pr i) s else 0)
      < ∑ i ∈ P, if mixed i then cap i else 0 := by
    refine Finset.sum_lt_sum (fun i hi => ?_) ⟨i₀, hi₀, ?_⟩
    · by_cases h : mixed i
      · simp only [h, if_true]
        exact ramp_le_cap (hcap i hi) (h1 i hi) s
      · simp [h]
    · simp only [hmix, if_true]
      exact ramp_lt_cap hc₀ hpr₀ s
  have hcard : (0 : ℝ) < (P.card : ℝ) := by
    have : 0 < P.card := Finset.card_pos.mpr ⟨i₀, hi₀⟩
    exact_mod_cast this
  exact (div_lt_div_iff_of_pos_right hcard).mpr hsum

end Population

/-! ### Bridge: the cap is arithmetic, not statistical -/

section Bridge

variable {ι : Type*}

/-- **The unlucky population is permanently unlucky.** If no instance of the population has a
base playing mixed roles, then the ramp is identically zero at every sample budget, and this is
not an artefact of the model: by `ControlledInstance.extractable_iff_mixed` *no* measurement
outcome of *any* instance yields a factor. Sample count is powerless against the structural
cap. -/
theorem unlucky_population_popRamp_eq_zero (P : Finset ι) (inst : ι → ControlledInstance)
    (cap pr : ι → ℝ) (hno : ∀ i ∈ P, ¬ (inst i).Mixed) (s : ℕ) :
    popRamp P (fun i => (inst i).Mixed) cap pr s = 0 ∧
      ∀ i ∈ P, ∀ m : ℕ, (inst i).IsPeriodHalf m →
        ¬ SplitsAt (inst i).a (inst i).p (inst i).q m := by
  classical
  constructor
  · have : (∑ i ∈ P, if (inst i).Mixed then ramp (cap i) (pr i) s else 0) = 0 := by
      refine Finset.sum_eq_zero fun i hi => ?_
      simp [hno i hi]
    simp [popRamp, this]
  · intro i hi m hm hsplit
    exact hno i hi (((inst i).extractable_iff_mixed).mp ⟨m, hm, hsplit⟩)

/-- Conversely, every mixed instance really does admit an extracting certificate, so the
population cap is exactly the mixed-role share of the population: the ramp's ceiling is the
arithmetic dichotomy, not a statistical accident. -/
theorem mixed_population_extractable (P : Finset ι) (inst : ι → ControlledInstance)
    (hall : ∀ i ∈ P, (inst i).Mixed) :
    ∀ i ∈ P, ∃ m : ℕ, (inst i).IsPeriodHalf m ∧
      SplitsAt (inst i).a (inst i).p (inst i).q m :=
  fun i hi => ((inst i).extractable_iff_mixed).mpr (hall i hi)

end Bridge

end QubitTrade