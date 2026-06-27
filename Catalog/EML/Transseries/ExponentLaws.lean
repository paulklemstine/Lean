/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: Laws of Exponents and the Non-Archimedean Value Group

This file develops the **multiplicative algebra of transmonomials** inside the field of
transseries `EMLTransseries.TSeries = HahnSeries (Lex (ℤ →₀ ℝ)) ℝ` built in `Field.lean`,
and pins down the two features that distinguish transseries from ordinary power series:

* a clean **law of exponents** at each tower height — `(level h)^a · (level h)^b =
  (level h)^{a+b}`, making `a ↦ term h a` a group homomorphism `(ℝ,+) → TSeriesˣ`; and
* the **non-Archimedean / unbounded** nature of the transmonomial value group: there is no
  dominant transmonomial (the exp/log tower never terminates), and *no finite power of* `x`
  ever catches up to `exp x`.

## Main results

- `EMLTransseries.term_mul_term_same` : `term h a * term h b = term h (a + b)`.
- `EMLTransseries.term_zero`          : `term h 0 = 1`.
- `EMLTransseries.term_ne_zero`       : one-term transseries are nonzero.
- `EMLTransseries.term_mul_neg`       : `term h a * term h (-a) = 1` (each term is a unit).
- `EMLTransseries.isUnit_term`        : every one-term transseries is a unit.
- `EMLTransseries.term_pow`           : `(term h a) ^ n = term h (n * a)`.
- `EMLTransseries.termHom`            : the group hom `(ℝ,+) →* TSeriesˣ`, `a ↦ term h a`.
- `EMLTransseries.exists_gt`          : the value group has **no maximum** (unbounded tower).
- `EMLTransseries.pow_var_lt_exp`     : no power of `x` dominates `exp x` (non-Archimedean).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the transmonomials at a fixed tower height should behave exactly
like a 1-parameter multiplicative group `(level h)^a`, with the real exponent as the group
parameter; and globally the value group `Lex (ℤ →₀ ℝ)` should have *no top element*,
formalizing the fact that the exp-tower `x, exp x, exp(exp x), …` never stabilizes.

Experiment (Experimenter): the law of exponents reduces, via `HahnSeries.single_mul_single`,
to `Finsupp.single` additivity `single (-h) a + single (-h) b = single (-h) (a+b)`, lifted
through `toLex`.  Unboundedness was obtained constructively: given `g = toLex f`, if `f` has
nonempty support with minimum index `i₀`, then adding a positive coefficient at `i₀ - 1`
produces a strictly larger element (it differs first, and positively, at the new smallest
index); if `f = 0`, any positive monomial works.

Analysis (Analyst): `pow_var_lt_exp` is the sharp non-Archimedean statement.  In a Laurent or
Puiseux series field the value group is `ℤ` (or `ℝ`), where *every* element is bounded by some
multiple of a fixed positive element — Archimedean.  Here `n • (mono 0 1) = mono 0 n` stays
strictly below `mono 1 1` for *every* `n`, because the tower-height coordinate (index `-1`)
is lexicographically more significant than the power-of-`x` coordinate (index `0`).  This is
precisely the phenomenon that power series cannot model.

Critique (Critic): none of these are `rfl`/`decide`.  `term_pow` is a genuine induction on
the exponent through the law of exponents; `exists_gt` constructs a witness and verifies it
via `Finsupp.Lex.lt_iff`; `pow_var_lt_exp` chains the multiplicative valuation with the
order theorem `exp_dominates_pow` from `Field.lean`, so it really uses the lex structure.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.Field

open HahnSeries

namespace EMLTransseries

noncomputable section

/-! ### Convenient names for the basic transmonomials -/

/-- The transseries `x` itself (tower height `0`, exponent `1`). -/
abbrev varX : TSeries := term 0 1
/-- The transseries `exp x` (tower height `1`, exponent `1`). -/
abbrev expX : TSeries := term 1 1
/-- The transseries `log x` (tower height `-1`, exponent `1`). -/
abbrev logX : TSeries := term (-1) 1

/-! ### Additivity of transmonomials at a fixed height -/

/-- Within a fixed tower height, transmonomials multiply by **adding exponents** at the level
of the transmonomial group. -/
theorem mono_add_same (h : ℤ) (a b : ℝ) : mono h a + mono h b = mono h (a + b) := by
  unfold mono
  rw [← toLex_add, ← Finsupp.single_add]

/-! ### The law of exponents for one-term transseries -/

/-- **Law of exponents.**  `(level h)^a · (level h)^b = (level h)^{a+b}`. -/
theorem term_mul_term_same (h : ℤ) (a b : ℝ) : term h a * term h b = term h (a + b) := by
  unfold term
  rw [single_mul_single, mono_add_same, one_mul]

/-- `(level h)^0 = 1`: the exponent-zero transmonomial is the multiplicative unit. -/
theorem term_zero (h : ℤ) : term h 0 = 1 := by
  unfold term mono
  simp

