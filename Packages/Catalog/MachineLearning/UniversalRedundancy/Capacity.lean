/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IV: the redundancy–capacity lower bound

Fourth instalment of the thread.  `UniversalRedundancy.Core` computed the
*worst-case* (pointwise) minimax redundancy exactly: `log₂ Cₛ`.  This file
develops the *average-case* side, which produces lower bounds that do not
depend on any single bad message: the Bayes / capacity bound.

## Central Idea

Put a prior `w` on the class.  For any coding distribution `q`,

`∑_θ w_θ · D(p_θ ‖ q) = I(w) + D(m_w ‖ q)`   (compensation identity),

where `m_w = ∑_θ w_θ p_θ` is the mixture and `I(w) = ∑_θ w_θ D(p_θ ‖ m_w)` is
the mutual information between parameter and data.  Since relative entropy is
non-negative (Gibbs), the mixture code is Bayes optimal and

`I(w) ≤ inf_q sup_θ D(p_θ ‖ q) ≤ log₂ Cₛ`.

So the *capacity* of the class is a lower bound on the average redundancy of any
universal scheme, and it never exceeds the worst-case answer of Part I.  All
statements are for strictly positive laws and priors, the regime where relative
entropy is finite and the classical theory lives.

## Main Results

* `KLb`, `mixture`, `mutualInfo`, `bayesRedundancy` — relative entropy in bits,
  the Bayes mixture, the capacity functional, and Bayes-average redundancy
* `KLb_nonneg` — Gibbs' inequality
* `compensation_identity` — the exact Bayes decomposition
* `mutualInfo_le_bayesRedundancy` — the mixture code is Bayes optimal: no code
  beats `I(w)` on average
* `exists_source_KLb_ge_mutualInfo` — minimax ≥ maximin: every coding
  distribution suffers at least `I(w)` against some source of the class
* `mutualInfo_le_logb_shtarkovSum` — capacity never exceeds the worst-case price
  `log₂ Cₛ` of Part I, tying the two theories together
* `mutualInfo_le_entropy`, `entropyb_le_logb_card` — `I(w) ≤ H(w) ≤ log₂ #Θ`:
  the price of universality is at most the cost of *naming the source*

## Application Keywords

redundancy-capacity theorem, relative entropy, Gibbs inequality, Bayes mixture
code, mutual information, universal coding
-/

import MachineLearning.UniversalRedundancy.Core

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Θ : Type*} [Fintype Θ] [Nonempty Θ]

/-- Relative entropy (Kullback–Leibler divergence) measured in bits. -/
noncomputable def KLb (p q : X → ℝ) : ℝ := ∑ x, p x * logb 2 (p x / q x)

/-- Shannon entropy in bits. -/
noncomputable def entropyb (p : X → ℝ) : ℝ := ∑ x, -(p x * logb 2 (p x))

/-- **Gibbs' inequality.**  Relative entropy between probability vectors with
positive entries is non-negative. -/
theorem KLb_nonneg (p q : X → ℝ) (hp : ∀ x, 0 < p x) (hq : ∀ x, 0 < q x)
    (hps : ∑ x, p x = 1) (hqs : ∑ x, q x = 1) : 0 ≤ KLb p q := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have key : ∑ x, p x * Real.log (q x / p x) ≤ 0 := by
    have hstep : ∀ x ∈ (univ : Finset X), p x * Real.log (q x / p x) ≤ q x - p x := by
      intro x _
      have hpx := hp x
      have hqx := hq x
      have hlt : Real.log (q x / p x) ≤ q x / p x - 1 :=
        Real.log_le_sub_one_of_pos (by positivity)
      have hmul := mul_le_mul_of_nonneg_left hlt hpx.le
      calc p x * Real.log (q x / p x) ≤ p x * (q x / p x - 1) := hmul
        _ = q x - p x := by field_simp
    calc ∑ x, p x * Real.log (q x / p x) ≤ ∑ x, (q x - p x) := Finset.sum_le_sum hstep
      _ = 0 := by rw [Finset.sum_sub_distrib, hps, hqs, sub_self]
  have hflip : ∀ x, p x * logb 2 (p x / q x)
      = -(p x * Real.log (q x / p x)) / Real.log 2 := by
    intro x
    have hpx := hp x
    have hqx := hq x
    have hinv : (p x / q x) = (q x / p x)⁻¹ := by field_simp
    rw [logb, hinv, Real.log_inv]
    field_simp
  unfold KLb
  rw [Finset.sum_congr rfl fun x _ => hflip x, ← Finset.sum_div,
    Finset.sum_neg_distrib]
  exact div_nonneg (by linarith) hlog2.le

/-- The Bayes mixture of the class under a prior `w`. -/
noncomputable def mixture (S : SourceClass X Θ) (w : Θ → ℝ) (x : X) : ℝ :=
  ∑ θ, w θ * S.prob θ x

