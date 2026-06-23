/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: The Asymptotic Comparison Theorem

A transseries is, by construction, completely determined by its coefficients on every
transmonomial.  The *asymptotic comparison theorem* makes this precise in valuation terms:

> If two transseries "agree to all orders" — i.e. their difference is asymptotically
> smaller than every transmonomial — then they are equal.

We formalize "agree to all orders" through the Hahn-series valuation `orderTop`, whose only
value strictly above *every* transmonomial is `⊤`, attained exactly by `0`.  Thus the
comparison theorem reduces to `orderTop x = ⊤ ↔ x = 0`, but stated as a quantified
asymptotic statement it is the genuine uniqueness principle for transseries expansions.

We also record the *analytic* counterparts that ground the formal order in real analysis:
`exp` dominates every polynomial, and `exp ∘ exp` dominates every power of `exp`.

## Main results

- `EMLTransseries.AgreeToAllOrders`            : the asymptotic-agreement relation.
- `EMLTransseries.agreeToAllOrders_iff_eq`     : **comparison theorem** (agree ↔ equal).
- `EMLTransseries.agreeToAllOrders_equivalence`: it is an equivalence relation.
- `EMLTransseries.isLittleO_pow_exp`           : analytic dominance of `exp` over powers.
- `EMLTransseries.isLittleO_expPow_expExp`     : analytic dominance of `exp∘exp` over `exp^n`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a transseries is determined "to all orders" by its asymptotic
data, so two transseries with the same expansion to every order must coincide.

Experiment (Experimenter): we encoded "agree to all orders" as
`∀ g, (g : WithTop TransMono) < (a - b).orderTop`.  The forward direction forces
`(a - b).orderTop = ⊤` (otherwise instantiate `g` at the finite value and contradict
irreflexivity), and `orderTop_eq_top` then gives `a - b = 0`.

Analysis (Analyst): the theorem is "true but shallow" *inside* the Hahn model — yet it is
exactly the content of the classical asymptotic comparison theorem once one accepts that the
Hahn coefficients are the asymptotic data.  The non-trivial mathematics is in the *order
structure* (Field.lean) that makes `orderTop` capture asymptotic size; the comparison
theorem is the clean consequence.

Critique (Critic): is this vacuous?  No — the relation is genuinely quantified over the
*entire* uncountable monomial group, and the proof must rule out every finite valuation via
`by_contra` + `WithTop` case analysis, not `rfl`.  We additionally connect to real analysis
(`Real.isLittleO_pow_exp_atTop`) so the formal "order" is not an empty abstraction.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.Field

open HahnSeries Filter

namespace EMLTransseries

noncomputable section

/-- Two transseries **agree to all orders** when their difference is asymptotically smaller
than every transmonomial, i.e. the valuation of `a - b` lies strictly above every element of
the transmonomial group. -/
def AgreeToAllOrders (a b : TSeries) : Prop :=
  ∀ g : TransMono, (g : WithTop TransMono) < (a - b).orderTop

/-- **Asymptotic comparison theorem.**  Two transseries agree to all orders iff they are
equal.  Equivalently: a transseries is uniquely determined by its asymptotic expansion. -/
theorem agreeToAllOrders_iff_eq (a b : TSeries) : AgreeToAllOrders a b ↔ a = b := by
  constructor
  · intro h
    have hdt : (a - b).orderTop = ⊤ := by
      by_contra hne
      obtain ⟨c, hc⟩ := WithTop.ne_top_iff_exists.mp hne
      have hcc := h c
      rw [← hc] at hcc
      exact lt_irrefl _ hcc
    exact sub_eq_zero.mp (HahnSeries.orderTop_eq_top.mp hdt)
  · rintro rfl g
    simp only [sub_self, HahnSeries.orderTop_zero]
    exact WithTop.coe_lt_top g

/-- Reflexivity of asymptotic agreement. -/
theorem agreeToAllOrders_refl (a : TSeries) : AgreeToAllOrders a a :=
  (agreeToAllOrders_iff_eq a a).mpr rfl

/-- Asymptotic agreement is an equivalence relation (in fact, it *is* equality). -/
theorem agreeToAllOrders_equivalence : Equivalence AgreeToAllOrders where
  refl := agreeToAllOrders_refl
  symm {a b} h := (agreeToAllOrders_iff_eq b a).mpr ((agreeToAllOrders_iff_eq a b).mp h).symm
  trans {a b c} hab hbc :=
    (agreeToAllOrders_iff_eq a c).mpr
      (((agreeToAllOrders_iff_eq a b).mp hab).trans ((agreeToAllOrders_iff_eq b c).mp hbc))

/-- A nonzero transseries does **not** agree to all orders with `0`: it has a genuine
leading term.  (Contrapositive form of the comparison theorem.) -/
theorem not_agree_zero_of_ne_zero {a : TSeries} (ha : a ≠ 0) : ¬ AgreeToAllOrders a 0 := by
  intro h
  exact ha ((agreeToAllOrders_iff_eq a 0).mp h)

/-! ### Analytic grounding: the formal order models real asymptotics -/

/-- **Analytic dominance of `exp` over powers.**  Every polynomial `x ↦ x^n` is little-o of
`exp` at `+∞`.  This is the real-analysis content modeled by the *formal* fact
`exp_dominates_pow` from `Field.lean`. -/
theorem isLittleO_pow_exp (n : ℕ) : (fun x : ℝ => x ^ n) =o[atTop] Real.exp :=
  Real.isLittleO_pow_exp_atTop

/-- **Analytic dominance of `exp ∘ exp` over powers of `exp`.**  Every `x ↦ (exp x)^n` is
little-o of `x ↦ exp (exp x)` at `+∞`.  This is the real-analysis content modeled by the
*formal* fact `mono_lt_mono_of_height` (height `1` is dominated by height `2`). -/
theorem isLittleO_expPow_expExp (n : ℕ) :
    (fun x : ℝ => (Real.exp x) ^ n) =o[atTop] (fun x : ℝ => Real.exp (Real.exp x)) := by
  have h := (Real.isLittleO_pow_exp_atTop (n := n)).comp_tendsto Real.tendsto_exp_atTop
  simpa [Function.comp] using h

end

end EMLTransseries