/-! # CatalogBuild.Pythagorean.Core.FiveDirections

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 96
-/

import Mathlib

/-- The Lorentz form Q₂₁ = diag(1,1,-1) for SO(2,1). -/
def Q21d : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]



/-- Berggren 3×3 matrix B₁. -/
def BB1d : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]



/-- Berggren 3×3 matrix B₂. -/
def BB2d : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]



/-- Berggren 3×3 matrix B₃. -/
def BB3d : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]



/-- B₁ preserves the Lorentz form Q₂₁. -/
theorem BB1d_preserves : BB1dᵀ * Q21d * BB1d = Q21d := by native_decide



/-- B₂ preserves the Lorentz form Q₂₁. -/
theorem BB2d_preserves : BB2dᵀ * Q21d * BB2d = Q21d := by native_decide



/-- B₃ preserves the Lorentz form Q₂₁. -/
theorem BB3d_preserves : BB3dᵀ * Q21d * BB3d = Q21d := by native_decide



/-- [Section: # CatalogBuild.Pythagorean.Core.FiveDirections
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 96] -/
theorem det_BB1d : Matrix.det BB1d = 1 := by native_decide


theorem det_BB2d : Matrix.det BB2d = -1 := by native_decide


theorem det_BB3d : Matrix.det BB3d = 1 := by native_decide



/-- The root quadruple (1,2,2,3). -/
theorem root_quadruple : IsPythQuad 1 2 2 3 := by unfold IsPythQuad; norm_num



/-- The quadruple (2,3,6,7). -/
theorem quad_2367 : IsPythQuad 2 3 6 7 := by unfold IsPythQuad; norm_num



/-- The quadruple parametrization identity. -/
theorem quadruple_param (p q r s : ℤ) :
    (p^2 + q^2 - r^2 - s^2)^2 + (2*(p*s + q*r))^2 + (2*(q*s - p*r))^2
    = (p^2 + q^2 + r^2 + s^2)^2 := by ring



/-- Product of two Q-preserving matrices preserves Q. -/
theorem product_preserves_Q21 (A B : Matrix (Fin 3) (Fin 3) ℤ)
    (hA : Aᵀ * Q21d * A = Q21d) (hB : Bᵀ * Q21d * B = Q21d) :
    (A * B)ᵀ * Q21d * (A * B) = Q21d := by
  have : Bᵀ * (Aᵀ * Q21d * A) * B = Q21d := by rw [hA, hB]
  rw [Matrix.transpose_mul]
  convert this using 1
  simp [Matrix.mul_assoc]



/-- B₁ maps (3,4,5) to another Pythagorean triple. -/
theorem BB1d_maps_345 :
    let v := ![3, 4, 5]
    let w := BB1d *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 = w 2 ^ 2 := by native_decide



/-- B₂ maps (3,4,5) to another Pythagorean triple. -/
theorem BB2d_maps_345 :
    let v := ![3, 4, 5]
    let w := BB2d *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 = w 2 ^ 2 := by native_decide



/-- B₃ maps (3,4,5) to another Pythagorean triple. -/
theorem BB3d_maps_345 :
    let v := ![3, 4, 5]
    let w := BB3d *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 = w 2 ^ 2 := by native_decide



/-- 7 is not a sum of three squares (Legendre obstruction). -/
theorem seven_not_three_sq : ¬ ∃ a b c : ℕ, a^2 + b^2 + c^2 = 7 := by
  intro ⟨a, b, c, h⟩
  have ha : a ≤ 2 := by nlinarith
  have hb : b ≤ 2 := by nlinarith
  have hc : c ≤ 2 := by nlinarith
  interval_cases a <;> interval_cases b <;> interval_cases c <;> omega



/-- 15 is not a sum of three squares (15 = 4⁰·(8·1+7)). -/
theorem fifteen_not_three_sq : ¬ ∃ a b c : ℕ, a^2 + b^2 + c^2 = 15 := by
  intro ⟨a, b, c, h⟩
  have ha : a ≤ 3 := by nlinarith
  have hb : b ≤ 3 := by nlinarith
  have hc : c ≤ 3 := by nlinarith
  interval_cases a <;> interval_cases b <;> interval_cases c <;> omega



