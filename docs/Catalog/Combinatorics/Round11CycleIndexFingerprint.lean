/-
# Round-11 Closures, Part I: the cycle-index fingerprint and its Möbius spectrum

Formal companion to the round-11 negative-results synthesis
(`29_Round11_Closures.md`, hypotheses **CIFINGER** / **CFSIGMA**).

For a semiprime `N = p * q` and a base `b` coprime to `N`, the *cycle-index
fingerprint* is
```
F(c) = gcd (b ^ c - 1) N .
```
The paper asserts three things about it, all of which are proved here in full:

* **Structure.** `F(c) = p^[ord_p b ∣ c] * q^[ord_q b ∣ c]`
  (`Round11.fpr_eq_indicator`).
* **The order seal.** `F(c) = 1` for every `0 < c < min (ord_p b) (ord_q b)`, and
  `F` first becomes informative exactly at `d* = min (ord_p b) (ord_q b)`
  (`Round11.fpr_eq_one_of_lt_dstar`, `Round11.one_lt_fpr_dstar`).
* **The Möbius spectrum.** The Möbius transform of the `p`-adic valuation of the
  fingerprint is the *exact indicator of the multiplicative order*:
  `∑_{c ∣ d} μ(d/c) · v_p(F c) = [ord_p b = d]`
  (`Round11.mobFinger_eq_indicator`).  Consequently the Möbius spectrum is
  supported on the two-element set `{ord_p b, ord_q b}`
  (`Round11.mobFinger_eq_zero_of_lt_dstar`): the Möbius structure is genuine but
  relocates no information below the order scale.

The last consequence is the formal content of the CFSIGMA closure: below the
order scale the fingerprint is a *constant* function of the instance, hence its
fibres cannot separate any secret statistic (see Part III).
-/
import Mathlib

namespace Round11

open ArithmeticFunction Finset

/-! ## The fingerprint -/

/-- The cycle-index fingerprint `F(c) = gcd (b^c - 1) N`. -/
def fpr (b N c : ℕ) : ℕ := Nat.gcd (b ^ c - 1) N

/-- The multiplicative order of `b` modulo a prime `p`. -/
noncomputable def ordAt (b p : ℕ) : ℕ := orderOf (b : ZMod p)

/-! ## Basic arithmetic of the fingerprint -/

/-- Divisibility of `b^c - 1` by a prime `p` is detected by the order of `b`. -/
theorem prime_dvd_pow_sub_one_iff {p b : ℕ} (hp : p.Prime) (hb : 1 ≤ b) (c : ℕ) :
    p ∣ b ^ c - 1 ↔ ordAt b p ∣ c := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcast : ((b ^ c - 1 : ℕ) : ZMod p) = (b : ZMod p) ^ c - 1 := by
    have h1 : 1 ≤ b ^ c := Nat.one_le_pow _ _ hb
    push_cast [Nat.cast_sub h1]
    ring
  rw [ordAt, ← ZMod.natCast_eq_zero_iff (b ^ c - 1) p, hcast, sub_eq_zero,
    ← orderOf_dvd_iff_pow_eq_one]

/-- The gcd of a number with a prime is the prime or one. -/
theorem gcd_prime_eq {p m : ℕ} (hp : p.Prime) :
    Nat.gcd m p = if p ∣ m then p else 1 := by
  split
  · next h => exact Nat.gcd_eq_right h
  · next h => exact Nat.Coprime.gcd_eq_one (((hp.coprime_iff_not_dvd).2 h).symm)

