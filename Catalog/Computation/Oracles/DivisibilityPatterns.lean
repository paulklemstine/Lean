/-! # CatalogBuild.Computation.Oracles.DivisibilityPatterns

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Oracles.DivisibilityPatterns
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9] -/
theorem two_consecutive_even (n : ℕ) : 2 ∣ n * (n + 1) := by
  exact even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] )




/-- [Section: # CatalogBuild.Computation.Oracles.DivisibilityPatterns
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 9] -/
theorem three_consecutive_div_six (n : ℕ) : 6 ∣ n * (n + 1) * (n + 2) := by
  exact Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial )




theorem sum_sq_divisibility (n : ℕ) : 6 ∣ n * (n + 1) * (2 * n + 1) := by
  rw [ Nat.dvd_iff_mod_eq_zero ] ; norm_num [ Nat.add_mod, Nat.succ_eq_add_one, Nat.mul_mod ] ; have := Nat.mod_lt n ( by decide : 6 > 0 ) ; interval_cases n % 6 <;> trivial;




theorem fifth_power_minus_self (n : ℕ) : 30 ∣ (n ^ 5 - n : ℤ) := by
  exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.sub_emod, pow_succ, Int.mul_emod ] ; have := Int.emod_nonneg n ( by decide : ( 30 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos n ( by decide : 0 < ( 30 : ℤ ) ) ; interval_cases ( n % 30 : ℤ ) <;> trivial ) ;




theorem square_mod_four (n : ℕ) : n ^ 2 % 4 = 0 ∨ n ^ 2 % 4 = 1 := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> ring_nf <;> norm_num




theorem square_mod_eight (n : ℕ) :
    n ^ 2 % 8 = 0 ∨ n ^ 2 % 8 = 1 ∨ n ^ 2 % 8 = 4 := by
      rw [ Nat.pow_mod ] ; have := Nat.mod_lt n ( by decide : 0 < 8 ) ; interval_cases n % 8 <;> trivial;




theorem fib_dvd_fib (m n : ℕ) (hm : 0 < m) (hmn : m ∣ n) :
    Nat.fib m ∣ Nat.fib n := by
      exact?




theorem sum_odd_eq_square (n : ℕ) :
    ∑ i ∈ range n, (2 * i + 1) = n ^ 2 := by
      induction n <;> simpa [ Finset.sum_range_succ ] using by linarith;




theorem sum_even (n : ℕ) :
    ∑ i ∈ range n, (2 * (i + 1)) = n * (n + 1) := by
      induction n <;> simpa [ Finset.sum_range_succ ] using by linarith;


