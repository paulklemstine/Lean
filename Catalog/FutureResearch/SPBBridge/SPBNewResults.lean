import Mathlib

/-!
# SPB New Results: Formally Verified Theorems

## Overview
New formally verified results about the Stereographic Projection Bridge (SPB):
  spb(x, y) = (x + y) / (1 - x * y)

## Main Results
- `euler_machin_unique`: Euler's formula is the unique 2-leaf Machin formula
- `spb_hasDerivAt`: Derivative of spb(x, a)
- `spbH_bounded`: Einstein velocity addition preserves light speed bound
- Machin formula verifications (Euler, Hutton, three-leaf formulas)
- Cocycle identity
-/

noncomputable section
open Real

namespace SPBNew

/-! ## Section 1: SPB Definition -/

def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)

/-! ## Section 2: Basic Properties -/

theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  unfold spb; ring

theorem spb_zero (x : ℝ) : spb x 0 = x := by
  unfold spb; simp

theorem spb_neg (x : ℝ) : spb x (-x) = 0 := by
  unfold spb; simp

theorem spb_double (x : ℝ) : spb x x = 2 * x / (1 - x ^ 2) := by
  unfold spb; ring

theorem spb_neg_neg (x y : ℝ) : spb (-x) (-y) = -(spb x y) := by
  unfold spb; ring

/-! ## Section 3: Euler's Machin Formula -/

theorem euler_formula : spb (1/2 : ℝ) (1/3) = 1 := by
  unfold spb; norm_num

/-
The key algebraic fact: spb(1/a, 1/b) = 1 iff (a-1)(b-1) = 2,
    for nonzero a, b with ab ≠ 1.
-/
theorem spb_reciprocal_factored (a b : ℝ) (ha : a ≠ 0) (hb : b ≠ 0)
    (hab : 1 - (1/a) * (1/b) ≠ 0) :
    spb (1/a) (1/b) = 1 ↔ (a - 1) * (b - 1) = 2 := by
  unfold spb;
  grind

/-
**Euler's Machin formula is optimal**: For integers a, b ≥ 2,
    (a-1)(b-1) = 2 implies a = 2 ∧ b = 3 (assuming a ≤ b).
-/
theorem euler_machin_unique (a b : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hab : a ≤ b)
    (hspb : (a - 1) * (b - 1) = 2) :
    a = 2 ∧ b = 3 := by
  constructor <;> nlinarith

/-! ## Section 4: Three-Leaf Machin Formulas -/

theorem hutton_formula : spb (spb (1/3 : ℝ) (1/3)) (1/7) = 1 := by
  unfold spb; norm_num

theorem three_leaf_2_4_13 : spb (spb (1/2 : ℝ) (1/4)) (1/13) = 1 := by
  unfold spb; norm_num

theorem three_leaf_2_5_8 : spb (spb (1/2 : ℝ) (1/5)) (1/8) = 1 := by
  unfold spb; norm_num

/-- Machin's classical formula -/
theorem machin_formula :
    spb (spb (spb (1/5 : ℝ) (1/5)) (spb (1/5) (1/5))) (-1/239) = 1 := by
  unfold spb; norm_num

/-! ## Section 5: SPB Derivative -/

/-
The derivative of x ↦ spb(x, a) is (1 + a²)/(1 - xa)².
-/
theorem spb_hasDerivAt (a x₀ : ℝ) (h : 1 - x₀ * a ≠ 0) :
    HasDerivAt (fun x => spb x a) ((1 + a ^ 2) / (1 - x₀ * a) ^ 2) x₀ := by
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x₀ ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_id x₀ ) ( hasDerivAt_const _ _ ) ) ) h using 1 ; ring;
  norm_num ; ring

/-
The derivative is always positive.
-/
theorem spb_deriv_pos (a x₀ : ℝ) (h : 1 - x₀ * a ≠ 0) :
    (1 + a ^ 2) / (1 - x₀ * a) ^ 2 > 0 := by
  positivity

/-! ## Section 6: Einstein Velocity Addition -/

/-
Einstein velocity addition preserves the speed-of-light bound.
-/
theorem spbH_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

theorem spbH_comm (u v : ℝ) : spbH u v = spbH v u := by
  unfold spbH; ring

theorem spbH_zero (u : ℝ) : spbH u 0 = u := by
  unfold spbH; simp

theorem spbH_neg (u : ℝ) : spbH u (-u) = 0 := by
  unfold spbH; simp

/-! ## Section 7: Cocycle Identity -/

/-
The cocycle identity: algebraic heart of associativity
-/
theorem spb_cocycle (x y z : ℝ) (hxy : 1 - x * y ≠ 0) (hyz : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; ring;
  grind

/-! ## Section 8: Associativity -/

theorem spb_assoc (x y z : ℝ) (hxy : 1 - x * y ≠ 0) (hyz : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb at *;
  grind

/-! ## Section 9: SPB Integer Classification -/

/-- spb(a, b) ∈ ℤ iff (1 - ab) divides (a + b). -/
theorem spb_integer_iff (a b : ℤ) (_h : a * b ≠ 1) :
    (1 - a * b) ∣ (a + b) ↔ ∃ q : ℤ, a + b = q * (1 - a * b) := by
  exact dvd_iff_exists_eq_mul_left

/-- For b = 0, spb(a, 0) = a, always integer. -/
theorem spb_zero_integer (a : ℤ) : (1 - a * 0) ∣ (a + 0) := by simp

/-- For b = -a, spb(a, -a) = 0, always integer. -/
theorem spb_neg_integer (a : ℤ) : (1 - a * (-a)) ∣ (a + (-a)) := by simp

/-! ## Section 10: Quadratic Residue Connection (p±1 Law Foundation) -/

/-
-1 is a square mod p iff p ≡ 1 (mod 4), for odd primes p.
    This is the key to the p±1 law.
-/
theorem neg_one_square_iff_mod4 (p : ℕ) [hp : Fact (Nat.Prime p)] (hp2 : p ≠ 2) :
    IsSquare (-1 : ZMod p) ↔ p % 4 = 1 := by
  rw [ FiniteField.isSquare_neg_one_iff ];
  cases Nat.Prime.eq_two_or_odd hp.1 <;> simp_all +decide;
  lia

end SPBNew
end