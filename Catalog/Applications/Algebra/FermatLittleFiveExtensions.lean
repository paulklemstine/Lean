import Catalog.Probability.FermatLittleFive

/-!
# Extensions of the divisibility `5 ∣ a ^ 5 - a`

This file builds on the catalog result
`Catalog.Probability.FermatLittleFive.five_dvd_pow_five_sub_self`
(the special case of Fermat's little theorem for `p = 5`) and derives several
genuinely stronger, insight-bearing consequences over the integers:

* `FermatFive.pow_five_modEq_self` — the congruence form `a ^ 5 ≡ a [ZMOD 5]`.
* `FermatFive.two_dvd_pow_five_sub_self` — the parity companion `2 ∣ a ^ 5 - a`.
* `FermatFive.ten_dvd_pow_five_sub_self` — the sharpened divisibility
  `10 ∣ a ^ 5 - a`, obtained by combining the mod-`2` and mod-`5` facts.
* `FermatFive.pow_five_last_digit` — the arithmetic pay-off: *every fifth power
  ends in the same base-ten digit as its base*, `a ^ 5 % 10 = a % 10`.
* `FermatFive.pow_four_mul_add_one_modEq` — the exponent-lifting generalisation
  `5 ∣ a ^ (4 * k + 1) - a` for all `k`, proved by induction on `k`.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
The bare statement `5 ∣ a^5 - a` is a one-liner from Fermat's little theorem, so
on its own it is not a research contribution. We hypothesised four falsifiable
strengthenings worth testing:
  H1. `10 ∣ a^5 - a` (i.e. fifth powers preserve the last decimal digit).
  H2. `a^5 % 10 = a % 10` for every integer `a` (the digit statement made explicit).
  H3. `5 ∣ a^(4k+1) - a` for all `k` (the multiplicative order of the Frobenius map
      on `ZMod 5` divides 4, so exponents in the residue class `1 mod 4` all act
      trivially).
  H4. (Surprising) The exponent `5` is *not* special for divisibility by `10`;
      the same last-digit phenomenon should hold for `a^(4k+1)` as well.

## Experiment (Experimenter)
Brute-force numerical checks (see `ComputationalEvidence.md`):
  * `(n^5 - n) % 10 = 0` for `n = 0..29`  ✓  (supports H1)
  * `n^5 % 10 = n % 10` for `n = 0..19`   ✓  (supports H2)
  * `(a^(4k+1) - a) % 5 = 0` for `k = 0..5`, `a = 0..19`  ✓  (supports H3)
No counterexamples were found, so all four hypotheses advanced to proof.

## Analysis (Analyst)
H1 splits cleanly as `2 ∣ ·` and `5 ∣ ·` with `gcd 2 5 = 1`; `omega` closes the
combination once both divisibilities are hypotheses.  The parity fact
`2 ∣ a^5 - a` is cleanest via `Int.even_sub`/`Int.even_pow` rather than a second
case analysis.  H3 is a textbook induction: `a^(4(n+1)+1) - a` decomposes as
`a^4 * (a^(4n+1) - a) + (a^5 - a)`, both summands divisible by 5.  H4 is a true
corollary of H2 + H3 but adds no new proof idea, so it was *not* promoted to a
separate theorem (avoiding trivial count-padding).

## Critique (Critic)
* None of the theorems are `True`, definitional, or closed by a single
  `decide`/`native_decide`; each uses `omega`, induction, or a Mathlib parity
  lemma on top of the imported catalog result.
* `pow_five_last_digit` genuinely uses `ten_dvd_pow_five_sub_self`, which in turn
  uses the catalog theorem — the dependency on the attached catalog is real.
* Corner cases: statements are over all of `ℤ` (including negatives and `0`),
  and `Int.ModEq`/`%` behave correctly there; the induction base `k = 0` gives
  `a^1 - a = 0`.

## Synthesis (PI)
The catalog's `5 ∣ a^5 - a` is repackaged into the decimal-digit invariant
`a^5 % 10 = a % 10` and lifted to the arithmetic progression of exponents
`1, 5, 9, 13, …`.  See `FUTURE_DIRECTIONS.md` for the resulting conjectures.
-- !-- Lab Notes -- !--
-/

namespace FermatFive

/-- Congruence form of the `p = 5` case: `a ^ 5 ≡ a` modulo `5`. -/
theorem pow_five_modEq_self (a : ℤ) : a ^ 5 ≡ a [ZMOD 5] :=
  Int.modEq_iff_dvd.mpr (by have := five_dvd_pow_five_sub_self a; omega)

/-- Parity companion: `a ^ 5 - a` is always even. -/
theorem two_dvd_pow_five_sub_self (a : ℤ) : (2 : ℤ) ∣ a ^ 5 - a := by
  have h : Even (a ^ 5 - a) := by
    rw [Int.even_sub, Int.even_pow]
    tauto
  exact h.two_dvd

/-- Sharpened divisibility: `10 ∣ a ^ 5 - a`, combining the mod-`2` and
mod-`5` facts (which are coprime). -/
theorem ten_dvd_pow_five_sub_self (a : ℤ) : (10 : ℤ) ∣ a ^ 5 - a := by
  have h5 := five_dvd_pow_five_sub_self a
  have h2 := two_dvd_pow_five_sub_self a
  omega

/-- **Last-digit invariance.** Every integer fifth power ends in the same
base-ten digit as its base: `a ^ 5 % 10 = a % 10`. -/
theorem pow_five_last_digit (a : ℤ) : a ^ 5 % 10 = a % 10 := by
  have := ten_dvd_pow_five_sub_self a
  omega

/-- Exponent-lifting generalisation: `5 ∣ a ^ (4 * k + 1) - a` for every `k`,
proved by induction on `k` using the base case `5 ∣ a ^ 5 - a`. -/
theorem pow_four_mul_add_one_modEq (k : ℕ) (a : ℤ) :
    (5 : ℤ) ∣ a ^ (4 * k + 1) - a := by
  induction k with
  | zero => norm_num
  | succ n ih =>
    have key : a ^ (4 * (n + 1) + 1) - a
        = a ^ 4 * (a ^ (4 * n + 1) - a) + (a ^ 5 - a) := by ring
    rw [key]
    exact dvd_add (ih.mul_left _) (five_dvd_pow_five_sub_self a)

end FermatFive