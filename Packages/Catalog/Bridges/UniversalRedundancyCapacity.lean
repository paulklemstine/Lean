/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IV: the exact redundancy–capacity theorem

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1:
**one shared decompressor must serve all inputs**.

Earlier files of the thread settle two halves of the picture.

* `MachineLearning.UniversalRedundancy.Core` computes the **worst-case pointwise**
  price of universality exactly: it is `log₂ Cₛ`, the logarithm of the Shtarkov
  sum.
* `NumberTheory.UniversalRedundancyAverage` develops the **average-case (Bayes)**
  theory and proves one half of the classical picture: for *every* prior `w`
  the minimax average redundancy is at least the mutual information `I(w)`
  (the Gallager–Davisson lower bound).

What was missing is the *converse*: is the supremum of `I(w)` over priors — the
**channel capacity of the source class** — actually achieved by a single
universal code?  This file proves that it is, i.e. the **redundancy–capacity
theorem** in exact (non-asymptotic) form:

`min_q max_θ D(p_θ ‖ q) = max_w I(w) = C`.

## Method

The saddle point is obtained without any minimax theorem, by an elementary
perturbation argument that is fully constructive in spirit:

* the map `w ↦ I(w) = H(m_w) − ∑ w_θ H(p_θ)` is continuous on the compact
  standard simplex (`continuous_mutualInfo`, `mutualInfo_eq_entropy_sub`), so a
  maximising prior `w*` exists (`exists_maxOn_mutualInfo`);
* moving the prior towards a single source, `w_t = (1−t) w* + t δ_θ`, and
  feeding the *compensation identity* of the previous file with the old mixture
  as coding distribution, gives `t (D(p_θ‖m*) − C) ≤ D(m_t ‖ m*)`;
* the χ²-bound `D(a‖b) ≤ χ²(a‖b)/ln 2` (`klDiv_le_chiSq`) makes the right-hand
  side `O(t²)`, so letting `t → 0` yields `D(p_θ ‖ m*) ≤ C` for *every* `θ`.

## Main results

* `klDiv_le_chiSq` — the χ² upper bound on Kullback–Leibler divergence
* `mutualInfo_eq_entropy_sub` — `I(w) = H(m_w) − ∑_θ w_θ H(p_θ)`
* `exists_maxOn_mutualInfo`, `capacity`, `exists_capacity_prior` — the capacity
  of a finite source class is attained
* `klDiv_le_capacity_of_isMaxOn` — **the saddle point**: the capacity-achieving
  mixture is a *uniformly good* universal code
* `redundancy_capacity_theorem` — minimax average redundancy `=` capacity
* `klDiv_eq_capacity_of_pos` — Kuhn–Tucker equalizer property of `w*`
* `capacity_le_of_forall_klDiv_le` — verification criterion for optimality
* `capacity_le_logb_shtarkovSum`, `capacity_le_logb_card` — *the average price of
  universality never exceeds the worst-case price*, and never exceeds `log₂ #Θ`
* `kraft_average_converse`, `mixtureCode_avgLen_le` — operational form: every
  Kraft code loses `≥ C` bits on some source, and one explicit universal code
  loses `≤ C + 1` bits on *every* source
* `capacity_eq_klDiv_uniformMix_of_symmetric` — a closed form for classes with a
  transitive symmetry group: the uniform prior is capacity-achieving

## Application keywords

universal compression, minimax redundancy, redundancy–capacity theorem, channel
capacity, Bayes mixture, mutual information, Kuhn–Tucker conditions, Shtarkov
sum, price of universality
-/

import NumberTheory.UniversalRedundancyAverage

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Θ : Type*} [Fintype Θ]

/-! ## Two elementary tools -/

/-- If a real number is below `t · K` for every small positive `t`, it is
nonpositive.  This replaces the derivative computation in the classical proof of
the redundancy–capacity theorem. -/
lemma le_zero_of_forall_le_mul {a K : ℝ} (hK : 0 ≤ K)
    (h : ∀ t : ℝ, 0 < t → t ≤ 1 → a ≤ t * K) : a ≤ 0 := by
  by_contra hcon
  push_neg at hcon
  have hK1 : (0 : ℝ) < K + 1 := by linarith
  have hfrac : (0 : ℝ) < a / (2 * (K + 1)) := by positivity
  set t : ℝ := min 1 (a / (2 * (K + 1))) with ht
  have ht0 : 0 < t := lt_min one_pos hfrac
  have ht1 : t ≤ 1 := min_le_left _ _
  have ht2 : t ≤ a / (2 * (K + 1)) := min_le_right _ _
  have hmain := h t ht0 ht1
  have hbound : t * K ≤ (a / (2 * (K + 1))) * K := by nlinarith
  have hhalf : (a / (2 * (K + 1))) * K ≤ a / 2 := by
    rw [div_mul_eq_mul_div, div_le_iff₀ (by linarith : (0:ℝ) < 2 * (K + 1))]
    nlinarith
  linarith

