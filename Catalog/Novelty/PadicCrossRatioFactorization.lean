/-
# Generalized Giampietro–Darmon Factorization — Genus 0 (additive/`p`-adic model)

This file develops a faithful arithmetic model of the **genus-0** case of the
Giampietro–Darmon factorization formula for the norm of `p`-adic cross-ratios of
CM points on Atkin–Lehner quotients of Shimura curves.

The relevant structure of the Giampietro–Darmon theorem is that the *valuation*
(the additive incarnation of the `p`-adic norm) of a cross-ratio of four CM
points factors as an alternating sum of **local intersection multiplicities** of
the associated Heegner divisors. Over a `p`-adic field, the local intersection
multiplicity of two CM points reducing to the same point is precisely the
valuation of their difference (Gross–Zagier style local computation). We model
this over `ℚ` with the `p`-adic valuation `padicValRat p`, which is fully
computable and lets us verify the formula on explicit examples.

## Main results

* `crossRatio_valuation_factor` — the *genus-0 Giampietro–Darmon factorization*:
  the `p`-adic valuation of the cross-ratio equals the alternating sum of the
  four local intersection multiplicities.
* `crossRatio_inv_swap` — the anharmonic-group relation: swapping the last two
  points inverts the cross-ratio.
* `crossRatio_one_sub` — the anharmonic-group relation: swapping the middle two
  points sends `λ` to `1 - λ`.

These identities are the algebraic backbone (the `S₃`-action generating the
6-element anharmonic group) underlying the factorization structure.
-/
import Mathlib

open scoped BigOperators

namespace GiampietroDarmon

/-- The cross-ratio of four points `a, b, c, d` in `ℚ`:
`(a,b;c,d) = ((a-c)(b-d)) / ((a-d)(b-c))`. -/
def crossRatio (a b c d : ℚ) : ℚ := ((a - c) * (b - d)) / ((a - d) * (b - c))

/-- The **local intersection multiplicity** at `p` of two CM points `x, y`,
modelled as the `p`-adic valuation of their difference. This is the additive,
local incarnation of the `p`-adic distance between two points reducing modulo `p`
to the same point. -/
def localMult (p : ℕ) (x y : ℚ) : ℤ := padicValRat p (x - y)

/-
**Genus-0 Giampietro–Darmon factorization.** The `p`-adic valuation of the
cross-ratio of four distinct points factors as the alternating sum of the local
intersection multiplicities of the corresponding Heegner divisors:
`v_p((a,b;c,d)) = m(a,c) + m(b,d) - m(a,d) - m(b,c)`.
-/
theorem crossRatio_valuation_factor (p : ℕ) [Fact p.Prime]
    {a b c d : ℚ} (hac : a ≠ c) (hbd : b ≠ d) (had : a ≠ d) (hbc : b ≠ c) :
    padicValRat p (crossRatio a b c d)
      = localMult p a c + localMult p b d - localMult p a d - localMult p b c := by
  unfold crossRatio localMult;
  rw [ padicValRat.div, padicValRat.mul, padicValRat.mul ] <;> ( simp_all +decide [ sub_eq_iff_eq_add ] )

/-
**Anharmonic relation (inversion).** Swapping the two "denominator" points
inverts the cross-ratio: `(a,b;d,c) = (a,b;c,d)⁻¹`.
-/
theorem crossRatio_inv_swap (a b c d : ℚ) :
    crossRatio a b d c = (crossRatio a b c d)⁻¹ := by
  unfold crossRatio
  rw [inv_div]

/-
**Anharmonic relation (`λ ↦ 1 - λ`).** Swapping the two "middle" points
sends the cross-ratio `λ` to `1 - λ`: `(a,c;b,d) = 1 - (a,b;c,d)`.
-/
theorem crossRatio_one_sub {a b c d : ℚ}
    (hac : a ≠ c) (hbd : b ≠ d) (had : a ≠ d) (hbc : b ≠ c) :
    crossRatio a c b d = 1 - crossRatio a b c d := by
  unfold crossRatio;
  grind

end GiampietroDarmon