import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities
open SPBResearch
open Real

/-! # CatalogBuild.Bridges.SPBMonoid

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

noncomputable section

/-- [Section: # SPB Abstract Algebra: Monoid and Group Structure] -/
theorem spb_rat (p q r s : ℤ) (hq : (q : ℝ) ≠ 0) (hs : (s : ℝ) ≠ 0)
    (hden : (q : ℝ) * s - p * r ≠ 0) :
    spb ((p : ℝ) / q) ((r : ℝ) / s) = (p * s + r * q : ℝ) / (q * s - p * r) := by
  unfold spb;
  field_simp

/-- [Section: # CatalogBuild.Bridges.SPBMonoid
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem spb_half_third : spb (1/2 : ℝ) (1/3) = 1 := by unfold spb; norm_num

theorem spb_half_half : spb (1/2 : ℝ) (1/2) = 4/3 := by unfold spb; norm_num

theorem spb_third_third : spb (1/3 : ℝ) (1/3) = 3/4 := by unfold spb; norm_num

theorem spb_quarter_quarter : spb (1/4 : ℝ) (1/4) = 8/15 := by unfold spb; norm_num

theorem spb_fifth_fifth : spb (1/5 : ℝ) (1/5) = 5/12 := by unfold spb; norm_num

/-- (1 + spb(x,y)²) = (1+x²)(1+y²)/(1-xy)². -/
theorem norm_sq_identity (x y : ℝ) (h : 1 - x * y ≠ 0) :
    1 + spb x y ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  unfold spb; field_simp; ring

/-- Half-angle quadratic: if s = spb(t,t), then s·t²+2t-s = 0. -/
theorem half_angle_quadratic (s t : ℝ) (h : 1 - t ^ 2 ≠ 0) (hs : s = spb t t) :
    s * t ^ 2 + 2 * t - s = 0 := by
  rw [hs]; unfold spb; field_simp; ring

theorem spb_involution (x a : ℝ) (h1 : 1 - x * a ≠ 0)
    (h2 : 1 - spb x a * (-a) ≠ 0) :
    spb (spb x a) (-a) = x := by
  unfold spb at *;
  grind

theorem spb_injective_on (a x y : ℝ) (hx : 1 - x * a ≠ 0) (hy : 1 - y * a ≠ 0)
    (h : spb x a = spb y a) : x = y := by
  by_contra hxy;
  -- By cross-multiplying, we get $(x + a)(1 - ya) = (y + a)(1 - xa)$.
  have h_cross : (x + a) * (1 - y * a) = (y + a) * (1 - x * a) := by
    unfold spb at h; rw [ div_eq_div_iff ] at h <;> first |linarith|aesop;
  -- Since $x \neq y$, we must have $1 + a^2 = 0$, which is a contradiction because $a^2$ is non-negative.
  have h_contra : 1 + a^2 = 0 := by
    exact mul_left_cancel₀ ( sub_ne_zero_of_ne hxy ) ( by linarith );
  nlinarith

theorem spb_subtraction_formula (x y : ℝ) (h : 1 + x * y ≠ 0) :
    spb x (-y) = (x - y) / (1 + x * y) := by
  unfold spb;
  ring

theorem tan_add_is_spb (α β : ℝ)
    (hα : ∀ k : ℤ, α ≠ (2 * ↑k + 1) * π / 2)
    (hβ : ∀ k : ℤ, β ≠ (2 * ↑k + 1) * π / 2)
    (h : 1 - Real.tan α * Real.tan β ≠ 0) :
    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
  rw [Real.tan_add (Or.inl ⟨hα, hβ⟩)]
  unfold spb
  rfl

end