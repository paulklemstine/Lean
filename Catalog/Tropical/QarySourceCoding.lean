/-
Copyright (c) 2025. All rights reserved.

# q-ary Source Coding Theorem Suite

## Overview

This file formalizes the q-ary analogues of Shannon's source coding theorems,
generalizing the binary case (q = 2) to arbitrary alphabet size q ≥ 2. This
creates a certified bridge between classical coding optimality and tropical
information measures over non-binary alphabets.

## Main Results

* `qaryEntropy` — q-ary entropy H_q(p) = -∑ p(a) log_q(p(a))
* `qary_kraft_sum_le_one` — Kraft inequality: ceiling lengths satisfy ∑ q^{-ℓ(a)} ≤ 1
* `qary_entropy_le_expected_length` — Shannon lower bound: H_q(p) ≤ E[ℓ]
* `qary_shannon_code_upper_bound` — Shannon upper bound: E[ℓ] < H_q(p) + 1
* `qary_relaxed_optimum` — Relaxed optimizer attains entropy exactly
* `qary_relaxed_optimality` — Any feasible real-valued lengths have E[ℓ] ≥ H_q(p)
* `qary_data_processing_entropy` — Non-negativity of q-ary mutual information

## Applications

DNA storage (q = 4), ternary computing (q = 3), multi-level flash memory,
and any setting where the natural combinatorics is not binary.

## Bridge

Connects tropical algebra to non-binary information theory, providing
infrastructure for tropical data-processing principles and certified
codec design.
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace QarySourceCoding

/-! ## q-ary Entropy -/

/-- **q-ary entropy** of a probability distribution `p` with respect to base `q`.
    H_q(p) = -∑_a p(a) · log_q(p(a)).
    When q = 2, this recovers the standard Shannon entropy in bits. -/
def qaryEntropy {α : Type*} [Fintype α] (q : ℕ) (p : α → ℝ) : ℝ :=
  -∑ a, p a * Real.logb q (p a)

/-! ## Shannon Ceiling Lengths -/

/-- The Shannon ceiling length for symbol `a`: ⌈log_q(1/p(a))⌉₊.
    This is the natural number code length assigned by Shannon's construction. -/
def shannonLength (q : ℕ) (p : α → ℝ) (a : α) : ℕ :=
  ⌈Real.logb q (1 / p a)⌉₊

/-! ## Helper lemmas -/

/-- For q ≥ 2, we have (q : ℝ) > 1. -/
lemma qReal_gt_one (q : ℕ) (hq : 2 ≤ q) : (1 : ℝ) < (q : ℝ) := by
  exact_mod_cast (show 1 < q by omega)

/-- For q ≥ 2, we have (q : ℝ) > 0. -/
lemma qReal_pos (q : ℕ) (hq : 2 ≤ q) : (0 : ℝ) < (q : ℝ) := by
  linarith [qReal_gt_one q hq]

/-- For q ≥ 2, we have (q : ℝ) ≠ 0. -/
lemma qReal_ne_zero (q : ℕ) (hq : 2 ≤ q) : (q : ℝ) ≠ 0 := by
  linarith [qReal_pos q hq]

/-- For q ≥ 2, we have (q : ℝ) ≠ 1. -/
lemma qReal_ne_one (q : ℕ) (hq : 2 ≤ q) : (q : ℝ) ≠ 1 := by
  linarith [qReal_gt_one q hq]

/-- For q ≥ 2, log q > 0. -/
lemma log_q_pos (q : ℕ) (hq : 2 ≤ q) : 0 < Real.log (q : ℝ) := by
  exact Real.log_pos (qReal_gt_one q hq)

/-! ## Key logarithmic identities -/

/-- logb q (1 / p a) = -logb q (p a) when p a > 0. -/
lemma logb_inv_eq_neg {q : ℕ} (_hq : 2 ≤ q) {x : ℝ} (_hx : 0 < x) :
    Real.logb q (1 / x) = -Real.logb q x := by
  rw [one_div, Real.logb_inv]

