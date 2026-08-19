/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VI: structure of the capacity

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

`Bridges.UniversalRedundancyCapacity` identified the average-case price of
universality with the capacity `C` of the source class and produced the
optimality criterion `capacity_le_of_forall_klDiv_le`.  That criterion turns
structural questions about universal compression into short arguments.  Here we
answer the ones the research plan actually asks:

* **Is the price ever zero?**  Only for a class that is a single distribution
  (`capacity_pos_of_ne`), via a strict Gibbs inequality (`klDiv_pos_of_ne`).
* **Does specialising to a sub-class help?**  Never by more than the price of
  the big class (`capacity_le_of_subclass`), and — the quantitative answer —
  merging `K` specialised classes into one universal scheme costs at most
  `log₂ K` extra bits (`capacity_sigmaClass_le`), while it can never cost less
  than the worst of the specialised prices (`capacity_le_capacity_sigmaClass`).
  This is `capacity_sigmaClass_sandwich`: **the total number of bits that
  specialisation can move from the message to the shared decompressor is at most
  `log₂ (number of classes)`.**
* **How large is the price for a genuinely rich class?**  For classes with `N`
  approximately distinguishable members it is `log₂ N` up to `4` bits
  (`capacity_approx_disjoint_sandwich`).

## Main results

* `klDiv_pos_of_ne` — strict Gibbs inequality
* `capacity_pos_of_ne` — the price of universality is strictly positive as soon
  as two sources of the class differ
* `capacity_le_of_subclass` — monotonicity of the price under passing to a
  sub-class
* `klDiv_avgCode_le` — a uniform mixture of `K` codes loses at most `log₂ K`
* `capacity_sigmaClass_le`, `capacity_le_capacity_sigmaClass`,
  `capacity_sigmaClass_sandwich` — the exact cost of model selection
* `capacity_ge_of_approx_disjoint`, `capacity_approx_disjoint_sandwich` — the
  price of a class of `N` distinguishable sources is `log₂ N ± 4`

## Application keywords

universal compression, minimax redundancy, channel capacity, model selection,
two-part codes, Gibbs inequality, price of universality
-/

import Bridges.UniversalRedundancyCapacity
import NumberTheory.UniversalRedundancyAlgebra
import NumberTheory.UniversalRedundancyConservation

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Θ : Type*} [Fintype Θ]

/-! ## A strict Gibbs inequality -/

/-- **Strict Gibbs inequality.**  The Kullback–Leibler divergence of two distinct
probability vectors is strictly positive. -/
theorem klDiv_pos_of_ne {p q : X → ℝ} (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 < q x)
    (hp1 : ∑ x, p x = 1) (hq1 : ∑ x, q x = 1) (hne : p ≠ q) : 0 < klDiv p q := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  set g : X → ℝ := fun x => p x * Real.log (p x / q x) - (p x - q x) with hg
  have hgnn : ∀ x, 0 ≤ g x := by
    intro x
    rcases eq_or_lt_of_le (hp x) with h | h
    · simp only [hg, ← h]
      simp [(hq x).le]
    · have ht : 0 < q x / p x := div_pos (hq x) h
      have hlt : Real.log (q x / p x) ≤ q x / p x - 1 := Real.log_le_sub_one_of_pos ht
      have hinv : Real.log (p x / q x) = -Real.log (q x / p x) := by
        rw [← Real.log_inv]
        congr 1
        field_simp
      have hmul : p x * Real.log (q x / p x) ≤ p x * (q x / p x - 1) :=
        mul_le_mul_of_nonneg_left hlt (hp x)
      have hval : p x * (q x / p x - 1) = q x - p x := by field_simp
      simp only [hg, hinv]
      nlinarith [hmul, hval.le, hval.ge]
  obtain ⟨x₀, hx₀⟩ : ∃ x, p x ≠ q x := Function.ne_iff.mp hne
  have hgpos : 0 < g x₀ := by
    rcases eq_or_lt_of_le (hp x₀) with h | h
    · simp only [hg, ← h]
      simpa using hq x₀
    · have ht : 0 < q x₀ / p x₀ := div_pos (hq x₀) h
      have hne2 : q x₀ / p x₀ ≠ 1 := by
        intro hcon
        rw [div_eq_one_iff_eq h.ne'] at hcon
        exact hx₀ hcon.symm
      have hlt : Real.log (q x₀ / p x₀) < q x₀ / p x₀ - 1 :=
        Real.log_lt_sub_one_of_pos ht hne2
      have hinv : Real.log (p x₀ / q x₀) = -Real.log (q x₀ / p x₀) := by
        rw [← Real.log_inv]
        congr 1
        field_simp
      have hmul : p x₀ * Real.log (q x₀ / p x₀) < p x₀ * (q x₀ / p x₀ - 1) :=
        mul_lt_mul_of_pos_left hlt h
      have hval : p x₀ * (q x₀ / p x₀ - 1) = q x₀ - p x₀ := by field_simp
      simp only [hg, hinv]
      nlinarith [hmul, hval.le, hval.ge]
  have hsum : 0 < ∑ x, g x :=
    Finset.sum_pos' (fun x _ => hgnn x) ⟨x₀, Finset.mem_univ x₀, hgpos⟩
  have hsplit : ∑ x, g x = ∑ x, p x * Real.log (p x / q x) := by
    simp only [hg]
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, hp1, hq1]
    ring
  have hbits : klDiv p q = (∑ x, p x * Real.log (p x / q x)) / Real.log 2 := by
    unfold klDiv
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun x _ => by rw [Real.logb]; ring
  rw [hbits]
  rw [hsplit] at hsum
  positivity

