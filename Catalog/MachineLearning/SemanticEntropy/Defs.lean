/-
# Semantic Entropy Theory: Definitions

This file introduces a formal framework for studying the relationship between
semantic compression (model elimination) and proof complexity. The central
insight is that when a theory strengthening destroys model volume, any
proof system with bounded information per step must pay a proportional cost.

## Main Definitions

- `FiniteTheory α` — a theory over a finite type, given by its model set
- `Strengthens` — the strengthening relation (model subset inclusion)
- `semanticEntropy` — logarithmic measure of model count
- `eliminationCost` — number of models removed in a strengthening
- `BoundedHalvingChain` — a chain of theories where each step removes at most
  half the remaining models
- `coordTheory` — theories on bitstrings defined by fixing coordinates
-/

import Mathlib

open Finset Real BigOperators

/-- A finite theory over a type `α`, represented by its set of models. -/
structure FiniteTheory (α : Type*) where
  models : Finset α

namespace FiniteTheory

variable {α : Type*} [DecidableEq α]

/-- Theory `T₂` strengthens `T₁` if every model of `T₂` is a model of `T₁`. -/
def Strengthens (T₁ T₂ : FiniteTheory α) : Prop :=
  T₂.models ⊆ T₁.models

/-- Semantic entropy: log₂ of the model count. -/
noncomputable def semanticEntropy (T : FiniteTheory α) : ℝ :=
  Real.logb 2 (T.models.card : ℝ)

/-- The number of models eliminated when strengthening from `S` to `T`. -/
def eliminationCost (S T : FiniteTheory α) : ℕ :=
  (S.models \ T.models).card

/-- Model count as a natural number. -/
def modelCount (T : FiniteTheory α) : ℕ := T.models.card

/-- The trivial (unconstrained) theory: everything is a model. -/
def trivialTheory [Fintype α] : FiniteTheory α where
  models := Finset.univ

/-- The empty (inconsistent) theory: nothing is a model. -/
def emptyTheory : FiniteTheory α where
  models := ∅

/-- A bounded-shrink chain from `S` to `T` of length `k`:
    a sequence of theories where each step removes at most half the models. -/
structure BoundedHalvingChain (S T : FiniteTheory α) (k : ℕ) where
  chain : Fin (k + 1) → FiniteTheory α
  start : chain ⟨0, Nat.zero_lt_succ k⟩ = S
  stop : chain ⟨k, Nat.lt_succ_of_le le_rfl⟩ = T
  mono : ∀ i : Fin k, (chain i.succ).models ⊆ (chain i.castSucc).models
  halving : ∀ i : Fin k, (chain i.castSucc).models.card ≤ 2 * (chain i.succ).models.card

/-- A coordinate theory on `Fin n → Bool`: the set of all bitstrings that equal `true`
    at every position in a given constraint set `A`. -/
def coordTheory (n : ℕ) (A : Finset (Fin n)) : FiniteTheory (Fin n → Bool) where
  models := Finset.univ.filter (fun f => ∀ i ∈ A, f i = true)

/-- A proper `q`-coloring of a simple graph: adjacent vertices get different colors. -/
def coloringTheory [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] (q : ℕ) :
    FiniteTheory (α → Fin q) where
  models := Finset.univ.filter (fun c => ∀ u v, G.Adj u v → c u ≠ c v)

end FiniteTheory