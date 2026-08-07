/-
# Perfect matching conjectures in (possibly infinite) cubic bridgeless graphs

This file develops a formal framework, valid for **arbitrary** (finite or infinite) vertex
types, for the three classical perfect-matching conjectures on cubic bridgeless graphs:

* the **Berge–Fulkerson conjecture** (`BergeFulkerson`): six perfect matchings covering
  every edge exactly twice;
* the **Fan–Raspaud conjecture** (`FanRaspaud`): three perfect matchings with empty
  intersection;
* the **Máčajová–Škoviera conjecture** (`MacajovaSkoviera`): two perfect matchings whose
  intersection contains no odd edge cut.

The main results proved here are

* `PerfectMatching.exists_mem_cutEdges` and `PerfectMatching.card_inter_cutEdges_odd`:
  the *parity lemma* in the infinite setting — a perfect matching meets every edge cut with
  a **finite odd side** in an odd (in particular nonzero) number of edges;
* `BergeFulkerson.fanRaspaud` : BF ⟹ FR;
* `FanRaspaud.macajovaSkoviera` : FR ⟹ MŠ (this is where the parity lemma is used);
* `BergeFulkerson.macajovaSkoviera` : BF ⟹ MŠ;
* `not_bergeFulkerson_of_oddCut_singleton` and friends: all three conjectures **fail** for a
  graph possessing a one-edge cut with a finite odd side (the infinite analogue of "a cubic
  graph with a bridge has no such family"); hence bridgelessness is a necessary hypothesis;
* `ProperThreeEdgeColoring.bergeFulkerson` : a 3-edge-colourable graph satisfies BF (by
  doubling the colour classes) — this works verbatim for infinite graphs;
* transport of all three properties along graph isomorphisms.

Everything is stated for an arbitrary vertex type `V`; no finiteness of `V` is assumed
anywhere.
-/
import Mathlib

namespace Bridges.InfiniteCubicMatchings

universe u v

variable {V : Type u} {G : SimpleGraph V}

/-! ## Perfect matchings as fixed-point-free involutions -/

/-- A perfect matching of `G`, encoded as a fixed-point-free involution `partner` of the
vertex set all of whose orbits are edges of `G`.  This is the standard encoding and works
for infinite graphs, where a matching cannot be described by a finite edge list. -/
structure PerfectMatching (G : SimpleGraph V) where
  /-- the vertex matched to a given vertex -/
  partner : V → V
  /-- a vertex is adjacent to its partner -/
  isAdj : ∀ v, G.Adj v (partner v)
  /-- the partner map is an involution -/
  invol : ∀ v, partner (partner v) = v

namespace PerfectMatching

/-- The set of edges of a perfect matching. -/
def edges (M : PerfectMatching G) : Set (Sym2 V) := {e | ∃ v, e = s(v, M.partner v)}

@[simp] lemma mem_edges (M : PerfectMatching G) (u w : V) :
    s(u, w) ∈ M.edges ↔ M.partner u = w := by
  constructor
  · rintro ⟨x, hx⟩
    rw [Sym2.eq_iff] at hx
    rcases hx with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rfl
    · exact M.invol _
  · rintro rfl
    exact ⟨u, rfl⟩

lemma edges_subset_edgeSet (M : PerfectMatching G) : M.edges ⊆ G.edgeSet := by
  rintro e ⟨v, rfl⟩
  simpa using M.isAdj v

lemma partner_ne (M : PerfectMatching G) (v : V) : M.partner v ≠ v :=
  fun h => G.irrefl (h ▸ M.isAdj v)

/-- Two perfect matchings that never share a partner have disjoint edge sets. -/
lemma disjoint_edges (M N : PerfectMatching G) (h : ∀ v, M.partner v ≠ N.partner v) :
    Disjoint M.edges N.edges := by
  rw [Set.disjoint_left]
  intro e
  induction e with
  | _ u w =>
    intro h1 h2
    rw [mem_edges] at h1 h2
    exact h u (h1.trans h2.symm)

/-- The subgraph associated with a perfect matching. -/
def toSubgraph (M : PerfectMatching G) : G.Subgraph where
  verts := Set.univ
  Adj u w := G.Adj u w ∧ M.partner u = w
  adj_sub := fun h => h.1
  edge_vert := fun _ => Set.mem_univ _
  symm := by
    rintro u w ⟨h, rfl⟩
    exact ⟨h.symm, M.invol u⟩

/-- The bridge to Mathlib's notion: the subgraph of a perfect matching is a perfect
matching in the sense of `SimpleGraph.Subgraph.IsPerfectMatching`. -/
theorem toSubgraph_isPerfectMatching (M : PerfectMatching G) :
    M.toSubgraph.IsPerfectMatching := by
  constructor
  · intro v _
    refine ⟨M.partner v, ⟨M.isAdj v, rfl⟩, ?_⟩
    rintro w ⟨-, rfl⟩
    rfl
  · intro v; exact Set.mem_univ v

end PerfectMatching

/-! ## Edge cuts with a finite side -/

/-- The edge cut determined by a finite set `S` of vertices: the edges of `G` with exactly
one endpoint in `S`. -/
def cutEdges (G : SimpleGraph V) (S : Finset V) : Set (Sym2 V) :=
  {e ∈ G.edgeSet | ∃ u w, e = s(u, w) ∧ u ∈ S ∧ w ∉ S}

lemma cutEdges_subset_edgeSet (S : Finset V) : cutEdges G S ⊆ G.edgeSet := fun _ h => h.1

/-- The edge cut of an arbitrary, possibly infinite, set of vertices. -/
def cutEdgesSet (G : SimpleGraph V) (S : Set V) : Set (Sym2 V) :=
  {e ∈ G.edgeSet | ∃ u w, e = s(u, w) ∧ u ∈ S ∧ w ∉ S}

lemma cutEdges_eq_cutEdgesSet (S : Finset V) : cutEdges G S = cutEdgesSet G ↑S := rfl

/-- An *odd cut* (with a finite side): the cut of a finite vertex set of odd cardinality.
In an infinite graph, cuts both of whose sides are infinite carry no parity information,
so this finiteness restriction is essential. -/
def IsOddCut (G : SimpleGraph V) (C : Set (Sym2 V)) : Prop :=
  ∃ S : Finset V, Odd S.card ∧ C = cutEdges G S

/-! ## A combinatorial lemma: fixed-point-free involutions have even orbit sets -/

/-- A finite set stable under a fixed-point-free involution has even cardinality. -/
theorem even_card_of_involutive {α : Type*} [DecidableEq α] (s : Finset α) (f : α → α)
    (hmaps : ∀ a ∈ s, f a ∈ s) (hinv : ∀ a ∈ s, f (f a) = a) (hne : ∀ a ∈ s, f a ≠ a) :
    Even s.card := by
  induction hn : s.card using Nat.strong_induction_on generalizing s with
  | _ n ih =>
  subst hn
  rcases Finset.eq_empty_or_nonempty s with rfl | ⟨a, ha⟩
  · simp
  · have hfa : f a ∈ s := hmaps a ha
    have hane : f a ≠ a := hne a ha
    set t : Finset α := s \ {a, f a} with ht
    have hsub : ({a, f a} : Finset α) ⊆ s := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> assumption
    have hpair : ({a, f a} : Finset α).card = 2 := Finset.card_pair (Ne.symm hane)
    have hcardt : t.card = s.card - 2 := by
      rw [ht, Finset.card_sdiff, Finset.inter_eq_left.mpr hsub, hpair]
    have h2 : 2 ≤ s.card := by
      have := Finset.card_le_card hsub
      rw [hpair] at this
      exact this
    have hmaps' : ∀ b ∈ t, f b ∈ t := by
      intro b hb
      rw [ht, Finset.mem_sdiff] at hb ⊢
      obtain ⟨hbs, hbn⟩ := hb
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hbn ⊢
      refine ⟨hmaps b hbs, ?_, ?_⟩
      · intro h
        exact hbn.2 (by rw [← h, hinv b hbs])
      · intro h
        exact hbn.1 (by
          have := congrArg f h
          rwa [hinv b hbs, hinv a ha] at this)
    have hinv' : ∀ b ∈ t, f (f b) = b := fun b hb => hinv b (Finset.mem_sdiff.mp hb).1
    have hne' : ∀ b ∈ t, f b ≠ b := fun b hb => hne b (Finset.mem_sdiff.mp hb).1
    obtain ⟨m, hm⟩ := ih t.card (by omega) t hmaps' hinv' hne' rfl
    exact ⟨m + 1, by omega⟩

/-! ## The parity lemma -/

namespace PerfectMatching

variable (M : PerfectMatching G)

open scoped Classical in
/-- The edges of `M` crossing the cut of `S` are exactly the edges `s(v, partner v)` for
`v ∈ S` with `partner v ∉ S`. -/
theorem inter_cutEdges_eq (S : Finset V) :
    M.edges ∩ cutEdges G S =
      ↑((S.filter (fun v => M.partner v ∉ S)).image (fun v => s(v, M.partner v))) := by
  ext e
  simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_filter,
    Set.mem_inter_iff]
  constructor
  · rintro ⟨hM, -, u, w, rfl, huS, hwS⟩
    rw [mem_edges] at hM
    subst hM
    exact ⟨u, ⟨huS, hwS⟩, rfl⟩
  · rintro ⟨v, ⟨hvS, hpv⟩, rfl⟩
    refine ⟨⟨v, rfl⟩, ?_, v, M.partner v, rfl, hvS, hpv⟩
    simpa using M.isAdj v

