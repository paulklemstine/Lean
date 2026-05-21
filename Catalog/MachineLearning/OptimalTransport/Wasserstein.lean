/-
# Wasserstein Distance and WGAN Stability

This module establishes:
1. Symmetric and identity couplings
2. Transport cost symmetry and identity properties
3. The absolute critic bound (bilateral WGAN stability)
4. Wasserstein nonnegativity from coupling structure

These results form the verified mathematical foundation for Wasserstein GANs
and distributional robustness in machine learning.
-/
import MachineLearning.OptimalTransport.Theorems

open Finset BigOperators

/-! ## Symmetric Coupling -/

/-- Reverse a coupling: if `π` couples `μ` to `ν`, then `πᵀ` couples `ν` to `μ`. -/
def reverseCoupling {α β : Type*} [Fintype α] [Fintype β]
    {μ : FinProb α} {ν : FinProb β}
    (π : Coupling μ ν) : Coupling ν μ where
  mass b a := π.mass a b
  nonneg b a := π.nonneg a b
  left_marginal b := π.right_marginal b
  right_marginal a := π.left_marginal a

/-
For symmetric cost, reversing a coupling preserves transport cost.
-/
theorem transportCost_reverse {α : Type*} [Fintype α]
    (c : α → α → ℝ) (μ ν : FinProb α) (π : Coupling μ ν)
    (hc_symm : ∀ a b, c a b = c b a) :
    transportCost c (reverseCoupling π) = transportCost c π := by
  unfold transportCost reverseCoupling;
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by rw [ hc_symm ] )

/-! ## Self-Coupling (Identity) -/

/-- The identity coupling of a distribution with itself, concentrating mass on the diagonal. -/
def identityCoupling {α : Type*} [Fintype α] [DecidableEq α]
    (μ : FinProb α) : Coupling μ μ where
  mass a b := if a = b then μ.weight a else 0
  nonneg a b := by split_ifs <;> simp_all [μ.nonneg]
  left_marginal a := by simp
  right_marginal b := by simp

/-
Transport cost of the identity coupling with a cost satisfying `c a a = 0` is zero.
-/
theorem transportCost_identity_eq_zero {α : Type*} [Fintype α] [DecidableEq α]
    (c : α → α → ℝ) (μ : FinProb α)
    (hc_diag : ∀ a, c a a = 0) :
    transportCost c (identityCoupling μ) = 0 := by
  simp +decide [ transportCost, identityCoupling, hc_diag ]

/-! ## WGAN Critic Stability (Bilateral) -/

/-
**WGAN Stability (Bilateral Coupling Form).** For every K-Lipschitz function and every coupling,
    the absolute expectation difference is bounded by K times the transport cost.
    Combined with the Wasserstein infimum, this yields the WGAN critic stability theorem.
-/
theorem abs_critic_bound {α : Type*} [Fintype α]
    (d : α → α → ℝ) (K : ℝ) (f : α → ℝ) (μ ν : FinProb α)
    (π : Coupling μ ν)
    (hK : 0 ≤ K)
    (hd_nonneg : ∀ a b, 0 ≤ d a b)
    (hd_symm : ∀ a b, d a b = d b a)
    (hLip : ∀ a b, |f a - f b| ≤ K * d a b) :
    |(∑ a, f a * μ.weight a) - (∑ a, f a * ν.weight a)| ≤ K * transportCost d π := by
  have h_reverse : (∑ a, f a * ν.weight a) - (∑ a, f a * μ.weight a) ≤ K * transportCost d (reverseCoupling π) := by
    convert critic_bound_via_coupling d K f ν μ ( reverseCoupling π ) hK ( fun a b => hd_nonneg a b ) ( fun a b => hLip a b ) using 1;
  rw [ abs_sub_le_iff ];
  exact ⟨ by simpa only [ transportCost_reverse d μ ν π hd_symm ] using critic_bound_via_coupling d K f μ ν π hK hd_nonneg hLip, by simpa only [ transportCost_reverse d μ ν π hd_symm ] using h_reverse ⟩

/-! ## Coupling Composition (Gluing Lemma) -/

/-
**Gluing Lemma.** Given couplings `π₁₂ : μ ↔ ν` and `π₂₃ : ν ↔ ρ`
    where ν has strictly positive weights, we can construct a coupling `μ ↔ ρ`
    whose transport cost satisfies the triangle inequality.
