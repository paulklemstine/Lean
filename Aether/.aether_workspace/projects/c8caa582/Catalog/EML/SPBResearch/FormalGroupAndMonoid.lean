import Mathlib

/-! # CatalogBuild.EML.SPBResearch.FormalGroupAndMonoid

Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 17
-/

noncomputable section

/-- The SPB operator -/
def spbFG (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- SPB identity -/
theorem spbFG_zero_right (x : ℝ) : spbFG x 0 = x := by simp [spbFG]

/-- SPB identity -/
theorem spbFG_zero_left (y : ℝ) : spbFG 0 y = y := by simp [spbFG]

/-- SPB inverse -/
theorem spbFG_inverse (x : ℝ) : spbFG x (-x) = 0 := by simp [spbFG]

/-- SPB commutativity -/
theorem spbFG_comm (x y : ℝ) : spbFG x y = spbFG y x := by
  simp [spbFG, add_comm, mul_comm]

/-- SPB associativity -/
theorem spbFG_assoc (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spbFG x y * z ≠ 0) (h4 : 1 - x * spbFG y z ≠ 0) :
    spbFG (spbFG x y) z = spbFG x (spbFG y z) := by
  unfold spbFG at *; field_simp at *; ring

/-- SPB double formula -/
theorem spbFG_double (x : ℝ) : spbFG x x = 2 * x / (1 - x ^ 2) := by
  unfold spbFG; ring

/-- [Section: # SPB Formal Group Law and Monoid Structure] -/
theorem spbFG_injective (x y a : ℝ)
    (hx : 1 - x * a ≠ 0) (hy : 1 - y * a ≠ 0)
    (heq : spbFG x a = spbFG y a) : x = y := by
  unfold spbFG at heq;
  rw [ div_eq_div_iff hx hy ] at heq;
  cases lt_or_gt_of_ne hx <;> cases lt_or_gt_of_ne hy <;> nlinarith [ sq_nonneg a ]

/-- [Section: # CatalogBuild.EML.SPBResearch.FormalGroupAndMonoid
Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 17] -/
theorem spbFG_involution (x a : ℝ)
    (h1 : 1 - x * a ≠ 0) (h2 : 1 - spbFG x a * (-a) ≠ 0) :
    spbFG (spbFG x a) (-a) = x := by
  unfold spbFG at *;
  grind

/-- Rational closure -/
theorem spbFG_rat_closure (p q r s : ℤ) (hq : (q : ℝ) ≠ 0) (hs : (s : ℝ) ≠ 0)
    (hd : (q * s - p * r : ℝ) ≠ 0) :
    spbFG (p / q) (r / s) = (p * s + r * q) / (q * s - p * r) := by
  unfold spbFG; push_cast; field_simp

/-- The arctan addition formula -/
theorem arctan_spbFG (x y : ℝ) (hxy : x * y < 1) :
    arctan (spbFG x y) = arctan x + arctan y := by
  rw [spbFG]; exact (Real.arctan_add hxy).symm

/-- Euler's π/4 formula: spb(1/2, 1/3) = 1 -/
theorem spbFG_euler_pi4 : spbFG (1/2) (1/3) = 1 := by norm_num [spbFG]

/-- The Cauchy invariance identity -/
theorem cauchy_invariance (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spbFG x a ^ 2) * (1 - x * a) ^ 2 = (1 + x ^ 2) * (1 + a ^ 2) := by
  unfold spbFG; field_simp; ring

/-- SPB difference identity -/
theorem spbFG_difference (a b c : ℝ) (hb : 1 - a * b ≠ 0) (hc : 1 - a * c ≠ 0) :
    spbFG a b - spbFG a c = (b - c) * (1 + a ^ 2) / ((1 - a * b) * (1 - a * c)) := by
  unfold spbFG; field_simp; ring

/-- SPB is continuous -/
theorem spbFG_continuousAt (x y : ℝ) (h : 1 - x * y ≠ 0) :
    ContinuousAt (fun p : ℝ × ℝ => spbFG p.1 p.2) (x, y) := by
  unfold spbFG
  exact ContinuousAt.div (continuousAt_fst.add continuousAt_snd)
    (continuousAt_const.sub (continuousAt_fst.mul continuousAt_snd)) h

/-- The derivative is always positive -/
theorem spbFG_deriv_pos (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by positivity

/-- The formal group law second-order term -/
theorem spbFG_power_series_coeff (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spbFG x y - (x + y) = x * y * (x + y) / (1 - x * y) := by
  unfold spbFG; field_simp; ring

end