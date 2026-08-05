import Mathlib
import Bridges.GraphTheory.K2UnionIndependentFree

/-!
# Invariants for `(K₂ ∪ kK₁)`-free graphs: induced copies, component counts and toughness

This file continues the development started in
`Bridges.GraphTheory.K2UnionIndependentFree`, where `(K₂ ∪ kK₁)`-freeness was defined by
naming an edge together with `k` independent vertices anticomplete to it.

The contributions here are:

* **Induced-copy interface.** `k2UnionK1 k` is the honest disjoint union `K₂ ⊕g kK₁`, and
  `free_iff_isEmpty_embedding` shows that the combinatorial definition `IsK2UnionK1Free`
  holds exactly when there is *no* graph embedding (i.e. no induced copy) of
  `k2UnionK1 k` into `G`.
* **A finite-graph invariant interface.** `compCount G S` counts the connected components
  remaining after deleting the vertex set `S`, and `ToughAtLeast` / `ToughGreaterThan`
  express the toughness inequalities `τ(G) ≥ t` and `τ(G) > t` in the form used in the
  literature (complete graphs satisfy every such condition vacuously, matching the
  convention `τ(K_n) = ∞`).
* **Toughness consequences.** Positive toughness forces connectivity, `1`-toughness
  forbids cut vertices and forces minimum degree at least `2`, and toughness greater than
  one forces every independent set to have fewer than half the vertices, in particular
  `2·α(G) < |V(G)|`.
* **Interaction with `(K₂ ∪ kK₁)`-freeness.** In a `(K₂ ∪ kK₁)`-free graph with toughness
  greater than one, the common antineighbourhood of any independent set of size at least
  `k` is independent and therefore also has fewer than half the vertices; equivalently
  more than half of the vertices have a neighbour in the independent set.
* **Finite regression tests.** Small path graphs are used to check the conventions.
-/

open Finset SimpleGraph K2UnionIndependentFree

namespace K2UnionK1FreeInvariants

variable {V : Type*}

/-! ## The forbidden graph and the induced-copy interface -/

/-- The graph `K₂ ∪ kK₁`: a single edge together with `k` isolated vertices. -/
abbrev k2UnionK1 (k : ℕ) : SimpleGraph (Fin 2 ⊕ Fin k) :=
  (⊤ : SimpleGraph (Fin 2)) ⊕g (⊥ : SimpleGraph (Fin k))

@[simp] lemma k2UnionK1_adj_inl_inl (k : ℕ) (i j : Fin 2) :
    (k2UnionK1 k).Adj (Sum.inl i) (Sum.inl j) ↔ i ≠ j := by
  simp [k2UnionK1]

@[simp] lemma k2UnionK1_adj_inr_inr (k : ℕ) (i j : Fin k) :
    ¬ (k2UnionK1 k).Adj (Sum.inr i) (Sum.inr j) := by
  simp [k2UnionK1]

@[simp] lemma k2UnionK1_adj_inl_inr (k : ℕ) (i : Fin 2) (j : Fin k) :
    ¬ (k2UnionK1 k).Adj (Sum.inl i) (Sum.inr j) := by
  simp [k2UnionK1]

@[simp] lemma k2UnionK1_adj_inr_inl (k : ℕ) (j : Fin k) (i : Fin 2) :
    ¬ (k2UnionK1 k).Adj (Sum.inr j) (Sum.inl i) := by
  simp [k2UnionK1]

