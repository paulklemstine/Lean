import Mathlib
import Combinatorics.PowerSumFactorReveal
import Combinatorics.PowerSumCarmichaelPeriod

/-!
# The coprime-restricted power sum: an exact criterion, and why it is not an improvement

A natural attempt to strengthen the power-sum reveal is to sum only over the *units*,
`F*(N,k) = ∑_{a ≤ N, gcd(a,N)=1} a^k`, mimicking Euler's theorem instead of Fermat's.
This file settles what that variant does for a semiprime `N = pq`.

Modulo `p` the multiples of `p` contribute nothing and the multiples of `q` contribute
`q^k · ∑_{x ∈ ZMod p} x^k`, so

`F*(pq, k) ≡ (q − q^k) · ∑_{x ∈ ZMod p} x^k  (mod p)`  (`cast_coprimeSum`),

whence the exact criterion (`prime_dvd_coprimeSum_iff`)

`p ∣ F*(pq, k) ↔ ((p−1) ∤ k ∨ p ∣ q − 1)`.

Comparing with `prime_dvd_powerSum_iff`, the unit-restricted sum is divisible by `p` in
*strictly more* cases, so its gcd is *larger*: it reveals **less**, not more.  The concrete
witness `p = 3, q = 7, k = 2` is proved in `coprime_variant_strictly_worse`: the full power
sum returns the factor `7`, the coprime-restricted sum returns the useless value `21`.
-/

namespace PowerSumReveal

open Finset

/-- `F*(N,k) = ∑_{a ≤ N, gcd(a,N) = 1} a^k`. -/
def coprimeSum (N k : ℕ) : ℕ :=
  ∑ a ∈ (Finset.Icc 1 N).filter (fun a => Nat.Coprime a N), a ^ k

/-- Summing a function over the multiples of `p` in `[1, p m]` is summing it over `[1, m]`
after scaling by `p`. -/
theorem sum_multiples {M : Type*} [AddCommMonoid M] {p : ℕ} (hp : 0 < p) (m : ℕ) (f : ℕ → M) :
    ∑ a ∈ (Finset.Icc 1 (p * m)).filter (fun a => p ∣ a), f a = ∑ j ∈ Finset.Icc 1 m, f (p * j) := by
  refine (Finset.sum_nbij' (i := fun j => p * j) (j := fun a => a / p) ?_ ?_ ?_ ?_ ?_).symm
  · intro j hj
    simp only [Finset.mem_Icc] at hj
    simp only [Finset.mem_filter, Finset.mem_Icc]
    exact ⟨⟨by nlinarith [hj.1], by nlinarith [hj.2]⟩, ⟨j, rfl⟩⟩
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_Icc] at ha
    obtain ⟨⟨h1, h2⟩, c, hc⟩ := ha
    subst hc
    simp only [Finset.mem_Icc, Nat.mul_div_cancel_left _ hp]
    constructor
    · rcases Nat.eq_zero_or_pos c with rfl | h
      · omega
      · exact h
    · exact Nat.le_of_mul_le_mul_left h2 hp
  · intro j hj
    exact Nat.mul_div_cancel_left _ hp
  · intro a ha
    simp only [Finset.mem_filter] at ha
    exact Nat.mul_div_cancel' ha.2
  · intro j _
    rfl

/-- Membership in the coprime part of `[1, pq]`. -/
theorem coprime_semiprime_iff {p q a : ℕ} (hp : p.Prime) (hq : q.Prime) :
    Nat.Coprime a (p * q) ↔ (¬ p ∣ a ∧ ¬ q ∣ a) := by
  have h1 : Nat.Coprime a p ↔ ¬ p ∣ a := by
    rw [Nat.coprime_comm]
    exact hp.coprime_iff_not_dvd
  have h2 : Nat.Coprime a q ↔ ¬ q ∣ a := by
    rw [Nat.coprime_comm]
    exact hq.coprime_iff_not_dvd
  rw [Nat.coprime_mul_iff_right, h1, h2]

