/-
Copyright (c) 2025 Tropical Information Theory Project. All rights reserved.

# Tropical Source Coding: Kraft Inequality and Shannon Coding Theorems

This file establishes the fundamental bridge between tropical algebra and
source coding theory. The central insight: the tropical potential (negative
log-probability) is the exact optimizer of the relaxed source coding
functional, and its integer rounding produces Shannon-optimal prefix codes.

## Main Results

* `shannon_lengths_kraft_admissible` — Shannon ceiling lengths satisfy the Kraft inequality
* `shannon_lengths_expected_upper` — Expected Shannon code length < entropy + 1
* `real_relaxed_source_coding_optimizer` — Source coding lower bound for real lengths
* `tropical_code_expected_length_sandwich` — H ≤ E[ℓ] < H + 1
* `tropical_product_source_additivity` — Entropy is additive for product sources
* `relaxed_optimizer_achieves_entropy` — Ideal lengths achieve entropy exactly
* `kraft_product_admissible` — Product codes preserve Kraft admissibility

## References

The theorems formalize classical results from Shannon's source coding theory,
recast in the language of tropical/idempotent analysis. The key bridge:
minimizing expected code length under Kraft constraints is equivalent to
minimizing a tropical potential, with the optimal solution being the
negative log-probability (the "tropical energy").
-/

import Mathlib

open Finset Real BigOperators

noncomputable section

namespace TropicalSourceCoding

/-! ## Core Definitions -/

