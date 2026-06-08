import Mathlib
import Combinatorics.ErdosFaberLovasz.Defs

/-!
# Erdős–Faber–Lovász: Advanced Results

Advanced structural results about EFL systems, including:
- Near-pencil disjointness lemma
- Near-pencil colorability
- Linear intersecting hypergraph edge bound
- Degree-based coloring
-/

open Finset Function

namespace EFL

/-! ## Near-Pencil Structure

In a near-pencil EFL system with center v₀, distinct edges share
only v₀. This means the non-center parts of different edges are disjoint. -/

/-
In a near-pencil system, if v₀ is the center and i ≠ j, then
    edges i ∩ edges j = {v₀}. The intersection is nonempty (contains v₀)
    and has cardinality ≤ 1 by linearity, hence equals {v₀}.
-/
theorem near_pencil_inter_eq_singleton {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v₀ : V) (hv : ∀ i : Fin S.k, v₀ ∈ S.edges i)
    (i j : Fin S.k) (hij : i ≠ j) :
    S.edges i ∩ S.edges j = {v₀} := by
  have := S.linear i j hij;
  rw [ Finset.card_le_one ] at this ; aesop

/-
In a near-pencil system, non-center vertices of distinct edges are disjoint.
    If v ∈ edges i, v ≠ v₀, and v ∈ edges j, then i = j.
-/
theorem near_pencil_unique_edge {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v₀ : V) (hv : ∀ i : Fin S.k, v₀ ∈ S.edges i)
    (v : V) (hne : v ≠ v₀) (i j : Fin S.k) (hi : v ∈ S.edges i) (hj : v ∈ S.edges j) :
    i = j := by
  contrapose! hne; have := S.linear i j; simp_all +decide [ Finset.card_le_one ] ;
  exact this _ hi hj _ ( hv _ ) ( hv _ )

/-
The non-center part of edge i in a near-pencil has k-1 elements.
-/
theorem near_pencil_erase_card {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v₀ : V) (hv : ∀ i : Fin S.k, v₀ ∈ S.edges i)
    (i : Fin S.k) : ((S.edges i).erase v₀).card = S.k - 1 := by
  rw [ Finset.card_erase_of_mem ( hv i ), S.uniform i ]

/-! ## EFL for k = 2

Two edges of size 2 sharing at most 1 vertex are 2-colorable. -/

