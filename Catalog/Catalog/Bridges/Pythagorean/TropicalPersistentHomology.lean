/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Persistent Homology for Network Data Analysis

This file introduces a new combinatorial invariant for graph filtrations —
the **tropical barcode profile** — and proves stability and monotonicity
theorems that parallel classical persistent homology but use purely
graph-theoretic (tropical) data.

## Main Definitions

* `tropNullity` — the tropical nullity (cycle rank / first Betti number) of a
  finite simple graph: |E| - |V| + c, where c is the number of connected components
* `GraphFiltration` — a monotone sequence of simple graphs on a fixed vertex set
* `tropBarcode` — the tropical barcode profile of a filtration: i ↦ tropNullity(Gᵢ)
* `tropBarcodeDist` — sup-distance between two tropical barcode profiles

## Main Results

* `tropNullity_eq_genus_of_connected` — for connected graphs, tropical nullity
  equals the graph genus |E| - |V| + 1
* `tropNullity_mono` — if G ≤ H (as subgraphs), then tropNullity G ≤ tropNullity H
* `tropBarcode_monotone` — tropical barcode profiles are monotone along filtrations
* `tropNullity_stable_under_edgeSymmDiff` — pointwise stability: the difference in
  tropical nullity is bounded by the symmetric difference of edge sets
* `tropBarcodeDist_le_edgePerturbation` — filtration-level stability theorem
* `tropBarcode_step_le_newEdges` — one-step Lipschitz bound for barcode jumps

## Cross-Domain Connection

The tropical nullity equals the graph genus from chip-firing / tropical Jacobian
theory. This bridges topological data analysis to tropical geometry and the
Baker–Norine theory of divisors on graphs.

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Edelsbrunner, H. and Harer, J. "Computational Topology"
* Mikhalkin, G. "Tropical geometry and its applications"
-/

import Mathlib

set_option linter.unusedSectionVars false

open Finset BigOperators SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Tropical Nullity -/

noncomputable def tropNullity (G : SimpleGraph V) : ℕ :=
  G.edgeFinset.card + Fintype.card G.ConnectedComponent - Fintype.card V

noncomputable def tropNullityConnected (G : SimpleGraph V) : ℕ :=
  G.edgeFinset.card + 1 - Fintype.card V

/-! ### Connected Component Count Lemmas -/

theorem connected_component_card_eq_one [Nonempty V]
    (G : SimpleGraph V) (hconn : G.Connected) :
    Fintype.card G.ConnectedComponent = 1 := by
  rw [Fintype.card_eq_one_iff]
  use G.connectedComponentMk (Classical.arbitrary V)
  intro c
  induction c using SimpleGraph.ConnectedComponent.ind with
  | _ v =>
    rw [SimpleGraph.ConnectedComponent.eq]
    exact (hconn v (Classical.arbitrary V)).some.reachable

/-! ### Tropical Nullity equals Genus for Connected Graphs -/

/-- For connected nonempty graphs, tropical nullity equals `|E| + 1 - |V|`,
    i.e., the graph genus. This connects tropical persistence to chip-firing
    and tropical Jacobian theory. -/
theorem tropNullity_eq_genus_of_connected [Nonempty V]
    (G : SimpleGraph V) (hconn : G.Connected) :
    tropNullity G = G.edgeFinset.card + 1 - Fintype.card V := by
  unfold tropNullity
  rw [connected_component_card_eq_one G hconn]

/-! ### Graph Filtration -/

structure GraphFiltration (V : Type*) [Fintype V] [DecidableEq V] where
  obj : ℕ → SimpleGraph V
  mono : Monotone obj

/-! ### Tropical Barcode Profile -/

noncomputable def tropBarcode (F : GraphFiltration V) (i : ℕ) : ℕ :=
  tropNullity (F.obj i)

/-! ### Tropical Barcode Distance -/

noncomputable def tropBarcodeDist
    (F H : GraphFiltration V) (N : ℕ) : ℕ :=
  Finset.sup (Finset.range (N + 1))
    (fun i => Nat.dist (tropBarcode F i) (tropBarcode H i))

/-! ### Edge Set Monotonicity -/

theorem edgeFinset_subset_of_le
    (G H : SimpleGraph V) (hle : G ≤ H) :
    G.edgeFinset ⊆ H.edgeFinset := by
  intro e he
  rw [SimpleGraph.mem_edgeFinset] at he ⊢
  exact SimpleGraph.edgeSet_mono hle he