/-- The mutual information (capacity functional) of a prior. -/
noncomputable def mutualInfo (S : SourceClass X Θ) (w : Θ → ℝ) : ℝ :=
  ∑ θ, w θ * KLb (S.prob θ) (mixture S w)

/-- The Bayes-average redundancy of a coding distribution `q` under prior `w`. -/
noncomputable def bayesRedundancy (S : SourceClass X Θ) (w : Θ → ℝ) (q : X → ℝ) : ℝ :=
  ∑ θ, w θ * KLb (S.prob θ) q

variable (S : SourceClass X Θ)

lemma mixture_pos (w : Θ → ℝ) (hw : ∀ θ, 0 < w θ) (hp : ∀ θ x, 0 < S.prob θ x) (x : X) :
    0 < mixture S w x := by
  unfold mixture
  refine Finset.sum_pos (fun θ _ => mul_pos (hw θ) (hp θ x)) ⟨Classical.arbitrary Θ, mem_univ _⟩

omit [Nonempty Θ] in
lemma mixture_sum_one (w : Θ → ℝ) (hws : ∑ θ, w θ = 1) : ∑ x, mixture S w x = 1 := by
  unfold mixture
  rw [Finset.sum_comm]
  calc ∑ θ, ∑ x, w θ * S.prob θ x = ∑ θ, w θ * ∑ x, S.prob θ x :=
        Finset.sum_congr rfl fun θ _ => by rw [Finset.mul_sum]
    _ = ∑ θ, w θ := by simp [S.sum_one]
    _ = 1 := hws

