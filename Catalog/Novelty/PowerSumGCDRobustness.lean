import Novelty.PowerSumGCDFactoring

/-!
# Robustness: the power sum has no "bad base", Pollard `p-1` always does

Pollard's `p-1` method computes `gcd(a^M - 1, N)` for a chosen base `a` and a smooth
exponent `M`.  The method *fails* (returns `N`, i.e. no information) whenever the chosen
base happens to satisfy `a^M ≡ 1` modulo **both** prime factors.

Here we show that for any product of two distinct odd primes and any even exponent `M`
such a bad base always exists — it is the CRT element `a ≡ 1 (mod p)`, `a ≡ -1 (mod q)` —
whereas the power sum `F(N,k) = ∑_{a=1}^{N} a^k` involves no base at all: it aggregates
every residue simultaneously, and by `gcd_powerSum_eq_factor` it produces the factor `q`
at `k = p-1` unconditionally (given `(q-1) ∤ (p-1)`).

## Main results

* `pow_even_modEq_one` : `s^M ≡ 1 (mod s+1)` for even `M` (the `(-1)^even = 1` mechanism);
* `exists_pollard_bad_base` : for distinct odd primes `p, q` and even `M > 0` there is a
  base `1 < a < pq` with `gcd(a^M - 1, pq) = pq`, i.e. Pollard's step fails;
* `powerSum_robust_vs_pollard` : at the very exponent `M = p-1` where the power sum
  hands over the factor `q`, a bad Pollard base exists.
-/

namespace PowerSumGCD

/-- `s ≡ -1 (mod s+1)`, so every even power of `s` is `1` modulo `s+1`. -/
lemma pow_even_modEq_one {s M : ℕ} (hs : 1 ≤ s) (hM : Even M) : s ^ M ≡ 1 [MOD s + 1] := by
  obtain ⟨t, rfl⟩ := hM
  have hsq : s ^ 2 ≡ 1 [MOD s + 1] := by
    obtain ⟨u, rfl⟩ : ∃ u, s = u + 1 := ⟨s - 1, by omega⟩
    have hdvd : (u + 1 + 1) ∣ (u + 1) ^ 2 - 1 := by
      refine ⟨u, ?_⟩
      have h1 : (u + 1) ^ 2 = u * u + 2 * u + 1 := by ring
      have h2 : (u + 1 + 1) * u = u * u + 2 * u := by ring
      omega
    exact ((Nat.modEq_iff_dvd' (Nat.one_le_pow _ _ (by omega))).mpr hdvd).symm
  have hpow : s ^ (t + t) = (s ^ 2) ^ t := by
    rw [← pow_mul]
    ring_nf
  rw [hpow]
  simpa using hsq.pow t

/-- **Pollard `p-1` has bad bases.**  For distinct odd primes `p, q` and any even
exponent `M`, there is a base `1 < a < pq` for which `gcd(a^M - 1, pq) = pq`: the
method returns the whole modulus and reveals nothing.  The witness is the CRT element
`a ≡ 1 (mod p)`, `a ≡ -1 (mod q)`. -/
theorem exists_pollard_bad_base {p q M : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hM : Even M) :
    ∃ a : ℕ, 1 < a ∧ a < p * q ∧ Nat.gcd (a ^ M - 1) (p * q) = p * q := by
  have hp2' := hp.two_le
  have hq2' := hq.two_le
  have hp3 : 3 ≤ p := by omega
  have hq3 : 3 ≤ q := by omega
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  set c := Nat.chineseRemainder hcop 1 (q - 1) with hc
  have ha1 : (c : ℕ) ≡ 1 [MOD p] := c.2.1
  have ha2 : (c : ℕ) ≡ q - 1 [MOD q] := c.2.2
  have hane0 : (c : ℕ) ≠ 0 := by
    intro h
    rw [h] at ha1
    have : p ∣ 1 - 0 := (Nat.modEq_iff_dvd' (by omega)).mp ha1
    have := Nat.le_of_dvd (by omega) this
    omega
  have hane1 : (c : ℕ) ≠ 1 := by
    intro h
    rw [h] at ha2
    have hle : (1 : ℕ) ≤ q - 1 := by omega
    have hdvd : q ∣ (q - 1) - 1 := (Nat.modEq_iff_dvd' hle).mp ha2
    have := Nat.le_of_dvd (by omega) hdvd
    omega
  have ha1lt : 1 < (c : ℕ) := by omega
  refine ⟨(c : ℕ), ha1lt, ?_, ?_⟩
  · exact Nat.chineseRemainder_lt_mul hcop 1 (q - 1) (by omega) (by omega)
  · have hmp : (c : ℕ) ^ M ≡ 1 [MOD p] := by
      calc (c : ℕ) ^ M ≡ 1 ^ M [MOD p] := ha1.pow M
        _ = 1 := one_pow M
    have hmq : (c : ℕ) ^ M ≡ 1 [MOD q] := by
      have h1 : (c : ℕ) ^ M ≡ (q - 1) ^ M [MOD q] := ha2.pow M
      have h2 : (q - 1) ^ M ≡ 1 [MOD q - 1 + 1] := pow_even_modEq_one (by omega) hM
      have hq1 : q - 1 + 1 = q := by omega
      rw [hq1] at h2
      exact h1.trans h2
    have hmod : (c : ℕ) ^ M ≡ 1 [MOD p * q] := (Nat.modEq_and_modEq_iff_modEq_mul hcop).mp ⟨hmp, hmq⟩
    have hone : 1 ≤ (c : ℕ) ^ M := Nat.one_le_pow _ _ (by omega)
    exact Nat.gcd_eq_right ((Nat.modEq_iff_dvd' hone).mp hmod.symm)

/-- **Theorem 2 (robustness).**  At the exponent `M = p-1`, where the power sum reveals
the factor `q`, Pollard's `p-1` step admits a bad base that reveals nothing.  The power
sum carries no base parameter, so it has no analogue of this failure mode. -/
theorem powerSum_robust_vs_pollard {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    Nat.gcd (powerSum (p * q) (p - 1)) (p * q) = q ∧
      ∃ a : ℕ, 1 < a ∧ a < p * q ∧ Nat.gcd (a ^ (p - 1) - 1) (p * q) = p * q :=
  ⟨gcd_powerSum_eq_factor hp hq hpq hdvd,
    exists_pollard_bad_base hp hq hpq hp2 hq2 (hp.even_sub_one hp2)⟩

end PowerSumGCD