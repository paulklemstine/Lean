/-! # CatalogBuild.Speculative.SPBBridge.SPBDeepResults

Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 22
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBDeepResults
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 23] -/
theorem spb_iter_half_2 : spb (1/2 : ℝ) (1/2) = 4/3 := by
  unfold spb; norm_num




/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBDeepResults
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 22] -/
theorem spb_iter_third_2 : spb (1/3 : ℝ) (1/3) = 3/4 := by
  unfold spb; norm_num




/-- Euler's two-leaf formula: arctan(1/2) + arctan(1/3) = π/4. -/
theorem euler_two_leaf : spb (1/2 : ℝ) (1/3) = 1 := by
  unfold spb; norm_num




theorem spb_eq_iff (a b q : ℝ) (h : 1 - a * b ≠ 0) :
    spb a b = q ↔ a + b = q * (1 - a * b) := by
  unfold spb; rw [div_eq_iff h]




theorem spb_23 : spb (2 : ℝ) 3 = -1 := by unfold spb; norm_num



theorem spb_12 : spb (1 : ℝ) 2 = -3 := by unfold spb; norm_num



theorem spb_13 : spb (1 : ℝ) 3 = -2 := by unfold spb; norm_num




theorem spb_int_divisibility (a b : ℤ) (h : 1 - a * b ≠ 0)
    (hq : (1 - a * b) ∣ (a + b)) :
    ∃ q : ℤ, (a : ℝ) + b = q * (1 - a * b) := by
  obtain ⟨ q, hq ⟩ := hq; use q; norm_cast; linarith;




theorem three_leaf_algebraic (a b c : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hc : 2 ≤ c)
    (hab : a ≤ b) (hbc : b ≤ c)
    (h : (a + b) * (c + 1) = (a * b - 1) * (c - 1)) :
    (a = 2 ∧ b = 4 ∧ c = 13) ∨ (a = 2 ∧ b = 5 ∧ c = 8) ∨ (a = 3 ∧ b = 3 ∧ c = 7) := by
  by_cases ha_le_3 : a ≤ 3;
  · interval_cases a <;> norm_num at *;
    · have : b ≤ 13 := Int.le_of_lt_add_one ( by nlinarith ) ; interval_cases b <;> norm_num at * <;> omega;
    · have : b ≤ 7 := Int.le_of_lt_add_one ( by nlinarith ) ; interval_cases b <;> norm_num at * <;> omega;
  · nlinarith [ mul_le_mul_of_nonneg_left hb ( sub_nonneg.2 ha ), mul_le_mul_of_nonneg_left hc ( sub_nonneg.2 hb ) ]




theorem tspb_zero (x : ℝ) : tspb x 0 = 0 := by
  unfold tspb;
  grind




theorem tspb_idempotent_neg (x : ℝ) (hx : x ≤ 0) : tspb x x = x := by
  unfold tspb; rw [ max_self, max_eq_left ] <;> linarith;




theorem cayley_normSq_val (x : ℝ) :
    Complex.normSq (1 + ↑x * Complex.I) = 1 + x ^ 2 := by
  norm_num [ Complex.normSq, sq ]




theorem lorentz_factor (u v : ℝ) (h : 1 + u * v ≠ 0)
    (hu : u ^ 2 ≠ 1) (hv : v ^ 2 ≠ 1) :
    1 - spbH u v ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) / (1 + u * v) ^ 2 := by
  unfold spbH; field_simp; ring




theorem gamma_product_sq (u v : ℝ) (h : 1 + u * v ≠ 0)
    (hu : u ^ 2 < 1) (hv : v ^ 2 < 1) :
    1 / (1 - spbH u v ^ 2) =
    (1 + u * v) ^ 2 / ((1 - u ^ 2) * (1 - v ^ 2)) := by
  convert congr_arg _ ( lorentz_factor u v h ( by nlinarith ) ( by nlinarith ) ) using 1;
  rw [ one_div_div ]




theorem spbOrbit_two_from_zero (a : ℝ) : spbOrbit a 2 0 = spb a a := by
  simp [spbOrbit, spb]




theorem spb_fundamental_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring




theorem spb_angle_norm_ratio (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  unfold spb; field_simp; ring




theorem spb_odd_symmetry (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  unfold spb; ring




theorem spb_reciprocal_neg (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (1/x) (1/y) = -(spb x y) := by
  unfold spb; ring_nf;
  grind




theorem weierstrass_circle (t : ℝ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp; ring




theorem spb_cf_inversion (x n : ℝ) (hn : n ≠ 0)
    (h1 : 1 + x / n ≠ 0) (h2 : 1 - x * (-1/n) ≠ 0) :
    spb (spb x (-1/n)) (1/n) = x := by
  unfold spb; ring_nf at *;
  rcases eq_or_ne ( n + x ) 0 <;> simp_all +decide [ sq, mul_assoc, mul_comm, mul_left_comm ];
  · grind;
  · field_simp;
    rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne hn <;> cases lt_or_gt_of_ne ‹¬n + x = 0› <;> nlinarith




theorem cayley_spb_hom (x y : ℝ) (h : 1 - x * y ≠ 0) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb;
  field_simp [h];
  rw [ div_eq_div_iff ] <;> norm_num [ Complex.ext_iff, h ];
  · norm_cast; ring;
    grind;
  · norm_cast; aesop




end