/-! ### Connected Component Count Anti-Monotonicity -/

noncomputable def connectedComponentMap
    (G H : SimpleGraph V) (hle : G ≤ H) :
    G.ConnectedComponent → H.ConnectedComponent :=
  fun c => c.map (SimpleGraph.Hom.ofLE hle)

theorem connectedComponent_card_anti_mono
    (G H : SimpleGraph V) (hle : G ≤ H) :
    Fintype.card H.ConnectedComponent ≤ Fintype.card G.ConnectedComponent := by
  exact Fintype.card_le_of_surjective
    (fun c => c.map (SimpleGraph.Hom.ofLE hle))
    (fun c => by obtain ⟨v, rfl⟩ := c.exists_rep; exact ⟨G.connectedComponentMk v, rfl⟩)

/-! ### Key Combinatorial Lemmas -/

theorem SimpleGraph.eq_of_edgeFinset_eq
    (G H : SimpleGraph V) (h : G.edgeFinset = H.edgeFinset) : G = H := by
  ext v w
  replace h := Finset.ext_iff.mp h (s(v, w)); aesop

/-
Reachability in G ⊔ fromEdgeSet {s(a,b)} decomposes into three cases.
-/
theorem reachable_sup_fromEdgeSet_cases
    (G : SimpleGraph V) (a b : V) (x y : V)
    (h : (G ⊔ SimpleGraph.fromEdgeSet {s(a, b)}).Reachable x y) :
    G.Reachable x y ∨
    (G.Reachable x a ∧ G.Reachable y b) ∨
    (G.Reachable x b ∧ G.Reachable y a) := by
  have h_walk : ∀ p : SimpleGraph.Walk (G ⊔ fromEdgeSet {s(a, b)}) x y, G.Reachable x y ∨ (G.Reachable x a ∧ G.Reachable y b) ∨ (G.Reachable x b ∧ G.Reachable y a) := by
    intro p
    induction' p with u v p ih;
    · grind +suggestions;
    · rename_i h₁ h₂ h₃;
      rcases h₃ ( SimpleGraph.Walk.reachable h₂ ) with ( h₃ | h₃ | h₃ ) <;> simp_all +decide [ SimpleGraph.sup_adj ];
      · rcases h₁ with ( h₁ | ⟨ ⟨ rfl, rfl ⟩ | ⟨ rfl, rfl ⟩, h₁ ⟩ ) <;> simp_all +decide [ SimpleGraph.Reachable ];
        · exact Or.inl ⟨ SimpleGraph.Walk.cons h₁ h₃.some ⟩;
        · exact Or.inr <| Or.inl ⟨ ⟨ SimpleGraph.Walk.nil ⟩, ⟨ h₃.some.reverse ⟩ ⟩;
        · exact Or.inr <| Or.inr ⟨ ⟨ SimpleGraph.Walk.nil ⟩, ⟨ h₃.some.reverse ⟩ ⟩;
      · rcases h₁ with ( h₁ | ⟨ ⟨ rfl, rfl ⟩ | ⟨ rfl, rfl ⟩, h₁ ⟩ ) <;> simp_all +decide [ SimpleGraph.Reachable ];
        · exact Or.inr <| Or.inl <| ⟨ SimpleGraph.Walk.cons h₁ h₃.1.some ⟩;
        · exact Or.inr <| Or.inl ⟨ SimpleGraph.Walk.nil ⟩;
        · exact Or.inl ⟨ h₃.2.some.reverse ⟩;
      · rcases h₁ with ( h₁ | ⟨ ⟨ rfl, rfl ⟩ | ⟨ rfl, rfl ⟩, h₁ ⟩ ) <;> simp_all +decide [ SimpleGraph.Reachable ];
        · exact Or.inr <| Or.inr <| ⟨ SimpleGraph.Walk.cons h₁ h₃.1.some ⟩;
        · exact Or.inl ⟨ h₃.2.some.reverse ⟩;
        · exact Or.inr <| Or.inr <| ⟨ SimpleGraph.Walk.nil ⟩;
  exact h_walk h.some;

