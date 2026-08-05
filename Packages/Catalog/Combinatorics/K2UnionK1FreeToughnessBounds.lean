import Mathlib
import Bridges.GraphTheory.K2UnionIndependentFree
import Combinatorics.K2UnionK1FreeInvariants

/-!
# Quantitative toughness bounds for finite graphs and `(K₂ ∪ kK₁)`-free graphs

This file continues `Combinatorics.K2UnionK1FreeInvariants`, where the toughness
predicates `ToughAtLeast G t` (`τ(G) ≥ t`) and `ToughGreaterThan G t` (`τ(G) > t`) and the
component counter `compCount` were introduced, and where the special case `t = 1` of
several inequalities was proved.

Here every one of those inequalities is proved for an arbitrary rational parameter `t`:

* **Separators and connectivity.** `compCount_le_one_of_ncard_lt_two_mul`: a vertex set of
  size smaller than `2t` cannot disconnect a graph with `τ(G) ≥ t`. With the predicate
  `VertexConnAtLeast G k` (`κ(G) ≥ k`) this becomes
  `vertexConnAtLeast_of_toughAtLeast`, the classical bound `κ(G) ≥ 2τ(G)`.
* **Degrees.** `two_mul_lt_degree_of_toughGreaterThan` and
  `two_mul_le_degree_of_toughAtLeast`: `δ(G) > 2t` when `τ(G) > t`, and `δ(G) ≥ 2t` when
  `τ(G) ≥ t`, on a graph with more than `2t + 1` vertices. The corollary
  `floor_two_mul_lt_minDegree` is the integral form `δ(G) ≥ ⌊2t⌋ + 1`.
* **Independence number.** `succ_mul_ncard_isIndepSet_lt` and `succ_mul_indepNum_lt`:
  `(t + 1)·α(G) < |V(G)|` when `τ(G) > t`, generalizing `2·α(G) < |V(G)|`.
* **Freeness.** `succ_mul_ncard_antiNeighborhood_lt`: in a `(K₂ ∪ kK₁)`-free graph with
  `τ(G) > t`, the common antineighbourhood of any independent set of size at least `k`
  has fewer than `|V(G)|/(t+1)` vertices.
* **Complete graphs.** `toughAtLeast_top` and `toughGreaterThan_top` confirm that the
  chosen conventions really do give `τ(Kₙ) = ∞`; small explicit graphs are used as
  regression tests at the end of the file.
-/

open Finset SimpleGraph K2UnionIndependentFree K2UnionK1FreeInvariants

namespace K2UnionK1FreeToughnessBounds

variable {V : Type*}

/-! ## Separators, connectivity and toughness -/

/-- **Separator bound.** In a graph with `τ(G) ≥ t` no vertex set of size smaller than
`2t` can leave two or more components behind. -/
theorem compCount_le_one_of_ncard_lt_two_mul {G : SimpleGraph V} {t : ℚ} (ht : 0 ≤ t)
    (h : ToughAtLeast G t) {S : Set V} (hS : (S.ncard : ℚ) < 2 * t) :
    compCount G S ≤ 1 := by
  by_contra hc
  push_neg at hc
  have h2 : 2 ≤ compCount G S := hc
  have hle := h S h2
  have hc2 : (2 : ℚ) ≤ (compCount G S : ℚ) := by exact_mod_cast h2
  nlinarith [mul_le_mul_of_nonneg_left hc2 ht]

/-- `VertexConnAtLeast G k` says `κ(G) ≥ k`: the graph has more than `k` vertices and no
set of fewer than `k` vertices disconnects it. -/
def VertexConnAtLeast (G : SimpleGraph V) (k : ℕ) : Prop :=
  k < Nat.card V ∧ ∀ S : Set V, S.ncard < k → compCount G S ≤ 1

/-- A `1`-connected graph is connected. -/
theorem connected_of_vertexConnAtLeast [Finite V] {G : SimpleGraph V} {k : ℕ} (hk : 1 ≤ k)
    (h : VertexConnAtLeast G k) : G.Connected := by
  have hpos : 0 < Nat.card V := lt_of_le_of_lt (Nat.zero_le k) h.1
  have : Nonempty V := (Nat.card_pos_iff.mp hpos).1
  refine connected_of_compCount_empty_le_one ?_
  exact h.2 ∅ (by rw [Set.ncard_empty]; omega)

/-- Connectivity is monotone in its parameter. -/
theorem VertexConnAtLeast.mono {G : SimpleGraph V} {k l : ℕ} (h : VertexConnAtLeast G k)
    (hlk : l ≤ k) : VertexConnAtLeast G l :=
  ⟨lt_of_le_of_lt (by exact_mod_cast hlk) h.1, fun S hS => h.2 S (lt_of_lt_of_le hS hlk)⟩

