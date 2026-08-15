import Novelty.PowerSumGCDFactoring

/-!
# Carmichael periodicity of the power-sum gcd, and the correct factor-recovery identity

Continuing `Novelty.PowerSumGCDFactoring`, let `N = p q` be a semiprime and

  `g(k) = gcd(F(N,k), N)`,  `F(N,k) = ∑_{a=1}^{N} a^k`.

The closed formula `gcd_powerSum_semiprime` shows `g` depends on `k` only through the
two divisibility conditions `(p-1) ∣ k`, `(q-1) ∣ k`.  Consequently `g` is periodic with
period `λ(N) = lcm(p-1, q-1)`, and `λ(N)` is *exactly* the minimal period; indeed

  `g(k) = 1 ↔ λ(N) ∣ k`   (for `k > 0`),

so the Carmichael exponent is readable off the zero set of `g`.

We also prove the stronger, term-wise statement that the power sum itself is periodic
modulo `N` (`powerSum_modEq_add_period`), which is the Korselt/Carmichael congruence
`a^{k+λ} ≡ a^k (mod N)` summed over `a`.

## Critique of the naive recovery formula

The informal claim "`p + q = N - λ(N) + 1`" is **false** whenever `gcd(p-1,q-1) > 1`,
in particular for *every* product of two distinct odd primes.  The correct statement is

  `p + q + λ(N) · gcd(p-1, q-1) = N + 1`   (`sum_primes_recovery`),

and the naive formula always strictly overshoots (`naive_recovery_strict_lt`), with the
explicit witness `N = 15` (`naive_recovery_counterexample`).

## Main results

* `powerSum_modEq_add_period`, `gcd_powerSum_periodic` : periodicity;
* `gcd_powerSum_eq_one_iff` : `g(k) = 1 ↔ λ(N) ∣ k`;
* `period_dvd_of_isPeriod`, `carmichael_is_least_period` : minimality of `λ(N)`;
* `sum_primes_recovery`, `naive_recovery_strict_lt`, `naive_recovery_counterexample`.
-/

open Finset

namespace PowerSumGCD

/-- The Carmichael exponent of a semiprime `p q`. -/
def carmichael (p q : ℕ) : ℕ := Nat.lcm (p - 1) (q - 1)

lemma carmichael_pos {p q : ℕ} (hp : p.Prime) (hq : q.Prime) : 0 < carmichael p q := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  refine Nat.pos_of_ne_zero fun h => ?_
  rcases Nat.lcm_eq_zero_iff.mp h with h' | h' <;> omega

