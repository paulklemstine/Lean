import Mathlib

/-!
# Finite Group Convolution and Probability Measures

This file develops the theory of convolution on finite groups, probability measures,
and basic analytic tools for the Bourgain–Gamburd machine.

## Main definitions

- `FiniteGroupConvolution.conv` : convolution of two functions on a finite group
- `FiniteGroupConvolution.IsProbMeasure` : predicate for probability measures
- `FiniteGroupConvolution.IsSymmetric` : symmetry of a measure
- `FiniteGroupConvolution.l2NormSq` : L² norm squared
- `FiniteGroupConvolution.uniformMeasure` : uniform probability measure

## Applications

These definitions form the analytic foundation for the Bourgain–Gamburd
spectral gap machine applied to finite orthogonal groups and other
matrix groups arising in arithmetic combinatorics.
-/

namespace FiniteGroupConvolution

open Finset BigOperators

variable {G : Type*} [Fintype G] [DecidableEq G] [Group G]

/-! ### Convolution -/

/-- Convolution of two functions on a finite group. -/
noncomputable def conv (μ ν : G → ℝ) : G → ℝ :=
  fun x => ∑ g : G, μ g * ν (g⁻¹ * x)

/-- The uniform probability measure on a finite group. -/
noncomputable def uniformMeasure (G : Type*) [Fintype G] : G → ℝ :=
  fun _ => (Fintype.card G : ℝ)⁻¹

/-! ### Probability measure predicates -/

/-- A function is a probability measure if it is nonnegative and sums to 1. -/
def IsProbMeasure (μ : G → ℝ) : Prop :=
  (∀ g, 0 ≤ μ g) ∧ (∑ g : G, μ g = 1)

/-- A measure is symmetric if `μ(g) = μ(g⁻¹)` for all `g`. -/
def IsSymmetric (μ : G → ℝ) : Prop :=
  ∀ g : G, μ g = μ g⁻¹

/-! ### L² norm -/

/-- The L² norm squared of a function on a finite group. -/
noncomputable def l2NormSq (f : G → ℝ) : ℝ :=
  ∑ g : G, f g ^ 2

/-- The inner product of two functions on a finite group. -/
noncomputable def innerProd (f g₀ : G → ℝ) : ℝ :=
  ∑ x : G, f x * g₀ x

/-- A function has mean zero. -/
def MeanZero (f : G → ℝ) : Prop :=
  ∑ g : G, f g = 0

/-! ### Basic lemmas -/

omit [DecidableEq G] [Group G] in
theorem l2NormSq_nonneg (f : G → ℝ) : 0 ≤ l2NormSq f := by
  apply Finset.sum_nonneg
  intro g _
  exact sq_nonneg (f g)

theorem conv_sum_eq (μ ν : G → ℝ) :
    ∑ x : G, conv μ ν x = (∑ g : G, μ g) * (∑ g : G, ν g) := by
  -- Expand the definition of conv, swap the order of summation, and use that ∑ i, ν(g⁻¹ * i) = ∑ i, ν(i) by reindexing via the bijection i ↦ g⁻¹ * i (Equiv.mulLeft g⁻¹). Then factor out μ g.
  have h_swap_sum : ∀ g, (∑ i, ν (g⁻¹ * i)) = (∑ i, ν i) := by
    exact fun g => Equiv.sum_comp ( Equiv.mulLeft g⁻¹ ) _;
  simp +decide only [conv];
  rw [ Finset.sum_comm, Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ ← h_swap_sum ] ; rw [ Finset.mul_sum _ _ _ ] ;

theorem conv_preserves_total_mass (μ ν : G → ℝ)
    (hμ : ∑ g : G, μ g = 1) (hν : ∑ g : G, ν g = 1) :
    ∑ x : G, conv μ ν x = 1 := by
  rw [conv_sum_eq, hμ, hν, mul_one]

theorem conv_preserves_prob (μ ν : G → ℝ)
    (hμ : IsProbMeasure μ) (hν : IsProbMeasure ν) :
    ∑ x : G, conv μ ν x = 1 :=
  conv_preserves_total_mass μ ν hμ.2 hν.2

omit [DecidableEq G] in
theorem conv_nonneg (μ ν : G → ℝ)
    (hμ : ∀ g, 0 ≤ μ g) (hν : ∀ g, 0 ≤ ν g) (x : G) :
    0 ≤ conv μ ν x := by
  apply Finset.sum_nonneg
  intro g _
  exact mul_nonneg (hμ g) (hν _)

theorem isProbMeasure_conv (μ ν : G → ℝ)
    (hμ : IsProbMeasure μ) (hν : IsProbMeasure ν) :
    IsProbMeasure (conv μ ν) :=
  ⟨fun x => conv_nonneg μ ν hμ.1 hν.1 x, conv_preserves_prob μ ν hμ hν⟩

omit [DecidableEq G] in
theorem uniformMeasure_isProbMeasure [Nonempty G] :
    IsProbMeasure (uniformMeasure G) := by
  exact ⟨ fun _ => by exact inv_nonneg.2 ( Nat.cast_nonneg _ ), by simp +decide [ uniformMeasure ] ⟩

omit [DecidableEq G] [Group G] in
theorem l2NormSq_uniformMeasure [Nonempty G] :
    l2NormSq (uniformMeasure G) = (Fintype.card G : ℝ)⁻¹ := by
  exact show ( ∑ g : G, ( ( Fintype.card G : ℝ ) ⁻¹ ) ^ 2 ) = ( ( Fintype.card G : ℝ ) ⁻¹ ) from by simp +decide [ sq, mul_assoc, mul_comm, mul_left_comm]

omit [DecidableEq G] in
/-- Convolution with the uniform measure yields the uniform measure. -/
theorem conv_uniform_right (μ : G → ℝ) (hμ : ∑ g : G, μ g = 1) :
    conv μ (uniformMeasure G) = uniformMeasure G := by
  funext x;
  -- Expand convolution definition.
  simp [conv, uniformMeasure];
  rw [ ← Finset.sum_mul _ _ _, hμ, one_mul ]

end FiniteGroupConvolution