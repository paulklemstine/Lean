/-! # CatalogBuild.Shared.CarmichaelHelper

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3
-/

import Mathlib

/-- For prime n ≥ 13, any prime factor of F(n) is a primitive divisor.
This is because the entry point must divide n, and since n is prime,
the entry point is either 1 or n. But F(1) = 1, so no prime divides F(1).
Therefore any prime dividing F(n) does not divide F(k) for 0 < k < n. -/
theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- By definition of $fib$, we know that $fib(n) > 1$ for $n \geq 3$.
  have h_fib_gt_one : 1 < Nat.fib n := by
    exact lt_of_lt_of_le ( by decide ) ( Nat.fib_mono hn );
  obtain ⟨ p, hp_prime, hp_div ⟩ := Nat.exists_prime_and_dvd h_fib_gt_one.ne';
  refine' ⟨ p, hp_prime, hp_div, fun k hk₁ hk₂ hk₃ => _ ⟩;
  -- By the properties of Fibonacci numbers, if $p$ divides both $F(n)$ and $F(k)$, then $p$ must also divide $F(\gcd(n, k))$.
  have h_div_gcd : p ∣ Nat.fib (Nat.gcd n k) := by
    exact Nat.dvd_gcd hp_div hk₃ |> fun h => h.trans ( by simp +decide [ Nat.fib_gcd ] );
  -- Since $n$ is prime and $0 < k < n$, we have $\gcd(n, k) = 1$.
  have h_gcd_one : Nat.gcd n k = 1 := by
    exact hnp.coprime_iff_not_dvd.mpr ( Nat.not_dvd_of_pos_of_lt hk₁ hk₂ );
  aesop


/-- [Section: # Helper lemmas for Carmichael's theorem on primitive Fibonacci divisors] -/
lemma fib_gt_one (n : ℕ) (hn : 3 ≤ n) : 1 < Nat.fib n := by
  exact Nat.le_trans ( by decide ) ( Nat.fib_mono hn )


lemma exists_prime_dvd (n : ℕ) (hn : 1 < n) : ∃ p, Nat.Prime p ∧ p ∣ n := by
  exact Nat.exists_prime_and_dvd hn.ne'
