/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: The Ordered Non-Archimedean Hahn Field Layer

This file builds the **ordered field** layer of the EML transseries on top of the
transmonomial group `EMLTransseries.TransMono = Lex (ℤ →₀ ℝ)` and its dominance theorem
`EMLTransseries.mono_lt_mono_of_height` from `EML/Transseries/Field.lean`.

## The order-dual convention

The ordered transseries object is

    `OrderedTSeries := Lex (HahnSeries TransMonoᵒᵈ ℝ)`.

Two design choices are forced on us by Mathlib's API and by the intended *asymptotic*
meaning of the order; both are documented here.

* **Why `Lex (HahnSeries …)` rather than the bare `HahnSeries …`.**
  Mathlib equips `Lex R⟦Γ⟧ = Lex (HahnSeries Γ R)` — *not* the bare `HahnSeries Γ R` — with
  a `LinearOrder`, an `IsOrderedAddMonoid`/`IsOrderedRing`, and, when `R` is a linearly
  ordered field domain, an `IsStrictOrderedRing` (see `Mathlib.RingTheory.HahnSeries.Lex`).
  Combined with the Hahn-series `Field` instance this makes `OrderedTSeries` a genuine
  *linearly ordered field*.  The order is lexicographic on the coefficient function: for
  `a < b` one compares coefficients at the **smallest** index of `Γ` where they differ
  (`HahnSeries.lt_iff`).  The sign of a series is therefore the sign of its
  *leading* (smallest-index, i.e. `orderTop`) coefficient (`HahnSeries.leadingCoeff_pos_iff`).
  A bare `HahnSeries Γ R` carries no such order in Mathlib, so we must use the `Lex` synonym.

* **Why the index type is `TransMonoᵒᵈ` rather than `TransMono`.**
  In the asymptotic picture the *leading term* of a transseries is its **largest**
  (most dominant) transmonomial — `exp x` is "bigger" than `x`, `x` is bigger than `log x`.
  But the Hahn-series order keys on the **smallest** index of `Γ`.  Taking
  `Γ = TransMonoᵒᵈ` reverses the group order, so the smallest `Γ`-index is exactly the
  largest transmonomial.  Hence the leading Hahn coefficient is the coefficient on the
  dominant transmonomial, and the field order *is* asymptotic comparison:
  larger tower height ⇒ larger element of the field.

## Leading term ↔ asymptotic comparison

For a one-term generator `monomial g r = toLex (single (toDual g) 1·r)`, the unique support
point is `toDual g`, so its leading coefficient is `r`; thus `0 < monomial g r ↔ 0 < r`
(`monomial_pos`).  For two generators, `monomial g r < monomial g' r'` whenever the
transmonomial `g'` dominates `g` (`g < g'` in `TransMono`) and `r' > 0`
(`monomial_lt_monomial_of_index`): the difference's leading term sits on the dominant
transmonomial `g'` with positive coefficient `r'`.  This is proved directly from
`HahnSeries.lt_iff` and the order-reversal `OrderDual.toDual_lt_toDual`, so it does **not**
appeal to any generator-order theorem — there is no circularity.

## Main definitions

- `EMLTransseries.OrderedTSeries`  : `Lex (HahnSeries TransMonoᵒᵈ ℝ)`, the ordered field.
- `EMLTransseries.monomial g r`    : the one-term series `r · g` (coefficient `r` on `g`).
- `EMLTransseries.gen h a`         : `(level h)^a` with coefficient `1` (height `h : ℕ`).

## Main results

- `EMLTransseries.instfield`/`instLinearOrder`/`instIsStrictOrderedRing` (re-exported):
  `OrderedTSeries` is a linearly ordered field.
- `EMLTransseries.monomial_pos`               : positivity of a positive-coefficient term.
- `EMLTransseries.monomial_lt_monomial_of_index` : order matches dominance of the index.
- `EMLTransseries.gen_pos`                    : every generator is positive.
- `EMLTransseries.gen_lt_gen_of_height`       : higher tower height ⇒ larger field element.
- `EMLTransseries.natCast_lt_gen_one`         : `exp x` exceeds every natural number.
- `EMLTransseries.inv_gen_lt_inv_nat`         : `(exp x)⁻¹` is infinitesimal.
- `EMLTransseries.not_archimedean_orderedTSeries` : the field is non-Archimedean.

## Scope: this is only the ordered non-Archimedean field layer

This file establishes that the transseries form a *linearly ordered, non-Archimedean field*
whose order coincides with asymptotic dominance on transmonomials.  It does **not** prove
real-closedness of this Hahn field, nor uniqueness of EML asymptotic expansions; those
require substantially more theory (square-root/odd-degree-root closure, truncation-closed
subfields, the EML expansion map).  See `FUTURE_DIRECTIONS.md` and `RESEARCH_PAPER.md`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the transmonomial dominance order from `Field.lean` should lift,
via the order-dual Hahn-series construction, to the *field* order, so that "exp beats every
power/number" becomes a non-Archimedean statement about an honest ordered field.

