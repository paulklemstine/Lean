/-
# Discrete Optimal Transport: Core Theorems

This module contains the main theorems of discrete optimal transport theory:
1. **Weak Duality**: Dual objective ≤ primal cost for any coupling and admissible potentials
2. **Complementary Slackness**: At optimality, positive mass implies tight dual constraint
3. **Critic-Gap Lipschitz Stability**: Adversarial objectives are bounded by Wasserstein distance
4. **Quadratic Swap Inequality**: The foundational inequality for monotone rearrangement
5. **Coupling Cost Nonnegativity**: Nonneg cost + nonneg coupling → nonneg transport cost

These results form the verified mathematical backbone connecting optimal transport
to adversarial machine learning (WGAN stability), convex duality, and metric geometry.
-/
import MachineLearning.OptimalTransport.Basic

open Finset BigOperators

/-! ## Theorem 1: Weak Duality

The fundamental inequality of Kantorovich theory: for any coupling π and any
admissible dual potentials (φ, ψ), the dual value is a lower bound on transport cost.
This is the finite-dimensional analog of LP weak duality.

**Proof idea**: Expand the dual value using marginal constraints, then apply
the admissibility inequality pointwise under the sum weighted by π.mass.
-/

/-
**Weak Kantorovich Duality.** For any coupling `π` and admissible potentials `(φ, ψ)`,
    the dual objective `∑ φ μ + ∑ ψ ν` is at most the primal cost `∑ c π`.
    This is the cornerstone inequality connecting primal optimization to dual certification.
-/
theorem weak_duality {α β : Type*} [Fintype α] [Fintype β]
    (c : α → β → ℝ) (μ : FinProb α) (ν : FinProb β)
    (π : Coupling μ ν) (φ : α → ℝ) (ψ : β → ℝ)
    (hadm : admissiblePotential c φ ψ) :
    dualValue μ ν φ ψ ≤ transportCost c π := by
  convert Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_right ( hadm i j ) ( π.nonneg i j ) using 1;
  simp +decide only [dualValue, add_mul, sum_add_distrib];
  simp +decide only [← Finset.mul_sum _ _ _, π.left_marginal];
  exact congr rfl ( by rw [ ← Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ ← Finset.mul_sum _ _ _, π.right_marginal ] )

/-! ## Theorem 2: Complementary Slackness

When a coupling and dual potentials achieve equal primal and dual values,
optimality forces a structural relationship: transport mass can only flow
along pairs where the dual constraint is tight. This is the discrete analog
of the support condition in continuous optimal transport.
-/

/-
**Complementary Slackness for Optimal Transport.** If primal cost equals dual value,
    then positive mass `π(a,b) > 0` implies the dual constraint is tight: `φ(a) + ψ(b) = c(a,b)`.
    This identifies the support of optimal couplings with the equality set of dual potentials.
