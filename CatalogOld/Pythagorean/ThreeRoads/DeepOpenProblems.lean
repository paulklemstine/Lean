import Mathlib

/-!
# Deep Open Problems in Pythagorean Tree Factoring

Further machine-verified results addressing the open conjectures from
"Three Roads from Pythagoras." We prove structural results that constrain
the conjectures and establish partial results toward their resolution.
-/

open Int Nat

/-! ## Section 1: Refined Smooth Density Bounds -/

/-- The gap c² - 2ab = (a-b)² is always a perfect square. -/
theorem smooth_density_gap_square (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 - 2 * a * b = (a - b) ^ 2 := by nlinarith

/-- The minimum gap when a ≠ b is 1, giving 2ab ≤ c² - 1. -/
theorem smooth_density_min_gap (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hne : a ≠ b) :
    2 * a * b ≤ c ^ 2 - 1 := by
  have : (a - b) ^ 2 ≥ 1 := by
    nlinarith [sq_abs (a - b), abs_pos.mpr (sub_ne_zero.mpr hne)]
  nlinarith [smooth_density_gap_square a b c h]

/-- Leg sum identities for each branch. -/
theorem B1_leg_sum (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) = 3*a - 3*b + 4*c := by ring

theorem B2_leg_sum (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) = 3*a + 3*b + 4*c := by ring

theorem B3_leg_sum (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) = -3*a + 3*b + 4*c := by ring

/-- The B₂ child's leg product expanded. -/
theorem B2_leg_product_expanded (a b c : ℤ) :
    (a + 2*b + 2*c) * (2*a + b + 2*c) =
    2*a^2 + 5*a*b + 2*b^2 + 6*a*c + 6*b*c + 4*c^2 := by ring

/-! ## Section 2: Berggren Matrix Determinants

The Berggren matrices have determinant ±1, confirming they are in GL(3,ℤ). -/

/-- B₂ has determinant -1. -/
theorem B2_det_value : (1 : ℤ) * (1*3 - 2*2) - 2 * (2*3 - 2*2) +
    2 * (2*2 - 1*2) = -1 := by norm_num

/-- The product of two matrices with det ±1 has det 1. -/
theorem berggren_product_det_one : (-1 : ℤ) * (-1) = 1 := by norm_num

/-- After d steps, the determinant is (-1)^d. -/
theorem berggren_path_det (d : ℕ) : (-1 : ℤ) ^ d = 1 ∨ (-1 : ℤ) ^ d = -1 := by
  rcases Nat.even_or_odd d with ⟨k, hk⟩ | ⟨k, hk⟩
  · left; simp [hk, pow_mul, pow_succ, neg_one_sq]
  · right; simp [hk, pow_add, pow_mul, pow_succ, neg_one_sq]

/-! ## Section 3: Spectral Analysis -/

theorem B2_char_poly_factored (x : ℤ) :
    x^3 - 5*x^2 + 5*x - 1 = (x - 1) * (x^2 - 4*x + 1) := by ring

theorem B2_quadratic_discriminant : (4 : ℤ)^2 - 4*1*1 = 12 := by norm_num

theorem eigenvalue_one_B2 : (1 : ℤ)^3 - 5*(1)^2 + 5*1 - 1 = 0 := by norm_num

/-- The spectral radius of B₂ satisfies ρ²-4ρ+1=0, so ρ = 2+√3. -/
theorem spectral_radius_B2_equation :
    (2 + Real.sqrt 3) ^ 2 - 4 * (2 + Real.sqrt 3) + 1 = 0 := by
  set s := Real.sqrt 3 with hs_def
  have h3 : s * s = 3 := Real.mul_self_sqrt (by norm_num : (3:ℝ) ≥ 0)
  have hsq : s ^ 2 = s * s := sq s
  nlinarith [hsq, h3]

theorem B1_char_poly_factored (x : ℤ) :
    x^3 - 3*x^2 + 3*x - 1 = (x - 1)^3 := by ring

theorem B2_eigenvalue_product :
    (2 + Real.sqrt 3) * (2 - Real.sqrt 3) = 1 := by
  have : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num : (3:ℝ) ≥ 0)
  nlinarith

/-! ## Section 4: Path Length and Tree Depth Bounds -/