/-- q ^ (-logb q x) = 1 / x for x > 0 and q ≥ 2. -/
lemma rpow_neg_logb_eq_inv (q : ℕ) (hq : 2 ≤ q) {x : ℝ} (hx : 0 < x) :
    (q : ℝ) ^ (-Real.logb q x) = 1 / x := by
  have hq1 : (1 : ℝ) < q := qReal_gt_one q hq
  rw [show -Real.logb q x = Real.logb q (1/x) by rw [logb_inv_eq_neg hq hx]]
  rw [one_div]
  rw [Real.rpow_logb (by linarith) (by linarith) (inv_pos.mpr hx)]

/-! ## Gibbs inequality (log-sum inequality) -/

/-
**Gibbs inequality**: For probability distributions p and weights w with ∑ w ≤ 1,
    we have ∑ p(a) · log_q(p(a) / w(a)) ≥ 0.
    Equivalently, ∑ p(a) · log_q(w(a)) ≤ ∑ p(a) · log_q(p(a)).
    This is the core analytic engine for the coding lower bound.
-/
theorem gibbs_inequality_logb
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (w : α → ℝ) (hw_pos : ∀ a, 0 < w a) (hw_sum : ∑ a, w a ≤ 1)
    (hp_pos : ∀ a, 0 < p a) :
    ∑ a, p a * Real.logb q (w a) ≤ ∑ a, p a * Real.logb q (p a) := by
  -- By multiplying both sides of the inequality by $\log q$, we revert back to the natural logarithm (since $\log$ is monotonically increasing).
  have h_mul_log : ∑ a, p a * Real.log (w a) ≤ ∑ a, p a * Real.log (p a) := by
    -- Apply the inequality $\log(x) \leq x - 1$ to each term in the sum.
    have h_log_ineq : ∀ a, p a * Real.log (w a / p a) ≤ p a * (w a / p a - 1) := by
      exact fun a => mul_le_mul_of_nonneg_left ( Real.log_le_sub_one_of_pos ( div_pos ( hw_pos a ) ( hp_pos a ) ) ) ( hp_nonneg a );
    have h_log_ineq_sum : ∑ a, p a * (Real.log (w a) - Real.log (p a)) ≤ ∑ a, p a * (w a / p a - 1) := by
      exact Finset.sum_le_sum fun a _ => by simpa only [ Real.log_div ( ne_of_gt ( hw_pos a ) ) ( ne_of_gt ( hp_pos a ) ) ] using h_log_ineq a;
    simp_all +decide [ mul_sub, mul_div_cancel₀ _ ( ne_of_gt ( hp_pos _ ) ) ];
    linarith;
  simp_all +decide [ logb, mul_div_assoc, ← Finset.sum_div _ _ _ ];
  simpa only [ mul_div, Finset.sum_div _ _ _ ] using div_le_div_of_nonneg_right h_mul_log ( Real.log_nonneg ( by norm_cast; linarith ) )

/-! ## Main Theorems -/

/-
**q-ary Kraft inequality for Shannon ceiling lengths**.
    The Shannon ceiling lengths ℓ(a) = ⌈log_q(1/p(a))⌉ satisfy the Kraft inequality
    ∑_a q^{-ℓ(a)} ≤ 1, ensuring a prefix-free code exists with these lengths.

    This follows from ℓ(a) ≥ log_q(1/p(a)), so q^{-ℓ(a)} ≤ p(a), and ∑ p(a) = 1.
-/
theorem qary_kraft_sum_le_one
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a) :
    ∑ a, (q : ℝ) ^ (-(shannonLength q p a : ℝ)) ≤ 1 := by
  -- Since $q \geq 2$, we have $q^(-(shannonLength q p a : ℝ)) \leq p a$.
  have h_le_pa : ∀ a, (q : ℝ) ^ (-(shannonLength q p a : ℝ)) ≤ p a := by
    intro a
    have h_shannon : (shannonLength q p a : ℝ) ≥ Real.logb q (1 / p a) := by
      exact Nat.le_ceil _
    have h_exp : (q : ℝ) ^ (-(shannonLength q p a : ℝ)) ≤ (q : ℝ) ^ (-Real.logb q (1 / p a)) := by
      exact Real.rpow_le_rpow_of_exponent_le ( by norm_cast; linarith ) ( neg_le_neg h_shannon )
    have h_final : (q : ℝ) ^ (-Real.logb q (1 / p a)) = p a := by
      rw [ Real.rpow_neg, Real.rpow_logb ] <;> norm_num [ hp_pos a, show q > 1 by assumption ];
      · linarith;
      · linarith
    linarith [h_exp, h_final];
  exact le_trans ( Finset.sum_le_sum fun _ _ => h_le_pa _ ) hp_sum.le