/-- **`κ(G) ≥ 2τ(G)`.** A graph with `τ(G) ≥ t` and more than `k` vertices is
`k`-connected for every `k ≤ 2t`. -/
theorem vertexConnAtLeast_of_toughAtLeast {G : SimpleGraph V} {t : ℚ} {k : ℕ} (ht : 0 ≤ t)
    (h : ToughAtLeast G t) (hk : (k : ℚ) ≤ 2 * t) (hcard : k < Nat.card V) :
    VertexConnAtLeast G k :=
  ⟨hcard, fun S hS => by
    refine compCount_le_one_of_ncard_lt_two_mul ht h ?_
    have : (S.ncard : ℚ) < (k : ℚ) := by exact_mod_cast hS
    linarith⟩

/-! ## Degree bounds -/

/-- **Degree bound from `τ(G) > t`.** Every vertex of a graph with `τ(G) > t` and more
than `2t + 1` vertices has degree greater than `2t`. -/
theorem two_mul_lt_degree_of_toughGreaterThan [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] {t : ℚ} (ht : 0 ≤ t) (h : ToughGreaterThan G t)
    (hcard : 2 * t + 1 < (Fintype.card V : ℚ)) (v : V) : 2 * t < (G.degree v : ℚ) := by
  classical
  by_cases hall : ∀ y, y ≠ v → G.Adj v y
  · have hsub : Finset.univ.erase v ⊆ G.neighborFinset v := by
      intro y hy
      rw [Finset.mem_erase] at hy
      simpa using hall y hy.1
    have hcard2 := Finset.card_le_card hsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ,
      SimpleGraph.card_neighborFinset_eq_degree] at hcard2
    have hnat : Fintype.card V ≤ G.degree v + 1 := by omega
    have : (Fintype.card V : ℚ) ≤ (G.degree v : ℚ) + 1 := by exact_mod_cast hnat
    linarith
  · push_neg at hall
    obtain ⟨y, hy, hadj⟩ := hall
    have h2 := two_le_compCount_neighborSet hy hadj
    have hlt := h _ h2
    rw [ncard_neighborSet v] at hlt
    have hc2 : (2 : ℚ) ≤ (compCount G (G.neighborSet v) : ℚ) := by exact_mod_cast h2
    nlinarith [mul_le_mul_of_nonneg_left hc2 ht]

/-- **Degree bound from `τ(G) ≥ t`.** Every vertex of a graph with `τ(G) ≥ t` and at least
`2t + 1` vertices has degree at least `2t`. -/
theorem two_mul_le_degree_of_toughAtLeast [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] {t : ℚ} (ht : 0 ≤ t) (h : ToughAtLeast G t)
    (hcard : 2 * t + 1 ≤ (Fintype.card V : ℚ)) (v : V) : 2 * t ≤ (G.degree v : ℚ) := by
  classical
  by_cases hall : ∀ y, y ≠ v → G.Adj v y
  · have hsub : Finset.univ.erase v ⊆ G.neighborFinset v := by
      intro y hy
      rw [Finset.mem_erase] at hy
      simpa using hall y hy.1
    have hcard2 := Finset.card_le_card hsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ,
      SimpleGraph.card_neighborFinset_eq_degree] at hcard2
    have hnat : Fintype.card V ≤ G.degree v + 1 := by omega
    have : (Fintype.card V : ℚ) ≤ (G.degree v : ℚ) + 1 := by exact_mod_cast hnat
    linarith
  · push_neg at hall
    obtain ⟨y, hy, hadj⟩ := hall
    have h2 := two_le_compCount_neighborSet hy hadj
    have hle := h _ h2
    rw [ncard_neighborSet v] at hle
    have hc2 : (2 : ℚ) ≤ (compCount G (G.neighborSet v) : ℚ) := by exact_mod_cast h2
    nlinarith [mul_le_mul_of_nonneg_left hc2 ht]

/-- Minimum-degree form of `two_mul_lt_degree_of_toughGreaterThan`. -/
theorem two_mul_lt_minDegree_of_toughGreaterThan [Fintype V] {G : SimpleGraph V}
    [DecidableRel G.Adj] {t : ℚ} (ht : 0 ≤ t) (h : ToughGreaterThan G t)
    (hcard : 2 * t + 1 < (Fintype.card V : ℚ)) : 2 * t < (G.minDegree : ℚ) := by
  have hpos : (0 : ℚ) < (Fintype.card V : ℚ) := by linarith
  have hne : Nonempty V := by
    refine Fintype.card_pos_iff.mp ?_
    exact_mod_cast hpos
  obtain ⟨v, hv⟩ := G.exists_minimal_degree_vertex
  rw [hv]
  exact two_mul_lt_degree_of_toughGreaterThan ht h hcard v