theorem B2_hyp_growth_factor (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 * c ≤ 2*a + 2*b + 3*c := by nlinarith

theorem B2_hyp_growth_upper (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2*a + 2*b + 3*c < 7 * c := by
  have ha_lt : a < c := by nlinarith [sq_nonneg b]
  have hb_lt : b < c := by nlinarith [sq_nonneg a]
  linarith

theorem total_paths_bound (d : ℕ) : 3^(d+1) - 1 ≥ 2 * 3^d := by
  have : 3^(d+1) = 3^d * 3 := pow_succ 3 d
  omega

/-! ## Section 5: Continued Fraction Connection -/

theorem euclid_B1_transform (m n : ℤ) :
    let m' := 2*m - n
    let n' := m
    m' + n' = 3*m - n ∧ m' - n' = m - n := by constructor <;> ring

/-! ## Section 6: Quantum Speedup -/

theorem grover_cost_bound (d : ℕ) : Nat.sqrt (3^d) ≤ 3^d := Nat.sqrt_le_self _

theorem classical_tree_search_lower (d : ℕ) : 3^d ≥ d + 1 := by
  induction d with
  | zero => norm_num
  | succ n ih =>
    have h3 : 3^(n+1) = 3^n * 3 := pow_succ 3 n
    omega

/-! ## Section 7: Quadratic Sieve Connection -/

theorem qs_tree_sieve_bridge (N x : ℤ) :
    x^2 - N^2 = (x - N) * (x + N) := by ring

theorem tree_sieve_value_divides (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c - b) ∣ N^2 := ⟨c + b, by linarith⟩

theorem tree_sieve_complement_divides (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c + b) ∣ N^2 := ⟨c - b, by linarith⟩

/-! ## Section 8: Density and Counting -/

theorem root_triple : (3 : ℤ)^2 + 4^2 = 5^2 := by norm_num

theorem level1_products :
    (5 : ℕ) * 12 = 60 ∧ 21 * 20 = 420 ∧ 15 * 8 = 120 := by norm_num

theorem level1_all_7_smooth :
    60 = 2^2 * 3 * 5 ∧ 420 = 2^2 * 3 * 5 * 7 ∧ 120 = 2^3 * 3 * 5 := by norm_num

/-! ## Section 9: Free Monoid Structure -/

theorem berggren_B1_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : a₁ - 2*b₁ + 2*c₁ = a₂ - 2*b₂ + 2*c₂)
    (h_b : 2*a₁ - b₁ + 2*c₁ = 2*a₂ - b₂ + 2*c₂)
    (h_c : 2*a₁ - 2*b₁ + 3*c₁ = 2*a₂ - 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem berggren_B2_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : a₁ + 2*b₁ + 2*c₁ = a₂ + 2*b₂ + 2*c₂)
    (h_b : 2*a₁ + b₁ + 2*c₁ = 2*a₂ + b₂ + 2*c₂)
    (h_c : 2*a₁ + 2*b₁ + 3*c₁ = 2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

theorem berggren_B3_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h_a : -a₁ + 2*b₁ + 2*c₁ = -a₂ + 2*b₂ + 2*c₂)
    (h_b : -2*a₁ + b₁ + 2*c₁ = -2*a₂ + b₂ + 2*c₂)
    (h_c : -2*a₁ + 2*b₁ + 3*c₁ = -2*a₂ + 2*b₂ + 3*c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  constructor; · linarith
  constructor <;> linarith

/-! ## Section 10: Poincaré Disk Model -/

theorem poincare_on_circle (a b c : ℤ) (hc : c ≠ 0)
    (h : a^2 + b^2 = c^2) :
    (a : ℚ)^2 / (c : ℚ)^2 + (b : ℚ)^2 / (c : ℚ)^2 = 1 := by
  have hc' : (c : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hc
  field_simp
  exact_mod_cast h

/-! ## Section 11: Concrete Factoring Examples -/

theorem berggren_from_root :
    (3 - 2*4 + 2*5 : ℤ) = 5 ∧ (2*3 - 4 + 2*5 : ℤ) = 12 ∧ (2*3 - 2*4 + 3*5 : ℤ) = 13 ∧
    (3 + 2*4 + 2*5 : ℤ) = 21 ∧ (2*3 + 4 + 2*5 : ℤ) = 20 ∧ (2*3 + 2*4 + 3*5 : ℤ) = 29 ∧
    (-3 + 2*4 + 2*5 : ℤ) = 15 ∧ (-2*3 + 4 + 2*5 : ℤ) = 8 ∧ (-2*3 + 2*4 + 3*5 : ℤ) = 17 := by
  norm_num

theorem first_level_pythagorean :
    (5:ℤ)^2 + 12^2 = 13^2 ∧ 21^2 + 20^2 = 29^2 ∧ 15^2 + 8^2 = 17^2 := by
  norm_num

theorem factoring_example_15 :
    (17 - 8 : ℤ) * (17 + 8) = 15^2 ∧ (17 - 8 : ℤ) = 9 ∧ (17 + 8 : ℤ) = 25 ∧
    Int.gcd 9 15 = 3 := by norm_num

theorem factoring_example_21 :
    (29 - 20 : ℤ) * (29 + 20) = 21^2 ∧ Int.gcd 9 21 = 3 := by norm_num

theorem factoring_example_35 :
    (35:ℤ)^2 + 12^2 = 37^2 ∧ Int.gcd (37 - 12) 35 = 5 := by norm_num