/-- **Local formula for the coprime-restricted sum.**  Modulo `p`,
`F*(pq,k) ≡ (q − q^k) · ∑_{x ∈ ZMod p} x^k`. -/
theorem cast_coprimeSum {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hk : k ≠ 0) :
    ((coprimeSum (p * q) k : ℕ) : ZMod p)
      = ((q : ZMod p) - (q : ZMod p) ^ k) * (if (p - 1) ∣ k then (-1 : ZMod p) else 0) := by
  haveI : Fact p.Prime := ⟨hp⟩
  classical
  set T : Finset ℕ := Finset.Icc 1 (p * q) with hT
  set g : ℕ → ZMod p := fun a => ((a : ℕ) : ZMod p) ^ k with hgdef
  -- the coprime part, described by the two non-divisibility conditions
  have hSet : T.filter (fun a => Nat.Coprime a (p * q))
      = (T.filter (fun a => ¬ p ∣ a)).filter (fun a => ¬ q ∣ a) := by
    rw [Finset.filter_filter]
    exact Finset.filter_congr (fun a _ => by
      simp [coprime_semiprime_iff hp hq])
  have hcast : ((coprimeSum (p * q) k : ℕ) : ZMod p)
      = ∑ a ∈ T.filter (fun a => Nat.Coprime a (p * q)), g a := by
    simp [coprimeSum, hT, hgdef]
  -- split off the multiples of p
  have e1 : ∑ a ∈ T, g a
      = ∑ a ∈ T.filter (fun a => p ∣ a), g a + ∑ a ∈ T.filter (fun a => ¬ p ∣ a), g a :=
    (Finset.sum_filter_add_sum_filter_not T _ g).symm
  -- split the non-multiples of p according to divisibility by q
  have e2 : ∑ a ∈ T.filter (fun a => ¬ p ∣ a), g a
      = ∑ a ∈ (T.filter (fun a => ¬ p ∣ a)).filter (fun a => q ∣ a), g a
        + ∑ a ∈ (T.filter (fun a => ¬ p ∣ a)).filter (fun a => ¬ q ∣ a), g a :=
    (Finset.sum_filter_add_sum_filter_not _ _ g).symm
  -- split the multiples of q according to divisibility by p
  have e3 : ∑ a ∈ T.filter (fun a => q ∣ a), g a
      = ∑ a ∈ (T.filter (fun a => q ∣ a)).filter (fun a => p ∣ a), g a
        + ∑ a ∈ (T.filter (fun a => q ∣ a)).filter (fun a => ¬ p ∣ a), g a :=
    (Finset.sum_filter_add_sum_filter_not _ _ g).symm
  have hcomm : (T.filter (fun a => ¬ p ∣ a)).filter (fun a => q ∣ a)
      = (T.filter (fun a => q ∣ a)).filter (fun a => ¬ p ∣ a) := by
    rw [Finset.filter_filter, Finset.filter_filter]
    exact Finset.filter_congr (fun a _ => by tauto)
  -- the three auxiliary sums
  have hmulp : ∑ a ∈ T.filter (fun a => p ∣ a), g a = 0 := by
    rw [hT, sum_multiples hp.pos q g]
    refine Finset.sum_eq_zero ?_
    intro j _
    simp [hgdef, hk]
  have hmulpq : ∑ a ∈ (T.filter (fun a => q ∣ a)).filter (fun a => p ∣ a), g a = 0 := by
    have hset : (T.filter (fun a => q ∣ a)).filter (fun a => p ∣ a) = T.filter (fun a => p ∣ a) ∩ T.filter (fun a => q ∣ a) := by
      rw [Finset.filter_filter]
      ext a
      simp [Finset.mem_filter, and_comm, and_assoc, and_left_comm]
    have : ∀ a ∈ (T.filter (fun a => q ∣ a)).filter (fun a => p ∣ a), g a = 0 := by
      intro a ha
      rw [Finset.filter_filter, Finset.mem_filter] at ha
      obtain ⟨_, hqa, hpa⟩ := ha
      obtain ⟨c, hc⟩ := hpa
      simp [hgdef, hc, hk]
    exact Finset.sum_eq_zero this
  have hmulq : ∑ a ∈ T.filter (fun a => q ∣ a), g a
      = (q : ZMod p) ^ k * ((powerSum p k : ℕ) : ZMod p) := by
    have hTq : T = Finset.Icc 1 (q * p) := by rw [hT, mul_comm]
    rw [hTq, sum_multiples hq.pos p g, powerSum]
    push_cast
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl ?_
    intro j _
    simp [hgdef, mul_pow]
  -- the total sum
  have htotal : ∑ a ∈ T, g a = ((powerSum (p * q) k : ℕ) : ZMod p) := by
    simp [hT, hgdef, powerSum]
  have hS : ((powerSum p k : ℕ) : ZMod p) = (if (p - 1) ∣ k then (-1 : ZMod p) else 0) := by
    rw [cast_powerSum p p k hp dvd_rfl hk, Nat.div_self hp.pos, one_smul]
  have hN : ((powerSum (p * q) k : ℕ) : ZMod p)
      = (q : ZMod p) * (if (p - 1) ∣ k then (-1 : ZMod p) else 0) := by
    rw [cast_powerSum (p * q) p k hp ⟨q, rfl⟩ hk, Nat.mul_div_cancel_left _ hp.pos, nsmul_eq_mul]
  rw [hcast, hSet]
  have hfinal : ∑ a ∈ (T.filter (fun a => ¬ p ∣ a)).filter (fun a => ¬ q ∣ a), g a
      = ∑ a ∈ T, g a - ∑ a ∈ T.filter (fun a => p ∣ a), g a
        - ∑ a ∈ T.filter (fun a => q ∣ a), g a
        + ∑ a ∈ (T.filter (fun a => q ∣ a)).filter (fun a => p ∣ a), g a := by
    rw [e1, e2, hcomm, e3]
    ring
  rw [hfinal, hmulp, hmulpq, hmulq, htotal, hN, hS]
  ring

