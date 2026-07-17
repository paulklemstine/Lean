import Mathlib

/-!
# Contrarian results on rooted three-vertex paths

This file isolates the local counting mechanism behind the exceptional case `P₃`.
It also gives a certified six-vertex counterexample to the tempting conjecture that
ordinary `P₃`-irregularity forces end-rooted `P₃`-irregularity.
-/

namespace RootedPathIrregularity

/-- A finite loopless undirected graph, represented by a Boolean adjacency test. -/
structure FinGraph (V : Type*) [Fintype V] where
  adj : V → V → Bool
  symm : ∀ v w, adj v w = adj w v
  loopless : ∀ v, adj v v = false

namespace FinGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The neighbors of a vertex. -/
def neighbors (G : FinGraph V) (v : V) : Finset V :=
  Finset.univ.filter fun w => G.adj v w

/-- Vertex degree. -/
def degree (G : FinGraph V) (v : V) : ℕ := (G.neighbors v).card

/-- Number of copies of `P₃` in which `v` is the central root. -/
def centerP3Count (G : FinGraph V) (v : V) : ℕ := (G.degree v).choose 2

/-- Number of copies of `P₃` in which `v` is a specified end root. -/
def endP3Count (G : FinGraph V) (v : V) : ℕ :=
  ∑ w ∈ G.neighbors v, (G.degree w - 1)

/-- Number of unrooted copies of `P₃` containing `v`. -/
def ordinaryP3Count (G : FinGraph V) (v : V) : ℕ :=
  G.centerP3Count v + G.endP3Count v

/-- A vertex statistic separates every pair of vertices. -/
def Irregular (f : V → ℕ) : Prop := Function.Injective f

omit [DecidableEq V] in
lemma mem_neighbors_iff (G : FinGraph V) (v w : V) :
    w ∈ G.neighbors v ↔ G.adj v w = true := by
  unfold FinGraph.neighbors; aesop;

omit [DecidableEq V] in
lemma degree_lt_card (G : FinGraph V) (v : V) : G.degree v < Fintype.card V := by
  refine' lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr _ ) ) _;
  · exact ⟨ v, Finset.mem_univ _, by simp +decide [ G.loopless ] ⟩;
  · rfl

omit [DecidableEq V] in
lemma degree_eq_zero_iff (G : FinGraph V) (v : V) :
    G.degree v = 0 ↔ ∀ w, G.adj v w = false := by
  simp +decide [ FinGraph.degree, FinGraph.neighbors ]

lemma degree_eq_card_sub_one_iff (G : FinGraph V) (v : V) :
    G.degree v = Fintype.card V - 1 ↔ ∀ w, w ≠ v → G.adj v w = true := by
  refine' ⟨ fun h w hw => _, fun h => _ ⟩;
  · contrapose! h;
    refine' ne_of_lt ( lt_of_le_of_lt ( Finset.card_le_card _ ) _ );
    exact Finset.univ \ { v, w };
    · grind +suggestions;
    · grind;
  · convert Finset.card_erase_of_mem ( Finset.mem_univ v ) using 1;
    refine' Finset.card_bij ( fun w hw => w ) _ _ _ <;> simp +decide [ * ];
    · simp +decide [ FinGraph.neighbors, G.loopless ];
    · exact fun w hw => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h w hw ⟩

