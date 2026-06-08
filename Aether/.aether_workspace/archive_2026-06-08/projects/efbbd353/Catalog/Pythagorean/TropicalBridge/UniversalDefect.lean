/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Bridge: Universal Defect Infrastructure

This file provides the defect/rank-nullity infrastructure connecting
the tropical kernel dimension to graph-theoretic invariants.
The key result is the universal defect formula relating tropical rank
deficiency to cycle rank and component visibility.
-/
import Mathlib
import Pythagorean.TropicalBridge.Defs

open Finset SimpleGraph TropicalHodge

namespace TropicalHodge

section UniversalDefect

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Tropical rank-nullity infrastructure

The universal defect of the tropical Laplacian principal minor L_S
measures how far L_S is from having full tropical rank. The defect
decomposes as:
  defect(L_S) = β₁(G[S]) + κ(G,q,S)
This is the content of the Tropical Kernel Dimension Formula. -/

/-- The **universal defect** of the tropical Laplacian principal minor
    indexed by S with basepoint q. This is defined as the predicted
    kernel dimension β₁(G[S]) + κ(G,q,S). -/
noncomputable def universalDefect (q : V) (S : Finset V) : ℕ :=
  predictedTropicalKernelDim G q S

/-- The universal defect splits into cycle and component parts. -/
theorem universalDefect_eq (q : V) (S : Finset V) :
    universalDefect G q S = inducedCycleRank G S + qVisibleComponentCount G q S := by
  rfl

/-
For the empty set, the cycle rank is zero.
-/
theorem inducedCycleRank_empty : inducedCycleRank G (∅ : Finset V) = 0 := by
  convert Nat.sub_zero 0

/-
For the empty set, there are no q-visible components.
-/
theorem qVisibleComponentCount_empty (q : V) :
    qVisibleComponentCount G q (∅ : Finset V) = 0 := by
  convert Fintype.card_eq_zero_iff.mpr ?_;
  exact Fintype.card_eq_zero_iff.mp ( by simp +decide [ isQVisible ] )

/-- The universal defect of the empty set is zero. -/
theorem universalDefect_empty (q : V) :
    universalDefect G q (∅ : Finset V) = 0 := by
  unfold universalDefect predictedTropicalKernelDim
  rw [inducedCycleRank_empty, qVisibleComponentCount_empty]

/-
The cycle rank is zero for a singleton.
-/
theorem inducedCycleRank_singleton (v : V) :
    inducedCycleRank G {v} = 0 := by
  refine' Nat.sub_eq_zero_of_le _;
  -- In the induced subgraph on {v}, there are no edges, so the edge count is 0.
  simp [inducedEdgeCount, inducedSubgraph];
  simp [induce, SimpleGraph.edgeFinset];
  simp +decide [ Finset.filter_singleton, SimpleGraph.comap ];
  refine' Fintype.card_le_one_iff.mpr _;
  rintro ⟨ a ⟩ ⟨ b ⟩;
  grind

/-
For a singleton {v}, the q-visible component count is 1 if v ~ q, else 0.
-/
theorem qVisibleComponentCount_singleton (q v : V) (hqv : q ≠ v) :
    qVisibleComponentCount G q {v} = if G.Adj v q then 1 else 0 := by
  unfold qVisibleComponentCount;
  split_ifs <;> simp_all +decide [ Fintype.card_subtype ];
  · rw [ Finset.filter_singleton ];
    rw [ if_pos ];
    · exact Finset.card_eq_one.mpr ⟨ _, Finset.eq_singleton_iff_unique_mem.mpr ⟨ Finset.mem_singleton_self _, fun x hx => by aesop ⟩ ⟩;
    · exact ⟨ ⟨ v, by simp +decide ⟩, rfl, by simpa [ SimpleGraph.adj_comm ] using ‹G.Adj v q› ⟩;
  · rintro ⟨ w, hw₁, hw₂ ⟩;
    grind

end UniversalDefect

end TropicalHodge