Experiment (Experimenter): we set `OrderedTSeries := Lex (HahnSeries TransMonoᵒᵈ ℝ)` and
verified Mathlib supplies `Field`, `LinearOrder`, and `IsStrictOrderedRing`.  Generators are
single terms; `HahnSeries.lt_iff` reduces every order claim to a comparison of coefficients
at the dominant (smallest-dual-index) transmonomial.

Analysis (Analyst): the load-bearing subtlety is the *double* order reversal — `Lex` keys on
the smallest `Γ`-index, and `TransMonoᵒᵈ` flips `TransMono`, so "smallest dual index" =
"largest transmonomial" = "dominant".  The proof of `monomial_lt_monomial_of_index` uses
`OrderDual.toDual_lt_toDual` exactly once, on the group order from `Field.lean`, and never
on a field-order lemma; this is what rules out circularity.

Critique (Critic): `gen_lt_gen_of_height` is genuinely the field-level shadow of
`mono_lt_mono_of_height`; it is *derived from* it (plus generic Hahn-order facts), not
re-proved by self-rewriting.  The requested `gen_inv_infinitesimal` for *all* `n` is false
at `n = 0` (since `(0 : OrderedTSeries)⁻¹ = 0 < (gen 1 1)⁻¹`); we state and prove the correct
`inv_gen_lt_inv_nat` for `0 < n` instead, and document why.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.Field

open HahnSeries OrderDual

namespace EMLTransseries

noncomputable section

/-! ### The ordered transseries field -/

/-- The **ordered field of transseries**: Hahn series over the *order dual* of the
transmonomial group, wrapped in `Lex` so that Mathlib's lexicographic Hahn-series order
applies.  The order is asymptotic comparison: an element is positive iff its dominant
transmonomial has positive coefficient.  See the module docstring for the dual convention. -/
abbrev OrderedTSeries : Type := Lex (HahnSeries TransMonoᵒᵈ ℝ)

/-- `OrderedTSeries` is a field (Mathlib's Hahn-series field instance, transported to the
`Lex` synonym). -/
example : Field OrderedTSeries := inferInstance

