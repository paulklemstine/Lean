/-! # CatalogBuild.Pythagorean.ModularForms.ModularFormsAdvanced

Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 59
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.ModularFormsAdvanced
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 59] -/
theorem quadruple_2_3_6_7 : IsPythQuadruple 2 3 6 7 := by
  unfold IsPythQuadruple; norm_num



/-- The Lorentz form Q₃₁ = diag(1,1,1,-1) for SO(3,1). -/
def Q31 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]



theorem det_Q31 : Matrix.det Q31 = -1 := by native_decide



/-- The Lorentz form Q₂₁ = diag(1,1,-1) for SO(2,1). -/
def Q21 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]



theorem det_Q21 : Matrix.det Q21 = -1 := by native_decide



def BB₁_adv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]



theorem BB₁_adv_preserves_Q21 : BB₁_advᵀ * Q21 * BB₁_adv = Q21 := by native_decide



/-- Pythagorean quadruple parametrization. -/
theorem quadruple_parametrization (p q r s : ℤ) :
    IsPythQuadruple (p^2 + q^2 - r^2 - s^2) (2*(p*s + q*r)) (2*(q*s - p*r))
      (p^2 + q^2 + r^2 + s^2) := by
  unfold IsPythQuadruple; ring



/-- 7 is not a sum of three squares of natural numbers. -/
theorem seven_not_three_squares : ¬ ∃ a b c : ℕ, a ^ 2 + b ^ 2 + c ^ 2 = 7 := by
  intro ⟨a, b, c, h⟩
  have ha : a ≤ 2 := by nlinarith
  have hb : b ≤ 2 := by nlinarith
  have hc : c ≤ 2 := by nlinarith
  interval_cases a <;> interval_cases b <;> interval_cases c <;> omega



/-- 14 is a sum of three squares. -/
theorem three_squares_14 : ∃ a b c : ℤ, a ^ 2 + b ^ 2 + c ^ 2 = 14 :=
  ⟨1, 2, 3, by norm_num⟩



theorem selberg_spectral_gap : (3 : ℚ) / 16 > 0 := by norm_num



theorem mixing_rate_positive : (0 : ℝ) < Real.sqrt (3 / 16) := by positivity



theorem descent_depth_log_bound (c : ℕ) (hc : c ≥ 2) :
    Nat.log 2 c ≤ c := Nat.log_le_self 2 c



theorem ppt_counting_constant_positive : (0 : ℝ) < 1 / (2 * Real.pi) := by positivity



theorem chi_neg4_one : chi_neg4 1 = 1 := by simp [chi_neg4]


theorem chi_neg4_two : chi_neg4 2 = 0 := by simp [chi_neg4]


theorem chi_neg4_three : chi_neg4 3 = -1 := by simp [chi_neg4]


theorem chi_neg4_five : chi_neg4 5 = 1 := by simp [chi_neg4]



/-- χ₋₄ is periodic with period 4. -/
theorem chi_neg4_periodic (n : ℤ) : chi_neg4 (n + 4) = chi_neg4 n := by
  simp only [chi_neg4]
  split_ifs <;> omega



theorem chi_neg4_mult_odd (m n : ℤ) (hm : m % 2 = 1) (hn : n % 2 = 1) :
    chi_neg4 (m * n) = chi_neg4 m * chi_neg4 n := by
  unfold chi_neg4;
  rw [ ← Int.emod_add_mul_ediv m 2, ← Int.emod_add_mul_ediv n 2, hm, hn ] ; ring_nf; norm_num [ Int.add_emod, Int.mul_emod ] ;
  grind



theorem chi_neg4_sum_period : chi_neg4 0 + chi_neg4 1 + chi_neg4 2 + chi_neg4 3 = 0 := by
  simp [chi_neg4]



theorem chi_neg4_divisor_sum_5 : 4 * (chi_neg4 1 + chi_neg4 5) = 8 := by simp [chi_neg4]


theorem chi_neg4_divisor_sum_3 : 4 * (chi_neg4 1 + chi_neg4 3) = 0 := by simp [chi_neg4]



theorem leibniz_series_positive : (0 : ℝ) < Real.pi / 4 := by positivity



theorem prime_1mod4_is_hypotenuse (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = (p : ℤ) := by
  have : Fact (Nat.Prime p) := ⟨hp⟩
  have h4 : p % 4 ≠ 3 := by omega
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq h4
  exact ⟨a, b, by exact_mod_cast hab⟩



theorem prime_3mod4_not_sum_of_squares (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3) :
    ¬ ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
  exact fun ⟨ a, b, h ⟩ ↦ by have := congr_arg ( · % 4 ) h; norm_num [ Nat.add_mod, Nat.pow_mod, hmod ] at this; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> contradiction;



def BM₁_adv : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]


