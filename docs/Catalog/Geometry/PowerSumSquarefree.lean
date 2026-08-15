import Geometry.PowerSumFactorReveal

/-!
# The power-sum reveal for arbitrary squarefree moduli, and a Giuga/Korselt bridge

The semiprime analysis of `Geometry.PowerSumFactorReveal` uses nothing about the
number of prime factors: for **any** squarefree `N` and any prime `p ∣ N`,

`p ∣ powerSum N k ↔ ¬ (p - 1) ∣ k`   (`k ≥ 1`).

Consequently `gcd (powerSum N k) N = 1` exactly when `λ(N) ∣ k`, where
`λ(N) = lcm_{p ∣ N} (p - 1)` is the Carmichael function of a squarefree number.
This is the general form of the "Carmichael periodicity" phenomenon.

The last section links this to two classical topics.

* *Fermat/Giuga.*  For a prime `p`, `powerSum p (p-1) ≡ -1 (mod p)`.
* *Korselt.*  A squarefree `N` is a Korselt number (`(p-1) ∣ (N-1)` for all `p ∣ N`,
  the criterion defining Carmichael numbers) **iff** the power-sum gcd at the natural
  exponent `k = N - 1` is trivial.  So Carmichael numbers are precisely the squarefree
  moduli on which the exponent `N-1` gives the method no information.

## Main results

* `PowerSumReveal.prime_dvd_powerSum_iff_squarefree`
* `PowerSumReveal.coprime_powerSum_iff_lambda_dvd`
* `PowerSumReveal.powerSum_prime_eq_neg_one` (Fermat/Giuga direction)
* `PowerSumReveal.korselt_iff_coprime_powerSum`
-/

namespace PowerSumReveal

open Finset

/-- The Carmichael function of a squarefree modulus: `lcm_{p ∣ N} (p - 1)`. -/
def lambdaSqfree (N : ℕ) : ℕ := N.primeFactors.lcm (fun p => p - 1)

/-- In a squarefree number, a prime factor appears to the first power only. -/
lemma not_dvd_div_of_squarefree {N p : ℕ} (hN : Squarefree N) (hp : p.Prime) (hd : p ∣ N) :
    ¬ p ∣ N / p := by
  intro h2
  have hsq : p * p ∣ N := by
    obtain ⟨c, hc⟩ := hd
    obtain ⟨d, hdd⟩ := h2
    subst hc
    rw [Nat.mul_div_cancel_left _ hp.pos] at hdd
    exact ⟨d, by rw [hdd]; ring⟩
  exact hp.one_lt.ne' (Nat.isUnit_iff.mp (hN p hsq))

/-- **Divisibility criterion, squarefree case.**  For squarefree `N`, a prime `p ∣ N`
and `k ≥ 1`: `p ∣ powerSum N k ↔ ¬ (p-1) ∣ k`. -/
theorem prime_dvd_powerSum_iff_squarefree {N p k : ℕ} (hN : Squarefree N) (hp : p.Prime)
    (hd : p ∣ N) (hk : k ≠ 0) :
    p ∣ powerSum N k ↔ ¬ (p - 1) ∣ k := by
  obtain ⟨m, hm⟩ := hd
  have hpm : ¬ p ∣ m := by
    have := not_dvd_div_of_squarefree hN hp ⟨m, hm⟩
    rwa [hm, Nat.mul_div_cancel_left _ hp.pos] at this
  rw [hm]
  exact prime_dvd_powerSum_iff hp hpm hk

/-- **General Carmichael periodicity.**  For squarefree `N > 0` and `k ≥ 1`, the power sum
is coprime to `N` exactly when `λ(N) ∣ k`. -/
theorem coprime_powerSum_iff_lambda_dvd {N k : ℕ} (hN : Squarefree N) (hN0 : N ≠ 0)
    (hk : k ≠ 0) :
    Nat.Coprime (powerSum N k) N ↔ lambdaSqfree N ∣ k := by
  rw [lambdaSqfree, Finset.lcm_dvd_iff]
  constructor
  · intro hcop r hr
    rw [Nat.mem_primeFactors] at hr
    obtain ⟨hrp, hrN, -⟩ := hr
    by_contra hdk
    have hdvd : r ∣ powerSum N k :=
      (prime_dvd_powerSum_iff_squarefree hN hrp hrN hk).2 hdk
    exact Nat.Prime.not_coprime_iff_dvd.2 ⟨r, hrp, hdvd, hrN⟩ hcop
  · intro hall
    by_contra hcop
    obtain ⟨r, hrp, hrS, hrN⟩ := Nat.Prime.not_coprime_iff_dvd.1 hcop
    have hmem : r ∈ N.primeFactors := Nat.mem_primeFactors.2 ⟨hrp, hrN, hN0⟩
    exact (prime_dvd_powerSum_iff_squarefree hN hrp hrN hk).1 hrS (hall r hmem)

/-- **Fermat / Giuga direction.**  For a prime `p`, `∑_{a=1}^{p} a^{p-1} ≡ -1 (mod p)`. -/
theorem powerSum_prime_eq_neg_one {p : ℕ} (hp : p.Prime) :
    ((powerSum p (p - 1) : ℕ) : ZMod p) = -1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hk : p - 1 ≠ 0 := by have := hp.two_le; omega
  have h := powerSum_cast p 1 (k := p - 1) hk
  rw [mul_one] at h
  rw [sum_pow_zmod p hk, if_pos dvd_rfl] at h
  simpa using h

/-- Consequently a prime is never "revealed" by itself: the gcd is `1`. -/
theorem gcd_powerSum_prime {p : ℕ} (hp : p.Prime) :
    Nat.gcd (powerSum p (p - 1)) p = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hne : ((powerSum p (p - 1) : ℕ) : ZMod p) ≠ 0 := by
    rw [powerSum_prime_eq_neg_one hp]
    simp
  have : ¬ p ∣ powerSum p (p - 1) := fun h => hne ((ZMod.natCast_eq_zero_iff _ p).2 h)
  rw [gcd_prime_eq hp, if_neg this]

/-- **Korselt bridge.**  A squarefree `N ≥ 2` satisfies Korselt's criterion — the
condition defining Carmichael numbers, `(p-1) ∣ (N-1)` for every prime `p ∣ N` — if and
only if the power-sum gcd at exponent `N - 1` is trivial.  Equivalently, Carmichael
numbers are exactly the squarefree moduli that defeat the reveal at `k = N-1`. -/
theorem korselt_iff_coprime_powerSum {N : ℕ} (hN : Squarefree N) (hN2 : 2 ≤ N) :
    (∀ p ∈ N.primeFactors, (p - 1) ∣ (N - 1)) ↔
      Nat.gcd (powerSum N (N - 1)) N = 1 := by
  have hk : N - 1 ≠ 0 := by omega
  have h := coprime_powerSum_iff_lambda_dvd hN (by omega) hk
  rw [Nat.Coprime] at h
  rw [h, lambdaSqfree, Finset.lcm_dvd_iff]

end PowerSumReveal