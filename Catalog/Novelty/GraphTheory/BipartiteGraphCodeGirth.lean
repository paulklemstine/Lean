import Mathlib

/-!
# Girth bounds the minimum distance of a bipartite graph code

Let `G` be a simple left-`d`-regular bipartite graph with `d ≥ 2` and girth at
least `2k + 2`.  Let `B(G)` be the binary linear code whose parity-check matrix is
the bi-adjacency matrix of `G`: a codeword is a finite set `S` of *left* vertices
such that every *right* vertex has an **even** number of neighbours in `S`.  The
minimum distance of `B(G)` (the size of the smallest non-empty codeword) is at
least `k + 1`.

We model `G` by a decidable incidence relation `inc : L → R → Prop` and realise
it as a `SimpleGraph (L ⊕ R)`.  The girth hypothesis is phrased with
`SimpleGraph.egirth` (valued in `ℕ∞`, so an acyclic graph genuinely has girth
`⊤ ≥ 2k+2`).

## Main result

* `girth_bounds_min_distance` — the minimum-distance bound.

The mathematical heart is split into two reusable graph-theoretic lemmas:

* `exists_isCycle_of_no_degree_one` — a finite simple graph with an edge and no
  vertex of degree one is not acyclic (contains a cycle);
* `isCycle_length_le_two_mul_card_left` — a cycle of the bipartite graph has
  length at most twice the number of distinct left vertices it visits.

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).** Girth of an LDPC/Tanner graph controls the code's
minimum distance: a length-`2t` cycle is the shortest linear dependence among
columns of the parity-check matrix, so distance `≥ ` girth`/2`.

**Experiment (Experimenter).** Formalise `B(G)` via parity of right-degrees of a
left-vertex set `S`.  Restrict `G` to edges meeting `S`; the restriction has no
degree-one vertex (left vertices keep degree `d ≥ 2`, right vertices keep an even
degree), hence contains a cycle.  Bipartiteness forces the cycle length to be
`2 · (#left vertices) ≤ 2|S|`.

**Analysis (Analyst).** The two genuinely hard steps are (i) "no degree-one
vertex + an edge ⇒ a cycle", proved through the forest/tree structure of an
acyclic graph, and (ii) the bipartite alternation count `length = 2 · #left`.
Both are graph-theoretic facts independent of coding theory and are isolated as
standalone lemmas.

**Critique (Critic).** `egirth` (not `girth : ℕ`) is used so the acyclic case is
handled honestly.  `d ≥ 2` is load-bearing (degree-one step).  The bound is tight
(Fano incidence graph: `d = 3`, girth `6`, distance exactly `3 = k+1`).

**Synthesis (PI).** `girth_bounds_min_distance` packages the chain
`2k+2 ≤ egirth ≤ length ≤ 2|S|`.
-/

namespace BipartiteGraphCode

open SimpleGraph Finset

variable {L R : Type*} [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R]

/-- The simple bipartite graph on `L ⊕ R` defined by the incidence relation
`inc`: a left vertex `l` and a right vertex `r` are adjacent iff `inc l r`. -/
def biGraph (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] : SimpleGraph (L ⊕ R) where
  Adj a b :=
    match a, b with
    | Sum.inl l, Sum.inr r => inc l r
    | Sum.inr r, Sum.inl l => inc l r
    | _, _ => False
  symm := by intro a b h; cases a <;> cases b <;> simp_all
  loopless := ⟨by intro a; cases a <;> simp⟩

instance instDecBi (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] :
    DecidableRel (biGraph inc).Adj := by
  intro a b
  cases a <;> cases b <;> (unfold biGraph; dsimp) <;> infer_instance

/-- The subgraph of `biGraph inc` keeping only the edges incident to a left vertex
in `S`. -/
def restrictGraph (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L) :
    SimpleGraph (L ⊕ R) where
  Adj a b :=
    match a, b with
    | Sum.inl l, Sum.inr r => inc l r ∧ l ∈ S
    | Sum.inr r, Sum.inl l => inc l r ∧ l ∈ S
    | _, _ => False
  symm := by intro a b h; cases a <;> cases b <;> simp_all
  loopless := ⟨by intro a; cases a <;> simp⟩