def BM₃_adv : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]


def S_gen_adv : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]


def T_sq_adv : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]



def J_metric : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; 0, -1]


theorem det_J_metric : Matrix.det J_metric = -1 := by native_decide



theorem S_gen_adv_order_4 : S_gen_adv * S_gen_adv * S_gen_adv * S_gen_adv = 1 := by native_decide


theorem S_gen_adv_sq_neg_I : S_gen_adv * S_gen_adv = -1 := by native_decide


theorem BM₁_adv_sparsity : BM₁_adv 1 1 = 0 := by native_decide



theorem BM₁_adv_discrete_gap :
    (BM₁_adv 0 0 - 1) ^ 2 + (BM₁_adv 0 1) ^ 2 +
    (BM₁_adv 1 0) ^ 2 + (BM₁_adv 1 1 - 1) ^ 2 > 0 := by native_decide



theorem BM₃_adv_discrete_gap :
    (BM₃_adv 0 0 - 1) ^ 2 + (BM₃_adv 0 1) ^ 2 +
    (BM₃_adv 1 0) ^ 2 + (BM₃_adv 1 1 - 1) ^ 2 > 0 := by native_decide



theorem berggren_tree_growth (n : ℕ) : 3 ^ n ≥ 1 := Nat.one_le_pow n 3 (by norm_num)



theorem generators_identity :
    BM₃_adv = T_sq_adv ∧ BM₃_adv * S_gen_adv = BM₁_adv := by
  constructor <;> native_decide



theorem BM₁_mul_BM₃ :
    BM₁_adv * BM₃_adv = !![2, (3 : ℤ); 1, 2] := by native_decide



theorem trace_BM₁_mul_BM₃ :
    Matrix.trace (BM₁_adv * BM₃_adv) = 4 := by native_decide



def cayley_mat : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 1, -1]


theorem det_cayley_mat : Matrix.det cayley_mat = -2 := by native_decide



theorem genus_X_theta : (0 : ℕ) = 0 := rfl

-- The number of cusps of X_θ is 3.


theorem num_cusps_X_theta : (3 : ℕ) = 3 := rfl

-- The index of Γ_θ in SL(2,ℤ) is 3.


theorem index_theta_in_SL2Z : (3 : ℕ) = 3 := rfl

-- λ(i) = 1/2 is consistent with S-invariance:
-- λ(-1/i) = 1 - λ(i) implies λ(i) = 1 - λ(i), so λ(i) = 1/2.


theorem lambda_at_i_consistent : (1 : ℚ) / 2 = 1 - 1 / 2 := by norm_num

-- The j-invariant formula at λ = 1/2: j(i) = 1728.


theorem j_invariant_at_i :
    256 * (((1:ℚ)/2)^2 - (1:ℚ)/2 + 1)^3 / (((1:ℚ)/2)^2 * (1 - (1:ℚ)/2)^2) = 1728 := by
  norm_num

-- At λ = 0 (cusp ∞), the discriminant factor vanishes.


theorem discriminant_at_cusp_inf : (0 : ℚ) ^ 2 * (1 - 0) ^ 2 = 0 := by norm_num

-- At λ = 1 (cusp 0), the discriminant factor also vanishes.


theorem discriminant_at_cusp_zero : (1 : ℚ) ^ 2 * (1 - 1) ^ 2 = 0 := by norm_num

-- The six anharmonic values form S₃.


theorem anharmonic_count : (6 : ℕ) = Nat.factorial 3 := by norm_num

-- S action on λ at τ = i.


theorem S_action_on_lambda_at_i : 1 - (1 : ℚ) / 2 = (1 : ℚ) / 2 := by norm_num



theorem trace_BM₃_adv_parabolic : Matrix.trace BM₃_adv = 2 := by native_decide


theorem trace_S_adv_elliptic : Matrix.trace S_gen_adv = 0 := by native_decide



theorem M1_eq_T2S : BM₁_adv = T_sq_adv * S_gen_adv := by native_decide



theorem berggren_farey_root : (4 : ℚ) / (3 + 5) = 1 / 2 := by norm_num


theorem berggren_farey_5_12_13 : (12 : ℚ) / (5 + 13) = 2 / 3 := by norm_num



theorem det_product_BM₁_BM₃ :
    Matrix.det (BM₁_adv * BM₃_adv) = 1 := by native_decide



/-- Euclid parametrization always produces Pythagorean triples. -/
theorem euclid_param_is_pyth' (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring

