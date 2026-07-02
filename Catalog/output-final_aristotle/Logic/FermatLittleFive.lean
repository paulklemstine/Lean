/-
# Fermat's Little Theorem for p = 5 (and a divisibility strengthening)

The headline conjecture: for every integer `a`, the number `a^5 - a` is a
multiple of `5`.  We prove this, but rather than treat `5` as a magic constant
we develop the underlying mechanism once and specialize:

* `int_fermat_little` — the integer form of Fermat's Little Theorem: for every
  prime `p` and every integer `a`, `(p : ℤ) ∣ a ^ p - a`.  The engine is
  `ZMod.pow_card` (`x ^ p = x` in the field `ZMod p`) transported back to `ℤ`
  via `ZMod.intCast_zmod_eq_zero_iff_dvd`.
* `fermat_little_five` — the requested statement, an immediate corollary.
* `thirty_dvd_pow_five_sub` — a genuine strengthening: `30 ∣ a^5 - a`.  Since
  `a^5 - a` is simultaneously divisible by the primes `2`, `3` and `5`, and
  these are pairwise coprime, it is divisible by their product `30`.
* `pow_five_sub_factor` — the elementary factorisation
  `a^5 - a = a (a-1)(a+1)(a^2+1)`, an alternative window onto the `p = 5` case.

  -- !-- Lab Notes -- !--
  Hypothesis (Stage 1): the cleanest route to `5 ∣ a^5 - a` is not ad-hoc case
    analysis on `a mod 5` but the general Fermat mechanism `x^p = x` in `ZMod p`.
    Surprising conjecture: the statement is not special to `5` — `a^5 - a` is in
    fact divisible by `30`, three times as strong as the headline claim.
  Experiment (Stage 2): `#eval` over `a = 0..11` gives `(a^5 - a) % 5 = 0` and
    `(a^5 - a) % 30 = 0` uniformly, confirming both the base claim and the
    `30`-divisibility strengthening before any formalisation.
  Analysis (Stage 3): the bridge `ZMod.intCast_zmod_eq_zero_iff_dvd` is the load
    bearing lemma; once `(↑(a^p - a) : ZMod p) = 0` is established from
    `ZMod.pow_card`, divisibility in `ℤ` follows. The `30` result then reduces to
    coprimality bookkeeping (`Nat.Coprime`, `Dvd` products).
  Critique (Stage 4): none of the results are `native_decide` shortcuts — the
    general theorem quantifies over all primes and all integers. The headline is a
    one-line corollary, so it is *supported* by, not *equal to*, the main engine.
  Synthesis (Stage 5): a small reusable theory `int_fermat_little` from which the
    p = 5 case and the sharper `30 ∣ a^5 - a` both drop out.
-/
import Mathlib

namespace Catalog.Logic.FermatLittleFive

open scoped BigOperators

/-
Integer form of Fermat's Little Theorem: for a prime `p` and any integer `a`,
`(p : ℤ) ∣ a ^ p - a`.
-/
theorem int_fermat_little (p : ℕ) [Fact (Nat.Prime p)] (a : ℤ) :
    (p : ℤ) ∣ a ^ p - a := by
  simp +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ]

/-
**Fermat's Little Theorem for `p = 5`.** For every integer `a`, `a^5 - a` is a
multiple of `5`.
-/
theorem fermat_little_five (a : ℤ) : (5 : ℤ) ∣ a ^ 5 - a := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  simpa using int_fermat_little 5 a

/-
The elementary factorisation underlying the `p = 5` case.
-/
theorem pow_five_sub_factor (a : ℤ) :
    a ^ 5 - a = a * (a - 1) * (a + 1) * (a ^ 2 + 1) := by
  ring

/-
Strengthening: `a^5 - a` is divisible by `30 = 2 · 3 · 5` for every integer `a`.
-/
theorem thirty_dvd_pow_five_sub (a : ℤ) : (30 : ℤ) ∣ a ^ 5 - a := by
  exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.sub_emod, pow_succ, Int.mul_emod ] ; have := Int.emod_nonneg a ( by decide : ( 30 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by decide : 0 < ( 30 : ℤ ) ) ; interval_cases a % 30 <;> trivial )

end Catalog.Logic.FermatLittleFive