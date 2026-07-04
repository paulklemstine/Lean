/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Applications.BipartitePartialDual.Characterization
import Applications.BipartitePartialDual.AllCrossing

/-!
# Worked example: a concrete medial datum with nonempty all-crossing family

This file exhibits an explicit `MedialData` on two hyperedges witnessing that the
hypotheses and conclusions of `Characterization.lean` are genuinely satisfiable
(non-vacuous): both the all-crossing family and the bipartite-partial-dual family are
nonempty, the crossing set map matches the characterization, and a length-`4` hyperedge
carries an all-crossing direction while a length-`3` one does not.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The abstract characterization is inhabited: there is a medial
  datum where all-crossing directions and bipartite partial duals both exist and `C`
  visibly maps one onto the other.
Experiment (Experimenter): Took `E = Fin 2`, all-ones interlacement `J ≡ 1`, reference
  twist `t = (1,0)`. Then `crossOp x = (x₀+x₁, x₀+x₁)`, so all-crossing directions are
  `{(0,0),(1,1)}` and bipartite duals are `{(1,0),(0,1)}`; `C` sends the former onto the
  latter. Verified concrete memberships and the even/odd hyperedge dichotomy by decision.
Analysis (Analyst): The example has `ker (crossOp)` of dimension `1`, so both families
  have exactly two members — a nontrivial coset, not a singleton, confirming the bijection
  is doing real work.
Critique (Critic): `decide` here is used only for *witnessing* examples, never for a main
  theorem, in line with the anti-trivial guardrails.
Synthesis (PI): Confirms the theory of `Characterization.lean` and `AllCrossing.lean` is
  non-vacuous.
-/

namespace BipartitePartialDual

/-- Two-hyperedge medial datum with all-ones interlacement form. -/
def Mex : MedialData (Fin 2) := ⟨fun _ _ => 1, by decide⟩

/-- Reference twist to the bipartite base map. -/
def tex : Fin 2 → ZMod 2 := ![1, 0]

/-- `(0,0)` is an all-crossing direction. -/
theorem Mex_allCrossing_zero : AllCrossing Mex 0 := by
  unfold AllCrossing crossOp; decide

/-- `(1,1)` is an all-crossing direction (nontrivial member of the kernel). -/
theorem Mex_allCrossing_oneone : AllCrossing Mex ![1, 1] := by
  unfold AllCrossing crossOp; decide

/-- `(1,0)` is **not** an all-crossing direction. -/
theorem Mex_not_allCrossing_ten : ¬ AllCrossing Mex ![1, 0] := by
  unfold AllCrossing crossOp; decide

/-- `(1,0)` is a bipartite partial dual for the reference twist `t = (1,0)`. -/
theorem Mex_bipartiteDual_ten : BipartiteDual Mex tex ![1, 0] := by
  unfold BipartiteDual crossOp tex; decide

/-- The crossing set map sends the all-crossing direction `(0,0)` to the bipartite dual
`(1,0)`, matching the characterization `bipartiteDual_iff_crossingSet`. -/
theorem Mex_crossingSet_zero : crossingSet tex 0 = ![1, 0] := by
  unfold crossingSet tex; decide

/-- A length-`4` hyperedge carries an all-crossing direction. -/
theorem allCrossing_len_four : (SimpleGraph.cycleGraph 4).Colorable 2 :=
  (allCrossingLocal_iff_even 4 (by norm_num)).2 (by norm_num)

/-- A length-`3` hyperedge carries **no** all-crossing direction. -/
theorem not_allCrossing_len_three : ¬ (SimpleGraph.cycleGraph 3).Colorable 2 := by
  intro h
  have := (allCrossingLocal_iff_even 3 (by norm_num)).1 h
  simp [Nat.even_iff] at this

end BipartitePartialDual