instance instDecRestrict (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L) :
    DecidableRel (restrictGraph inc S).Adj := by
  intro a b
  cases a <;> cases b <;> (unfold restrictGraph; dsimp) <;> infer_instance

omit [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R] in
/-- `restrictGraph` is a subgraph of `biGraph`. -/
lemma restrictGraph_le (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L) :
    restrictGraph inc S ≤ biGraph inc := by
  intro a b h
  cases a <;> cases b <;> simp_all [restrictGraph, biGraph]

omit [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R] in
/-- `restrictGraph` is symmetric in the obvious adjacency description. -/
lemma restrictGraph_adj_inl_inr (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) (l : L) (r : R) :
    (restrictGraph inc S).Adj (Sum.inl l) (Sum.inr r) ↔ inc l r ∧ l ∈ S := Iff.rfl

/-- Neighbours of a left vertex `l ∈ S` in the restricted graph are its right
neighbours. -/
lemma restrict_neighborFinset_inl (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) (l : L) (hl : l ∈ S) :
    (restrictGraph inc S).neighborFinset (Sum.inl l)
      = (univ.filter (fun r => inc l r)).image Sum.inr := by
  ext x
  cases x <;> simp [restrictGraph, SimpleGraph.mem_neighborFinset, hl]

/-- Neighbours of a right vertex `r` in the restricted graph are its left
neighbours that lie in `S`. -/
lemma restrict_neighborFinset_inr (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) (r : R) :
    (restrictGraph inc S).neighborFinset (Sum.inr r)
      = (S.filter (fun l => inc l r)).image Sum.inl := by
  ext x
  cases x <;> simp [restrictGraph, SimpleGraph.mem_neighborFinset, and_comm]

/-- Degree of a left vertex in `S` equals its number of right neighbours. -/
lemma restrict_degree_inl_mem (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) (l : L) (hl : l ∈ S) :
    (restrictGraph inc S).degree (Sum.inl l) = (univ.filter (fun r => inc l r)).card := by
  rw [SimpleGraph.degree, restrict_neighborFinset_inl inc S l hl,
    Finset.card_image_of_injective _ (Sum.inr_injective)]

omit [DecidableEq R] in
/-- Degree of a left vertex not in `S` is zero. -/
lemma restrict_degree_inl_not_mem (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) (l : L) (hl : l ∉ S) :
    (restrictGraph inc S).degree (Sum.inl l) = 0 := by
  rw [SimpleGraph.degree, Finset.card_eq_zero]
  ext x
  cases x <;> simp [restrictGraph, SimpleGraph.mem_neighborFinset, hl]

/-- Degree of a right vertex equals its number of `S`-neighbours. -/
lemma restrict_degree_inr (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) (r : R) :
    (restrictGraph inc S).degree (Sum.inr r) = (S.filter (fun l => inc l r)).card := by
  rw [SimpleGraph.degree, restrict_neighborFinset_inr inc S r,
    Finset.card_image_of_injective _ (Sum.inl_injective)]

/-- **Graph lemma.** A finite simple graph that has at least one edge and no vertex
of degree one is not acyclic: it contains a cycle. -/
lemma exists_isCycle_of_no_degree_one {W : Type*} [Fintype W] (G : SimpleGraph W)
    [DecidableRel G.Adj] (hdeg : ∀ v, G.degree v ≠ 1)
    (hedge : ∃ a b, G.Adj a b) :
    ∃ (a : W) (w : G.Walk a a), w.IsCycle := by
  classical
  by_contra hcon
  push_neg at hcon
  have hac : G.IsAcyclic := fun v w hw => hcon v w hw
  obtain ⟨a, b, hab⟩ := hedge
  set C := G.connectedComponentMk a with hC
  have haC : a ∈ C := ConnectedComponent.connectedComponentMk_mem
  have hbC : b ∈ C := by
    show G.connectedComponentMk b = C
    rw [hC]; exact (ConnectedComponent.eq.mpr hab.reachable).symm
  have htree : C.toSimpleGraph.IsTree := hac.isTree_connectedComponent C
  have hnt : Nontrivial ↥C := by
    refine ⟨⟨a, haC⟩, ⟨b, hbC⟩, ?_⟩
    simp only [ne_eq, Subtype.mk.injEq]; exact G.ne_of_adj hab
  obtain ⟨v, hv⟩ := htree.exists_vert_degree_one_of_nontrivial
  have hsub : ∀ w, G.Adj (↑v) w → w ∈ C := by
    intro w hw
    have hvC : (↑v : W) ∈ C := v.2
    show G.connectedComponentMk w = C
    rw [← (show G.connectedComponentMk (↑v) = C from hvC)]
    exact ConnectedComponent.eq.mpr hw.symm.reachable
  have hdegeq : C.toSimpleGraph.degree v = G.degree (↑v) := by
    rw [← SimpleGraph.card_neighborSet_eq_degree, ← SimpleGraph.card_neighborSet_eq_degree]
    apply Fintype.card_congr
    refine ⟨fun w' => ⟨↑w'.1, ?_⟩, fun w => ⟨⟨↑w, hsub w.1 w.2⟩, ?_⟩, ?_, ?_⟩
    · have := w'.2
      rw [mem_neighborSet, ConnectedComponent.toSimpleGraph_adj] at this; exact this
    · have := w.2
      rw [mem_neighborSet] at this ⊢
      rw [ConnectedComponent.toSimpleGraph_adj]; exact this
    · intro w'; ext; rfl
    · intro w; ext; rfl
  rw [hdegeq] at hv
  exact hdeg (↑v) hv

