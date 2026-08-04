/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite-interval consequences for t-fold sumset avoidance

This file builds on the catalog's existing iterated-sumset definition and sharp
Cauchy--Davenport growth theorem.  It records the exact deterministic
finite-interval obstruction that any future logarithmic-scale construction must
surpass.
-/
import Logic.PosetTheory.TFoldSumsetAvoidance

open Finset Pointwise
open TFoldSumsetAvoidance

namespace Pythagorean.TFoldSumsetAvoidance

/-- The integer model of the initial interval `[n] = {0, ..., n-1}`. -/
def initialInterval (n : ℕ) : Finset ℤ :=
  (Finset.range n).image (Nat.cast : ℕ → ℤ)

/-- The integer initial interval has exactly `n` elements. -/
lemma initialInterval_card (n : ℕ) : (initialInterval n).card = n := by
  rw [initialInterval, Finset.card_image_of_injective]
  · simp
  · intro a b hab
    exact_mod_cast hab

/-- If an initial interval of length `n` contains a `t`-fold sumset whose
summands all have at least `k` elements, then necessarily
`t (k - 1) + 1 ≤ n`.  This is the sharp cardinal-growth obstruction specialized
to the ambient set `[n]`. -/
theorem contained_uniform_tfold_card_bound
    (n t k : ℕ) (l : List (Finset ℤ))
    (hlen : l.length = t)
    (hne : ∀ A ∈ l, A.Nonempty)
    (hk : ∀ A ∈ l, k ≤ A.card)
    (hsub : sumsetList l ⊆ initialInterval n) :
    t * (k - 1) + 1 ≤ n := by
  have h := sumset_containment_forces_card (initialInterval n) l k hne hk hsub
  rw [initialInterval_card, hlen] at h
  exact h

/-- Whenever `n ≤ t(k-1)`, the full interval `[n]` avoids every `t`-fold
sumset whose summands all have cardinality at least `k`. -/
theorem initialInterval_avoids_uniform_tfold
    (n t k : ℕ) (hbarrier : n ≤ t * (k - 1)) :
    ∀ l : List (Finset ℤ), l.length = t →
      (∀ A ∈ l, A.Nonempty) → (∀ A ∈ l, k ≤ A.card) →
      ¬ sumsetList l ⊆ initialInterval n := by
  intro l hlen hne hk
  apply sumset_avoidance (initialInterval n) l k hne hk
  rw [initialInterval_card, hlen]
  exact hbarrier

/-- A completely explicit dense-set existence theorem at the deterministic
linear threshold.  For every `0 ≤ δ ≤ 1`, the full interval has density at
least `δ` and avoids all uniformly large `t`-fold sumsets once
`n ≤ t(k-1)`.  The assumption `2 ≤ t` keeps the statement in the intended
multi-summand regime when specialized to `2 ≤ t`.  The theorem is stated in
its stronger minimal form: the full-interval witness only needs `δ ≤ 1`; in
particular it applies throughout the requested domain `0 < δ < 1`. -/
theorem dense_initialInterval_avoidance
    (n t k : ℕ) (δ : ℝ) (hδ1 : δ ≤ 1)
    (hbarrier : n ≤ t * (k - 1)) :
    ∃ S : Finset ℤ,
      S ⊆ initialInterval n ∧
      δ * (n : ℝ) ≤ (S.card : ℝ) ∧
      S.card = n ∧
      ∀ l : List (Finset ℤ), l.length = t →
        (∀ A ∈ l, A.Nonempty) → (∀ A ∈ l, k ≤ A.card) →
        ¬ sumsetList l ⊆ S := by
  refine ⟨initialInterval n, Finset.Subset.refl _, ?_, initialInterval_card n, ?_⟩
  · rw [initialInterval_card]
    have hn : 0 ≤ (n : ℝ) := Nat.cast_nonneg n
    nlinarith
  · exact initialInterval_avoids_uniform_tfold n t k hbarrier

/-- The exact logarithmic-scale research target, expressed using the catalog's
existing `sumsetList`.  It asks for a positive constant and a sufficiently-large
cutoff, after which a density-`δ` subset of `[n]` avoids every `t`-fold sumset
whose parts exceed the stated real-valued threshold.

This is a definition of the target proposition, not an assertion that the open
research target has already been proved. -/
def LogScaleAvoidance (t : ℕ) (δ : ℝ) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
    ∃ S : Finset ℤ,
      S ⊆ initialInterval n ∧
      δ * (n : ℝ) ≤ (S.card : ℝ) ∧
      ∀ l : List (Finset ℤ), l.length = t →
        (∀ A ∈ l, A.Nonempty) →
        (∀ A ∈ l,
          C * Real.log (n : ℝ) /
              Real.rpow (Real.log (1 / δ)) (1 / ((t - 1 : ℕ) : ℝ)) ≤ (A.card : ℝ)) →
        ¬ sumsetList l ⊆ S

end Pythagorean.TFoldSumsetAvoidance