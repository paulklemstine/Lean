import Mathlib
import Applications.TransitionEndomorphism

/-!
# Iterates as transition endomorphisms

This companion file specializes the transition-endomorphism API of
`Applications.TransitionEndomorphism` to a *constant* sequence, recovering the
ordinary operator powers `g ^ n` of a single endomorphism `g : V →ₗ[K] V`.

The identity `transEndo (fun _ => g) i n = g ^ n` lets the general cocycle
results descend, for free, to classical facts about iterates: the rank of the
iterates `g ^ n` is antitone, and injectivity of `g` propagates to all powers.

-- !-- Lab Notes -- !--
Hypothesis: The autonomous (time-independent) case of a discrete linear cocycle
  is exactly the monoid of operator powers, so every cocycle theorem must
  specialize to a statement about `g ^ n`.
Experiment: Proved `transEndo (fun _ => g) i n = g ^ n` by induction (`pow_succ'`
  plus the End-monoid identities `End.one_eq_id`, `mul = comp`), then transported
  `finrank_range_transEndo_antitone` and `transEndo_injective` across it.
Analysis: The specialization is a clean rewrite bridge; the work is entirely in
  matching `LinearMap.comp`/`LinearMap.id` to the multiplicative `End V` structure.
Critique: Each corollary genuinely *uses* a previous-file theorem (not re-proved);
  none is trivial — they rest on induction and the cocycle identity upstream.
Synthesis: A two-file cycle: a general transition-operator theory and its
  autonomous specialization to operator powers.
-- !-- Lab Notes -- !--
-/

open LinearMap Module

namespace TransitionEndomorphism

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- A constant sequence's transition endomorphism is an ordinary operator power. -/
theorem transEndo_const (g : V →ₗ[K] V) (i n : ℕ) :
    transEndo (fun _ => g) i n = g ^ n := by
  induction n with
  | zero => simp [transEndo, ← End.one_eq_id]
  | succ n ih => rw [transEndo_succ, ih, pow_succ']; rfl

/-- The rank of the iterates `g ^ n` is antitone in `n`. -/
theorem finrank_range_pow_antitone [FiniteDimensional K V]
    (g : V →ₗ[K] V) {m n : ℕ} (h : n ≤ m) :
    finrank K (range (g ^ m)) ≤ finrank K (range (g ^ n)) := by
  have := finrank_range_transEndo_antitone (fun _ => g) 0 h
  rwa [transEndo_const, transEndo_const] at this

/-- Injectivity of `g` propagates to every power `g ^ n`. -/
theorem pow_injective_of (g : V →ₗ[K] V) (n : ℕ) (hg : Function.Injective g) :
    Function.Injective (g ^ n) := by
  have := transEndo_injective (fun _ => g) 0 n (fun k _ => hg)
  rwa [transEndo_const] at this

end TransitionEndomorphism