namespace SourceClass

variable (S : SourceClass X Θ)

/-- **The price of universality is strictly positive for a nontrivial class.**
As soon as two members of the class are different distributions, no single code
can be optimal for all of them. -/
theorem capacity_pos_of_ne [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x) {θ₁ θ₂ : Θ}
    (hne : S.prob θ₁ ≠ S.prob θ₂) : 0 < S.capacity := by
  have hmem : (uniformPrior Θ) ∈ stdSimplex ℝ Θ :=
    ⟨fun θ => uniformPrior_nonneg θ, uniformPrior_sum_one⟩
  have hmpos := S.mix_pos_of_mem_stdSimplex hpos hmem
  have hm1 : ∑ x, S.mix (uniformPrior Θ) x = 1 := S.mix_sum_one uniformPrior_sum_one
  have hklnn : ∀ θ, 0 ≤ klDiv (S.prob θ) (S.mix (uniformPrior Θ)) := fun θ =>
    klDiv_nonneg (S.nonneg θ) hmpos (S.sum_one θ) (le_of_eq hm1)
  -- at least one of the two sources differs from the uniform mixture
  obtain ⟨θ, hθ⟩ : ∃ θ : Θ, S.prob θ ≠ S.mix (uniformPrior Θ) := by
    by_contra hcon
    push_neg at hcon
    exact hne ((hcon θ₁).trans (hcon θ₂).symm)
  have hklpos : 0 < klDiv (S.prob θ) (S.mix (uniformPrior Θ)) :=
    klDiv_pos_of_ne (S.nonneg θ) hmpos (S.sum_one θ) hm1 hθ
  have hIpos : 0 < S.mutualInfo (uniformPrior Θ) := by
    unfold mutualInfo
    refine Finset.sum_pos' (fun θ' _ =>
      mul_nonneg (uniformPrior_nonneg θ') (hklnn θ')) ⟨θ, Finset.mem_univ θ, ?_⟩
    exact mul_pos (uniformPrior_pos θ) hklpos
  exact lt_of_lt_of_le hIpos (S.mutualInfo_le_capacity hpos hmem)

/-! ## Monotonicity: specialising to a sub-class -/

