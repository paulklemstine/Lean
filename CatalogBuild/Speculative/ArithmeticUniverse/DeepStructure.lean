/-! # CatalogBuild.Speculative.ArithmeticUniverse.DeepStructure

Auto-generated from theorem catalog database.
Domain: Speculative/ArithmeticUniverse
Declarations: 5
-/

import Mathlib

/-- **σ₀ is multiplicative**: The number-of-divisors function is multiplicative.
For coprime m, n: d(mn) = d(m) · d(n).
This bridges the Oracle of Sums and the Oracle of Divisibility. -/
theorem oracle_divisor_count_multiplicative (m n : ℕ) (_hm : 0 < m) (_hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    (Nat.divisors (m * n)).card = (Nat.divisors m).card * (Nat.divisors n).card :=
  Nat.Coprime.card_divisors_mul hcop


/-- **Gauss's totient identity**: ∑_{d | n} φ(d) = n.
Every oracle contributes: sums over divisors, divisibility structure,
and the congruence-based definition of φ. -/
theorem oracle_totient_sum (n : ℕ) (_hn : 0 < n) :
    ∑ d ∈ Nat.divisors n, Nat.totient d = n := by
  convert Nat.sum_totient n


/-- **Euler's theorem**: a^φ(n) ≡ 1 (mod n) when gcd(a,n) = 1.
This generalizes Fermat's little theorem from primes to all moduli. -/
theorem oracle_euler_theorem (a n : ℕ) (_hn : 0 < n) (hcop : Nat.Coprime a n) :
    a ^ Nat.totient n ≡ 1 [MOD n] :=
  Nat.ModEq.pow_totient hcop


/-- There are infinitely many primes congruent to 3 mod 4.
A beautiful interplay between primes and congruences. -/
theorem oracle_primes_3_mod_4 : ∀ n : ℕ, ∃ p : ℕ, n < p ∧ Nat.Prime p ∧ p % 4 = 3 := by
  have h_finite : ∀ n : ℕ, ∃ p : ℕ, p > n ∧ Nat.Prime p ∧ p % 4 = 3 := by
    intro n
    by_contra h
    push_neg at h
    have hN_prime_divisor :
        ∃ p, Nat.Prime p ∧ p ∣ (4 * Nat.factorial (n + 1) - 1) ∧ p % 4 = 3 := by
      by_contra h_no_prime_divisor
      have h_all_prime_divisors_mod_4_1 :
          ∀ p, Nat.Prime p ∧ p ∣ (4 * Nat.factorial (n + 1) - 1) → p % 4 = 1 := by
        intros p hp
        have hp_odd : p % 2 = 1 :=
          hp.1.eq_two_or_odd.resolve_left (by
            rintro rfl
            exact absurd (hp.2.even) (by
              norm_num [Nat.one_le_iff_ne_zero, parity_simps, Nat.factorial_ne_zero]))
        grind +ring
      have hN_mod_4_1 : (4 * Nat.factorial (n + 1) - 1) % 4 = 1 := by
        have h_prod_mod_4_1 :
            ∀ {m : ℕ}, (∀ p, Nat.Prime p ∧ p ∣ m → p % 4 = 1) → m % 4 = 1 := by
          intros m hm
          rw [← Nat.prod_primeFactorsList (show m ≠ 0 from fun hk ↦ by
            subst hk; specialize @hm 2; simp_all +decide)]
          rw [List.prod_nat_mod]
          exact by rw [List.prod_eq_one] <;> intros <;> aesop
        exact h_prod_mod_4_1 h_all_prime_divisors_mod_4_1
      omega
    obtain ⟨p, hp₁, hp₂, hp₃⟩ := hN_prime_divisor
    exact h p (not_le.mp fun hp₄ => by
      have := Nat.dvd_sub
        (dvd_mul_of_dvd_right (Nat.dvd_factorial (Nat.pos_of_ne_zero hp₁.ne_zero)
          (by linarith : n + 1 ≥ p)) 4) hp₂
      erw [Nat.sub_sub_self (Nat.one_le_iff_ne_zero.2 <| by positivity)] at this
      aesop) hp₁ hp₃
  exact h_finite


/-- **Möbius inversion setup**: The Möbius function μ satisfies
∑_{d | n} μ(d) = if n = 1 then 1 else 0.
This is the heartbeat of arithmetic inversion. -/
theorem oracle_mobius_sum (n : ℕ) (_hn : 0 < n) :
    ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius d = if n = 1 then 1 else 0 := by
  rw [← ArithmeticFunction.coe_mul_zeta_apply]; aesop