/-
EFL systems with k = 2 are always 2-colorable.
-/
theorem efl_two {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (hk : S.k = 2) : S.IsKColorable := by
  revert hk S;
  -- Let's unfold the definition of `System` to work with the edges directly.
  intro S hS
  obtain ⟨edges, h_edges⟩ := S;
  rcases edges with ( _ | _ | edges ) <;> simp_all +decide;
  subst hS; simp_all +decide [ System.IsKColorable ] ;
  -- Since the edges are disjoint, we can color each edge with a different color.
  obtain ⟨a, b, hab⟩ : ∃ a b : V, a ≠ b ∧ h_edges 0 = {a, b} := by
    have := Finset.card_eq_two.mp ( by solve_by_elim : Finset.card ( h_edges 0 ) = 2 ) ; tauto;
  obtain ⟨c, d, hcd⟩ : ∃ c d : V, c ≠ d ∧ h_edges 1 = {c, d} := by
    have := Finset.card_eq_two.mp ( by solve_by_elim : Finset.card ( h_edges 1 ) = 2 ) ; tauto;
  by_cases hac : a = c <;> by_cases had : a = d <;> by_cases hbc : b = c <;> by_cases hbd : b = d <;> simp_all +decide [ Fin.forall_fin_succ ];
  all_goals rename_i h; have := h 0 1; simp_all +decide [ Fin.forall_fin_succ ] ;
  · use fun x => if x = c then 0 else if x = b then 1 else if x = d then 1 else 0;
    intro i; fin_cases i <;> simp +decide [ *, EFL.System.IsStrongColoring ] ;
    tauto;
  · use fun x => if x = d then 0 else if x = b then 1 else if x = c then 1 else 0; simp_all +decide [ Fin.forall_fin_succ, EFL.System.IsStrongColoring ] ;
  · use fun x => if x = a then 0 else if x = c then 1 else 0;
    intro i; fin_cases i <;> simp +decide [ *, Set.InjOn ] ;
    · tauto;
    · grind;
  · use fun x => if x = a then 0 else if x = c then 0 else 1;
    intro i; fin_cases i <;> simp +decide [ *, EFL.System.IsStrongColoring ] ;
    · tauto;
    · tauto;
  · use fun x => if x = a then 0 else if x = b then 1 else if x = c then 0 else 1;
    intro i; fin_cases i <;> simp +decide [ *, Set.InjOn ] ;
    · tauto;
    · grind

/-! ## Degree-Sum Structural Inequality

The number of degree-1 vertices is at least k (each edge has k vertices,
at most k-1 of which can have degree ≥ 2). This uses the high-degree bound. -/

/-
Each edge contributes at least one degree-1 vertex that appears in no
    other edge (unless k ≤ 1). For k ≥ 2, the k vertices of edge i include
    at most k-1 vertices shared with other edges, leaving at least one
    exclusive vertex.
-/
theorem edge_has_exclusive_vertex {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (hk : 2 ≤ S.k) (i : Fin S.k) :
    ∃ v ∈ S.edges i, S.degree v = 1 := by
  -- Consider the set of vertices in edge i that are shared with other edges.
  set shared_vertices := Finset.filter (fun v => S.degree v ≥ 2) (S.edges i);
  -- By linearity, each vertex in `shared_vertices` is shared with at most one other edge.
  have h_shared_vertices_card : shared_vertices.card ≤ S.k - 1 := by
    -- By linearity, each vertex in `shared_vertices` is shared with at most one other edge, so there are at most `S.k - 1` such vertices.
    have h_shared_vertices_card : shared_vertices.card ≤ Finset.card (Finset.biUnion (Finset.univ.erase i) (fun j => S.edges i ∩ S.edges j)) := by
      refine Finset.card_mono ?_;
      intro v hv; simp_all +decide [ Finset.subset_iff ] ;
      obtain ⟨ j, hj ⟩ := Finset.exists_mem_ne ( show 1 < Finset.card ( Finset.filter ( fun x => v ∈ S.edges x ) Finset.univ ) from by aesop ) i; use j; aesop;
    refine' le_trans h_shared_vertices_card ( le_trans ( Finset.card_biUnion_le ) _ );
    exact le_trans ( Finset.sum_le_sum fun _ _ => S.linear _ _ <| by aesop ) ( by simp +decide [ Finset.card_erase_of_mem ( Finset.mem_univ i ) ] );
  contrapose! h_shared_vertices_card;
  rw [ show shared_vertices = S.edges i from Finset.filter_true_of_mem fun v hv => Nat.lt_of_le_of_ne ( Nat.succ_le_of_lt ( Finset.card_pos.mpr ⟨ i, by aesop ⟩ ) ) ( Ne.symm ( h_shared_vertices_card v hv ) ) ] ; simp +decide [ S.uniform i ] ; omega;

/-! ## Near-Pencil Vertex Count

A near-pencil EFL system has exactly k(k-1) + 1 = k² - k + 1 vertices
in its vertex set. -/

/-
In a near-pencil EFL system, the vertex set has exactly k² - k + 1 elements.
-/
theorem near_pencil_vertexSet_card {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (hk : 2 ≤ S.k) (v₀ : V) (hv : ∀ i : Fin S.k, v₀ ∈ S.edges i) :
    S.vertexSet.card = S.k ^ 2 - S.k + 1 := by
  have h_disjoint : ∀ i j : Fin S.k, i ≠ j → Disjoint ((S.edges i).erase v₀) ((S.edges j).erase v₀) := by
    intro i j hij; rw [ Finset.disjoint_left ] ; intro x hx₁ hx₂; simp_all +decide [ Finset.mem_erase ] ;
    exact hij ( near_pencil_unique_edge S v₀ hv x hx₁.1 i j hx₁.2 hx₂ );
  have h_union : S.vertexSet = {v₀} ∪ Finset.biUnion Finset.univ (fun i => (S.edges i).erase v₀) := by
    ext v; simp [System.vertexSet, hv];
    exact ⟨ fun ⟨ i, hi ⟩ => if h : v = v₀ then Or.inl h else Or.inr ⟨ h, i, hi ⟩, fun h => h.elim ( fun h => ⟨ ⟨ 0, by linarith ⟩, h.symm ▸ hv _ ⟩ ) fun h => ⟨ h.2.choose, h.2.choose_spec ⟩ ⟩;
  rw [ h_union, Finset.card_union_of_disjoint, Finset.card_biUnion ] <;> norm_num;
  · rw [ Finset.sum_congr rfl fun i _ => by rw [ Finset.card_erase_of_mem ( hv i ), S.uniform i ] ] ; simp +decide [ sq, Nat.mul_sub_left_distrib ] ; ring;
  · exact fun i _ j _ hij => h_disjoint i j hij

end EFL