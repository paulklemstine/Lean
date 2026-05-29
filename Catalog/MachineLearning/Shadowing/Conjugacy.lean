import Mathlib
import Speculative.Shadowing.Defs

/-!
# The Conjugacy Equation and Logistic Map Properties

This file proves the trigonometric conjugacy equation connecting the tent map
and the logistic map: `chaosConj (tentMap y) = logistic (chaosConj y)`.

This is the key identity: sin²(π · min(y, 1-y)) = 4 · sin²(πy/2) · (1 - sin²(πy/2)).

We also prove that the logistic map maps [0,1] to [0,1].
-/

noncomputable section

open Real Set

/-! ## Logistic map stays in [0,1] -/

theorem logistic_mem_Icc {x : ℝ} (hx : x ∈ Icc 0 1) :
    logistic x ∈ Icc 0 1 := by
  exact ⟨ mul_nonneg ( mul_nonneg zero_le_four hx.1 ) ( sub_nonneg.2 hx.2 ), by unfold logistic; nlinarith [ mul_self_nonneg ( x - 1 / 2 ), hx.1, hx.2 ] ⟩

/-! ## Tent map stays in [0,1] -/

theorem tentMap_mem_Icc {y : ℝ} (hy : y ∈ Icc 0 1) :
    tentMap y ∈ Icc 0 1 := by
  -- By definition of tentMap, we have tentMap y = 2 * min y (1 - y).
  have h_tentMap : tentMap y = 2 * min y (1 - y) := by
    rfl;
  constructor <;> cases min_cases y ( 1 - y ) <;> linarith [ hy.1, hy.2 ]

/-! ## Conjugacy stays in [0,1] -/

theorem chaosConj_mem_Icc {y : ℝ} (_hy : y ∈ Icc 0 1) :
    chaosConj y ∈ Icc 0 1 := by
  exact ⟨ sq_nonneg _, sin_sq_le_one _ ⟩

/-! ## The conjugacy equation -/

/-
The conjugacy h(y) = sin²(πy/2) satisfies h(T(y)) = f(h(y))
    where T is the tent map and f is the logistic map.
    This is the trigonometric core of the shadowing argument.
-/
theorem conjugacy_equation (y : ℝ) (_hy : y ∈ Icc 0 1) :
    chaosConj (tentMap y) = logistic (chaosConj y) := by
  unfold chaosConj logistic tentMap;
  cases le_total y ( 1 - y ) <;> simp +decide [ *, mul_assoc, mul_div_assoc ];
  · rw [ show Real.pi * y = 2 * ( Real.pi * ( y / 2 ) ) by ring, Real.sin_two_mul ] ; ring;
    rw [ Real.cos_sq' ] ; ring;
  · rw [ ← Real.cos_sq' ] ; rw [ show Real.pi * ( 1 - y ) = 2 * ( Real.pi * ( 1 / 2 - y / 2 ) ) by ring ] ; rw [ Real.sin_two_mul ] ; ring;
    norm_num [ Real.sin_add, Real.cos_add, mul_div ];
    ring

end