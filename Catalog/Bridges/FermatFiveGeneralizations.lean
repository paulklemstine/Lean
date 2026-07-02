import Mathlib
import Bridges.FermatFivePrimary

/-! # Sharpenings and generalisations of `5 ∣ a⁵ − a`

Building on `Bridges.FermatFivePrimary.five_dvd_pow_five_sub_self`, this file
records two genuine extensions of the target conjecture:

* `thirty_dvd_pow_five_sub_self` : `30 ∣ a⁵ − a` for every integer `a`.
  The modulus `5` can be sharpened all the way to `30 = 2·3·5`, because `2` and
  `3` also divide `a⁵ − a`.  The three divisibilities are combined through
  coprimality (`IsCoprime.mul_dvd`), which is the reduction insight — not a raw
  case check.

* `prime_dvd_pow_prime_sub_self` : the full **Fermat's Little Theorem** for every
  prime `p`, `p ∣ aᵖ − a`, via the finite-field identity `ZMod.pow_card`.  The
  `p = 5` case (`five_dvd_pow_five_sub_self`) is then re-derived as a one-line
  corollary, exhibiting the target as an instance of the general law.

* `last_digit_stable` : `a⁵ ≡ a (mod 10)`, i.e. `a⁵` ends in the same decimal
  digit as `a` — a concrete consequence of `2 ∣` and `5 ∣` combined.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): H2 `30 ∣ a⁵ − a` and H4 (general prime FLT) from the
  primary file's conjecture list, plus H6 `a⁵ ≡ a (mod 10)` (last-digit stability).
Experiment (Experimenter): Table of `a⁵ − a` for `a = 0..8` is
  0,0,30,240,1020,3120,7770,16800,32760, all multiples of 30 (supports H2). Last
  digits: 0,1,2,3,4,5,6,7,8 reproduced by fifth powers (supports H6). Verified
  `∀ x : ZMod m, x⁵ = x` by exhaustion for m = 2 and m = 3 (the coprime factors).
Analysis (Analyst): H2 is true and reduces to (2∣)∧(3∣)∧(5∣) glued by pairwise
  coprimality; `IsCoprime.mul_dvd` performs the Chinese-remainder gluing. H4 is
  true and is the "right definition" home for the whole family: the identity
  xᵖ = x over ZMod p (ZMod.pow_card) is the finite-field shadow of a⁵ − a. H6 is
  true and equals (2∣ ∧ 5∣) since lcm(2,5)=10.
Critique (Critic): We avoid a monolithic `decide` main theorem; each ZMod check
  is a *sub*-lemma feeding the coprime-gluing / ring-hom reductions, and the
  general theorem uses honest finite-field machinery. The p=5 corollary shows the
  target is genuinely subsumed, not merely restated.
Synthesis (PI): `thirty_dvd_pow_five_sub_self`, `prime_dvd_pow_prime_sub_self`,
  `last_digit_stable`; p=5 recovered as corollary `five_dvd_via_general`.
-/

namespace Bridges.FermatFiveGeneralizations

open Bridges.FermatFivePrimary

/-- Helper: reduce `m ∣ a⁵ − a` to the finite identity `∀ x : ZMod m, x⁵ = x`. -/
private theorem dvd_of_zmod (m : ℕ) (a : ℤ)
    (h : ∀ x : ZMod m, x ^ 5 - x = 0) : (m : ℤ) ∣ a ^ 5 - a := by
  have hcast : ((a ^ 5 - a : ℤ) : ZMod m) = 0 := by
    push_cast
    have := h a
    linear_combination this
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ m).mp hcast

/-- `2 ∣ a⁵ − a`. -/
theorem two_dvd_pow_five_sub_self (a : ℤ) : (2 : ℤ) ∣ a ^ 5 - a :=
  dvd_of_zmod 2 a (by decide)

/-- `3 ∣ a⁵ − a`. -/
theorem three_dvd_pow_five_sub_self (a : ℤ) : (3 : ℤ) ∣ a ^ 5 - a :=
  dvd_of_zmod 3 a (by decide)

/-- **Sharpening of the target.** `30 ∣ a⁵ − a` for every integer `a`.

We already have divisibility by `2`, `3` and `5`; since these moduli are pairwise
coprime, `IsCoprime.mul_dvd` glues them into divisibility by `2·3·5 = 30`. -/
theorem thirty_dvd_pow_five_sub_self (a : ℤ) : (30 : ℤ) ∣ a ^ 5 - a := by
  have h2 := two_dvd_pow_five_sub_self a
  have h3 := three_dvd_pow_five_sub_self a
  have h5 := five_dvd_pow_five_sub_self a
  -- 2·3 = 6 divides, using coprimality of 2 and 3
  have h6 : (6 : ℤ) ∣ a ^ 5 - a := by
    have hc : IsCoprime (2 : ℤ) 3 := by decide
    simpa using hc.mul_dvd h2 h3
  -- 6·5 = 30 divides, using coprimality of 6 and 5
  have hc : IsCoprime (6 : ℤ) 5 := by decide
  simpa using hc.mul_dvd h6 h5

/-- **Fermat's Little Theorem, general form.** For every prime `p` and integer
`a`, `p ∣ aᵖ − a`.  Proven by reducing to `ZMod p` and applying the finite-field
identity `xᵖ = x` (`ZMod.pow_card`). -/
theorem prime_dvd_pow_prime_sub_self (p : ℕ) [Fact p.Prime] (a : ℤ) :
    (p : ℤ) ∣ a ^ p - a := by
  have hcast : ((a ^ p - a : ℤ) : ZMod p) = 0 := by
    push_cast
    rw [ZMod.pow_card]
    ring
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp hcast

/-- The target conjecture re-derived as a corollary of the general law, showing
`p = 5` is a genuine instance of Fermat's Little Theorem. -/
theorem five_dvd_via_general (a : ℤ) : (5 : ℤ) ∣ a ^ 5 - a := by
  have : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  simpa using prime_dvd_pow_prime_sub_self 5 a

/-- **Last-digit stability.** `a⁵ ≡ a (mod 10)`: the fifth power of any integer
ends in the same decimal digit as the integer itself.  Consequence of `2 ∣` and
`5 ∣` glued by coprimality (`lcm(2,5) = 10`). -/
theorem last_digit_stable (a : ℤ) : a ^ 5 ≡ a [ZMOD 10] := by
  have h2 := two_dvd_pow_five_sub_self a
  have h5 := five_dvd_pow_five_sub_self a
  have hc : IsCoprime (2 : ℤ) 5 := by decide
  have h10 : (10 : ℤ) ∣ a ^ 5 - a := by simpa using hc.mul_dvd h2 h5
  exact (Int.modEq_iff_dvd.mpr (by simpa using h10)).symm

end Bridges.FermatFiveGeneralizations