/-- **Structure of the fingerprint.**  For a semiprime `N = p*q` with `b` coprime
to `N`, `F(c) = p^[ord_p b ∣ c] · q^[ord_q b ∣ c]`. -/
theorem fpr_eq_indicator {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (c : ℕ) :
    fpr b (p * q) c =
      (if ordAt b p ∣ c then p else 1) * (if ordAt b q ∣ c then q else 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  rw [fpr, Nat.Coprime.gcd_mul _ hcop, gcd_prime_eq hp, gcd_prime_eq hq,
    if_congr (prime_dvd_pow_sub_one_iff hp hb c) rfl rfl,
    if_congr (prime_dvd_pow_sub_one_iff hq hb c) rfl rfl]

/-- The order of `b` mod a prime `p` not dividing `b` is positive. -/
theorem ordAt_pos {p b : ℕ} (hp : p.Prime) (hbp : ¬ p ∣ b) : 0 < ordAt b p := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hb0 : (b : ZMod p) ≠ 0 := by
    simpa [ZMod.natCast_eq_zero_iff] using hbp
  have hpow : (b : ZMod p) ^ (p - 1) = 1 := ZMod.pow_card_sub_one_eq_one hb0
  have hdvd : ordAt b p ∣ p - 1 := orderOf_dvd_iff_pow_eq_one.2 hpow
  rcases Nat.eq_zero_or_pos (ordAt b p) with h | h
  · exfalso
    rw [h] at hdvd
    have := Nat.eq_zero_of_zero_dvd hdvd
    have := hp.two_le
    omega
  · exact h

/-! ## The order seal: no information below `d* = min (ord_p b) (ord_q b)` -/

/-- **The order seal.** Below the order scale the fingerprint is identically `1`:
it is a constant function of the instance `(p, q, b)`. -/
theorem fpr_eq_one_of_lt_dstar {p q b c : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hb : 1 ≤ b) (hc : 0 < c) (hlt : c < min (ordAt b p) (ordAt b q)) :
    fpr b (p * q) c = 1 := by
  have hnp : ¬ ordAt b p ∣ c := fun h =>
    absurd (Nat.le_of_dvd hc h) (by omega)
  have hnq : ¬ ordAt b q ∣ c := fun h =>
    absurd (Nat.le_of_dvd hc h) (by omega)
  rw [fpr_eq_indicator hp hq hpq hb c, if_neg hnp, if_neg hnq, one_mul]

/-- **Informative entry at the order scale.** At `d* = min (ord_p b) (ord_q b)`
the fingerprint is a nontrivial factor of `N`. -/
theorem one_lt_fpr_dstar {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) :
    1 < fpr b (p * q) (min (ordAt b p) (ordAt b q)) := by
  rw [fpr_eq_indicator hp hq hpq hb]
  rcases le_total (ordAt b p) (ordAt b q) with h | h
  · have : min (ordAt b p) (ordAt b q) = ordAt b p := min_eq_left h
    rw [this, if_pos dvd_rfl]
    have := hp.two_le
    rcases (by split <;> simp : (if ordAt b q ∣ ordAt b p then q else 1) = q ∨
        (if ordAt b q ∣ ordAt b p then q else 1) = 1) with h' | h' <;> rw [h']
    · nlinarith [hq.two_le]
    · omega
  · have : min (ordAt b p) (ordAt b q) = ordAt b q := min_eq_right h
    rw [this, if_pos dvd_rfl]
    have := hq.two_le
    rcases (by split <;> simp : (if ordAt b p ∣ ordAt b q then p else 1) = p ∨
        (if ordAt b p ∣ ordAt b q then p else 1) = 1) with h' | h' <;> rw [h']
    · nlinarith [hp.two_le]
    · omega

/-- The nontrivial value at the order scale is a proper divisor of `N`, i.e. the
fingerprint really splits `N` there (it is `p`, `q`, or — in the degenerate case
`ord_p b = ord_q b` — all of `N`). -/
theorem fpr_dvd (b p q c : ℕ) : fpr b (p * q) c ∣ p * q := Nat.gcd_dvd_right _ _

/-- **An oracle for the order scale factors `N`.**  Whenever the two orders
differ, the fingerprint evaluated at `d* = min (ord_p b) (ord_q b)` is a *proper
nontrivial* divisor of `N`: reaching the order scale is the same thing as
factoring.  This is the positive half of the CIFINGER dichotomy — nothing below
`d*`, everything at `d*`. -/
theorem fpr_dstar_splits {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hbp : ¬ p ∣ b) (hbq : ¬ q ∣ b) (hne : ordAt b p ≠ ordAt b q) :
    1 < fpr b (p * q) (min (ordAt b p) (ordAt b q)) ∧
      fpr b (p * q) (min (ordAt b p) (ordAt b q)) < p * q ∧
      fpr b (p * q) (min (ordAt b p) (ordAt b q)) ∣ p * q := by
  have hp0 : 0 < ordAt b p := ordAt_pos hp hbp
  have hq0 : 0 < ordAt b q := ordAt_pos hq hbq
  refine ⟨one_lt_fpr_dstar hp hq hpq hb, ?_, fpr_dvd _ _ _ _⟩
  rw [fpr_eq_indicator hp hq hpq hb]
  rcases lt_or_gt_of_ne hne with h | h
  · have hmin : min (ordAt b p) (ordAt b q) = ordAt b p := min_eq_left h.le
    have hnd : ¬ ordAt b q ∣ ordAt b p := fun hdvd =>
      absurd (Nat.le_of_dvd hp0 hdvd) (by omega)
    rw [hmin, if_pos dvd_rfl, if_neg hnd, mul_one]
    exact lt_mul_of_one_lt_right hp.pos hq.one_lt
  · have hmin : min (ordAt b p) (ordAt b q) = ordAt b q := min_eq_right h.le
    have hnd : ¬ ordAt b p ∣ ordAt b q := fun hdvd =>
      absurd (Nat.le_of_dvd hq0 hdvd) (by omega)
    rw [hmin, if_pos dvd_rfl, if_neg hnd, one_mul]
    exact lt_mul_of_one_lt_left hq.pos hp.one_lt

/-! ## The Möbius spectrum -/

/-- The `p`-adic valuation of the fingerprint is the divisibility indicator of the
order of `b` mod `p`. -/
theorem fpr_factorization {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (c : ℕ) :
    (fpr b (p * q) c).factorization p = if ordAt b p ∣ c then 1 else 0 := by
  rw [fpr_eq_indicator hp hq hpq hb c]
  by_cases h1 : ordAt b p ∣ c <;> by_cases h2 : ordAt b q ∣ c <;>
    simp [h1, h2, Nat.factorization_mul hp.ne_zero hq.ne_zero,
      hp.factorization, hq.factorization, hpq]

/-- The Möbius transform of the `p`-valuation of the fingerprint (the
"per-coefficient" cycle-index object `M_d` of CIFINGER). -/
def mobFinger (p b N d : ℕ) : ℤ :=
  ∑ c ∈ d.divisors, moebius (d / c) * (((fpr b N c).factorization p : ℕ) : ℤ)

/-- Sum of the Möbius function over the divisors of `n`. -/
theorem sum_divisors_moebius (n : ℕ) :
    ∑ d ∈ n.divisors, moebius d = if n = 1 then 1 else 0 := by
  have h : ((moebius * ↑zeta : ArithmeticFunction ℤ)) n = (1 : ArithmeticFunction ℤ) n := by
    rw [moebius_mul_coe_zeta]
  rwa [ArithmeticFunction.coe_mul_zeta_apply, ArithmeticFunction.one_apply] at h

/-- **Möbius detection.** The Möbius transform of the divisibility indicator of a
positive integer `k` is the indicator of `k = d`. -/
theorem mob_detect (k d : ℕ) (hk : 0 < k) (hd : 0 < d) :
    ∑ c ∈ d.divisors, moebius (d / c) * (if k ∣ c then (1:ℤ) else 0)
      = if k = d then 1 else 0 := by
  have hd0 : d ≠ 0 := hd.ne'
  rw [← Nat.sum_div_divisors d (fun c => moebius (d / c) * (if k ∣ c then (1:ℤ) else 0))]
  have step1 : ∑ j ∈ d.divisors, moebius (d / (d / j)) * (if k ∣ d / j then (1:ℤ) else 0)
      = ∑ j ∈ d.divisors, moebius j * (if k ∣ d / j then (1:ℤ) else 0) :=
    Finset.sum_congr rfl (fun j hj => by
      rw [Nat.div_div_self (Nat.dvd_of_mem_divisors hj) hd0])
  rw [step1]
  by_cases hkd : k ∣ d
  · obtain ⟨e, he⟩ := hkd
    have he0 : 0 < e := by
      rcases Nat.eq_zero_or_pos e with h | h
      · simp [h] at he; omega
      · exact h
    have key : ∀ j ∈ d.divisors, (if k ∣ d / j then (1:ℤ) else 0) = (if j ∣ e then 1 else 0) := by
      intro j hj
      have hjd := Nat.dvd_of_mem_divisors hj
      have hj0 : 0 < j := Nat.pos_of_mem_divisors hj
      have hiff : (k ∣ d / j) ↔ j ∣ e := by
        constructor
        · rintro ⟨t, ht⟩
          have hdj : d = j * (k * t) := by rw [← ht, Nat.mul_div_cancel' hjd]
          refine ⟨t, ?_⟩
          have : k * e = k * (j * t) := by rw [← he, hdj]; ring
          exact Nat.eq_of_mul_eq_mul_left hk this
        · rintro ⟨t, ht⟩
          refine ⟨t, ?_⟩
          rw [he, ht, show k * (j * t) = j * (k * t) by ring, Nat.mul_div_cancel_left _ hj0]
      simp [hiff]
    rw [Finset.sum_congr rfl (fun j hj => by rw [key j hj])]
    have hfilter : d.divisors.filter (fun j => j ∣ e) = e.divisors := by
      ext j
      simp only [Finset.mem_filter, Nat.mem_divisors]
      constructor
      · rintro ⟨⟨_, _⟩, hje⟩; exact ⟨hje, he0.ne'⟩
      · rintro ⟨hje, _⟩
        exact ⟨⟨hje.trans ⟨k, by rw [he]; ring⟩, hd0⟩, hje⟩
    simp only [mul_ite, mul_one, mul_zero, ← Finset.sum_filter]
    rw [hfilter, sum_divisors_moebius e]
    have hee : (e = 1) ↔ (k = d) := by
      constructor
      · rintro rfl; omega
      · rintro rfl; nlinarith
    simp [hee]
  · have hz : ∀ j ∈ d.divisors, moebius j * (if k ∣ d / j then (1:ℤ) else 0) = 0 := by
      intro j hj
      have hjd := Nat.dvd_of_mem_divisors hj
      have : ¬ k ∣ d / j := fun h => hkd (h.trans (Nat.div_dvd_of_dvd hjd))
      simp [this]
    rw [Finset.sum_congr rfl hz, Finset.sum_const_zero]
    have : k ≠ d := by rintro rfl; exact hkd dvd_rfl
    simp [this]

/-- **The Möbius spectrum of the cycle-index fingerprint is the order indicator.**
This is the sharpest form of the spectral wall: `M_d ≠ 0` for exactly one value of
`d`, namely `d = ord_p b`. -/
theorem mobFinger_eq_indicator {p q b d : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hb : 1 ≤ b) (hbp : ¬ p ∣ b) (hd : 0 < d) :
    mobFinger p b (p * q) d = if ordAt b p = d then 1 else 0 := by
  rw [mobFinger]
  have h : ∀ c ∈ d.divisors,
      moebius (d / c) * (((fpr b (p * q) c).factorization p : ℕ) : ℤ)
        = moebius (d / c) * (if ordAt b p ∣ c then (1:ℤ) else 0) := by
    intro c _
    rw [fpr_factorization hp hq hpq hb c]
    by_cases hcc : ordAt b p ∣ c <;> simp [hcc]
  rw [Finset.sum_congr rfl h, mob_detect _ _ (ordAt_pos hp hbp) hd]

/-- The **`N`-computable** Möbius coefficient of the paper: `M_d` built directly
from the fingerprint *values* (no knowledge of `p` is needed to evaluate it). -/
def mobRaw (b N d : ℕ) : ℤ :=
  ∑ c ∈ d.divisors, moebius (d / c) * ((fpr b N c : ℕ) : ℤ)

/-- **The `N`-computable Möbius coefficients are instance-independent below the
order scale.**  For `0 < d < d*` the coefficient `M_d` equals `[d = 1]` — the
same value for every semiprime and every base.  This is CIFINGER in the form the
attacker actually has access to. -/
theorem mobRaw_eq_of_lt_dstar {p q b d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hd : 0 < d) (hlt : d < min (ordAt b p) (ordAt b q)) :
    mobRaw b (p * q) d = if d = 1 then 1 else 0 := by
  have hcongr : ∀ c ∈ d.divisors,
      moebius (d / c) * ((fpr b (p * q) c : ℕ) : ℤ) = moebius (d / c) := by
    intro c hc
    have hcd : c ∣ d := Nat.dvd_of_mem_divisors hc
    have hc0 : 0 < c := Nat.pos_of_mem_divisors hc
    have hcle : c ≤ d := Nat.le_of_dvd hd hcd
    rw [fpr_eq_one_of_lt_dstar hp hq hpq hb hc0 (by omega)]
    simp
  rw [mobRaw, Finset.sum_congr rfl hcongr, Nat.sum_div_divisors d (fun c => moebius c),
    sum_divisors_moebius d]

/-- **The complete raw Möbius spectrum.**  The `N`-computable coefficients of the
cycle-index fingerprint are supported on the four points `1`, `ord_p b`,
`ord_q b` and `ord_N b = lcm (ord_p b) (ord_q b)`, with masses `1`, `p-1`, `q-1`
and `(p-1)(q-1) = φ(N)`:
```
M_d = [d = 1] + (p-1)[ord_p b = d] + (q-1)[ord_q b = d] + φ(N)[ord_N b = d].
```
This is the sharpest form of the spectral wall: the Möbius structure is genuine,
but every nonzero coefficient sits at the order scale. -/
theorem mobRaw_eq {p q b d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hbp : ¬ p ∣ b) (hbq : ¬ q ∣ b) (hd : 0 < d) :
    mobRaw b (p * q) d
      = (if d = 1 then 1 else 0)
        + ((p : ℤ) - 1) * (if ordAt b p = d then 1 else 0)
        + ((q : ℤ) - 1) * (if ordAt b q = d then 1 else 0)
        + ((p : ℤ) - 1) * ((q : ℤ) - 1) *
            (if Nat.lcm (ordAt b p) (ordAt b q) = d then 1 else 0) := by
  have hdp := ordAt_pos hp hbp
  have hdq := ordAt_pos hq hbq
  have hn0 : 0 < Nat.lcm (ordAt b p) (ordAt b q) := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff]; omega)
  have pointwise : ∀ c, ((fpr b (p * q) c : ℕ) : ℤ)
      = 1 + ((p:ℤ) - 1) * (if ordAt b p ∣ c then 1 else 0)
        + ((q:ℤ) - 1) * (if ordAt b q ∣ c then 1 else 0)
        + ((p:ℤ) - 1) * ((q:ℤ) - 1) *
            (if Nat.lcm (ordAt b p) (ordAt b q) ∣ c then 1 else 0) := by
    intro c
    have hiff : (ordAt b p ∣ c ∧ ordAt b q ∣ c) ↔ Nat.lcm (ordAt b p) (ordAt b q) ∣ c :=
      ⟨fun h => Nat.lcm_dvd h.1 h.2,
       fun h => ⟨(Nat.dvd_lcm_left _ _).trans h, (Nat.dvd_lcm_right _ _).trans h⟩⟩
    rw [fpr_eq_indicator hp hq hpq hb c]
    by_cases h1 : ordAt b p ∣ c
    · by_cases h2 : ordAt b q ∣ c
      · simp only [if_pos h1, if_pos h2, if_pos (hiff.1 ⟨h1, h2⟩)]
        push_cast
        ring
      · simp only [if_pos h1, if_neg h2, if_neg (fun h => h2 (hiff.2 h).2)]
        push_cast
        ring
    · by_cases h2 : ordAt b q ∣ c
      · simp only [if_neg h1, if_pos h2, if_neg (fun h => h1 (hiff.2 h).1)]
        push_cast
        ring
      · simp only [if_neg h1, if_neg h2, if_neg (fun h => h1 (hiff.2 h).1)]
        push_cast
        ring
  rw [mobRaw]
  have hsplit : ∀ c ∈ d.divisors, moebius (d / c) * ((fpr b (p * q) c : ℕ) : ℤ)
      = moebius (d/c) * (if (1:ℕ) ∣ c then (1:ℤ) else 0)
        + ((p:ℤ)-1) * (moebius (d/c) * (if ordAt b p ∣ c then (1:ℤ) else 0))
        + ((q:ℤ)-1) * (moebius (d/c) * (if ordAt b q ∣ c then (1:ℤ) else 0))
        + ((p:ℤ)-1) * ((q:ℤ)-1) *
            (moebius (d/c) * (if Nat.lcm (ordAt b p) (ordAt b q) ∣ c then (1:ℤ) else 0)) := by
    intro c _
    rw [pointwise c]
    simp only [one_dvd, if_true]
    ring
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib, Finset.sum_add_distrib,
    Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum,
    mob_detect 1 d one_pos hd, mob_detect _ d hdp hd, mob_detect _ d hdq hd,
    mob_detect _ d hn0 hd]
  simp [eq_comm]

/-- **CIFINGER, closed.**  The Möbius spectrum vanishes identically below the
order scale `d* = min (ord_p b) (ord_q b)`: the per-coefficient spectral object
carries no information before the `√N`-sized order threshold. -/
theorem mobFinger_eq_zero_of_lt_dstar {p q b d : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hb : 1 ≤ b) (hbp : ¬ p ∣ b) (hbq : ¬ q ∣ b)
    (hd : 0 < d) (hlt : d < min (ordAt b p) (ordAt b q)) :
    mobFinger p b (p * q) d = 0 ∧ mobFinger q b (p * q) d = 0 := by
  constructor
  · rw [mobFinger_eq_indicator hp hq hpq hb hbp hd, if_neg (by omega)]
  · rw [mul_comm p q,
      mobFinger_eq_indicator hq hp (Ne.symm hpq) hb hbq hd, if_neg (by omega)]

/-- **The spectrum is a unit point mass.**  Summing the Möbius spectrum over a
window `1 ≤ d ≤ D` detects whether the order has been reached: the total mass is
`1` exactly when `ord_p b ≤ D`, and `0` otherwise.  All of the information in the
cycle-index object is this single point mass at the order scale. -/
theorem sum_mobFinger_Icc {p q b D : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hbp : ¬ p ∣ b) :
    ∑ d ∈ Finset.Icc 1 D, mobFinger p b (p * q) d = if ordAt b p ≤ D then 1 else 0 := by
  have hcongr : ∀ d ∈ Finset.Icc 1 D,
      mobFinger p b (p * q) d = if ordAt b p = d then (1 : ℤ) else 0 := by
    intro d hd
    exact mobFinger_eq_indicator hp hq hpq hb hbp (by simpa using (Finset.mem_Icc.1 hd).1)
  rw [Finset.sum_congr rfl hcongr, Finset.sum_ite_eq (Finset.Icc 1 D) (ordAt b p) (fun _ => (1:ℤ))]
  have hmem : (ordAt b p ∈ Finset.Icc 1 D) ↔ (ordAt b p ≤ D) := by
    rw [Finset.mem_Icc]
    have := ordAt_pos hp hbp
    omega
  simp [hmem]

/-- **The first informative coefficient is exactly `d*`.**  The least index at
which the fingerprint is nontrivial is `min (ord_p b) (ord_q b)`. -/
theorem isLeast_informative_index {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hbp : ¬ p ∣ b) (hbq : ¬ q ∣ b) :
    IsLeast {c | 0 < c ∧ 1 < fpr b (p * q) c} (min (ordAt b p) (ordAt b q)) := by
  constructor
  · exact ⟨lt_min (ordAt_pos hp hbp) (ordAt_pos hq hbq), one_lt_fpr_dstar hp hq hpq hb⟩
  · rintro c ⟨hc0, hc1⟩
    by_contra hlt
    push_neg at hlt
    rw [fpr_eq_one_of_lt_dstar hp hq hpq hb hc0 hlt] at hc1
    exact absurd hc1 (lt_irrefl 1)

end Round11