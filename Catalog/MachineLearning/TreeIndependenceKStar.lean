import Mathlib

/-!
# Tree-independence number of `K_{1,d}`-free, `H`-induced-minor-free graphs

This file formalizes a conjecture in structural graph theory:

> For every integer `d ≥ 2` and every planar graph `H`, there is a constant `C(d,H)` such
> that every connected graph `G` that is both `K_{1,d}`-free and `H`-induced-minor-free
> satisfies `α-tw(G) ≤ C(d,H)`, where `α-tw(G)` is the *tree-independence number*.

We build the required infrastructure from scratch (none of treewidth, tree decompositions,
induced minors, or the tree-independence number are in Mathlib), prove the elementary degree
facts, prove the reduction between treewidth and tree-independence number for bounded-degree
graphs, and finally give a complete *conditional* proof of the conjecture: assuming the
treewidth bound for bounded-degree `H`-induced-minor-free graphs (which is exactly what the
Robertson–Seymour grid-minor theorem provides when `H` is planar), the tree-independence
number is bounded by that treewidth bound plus one.

## Main definitions

* `TreeIndepKStar.IsKStarFree d G` : `G` contains no `K_{1,d}` subgraph (equivalently, every
  vertex has fewer than `d` neighbours).
* `TreeIndepKStar.HasInducedMinor H G` : `H` is an induced minor of `G`.
* `TreeIndepKStar.TreeDecomp G` : a tree decomposition of `G`.
* `TreeIndepKStar.indepNumOn G B` : the independence number of the subgraph induced on `B`.
* `TreeIndepKStar.treewidth G`, `TreeIndepKStar.treeIndepNumber G` : the treewidth and the
  tree-independence number `α-tw(G)`.

## Main results

* `IsKStarFree.degree_lt`, `IsKStarFree.maxDegree_le`, `IsKStarFree.minDegree_le` : the degree
  bounds of task 2.
* `treeIndepNumber_le_treewidth_succ` : `α-tw(G) ≤ tw(G) + 1` (always).
* `treewidth_le_mul_treeIndepNumber` : `tw(G) ≤ (Δ+1)·α-tw(G)` for graphs of max degree `≤ Δ`;
  together these show treewidth and tree-independence number are linearly equivalent in the
  bounded-degree setting.
* `treeIndepNumber_bounded_of_treewidth_bound` : the conjecture, with the explicit bound
  `C(d,H) = B(d,H) + 1`, where `B(d,H)` is the treewidth bound for connected, max-degree-`≤(d-1)`,
  `H`-induced-minor-free graphs supplied by the grid-minor theorem.
-/

namespace TreeIndepKStar

open SimpleGraph Finset

variable {V W : Type*}

/-! ## `K_{1,d}`-free graphs -/

/-- `G` is `K_{1,d}`-free: it contains no copy of the star `K_{1,d}` as a subgraph.
Concretely, no vertex `v` has `d` distinct neighbours. -/
def IsKStarFree (d : ℕ) (G : SimpleGraph V) : Prop :=
  ∀ v : V, ¬ ∃ s : Finset V, s.card = d ∧ ∀ w ∈ s, G.Adj v w

/-- A `K_{1,d}`-free graph has every degree strictly less than `d`. -/
theorem IsKStarFree.degree_lt [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj]
    {d : ℕ} (h : IsKStarFree d G) (v : V) : G.degree v < d := by
  by_contra hge
  push_neg at hge
  have hge' : d ≤ (G.neighborFinset v).card := by
    rw [G.card_neighborFinset_eq_degree]; exact hge
  obtain ⟨s, hs_sub, hs_card⟩ := Finset.exists_subset_card_eq hge'
  exact h v ⟨s, hs_card, fun w hw => (G.mem_neighborFinset v w).1 (hs_sub hw)⟩

/-- A `K_{1,d}`-free graph (`1 ≤ d`) has maximum degree at most `d - 1`. -/
theorem IsKStarFree.maxDegree_le [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] {d : ℕ} (hd : 1 ≤ d) (h : IsKStarFree d G) :
    G.maxDegree ≤ d - 1 := by
  apply SimpleGraph.maxDegree_le_of_forall_degree_le
  intro v
  have := h.degree_lt G v
  omega

/-- A `K_{1,d}`-free graph (`1 ≤ d`) has minimum degree at most `d - 1`. -/
theorem IsKStarFree.minDegree_le [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] {d : ℕ} (hd : 1 ≤ d) (h : IsKStarFree d G) :
    G.minDegree ≤ d - 1 :=
  (SimpleGraph.minDegree_le_maxDegree G).trans (h.maxDegree_le G hd)

