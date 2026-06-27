/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: The Exponential-Substitution Automorphism

The substitution `x ↦ exp x` is the defining *self-map* of the transseries world: it raises
every tower height by one (`x ↦ exp x`, `exp x ↦ exp(exp x)`, `log x ↦ x`, …) while leaving
real exponents untouched.  This file realizes that substitution as a genuine **ring
homomorphism** of the transseries field `EMLTransseries.TSeries` built in `Field.lean`, by
*relabeling* the transmonomial group `Lex (ℤ →₀ ℝ)` along the index translation `i ↦ i - 1`
(tower height `h ↦ h + 1`).

The construction goes through Mathlib's `HahnSeries.embDomainRingHom`, whose hypotheses are
exactly: an additive group hom on the value group that is injective and **order-reflecting**.
The order-reflection property is the mathematical heart — it says the exp-substitution
*preserves asymptotic dominance*, which it does because translating finsupp indices by a
monotone bijection permutes the lexicographic order isomorphically.

## Main results

- `EMLTransseries.shift`            : the index-translation map on transmonomials.
- `EMLTransseries.shift_mono`       : `shift (mono h a) = mono (h+1) a` (raises tower height).
- `EMLTransseries.shift_lt_iff`     : exp-substitution **preserves dominance** (`<` iff).
- `EMLTransseries.expShift`         : the ring homomorphism `TSeries →+* TSeries`.
- `EMLTransseries.expShift_term`    : `expShift (term h a) = term (h+1) a`.
- `EMLTransseries.expShift_var`     : `expShift x = exp x` (the headline substitution fact).
- `EMLTransseries.expShift_C`       : exp-substitution fixes the constant subfield `ℝ`.
- `EMLTransseries.expShift_injective`: exp-substitution is injective (an embedding).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the asymptotic operation `x ↦ exp x` is not merely analytic — it
should lift to a *field endomorphism* of the formal transseries model, acting on the value
group by shifting tower heights and acting trivially on real coefficients.

Experiment (Experimenter): we encode the height shift as `Finsupp.equivMapDomain` along the
bijection `i ↦ i - 1` (so index `-h` becomes `-(h+1)`).  `HahnSeries.embDomainRingHom`
then needs (i) an `AddMonoidHom` — obtained from `equivMapDomain`'s additivity; (ii)
injectivity — from `Finsupp.mapDomain_injective`; (iii) order-reflection `f g ≤ f g' ↔ g ≤ g'`
— the crucial lemma `shift_lt_iff`, proved through `Finsupp.Lex.lt_iff` by transporting the
"first differing index" along the monotone bijection.

Analysis (Analyst): the order-reflection lemma is where "transseries" really shows up.  A
lexicographic comparison is decided at the *least* index of difference; a monotone bijection
of the index set maps least-index-of-difference to least-index-of-difference, so the order is
preserved.  This makes `exp`-substitution an *order automorphism* of the value group, hence a
valuation-preserving ring map — i.e. it respects all asymptotic scales simultaneously.

Critique (Critic): is this a renaming of Mathlib's `embDomainRingHom`?  No: the whole content
is supplying the three hypotheses for *this specific* shift, the load-bearing one being
`shift_lt_iff` (a real `Finsupp.Lex` argument, not `rfl`).  The payoff `expShift_var :
expShift x = exp x` is the precise statement that the formal automorphism *is* the
exp-substitution, and `expShift_C` certifies it fixes the scalar field — together they show
the map is a non-trivial field endomorphism realizing a transseries-only operation.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.Field
import EML.Transseries.ExponentLaws

open HahnSeries

namespace EMLTransseries

noncomputable section

/-- The index translation `i ↦ i - 1` on `ℤ`, the engine of the exp-substitution. -/
def shiftEquiv : ℤ ≃ ℤ := Equiv.subRight 1

/-- The **exp-substitution** acting on transmonomials: relabel the tower-height index by
`i ↦ i - 1`, i.e. raise every tower height by one. -/
def shift (x : TransMono) : TransMono := toLex (Finsupp.equivMapDomain shiftEquiv (ofLex x))

/-- `shift` as an additive group homomorphism on the transmonomial group. -/
def shiftHom : TransMono →+ TransMono where
  toFun := shift
  map_zero' := by simp [shift]
  map_add' x y := by
    simp only [shift, ofLex_add, Finsupp.equivMapDomain_eq_mapDomain, Finsupp.mapDomain_add,
      toLex_add]

