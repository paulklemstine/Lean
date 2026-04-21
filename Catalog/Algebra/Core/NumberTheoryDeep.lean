/-! # CatalogBuild.Algebra.Core.NumberTheoryDeep

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 20
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.Core.NumberTheoryDeep
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 21] -/
theorem neg_one_qr_mod5 : ∃ a : ZMod 5, a ^ 2 = -1 := by
  native_decide +revert




/-- [Section: # CatalogBuild.Algebra.Core.NumberTheoryDeep
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 21] -/
theorem neg_one_not_qr_mod3 : ¬ ∃ a : ZMod 3, a ^ 2 = -1 := by
  native_decide +revert




theorem neg_one_qr_mod13 : ∃ a : ZMod 13, a ^ 2 = -1 := by
  native_decide +revert




theorem neg_one_not_qr_mod7 : ¬ ∃ a : ZMod 7, a ^ 2 = -1 := by
  native_decide +revert




theorem two_qr_mod7 : ∃ a : ZMod 7, a ^ 2 = 2 := by
  native_decide +revert




theorem two_not_qr_mod5 : ¬ ∃ a : ZMod 5, a ^ 2 = 2 := by
  native_decide +revert




theorem totient_mul_of_coprime (m n : ℕ) (hmn : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n := by
  exact?




theorem totient_prime_eq (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 := by
  exact Nat.totient_prime hp




theorem totient_prime_sq' (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient (p ^ 2) = p * (p - 1) := by
  norm_num [ Nat.totient_prime_pow hp ]




theorem sum_totient_divisors (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, Nat.totient d = n := by
  exact Nat.sum_totient n




/-- CRT example: x ≡ 1 (mod 2), x ≡ 2 (mod 3) has solution x = 5 -/
theorem crt_example_5 : (5 : ℤ) % 2 = 1 ∧ (5 : ℤ) % 3 = 2 := by norm_num




/-- CRT example: x ≡ 2 (mod 3), x ≡ 3 (mod 5), x ≡ 2 (mod 7) → x = 23 -/
theorem crt_example_23 : (23 : ℤ) % 3 = 2 ∧ (23 : ℤ) % 5 = 3 ∧ (23 : ℤ) % 7 = 2 := by norm_num




theorem padic_val_prime (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p p = 1 := by
  rcases eq_or_ne p 2 <;> simp_all +decide [ padicValNat.eq_zero_of_not_dvd ]




theorem padic_val_pow (p k : ℕ) (hp : Nat.Prime p) :
    padicValNat p (p ^ k) = k := by
  haveI := Fact.mk hp; rw [ padicValNat.pow ] <;> aesop;




theorem padic_val_mul_eq (p : ℕ) (hp : Nat.Prime p) (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI := Fact.mk hp; rw [ padicValNat.mul ] <;> aesop;




theorem bertrand (n : ℕ) (hn : 1 ≤ n) :
    ∃ p : ℕ, n < p ∧ p ≤ 2 * n ∧ Nat.Prime p := by
  exact Nat.exists_prime_lt_and_le_two_mul n ( by linarith ) |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₂.1, hp₂.2, hp₁ ⟩




theorem consecutive_prod_even (n : ℕ) : 2 ∣ n * (n + 1) := by
  exact even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] )




theorem three_consec_div6 (n : ℕ) : 6 ∣ n * (n + 1) * (n + 2) := by
  exact Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial )




theorem cube_minus_self_div6 (a : ℤ) : (6 : ℤ) ∣ a ^ 3 - a := by
  exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.sub_emod, pow_succ, Int.mul_emod ] ; have := Int.emod_nonneg a ( by decide : ( 6 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by decide : ( 6 : ℤ ) > 0 ) ; interval_cases a % 6 <;> trivial ) ;




theorem fifth_pow_minus (n : ℤ) : (30 : ℤ) ∣ n ^ 5 - n := by
  rw [ Int.dvd_iff_emod_eq_zero ] ; norm_num [ Int.sub_emod, pow_succ, Int.mul_emod ] ; have := Int.emod_nonneg n ( by decide : ( 30 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos n ( by decide : 0 < ( 30 : ℤ ) ) ; interval_cases n % 30 <;> trivial;



