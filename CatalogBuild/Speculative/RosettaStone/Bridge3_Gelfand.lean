/-! # CatalogBuild.Speculative.RosettaStone.Bridge3_Gelfand

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 5
-/

import Mathlib

/-- A projection (idempotent element). -/
structure Projection (R : Type*) [Ring R] where
  val : R
  idem : val * val = val


/-- The complement of a projection is a projection. -/
def Projection.complement (p : Projection R) : Projection R where
  val := 1 - p.val
  idem := by
    have h1 : (1 - p.val) * p.val = 0 := by rw [sub_mul, one_mul, p.idem, sub_self]
    calc (1 - p.val) * (1 - p.val)
        = 1 - p.val - (1 - p.val) * p.val := by rw [mul_sub, mul_one]
      _ = 1 - p.val - 0 := by rw [h1]
      _ = 1 - p.val := by rw [sub_zero]


/-- Two complementary projections are orthogonal. -/
theorem projection_orthogonal (p : Projection R) :
    p.val * p.complement.val = 0 := by
  simp only [Projection.complement]
  rw [mul_sub, mul_one, p.idem, sub_self]


/-- Complementary projections sum to identity. -/
theorem projection_sum_one (p : Projection R) :
    p.val + p.complement.val = 1 := by
  simp only [Projection.complement]
  rw [add_sub_cancel]


/-- Evaluation at a point is a ring homomorphism from (X → ℝ) to ℝ. -/
def evalHomomorphism (X : Type*) (x : X) : (X → ℝ) →+* ℝ where
  toFun f := f x
  map_one' := rfl
  map_mul' _ _ := rfl
  map_zero' := rfl
  map_add' _ _ := rfl


