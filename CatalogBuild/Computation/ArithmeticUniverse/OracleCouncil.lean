/-! # CatalogBuild.Computation.ArithmeticUniverse.OracleCouncil

Auto-generated from theorem catalog database.
Domain: Computation/ArithmeticUniverse
Declarations: 5
-/

import Mathlib

/-- The Oracle of Primes sees the atomic structure of ℕ. -/
structure OracleOfPrimes where
  /-- A prime is an atom — it cannot be decomposed. -/
  atom_irreducible : ∀ p : ℕ, Nat.Prime p → ¬∃ a b : ℕ, 1 < a ∧ 1 < b ∧ p = a * b
  /-- There are infinitely many atoms. -/
  infinite_atoms : ∀ n : ℕ, ∃ p : ℕ, n < p ∧ Nat.Prime p


/-- The Oracle of Divisibility sees the lattice structure. -/
structure OracleOfDivisibility where
  /-- Divisibility is a partial order. -/
  div_refl : ∀ n : ℕ, 0 < n → n ∣ n
  /-- GCD is the meet in the divisibility lattice. -/
  gcd_is_meet : ∀ a b d : ℕ, d = Nat.gcd a b → d ∣ a ∧ d ∣ b


/-- The Oracle of Congruences sees the cyclic symmetry. -/
structure OracleOfCongruences where
  /-- Fermat's little theorem: the prime clock resets. -/
  fermat_little : ∀ p a : ℕ, Nat.Prime p → ¬(p ∣ a) → a ^ (p - 1) ≡ 1 [MOD p]


/-- The Oracle of Sums sees the accumulation of pattern. -/
structure OracleOfSums where
  /-- Gauss's identity: the triangle numbers. -/
  gauss_sum : ∀ n : ℕ, 2 * (∑ i ∈ Finset.range (n + 1), i) = n * (n + 1)


/-- The Oracle of Diophantine sees integer solutions. -/
structure OracleOfDiophantine where
  /-- Fermat's Last Theorem for n=4: no solutions in positive integers. -/
  flt4 : ∀ a b c : ℕ, a ≠ 0 → b ≠ 0 → c ≠ 0 → a ^ 4 + b ^ 4 ≠ c ^ 4


