import Mathlib

/-!
# Modular cusp orbits, horocycles, and Pythagorean triples

Integer translations of `i` in the upper half-plane become, under the Cayley
transform, the points `n/(n+2i)` of the Poincaré disk.  This file proves that
this modular orbit lies on the horocycle `|2z-1| = 1`.  After clearing
coordinates, the same identity is exactly Euclid's Pythagorean identity

`(n² - 4)² + (4n)² = (n² + 4)²`.

Thus one algebraic equation simultaneously describes a geometric cusp orbit
and an infinite family of integral right triangles.
-/

namespace HyperbolicNumberTheory

open Complex

/-- Cayley image of the modular translation orbit `n + i`. -/
noncomputable def cayleyModularOrbit (n : ℤ) : ℂ :=
  (n : ℂ) / ((n : ℂ) + 2 * I)

/-
Exact real coordinate of the Cayley-transformed modular orbit.
-/
theorem cayleyModularOrbit_re (n : ℤ) :
    (cayleyModularOrbit n).re = (n : ℝ) ^ 2 / ((n : ℝ) ^ 2 + 4) := by
  unfold cayleyModularOrbit
  norm_num [Complex.normSq, Complex.div_re]
  ring

/-
Exact imaginary coordinate of the Cayley-transformed modular orbit.
-/
theorem cayleyModularOrbit_im (n : ℤ) :
    (cayleyModularOrbit n).im = -(2 * (n : ℝ)) / ((n : ℝ) ^ 2 + 4) := by
  unfold cayleyModularOrbit
  norm_num [Complex.normSq, Complex.div_im]
  ring

/-
Every finite modular translate is strictly inside the Poincaré disk.
-/
theorem cayleyModularOrbit_mem_disk (n : ℤ) :
    normSq (cayleyModularOrbit n) < 1 := by
  unfold cayleyModularOrbit
  norm_num [Complex.normSq]
  rw [div_lt_iff₀] <;> nlinarith

/-
The modular translation orbit lies on the horocycle centered at `1/2`
with Euclidean radius `1/2`, tangent to the ideal boundary at `1`.
-/
theorem cayleyModularOrbit_horocycle (n : ℤ) :
    normSq (2 * cayleyModularOrbit n - 1) = 1 := by
  unfold cayleyModularOrbit
  norm_num [Complex.normSq, Complex.div_re, Complex.div_im]
  field_simp
  ring

/-
Euclid's Pythagorean identity in the normalization naturally supplied by
Cayley transformation of the modular orbit.
-/
theorem modular_pythagorean_identity (n : ℤ) :
    (n ^ 2 - 4) ^ 2 + (4 * n) ^ 2 = (n ^ 2 + 4) ^ 2 := by
  ring

/-
**Cayley–Pythagorean connector.**  The same integer parameter `n` determines
both a point of a modular cusp orbit on a Poincaré-disk horocycle and an
integral Pythagorean triple.  The first conjunct is genuinely geometric; the
second is the cleared-denominator arithmetic shadow of its circle equation.
-/
theorem cayley_pythagorean_bridge (n : ℤ) :
    normSq (cayleyModularOrbit n) < 1 ∧
    normSq (2 * cayleyModularOrbit n - 1) = 1 ∧
    (n ^ 2 - 4) ^ 2 + (4 * n) ^ 2 = (n ^ 2 + 4) ^ 2 := by
  exact ⟨cayleyModularOrbit_mem_disk n, cayleyModularOrbit_horocycle n,
    modular_pythagorean_identity n⟩

/-- Kernel-checked small cases for the arithmetic side of the bridge. -/
theorem first_pythagorean_instances :
    ((3 : ℤ) ^ 2 - 4, 4 * 3, (3 : ℤ) ^ 2 + 4) = (5, 12, 13) ∧
    ((4 : ℤ) ^ 2 - 4, 4 * 4, (4 : ℤ) ^ 2 + 4) = (12, 16, 20) ∧
    ((5 : ℤ) ^ 2 - 4, 4 * 5, (5 : ℤ) ^ 2 + 4) = (21, 20, 29) := by
  norm_num

end HyperbolicNumberTheory