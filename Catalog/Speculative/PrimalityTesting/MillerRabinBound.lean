import Mathlib
import Speculative.PrimalityTesting.Defs

/-!
# Miller-Rabin Witness Density Bound

Helper lemmas toward the proof that for odd composite n ≥ 3,
the set of Miller-Rabin liars has cardinality at most (n-1)/4.

## Overview

The proof splits into cases based on whether n is a prime power or has
at least two distinct prime factors.

### Case 1: n has at least two coprime factors
If n = ab with gcd(a,b)=1, a,b > 1, then by CRT we can construct
elements x with x ≡ 1 (mod a), x ≡ -1 (mod b). Such x is a nontrivial
square root of unity, which constrains the Miller-Rabin liar set.

### Case 2: n is a prime power p^k, k ≥ 2
The unit group (Z/p^k Z)* is cyclic. The liars form a specific subgroup
whose index is at least 4.
-/

open Finset Nat

/-! ## Nontrivial square roots of unity -/

/-
For composite n with two coprime factors, nontrivial square roots of unity exist.
-/
theorem exists_nontrivial_sqrt_unity (n a b : ℕ)
    (hn : n = a * b) (ha : 1 < a) (hb : 1 < b) (hcop : Nat.Coprime a b)
    (hn_odd : n % 2 = 1) :
    ∃ x, 1 < x ∧ x < n ∧ x ^ 2 ≡ 1 [MOD n] ∧ ¬ (x ≡ 1 [MOD n]) ∧ ¬ (x ≡ n - 1 [MOD n]) := by
  -- By the Chinese Remainder Theorem, there exists an $x$ such that $x \equiv 1 \pmod{a}$ and $x \equiv -1 \pmod{b}$.
  obtain ⟨x, hx⟩ : ∃ x, x ≡ 1 [MOD a] ∧ x ≡ b - 1 [MOD b] ∧ x < a * b := by
    have := Nat.chineseRemainder hcop 1 ( b - 1 );
    exact ⟨ this.1 % ( a * b ), by simpa [ Nat.ModEq, Nat.mod_mod ] using this.2.1, by simpa [ Nat.ModEq, Nat.mod_mod ] using this.2.2, Nat.mod_lt _ ( by positivity ) ⟩;
  refine' ⟨ x, _, _, _, _, _ ⟩ <;> simp_all +decide [ Nat.ModEq ];
  · rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> rcases x with ( _ | _ | x ) <;> simp_all +arith +decide [ Nat.mod_eq_of_lt ];
  · -- Since $x \equiv 1 \pmod{a}$ and $x \equiv -1 \pmod{b}$, we have $x^2 \equiv 1 \pmod{a}$ and $x^2 \equiv 1 \pmod{b}$.
    have hx2_mod_a : x^2 % a = 1 % a := by
      simp +decide [ Nat.pow_mod, hx.1 ];
      norm_num [ Nat.mod_eq_of_lt ha ]
    have hx2_mod_b : x^2 % b = 1 % b := by
      simp +decide [ ← ZMod.natCast_eq_natCast_iff', hx.2.1 ];
      rw [ ← Nat.mod_add_div x b, hx.2.1 ] ; norm_num [ Nat.cast_sub hb.le ];
    rw [ Nat.ModEq.symm ];
    rw [ ← Nat.modEq_and_modEq_iff_modEq_mul ] ; tauto;
    assumption;
  · rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
    aesop;
  · rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
    intro H; simp_all +decide [ Nat.mul_succ, Nat.add_mod, Nat.mod_eq_of_lt ] ;

/-
Any odd composite n ≥ 9 has at least two coprime factors > 1, or is an odd prime power.
-/
theorem composite_odd_dichotomy (n : ℕ) (hn_odd : n % 2 = 1) (hn_comp : ¬ Nat.Prime n) (hge : 3 ≤ n) :
    (∃ a b : ℕ, n = a * b ∧ 1 < a ∧ 1 < b ∧ Nat.Coprime a b) ∨
    (∃ p k : ℕ, Nat.Prime p ∧ 2 ≤ k ∧ n = p ^ k) := by
  by_cases h_coprime_factors : ∃ a b : ℕ, n = a * b ∧ 1 < a ∧ 1 < b ∧ Nat.Coprime a b;
  · exact Or.inl h_coprime_factors;
  · -- If n has only one prime factor p, then n = p^k for some k ≥ 2.
    obtain ⟨p, k, hp, hk⟩ : ∃ p k : ℕ, Nat.Prime p ∧ n = p^k := by
      -- Since n is composite and has no coprime factors, it must be a prime power.
      have h_prime_power : ∀ p, Nat.Prime p → p ∣ n → ∀ q, Nat.Prime q → q ∣ n → p = q := by
        contrapose! h_coprime_factors;
        obtain ⟨ p, hp₁, hp₂, q, hq₁, hq₂, hpq ⟩ := h_coprime_factors;
        -- Since $p$ and $q$ are distinct primes dividing $n$, we can write $n = p^k \cdot m$ where $m$ is not divisible by $p$.
        obtain ⟨k, m, hm⟩ : ∃ k m : ℕ, n = p^k * m ∧ ¬p ∣ m := by
          exact ⟨ Nat.factorization n p, n / p ^ Nat.factorization n p, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.not_dvd_ordCompl ( by aesop ) ( by aesop ) ⟩;
        refine' ⟨ p ^ k, m, hm.1, _, _, _ ⟩;
        · rcases k with ( _ | k ) <;> simp_all +decide [ Nat.pow_succ' ];
          exact one_lt_mul_of_lt_of_le hp₁.one_lt ( Nat.one_le_pow _ _ hp₁.pos );
        · rcases m with ( _ | _ | m ) <;> simp_all +decide;
          exact absurd ( hq₁.dvd_of_dvd_pow hq₂ ) ( by rw [ Nat.prime_dvd_prime_iff_eq ] <;> tauto );
        · exact Nat.Coprime.pow_left _ ( hp₁.coprime_iff_not_dvd.mpr hm.2 );
      obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ n := by
        exact Nat.exists_prime_and_dvd ( by linarith );
      exact ⟨ p, Nat.primeFactorsList n |> List.count p, hp.1, by nth_rw 1 [ ← Nat.prod_primeFactorsList ( by linarith : n ≠ 0 ) ] ; rw [ List.prod_eq_pow_single p ] ; intros q hq ; specialize h_prime_power p hp.1 hp.2 q ; aesop ⟩;
    exact Or.inr ⟨ p, k, hp, le_of_not_gt fun h => by interval_cases k <;> simp_all +decide, hk ⟩

/-- For odd prime powers p^k with k ≥ 2, the unit group has a specific structure
    that limits the liar count. -/
theorem prime_power_liars_bound (p k : ℕ) (hp : Nat.Prime p) (hk : 2 ≤ k)
    (hp_odd : p % 2 = 1) :
    4 * (MRLiars (p ^ k)).card ≤ p ^ k - 1 := by
  sorry

/-- For n with two coprime factors, the liar count is bounded by (n-1)/4. -/
theorem coprime_factors_liars_bound (n a b : ℕ)
    (hn : n = a * b) (ha : 1 < a) (hb : 1 < b) (hcop : Nat.Coprime a b)
    (hn_odd : n % 2 = 1) :
    4 * (MRLiars n).card ≤ n - 1 := by
  sorry