/-- **Parity lemma** (infinite version).  If `S` is a finite set of vertices with an odd
number of elements, then every perfect matching contains an odd number of edges of the cut
`cutEdges G S`.  (The intersection is automatically finite.) -/
theorem card_inter_cutEdges_odd (S : Finset V) (hS : Odd S.card) :
    Odd (M.edges ∩ cutEdges G S).ncard := by
  classical
  have hinj : Set.InjOn (fun v => s(v, M.partner v))
      ↑(S.filter (fun v => M.partner v ∉ S)) := by
    intro a ha b hb hab
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at ha hb
    rw [Sym2.eq_iff] at hab
    rcases hab with ⟨rfl, -⟩ | ⟨rfl, -⟩
    · rfl
    · exact absurd hb.1 (by simpa [M.invol] using ha.2)
  rw [inter_cutEdges_eq, Set.ncard_coe_finset, Finset.card_image_of_injOn (by
    simpa using hinj)]
  -- the complementary part of `S` is even, being stable under the partner involution
  have hEven : Even (S.filter (fun v => M.partner v ∈ S)).card := by
    refine even_card_of_involutive _ M.partner ?_ (fun a _ => M.invol a)
      (fun a _ => M.partner_ne a)
    intro a ha
    simp only [Finset.mem_filter] at ha ⊢
    exact ⟨ha.2, by rw [M.invol]; exact ha.1⟩
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := S) (p := fun v => M.partner v ∈ S)
  rcases hS with ⟨k, hk⟩
  rcases hEven with ⟨m, hm⟩
  refine ⟨k - m, ?_⟩
  omega

