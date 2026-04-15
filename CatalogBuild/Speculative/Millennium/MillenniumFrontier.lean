/-! # CatalogBuild.Speculative.Millennium.MillenniumFrontier

Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 13
-/

import Mathlib

theorem prime_between_2_4 : ∃ p, 2 < p ∧ p < 4 ∧ Nat.Prime p := by
  exists 3

/-
PROBLEM
There exists a prime between n² and (n+1)² for n = 1.

PROVIDED SOLUTION
⟨2, by omega, by omega, by decide⟩ or ⟨3, ...⟩
-/

theorem legendre_n1 : ∃ p, 1 < p ∧ p < 4 ∧ Nat.Prime p := by
  exists 3

/-
PROBLEM
There exists a prime between n² and (n+1)² for n = 2.

PROVIDED SOLUTION
⟨5, by omega, by omega, by decide⟩ or ⟨7, ...⟩
-/

theorem legendre_n2 : ∃ p, 4 < p ∧ p < 9 ∧ Nat.Prime p := by
  exists 5

/-
PROBLEM
There exists a prime between n² and (n+1)² for n = 3.

PROVIDED SOLUTION
⟨11, by omega, by omega, by decide⟩ or ⟨13, ...⟩
-/

theorem legendre_n3 : ∃ p, 9 < p ∧ p < 16 ∧ Nat.Prime p := by
  exists 11

/-! ## Section 3: Collatz Base Cases -/

/-- The Collatz function. -/

theorem collatz_one : collatz 1 = 4 := by
  rfl

/-
PROBLEM
Collatz sequence from 2: 2 → 1.

PROVIDED SOLUTION
native_decide or decide
-/

theorem collatz_two : collatz 2 = 1 := by
  native_decide +revert

/-
PROBLEM
Collatz sequence from 3: 3 → 10 → 5 → 16 → 8 → 4 → 2 → 1.

PROVIDED SOLUTION
native_decide or decide
-/

theorem collatz_three : collatz 3 = 10 := by
  native_decide +revert

/-
PROBLEM
The Collatz sequence from any n ∈ {1, 2, 3, 4} eventually reaches 1.

PROVIDED SOLUTION
For each n in {1,2,3,4}, compute the Collatz iteration. n=1: already 1 (k=0). n=2: collatz 2 = 1 (k=1). n=3: 3→10→5→16→8→4→2→1 (k=7). n=4: 4→2→1 (k=2). Use decide or native_decide, or provide explicit witnesses for k.
-/

theorem collatz_small : ∀ n ∈ ({1, 2, 3, 4} : Finset ℕ),
    ∃ k : ℕ, (collatz^[k]) n = 1 := by
      norm_num;
      exact ⟨ ⟨ 0, rfl ⟩, ⟨ 1, rfl ⟩, ⟨ 7, rfl ⟩, ⟨ 2, rfl ⟩ ⟩

/-! ## Section 4: Erdős-Straus for specific n -/

/-
PROBLEM
4/2 = 1/1 + 1/1 + 1/1. Erdős-Straus for n=2.

PROVIDED SOLUTION
4/2 = 2 = 1/1 + 1/2 + 1/2. Use ⟨1, 2, 2⟩ as witnesses, then norm_num.
-/

theorem erdos_straus_4 : ∃ x y z : ℕ+, (4 : ℚ) / 4 = 1 / x + 1 / y + 1 / z := by
  refine ⟨2, 3, 6, ?_⟩
  norm_num

/-
PROBLEM
4/5 = 1/2 + 1/5 + 1/10.

PROVIDED SOLUTION
4/5 = 1/2 + 1/5 + 1/10. Use ⟨2, 5, 10⟩, then norm_num. Check: 5/10 + 2/10 + 1/10 = 8/10 = 4/5. ✓
-/

theorem twin_primes_3_5 : Nat.Prime 3 ∧ Nat.Prime 5 ∧ 5 - 3 = 2 := by
  norm_num

/-
PROBLEM
11 and 13 are twin primes.

PROVIDED SOLUTION
decide
-/

theorem twin_primes_11_13 : Nat.Prime 11 ∧ Nat.Prime 13 ∧ 13 - 11 = 2 := by
  norm_num

/-
PROBLEM
41 and 43 are twin primes.

PROVIDED SOLUTION
decide
-/

theorem twin_primes_41_43 : Nat.Prime 41 ∧ Nat.Prime 43 ∧ 43 - 41 = 2 := by
  native_decide +revert

/-! ## Section 6: Brocard's Problem — Known Solutions -/

/-
PROBLEM
4! + 1 = 25 = 5².

PROVIDED SOLUTION
4! = 24, 24 + 1 = 25 = 5². Compute: native_decide or norm_num.
-/

theorem flt_4_no_solution : ¬ ∃ (a b c : ℕ), 0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 4 + b ^ 4 = c ^ 4 := by
  simp +zetaDelta at *;
  intro x hx y hy z hz H; have := fermatLastTheoremFour; aesop;
