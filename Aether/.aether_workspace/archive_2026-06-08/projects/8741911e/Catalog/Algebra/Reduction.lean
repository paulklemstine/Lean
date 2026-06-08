/-
# Erdős–Straus Conjecture: Structural Reductions

This file proves two key structural theorems:

1. **Divisor lifting**: If m | n and 4/m has an Egyptian-fraction decomposition,
   then so does 4/n (by scaling all denominators by n/m).

2. **Prime reduction**: It suffices to prove the conjecture for primes.
   This is because every n ≥ 2 has a prime factor p, and if 4/p = 1/a + 1/b + 1/c,
   then 4/n = 1/(a·(n/p)) + 1/(b·(n/p)) + 1/(c·(n/p)).

These reductions transform the conjecture into a prime-only problem.
-/
import Speculative.ErdosStraus.Defs

/-
**Divisor lifting.**
If m divides n, both are positive, and 4/m admits an Erdős–Straus decomposition
(a, b, c), then 4/n admits the decomposition (a·(n/m), b·(n/m), c·(n/m)).

Proof: let d = n/m. If 4·a·b·c = m·(ab + ac + bc), then
4·(ad)·(bd)·(cd) = 4abcd³ = m(ab+ac+bc)d³ = md·d²(ab+ac+bc) = n·d²(ab+ac+bc)
= n·((ad)(bd) + (ad)(cd) + (bd)(cd)).
-/
theorem erdos_straus_of_dvd
    {m n : ℕ} (hmn : m ∣ n) (hm : 1 ≤ m) (hn : 1 ≤ n)
    (hsol : ErdosStrausSolvable m) :
    ErdosStrausSolvable n := by
  obtain ⟨ a, b, c, hab, hbc, hac ⟩ := hsol;
  -- Set d = n / m (natural division, exact since m ∣ n).
  set d := n / m;
  -- Witnesses: (a * d, b * d, c * d).
  use a * d, b * d, c * d;
  constructor;
  · exact Nat.mul_pos hab ( Nat.div_pos ( Nat.le_of_dvd hn hmn ) hm );
  · exact ⟨ Nat.mul_pos hbc ( Nat.div_pos ( Nat.le_of_dvd hn hmn ) hm ), Nat.mul_pos hac.1 ( Nat.div_pos ( Nat.le_of_dvd hn hmn ) hm ), by push_cast; rw [ show ( n : ℤ ) = m * d by norm_cast; rw [ Nat.mul_div_cancel' hmn ] ] ; linear_combination' hac.2 * d ^ 3 ⟩

/-
**Prime reduction.**
If every prime p admits an Erdős–Straus decomposition, then every n ≥ 2 does.

Proof: every n ≥ 2 has a prime factor p (by Nat.exists_prime_and_dvd or
Nat.minFac_prime). Since p | n and ErdosStrausSolvable p,
the divisor-lifting theorem gives ErdosStrausSolvable n.
-/
theorem erdos_straus_reduced_to_primes
    (hprime : ∀ p : ℕ, Nat.Prime p → ErdosStrausSolvable p) :
    ∀ n : ℕ, 2 ≤ n → ErdosStrausSolvable n := by
  -- Let $p$ be the smallest prime factor of $n$.
  intro n hn
  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ n := by
    exact Nat.exists_prime_and_dvd ( by linarith );
  exact erdos_straus_of_dvd hp_dvd hp_prime.pos ( by linarith ) ( hprime p hp_prime )