/-- A perfect matching meets every odd cut. -/
theorem exists_mem_cutEdges (S : Finset V) (hS : Odd S.card) :
    (M.edges ∩ cutEdges G S).Nonempty := by
  have h := M.card_inter_cutEdges_odd S hS
  rw [Set.nonempty_iff_ne_empty]
  rintro he
  rw [he] at h
  simp at h

/-- A perfect matching meets every odd cut. -/
theorem exists_mem_of_isOddCut {C : Set (Sym2 V)} (hC : IsOddCut G C) :
    (M.edges ∩ C).Nonempty := by
  obtain ⟨S, hS, rfl⟩ := hC
  exact M.exists_mem_cutEdges S hS

end PerfectMatching

/-! ## The three conjectures -/

/-- The Berge–Fulkerson property: there are six perfect matchings such that every edge
belongs to exactly two of them. -/
def BergeFulkerson (G : SimpleGraph V) : Prop :=
  ∃ M : Fin 6 → PerfectMatching G,
    ∀ e ∈ G.edgeSet, {i : Fin 6 | e ∈ (M i).edges}.ncard = 2

/-- The Fan–Raspaud property: there are three perfect matchings with empty intersection. -/
def FanRaspaud (G : SimpleGraph V) : Prop :=
  ∃ M : Fin 3 → PerfectMatching G, (M 0).edges ∩ (M 1).edges ∩ (M 2).edges = ∅

