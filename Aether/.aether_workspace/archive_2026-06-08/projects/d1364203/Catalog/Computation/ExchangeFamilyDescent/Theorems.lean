/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exchange Family Descent Complexity: Complete Theory

## Overview

An **exchange family** is a combinatorial structure modeling iterative optimization:
a set of states equipped with a natural-number-valued measure and a binary
exchange relation that strictly decreases the measure at each step.

## Main Results

1. `descent_chain_length_bound` — chain length ≤ initial measure + 1
2. `exchange_irrefl` — exchange relation is irreflexive
3. `descent_no_cycle` — exchange families are acyclic
4. `valuation_cost_lower_bound` — tropical cost lower bound
5. `valuation_cost_upper_bound` — tropical cost upper bound
6. `depth_cost_tradeoff` — fundamental depth-cost bridge
7. `product_chain_length_bound` — product additivity
8. `morphism_preserves_chain` — morphism preservation
9. `measure_last_le` — measure decrease along chains
10. `chain_length_universal_bound` — uniform depth bound
-/

import Mathlib

open Finset Function

/-- An **exchange family** on a type `α`: a measure function to ℕ and an exchange
relation that strictly decreases the measure. -/
structure ExchangeFamily (α : Type*) where
  measure : α → ℕ
  exchange : α → α → Prop
  exchange_decreasing : ∀ x y, exchange x y → measure y < measure x

namespace ExchangeFamily

variable {α β : Type*}

/-- A descent chain: consecutive elements are related by exchange. -/
def IsDescentChain (E : ExchangeFamily α) : List α → Prop
  | [] => True
  | [_] => True
  | x :: y :: rest => E.exchange x y ∧ E.IsDescentChain (y :: rest)

/-- Tail of a descent chain is a descent chain. -/
theorem isDescentChain_tail (E : ExchangeFamily α) (x : α) (rest : List α)
    (h : E.IsDescentChain (x :: rest)) : E.IsDescentChain rest := by
  cases rest with
  | nil => trivial
  | cons y rest' => exact h.2

/-- A tropical descent valuation assigns a positive cost to each exchange. -/
structure TropicalDescentValuation (E : ExchangeFamily α) where
  cost : α → α → ℕ
  cost_pos : ∀ x y, E.exchange x y → 0 < cost x y

/-- Total cost of a descent chain under a valuation. -/
def chainCost {E : ExchangeFamily α} (V : TropicalDescentValuation E) :
    List α → ℕ
  | [] => 0
  | [_] => 0
  | x :: y :: rest => V.cost x y + chainCost V (y :: rest)

/-- Product of two exchange families. Exchanges in one component at a time. -/
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

/-- Exchange family morphism: preserves exchanges. -/
structure Morphism (E₁ : ExchangeFamily α) (E₂ : ExchangeFamily β) where
  toFun : α → β
  map_exchange : ∀ x y, E₁.exchange x y → E₂.exchange (toFun x) (toFun y)

/-- A state with measure 0 is a local minimum. -/
theorem isLocalMin_of_measure_zero (E : ExchangeFamily α) (x : α)
    (hx : E.measure x = 0) : ∀ y, ¬E.exchange x y := by
  intro y hy
  have := E.exchange_decreasing x y hy
  omega

/-! ## Main Theorems -/

/-
**Descent Termination.** Any descent chain has length ≤ μ(head) + 1.
-/
theorem descent_chain_length_bound (E : ExchangeFamily α)
    (chain : List α) (hchain : E.IsDescentChain chain) (hne : chain ≠ []) :
    chain.length ≤ E.measure (chain.head hne) + 1 := by
  induction' chain with x chain ih;
  · contradiction;
  · rcases chain <;> simp_all +arith +decide;
    exact lt_of_le_of_lt ( ih hchain.2 ) ( E.exchange_decreasing _ _ hchain.1 )

/-
Exchange is irreflexive.
-/
theorem exchange_irrefl (E : ExchangeFamily α) (x : α) : ¬E.exchange x x := by
  exact fun h => Nat.lt_asymm ( E.exchange_decreasing _ _ h ) ( E.exchange_decreasing _ _ h )

