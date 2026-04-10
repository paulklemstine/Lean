/-
  Millennium Frontier: Formal Verification of Partial Results
  =============================================================
  
  We formalize several provable partial results related to the 20 open problems,
  demonstrating what CAN be proven with current mathematical knowledge.
  
  Contents:
  1. Goldbach verification for small cases
  2. Bertrand's postulate consequence (toward Legendre)
  3. Collatz conjecture base cases
  4. Erdős-Straus for specific values
  5. Prime gap bounds (toward twin primes)
  6. ABC conjecture: quality bound examples
-/

import Mathlib

open Nat Finset

/-! ## Section 1: Goldbach Verification for Small Cases -/

/-
PROBLEM
Every even number from 4 to 20 can be written as a sum of two primes.

PROVIDED SOLUTION
For each n in {4,6,8,10,12,14,16,18,20}, exhibit two primes that sum to n: 4=2+2, 6=3+3, 8=3+5, 10=3+7 or 5+5, 12=5+7, 14=3+11 or 7+7, 16=3+13 or 5+11, 18=5+13 or 7+11, 20=3+17 or 7+13. Use decide or native_decide.
-/
theorem goldbach_small : ∀ n ∈ ({4, 6, 8, 10, 12, 14, 16, 18, 20} : Finset ℕ),
    ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ n = p + q := by
      simp +zetaDelta at *;
      exact ⟨ ⟨ 2, by norm_num, 2, by norm_num ⟩, ⟨ 3, by norm_num, 3, by norm_num ⟩, ⟨ 3, by norm_num, 5, by norm_num ⟩, ⟨ 3, by norm_num, 7, by norm_num ⟩, ⟨ 5, by norm_num, 7, by norm_num ⟩, ⟨ 3, by norm_num, 11, by norm_num ⟩, ⟨ 3, by norm_num, 13, by norm_num ⟩, ⟨ 5, by norm_num, 13, by norm_num ⟩, ⟨ 3, by norm_num, 17, by norm_num ⟩ ⟩

/-! ## Section 2: Legendre-adjacent — Primes exist in intervals -/

/-
PROBLEM
There exists a prime between 2 and 4 (i.e., 3).

PROVIDED SOLUTION
Use ⟨3, by omega, by omega, by decide⟩
-/
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
def collatz (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-
PROBLEM
Iterating Collatz from 1 gives 1.

PROVIDED SOLUTION
Unfold collatz and compute: collatz 1 = if 1 % 2 = 0 then ... else 3*1+1 = 4. Use native_decide or decide.
-/
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
theorem erdos_straus_2 : ∃ x y z : ℕ+, (4 : ℚ) / 2 = 1 / x + 1 / y + 1 / z := by
  use 1, 2, 2
  norm_num

/-
PROBLEM
4/3 = 1/1 + 1/3 + 1/∞... Actually 4/3 = 1/1 + 1/4 + 1/12.

PROVIDED SOLUTION
4/3 = 1/1 + 1/4 + 1/12. Use ⟨1, 4, 12⟩ as witnesses then norm_num. Check: 1 + 1/4 + 1/12 = 12/12 + 3/12 + 1/12 = 16/12 = 4/3. ✓
-/
theorem erdos_straus_3 : ∃ x y z : ℕ+, (4 : ℚ) / 3 = 1 / x + 1 / y + 1 / z := by
  refine ⟨1, 4, 12, ?_⟩
  norm_num

/-
PROBLEM
4/4 = 1/1 + 1/∞... 4/4 = 1/2 + 1/3 + 1/6.

PROVIDED SOLUTION
4/4 = 1 = 1/2 + 1/3 + 1/6. Use ⟨2, 3, 6⟩, then norm_num.
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
theorem erdos_straus_5 : ∃ x y z : ℕ+, (4 : ℚ) / 5 = 1 / x + 1 / y + 1 / z := by
  refine ⟨2, 5, 10, ?_⟩
  norm_num

/-! ## Section 5: Twin Prime Examples -/

/-
PROBLEM
3 and 5 are twin primes.

PROVIDED SOLUTION
decide
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
theorem brocard_4 : Nat.factorial 4 + 1 = 5 ^ 2 := by
  decide +kernel

/-
PROBLEM
5! + 1 = 121 = 11².

PROVIDED SOLUTION
5! = 120, 120 + 1 = 121 = 11². native_decide or norm_num.
-/
theorem brocard_5 : Nat.factorial 5 + 1 = 11 ^ 2 := by
  rfl

/-
PROBLEM
7! + 1 = 5041 = 71².

PROVIDED SOLUTION
7! = 5040, 5040 + 1 = 5041 = 71². native_decide or norm_num.
-/
theorem brocard_7 : Nat.factorial 7 + 1 = 71 ^ 2 := by
  native_decide +revert

/-! ## Section 7: Key Inequality for Prime Number Theorem -/

/-
PROBLEM
For all n ≥ 2, there exists a prime p with p ≤ n.
    (Existence of primes — a weak form of infinitude of primes.)

PROVIDED SOLUTION
2 is prime and 2 ≤ n. Use ⟨2, by decide, hn⟩.
-/
theorem exists_prime_le (n : ℕ) (hn : 2 ≤ n) : ∃ p, Nat.Prime p ∧ p ≤ n := by
  exact ⟨ 2, Nat.prime_two, hn ⟩

/-
PROBLEM
Euclid's theorem: there are infinitely many primes.

PROVIDED SOLUTION
This is Nat.exists_infinite_primes in Mathlib. Use exact Nat.exists_infinite_primes n.
-/
theorem infinitely_many_primes : ∀ n : ℕ, ∃ p, n < p ∧ Nat.Prime p := by
  exact fun n => Nat.exists_infinite_primes ( n + 1 ) |> Exists.imp fun p => by aesop;

/-! ## Section 8: Fermat's Last Theorem for n=3,4 (toward Beal) -/

/-
PROBLEM
There are no positive integer solutions to a⁴ + b⁴ = c⁴.
    (Fermat's Last Theorem for n=4, proved by Fermat himself.)

PROVIDED SOLUTION
This is a consequence of Fermat's infinite descent proof that x^4 + y^4 = z^2 has no positive solutions, which implies x^4 + y^4 = z^4 has no positive solutions. In Mathlib, try using Int.FermatLastTheoremFour or FermatLastTheoremFour. The key fact is fermatLastTheoremFour or Nat.FermatLastTheoremFour. Convert from ℕ to the form Mathlib uses.
-/
theorem flt_4_no_solution : ¬ ∃ (a b c : ℕ), 0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 4 + b ^ 4 = c ^ 4 := by
  simp +zetaDelta at *;
  intro x hx y hy z hz H; have := fermatLastTheoremFour; aesop;