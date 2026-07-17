import Mathlib

open SimpleGraph Finset

/-!
# Toughness as an order-monotone invariant

This file packages the component-count definition of `1`-toughness as an
order-theoretic graph invariant.  Its main result, `isOneTough_mono`, says that
adding edges preserves `1`-toughness.  It also gives contrapositives and explicit
witness extraction for graphs which fail the toughness inequality.
-/

namespace ToughnessOrder

variable {V : Type*}

/-- Number of connected components after deleting the finite vertex set `S`. -/
noncomputable def numComp [Fintype V] (G : SimpleGraph V) (S : Finset V) : ℕ :=
  Nat.card (G.induce ((↑S : Set V)ᶜ)).ConnectedComponent

/-- A finite graph is `1`-tough when it is connected and every deletion producing
at least two components produces no more components than deleted vertices. -/
def IsOneTough [Fintype V] (G : SimpleGraph V) : Prop :=
  G.Connected ∧ ∀ S : Finset V, 2 ≤ numComp G S → numComp G S ≤ S.card

/-
Adding edges can only merge connected components, even after deleting an
arbitrary fixed set of vertices.
-/
theorem numComp_le_of_le [Fintype V] {G H : SimpleGraph V} (h : G ≤ H)
    (S : Finset V) : numComp H S ≤ numComp G S := by
  -- Use the identity graph homomorphism between the induced subgraphs.
  set f : (G.induce ((S : Set V)ᶜ)) →g (H.induce ((S : Set V)ᶜ)) := ⟨fun x => x, fun hab => by
    exact h hab⟩
  generalize_proofs at *;
  -- Prove that the map on connected components is surjective.
  have h_surjective : Function.Surjective (SimpleGraph.ConnectedComponent.map f) := by
    rintro ⟨ x ⟩
    generalize_proofs at *;
    exact ⟨ Quot.mk _ x, rfl ⟩
  generalize_proofs at *;
  convert Nat.card_le_card_of_surjective _ h_surjective

/-
The component-count profile is antitone in the graph order.
-/
theorem numComp_antitone [Fintype V] (S : Finset V) :
    Antitone (fun G : SimpleGraph V => numComp G S) := by
  intro G H hGH;
  convert numComp_le_of_le hGH S

/-
Connectivity is preserved when edges are added.
-/
theorem connected_mono {G H : SimpleGraph V} (hGH : G ≤ H) (hG : G.Connected) :
    H.Connected := by
  convert hG.mono hGH

/-
**Main theorem: `1`-toughness is upward closed in the graph order.**
-/
theorem isOneTough_mono [Fintype V] {G H : SimpleGraph V}
    (hGH : G ≤ H) (hG : IsOneTough G) : IsOneTough H := by
  refine' ⟨ connected_mono hGH hG.1, fun S hS => _ ⟩;
  exact le_trans ( numComp_le_of_le hGH S ) ( hG.2 S ( by linarith [ numComp_le_of_le hGH S ] ) )

/-
Equivalently, failure of `1`-toughness is downward closed.
-/
theorem not_isOneTough_anti [Fintype V] {G H : SimpleGraph V}
    (hGH : G ≤ H) (hH : ¬ IsOneTough H) : ¬ IsOneTough G := by
  exact fun h => hH <| isOneTough_mono hGH h

/-- The collection of `1`-tough graphs, viewed as a set in the graph lattice. -/
def oneToughGraphs [Fintype V] : Set (SimpleGraph V) := {G | IsOneTough G}

/-
Order-theoretic packaging of the main theorem: the set of tough graphs is an
upper set.
-/
theorem oneToughGraphs_isUpperSet [Fintype V] :
    IsUpperSet (oneToughGraphs (V := V)) := by
  exact fun G H hGH hG => isOneTough_mono hGH hG

/-
A connected graph which is not `1`-tough has an explicit deletion set whose
component count is both nontrivial and too large.
-/
theorem exists_toughness_violation [Fintype V] {G : SimpleGraph V}
    (hconn : G.Connected) (hnot : ¬ IsOneTough G) :
    ∃ S : Finset V, 2 ≤ numComp G S ∧ S.card < numComp G S := by
  contrapose! hnot; simp_all +decide [ IsOneTough ] ;

