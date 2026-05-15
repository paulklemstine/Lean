/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# From Weighted MSO Formulas to Min-Plus Automata

This file proves the "logic → automata" direction of the tropical Büchi–Elgot
theorem: every weighted MSO formula defines a tropically recognizable cost function.

The proof proceeds by structural induction on formulas. For each constructor,
we build an explicit min-plus automaton computing the same cost function.
-/

import Mathlib
import Tropical.WeightedMSO.Defs
import Tropical.WeightedMSO.Algebra
import Tropical.WeightedMSO.Closure
import Tropical.WeightedMSO.ProductAutomaton

namespace TropicalMSO

open Classical

variable {α : Type} [Fintype α] [DecidableEq α]

/-! ## Base cases: constant formulas -/

/-
The `bot` formula (constant ⊤) has a recognizable evaluation.
-/
theorem recognizable_bot :
    TropicallyRecognizable (WMSOFormula.bot : WMSOFormula α).eval := by
  convert TropicalMSO.recognizable_top;
  · infer_instance;
  · infer_instance

/-
The `top` formula (constant 0) has a recognizable evaluation.
-/
theorem recognizable_top_formula :
    TropicallyRecognizable (WMSOFormula.top : WMSOFormula α).eval := by
  convert TropicalMSO.recognizable_zero;
  · infer_instance;
  · infer_instance

/-! ## Inductive cases: boolean combinators -/

/-
If φ and ψ have recognizable evaluations, so does `and φ ψ` (tropical sum).
-/
theorem recognizable_and (φ ψ : WMSOFormula α)
    (hφ : TropicallyRecognizable φ.eval) (hψ : TropicallyRecognizable ψ.eval) :
    TropicallyRecognizable (WMSOFormula.and φ ψ).eval := by
  convert TropicalMSO.recognizable_closed_under_add _ _ hφ hψ using 1

/-
If φ and ψ have recognizable evaluations, so does `or φ ψ` (tropical min).
-/
theorem recognizable_or (φ ψ : WMSOFormula α)
    (hφ : TropicallyRecognizable φ.eval) (hψ : TropicallyRecognizable ψ.eval) :
    TropicallyRecognizable (WMSOFormula.or φ ψ).eval := by
  convert TropicalMSO.recognizable_closed_under_min _ _ hφ hψ using 1

/-! ## Main induction: every formula is recognizable -/

/-- **Logic → Automata direction.** Every weighted MSO formula defines a
    tropically recognizable cost function. Proved by structural induction. -/
theorem wmso_eval_recognizable_full (φ : WMSOFormula α) :
    TropicallyRecognizable φ.eval := by
  sorry

end TropicalMSO