/-- **Induced-copy interface.** A graph is `(K₂ ∪ kK₁)`-free in the sense of
`IsK2UnionK1Free` exactly when it contains no induced copy of `k2UnionK1 k`, i.e. when
there is no graph embedding of `k2UnionK1 k` into `G`. -/
theorem free_iff_isEmpty_embedding (G : SimpleGraph V) (k : ℕ) :
    IsK2UnionK1Free G k ↔ IsEmpty (k2UnionK1 k ↪g G) := by
  classical
  constructor
  · intro hfree
    refine ⟨fun f => ?_⟩
    set u := f (Sum.inl 0) with hu
    set v := f (Sum.inl 1) with hv
    have huv : G.Adj u v := by
      have hmap := f.map_rel_iff (a := Sum.inl 0) (b := Sum.inl 1)
      rw [hu, hv, hmap]
      simp
    set I : Finset V := Finset.univ.image (fun j : Fin k => f (Sum.inr j)) with hI
    have hinj : Function.Injective (fun j : Fin k => f (Sum.inr j)) := by
      intro a b hab
      simpa using f.injective hab
    have hcard : I.card = k := by
      rw [hI, Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin]
    refine hfree huv I hcard ?_ ?_
    · intro a ha b hb _
      simp only [hI, Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_univ] at ha hb
      obtain ⟨i, -, rfl⟩ := ha
      obtain ⟨j, -, rfl⟩ := hb
      intro hadj
      rw [f.map_rel_iff] at hadj
      simp at hadj
    · intro x hx
      simp only [hI, Finset.mem_image, Finset.mem_univ, true_and] at hx
      obtain ⟨j, rfl⟩ := hx
      refine ⟨fun hadj => ?_, fun hadj => ?_⟩
      · rw [hu, f.map_rel_iff] at hadj; simp at hadj
      · rw [hv, f.map_rel_iff] at hadj; simp at hadj
  · intro hempty u v huv I hcard hIndep hanti
    have huI : u ∉ I := fun hmem => (hanti u hmem).2 huv.symm
    have hvI : v ∉ I := fun hmem => (hanti v hmem).1 huv
    let e : Fin k ≃ {x // x ∈ I} := (I.equivFinOfCardEq hcard).symm
    let F : (Fin 2 ⊕ Fin k) → V :=
      Sum.elim (fun i => if i = 0 then u else v) (fun j => (e j : V))
    have hFinr : ∀ j, F (Sum.inr j) ∈ I := fun j => (e j).2
    have hUV : ∀ i : Fin 2, F (Sum.inl i) = u ∨ F (Sum.inl i) = v := by
      intro i; by_cases h : i = 0 <;> simp [F, h]
    have hnotmem : ∀ i : Fin 2, F (Sum.inl i) ∉ I := by
      intro i; rcases hUV i with h | h <;> rw [h] <;> assumption
    have hmix : ∀ (i : Fin 2) (j : Fin k), ¬ G.Adj (F (Sum.inl i)) (F (Sum.inr j)) := by
      intro i j
      rcases hUV i with h | h <;> rw [h]
      · exact (hanti _ (hFinr j)).1
      · exact (hanti _ (hFinr j)).2
    have hrel : ∀ a b, G.Adj (F a) (F b) ↔ (k2UnionK1 k).Adj a b := by
      rintro (i | i) (j | j)
      · fin_cases i <;> fin_cases j <;> simp [F, huv, huv.symm]
      · simpa [k2UnionK1] using hmix i j
      · simp only [k2UnionK1, SimpleGraph.sum_adj, iff_false]
        exact fun h => hmix j i h.symm
      · simp only [k2UnionK1, SimpleGraph.sum_adj, bot_adj, iff_false]
        exact fun h => hIndep (hFinr i) (hFinr j) h.ne h
    have hinj : Function.Injective F := by
      rintro (i | i) (j | j) hab
      · fin_cases i <;> fin_cases j <;> simp_all [F, huv.ne, huv.ne']
      · exact absurd (hab ▸ hFinr j) (hnotmem i)
      · exact absurd (hab ▸ hFinr i) (hnotmem j)
      · have h2 : e i = e j := Subtype.ext hab
        simpa using congrArg (fun z => e.symm z) h2
    exact hempty.elim ⟨⟨F, hinj⟩, fun {a b} => hrel a b⟩

/-- Contrapositive form of the induced-copy interface. -/
theorem not_free_iff_nonempty_embedding (G : SimpleGraph V) (k : ℕ) :
    ¬ IsK2UnionK1Free G k ↔ Nonempty (k2UnionK1 k ↪g G) := by
  rw [free_iff_isEmpty_embedding, not_isEmpty_iff]

/-- Every edge of a `(K₂ ∪ kK₁)`-free graph is dominated by every independent set of size
at least `k`. -/
theorem exists_adj_of_indepSet {G : SimpleGraph V} {k : ℕ}
    (hfree : IsK2UnionK1Free G k) {I : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hk : k ≤ I.card) {u v : V} (huv : G.Adj u v) :
    ∃ x ∈ I, G.Adj u x ∨ G.Adj v x := by
  by_contra hc
  push_neg at hc
  obtain ⟨J, hJI, hJcard⟩ := Finset.exists_subset_card_eq hk
  exact hfree huv J hJcard (hI.mono (fun z hz => hJI hz))
    (fun x hx => ⟨(hc x (hJI hx)).1, (hc x (hJI hx)).2⟩)

/-! ## Component counts after vertex deletion -/

/-- The number of connected components of `G` after deleting the vertex set `S`. -/
noncomputable def compCount (G : SimpleGraph V) (S : Set V) : ℕ :=
  Nat.card (G.induce Sᶜ).ConnectedComponent

/-- An edgeless graph has one component per vertex. -/
theorem card_connectedComponent_bot (α : Type*) :
    Nat.card (⊥ : SimpleGraph α).ConnectedComponent = Nat.card α :=
  Nat.card_congr (Equiv.symm (Equiv.ofBijective _
    ⟨fun _ _ h => SimpleGraph.reachable_bot.mp (SimpleGraph.ConnectedComponent.exact h),
      fun c => by induction c using SimpleGraph.ConnectedComponent.ind with | _ x => exact ⟨x, rfl⟩⟩))

/-- A set is independent exactly when it induces an edgeless graph. -/
theorem induce_eq_bot_of_isIndepSet {G : SimpleGraph V} {A : Set V} (hA : G.IsIndepSet A) :
    G.induce A = ⊥ := by
  ext a b
  simp only [comap_adj, Function.Embedding.coe_subtype, bot_adj, iff_false]
  exact fun h => hA a.2 b.2 h.ne h

/-- Deleting nothing leaves the components of `G` itself. -/
theorem compCount_empty (G : SimpleGraph V) :
    compCount G (∅ : Set V) = Nat.card G.ConnectedComponent := by
  unfold compCount
  rw [Set.compl_empty]
  exact Nat.card_congr G.induceUnivIso.connectedComponentEquiv

/-- A finite graph with at most one connected component and at least one vertex is
connected. -/
theorem connected_of_compCount_empty_le_one [Finite V] [Nonempty V] {G : SimpleGraph V}
    (h : compCount G (∅ : Set V) ≤ 1) : G.Connected := by
  unfold compCount at h
  rw [Set.compl_empty] at h
  have hsub : Subsingleton (G.induce (Set.univ : Set V)).ConnectedComponent :=
    Finite.card_le_one_iff_subsingleton.mp h
  refine ⟨fun u v => ?_⟩
  have hr : (G.induce (Set.univ : Set V)).Reachable ⟨u, trivial⟩ ⟨v, trivial⟩ :=
    SimpleGraph.ConnectedComponent.exact (Subsingleton.elim _ _)
  exact hr.map G.induceUnivIso.toHom

/-- If, after deleting `S`, some remaining vertex `x` is isolated and some other vertex
`y ≠ x` also remains, then at least two components remain. -/
theorem two_le_compCount_of_isolated [Finite V] {G : SimpleGraph V} {S : Set V} {x y : V}
    (hx : x ∉ S) (hy : y ∉ S) (hxy : x ≠ y) (hiso : ∀ z, z ∉ S → ¬ G.Adj x z) :
    2 ≤ compCount G S := by
  unfold compCount
  refine Finite.one_lt_card_iff_nontrivial.mpr ⟨(G.induce Sᶜ).connectedComponentMk ⟨x, hx⟩,
    (G.induce Sᶜ).connectedComponentMk ⟨y, hy⟩, ?_⟩
  intro hcon
  obtain ⟨w⟩ := SimpleGraph.ConnectedComponent.exact hcon
  cases w with
  | nil => exact hxy rfl
  | @cons _ z _ hadj _ => exact hiso z.1 z.2 hadj

/-- Deleting the complement of an independent set leaves exactly one component per vertex
of that set. -/
theorem compCount_compl_isIndepSet [Finite V] {G : SimpleGraph V} {A : Set V}
    (hA : G.IsIndepSet A) : compCount G Aᶜ = A.ncard := by
  unfold compCount
  rw [compl_compl, induce_eq_bot_of_isIndepSet hA, card_connectedComponent_bot,
    Nat.card_coe_set_eq]

/-! ## Toughness -/

/-- `ToughAtLeast G t` says `τ(G) ≥ t`: every vertex set whose deletion disconnects `G`
has at least `t` times as many vertices as the number of components it creates.
Complete graphs satisfy this for every `t`, matching the convention `τ(K_n) = ∞`. -/
def ToughAtLeast (G : SimpleGraph V) (t : ℚ) : Prop :=
  ∀ S : Set V, 2 ≤ compCount G S → t * (compCount G S : ℚ) ≤ (S.ncard : ℚ)

/-- `ToughGreaterThan G t` says `τ(G) > t`, with the same convention for complete
graphs. -/
def ToughGreaterThan (G : SimpleGraph V) (t : ℚ) : Prop :=
  ∀ S : Set V, 2 ≤ compCount G S → t * (compCount G S : ℚ) < (S.ncard : ℚ)

theorem ToughGreaterThan.toughAtLeast {G : SimpleGraph V} {t : ℚ}
    (h : ToughGreaterThan G t) : ToughAtLeast G t :=
  fun S hS => (h S hS).le

theorem ToughAtLeast.mono {G : SimpleGraph V} {t s : ℚ} (h : ToughAtLeast G t)
    (hst : s ≤ t) : ToughAtLeast G s := by
  intro S hS
  refine le_trans ?_ (h S hS)
  have hnn : (0 : ℚ) ≤ (compCount G S : ℚ) := Nat.cast_nonneg _
  nlinarith

/-- Positive toughness forces connectivity. -/
theorem connected_of_toughAtLeast [Finite V] [Nonempty V] {G : SimpleGraph V} {t : ℚ}
    (ht : 0 < t) (h : ToughAtLeast G t) : G.Connected := by
  refine connected_of_compCount_empty_le_one ?_
  by_contra hc
  push_neg at hc
  have h2 : 2 ≤ compCount G (∅ : Set V) := hc
  have hle := h ∅ h2
  rw [Set.ncard_empty] at hle
  have hc2 : (2 : ℚ) ≤ (compCount G (∅ : Set V) : ℚ) := by exact_mod_cast h2
  push_cast at hle
  nlinarith [mul_le_mul_of_nonneg_left hc2 ht.le]

/-- A `1`-tough graph has no cut vertex. -/
theorem compCount_singleton_le_one {G : SimpleGraph V} {t : ℚ} (ht : 1 ≤ t)
    (h : ToughAtLeast G t) (v : V) : compCount G ({v} : Set V) ≤ 1 := by
  by_contra hc
  push_neg at hc
  have h2 : 2 ≤ compCount G ({v} : Set V) := hc
  have hle := h {v} h2
  rw [Set.ncard_singleton] at hle
  have hc2 : (2 : ℚ) ≤ (compCount G ({v} : Set V) : ℚ) := by exact_mod_cast h2
  push_cast at hle
  nlinarith [mul_le_mul_of_nonneg_left hc2 (le_trans zero_le_one ht)]

/-- The number of neighbours of a vertex, as a set cardinality. -/
theorem ncard_neighborSet [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj] (v : V) :
    (G.neighborSet v).ncard = G.degree v := by
  rw [Set.ncard_eq_toFinset_card', ← SimpleGraph.card_neighborFinset_eq_degree]
  congr 1

/-- If some vertex `y ≠ v` is not adjacent to `v`, then deleting the neighbourhood of `v`
separates `v` from `y`, leaving at least two components. -/
theorem two_le_compCount_neighborSet [Finite V] {G : SimpleGraph V} {v y : V}
    (hy : y ≠ v) (hadj : ¬ G.Adj v y) : 2 ≤ compCount G (G.neighborSet v) := by
  refine two_le_compCount_of_isolated (x := v) (y := y) ?_ ?_ (Ne.symm hy) ?_
  · simp [SimpleGraph.mem_neighborSet]
  · simpa [SimpleGraph.mem_neighborSet] using hadj
  · intro z hz
    simpa [SimpleGraph.mem_neighborSet] using hz

/-- **Separator inequality.** If `τ(G) > 1` then every vertex cut has at least one more
vertex than the number of components it creates. -/
theorem succ_compCount_le_ncard_of_toughGreaterThan_one {G : SimpleGraph V}
    (h : ToughGreaterThan G 1) {S : Set V} (hS : 2 ≤ compCount G S) :
    compCount G S + 1 ≤ S.ncard := by
  have hlt := h S hS
  rw [one_mul] at hlt
  exact_mod_cast hlt

/-- Every vertex cut of a graph with `τ(G) > 1` has at least three vertices. -/
theorem three_le_ncard_of_separator {G : SimpleGraph V} (h : ToughGreaterThan G 1)
    {S : Set V} (hS : 2 ≤ compCount G S) : 3 ≤ S.ncard := by
  have := succ_compCount_le_ncard_of_toughGreaterThan_one h hS
  omega

/-- In a `1`-tough graph on at least three vertices every vertex has degree at least
`2`. -/
theorem two_le_degree_of_toughAtLeast [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj]
    {t : ℚ} (ht : 1 ≤ t) (h : ToughAtLeast G t) (hcard : 3 ≤ Fintype.card V) (v : V) :
    2 ≤ G.degree v := by
  classical
  by_cases hall : ∀ y, y ≠ v → G.Adj v y
  · have hsub : Finset.univ.erase v ⊆ G.neighborFinset v := by
      intro y hy
      rw [Finset.mem_erase] at hy
      simpa using hall y hy.1
    have hcard2 := Finset.card_le_card hsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ,
      SimpleGraph.card_neighborFinset_eq_degree] at hcard2
    omega
  · push_neg at hall
    obtain ⟨y, hy, hadj⟩ := hall
    have h2 := two_le_compCount_neighborSet hy hadj
    have hle := h _ h2
    rw [ncard_neighborSet v] at hle
    have hc2 : (2 : ℚ) ≤ (compCount G (G.neighborSet v) : ℚ) := by exact_mod_cast h2
    have : (2 : ℚ) ≤ (G.degree v : ℚ) := by nlinarith
    exact_mod_cast this

/-- A `1`-tough graph on at least three vertices has minimum degree at least `2`. -/
theorem two_le_minDegree_of_toughAtLeast {G : SimpleGraph V} [Fintype V]
    [DecidableRel G.Adj] {t : ℚ} (ht : 1 ≤ t) (h : ToughAtLeast G t)
    (hcard : 3 ≤ Fintype.card V) : 2 ≤ G.minDegree := by
  have : Nonempty V := Fintype.card_pos_iff.mp (by omega)
  obtain ⟨v, hv⟩ := G.exists_minimal_degree_vertex
  rw [hv]
  exact two_le_degree_of_toughAtLeast ht h hcard v

/-- In a graph with `τ(G) > 1` on at least four vertices every vertex has degree at least
`3`. -/
theorem three_le_degree_of_toughGreaterThan_one [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (h : ToughGreaterThan G 1) (hcard : 4 ≤ Fintype.card V) (v : V) :
    3 ≤ G.degree v := by
  classical
  by_cases hall : ∀ y, y ≠ v → G.Adj v y
  · have hsub : Finset.univ.erase v ⊆ G.neighborFinset v := by
      intro y hy
      rw [Finset.mem_erase] at hy
      simpa using hall y hy.1
    have hcard2 := Finset.card_le_card hsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ,
      SimpleGraph.card_neighborFinset_eq_degree] at hcard2
    omega
  · push_neg at hall
    obtain ⟨y, hy, hadj⟩ := hall
    have h2 := two_le_compCount_neighborSet hy hadj
    have hlt := h _ h2
    rw [ncard_neighborSet v, one_mul] at hlt
    have hd : compCount G (G.neighborSet v) < G.degree v := by exact_mod_cast hlt
    omega

/-- A graph with `τ(G) > 1` on at least four vertices has minimum degree at least `3`. -/
theorem three_le_minDegree_of_toughGreaterThan_one [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] (h : ToughGreaterThan G 1) (hcard : 4 ≤ Fintype.card V) :
    3 ≤ G.minDegree := by
  have : Nonempty V := Fintype.card_pos_iff.mp (by omega)
  obtain ⟨v, hv⟩ := G.exists_minimal_degree_vertex
  rw [hv]
  exact three_le_degree_of_toughGreaterThan_one h hcard v

/-- Toughness greater than one forces every independent set to contain fewer than half of
the vertices. -/
theorem two_mul_ncard_isIndepSet_lt [Fintype V] {G : SimpleGraph V}
    (h : ToughGreaterThan G 1) (hcard : 3 ≤ Fintype.card V) {A : Set V}
    (hA : G.IsIndepSet A) : 2 * A.ncard < Fintype.card V := by
  rcases le_or_gt A.ncard 1 with hle | hgt
  · omega
  · have h2 : 2 ≤ compCount G Aᶜ := by
      rw [compCount_compl_isIndepSet hA]; omega
    have hlt := h Aᶜ h2
    rw [compCount_compl_isIndepSet hA] at hlt
    have hsum : A.ncard + Aᶜ.ncard = Nat.card V := Set.ncard_add_ncard_compl A
    have hAlt : A.ncard < Aᶜ.ncard := by
      rw [one_mul] at hlt
      exact_mod_cast hlt
    rw [Nat.card_eq_fintype_card] at hsum
    omega

/-- Toughness greater than one bounds the independence number: `2·α(G) < |V(G)|`. -/
theorem two_mul_indepNum_lt [Fintype V] {G : SimpleGraph V}
    (h : ToughGreaterThan G 1) (hcard : 3 ≤ Fintype.card V) :
    2 * G.indepNum < Fintype.card V := by
  obtain ⟨s, hs, hscard⟩ := G.exists_isNIndepSet_indepNum
  have := two_mul_ncard_isIndepSet_lt h hcard hs
  rwa [Set.ncard_coe_finset, hscard] at this

/-! ## Interaction of freeness and toughness -/

/-- An independent set is contained in its own antineighbourhood. -/
theorem subset_antiNeighborhood_self {G : SimpleGraph V} {A : Set V}
    (hA : G.IsIndepSet A) : A ⊆ antiNeighborhood G A := by
  intro x hx a ha h
  exact hA hx ha h.ne h

/-- In a `(K₂ ∪ kK₁)`-free graph of toughness greater than one, the common
antineighbourhood of an independent set of size at least `k` contains fewer than half of
the vertices. -/
theorem two_mul_ncard_antiNeighborhood_lt [Fintype V]
    {G : SimpleGraph V} {k : ℕ} (hfree : IsK2UnionK1Free G k)
    (h : ToughGreaterThan G 1) (hcard : 3 ≤ Fintype.card V)
    {I : Finset V} (hI : G.IsIndepSet (I : Set V)) (hk : k ≤ I.card) :
    2 * (antiNeighborhood G (I : Set V)).ncard < Fintype.card V :=
  two_mul_ncard_isIndepSet_lt h hcard (antiNeighborhood_isIndepSet hfree hI hk)

/-- Consequently, in a `(K₂ ∪ kK₁)`-free graph of toughness greater than one, more than
half of the vertices have a neighbour in any given independent set of size at least
`k`. -/
theorem lt_two_mul_ncard_hasNeighbor [Fintype V]
    {G : SimpleGraph V} {k : ℕ} (hfree : IsK2UnionK1Free G k)
    (h : ToughGreaterThan G 1) (hcard : 3 ≤ Fintype.card V)
    {I : Finset V} (hI : G.IsIndepSet (I : Set V)) (hk : k ≤ I.card) :
    Fintype.card V < 2 * {v : V | ∃ x ∈ I, G.Adj v x}.ncard := by
  have hcompl : {v : V | ∃ x ∈ I, G.Adj v x} = (antiNeighborhood G (I : Set V))ᶜ := by
    ext v
    simp [antiNeighborhood, Set.mem_compl_iff]
  have hsum : (antiNeighborhood G (I : Set V)).ncard
      + (antiNeighborhood G (I : Set V))ᶜ.ncard = Nat.card V :=
    Set.ncard_add_ncard_compl _
  rw [Nat.card_eq_fintype_card] at hsum
  have hlt := two_mul_ncard_antiNeighborhood_lt hfree h hcard hI hk
  rw [hcompl]
  omega

/-! ## Hamilton connectedness -/

/-- `G` is Hamilton-connected when every pair of distinct vertices is joined by a
Hamiltonian path, i.e. a path through all the vertices. -/
def IsHamiltonConnected (G : SimpleGraph V) : Prop :=
  ∀ u v : V, u ≠ v → ∃ p : G.Walk u v, p.IsPath ∧ ∀ w : V, w ∈ p.support

/-- A Hamilton-connected graph on a nonempty vertex set is connected. -/
theorem connected_of_isHamiltonConnected [Nonempty V] {G : SimpleGraph V}
    (h : IsHamiltonConnected G) : G.Connected := by
  refine ⟨fun u v => ?_⟩
  rcases eq_or_ne u v with rfl | hne
  · exact SimpleGraph.Reachable.refl u
  · obtain ⟨p, -, -⟩ := h u v hne
    exact ⟨p⟩

/-! ## Finite regression tests -/

/-- In the path on three vertices every edge dominates every vertex. -/
theorem pathGraph_three_dominating (u v x : Fin 3) (huv : (pathGraph 3).Adj u v) :
    (pathGraph 3).Adj u x ∨ (pathGraph 3).Adj v x := by
  revert huv
  simp only [SimpleGraph.pathGraph_adj]
  revert u v x
  decide

/-- The path on three vertices is `(K₂ ∪ K₁)`-free. -/
theorem pathGraph_three_free : IsK2UnionK1Free (pathGraph 3) 1 := by
  intro u v huv I hcard _ hanti
  obtain ⟨x, rfl⟩ := Finset.card_eq_one.mp hcard
  have hx : x ∈ ({x} : Finset (Fin 3)) := Finset.mem_singleton_self x
  rcases pathGraph_three_dominating u v x huv with hadj | hadj
  · exact (hanti x hx).1 hadj
  · exact (hanti x hx).2 hadj

/-- The path on four vertices is *not* `(K₂ ∪ K₁)`-free: the edge `0-1` together with the
vertex `3` is an induced `K₂ ∪ K₁`. -/
theorem pathGraph_four_not_free : ¬ IsK2UnionK1Free (pathGraph 4) 1 := by
  intro hfree
  have h01 : (pathGraph 4).Adj 0 1 := by simp [SimpleGraph.pathGraph_adj]
  refine hfree h01 {3} rfl ?_ ?_
  · intro a ha b hb hab
    simp only [Finset.coe_singleton, Set.mem_singleton_iff] at ha hb
    exact absurd (ha.trans hb.symm) hab
  · intro x hx
    rw [Finset.mem_singleton] at hx
    subst hx
    constructor <;> · simp only [SimpleGraph.pathGraph_adj]; decide

/-- Deleting the middle vertex of `P₃` leaves two components; hence `P₃` is not
`1`-tough. -/
theorem pathGraph_three_not_toughAtLeast_one : ¬ ToughAtLeast (pathGraph 3) 1 := by
  intro h
  have hiso : ∀ z : Fin 3, z ∉ ({1} : Set (Fin 3)) → ¬ (pathGraph 3).Adj 0 z := by
    intro z hz hadj
    rw [Set.mem_singleton_iff] at hz
    revert hz
    simp only [SimpleGraph.pathGraph_adj] at hadj
    revert hadj
    revert z
    decide
  have h2 : 2 ≤ compCount (pathGraph 3) ({1} : Set (Fin 3)) :=
    two_le_compCount_of_isolated (x := 0) (y := 2) (by simp) (by simp) (by decide) hiso
  have := compCount_singleton_le_one (le_refl (1 : ℚ)) h 1
  omega

/-- The edgeless graph on three vertices has three components. -/
theorem compCount_bot_fin_three :
    compCount (⊥ : SimpleGraph (Fin 3)) (∅ : Set (Fin 3)) = 3 := by
  have h : compCount (⊥ : SimpleGraph (Fin 3)) ((Set.univ : Set (Fin 3))ᶜ)
      = (Set.univ : Set (Fin 3)).ncard :=
    compCount_compl_isIndepSet (by intro a _ b _ _ hadj; simp at hadj)
  simpa using h

end K2UnionK1FreeInvariants