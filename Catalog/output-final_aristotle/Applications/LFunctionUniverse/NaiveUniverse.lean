import Mathlib

/-!
# The L-function universe, part I: the naive universe is uncountable

An L-function is, at bottom, a Dirichlet series `L(s) = ∑ a(k) k^{-s}`, and is
completely determined by its coefficient sequence `a : ℕ → ℂ`.  If we impose *no*
arithmetic constraints, this "universe of all Dirichlet series" is enormous: the
type `ℕ → ℂ` of coefficient sequences has the cardinality of the continuum, hence
is uncountable.

This file records that fact.  It is the counterpoint to the main theme of the
project: the interesting statement is not that *some* space of L-functions is big,
but that once one imposes the arithmetic axioms (Euler product, functional
equation, periodicity/algebraicity of coefficients), the surviving family collapses
to a *countable* one.  See `PeriodicUniverse.lean` and `SelbergCensus.lean`.
-/

open scoped Classical

namespace LFunctionUniverse

/-- The space of `Bool`-valued sequences is uncountable: there are `2 ^ ℵ₀` of
them, which strictly exceeds `ℵ₀` by Cantor's theorem. -/
theorem boolSequences_uncountable : ¬ Countable (ℕ → Bool) := by
  intro h
  exact absurd (Cardinal.mk_le_aleph0_iff.mpr h) (by
    rw [Cardinal.mk_arrow]
    simp only [Cardinal.mk_bool, Cardinal.mk_nat, Cardinal.lift_id]
    exact not_le.mpr (Cardinal.cantor' _ (by norm_num)))

/-- **The naive L-function universe is uncountable.**

The coefficient sequences of arbitrary Dirichlet series form the type `ℕ → ℂ`,
which is uncountable.  Indeed, the `{0,1}`-valued sequences already inject into it,
and there are uncountably many of those. -/
theorem allDirichletSeries_uncountable : ¬ Countable (ℕ → ℂ) := by
  intro h
  have hb : Countable (ℕ → Bool) := by
    apply Function.Injective.countable
      (f := fun a : ℕ → Bool => (fun k => if a k then (1 : ℂ) else 0))
    intro a b hab
    funext k
    have := congrFun hab k
    by_cases ha : a k <;> by_cases hb : b k <;> simp [ha, hb] at this ⊢
  exact boolSequences_uncountable hb

/-- Even the sub-universe of sequences taking only the two values `0` and `1`
(a caricature of "coefficients in a two-element alphabet") is already uncountable. -/
theorem zeroOneSequences_uncountable :
    ¬ {a : ℕ → ℂ | ∀ k, a k = 0 ∨ a k = 1}.Countable := by
  intro h
  have hc := h.to_subtype
  apply boolSequences_uncountable
  have hinj : Function.Injective
      (fun a : ℕ → Bool => (⟨fun k => if a k then (1 : ℂ) else 0,
        fun k => by by_cases ha : a k <;> simp [ha]⟩ :
        {a : ℕ → ℂ | ∀ k, a k = 0 ∨ a k = 1})) := by
    intro a b hab
    funext k
    have := congrFun (Subtype.ext_iff.mp hab) k
    by_cases ha : a k <;> by_cases hb : b k <;> simp [ha, hb] at this ⊢
  exact hinj.countable

end LFunctionUniverse