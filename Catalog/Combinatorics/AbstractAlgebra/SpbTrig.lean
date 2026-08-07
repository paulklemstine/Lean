import Mathlib

/-! # Trigonometric face of the SPB operation

`spb x y = (x + y) / (1 - x*y)` is the tangent addition law.  This module
collects the genuinely trigonometric / complex-analytic SPB statements that the
auto-generated modules `Shared.AbstractAlgebra.Spb_zero_left` and
`Shared.AbstractAlgebra.Spb_zero_right` (two permutations of one another)
attempted but could not state, because the definitions they referenced —
`spb` itself and the Cayley transform `cayley` — were never emitted.

The purely algebraic SPB facts live in `Shared.AbstractAlgebra.Spb`; this module
re-exports that development and adds:

* `spb_tan_add`     — `tan (a + b) = spb (tan a) (tan b)`;
* `spb_tan_double`  — the double-angle instance;
* `spb_tan_triple`  — the triple-angle instance;
* `spb_cocycle`     — the two-cocycle identity for the denominators;
* `spb_cayley`      — `spb` is transported to multiplication by the Cayley
  transform `x ↦ (1 + i x)/(1 - i x)`, i.e. the SPB monoid is (a piece of) the
  circle group.
-/

open Complex

noncomputable section

namespace SpbTrig

/-- The SPB (Stereographic Projection Bridge) operation, `spb x y = (x+y)/(1-xy)`. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by simp [spb]

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by simp [spb]

/-- **SPB is the tangent addition law.** -/
theorem spb_tan_add (a b : ℝ) (ha : Real.cos a ≠ 0) (hb : Real.cos b ≠ 0) :
    Real.tan (a + b) = spb (Real.tan a) (Real.tan b) := by
  unfold spb
  exact Real.tan_add' ⟨Real.cos_ne_zero_iff.mp ha, Real.cos_ne_zero_iff.mp hb⟩

/-- Double-angle instance of the tangent addition law. -/
theorem spb_tan_double (a : ℝ) (ha : Real.cos a ≠ 0) :
    Real.tan (2 * a) = spb (Real.tan a) (Real.tan a) := by
  rw [two_mul]; exact spb_tan_add a a ha ha

/-- Triple-angle instance: iterating `spb` on `tan a` computes `tan (3a)`. -/
theorem spb_tan_triple (a : ℝ) (ha : Real.cos a ≠ 0) (h2a : Real.cos (2 * a) ≠ 0) :
    Real.tan (3 * a) = spb (spb (Real.tan a) (Real.tan a)) (Real.tan a) := by
  have h3 : (3 : ℝ) * a = 2 * a + a := by ring
  rw [h3, spb_tan_add _ _ h2a ha, spb_tan_double a ha]

/-- The SPB two-cocycle identity: the denominators of the two bracketings of
`spb` agree after multiplying by the inner denominators. -/
theorem spb_cocycle (x y z : ℝ) (hxy : x * y ≠ 1) (hyz : y * z ≠ 1) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  have h1 : 1 - x * y ≠ 0 := sub_ne_zero_of_ne (Ne.symm hxy)
  have h2 : 1 - y * z ≠ 0 := sub_ne_zero_of_ne (Ne.symm hyz)
  unfold spb
  field_simp
  ring

/-- The Cayley transform `ℝ → ℂ`, `x ↦ (1 + i x)/(1 - i x)`. -/
def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)

theorem cayley_den_ne (x : ℝ) : (1 : ℂ) - (x : ℂ) * Complex.I ≠ 0 := by
  intro h
  have := congrArg Complex.re h
  simp at this

/-- **The Cayley transform turns `spb` into multiplication.**  This is the exact
statement that SPB is the group law of the circle pulled back to `ℝ`. -/
theorem spb_cayley (x y : ℝ) (hxy : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  have h1 : (1 : ℝ) - x * y ≠ 0 := sub_ne_zero_of_ne (Ne.symm hxy)
  have h1c : (1 : ℂ) - (x : ℂ) * (y : ℂ) ≠ 0 := by
    intro h
    exact h1 (by exact_mod_cast (by push_cast; linear_combination h :
      ((1 - x * y : ℝ) : ℂ) = 0))
  have hden : (1 : ℂ) - ((((x : ℝ) + y) / (1 - x * y) : ℝ) : ℂ) * Complex.I ≠ 0 :=
    cayley_den_ne _
  have hI3 : (I : ℂ) ^ 3 = -I := by rw [pow_succ, Complex.I_sq]; ring
  unfold cayley spb
  rw [div_mul_div_comm, div_eq_div_iff hden (mul_ne_zero (cayley_den_ne x) (cayley_den_ne y))]
  push_cast
  field_simp
  ring_nf
  simp only [hI3, Complex.I_sq]
  ring

end SpbTrig

end