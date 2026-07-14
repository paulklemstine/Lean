/-
# Toughness, minimal toughness, and induced `K₁ ∪ P₄`-freeness

Toughness is a quantitative measure of how hard it is to disconnect a graph by
deleting vertices.  A graph `G` is **`1`-tough** if it is connected and, for every
set `S` of vertices, deleting `S` leaves at most `|S|` connected components.
Toughness is a classical *necessary* condition for Hamiltonicity: every graph that
admits a Hamiltonian cycle is `1`-tough (Chvátal).  The converse is famously false
— there exist graphs of arbitrarily high toughness with no Hamiltonian cycle — so
one restricts attention to structured graph classes.  A recurring theme is
**minimal** toughness: `G` is *minimally `1`-tough* when it is `1`-tough but the
removal of any single edge destroys `1`-toughness.  For such graphs a conjecture of
Kriesell asserts a uniform minimum degree of `2`, and it is known that within
several hereditary classes (defined by a forbidden induced subgraph) minimally
`1`-tough graphs are Hamiltonian.  The class studied here is that of
`(K₁ ∪ P₄)`-free graphs: graphs with no induced subgraph isomorphic to the disjoint
union of an isolated vertex and a path on four vertices.

This file develops a self-contained account of the underlying toughness machinery
and proves the structural results that power the theory:

* `numComp_le_of_le` — the **monotonicity of the component count**: adding edges can
  only merge components.  This is the exact reduction step by which any
  Hamiltonicity-vs-toughness argument is transported from a spanning cycle to the
  ambient graph.
* `isOneTough_complete` — complete graphs are `1`-tough.
* `oneTough_two_le_degree` — every `1`-tough graph on at least three vertices has
  minimum degree at least `2` (the vertex-side heart of Kriesell's minimum-degree
  programme).
* `complete_inducedFree_of_nonAdj` / `complete_inducedFree_K1P4` — a complete graph
  forbids every induced subgraph that has a non-edge; in particular it is
  `(K₁ ∪ P₄)`-free.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The correct atomic notion is the *component count*
  `numComp G S = |components of G − S|`.  Toughness, minimal toughness and the
  Chvátal necessary condition should all reduce to two facts about this count:
  (i) it is monotone under edge additions, and (ii) on a cycle it is bounded by
  `|S|`.  Fact (i) is graph-class independent and should be provable in full.
Experiment (Experimenter): `numComp` is realised as the cardinality of the
  connected-component type of the induced subgraph on the complement of `S`.
  The identity vertex map is a graph homomorphism `G.induce s →g H.induce s`
  whenever `G ≤ H`; the induced map on components is surjective, giving (i) via
  `Nat.card_le_card_of_surjective`.  Complete graphs have every induced subgraph
  connected, so their component count never exceeds one — hence they are `1`-tough.
  The minimum-degree theorem isolates a degree-`≤ 1` vertex `v` with neighbour `u`
  and deletes `S = {u}`: `v` becomes isolated, so `G − u` has at least two
  components while `|S| = 1`, contradicting `1`-toughness.
Analysis (Analyst): The component count is the load-bearing invariant.  Its
  monotonicity is the graph-theoretic content of "a Hamiltonian cycle certifies
  toughness"; the singleton-deletion argument is the content of "tough graphs have
  no near-pendant vertices".  Both are genuinely structural (surjections on
  quotient types, reachability from an isolated vertex), not computational.
Critique (Critic): We keep `IsOneTough` faithful (connectivity **and** the count
  inequality) rather than the vacuous count-only version, so that boundary
  witnesses such as disconnected graphs are correctly excluded.  The forbidden
  graph `K₁ ∪ P₄` is pinned down as a concrete `SimpleGraph (Fin 5)` and verified
  to have the intended non-edges, preventing a silent mis-encoding.
Synthesis (PI): Monotonicity, complete-graph toughness, the minimum-degree
  theorem, and the `(K₁ ∪ P₄)`-freeness of complete graphs assemble into a
  compact, reusable toughness toolkit; the full Hamiltonicity theorem for
  minimally `1`-tough `(K₁ ∪ P₄)`-free graphs is recorded as a future direction.
-/

