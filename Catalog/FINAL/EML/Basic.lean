/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Arithmetic Thermodynamics: Finite-Volume Free Energy

This file develops the finite-volume thermodynamics of arithmetic partition functions.

Given a finite type `ι`, weights `w : ι → ℝ≥0`, and an observable `τ : ι → ℝ`, we define the
partition function `Z(θ) = ∑ᵢ w(i) * exp(-θ * τ(i))` and the free energy `F(θ) = log Z(θ)`.

## Main results

* `partition_hasDerivAt` : `Z` is differentiable with derivative `-∑ᵢ w(i) τ(i) exp(-θ τ(i))`
* `freeEnergy_hasDerivAt` : `F` is differentiable with `F'(θ) = -⟨τ⟩_θ` (negative Gibbs mean)
* `freeEnergy_second_deriv` : `F''(θ) = Var_θ(τ)` (Gibbs variance)
* `freeEnergy_second_deriv_nonneg` : `F''(θ) ≥ 0`
* `freeEnergy_convex` : `F` is convex on `ℝ`

These results establish that finite-volume free energies in arithmetic thermodynamics
satisfy the standard thermodynamic identities: the first derivative is the negative
expectation, and the second derivative (specific heat) is the variance.
-/

import Mathlib

open Finset Real BigOperators

noncomputable section

namespace ArithThermo

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The partition function `Z(θ) = ∑ᵢ w(i) * exp(-θ * τ(i))`. -/
def partitionFn (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ) : ℝ :=
  ∑ i, w i * Real.exp (-θ * τ i)

/-- The free energy `F(θ) = log Z(θ)`. -/
def freeEnergy (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ) : ℝ :=
  Real.log (partitionFn w τ θ)

/-- The derivative of the partition function:
  `Z'(θ) = -∑ᵢ w(i) * τ(i) * exp(-θ * τ(i))`. -/
def partitionFn' (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ) : ℝ :=
  -(∑ i, w i * τ i * Real.exp (-θ * τ i))

/-- The second derivative of the partition function. -/
def partitionFn'' (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ) : ℝ :=
  ∑ i, w i * (τ i) ^ 2 * Real.exp (-θ * τ i)

/-! ### Differentiability of the partition function -/

/-
Each summand `θ ↦ w(i) * exp(-θ * τ(i))` has a derivative.
-/
lemma summand_hasDerivAt (w : ι → ℝ) (τ : ι → ℝ) (i : ι) (θ : ℝ) :
    HasDerivAt (fun θ => w i * Real.exp (-θ * τ i))
      (w i * (-τ i) * Real.exp (-θ * τ i)) θ := by
  convert HasDerivAt.const_mul ( w i ) ( HasDerivAt.exp ( HasDerivAt.mul ( hasDerivAt_neg θ ) ( hasDerivAt_const _ _ ) ) ) using 1 ; ring;
  exact congrArg Neg.neg ( congrArg _ ( congrArg _ ( by simp +decide [ mul_comm ] ) ) )

