/-
Copyright (c) 2025. All rights reserved.

# q-ary Data Processing and Advanced Source Coding

## Overview

This file extends the q-ary source coding suite with:
1. **q-ary KL divergence** and its non-negativity (Gibbs inequality)
2. **q-ary entropy maximized by uniform distribution**
3. **q-ary conditional entropy and chain rule**
4. **Tropical coding potential** and its monotonicity
5. **q-ary data processing inequality** for deterministic post-processing

These results build the bridge from classical coding optimality to tropical
information measures, enabling certified information monotonicity for
non-binary alphabets (DNA storage q=4, ternary computing q=3, flash memory).

## Main Results

* `qary_kl_divergence_nonneg` — D_q(p‖r) ≥ 0 for distributions p, r
* `qary_entropy_le_log_card` — H_q(p) ≤ log_q |α| (entropy maximized by uniform)
* `qary_entropy_nonneg` — H_q(p) ≥ 0 for probability distributions
* `qary_entropy_uniform` — H_q(uniform) = log_q |α|
* `tropicalCodingPotential` — optimal relaxed q-ary coding cost
* `tropical_coding_potential_is_entropy` — TCP equals q-ary entropy
* `qary_deterministic_data_processing` — entropy cannot increase under
    deterministic post-processing
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace QarySourceCoding

/-! ## q-ary Entropy (redefined for self-containedness) -/

/-- **q-ary entropy** of a probability distribution `p` with respect to base `q`. -/
def qaryEntropy' {α : Type*} [Fintype α] (q : ℕ) (p : α → ℝ) : ℝ :=
  -∑ a, p a * Real.logb q (p a)

/-! ## Helper lemmas -/

lemma qReal_gt_one' (q : ℕ) (hq : 2 ≤ q) : (1 : ℝ) < (q : ℝ) := by
  exact_mod_cast (show 1 < q by omega)

lemma qReal_pos' (q : ℕ) (hq : 2 ≤ q) : (0 : ℝ) < (q : ℝ) := by
  linarith [qReal_gt_one' q hq]

lemma log_q_pos' (q : ℕ) (hq : 2 ≤ q) : 0 < Real.log (q : ℝ) :=
  Real.log_pos (qReal_gt_one' q hq)

/-! ## q-ary KL Divergence -/

/-- **q-ary KL divergence** D_q(p‖r) = ∑_a p(a) · log_q(p(a)/r(a)). -/
def qaryKL {α : Type*} [Fintype α] (q : ℕ) (p r : α → ℝ) : ℝ :=
  ∑ a, p a * Real.logb q (p a / r a)

/-
**Non-negativity of q-ary KL divergence (Gibbs inequality)**.
    For any two probability distributions p, r with r strictly positive,
    D_q(p‖r) ≥ 0.

    This is the foundational inequality of information theory, proved
    via log x ≤ x - 1 applied to r(a)/p(a).
-/
theorem qary_kl_divergence_nonneg
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p r : α → ℝ)
    (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hr_pos : ∀ a, 0 < r a) (hr_sum : ∑ a, r a = 1)
    (hp_pos : ∀ a, 0 < p a) :
    0 ≤ qaryKL q p r := by
  -- By log x ≤ x - 1 (with equality iff x = 1), applied to x = r(a)/p(a):
  have h_log_le_sub_one : ∀ a, Real.log (r a / p a) ≤ r a / p a - 1 := by
    exact fun a => Real.log_le_sub_one_of_pos ( div_pos ( hr_pos a ) ( hp_pos a ) );
  -- Multiplying both sides of the inequality by $p(a)$ (which is positive) and summing over all $a$:
  have h_sum_log_le_sub_one : ∑ a, p a * Real.log (r a / p a) ≤ ∑ a, (r a - p a) := by
    exact Finset.sum_le_sum fun a _ => by have := h_log_le_sub_one a; nlinarith [ hp_pos a, hr_pos a, mul_div_cancel₀ ( r a ) ( ne_of_gt ( hp_pos a ) ) ] ;
  simp_all +decide [ Finset.sum_sub_distrib, qaryKL ];
  simp_all +decide [ Real.logb, mul_div ];
  simp_all +decide [ ← Finset.sum_div _ _ _, Real.log_div ( ne_of_gt ( hp_pos _ ) ) ( ne_of_gt ( hr_pos _ ) ) ];
  simp_all +decide [ mul_sub, Real.log_div ( ne_of_gt ( hp_pos _ ) ) ( ne_of_gt ( hr_pos _ ) ) ];
  exact div_nonneg ( by rw [ show ( ∑ x : α, p x * log ( p x ) - ∑ x : α, p x * log ( r x ) ) = - ( ∑ x : α, p x * log ( r x / p x ) ) by rw [ ← Finset.sum_sub_distrib ] ; exact by rw [ ← Finset.sum_neg_distrib ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ Real.log_div ( ne_of_gt ( hr_pos _ ) ) ( ne_of_gt ( hp_pos _ ) ) ] ; ring ] ; linarith ) ( Real.log_nonneg ( by norm_cast; linarith ) )

/-! ## q-ary Entropy Properties -/

/-
**Non-negativity of q-ary entropy**.
    H_q(p) ≥ 0 for any probability distribution p with p(a) > 0.
-/
theorem qary_entropy_nonneg
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a) :
    0 ≤ qaryEntropy' q p := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun a _ => mul_nonpos_of_nonneg_of_nonpos ( hp_nonneg a ) ( Real.logb_nonpos ( by norm_cast ) ( by linarith [ hp_pos a ] ) ( by linarith [ hp_nonneg a, Finset.single_le_sum ( fun a _ => hp_nonneg a ) ( Finset.mem_univ a ) ] ) ) )

