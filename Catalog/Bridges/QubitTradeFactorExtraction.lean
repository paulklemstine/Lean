/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# QUBIT-TRADE3: period certificates, factor extraction, and the per-modulus unlucky cap

This file formalizes the *arithmetic* half of the "fungibility ramp survives contact with
factors" experiment: what a period certificate for a base `a` modulo a semiprime `N = p * q`
can and cannot reveal about the factors of `N`.

The experiment constructs semiprimes with *controlled multiplicative orders*: primes
`p ≡ 1 [MOD r]`, an element of exact order `d_p ∣ r` obtained by projection
`h ^ ((p-1)/d_p)`, and a base `a` obtained by CRT from per-prime bases of orders
`d_p, d_q ∈ {r, r/2}`. The measured dichotomy (100% of trials, see `ComputationalEvidence.md`)
is that the pair `(d_p, d_q)` alone decides everything:

* `d_p = d_q` ⇒ **no** even period certificate for `a` ever splits `N`
  (`gcd_certificate_trivial_of_orderOf_eq`), the *permanently unlucky* base; and
* `v₂(d_p) ≠ v₂(d_q)` ⇒ the halved exact order of `a` **always** splits `N`
  (`gcd_half_lcm_eq_prime_of_two_adic_lt`).

This is precisely the per-`N` structural cap that no number of measurement samples can move:
the quantum sampling stage only ever produces multiples of the order of `a`, and the theorems
below quantify over *all* such exponents.

## Main definitions

* `QubitTrade.ordMod` — the multiplicative order of `a` modulo a prime `p`.
* `QubitTrade.SplitsAt` — the exponent `m` yields a nontrivial factor of `N` via `gcd(aᵐ-1, N)`.

## Main results

* `QubitTrade.unlucky_cap` — equal per-prime orders force `N ∣ aᵐ - 1` or `N ∣ aᵐ + 1`
  for every halved even period.
* `QubitTrade.gcd_certificate_trivial_of_orderOf_eq` — hence every period certificate gives a
  trivial gcd: the unlucky cap is structural, independent of the number of samples.
* `QubitTrade.gcd_eq_prime_of_dvd_of_not_dvd` — the splitting criterion.
* `QubitTrade.lcm_two_pow_mul_odd` — `lcm (2^i u) (2^j v) = 2^i * lcm u v` for odd `u, v`, `j ≤ i`.
* `QubitTrade.gcd_half_lcm_eq_prime_of_two_adic_lt` — unequal 2-adic valuations of the two
  per-prime orders make the halved exact order split `N`.
* `QubitTrade.controlled_order_dichotomy` — the population dichotomy for `d_p, d_q ∈ {2u, u}`
  with `u` odd: a factor is extracted exactly when the two orders differ.
* `QubitTrade.orderOf_projection` — correctness of the projection construction of an element of
  prescribed order.
-/

import Mathlib

namespace QubitTrade

/-- The multiplicative order of `a` in `ZMod p`. For `p` prime with `p ∤ a` this is the usual
multiplicative order: the quantity the period-finding subroutine estimates. -/
noncomputable def ordMod (a p : ℕ) : ℕ := orderOf ((a : ZMod p))

section Basic

variable {a p : ℕ}

/-- A period certificate modulo `p`, in integer form. -/
lemma int_dvd_pow_sub_one_iff {m : ℕ} :
    ((p : ℤ) ∣ (a : ℤ) ^ m - 1) ↔ ((a : ZMod p)) ^ m = 1 := by
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  constructor
  · intro h; linear_combination h
  · intro h; rw [h]; ring

lemma int_dvd_pow_add_one_iff {m : ℕ} :
    ((p : ℤ) ∣ (a : ℤ) ^ m + 1) ↔ ((a : ZMod p)) ^ m = -1 := by
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  constructor
  · intro h; linear_combination h
  · intro h; rw [h]; ring

lemma pow_eq_one_iff_ordMod_dvd {m : ℕ} :
    ((a : ZMod p)) ^ m = 1 ↔ ordMod a p ∣ m :=
  orderOf_dvd_iff_pow_eq_one.symm

