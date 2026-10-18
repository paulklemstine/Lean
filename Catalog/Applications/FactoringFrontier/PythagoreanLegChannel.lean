import Mathlib
import Bridges.BerggrenTrees.BerggrenPythagoreanCore
import Cryptography.FactoringBarriers.CongruenceOfSquares

/-!
# The Pythagorean channel is a coordinate gcd — and it is circular

The campaign closed the Pythagorean / Berggren route with the verdict "the
non-circular channel is a coordinate gcd".  This file makes the *leg* version of
that verdict an exact theorem, for **every** `N > 1` (no semiprime hypothesis):

* `leg_triple_gcd_nontrivial`: if `N^2 + b^2 = c^2` with `b > 0` and the triple
  is not the trivial one (`c - b ≠ 1`), then `gcd(c - b, N)` is a nontrivial
  divisor of `N` (in the sense of `FactoringBarriers.NontrivialDivisor`).
  So *every* information-bearing triple with leg `N` hands over a factor through
  a single gcd.
* `trivial_leg_triple`: the trivial triple `c - b = 1` exists for every odd `N`
  and carries no information.
* `leg_triple_of_factorization`: conversely, every factorization `N = d·e` with
  `1 < d < e`, `d ≡ e (mod 2)` produces a nontrivial leg triple with
  `c - b = d^2`.
* `composite_iff_nontrivial_leg_triple`: for odd `N > 1`,
  `N` is composite ⇔ `N` is a leg of a nontrivial Pythagorean triple.

Hence locating a nontrivial triple on leg `N` (by Berggren descent or any
other means) is *equivalent* to factoring `N`: the channel is circular.  The
statements are phrased with the catalog predicate `IsPythag`.
-/

namespace FactoringFrontier.PythagoreanLeg

open FactoringBarriers

/-- In a triple `N^2 + b^2 = c^2` (naturals), `(c - b)(c + b) = N^2` and `b ≤ c`. -/
theorem leg_factor_identity {N b c : ℕ} (h : IsPythag (N : ℤ) (b : ℤ) (c : ℤ)) :
    b ≤ c ∧ (c - b) * (c + b) = N ^ 2 := by
  unfold IsPythag at h
  have hbc : b ≤ c := by
    have : (b : ℤ) ^ 2 ≤ (c : ℤ) ^ 2 := by nlinarith
    exact_mod_cast (pow_le_pow_iff_left₀ (by positivity) (by positivity) two_ne_zero).1 this
  refine ⟨hbc, ?_⟩
  have : ((c - b : ℕ) : ℤ) * ((c + b : ℕ) : ℤ) = ((N ^ 2 : ℕ) : ℤ) := by
    push_cast [Nat.cast_sub hbc]
    linear_combination -h
  exact_mod_cast this

/-- **The channel is a coordinate gcd (every `N > 1`).**  A Pythagorean triple
with leg `N`, positive second leg, and `c - b ≠ 1` reveals a nontrivial divisor
of `N` as `gcd(c - b, N)`. -/
theorem leg_triple_gcd_nontrivial {N b c : ℕ} (hN : 1 < N) (hb : 0 < b)
    (h : IsPythag (N : ℤ) (b : ℤ) (c : ℤ)) (hnt : c - b ≠ 1) :
    NontrivialDivisor N (Nat.gcd (c - b) N) := by
  obtain ⟨hbc, hid⟩ := leg_factor_identity h
  set u := c - b with hu
  set v := c + b with hv
  have huv : u < v := by omega
  have hu0 : 0 < u := by
    rcases Nat.eq_zero_or_pos u with h0 | h0
    · rw [h0, zero_mul] at hid
      have := pow_pos (by omega : 0 < N) 2
      omega
    · exact h0
  -- `u < N`, since `u < v` and `u v = N^2`
  have huN : u < N := by
    by_contra hcon
    push_neg at hcon
    have : N * N < u * v := Nat.mul_lt_mul_of_le_of_lt hcon (by omega) (by omega)
    nlinarith
  refine ⟨Nat.gcd_dvd_right _ _, ?_, ?_⟩
  · -- the gcd is not `1`: otherwise `u` is coprime to `N^2` and divides it
    by_contra hle
    push_neg at hle
    have hg1 : Nat.gcd u N = 1 := by
      have := Nat.gcd_pos_of_pos_left N hu0
      omega
    have hcop : Nat.Coprime u (N ^ 2) := Nat.Coprime.pow_right 2 hg1
    have hdvd : u ∣ N ^ 2 := ⟨v, hid.symm⟩
    exact hnt (Nat.Coprime.eq_one_of_dvd hcop hdvd)
  · -- the gcd is at most `u < N`
    exact lt_of_le_of_lt (Nat.le_of_dvd hu0 (Nat.gcd_dvd_left _ _)) huN

