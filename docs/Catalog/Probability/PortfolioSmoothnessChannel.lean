/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The hidden channel is number-theoretic: `p - 1` powersmoothness

The abstract model of `Probability.PortfolioRegretCore` assumes an *invisible*
organising channel: a hidden coordinate that decides which member of a factoring
portfolio wins, and which the observable features of the modulus `N` do not
resolve.  This file supplies the number theory behind that assumption.

* `PowerSmooth` — the hidden coordinate: `B`-powersmoothness of `p - 1`.
* `Probability.PortfolioRegret.smoothness_invisible_at_bitlength_11` — an
  explicit witness that the observable `(bit length of N, bit lengths of the two
  factors)` does *not* determine the hidden coordinate: two balanced semiprimes
  of exactly `21` bits, with both factors of exactly `11` bits, one of which has
  both `p - 1` and `q - 1` `256`-powersmooth while the other has neither.
  Hence the observation fiber genuinely contains both smoothness classes: the
  channel is `N`-invisible in the strong, pointwise sense.
* `Probability.PortfolioRegret.dvd_pow_lcmUpTo_sub_one` — the *paid probe* pays
  off: if `p - 1` is `B`-powersmooth then `p` divides `a ^ L - 1` for
  `L = lcm(1, …, B)` and any `a` prime to `p`.  This is exactly the guarantee
  behind a short-capped `p - 1` probe, so the value-of-information theorems of
  the core file are not vacuous.
-/
import Mathlib

namespace Probability.PortfolioRegret

/-! ## The hidden coordinate -/

/-- `n` is `B`-powersmooth: every prime power dividing `n` is at most `B`. -/
def PowerSmooth (B n : ℕ) : Prop := ∀ p k : ℕ, p.Prime → p ^ k ∣ n → p ^ k ≤ B

/-- Bounding a prime power divisor by exhibiting a higher power that fails to
divide. -/
theorem pow_le_of_pow_not_dvd {p k m n B : ℕ} (hp : 1 < p) (hdvd : p ^ k ∣ n)
    (hnd : ¬ p ^ m ∣ n) (hB : p ^ (m - 1) ≤ B) : p ^ k ≤ B := by
  have hk : k < m := by
    by_contra h
    exact hnd (dvd_trans (pow_dvd_pow p (not_lt.mp h)) hdvd)
  exact le_trans (Nat.pow_le_pow_right (le_of_lt hp) (by omega)) hB

/-- A prime divisor above the bound destroys powersmoothness. -/
theorem not_powerSmooth_of_large_prime_dvd {B n p : ℕ} (hp : p.Prime) (hdvd : p ∣ n)
    (hB : B < p) : ¬ PowerSmooth B n := by
  intro h
  have := h p 1 hp (by simpa using hdvd)
  simp only [pow_one] at this
  omega

/-! ## Two balanced 21-bit semiprimes with opposite hidden coordinate -/