/-
**Acyclicity.** Descent chains cannot form cycles.
-/
theorem descent_no_cycle (E : ExchangeFamily α)
    (chain : List α) (hchain : E.IsDescentChain chain)
    (hlen : 2 ≤ chain.length) (hne : chain ≠ [])
    (hcycle : chain.head hne = chain.getLast hne) :
    False := by
  -- From measure_last_le, `E.measure (chain.getLast hne) + (chain.length - 1) ≤ E.measure (chain.head hne)`. But `hcycle` says `head = last`, so `E.measure (chain.head hne) + (chain.length - 1) ≤ E.measure (chain.head hne)`. This gives `chain.length - 1 ≤ 0`, so `chain.length ≤ 1`.
  have h_length_le_one : E.measure (chain.getLast hne) + (chain.length - 1) ≤ E.measure (chain.head hne) := by
    -- By induction on the length of the chain, we can show that the measure of the last element is at least the measure of the head minus the length of the chain.
    have h_measure_last (chain : List α) (hchain : E.IsDescentChain chain) (hne : chain ≠ []) : E.measure (chain.getLast hne) + (chain.length - 1) ≤ E.measure (chain.head hne) := by
      induction' chain with x chain ih;
      · contradiction;
      · rcases chain <;> simp_all +decide [ List.getLast ];
        linarith [ ih ( by cases hchain ; tauto ), E.exchange_decreasing _ _ ( by cases hchain ; tauto ) ];
    exact h_measure_last chain hchain hne;
  grind +ring

/-
**Tropical Cost Lower Bound.** Total cost ≥ w × (length - 1).
-/
theorem valuation_cost_lower_bound (E : ExchangeFamily α)
    (V : TropicalDescentValuation E) (w : ℕ)
    (hw : ∀ x y, E.exchange x y → w ≤ V.cost x y)
    (chain : List α) (hchain : E.IsDescentChain chain) :
    w * (chain.length - 1) ≤ chainCost V chain := by
  induction' chain with x chain ih generalizing w;
  · exact Nat.zero_le _;
  · rcases chain with ( _ | ⟨ y, chain ⟩ );
    · exact Nat.zero_le _;
    · specialize ih w hw ( by cases hchain ; tauto ) ; simp_all +decide [ Nat.mul_succ, chainCost ] ; linarith [ hw x y ( by cases hchain ; tauto ) ] ;

/-
**Tropical Cost Upper Bound.** Total cost ≤ W × (length - 1).
-/
theorem valuation_cost_upper_bound (E : ExchangeFamily α)
    (V : TropicalDescentValuation E) (W : ℕ)
    (hW : ∀ x y, E.exchange x y → V.cost x y ≤ W)
    (chain : List α) (hchain : E.IsDescentChain chain) :
    chainCost V chain ≤ W * (chain.length - 1) := by
  rcases chain with ( _ | ⟨ x, _ | ⟨ y, l ⟩ ⟩ ) <;> simp_all +decide [ chainCost ];
  induction' l with z l ih generalizing x y <;> simp_all +decide [ chainCost ];
  · exact hW x y hchain.1;
  · linarith [ ih y z ( by cases hchain; tauto ), hW x y ( by cases hchain; tauto ) ]

/-
**Measure decrease.** Last element's measure + (length-1) ≤ head's measure.
-/
theorem measure_last_le (E : ExchangeFamily α)
    (chain : List α) (hchain : E.IsDescentChain chain)
    (hne : chain ≠ []) (hlen : 2 ≤ chain.length) :
    E.measure (chain.getLast hne) + (chain.length - 1) ≤ E.measure (chain.head hne) := by
  revert hne hlen hchain;
  induction' chain with x chain ih;
  · grind;
  · rcases chain with ( _ | ⟨ y, _ | ⟨ z, chain ⟩ ⟩ ) <;> simp +arith +decide at *;
    · exact fun h => E.exchange_decreasing _ _ h.1;
    · intro hchain; have := ih ( by exact hchain.2 ) ; linarith [ E.exchange_decreasing x y hchain.1 ] ;

