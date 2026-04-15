import Mathlib

/-!
# SPB Deep Results: New Theorems and Open Questions Resolved

## Overview
This file contains formally verified results about the Stereographic Projection
Bridge (SPB) operation `spb(x, y) = (x + y) / (1 - x * y)`.

## Main Results
- **Power formulas**: Closed forms for iterated SPB
- **Machin-type formulas**: Three-leaf and four-leaf decompositions verified
- **Tropical SPB**: Commutativity, idempotency
- **Cayley transform**: Norm preservation, homomorphism property
- **Lorentz factor identity**: Relativistic gamma via SPB
- **Cross-ratio preservation**: SPB difference formula
- **SPB dynamics**: Orbit structure theorems
-/

noncomputable section
open Real

namespace SPBDeep

/-! ## Core Definitions -/

def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)

/-! ## SPB Power Formulas -/

/-
The quadruple angle formula
-/
theorem spb_quadruple (t : ℝ) (h1 : 1 - t ^ 2 ≠ 0)
    (h2 : (1 - t ^ 2) ^ 2 - 4 * t ^ 2 ≠ 0) :
    spb (spb t t) (spb t t) =
    4 * t * (1 - t ^ 2) / ((1 - t ^ 2) ^ 2 - 4 * t ^ 2) := by
  unfold spb;
  grind

theorem spb_iter_half_2 : spb (1/2 : ℝ) (1/2) = 4/3 := by
  unfold spb; norm_num

theorem spb_iter_third_2 : spb (1/3 : ℝ) (1/3) = 3/4 := by
  unfold spb; norm_num

/-- Euler's two-leaf formula: arctan(1/2) + arctan(1/3) = π/4. -/
theorem euler_two_leaf : spb (1/2 : ℝ) (1/3) = 1 := by
  unfold spb; norm_num

/-! ## Integer SPB -/

theorem spb_eq_iff (a b q : ℝ) (h : 1 - a * b ≠ 0) :
    spb a b = q ↔ a + b = q * (1 - a * b) := by
  unfold spb; rw [div_eq_iff h]

theorem spb_23 : spb (2 : ℝ) 3 = -1 := by unfold spb; norm_num
theorem spb_12 : spb (1 : ℝ) 2 = -3 := by unfold spb; norm_num
theorem spb_13 : spb (1 : ℝ) 3 = -2 := by unfold spb; norm_num

/-
If (1-ab) | (a+b) in ℤ, then spb(a,b) is an integer.
-/
theorem spb_int_divisibility (a b : ℤ) (h : 1 - a * b ≠ 0)
    (hq : (1 - a * b) ∣ (a + b)) :
    ∃ q : ℤ, (a : ℝ) + b = q * (1 - a * b) := by
  obtain ⟨ q, hq ⟩ := hq; use q; norm_cast; linarith;

/-! ## Three-Leaf Machin Formulas -/

theorem three_leaf_3_3_7 : spb (spb (1/3 : ℝ) (1/3)) (1/7) = 1 := by
  unfold spb; norm_num

theorem three_leaf_2_5_8 : spb (spb (1/2 : ℝ) (1/5)) (1/8) = 1 := by
  unfold spb; norm_num

theorem three_leaf_2_4_13 : spb (spb (1/2 : ℝ) (1/4)) (1/13) = 1 := by
  unfold spb; norm_num

/-
Completeness of three-leaf Machin formulas with a ≤ b ≤ c.
    The solutions are exactly {(2,4,13), (2,5,8), (3,3,7)}.
-/
theorem three_leaf_algebraic (a b c : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hc : 2 ≤ c)
    (hab : a ≤ b) (hbc : b ≤ c)
    (h : (a + b) * (c + 1) = (a * b - 1) * (c - 1)) :
    (a = 2 ∧ b = 4 ∧ c = 13) ∨ (a = 2 ∧ b = 5 ∧ c = 8) ∨ (a = 3 ∧ b = 3 ∧ c = 7) := by
  by_cases ha_le_3 : a ≤ 3;
  · interval_cases a <;> norm_num at *;
    · have : b ≤ 13 := Int.le_of_lt_add_one ( by nlinarith ) ; interval_cases b <;> norm_num at * <;> omega;
    · have : b ≤ 7 := Int.le_of_lt_add_one ( by nlinarith ) ; interval_cases b <;> norm_num at * <;> omega;
  · nlinarith [ mul_le_mul_of_nonneg_left hb ( sub_nonneg.2 ha ), mul_le_mul_of_nonneg_left hc ( sub_nonneg.2 hb ) ]

/-! ## Tropical SPB -/

def tspb (x y : ℝ) : ℝ := max x y - max 0 (x + y)

theorem tspb_comm (x y : ℝ) : tspb x y = tspb y x := by
  unfold tspb; ring;
  rw [ max_comm, neg_add_eq_sub ]

theorem tspb_zero (x : ℝ) : tspb x 0 = 0 := by
  unfold tspb;
  grind

theorem tspb_idempotent_neg (x : ℝ) (hx : x ≤ 0) : tspb x x = x := by
  unfold tspb; rw [ max_self, max_eq_left ] <;> linarith;

/-
For x,y ≥ 0, tspb(x,y) = -min(x,y).
-/
theorem tspb_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tspb x y = -min x y := by
  unfold tspb;
  grind +qlia

/-! ## SPB Derivative Chain Rule -/