/-
A toughness violation in a supergraph is also a violation in every subgraph:
the same deleted vertex set works.
-/
theorem violation_descends [Fintype V] {G H : SimpleGraph V} (hGH : G ≤ H)
    {S : Finset V} (h2 : 2 ≤ numComp H S) (hbad : S.card < numComp H S) :
    2 ≤ numComp G S ∧ S.card < numComp G S := by
  -- Adding edges can only merge connected components, even after deleting an arbitrary fixed set of vertices.
  have numComp_le_of_le : numComp H S ≤ numComp G S := by
    convert numComp_le_of_le hGH S using 1;
  exact ⟨ h2.trans numComp_le_of_le, hbad.trans_le numComp_le_of_le ⟩

/-
For connected graphs, non-toughness descends with an explicit common witness.
-/
theorem exists_common_violation_of_le [Fintype V] {G H : SimpleGraph V}
    (hGH : G ≤ H) (hHconn : H.Connected) (hHnot : ¬ IsOneTough H) :
    ∃ S : Finset V,
      (2 ≤ numComp H S ∧ S.card < numComp H S) ∧
      (2 ≤ numComp G S ∧ S.card < numComp G S) := by
  obtain ⟨S, hS₂, hSbad⟩ := exists_toughness_violation hHconn hHnot
  exact ⟨S, ⟨hS₂, hSbad⟩, violation_descends hGH hS₂ hSbad⟩

/-
Any tough spanning subgraph certifies toughness of the ambient graph.  This is
the abstract form of the usual Hamiltonian-cycle reduction.
-/
theorem isOneTough_of_spanning_certificate [Fintype V] {C G : SimpleGraph V}
    (hCG : C ≤ G) (hC : IsOneTough C) : IsOneTough G := by
  apply isOneTough_mono hCG hC

/-
Adding all edges of an arbitrary graph to a tough graph preserves toughness.
-/
theorem isOneTough_sup_left [Fintype V] (G : SimpleGraph V) {H : SimpleGraph V}
    (hH : IsOneTough H) : IsOneTough (H ⊔ G) := by
  exact isOneTough_mono ( le_sup_left ) hH

/-
The supremum of two graphs is tough as soon as either constituent is tough.
-/
theorem isOneTough_sup [Fintype V] {G H : SimpleGraph V}
    (h : IsOneTough G ∨ IsOneTough H) : IsOneTough (G ⊔ H) := by
  cases' h with h h;
  · exact isOneTough_mono le_sup_left h;
  · exact isOneTough_mono ( le_sup_right ) h

/-
On a nonempty finite vertex type, the complete graph is `1`-tough.  This
also demonstrates that the upper set of tough graphs contains the lattice top.
-/
theorem isOneTough_top [Fintype V] [Nonempty V] :
    IsOneTough (⊤ : SimpleGraph V) := by
  refine' ⟨ _, _ ⟩;
  · simp +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
  · intro S;
    -- The induced graph on the complement of S is complete, hence it is preconnected.
    have h_preconnected : (⊤ : SimpleGraph V).induce ((↑S : Set V)ᶜ) |>.Preconnected := by
      intro v w; by_cases hvw : v = w <;> simp +decide [ hvw ] ;
    have h_subsingleton : Subsingleton ((⊤ : SimpleGraph V).induce ((↑S : Set V)ᶜ)).ConnectedComponent := by
      exact Preconnected.subsingleton_connectedComponent h_preconnected
    have h_card_le_one : Nat.card ((⊤ : SimpleGraph V).induce ((↑S : Set V)ᶜ)).ConnectedComponent ≤ 1 := by
      exact Finite.card_le_one_iff_subsingleton.mpr h_subsingleton
    exact fun h => absurd h ( not_le_of_gt ( lt_of_le_of_lt h_card_le_one ( by decide ) ) )

end ToughnessOrder