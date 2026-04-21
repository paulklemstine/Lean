/-! # CatalogBuild.Speculative.Other.FutureResearch

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 35
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Other.FutureResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 35] -/
theorem fibonacci_pythagorean_identity (a b : ℤ) :
    let p := a + b
    let q := b + p
    (a * q) ^ 2 + (2 * b * p) ^ 2 = (b ^ 2 + p ^ 2) ^ 2 := by
  ring




/-- [Section: # CatalogBuild.Speculative.Other.FutureResearch
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 35] -/
theorem fib_square_recurrence (a b : ℤ) :
    (a + b) ^ 2 = a ^ 2 + b ^ 2 + 2 * a * b := by
  ring




theorem berggren_M1_fibonacci_action :
    (!![2, -1; 1, 0] : Matrix (Fin 2) (Fin 2) ℤ) *ᵥ ![2, 1] = ![3, 2] := by
  native_decide +revert




theorem fibonacci_double_square (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring




theorem trace_B₁_mul_B₂ : Matrix.trace (B₁' * B₂') = 17 := by
  native_decide +revert




theorem trace_B₁_sq : Matrix.trace (B₁' * B₁') = 3 := by
  native_decide +revert




theorem B₁_in_SO21 : Matrix.det B₁' = 1 ∧ B₁'ᵀ * Q_lor * B₁' = Q_lor := by
  native_decide +revert




theorem B₂_in_O21_not_SO21 : Matrix.det B₂' = -1 ∧ B₂'ᵀ * Q_lor * B₂' = Q_lor := by
  native_decide +revert




theorem B₃_in_SO21 : Matrix.det B₃' = 1 ∧ B₃'ᵀ * Q_lor * B₃' = Q_lor := by
  native_decide +revert




theorem det_B₁_mul_B₃ : Matrix.det (B₁' * B₃') = 1 := by
  native_decide +revert




theorem det_triple_product : Matrix.det (B₁' * B₂' * B₃') = -1 := by
  native_decide +revert




theorem pyth_prod_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 ∣ a * b := by
  rw [ Int.dvd_iff_emod_eq_zero ] ; replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;




theorem pyth_prod_div3 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 ∣ a * b := by
  rw [ Int.dvd_iff_emod_eq_zero ] ; have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this ⊢; have := Int.emod_nonneg a three_pos.ne'; have := Int.emod_nonneg b three_pos.ne'; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial;




theorem pyth_prod_div6 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    6 ∣ a * b := by
  exact dvd_trans ( by decide ) ( Int.coe_lcm_dvd ( pyth_prod_even a b c h ) ( pyth_prod_div3 a b c h ) )




theorem area_345 : 3 * 4 / 2 = (6 : ℤ) := by
  decide +revert




theorem area_5_12_13 : 5 * 12 / 2 = (30 : ℤ) := by
  native_decide +revert




theorem quadratic_descent_positive (n : ℕ) (hn : 2 ≤ n) : 0 < n ^ 2 - n := by
  exact Nat.sub_pos_of_lt ( by nlinarith )




theorem linear_descent_bound (n : ℕ) : n / 2 * 2 ≤ n := by
  linarith [ Nat.div_mul_le_self n 2 ]




theorem elliptic_positivity (x n : ℤ) (hn : 0 < n) (hx : n < x) : 0 < x := by
  grind




theorem M₁_cayley_hamilton :
    let M : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]
    M * M - 2 • M + 1 = 0 := by
  decide +kernel




theorem M₂_cayley_hamilton :
    let M : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]
    M * M - 2 • M - 1 = 0 := by
  decide +kernel




theorem M₃_unipotent :
    let M : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]
    (M - 1) * (M - 1) = 0 := by
  native_decide +revert




theorem M₂_expanding :
    let M : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]
    Matrix.trace (M * M) = 6 := by
  native_decide +revert




theorem M₁_trace_powers :
    let M : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]
    Matrix.trace M = 2 ∧
    Matrix.trace (M * M) = 2 ∧
    Matrix.trace (M * M * M) = 2 := by
  native_decide +revert




theorem tropical_det_M₁ : min (2 + 0) ((-1) + 1) = (0 : ℤ) := by
  decide +revert




theorem pyth_mod_any (p : ℕ) : (3 ^ 2 + 4 ^ 2) % p = 5 ^ 2 % p := by
  rfl




theorem pyth_mod4_parity (a b c : ZMod 4) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a * b = 0 ∨ a * b = 2 := by
  revert a b c h; native_decide;




theorem sum_sq_mod3 (a b : ZMod 3) (h : a ^ 2 + b ^ 2 = 0) : a = 0 ∧ b = 0 := by
  decide +revert




theorem pythagorean_unit : (1 : ℤ) ^ 2 + (0 : ℤ) ^ 2 = (1 : ℤ) ^ 2 := by
  norm_num




theorem pythagorean_unit_compose (a b : ℤ) :
    (a * 1 - b * 0) ^ 2 + (a * 0 + b * 1) ^ 2 = a ^ 2 + b ^ 2 := by
  grind




theorem norm_mul_assoc (a₁ b₁ a₂ b₂ a₃ b₃ : ℤ) :
    (a₁ ^ 2 + b₁ ^ 2) * ((a₂ ^ 2 + b₂ ^ 2) * (a₃ ^ 2 + b₃ ^ 2)) =
    ((a₁ ^ 2 + b₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2)) * (a₃ ^ 2 + b₃ ^ 2) := by
  ring




theorem berggren_345_child : B₁' *ᵥ ![3, 4, 5] = ![5, 12, 13] := by
  native_decide +revert




theorem berggren_child_area_div6 : (6 : ℤ) ∣ 5 * 12 := by
  native_decide +revert




theorem trace_det_duality_B₁ :
    Matrix.trace B₁' ^ 2 - Matrix.trace (B₁' * B₁') = 6 := by
  native_decide




theorem master_identity :
    (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by
  native_decide +revert


