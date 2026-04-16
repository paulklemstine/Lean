import Mathlib

/-!
# Stereographic Bridge

The inverse stereographic projection σ⁻¹ : ℝ → S¹ ⊂ ℝ² is defined by:
  σ⁻¹(t) = (2t/(1+t²), (1-t²)/(1+t²))

## Main Results

- `stereo_inv_on_circle`: σ⁻¹(t) lies on the unit circle
- `stereo_round_trip`: σ(σ⁻¹(t)) = t
- `stereo_y_upper_bound`: y(t) ≤ 1
- `stereo_y_lower_bound`: -1 ≤ y(t)
- `stereo_at_zero`: σ⁻¹(0) = (0, 1)
- `stereo_at_one`: σ⁻¹(1) = (1, 0)
-/

noncomputable section

open Real

/-- x-coordinate of inverse stereographic projection. -/
def stereoX (t : ℝ) : ℝ := 2 * t / (1 + t ^ 2)

/-- y-coordinate of inverse stereographic projection. -/
def stereoY (t : ℝ) : ℝ := (1 - t ^ 2) / (1 + t ^ 2)

/-- 1 + t² > 0 for all real t. -/
lemma one_plus_sq_pos (t : ℝ) : 0 < 1 + t ^ 2 := by positivity

/-- 1 + t² ≠ 0 for all real t. -/
lemma one_plus_sq_ne_zero (t : ℝ) : 1 + t ^ 2 ≠ 0 := ne_of_gt (one_plus_sq_pos t)

/-
PROBLEM
σ⁻¹(t) lies on the unit circle: x² + y² = 1.

PROVIDED SOLUTION
Unfold stereoX and stereoY. Then field_simp using one_plus_sq_ne_zero, then ring.
-/
theorem stereo_inv_on_circle (t : ℝ) :
    stereoX t ^ 2 + stereoY t ^ 2 = 1 := by
      unfold stereoX stereoY; rw [ div_pow, div_pow ] ; rw [ ← add_div, div_eq_iff ] <;> nlinarith [ one_plus_sq_ne_zero t ] ;

/-
PROBLEM
The stereographic projection σ recovers t from σ⁻¹(t).
    σ(x,y) = x/(1+y) gives back t when (x,y) = σ⁻¹(t).

PROVIDED SOLUTION
Unfold stereoX and stereoY. Use field_simp with one_plus_sq_ne_zero, then ring. Key identity: 1 + (1-t²)/(1+t²) = 2/(1+t²), so x/(1+y) = (2t/(1+t²))/(2/(1+t²)) = t.
-/
theorem stereo_round_trip (t : ℝ) :
    stereoX t / (1 + stereoY t) = t := by
      -- Substitute the definitions of stereoX and stereoY into the expression.
      have h_sub : stereoX t / (1 + stereoY t) = (2 * t / (1 + t ^ 2)) / (1 + (1 - t ^ 2) / (1 + t ^ 2)) := by
        rfl;
      rw [ h_sub, div_div, mul_add, mul_div_cancel₀ ] <;> ring ; positivity

/-
PROBLEM
The y-coordinate is at most 1.

PROVIDED SOLUTION
stereoY t = (1 - t²)/(1 + t²) ≤ 1 iff 1 - t² ≤ 1 + t² (since 1+t² > 0) iff 0 ≤ 2t², which is true. Use div_le_one (one_plus_sq_pos t) and linarith [sq_nonneg t].
-/
theorem stereo_y_upper_bound (t : ℝ) : stereoY t ≤ 1 := by
  exact div_le_one_of_le₀ ( by nlinarith ) ( by nlinarith )

/-
PROBLEM
The y-coordinate is at least -1.

PROVIDED SOLUTION
-1 ≤ (1 - t²)/(1 + t²) iff -(1+t²) ≤ 1-t² iff -1-t² ≤ 1-t² iff -1 ≤ 1, which is true. Use le_div_iff or neg_one_le_... approach with nlinarith [sq_nonneg t].
-/
theorem stereo_y_lower_bound (t : ℝ) : -1 ≤ stereoY t := by
  rw [ stereoY ] ; rw [ le_div_iff₀ ] <;> nlinarith [ sq_nonneg t ] ;

/-
PROBLEM
σ⁻¹(0) = (0, 1), the north pole.

PROVIDED SOLUTION
Unfold stereoX and stereoY, substitute t=0, simp/norm_num.
-/
theorem stereo_at_zero : stereoX 0 = 0 ∧ stereoY 0 = 1 := by
  exact ⟨ by unfold stereoX; norm_num, by unfold stereoY; norm_num ⟩

/-
PROBLEM
σ⁻¹(1) = (1, 0), on the equator.

PROVIDED SOLUTION
Unfold stereoX and stereoY, substitute t=1, norm_num.
-/
theorem stereo_at_one : stereoX 1 = 1 ∧ stereoY 1 = 0 := by
  unfold stereoX stereoY; norm_num;

/-
PROBLEM
The frozen crystal: σ ∘ σ⁻¹ is the identity, so Fix(σ ∘ σ⁻¹) = ℝ.

PROVIDED SOLUTION
Use Set.eq_univ_iff_forall and stereo_round_trip to show every t satisfies the condition.
-/
theorem stereo_frozen_crystal :
    {t : ℝ | stereoX t / (1 + stereoY t) = t} = Set.univ := by
      exact Set.eq_univ_of_forall fun t => stereo_round_trip t

end