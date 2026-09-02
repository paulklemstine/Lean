import Mathlib
import Shared.Ispythquadruple.IsPythQuadruple
import Shared.HigherPythagorean.LorentzCore
import Shared.HigherPythagorean.QuadrupleTree

/-!
# The hyperbolic (ideal boundary) picture, and algebraicity of the growth constant

Normalising a null vector by its height embeds the Pythagorean quadruples into the ideal
boundary `S²` of the hyperbolic `4`-space (equivalently, the boundary sphere of the Poincaré
ball), and the reflection move acts there by an explicit affine–fractional (Möbius) formula.

* `sphere_of_quad` : a Pythagorean quadruple normalises to a rational point of the unit sphere.
* `boundary_move` : the reflection acts on the boundary by `u ↦ (u − s + 1)/(2 − s)`, where
  `s = (a+b+c)/d` is the *shadow* of the node; the height is multiplied by `2 − s`.
* `shadow_bound` : `|s| ≤ √3`, so the height multiplier `2 − s` lies in `[2−√3, 2+√3]`.
* `growth_const_quadratic` : the growth constant `(√n+1)/(√n−1)` of dimension `n` is an
  algebraic number of degree ≤ 2: it is a root of `(n−1)X² − 2(n+1)X + (n−1)`.  For `n = 2` this
  is `X²−6X+1` (root `3+2√2 = (1+√2)²`, silver ratio) and for `n = 3` it is `X²−4X+1`
  (root `2+√3`).
-/

namespace HigherPythagorean

/-! ## Boundary sphere -/

/-- Normalising by the height sends a Pythagorean quadruple to a rational point of the unit
sphere, i.e. to a point of the ideal boundary of hyperbolic space. -/
theorem sphere_of_quad {a b c d : ℤ} (hd : d ≠ 0) (h : IsPythQuadruple a b c d) :
    ((a : ℚ) / (d : ℚ)) ^ 2 + ((b : ℚ) / (d : ℚ)) ^ 2 + ((c : ℚ) / (d : ℚ)) ^ 2 = 1 := by
  unfold IsPythQuadruple at h
  have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
  have h' : (a : ℚ) ^ 2 + (b : ℚ) ^ 2 + (c : ℚ) ^ 2 = (d : ℚ) ^ 2 := by exact_mod_cast h
  field_simp
  linarith [h']

/-- The *shadow* of a node: the sum of its normalised space coordinates. -/
def shadow (a b c d : ℤ) : ℚ := ((a : ℚ) + (b : ℚ) + (c : ℚ)) / (d : ℚ)

/-- The reflection move acts on the ideal boundary by the affine–fractional map
`u ↦ (u − s + 1)/(2 − s)`, and multiplies the height by `2 − s`. -/
theorem boundary_move {a b c d : ℤ} (hd : 0 < d) (hs : (a + b + c : ℤ) ≠ 2 * d) :
    ((d - qk a b c d : ℤ) : ℚ) = (2 - shadow a b c d) * (d : ℚ) ∧
    (((a - qk a b c d : ℤ) : ℚ)) / ((d - qk a b c d : ℤ) : ℚ) =
      ((a : ℚ) / (d : ℚ) - shadow a b c d + 1) / (2 - shadow a b c d) := by
  have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr (ne_of_gt hd)
  have hne : ((a : ℚ) + b + c) ≠ 2 * (d : ℚ) := by
    intro hcon
    apply hs
    have : ((a + b + c : ℤ) : ℚ) = ((2 * d : ℤ) : ℚ) := by push_cast; linarith
    exact_mod_cast this
  have h2s : (2 : ℚ) - shadow a b c d ≠ 0 := by
    unfold shadow
    intro hcon
    apply hne
    field_simp at hcon
    linarith
  have hnum : ((a - qk a b c d : ℤ) : ℚ) = (a : ℚ) - ((a : ℚ) + b + c) + (d : ℚ) := by
    unfold qk; push_cast; ring
  have hden : ((d - qk a b c d : ℤ) : ℚ) = 2 * (d : ℚ) - ((a : ℚ) + b + c) := by
    unfold qk; push_cast; ring
  have hdenne : (2 * (d : ℚ) - ((a : ℚ) + b + c)) ≠ 0 := by
    intro hcon; exact hne (by linarith)
  refine ⟨?_, ?_⟩
  · rw [hden]
    unfold shadow
    field_simp
  · rw [hnum, hden]
    unfold shadow at h2s ⊢
    rw [div_eq_div_iff hdenne h2s]
    field_simp

/-- The shadow of a Pythagorean quadruple is bounded by `√3`; hence the height multiplier
`2 − s` of the reflection lies in the annulus `[2−√3, 2+√3]`. -/
theorem shadow_bound {a b c d : ℤ} (hd : 0 < d) (h : IsPythQuadruple a b c d) :
    (shadow a b c d) ^ 2 ≤ 3 := by
  unfold IsPythQuadruple at h
  unfold shadow
  have hd' : (0 : ℚ) < (d : ℚ) := by exact_mod_cast hd
  have h' : (a : ℚ) ^ 2 + (b : ℚ) ^ 2 + (c : ℚ) ^ 2 = (d : ℚ) ^ 2 := by exact_mod_cast h
  rw [div_pow, div_le_iff₀ (by positivity)]
  nlinarith [sq_nonneg ((a : ℚ) - (b : ℚ)), sq_nonneg ((b : ℚ) - (c : ℚ)),
    sq_nonneg ((a : ℚ) - (c : ℚ))]

/-! ## Algebraicity of the growth constant -/

/-- **The growth constant is algebraic of degree ≤ 2.**  In dimension `n ≥ 2` the sharp one-step
growth constant `ρ = (√n+1)/(√n−1)` satisfies `(n−1)ρ² − 2(n+1)ρ + (n−1) = 0`.  For `n = 2` this
gives `ρ = 3+2√2 = (1+√2)²` (the square of the silver ratio) and for `n = 3` it gives
`ρ = 2+√3`. -/
theorem growth_const_quadratic {n : ℕ} (hn : 2 ≤ n) :
    ((n : ℝ) - 1) * ((Real.sqrt n + 1) / (Real.sqrt n - 1)) ^ 2
      - 2 * ((n : ℝ) + 1) * ((Real.sqrt n + 1) / (Real.sqrt n - 1)) + ((n : ℝ) - 1) = 0 := by
  have hn2 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set s := Real.sqrt n with hs
  have hs0 : 0 ≤ s := Real.sqrt_nonneg _
  have hs2 : s ^ 2 = (n : ℝ) := Real.sq_sqrt (by positivity)
  have hs1 : 1 < s := by nlinarith
  have hne : s - 1 ≠ 0 := by intro hcon; nlinarith
  field_simp
  nlinarith [hs2]

/-- Dimension two: the growth constant is the square of the silver ratio, a root of `X²−6X+1`. -/
theorem growth_const_two : (3 + 2 * Real.sqrt 2) = (1 + Real.sqrt 2) ^ 2 ∧
    (3 + 2 * Real.sqrt 2) ^ 2 - 6 * (3 + 2 * Real.sqrt 2) + 1 = 0 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  constructor <;> nlinarith [h2]

/-- Dimension three: the growth constant `2+√3` is a root of `X²−4X+1`. -/
theorem growth_const_three : (2 + Real.sqrt 3) ^ 2 - 4 * (2 + Real.sqrt 3) + 1 = 0 := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  nlinarith [h3]

end HigherPythagorean