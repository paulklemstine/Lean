/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Product and Union Automaton Correctness

This file proves that the product automaton computes the tropical sum
(regular addition) of two automata's costs, and establishes the
corresponding closure property for tropically recognizable functions.
-/

import Mathlib
import Tropical.WeightedMSO.Defs
import Tropical.WeightedMSO.Algebra

namespace TropicalMSO

open Classical

variable {α : Type} [Fintype α] [DecidableEq α]

/-! ## Product Automaton Correctness -/

/-
The run cost of the product automaton decomposes as the sum of the
    individual run costs on each component.
-/
theorem product_runCost_eq (A B : MinPlusAutomaton α) (w : List α)
    (run : Fin (w.length + 1) → A.Q × B.Q) :
    (A.product B).runCost w run =
      A.runCost w (fun i => (run i).1) + B.runCost w (fun i => (run i).2) := by
  simp +decide only [MinPlusAutomaton.runCost];
  rw [ show ( A.product B ).init = fun ⟨ q, r ⟩ => A.init q + B.init r from rfl, show ( A.product B ).step = fun ⟨ q, r ⟩ a ⟨ q', r' ⟩ => A.step q a q' + B.step r a r' from rfl, show ( A.product B ).final = fun ⟨ q, r ⟩ => A.final q + B.final r from rfl ];
  simp +decide only [Finset.sum_add_distrib];
  grind

/-
The product automaton evaluates to the sum of the individual evaluations.
    This is the key semantic theorem for the product construction.
-/
theorem product_eval_eq (A B : MinPlusAutomaton α) (w : List α) :
    (A.product B).eval w = A.eval w + B.eval w := by
  by_cases hA : Nonempty A.Q <;> by_cases hB : Nonempty B.Q <;> simp +decide [ hA, hB, MinPlusAutomaton.eval ];
  · rw [ tropical_iInf_prod_eq ];
    refine' le_antisymm _ _;
    · refine' le_csInf _ _ <;> norm_num;
      · exact ⟨ _, ⟨ ⟨ fun _ => hA.some, fun _ => hB.some ⟩, rfl ⟩ ⟩;
      · rintro b x y rfl; exact le_trans ( ciInf_le ( Finite.bddBelow_range _ ) ( fun i => ( x i, y i ) ) ) ( by simp +decide [ product_runCost_eq ] ) ;
    · refine' le_csInf _ _;
      · exact ⟨ _, ⟨ fun _ => ⟨ hA.some, hB.some ⟩, rfl ⟩ ⟩;
      · rintro _ ⟨ run, rfl ⟩;
        refine' le_trans ( ciInf_le _ ( fun i => ( run i |>.1 ), fun i => ( run i |>.2 ) ) ) _;
        · exact ⟨ 0, Set.forall_mem_range.mpr fun p => zero_le _ ⟩;
        · convert product_runCost_eq A B w run |> le_of_eq using 1;
          · exact?;
          · exact?;
  · cases isEmpty_or_nonempty ( A.Q × B.Q ) <;> simp_all +decide [ MinPlusAutomaton.runCost ];
    exact fun i => False.elim <| hB.elim <| i 0 |>.2;
  · simp_all +decide [ MinPlusAutomaton.runCost, MinPlusAutomaton.product ];
  · simp_all +decide [ Finset.sum_range_succ', Fintype.elems ];
    exact fun i => False.elim <| hA.elim <| i 0 |>.1

/-
Tropically recognizable cost functions are closed under tropical addition.
    Uses the product automaton construction.
-/
theorem recognizable_closed_under_add
    (f g : List α → Weight)
    (hf : TropicallyRecognizable f) (hg : TropicallyRecognizable g) :
    TropicallyRecognizable (fun w => f w + g w) := by
  -- By definition of $f$ and $g$, there exist finite automata $A$ and $B$ such that $A.eval w = f w$ and $B.eval w = g w$.
  obtain ⟨A, hA⟩ := hf
  obtain ⟨B, hB⟩ := hg;
  exact ⟨ A.product B, fun w => by rw [ product_eval_eq, hA, hB ] ⟩

/-! ## Finset.sum decomposition for product automaton -/

/-
The Finset.sum of product-step weights decomposes into the sum of
    individual step weight sums. This is used in the product automaton proof.
-/
theorem finset_sum_step_decompose (A B : MinPlusAutomaton α) (w : List α)
    (run : Fin (w.length + 1) → A.Q × B.Q) :
    Finset.univ.sum (fun (i : Fin w.length) =>
      A.step (run ⟨i.val, by omega⟩).1 (w.get i) (run ⟨i.val + 1, by omega⟩).1 +
      B.step (run ⟨i.val, by omega⟩).2 (w.get i) (run ⟨i.val + 1, by omega⟩).2) =
    Finset.univ.sum (fun (i : Fin w.length) =>
      A.step (run ⟨i.val, by omega⟩).1 (w.get i) (run ⟨i.val + 1, by omega⟩).1) +
    Finset.univ.sum (fun (i : Fin w.length) =>
      B.step (run ⟨i.val, by omega⟩).2 (w.get i) (run ⟨i.val + 1, by omega⟩).2) := by
  -- The sum of the step costs over all i can be split into the sum of the step costs for A and the sum of the step costs for B.
  simp [Finset.sum_add_distrib]

end TropicalMSO