/-- Square roots of unity modulo a prime are `±1`: the arithmetic heart of Shor's factoring
step. -/
lemma pow_eq_one_or_neg_one (hp : p.Prime) {m : ℕ}
    (h : (p : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1) :
    ((a : ZMod p)) ^ m = 1 ∨ ((a : ZMod p)) ^ m = -1 := by
  haveI := Fact.mk hp
  have h1 : ((a : ZMod p)) ^ (2 * m) = 1 := int_dvd_pow_sub_one_iff.mp h
  have h2 : ((a : ZMod p)) ^ m * ((a : ZMod p)) ^ m = 1 := by
    rw [← pow_add, two_mul] at *
    exact h1
  exact mul_self_eq_one_iff.mp h2

end Basic

section UnluckyCap

variable {a p q : ℕ}

private lemma coprime_int_of_primes (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    IsCoprime (p : ℤ) (q : ℤ) := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  simpa using (Nat.coprime_primes hp hq).mpr hpq

/-- A common period of the two per-prime orders is a period modulo the semiprime. -/
theorem semiprime_dvd_pow_sub_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {m : ℕ}
    (h1 : ordMod a p ∣ m) (h2 : ordMod a q ∣ m) :
    ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m - 1 := by
  have hcast : ((p * q : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by push_cast; ring
  rw [hcast]
  exact (coprime_int_of_primes hp hq hpq).mul_dvd
    (int_dvd_pow_sub_one_iff.mpr (pow_eq_one_iff_ordMod_dvd.mpr h1))
    (int_dvd_pow_sub_one_iff.mpr (pow_eq_one_iff_ordMod_dvd.mpr h2))

/-- **The unlucky cap.** If the base `a` has the *same* multiplicative order modulo both prime
factors of `N = p * q`, then for every even period `2 * m` of `a` modulo `N` the halved power
`a ^ m` is congruent to `1` or to `-1` modulo the whole of `N`. Both branches are useless for
factoring: the failure is a property of the base, not of the measurement budget. -/
theorem unlucky_cap_of_dvd_iff (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {m : ℕ}
    (hdvd_iff : ordMod a p ∣ m ↔ ordMod a q ∣ m)
    (hm : ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1) :
    ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m - 1 ∨ ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m + 1 := by
  have hcop := coprime_int_of_primes hp hq hpq
  have hNp : (p : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 :=
    dvd_trans ⟨(q : ℤ), by push_cast; ring⟩ hm
  have hNq : (q : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 :=
    dvd_trans ⟨(p : ℤ), by push_cast; ring⟩ hm
  have hx := pow_eq_one_or_neg_one hp hNp
  have hy := pow_eq_one_or_neg_one hq hNq
  have hiff : ((a : ZMod p)) ^ m = 1 ↔ ((a : ZMod q)) ^ m = 1 := by
    rw [pow_eq_one_iff_ordMod_dvd, pow_eq_one_iff_ordMod_dvd]; exact hdvd_iff
  have hcast : ((p * q : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by push_cast; ring
  by_cases h1 : ((a : ZMod p)) ^ m = 1
  · left
    rw [hcast]
    exact hcop.mul_dvd (int_dvd_pow_sub_one_iff.mpr h1)
      (int_dvd_pow_sub_one_iff.mpr (hiff.mp h1))
  · right
    have hx' : ((a : ZMod p)) ^ m = -1 := hx.resolve_left h1
    have hy' : ((a : ZMod q)) ^ m = -1 := hy.resolve_left fun h => h1 (hiff.mpr h)
    rw [hcast]
    exact hcop.mul_dvd (int_dvd_pow_add_one_iff.mpr hx') (int_dvd_pow_add_one_iff.mpr hy')

/-- **The unlucky cap for equal orders.** If the base has the same multiplicative order modulo
both prime factors, every halved even period is `±1` modulo the whole of `N`. -/
theorem unlucky_cap (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (heq : ordMod a p = ordMod a q) {m : ℕ}
    (hm : ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1) :
    ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m - 1 ∨ ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m + 1 :=
  unlucky_cap_of_dvd_iff hp hq hpq (by rw [heq]) hm

/-- The gcd form of the unlucky cap: *every* period certificate of an equal-order base returns a
trivial gcd, so no amount of sampling can extract a factor from such a base. -/
theorem gcd_trivial_of_cap (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) {m : ℕ}
    (hcap : ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m - 1 ∨ ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ m + 1) :
    Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = 1 ∨
      Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = p * q := by
  rcases hcap with h | h
  · right
    have := Int.gcd_eq_natAbs_right_iff_dvd.mpr h
    simpa using this
  · left
    have hodd : ¬ (2 ∣ p * q) := by
      intro h2
      rcases (Nat.Prime.dvd_mul Nat.prime_two).mp h2 with h2 | h2
      · exact hp2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).mp h2).symm
      · exact hq2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hq).mp h2).symm
    set g : ℕ := Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) with hg
    have hg1 : (g : ℤ) ∣ (a : ℤ) ^ m - 1 := Int.gcd_dvd_left _ _
    have hg2 : (g : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right _ _
    have hg3 : (g : ℤ) ∣ (a : ℤ) ^ m + 1 := dvd_trans hg2 h
    have hg4 : (g : ℤ) ∣ 2 := by
      have := dvd_sub hg3 hg1
      simpa using this
    have hgn : g ∣ 2 := by exact_mod_cast hg4
    have hgpq : g ∣ p * q := by exact_mod_cast hg2
    rcases (Nat.dvd_prime Nat.prime_two).mp hgn with h' | h'
    · exact h'
    · exact absurd (h' ▸ hgpq) hodd

/-- Every period certificate of an equal-order base returns a trivial gcd, so no amount of
sampling can extract a factor from such a base. -/
theorem gcd_certificate_trivial_of_orderOf_eq (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (heq : ordMod a p = ordMod a q) {m : ℕ}
    (hm : ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1) :
    Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = 1 ∨
      Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = p * q :=
  gcd_trivial_of_cap hp hq hp2 hq2 (unlucky_cap hp hq hpq heq hm)

end UnluckyCap

section Splitting

variable {a p q : ℕ}

/-- The exponent `m` splits `N = p * q` through the period certificate: the classical gcd step
returns a nontrivial factor. -/
def SplitsAt (a p q m : ℕ) : Prop :=
  Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = p ∨
    Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = q

/-- **The splitting criterion.** If the order of `a` modulo `p` divides the exponent `m` but the
order modulo `q` does not, then the gcd returns exactly `p`. -/
theorem gcd_eq_prime_of_dvd_of_not_dvd (hq : q.Prime)
    {m : ℕ} (h1 : ordMod a p ∣ m) (h2 : ¬ ordMod a q ∣ m) :
    Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = p := by
  set g : ℕ := Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) with hg
  have hpdvd : (p : ℤ) ∣ (a : ℤ) ^ m - 1 :=
    int_dvd_pow_sub_one_iff.mpr (pow_eq_one_iff_ordMod_dvd.mpr h1)
  have hqnot : ¬ ((q : ℤ) ∣ (a : ℤ) ^ m - 1) := fun hc =>
    h2 (pow_eq_one_iff_ordMod_dvd.mp (int_dvd_pow_sub_one_iff.mp hc))
  have hgpq : g ∣ p * q := by
    have : (g : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hpg : p ∣ g := by
    refine Nat.dvd_gcd (Int.natCast_dvd.mp hpdvd) ?_
    simpa using ⟨q, rfl⟩
  have hqg : ¬ q ∣ g := by
    intro hc
    exact hqnot (dvd_trans (Int.natCast_dvd_natCast.mpr hc) (Int.gcd_dvd_left _ _))
  have hcop : Nat.Coprime g q := (hq.coprime_iff_not_dvd.mpr hqg).symm
  exact Nat.dvd_antisymm (hcop.dvd_of_dvd_mul_right hgpq) hpg

private lemma odd_lcm {u v : ℕ} (hu : Odd u) (hv : Odd v) : Odd (Nat.lcm u v) := by
  have hdvd : Nat.lcm u v ∣ u * v := Nat.lcm_dvd (Dvd.intro v rfl) (Dvd.intro_left u rfl)
  rw [Nat.odd_iff] at hu hv ⊢
  by_contra hc
  have h2 : (2 : ℕ) ∣ Nat.lcm u v := by omega
  have : (2 : ℕ) ∣ u * v := h2.trans hdvd
  rcases (Nat.Prime.dvd_mul Nat.prime_two).mp this with h | h <;> omega

/-- For odd `u, v` and `j ≤ i`, the 2-adic part of the lcm is the larger 2-adic part. -/
theorem lcm_two_pow_mul_odd {i j u v : ℕ} (hu : Odd u) (hv : Odd v) (hji : j ≤ i) :
    Nat.lcm (2 ^ i * u) (2 ^ j * v) = 2 ^ i * Nat.lcm u v := by
  have hlcm_odd : Odd (Nat.lcm u v) := odd_lcm hu hv
  have hcop : Nat.Coprime (2 ^ i) (Nat.lcm u v) :=
    Nat.Coprime.pow_left _ ((Nat.prime_two.coprime_iff_not_dvd).mpr
      (by rw [Nat.odd_iff] at hlcm_odd; omega))
  refine Nat.dvd_antisymm (Nat.lcm_dvd ?_ ?_) (hcop.mul_dvd_of_dvd_of_dvd ?_ ?_)
  · exact Nat.mul_dvd_mul_left _ (Nat.dvd_lcm_left u v)
  · exact Nat.mul_dvd_mul (pow_dvd_pow 2 hji) (Nat.dvd_lcm_right u v)
  · exact dvd_trans (Dvd.intro u rfl) (Nat.dvd_lcm_left _ _)
  · exact Nat.lcm_dvd (dvd_trans (Dvd.intro_left (2 ^ i) rfl) (Nat.dvd_lcm_left _ _))
      (dvd_trans (Dvd.intro_left (2 ^ j) rfl) (Nat.dvd_lcm_right _ _))

/-- The halved exact order is divisible by the smaller-valuation order and not by the larger:
the exponent that separates the two primes. -/
theorem half_lcm_dvd_and_not_dvd {i j u v : ℕ} (hu : Odd u) (hv : Odd v) (hji : j < i) :
    (2 ^ j * v ∣ Nat.lcm (2 ^ i * u) (2 ^ j * v) / 2) ∧
      ¬ (2 ^ i * u ∣ Nat.lcm (2 ^ i * u) (2 ^ j * v) / 2) := by
  obtain ⟨i', rfl⟩ : ∃ i', i = i' + 1 := ⟨i - 1, by omega⟩
  have hlcm := lcm_two_pow_mul_odd hu hv hji.le
  have hlcm_odd : Odd (Nat.lcm u v) := odd_lcm hu hv
  have hhalf : Nat.lcm (2 ^ (i' + 1) * u) (2 ^ j * v) / 2 = 2 ^ i' * Nat.lcm u v := by
    rw [hlcm]
    refine Nat.div_eq_of_eq_mul_left (by norm_num) ?_
    rw [pow_succ]; ring
  refine ⟨?_, ?_⟩
  · rw [hhalf]
    exact Nat.mul_dvd_mul (pow_dvd_pow 2 (by omega)) (Nat.dvd_lcm_right u v)
  · rw [hhalf]
    intro hc
    have h2i : (2 : ℕ) ^ (i' + 1) ∣ 2 ^ i' * Nat.lcm u v := dvd_trans (Dvd.intro u rfl) hc
    rw [pow_succ] at h2i
    have hpos : (0 : ℕ) < 2 ^ i' := pow_pos (by norm_num) _
    have h2 : (2 : ℕ) ∣ Nat.lcm u v := (Nat.mul_dvd_mul_iff_left hpos).mp h2i
    rw [Nat.odd_iff] at hlcm_odd
    omega

/-- Symmetric form of the splitting criterion: when it is the order modulo `q` that divides the
exponent, the gcd returns exactly `q`. -/
theorem gcd_eq_prime_of_dvd_of_not_dvd' (hp : p.Prime)
    {m : ℕ} (h1 : ordMod a q ∣ m) (h2 : ¬ ordMod a p ∣ m) :
    Int.gcd ((a : ℤ) ^ m - 1) ((p * q : ℕ) : ℤ) = q := by
  have h := gcd_eq_prime_of_dvd_of_not_dvd (a := a) (p := q) (q := p) hp h1 h2
  rwa [Nat.mul_comm q p] at h

/-- **Mixed 2-adic roles always split.** If the two per-prime orders of the base have different
2-adic valuations, the halved exact order of `a` modulo `N` is an exponent at which the classical
gcd step returns a prime factor of `N`. -/
theorem gcd_half_lcm_eq_prime_of_two_adic_lt (hp : p.Prime) {i j u v : ℕ}
    (hu : Odd u) (hv : Odd v) (hji : j < i)
    (hdp : ordMod a p = 2 ^ i * u) (hdq : ordMod a q = 2 ^ j * v) :
    Int.gcd ((a : ℤ) ^ (Nat.lcm (ordMod a p) (ordMod a q) / 2) - 1) ((p * q : ℕ) : ℤ) = q := by
  obtain ⟨hdvd, hnot⟩ := half_lcm_dvd_and_not_dvd hu hv hji
  rw [hdp, hdq]
  exact gcd_eq_prime_of_dvd_of_not_dvd' hp (by rw [hdq]; exact hdvd)
    (by rw [hdp]; exact hnot)

end Splitting

section Dichotomy

variable {a p q : ℕ}

/-- **The controlled-order dichotomy.** For the constructed population — per-prime orders drawn
from `{2u, u}` with `u` odd, i.e. `r = 2u` and `r/2 = u` — the outcome of the whole
period-finding pipeline is decided by the pair of orders alone:

* equal orders: *no* even period certificate ever splits `N` (permanently unlucky base); and
* different orders: the exponent `u` already splits `N`.

The first horn is the per-`N` cap that no sample budget can move; the second is the event whose
probability the fungibility ramp measures. -/
theorem controlled_order_dichotomy (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) {u : ℕ} (hu : Odd u)
    (hdp : ordMod a p = 2 * u ∨ ordMod a p = u)
    (hdq : ordMod a q = 2 * u ∨ ordMod a q = u) :
    (ordMod a p = ordMod a q →
        ∀ m : ℕ, ((p * q : ℕ) : ℤ) ∣ (a : ℤ) ^ (2 * m) - 1 → ¬ SplitsAt a p q m) ∧
      (ordMod a p ≠ ordMod a q → SplitsAt a p q u) := by
  have hu0 : 0 < u := hu.pos
  have hnotdvd : ¬ (2 * u ∣ u) := fun hc => by
    have := Nat.le_of_dvd hu0 hc; omega
  constructor
  · intro heq m hm hsplit
    have htriv := gcd_certificate_trivial_of_orderOf_eq hp hq hpq hp2 hq2 heq hm
    have h2p : p * 2 ≤ p * q := Nat.mul_le_mul_left p hq.two_le
    have h2q : q * 2 ≤ q * p := Nat.mul_le_mul_left q hp.two_le
    have hcomm : q * p = p * q := Nat.mul_comm q p
    rw [hcomm] at h2q
    have hp2' := hp.two_le
    have hq2' := hq.two_le
    rcases htriv with h | h <;> rcases hsplit with h' | h' <;> omega
  · intro hne
    rcases hdp with hdp | hdp <;> rcases hdq with hdq | hdq
    · exact absurd (hdp.trans hdq.symm) hne
    · exact Or.inr (gcd_eq_prime_of_dvd_of_not_dvd' hp (by rw [hdq]) (by rw [hdp]; exact hnotdvd))
    · exact Or.inl (gcd_eq_prime_of_dvd_of_not_dvd hq (by rw [hdp]) (by rw [hdq]; exact hnotdvd))
    · exact absurd (hdp.trans hdq.symm) hne

/-- A single instance of the controlled-order construction: a semiprime `p * q` with odd `p, q`
and a base `a` whose per-prime multiplicative orders are drawn from `{r, r/2} = {2u, u}` with
`u` odd. -/
structure ControlledInstance where
  /-- the base -/
  a : ℕ
  /-- the first prime factor -/
  p : ℕ
  /-- the second prime factor -/
  q : ℕ
  /-- the odd half-order `r/2` -/
  u : ℕ
  hp : p.Prime
  hq : q.Prime
  hpq : p ≠ q
  hp2 : p ≠ 2
  hq2 : q ≠ 2
  hu : Odd u
  hdp : ordMod a p = 2 * u ∨ ordMod a p = u
  hdq : ordMod a q = 2 * u ∨ ordMod a q = u

namespace ControlledInstance

variable (I : ControlledInstance)

/-- The base plays *mixed roles*: its orders modulo the two primes differ. -/
def Mixed : Prop := ordMod I.a I.p ≠ ordMod I.a I.q

/-- A period certificate: `2 * m` is a period of the base modulo `N = p * q`. -/
def IsPeriodHalf (m : ℕ) : Prop := ((I.p * I.q : ℕ) : ℤ) ∣ (I.a : ℤ) ^ (2 * m) - 1

/-- **Extractability is exactly mixedness.** Some period certificate of the base yields a factor
of `N` if and only if the two per-prime orders differ. The right-to-left direction exhibits the
explicit splitting exponent `u`; the left-to-right direction is the unlucky cap, and it holds for
every exponent, i.e. for every possible measurement outcome and every sample budget. -/
theorem extractable_iff_mixed :
    (∃ m : ℕ, I.IsPeriodHalf m ∧ SplitsAt I.a I.p I.q m) ↔ I.Mixed := by
  obtain ⟨d, h⟩ := (controlled_order_dichotomy I.hp I.hq I.hpq I.hp2 I.hq2 I.hu I.hdp I.hdq)
  constructor
  · rintro ⟨m, hm, hsplit⟩
    by_contra hmix
    exact d (not_not.mp hmix) m hm hsplit
  · intro hmix
    refine ⟨I.u, ?_, h hmix⟩
    have hdvd : ∀ k : ℕ, (k = 2 * I.u ∨ k = I.u) → k ∣ 2 * I.u := by
      rintro k (rfl | rfl)
      · exact dvd_rfl
      · exact ⟨2, by ring⟩
    exact semiprime_dvd_pow_sub_one I.hp I.hq I.hpq (hdvd _ I.hdp) (hdvd _ I.hdq)

end ControlledInstance

end Dichotomy

section Construction

/-- **Correctness of the projection construction.** In a finite group, projecting a generator by
the cofactor exponent produces an element of exactly the prescribed order. This is the step the
experiment uses to build bases of controlled order `d ∣ p - 1`. -/
theorem orderOf_projection {G : Type*} [Group G] [Finite G] (g : G) {d : ℕ}
    (hd : d ∣ orderOf g) : orderOf (g ^ (orderOf g / d)) = d := by
  have hpos : 0 < orderOf g := orderOf_pos g
  rw [orderOf_pow]
  rw [Nat.gcd_eq_right (Nat.div_dvd_of_dvd hd)]
  exact Nat.div_div_self hd hpos.ne'

/-- **Prescribed orders exist modulo `p ≡ 1 [MOD r]`.** For every divisor `r` of `p - 1` the unit
group modulo the prime `p` contains an element of exact order `r`: this is why the experiment can
choose its primes as `p = k * r + 1` and then realise any per-prime order dividing `r`. -/
theorem exists_orderOf_eq_of_dvd_sub_one {p r : ℕ} (hp : p.Prime) (hr : r ∣ p - 1) :
    ∃ g : (ZMod p)ˣ, orderOf g = r := by
  haveI := Fact.mk hp
  obtain ⟨h, hh⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := (ZMod p)ˣ)
  have hcard : Nat.card (ZMod p)ˣ = p - 1 := by
    simp [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hp]
  rw [hcard] at hh
  exact ⟨h ^ ((p - 1) / r), by rw [← hh] at hr ⊢; exact orderOf_projection h hr⟩

end Construction

end QubitTrade