/-- **Exact criterion for the coprime-restricted sum.**  For distinct primes `p, q` and
`k ≥ 1`: `p ∣ F*(pq, k) ↔ ((p−1) ∤ k ∨ p ∣ q − 1)`. -/
theorem prime_dvd_coprimeSum_iff {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : k ≠ 0) : p ∣ coprimeSum (p * q) k ↔ (¬ (p - 1) ∣ k ∨ p ∣ (q - 1)) := by
  haveI : Fact p.Prime := ⟨hp⟩
  rw [← ZMod.natCast_eq_zero_iff (coprimeSum (p * q) k) p, cast_coprimeSum hp hq hk]
  by_cases hd : (p - 1) ∣ k
  · have hqne : (q : ZMod p) ≠ 0 := by
      intro h
      exact hpq (((Nat.prime_dvd_prime_iff_eq hp hq).mp ((ZMod.natCast_eq_zero_iff q p).mp h)))
    have hferm : (q : ZMod p) ^ k = 1 := by
      obtain ⟨c, hc⟩ := hd
      rw [hc, pow_mul, ZMod.pow_card_sub_one_eq_one hqne, one_pow]
    simp only [hd, if_true, not_true_eq_false, false_or, hferm]
    have hq1 : ((q - 1 : ℕ) : ZMod p) = (q : ZMod p) - 1 := by
      have := hq.two_le
      push_cast [Nat.cast_sub (by omega : 1 ≤ q)]
      ring
    rw [← ZMod.natCast_eq_zero_iff (q - 1) p, hq1]
    constructor
    · intro h
      have : ((q : ZMod p) - 1) * (-1 : ZMod p) = 0 := h
      have h2 : ((q : ZMod p) - 1) = 0 := by
        have := mul_eq_zero.mp this
        rcases this with h' | h'
        · exact h'
        · exact absurd h' (by norm_num)
      exact h2
    · intro h
      rw [h]
      ring
  · simp [hd]

/-- Divisibility of the coprime-restricted sum by the *other* prime, by symmetry. -/
theorem prime_dvd_coprimeSum_iff' {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : k ≠ 0) : q ∣ coprimeSum (p * q) k ↔ (¬ (q - 1) ∣ k ∨ q ∣ (p - 1)) := by
  rw [show p * q = q * p from mul_comm p q]
  exact prime_dvd_coprimeSum_iff hq hp (Ne.symm hpq) hk

/-- **The coprime-restricted variant reveals less.**  Whenever `p ∣ q − 1`, the prime `p`
divides `F*(pq,k)` for *every* `k ≥ 1`, including the exponents `(p−1) ∣ k` at which the full
power sum excludes `p`.  So the reveal gcd of the coprime variant is always at least as large
as that of the full sum, and strictly larger at those exponents. -/
theorem coprimeSum_reveals_less {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : k ≠ 0) (hdvd : p ∣ (q - 1)) :
    p ∣ coprimeSum (p * q) k :=
  (prime_dvd_coprimeSum_iff hp hq hpq hk).mpr (Or.inr hdvd)

/-- **A concrete failure of the coprime variant.**  For `N = 21 = 3·7` and `k = 2` the full
power sum reveals the factor `7`, while the coprime-restricted sum returns `21`, i.e. nothing:
restricting to units is a strict loss. -/
theorem coprime_variant_strictly_worse :
    revealGcd 21 2 = 7 ∧ Nat.gcd (coprimeSum 21 2) 21 = 21 := by
  have h3 : Nat.Prime 3 := by norm_num
  have h7 : Nat.Prime 7 := by norm_num
  have hpq : (3 : ℕ) ≠ 7 := by norm_num
  constructor
  · have := powerSum_reveal h3 h7 hpq (by decide)
    simpa [revealGcd] using this
  · have hd3 : (3 : ℕ) ∣ coprimeSum (3 * 7) 2 :=
      (prime_dvd_coprimeSum_iff h3 h7 hpq (by norm_num)).mpr (Or.inr (by norm_num))
    have hd7 : (7 : ℕ) ∣ coprimeSum (3 * 7) 2 :=
      (prime_dvd_coprimeSum_iff' h3 h7 hpq (by norm_num)).mpr (Or.inl (by decide))
    have := gcd_two_primes h3 h7 hpq (coprimeSum (3 * 7) 2)
    norm_num [hd3, hd7] at this ⊢
    simpa using this

end PowerSumReveal