/-- The Máčajová–Škoviera property: there are two perfect matchings whose intersection
contains no odd edge cut. -/
def MacajovaSkoviera (G : SimpleGraph V) : Prop :=
  ∃ M₁ M₂ : PerfectMatching G, ∀ C, IsOddCut G C → ¬ C ⊆ M₁.edges ∩ M₂.edges

/-- A proper 3-edge-colouring of a (cubic) graph: a partition of the edge set into three
perfect matchings. -/
def ProperThreeEdgeColoring (G : SimpleGraph V) : Prop :=
  ∃ M : Fin 3 → PerfectMatching G,
    (∀ i j, i ≠ j → Disjoint (M i).edges (M j).edges) ∧
    (∀ e ∈ G.edgeSet, ∃ i, e ∈ (M i).edges)

/-- `G` is cubic if every vertex has exactly three neighbours. -/
def IsCubic (G : SimpleGraph V) : Prop := ∀ v : V, (G.neighborSet v).ncard = 3

/-- `G` is bridgeless if no edge is a bridge (in the sense of `SimpleGraph.IsBridge`). -/
def Bridgeless (G : SimpleGraph V) : Prop := ∀ e ∈ G.edgeSet, ¬ G.IsBridge e

/-! ## The implications BF ⟹ FR ⟹ MŠ -/

theorem BergeFulkerson.fanRaspaud (h : BergeFulkerson G) : FanRaspaud G := by
  obtain ⟨M, hM⟩ := h
  refine ⟨![M 0, M 1, M 2], ?_⟩
  rw [Set.eq_empty_iff_forall_notMem]
  rintro e ⟨⟨h0, h1⟩, h2⟩
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons] at h0 h1 h2
  have hE : e ∈ G.edgeSet := (M 0).edges_subset_edgeSet h0
  have hsub : ({0, 1, 2} : Set (Fin 6)) ⊆ {i : Fin 6 | e ∈ (M i).edges} := by
    rintro i hi
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hi
    rcases hi with rfl | rfl | rfl
    · exact h0
    · exact h1
    · exact h2
  have hcard : ({0, 1, 2} : Set (Fin 6)).ncard = 3 := by
    rw [Set.ncard_insert_of_notMem (by decide) (Set.toFinite _),
      Set.ncard_insert_of_notMem (by decide) (Set.toFinite _), Set.ncard_singleton]
  have := Set.ncard_le_ncard hsub (Set.toFinite _)
  rw [hcard, hM e hE] at this
  omega

theorem FanRaspaud.macajovaSkoviera (h : FanRaspaud G) : MacajovaSkoviera G := by
  obtain ⟨M, hM⟩ := h
  refine ⟨M 0, M 1, ?_⟩
  intro C hC hsub
  obtain ⟨e, he2, heC⟩ := (M 2).exists_mem_of_isOddCut hC
  obtain ⟨he0, he1⟩ := hsub heC
  have : e ∈ (M 0).edges ∩ (M 1).edges ∩ (M 2).edges := ⟨⟨he0, he1⟩, he2⟩
  rw [hM] at this
  exact this

theorem BergeFulkerson.macajovaSkoviera (h : BergeFulkerson G) : MacajovaSkoviera G :=
  h.fanRaspaud.macajovaSkoviera

/-! ## Bridgelessness is necessary: one-edge odd cuts destroy all three properties -/

/-- Every perfect matching contains an edge forming a one-edge odd cut (the infinite
analogue of "every perfect matching contains every bridge"). -/
theorem mem_edges_of_isOddCut_singleton (M : PerfectMatching G) {e : Sym2 V}
    (h : IsOddCut G {e}) : e ∈ M.edges := by
  obtain ⟨f, hf, hfe⟩ := M.exists_mem_of_isOddCut h
  rwa [Set.mem_singleton_iff.mp hfe] at hf

theorem edge_mem_edgeSet_of_isOddCut_singleton {e : Sym2 V} (h : IsOddCut G {e}) :
    e ∈ G.edgeSet := by
  obtain ⟨S, -, hS⟩ := h
  exact cutEdges_subset_edgeSet S (hS ▸ rfl)