/-- **χ²-bound for the Kullback–Leibler divergence.**  For probability vectors
`a`, `b` with `b` strictly positive, `D(a‖b) ≤ χ²(a‖b) / ln 2`.  This is the
quantitative second-order estimate that drives the perturbation argument. -/
theorem klDiv_le_chiSq {a b : X → ℝ} (ha : ∀ x, 0 ≤ a x) (hb : ∀ x, 0 < b x)
    (ha1 : ∑ x, a x = 1) (hb1 : ∑ x, b x = 1) :
    klDiv a b ≤ (∑ x, (a x - b x) ^ 2 / b x) / Real.log 2 := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hbits : klDiv a b = (∑ x, a x * Real.log (a x / b x)) / Real.log 2 := by
    unfold klDiv
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun x _ => by rw [Real.logb]; ring
  have key : ∑ x, a x * Real.log (a x / b x) ≤ ∑ x, (a x - b x) ^ 2 / b x := by
    have step : ∀ x ∈ (univ : Finset X),
        a x * Real.log (a x / b x) ≤ a x ^ 2 / b x - a x := by
      intro x _
      rcases eq_or_lt_of_le (ha x) with h | h
      · simp [← h]
      · have hbx := hb x
        have h1 : Real.log (a x / b x) ≤ a x / b x - 1 :=
          Real.log_le_sub_one_of_pos (div_pos h hbx)
        have h2 : a x * Real.log (a x / b x) ≤ a x * (a x / b x - 1) :=
          mul_le_mul_of_nonneg_left h1 (ha x)
        have h3 : a x * (a x / b x - 1) = a x ^ 2 / b x - a x := by
          field_simp
        linarith [h2, h3.le, h3.ge]
    have hexp : ∀ x : X, (a x - b x) ^ 2 / b x = a x ^ 2 / b x - 2 * a x + b x := by
      intro x
      have hbx := (hb x).ne'
      field_simp
      ring
    calc ∑ x, a x * Real.log (a x / b x)
        ≤ ∑ x, (a x ^ 2 / b x - a x) := Finset.sum_le_sum step
      _ = (∑ x, a x ^ 2 / b x) - 1 := by rw [Finset.sum_sub_distrib, ha1]
      _ = ∑ x, (a x - b x) ^ 2 / b x := by
          rw [Finset.sum_congr rfl fun x _ => hexp x, Finset.sum_add_distrib,
            Finset.sum_sub_distrib, ← Finset.mul_sum, ha1, hb1]
          ring
  rw [hbits]
  gcongr

namespace SourceClass

variable (S : SourceClass X Θ)

/-! ## Positivity of Bayes mixtures -/

/-- Under a prior on the standard simplex a strictly positive class has a
strictly positive Bayes mixture. -/
lemma mix_pos_of_mem_stdSimplex (hpos : ∀ θ x, 0 < S.prob θ x) {w : Θ → ℝ}
    (hw : w ∈ stdSimplex ℝ Θ) (x : X) : 0 < S.mix w x := by
  obtain ⟨hw0, hw1⟩ := hw
  obtain ⟨θ, -, hθ⟩ : ∃ θ ∈ (univ : Finset Θ), (0 : ℝ) < w θ := by
    refine Finset.exists_lt_of_sum_lt (f := fun _ : Θ => (0 : ℝ)) (g := w) ?_
    simp [hw1]
  have h1 : w θ * S.prob θ x ≤ S.mix w x := S.le_mix hw0 θ x
  nlinarith [hpos θ x]

/-! ## Mutual information as an entropy difference -/

/-- **`I(w) = H(m_w) − ∑_θ w_θ H(p_θ)`.**  The Bayes redundancy of the mixture
code is the entropy of the mixture minus the average entropy of the class: the
information the message carries about the *identity of the source*. -/
theorem mutualInfo_eq_entropy_sub (hpos : ∀ θ x, 0 < S.prob θ x) {w : Θ → ℝ}
    (hw0 : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1) :
    S.mutualInfo w = entropyBits (S.mix w) - ∑ θ, w θ * entropyBits (S.prob θ) := by
  have hm : ∀ x, 0 < S.mix w x := S.mix_pos_of_mem_stdSimplex hpos ⟨hw0, hw1⟩
  have hkl : ∀ θ, klDiv (S.prob θ) (S.mix w)
      = (∑ x, S.prob θ x * logb 2 (S.prob θ x))
        - ∑ x, S.prob θ x * logb 2 (S.mix w x) := by
    intro θ
    unfold klDiv
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [Real.logb_div (hpos θ x).ne' (hm x).ne']
    ring
  have hB : ∑ θ, w θ * (∑ x, S.prob θ x * logb 2 (S.mix w x))
      = ∑ x, S.mix w x * logb 2 (S.mix w x) := by
    calc ∑ θ, w θ * (∑ x, S.prob θ x * logb 2 (S.mix w x))
        = ∑ θ, ∑ x, (w θ * S.prob θ x) * logb 2 (S.mix w x) := by
          refine Finset.sum_congr rfl fun θ _ => ?_
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun x _ => by ring
      _ = ∑ x, ∑ θ, (w θ * S.prob θ x) * logb 2 (S.mix w x) := Finset.sum_comm
      _ = ∑ x, S.mix w x * logb 2 (S.mix w x) := by
          refine Finset.sum_congr rfl fun x _ => ?_
          rw [← Finset.sum_mul]
          rfl
  have hA : ∑ θ, w θ * (∑ x, S.prob θ x * logb 2 (S.prob θ x))
      = -∑ θ, w θ * entropyBits (S.prob θ) := by
    have hterm : ∀ θ : Θ, w θ * (∑ x, S.prob θ x * logb 2 (S.prob θ x))
        = -(w θ * entropyBits (S.prob θ)) := by
      intro θ; unfold entropyBits; ring
    rw [Finset.sum_congr rfl fun θ _ => hterm θ, Finset.sum_neg_distrib]
  have hsplit : ∀ θ : Θ, w θ * klDiv (S.prob θ) (S.mix w)
      = w θ * (∑ x, S.prob θ x * logb 2 (S.prob θ x))
        - w θ * (∑ x, S.prob θ x * logb 2 (S.mix w x)) := by
    intro θ; rw [hkl θ]; ring
  unfold mutualInfo
  rw [Finset.sum_congr rfl fun θ _ => hsplit θ, Finset.sum_sub_distrib, hA, hB]
  unfold entropyBits
  ring