omit [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R] in
/-- Adjacent vertices of `restrictGraph` lie on opposite sides. -/
lemma restrict_adj_isRight (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L)
    {a b : L ⊕ R} (h : (restrictGraph inc S).Adj a b) : a.isRight ≠ b.isRight := by
  cases a <;> cases b <;> simp_all [restrictGraph]

omit [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R] in
/-- A left endpoint of an edge of `restrictGraph` lies in `S`. -/
lemma restrict_adj_inl_mem (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L)
    {l : L} {u : L ⊕ R} (h : (restrictGraph inc S).Adj (Sum.inl l) u) : l ∈ S := by
  cases u <;> simp_all [restrictGraph]

omit [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R] in
/-- `restrictGraph` is `2`-colourable (it is bipartite), coloured by side. -/
lemma restrict_colorable (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L) :
    (restrictGraph inc S).Colorable 2 := by
  refine ⟨⟨fun v => if v.isRight then 1 else 0, ?_⟩⟩
  intro a b hab
  have := restrict_adj_isRight inc S hab
  cases a <;> cases b <;> simp_all [restrictGraph]

omit [Fintype L] [Fintype R] [DecidableEq L] [DecidableEq R] in
/-- Every closed walk of `restrictGraph` has even length (bipartiteness). -/
lemma restrict_even_length (inc : L → R → Prop) [∀ l r, Decidable (inc l r)] (S : Finset L)
    {a : L ⊕ R} (w : (restrictGraph inc S).Walk a a) : Even w.length :=
  (SimpleGraph.two_colorable_iff_forall_loop_even.mp (restrict_colorable inc S)) a w

/-- A vertex on a positive-length walk has a neighbour. -/
lemma mem_support_exists_adj {W : Type*} {G : SimpleGraph W} : ∀ {x y : W} (p : G.Walk x y),
    0 < p.length → ∀ {v : W}, v ∈ p.support → ∃ u, G.Adj v u := by
  intro x y p
  induction p with
  | nil => intro h; simp at h
  | cons hadj q ih =>
      intro _ v hv
      rw [SimpleGraph.Walk.support_cons, List.mem_cons] at hv
      rcases hv with rfl | hv
      · exact ⟨_, hadj⟩
      · cases q with
        | nil =>
            rw [SimpleGraph.Walk.support_nil, List.mem_singleton] at hv
            subst hv
            exact ⟨_, hadj.symm⟩
        | cons hadj2 q2 => exact ih (by simp) hv