/-- A one-term transseries is never zero. -/
theorem term_ne_zero (h : ℤ) (a : ℝ) : term h a ≠ 0 :=
  single_ne_zero one_ne_zero

/-- Inverse law: `(level h)^a · (level h)^{-a} = 1`. -/
theorem term_mul_neg (h : ℤ) (a : ℝ) : term h a * term h (-a) = 1 := by
  rw [term_mul_term_same, add_neg_cancel, term_zero]

/-- Every one-term transseries is a unit, with explicit inverse `term h (-a)`. -/
theorem isUnit_term (h : ℤ) (a : ℝ) : IsUnit (term h a) :=
  IsUnit.of_mul_eq_one _ (term_mul_neg h a)

/-- **Power law.**  `(level h)^a` raised to a natural power multiplies the exponent. -/
theorem term_pow (h : ℤ) (a : ℝ) : ∀ n : ℕ, (term h a) ^ n = term h (n * a)
  | 0 => by simp [term_zero]
  | n + 1 => by
    rw [pow_succ, term_pow h a n, term_mul_term_same]
    push_cast
    ring_nf

/-- The map `a ↦ term h a` packaged as a group homomorphism `(ℝ, +) →* TSeriesˣ`. -/
def termHom (h : ℤ) : Multiplicative ℝ →* TSeriesˣ where
  toFun a := (isUnit_term h (Multiplicative.toAdd a)).unit
  map_one' := by
    apply Units.ext
    simp only [IsUnit.unit_spec]
    exact term_zero h
  map_mul' a b := by
    apply Units.ext
    simp only [IsUnit.unit_spec, Units.val_mul]
    rw [term_mul_term_same]
    rfl

/-! ### The value group is unbounded: no dominant transmonomial -/

/-- **No maximal transmonomial.**  For every transmonomial `g` there is a strictly larger
one.  Asymptotically: the exp-tower `x, exp x, exp(exp x), …` never terminates, so no
transseries is asymptotically the largest. -/
theorem exists_gt (g : TransMono) : ∃ g' : TransMono, g < g' := by
  classical
  set f := ofLex g with hf
  by_cases hsupp : f.support.Nonempty
  · obtain ⟨i₀, hi₀mem, hi₀⟩ := f.support.exists_min_image id hsupp
    refine ⟨toLex (f + Finsupp.single (i₀ - 1) 1), ?_⟩
    rw [show g = toLex f from rfl, Finsupp.Lex.lt_iff]
    refine ⟨i₀ - 1, fun d hd => ?_, ?_⟩
    · simp only [ofLex_toLex, Finsupp.coe_add, Pi.add_apply, Finsupp.single_apply]
      rw [if_neg (by omega)]
      have hd' : d ∉ f.support := fun hmem => by
        have := hi₀ d hmem; simp only [id] at this; omega
      simp [Finsupp.notMem_support_iff.mp hd']
    · simp only [ofLex_toLex, Finsupp.coe_add, Pi.add_apply, Finsupp.single_eq_same]
      have hd' : (i₀ - 1) ∉ f.support := fun hmem => by
        have := hi₀ _ hmem; simp only [id] at this; omega
      simp [Finsupp.notMem_support_iff.mp hd']
  · rw [Finset.not_nonempty_iff_eq_empty, Finsupp.support_eq_empty] at hsupp
    refine ⟨toLex (Finsupp.single 0 1), ?_⟩
    rw [show g = toLex f from rfl, hsupp, Finsupp.Lex.lt_iff]
    refine ⟨0, fun d hd => ?_, ?_⟩
    · simp only [ofLex_toLex, Finsupp.coe_zero, Pi.zero_apply, Finsupp.single_apply]
      rw [if_neg (by omega)]
    · simp only [ofLex_toLex, Finsupp.coe_zero, Pi.zero_apply, Finsupp.single_eq_same]
      norm_num

/-! ### Non-Archimedean: no power of `x` dominates `exp x` -/

/-- The valuation of `x^n` is the transmonomial `mono 0 n`. -/
theorem orderTop_varX_pow (n : ℕ) : (varX ^ n).orderTop = (mono 0 (n : ℝ) : WithTop TransMono) := by
  rw [varX, term_pow, orderTop_term, mul_one]

/-- **Non-Archimedean dominance.**  For *every* natural number `n`, the valuation of `x^n`
is strictly below the valuation of `exp x`: no finite power of `x` ever catches up to `exp x`.
This is impossible for any (Laurent/Puiseux) power-series valuation, whose value group is
Archimedean. -/
theorem pow_var_lt_exp (n : ℕ) : (varX ^ n).orderTop < expX.orderTop := by
  rw [orderTop_varX_pow, expX, orderTop_term]
  exact_mod_cast WithTop.coe_lt_coe.mpr (exp_dominates_pow (n : ℝ))

end

end EMLTransseries