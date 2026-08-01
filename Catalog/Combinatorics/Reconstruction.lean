import Mathlib

/-!
# Vertex-deleted decks and Kelly's counting lemma

The full reconstruction conjecture is open.  This file develops its standard
finite-graph language, proves the double-counting core of Kelly's lemma, and
proves reconstruction for the two extremal graph classes: edgeless and complete
graphs.
-/

namespace Catalog.Combinatorics.Reconstruction

open Finset SimpleGraph
open scoped Sym2

variable {V W U : Type*}

/-- The card obtained by deleting one vertex and taking the induced graph. -/
abbrev vertexCard (G : SimpleGraph V) (v : V) : SimpleGraph {x : V // x ≠ v} :=
  G.induce ({v}ᶜ : Set V)

/-- Two finite graphs have the same deck when their vertices can be paired so
that corresponding vertex-deleted cards are isomorphic. -/
def SameDeck (G : SimpleGraph V) (H : SimpleGraph W) : Prop :=
  ∃ e : V ≃ W, ∀ v : V, Nonempty (vertexCard G v ≃g vertexCard H (e v))

/-- A family of `k`-element vertex sets, used for the abstract form of Kelly's
counting argument. -/
def UniformFamily [Fintype V] [DecidableEq V] (A : Finset (Finset V)) (k : ℕ) : Prop :=
  ∀ s ∈ A, s.card = k

/-- The members of a family which survive deletion of `v`. -/
def survivingSets [DecidableEq V] (A : Finset (Finset V)) (v : V) : Finset (Finset V) :=
  A.filter fun s => v ∉ s

/-- Kelly's double-counting identity: every `k`-vertex member of `A` survives
in exactly `|V|-k` cards. -/
theorem kelly_double_count [Fintype V] [DecidableEq V]
    (A : Finset (Finset V)) (k : ℕ) (hA : UniformFamily A k) :
    ∑ v : V, (survivingSets A v).card = (Fintype.card V - k) * A.card := by
  have h1 : ∑ v : V, (survivingSets A v).card = ∑ s ∈ A, (Fintype.card V - k) := by
    simp_rw [survivingSets, Finset.card_filter]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro s hs
    have hsk : s.card = k := hA s hs
    rw [Finset.sum_ite]
    simp
    rw [show (Finset.univ.filter fun x => x ∉ s) = Finset.univ \ s from by ext; simp]
    rw [Finset.card_sdiff_of_subset (Finset.subset_univ s), Finset.card_univ, hsk]
  rw [h1, Finset.sum_const, Finset.card_eq_sum_ones, smul_eq_mul, mul_comm]

/-- The family of vertex sets inducing a copy of the finite pattern `F`. -/
noncomputable def inducedCopyFamily [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (F : SimpleGraph U) [Fintype U] : Finset (Finset V) := by
  classical
  exact Finset.univ.filter fun s =>
    s.card = Fintype.card U ∧ Nonempty (G.induce (s : Set V) ≃g F)

/-- Every member of `inducedCopyFamily` has the order of the pattern. -/
theorem inducedCopyFamily_uniform [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (F : SimpleGraph U) [Fintype U] :
    UniformFamily (inducedCopyFamily G F) (Fintype.card U) := by
  classical
  intro s hs
  exact (Finset.mem_filter.mp hs).2.1

/-- **Kelly's lemma (counting form).** The total number of induced copies of a
`k`-vertex pattern visible across all vertex-deleted cards is `n-k` times its
number in the original graph.  Here a copy is counted by its vertex set. -/
theorem kelly_lemma [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (F : SimpleGraph U) [Fintype U] :
    ∑ v : V, (survivingSets (inducedCopyFamily G F) v).card =
      (Fintype.card V - Fintype.card U) * (inducedCopyFamily G F).card := by
  exact kelly_double_count _ _ (inducedCopyFamily_uniform G F)

/-- Isomorphic finite graphs have equal numbers of edges. -/
theorem edge_count_eq_of_iso [Fintype V] [Fintype W]
    {G : SimpleGraph V} {H : SimpleGraph W} [DecidableRel G.Adj] [DecidableRel H.Adj]
    (e : G ≃g H) : G.edgeFinset.card = H.edgeFinset.card := by
  exact e.card_edgeFinset_eq

/-- Summing edge counts over the vertex-deleted cards counts every original
edge once for each vertex outside its two endpoints. -/
theorem vertexCard_edge_sum [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ v : V, (vertexCard G v).edgeFinset.card =
      (Fintype.card V - 2) * G.edgeFinset.card := by
  -- First, establish that (vertexCard G v).edgeFinset.card equals
  -- the number of edges not containing v
  have card_equiv : ∀ v : V, (vertexCard G v).edgeFinset.card =
      (G.edgeFinset.filter (fun e => v ∉ e)).card := by
    intro v
    let embed : {x : V // x ≠ v} ↪ V := Function.Embedding.subtype _
    refine Finset.card_bij (fun e _ => e.map embed) ?_ ?_ ?_
    · intro e he
      simp only [Finset.mem_filter]
      -- Extract that e is an edge from he using Sym2.induction
      induction e using Sym2.ind with
      | _ a b =>
        have hadj : (vertexCard G v).Adj a b := by
          have := he
          simp only [SimpleGraph.mem_edgeFinset] at this
          exact this
        refine ⟨?_, ?_⟩
        · -- Show Sym2.map embed s(a, b) ∈ G.edgeFinset
          simp only [vertexCard, SimpleGraph.induce_adj] at hadj
          rw [SimpleGraph.mem_edgeFinset]
          exact hadj
        · -- Show v ∉ Sym2.map embed s(a, b)
          have ha : (a : V) ≠ v := a.property
          have hb : (b : V) ≠ v := b.property
          simp only [Sym2.map]
          rintro ⟨x, hx⟩
          have hx' : Sym2.mk (embed a, embed b) = Sym2.mk (v, x) := hx
          rw [Sym2.eq_iff] at hx'
          simp at hx'
          rcases hx' with ⟨h1, _⟩ | ⟨_, h2⟩
          · exact ha h1
          · exact hb h2
    · intro e₁ _ e₂ _ heq
      induction e₁ using Sym2.ind with
      | _ a₁ b₁ =>
        induction e₂ using Sym2.ind with
        | _ a₂ b₂ =>
          have heq' : Sym2.mk (embed a₁, embed b₁) = Sym2.mk (embed a₂, embed b₂) := heq
          rw [Sym2.eq_iff] at heq'
          rcases heq' with ⟨h1, h2⟩ | ⟨h1, h2⟩
          · rw [Sym2.eq_iff]
            exact Or.inl ⟨Subtype.val_injective h1, Subtype.val_injective h2⟩
          · rw [Sym2.eq_iff]
            exact Or.inr ⟨Subtype.val_injective h1, Subtype.val_injective h2⟩
    · intro e he
      simp only [Finset.mem_filter] at he
      obtain ⟨he_edge, hv_notin⟩ := he
      rw [SimpleGraph.mem_edgeFinset] at he_edge
      induction e using Sym2.ind with
      | _ x y =>
        have hadj : G.Adj x y := he_edge
        have hx : x ≠ v := by
          intro h
          apply hv_notin
          rw [h]
          simp
        have hy : y ≠ v := by
          intro h
          apply hv_notin
          rw [h]
          simp
        use Sym2.mk (⟨x, hx⟩, ⟨y, hy⟩)
        refine ⟨?_, ?_⟩
        · -- Show it's in the edgeFinset of vertexCard G v
          rw [SimpleGraph.mem_edgeFinset]
          simp [vertexCard, hadj]
        · -- Show the map equals s(x, y)
          rfl
  -- Rewrite using card_equiv
  simp_rw [card_equiv]
  -- Now we need: ∑ v, #{e ∈ G.edgeFinset | v ∉ e} = (n - 2) * |G.edgeFinset|
  -- Convert #{e ∈ E | v ∉ e} to a sum
  conv_lhs =>
    arg 2
    ext v
    rw [show #{e ∈ G.edgeFinset | v ∉ e} = ∑ e ∈ G.edgeFinset, if v ∉ e then 1 else 0 by
      rw [Finset.card_filter]]
  rw [Finset.sum_comm]
  -- For each edge e = {u, v}, #{x | x ∉ e} = n - 2
  have h_card : ∀ e ∈ G.edgeFinset, ∑ x : V, (if x ∉ e then 1 else 0) = Fintype.card V - 2 := by
    intro e he
    simp only [Finset.sum_ite, Finset.sum_const, smul_eq_mul, mul_zero, add_zero, mul_one]
    -- #{x | x ∉ e} = |V \ e| = n - |e| = n - 2
    have he_card : e.toFinset.card = 2 := by
      induction e using Sym2.ind with
      | _ x y =>
        have hxy : x ≠ y := by
          have he' : s(x, y) ∈ G.edgeFinset := he
          rw [SimpleGraph.mem_edgeFinset] at he'
          exact he'.ne
        rw [Sym2.toFinset]
        rw [Sym2.toMultiset]
        simp [Multiset.toFinset, hxy]
    -- #{x | x ∉ e} = |Finset.univ \ e.toFinset| = n - 2
    have h1 : #{x : V | x ∉ e} = #{x : V | x ∉ e.toFinset} := by
      congr 1
      ext x
      simp [Sym2.mem_toFinset]
    have h2 : #{x : V | x ∉ e.toFinset} = (Finset.univ \ e.toFinset).card := by
      rw [show (Finset.univ : Finset V) \ e.toFinset = Finset.univ.filter (fun x => x ∉ e.toFinset) by
        ext x; simp]
    rw [h1, h2]
    rw [Finset.card_sdiff]
    simp [he_card]
  rw [Finset.sum_congr rfl h_card]
  simp [mul_comm]

/-- The number of edges is reconstructible from the deck for graphs with at
least three vertices.  This is the `K₂` instance of Kelly's principle. -/
theorem edge_count_reconstructible [Fintype V] [Fintype W]
    [DecidableEq V] [DecidableEq W]
    (G : SimpleGraph V) (H : SimpleGraph W)
    [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hcard : 3 ≤ Fintype.card V) (hdeck : SameDeck G H) :
    G.edgeFinset.card = H.edgeFinset.card := by
  obtain ⟨e, he⟩ := hdeck
  have hVW : Fintype.card V = Fintype.card W := Fintype.card_congr e
  have hsums : (∑ v : V, (vertexCard G v).edgeFinset.card) =
      ∑ w : W, (vertexCard H w).edgeFinset.card := by
    rw [← e.sum_comp]
    apply Finset.sum_congr rfl
    intro v _
    exact edge_count_eq_of_iso (Classical.choice (he v))
  rw [vertexCard_edge_sum G, vertexCard_edge_sum H, ← hVW] at hsums
  exact Nat.eq_of_mul_eq_mul_left (by omega) hsums

/-- The edgeless graph is reconstructible from its deck (for order at least
three). -/
theorem edgeless_reconstructible [Fintype V] [Fintype W]
    [DecidableEq V] [DecidableEq W]
    (G : SimpleGraph V) (H : SimpleGraph W)
    [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hcard : 3 ≤ Fintype.card V) (hG : G = ⊥) (hdeck : SameDeck G H) :
    Nonempty (G ≃g H) := by
  classical
  have hedge := edge_count_reconstructible G H hcard hdeck
  obtain ⟨e, _⟩ := hdeck
  have hGE : G.edgeFinset = ∅ := by
    ext x
    rw [SimpleGraph.mem_edgeFinset]
    simp [hG]
  have hzero : H.edgeFinset.card = 0 := by
    rw [← hedge, hGE, Finset.card_empty]
  have hH : H = ⊥ := (SimpleGraph.edgeFinset_eq_empty.mp (Finset.card_eq_zero.mp hzero))
  subst G
  subst H
  exact ⟨⟨e, by simp⟩⟩

/-- The complete graph is reconstructible from its deck (for order at least
three). -/
theorem complete_reconstructible [Fintype V] [Fintype W]
    [DecidableEq V] [DecidableEq W]
    (G : SimpleGraph V) (H : SimpleGraph W)
    [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hcard : 3 ≤ Fintype.card V) (hG : G = ⊤) (hdeck : SameDeck G H) :
    Nonempty (G ≃g H) := by
  classical
  have hedge := edge_count_reconstructible G H hcard hdeck
  obtain ⟨e, _⟩ := hdeck
  have hcardVW : Fintype.card V = Fintype.card W := Fintype.card_congr e
  have hGE : G.edgeFinset = (⊤ : SimpleGraph V).edgeFinset := by
    ext x
    rw [SimpleGraph.mem_edgeFinset, SimpleGraph.mem_edgeFinset]
    simp [hG]
  have htopcard : H.edgeFinset.card = (⊤ : SimpleGraph W).edgeFinset.card := by
    have hV := (SimpleGraph.card_edgeFinset_top_eq_card_choose_two (V := V))
    have hW := (SimpleGraph.card_edgeFinset_top_eq_card_choose_two (V := W))
    calc
      H.edgeFinset.card = G.edgeFinset.card := hedge.symm
      _ = (⊤ : SimpleGraph V).edgeFinset.card := congrArg Finset.card hGE
      _ = (Fintype.card V).choose 2 := hV
      _ = (Fintype.card W).choose 2 := by rw [hcardVW]
      _ = (⊤ : SimpleGraph W).edgeFinset.card := hW.symm
  have hedges : H.edgeFinset = (⊤ : SimpleGraph W).edgeFinset :=
    Finset.eq_of_subset_of_card_le (SimpleGraph.edgeFinset_mono le_top) (by omega)
  have hH : H = ⊤ := SimpleGraph.edgeFinset_inj.mp hedges
  subst G
  subst H
  exact ⟨SimpleGraph.Iso.completeGraph e⟩

end Catalog.Combinatorics.Reconstruction