/-- **Integral degree bound.** A graph with `τ(G) > t ≥ 0` and more than `2t + 1` vertices
has minimum degree at least `⌊2t⌋ + 1`. -/
theorem floor_two_mul_lt_minDegree [Fintype V] {G : SimpleGraph V} [DecidableRel G.Adj]
    {t : ℚ} (ht : 0 ≤ t) (h : ToughGreaterThan G t)
    (hcard : 2 * t + 1 < (Fintype.card V : ℚ)) : ⌊2 * t⌋ < (G.minDegree : ℤ) := by
  have h1 := two_mul_lt_minDegree_of_toughGreaterThan ht h hcard
  have h2 : ((⌊2 * t⌋ : ℤ) : ℚ) ≤ 2 * t := Int.floor_le _
  have h3 : ((⌊2 * t⌋ : ℤ) : ℚ) < (((G.minDegree : ℤ)) : ℚ) := by push_cast; linarith
  exact_mod_cast h3

/-! ## Independence number -/

/-- **Independence bound.** If `τ(G) > t ≥ 0` and `|V(G)| > t + 1`, then every independent
set `A` satisfies `(t + 1)·|A| < |V(G)|`. -/
theorem succ_mul_ncard_isIndepSet_lt [Fintype V] {G : SimpleGraph V} {t : ℚ} (ht : 0 ≤ t)
    (h : ToughGreaterThan G t) (hcard : t + 1 < (Fintype.card V : ℚ)) {A : Set V}
    (hA : G.IsIndepSet A) : (t + 1) * (A.ncard : ℚ) < (Fintype.card V : ℚ) := by
  rcases le_or_gt A.ncard 1 with hle | hgt
  · have h1 : (A.ncard : ℚ) ≤ 1 := by exact_mod_cast hle
    have h0 : (0 : ℚ) ≤ (A.ncard : ℚ) := Nat.cast_nonneg _
    nlinarith
  · have h2 : 2 ≤ compCount G Aᶜ := by rw [compCount_compl_isIndepSet hA]; omega
    have hlt := h Aᶜ h2
    rw [compCount_compl_isIndepSet hA] at hlt
    have hsum : A.ncard + Aᶜ.ncard = Nat.card V := Set.ncard_add_ncard_compl A
    rw [Nat.card_eq_fintype_card] at hsum
    have hsumq : (A.ncard : ℚ) + (Aᶜ.ncard : ℚ) = (Fintype.card V : ℚ) := by
      exact_mod_cast hsum
    linarith

/-- **Independence-number bound.** `τ(G) > t ≥ 0` and `|V(G)| > t + 1` imply
`(t + 1)·α(G) < |V(G)|`. -/
theorem succ_mul_indepNum_lt [Fintype V] {G : SimpleGraph V} {t : ℚ} (ht : 0 ≤ t)
    (h : ToughGreaterThan G t) (hcard : t + 1 < (Fintype.card V : ℚ)) :
    (t + 1) * (G.indepNum : ℚ) < (Fintype.card V : ℚ) := by
  obtain ⟨s, hs, hscard⟩ := G.exists_isNIndepSet_indepNum
  have := succ_mul_ncard_isIndepSet_lt ht h hcard hs
  rwa [Set.ncard_coe_finset, hscard] at this

/-! ## Interaction with `(K₂ ∪ kK₁)`-freeness -/

/-- In a `(K₂ ∪ kK₁)`-free graph with `τ(G) > t ≥ 0` and `|V(G)| > t + 1`, the common
antineighbourhood of every independent set of size at least `k` has fewer than
`|V(G)|/(t+1)` vertices. -/
theorem succ_mul_ncard_antiNeighborhood_lt [Fintype V] {G : SimpleGraph V} {k : ℕ} {t : ℚ}
    (hfree : IsK2UnionK1Free G k) (ht : 0 ≤ t) (h : ToughGreaterThan G t)
    (hcard : t + 1 < (Fintype.card V : ℚ)) {I : Finset V} (hI : G.IsIndepSet (I : Set V))
    (hk : k ≤ I.card) :
    (t + 1) * ((antiNeighborhood G (I : Set V)).ncard : ℚ) < (Fintype.card V : ℚ) :=
  succ_mul_ncard_isIndepSet_lt ht h hcard (antiNeighborhood_isIndepSet hfree hI hk)