-/
noncomputable def gluedCoupling {α : Type*} [Fintype α]
    (μ ν ρ : FinProb α)
    (π₁₂ : Coupling μ ν) (π₂₃ : Coupling ν ρ)
    (hν : ∀ b, 0 < ν.weight b) : Coupling μ ρ where
  mass a c := ∑ b, π₁₂.mass a b * π₂₃.mass b c / ν.weight b
  nonneg a c := Finset.sum_nonneg fun b _ =>
    div_nonneg (mul_nonneg (π₁₂.nonneg a b) (π₂₃.nonneg b c)) (le_of_lt (hν b))
  left_marginal a := by
    convert π₁₂.left_marginal a using 1;
    rw [ Finset.sum_comm ];
    simp +decide only [← mul_div_assoc, ← sum_div];
    exact Finset.sum_congr rfl fun b _ => by rw [ ← Finset.mul_sum _ _ _, π₂₃.left_marginal, mul_div_cancel_right₀ _ ( ne_of_gt ( hν b ) ) ] ;
  right_marginal c := by
    -- By definition of right marginal, we can rewrite the inner sum:
    have h_inner : ∀ b, ∑ a, π₁₂.mass a b * π₂₃.mass b c / ν.weight b = π₂₃.mass b c := by
      intro b
      have h_sum : ∑ a, π₁₂.mass a b = ν.weight b := by
        exact π₁₂.right_marginal b;
      simp +decide [ ← Finset.sum_div _ _ _, ← Finset.sum_mul, h_sum, ne_of_gt ( hν b ) ];
    rw [ Finset.sum_comm, Finset.sum_congr rfl fun b _ => h_inner b, π₂₃.right_marginal ]

/-
**Triangle inequality for transport cost via gluing.** The glued coupling's cost
    is at most the sum of costs of the two component couplings, when the cost function
    satisfies the triangle inequality.
-/
theorem gluedCoupling_cost_le {α : Type*} [Fintype α]
    (d : α → α → ℝ) (μ ν ρ : FinProb α)
    (π₁₂ : Coupling μ ν) (π₂₃ : Coupling ν ρ)
    (hν : ∀ b, 0 < ν.weight b)
    (hd_triangle : ∀ a b c, d a c ≤ d a b + d b c)
    (hd_nonneg : ∀ a b, 0 ≤ d a b) :
    transportCost d (gluedCoupling μ ν ρ π₁₂ π₂₃ hν) ≤
    transportCost d π₁₂ + transportCost d π₂₃ := by
  -- Apply the triangle inequality to the cost function.
  have h_triangle : ∀ a b c, d a c * (π₁₂.mass a b * π₂₃.mass b c / ν.weight b) ≤ (d a b + d b c) * (π₁₂.mass a b * π₂₃.mass b c / ν.weight b) := by
    exact fun a b c => mul_le_mul_of_nonneg_right ( hd_triangle a b c ) ( div_nonneg ( mul_nonneg ( π₁₂.nonneg a b ) ( π₂₃.nonneg b c ) ) ( le_of_lt ( hν b ) ) );
  -- Apply the triangle inequality to each term in the sum.
  have h_sum_triangle : ∑ a, ∑ c, ∑ b, d a c * (π₁₂.mass a b * π₂₃.mass b c / ν.weight b) ≤ ∑ a, ∑ c, ∑ b, (d a b + d b c) * (π₁₂.mass a b * π₂₃.mass b c / ν.weight b) := by
    exact Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun c _ => Finset.sum_le_sum fun b _ => h_triangle a b c;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ a, ∑ c, ∑ b, (d a b + d b c) * (π₁₂.mass a b * π₂₃.mass b c / ν.weight b) = ∑ a, ∑ b, d a b * π₁₂.mass a b + ∑ c, ∑ b, d b c * π₂₃.mass b c := by
    simp +decide only [add_mul, mul_assoc, sum_add_distrib];
    congr! 1;
    · refine' Finset.sum_congr rfl fun a _ => _;
      rw [ Finset.sum_comm ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_div, mul_div_assoc, ne_of_gt ( hν _ ) ];
      exact Finset.sum_congr rfl fun b _ => by rw [ π₂₃.left_marginal ] ; simp +decide [ ne_of_gt ( hν b ) ] ;
    · rw [ Finset.sum_comm ];
      refine' Finset.sum_congr rfl fun c _ => _;
      rw [ Finset.sum_comm ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_div, mul_div_assoc, π₁₂.right_marginal, ne_of_gt ( hν _ ) ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_div_assoc, π₁₂.right_marginal, ne_of_gt ( hν _ ) ];
      exact Finset.sum_congr rfl fun _ _ => by rw [ mul_div_cancel₀ _ ( ne_of_gt ( hν _ ) ) ] ;
  convert h_sum_triangle.trans_eq h_fubini using 1;
  · unfold transportCost gluedCoupling; simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ] ;
  · exact congr_arg₂ ( · + · ) rfl ( Finset.sum_comm )