theorem not_bergeFulkerson_of_oddCut_singleton {e : Sym2 V} (h : IsOddCut G {e}) :
    ¬ BergeFulkerson G := by
  rintro ⟨M, hM⟩
  have hE : e ∈ G.edgeSet := edge_mem_edgeSet_of_isOddCut_singleton h
  have huniv : {i : Fin 6 | e ∈ (M i).edges} = Set.univ := by
    ext i
    simp [mem_edges_of_isOddCut_singleton (M i) h]
  have := hM e hE
  rw [huniv, Set.ncard_univ] at this
  simp at this

theorem not_fanRaspaud_of_oddCut_singleton {e : Sym2 V} (h : IsOddCut G {e}) :
    ¬ FanRaspaud G := by
  rintro ⟨M, hM⟩
  have : e ∈ (M 0).edges ∩ (M 1).edges ∩ (M 2).edges :=
    ⟨⟨mem_edges_of_isOddCut_singleton _ h, mem_edges_of_isOddCut_singleton _ h⟩,
      mem_edges_of_isOddCut_singleton _ h⟩
  rw [hM] at this
  exact this

theorem not_macajovaSkoviera_of_oddCut_singleton {e : Sym2 V} (h : IsOddCut G {e}) :
    ¬ MacajovaSkoviera G := by
  rintro ⟨M₁, M₂, hM⟩
  refine hM {e} h ?_
  rintro f hf
  rw [Set.mem_singleton_iff.mp hf]
  exact ⟨mem_edges_of_isOddCut_singleton _ h, mem_edges_of_isOddCut_singleton _ h⟩

/-! ## 3-edge-colourable graphs satisfy Berge–Fulkerson -/

