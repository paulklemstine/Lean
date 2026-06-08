/-
  # Tropical-Probabilistic Bridge: Definitions

  This module defines the core structures that bridge the probabilistic method
  in combinatorics with tropical (min-plus) algebra.

  ## Novel Definitions

  - `TropicalCostWitness`: Captures when a tropical optimization problem over a
    finite universe certifies the existence of a combinatorial object via the
    first moment / counting principle.

  - `TropicalLLLConfig`: Algebraic formulation of the Lovász Local Lemma conditions
    in the language of tropical fixed-point equations.

  - `MinPlusMoment`: The tropical analogue of the expected value — the minimum
    of a cost function over a finite domain, related to the first moment method
    by duality.

  ## Mathematical Context

  The probabilistic method proves existence by showing that a random object has
  the desired property with positive probability. Equivalently, among all objects,
  the minimum "cost" (number of violated constraints) is zero.

  This minimum is precisely a tropical (min-plus) computation: the "tropical
  expected value" min_{x ∈ Ω} cost(x) = 0 iff a good object exists.
-/
import Mathlib

open Finset BigOperators

namespace TropicalProbBridge

/-- A tropical cost witness certifies that a combinatorial optimization
    problem has a zero-cost solution. The `avg_bound` field encodes the
    first moment condition: ∑ costs < |universe|. -/
structure TropicalCostWitness (α : Type*) [Fintype α] where
  /-- Cost function: number of "bad" events for each outcome -/
  cost : α → ℕ
  /-- The first moment bound: total cost < universe size -/
  avg_bound : Finset.univ.sum cost < Fintype.card α

/-- Configuration for an algebraic LLL argument over n events. -/
structure TropicalLLLConfig (n : ℕ) where
  /-- Upper bounds on event probabilities -/
  probs : Fin n → ℝ
  /-- LLL witness values -/
  witnesses : Fin n → ℝ
  /-- Dependency graph -/
  deps : Fin n → Finset (Fin n)
  /-- All probabilities are nonneg -/
  prob_nonneg : ∀ i, 0 ≤ probs i
  /-- All probabilities are < 1 -/
  prob_lt_one : ∀ i, probs i < 1
  /-- All witnesses are positive -/
  wit_pos : ∀ i, 0 < witnesses i
  /-- All witnesses are < 1 -/
  wit_lt_one : ∀ i, witnesses i < 1
  /-- The LLL domination condition -/
  lll_condition : ∀ i, probs i ≤
    witnesses i * ∏ j ∈ deps i, (1 - witnesses j)

/-- The min-plus moment: minimum value of a function over a finite type. -/
noncomputable def minPlusMoment {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) : ℕ :=
  Finset.univ.inf' Finset.univ_nonempty f

/-- The tropical deficiency measures how far a cost function is from having
    a zero-cost element. It equals 0 iff a witness exists. -/
noncomputable def tropicalDeficiency {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) : ℕ :=
  minPlusMoment f

end TropicalProbBridge