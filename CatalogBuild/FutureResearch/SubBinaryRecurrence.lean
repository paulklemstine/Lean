/-! # CatalogBuild.FutureResearch.SubBinaryRecurrence

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 6
-/

import Mathlib

/-- [Section: # General Sub-Binary Recurrence Theorem
Recurrences with dominant root λ < 2 have values eventually less than 2^n.] -/
theorem fib_sub_binary (n : ℕ) (hn : 2 ≤ n) : fib (n + 2) < 2 ^ n := by
  rcases n with (_ | _ | n) <;> simp_all +arith +decide [Nat.pow_succ']
  induction' n with n ih <;> norm_num [Nat.pow_succ', fib_add_two] at *
  linarith [Nat.zero_le (2 ^ n)]


theorem fib_le_pow_two (n : ℕ) : fib (n + 2) ≤ 2 ^ n := by
  induction' n with n ih;
  · decide +revert;
  · rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
    grind


def padovan : ℕ → ℕ
  | 0 => 1
  | 1 => 1
  | 2 => 1
  | n + 3 => padovan (n + 1) + padovan n


theorem padovan_sub_binary (n : ℕ) (hn : 1 ≤ n) : padovan n < 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, pow_succ' ];
  · contradiction;
  · rw [ show padovan ( n + 3 ) = padovan ( n + 1 ) + padovan n by rfl ];
    by_cases hn : n = 0;
    · simp +arith +decide [ hn ];
    · grind +splitIndPred


theorem two_term_recurrence_bound (a : ℕ → ℕ) (c₁ c₂ : ℕ)
    (hrec : ∀ n, a (n + 2) = c₁ * a (n + 1) + c₂ * a n)
    (hcoeff : c₁ + c₂ ≤ 2) (h0 : a 0 ≤ 1) (h1 : a 1 ≤ 1) :
    ∀ n, a n ≤ 2 ^ n := by
  intro n;
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  · linarith;
  · have := ih ( n + 1 ) le_rfl; ( have := ih n ( by linarith ) ; ( norm_num [ pow_succ' ] at * ; nlinarith; ) )


theorem fibonacci_reduction_factor (n : ℕ) (hn : 2 ≤ n) : 2 ^ n - fib (n + 2) ≥ 1 := by
  have := fib_sub_binary n hn; omega