-/
theorem complementary_slackness {α β : Type*} [Fintype α] [Fintype β]
    (c : α → β → ℝ) (μ : FinProb α) (ν : FinProb β)
    (π : Coupling μ ν) (φ : α → ℝ) (ψ : β → ℝ)
    (hadm : admissiblePotential c φ ψ)
    (hEq : transportCost c π = dualValue μ ν φ ψ) :
    ∀ a b, 0 < π.mass a b → φ a + ψ b = c a b := by
  -- By definition of transport cost and dual value, we can expand their difference.
  have h_diff : ∑ a, ∑ b, (c a b - φ a - ψ b) * π.mass a b = 0 := by
    simp_all +decide [ transportCost, dualValue, sub_mul, Finset.sum_add_distrib ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← π.left_marginal, ← π.right_marginal ];
    rw [ sub_eq_zero, Finset.sum_comm ];
    simp +decide only [Finset.mul_sum _ _ _];
  rw [ Finset.sum_eq_zero_iff_of_nonneg ] at h_diff;
  · intro a b hab; specialize h_diff a; rw [ Finset.sum_eq_zero_iff_of_nonneg ] at h_diff <;> simp_all +decide [ sub_eq_iff_eq_add' ] ;
    · grind;
    · exact fun i => mul_nonneg ( by linarith [ hadm a i ] ) ( π.nonneg a i );
  · exact fun a _ => Finset.sum_nonneg fun b _ => mul_nonneg ( by linarith [ hadm a b ] ) ( π.nonneg a b )

/-! ## Theorem 3: Transport Cost Nonnegativity

For nonnegative cost functions, every coupling has nonnegative transport cost.
-/

/-
Transport cost is nonnegative when the cost function is nonnegative.
-/
theorem transportCost_nonneg {α β : Type*} [Fintype α] [Fintype β]
    (c : α → β → ℝ) {μ : FinProb α} {ν : FinProb β}
    (π : Coupling μ ν)
    (hc : ∀ a b, 0 ≤ c a b) :
    0 ≤ transportCost c π := by
  exact Finset.sum_nonneg fun a _ => Finset.sum_nonneg fun b _ => mul_nonneg ( hc a b ) ( π.nonneg a b )

/-! ## Theorem 4: Quadratic Swap Inequality

The core algebraic inequality behind the monotone rearrangement theorem:
swapping an out-of-order assignment reduces quadratic cost. If x₁ ≤ x₂ and y₁ ≤ y₂,
then (x₁-y₁)² + (x₂-y₂)² ≤ (x₁-y₂)² + (x₂-y₁)².

This is equivalent to the rearrangement inequality for two elements and is the
foundation for proving that monotone transport maps are optimal for quadratic cost.
-/

/-
**Quadratic Swap Inequality.** For ordered pairs `x₁ ≤ x₂` and `y₁ ≤ y₂`,
    the order-preserving assignment has lower quadratic cost than the order-reversing one.
    Equivalently: `(x₂ - x₁)(y₂ - y₁) ≥ 0` implies the rearrangement inequality for squares.
-/
theorem quadratic_swap_inequality (x₁ x₂ y₁ y₂ : ℝ)
    (hx : x₁ ≤ x₂) (hy : y₁ ≤ y₂) :
    (x₁ - y₁)^2 + (x₂ - y₂)^2 ≤ (x₁ - y₂)^2 + (x₂ - y₁)^2 := by
  nlinarith

/-! ## Theorem 5: Critic Gap Bound via Coupling

The key inequality for WGAN stability: for any single K-Lipschitz function and
any coupling, the expectation difference is bounded by K times the transport cost.
This is the pointwise version of the critic-gap theorem.
-/

/-
**Single-Critic Transport Bound.** For any function `f` that is `K`-Lipschitz w.r.t. `d`,
    and any coupling `π`, the expectation difference `𝔼_μ[f] - 𝔼_ν[f]` is at most
    `K * transportCost d π`. This is the building block for WGAN stability.
-/
theorem critic_bound_via_coupling {α : Type*} [Fintype α]
    (d : α → α → ℝ) (K : ℝ) (f : α → ℝ) (μ ν : FinProb α)
    (π : Coupling μ ν)
    (hK : 0 ≤ K)
    (hd_nonneg : ∀ a b, 0 ≤ d a b)
    (hLip : ∀ a b, |f a - f b| ≤ K * d a b) :
    (∑ a, f a * μ.weight a) - (∑ a, f a * ν.weight a) ≤ K * transportCost d π := by
  -- Apply the Lipschitz condition to each term in the sum.
  have h_term_bound : ∀ a b, (f a - f b) * (π.mass a b) ≤ K * (d a b) * (π.mass a b) := by
    exact fun a b => mul_le_mul_of_nonneg_right ( le_of_abs_le ( hLip a b ) ) ( by linarith [ π.nonneg a b ] );
  -- Apply the term bound to each term in the sum.
  have h_sum_bound : ∑ a, ∑ b, (f a - f b) * (π.mass a b) ≤ ∑ a, ∑ b, K * (d a b) * (π.mass a b) := by
    exact Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => h_term_bound a b;
  simp_all +decide [ mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul, transportCost ];
  convert add_le_add_right h_sum_bound ( ∑ a, f a * ν.weight a ) using 1 ; simp +decide [ sub_mul, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, π.left_marginal, π.right_marginal ];
  · simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, π.left_marginal, π.right_marginal ];
  · ring

/-! ## Theorem 6: Expectation Rewrite via Coupling

A fundamental identity: the expectation difference of any function `f` can be
rewritten as a sum over the coupling of `f(a) - f(b)`.
-/

/-
**Expectation difference rewrite.** For any coupling `π` and function `f`,
    `𝔼_μ[f] - 𝔼_ν[f] = ∑_{a,b} (f(a) - f(b)) π(a,b)`.
-/
theorem expectation_diff_eq_coupling_sum {α : Type*} [Fintype α]
    (f : α → ℝ) (μ ν : FinProb α)
    (π : Coupling μ ν) :
    (∑ a, f a * μ.weight a) - (∑ a, f a * ν.weight a) =
    ∑ a, ∑ b, (f a - f b) * π.mass a b := by
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sub_mul, π.left_marginal, π.right_marginal ];
  rw [ Finset.sum_comm ];
  simp +decide only [← π.right_marginal, Finset.mul_sum _ _ _]

/-! ## Derived Results -/

/-- Zero potentials are always admissible for nonnegative cost. -/
theorem zero_potentials_admissible {α β : Type*} [Fintype α] [Fintype β]
    (c : α → β → ℝ) (hc : ∀ a b, 0 ≤ c a b) :
    admissiblePotential c (fun _ => 0) (fun _ => 0) := by
  intro a b
  simp
  exact hc a b

/-- The dual value of zero potentials is zero. -/
theorem dualValue_zero {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinProb α) (ν : FinProb β) :
    dualValue μ ν (fun _ => 0) (fun _ => 0) = 0 := by
  simp [dualValue]