/-
Adding a single edge decreases cc by at most 1.
-/
theorem cc_le_cc_sup_fromEdgeSet_add_one
    (G : SimpleGraph V) (e : Sym2 V) :
    Fintype.card G.ConnectedComponent ≤
    Fintype.card (G ⊔ SimpleGraph.fromEdgeSet {e}).ConnectedComponent + 1 := by
  induction' e using Sym2.ind with a b;
  convert Fintype.card_le_of_injective _ ( show Function.Injective ( fun c : G.ConnectedComponent => if c = G.connectedComponentMk b then Sum.inr () else Sum.inl ( c.map ( SimpleGraph.Hom.ofLE ( le_sup_left : G ≤ G ⊔ fromEdgeSet { s(a, b) } ) ) ) ) from ?_ ) using 1;
  all_goals norm_num [ Fintype.card_sum ];
  exact fun _ => Classical.dec _;
  intro c₁ c₂ h; by_cases h₁ : c₁ = G.connectedComponentMk b <;> by_cases h₂ : c₂ = G.connectedComponentMk b <;> simp_all +decide ;
  obtain ⟨ x, rfl ⟩ := c₁.exists_rep; obtain ⟨ x₂, rfl ⟩ := c₂.exists_rep; simp_all +decide [ ConnectedComponent.map ] ;
  -- Since $x$ and $x₂$ are in the same connected component of $G ⊔ fromEdgeSet {s(a, b)}$, they must be reachable from each other in $G ⊔ fromEdgeSet {s(a, b)}$.
  have h_reachable : (G ⊔ fromEdgeSet {s(a, b)}).Reachable x x₂ := by
    convert h using 1;
    simp +decide [ ConnectedComponent.lift ];
  have h_reachable_cases : G.Reachable x x₂ ∨ (G.Reachable x a ∧ G.Reachable x₂ b) ∨ (G.Reachable x b ∧ G.Reachable x₂ a) := by
    exact reachable_sup_fromEdgeSet_cases G a b x x₂ h_reachable;
  rcases h_reachable_cases with ( h | h | h );
  · exact Quot.sound h;
  · exact False.elim ( h₂ ( Quot.sound h.2 ) );
  · exact False.elim ( h₁ ( Quot.sound h.1 ) )

