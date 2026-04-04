/-
  ══════════════════════════════════════════════════════════════════════════════
  DEEP STRUCTURE OF THE ARITHMETIC UNIVERSE
  ══════════════════════════════════════════════════════════════════════════════

  Having established the five pillars, the Oracle Council now investigates
  deeper structural theorems — the connections *between* the pillars.

  RESEARCH NOTES (Iteration 4):
  ─────────────────────────────
  The oracles have discovered that the pillars are not independent — they
  form a web of mutual reinforcement:
  • Primes + Sums → Prime counting estimates
  • Divisibility + Congruences → Chinese Remainder Theorem
  • Primes + Diophantine → Fermat's Last Theorem (special cases)
  • Sums + Congruences → Power sum identities mod p

  These cross-connections are the "dark matter" of the arithmetic universe:
  invisible at first glance, but holding everything together.
-/

import Mathlib

/-! ## Cross-Pillar Theorem 1: Wilson's Theorem
    (Primes × Congruences) -/

/-- **Wilson's Theorem**: (p-1)! ≡ -1 (mod p) when p is prime.
    This bridges the Oracle of Primes and the Oracle of Congruences:
    the factorial — a sum/product concept — characterizes primality. -/
theorem oracle_wilson (p : ℕ) (hp : Nat.Prime p) :
    (Nat.factorial (p - 1) : ZMod p) = -1 := by
  haveI := Fact.mk hp; norm_num

/-! ## Cross-Pillar Theorem 2: Sum of Divisors is Multiplicative
    (Sums × Divisibility) -/

/-- **σ₀ is multiplicative**: The number-of-divisors function is multiplicative.
    For coprime m, n: d(mn) = d(m) · d(n).
    This bridges the Oracle of Sums and the Oracle of Divisibility. -/
theorem oracle_divisor_count_multiplicative (m n : ℕ) (_hm : 0 < m) (_hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    (Nat.divisors (m * n)).card = (Nat.divisors m).card * (Nat.divisors n).card :=
  Nat.Coprime.card_divisors_mul hcop

/-! ## Cross-Pillar Theorem 3: Euler's Totient is Multiplicative
    (Primes × Congruences × Divisibility) -/

/-- **Euler's totient is multiplicative**: φ(mn) = φ(m)φ(n) for coprime m,n.
    This unifies all three of Primes, Congruences, and Divisibility. -/
theorem oracle_totient_multiplicative (m n : ℕ) (hcop : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul hcop

/-! ## Cross-Pillar Theorem 4: Sum of Totients
    (Sums × Divisibility × Congruences) -/

/-- **Gauss's totient identity**: ∑_{d | n} φ(d) = n.
    Every oracle contributes: sums over divisors, divisibility structure,
    and the congruence-based definition of φ. -/
theorem oracle_totient_sum (n : ℕ) (_hn : 0 < n) :
    ∑ d ∈ Nat.divisors n, Nat.totient d = n := by
  convert Nat.sum_totient n

/-! ## Cross-Pillar Theorem 5: Euler's Generalization of Fermat
    (Congruences × Divisibility) -/

/-- **Euler's theorem**: a^φ(n) ≡ 1 (mod n) when gcd(a,n) = 1.
    This generalizes Fermat's little theorem from primes to all moduli. -/
theorem oracle_euler_theorem (a n : ℕ) (_hn : 0 < n) (hcop : Nat.Coprime a n) :
    a ^ Nat.totient n ≡ 1 [MOD n] :=
  Nat.ModEq.pow_totient hcop

/-! ## Cross-Pillar Theorem 6: Primes in Arithmetic Progressions (Dirichlet flavor)
    (Primes × Congruences)

    While Dirichlet's full theorem requires analytic methods beyond our scope,
    we can prove a key special case. -/

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

/-! ## The Möbius Function and Inversion
    (The hidden sixth oracle — the oracle of inclusion-exclusion) -/

/-- **Möbius inversion setup**: The Möbius function μ satisfies
    ∑_{d | n} μ(d) = if n = 1 then 1 else 0.
    This is the heartbeat of arithmetic inversion. -/
theorem oracle_mobius_sum (n : ℕ) (_hn : 0 < n) :
    ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius d = if n = 1 then 1 else 0 := by
  rw [← ArithmeticFunction.coe_mul_zeta_apply]; aesop