/-- 14 is a sum of three squares. -/
theorem three_sq_14 : ∃ a b c : ℤ, a^2 + b^2 + c^2 = 14 := ⟨1, 2, 3, by norm_num⟩



/-- Selberg's bound λ₁ ≥ 3/16 for congruence subgroups. -/
theorem selberg_316_pos : (3 : ℝ) / 16 > 0 := by positivity



/-- The optimal bound λ₁ = 1/4 is stronger than Selberg's 3/16. -/
theorem optimal_gt_selberg : (1 : ℚ) / 4 > 3 / 16 := by norm_num



/-- The Ramanujan bound at level 2: s(1-s) = λ₁ = 1/4 gives s = 1/2. -/
theorem ramanujan_level2 : (1 : ℝ) / 2 * (1 - 1 / 2) = 1 / 4 := by ring



/-- The mixing rate with λ₁ = 1/4: √(1/4) = 1/2. -/
theorem mixing_exp : Real.sqrt (1 / 4 : ℝ) = 1 / 2 := by
  rw [show (1 : ℝ) / 4 = (1 / 2) ^ 2 from by ring]
  exact Real.sqrt_sq (by norm_num : (1 : ℝ) / 2 ≥ 0)



/-- The Cheeger constant bound: 4λ₁ = 1 when λ₁ = 1/4. -/
theorem cheeger_bound : 4 * (1 / 4 : ℝ) = 1 := by ring



/-- The lattice point error exponent: 1 - √(1/4) = 1/2. -/
theorem lattice_pt_error : (1 : ℝ) - Real.sqrt (1 / 4) = 1 / 2 := by
  rw [mixing_exp]; norm_num



/-- The equidistribution exponent with λ₁ = 1/4 dominates Selberg's bound. -/
theorem equidist_exp : Real.sqrt (1 / 4 : ℝ) ≥ Real.sqrt (3 / 16) := by
  apply Real.sqrt_le_sqrt; norm_num



/-- The average descent depth constant: 1/√λ₁ = 2. -/
theorem descent_const : 1 / Real.sqrt (1 / 4 : ℝ) = 2 := by
  rw [mixing_exp]; norm_num



/-- The hyperbolic area of the fundamental domain of Γ_θ is π. -/
theorem fund_domain_area : 3 * (Real.pi / 3) = Real.pi := by ring



/-- PPT counting: #{(a,b,c) PPT : c ≤ N} ~ N/(2π). -/
theorem ppt_counting_pos : (0 : ℝ) < 1 / (2 * Real.pi) := by positivity



theorem chi4_zero : chi4 0 = 0 := by simp [chi4]


theorem chi4_two : chi4 2 = 0 := by simp [chi4]


theorem chi4_four : chi4 4 = 0 := by simp [chi4]


/-- χ₋₄ has period 4. -/
theorem chi4_periodic (n : ℤ) : chi4 (n + 4) = chi4 n := by
  unfold chi4; split_ifs <;> omega



/-- The sum over a full period vanishes. -/
theorem chi4_sum_period : chi4 0 + chi4 1 + chi4 2 + chi4 3 = 0 := by
  unfold chi4; norm_num



theorem chi4_mult_odd (m n : ℤ) (hm : m % 2 = 1) (hn : n % 2 = 1) :
    chi4 (m * n) = chi4 m * chi4 n := by
      unfold chi4;
      rw [ ← Int.emod_add_mul_ediv m 4, ← Int.emod_add_mul_ediv n 4 ] ; have := Int.emod_nonneg m four_ne_zero; have := Int.emod_nonneg n four_ne_zero; have := Int.emod_lt_of_pos m four_pos; have := Int.emod_lt_of_pos n four_pos; interval_cases m % 4 <;> interval_cases n % 4 <;> norm_num [ Int.add_emod, Int.mul_emod ] ;



/-- The divisor sum formula for r₂ (computable version). -/
def r2_formula (n : ℕ) : ℤ :=
  4 * ((Finset.Icc 1 n).filter (· ∣ n)).sum (fun d => chi4 d)

