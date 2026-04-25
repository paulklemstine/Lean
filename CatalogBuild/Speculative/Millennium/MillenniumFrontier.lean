/-! # CatalogBuild.Speculative.Millennium.MillenniumFrontier

Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 13
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Millennium.MillenniumFrontier
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 13] -/
theorem prime_between_2_4 : ∃ p, 2 < p ∧ p < 4 ∧ Nat.Prime p := by
  exists 3


/-- [Section: # CatalogBuild.Speculative.Millennium.MillenniumFrontier
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 13] -/
theorem legendre_n1 : ∃ p, 1 < p ∧ p < 4 ∧ Nat.Prime p := by
  exists 3


/-- [Section: # CatalogBuild.Speculative.Millennium.MillenniumFrontier
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 13] -/
theorem legendre_n2 : ∃ p, 4 < p ∧ p < 9 ∧ Nat.Prime p := by
  exists 5


theorem legendre_n3 : ∃ p, 9 < p ∧ p < 16 ∧ Nat.Prime p := by
  exists 11


theorem collatz_one : collatz 1 = 4 := by
  rfl


theorem collatz_two : collatz 2 = 1 := by
  native_decide +revert


theorem collatz_three : collatz 3 = 10 := by
  native_decide +revert


theorem collatz_small : ∀ n ∈ ({1, 2, 3, 4} : Finset ℕ),
    ∃ k : ℕ, (collatz^[k]) n = 1 := by
      norm_num;
      exact ⟨ ⟨ 0, rfl ⟩, ⟨ 1, rfl ⟩, ⟨ 7, rfl ⟩, ⟨ 2, rfl ⟩ ⟩


theorem erdos_straus_4 : ∃ x y z : ℕ+, (4 : ℚ) / 4 = 1 / x + 1 / y + 1 / z := by
  refine ⟨2, 3, 6, ?_⟩
  norm_num


theorem twin_primes_3_5 : Nat.Prime 3 ∧ Nat.Prime 5 ∧ 5 - 3 = 2 := by
  norm_num


theorem twin_primes_11_13 : Nat.Prime 11 ∧ Nat.Prime 13 ∧ 13 - 11 = 2 := by
  norm_num


theorem twin_primes_41_43 : Nat.Prime 41 ∧ Nat.Prime 43 ∧ 43 - 41 = 2 := by
  native_decide +revert


theorem flt_4_no_solution : ¬ ∃ (a b c : ℕ), 0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 4 + b ^ 4 = c ^ 4 := by
  simp +zetaDelta at *;
  intro x hx y hy z hz H; have := fermatLastTheoremFour; aesop;