/-- `OrderedTSeries` is linearly ordered (Mathlib's lexicographic Hahn-series order). -/
example : LinearOrder OrderedTSeries := inferInstance

/-- `OrderedTSeries` is a strictly ordered ring; together with the field instance this is a
linearly ordered field. -/
example : IsStrictOrderedRing OrderedTSeries := inferInstance

/-! ### Monomial and generator embeddings -/

/-- The one-term transseries `r · g`: the series whose only nonzero coefficient is `r`, on
the transmonomial `g`.  We store it at the *dual* index `toDual g` so that the lexicographic
Hahn order keys on the dominant transmonomial. -/
def monomial (g : TransMono) (r : ℝ) : OrderedTSeries := toLex (HahnSeries.single (toDual g) r)

/-- The generator `(level h)^a` with coefficient `1`, as an element of the ordered field.
Tower height `h : ℕ`: `gen 1 a` is `(exp x)^a`, `gen 0 a` is `x^a`, `gen 2 a` is
`(exp(exp x))^a`, etc. -/
def gen (h : ℕ) (a : ℝ) : OrderedTSeries := monomial (mono (h : ℤ) a) 1

/-! ### Order = asymptotic dominance

The two structural lemmas below reduce every field-order statement about generators to the
*group* order on transmonomials, proved in `Field.lean`.  They are proved directly from
`HahnSeries.lt_iff` and `OrderDual.toDual_lt_toDual`; in particular they do **not** invoke
any generator-order theorem, so the development is free of circularity. -/

/-- **Order matches dominance.** If the transmonomial `g'` dominates `g` (`g < g'` in the
transmonomial group) and the leading coefficient `r'` is positive, then `monomial g r` is
strictly below `monomial g' r'` in the field — for *any* coefficient `r`.  The difference's
leading term lives on the dominant transmonomial `g'` (the smallest dual index) with the
positive coefficient `r'`. -/
theorem monomial_lt_monomial_of_index {g g' : TransMono} {r r' : ℝ}
    (hgg : g < g') (hr' : 0 < r') : monomial g r < monomial g' r' := by
  have hdual : (toDual g' : TransMonoᵒᵈ) < toDual g := toDual_lt_toDual.mpr hgg
  rw [monomial, monomial, HahnSeries.lt_iff]
  refine ⟨toDual g', fun j hj => ?_, ?_⟩
  · simp only [ofLex_toLex, coeff_single]
    rw [if_neg (by rintro rfl; exact absurd (hdual.trans hj) (lt_irrefl _)), if_neg (ne_of_lt hj)]
  · simp only [ofLex_toLex, coeff_single]
    rw [if_neg (ne_of_lt hdual)]; simpa using hr'

/-- **Positivity of a positive-coefficient term.** `monomial g r > 0` whenever `r > 0`: its
leading (and only) coefficient is `r`. -/
theorem monomial_pos {g : TransMono} {r : ℝ} (hr : 0 < r) : 0 < monomial g r := by
  rw [monomial, HahnSeries.lt_iff]
  refine ⟨toDual g, fun j hj => ?_, ?_⟩
  · simp only [ofLex_toLex, coeff_single]; rw [if_neg (ne_of_lt hj)]; rfl
  · simp only [ofLex_toLex, coeff_single]; simpa using hr

/-- The transmonomial of height `0` and exponent `0` is the identity transmonomial, i.e. the
additive zero of the transmonomial group (the constant `1 = x^0`). -/
theorem mono_zero_zero : mono 0 0 = 0 := by rw [mono]; simp

/-- The natural number `n`, as a transseries, is the constant term `n · 1` — i.e. the
monomial on the identity transmonomial `0` with coefficient `n`. -/
theorem natCast_eq_monomial (n : ℕ) : (n : OrderedTSeries) = monomial 0 (n : ℝ) := by
  rw [monomial, toDual_zero]
  show toLex (n : HahnSeries TransMonoᵒᵈ ℝ) = toLex (HahnSeries.single 0 (n : ℝ))
  exact congrArg toLex (coeff_inj.mp rfl)

/-- A positive-height, positive-exponent transmonomial dominates the identity transmonomial:
`0 < mono h a` in the transmonomial group when `0 < h` and `0 < a`. -/
theorem zero_lt_mono {h : ℤ} (hh : 0 < h) {a : ℝ} (ha : 0 < a) : (0 : TransMono) < mono h a := by
  rw [← mono_zero_zero]; exact mono_lt_mono_of_height 0 h hh 0 a ha

/-! ### Positivity and dominance of generators -/

/-- **Generators are positive.** Every generator `gen h a` is strictly positive: its single
coefficient is `1 > 0`.  (Note: this holds for every real exponent `a`, including `a = 0`,
which gives the constant `1`, and negative `a`.) -/
theorem gen_pos {h : ℕ} {a : ℝ} : 0 < gen h a := monomial_pos one_pos

/-- **Higher tower height ⇒ larger field element.** If `h < k` and the exponents are
positive, then `gen h a < gen k b` in the ordered field.

Orientation/convention: a *larger tower height* gives a *larger* element of the field, in
keeping with asymptotic growth (`exp(exp x) > exp x > x > log x > 1`).  This works because
the Hahn order keys on the smallest dual index, which — thanks to `TransMonoᵒᵈ` — is the
*dominant* transmonomial.  This is the field-level image of `mono_lt_mono_of_height` from
`Field.lean`; it is *derived from* that group-order theorem (via
`monomial_lt_monomial_of_index`), not re-proved by self-rewriting.

The hypothesis `ha : 0 < a` is included because it was part of the requested statement; it is
not actually needed (only the dominant exponent `b`'s positivity matters for the comparison),
which reflects that height dominance is insensitive to the lower tower's exponent. -/
theorem gen_lt_gen_of_height {h k : ℕ} {a b : ℝ}
    (hhk : h < k) (ha : 0 < a) (hb : 0 < b) : gen h a < gen k b :=
  monomial_lt_monomial_of_index
    (mono_lt_mono_of_height (h : ℤ) (k : ℤ) (by exact_mod_cast hhk) a b hb) one_pos

/-! ### Infinite and infinitesimal elements; non-Archimedean witness -/

/-- **`exp x` is infinite.** The generator `gen 1 1 = exp x` is larger than every natural
number: `(n : OrderedTSeries) < gen 1 1` for all `n`.  The natural number `n` lives on the
identity transmonomial, which `exp x` strictly dominates. -/
theorem natCast_lt_gen_one (n : ℕ) : (n : OrderedTSeries) < gen 1 1 := by
  rw [natCast_eq_monomial, gen]
  exact monomial_lt_monomial_of_index (zero_lt_mono (by norm_num) (by norm_num)) one_pos

/-- **The ordered transseries field is non-Archimedean.** There is an element exceeding every
natural number; `gen 1 1 = exp x` is an explicit witness. -/
theorem not_archimedean_orderedTSeries :
    ∃ x : OrderedTSeries, ∀ n : ℕ, (n : OrderedTSeries) < x :=
  ⟨gen 1 1, natCast_lt_gen_one⟩

/-- **`(exp x)⁻¹` is infinitesimal.** For every positive natural number `n`, the
infinitesimal `(gen 1 1)⁻¹` is below `(n : OrderedTSeries)⁻¹`.

We require `0 < n`: the naive "for all `n`" version is *false* at `n = 0`, because
`(0 : OrderedTSeries)⁻¹ = 0` while `(gen 1 1)⁻¹ > 0`.  For `0 < n` the inequality follows by
order-reversal of inversion from `natCast_lt_gen_one`. -/
theorem inv_gen_lt_inv_nat {n : ℕ} (hn : 0 < n) :
    (gen 1 1)⁻¹ < (n : OrderedTSeries)⁻¹ := by
  have hnpos : (0 : OrderedTSeries) < (n : OrderedTSeries) := by
    rw [natCast_eq_monomial]; exact monomial_pos (by exact_mod_cast hn)
  exact inv_strictAnti₀ hnpos (natCast_lt_gen_one n)

end

end EMLTransseries