/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# QUBIT-TRADE3, cycle 2: the sharp criterion for period-certificate factoring

`Bridges.QubitTradeFactorExtraction` established the two horns of the experimental dichotomy on
the constructed population (equal orders ⇒ permanently unlucky; mixed 2-adic roles ⇒ splitting).
This file sharpens both horns into a single *iff*, valid for an arbitrary base modulo an
arbitrary odd semiprime:

> a period certificate of `a` modulo `N = p * q` can ever produce a factor **iff** the 2-adic
> valuations of the two per-prime orders differ.

Equality of the orders is therefore *not* the true cause of permanent unluckiness: equality of
their 2-adic valuations is, and that is a strictly weaker (hence strictly more often satisfied)
condition. On the constructed population the two conditions coincide, which is why the measured
per-`N` cap tracked the equal-order share.

## Main results

* `QubitTrade.dvd_of_two_adic_eq` — the odd-part transfer lemma behind the general cap.
* `QubitTrade.unlucky_cap_of_two_adic_eq` — equal 2-adic valuations cap every certificate.
* `QubitTrade.not_splitsAt_of_gcd_trivial` — a trivial gcd is not a factorization.
* `QubitTrade.exists_splitting_certificate_of_two_adic_lt` — unequal valuations produce an
  explicit certificate that splits `N`.
* `QubitTrade.splits_iff_two_adic_ne` — **the sharp criterion**, an exact characterization of the
  bases from which Shor's classical post-processing can ever extract a factor.
-/

import Mathlib
import Bridges.QubitTradeFactorExtraction

namespace QubitTrade

variable {a p q : ℕ}

/-- **Odd-part transfer.** If two orders share the 2-adic part `2 ^ k` and the first divides `m`
while the second divides `2 * m`, then the second divides `m` as well. -/
theorem dvd_of_two_adic_eq {k u v m : ℕ} (hv : Odd v)
    (h1 : 2 ^ k * u ∣ m) (h2 : 2 ^ k * v ∣ 2 * m) : 2 ^ k * v ∣ m := by
  have hv2 : ¬ (2 ∣ v) := by rw [Nat.odd_iff] at hv; omega
  have hcop2v : Nat.Coprime 2 v := (Nat.prime_two.coprime_iff_not_dvd).mpr hv2
  have hvdvd : v ∣ 2 * m := dvd_trans (Dvd.intro_left (2 ^ k) rfl) h2
  have hvm : v ∣ m := (Nat.Coprime.dvd_of_dvd_mul_left hcop2v.symm hvdvd)
  have h2k : 2 ^ k ∣ m := dvd_trans (Dvd.intro u rfl) h1
  exact Nat.Coprime.mul_dvd_of_dvd_of_dvd (Nat.Coprime.pow_left _ hcop2v) h2k hvm