/-- In a `(K₂ ∪ kK₁)`-free graph with `τ(G) > t ≥ 0`, an independent set of size at least
`k` dominates more than `t/(t+1)` of all the vertices. -/
theorem lt_mul_ncard_hasNeighbor [Fintype V] {G : SimpleGraph V} {k : ℕ} {t : ℚ}
    (hfree : IsK2UnionK1Free G k) (ht : 0 ≤ t) (h : ToughGreaterThan G t)
    (hcard : t + 1 < (Fintype.card V : ℚ)) {I : Finset V} (hI : G.IsIndepSet (I : Set V))
    (hk : k ≤ I.card) :
    t * (Fintype.card V : ℚ) < (t + 1) * ({v : V | ∃ x ∈ I, G.Adj v x}.ncard : ℚ) := by
  have hcompl : {v : V | ∃ x ∈ I, G.Adj v x} = (antiNeighborhood G (I : Set V))ᶜ := by
    ext v
    simp [antiNeighborhood, Set.mem_compl_iff]
  have hsum : (antiNeighborhood G (I : Set V)).ncard
      + (antiNeighborhood G (I : Set V))ᶜ.ncard = Nat.card V :=
    Set.ncard_add_ncard_compl _
  rw [Nat.card_eq_fintype_card] at hsum
  have hsumq : ((antiNeighborhood G (I : Set V)).ncard : ℚ)
      + ((antiNeighborhood G (I : Set V))ᶜ.ncard : ℚ) = (Fintype.card V : ℚ) := by
    exact_mod_cast hsum
  have hlt := succ_mul_ncard_antiNeighborhood_lt hfree ht h hcard hI hk
  have hexp : (t + 1) * ((antiNeighborhood G (I : Set V)).ncard : ℚ)
      + (t + 1) * ((antiNeighborhood G (I : Set V))ᶜ.ncard : ℚ)
      = (t + 1) * (Fintype.card V : ℚ) := by
    rw [← mul_add, hsumq]
  have hring : (t + 1) * (Fintype.card V : ℚ) = t * (Fintype.card V : ℚ)
      + (Fintype.card V : ℚ) := by ring
  rw [hcompl]
  linarith

/-! ## Complete graphs: the convention `τ(Kₙ) = ∞` -/

/-- After deleting any set of vertices from a complete graph at most one component
remains. -/
theorem compCount_top_le_one [Finite V] (S : Set V) :
    compCount (⊤ : SimpleGraph V) S ≤ 1 := by
  unfold compCount
  refine Finite.card_le_one_iff_subsingleton.mpr ⟨fun c d => ?_⟩
  induction c using SimpleGraph.ConnectedComponent.ind with
  | _ x =>
    induction d using SimpleGraph.ConnectedComponent.ind with
    | _ y =>
      refine SimpleGraph.ConnectedComponent.sound ?_
      rcases eq_or_ne x y with rfl | hne
      · exact SimpleGraph.Reachable.refl _
      · exact SimpleGraph.Adj.reachable (by simpa using hne)

/-- Complete graphs satisfy `τ(G) ≥ t` for every `t`: the convention `τ(Kₙ) = ∞`. -/
theorem toughAtLeast_top [Finite V] (t : ℚ) : ToughAtLeast (⊤ : SimpleGraph V) t := by
  intro S hS
  exfalso
  have := compCount_top_le_one (V := V) S
  omega

/-- Complete graphs satisfy `τ(G) > t` for every `t`. -/
theorem toughGreaterThan_top [Finite V] (t : ℚ) :
    ToughGreaterThan (⊤ : SimpleGraph V) t := by
  intro S hS
  exfalso
  have := compCount_top_le_one (V := V) S
  omega

/-! ## Regression tests -/

/-- Sanity check for `vertexConnAtLeast_of_toughAtLeast`: the complete graph on five
vertices is `4`-connected. -/
theorem top_fin_five_vertexConnAtLeast_four :
    VertexConnAtLeast (⊤ : SimpleGraph (Fin 5)) 4 :=
  ⟨by simp [Nat.card_eq_fintype_card], fun S _ => compCount_top_le_one S⟩

/-- Sanity check for the degree bound: `K₅` has minimum degree `4 > 2·(3/2)`, as predicted
by `two_mul_lt_minDegree_of_toughGreaterThan` applied with `t = 3/2`. -/
theorem top_fin_five_minDegree : (⊤ : SimpleGraph (Fin 5)).minDegree = 4 := by
  decide

/-- The five-cycle is not `τ > 1`-tough (already known), and indeed the general degree
bound is tight for it: `δ(C₅) = 2 = 2·1`, so `C₅` satisfies the conclusion of
`two_mul_le_degree_of_toughAtLeast` with `t = 1` with equality. -/
theorem cycleGraph_five_minDegree : (cycleGraph 5).minDegree = 2 := by
  decide

end K2UnionK1FreeToughnessBounds