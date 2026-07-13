import Mathlib

/-!
# Multiplication by `i` is a fixed-point-free isometric complex structure

This file addresses the algebraic obstruction at the heart of **Conjecture 3** of
the "Composition-Algebra Playground" research direction: on `ℂⁿ`, the map
`J = ·i` ("rotation through the fourth dimension") is a genuine algebraic complex
structure — it squares to `−1`, preserves the Euclidean norm, and, crucially, is
**fixed-point-free** on the unit sphere `S^{2n-1}`.

We work with the concrete squared Euclidean norm `N v = ∑ᵢ ‖vᵢ‖²` on
`Fin n → ℂ`, so that `N v = 1` is exactly the equation of `S^{2n-1} ⊆ ℂⁿ`.

* `J_sq` : `J (J v) = -v`  (so `J² = −1`);
* `N_J` : `N (J v) = N v`  (norm preservation);
* `fixed_point_free` : `J v = v → v = 0`  (no fixed point on any nonzero vector);
* `no_fixed_point_on_sphere` : `J` has no fixed point on the unit sphere;
* `J_add`, `J_real_smul` : `J` is real-linear.
-/

open Finset

namespace AlmostComplex

variable {n : ℕ}

/-- The candidate complex structure `J = ·i` on `ℂⁿ`. -/
def J (v : Fin n → ℂ) : Fin n → ℂ := fun i => Complex.I * v i

/-- Squared Euclidean norm on `ℂⁿ`; `N v = 1` is the equation of `S^{2n-1}`. -/
noncomputable def N (v : Fin n → ℂ) : ℝ := ∑ i, ‖v i‖ ^ 2

/--
`J² = −1`: multiplication by `i` is an almost-complex structure.
-/
theorem J_sq (v : Fin n → ℂ) : J (J v) = -v := by
  ext i; simp +decide [ J, mul_assoc, mul_comm Complex.I ] ;

/--
`J` preserves the (squared) Euclidean norm.
-/
theorem N_J (v : Fin n → ℂ) : N (J v) = N v := by
  unfold N J; simp +decide

/--
**Fixed-point freeness.**  `J v = v` forces `v = 0`; the single scalar fact
`Complex.I - 1 ≠ 0` is the obstruction.
-/
theorem fixed_point_free (v : Fin n → ℂ) (h : J v = v) : v = 0 := by
  -- From `h : J v = v`, for each `i` we get `Complex.I * v i = v i` by `congrFun h i`.
  -- Then `(Complex.I - 1) * v i = 0`.
  have h1 : ∀ i, (Complex.I - 1) * v i = 0 := by
    exact fun i => by rw [ sub_mul, one_mul, sub_eq_zero ] ; exact congr_fun h i;
  exact funext fun i => eq_zero_of_ne_zero_of_mul_left_eq_zero ( sub_ne_zero_of_ne ( by simp +decide [ Complex.ext_iff ] ) ) ( h1 i )

/--
`J` has no fixed point on the unit sphere `S^{2n-1} = { v | N v = 1 }`.
-/
theorem no_fixed_point_on_sphere (v : Fin n → ℂ) (hv : N v = 1) : J v ≠ v := by
  contrapose! hv;
  rw [ show v = 0 from fixed_point_free v hv ] ; norm_num [ N ]

/--
`J` is additive.
-/
theorem J_add (v w : Fin n → ℂ) : J (v + w) = J v + J w := by
  exact funext fun i => mul_add _ _ _

/--
`J` commutes with real scaling; together with `J_add` this is real-linearity.
-/
theorem J_real_smul (c : ℝ) (v : Fin n → ℂ) : J (c • v) = c • J v := by
  ext i; exact (by
  simp +decide [ J, mul_comm ];
  ring)

end AlmostComplex