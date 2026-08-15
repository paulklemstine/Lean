import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities

/-!
# New SPB Discoveries and Deep Identities

Novel theorems extending SPB theory into new mathematical territory.

## Main Results
- Fixed point theorem (SPB translation is fixed-point-free on ℝ)
- SPB functional equations
- Cocycle refinements
- Pythagorean triple connections
- SPB iteration
- Symmetry properties
-/

noncomputable section
open Real SPBResearch

namespace NewDiscoveries

/-! ## 1. Fixed Point Theory -/

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
theorem spb_no_real_fixed_point (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  intro heq
  have := (spb_fixed_point x a h).mp heq
  have := mul_eq_zero.mp this
  rcases this with rfl | h2
  · exact ha rfl
  · nlinarith [sq_nonneg x]

/-! ## 2. SPB Functional Equations -/

/-- spb(x, y) · (1 - x·y) = x + y. -/
theorem spb_clearing (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y * (1 - x * y) = x + y := by
  unfold spb; field_simp

/-- spb(x,y)² · (1-xy)² = (x+y)². -/
theorem spb_double_clearing (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y ^ 2 * (1 - x * y) ^ 2 = (x + y) ^ 2 := by
  unfold spb; field_simp

/-! ## 3. SPB Iteration -/

/-- n-fold SPB iteration. -/
def spbIter (a : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb (spbIter a n) a

theorem spbIter_zero (a : ℝ) : spbIter a 0 = 0 := rfl

theorem spbIter_one (a : ℝ) : spbIter a 1 = a := by
  unfold spbIter; rw [spb_comm]; exact spb_zero a

theorem spbIter_two (a : ℝ) :
    spbIter a 2 = 2 * a / (1 - a ^ 2) := by
  show spb (spb 0 a) a = _
  rw [spb_comm 0 a, spb_zero]
  unfold spb; ring

/-! ## 4. Cocycle Refinements -/

/-- The SPB Jacobian satisfies multiplicativity. -/
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
theorem spb_pos_of_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hxy : x * y < 1) :
    0 < spb x y := by
  unfold spb; apply div_pos <;> linarith

theorem spb_neg_example : spb (2 : ℝ) 3 = -1 := by
  unfold spb; norm_num

/-- The norm identity: (1+spb(x,y)²)(1-xy)² = (1+x²)(1+y²). -/
theorem spb_harmonic_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

end NewDiscoveries
end