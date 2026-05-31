/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exchange Family Descent Complexity: Definitions

## Overview

An **exchange family** is a combinatorial structure modeling iterative optimization:
a set of states equipped with a natural-number-valued measure and a binary
exchange relation that strictly decreases the measure at each step. The central
invariant is the **descent depth** — the worst-case number of exchanges needed
to reach a minimum from any starting state.

This framework unifies:
- Local search algorithms (measure = objective, exchange = neighborhood move)
- Simplex method pivoting (measure = reduced cost, exchange = pivot)
- Tropical circuit depth (measure = path length, exchange = edge traversal)

## Main Definitions

- `ExchangeFamily α` — measure + exchange relation with strict decrease
- `IsDescentChain` — valid sequence of exchanges
- `chainCost` — total cost of a weighted descent chain
- `TropicalDescentValuation` — cost structure on exchanges (novel concept)
- `ExchangeFamily.prod` — product tensorization of exchange families
- `DescentComplexityClass` — bundled exchange family with depth bounds
- `ExchangeFamily.Morphism` — structure-preserving maps

## Keywords

exchange family, descent complexity, tropical valuation, iterative optimization,
measure theory, well-founded relations, circuit depth, product tensorization
-/

import Mathlib

open Finset Function

/-! ## Core Definitions -/

/-- An **exchange family** on a type `α`: a measure function `μ : α → ℕ` and
an exchange relation such that every exchange strictly decreases the measure.
This is the fundamental abstraction of iterative improvement algorithms. -/
structure ExchangeFamily (α : Type*) where
  /-- The potential/measure function, valued in ℕ for well-foundedness -/
  measure : α → ℕ
  /-- The exchange relation: `exchange x y` means we can move from x to y -/
  exchange : α → α → Prop
  /-- Every exchange strictly decreases the measure -/
  exchange_decreasing : ∀ x y, exchange x y → measure y < measure x

namespace ExchangeFamily

variable {α β γ : Type*}

/-! ### Descent Chains -/

/-- A **descent chain** is a list where consecutive elements are related by exchange.
This models a sequence of improvement steps in an optimization process. -/
def IsDescentChain (E : ExchangeFamily α) : List α → Prop
  | [] => True
  | [_] => True
  | x :: y :: rest => E.exchange x y ∧ E.IsDescentChain (y :: rest)

/-- IsDescentChain for a single element is trivially true. -/
@[simp]
theorem isDescentChain_singleton (E : ExchangeFamily α) (x : α) :
    E.IsDescentChain [x] = True := rfl

/-- IsDescentChain for cons-cons unfolds to exchange ∧ tail chain. -/
theorem isDescentChain_cons_cons (E : ExchangeFamily α) (x y : α) (rest : List α) :
    E.IsDescentChain (x :: y :: rest) ↔ E.exchange x y ∧ E.IsDescentChain (y :: rest) :=
  Iff.rfl

/-- The tail of a descent chain is a descent chain. -/
theorem isDescentChain_tail (E : ExchangeFamily α) (x : α) (rest : List α)
    (h : E.IsDescentChain (x :: rest)) : E.IsDescentChain rest := by
  cases rest with
  | nil => trivial
  | cons y rest' => exact h.2

/-! ### Weighted Descent Chains (Tropical Descent Valuations) -/

/-- A **tropical descent valuation** assigns a positive cost to each exchange step.
This creates a dual view of descent complexity: not just counting steps (depth),
but measuring their total computational weight (cost).

The name "tropical" comes from the connection to tropical geometry: the cost
function plays the role of a tropical metric on the exchange graph, and the
total chain cost is the tropical path length. -/
structure TropicalDescentValuation (E : ExchangeFamily α) where
  /-- Cost of performing an exchange from x to y -/
  cost : α → α → ℕ
  /-- Costs are positive for actual exchanges -/
  cost_pos : ∀ x y, E.exchange x y → 0 < cost x y

