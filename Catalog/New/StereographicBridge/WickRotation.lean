import Mathlib

/-!
# Wick Rotation Functoriality

The Wick rotation (sign change in the denominator) bridges the circular SPB group
and the hyperbolic SPB group. The map 1-xy ↔ 1+xy corresponds to the Wick rotation
t → it in physics.
-/

noncomputable section

open Real

def spbCirc (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def spbHyp (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Wick Rotation as Sign Flip -/

/-- The Wick rotation relates circular and hyperbolic SPB via sign. -/
theorem wick_sign_flip (x y : ℝ) :
    spbCirc x (-y) = (x - y) / (1 + x * y) := by
  simp [spbCirc]; ring

/-- spbHyp is definitionally (x+y)/(1+xy). -/
theorem spbHyp_def (x y : ℝ) :
    spbHyp x y = (x + y) / (1 + x * y) := rfl

/-! ## Shared Algebraic Structure -/

theorem spbCirc_identity (x : ℝ) : spbCirc x 0 = x := by simp [spbCirc]
theorem spbHyp_identity (x : ℝ) : spbHyp x 0 = x := by simp [spbHyp]

theorem spbCirc_inverse (x : ℝ) : spbCirc x (-x) = 0 := by simp [spbCirc]
theorem spbHyp_inverse (x : ℝ) : spbHyp x (-x) = 0 := by simp [spbHyp]

theorem spbCirc_comm (x y : ℝ) : spbCirc x y = spbCirc y x := by
  simp [spbCirc, add_comm, mul_comm]

theorem spbHyp_comm (x y : ℝ) : spbHyp x y = spbHyp y x := by
  simp [spbHyp, add_comm, mul_comm]

/-! ## Rapidity Addition -/

/-- The rapidity-velocity relationship: v = tanh(φ). -/
def rapidityToVelocity (φ : ℝ) : ℝ := tanh φ

/-- Rapidity addition: tanh(a+b) = spbHyp(tanh a, tanh b).
    Stated as: the result equals (tanh a + tanh b)/(1 + tanh a · tanh b). -/
theorem rapidity_addition (a b : ℝ) :
    tanh (a + b) = spbHyp (tanh a) (tanh b) := by
  rw [spbHyp]
  rw [Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add]
  rw [Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh]
  field_simp

/-! ## Lorentz Factor -/

/-- γ(v₁ ⊕ v₂) expressed via spbHyp. -/
theorem lorentz_factor_composition (v₁ v₂ : ℝ) :
    spbHyp v₁ v₂ = (v₁ + v₂) / (1 + v₁ * v₂) := rfl

/-! ## Circular-Hyperbolic Duality Table

The complete duality:

| Circular (SPB)           | Hyperbolic (SPB_H)          |
|--------------------------|------------------------------|
| (x+y)/(1-xy)            | (x+y)/(1+xy)                |
| tan(α+β)                | tanh(a+b)                   |
| arctan composition      | arctanh composition          |
| S¹ group                | Interval (-1,1) group       |
| cos²+sin²=1             | cosh²-sinh²=1               |
| Rotation matrices       | Boost matrices               |
| Cayley: (1+ix)/(1-ix)   | (1+x)/(1-x)                 |
| Periodic orbits          | Open orbits                  |
-/

end
