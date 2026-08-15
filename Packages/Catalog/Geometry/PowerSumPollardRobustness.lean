import Geometry.PowerSumFactorReveal

/-!
# Robustness: the power sum has no "bad base", Pollard's `p-1` does

Pollard's `p-1` method depends on a *base* `a`: it computes `gcd (a^M - 1, N)` and
succeeds only if the multiplicative order of `a` modulo one prime factor divides the
exponent `M` while the order modulo the other one does not.  The power-sum quantity
`powerSum N k = ∑_{a=1}^{N} a^k` has no base parameter at all: it aggregates every
residue simultaneously.

This file makes the contrast precise.

* `PowerSumReveal.pollard_universally_bad_base` — for a semiprime `N = p*q` of distinct
  *odd* primes, the base `a = N - 1` (a nontrivial base, coprime to `N`) is bad for
  **every** exponent `M ≥ 1`: `gcd (a^M - 1, N) ∈ {1, N}`, never a proper factor.
* `PowerSumReveal.powerSum_succeeds_where_pollard_fails` — at the very exponent
  `k = p - 1` where that base makes Pollard return the useless value `N`, the power
  sum returns the factor `q` (under the standard side condition `(q-1) ∤ (p-1)`).
* `PowerSumReveal.pollard_bad_base_example` — the concrete instance `N = 35`, `M = 4`,
  `a = 6`: Pollard returns `35`, the power sum returns `7`.

Note that the statement `a = N - 1` is a genuinely nontrivial base: `1 < N - 1 < N`.
-/

namespace PowerSumReveal

open Finset

variable {p q : ℕ}

/-- Pollard `p-1` style gcd for base `a` and exponent `M`. -/
def pollardGcd (N a M : ℕ) : ℕ := Nat.gcd (a ^ M - 1) N

/-- Casting `(N-1)^M - 1` into `ZMod p`. -/
lemma cast_pow_pred_sub_one (r N M : ℕ) [NeZero r] (hN : 2 ≤ N) :
    (((N - 1) ^ M - 1 : ℕ) : ZMod r) = ((N : ZMod r) - 1) ^ M - 1 := by
  have h1 : 1 ≤ (N - 1) ^ M := Nat.one_le_pow _ _ (by omega)
  rw [Nat.cast_sub h1]
  push_cast [Nat.cast_sub (show 1 ≤ N by omega)]
  ring

/-- For an odd prime factor `r` of `N` and an *odd* exponent `M`, the prime `r` does not
divide `(N-1)^M - 1`, because that quantity is `≡ -2 (mod r)`. -/
lemma not_dvd_pow_pred_sub_one_of_odd {r N M : ℕ} (hr : r.Prime) (hr2 : r ≠ 2)
    (hrN : r ∣ N) (hN : 2 ≤ N) (hM : Odd M) :
    ¬ r ∣ ((N - 1) ^ M - 1) := by
  haveI : Fact r.Prime := ⟨hr⟩
  intro hdvd
  have h0 : (((N - 1) ^ M - 1 : ℕ) : ZMod r) = 0 := (ZMod.natCast_eq_zero_iff _ r).2 hdvd
  rw [cast_pow_pred_sub_one r N M hN, (ZMod.natCast_eq_zero_iff N r).2 hrN, zero_sub,
    hM.neg_one_pow] at h0
  have h2 : ((2 : ℕ) : ZMod r) = 0 := by
    have : (-1 : ZMod r) - 1 = -(2 : ZMod r) := by ring
    rw [this] at h0
    have := neg_eq_zero.mp h0
    exact_mod_cast this
  exact hr2 ((Nat.prime_dvd_prime_iff_eq hr Nat.prime_two).1
    ((ZMod.natCast_eq_zero_iff 2 r).1 h2))

/-- For an even exponent `M`, every divisor of `N` divides `(N-1)^M - 1`. -/
lemma dvd_pow_pred_sub_one_of_even {r N M : ℕ} (hr : r.Prime) (hrN : r ∣ N) (hN : 2 ≤ N)
    (hM : Even M) : r ∣ ((N - 1) ^ M - 1) := by
  haveI : Fact r.Prime := ⟨hr⟩
  refine (ZMod.natCast_eq_zero_iff _ r).1 ?_
  rw [cast_pow_pred_sub_one r N M hN, (ZMod.natCast_eq_zero_iff N r).2 hrN, zero_sub,
    hM.neg_one_pow, sub_self]

