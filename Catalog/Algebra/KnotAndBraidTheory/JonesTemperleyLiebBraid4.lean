import Mathlib

/-!
# Core Jones–Temperley–Lieb braid calculation

This file formalizes the basic algebraic identities underlying the Jones
representation of the braid group via the Temperley–Lieb algebra.

Given a field element `A` and a Temperley–Lieb-type generator `X` in an algebra
`R`, we set
`jonesOp A X = A • 1 + A⁻¹ • X`,
the image of a braid generator, with inverse `jonesInv A X = A⁻¹ • 1 + A • X`.

We prove, under the loop-value relation `δ = -(A² + A⁻²)` and the
Temperley–Lieb relations `X² = δ • X`, `X Y X = X`, `Y X Y = Y`:

* the adjacent braid relation `σ₁ σ₂ σ₁ = σ₂ σ₁ σ₂`;
* the distant commutation `σ_i σ_j = σ_j σ_i` for commuting generators;
* the two-sided inverse formula `jonesOp A X * jonesInv A X = 1` and vice versa.

No claim is made about braid group universality, density, topology, or quantum
computation beyond these algebraic identities.
-/

namespace JonesTemperleyLiebBraid4

variable {K R : Type*} [Field K] [Ring R] [Algebra K R]

/-- The image of a braid generator in the Temperley–Lieb algebra. -/
def jonesOp (A : K) (X : R) : R := A • (1 : R) + A⁻¹ • X

/-- The inverse of `jonesOp A X`. -/
def jonesInv (A : K) (X : R) : R := A⁻¹ • (1 : R) + A • X

/-- Scalar cancellation: with the loop value `δ = -(A² + A⁻²)`,
the combination `A² + δ + A⁻²` vanishes. -/
theorem delta_scalar_id (A δ : K) (hδ : δ = -(A ^ 2 + A⁻¹ ^ 2)) :
    A ^ 2 + δ + A⁻¹ ^ 2 = 0 := by
  subst hδ; ring

/-- Distant commutation of two Jones operators built from commuting generators. -/
theorem braid_commute (A : K) (X Y : R) (hXY : X * Y = Y * X) :
    jonesOp A X * jonesOp A Y = jonesOp A Y * jonesOp A X := by
  by_cases hA : A = 0 <;> simp_all +decide [ jonesOp ];
  simp +decide [ mul_add, add_mul, hA, hXY ];
  abel1

/-- The adjacent braid relation `σ₁ σ₂ σ₁ = σ₂ σ₁ σ₂`. -/
theorem braid_relation (A δ : K) (X Y : R) (hA : A ≠ 0)
    (hδ : δ = -(A ^ 2 + A⁻¹ ^ 2)) (hX2 : X * X = δ • X) (hY2 : Y * Y = δ • Y)
    (hXYX : X * Y * X = X) (hYXY : Y * X * Y = Y) :
    jonesOp A X * jonesOp A Y * jonesOp A X
      = jonesOp A Y * jonesOp A X * jonesOp A Y := by
  simp +decide only [jonesOp, mul_add, mul_smul_comm, add_mul, smul_mul_assoc, one_mul, smul_add];
  simp +decide [ ← smul_assoc, hA, hδ, hX2, hY2, hXYX, hYXY ];
  simp +decide [ add_comm, add_left_comm, add_assoc, hA, sq, mul_add, add_smul ]

/-- `jonesOp A X` is a right inverse of `jonesInv A X`. -/
theorem jonesOp_mul_jonesInv (A δ : K) (X : R) (hA : A ≠ 0)
    (hδ : δ = -(A ^ 2 + A⁻¹ ^ 2)) (hX2 : X * X = δ • X) :
    jonesOp A X * jonesInv A X = 1 := by
  unfold jonesOp jonesInv;
  simp +decide [ mul_add, add_mul, smul_smul, hA, hδ, hX2 ];
  simp +decide [ ← add_assoc, ← add_smul, sq ]

/-- `jonesOp A X` is a left inverse of `jonesInv A X`. -/
theorem jonesInv_mul_jonesOp (A δ : K) (X : R) (hA : A ≠ 0)
    (hδ : δ = -(A ^ 2 + A⁻¹ ^ 2)) (hX2 : X * X = δ • X) :
    jonesInv A X * jonesOp A X = 1 := by
  unfold jonesInv jonesOp;
  simp_all +decide [ mul_add, add_mul, Algebra.smul_mul_assoc, Algebra.mul_smul_comm ];
  simp +decide [ sq, smul_smul, add_smul ]

end JonesTemperleyLiebBraid4