/-
The partition function is differentiable with the expected derivative.
-/
theorem partition_hasDerivAt (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ) :
    HasDerivAt (partitionFn w τ) (partitionFn' w τ θ) θ := by
  convert HasDerivAt.sum fun i _ => summand_hasDerivAt w τ i θ using 1;
  -- The sum of functions is equal to the function of the sum.
  funext θ; simp [partitionFn];
  congr! 1;
  unfold partitionFn';
  simp +decide only [mul_neg];
  simp +decide only [neg_mul];
  rw [ Finset.sum_neg_distrib ]

/-! ### Differentiability of the free energy -/

/-
The free energy has derivative `F'(θ) = Z'(θ)/Z(θ)`, which equals the negative
    Gibbs expectation of `τ`.
-/
theorem freeEnergy_hasDerivAt (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ)
    (hZ : 0 < partitionFn w τ θ) :
    HasDerivAt (freeEnergy w τ) (partitionFn' w τ θ / partitionFn w τ θ) θ := by
  convert HasDerivAt.log ( partition_hasDerivAt w τ θ ) hZ.ne' using 1

/-! ### Second derivative of the partition function -/

/-
Each summand of Z' has a derivative.
-/
lemma summand'_hasDerivAt (w : ι → ℝ) (τ : ι → ℝ) (i : ι) (θ : ℝ) :
    HasDerivAt (fun θ => w i * τ i * Real.exp (-θ * τ i))
      (w i * τ i * (-τ i) * Real.exp (-θ * τ i)) θ := by
  convert HasDerivAt.const_mul ( w i * τ i ) ( HasDerivAt.exp ( HasDerivAt.neg ( hasDerivAt_mul_const ( τ i ) ) ) ) using 1 ; ring!;
  · rfl;
  · norm_num ; ring

/-
Z' is differentiable with derivative Z''.
-/
theorem partitionFn'_hasDerivAt (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ) :
    HasDerivAt (fun θ => -(∑ i, w i * τ i * Real.exp (-θ * τ i)))
      (-(-(∑ i, w i * (τ i) ^ 2 * Real.exp (-θ * τ i)))) θ := by
  convert HasDerivAt.neg ( HasDerivAt.sum fun i _ => summand'_hasDerivAt w τ i θ ) using 1 ; ring;
  rotate_right;
  exacts [ Finset.univ, by ext; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ], by simp +decide [ mul_assoc, mul_comm, mul_left_comm, pow_two, Finset.mul_sum _ _ _ ] ]

/-! ### Second derivative of the free energy equals Gibbs variance -/

/-
The second derivative of the free energy equals the Gibbs variance of τ:
    `F''(θ) = ⟨τ²⟩_θ - ⟨τ⟩_θ²`
-/
theorem freeEnergy_second_deriv (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ)
    (hZ : ∀ θ, 0 < partitionFn w τ θ) :
    deriv (deriv (freeEnergy w τ)) θ =
      (∑ i, w i * (τ i) ^ 2 * Real.exp (-θ * τ i)) / partitionFn w τ θ -
      ((∑ i, w i * τ i * Real.exp (-θ * τ i)) / partitionFn w τ θ) ^ 2 := by
  convert HasDerivAt.deriv ( _ ) using 1;
  convert HasDerivAt.congr_of_eventuallyEq _ ?_ using 1;
  exact fun θ => ( - ( ∑ i, w i * τ i * Real.exp ( -θ * τ i ) ) ) / partitionFn w τ θ;
  · convert HasDerivAt.div ( partitionFn'_hasDerivAt w τ θ ) ( partition_hasDerivAt w τ θ ) ( ne_of_gt ( hZ θ ) ) using 1 ; ring;
    unfold partitionFn' ; ring;
    simp +decide [ sq, mul_assoc, ne_of_gt ( hZ θ ) ];
  · filter_upwards [ ] with θ using HasDerivAt.deriv ( freeEnergy_hasDerivAt w τ θ ( hZ θ ) ) ▸ by aesop;

/-
The second derivative of the free energy is nonneg (variance is nonneg).
-/
theorem freeEnergy_second_deriv_nonneg (w : ι → ℝ) (τ : ι → ℝ) (θ : ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hZ : ∀ θ, 0 < partitionFn w τ θ) :
    0 ≤ deriv (deriv (freeEnergy w τ)) θ := by
  -- The second derivative of the free energy is nonneg (variance is nonneg).
  have h_var : deriv (deriv (freeEnergy w τ)) θ =
    (∑ i, w i * (τ i) ^ 2 * Real.exp (-θ * τ i)) / partitionFn w τ θ -
    ((∑ i, w i * τ i * Real.exp (-θ * τ i)) / partitionFn w τ θ) ^ 2 := by
      convert freeEnergy_second_deriv w τ θ hZ using 1
  rw [h_var];
  -- By multiplying both sides of the inequality by $Z^2$, we get:
  have h_mul : (∑ i, w i * (τ i) ^ 2 * Real.exp (-θ * τ i)) * (∑ i, w i * Real.exp (-θ * τ i)) ≥ (∑ i, w i * τ i * Real.exp (-θ * τ i)) ^ 2 := by
    -- By the Cauchy-Schwarz inequality, we have that for any vectors $v$ and $w$ of equal length, $(∑ i, v i * w i)^2 ≤ (∑ i, v i^2) * (∑ i, w i^2)$.
    have h_cauchy_schwarz : ∀ (v w : ι → ℝ), (∑ i, v i * w i)^2 ≤ (∑ i, v i^2) * (∑ i, w i^2) := by
      exact?;
    specialize h_cauchy_schwarz ( fun i => Real.sqrt ( w i ) * τ i * Real.exp ( -θ * τ i / 2 ) ) ( fun i => Real.sqrt ( w i ) * Real.exp ( -θ * τ i / 2 ) ) ; simp_all +decide [ mul_pow, Real.sq_sqrt ( hw _ ) ];
    convert h_cauchy_schwarz using 3 <;> ring_nf <;> norm_num [ Real.sq_sqrt ( hw _ ), Real.exp_neg, Real.exp_mul ] ; ring_nf;
    · norm_num [ ← Real.sqrt_eq_rpow, Real.sq_sqrt ( Real.rpow_nonneg ( Real.exp_nonneg _ ) _ ) ];
    · exact Or.inl ( by rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ) ] ; norm_num );
    · exact Or.inl ( by rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ) ] ; norm_num );
  -- We can factor out the positive denominator $Z$ and the positive factor $Z^2$ to simplify to the goal.
  unfold partitionFn at *;
  field_simp [hZ θ] at *;
  exact div_nonneg ( by simpa only [ mul_comm ] using sub_nonneg_of_le h_mul ) ( sq_nonneg _ )

