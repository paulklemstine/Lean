/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Defect Theory for the Tropical Bridge

Quantitative defect theory for the tropical bridge between restricted
Laplacian rank and rooted subset divisor rank on finite graphs.
-/

import Mathlib

open Finset BigOperators

namespace TropicalBridge.Defect

variable {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Definitions -/

/-- The number of edges in the subgraph of `G` induced on vertex set `S`. -/
noncomputable def inducedEdgeCount (S : Finset V) : ℕ :=
  (G.induce (↑S : Set V)).edgeFinset.card

/-- The number of connected components of the subgraph of `G` induced on `S`. -/
noncomputable def inducedComponentCount (S : Finset V) : ℕ :=
  Fintype.card (G.induce (↑S : Set V)).ConnectedComponent

/-- The cycle rank (first Betti number) of the induced subgraph `G[S]`:
    β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|. -/
noncomputable def inducedCycleRank (S : Finset V) : ℕ :=
  inducedEdgeCount G S + inducedComponentCount G S - S.card

/-- The number of connected components of `G - {q}` that contain at least
    one vertex of `S`. -/
noncomputable def rootComponentCount (q : V) (S : Finset V) : ℕ :=
  let Gq := G.induce ({q}ᶜ : Set V)
  Fintype.card { c : Gq.ConnectedComponent //
    ∃ v : ({q}ᶜ : Set V), v.1 ∈ S ∧ Gq.connectedComponentMk v = c }

/-- S is root-connected: all vertices of S lie in one component of G-{q}. -/
def IsRootConnected (q : V) (S : Finset V) : Prop :=
  ∀ u v : ({q}ᶜ : Set V), u.1 ∈ S → v.1 ∈ S →
    (G.induce ({q}ᶜ : Set V)).Reachable u v

/-- G[S] is acyclic (a forest). -/
def IsInducedAcyclic (S : Finset V) : Prop :=
  (G.induce (↑S : Set V)).IsAcyclic

/-- The structural defect: β₁(G[S]) + κ(G,q,S) - 1. -/
noncomputable def structuralDefect (q : V) (S : Finset V) : ℤ :=
  (inducedCycleRank G S : ℤ) + (rootComponentCount G q S : ℤ) - 1

/-! ## Base cases -/

omit [Fintype V] [DecidableEq V] in
theorem inducedEdgeCount_empty : inducedEdgeCount G (∅ : Finset V) = 0 := by
  convert Set.ncard_eq_toFinset_card'
    (∅ : Set (Sym2 ({ x : V // x ∈ (∅ : Finset V) }))) using 1
  simp +decide [inducedEdgeCount]
  grind +extAll

omit [Fintype V] in
theorem inducedComponentCount_empty :
    inducedComponentCount G (∅ : Finset V) = 0 := by
  constructor

omit [Fintype V] in
theorem inducedCycleRank_empty : inducedCycleRank G (∅ : Finset V) = 0 := by
  unfold inducedCycleRank; aesop

omit [DecidableEq V] [DecidableRel G.Adj] in
theorem rootComponentCount_empty (q : V) :
    rootComponentCount G q (∅ : Finset V) = 0 := by
  convert Fintype.card_eq_zero_iff.mpr ?_
  exact ⟨fun x => by aesop⟩

omit [Fintype V] [DecidableEq V] in
theorem inducedEdgeCount_singleton (v : V) :
    inducedEdgeCount G {v} = 0 := by
  simp +decide [inducedEdgeCount, SimpleGraph.comap, SimpleGraph.edgeFinset]

omit [Fintype V] in
theorem inducedComponentCount_singleton (v : V) :
    inducedComponentCount G {v} = 1 :=
  Eq.symm (Nat.eq_of_beq_eq_true rfl)

omit [Fintype V] in
theorem inducedCycleRank_singleton (v : V) :
    inducedCycleRank G {v} = 0 := by
  unfold inducedCycleRank
  rw [inducedEdgeCount_singleton, inducedComponentCount_singleton]
  simp

/-! ## Structural bounds -/

omit [Fintype V] in
theorem inducedComponentCount_le_card (S : Finset V) :
    inducedComponentCount G S ≤ S.card := by
  have h_card : Fintype.card (G.induce (↑S : Set V)).ConnectedComponent ≤
      Fintype.card {v : V | v ∈ S} := by
    have h_surj : Function.Surjective
        (fun v : {v : V | v ∈ S} =>
          (G.induce (↑S : Set V)).connectedComponentMk ⟨v, by grind⟩) := by
      intro c; rcases c with ⟨c⟩; aesop
    exact Fintype.card_le_of_surjective _ h_surj
  aesop

omit [DecidableEq V] [DecidableRel G.Adj] in
theorem rootComponentCount_pos_of_nonempty
    (_hconn : G.Connected) (q : V) (S : Finset V)
    (hq : q ∉ S) (hne : S.Nonempty) :
    1 ≤ rootComponentCount G q S := by
  obtain ⟨v, hv⟩ := hne
  refine Fintype.card_pos_iff.mpr ?_
  exact ⟨_, ⟨⟨v, by aesop⟩, hv, rfl⟩⟩

/-! ## Core theorems -/

/-- **Nonnegativity of structural defect.** -/
theorem structuralDefect_nonneg
    (hconn : G.Connected) (q : V) (S : Finset V)
    (hq : q ∉ S) (hne : S.Nonempty) :
    0 ≤ structuralDefect G q S := by
  refine sub_nonneg_of_le ?_
  exact_mod_cast le_add_of_nonneg_of_le (Nat.zero_le _)
    (rootComponentCount_pos_of_nonempty G hconn q S hq hne)

/-- **Zero-defect rigidity.** -/
theorem structuralDefect_eq_zero_iff
    (hconn : G.Connected) (q : V) (S : Finset V)
    (hq : q ∉ S) (hne : S.Nonempty) :
    structuralDefect G q S = 0 ↔
      inducedCycleRank G S = 0 ∧ rootComponentCount G q S = 1 := by
  constructor <;> intro h
  · have h_pos := rootComponentCount_pos_of_nonempty G hconn q S hq hne
    unfold structuralDefect at h; omega
  · unfold structuralDefect; omega

/-- **Tree-component exactness.** -/
theorem structuralDefect_eq_zero_of_acyclic_singleComponent
    (_hconn : G.Connected) (q : V) (S : Finset V)
    (_hq : q ∉ S) (_hne : S.Nonempty)
    (hacyclic : inducedCycleRank G S = 0)
    (hroot : rootComponentCount G q S = 1) :
    structuralDefect G q S = 0 := by
  unfold structuralDefect; omega

end TropicalBridge.Defect