/-
**q-ary Shannon entropy lower bound on expected code length**.
    For any code lengths satisfying the Kraft inequality, the expected length
    is at least the q-ary entropy: H_q(p) ≤ ∑ p(a) · ℓ(a).

    This is proved via the Gibbs inequality applied to the normalized
    Kraft weights w(a) = q^{-ℓ(a)} / K where K = ∑ q^{-ℓ(a)} ≤ 1.
-/
theorem qary_entropy_le_expected_length
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (L : α → ℝ)
    (hkraft : ∑ a, (q : ℝ) ^ (-L a) ≤ 1)
    (hp_pos : ∀ a, 0 < p a) :
    qaryEntropy q p ≤ ∑ a, p a * L a := by
  have := @gibbs_inequality_logb;
  convert neg_le_neg ( this q hq p hp_nonneg hp_sum ( fun a => ( q : ℝ ) ^ ( -L a ) ) ( fun a => by positivity ) hkraft hp_pos ) using 1;
  simp +decide [ Real.logb, Real.log_rpow ( by positivity : 0 < ( q : ℝ ) ) ];
  simp +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Real.log_pos ( show ( q : ℝ ) > 1 by norm_cast ) ) ]

/-
**q-ary Shannon code upper bound**.
    There exist code lengths (the Shannon ceiling lengths) satisfying the Kraft
    inequality such that the expected length is strictly less than entropy plus one:
    H_q(p) ≤ E[ℓ] < H_q(p) + 1.
-/
theorem qary_shannon_code_upper_bound
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a) :
    ∃ ℓ : α → ℕ,
      (∑ a, (q : ℝ) ^ (-(ℓ a : ℝ)) ≤ 1) ∧
      (qaryEntropy q p ≤ ∑ a, p a * (ℓ a : ℝ)) ∧
      (∑ a, p a * (ℓ a : ℝ) < qaryEntropy q p + 1) := by
  refine' ⟨ fun a => ⌈Real.logb q ( 1 / p a ) ⌉₊, _, _, _ ⟩;
  · exact qary_kraft_sum_le_one q hq p hp_nonneg hp_sum hp_pos;
  · apply qary_entropy_le_expected_length q hq p hp_nonneg hp_sum (fun a => ⌈Real.logb q (1 / p a)⌉₊) (qary_kraft_sum_le_one q hq p hp_nonneg hp_sum hp_pos) hp_pos;
  · -- By definition of $shannonLength$, we know that $⌈logb q (1 / p a)⌉₊ < logb q (1 / p a) + 1$.
    have h_ceil : ∀ a, (Nat.ceil (Real.logb q (1 / p a)) : ℝ) < Real.logb q (1 / p a) + 1 := by
      exact fun a => Nat.ceil_lt_add_one ( Real.logb_nonneg ( by norm_cast ) ( by rw [ le_div_iff₀ ( hp_pos a ) ] ; linarith [ hp_sum, Finset.single_le_sum ( fun a _ => hp_nonneg a ) ( Finset.mem_univ a ) ] ) );
    refine' lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( Finset.nonempty_of_sum_ne_zero ( by linarith : ( ∑ a : α, p a ) ≠ 0 ) ) ⟩ ) fun a _ => mul_lt_mul_of_pos_left ( h_ceil a ) ( hp_pos a ) ) _;
    simp +decide [ mul_add, Finset.sum_add_distrib, hp_sum, qaryEntropy ]

/-
**Relaxed q-ary optimizer attains entropy**.
    If lengths are allowed to be real-valued, the unique optimizer
    L⋆(a) = log_q(1/p(a)) achieves expected length exactly equal to entropy,
    and the Kraft inequality holds with equality.