/-- **Depth-Cost Tradeoff.** Combines all bounds into one theorem. -/
theorem depth_cost_tradeoff (E : ExchangeFamily α)
    (V : TropicalDescentValuation E) (w W : ℕ)
    (hw : ∀ x y, E.exchange x y → w ≤ V.cost x y)
    (hW : ∀ x y, E.exchange x y → V.cost x y ≤ W)
    (chain : List α) (hchain : E.IsDescentChain chain) (hne : chain ≠ []) :
    w * (chain.length - 1) ≤ chainCost V chain ∧
    chainCost V chain ≤ W * (chain.length - 1) ∧
    chain.length - 1 ≤ E.measure (chain.head hne) := by
  exact ⟨valuation_cost_lower_bound E V w hw chain hchain,
         valuation_cost_upper_bound E V W hW chain hchain,
         by have := descent_chain_length_bound E chain hchain hne; omega⟩

/-- **Product Chain Length Bound.** Additivity under product. -/
theorem product_chain_length_bound (E₁ : ExchangeFamily α) (E₂ : ExchangeFamily β)
    (chain : List (α × β))
    (hchain : (E₁.prod E₂).IsDescentChain chain) (hne : chain ≠ []) :
    chain.length ≤ E₁.measure (chain.head hne).1 + E₂.measure (chain.head hne).2 + 1 :=
  descent_chain_length_bound (E₁.prod E₂) chain hchain hne

/-
**Morphism Preservation.** Morphisms preserve descent chains.
-/
theorem morphism_preserves_chain (E₁ : ExchangeFamily α) (E₂ : ExchangeFamily β)
    (f : Morphism E₁ E₂) (chain : List α) (hchain : E₁.IsDescentChain chain) :
    E₂.IsDescentChain (chain.map f.toFun) := by
  -- We'll use induction on the chain.
  induction' chain with x rest ih;
  · trivial;
  · rcases rest with ( _ | ⟨ y, rest ⟩ ) <;> simp_all +decide [ ExchangeFamily.IsDescentChain ];
    exact f.map_exchange x y hchain.1

/-! ## Complexity Class -/

/-- Bundled exchange family with uniform depth bound. -/
structure DescentComplexityClass where
  StateType : Type*
  family : ExchangeFamily StateType
  maxMeasure : ℕ
  measure_bound : ∀ x : StateType, family.measure x ≤ maxMeasure

namespace DescentComplexityClass

/-- Product of two complexity classes. -/
def prod (C₁ C₂ : DescentComplexityClass) : DescentComplexityClass where
  StateType := C₁.StateType × C₂.StateType
  family := C₁.family.prod C₂.family
  maxMeasure := C₁.maxMeasure + C₂.maxMeasure
  measure_bound := by
    intro ⟨x, y⟩
    simp [ExchangeFamily.prod]
    exact Nat.add_le_add (C₁.measure_bound x) (C₂.measure_bound y)

/-- **Universal Depth Bound.** Chain length ≤ maxMeasure + 1 in any complexity class. -/
theorem chain_length_universal_bound (C : DescentComplexityClass)
    (chain : List C.StateType) (hchain : C.family.IsDescentChain chain)
    (hne : chain ≠ []) :
    chain.length ≤ C.maxMeasure + 1 := by
  have h1 := descent_chain_length_bound C.family chain hchain hne
  have h2 := C.measure_bound (chain.head hne)
  omega

end DescentComplexityClass

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Binary Exchange Depth Bound).**
For an exchange family on `Fin (n+1)` with binary in-degree and a minimum,
we have `n + 1 ≤ 2^(max_measure + 1)`.

**Test**: Construct exchange families on Fin 4, 8, 16, 32. For each, verify
`card ≤ 2^(max_measure + 1)`. A counterexample with max_measure < log₂(n) - 1
disproves the conjecture. -/
theorem binary_exchange_depth_bound
    {n : ℕ} (E : ExchangeFamily (Fin (n + 1)))
    (h_binary : ∀ x : Fin (n + 1),
      Fintype.card { y : Fin (n + 1) // E.exchange y x } ≤ 2)
    (h_min_exists : ∃ m : Fin (n + 1), E.measure m = 0)
    (h_reachable : ∀ x : Fin (n + 1), E.measure x = 0 ∨ ∃ y, E.exchange x y) :
    n + 1 ≤ 2 ^ (Finset.sup Finset.univ E.measure + 1) := by
  sorry

end ExchangeFamily