/-- A prime power congruence: for `k > 0` and `(p-1) ∣ L`, raising to the extra exponent
`L` changes nothing modulo `p`.  Both the unit classes (Fermat) and the zero class
(where `k > 0` is what is needed) are covered. -/
lemma pow_add_modEq_prime {p a k L : ℕ} (hp : p.Prime) (hk : 0 < k) (hL : (p - 1) ∣ L) :
    a ^ (k + L) ≡ a ^ k [MOD p] := by
  haveI : Fact p.Prime := ⟨hp⟩
  rw [← ZMod.natCast_eq_natCast_iff]
  push_cast
  obtain ⟨t, rfl⟩ := hL
  by_cases h : (a : ZMod p) = 0
  · rw [h, zero_pow hk.ne', zero_pow (by omega)]
  · rw [pow_add, pow_mul, ZMod.pow_card_sub_one_eq_one h, one_pow, mul_one]

/-- **Korselt/Carmichael periodicity of the power sum itself.**  For a semiprime `N = pq`
and `k > 0`, `F(N, k + λ(N)) ≡ F(N, k) (mod N)`. -/
theorem powerSum_modEq_add_period {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : 0 < k) :
    powerSum (p * q) (k + carmichael p q) ≡ powerSum (p * q) k [MOD p * q] := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hterm : ∀ a : ℕ, a ^ (k + carmichael p q) ≡ a ^ k [MOD p * q] := fun a =>
    (Nat.modEq_and_modEq_iff_modEq_mul hcop).mp
      ⟨pow_add_modEq_prime hp hk (Nat.dvd_lcm_left _ _),
       pow_add_modEq_prime hq hk (Nat.dvd_lcm_right _ _)⟩
  exact Nat.ModEq.sum fun a _ => hterm a

/-- **Theorem 3a (periodicity).**  `g(k) = gcd(F(N,k), N)` has period `λ(N)`. -/
theorem gcd_powerSum_periodic {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : 0 < k) :
    Nat.gcd (powerSum (p * q) (k + carmichael p q)) (p * q)
      = Nat.gcd (powerSum (p * q) k) (p * q) := by
  have hkl : 0 < k + carmichael p q := by omega
  rw [gcd_powerSum_semiprime hp hq hpq hk, gcd_powerSum_semiprime hp hq hpq hkl]
  have e1 : ((p - 1) ∣ k + carmichael p q) ↔ ((p - 1) ∣ k) :=
    (Nat.dvd_add_iff_left (Nat.dvd_lcm_left (p - 1) (q - 1))).symm
  have e2 : ((q - 1) ∣ k + carmichael p q) ↔ ((q - 1) ∣ k) :=
    (Nat.dvd_add_iff_left (Nat.dvd_lcm_right (p - 1) (q - 1))).symm
  simp only [e1, e2]

/-- **Theorem 3b (the Carmichael exponent is the zero set).**  For `k > 0`,
the gcd is trivial exactly on the multiples of `λ(N)`. -/
theorem gcd_powerSum_eq_one_iff {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : 0 < k) :
    Nat.gcd (powerSum (p * q) k) (p * q) = 1 ↔ carmichael p q ∣ k := by
  rw [gcd_powerSum_semiprime hp hq hpq hk, carmichael, Nat.lcm_dvd_iff]
  constructor
  · intro h
    by_cases h1 : (p - 1) ∣ k <;> by_cases h2 : (q - 1) ∣ k
    · exact ⟨h1, h2⟩
    · rw [if_pos h1, if_neg h2, one_mul] at h; exact absurd h hq.one_lt.ne'
    · rw [if_neg h1, if_pos h2, mul_one] at h; exact absurd h hp.one_lt.ne'
    · rw [if_neg h1, if_neg h2] at h
      exact absurd (Nat.eq_one_of_mul_eq_one_right h) hp.one_lt.ne'
  · rintro ⟨h1, h2⟩
    rw [if_pos h1, if_pos h2, one_mul]

/-- **Theorem 3c (minimality of the period).**  Any period of `g` is a multiple of `λ(N)`,
so no shorter period exists and `λ(N)` is genuinely observable. -/
theorem period_dvd_of_isPeriod {p q d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hper : ∀ k, 0 < k → Nat.gcd (powerSum (p * q) (k + d)) (p * q)
      = Nat.gcd (powerSum (p * q) k) (p * q)) :
    carmichael p q ∣ d := by
  have hlam := carmichael_pos hp hq
  have h1 : Nat.gcd (powerSum (p * q) (carmichael p q)) (p * q) = 1 :=
    (gcd_powerSum_eq_one_iff hp hq hpq hlam).mpr dvd_rfl
  have h2 : Nat.gcd (powerSum (p * q) (carmichael p q + d)) (p * q) = 1 := by
    rw [hper _ hlam, h1]
  have h3 : carmichael p q ∣ carmichael p q + d :=
    (gcd_powerSum_eq_one_iff hp hq hpq (by omega)).mp h2
  exact (Nat.dvd_add_iff_right (dvd_refl (carmichael p q))).mpr h3

/-- `λ(N)` is the least positive period of `g`, so the Carmichael exponent is
observable from the gcd sequence alone. -/
theorem carmichael_is_least_period {p q d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hd : 0 < d)
    (hper : ∀ k, 0 < k → Nat.gcd (powerSum (p * q) (k + d)) (p * q)
      = Nat.gcd (powerSum (p * q) k) (p * q)) :
    carmichael p q ≤ d :=
  Nat.le_of_dvd hd (period_dvd_of_isPeriod hp hq hpq hper)

/-- **The corrected recovery identity.**  Knowing `N = pq`, `λ(N)` and `gcd(p-1,q-1)`
determines `p + q`, hence (with `N`) the factorisation. -/
theorem sum_primes_recovery {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    p + q + carmichael p q * Nat.gcd (p - 1) (q - 1) = p * q + 1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  have h := Nat.gcd_mul_lcm a b
  simp only [carmichael, Nat.add_sub_cancel]
  rw [Nat.mul_comm (Nat.lcm a b), h]
  ring

/-- **The naive recovery formula `p + q = N - λ(N) + 1` always overshoots** for a product
of two distinct odd primes: the true value of `p + q` is strictly smaller, because
`gcd(p-1,q-1) ≥ 2` forces `λ(N) < (p-1)(q-1)`. -/
theorem naive_recovery_strict_lt {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    p + q + carmichael p q < p * q + 1 := by
  have hrec := sum_primes_recovery hp hq
  have hlam := carmichael_pos hp hq
  have hgcd : 2 ≤ Nat.gcd (p - 1) (q - 1) := by
    have h2p : 2 ∣ p - 1 := (hp.even_sub_one hp2).two_dvd
    have h2q : 2 ∣ q - 1 := (hq.even_sub_one hq2).two_dvd
    have hpos : 0 < p - 1 := by have := hp.two_le; omega
    exact Nat.le_of_dvd (Nat.gcd_pos_of_pos_left _ hpos) (Nat.dvd_gcd h2p h2q)
  nlinarith [hrec, hlam, hgcd]

/-- Explicit counterexample to the naive recovery formula: for `N = 15` we have `λ = 4`
and `N - λ + 1 = 12`, while `p + q = 8`. -/
theorem naive_recovery_counterexample :
    carmichael 3 5 = 4 ∧ 3 + 5 ≠ 3 * 5 - carmichael 3 5 + 1 := by
  refine ⟨by decide, by decide⟩

end PowerSumGCD