/-! ### Convexity of the free energy -/

/-
The free energy is convex on ℝ when Z > 0 everywhere.
-/
theorem freeEnergy_convex (w : ι → ℝ) (τ : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i)
    (hZ : ∀ θ, 0 < partitionFn w τ θ) :
    ConvexOn ℝ Set.univ (freeEnergy w τ) := by
  apply_rules [ convexOn_of_deriv2_nonneg, convex_univ ];
  · exact ContinuousOn.log ( Continuous.continuousOn <| by unfold partitionFn; continuity ) fun x hx => ne_of_gt <| hZ x;
  · exact fun x hx => ( freeEnergy_hasDerivAt w τ x ( hZ x ) |> HasDerivAt.differentiableAt |> DifferentiableAt.differentiableWithinAt );
  · refine' Differentiable.differentiableOn _;
    -- By definition of $FreeEnergy$, we know that its first derivative is given by:
    have h_freeEnergy_deriv : ∀ θ, deriv (freeEnergy w τ) θ = partitionFn' w τ θ / partitionFn w τ θ := by
      exact fun θ => HasDerivAt.deriv ( freeEnergy_hasDerivAt w τ θ ( hZ θ ) );
    rw [ show deriv ( freeEnergy w τ ) = _ from funext h_freeEnergy_deriv ];
    refine' Differentiable.div _ _ _;
    · exact fun θ => HasDerivAt.differentiableAt ( partitionFn'_hasDerivAt w τ θ );
    · exact fun θ => ( partition_hasDerivAt w τ θ |> HasDerivAt.differentiableAt );
    · grind;
  · exact fun x _ => freeEnergy_second_deriv_nonneg w τ x hw hZ

/-! ### Combined main theorem -/

/-
**Main theorem**: The finite-volume free energy satisfies:
1. Convexity on ℝ
2. Derivative formula (negative Gibbs expectation)
3. Second derivative = Gibbs variance
4. Second derivative is nonneg
-/
theorem logSumExp_convex_and_second_derivative_eq_variance
    (w : ι → ℝ) (τ : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i) :
    let Z : ℝ → ℝ := partitionFn w τ
    let F : ℝ → ℝ := freeEnergy w τ
    (∀ θ, 0 < Z θ) →
    (ConvexOn ℝ Set.univ F ∧
     (∀ θ, HasDerivAt F (partitionFn' w τ θ / Z θ) θ) ∧
     (∀ θ, deriv (deriv F) θ =
        (∑ i, w i * (τ i) ^ 2 * Real.exp (-θ * τ i)) / Z θ -
        ((∑ i, w i * τ i * Real.exp (-θ * τ i)) / Z θ) ^ 2) ∧
     (∀ θ, 0 ≤ deriv (deriv F) θ)) := by
  refine' fun hZ => ⟨ _, _, _, _ ⟩;
  · exact?;
  · exact fun θ => freeEnergy_hasDerivAt w τ θ ( hZ θ );
  · exact?;
  · exact?

end ArithThermo

end