/-
# Non-Archimedean Finitely Additive Probability: Definitions

This module defines a finitely additive probability structure valued in an
ordered field `K`, along with uniform grid probabilities, expectation, and
the key notion of refinement for observable functions.
-/
import Mathlib

open Finset BigOperators

/-- A finitely additive probability valued in an ordered field `K`.
This is the core structure for non-Archimedean probability:
it replaces countable additivity with finite additivity, allowing
every atom to carry positive mass even when the total mass is 1. -/
structure NAProbability (α : Type*) (K : Type*)
    [Fintype α] [DecidableEq α]
    [Field K] [LinearOrder K] [IsStrictOrderedRing K] where
  mass : Finset α → K
  empty_mass : mass ∅ = 0
  add_mass : ∀ s t : Finset α, Disjoint s t → mass (s ∪ t) = mass s + mass t
  total_mass : mass Finset.univ = 1
  nonneg_mass : ∀ s : Finset α, 0 ≤ mass s

/-- Expectation of an observable `X : α → K` under a non-Archimedean probability. -/
noncomputable def NAExpectation {α K : Type*} [Fintype α] [DecidableEq α]
    [Field K] [LinearOrder K] [IsStrictOrderedRing K]
    (P : NAProbability α K) (X : α → K) : K :=
  ∑ a : α, X a * P.mass ({a})

/-- The uniform probability on `Fin (n+1)` with singleton mass `1/(n+1)`. -/
noncomputable def gridUniformProb (n : ℕ) : NAProbability (Fin (n + 1)) ℚ where
  mass s := (s.card : ℚ) / (n + 1 : ℚ)
  empty_mass := by simp
  add_mass := by
    intro s t hst
    rw [Finset.card_union_of_disjoint hst]
    push_cast; ring
  total_mass := by
    rw [Finset.card_fin]; push_cast
    exact div_self (by positivity)
  nonneg_mass := fun s => by positivity

/-- Singleton mass of the uniform grid probability. -/
theorem gridUniformProb_singleton (n : ℕ) (i : Fin (n + 1)) :
    (gridUniformProb n).mass {i} = 1 / (n + 1 : ℚ) := by
  simp [gridUniformProb, Finset.card_singleton]

/-- Lift a coarse-grid observable to a fine grid by block embedding.
Point `j : Fin (k * (n+1))` maps to coarse point `⟨j / k, ...⟩`.
Each coarse grid point has exactly `k` preimages under this map. -/
def refineObservable {n : ℕ} (k : ℕ) (_hk : 0 < k)
    (X : Fin (n + 1) → ℚ) : Fin (k * (n + 1)) → ℚ :=
  fun j => X ⟨j.val / k, Nat.div_lt_of_lt_mul (by omega)⟩