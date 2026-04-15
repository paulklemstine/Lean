/-! # CatalogBuild.SPBBridge.NewDiscoveries

Auto-generated from theorem catalog database.
Domain: SPBBridge
Declarations: 13
-/

import Mathlib
import SPBBridge.Core

noncomputable section

/-- spb(x, a) = x iff a(x² + 1) = 0. -/
theorem spb_fixed_point (x a : ℝ) (h : 1 - x * a ≠ 0) :
    spb x a = x ↔ a * (x ^ 2 + 1) = 0 := by
  constructor
  · intro heq
    unfold spb at heq
    have := (div_eq_iff h).mp heq
    nlinarith
  · intro heq
    unfold spb
    rw [div_eq_iff h]
    nlinarith

/-- For a ≠ 0, spb(x, a) ≠ x for all x ∈ ℝ. -/

theorem spb_clearing (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y * (1 - x * y) = x + y := by
  unfold spb; field_simp

/-- spb(x,y)² · (1-xy)² = (x+y)². -/

theorem spb_double_clearing (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y ^ 2 * (1 - x * y) ^ 2 = (x + y) ^ 2 := by
  unfold spb; field_simp

/-! ## 3. SPB Iteration -/

/-- n-fold SPB iteration. -/

theorem jacobian_chain (x y z : ℝ) (hxy : 1 - x * y ≠ 0) (hyz : 1 - y * z ≠ 0) :
    (1 - spb x y * z) * (1 - x * y) = (1 - x * spb y z) * (1 - y * z) := by
  unfold spb at *; field_simp; ring

/-- The derivative of spb(·, y) at x. -/

theorem deriv_jacobian (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun t => spb t y) ((1 + y ^ 2) / (1 - x * y) ^ 2) x := by
  unfold spb
  have := HasDerivAt.div
    (HasDerivAt.add (hasDerivAt_id x) (hasDerivAt_const x y))
    (HasDerivAt.sub (hasDerivAt_const x 1) (HasDerivAt.mul_const (hasDerivAt_id x) y))
    h
  convert this using 1; simp [id]; field_simp; ring

/-! ## 5. SPB Symmetries -/

/-- Parity: spb(-x, -y) = -spb(x, y). -/

theorem spb_parity (x y : ℝ) : spb (-x) (-y) = -(spb x y) := by
  unfold spb; ring

/-
Inversion: spb(1/x, 1/y) = -spb(x, y).
-/

theorem spb_inversion (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (h : x * y ≠ 1) :
    spb (1/x) (1/y) = -(spb x y) := by
  unfold spb;
  grind

/-- Corrected: spb(x, y) + spb(x, -y) = 2x(1+y²)/((1-xy)(1+xy)). -/

theorem spb_pm_sum (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spb x y + spb x (-y) =
    2 * x * (1 + y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have hh' : 1 - x * (-y) ≠ 0 := by rwa [mul_neg, sub_neg_eq_add]
  rw [div_add_div _ _ hc hh']
  congr 1 <;> ring

/-! ## 6. Pythagorean Triple Connections -/

/-- Every rational slope gives an SPB double formula. -/

theorem pythagorean_spb (a b : ℝ) (hb : b ≠ 0) :
    spb (a/b) (a/b) = 2 * a * b / (b ^ 2 - a ^ 2) := by
  unfold spb; field_simp; ring


theorem pythagorean_345 : spb (3/4 : ℝ) (3/4) = 24/7 := by
  unfold spb; norm_num


theorem pythagorean_5_12_13 : spb (5/12 : ℝ) (5/12) = 120/119 := by
  unfold spb; norm_num

/-! ## 7. SPB Sign and Bounds -/

/-- For positive inputs with xy < 1, spb is positive. -/

theorem spb_neg_example : spb (2 : ℝ) 3 = -1 := by
  unfold spb; norm_num

/-- The norm identity: (1+spb(x,y)²)(1-xy)² = (1+x²)(1+y²). -/

theorem spb_harmonic_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring


end