/-
Every finite simple graph with at least two vertices has two vertices of equal degree.
-/
theorem exists_distinct_equal_degree (G : FinGraph V) (hcard : 2 ≤ Fintype.card V) :
    ∃ v w : V, v ≠ w ∧ G.degree v = G.degree w := by
  by_contra! h;
  -- If all $N$ degrees are distinct, they realize every value from $0$ to $N-1$.
  have h_realize : Finset.image (fun v => G.degree v) Finset.univ = Finset.range (Fintype.card V) := by
    exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.2 fun v _ => Finset.mem_range.2 ( G.degree_lt_card v ) ) ( by rw [ Finset.card_image_of_injective _ fun v w hvw => not_imp_not.1 ( h v w ) hvw, Finset.card_range, Finset.card_univ ] );
  -- Thus there are vertices of degree $0$ and $N-1$.
  obtain ⟨v0, hv0⟩ : ∃ v0 : V, G.degree v0 = 0 := by
    exact Exists.elim ( Finset.mem_image.mp ( h_realize.symm ▸ Finset.mem_range.mpr ( zero_lt_two.trans_le hcard ) ) ) fun v hv => ⟨ v, hv.2 ⟩
  obtain ⟨vN, hvN⟩ : ∃ vN : V, G.degree vN = Fintype.card V - 1 := by
    exact Exists.elim ( Finset.mem_image.mp ( h_realize.symm ▸ Finset.mem_range.mpr ( Nat.sub_lt ( by linarith ) zero_lt_one ) ) ) fun v hv => ⟨ v, hv.2 ⟩;
  -- The latter is adjacent to every other vertex, contradicting the degree-zero vertex.
  have h_adj : ∀ w : V, w ≠ vN → G.adj vN w = true := by
    have := G.degree_eq_card_sub_one_iff vN; aesop;
  by_cases hv0vN : v0 = vN <;> simp_all +decide [ FinGraph.degree_eq_zero_iff ];
  · omega;
  · exact absurd ( G.symm v0 vN ) ( by simp +decide [ hv0, h_adj v0 hv0vN ] )

/-
The central-root count for `P₃` can never distinguish all vertices of a
nontrivial finite graph.  This strengthens the paper's negative observation by
making the degree-collision obstruction explicit.
-/
theorem no_nontrivial_centerP3_irregular (G : FinGraph V)
    (hcard : 2 ≤ Fintype.card V) : ¬ Irregular (G.centerP3Count) := by
  obtain ⟨ v, w, hvw, h ⟩ := exists_distinct_equal_degree G hcard;
  exact fun h' => hvw ( h' ( by unfold FinGraph.centerP3Count; aesop ) )

end FinGraph

section Counterexample

/-- The graph with edges `02, 03, 05, 12, 14, 23`. -/
def sixVertexGraph : FinGraph (Fin 6) where
  adj v w :=
    (v = 0 && w = 2) || (v = 2 && w = 0) ||
    (v = 0 && w = 3) || (v = 3 && w = 0) ||
    (v = 0 && w = 5) || (v = 5 && w = 0) ||
    (v = 1 && w = 2) || (v = 2 && w = 1) ||
    (v = 1 && w = 4) || (v = 4 && w = 1) ||
    (v = 2 && w = 3) || (v = 3 && w = 2)
  symm := by decide
  loopless := by decide

/-- Its ordinary `P₃` counts, in vertex order, are `6,3,7,5,1,2`. -/
theorem sixVertex_ordinary_counts :
    (List.ofFn (fun v : Fin 6 => sixVertexGraph.ordinaryP3Count v)) =
      [6, 3, 7, 5, 1, 2] := by
  decide

/-- Its end-rooted counts are `3,2,4,4,1,2`, so vertices 2 and 3 collide. -/
theorem sixVertex_end_counts :
    (List.ofFn (fun v : Fin 6 => sixVertexGraph.endP3Count v)) =
      [3, 2, 4, 4, 1, 2] := by
  decide

/-- **Disproof of a plausible converse:** ordinary `P₃`-irregularity does not
imply end-rooted `P₃`-irregularity. -/
theorem ordinary_does_not_force_end_rooted :
    FinGraph.Irregular sixVertexGraph.ordinaryP3Count ∧
      ¬ FinGraph.Irregular sixVertexGraph.endP3Count := by
  constructor
  · intro v w
    fin_cases v <;> fin_cases w <;> native_decide
  · intro h
    have heq : sixVertexGraph.endP3Count (2 : Fin 6) =
        sixVertexGraph.endP3Count (3 : Fin 6) := by native_decide
    exact (by decide : (2 : Fin 6) ≠ 3) (h heq)

end Counterexample

end RootedPathIrregularity