/-- **Theorem 2a (a universally bad Pollard base).**  Let `N = p * q` with `p ≠ q`
distinct odd primes.  Then the nontrivial base `a = N - 1` never reveals a factor:
for every exponent `M`, `pollardGcd N (N-1) M` is `N` (when `M` is even) or `1`
(when `M` is odd).  In particular it is never a proper divisor of `N`. -/
theorem pollard_universally_bad_base (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (M : ℕ) :
    pollardGcd (p * q) (p * q - 1) M = if Even M then p * q else 1 := by
  have hN : 2 ≤ p * q := by
    have := hp.two_le; have := hq.two_le; nlinarith
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have hpN : p ∣ p * q := ⟨q, rfl⟩
  have hqN : q ∣ p * q := ⟨p, by ring⟩
  unfold pollardGcd
  rw [Nat.Coprime.gcd_mul _ hcop, gcd_prime_eq hp, gcd_prime_eq hq]
  rcases Nat.even_or_odd M with hM | hM
  · rw [if_pos hM, if_pos (dvd_pow_pred_sub_one_of_even hp hpN hN hM),
      if_pos (dvd_pow_pred_sub_one_of_even hq hqN hN hM)]
  · rw [if_neg (Nat.not_even_iff_odd.2 hM),
      if_neg (not_dvd_pow_pred_sub_one_of_odd hp hp2 hpN hN hM),
      if_neg (not_dvd_pow_pred_sub_one_of_odd hq hq2 hqN hN hM), one_mul]

/-- The bad base is genuinely nontrivial: `1 < N - 1 < N` and it is coprime to `N`. -/
theorem pollard_bad_base_nontrivial (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) :
    1 < p * q - 1 ∧ p * q - 1 < p * q ∧ Nat.Coprime (p * q - 1) (p * q) := by
  have h1 := hp.two_le
  have h2 := hq.two_le
  have h3 : 3 ≤ p := by omega
  have h4 : 3 ≤ q := by omega
  have hN : 9 ≤ p * q := by nlinarith
  refine ⟨by omega, by omega, ?_⟩
  obtain ⟨m, hm⟩ : ∃ m, p * q = m + 1 := ⟨p * q - 1, by omega⟩
  rw [hm]; simp

/-- **Theorem 2b (robustness).**  At the exponent `k = p - 1`, Pollard's method with the
bad base `N - 1` returns the useless value `N`, while the base-free power sum returns the
proper factor `q`. -/
theorem powerSum_succeeds_where_pollard_fails (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    pollardGcd (p * q) (p * q - 1) (p - 1) = p * q ∧
      Nat.gcd (powerSum (p * q) (p - 1)) (p * q) = q := by
  have hodd : Odd p := hp.odd_of_ne_two hp2
  have heven : Even (p - 1) := by
    obtain ⟨m, hm⟩ := hodd
    refine ⟨m, by omega⟩
  refine ⟨?_, powerSum_factor_reveal hp hq hpq hdvd⟩
  rw [pollard_universally_bad_base hp hq hpq hp2 hq2, if_pos heven]

/-- **Concrete instance.**  `N = 35 = 5 * 7`, exponent `M = 4 = p - 1`.
Pollard's `p-1` with the base `6 = N - 1` returns `35` (failure); the power sum at the
same exponent returns the factor `7`. -/
theorem pollard_bad_base_example :
    pollardGcd 35 6 4 = 35 ∧ Nat.gcd (powerSum 35 4) 35 = 7 := by
  constructor
  · decide
  · have h : (35 : ℕ) = 5 * 7 := by norm_num
    have := powerSum_factor_reveal (p := 5) (q := 7) (by norm_num) (by norm_num)
      (by norm_num) (by decide)
    simpa [h] using this

end PowerSumReveal