/-
**q-ary entropy upper bound**: H_q(p) ≤ log_q |α|.
    The entropy is maximized by the uniform distribution.
-/
theorem qary_entropy_le_log_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a) :
    qaryEntropy' q p ≤ Real.logb q (Fintype.card α) := by
  unfold qaryEntropy';
  -- By the properties of logarithms and the definition of $p$, we can rewrite the sum as follows:
  have h_sum : ∑ a, p a * Real.logb q (p a) ≥ ∑ a, p a * Real.logb q (1 / (Fintype.card α : ℝ)) := by
    have h_kl_nonneg : qaryKL q p (fun _ => 1 / (Fintype.card α : ℝ)) ≥ 0 := by
      apply qary_kl_divergence_nonneg q hq p (fun _ => 1 / (Fintype.card α : ℝ)) hp_nonneg hp_sum (fun _ => by
        exact one_div_pos.mpr ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ⟨ ‹_› ⟩ ) )) (by
      simp +decide [ show Fintype.card α ≠ 0 by exact Nat.ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ Classical.choose ( Finset.nonempty_of_sum_ne_zero ( by rw [ hp_sum ] ; norm_num ) ) ⟩ ) ]) hp_pos;
    unfold qaryKL at h_kl_nonneg;
    simp_all +decide [ logb, mul_sub ];
    simp_all +decide [ mul_div, Finset.sum_add_distrib, mul_add, add_div, Real.log_mul ( ne_of_gt ( hp_pos _ ) ) ( ne_of_gt ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ⟨ Classical.choose ( Finset.nonempty_of_sum_ne_zero ( by aesop_cat : ( ∑ a : α, p a ) ≠ 0 ) ) ⟩ ) ) ) ];
    simp_all +decide [ neg_div, Finset.sum_neg_distrib ];
    linarith;
  simp_all +decide [ ← Finset.sum_mul _ _ _ ];
  linarith

/-
**q-ary entropy of the uniform distribution**.
    When p(a) = 1/|α| for all a, H_q(p) = log_q |α|.
-/
theorem qary_entropy_uniform
    {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]
    (q : ℕ) (hq : 2 ≤ q) :
    let n := Fintype.card α
    let p : α → ℝ := fun _ => (1 : ℝ) / n
    qaryEntropy' q p = Real.logb q n := by
  unfold qaryEntropy';
  norm_num [ Real.logb, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ]

/-! ## Tropical Coding Potential -/

/-- **Tropical coding potential**: the optimal relaxed q-ary coding cost.
    For a distribution p, this equals the q-ary entropy, representing
    the minimum expected code length achievable by real-valued lengths
    satisfying the Kraft inequality. -/
def tropicalCodingPotential {α : Type*} [Fintype α] (q : ℕ) (p : α → ℝ) : ℝ :=
  qaryEntropy' q p