theorem shift_inj : Function.Injective shift := by
  intro x y h
  have h2 := congrArg ofLex h
  simp only [shift, ofLex_toLex, Finsupp.equivMapDomain_eq_mapDomain] at h2
  exact ofLex_inj.mp (Finsupp.mapDomain_injective shiftEquiv.injective h2)

/-- **Exp-substitution preserves dominance.**  The height-shift is an order *isomorphism* of
the transmonomial group: `shift x < shift y ↔ x < y`.  Equivalently, `x ↦ exp x` respects all
asymptotic scales. -/
theorem shift_lt_iff (x y : TransMono) : shift x < shift y ↔ x < y := by
  unfold shift
  rw [Finsupp.Lex.lt_iff, Finsupp.Lex.lt_iff]
  constructor
  · rintro ⟨i, hlt, hi⟩
    refine ⟨shiftEquiv.symm i, fun d hd => ?_, ?_⟩
    · have := hlt (shiftEquiv d) (by simp [shiftEquiv, Equiv.subRight] at *; omega)
      simpa [Finsupp.equivMapDomain_apply] using this
    · simpa [Finsupp.equivMapDomain_apply] using hi
  · rintro ⟨i, hlt, hi⟩
    refine ⟨shiftEquiv i, fun d hd => ?_, ?_⟩
    · have := hlt (shiftEquiv.symm d) (by simp [shiftEquiv, Equiv.subRight] at *; omega)
      simpa [Finsupp.equivMapDomain_apply] using this
    · simpa [Finsupp.equivMapDomain_apply] using hi

theorem shiftHom_le_iff (g g' : TransMono) : shiftHom g ≤ shiftHom g' ↔ g ≤ g' := by
  show shift g ≤ shift g' ↔ g ≤ g'
  rw [le_iff_lt_or_eq, le_iff_lt_or_eq, shift_lt_iff]
  constructor
  · rintro (h | h)
    · exact Or.inl h
    · exact Or.inr (shift_inj h)
  · rintro (h | h)
    · exact Or.inl h
    · exact Or.inr (by rw [h])

/-- **The exp-substitution ring homomorphism** `x ↦ exp x` on transseries, built from the
order-automorphism `shift` of the value group via `HahnSeries.embDomainRingHom`. -/
def expShift : TSeries →+* TSeries :=
  HahnSeries.embDomainRingHom shiftHom shift_inj shiftHom_le_iff

/-- The height shift on a single transmonomial: `(level h)^a ↦ (level (h+1))^a`. -/
theorem shift_mono (h : ℤ) (a : ℝ) : shift (mono h a) = mono (h + 1) a := by
  unfold shift mono
  rw [ofLex_toLex]
  congr 1
  ext i
  rw [Finsupp.equivMapDomain_apply]
  simp only [shiftEquiv, Equiv.subRight, Equiv.coe_fn_symm_mk, Finsupp.single_apply]
  rcases eq_or_ne (-h) (i + 1) with h1 | h1
  · rw [if_pos h1, if_pos (by omega)]
  · rw [if_neg h1, if_neg (by omega)]

/-- **Exp-substitution on a one-term transseries** raises the tower height by one:
`(level h)^a ↦ (level (h+1))^a`. -/
theorem expShift_term (h : ℤ) (a : ℝ) : expShift (term h a) = term (h + 1) a := by
  unfold expShift term
  rw [HahnSeries.embDomainRingHom_apply, HahnSeries.embDomain_single]
  show single (shift (mono h a)) (1 : ℝ) = single (mono (h + 1) a) 1
  rw [shift_mono]

/-- **The headline fact.**  Exp-substitution sends `x` to `exp x`. -/
theorem expShift_var : expShift varX = expX := by
  rw [varX, expShift_term]; rfl

/-- Exp-substitution sends `exp x` to `exp(exp x)`. -/
theorem expShift_exp : expShift expX = term 2 1 := by
  rw [expX, expShift_term]; rfl

/-- Exp-substitution sends `log x` to `x`. -/
theorem expShift_log : expShift logX = varX := by
  rw [logX, expShift_term]; rfl

/-- **Exp-substitution fixes the constant subfield** `ℝ ↪ TSeries`: it acts trivially on
scalars, as any algebra/substitution map should. -/
theorem expShift_C (r : ℝ) : expShift (HahnSeries.C r) = HahnSeries.C r :=
  HahnSeries.embDomainRingHom_C

/-- Exp-substitution is injective: it is an embedding of the transseries field into itself. -/
theorem expShift_injective : Function.Injective expShift :=
  HahnSeries.embDomain_injective

end

end EMLTransseries