/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Tropical Büchi–Elgot Theorem: Main Equivalence

This file states and reduces the tropical Büchi–Elgot theorem to two
main lemmas (logic → automata and automata → logic), both of which
require substantial additional infrastructure to complete.

## Status

The theorem is reduced to two key lemmas:
1. `wmso_eval_recognizable`: Every weighted MSO formula defines a recognizable
   cost function. Partial progress in `FormulaToAutomaton.lean` (base cases +
   boolean/optimization combinators proved, atomic predicates + quantifiers
   require extended alphabet technique).
2. `recognizable_eval_wmso_definable`: Every recognizable cost function is
   weighted MSO-definable. Requires programmatic formula construction from
   automaton structure.

The main theorem `tropical_buchi_elgot_equiv` follows cleanly from these.
-/

import Mathlib
import Tropical.WeightedMSO.Defs
import Tropical.WeightedMSO.Algebra
import Tropical.WeightedMSO.Closure
import Tropical.WeightedMSO.ProductAutomaton
import Tropical.WeightedMSO.FormulaToAutomaton

namespace TropicalMSO

open Classical

variable {α : Type} [Fintype α] [DecidableEq α]

/-! ## Main Lemmas (require extended alphabet infrastructure) -/

/-- **Logic → Automata direction.** Every weighted MSO formula defines a
    tropically recognizable cost function.

    The proof proceeds by structural induction on formulas. Base cases (bot, top)
    and boolean/optimization combinators (and, or) are proved in
    `FormulaToAutomaton.lean`. The remaining cases (atomic predicates and
    quantifiers) require an extended alphabet technique to track variable
    assignments within the word, which is standard in classical Büchi theorem
    proofs but requires additional infrastructure. -/
theorem wmso_eval_recognizable (φ : WMSOFormula α) :
    TropicallyRecognizable φ.eval := by
  sorry

/-- **Automata → Logic direction.** Every cost function recognized by a
    min-plus automaton is weighted MSO-definable.

    The proof encodes automaton runs as second-order state predicates X_q
    (for each state q) that partition the word positions. Transition costs,
    initial costs, and final costs are then expressed as tropical conjunctions
    of atomic predicates. The formula uses existsSO quantifiers to optimize
    over all valid run encodings. -/
theorem recognizable_eval_wmso_definable (A : MinPlusAutomaton α) :
    WMSODefinable (A.eval) := by
  sorry

/-! ## Main Theorem -/

/-- **Tropical Büchi–Elgot Theorem for Finite Words.**

    A cost function `f : List α → WithTop ℕ` is recognized by a finite min-plus
    weighted automaton if and only if it is definable by a weighted MSO sentence
    with tropical semantics.

    This is the tropical (min-plus) analogue of the classical Büchi–Elgot theorem
    that characterizes regular languages as exactly the MSO-definable languages.
    In the tropical world:
    - **truth** becomes **cost** (0 = true, ⊤ = false)
    - **disjunction** becomes **minimization**
    - **conjunction** becomes **cost accumulation**
    - **existential quantification** becomes **optimization**

    The proof reduces to two directions:
    - `wmso_eval_recognizable`: every formula gives a recognizable function
    - `recognizable_eval_wmso_definable`: every automaton has an MSO encoding -/
theorem tropical_buchi_elgot_equiv :
    ∀ f : List α → Weight,
      TropicallyRecognizable f ↔ WMSODefinable f := by
  intro f
  constructor
  · intro ⟨A, hA⟩
    have hdef := recognizable_eval_wmso_definable A
    obtain ⟨φ, hφ⟩ := hdef
    exact ⟨φ, by ext w; rw [← hA w]; exact congr_fun hφ w⟩
  · intro ⟨φ, hφ⟩
    have hrec := wmso_eval_recognizable φ
    obtain ⟨A, hA⟩ := hrec
    exact ⟨A, by intro w; rw [hA w]; exact congr_fun hφ w⟩

end TropicalMSO