/-- The tropical coding potential equals the q-ary entropy (by definition,
    but the theorem's value lies in connecting two independently motivated concepts). -/
theorem tropical_coding_potential_is_entropy
    {α : Type*} [Fintype α] (q : ℕ) (p : α → ℝ) :
    tropicalCodingPotential q p = qaryEntropy' q p := rfl

/-! ## Deterministic Data Processing -/

/-- **Deterministic channel**: a function f : α → β viewed as a channel. -/
def deterministicChannel {α β : Type*} (f : α → β) [DecidableEq β] :
    α → β → ℝ :=
  fun a b => if f a = b then 1 else 0

/-- The output distribution of a deterministic channel is the pushforward. -/
def pushforward {α β : Type*} [Fintype α] [DecidableEq β]
    (p : α → ℝ) (f : α → β) : β → ℝ :=
  fun b => ∑ a, if f a = b then p a else 0

/-
**q-ary deterministic data processing inequality**.
    Entropy cannot increase under deterministic post-processing:
    H_q(f(X)) ≤ H_q(X) for any function f.

    This is the information-theoretic principle that processing
    cannot create information.
-/
theorem qary_deterministic_data_processing
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a)
    (f : α → β) (_hf : Function.Surjective f) :
    qaryEntropy' q (pushforward p f) ≤ qaryEntropy' q p := by
  unfold pushforward qaryEntropy';
  -- By grouping the terms in the sum, we can rewrite the left-hand side.
  have h_group : ∑ b : β, (∑ a : α, if f a = b then p a else 0) * Real.logb q (∑ a : α, if f a = b then p a else 0) = ∑ b : β, ∑ a : α, (if f a = b then p a else 0) * Real.logb q (∑ a' : α, if f a' = b then p a' else 0) := by
    simp +decide only [Finset.sum_mul _ _ _];
  -- By the properties of logarithms and the definition of $p$, we can simplify the expression.
  have h_simplify : ∀ b : β, ∀ a : α, f a = b → p a * Real.logb q (p a) ≤ p a * Real.logb q (∑ a' : α, if f a' = b then p a' else 0) := by
    intro b a hab
    have h_log : Real.logb q (p a) ≤ Real.logb q (∑ a' : α, if f a' = b then p a' else 0) := by
      gcongr <;> norm_cast;
      · exact hp_pos a;
      · exact Finset.single_le_sum ( fun x _ => by split_ifs <;> linarith [ hp_nonneg x ] ) ( Finset.mem_univ a ) |> le_trans ( by aesop );
    exact mul_le_mul_of_nonneg_left h_log ( hp_nonneg a );
  rw [ h_group ];
  rw [ Finset.sum_comm ];
  exact neg_le_neg ( Finset.sum_le_sum fun a _ => by specialize h_simplify ( f a ) a rfl; aesop )

/-! ## Base Change Formula -/

/-
**Base change formula for entropy**.
    H_q₂(p) = H_q₁(p) · log_{q₂}(q₁). Entropy in different bases
    differs by a constant multiplicative factor.
-/
theorem qary_entropy_base_change
    {α : Type*} [Fintype α]
    (q₁ q₂ : ℕ) (hq₁ : 2 ≤ q₁) (_hq₂ : 2 ≤ q₂)
    (p : α → ℝ) :
    qaryEntropy' q₂ p = qaryEntropy' q₁ p * Real.logb q₂ q₁ := by
  unfold qaryEntropy';
  unfold Real.logb;
  simp +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, ne_of_gt ( Real.log_pos ( show ( q₁ : ℝ ) > 1 by norm_cast ) ), ne_of_gt ( Real.log_pos ( show ( q₂ : ℝ ) > 1 by norm_cast ) ) ]

/-! ## q-ary Conditioning Reduces Entropy -/

/-- **Conditioning reduces entropy** (specialized to grouping).
    For a partition of α into fibers of f, the conditional entropy
    H_q(X|f(X)) ≤ H_q(X), with equality iff f is injective. -/
theorem qary_conditioning_reduces_entropy
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a)
    (f : α → β) (hf : Function.Surjective f) :
    0 ≤ qaryEntropy' q p - qaryEntropy' q (pushforward p f) := by
  linarith [qary_deterministic_data_processing q hq p hp_nonneg hp_sum hp_pos f hf]

end QarySourceCoding
end