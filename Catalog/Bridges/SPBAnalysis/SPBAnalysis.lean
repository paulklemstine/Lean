import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities
open Real
open SPBResearch

/-! # CatalogBuild.Bridges.SPBAnalysis

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

noncomputable section

/-- SPB is continuous at (x,y) when 1-xy ≠ 0. -/
theorem spb_continuous_at (x y : ℝ) (h : 1 - x * y ≠ 0) :
    ContinuousAt (fun p : ℝ × ℝ => spb p.1 p.2) (x, y) := by
  unfold spb
  apply ContinuousAt.div
  · exact continuousAt_fst.add continuousAt_snd
  · exact continuousAt_const.sub (continuousAt_fst.mul continuousAt_snd)
  · exact h

/-- arctan(spb(x,y)) = arctan(x) + arctan(y) when xy < 1. -/
theorem arctan_spb_add (x y : ℝ) (h : x * y < 1) :
    arctan (spb x y) = arctan x + arctan y := by
  unfold spb; exact (arctan_add h).symm

/-- arctan(0) = 0. -/
theorem arctan_zero' : arctan 0 = 0 := by simp

/-- arctan(1) = π/4. -/
theorem arctan_one' : arctan 1 = π / 4 := Real.arctan_one

/-- Euler's formula: arctan(1/2) + arctan(1/3) = π/4. -/
theorem euler_pi_formula : arctan (1/2) + arctan (1/3) = π / 4 := by
  rw [← arctan_one', ← arctan_spb_add (1/2) (1/3) (by norm_num)]
  congr 1; unfold spb; norm_num

/-- Cauchy PDF value is positive. -/
theorem cauchy_pdf_pos (a : ℝ) : 1 / (1 + a ^ 2) > 0 := by positivity

/-- Key identity: (1+spb²)(1-xy)² = (1+x²)(1+y²). -/
theorem cauchy_invariance_identity (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spb x a ^ 2) * (1 - x * a) ^ 2 = (1 + x ^ 2) * (1 + a ^ 2) := by
  unfold spb; field_simp; ring

/-- Orbit is trivially periodic when a = 0. -/
theorem spb_iterate_zero_period (x : ℝ) : spb (spb x 0) 0 = x := by simp [spb]

/-- spb(x,a) - a = x(1+a²)/(1-xa). -/
theorem spb_minus_a (x a : ℝ) (h : 1 - x * a ≠ 0) :
    spb x a - a = x * (1 + a ^ 2) / (1 - x * a) := by
  unfold spb; field_simp; ring

/-- spb(x,a) + 1/a = (1+a²)/(a(1-xa)). -/
theorem spb_plus_inv_a (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a + 1/a = (1 + a ^ 2) / (a * (1 - x * a)) := by
  unfold spb; field_simp; ring

/-- When a > 0 and xa < 1, second derivative is positive (convex). -/
theorem spb_convex_criterion (x a : ℝ) (ha : 0 < a) (h : x * a < 1) :
    0 < 2 * a * (1 + a ^ 2) / (1 - x * a) ^ 3 := by
  apply div_pos
  · positivity
  · have : 0 < 1 - x * a := by linarith
    positivity

/-- [Section: # SPB Analysis: Continuity, Integration, and Functional Equations
## Main Results
- SPB is continuous away from the pole xy = 1
- arctan is the SPB formal group logarithm
- Cauchy distribution invariance identity
- Euler's π/4 formula
- Convexity criteria] -/
theorem spb_concave_criterion (x a : ℝ) (ha : 0 < a) (h : 1 < x * a) :
    2 * a * (1 + a ^ 2) / (1 - x * a) ^ 3 < 0 := by
  exact div_neg_of_pos_of_neg ( by positivity ) ( by nlinarith [ sq_pos_of_pos ( sub_pos.mpr h ) ] )

end