theorem ProperThreeEdgeColoring.bergeFulkerson (h : ProperThreeEdgeColoring G) :
    BergeFulkerson G := by
  obtain ⟨M, hdisj, hcover⟩ := h
  refine ⟨fun i => M ⟨i.1 / 2, by omega⟩, ?_⟩
  intro e hE
  obtain ⟨i₀, hi₀⟩ := hcover e hE
  have key : {i : Fin 6 | e ∈ (M ⟨i.1 / 2, by omega⟩).edges} = {i : Fin 6 | i.1 / 2 = i₀.1} := by
    ext i
    simp only [Set.mem_setOf_eq]
    constructor
    · intro hi
      by_contra hne
      have : (⟨i.1 / 2, by omega⟩ : Fin 3) ≠ i₀ := by
        intro hEq
        exact hne (congrArg Fin.val hEq)
      exact (hdisj _ _ this).le_bot ⟨hi, hi₀⟩
    · intro hi
      have : (⟨i.1 / 2, by omega⟩ : Fin 3) = i₀ := Fin.ext hi
      rw [this]
      exact hi₀
  rw [key]
  have hc : ∀ j : Fin 3, {i : Fin 6 | i.1 / 2 = j.1}.ncard = 2 := by
    intro j
    simp only [Set.ncard_eq_toFinset_card', Set.toFinset_setOf]
    revert j
    decide
  exact hc i₀

/-! ## Invariance under isomorphism -/

namespace PerfectMatching

variable {W : Type v} {H : SimpleGraph W}

/-- Transport a perfect matching along a graph isomorphism. -/
def map (f : G ≃g H) (M : PerfectMatching G) : PerfectMatching H where
  partner w := f (M.partner (f.symm w))
  isAdj w := by
    have h := f.map_adj_iff.mpr (M.isAdj (f.symm w))
    simpa using h
  invol w := by simp [M.invol]

@[simp] lemma mem_map_edges (f : G ≃g H) (M : PerfectMatching G) (u w : V) :
    s(f u, f w) ∈ (M.map f).edges ↔ s(u, w) ∈ M.edges := by
  simp only [mem_edges, map]
  constructor
  · intro h
    have := congrArg f.symm h
    simpa using this
  · intro h
    rw [show f.symm (f u) = u by simp, h]

lemma mem_map_edges' (f : G ≃g H) (M : PerfectMatching G) (e : Sym2 W) :
    e ∈ (M.map f).edges ↔ Sym2.map f.symm e ∈ M.edges := by
  induction e with
  | _ a b =>
    rw [Sym2.map_pair_eq, show s(a, b) = s(f (f.symm a), f (f.symm b)) by simp]
    exact mem_map_edges f M _ _

end PerfectMatching

lemma mem_edgeSet_map_symm {W : Type v} {H : SimpleGraph W} (f : G ≃g H) (e : Sym2 W) :
    Sym2.map f.symm e ∈ G.edgeSet ↔ e ∈ H.edgeSet := by
  induction e with
  | _ a b =>
    simp only [Sym2.map_pair_eq, SimpleGraph.mem_edgeSet]
    exact f.symm.map_adj_iff

/-- The image of a cut edge under an isomorphism matching the two sides is a cut edge. -/
lemma mem_cutEdges_map {W : Type v} {H : SimpleGraph W} (f : G ≃g H) (S : Finset V)
    (T : Finset W) (hST : ∀ v : V, v ∈ S ↔ f v ∈ T) {e : Sym2 V} (he : e ∈ cutEdges G S) :
    Sym2.map f e ∈ cutEdges H T := by
  obtain ⟨heE, u, w, rfl, huS, hwS⟩ := he
  refine ⟨?_, f u, f w, by simp, (hST u).mp huS, fun hc => hwS ((hST w).mpr hc)⟩
  simpa using f.map_adj_iff.mpr (by simpa using heE)

/-- The Berge–Fulkerson property is invariant under graph isomorphism. -/
theorem BergeFulkerson.map {W : Type v} {H : SimpleGraph W} (f : G ≃g H)
    (h : BergeFulkerson G) : BergeFulkerson H := by
  obtain ⟨M, hM⟩ := h
  refine ⟨fun i => (M i).map f, fun e hE => ?_⟩
  have key : {i : Fin 6 | e ∈ ((M i).map f).edges}
      = {i : Fin 6 | Sym2.map f.symm e ∈ (M i).edges} := by
    ext i
    exact PerfectMatching.mem_map_edges' f (M i) e
  rw [key]
  exact hM _ ((mem_edgeSet_map_symm f e).mpr hE)

/-- The Fan–Raspaud property is invariant under graph isomorphism. -/
theorem FanRaspaud.map {W : Type v} {H : SimpleGraph W} (f : G ≃g H)
    (h : FanRaspaud G) : FanRaspaud H := by
  obtain ⟨M, hM⟩ := h
  refine ⟨fun i => (M i).map f, ?_⟩
  rw [Set.eq_empty_iff_forall_notMem]
  rintro e ⟨⟨h0, h1⟩, h2⟩
  rw [PerfectMatching.mem_map_edges'] at h0 h1 h2
  have : Sym2.map f.symm e ∈ (M 0).edges ∩ (M 1).edges ∩ (M 2).edges := ⟨⟨h0, h1⟩, h2⟩
  rw [hM] at this
  exact this

/-- The Máčajová–Škoviera property is invariant under graph isomorphism. -/
theorem MacajovaSkoviera.map {W : Type v} {H : SimpleGraph W} (f : G ≃g H)
    (h : MacajovaSkoviera G) : MacajovaSkoviera H := by
  classical
  obtain ⟨M₁, M₂, hM⟩ := h
  refine ⟨M₁.map f, M₂.map f, ?_⟩
  rintro C ⟨T, hT, rfl⟩ hsub
  refine hM (cutEdges G (T.image f.symm)) ⟨T.image f.symm, ?_, rfl⟩ ?_
  · rwa [Finset.card_image_of_injective _ f.symm.injective]
  · intro e he
    have hST : ∀ v : V, v ∈ T.image f.symm ↔ f v ∈ T := by
      intro v
      simp only [Finset.mem_image]
      constructor
      · rintro ⟨w, hw, rfl⟩; simpa using hw
      · intro hv; exact ⟨f v, hv, by simp⟩
    have hmap := mem_cutEdges_map f _ T hST he
    obtain ⟨h1, h2⟩ := hsub hmap
    rw [PerfectMatching.mem_map_edges'] at h1 h2
    simp only [Sym2.map_map, Function.comp, RelIso.symm_apply_apply, Sym2.map_id'] at h1 h2
    exact ⟨h1, h2⟩

end Bridges.InfiniteCubicMatchings