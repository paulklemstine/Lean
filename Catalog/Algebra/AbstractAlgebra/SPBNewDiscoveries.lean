import Mathlib

/-! # CatalogBuild.Speculative.SPBNewDiscoveries

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 16
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBNewDiscoveries
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 19] -/
theorem norm_factorization (x y : ℝ) :
    (1 + (x + y) ^ 2) * (1 + (x * y) ^ 2) ≤
    ((1 + x ^ 2) * (1 + y ^ 2)) ^ 2 := by
  nlinarith [sq_nonneg x, sq_nonneg y, sq_nonneg (x*y), sq_nonneg (x - y),
             sq_nonneg (x + y), sq_nonneg (x*y - 1), sq_nonneg (x*y + 1)]

/-- [Section: # CatalogBuild.Speculative.SPBNewDiscoveries
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 16] -/
theorem spbMat_not_SL2 (n : ℤ) (hn : n ≠ 0) :
    (spbMat n).det ≠ 1 := by
  rw [spbMat_det]
  have : n ^ 2 > 0 := by positivity
  omega

theorem spb_arctan_add (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spb x y) = arctan x + arctan y := by
  unfold spb
  exact (Real.arctan_add (by linarith)).symm

theorem spb_difference_formula (a b t : ℝ)
    (ha : 1 - a * t ≠ 0) (hb : 1 - b * t ≠ 0) :
    spb a t - spb b t =
      (a - b) * (1 + t ^ 2) / ((1 - a * t) * (1 - b * t)) := by
  unfold spb;
  rw [ div_sub_div ] <;> ring <;> assumption

theorem crossRatio_spb_invariant (a b c d t : ℝ)
    (ha : 1 - a * t ≠ 0) (hb : 1 - b * t ≠ 0)
    (hc : 1 - c * t ≠ 0) (hd : 1 - d * t ≠ 0)
    (hac : a ≠ c) (hbd : b ≠ d) :
    crossRatio (spb a t) (spb b t) (spb c t) (spb d t) =
      crossRatio a b c d := by
  unfold crossRatio;
  rw [ spb_difference_formula, spb_difference_formula, spb_difference_formula, spb_difference_formula ];
  all_goals try assumption;
  field_simp;
  convert mul_div_mul_right _ _ ( mul_ne_zero ( by contrapose! hc; linarith : ( 1 - t * c ) ≠ 0 ) ( by contrapose! hd; linarith : ( 1 - t * d ) ≠ 0 ) ) using 1 ; ring

theorem deriv_cauchy_kernel (x : ℝ) :
    HasDerivAt (fun t => 1 / (1 + t ^ 2)) (-2 * x / (1 + x ^ 2) ^ 2) x := by
  simpa [ div_eq_mul_inv ] using HasDerivAt.inv ( hasDerivAt_pow 2 x |> HasDerivAt.const_add ( 1 : ℝ ) ) ( by positivity )

theorem circular_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

theorem hyperbolic_norm (x y : ℝ) (h : 1 + x * y ≠ 0) :
    (1 + x * y) ^ 2 * (1 - spbH x y ^ 2) = (1 - x ^ 2) * (1 - y ^ 2) := by
  unfold spbH; field_simp; ring

theorem sum_of_squares_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
      (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

def spbProj (x₁ x₂ y₁ y₂ : ℝ) : ℝ × ℝ :=
  (x₁ * y₂ + x₂ * y₁, x₂ * y₂ - x₁ * y₁)

theorem spbProj_reduces (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (spbProj x 1 y 1).1 / (spbProj x 1 y 1).2 = spb x y := by
  unfold spbProj spb; aesop

theorem spbProj_comm (x₁ x₂ y₁ y₂ : ℝ) :
    spbProj x₁ x₂ y₁ y₂ = spbProj y₁ y₂ x₁ x₂ := by
  simp only [spbProj, Prod.mk.injEq]; constructor <;> ring

theorem spbProj_identity (x₁ x₂ : ℝ) :
    spbProj x₁ x₂ 0 1 = (x₁, x₂) := by simp [spbProj]

theorem spbProj_inverse (x : ℝ) :
    spbProj x 1 (-x) 1 = (0, 1 + x ^ 2) := by
  simp only [spbProj, Prod.mk.injEq]; constructor <;> ring

/-- SPB matrices are elliptic (trace² < 4·det) for nonzero parameter.
This means the corresponding Möbius transformation has no real fixed
points, confirming the no-fixed-point theorem algebraically. -/
theorem spbMat_elliptic (n : ℤ) (hn : n ≠ 0) :
    (spbMat n).trace ^ 2 < 4 * (spbMat n).det := by
  rw [spbMat_trace, spbMat_det]
  have : n ^ 2 > 0 := by positivity
  nlinarith

theorem geometric_cocycle (x y : ℝ) (h : |x * y| < 1) :
    HasSum (fun n => (x * y) ^ n) (1 / (1 - x * y)) := by
  simpa using hasSum_geometric_of_abs_lt_one h

end