theorem powerSmooth_1050 : PowerSmooth 256 1050 := by
  intro p k hp hdvd
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · norm_num
  have hpd : p ∣ 1050 := dvd_trans (dvd_pow_self p hk.ne') hdvd
  rw [show (1050 : ℕ) = 2 * (3 * (5 ^ 2 * 7)) by norm_num] at hpd
  rcases (Nat.Prime.dvd_mul hp).mp hpd with h | h
  · have hp2 : p = 2 := (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp h
    subst hp2
    exact pow_le_of_pow_not_dvd (m := 2) (by norm_num) hdvd (by norm_num) (by norm_num)
  rcases (Nat.Prime.dvd_mul hp).mp h with h | h
  · have hp3 : p = 3 := (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h
    subst hp3
    exact pow_le_of_pow_not_dvd (m := 2) (by norm_num) hdvd (by norm_num) (by norm_num)
  rcases (Nat.Prime.dvd_mul hp).mp h with h | h
  · have hp5 : p = 5 := (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp (hp.dvd_of_dvd_pow h)
    subst hp5
    exact pow_le_of_pow_not_dvd (m := 3) (by norm_num) hdvd (by norm_num) (by norm_num)
  · have hp7 : p = 7 := (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h
    subst hp7
    exact pow_le_of_pow_not_dvd (m := 2) (by norm_num) hdvd (by norm_num) (by norm_num)

theorem powerSmooth_1032 : PowerSmooth 256 1032 := by
  intro p k hp hdvd
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · norm_num
  have hpd : p ∣ 1032 := dvd_trans (dvd_pow_self p hk.ne') hdvd
  rw [show (1032 : ℕ) = 2 ^ 3 * (3 * 43) by norm_num] at hpd
  rcases (Nat.Prime.dvd_mul hp).mp hpd with h | h
  · have hp2 : p = 2 := (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp (hp.dvd_of_dvd_pow h)
    subst hp2
    exact pow_le_of_pow_not_dvd (m := 4) (by norm_num) hdvd (by norm_num) (by norm_num)
  rcases (Nat.Prime.dvd_mul hp).mp h with h | h
  · have hp3 : p = 3 := (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h
    subst hp3
    exact pow_le_of_pow_not_dvd (m := 2) (by norm_num) hdvd (by norm_num) (by norm_num)
  · have hp43 : p = 43 := (Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp h
    subst hp43
    exact pow_le_of_pow_not_dvd (m := 2) (by norm_num) hdvd (by norm_num) (by norm_num)

theorem not_powerSmooth_1318 : ¬ PowerSmooth 256 1318 :=
  not_powerSmooth_of_large_prime_dvd (p := 659) (by norm_num) (by norm_num) (by norm_num)

theorem not_powerSmooth_1306 : ¬ PowerSmooth 256 1306 :=
  not_powerSmooth_of_large_prime_dvd (p := 653) (by norm_num) (by norm_num) (by norm_num)

/-- A balanced semiprime instance: both factors are primes of exactly `b + 1`
bits. -/
def BalancedFactorPair (b : ℕ) (x : ℕ × ℕ) : Prop :=
  x.1.Prime ∧ x.2.Prime ∧ 2 ^ b ≤ x.1 ∧ x.1 < 2 ^ (b + 1) ∧ 2 ^ b ≤ x.2 ∧ x.2 < 2 ^ (b + 1)

/-- The hidden coordinate of an instance: both `p - 1` and `q - 1` are
`B`-powersmooth. -/
def SmoothChannel (B : ℕ) (x : ℕ × ℕ) : Prop :=
  PowerSmooth B (x.1 - 1) ∧ PowerSmooth B (x.2 - 1)

/-- **The channel is `N`-invisible.**  Two balanced semiprimes with *identical*
observable profile — modulus of exactly `21` bits, both factors of exactly `11`
bits — sit in opposite smoothness classes.  No feature computed from the bit
length and the balance of `N` can separate them, so the fiber of the observation
map contains both hidden classes. -/
theorem smoothness_invisible_at_bitlength_11 :
    ∃ x y : ℕ × ℕ,
      BalancedFactorPair 10 x ∧ BalancedFactorPair 10 y ∧
      2 ^ 20 ≤ x.1 * x.2 ∧ x.1 * x.2 < 2 ^ 21 ∧
      2 ^ 20 ≤ y.1 * y.2 ∧ y.1 * y.2 < 2 ^ 21 ∧
      SmoothChannel 256 x ∧ ¬ SmoothChannel 256 y := by
  refine ⟨(1051, 1033), (1319, 1307), ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩
  · exact ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩
  · norm_num
  · norm_num
  · norm_num
  · norm_num
  · exact ⟨by simpa using powerSmooth_1050, by simpa using powerSmooth_1032⟩
  · rintro ⟨h, -⟩
    exact not_powerSmooth_1318 (by simpa using h)

/-! ## The paid probe: `p - 1` really does succeed on the smooth class -/

/-- The exponent used by a `p - 1` probe capped at `B`. -/
def lcmUpTo (B : ℕ) : ℕ := (Finset.Icc 1 B).lcm id

/-- A `B`-powersmooth number divides `lcm (1, …, B)`. -/
theorem dvd_lcmUpTo_of_powerSmooth {B n : ℕ} (hs : PowerSmooth B n) :
    n ∣ lcmUpTo B := by
  rw [Nat.dvd_iff_prime_pow_dvd_dvd]
  intro p k hp hdvd
  have hle : p ^ k ≤ B := hs p k hp hdvd
  have hpos : 1 ≤ p ^ k := Nat.one_le_pow _ _ hp.pos
  exact Finset.dvd_lcm (f := id) (Finset.mem_Icc.mpr ⟨hpos, hle⟩)

/-- **The probe pays off.**  If the hidden coordinate of the prime factor `p` is
`B`-smooth, then a `p - 1` probe capped at `B` exposes `p`: for every `a` not
divisible by `p`, `p ∣ a ^ lcm(1, …, B) - 1`, so `gcd (a ^ L - 1, N)` is a
nontrivial factor of any `N` that `p` divides. -/
theorem dvd_pow_lcmUpTo_sub_one {B p : ℕ} (hp : p.Prime) (hs : PowerSmooth B (p - 1))
    {a : ℤ} (ha : ¬ (p : ℤ) ∣ a) : (p : ℤ) ∣ a ^ lcmUpTo B - 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨m, hm⟩ := dvd_lcmUpTo_of_powerSmooth hs
  have hazero : ((a : ZMod p)) ≠ 0 := by
    intro h
    exact ha ((ZMod.intCast_zmod_eq_zero_iff_dvd a p).mp h)
  have hpow : ((a : ZMod p)) ^ lcmUpTo B = 1 := by
    rw [hm, pow_mul, ZMod.pow_card_sub_one_eq_one hazero, one_pow]
  have : ((a ^ lcmUpTo B - 1 : ℤ) : ZMod p) = 0 := by
    push_cast
    rw [hpow, sub_self]
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp this

end Probability.PortfolioRegret