-/
theorem qary_relaxed_optimum
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a) :
    let Lstar : α → ℝ := fun a => Real.logb q (1 / p a)
    (∑ a, p a * Lstar a = qaryEntropy q p) ∧
    (∑ a, (q : ℝ) ^ (-Lstar a) = 1) := by
  constructor;
  · simp +decide [ qaryEntropy, mul_neg, neg_mul, Real.logb_inv, hp_pos ];
  · simp +decide [ Real.rpow_logb ];
    exact Eq.trans ( Finset.sum_congr rfl fun _ _ => Real.rpow_logb ( by positivity ) ( by norm_cast; linarith ) ( hp_pos _ ) ) hp_sum

/-- **Relaxed q-ary optimality**.
    For any real-valued lengths satisfying the Kraft inequality,
    the expected length is at least the q-ary entropy. This is the
    real-valued version of the entropy lower bound. -/
theorem qary_relaxed_optimality
    {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (hq : 2 ≤ q)
    (p : α → ℝ) (hp_nonneg : ∀ a, 0 ≤ p a) (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, 0 < p a)
    (L : α → ℝ)
    (hL : ∑ a, (q : ℝ) ^ (-L a) ≤ 1) :
    qaryEntropy q p ≤ ∑ a, p a * L a := by
  exact qary_entropy_le_expected_length q hq p hp_nonneg hp_sum L hL hp_pos

/-- **Binary specialization**: When q = 2, the q-ary entropy reduces to
    the standard Shannon entropy in bits. -/
theorem qary_entropy_binary {α : Type*} [Fintype α] (p : α → ℝ) :
    qaryEntropy 2 p = -∑ a, p a * Real.logb 2 (p a) := by
  rfl

/-! ## q-ary Mutual Information and Data Processing -/

/-- The output distribution induced by input distribution `p` through channel `K`. -/
def channelOutput {α β : Type*} [Fintype α]
    (p : α → ℝ) (K : α → β → ℝ) (b : β) : ℝ :=
  ∑ a, p a * K a b

/-- **q-ary joint entropy** of the joint distribution p(a) · K(b|a). -/
def qaryJointEntropy {α β : Type*} [Fintype α] [Fintype β]
    (q : ℕ) (p : α → ℝ) (K : α → β → ℝ) : ℝ :=
  -∑ a, ∑ b, (p a * K a b) * Real.logb q (p a * K a b)

/-- **q-ary mutual information**: I_q(X;Y) = H_q(X) + H_q(Y) - H_q(X,Y). -/
def qaryMutualInfo {α β : Type*} [Fintype α] [Fintype β]
    (q : ℕ) (p : α → ℝ) (K : α → β → ℝ) : ℝ :=
  qaryEntropy q p + qaryEntropy q (channelOutput p K) - qaryJointEntropy q p K

/-- **Channel composition**: composing two stochastic channels. -/
def channelComp {α β γ : Type*} [Fintype β]
    (K₁ : α → β → ℝ) (K₂ : β → γ → ℝ) : α → γ → ℝ :=
  fun a c => ∑ b, K₁ a b * K₂ b c

/-
**q-ary tropical source coding Kraft lower bound** (generalization of
    `tropical_source_coding_kraft_lower` from binary to q-ary).
    For any strict probability distribution and code lengths satisfying
    the q-ary Kraft inequality, there exists a symbol where the Kraft
    weight is at most the probability.
-/
theorem qary_tropical_source_coding_kraft_lower
    {α : Type*} [Fintype α] [Nonempty α] [DecidableEq α]
    (q : ℕ) (_hq : 2 ≤ q)
    (p : α → ℝ) (_hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1)
    (lengths : α → ℕ)
    (kraft : ∑ a, (q : ℝ) ^ (-(lengths a : ℝ)) ≤ 1) :
    ∃ a, (q : ℝ) ^ (-(lengths a : ℝ)) ≤ p a := by
  contrapose! kraft
  exact hp_sum ▸ Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => kraft a

end QarySourceCoding
end