theorem spb_chain_rule (f g : ℝ → ℝ) (t₀ : ℝ) (f' g' : ℝ)
    (hf : HasDerivAt f f' t₀) (hg : HasDerivAt g g' t₀)
    (h : 1 - f t₀ * g t₀ ≠ 0) :
    HasDerivAt (fun t => spb (f t) (g t))
      ((f' * (1 + g t₀ ^ 2) + g' * (1 + f t₀ ^ 2)) / (1 - f t₀ * g t₀) ^ 2) t₀ := by
  convert HasDerivAt.div ( hf.add hg ) ( HasDerivAt.const_sub 1 ( hf.mul hg ) ) ( by positivity ) using 1 ; ring!;
  norm_num ; ring

/-! ## Cayley Transform -/

def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)

/-
Cayley transform has equal normSq in numerator and denominator.
-/
theorem cayley_normSq_eq (x : ℝ) :
    Complex.normSq (1 + ↑x * Complex.I) = Complex.normSq (1 - ↑x * Complex.I) := by
  norm_num [ Complex.normSq_add, Complex.normSq_sub ]

/-
Both numerator and denominator of cayley have normSq = 1 + x².
-/
theorem cayley_normSq_val (x : ℝ) :
    Complex.normSq (1 + ↑x * Complex.I) = 1 + x ^ 2 := by
  norm_num [ Complex.normSq, sq ]

theorem cayley_zero : cayley 0 = 1 := by unfold cayley; simp

theorem cayley_one : cayley 1 = Complex.I := by
  unfold cayley;
  rw [ div_eq_iff ] <;> norm_num [ Complex.ext_iff ]

/-! ## Lorentz Factor -/

theorem lorentz_factor (u v : ℝ) (h : 1 + u * v ≠ 0)
    (hu : u ^ 2 ≠ 1) (hv : v ^ 2 ≠ 1) :
    1 - spbH u v ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) / (1 + u * v) ^ 2 := by
  unfold spbH; field_simp; ring

/-
The gamma factor product rule (corrected):
    1/(1 - w²) = (1+uv)² / ((1-u²)(1-v²)).
-/
theorem gamma_product_sq (u v : ℝ) (h : 1 + u * v ≠ 0)
    (hu : u ^ 2 < 1) (hv : v ^ 2 < 1) :
    1 / (1 - spbH u v ^ 2) =
    (1 + u * v) ^ 2 / ((1 - u ^ 2) * (1 - v ^ 2)) := by
  convert congr_arg _ ( lorentz_factor u v h ( by nlinarith ) ( by nlinarith ) ) using 1;
  rw [ one_div_div ]

/-! ## Machin's Formula -/

theorem machin_classical :
    spb (spb (spb (1/5 : ℝ) (1/5)) (spb (1/5) (1/5))) (-1/239) = 1 := by
  unfold spb; norm_num

/-! ## SPB Dynamics -/

def spbOrbit (a : ℝ) : ℕ → ℝ → ℝ
  | 0, x => x
  | n+1, x => spb (spbOrbit a n x) a

theorem spbOrbit_zero (a x : ℝ) : spbOrbit a 0 x = x := rfl
theorem spbOrbit_one (a x : ℝ) : spbOrbit a 1 x = spb x a := rfl
theorem spbOrbit_two_from_zero (a : ℝ) : spbOrbit a 2 0 = spb a a := by
  simp [spbOrbit, spb]

/-! ## SPB Norm Identity -/

theorem spb_fundamental_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

theorem spb_angle_norm_ratio (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  unfold spb; field_simp; ring

/-! ## SPB Symmetry -/

theorem spb_odd_symmetry (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  unfold spb; ring

/-
Inversion anti-automorphism: spb(1/x, 1/y) = -spb(x,y).
-/
theorem spb_reciprocal_neg (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (1/x) (1/y) = -(spb x y) := by
  unfold spb; ring_nf;
  grind

/-! ## Weierstrass Substitution -/

theorem weierstrass_circle (t : ℝ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp; ring

/-! ## Cross-Ratio -/

theorem spb_difference_formula (a b t : ℝ)
    (ha : 1 - a * t ≠ 0) (hb : 1 - b * t ≠ 0) :
    spb a t - spb b t = (a - b) * (1 + t ^ 2) / ((1 - a * t) * (1 - b * t)) := by
  unfold spb; rw [ div_sub_div ] <;> ring <;> positivity;

/-! ## SPB CF Inversion -/

theorem spb_cf_inversion (x n : ℝ) (hn : n ≠ 0)
    (h1 : 1 + x / n ≠ 0) (h2 : 1 - x * (-1/n) ≠ 0) :
    spb (spb x (-1/n)) (1/n) = x := by
  unfold spb; ring_nf at *;
  rcases eq_or_ne ( n + x ) 0 <;> simp_all +decide [ sq, mul_assoc, mul_comm, mul_left_comm ];
  · grind;
  · field_simp;
    rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne hn <;> cases lt_or_gt_of_ne ‹¬n + x = 0› <;> nlinarith

/-! ## Cayley Homomorphism -/

theorem cayley_spb_hom (x y : ℝ) (h : 1 - x * y ≠ 0) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb;
  field_simp [h];
  rw [ div_eq_div_iff ] <;> norm_num [ Complex.ext_iff, h ];
  · norm_cast; ring;
    grind;
  · norm_cast; aesop

end SPBDeep
end