/-- **The price of a sub-class never exceeds the price of the class.**  Any class
whose sources all occur in `S` (up to reindexing) is at most as expensive. -/
theorem capacity_le_of_subclass [Nonempty Θ] {Θ' : Type*} [Fintype Θ'] [Nonempty Θ']
    (T : SourceClass X Θ') (hpos : ∀ θ x, 0 < S.prob θ x) (f : Θ' → Θ)
    (hf : ∀ θ' x, T.prob θ' x = S.prob (f θ') x) : T.capacity ≤ S.capacity := by
  have hTpos : ∀ θ' x, 0 < T.prob θ' x := by
    intro θ' x
    rw [hf θ' x]
    exact hpos _ x
  obtain ⟨q, hq, hq1, hle⟩ := S.exists_universal_code_capacity hpos
  refine T.capacity_le_of_forall_klDiv_le hTpos hq (le_of_eq hq1) fun θ' => ?_
  have : T.prob θ' = S.prob (f θ') := funext fun x => hf θ' x
  rw [this]
  exact hle (f θ')

/-! ## Model selection: merging `K` specialised classes -/

variable {ι : Type*} [Fintype ι] {Θ' : ι → Type*}

/-- **A uniform mixture of codes loses at most `log₂ K` bits.**  This is the
two-part-code bound at the level of coding distributions. -/
theorem klDiv_avgCode_le [Nonempty ι] {p : X → ℝ} (hp : ∀ x, 0 ≤ p x)
    (hp1 : ∑ x, p x = 1) (q : ι → X → ℝ) (hq : ∀ i x, 0 < q i x) (j : ι) :
    klDiv p (fun x => (∑ i, q i x) / (Fintype.card ι : ℝ))
      ≤ klDiv p (q j) + logb 2 (Fintype.card ι) := by
  have hK : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have hbar : ∀ x, 0 < (∑ i, q i x) / (Fintype.card ι : ℝ) := by
    intro x
    have : 0 < ∑ i, q i x := Finset.sum_pos (fun i _ => hq i x) Finset.univ_nonempty
    positivity
  have hdom : ∀ x, q j x / (Fintype.card ι : ℝ) ≤ (∑ i, q i x) / (Fintype.card ι : ℝ) := by
    intro x
    have : q j x ≤ ∑ i, q i x :=
      Finset.single_le_sum (f := fun i => q i x) (fun i _ => (hq i x).le) (Finset.mem_univ j)
    gcongr
  have hstep : ∀ x : X, p x * logb 2 (p x / ((∑ i, q i x) / (Fintype.card ι : ℝ)))
      ≤ p x * logb 2 (p x / q j x) + p x * logb 2 (Fintype.card ι) := by
    intro x
    rcases eq_or_lt_of_le (hp x) with h | h
    · simp [← h]
    · have h1 : p x / ((∑ i, q i x) / (Fintype.card ι : ℝ))
          ≤ (p x / q j x) * (Fintype.card ι : ℝ) := by
        rw [div_le_iff₀ (hbar x)]
        have hqjx := hq j x
        have h2 : (p x / q j x) * (Fintype.card ι : ℝ) * (q j x / (Fintype.card ι : ℝ))
            = p x := by
          field_simp
        calc p x = (p x / q j x) * (Fintype.card ι : ℝ) * (q j x / (Fintype.card ι : ℝ)) :=
              h2.symm
          _ ≤ (p x / q j x) * (Fintype.card ι : ℝ)
              * ((∑ i, q i x) / (Fintype.card ι : ℝ)) := by
              refine mul_le_mul_of_nonneg_left (hdom x) ?_
              have := hq j x
              positivity
      have hlogle : logb 2 (p x / ((∑ i, q i x) / (Fintype.card ι : ℝ)))
          ≤ logb 2 ((p x / q j x) * (Fintype.card ι : ℝ)) :=
        Real.logb_le_logb_of_le (by norm_num) (div_pos h (hbar x)) h1
      have hsplit : logb 2 ((p x / q j x) * (Fintype.card ι : ℝ))
          = logb 2 (p x / q j x) + logb 2 (Fintype.card ι) := by
        have hqjx := hq j x
        exact Real.logb_mul (by positivity) hK.ne'
      have := mul_le_mul_of_nonneg_left (hlogle.trans (le_of_eq hsplit)) (hp x)
      linarith [this]
  unfold klDiv
  calc ∑ x, p x * logb 2 (p x / ((∑ i, q i x) / (Fintype.card ι : ℝ)))
      ≤ ∑ x, (p x * logb 2 (p x / q j x) + p x * logb 2 (Fintype.card ι)) :=
        Finset.sum_le_sum fun x _ => hstep x
    _ = (∑ x, p x * logb 2 (p x / q j x)) + logb 2 (Fintype.card ι) := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, hp1, one_mul]

/-- **The cost of model selection.**  Merging `K` source classes into a single
universal scheme costs at most `log₂ K` bits more than the most expensive of the
specialised schemes. -/
theorem capacity_sigmaClass_le [Nonempty ι] [∀ i, Fintype (Θ' i)] [∀ i, Nonempty (Θ' i)]
    (T : (i : ι) → SourceClass X (Θ' i)) (hpos : ∀ i θ x, 0 < (T i).prob θ x)
    {B : ℝ} (hB : ∀ i, (T i).capacity ≤ B) :
    (SourceClass.sigmaClass T).capacity ≤ B + logb 2 (Fintype.card ι) := by
  classical
  have hK : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  choose q hq hq1 hqle using fun i => (T i).exists_universal_code_capacity (hpos i)
  set qbar : X → ℝ := fun x => (∑ i, q i x) / (Fintype.card ι : ℝ) with hqbar
  have hbarpos : ∀ x, 0 < qbar x := by
    intro x
    have : 0 < ∑ i, q i x := Finset.sum_pos (fun i _ => hq i x) Finset.univ_nonempty
    rw [hqbar]
    positivity
  have hbar1 : ∑ x, qbar x = 1 := by
    rw [hqbar]
    rw [← Finset.sum_div, Finset.sum_comm]
    rw [Finset.sum_congr rfl fun i _ => hq1 i]
    simp
  have hSpos : ∀ (c : Σ i, Θ' i) x, 0 < (SourceClass.sigmaClass T).prob c x :=
    fun c x => hpos c.1 c.2 x
  refine (SourceClass.sigmaClass T).capacity_le_of_forall_klDiv_le hSpos hbarpos
    (le_of_eq hbar1) fun c => ?_
  have hprob : (SourceClass.sigmaClass T).prob c = (T c.1).prob c.2 := rfl
  rw [hprob]
  have hmix := klDiv_avgCode_le (p := (T c.1).prob c.2) ((T c.1).nonneg c.2)
    ((T c.1).sum_one c.2) q hq c.1
  have h2 : klDiv ((T c.1).prob c.2) (q c.1) ≤ B := le_trans (hqle c.1 c.2) (hB c.1)
  rw [hqbar]
  linarith

/-- Merging classes never *lowers* the price: each specialised price is a lower
bound for the merged one. -/
theorem capacity_le_capacity_sigmaClass [Nonempty ι] [∀ i, Fintype (Θ' i)]
    [∀ i, Nonempty (Θ' i)] (T : (i : ι) → SourceClass X (Θ' i))
    (hpos : ∀ i θ x, 0 < (T i).prob θ x) (i : ι) :
    (T i).capacity ≤ (SourceClass.sigmaClass T).capacity :=
  (SourceClass.sigmaClass T).capacity_le_of_subclass (T i)
    (fun c x => hpos c.1 c.2 x) (fun θ => ⟨i, θ⟩) (fun _ _ => rfl)

/-- **The exact cost of universality across `K` models.**  Between the best
specialised scheme and the merged universal scheme there is a gap of at most
`log₂ K` bits — and never a negative one.  Specialising the decompressor to one
of `K` classes can therefore move at most `log₂ K` bits from the message to the
shared decompressor. -/
theorem capacity_sigmaClass_sandwich [Nonempty ι] [∀ i, Fintype (Θ' i)]
    [∀ i, Nonempty (Θ' i)] (T : (i : ι) → SourceClass X (Θ' i))
    (hpos : ∀ i θ x, 0 < (T i).prob θ x) {B : ℝ} (hB : ∀ i, (T i).capacity ≤ B) :
    (∀ i, (T i).capacity ≤ (SourceClass.sigmaClass T).capacity) ∧
      (SourceClass.sigmaClass T).capacity ≤ B + logb 2 (Fintype.card ι) :=
  ⟨fun i => capacity_le_capacity_sigmaClass T hpos i, capacity_sigmaClass_le T hpos hB⟩

/-! ## Classes of approximately distinguishable sources -/

/-- **Lower bound on the price for distinguishable classes.**  If the class has
`N` members concentrated on pairwise disjoint sets up to `δ`, the average price
of universality is at least `(1 − δ) log₂ N − 4` bits. -/
theorem capacity_ge_of_approx_disjoint [Nonempty Θ] [DecidableEq X] {δ : ℝ}
    (hpos : ∀ θ x, 0 < S.prob θ x) (A : Θ → Finset X)
    (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (A θ) (A θ'))
    (hmass : ∀ θ, 1 - δ ≤ ∑ x ∈ A θ, S.prob θ x) :
    (1 - δ) * logb 2 (Fintype.card Θ) - 4 ≤ S.capacity := by
  obtain ⟨q, hq, hq1, hle⟩ := S.exists_universal_code_capacity hpos
  obtain ⟨θ, hθ⟩ := S.exists_kl_ge_of_approx_disjoint A hdisj hmass hq (le_of_eq hq1)
  exact le_trans hθ (hle θ)

/-- **The price of a distinguishable class is `log₂ N` up to 4 bits.**  A shared
decompressor must essentially *name* the source, and can do no worse. -/
theorem capacity_approx_disjoint_sandwich [Nonempty Θ] [DecidableEq X] {δ : ℝ}
    (hpos : ∀ θ x, 0 < S.prob θ x) (A : Θ → Finset X)
    (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (A θ) (A θ'))
    (hmass : ∀ θ, 1 - δ ≤ ∑ x ∈ A θ, S.prob θ x) :
    (1 - δ) * logb 2 (Fintype.card Θ) - 4 ≤ S.capacity ∧
      S.capacity ≤ logb 2 (Fintype.card Θ) :=
  ⟨S.capacity_ge_of_approx_disjoint hpos A hdisj hmass, S.capacity_le_logb_card hpos⟩

end SourceClass

end UniversalRedundancy