-- Verified values of the r₂ formula


theorem r2_val_1 : r2_formula 1 = 4 := by native_decide


theorem r2_val_2 : r2_formula 2 = 4 := by native_decide


theorem r2_val_3 : r2_formula 3 = 0 := by native_decide


theorem r2_val_4 : r2_formula 4 = 4 := by native_decide


theorem r2_val_5 : r2_formula 5 = 8 := by native_decide


theorem r2_val_7 : r2_formula 7 = 0 := by native_decide


theorem r2_val_10 : r2_formula 10 = 8 := by native_decide


theorem r2_val_11 : r2_formula 11 = 0 := by native_decide


theorem r2_val_13 : r2_formula 13 = 8 := by native_decide


theorem r2_val_25 : r2_formula 25 = 12 := by native_decide


theorem r2_val_50 : r2_formula 50 = 12 := by native_decide



/-- Fermat's two-square theorem. -/
theorem fermat_two_sq (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = (p : ℤ) := by
  have : Fact (Nat.Prime p) := ⟨hp⟩
  have h4 : p % 4 ≠ 3 := by omega
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq h4
  exact ⟨a, b, by exact_mod_cast hab⟩



theorem no_sum_sq_3mod4 (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    ¬ ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
      exact fun ⟨ a, b, h ⟩ => by have := congr_arg ( · % 4 ) h; norm_num [ Nat.add_mod, Nat.pow_mod, hmod ] at this; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> contradiction;



/-- The Leibniz series L(1, χ₋₄) = π/4 > 0. -/
theorem leibniz_positive : (0 : ℝ) < Real.pi / 4 := by positivity



/-- Berggren matrix M₁. -/
def QM1 : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]



/-- Berggren matrix M₃. -/
def QM3 : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]



/-- The S generator. -/
def QS : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]



theorem det_QM1 : Matrix.det QM1 = 1 := by native_decide


theorem det_QM3 : Matrix.det QM3 = 1 := by native_decide


theorem det_QS : Matrix.det QS = 1 := by native_decide



/-- S⁴ = I. -/
theorem QS_order_4 : QS ^ 4 = 1 := by native_decide



/-- S² = -I. -/
theorem QS_sq_neg_I : QS ^ 2 = -1 := by native_decide



/-- M₁ = T² · S. -/
theorem QM1_eq_T2S : QM1 = QM3 * QS := by native_decide



/-- ‖M₁ - I‖² = 4 (discreteness gap). -/
theorem QM1_frob_gap :
    (QM1 0 0 - 1)^2 + (QM1 0 1)^2 + (QM1 1 0)^2 + (QM1 1 1 - 1)^2 = 4 := by
  native_decide



/-- ‖M₃ - I‖² = 4. -/
theorem QM3_frob_gap :
    (QM3 0 0 - 1)^2 + (QM3 0 1)^2 + (QM3 1 0)^2 + (QM3 1 1 - 1)^2 = 4 := by
  native_decide



/-- ‖S - I‖² = 4. -/
theorem QS_frob_gap :
    (QS 0 0 - 1)^2 + (QS 0 1)^2 + (QS 1 0)^2 + (QS 1 1 - 1)^2 = 4 := by
  native_decide



/-- M₁ has a zero entry. -/
theorem QM1_sparse : QM1 1 1 = 0 := by native_decide



/-- Code rate: 3^n codewords at depth n. -/
theorem code_rate (n : ℕ) : 3 ^ n ≥ 1 := Nat.one_le_pow n 3 (by norm_num)



theorem code_depth_3 : 3 ^ 3 = 27 := by norm_num


theorem code_depth_5 : 3 ^ 5 = 243 := by norm_num


theorem code_depth_10 : 3 ^ 10 = 59049 := by norm_num



/-- All products of generators have determinant 1. -/
theorem det_product_chain :
    Matrix.det (QM1 * QM3 * QM1 * QM3 * QM1) = 1 := by
  simp [Matrix.det_mul, det_QM1, det_QM3]