/-- **Task 2.** A connected `K_{1,d}`-free graph (`d ≥ 2`) has both minimum and maximum degree
at most `d - 1`.  (The connectivity hypothesis is not actually needed for the degree bounds; it
is kept because it is part of the statement requested.) -/
theorem IsKStarFree.degree_bounds [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] {d : ℕ} (hd : 2 ≤ d) (_hconn : G.Connected) (h : IsKStarFree d G) :
    G.minDegree ≤ d - 1 ∧ G.maxDegree ≤ d - 1 :=
  ⟨h.minDegree_le G (by omega), h.maxDegree_le G (by omega)⟩

/-! ## Induced minors -/

/-- `H` is an *induced minor* of `G`: there are pairwise-disjoint branch sets `branch h`
(`h` a vertex of `H`), each inducing a connected subgraph of `G`, such that for `h ≠ h'`
there is an edge of `G` between `branch h` and `branch h'` **iff** `h` and `h'` are adjacent
in `H`.  (The "iff" is what distinguishes induced minors from ordinary minors.) -/
def HasInducedMinor (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  ∃ branch : W → Set V,
    (∀ h : W, (G.induce (branch h)).Connected) ∧
    (∀ h h' : W, h ≠ h' → Disjoint (branch h) (branch h')) ∧
    (∀ h h' : W, h ≠ h' →
      ((∃ a ∈ branch h, ∃ b ∈ branch h', G.Adj a b) ↔ H.Adj h h'))

/-! ## Independence number of an induced subgraph -/

open scoped Classical in
/-- The independence number of the subgraph of `G` induced on a finite set `B`: the largest
size of an independent set contained in `B`. -/
noncomputable def indepNumOn [Fintype V] (G : SimpleGraph V) (B : Finset V) : ℕ :=
  (B.powerset.filter (fun s : Finset V => G.IsIndepSet (s : Set V))).sup Finset.card

theorem indepNumOn_le_card [Fintype V] (G : SimpleGraph V) (B : Finset V) :
    indepNumOn G B ≤ B.card := by
  classical
  rw [indepNumOn]
  apply Finset.sup_le
  intro s hs
  rw [Finset.mem_filter, Finset.mem_powerset] at hs
  exact Finset.card_le_card hs.1

/-- `indepNumOn` is attained: there is an independent set `s ⊆ B` with `s.card = indepNumOn G B`. -/
theorem exists_indepNumOn [Fintype V] (G : SimpleGraph V) (B : Finset V) :
    ∃ s : Finset V, s ⊆ B ∧ G.IsIndepSet (s : Set V) ∧ s.card = indepNumOn G B := by
  classical
  have hne : (B.powerset.filter (fun s : Finset V => G.IsIndepSet (s : Set V))).Nonempty := by
    refine ⟨∅, ?_⟩
    simp [Finset.mem_filter, Finset.mem_powerset, SimpleGraph.isIndepSet_iff]
  obtain ⟨s, hs, hsup⟩ := Finset.exists_mem_eq_sup _ hne Finset.card
  rw [Finset.mem_filter, Finset.mem_powerset] at hs
  exact ⟨s, hs.1, hs.2, by rw [indepNumOn]; exact hsup.symm⟩

/-- Lower-bounding `indepNumOn` by exhibiting an independent set inside `B`. -/
theorem le_indepNumOn [Fintype V] (G : SimpleGraph V) {B s : Finset V}
    (hsB : s ⊆ B) (hind : G.IsIndepSet (s : Set V)) : s.card ≤ indepNumOn G B := by
  classical
  rw [indepNumOn]
  apply Finset.le_sup (f := Finset.card)
  rw [Finset.mem_filter, Finset.mem_powerset]
  exact ⟨hsB, hind⟩

/-- **Key combinatorial bound.**  In a graph of maximum degree at most `Δ`, every finite set `B`
contains an independent set of size at least `|B|/(Δ+1)`; equivalently
`|B| ≤ (Δ+1)·indepNumOn G B`. -/
theorem card_le_indepNumOn [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]
    {Δ : ℕ} (hΔ : G.maxDegree ≤ Δ) (B : Finset V) :
    B.card ≤ (Δ + 1) * indepNumOn G B := by
  have h_ind : ∀ B : Finset V, ∀ v ∈ B, ∃ B' ⊆ B, B'.card < B.card ∧ B.card ≤ B'.card + (Δ + 1) ∧ indepNumOn G B ≥ indepNumOn G B' + 1 := by
    intro B v hv
    obtain ⟨s', hs'⟩ : ∃ s' : Finset V, s' ⊆ B \ (insert v (G.neighborFinset v)) ∧ G.IsIndepSet (s' : Set V) ∧ s'.card = indepNumOn G (B \ (insert v (G.neighborFinset v))) := by
      exact exists_indepNumOn G _;
    refine' ⟨ B \ ( insert v ( G.neighborFinset v ) ), _, _, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
    · grind;
    · have h_card : (insert v (G.neighborFinset v)).card ≤ Δ + 1 := by
        have h_card : (G.neighborFinset v).card ≤ Δ := by
          exact le_trans ( SimpleGraph.degree_le_maxDegree _ _ ) hΔ;
        exact le_trans ( Finset.card_insert_le _ _ ) ( by linarith );
      grind;
    · refine' lt_of_lt_of_le _ ( le_indepNumOn G ( show insert v s' ⊆ B from _ ) _ );
      · grind;
      · exact Finset.insert_subset hv ( fun x hx => hs'.1 hx |>.1 );
      · simp_all +decide [ Set.Pairwise, SimpleGraph.isIndepSet_iff ];
        exact fun x hx => by simpa [ SimpleGraph.adj_comm ] using hs'.1 hx |>.2.2;
  induction' n : B.card using Nat.strong_induction_on with n ih generalizing B;
  by_cases hB : B.Nonempty;
  · obtain ⟨ B', hB', hB'', hB''', hB'''' ⟩ := h_ind B _ hB.choose_spec; nlinarith [ ih _ ( by linarith ) _ rfl ] ;
  · aesop

/-! ## Tree decompositions -/

/-- A graph on a `Nonempty`, `Subsingleton` vertex type is connected. -/
theorem connected_of_subsingleton {U : Type*} [Nonempty U] [Subsingleton U]
    (g : SimpleGraph U) : g.Connected := by
  refine SimpleGraph.Connected.mk (fun u v => ?_)
  rw [Subsingleton.elim u v]

/-- A *tree decomposition* of a finite graph `G`: a tree `tree` on a node set `T`, with a
bag `bag t ⊆ V` for each node, such that

* every edge of `G` is contained in some bag (`edge_cover`); and
* for every vertex `v`, the set of nodes whose bag contains `v` induces a connected (hence
  nonempty) subtree (`subtree_connected`), which also forces every vertex to lie in some bag.
-/
structure TreeDecomp [Fintype V] (G : SimpleGraph V) where
  /-- The node set of the decomposition tree. -/
  T : Type
  /-- The decomposition tree. -/
  tree : SimpleGraph T
  /-- The tree is indeed a tree. -/
  isTree : tree.IsTree
  /-- The bag assigned to each node. -/
  bag : T → Finset V
  /-- Every edge of `G` lies in a common bag. -/
  edge_cover : ∀ ⦃u v : V⦄, G.Adj u v → ∃ t, u ∈ bag t ∧ v ∈ bag t
  /-- For each vertex, the nodes containing it induce a connected subtree. -/
  subtree_connected : ∀ v : V, (tree.induce {t | v ∈ bag t}).Connected

/-- The trivial tree decomposition with a single bag equal to all of `V`. -/
def TreeDecomp.trivial [Fintype V] (G : SimpleGraph V) : TreeDecomp G where
  T := Unit
  tree := ⊤
  isTree := SimpleGraph.IsTree.of_subsingleton
  bag := fun _ => Finset.univ
  edge_cover := fun u v _ => ⟨(), Finset.mem_univ u, Finset.mem_univ v⟩
  subtree_connected := by
    intro v
    haveI : Nonempty {t : Unit // t ∈ {t : Unit | v ∈ (Finset.univ : Finset V)}} :=
      ⟨⟨(), Finset.mem_univ v⟩⟩
    haveI : Subsingleton {t : Unit // t ∈ {t : Unit | v ∈ (Finset.univ : Finset V)}} :=
      ⟨fun a b => Subtype.ext (Subsingleton.elim _ _)⟩
    exact connected_of_subsingleton _

/-- The treewidth of `G`: the least `k` such that some tree decomposition has all bags of size
at most `k + 1`. -/
noncomputable def treewidth [Fintype V] (G : SimpleGraph V) : ℕ :=
  sInf { k | ∃ D : TreeDecomp G, ∀ t, (D.bag t).card ≤ k + 1 }

/-- The tree-independence number `α-tw(G)`: the least `k` such that some tree decomposition has
every bag inducing a subgraph of independence number at most `k`. -/
noncomputable def treeIndepNumber [Fintype V] (G : SimpleGraph V) : ℕ :=
  sInf { k | ∃ D : TreeDecomp G, ∀ t, indepNumOn G (D.bag t) ≤ k }

theorem treewidth_set_nonempty [Fintype V] (G : SimpleGraph V) :
    { k | ∃ D : TreeDecomp G, ∀ t, (D.bag t).card ≤ k + 1 }.Nonempty := by
  refine ⟨Fintype.card V, TreeDecomp.trivial G, fun t => ?_⟩
  simp only [TreeDecomp.trivial, Finset.card_univ]
  omega

theorem treeIndep_set_nonempty [Fintype V] (G : SimpleGraph V) :
    { k | ∃ D : TreeDecomp G, ∀ t, indepNumOn G (D.bag t) ≤ k }.Nonempty := by
  refine ⟨Fintype.card V, TreeDecomp.trivial G, fun t => ?_⟩
  calc indepNumOn G ((TreeDecomp.trivial G).bag t)
      ≤ ((TreeDecomp.trivial G).bag t).card := indepNumOn_le_card _ _
    _ = Fintype.card V := by simp [TreeDecomp.trivial, Finset.card_univ]

/-! ## Reduction between treewidth and tree-independence number -/

/-- `α-tw(G) ≤ tw(G) + 1`, always (no degree hypothesis). -/
theorem treeIndepNumber_le_treewidth_succ [Fintype V] (G : SimpleGraph V) :
    treeIndepNumber G ≤ treewidth G + 1 := by
  obtain ⟨D, hD⟩ := Nat.sInf_mem (treewidth_set_nonempty G)
  apply Nat.sInf_le
  refine ⟨D, fun t => ?_⟩
  calc indepNumOn G (D.bag t) ≤ (D.bag t).card := indepNumOn_le_card _ _
    _ ≤ treewidth G + 1 := hD t

/-- For graphs of maximum degree at most `Δ`, `tw(G) ≤ (Δ+1)·α-tw(G)`.  Combined with
`treeIndepNumber_le_treewidth_succ`, treewidth and tree-independence number are linearly
equivalent in the bounded-degree setting. -/
theorem treewidth_le_mul_treeIndepNumber [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] {Δ : ℕ} (hΔ : G.maxDegree ≤ Δ) :
    treewidth G ≤ (Δ + 1) * treeIndepNumber G := by
  obtain ⟨D, hD⟩ := Nat.sInf_mem (treeIndep_set_nonempty G)
  apply Nat.sInf_le
  refine ⟨D, fun t => ?_⟩
  have h1 : (D.bag t).card ≤ (Δ + 1) * indepNumOn G (D.bag t) := card_le_indepNumOn G hΔ _
  have h2 : indepNumOn G (D.bag t) ≤ treeIndepNumber G := hD t
  calc (D.bag t).card ≤ (Δ + 1) * indepNumOn G (D.bag t) := h1
    _ ≤ (Δ + 1) * treeIndepNumber G := by exact Nat.mul_le_mul_left _ h2
    _ ≤ (Δ + 1) * treeIndepNumber G + 1 := by omega

/-! ## The main conjecture (conditional on the grid-minor treewidth bound) -/

/-- **Tasks 3–5.**  *The conjecture, proved conditionally.*

Fix `d ≥ 2` and a graph `H`.  Suppose `B` is a treewidth bound for the class of connected,
maximum-degree-`≤ (d-1)`, `H`-induced-minor-free graphs (hypothesis `hB`).  Then every connected
`K_{1,d}`-free `H`-induced-minor-free graph `G` satisfies `α-tw(G) ≤ B + 1`.

This gives the explicit constant `C(d,H) = B(d,H) + 1`.

*Why the hypothesis `hB` holds for planar `H`.*  By the Robertson–Seymour grid-minor theorem, a
graph class has bounded treewidth iff it excludes some planar graph as a minor; and for graphs of
bounded degree, excluding a fixed planar `H` as an *induced* minor forces (after passing to an
induced grid) the exclusion of a large grid as a minor, hence bounded treewidth.  Thus for planar
`H` the bound `B(d,H)` exists and can be taken to be the grid-minor treewidth bound for excluding
a grid large enough to contain `H` as an induced minor.  Formalizing the grid-minor theorem itself
is out of scope, so it is recorded here as the hypothesis `hB`; the remaining reduction is proved
in full. -/
theorem treeIndepNumber_bounded_of_treewidth_bound
    {WH : Type} (H : SimpleGraph WH) (d : ℕ) (hd : 2 ≤ d) (B : ℕ)
    (hB : ∀ {U : Type} [Fintype U] [DecidableEq U] (G : SimpleGraph U) [DecidableRel G.Adj],
            G.Connected → G.maxDegree ≤ d - 1 → ¬ HasInducedMinor H G → treewidth G ≤ B) :
    ∀ {U : Type} [Fintype U] [DecidableEq U] (G : SimpleGraph U) [DecidableRel G.Adj],
      G.Connected → IsKStarFree d G → ¬ HasInducedMinor H G → treeIndepNumber G ≤ B + 1 := by
  intro U _ _ G _ hconn hstar hH
  have hdeg : G.maxDegree ≤ d - 1 := hstar.maxDegree_le G (by omega)
  have htw : treewidth G ≤ B := hB G hconn hdeg hH
  exact (treeIndepNumber_le_treewidth_succ G).trans (by omega)

end TreeIndepKStar