/-! ## Existence of a capacity-achieving prior -/

/-- The Bayes redundancy is continuous in the prior (through the entropy
formula), which is what compactness of the simplex needs. -/
lemma continuous_entropy_mix :
    Continuous fun w : Θ → ℝ => entropyBits (S.mix w) := by
  unfold entropyBits
  refine Continuous.neg ?_
  refine continuous_finset_sum _ fun x _ => ?_
  have hmix : Continuous fun w : Θ → ℝ => S.mix w x :=
    continuous_finset_sum _ fun θ _ => (continuous_apply θ).mul continuous_const
  have hrw : (fun w : Θ → ℝ => S.mix w x * logb 2 (S.mix w x))
      = fun w : Θ → ℝ => (S.mix w x * Real.log (S.mix w x)) / Real.log 2 := by
    funext w; rw [Real.logb]; ring
  rw [hrw]
  exact (Real.continuous_mul_log.comp hmix).div_const _

/-- A prior maximising the Bayes redundancy exists: the simplex is compact and
`I` is continuous on it. -/
theorem exists_maxOn_mutualInfo [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    ∃ w ∈ stdSimplex ℝ Θ, ∀ w' ∈ stdSimplex ℝ Θ, S.mutualInfo w' ≤ S.mutualInfo w := by
  classical
  set F : (Θ → ℝ) → ℝ :=
    fun w => entropyBits (S.mix w) - ∑ θ, w θ * entropyBits (S.prob θ) with hF
  have hFcont : Continuous F := by
    refine (S.continuous_entropy_mix).sub ?_
    exact continuous_finset_sum _ fun θ _ => (continuous_apply θ).mul continuous_const
  have hne : (stdSimplex ℝ Θ).Nonempty := Set.Nonempty.of_subtype
  obtain ⟨w, hw, hmax⟩ :=
    (isCompact_stdSimplex Θ).exists_isMaxOn hne hFcont.continuousOn
  refine ⟨w, hw, fun w' hw' => ?_⟩
  have h1 : S.mutualInfo w' = F w' := S.mutualInfo_eq_entropy_sub hpos hw'.1 hw'.2
  have h2 : S.mutualInfo w = F w := S.mutualInfo_eq_entropy_sub hpos hw.1 hw.2
  rw [h1, h2]
  exact hmax hw'

/-- **The capacity of a source class**: the largest Bayes redundancy over all
priors.  By the redundancy–capacity theorem below this is exactly the minimax
average price of universality. -/
noncomputable def capacity : ℝ := sSup ((fun w => S.mutualInfo w) '' stdSimplex ℝ Θ)

/-- The capacity is attained, and dominates the Bayes redundancy of every
prior. -/
theorem exists_capacity_prior [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    ∃ w ∈ stdSimplex ℝ Θ, S.mutualInfo w = S.capacity ∧
      ∀ w' ∈ stdSimplex ℝ Θ, S.mutualInfo w' ≤ S.capacity := by
  obtain ⟨w, hw, hmax⟩ := S.exists_maxOn_mutualInfo hpos
  have hbdd : BddAbove ((fun w => S.mutualInfo w) '' stdSimplex ℝ Θ) := by
    refine ⟨S.mutualInfo w, ?_⟩
    rintro _ ⟨w', hw', rfl⟩
    exact hmax w' hw'
  have hle : S.capacity ≤ S.mutualInfo w := by
    refine csSup_le ⟨S.mutualInfo w, ⟨w, hw, rfl⟩⟩ ?_
    rintro _ ⟨w', hw', rfl⟩
    exact hmax w' hw'
  have hge : S.mutualInfo w ≤ S.capacity := le_csSup hbdd ⟨w, hw, rfl⟩
  have heq : S.mutualInfo w = S.capacity := le_antisymm hge hle
  exact ⟨w, hw, heq, fun w' hw' => heq ▸ hmax w' hw'⟩

/-- Every prior's Bayes redundancy is at most the capacity. -/
theorem mutualInfo_le_capacity [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x)
    {w : Θ → ℝ} (hw : w ∈ stdSimplex ℝ Θ) : S.mutualInfo w ≤ S.capacity := by
  obtain ⟨_, _, _, hmax⟩ := S.exists_capacity_prior hpos
  exact hmax w hw

/-! ## The saddle point

The heart of the file: a maximising prior produces a mixture that is good
*uniformly over the class*, not merely on average. -/

/-- **Saddle point / Kuhn–Tucker inequality.**  If `w` maximises the Bayes
redundancy then the mixture `m_w` is within `I(w)` bits of *every* source in the
class.  Proof by perturbing the prior towards a single source and using the
χ²-bound to control the second-order term. -/
theorem klDiv_le_mutualInfo_of_isMaxOn (hpos : ∀ θ x, 0 < S.prob θ x) {w : Θ → ℝ}
    (hw : w ∈ stdSimplex ℝ Θ)
    (hmax : ∀ w' ∈ stdSimplex ℝ Θ, S.mutualInfo w' ≤ S.mutualInfo w) (θ₀ : Θ) :
    klDiv (S.prob θ₀) (S.mix w) ≤ S.mutualInfo w := by
  classical
  obtain ⟨hw0, hw1⟩ := hw
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hmpos : ∀ x, 0 < S.mix w x := S.mix_pos_of_mem_stdSimplex hpos ⟨hw0, hw1⟩
  set V : ℝ := ∑ x, (S.prob θ₀ x - S.mix w x) ^ 2 / S.mix w x with hV
  have hVnn : 0 ≤ V := Finset.sum_nonneg fun x _ => div_nonneg (sq_nonneg _) (hmpos x).le
  refine sub_nonpos.mp (le_zero_of_forall_le_mul (K := V / Real.log 2)
    (by positivity) ?_)
  intro t ht0 ht1
  set wt : Θ → ℝ := fun θ => (1 - t) * w θ + t * (if θ = θ₀ then 1 else 0) with hwt
  have hwt0 : ∀ θ, 0 ≤ wt θ := by
    intro θ
    have h1 : 0 ≤ (1 - t) * w θ := mul_nonneg (by linarith) (hw0 θ)
    have h2 : 0 ≤ t * (if θ = θ₀ then (1 : ℝ) else 0) := by
      by_cases h : θ = θ₀ <;> simp [h, ht0.le]
    simp only [hwt]
    linarith
  have hwt1 : ∑ θ, wt θ = 1 := by
    simp only [hwt]
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, hw1, ← Finset.mul_sum]
    simp
  have hmixt : ∀ x, S.mix wt x = (1 - t) * S.mix w x + t * S.prob θ₀ x := by
    intro x
    unfold mix
    simp only [hwt, add_mul]
    rw [Finset.sum_add_distrib]
    congr 1
    · rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun θ _ => by ring
    · rw [Finset.sum_congr rfl (fun θ _ =>
        show (t * (if θ = θ₀ then (1 : ℝ) else 0)) * S.prob θ x
            = if θ = θ₀ then t * S.prob θ₀ x else 0 by
          by_cases h : θ = θ₀ <;> simp [h])]
      simp
  have hmtpos : ∀ x, 0 < S.mix wt x := S.mix_pos_of_mem_stdSimplex hpos ⟨hwt0, hwt1⟩
  have hcomp := S.bayes_compensation (w := wt) (q := S.mix w) hmpos hmtpos
  have hLHS : ∑ θ, wt θ * klDiv (S.prob θ) (S.mix w)
      = (1 - t) * S.mutualInfo w + t * klDiv (S.prob θ₀) (S.mix w) := by
    simp only [hwt, add_mul]
    rw [Finset.sum_add_distrib]
    congr 1
    · unfold mutualInfo
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun θ _ => by ring
    · rw [Finset.sum_congr rfl fun θ _ =>
        (by by_cases h : θ = θ₀ <;> simp [h] :
          t * (if θ = θ₀ then (1 : ℝ) else 0) * klDiv (S.prob θ) (S.mix w)
            = if θ = θ₀ then t * klDiv (S.prob θ₀) (S.mix w) else 0)]
      simp
  have hchi : klDiv (S.mix wt) (S.mix w) ≤ t ^ 2 * V / Real.log 2 := by
    have hsum : ∑ x, (S.mix wt x - S.mix w x) ^ 2 / S.mix w x = t ^ 2 * V := by
      rw [hV, Finset.mul_sum]
      refine Finset.sum_congr rfl fun x _ => ?_
      rw [hmixt x]
      have : (1 - t) * S.mix w x + t * S.prob θ₀ x - S.mix w x
          = t * (S.prob θ₀ x - S.mix w x) := by ring
      rw [this, mul_pow]
      ring
    have := klDiv_le_chiSq (a := S.mix wt) (b := S.mix w)
      (fun x => (hmtpos x).le) hmpos (S.mix_sum_one hwt1) (S.mix_sum_one hw1)
    rw [hsum] at this
    linarith
  have hIle : S.mutualInfo wt ≤ S.mutualInfo w := hmax wt ⟨hwt0, hwt1⟩
  have hstep : t * (klDiv (S.prob θ₀) (S.mix w) - S.mutualInfo w)
      ≤ t * (t * (V / Real.log 2)) := by
    rw [hLHS] at hcomp
    have h2 : t ^ 2 * V / Real.log 2 = t * (t * (V / Real.log 2)) := by ring
    nlinarith [hcomp, hIle, hchi]
  exact le_of_mul_le_mul_left hstep ht0

/-! ## The redundancy–capacity theorem -/

/-- **Achievability.**  The mixture over a capacity-achieving prior is a single
universal coding distribution that is within `C` bits of the true source, for
*every* source of the class. -/
theorem exists_universal_code_capacity [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    ∃ q : X → ℝ, (∀ x, 0 < q x) ∧ (∑ x, q x = 1) ∧
      ∀ θ, klDiv (S.prob θ) q ≤ S.capacity := by
  obtain ⟨w, hw, heq, -⟩ := S.exists_capacity_prior hpos
  obtain ⟨wmem, hwmax⟩ : w ∈ stdSimplex ℝ Θ ∧
      ∀ w' ∈ stdSimplex ℝ Θ, S.mutualInfo w' ≤ S.mutualInfo w := by
    refine ⟨hw, fun w' hw' => ?_⟩
    obtain ⟨-, -, -, hmax⟩ := S.exists_capacity_prior hpos
    rw [heq]
    exact hmax w' hw'
  refine ⟨S.mix w, S.mix_pos_of_mem_stdSimplex hpos hw, S.mix_sum_one hw.2, fun θ => ?_⟩
  rw [← heq]
  exact S.klDiv_le_mutualInfo_of_isMaxOn hpos wmem hwmax θ

/-- **The redundancy–capacity theorem** (Gallager–Ryabko–Davisson), exact and
non-asymptotic.  The minimax average price of universality equals the capacity
of the source class: one universal code achieves `C` bits against every source,
and no coding distribution beats `C` against all of them. -/
theorem redundancy_capacity_theorem [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    (∃ q : X → ℝ, (∀ x, 0 < q x) ∧ (∑ x, q x = 1) ∧
        ∀ θ, klDiv (S.prob θ) q ≤ S.capacity) ∧
      (∀ q : X → ℝ, (∀ x, 0 < q x) → (∑ x, q x ≤ 1) →
        ∃ θ, S.capacity ≤ klDiv (S.prob θ) q) := by
  refine ⟨S.exists_universal_code_capacity hpos, fun q hq hq1 => ?_⟩
  obtain ⟨w, hw, heq, -⟩ := S.exists_capacity_prior hpos
  obtain ⟨θ, hθ⟩ := S.exists_kl_ge_mutualInfo hw.1 hw.2 hq hq1
    (S.mix_pos_of_mem_stdSimplex hpos hw)
  exact ⟨θ, by rw [← heq]; exact hθ⟩

/-- **Verification criterion (Kuhn–Tucker sufficiency).**  If some coding
distribution is within `c` bits of every source, the capacity is at most `c`.
Together with `mutualInfo_le_capacity` this determines the capacity exactly
whenever a matching prior is exhibited. -/
theorem capacity_le_of_forall_klDiv_le [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x)
    {q : X → ℝ} (hq : ∀ x, 0 < q x) (hq1 : ∑ x, q x ≤ 1) {c : ℝ}
    (h : ∀ θ, klDiv (S.prob θ) q ≤ c) : S.capacity ≤ c := by
  obtain ⟨w, hw, heq, -⟩ := S.exists_capacity_prior hpos
  have hmpos := S.mix_pos_of_mem_stdSimplex hpos hw
  have hcomp := S.bayes_compensation (w := w) (q := q) hq hmpos
  have hklnn : 0 ≤ klDiv (S.mix w) q :=
    klDiv_nonneg (fun x => (hmpos x).le) hq (S.mix_sum_one hw.2) hq1
  have hupper : ∑ θ, w θ * klDiv (S.prob θ) q ≤ c := by
    calc ∑ θ, w θ * klDiv (S.prob θ) q ≤ ∑ θ, w θ * c :=
          Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left (h θ) (hw.1 θ)
      _ = c := by rw [← Finset.sum_mul, hw.2, one_mul]
  rw [← heq]
  linarith [hcomp, hklnn, hupper]

/-- **Equalizer property.**  Every source that the capacity-achieving prior
charges with positive weight pays *exactly* the capacity: the optimal universal
code is an equalizer rule on the support of `w*`. -/
theorem klDiv_eq_capacity_of_pos [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x)
    {w : Θ → ℝ} (hw : w ∈ stdSimplex ℝ Θ) (heq : S.mutualInfo w = S.capacity)
    {θ : Θ} (hwθ : 0 < w θ) : klDiv (S.prob θ) (S.mix w) = S.capacity := by
  have hmax : ∀ w' ∈ stdSimplex ℝ Θ, S.mutualInfo w' ≤ S.mutualInfo w := by
    intro w' hw'
    rw [heq]
    exact S.mutualInfo_le_capacity hpos hw'
  have hle : ∀ θ', klDiv (S.prob θ') (S.mix w) ≤ S.capacity := fun θ' => by
    rw [← heq]; exact S.klDiv_le_mutualInfo_of_isMaxOn hpos hw hmax θ'
  by_contra hne
  have hlt : klDiv (S.prob θ) (S.mix w) < S.capacity := lt_of_le_of_ne (hle θ) hne
  have hsum : ∑ θ', w θ' * klDiv (S.prob θ') (S.mix w) < ∑ θ', w θ' * S.capacity := by
    refine Finset.sum_lt_sum (fun θ' _ =>
      mul_le_mul_of_nonneg_left (hle θ') (hw.1 θ')) ⟨θ, Finset.mem_univ θ, ?_⟩
    exact (mul_lt_mul_of_pos_left hlt hwθ)
  rw [← Finset.sum_mul, hw.2, one_mul] at hsum
  exact absurd heq (by unfold mutualInfo; linarith)

/-! ## The average price never exceeds the worst-case price -/

/-- **Average ≤ worst case.**  The capacity — the exact average-case price of
universality — is at most `log₂ Cₛ`, the exact worst-case pointwise price.  The
two pillars of the thread are thus ordered. -/
theorem capacity_le_logb_shtarkovSum [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    S.capacity ≤ logb 2 S.shtarkovSum := by
  have hmax : ∀ x, 0 < S.maxLik x := fun x =>
    lt_of_lt_of_le (hpos (Classical.arbitrary Θ) x) (S.le_maxLik _ x)
  have hnmlpos : ∀ x, 0 < S.nml x := fun x => div_pos (hmax x) S.shtarkovSum_pos
  exact S.capacity_le_of_forall_klDiv_le hpos hnmlpos (le_of_eq S.nml_sum_one)
    (S.klDiv_nml_le_logb_shtarkovSum hmax)

/-- The capacity of a class of `N` sources is at most `log₂ N`: a two-part code
that first names the source is never worse than that. -/
theorem capacity_le_logb_card [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    S.capacity ≤ logb 2 (Fintype.card Θ) := by
  have hmpos : ∀ x, 0 < S.mix (uniformPrior Θ) x :=
    S.mix_pos_of_mem_stdSimplex hpos ⟨fun θ => uniformPrior_nonneg θ, uniformPrior_sum_one⟩
  exact S.capacity_le_of_forall_klDiv_le hpos hmpos
    (le_of_eq (S.mix_sum_one uniformPrior_sum_one)) (fun θ => S.klDiv_uniformMix_le θ)

/-- The capacity is nonnegative. -/
theorem capacity_nonneg [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) : 0 ≤ S.capacity := by
  have hmem : (uniformPrior Θ) ∈ stdSimplex ℝ Θ :=
    ⟨fun θ => uniformPrior_nonneg θ, uniformPrior_sum_one⟩
  have hmpos := S.mix_pos_of_mem_stdSimplex hpos hmem
  have h0 : 0 ≤ S.mutualInfo (uniformPrior Θ) := by
    unfold mutualInfo
    refine Finset.sum_nonneg fun θ _ => mul_nonneg (uniformPrior_nonneg θ) ?_
    exact klDiv_nonneg (S.nonneg θ) hmpos (S.sum_one θ)
      (le_of_eq (S.mix_sum_one uniformPrior_sum_one))
  exact le_trans h0 (S.mutualInfo_le_capacity hpos hmem)

/-! ## Operational form: expected code lengths

The capacity is not an abstract quantity: it is, to within one bit, the number
of extra bits a *single prefix code* must spend. -/

/-- The Shannon code of a coding distribution. -/
noncomputable def shannonLen (q : X → ℝ) (x : X) : ℕ := ⌈logb 2 (1 / q x)⌉₊

/-- The Shannon code of a probability distribution is Kraft compliant, hence
realizable as a prefix-free binary code. -/
theorem kraft_shannonLen {q : X → ℝ} (hq : ∀ x, 0 < q x) (hq1 : ∑ x, q x = 1) :
    Kraft (shannonLen q) := by
  unfold Kraft
  have hstep : ∀ x : X, (2 : ℝ) ^ (-(shannonLen q x : ℤ)) ≤ q x := by
    intro x
    have hceil : logb 2 (1 / q x) ≤ (shannonLen q x : ℝ) := Nat.le_ceil _
    have h1 : (1 : ℝ) / q x ≤ (2 : ℝ) ^ (shannonLen q x : ℕ) := by
      have hqx := hq x
      have h := (Real.logb_le_iff_le_rpow (by norm_num : (1:ℝ) < 2)
        (by positivity : (0:ℝ) < 1 / q x)).mp hceil
      calc (1 : ℝ) / q x ≤ (2 : ℝ) ^ ((shannonLen q x : ℕ) : ℝ) := h
        _ = (2 : ℝ) ^ (shannonLen q x : ℕ) := by rw [Real.rpow_natCast]
    have hpow : (0 : ℝ) < (2 : ℝ) ^ (shannonLen q x : ℕ) := by positivity
    rw [zpow_neg, zpow_natCast, inv_le_comm₀ hpow (hq x)]
    calc (q x)⁻¹ = 1 / q x := by rw [one_div]
      _ ≤ (2 : ℝ) ^ (shannonLen q x : ℕ) := h1
  calc ∑ x, (2 : ℝ) ^ (-(shannonLen q x : ℤ)) ≤ ∑ x, q x :=
        Finset.sum_le_sum fun x _ => hstep x
    _ = 1 := hq1

/-- Expected length of the Shannon code of `q` under a source `p`: entropy plus
divergence plus at most one bit. -/
theorem avgLen_shannonLen_le {p q : X → ℝ} (hp : ∀ x, 0 < p x) (hq : ∀ x, 0 < q x)
    (hp1 : ∑ x, p x = 1) (hq1 : ∑ x, q x = 1) :
    avgLen p (fun x => (shannonLen q x : ℝ)) ≤ entropyBits p + klDiv p q + 1 := by
  have hstep : ∀ x : X, p x * (shannonLen q x : ℝ) ≤ p x * (logb 2 (1 / q x) + 1) := by
    intro x
    refine mul_le_mul_of_nonneg_left ?_ (hp x).le
    have : (⌈logb 2 (1 / q x)⌉₊ : ℝ) < logb 2 (1 / q x) + 1 := by
      refine Nat.ceil_lt_add_one ?_
      have h1 : (1 : ℝ) ≤ 1 / q x := by
        rw [le_div_iff₀ (hq x), one_mul]
        calc q x ≤ ∑ y, q y :=
              Finset.single_le_sum (f := q) (fun y _ => (hq y).le) (Finset.mem_univ x)
          _ = 1 := hq1
      exact Real.logb_nonneg (by norm_num) h1
    unfold shannonLen
    linarith
  have hsplit : ∑ x, p x * (logb 2 (1 / q x) + 1) = entropyBits p + klDiv p q + 1 := by
    have hterm : ∀ x : X, p x * (logb 2 (1 / q x) + 1)
        = -(p x * logb 2 (p x)) + p x * logb 2 (p x / q x) + p x := by
      intro x
      rw [one_div, Real.logb_inv, Real.logb_div (hp x).ne' (hq x).ne']
      ring
    rw [Finset.sum_congr rfl fun x _ => hterm x, Finset.sum_add_distrib,
      Finset.sum_add_distrib, hp1]
    unfold entropyBits klDiv
    rw [Finset.sum_neg_distrib]
  calc avgLen p (fun x => (shannonLen q x : ℝ))
      ≤ ∑ x, p x * (logb 2 (1 / q x) + 1) := Finset.sum_le_sum fun x _ => hstep x
    _ = entropyBits p + klDiv p q + 1 := hsplit

/-- **Converse in code lengths.**  Every Kraft-compliant code has a source in the
class on which its expected length exceeds the entropy by at least the capacity:
the price of universality is really paid, in bits. -/
theorem kraft_average_converse [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x)
    (ℓ : X → ℕ) (hℓ : Kraft ℓ) :
    ∃ θ, entropyBits (S.prob θ) + S.capacity
      ≤ avgLen (S.prob θ) (fun x => (ℓ x : ℝ)) := by
  obtain ⟨-, hconv⟩ := S.redundancy_capacity_theorem hpos
  obtain ⟨θ, hθ⟩ := hconv (fun x => (2 : ℝ) ^ (-(ℓ x : ℤ))) (fun x => by positivity) hℓ
  refine ⟨θ, ?_⟩
  have hcode := klDiv_code_eq (p := S.prob θ) (S.nonneg θ) ℓ
  rw [hcode] at hθ
  linarith

/-- **Achievability in code lengths.**  One explicit prefix code — the Shannon
code of the capacity mixture — is within `C + 1` bits of the entropy of *every*
source in the class.  With `kraft_average_converse` this brackets the minimax
average redundancy of prefix codes between `C` and `C + 1`. -/
theorem exists_universal_kraft_code [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) :
    ∃ ℓ : X → ℕ, Kraft ℓ ∧ ∀ θ,
      avgLen (S.prob θ) (fun x => (ℓ x : ℝ))
        ≤ entropyBits (S.prob θ) + S.capacity + 1 := by
  obtain ⟨q, hq, hq1, hle⟩ := S.exists_universal_code_capacity hpos
  refine ⟨shannonLen q, kraft_shannonLen hq hq1, fun θ => ?_⟩
  have h := avgLen_shannonLen_le (p := S.prob θ) (q := q) (hpos θ) hq (S.sum_one θ) hq1
  have := hle θ
  linarith

/-! ## Closed form under a transitive symmetry group

If a group acts on messages and on parameters compatibly and transitively on
parameters, the uniform prior is capacity-achieving and the capacity has a
closed form.  This is the bridge to algebra: symmetry *computes* the price of
universality. -/

variable {G : Type*}

/-- A symmetry of the class transports the uniform mixture to itself. -/
lemma mix_uniformPrior_symm [Nonempty Θ] (actX : G → X ≃ X) (actΘ : G → Θ ≃ Θ)
    (hcompat : ∀ g θ x, S.prob (actΘ g θ) (actX g x) = S.prob θ x) (g : G) (x : X) :
    S.mix (uniformPrior Θ) (actX g x) = S.mix (uniformPrior Θ) x := by
  unfold mix
  calc ∑ θ, uniformPrior Θ θ * S.prob θ (actX g x)
      = ∑ θ, uniformPrior Θ (actΘ g θ) * S.prob (actΘ g θ) (actX g x) :=
        (Equiv.sum_comp (actΘ g) (fun θ => uniformPrior Θ θ * S.prob θ (actX g x))).symm
    _ = ∑ θ, uniformPrior Θ θ * S.prob θ x := by
        refine Finset.sum_congr rfl fun θ _ => ?_
        rw [hcompat g θ x]
        rfl

/-- Divergence against the uniform mixture is a symmetry invariant. -/
lemma klDiv_uniformMix_symm [Nonempty Θ] (actX : G → X ≃ X) (actΘ : G → Θ ≃ Θ)
    (hcompat : ∀ g θ x, S.prob (actΘ g θ) (actX g x) = S.prob θ x) (g : G) (θ : Θ) :
    klDiv (S.prob (actΘ g θ)) (S.mix (uniformPrior Θ))
      = klDiv (S.prob θ) (S.mix (uniformPrior Θ)) := by
  unfold klDiv
  calc ∑ x, S.prob (actΘ g θ) x * logb 2 (S.prob (actΘ g θ) x / S.mix (uniformPrior Θ) x)
      = ∑ x, S.prob (actΘ g θ) (actX g x)
          * logb 2 (S.prob (actΘ g θ) (actX g x) / S.mix (uniformPrior Θ) (actX g x)) :=
        (Equiv.sum_comp (actX g) (fun y => S.prob (actΘ g θ) y
          * logb 2 (S.prob (actΘ g θ) y / S.mix (uniformPrior Θ) y))).symm
    _ = ∑ x, S.prob θ x * logb 2 (S.prob θ x / S.mix (uniformPrior Θ) x) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [hcompat g θ x, S.mix_uniformPrior_symm actX actΘ hcompat g x]

/-- **Symmetric classes: the uniform prior is optimal.**  If a group acts
compatibly on messages and parameters and transitively on parameters, the
capacity equals the divergence of any single source from the uniform mixture —
a closed form for the price of universality. -/
theorem capacity_eq_klDiv_uniformMix_of_symmetric [Nonempty Θ]
    (hpos : ∀ θ x, 0 < S.prob θ x) (actX : G → X ≃ X) (actΘ : G → Θ ≃ Θ)
    (hcompat : ∀ g θ x, S.prob (actΘ g θ) (actX g x) = S.prob θ x)
    (htrans : ∀ θ θ' : Θ, ∃ g, actΘ g θ = θ') (θ₀ : Θ) :
    S.capacity = klDiv (S.prob θ₀) (S.mix (uniformPrior Θ)) := by
  have hmem : (uniformPrior Θ) ∈ stdSimplex ℝ Θ :=
    ⟨fun θ => uniformPrior_nonneg θ, uniformPrior_sum_one⟩
  have hmpos := S.mix_pos_of_mem_stdSimplex hpos hmem
  have hall : ∀ θ, klDiv (S.prob θ) (S.mix (uniformPrior Θ))
      = klDiv (S.prob θ₀) (S.mix (uniformPrior Θ)) := by
    intro θ
    obtain ⟨g, hg⟩ := htrans θ₀ θ
    rw [← hg, S.klDiv_uniformMix_symm actX actΘ hcompat g θ₀]
  refine le_antisymm ?_ ?_
  · exact S.capacity_le_of_forall_klDiv_le hpos hmpos
      (le_of_eq (S.mix_sum_one uniformPrior_sum_one)) (fun θ => le_of_eq (hall θ))
  · have hI : S.mutualInfo (uniformPrior Θ)
        = klDiv (S.prob θ₀) (S.mix (uniformPrior Θ)) := by
      unfold mutualInfo
      rw [Finset.sum_congr rfl fun θ _ => by rw [hall θ], ← Finset.sum_mul,
        uniformPrior_sum_one, one_mul]
    rw [← hI]
    exact S.mutualInfo_le_capacity hpos hmem

end SourceClass

end UniversalRedundancy