import Mathlib

open SimpleGraph Finset

namespace ToughP4

variable {V : Type*}

/-! ## Component count and toughness -/

/-- The number of connected components remaining after deleting a set `S` of
vertices, i.e. the number of components of the subgraph induced on the complement
of `S`. -/
noncomputable def numComp [Fintype V] (G : SimpleGraph V) (S : Finset V) : ℕ :=
  Nat.card (G.induce ((↑S : Set V)ᶜ)).ConnectedComponent

/-- A graph is `1`-tough if it is connected and deleting any vertex set `S` leaves
at most `|S|` connected components. -/
def IsOneTough [Fintype V] (G : SimpleGraph V) : Prop :=
  G.Connected ∧ ∀ S : Finset V, 2 ≤ numComp G S → numComp G S ≤ S.card

/-- `G` is *minimally `1`-tough* if it is `1`-tough but deleting any single edge
destroys `1`-toughness. -/
def MinimallyOneTough [Fintype V] [DecidableEq V] (G : SimpleGraph V) : Prop :=
  IsOneTough G ∧ ∀ e ∈ G.edgeSet, ¬ IsOneTough (G \ fromEdgeSet {e})

/-- `G` contains no induced copy of `H`: no injective vertex map is simultaneously
adjacency-preserving and adjacency-reflecting. -/
def InducedFree {W : Type*} (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  ¬ ∃ f : W ↪ V, ∀ a b, H.Adj a b ↔ G.Adj (f a) (f b)

/-! ## Monotonicity of the component count (the Chvátal reduction step) -/

/-- **Adding edges can only merge components.**  If `G ≤ H` then deleting the same
set of vertices from `H` leaves at most as many components as from `G`.  This is the
reduction step underlying every toughness-from-Hamiltonicity argument: a spanning
Hamiltonian cycle `C ≤ G` transports its component bound to `G`. -/
theorem numComp_le_of_le [Fintype V] {G H : SimpleGraph V} (h : G ≤ H)
    (S : Finset V) : numComp H S ≤ numComp G S := by
  unfold numComp
  set s : Set V := ((↑S : Set V)ᶜ)
  let f : (G.induce s) →g (H.induce s) := ⟨id, fun {a b} hab => h hab⟩
  have hsurj : Function.Surjective (SimpleGraph.ConnectedComponent.map f) := by
    intro c
    refine c.ind ?_
    intro v
    exact ⟨(G.induce s).connectedComponentMk v, rfl⟩
  exact Nat.card_le_card_of_surjective _ hsurj

/-! ## Complete graphs are `1`-tough -/

/-- Deleting any vertex set from a complete graph leaves at most one component:
every induced subgraph of a complete graph is again complete, hence (pre)connected.
-/
theorem numComp_complete_le_one [Fintype V] (S : Finset V) :
    numComp (⊤ : SimpleGraph V) S ≤ 1 := by
  unfold numComp
  set s : Set V := ((↑S : Set V)ᶜ)
  have hpre : ((⊤ : SimpleGraph V).induce s).Preconnected := by
    intro a b
    by_cases hab : a = b
    · exact hab ▸ Reachable.refl a
    · exact Adj.reachable (by
        simp only [SimpleGraph.induce_adj, SimpleGraph.top_adj]
        exact fun hh => hab (Subtype.ext hh))
  have hsub := hpre.subsingleton_connectedComponent
  exact Finite.card_le_one_iff_subsingleton.mpr hsub

/-- Complete graphs on a nonempty vertex set are `1`-tough. -/
theorem isOneTough_complete [Fintype V] [Nonempty V] :
    IsOneTough (⊤ : SimpleGraph V) := by
  refine ⟨?_, ?_⟩
  · rw [connected_iff]
    refine ⟨fun a b => ?_, ‹Nonempty V›⟩
    rcases eq_or_ne a b with hh | hh
    · exact hh ▸ Reachable.refl a
    · exact Adj.reachable (by simpa using hh)
  · intro S hS
    exact absurd (le_trans hS (numComp_complete_le_one S)) (by norm_num)

/-! ## Minimum degree of `1`-tough graphs -/

/-- Reachability from a vertex incident to no edges forces equality: an isolated
vertex is its own connected component. -/
theorem reachable_eq_of_no_adj {H : SimpleGraph V} {a c : V}
    (ha : ∀ b, ¬ H.Adj a b) (h : H.Reachable a c) : a = c := by
  obtain ⟨p⟩ := h
  cases p with
  | nil => rfl
  | cons hadj q => exact absurd hadj (ha _)

/-- Two mutually unreachable vertices witness at least two connected components. -/
theorem two_le_card_connectedComponent [Fintype V] {H : SimpleGraph V} {x y : V}
    (hxy : ¬ H.Reachable x y) : 2 ≤ Nat.card H.ConnectedComponent := by
  have hne : H.connectedComponentMk x ≠ H.connectedComponentMk y :=
    fun heq => hxy (SimpleGraph.ConnectedComponent.eq.mp heq)
  have : Nontrivial H.ConnectedComponent := ⟨_, _, hne⟩
  exact Finite.one_lt_card_iff_nontrivial.mpr this

/-- **`1`-tough graphs have minimum degree at least two.**  In a `1`-tough graph on
at least three vertices no vertex can have degree `0` (that would disconnect the
graph) or degree `1` (deleting its unique neighbour would isolate it, producing two
components after a single deletion).  This is the vertex-local core of Kriesell's
minimum-degree programme for minimally `1`-tough graphs. -/
theorem oneTough_two_le_degree [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    (hG : IsOneTough G) (hcard : 3 ≤ Fintype.card V) (v : V) :
    2 ≤ (G.neighborSet v).ncard := by
  obtain ⟨hconn, htough⟩ := hG
  by_contra hcon
  have hle : (G.neighborSet v).ncard ≤ 1 := by omega
  by_cases h0 : (G.neighborSet v).ncard = 0
  · have hset : G.neighborSet v = ∅ := (Set.ncard_eq_zero (Set.toFinite _)).mp h0
    have hnoadj : ∀ b, ¬ G.Adj v b := by
      intro b hb
      have : b ∈ G.neighborSet v := hb
      rw [hset] at this; exact this
    obtain ⟨w, hw⟩ := Fintype.exists_ne_of_one_lt_card (by omega) v
    exact hw (reachable_eq_of_no_adj hnoadj (hconn.preconnected v w)).symm
  · have h1 : (G.neighborSet v).ncard = 1 := by omega
    obtain ⟨u, hu⟩ := Set.ncard_eq_one.mp h1
    have hvu : v ≠ u := by
      have hmem : u ∈ G.neighborSet v := by rw [hu]; exact rfl
      exact G.ne_of_adj hmem
    have hne : (Finset.univ \ {v, u}).Nonempty := by
      rw [Finset.sdiff_nonempty]
      intro hsub
      have hcle : Fintype.card V ≤ ({v, u} : Finset V).card := by
        simpa [Finset.card_univ] using Finset.card_le_card hsub
      have hcardsub : ({v, u} : Finset V).card ≤ 2 :=
        (Finset.card_insert_le _ _).trans (by simp)
      omega
    obtain ⟨w, hwmem⟩ := hne
    rw [Finset.mem_sdiff] at hwmem
    have hwv : w ≠ v := fun h => hwmem.2 (by rw [h]; exact Finset.mem_insert_self _ _)
    have hwu : w ≠ u := fun h => hwmem.2 (by rw [h]; simp)
    have hvc : v ∈ ((↑({u} : Finset V) : Set V)ᶜ) := by
      simp only [Set.mem_compl_iff, Finset.coe_singleton, Set.mem_singleton_iff]; exact hvu
    have hwc : w ∈ ((↑({u} : Finset V) : Set V)ᶜ) := by
      simp only [Set.mem_compl_iff, Finset.coe_singleton, Set.mem_singleton_iff]; exact hwu
    set Gs := G.induce ((↑({u} : Finset V) : Set V)ᶜ) with hGs
    have hisol : ∀ b, ¬ Gs.Adj ⟨v, hvc⟩ b := by
      rintro ⟨b, hb⟩ hadj
      rw [hGs, SimpleGraph.induce_adj] at hadj
      have hbn : b ∈ G.neighborSet v := hadj
      rw [hu, Set.mem_singleton_iff] at hbn
      simp only [Set.mem_compl_iff, Finset.coe_singleton, Set.mem_singleton_iff] at hb
      exact hb hbn
    have hnr : ¬ Gs.Reachable ⟨v, hvc⟩ ⟨w, hwc⟩ := by
      intro hr
      have heq := reachable_eq_of_no_adj hisol hr
      exact hwv (congrArg Subtype.val heq).symm
    have h2 : 2 ≤ numComp G {u} := two_le_card_connectedComponent hnr
    have hfin := htough {u} h2
    simp only [Finset.card_singleton] at hfin
    omega

/-! ## Induced `K₁ ∪ P₄`-freeness of complete graphs -/

/-- A complete graph forbids, as an induced subgraph, any graph that possesses a
non-edge: an induced embedding would have to send a non-adjacent pair to a
non-adjacent pair, but distinct vertices of a complete graph are always adjacent. -/
theorem complete_inducedFree_of_nonAdj [Fintype V] {W : Type*} (H : SimpleGraph W)
    {a b : W} (hab : a ≠ b) (hnadj : ¬ H.Adj a b) :
    InducedFree H (⊤ : SimpleGraph V) := by
  rintro ⟨f, hf⟩
  apply hnadj
  rw [hf a b]
  simp [Function.Embedding.injective f |>.ne_iff.mpr hab]

/-- The graph `K₁ ∪ P₄`: an isolated vertex `0` together with the path `1-2-3-4`. -/
def K1P4 : SimpleGraph (Fin 5) :=
  SimpleGraph.fromRel (fun a b =>
    (a = 1 ∧ b = 2) ∨ (a = 2 ∧ b = 3) ∨ (a = 3 ∧ b = 4))

/-- The isolated vertex `0` of `K₁ ∪ P₄` is non-adjacent to the path endpoint `1`. -/
theorem K1P4_not_adj_zero_one : ¬ K1P4.Adj 0 1 := by
  simp [K1P4, SimpleGraph.fromRel_adj]

/-- The path `1-2-3-4` is genuinely induced: `1` and `3` are non-adjacent. -/
theorem K1P4_not_adj_one_three : ¬ K1P4.Adj 1 3 := by
  simp [K1P4, SimpleGraph.fromRel_adj]

/-- Consecutive path vertices are adjacent. -/
theorem K1P4_adj_one_two : K1P4.Adj 1 2 := by
  simp [K1P4, SimpleGraph.fromRel_adj]

/-- **Complete graphs are `(K₁ ∪ P₄)`-free.**  Since `K₁ ∪ P₄` contains the non-edge
`0-1`, no complete graph can contain it as an induced subgraph. -/
theorem complete_inducedFree_K1P4 [Fintype V] :
    InducedFree K1P4 (⊤ : SimpleGraph V) :=
  complete_inducedFree_of_nonAdj K1P4 (by decide) K1P4_not_adj_zero_one

/-! ## Boundary witnesses -/

/-- A disconnected graph is never `1`-tough: `1`-toughness demands connectivity.
This marks the boundary of the theory — the toughness inequality alone is not
enough. -/
theorem not_isOneTough_bot [Fintype V] (h : 2 ≤ Fintype.card V) :
    ¬ IsOneTough (⊥ : SimpleGraph V) := by
  rintro ⟨hconn, -⟩
  obtain ⟨a, b, hab⟩ := Fintype.exists_pair_of_one_lt_card h
  have hr := hconn.preconnected a b
  rw [SimpleGraph.reachable_bot] at hr
  exact hab hr

/-! ## Examples and sanity checks -/

/-- The complete graph on three vertices is `1`-tough. -/
example : IsOneTough (⊤ : SimpleGraph (Fin 3)) := isOneTough_complete

/-- The complete graph on five vertices is `(K₁ ∪ P₄)`-free. -/
example : InducedFree K1P4 (⊤ : SimpleGraph (Fin 5)) := complete_inducedFree_K1P4

#check @numComp_le_of_le
#check @oneTough_two_le_degree
#check @complete_inducedFree_K1P4
#check @MinimallyOneTough

end ToughP4