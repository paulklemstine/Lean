/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: Signs, Arithmetic, and Square Roots of One-Term Hahn Series

This file develops a small, *mathematically correct* base layer for the EML transseries
field, working with the lexicographically ordered Hahn-series field

    `TSeries := Lex (HahnSeries (Lex (ℤ →₀ ℝ)) ℝ)`

over the transmonomial value group `TransMono := Lex (ℤ →₀ ℝ)`.  Mathlib equips the
`Lex`-wrapped Hahn series with a `LinearOrder`, an `IsOrderedRing`, and (over an ordered
field domain) an `IsStrictOrderedRing`; the order keys on the coefficient at the *smallest*
index of the value group, i.e. on the leading coefficient
(`HahnSeries.leadingCoeff_pos_iff`).

The single one-term generator is `term g a := toLex (HahnSeries.single g a)`: the series with
the single nonzero coefficient `a` placed on the transmonomial `g`.

## Main results

- `single_pos_iff_coeff_pos`        : `0 < term g a ↔ 0 < a` (sign is the coefficient sign).
- `single_neg_of_coeff_neg`         : `a < 0 → term g a < 0`.
- `term_mul_term`                   : `term g a * term h b = term (g + h) (a * b)`
                                      (the monomial law; a `Lex`-wrapped instance of the
                                      Mathlib lemma `HahnSeries.single_mul_single`).
- `single_square_of_double_exponent`: if `g = k + k` and `0 ≤ a`, then
                                      `term k (Real.sqrt a) ^ 2 = term g a` — the *corrected*
                                      square-root statement (both the exponent **and** the
                                      coefficient are handled).
- `not_square_negative_monomial`    : a negative-coefficient monomial is never a square,
                                      because squares are nonnegative in an ordered ring.
- `positive_infinitesimal_monomial` : for any `0 < δ`, `ε = term δ 1` is positive and
                                      `(n : TSeries) * ε < 1` for every `n : ℕ`.
- `posExp` / `posExp_pos` / `explicit_positive_infinitesimal` : an explicit choice of a
                                      positive exponent `δ` in the value group and the
                                      resulting concrete infinitesimal.

## Scope

