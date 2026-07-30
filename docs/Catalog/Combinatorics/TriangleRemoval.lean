/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib.Combinatorics.SimpleGraph.Triangle.Removal

/-! # The triangle removal lemma

The standard quantified formulation is extracted from Mathlib's effective
bound.  A graph with fewer than `δ n³` triangles can be made triangle-free by
deleting fewer than `ε n²` edges.
-/

open Finset SimpleGraph

namespace Catalog.Combinatorics.ExtremalGraphTheory

/-- **Triangle removal lemma.** For every positive `ε` there is a positive
`δ` that works uniformly for all finite simple graphs. -/
theorem triangle_removal_lemma {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧
      ∀ {α : Type*} [Fintype α] [DecidableEq α] (G : SimpleGraph α)
        [DecidableRel G.Adj],
        (#(G.cliqueFinset 3) : ℝ) < δ * (Fintype.card α : ℝ) ^ 3 →
          ∃ G' ≤ G, ∃ _ : DecidableRel G'.Adj,
            (#G.edgeFinset - #G'.edgeFinset : ℝ) <
                ε * (Fintype.card α : ℝ) ^ 2 ∧
              G'.CliqueFree 3 := by
  refine ⟨triangleRemovalBound ε, triangleRemovalBound_pos hε, ?_⟩
  intro α _ _ G _ htri
  obtain ⟨G', hsub, inst, hedge, hfree⟩ := triangle_removal htri
  refine ⟨G', hsub, inst, ?_, hfree⟩
  simpa only [Nat.cast_pow] using hedge

/-- Contrapositive counting form: a graph that is `ε`-far from triangle-free
contains at least `triangleRemovalBound ε · n³` triangles. -/
theorem many_triangles_of_far_from_triangleFree
    {α : Type*} [Fintype α] [DecidableEq α] {G : SimpleGraph α}
    [DecidableRel G.Adj] {ε : ℝ} (hG : G.FarFromTriangleFree ε) :
    triangleRemovalBound ε * (Fintype.card α : ℝ) ^ 3 ≤
      (#(G.cliqueFinset 3) : ℝ) := by
  simpa only [Nat.cast_pow] using hG.le_card_cliqueFinset

end Catalog.Combinatorics.ExtremalGraphTheory