/-- **The general unlucky cap.** If the two per-prime orders of the base have the *same* 2-adic
valuation, then every halved even period of `a` modulo `N` is `± 1` modulo the whole of `N`, so
no measurement outcome can ever split `N`. -/
theorem unlucky_cap_of_two_adic_eq (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    {k u v : ℕ} (hu : Odd u) (hv : Odd v)
    (hdp : ordMod a p = 2 ^ k * u) (hdq : ordMod a q = 2 ^ k * v) {m : ℕ}
    (hm : ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1) :
    ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m - 1 ∨ ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m + 1 := by
  have hNp : (p : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 := dvd_trans ⟨(q : ℤ), by push_cast; ring⟩ hm
  have hNq : (q : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 := dvd_trans ⟨(p : ℤ), by push_cast; ring⟩ hm
  have hp2m : ordMod a p ∣ 2 * m :=
    pow_eq_one_iff_ordMod_dvd.mp (int_dvd_pow_sub_one_iff.mp hNp)
  have hq2m : ordMod a q ∣ 2 * m :=
    pow_eq_one_iff_ordMod_dvd.mp (int_dvd_pow_sub_one_iff.mp hNq)
  refine unlucky_cap_of_dvd_iff hp hq hpq ⟨fun h => ?_, fun h => ?_⟩ hm
  · rw [hdq]
    exact dvd_of_two_adic_eq hv (hdp ▸ h) (hdq ▸ hq2m)
  · rw [hdp]
    exact dvd_of_two_adic_eq hu (hdq ▸ h) (hdp ▸ hp2m)

/-- A trivial gcd is not a factorization of `N = p * q`. -/
theorem not_splitsAt_of_gcd_trivial (hp : p.Prime) (hq : q.Prime) {m : ℕ}
    (h : Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = 1 ∨
      Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = p * q) :
    ¬ SplitsAt a p q m := by
  intro hsplit
  have h2p : p * 2 ≤ p * q := Nat.mul_le_mul_left p hq.two_le
  have h2q : q * 2 ≤ q * p := Nat.mul_le_mul_left q hp.two_le
  have hcomm : q * p = p * q := Nat.mul_comm q p
  rw [hcomm] at h2q
  have hp2' := hp.two_le
  have hq2' := hq.two_le
  rcases h with h | h <;> rcases hsplit with h' | h' <;> omega

/-- **Unequal 2-adic valuations always split.** If the order modulo `p` carries strictly more
factors of `2` than the order modulo `q`, the halved exact order of `a` modulo `N` is a genuine
period certificate whose gcd returns the factor `q`. -/
theorem exists_splitting_certificate_of_two_adic_lt (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    {i j u v : ℕ} (hu : Odd u) (hv : Odd v) (hji : j < i)
    (hdp : ordMod a p = 2 ^ i * u) (hdq : ordMod a q = 2 ^ j * v) :
    ∃ m : ℕ, ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 ∧
      Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = q := by
  set L : ℕ := Nat.lcm (ordMod a p) (ordMod a q) with hL
  have hdvdp : ordMod a p ∣ L := Nat.dvd_lcm_left _ _
  have hdvdq : ordMod a q ∣ L := Nat.dvd_lcm_right _ _
  have h2L : 2 ∣ L := by
    refine dvd_trans ?_ hdvdp
    rw [hdp]
    exact Dvd.dvd.mul_right (dvd_pow_self 2 (by omega)) u
  refine ⟨L / 2, ?_, ?_⟩
  · rw [Nat.mul_div_cancel' h2L]
    exact semiprime_dvd_pow_sub_one hp hq hpq hdvdp hdvdq
  · exact gcd_half_lcm_eq_prime_of_two_adic_lt hp hu hv hji hdp hdq

/-- **The sharp criterion.** For an odd semiprime `N = p * q` and a base `a` whose per-prime
multiplicative orders factor as `2 ^ i * u` and `2 ^ j * v` with `u, v` odd, a period certificate
of `a` can produce a nontrivial factor of `N` **iff** `i ≠ j`.

Both directions are uniform in the measurement outcome: the negative direction rules out *every*
exponent (so no sample budget helps), and the positive direction exhibits an explicit splitting
exponent (so one lucky sample suffices). This is the exact boundary of the per-`N` cap measured
by the fungibility-ramp experiment. -/
theorem splits_iff_two_adic_ne (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) {i j u v : ℕ} (hu : Odd u) (hv : Odd v)
    (hdp : ordMod a p = 2 ^ i * u) (hdq : ordMod a q = 2 ^ j * v) :
    (∃ m : ℕ, ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 ∧ SplitsAt a p q m) ↔ i ≠ j := by
  constructor
  · rintro ⟨m, hm, hsplit⟩ rfl
    exact not_splitsAt_of_gcd_trivial hp hq
      (gcd_trivial_of_cap hp hq hp2 hq2
        (unlucky_cap_of_two_adic_eq hp hq hpq hu hv hdp hdq hm)) hsplit
  · intro hne
    rcases lt_or_gt_of_ne hne with hlt | hlt
    · -- the order modulo `q` carries more factors of `2`; the gcd returns `p`
      obtain ⟨m, hm, hgcd⟩ :=
        exists_splitting_certificate_of_two_adic_lt (a := a) (p := q) (q := p)
          hq hp (Ne.symm hpq) hv hu hlt hdq hdp
      rw [Nat.mul_comm q p] at hm hgcd
      exact ⟨m, hm, Or.inl hgcd⟩
    · obtain ⟨m, hm, hgcd⟩ :=
        exists_splitting_certificate_of_two_adic_lt hp hq hpq hu hv hlt hdp hdq
      exact ⟨m, hm, Or.inr hgcd⟩

/-- Every positive order factors as a power of two times an odd number, so the sharp criterion
applies to every base of positive order: the set of bases usable for factoring `N` is exactly the
set whose two per-prime orders have different 2-adic valuations. -/
theorem exists_two_adic_decomposition : ∀ {d : ℕ}, 0 < d → ∃ i u : ℕ, Odd u ∧ d = 2 ^ i * u := by
  intro d
  induction d using Nat.strong_induction_on with
  | _ d ih =>
    intro hd
    rcases Nat.even_or_odd d with he | ho
    · obtain ⟨c, rfl⟩ := he
      obtain ⟨i, u, hu, hcu⟩ := ih c (by omega) (by omega)
      exact ⟨i + 1, u, hu, by rw [hcu]; ring⟩
    · exact ⟨0, d, ho, by ring⟩

/-! ### Re-drawing the base removes the cap -/

/-- The multiplicative order modulo `p` only depends on the residue class. -/
theorem ordMod_congr {b c p : ℕ} (h : b ≡ c [MOD p]) : ordMod b p = ordMod c p := by
  unfold ordMod
  rw [(ZMod.natCast_eq_natCast_iff b c p).mpr h]

/-- **Base re-drawing defeats the structural cap.** For every odd semiprime `N = p * q` with
distinct prime factors there exists a base `a` and an exponent `m` such that `2 * m` is a period
of `a` modulo `N` whose halved power splits `N`.

So the per-`N` cap measured by the experiment is a property of the *fixed* base, not of the
modulus: the classical step of re-drawing the base — unavailable to the fixed-base sampling model
whose ramp saturates — always escapes the unlucky half. The witness is the CRT combination of a
primitive root modulo `p` with the trivial residue modulo `q`. -/
theorem exists_splitting_base {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    ∃ a m : ℕ, ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 ∧ SplitsAt a p q m := by
  haveI := Fact.mk hp
  obtain ⟨g, hg⟩ := exists_orderOf_eq_of_dvd_sub_one (r := p - 1) hp dvd_rfl
  set b : ℕ := ((g : ZMod p)).val with hb
  have hbcast : ((b : ℕ) : ZMod p) = (g : ZMod p) := by
    rw [hb]; simp [ZMod.natCast_val, ZMod.cast_id]
  have hordb : ordMod b p = p - 1 := by
    unfold ordMod
    rw [hbcast, orderOf_units, hg]
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  obtain ⟨a, ha1, ha2⟩ := Nat.chineseRemainder hcop b 1
  have hordp : ordMod a p = p - 1 := by rw [ordMod_congr ha1, hordb]
  have hordq : ordMod a q = 1 := by
    rw [ordMod_congr ha2]
    unfold ordMod
    simp
  -- the order modulo `p` is even, the order modulo `q` is odd: the valuations differ
  have hppos : 0 < p - 1 := by have := hp.two_le; omega
  obtain ⟨i, u, hu, hiu⟩ := exists_two_adic_decomposition hppos
  have hi0 : i ≠ 0 := by
    intro h
    rw [h, pow_zero, one_mul] at hiu
    have hpodd : Odd p := hp.odd_of_ne_two hp2
    rw [Nat.odd_iff] at hu hpodd
    have := hp.two_le
    omega
  have hsharp := splits_iff_two_adic_ne (a := a) (i := i) (j := 0) (u := u) (v := 1)
    hp hq hpq hp2 hq2 hu odd_one (by rw [hordp, hiu]) (by rw [hordq]; norm_num)
  obtain ⟨m, hm, hsplit⟩ := hsharp.mpr hi0
  exact ⟨a, m, hm, hsplit⟩

end QubitTrade