This is **not** a proof of real closure of the transseries field, nor of square-root closure
in general.  It is a verified base layer: monomial signs, monomial arithmetic, valid square
roots of positive square-compatible monomials, and infinitesimals.  See `RESEARCH_PAPER.md`
and `FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open HahnSeries

namespace EMLTransseries.MonomialOrder

noncomputable section

/-- The ordered group of **transmonomials**: finitely supported real exponents indexed by
the tower height `h ∈ ℤ`, with the lexicographic order. -/
abbrev TransMono : Type := Lex (ℤ →₀ ℝ)

/-- The **ordered field of transseries**: Hahn series over the transmonomial group, wrapped
in `Lex` so that Mathlib's lexicographic Hahn-series order (and the induced ordered-field
structure) applies. -/
abbrev TSeries : Type := Lex (HahnSeries TransMono ℝ)

/-- The one-term transseries with the single coefficient `a` on the transmonomial `g`. -/
def term (g : TransMono) (a : ℝ) : TSeries := toLex (HahnSeries.single g a)

/-! ### Signs of one-term series -/

/-- **Monomial positivity.** A one-term series is positive iff its coefficient is positive:
its leading coefficient *is* its coefficient.  (Note this requires `0 < a`; nothing about
`term g a` is positive for general real `a`.) -/
theorem single_pos_iff_coeff_pos (g : TransMono) (a : ℝ) : 0 < term g a ↔ 0 < a := by
  rw [← HahnSeries.leadingCoeff_pos_iff]; unfold term
  rw [ofLex_toLex, HahnSeries.leadingCoeff_of_single]

/-- **Monomial negativity.** A negative coefficient gives a negative one-term series. -/
theorem single_neg_of_coeff_neg (g : TransMono) (a : ℝ) (ha : a < 0) : term g a < 0 := by
  rw [← HahnSeries.leadingCoeff_neg_iff]; unfold term
  rw [ofLex_toLex, HahnSeries.leadingCoeff_of_single]; exact ha

/-! ### Arithmetic of one-term series -/

/-- **The monomial law.** Multiplying two one-term series adds the exponents (transmonomials)
and multiplies the coefficients.  This is the `Lex`-wrapped form of the Mathlib lemma
`HahnSeries.single_mul_single`. -/
theorem term_mul_term (g h : TransMono) (a b : ℝ) :
    term g a * term h b = term (g + h) (a * b) := by
  unfold term; rw [← HahnSeries.single_mul_single]; rfl

/-- **Corrected square root of a square-compatible monomial.** If the exponent `g` is
*even* in the value group (`g = k + k`) and the coefficient `a` is nonnegative, then the
one-term series `term k (Real.sqrt a)` squares to `term g a`.  Both the exponent (halved to
`k`) and the coefficient (replaced by `Real.sqrt a`, using `Real.mul_self_sqrt`) are handled
correctly. -/
theorem single_square_of_double_exponent (g k : TransMono) (a : ℝ)
    (hg : g = k + k) (ha : 0 ≤ a) : term k (Real.sqrt a) ^ 2 = term g a := by
  rw [sq, term_mul_term, ← hg, Real.mul_self_sqrt ha]

/-- **A negative monomial is never a square.** In an ordered ring every square is
nonnegative, but a negative-coefficient monomial is strictly negative
(`single_neg_of_coeff_neg`), so it cannot be a square. -/
theorem not_square_negative_monomial (g : TransMono) (a : ℝ) (ha : a < 0) :
    ¬ IsSquare (term g a) := by
  rintro ⟨r, hr⟩
  have hnonneg : 0 ≤ term g a := by rw [hr]; exact mul_self_nonneg r
  exact absurd hnonneg (not_le.mpr (single_neg_of_coeff_neg g a ha))

/-! ### Constants as one-term series -/

/-- The natural number `n`, as a transseries, is the constant one-term series with
coefficient `n` on the identity transmonomial `0`. -/
theorem natCast_eq_term (n : ℕ) : (n : TSeries) = term (0 : TransMono) (n : ℝ) := by
  unfold term
  show toLex (n : HahnSeries TransMono ℝ) = toLex (HahnSeries.single (0 : TransMono) (n : ℝ))
  exact congrArg toLex (coeff_inj.mp rfl)

/-- The field unit `1` is the one-term series with coefficient `1` on the identity
transmonomial `0`. -/
theorem one_eq_term : (1 : TSeries) = term (0 : TransMono) 1 := by
  unfold term
  show toLex (1 : HahnSeries TransMono ℝ) = toLex (HahnSeries.single (0 : TransMono) (1 : ℝ))
  exact congrArg toLex (coeff_inj.mp rfl)

/-! ### Infinitesimals -/

/-- **Positive infinitesimal monomial (parametric).** For any strictly positive exponent
`δ` in the value group, the monomial `ε = term δ 1` is strictly positive and is
infinitesimal: `(n : TSeries) * ε < 1` for every natural number `n`.  (The product
`(n : TSeries) * ε` lives on the exponent `δ > 0`, so it is dominated by the constant `1`,
whose leading term sits on the identity exponent `0`.) -/
theorem positive_infinitesimal_monomial (δ : TransMono) (hδ : 0 < δ) :
    0 < term δ 1 ∧ ∀ n : ℕ, (n : TSeries) * term δ 1 < 1 := by
  refine ⟨(single_pos_iff_coeff_pos δ 1).mpr one_pos, fun n => ?_⟩
  rw [natCast_eq_term, term_mul_term, one_eq_term, HahnSeries.lt_iff]
  have hδne : (0 : TransMono) ≠ δ := ne_of_lt hδ
  refine ⟨(0 : TransMono), fun j hj => ?_, ?_⟩
  · unfold term
    simp only [ofLex_toLex, zero_add, mul_one, HahnSeries.coeff_single]
    rw [if_neg (ne_of_lt (hj.trans hδ)), if_neg (ne_of_lt hj)]
  · unfold term
    simp only [ofLex_toLex, zero_add, mul_one, HahnSeries.coeff_single]
    rw [if_neg hδne]; norm_num

/-- An explicit positive exponent in the transmonomial value group: the transmonomial with
real exponent `1` at tower index `0` (i.e. `x` itself). -/
def posExp : TransMono := toLex (Finsupp.single (0 : ℤ) (1 : ℝ))

/-- `posExp` is strictly positive in the lexicographic value group. -/
theorem posExp_pos : (0 : TransMono) < posExp := by
  rw [posExp, show (0 : TransMono) = toLex (0 : ℤ →₀ ℝ) from rfl, Finsupp.Lex.lt_iff]
  refine ⟨0, fun d hd => ?_, ?_⟩
  · simp only [ofLex_toLex, Finsupp.coe_zero, Pi.zero_apply, Finsupp.single_apply]
    rw [if_neg (by omega)]
  · simp only [ofLex_toLex, Finsupp.coe_zero, Pi.zero_apply, Finsupp.single_apply]
    norm_num

/-- **Explicit positive infinitesimal.** Instantiating `positive_infinitesimal_monomial` at
the explicit exponent `posExp` yields a concrete positive infinitesimal monomial. -/
theorem explicit_positive_infinitesimal :
    0 < term posExp 1 ∧ ∀ n : ℕ, (n : TSeries) * term posExp 1 < 1 :=
  positive_infinitesimal_monomial posExp posExp_pos

end

end EMLTransseries.MonomialOrder