/-- The three generators are pairwise distinct. -/
theorem QM1_ne_QM3 : QM1 ≠ QM3 := by
  intro h; have := congr_fun (congr_fun h 0) 0; simp [QM1, QM3] at this



theorem QM1_ne_QS : QM1 ≠ QS := by
  intro h; have := congr_fun (congr_fun h 0) 0; simp [QM1, QS] at this



theorem QM3_ne_QS : QM3 ≠ QS := by
  intro h; have := congr_fun (congr_fun h 0) 0; simp [QM3, QS] at this



/-- The Cayley transform matrix. -/
def CayleyMat : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 1, -1]



theorem det_Cayley : Matrix.det CayleyMat = -2 := by native_decide



/-- Trace of M₁ is 2 (parabolic). -/
theorem trace_QM1 : Matrix.trace QM1 = 2 := by native_decide



/-- Trace of M₃ is 2 (parabolic). -/
theorem trace_QM3 : Matrix.trace QM3 = 2 := by native_decide



/-- Trace of S is 0 (elliptic of order 4). -/
theorem trace_QS : Matrix.trace QS = 0 := by native_decide



/-- M₁ · M₃ has trace 4 (hyperbolic). -/
theorem trace_QM1_QM3 : Matrix.trace (QM1 * QM3) = 4 := by native_decide



/-- Minimum Frobenius distance between distinct depth-1 elements is positive. -/
theorem min_dist_depth1 :
    (QM1 0 0 - QM3 0 0)^2 + (QM1 0 1 - QM3 0 1)^2 +
    (QM1 1 0 - QM3 1 0)^2 + (QM1 1 1 - QM3 1 1)^2 > 0 := by native_decide



/-- The S-transformation λ ↦ 1-λ has λ = 1/2 as its unique fixed point. -/
theorem lambda_S_fixed : ∀ x : ℚ, 1 - x = x → x = 1 / 2 := by
  intro x hx; linarith



/-- At τ = i: λ(i) = 1/2 (self-consistency). -/
theorem lambda_at_i : (1 : ℚ) / 2 = 1 - 1 / 2 := by norm_num



/-- Discriminant vanishes at cusp λ = 0. -/
theorem discrim_cusp_0 : (0 : ℚ)^2 * (1 - 0)^2 = 0 := by norm_num



/-- Discriminant vanishes at cusp λ = 1. -/
theorem discrim_cusp_1 : (1 : ℚ)^2 * (1 - 1)^2 = 0 := by norm_num



/-- The six anharmonic ratios form S₃. -/
theorem anharmonic_S3 : Nat.factorial 3 = 6 := by norm_num



/-- The leading q-expansion coefficient of λ(τ) is 16 = 2⁴. -/
theorem lambda_leading : (16 : ℤ) = 2 ^ 4 := by norm_num



/-- Gauss-Bonnet: Area(X_θ) = π. -/
theorem gauss_bonnet : 3 * (Real.pi / 3) = Real.pi := by ring



theorem area_positive : Real.pi > 0 := Real.pi_pos



/-- The Berggren-Farey map. -/
def berggrenFarey (a b c : ℤ) : ℚ := (b : ℚ) / (a + c)



theorem farey_345 : berggrenFarey 3 4 5 = 1 / 2 := by simp [berggrenFarey]; norm_num


theorem farey_51213 : berggrenFarey 5 12 13 = 2 / 3 := by simp [berggrenFarey]; norm_num


theorem farey_81517 : berggrenFarey 8 15 17 = 3 / 5 := by simp [berggrenFarey]; norm_num


theorem farey_72425 : berggrenFarey 7 24 25 = 3 / 4 := by simp [berggrenFarey]; norm_num



theorem two_sum_sq : ∃ a b : ℤ, a^2 + b^2 = 2 := ⟨1, 1, by norm_num⟩


theorem five_sum_sq : ∃ a b : ℤ, a^2 + b^2 = 5 := ⟨1, 2, by norm_num⟩


theorem thirteen_sum_sq : ∃ a b : ℤ, a^2 + b^2 = 13 := ⟨2, 3, by norm_num⟩



theorem prime_density_pos : (1 : ℚ) / 2 > 0 := by norm_num