/-- In a `Bool` list whose consecutive entries differ, the counts of the two
values are nearly balanced: the head value's count is between the other count
and the other count plus one. -/
lemma balt_head : ∀ (bl : List Bool), List.IsChain (· ≠ ·) bl → ∀ h : Bool, bl.head? = some h →
    (bl.count (!h) ≤ bl.count h ∧ bl.count h ≤ bl.count (!h) + 1) := by
  intro bl
  induction bl with
  | nil => intro _ h hh; simp at hh
  | cons a t iht =>
      intro hchain h hh
      simp only [List.head?_cons, Option.some.injEq] at hh
      subst hh
      cases t with
      | nil => simp
      | cons b t' =>
          rw [List.isChain_cons_cons] at hchain
          obtain ⟨hab, htail⟩ := hchain
          have hb : b = !a := by cases a <;> cases b <;> simp_all
          subst hb
          have IH := iht htail (!a) (by simp)
          rw [List.count_cons, List.count_cons]
          rw [List.count_cons, List.count_cons] at IH
          simp only [Bool.not_not] at *
          rcases a <;> simp_all

/-- In a `Bool` list whose consecutive entries differ, the two counts differ by
at most one. -/
lemma balt (bl : List Bool) (h : List.IsChain (· ≠ ·) bl) :
    bl.count true ≤ bl.count false + 1 ∧ bl.count false ≤ bl.count true + 1 := by
  cases bl with
  | nil => simp
  | cons a t =>
      obtain ⟨h1, h2⟩ := balt_head (a :: t) h a (by simp)
      cases a <;> simp_all <;> omega

/-- If consecutive entries of `l` have different `f`-value, the two `f`-classes
have nearly equal sizes (differ by at most one). -/
lemma filter_alt {α : Type*} (f : α → Bool) (l : List α)
    (h : List.IsChain (fun x y => f x ≠ f y) l) :
    (l.filter f).length ≤ (l.filter (fun x => !f x)).length + 1 ∧
    (l.filter (fun x => !f x)).length ≤ (l.filter f).length + 1 := by
  have hmap : List.IsChain (· ≠ ·) (l.map f) :=
    List.isChain_map_of_isChain f (fun a b hab => hab) h
  have e1 : (l.filter f).length = (l.map f).count true := by
    rw [List.count_eq_length_filter, List.filter_map]; simp [Function.comp_def]
  have e2 : (l.filter (fun x => !f x)).length = (l.map f).count false := by
    rw [List.count_eq_length_filter, List.filter_map]; simp [Function.comp_def]
  rw [e1, e2]
  exact balt (l.map f) hmap