/-- Shannon entropy in bits: H₂(p) = -∑ₐ p(a) · log₂(p(a)). -/
def entropyBase2 {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  - ∑ a, p a * Real.logb 2 (p a)

/-- Kraft sum for integer code lengths: ∑ₐ 2^(-ℓ(a)). -/
def kraftSum {α : Type*} [Fintype α] (ℓ : α → ℕ) : ℝ :=
  ∑ a, (2 : ℝ) ^ (-(ℓ a : ℤ))

/-- Kraft sum for real code lengths using rpow: ∑ₐ 2^(-L(a)). -/
def kraftSumReal {α : Type*} [Fintype α] (L : α → ℝ) : ℝ :=
  ∑ a, (2 : ℝ) ^ (- L a)

/-- Shannon code length: ℓ(a) = ⌈log₂(1/p(a))⌉₊. -/
def shannonLength {α : Type*} [Fintype α] (p : α → ℝ) (a : α) : ℕ :=
  Nat.ceil (Real.logb 2 (1 / p a))

/-! ## Pointwise Helper Lemmas -/

/-- logb 2 (1/p) = -logb 2 p for p > 0. -/
lemma logb_one_div {p : ℝ} (hp : 0 < p) :
    Real.logb 2 (1 / p) = -Real.logb 2 p := by
  rw [one_div, Real.logb_inv]

/-- For p > 0, 2 ^ (logb 2 p) = p. -/
lemma rpow_logb_two {p : ℝ} (hp : 0 < p) :
    (2 : ℝ) ^ (Real.logb 2 p) = p :=
  Real.rpow_logb (by norm_num) (by norm_num) hp

/-- For 0 < p ≤ 1, logb 2 (1/p) ≥ 0. -/
lemma logb_one_div_nonneg {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    0 ≤ Real.logb 2 (1 / p) := by
  rw [logb_one_div hp]
  exact neg_nonneg.mpr (Real.logb_nonpos (by norm_num) (le_of_lt hp) hp1)

/-
The pointwise Kraft bound: 2^(-⌈logb 2 (1/p)⌉) ≤ p for 0 < p ≤ 1.
-/
lemma zpow_neg_ceil_le {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    (2 : ℝ) ^ (-(Nat.ceil (Real.logb 2 (1 / p)) : ℤ)) ≤ p := by
  -- Since $2 \ge 1$, $zpow$ is monotone: $2^{-⌈logb 2 (1/p)⌉} ≤ 2^{-logb 2 (1/p)}$
  have hmono : (2 : ℝ) ^ (-Nat.ceil (Real.logb 2 (1 / p)) : ℤ) ≤ (2 : ℝ) ^ (-Real.logb 2 (1 / p)) := by
    exact le_trans ( by norm_num ) ( Real.rpow_le_rpow_of_exponent_le ( by norm_num ) ( neg_le_neg ( Nat.le_ceil _ ) ) );
  convert hmono using 1 ; norm_num [ Real.rpow_neg, Real.rpow_logb, hp, hp1 ]

/-- ⌈logb 2 (1/p)⌉ < logb 2 (1/p) + 1 for 0 < p ≤ 1. -/
lemma ceil_logb_lt_add_one {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    (Nat.ceil (Real.logb 2 (1 / p)) : ℝ) < Real.logb 2 (1 / p) + 1 :=
  Nat.ceil_lt_add_one (logb_one_div_nonneg hp hp1)

/-- p ≤ 1 when p is from a positive probability distribution. -/
lemma prob_le_one {α : Type*} [Fintype α] (p : α → ℝ)
    (hp_pos : ∀ a, 0 < p a) (hp_sum : ∑ a, p a = 1) (a : α) :
    p a ≤ 1 := by
  calc p a ≤ ∑ b, p b := single_le_sum (fun b _ => le_of_lt (hp_pos b)) (mem_univ a)
  _ = 1 := hp_sum

/-! ## Theorem 1: Shannon Ceiling Lengths -/

/-
**Kraft admissibility**: Shannon ceiling lengths satisfy ∑ 2^(-ℓ(a)) ≤ 1.

    The proof follows from the pointwise bound 2^(-⌈log₂(1/p(a))⌉) ≤ p(a)
    and the fact that ∑ p(a) = 1.
-/
theorem shannon_lengths_kraft_admissible
    {α : Type*} [Fintype α]
    (p : α → ℝ)
    (hp_pos : ∀ a, 0 < p a)
    (hp_sum : ∑ a, p a = 1) :
    kraftSum (shannonLength p) ≤ 1 := by
  convert Finset.sum_le_sum fun a _ => zpow_neg_ceil_le ( hp_pos a ) ( prob_le_one p hp_pos hp_sum a ) using 1;
  exact hp_sum.symm

/-
**Upper bound**: Expected Shannon code length < entropy + 1.
-/
theorem shannon_lengths_expected_upper
    {α : Type*} [Fintype α] [Nonempty α]
    (p : α → ℝ)
    (hp_pos : ∀ a, 0 < p a)
    (hp_sum : ∑ a, p a = 1) :
    ∑ a, p a * (shannonLength p a : ℝ) < entropyBase2 p + 1 := by
  convert Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => mul_lt_mul_of_pos_left ( ( show ( shannonLength p a : ℝ ) < Real.logb 2 ( 1 / p a ) + 1 from ?_ ) ) ( hp_pos a ) using 1;
  · simp +decide [ mul_add, Finset.sum_add_distrib, hp_sum ];
    rfl;
  · exact Nat.ceil_lt_add_one ( Real.logb_nonneg ( by norm_num ) ( by rw [ le_div_iff₀ ( hp_pos a ) ] ; linarith [ hp_pos a, hp_sum, Finset.single_le_sum ( fun a _ => le_of_lt ( hp_pos a ) ) ( Finset.mem_univ a ) ] ) )

/-! ## Theorem 2: Source Coding Lower Bound -/

/-
**Gibbs inequality for source coding**: For any real code lengths L with
    Kraft sum ≤ 1, the expected code length is at least the entropy.

    This is the variational characterization: the tropical potential
    L⋆(a) = log₂(1/p(a)) is the unique minimizer of E_p[L] subject to
    the Kraft constraint ∑ 2^(-L(a)) ≤ 1.
-/
theorem real_relaxed_source_coding_optimizer
    {α : Type*} [Fintype α]
    (p : α → ℝ)
    (hp_nonneg : ∀ a, 0 ≤ p a)
    (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, p a > 0) :
    ∀ L : α → ℝ,
      (kraftSumReal L ≤ 1) →
      entropyBase2 p ≤ ∑ a, p a * L a := by
  intro L hL
  set q : α → ℝ := fun a => (2 : ℝ) ^ (-L a)
  have hq_sum : ∑ a, q a ≤ 1 := by
    exact hL
  have hq_pos : ∀ a, 0 < q a := by
    exact fun a => Real.rpow_pos_of_pos zero_lt_two _
  have h_log_sum : ∑ a, p a * Real.log (q a / p a) ≤ 0 := by
    have h_log_sum : ∀ a, p a * Real.log (q a / p a) ≤ q a - p a := by
      exact fun a => by nlinarith only [ hp_pos a, hq_pos a, Real.log_le_sub_one_of_pos ( div_pos ( hq_pos a ) ( hp_pos a ) ), mul_div_cancel₀ ( q a ) ( ne_of_gt ( hp_pos a ) ) ] ;
    exact le_trans ( Finset.sum_le_sum fun _ _ => h_log_sum _ ) ( by simp +decide [ *, Finset.sum_sub_distrib ] )
  have h_log_sum_eq : ∑ a, p a * Real.log (q a / p a) = ∑ a, p a * (-L a * Real.log 2 - Real.log (p a)) := by
    exact Finset.sum_congr rfl fun a _ => by rw [ Real.log_div ( ne_of_gt ( hq_pos a ) ) ( ne_of_gt ( hp_pos a ) ), Real.log_rpow ( by norm_num ) ] ;
  have h_log_sum_eq' : ∑ a, p a * (-L a * Real.log 2 - Real.log (p a)) = -Real.log 2 * ∑ a, p a * L a - ∑ a, p a * Real.log (p a) := by
    simp +decide only [mul_sub, mul_comm, mul_assoc, Finset.sum_sub_distrib, Finset.mul_sum _ _ _];
    exact congrArg₂ _ ( Finset.sum_congr rfl fun _ _ => by ring ) rfl
  have h_final : -Real.log 2 * ∑ a, p a * L a - ∑ a, p a * Real.log (p a) ≤ 0 := by
    linarith
  have h_final' : ∑ a, p a * L a ≥ -∑ a, p a * Real.log (p a) / Real.log 2 := by
    rw [ ← Finset.sum_div _ _ _ ] ; rw [ ge_iff_le ] ; rw [ neg_div', div_le_iff₀ ] <;> first | positivity | linarith;
  have h_final'' : -∑ a, p a * Real.log (p a) / Real.log 2 = entropyBase2 p := by
    unfold entropyBase2; simp +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ;
    rfl
  aesop

/-
**Source coding sandwich**: H₂ ≤ E[ℓ_Shannon] < H₂ + 1.
-/
theorem tropical_code_expected_length_sandwich
    {α : Type*} [Fintype α] [Nonempty α]
    (p : α → ℝ)
    (hp_nonneg : ∀ a, 0 ≤ p a)
    (hp_sum : ∑ a, p a = 1)
    (hp_pos : ∀ a, p a > 0) :
    let ℓ := shannonLength p
    entropyBase2 p ≤ ∑ a, p a * (ℓ a : ℝ) ∧
    ∑ a, p a * (ℓ a : ℝ) < entropyBase2 p + 1 := by
  refine' ⟨ _, _ ⟩;
  · refine' le_trans _ ( Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left ( Nat.le_ceil _ ) ( hp_nonneg a ) );
    simp +decide [ entropyBase2, mul_comm, Real.logb, div_eq_mul_inv ];
  · convert shannon_lengths_expected_upper p hp_pos hp_sum using 1

/-! ## Theorem 3: Entropy Additivity -/

/-
**Entropy additivity for product sources**:
    H₂(p₁ ⊗ p₂) = H₂(p₁) + H₂(p₂).
-/
theorem tropical_product_source_additivity
    {α β : Type*} [Fintype α] [Fintype β]
    (p₁ : α → ℝ) (p₂ : β → ℝ)
    (hp₁_pos : ∀ a, 0 < p₁ a) (hp₂_pos : ∀ b, 0 < p₂ b)
    (hp₁_sum : ∑ a, p₁ a = 1) (hp₂_sum : ∑ b, p₂ b = 1) :
    entropyBase2 (fun ab : α × β => p₁ ab.1 * p₂ ab.2) =
    entropyBase2 p₁ + entropyBase2 p₂ := by
  unfold entropyBase2 at *;
  simp +decide [ Finset.sum_mul _ _ _, mul_assoc, mul_left_comm, mul_add, Finset.sum_add_distrib, Real.logb_mul ( ne_of_gt ( hp₁_pos _ ) ) ( ne_of_gt ( hp₂_pos _ ) ) ];
  erw [ Finset.sum_product, Finset.sum_product ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, hp₁_sum, hp₂_sum ];
  ring

/-! ## Theorem 4: Relaxed Optimizer -/

/-
**Equality at the optimizer**: The ideal code lengths L⋆(a) = log₂(1/p(a))
    are Kraft-tight and achieve expected length = entropy.
-/
theorem relaxed_optimizer_achieves_entropy
    {α : Type*} [Fintype α]
    (p : α → ℝ)
    (hp_pos : ∀ a, 0 < p a)
    (hp_sum : ∑ a, p a = 1) :
    let L := fun a => Real.logb 2 (1 / p a)
    kraftSumReal L = 1 ∧
    ∑ a, p a * L a = entropyBase2 p := by
  unfold kraftSumReal entropyBase2;
  simp_all +decide [ Real.rpow_neg, Real.logb_div, ne_of_gt ]

/-! ## Product Code Kraft Admissibility -/

/-
**Product codes preserve Kraft admissibility**.
-/
theorem kraft_product_admissible
    {α β : Type*} [Fintype α] [Fintype β]
    (ℓ₁ : α → ℕ) (ℓ₂ : β → ℕ)
    (h₁ : kraftSum ℓ₁ ≤ 1) (h₂ : kraftSum ℓ₂ ≤ 1) :
    kraftSum (fun ab : α × β => ℓ₁ ab.1 + ℓ₂ ab.2) ≤ 1 := by
  convert mul_le_mul h₁ h₂ ( Finset.sum_nonneg fun _ _ => zpow_nonneg zero_le_two _ ) zero_le_one;
  · unfold kraftSum;
    simp +decide [ zpow_add₀, Finset.sum_mul _ _ _ ];
    simp +decide only [Fintype.sum_prod_type, sum_mul, mul_comm];
    simp +decide only [Finset.mul_sum _ _ _];
  · norm_num

end TropicalSourceCoding