/-
For subgraphs, cc(G) - cc(H) ≤ |H \ G|.
-/
set_option maxHeartbeats 800000 in
theorem cc_sub_le_sdiff_card
    (G H : SimpleGraph V) (hle : G ≤ H) :
    Fintype.card G.ConnectedComponent - Fintype.card H.ConnectedComponent
    ≤ (H.edgeFinset \ G.edgeFinset).card := by
  induction' n : ( H.edgeFinset \ G.edgeFinset ).card using Nat.strongRecOn with n ih generalizing G H;
  by_cases h_empty : H.edgeFinset \ G.edgeFinset = ∅;
  · rw [ Finset.sdiff_eq_empty_iff_subset ] at h_empty;
    grind +suggestions;
  · obtain ⟨ e, he ⟩ := Finset.nonempty_iff_ne_empty.mpr h_empty;
    -- Set G' = G ⊔ fromEdgeSet {e}.
    set G' : SimpleGraph V := G ⊔ SimpleGraph.fromEdgeSet {e};
    -- By IH: cc(G') - cc(H) ≤ (H \ G').card
    have h_ind : Fintype.card G'.ConnectedComponent - Fintype.card H.ConnectedComponent ≤ (H.edgeFinset \ G'.edgeFinset).card := by
      apply ih;
      · refine' n ▸ Finset.card_lt_card _;
        simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
        aesop;
      · intro v w hvw; aesop;
      · grind +suggestions;
    -- By cc_le_cc_sup_fromEdgeSet_add_one: cc(G) ≤ cc(G') + 1
    have h_cc_le : Fintype.card G.ConnectedComponent ≤ Fintype.card G'.ConnectedComponent + 1 := by
      convert cc_le_cc_sup_fromEdgeSet_add_one G e using 1;
    -- By definition of $G'$, we have $(H.edgeFinset \ G'.edgeFinset).card = (H.edgeFinset \ G.edgeFinset).card - 1$.
    have h_card_diff : (H.edgeFinset \ G'.edgeFinset).card = (H.edgeFinset \ G.edgeFinset).card - 1 := by
      rw [ show H.edgeFinset \ G'.edgeFinset = ( H.edgeFinset \ G.edgeFinset ) \ { e } from ?_, Finset.card_sdiff ] ; aesop;
      ext; simp [G'];
      by_cases h : ‹Sym2 V› = e <;> simp_all +decide [ SimpleGraph.edgeSet ];
      grind +suggestions;
    grind +suggestions

/-- Key arithmetic lemma: if G ≤ H then |E(G)| + cc(G) ≤ |E(H)| + cc(H). -/
theorem edgeCard_add_cc_mono
    (G H : SimpleGraph V) (hle : G ≤ H) :
    G.edgeFinset.card + Fintype.card G.ConnectedComponent ≤
    H.edgeFinset.card + Fintype.card H.ConnectedComponent := by
  have h1 := cc_sub_le_sdiff_card G H hle
  have h2 : G.edgeFinset ⊆ H.edgeFinset := edgeFinset_subset_of_le G H hle
  have h3 : H.edgeFinset.card = G.edgeFinset.card + (H.edgeFinset \ G.edgeFinset).card := by
    have h4 := Finset.card_sdiff_add_card_inter H.edgeFinset G.edgeFinset
    have h5 : H.edgeFinset ∩ G.edgeFinset = G.edgeFinset := by
      rw [Finset.inter_comm]; exact Finset.inter_eq_left.mpr h2
    rw [h5] at h4; omega
  omega

/-! ### Monotonicity of Tropical Nullity -/

theorem tropNullity_mono
    (G H : SimpleGraph V) (hle : G ≤ H) :
    tropNullity G ≤ tropNullity H := by
  unfold tropNullity
  exact Nat.sub_le_sub_right (edgeCard_add_cc_mono G H hle) _

theorem tropBarcode_monotone
    (F : GraphFiltration V) :
    Monotone (tropBarcode F) := by
  intro i j hij
  exact tropNullity_mono _ _ (F.mono hij)

/-! ### Stability Theorems -/

/-- **Pointwise stability of tropical nullity** -/
theorem tropNullity_stable_under_edgeSymmDiff
    (G H : SimpleGraph V) :
    Nat.dist (tropNullity G) (tropNullity H)
      ≤ (G.edgeFinset \ H.edgeFinset).card + (H.edgeFinset \ G.edgeFinset).card := by
  have h_triangle : Nat.dist (tropNullity G) (tropNullity H) ≤
    (tropNullity G - tropNullity (G ⊓ H)) + (tropNullity H - tropNullity (G ⊓ H)) := by
    simp only [Nat.dist]
    gcongr <;> apply tropNullity_mono <;> aesop
  refine le_trans h_triangle (add_le_add ?_ ?_)
  · unfold tropNullity
    have : Fintype.card G.ConnectedComponent ≤ Fintype.card (G ⊓ H).ConnectedComponent :=
      connectedComponent_card_anti_mono (G ⊓ H) G inf_le_left
    grind +suggestions
  · rw [tropNullity, tropNullity]
    have : Fintype.card H.ConnectedComponent ≤ Fintype.card (G ⊓ H).ConnectedComponent :=
      connectedComponent_card_anti_mono (G ⊓ H) H inf_le_right
    grind +suggestions

/-- **Filtration-level stability theorem** -/
theorem tropBarcodeDist_le_edgePerturbation
    (F H : GraphFiltration V) (N : ℕ) :
    tropBarcodeDist F H N ≤
      Finset.sup (Finset.range (N + 1))
        (fun i =>
          ((F.obj i).edgeFinset \ (H.obj i).edgeFinset).card +
          ((H.obj i).edgeFinset \ (F.obj i).edgeFinset).card) := by
  exact Finset.sup_mono_fun fun i _ =>
    tropNullity_stable_under_edgeSymmDiff (F.obj i) (H.obj i)

/-! ### One-Step Lipschitz Bound -/

theorem tropBarcode_step_le_newEdges
    (F : GraphFiltration V) (i : ℕ) :
    tropBarcode F (i + 1) - tropBarcode F i
      ≤ ((F.obj (i + 1)).edgeFinset \ (F.obj i).edgeFinset).card := by
  set G := F.obj i
  set H := F.obj (i + 1)
  have h_cc : Fintype.card H.ConnectedComponent ≤ Fintype.card G.ConnectedComponent := by
    exact Fintype.card_le_of_surjective
      (fun x => x.map (SimpleGraph.Hom.ofLE (F.mono (Nat.le_succ i))))
      (fun x => by obtain ⟨v, rfl⟩ := x.exists_rep; exact ⟨Quot.mk G.Reachable v, rfl⟩)
  unfold tropBarcode tropNullity
  grind

/-! ### Nonnegativity -/

theorem tropNullity_nonneg (G : SimpleGraph V) : 0 ≤ tropNullity G :=
  Nat.zero_le _