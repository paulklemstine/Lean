/-! # CatalogBuild.Algebra.AutoResearch.PythagoreanTriples

Auto-generated from theorem catalog database.
Domain: Algebra/AutoResearch
Declarations: 10
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanTriples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 13] -/
theorem pythagorean_3_4_5 : IsPythagoreanTriple 3 4 5 := by
  exact?


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanTriples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 13] -/
theorem pythagorean_8_15_17 : IsPythagoreanTriple 8 15 17 := by
  exact show 8 ^ 2 + 15 ^ 2 = 17 ^ 2 by decide;


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanTriples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 13] -/
theorem pythagorean_scale (a b c k : ℤ) (h : IsPythagoreanTriple a b c) :
    IsPythagoreanTriple (k * a) (k * b) (k * c) := by
      exact Eq.symm ( by linear_combination' h.symm * k ^ 2 )


theorem pythagorean_swap (a b c : ℤ) (h : IsPythagoreanTriple a b c) :
    IsPythagoreanTriple b a c := by
      exact Eq.trans ( by ring ) h


theorem euclid_formula (m n : ℤ) :
    IsPythagoreanTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
      exact Eq.symm ( by ring )


theorem pythagorean_even_leg (a b c : ℤ) (h : IsPythagoreanTriple a b c) :
    2 ∣ a ∨ 2 ∣ b := by
      replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ d, rfl | rfl ⟩ <;> ( rcases Int.even_or_odd' b with ⟨ e, rfl | rfl ⟩ <;> ( rcases Int.even_or_odd' c with ⟨ f, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *; ) )


theorem fermat_n4_no_solution (a b c : ℤ) (ha : a ≠ 0) (hb : b ≠ 0) :
    a ^ 4 + b ^ 4 ≠ c ^ 4 := by
      -- By Fermat's Last Theorem for the case n=4, there are no non-trivial integer solutions to a^4 + b^4 = c^4.
      have h_flt : ∀ (a b c : ℤ), a ≠ 0 → b ≠ 0 → c ≠ 0 → a^4 + b^4 ≠ c^4 := by
        intro a b c ha hb hc h;
        -- We'll use that $a^4 + b^4 = c^2$ has no nontrivial integer solutions.
        have h_no_solution : ∀ (a b c : ℤ), a ≠ 0 → b ≠ 0 → c ≠ 0 → a^4 + b^4 ≠ c^2 := by
          exact?;
        exact h_no_solution a b ( c ^ 2 ) ha hb ( pow_ne_zero 2 hc ) ( by linarith );
      by_cases hc : c = 0 <;> simp_all +decide;
      positivity


theorem sum_two_squares_5 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 5 := by
  exists 1, 2


theorem sum_two_squares_13 : ∃ a b : ℤ, a ^ 2 + b ^ 2 = 13 := by
  exists 2, 3


theorem no_sum_two_squares_mod4 (n : ℕ) (hn : n % 4 = 3) :
    ¬ ∃ a b : ℕ, a ^ 2 + b ^ 2 = n := by
      exact fun ⟨ a, b, h ⟩ => by have := congr_arg ( · % 4 ) h; norm_num [ Nat.add_mod, Nat.pow_mod, hn ] at this; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> contradiction;


