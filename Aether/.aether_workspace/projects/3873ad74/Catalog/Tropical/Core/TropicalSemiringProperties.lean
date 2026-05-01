import Mathlib

/-! # Tropical Semiring Properties

Formalizes core properties of the tropical semiring (ℝ, max, +).

Main results:
1. tropical_max_idempotent: max(x, x) = x
2. tropical_add_comm: max(x, y) = max(y, x)
3. tropical_add_assoc: max(max(x,y),z) = max(x,max(y,z))
4. tropical_scalar_distrib: a + max(b,c) = max(a+b, a+c)
5. tropical_scalar_distrib_right: max(a,b) + c = max(a+c, b+c)
6. tropical_absorption: max(x, max(x, y)) = max(x, y)
7. tropical_add_mono: x ≤ y → max(x,z) ≤ max(y,z)
8. tropical_mul_identity: x + 0 = x
9. tropical_mul_inv: x + (-x) = 0
-/

namespace TropicalSemiringProperties

theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_eq_left (le_refl x)

theorem tropical_add_comm (x y : ℝ) : max x y = max y x := max_comm x y

theorem tropical_add_assoc (x y z : ℝ) : max (max x y) z = max x (max y z) := by
  rw [← max_assoc x y z]

theorem tropical_scalar_distrib (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  cases le_total b c with
  | inl h =>
    rw [max_eq_right h]
    have : a + c ≥ a + b := by linarith
    rw [max_eq_right this]
  | inr h =>
    rw [max_eq_left h]
    have : a + b ≥ a + c := by linarith
    rw [max_eq_left this]

theorem tropical_scalar_distrib_right (a b c : ℝ) :
    max a b + c = max (a + c) (b + c) := by
  have h := tropical_scalar_distrib c a b
  rw [add_comm c (max a b), add_comm c a, add_comm c b] at h
  exact h

theorem tropical_absorption (x y : ℝ) : max x (max x y) = max x y := by simp

theorem tropical_absorption_dual (x y : ℝ) : max (max x y) y = max x y := by simp

theorem tropical_add_mono (x y z : ℝ) (h : x ≤ y) : max x z ≤ max y z :=
  max_le_max h le_rfl

theorem tropical_mul_identity (x : ℝ) : x + 0 = x := add_zero x

theorem tropical_mul_inv (x : ℝ) : x + (-x) = 0 := add_neg_cancel x

theorem tropical_mul_comm (x y : ℝ) : x + y = y + x := add_comm x y

theorem tropical_mul_assoc (x y z : ℝ) : x + y + z = x + (y + z) := add_assoc x y z

end TropicalSemiringProperties