/-- The trivial triple on an odd leg: `N^2 + ((N^2-1)/2)^2 = ((N^2+1)/2)^2`,
with `c - b = 1`.  It exists for every odd `N` and carries no information. -/
theorem trivial_leg_triple (k : ℕ) :
    IsPythag ((2 * k + 1 : ℕ) : ℤ) ((2 * k ^ 2 + 2 * k : ℕ) : ℤ)
      ((2 * k ^ 2 + 2 * k + 1 : ℕ) : ℤ) := by
  unfold IsPythag; push_cast; ring

/-- **Converse: a factorization yields a nontrivial triple.**  If `N = d·e`
with `e = d + 2k`, `k ≥ 1` and `d > 1`, then
`N^2 + (2k(d+k))^2 = (d^2 + 2kd + 2k^2)^2`, a triple with `c - b = d^2 ≠ 1`. -/
theorem leg_triple_of_factorization (d k : ℕ) :
    IsPythag ((d * (d + 2 * k) : ℕ) : ℤ) ((2 * k * (d + k) : ℕ) : ℤ)
      ((d ^ 2 + 2 * k * d + 2 * k ^ 2 : ℕ) : ℤ) := by
  unfold IsPythag; push_cast; ring

/-- The difference `c - b` of the factorization triple is exactly `d^2`. -/
theorem leg_triple_of_factorization_diff (d k : ℕ) :
    (d ^ 2 + 2 * k * d + 2 * k ^ 2) - 2 * k * (d + k) = d ^ 2 := by
  have : 2 * k * (d + k) ≤ d ^ 2 + 2 * k * d + 2 * k ^ 2 := by nlinarith
  zify [this]; ring

/-- **Scaled trivial triple.**  If `e = 2m+1`, then
`(d e)^2 + (d(2m^2+2m))^2 = (d(2m^2+2m+1))^2`: the trivial triple of `e` scaled
by `d`, whose difference `c - b` is exactly `d`. -/
theorem scaled_leg_triple (d m : ℕ) :
    IsPythag ((d * (2 * m + 1) : ℕ) : ℤ) ((d * (2 * m ^ 2 + 2 * m) : ℕ) : ℤ)
      ((d * (2 * m ^ 2 + 2 * m + 1) : ℕ) : ℤ) := by
  unfold IsPythag; push_cast; ring

/-- **Composite ⇔ nontrivial leg triple (odd `N`).**  For odd `N > 1`, `N` has a
nontrivial divisor iff it is the leg of a Pythagorean triple `(N, b, c)` with
`b > 0` and `c - b ≠ 1`.  The forward direction uses the scaled trivial triple
(so `c - b = d`, the divisor itself); the backward direction is
`leg_triple_gcd_nontrivial`. -/
theorem composite_iff_nontrivial_leg_triple {N : ℕ} (hN : 1 < N) (hodd : Odd N) :
    (∃ d, NontrivialDivisor N d) ↔
      ∃ b c : ℕ, 0 < b ∧ c - b ≠ 1 ∧ IsPythag (N : ℤ) (b : ℤ) (c : ℤ) := by
  constructor
  · rintro ⟨d0, hd0⟩
    obtain ⟨e, hNe, hd1, he1⟩ := hd0.splits
    have heo : Odd e := (Nat.odd_mul.1 (hNe ▸ hodd)).2
    obtain ⟨m, hm⟩ := heo
    have hm1 : 1 ≤ m := by omega
    refine ⟨d0 * (2 * m ^ 2 + 2 * m), d0 * (2 * m ^ 2 + 2 * m + 1), ?_, ?_, ?_⟩
    · have : 0 < 2 * m ^ 2 + 2 * m := by positivity
      exact Nat.mul_pos (by omega) this
    · rw [Nat.mul_add, Nat.mul_one, Nat.add_sub_cancel_left]
      omega
    · rw [hNe, hm]; exact scaled_leg_triple d0 m
  · rintro ⟨b, c, hb, hnt, h⟩
    exact ⟨_, leg_triple_gcd_nontrivial hN hb h hnt⟩

/-! ## Lab notes (kernel-checked)

`N = 15 = 3·5`.  The four triples with leg `15` and `b > 0` have
`c - b ∈ {1, 3, 5, 9}`; the gcds with `15` are `1, 3, 5, 3`: every nontrivial
triple reveals a factor, the trivial one (`c - b = 1`) reveals nothing. -/

example : 15 ^ 2 + 112 ^ 2 = 113 ^ 2 ∧ 15 ^ 2 + 36 ^ 2 = 39 ^ 2 ∧
    15 ^ 2 + 20 ^ 2 = 25 ^ 2 ∧ 15 ^ 2 + 8 ^ 2 = 17 ^ 2 := by norm_num

example : Nat.gcd (113 - 112) 15 = 1 ∧ Nat.gcd (39 - 36) 15 = 3 ∧
    Nat.gcd (25 - 20) 15 = 5 ∧ Nat.gcd (17 - 8) 15 = 3 := by norm_num

end FactoringFrontier.PythagoreanLeg