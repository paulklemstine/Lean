import Mathlib

/-!
# A structural lemma for `(K₂ ∪ kK₁)`-free graphs

The forbidden induced subgraph condition has a useful equivalent local form: after fixing
an independent `k`-set, the vertices with no neighbour in that set induce an edgeless graph.
This is one of the elementary reductions used in Hamilton-connectivity arguments for this
graph class.
-/

open Finset

namespace K2UnionIndependentFree

variable {V : Type*}

/-- `G` has no induced copy of `K₂ ∪ kK₁`, expressed by naming the edge and the
`k` isolated vertices. -/
def IsK2UnionK1Free (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∀ ⦃u v : V⦄, G.Adj u v → ∀ I : Finset V,
    I.card = k → G.IsIndepSet (I : Set V) →
    (∀ x ∈ I, ¬ G.Adj u x ∧ ¬ G.Adj v x) → False

/-- The common antineighbourhood of a set: vertices having no neighbour in it. -/
def antiNeighborhood (G : SimpleGraph V) (A : Set V) : Set V :=
  {v | ∀ a ∈ A, ¬ G.Adj v a}

/-- **Main structural theorem.** In a `(K₂ ∪ kK₁)`-free graph, the common
antineighbourhood of every independent set of size at least `k` is independent. -/
theorem antiNeighborhood_isIndepSet {G : SimpleGraph V} {k : ℕ}
    (hfree : IsK2UnionK1Free G k) {I : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hk : k ≤ I.card) :
    G.IsIndepSet (antiNeighborhood G (I : Set V)) := by
  refine fun v hv w hw hne => ?_
  simp only [antiNeighborhood] at hv hw
  intro hadj
  have h_exists : ∃ J : Finset V, J ⊆ I ∧ J.card = k := Finset.exists_subset_card_eq hk
  obtain ⟨J, hJI, hJcard⟩ := h_exists
  exact hfree hadj J hJcard (hI.mono (fun z hz => hJI hz))
    (fun z hz => ⟨hv z (hJI hz), hw z (hJI hz)⟩)

/-- Exact local characterization of the forbidden induced-subgraph condition. A graph is
`(K₂ ∪ kK₁)`-free precisely when the common antineighbourhood of every independent
`k`-set is independent. -/
theorem free_iff_antineighborhood_independent {G : SimpleGraph V} {k : ℕ} :
    IsK2UnionK1Free G k ↔
      ∀ I : Finset V, I.card = k → G.IsIndepSet (I : Set V) →
        G.IsIndepSet (antiNeighborhood G (I : Set V)) := by
  constructor
  · intro hfree I hcard hI
    exact antiNeighborhood_isIndepSet hfree hI hcard.ge
  · intro hlocal u v huv I hcard hI hanti
    have hu : u ∈ antiNeighborhood G (I : Set V) := by
      intro x hx
      exact (hanti x hx).1
    have hv : v ∈ antiNeighborhood G (I : Set V) := by
      intro x hx
      exact (hanti x hx).2
    exact hlocal I hcard hI hu hv huv.ne huv

/-- Set-level form of the main theorem for an independent finite set. -/
theorem no_edge_anticomplete_to_large_indepSet {G : SimpleGraph V} {k : ℕ}
    (hfree : IsK2UnionK1Free G k) {I : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hk : k ≤ I.card)
    {u v : V} (hu : u ∈ antiNeighborhood G (I : Set V))
    (hv : v ∈ antiNeighborhood G (I : Set V)) :
    ¬ G.Adj u v := by
  intro huv
  exact antiNeighborhood_isIndepSet hfree hI hk hu hv huv.ne huv

/-- If the forbidden condition holds for `k`, it also holds for every larger number
of isolated vertices. -/
theorem mono_parameter {G : SimpleGraph V} {k l : ℕ}
    (hfree : IsK2UnionK1Free G k) (hkl : k ≤ l) :
    IsK2UnionK1Free G l := by
  intro u v huv I hl hIndep hNonAdj
  -- Find a subset J of I with exactly k elements
  obtain ⟨J, hJI, hJcard⟩ := Finset.exists_subset_card_eq (hl ▸ hkl)
  apply hfree huv J hJcard
  · exact hIndep.mono hJI
  · exact fun x hx => hNonAdj x (hJI hx)

/-- For `k = 0`, the condition says exactly that the graph has no edges. -/
theorem zero_iff_bot (G : SimpleGraph V) :
    IsK2UnionK1Free G 0 ↔ G = ⊥ := by
  constructor
  · intro hfree
    ext u v
    simp only [SimpleGraph.bot_adj]
    constructor
    · intro hadj
      have := hfree hadj ∅ rfl (by simp) (by simp)
      contradiction
    · intro hv; contradiction
  · intro hG u v hadj
    simp [hG] at hadj

/-- A graph satisfying the condition for `k = 1` has an independent common
antineighbourhood for every single vertex. -/
theorem antiNeighborhood_singleton_isIndepSet [DecidableEq V] {G : SimpleGraph V}
    (hfree : IsK2UnionK1Free G 1) (a : V) :
    G.IsIndepSet (antiNeighborhood G ({a} : Set V)) := by
  simpa using antiNeighborhood_isIndepSet hfree
    (I := ({a} : Finset V)) (by simp) (by simp)

end K2UnionIndependentFree