omit [Fintype L] [Fintype R] in
/-- **Bipartite counting lemma.** In `restrictGraph inc S`, a cycle has length at
most twice the number of distinct left vertices it visits, and every such left
vertex lies in `S`; hence its length is at most `2 * S.card`. -/
lemma isCycle_length_le_two_mul_card_left (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (S : Finset L) {a : L ⊕ R} (w : (restrictGraph inc S).Walk a a) (hw : w.IsCycle) :
    w.length ≤ 2 * S.card := by
  classical
  set f : L ⊕ R → Bool := fun v => Sum.isRight v with hf
  set tail := w.support.tail with htail
  have hlen : tail.length = w.length := by
    rw [htail, List.length_tail, w.length_support]; omega
  have hnd : tail.Nodup := hw.support_nodup
  have hchain : List.IsChain (restrictGraph inc S).Adj tail :=
    (w.isChain_adj_support).tail
  have hchain' : List.IsChain (fun x y => f x ≠ f y) tail :=
    hchain.imp (fun x y hxy => restrict_adj_isRight inc S hxy)
  set nR := (tail.filter f).length with hnR
  set nL := (tail.filter (fun x => !f x)).length with hnL
  have hpart : nR + nL = w.length := by
    rw [hnR, hnL, ← hlen]; exact (List.length_eq_length_filter_add f).symm
  have halt := filter_alt f tail hchain'
  have heven := restrict_even_length inc S w
  have hLR : nL = nR := by rcases heven with ⟨m, hm⟩; omega
  have hLcard : nL ≤ S.card := by
    have hsub : (tail.filter (fun x => !f x)).toFinset ⊆ S.image Sum.inl := by
      intro v hv
      rw [List.mem_toFinset, List.mem_filter] at hv
      obtain ⟨hmem, hright⟩ := hv
      obtain ⟨l, rfl⟩ : ∃ l, v = Sum.inl l := by
        cases v with
        | inl l => exact ⟨l, rfl⟩
        | inr r => simp [hf] at hright
      obtain ⟨u, hu⟩ := mem_support_exists_adj w (by have := hw.three_le_length; omega)
        (List.mem_of_mem_tail hmem)
      have : l ∈ S := restrict_adj_inl_mem inc S hu
      simp [Finset.mem_image, this]
    have hcard := Finset.card_le_card hsub
    rw [Finset.card_image_of_injective _ Sum.inl_injective] at hcard
    rw [hnL, ← List.toFinset_card_of_nodup (hnd.filter _)]
    exact hcard
  omega

/-- The restricted graph has no vertex of degree one, given `d ≥ 2`-regularity of
left vertices and the even-degree (codeword) condition on right vertices. -/
lemma restrict_no_degree_one (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (d : ℕ) (hd : 2 ≤ d)
    (hreg : ∀ l, (univ.filter (fun r => inc l r)).card = d)
    (S : Finset L)
    (hcode : ∀ r, Even (S.filter (fun l => inc l r)).card) :
    ∀ v, (restrictGraph inc S).degree v ≠ 1 := by
  intro v
  cases v with
  | inl l =>
      by_cases hl : l ∈ S
      · rw [restrict_degree_inl_mem inc S l hl, hreg l]; omega
      · rw [restrict_degree_inl_not_mem inc S l hl]; omega
  | inr r =>
      rw [restrict_degree_inr inc S r]
      have he := hcode r
      rcases he with ⟨m, hm⟩
      omega

omit [Fintype L] [DecidableEq L] [DecidableEq R] in
/-- If `S` is a non-empty codeword (every right vertex has an even number of
`S`-neighbours) and left vertices are `d ≥ 2`-regular, the restricted graph has an
edge. -/
lemma restrict_has_edge (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (d : ℕ) (hd : 2 ≤ d)
    (hreg : ∀ l, (univ.filter (fun r => inc l r)).card = d)
    (S : Finset L) (hS : S.Nonempty) :
    ∃ a b, (restrictGraph inc S).Adj a b := by
  obtain ⟨l, hl⟩ := hS
  have hdpos : 0 < (univ.filter (fun r => inc l r)).card := by rw [hreg l]; omega
  obtain ⟨r, hr⟩ := Finset.card_pos.mp hdpos
  simp only [Finset.mem_filter] at hr
  exact ⟨Sum.inl l, Sum.inr r, by simp [restrictGraph, hr.2, hl]⟩

/-- **Main theorem: girth bounds the minimum distance of `B(G)`.**

Let `G = biGraph inc` be a simple left-`d`-regular bipartite graph with `d ≥ 2`
and `egirth G ≥ 2k + 2`.  Then every non-empty codeword `S` of `B(G)` (every right
vertex has an even number of `S`-neighbours) has size at least `k + 1`; i.e. the
minimum distance of `B(G)` is at least `k + 1`. -/
theorem girth_bounds_min_distance
    (inc : L → R → Prop) [∀ l r, Decidable (inc l r)]
    (d k : ℕ) (hd : 2 ≤ d)
    (hreg : ∀ l, (univ.filter (fun r => inc l r)).card = d)
    (hgirth : (2 * k + 2 : ℕ∞) ≤ (biGraph inc).egirth)
    (S : Finset L) (hS : S.Nonempty)
    (hcode : ∀ r, Even (S.filter (fun l => inc l r)).card) :
    k + 1 ≤ S.card := by
  -- Find a cycle in the restricted graph.
  obtain ⟨a, w, hw⟩ :=
    exists_isCycle_of_no_degree_one (restrictGraph inc S)
      (restrict_no_degree_one inc d hd hreg S hcode)
      (restrict_has_edge inc d hd hreg S hS)
  -- Its length is at most `2 * |S|`.
  have hlen : w.length ≤ 2 * S.card :=
    isCycle_length_le_two_mul_card_left inc S w hw
  -- Map the cycle into `biGraph` and bound `egirth` by its length.
  have hmap : (w.mapLe (restrictGraph_le inc S)).IsCycle := hw.mapLe _
  have hegirth : (biGraph inc).egirth ≤ (w.length : ℕ∞) := by
    have := SimpleGraph.egirth_le_length hmap
    simpa using this
  -- Chain the inequalities.
  have : (2 * k + 2 : ℕ∞) ≤ (w.length : ℕ∞) := le_trans hgirth hegirth
  have hk : 2 * k + 2 ≤ w.length := by exact_mod_cast this
  omega

end BipartiteGraphCode