/-- The **total cost** of a descent chain under a tropical valuation.
This is the sum of exchange costs along the chain. -/
def chainCost {E : ExchangeFamily α} (V : TropicalDescentValuation E) :
    List α → ℕ
  | [] => 0
  | [_] => 0
  | x :: y :: rest => V.cost x y + chainCost V (y :: rest)

@[simp]
theorem chainCost_nil {E : ExchangeFamily α} (V : TropicalDescentValuation E) :
    chainCost V [] = 0 := rfl

@[simp]
theorem chainCost_singleton {E : ExchangeFamily α} (V : TropicalDescentValuation E) (x : α) :
    chainCost V [x] = 0 := rfl

theorem chainCost_cons_cons {E : ExchangeFamily α} (V : TropicalDescentValuation E)
    (x y : α) (rest : List α) :
    chainCost V (x :: y :: rest) = V.cost x y + chainCost V (y :: rest) := rfl

/-! ### Product Exchange Families -/

/-- **Product** of two exchange families. Exchanges happen in exactly one component
at a time, and the product measure is the sum of component measures.
This models independent optimization problems running in parallel. -/
def prod (E₁ : ExchangeFamily α) (E₂ : ExchangeFamily β) :
    ExchangeFamily (α × β) where
  measure := fun p => E₁.measure p.1 + E₂.measure p.2
  exchange := fun p q =>
    (E₁.exchange p.1 q.1 ∧ p.2 = q.2) ∨ (p.1 = q.1 ∧ E₂.exchange p.2 q.2)
  exchange_decreasing := by
    intro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩ h
    rcases h with ⟨hex, rfl⟩ | ⟨rfl, hex⟩
    · exact Nat.add_lt_add_right (E₁.exchange_decreasing _ _ hex) _
    · exact Nat.add_lt_add_left (E₂.exchange_decreasing _ _ hex) _

/-! ### Morphisms -/

/-- A **morphism** of exchange families: a function that maps exchanges to exchanges.
Morphisms allow comparing the complexity of different optimization problems. -/
structure Morphism (E₁ : ExchangeFamily α) (E₂ : ExchangeFamily β) where
  /-- The underlying function -/
  toFun : α → β
  /-- Exchanges are preserved -/
  map_exchange : ∀ x y, E₁.exchange x y → E₂.exchange (toFun x) (toFun y)

/-! ### Descent Complexity Classes -/

/-- A **descent complexity class** bundles an exchange family with a uniform
upper bound on the measure. This is the analogue of a computational complexity
class (like P or NP) for iterative optimization. -/
structure DescentComplexityClass where
  /-- The state space -/
  StateType : Type*
  /-- The underlying exchange family -/
  family : ExchangeFamily StateType
  /-- Uniform upper bound on the measure -/
  maxMeasure : ℕ
  /-- Every state's measure is bounded -/
  measure_bound : ∀ x : StateType, family.measure x ≤ maxMeasure

namespace DescentComplexityClass

/-- Product of two complexity classes has additive depth bound. -/
def prod (C₁ C₂ : DescentComplexityClass) : DescentComplexityClass where
  StateType := C₁.StateType × C₂.StateType
  family := C₁.family.prod C₂.family
  maxMeasure := C₁.maxMeasure + C₂.maxMeasure
  measure_bound := by
    intro ⟨x, y⟩
    simp [ExchangeFamily.prod]
    exact Nat.add_le_add (C₁.measure_bound x) (C₂.measure_bound y)

end DescentComplexityClass

/-! ### Local Minima -/

/-- A state is a **local minimum** if it has no exchange successors. -/
def IsLocalMin (E : ExchangeFamily α) (x : α) : Prop :=
  ∀ y, ¬E.exchange x y

/-- A state with measure 0 is necessarily a local minimum:
any exchange would decrease the measure below 0, which is impossible in ℕ. -/
theorem isLocalMin_of_measure_zero (E : ExchangeFamily α) (x : α)
    (hx : E.measure x = 0) : E.IsLocalMin x := by
  intro y hy
  have := E.exchange_decreasing x y hy
  omega

end ExchangeFamily