/-- **Compensation identity.**  The Bayes-average redundancy of any code splits
exactly into the capacity term `I(w)` and the excess `D(m_w ‖ q)` of the code
over the mixture. -/
theorem compensation_identity (w : Θ → ℝ) (q : X → ℝ) (hw : ∀ θ, 0 < w θ)
    (hp : ∀ θ x, 0 < S.prob θ x) (hq : ∀ x, 0 < q x) :
    bayesRedundancy S w q = mutualInfo S w + KLb (mixture S w) q := by
  have hm : ∀ x, 0 < mixture S w x := mixture_pos S w hw hp
  have hsplit : ∀ θ x, logb 2 (S.prob θ x / q x)
      = logb 2 (S.prob θ x / mixture S w x) + logb 2 (mixture S w x / q x) := by
    intro θ x
    have hmx : mixture S w x ≠ 0 := (hm x).ne'
    have hqx : q x ≠ 0 := (hq x).ne'
    have h1 : S.prob θ x / q x
        = (S.prob θ x / mixture S w x) * (mixture S w x / q x) := by
      field_simp
    rw [h1, Real.logb_mul (ne_of_gt (div_pos (hp θ x) (hm x)))
      (ne_of_gt (div_pos (hm x) (hq x)))]
  have hexpand : bayesRedundancy S w q
      = (∑ θ, w θ * ∑ x, S.prob θ x * logb 2 (S.prob θ x / mixture S w x))
        + ∑ θ, w θ * ∑ x, S.prob θ x * logb 2 (mixture S w x / q x) := by
    unfold bayesRedundancy KLb
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun θ _ => ?_
    rw [← mul_add, ← Finset.sum_add_distrib]
    refine congrArg (fun t => w θ * t) (Finset.sum_congr rfl fun x _ => ?_)
    rw [hsplit θ x, mul_add]
  have hsecond : ∑ θ, w θ * ∑ x, S.prob θ x * logb 2 (mixture S w x / q x)
      = KLb (mixture S w) q := by
    unfold KLb mixture
    calc ∑ θ, w θ * ∑ x, S.prob θ x * logb 2 ((∑ θ', w θ' * S.prob θ' x) / q x)
        = ∑ θ, ∑ x, w θ * S.prob θ x * logb 2 ((∑ θ', w θ' * S.prob θ' x) / q x) := by
          refine Finset.sum_congr rfl fun θ _ => ?_
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun x _ => by ring
      _ = ∑ x, ∑ θ, w θ * S.prob θ x * logb 2 ((∑ θ', w θ' * S.prob θ' x) / q x) :=
          Finset.sum_comm
      _ = ∑ x, (∑ θ, w θ * S.prob θ x) * logb 2 ((∑ θ', w θ' * S.prob θ' x) / q x) :=
          Finset.sum_congr rfl fun x _ => by rw [Finset.sum_mul]
  rw [hexpand, hsecond]
  rfl

/-- **The mixture code is Bayes optimal.**  No coding distribution achieves
average redundancy below the capacity functional `I(w)`. -/
theorem mutualInfo_le_bayesRedundancy (w : Θ → ℝ) (q : X → ℝ) (hw : ∀ θ, 0 < w θ)
    (hws : ∑ θ, w θ = 1) (hp : ∀ θ x, 0 < S.prob θ x) (hq : ∀ x, 0 < q x)
    (hqs : ∑ x, q x = 1) : mutualInfo S w ≤ bayesRedundancy S w q := by
  have hid := compensation_identity S w q hw hp hq
  have hnn : 0 ≤ KLb (mixture S w) q :=
    KLb_nonneg _ _ (mixture_pos S w hw hp) hq (mixture_sum_one S w hws) hqs
  linarith

/-- **Minimax ≥ maximin.**  Against any single coding distribution some source of
the class suffers at least the capacity `I(w)` in expected redundancy. -/
theorem exists_source_KLb_ge_mutualInfo (w : Θ → ℝ) (q : X → ℝ) (hw : ∀ θ, 0 < w θ)
    (hws : ∑ θ, w θ = 1) (hp : ∀ θ x, 0 < S.prob θ x) (hq : ∀ x, 0 < q x)
    (hqs : ∑ x, q x = 1) : ∃ θ, mutualInfo S w ≤ KLb (S.prob θ) q := by
  by_contra hcon
  push_neg at hcon
  have hlt : ∑ θ, w θ * KLb (S.prob θ) q < ∑ θ, w θ * mutualInfo S w := by
    refine Finset.sum_lt_sum_of_nonempty ⟨Classical.arbitrary Θ, mem_univ _⟩ fun θ _ => ?_
    exact mul_lt_mul_of_pos_left (hcon θ) (hw θ)
  have hsum : ∑ θ, w θ * mutualInfo S w = mutualInfo S w := by
    rw [← Finset.sum_mul, hws, one_mul]
  have hbayes := mutualInfo_le_bayesRedundancy S w q hw hws hp hq hqs
  unfold bayesRedundancy at hbayes
  rw [hsum] at hlt
  linarith

/-! ## Capacity never exceeds the worst-case price -/

omit [Fintype Θ] in
/-- Relative entropy of any source of the class from the NML distribution is at
most `log₂ Cₛ`. -/
theorem KLb_nml_le_logb_shtarkovSum (θ : Θ) (hp : ∀ θ x, 0 < S.prob θ x)
    (hmax : ∀ x, 0 < S.maxLik x) :
    KLb (S.prob θ) S.nml ≤ logb 2 S.shtarkovSum := by
  have hCpos := S.shtarkovSum_pos
  have hnml : ∀ x, 0 < S.nml x := fun x => div_pos (hmax x) hCpos
  have hterm : ∀ x, S.prob θ x * logb 2 (S.prob θ x / S.nml x)
      ≤ S.prob θ x * logb 2 S.shtarkovSum := by
    intro x
    refine mul_le_mul_of_nonneg_left ?_ (S.nonneg θ x)
    refine Real.logb_le_logb_of_le (by norm_num) (div_pos (hp θ x) (hnml x)) ?_
    rw [div_le_iff₀ (hnml x)]
    exact S.prob_le_shtarkovSum_mul_nml θ x
  calc KLb (S.prob θ) S.nml ≤ ∑ x, S.prob θ x * logb 2 S.shtarkovSum :=
        Finset.sum_le_sum fun x _ => hterm x
    _ = logb 2 S.shtarkovSum := by rw [← Finset.sum_mul, S.sum_one θ, one_mul]

/-- **Capacity ≤ worst-case price.**  For every prior, the average-case lower
bound `I(w)` is dominated by the exact worst-case minimax redundancy `log₂ Cₛ`
of Part I: the two theories are consistent, and the pointwise theory is the
stronger requirement. -/
theorem mutualInfo_le_logb_shtarkovSum (w : Θ → ℝ) (hw : ∀ θ, 0 < w θ)
    (hws : ∑ θ, w θ = 1) (hp : ∀ θ x, 0 < S.prob θ x) (hmax : ∀ x, 0 < S.maxLik x) :
    mutualInfo S w ≤ logb 2 S.shtarkovSum := by
  have hnml : ∀ x, 0 < S.nml x := fun x => div_pos (hmax x) S.shtarkovSum_pos
  have hbayes := mutualInfo_le_bayesRedundancy S w S.nml hw hws hp hnml S.nml_sum_one
  have hle : bayesRedundancy S w S.nml ≤ logb 2 S.shtarkovSum := by
    unfold bayesRedundancy
    calc ∑ θ, w θ * KLb (S.prob θ) S.nml
        ≤ ∑ θ, w θ * logb 2 S.shtarkovSum :=
          Finset.sum_le_sum fun θ _ =>
            mul_le_mul_of_nonneg_left (KLb_nml_le_logb_shtarkovSum S θ hp hmax) (hw θ).le
      _ = logb 2 S.shtarkovSum := by rw [← Finset.sum_mul, hws, one_mul]
  linarith

/-! ## Capacity is at most the entropy of the prior -/

/-- **`I(w) ≤ H(w)`.**  The price of universality is at most the number of bits
needed to *name* the source: mutual information is bounded by prior entropy. -/
theorem mutualInfo_le_entropy (w : Θ → ℝ) (hw : ∀ θ, 0 < w θ)
    (hp : ∀ θ x, 0 < S.prob θ x) : mutualInfo S w ≤ entropyb w := by
  have hm : ∀ x, 0 < mixture S w x := mixture_pos S w hw hp
  have hKL : ∀ θ, KLb (S.prob θ) (mixture S w) ≤ -logb 2 (w θ) := by
    intro θ
    have hterm : ∀ x, S.prob θ x * logb 2 (S.prob θ x / mixture S w x)
        ≤ S.prob θ x * (-logb 2 (w θ)) := by
      intro x
      refine mul_le_mul_of_nonneg_left ?_ (S.nonneg θ x)
      have hbound : S.prob θ x / mixture S w x ≤ 1 / w θ := by
        rw [div_le_div_iff₀ (hm x) (hw θ)]
        have hle : w θ * S.prob θ x ≤ mixture S w x := by
          unfold mixture
          refine Finset.single_le_sum (f := fun θ' => w θ' * S.prob θ' x)
            (fun θ' _ => (mul_pos (hw θ') (hp θ' x)).le) (mem_univ θ)
        linarith
      have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (div_pos (hp θ x) (hm x)) hbound
      rw [one_div, Real.logb_inv] at this
      exact this
    calc KLb (S.prob θ) (mixture S w) ≤ ∑ x, S.prob θ x * (-logb 2 (w θ)) :=
          Finset.sum_le_sum fun x _ => hterm x
      _ = -logb 2 (w θ) := by rw [← Finset.sum_mul, S.sum_one θ, one_mul]
  unfold mutualInfo entropyb
  refine Finset.sum_le_sum fun θ _ => ?_
  have := mul_le_mul_of_nonneg_left (hKL θ) (hw θ).le
  calc w θ * KLb (S.prob θ) (mixture S w) ≤ w θ * -logb 2 (w θ) := this
    _ = -(w θ * logb 2 (w θ)) := by ring

/-- **`H(w) ≤ log₂ #Θ`.**  Uniform priors maximize entropy (a Gibbs corollary),
so the capacity of any finite class is at most `log₂ #Θ`. -/
theorem entropyb_le_logb_card (w : Θ → ℝ) (hw : ∀ θ, 0 < w θ) (hws : ∑ θ, w θ = 1) :
    entropyb w ≤ logb 2 (Fintype.card Θ) := by
  have hcard : (0 : ℝ) < (Fintype.card Θ : ℝ) := by exact_mod_cast Fintype.card_pos
  set u : Θ → ℝ := fun _ => (Fintype.card Θ : ℝ)⁻¹ with hu
  have hupos : ∀ θ, 0 < u θ := fun θ => by rw [hu]; positivity
  have hus : ∑ θ, u θ = 1 := by
    rw [hu, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
  have hgibbs := KLb_nonneg w u hw hupos hws hus
  have hexp : KLb w u = ∑ θ, w θ * (logb 2 (w θ) + logb 2 (Fintype.card Θ)) := by
    unfold KLb
    refine Finset.sum_congr rfl fun θ _ => ?_
    have hdiv : w θ / u θ = w θ * (Fintype.card Θ : ℝ) := by
      rw [hu]; field_simp
    rw [hdiv, Real.logb_mul (ne_of_gt (hw θ)) (ne_of_gt hcard)]
  rw [hexp] at hgibbs
  have hsplit : ∑ θ, w θ * (logb 2 (w θ) + logb 2 (Fintype.card Θ))
      = (∑ θ, w θ * logb 2 (w θ)) + logb 2 (Fintype.card Θ) := by
    calc ∑ θ, w θ * (logb 2 (w θ) + logb 2 (Fintype.card Θ))
        = ∑ θ, (w θ * logb 2 (w θ) + w θ * logb 2 (Fintype.card Θ)) :=
          Finset.sum_congr rfl fun θ _ => by ring
      _ = (∑ θ, w θ * logb 2 (w θ)) + (∑ θ, w θ) * logb 2 (Fintype.card Θ) := by
          rw [Finset.sum_add_distrib, Finset.sum_mul]
      _ = (∑ θ, w θ * logb 2 (w θ)) + logb 2 (Fintype.card Θ) := by rw [hws, one_mul]
  rw [hsplit] at hgibbs
  unfold entropyb
  rw [Finset.sum_neg_distrib]
  linarith

end UniversalRedundancy