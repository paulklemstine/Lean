/-
# Bond percolation dominates site percolation on the line graph

This file settles Conjecture 5 of the previous cycle of this research thread:
on the *same* key space `Sym2 V`, the bond connection probability of a graph `G`
dominates the site connection probability of its line graph.

The comparison is carried out on `Sym2 V` rather than on the subtype
`G.edgeSet` used by Mathlib's `SimpleGraph.lineGraph`, so that the two
percolation models literally share their index type and their Bernoulli
measure; `lineGraphSym2_adj_iff` identifies the two adjacency relations on
edges of `G`.

The domination is in fact *pointwise in the configuration*: an open line-graph
site path from an edge `e` to an edge `f` is, read in `G`, a chain of pairwise
incident open edges, hence an open bond path between any endpoint of `e` and any
endpoint of `f`.  The probabilistic statement then follows from monotonicity of
`bernProb` under inclusion of events, and the same inclusion transfers verbatim
to the uniform key coupling, where one family of keys drives both models at once.

Finally the domination is shown to be *strict* on the triangle, so it is not an
identity: two vertices can be bond connected around a closed edge, while the
line-graph site path from that edge to itself needs the edge itself.

## Main results

* `lineGraphSym2`, `lineGraphSym2_adj_iff`: the line graph carried on `Sym2 V`
  and its identification with `SimpleGraph.lineGraph`.
* `bondConnected_of_siteConnected_lineGraphSym2`: the pointwise domination.
* `bernProb_site_lineGraph_le_bond`: **Conjecture 5**.
* `keyMeasure_site_lineGraph_le_bond`: the same for the uniform key coupling.
* `bernProb_site_lineGraph_lt_bond_triangle`: strictness on the triangle.
-/

import Logic.BKInequalityBernoulli

open Finset Cryptography.PercolationThresholdCoupling

namespace BernoulliThresholdCoupling

/-! ## Monotonicity of `bernProb` in the event -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- `bernProb` is monotone under inclusion of events. -/
theorem bernProb_mono_subset {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A B : Set (ι → Bool)}
    (hAB : A ⊆ B) : bernProb p A ≤ bernProb p B := by
  refine Finset.sum_le_sum fun η _ => ?_
  by_cases h : η ∈ A
  · rw [Set.indicator_of_mem h, Set.indicator_of_mem (hAB h)]
  · rw [Set.indicator_of_notMem h]
    exact Set.indicator_nonneg (fun x _ => weight_nonneg hp0 hp1 x) η

/-- Strict monotonicity of `bernProb` under inclusion, witnessed by a single
omitted configuration, at densities in `(0,1)`. -/
theorem bernProb_lt_of_subset {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) {A B : Set (ι → Bool)}
    (hAB : A ⊆ B) {η : ι → Bool} (hηB : η ∈ B) (hηA : η ∉ A) :
    bernProb p A < bernProb p B := by
  classical
  have hterm : ∀ ξ ∈ (univ : Finset (ι → Bool)),
      A.indicator (weight p) ξ ≤ B.indicator (weight p) ξ := by
    intro ξ _
    by_cases h : ξ ∈ A
    · rw [Set.indicator_of_mem h, Set.indicator_of_mem (hAB h)]
    · rw [Set.indicator_of_notMem h]
      exact Set.indicator_nonneg (fun x _ => weight_nonneg hp0.le hp1.le x) ξ
  have hstrict : A.indicator (weight p) η < B.indicator (weight p) η := by
    rw [Set.indicator_of_notMem hηA, Set.indicator_of_mem hηB]
    exact weight_pos hp0 hp1 η
  exact Finset.sum_lt_sum hterm ⟨η, Finset.mem_univ η, hstrict⟩

/-! ## The line graph on `Sym2 V` -/

variable {V : Type*}

/-- The line graph of `G`, carried on the whole of `Sym2 V`: two edges of `G`
are adjacent when they are distinct and share an endpoint.  Elements of
`Sym2 V` that are not edges of `G` are isolated. -/
def lineGraphSym2 (G : SimpleGraph V) : SimpleGraph (Sym2 V) where
  Adj e f := e ≠ f ∧ e ∈ G.edgeSet ∧ f ∈ G.edgeSet ∧ ∃ w, w ∈ e ∧ w ∈ f
  symm := by
    rintro e f ⟨hne, he, hf, w, hwe, hwf⟩
    exact ⟨hne.symm, hf, he, w, hwf, hwe⟩
  loopless := by
    constructor
    rintro e ⟨hne, -⟩
    exact hne rfl

/-- On edges of `G` this is Mathlib's line graph. -/
theorem lineGraphSym2_adj_iff {G : SimpleGraph V} {e f : G.edgeSet} :
    (lineGraphSym2 G).Adj (e : Sym2 V) (f : Sym2 V) ↔ (G.lineGraph).Adj e f := by
  rw [SimpleGraph.lineGraph_adj_iff_exists]
  constructor
  · rintro ⟨hne, -, -, w, hwe, hwf⟩
    exact ⟨fun h => hne (congrArg Subtype.val h), w, hwe, hwf⟩
  · rintro ⟨hne, w, hwe, hwf⟩
    exact ⟨fun h => hne (Subtype.ext h), e.2, f.2, w, hwe, hwf⟩

/-! ## Pointwise domination -/

/-- Bond connectivity is reflexive. -/
theorem bondConnected_refl (G : SimpleGraph V) (ω : Sym2 V → Bool) (u : V) :
    BondConnected G ω u u :=
  ⟨SimpleGraph.Walk.nil, by simp⟩

/-- Bond connectivity is transitive. -/
theorem bondConnected_trans {G : SimpleGraph V} {ω : Sym2 V → Bool} {u w v : V}
    (h₁ : BondConnected G ω u w) (h₂ : BondConnected G ω w v) : BondConnected G ω u v := by
  obtain ⟨p, hp⟩ := h₁
  obtain ⟨q, hq⟩ := h₂
  refine ⟨p.append q, fun e he => ?_⟩
  rw [SimpleGraph.Walk.edges_append, List.mem_append] at he
  rcases he with he | he
  · exact hp e he
  · exact hq e he

/-- Both endpoints of a single open edge are bond connected. -/
theorem bondConnected_of_mem_edge {G : SimpleGraph V} {ω : Sym2 V → Bool} {e : Sym2 V}
    (he : e ∈ G.edgeSet) (hopen : ω e = true) {u v : V} (hu : u ∈ e) (hv : v ∈ e) :
    BondConnected G ω u v := by
  induction e with
  | _ a b =>
    rw [Sym2.mem_iff] at hu hv
    have hadj : G.Adj a b := by rwa [SimpleGraph.mem_edgeSet] at he
    rcases hu with rfl | rfl <;> rcases hv with rfl | rfl
    · exact bondConnected_refl G ω _
    · exact ⟨SimpleGraph.Walk.cons hadj SimpleGraph.Walk.nil, by simpa using hopen⟩
    · exact ⟨SimpleGraph.Walk.cons hadj.symm SimpleGraph.Walk.nil,
        by simpa [Sym2.eq_swap] using hopen⟩
    · exact bondConnected_refl G ω _

/-- The recursion behind the pointwise domination: an open line-graph walk is a
chain of pairwise incident open edges of `G`. -/
theorem bondConnected_of_walk_lineGraphSym2 {G : SimpleGraph V} {ω : Sym2 V → Bool} {v : V}
    (e f : Sym2 V) (p : (lineGraphSym2 G).Walk e f) :
    (∀ x ∈ p.support, ω x = true) → e ∈ G.edgeSet → v ∈ f → ∀ u ∈ e,
      BondConnected G ω u v := by
  induction p with
  | nil =>
    intro hp he hv u hu
    exact bondConnected_of_mem_edge he (hp _ (by simp)) hu hv
  | cons hadj q ih =>
    intro hp he hv u hu
    have hg : _ ∈ G.edgeSet := hadj.2.2.1
    obtain ⟨w, hwe, hwg⟩ := hadj.2.2.2
    refine bondConnected_trans
      (bondConnected_of_mem_edge he (hp _ (by simp)) hu hwe) (ih (fun x hx => ?_) hg hv w hwg)
    exact hp x (by rw [SimpleGraph.Walk.support_cons]; exact List.mem_cons_of_mem _ hx)

/-- **Pointwise bond–site domination.**  An open site path in the line graph
from the edge `e` to the edge `f` yields an open bond path in `G` between any
endpoint of `e` and any endpoint of `f`. -/
theorem bondConnected_of_siteConnected_lineGraphSym2 {G : SimpleGraph V} {ω : Sym2 V → Bool}
    {e f : Sym2 V} (he : e ∈ G.edgeSet) (hconn : SiteConnected (lineGraphSym2 G) ω e f)
    {u v : V} (hu : u ∈ e) (hv : v ∈ f) : BondConnected G ω u v := by
  obtain ⟨p, hp⟩ := hconn
  exact bondConnected_of_walk_lineGraphSym2 e f p hp he hv u hu

/-- The line-graph site connection event is contained in the bond connection
event. -/
theorem siteConnected_lineGraph_subset_bondConnected {G : SimpleGraph V} {e f : Sym2 V}
    (he : e ∈ G.edgeSet) {u v : V} (hu : u ∈ e) (hv : v ∈ f) :
    {ω : Sym2 V → Bool | SiteConnected (lineGraphSym2 G) ω e f} ⊆
      {ω : Sym2 V → Bool | BondConnected G ω u v} :=
  fun _ hω => bondConnected_of_siteConnected_lineGraphSym2 he hω hu hv

/-! ## The probabilistic domination -/

/-- **Bond–site domination on the same key space.**  For every density `p` the
bond connection probability of `G` dominates the site connection probability of
the line graph of `G`, both computed for the Bernoulli measure on `Sym2 V`. -/
theorem bernProb_site_lineGraph_le_bond [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {e f : Sym2 V} (he : e ∈ G.edgeSet)
    {u v : V} (hu : u ∈ e) (hv : v ∈ f) :
    bernProb p {ω : Sym2 V → Bool | SiteConnected (lineGraphSym2 G) ω e f} ≤
      bernProb p {ω : Sym2 V → Bool | BondConnected G ω u v} :=
  bernProb_mono_subset hp0 hp1 (siteConnected_lineGraph_subset_bondConnected he hu hv)

/-- **Bond–site domination for the uniform key coupling.**  A single family of
uniform keys drives both models; the bond event then contains the line-graph
site event key by key. -/
theorem keyMeasure_site_lineGraph_le_bond [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    (p : ℝ) {e f : Sym2 V} (he : e ∈ G.edgeSet) {u v : V} (hu : u ∈ e) (hv : v ∈ f) :
    keyMeasure (Sym2 V)
        {key | SiteConnected (lineGraphSym2 G) (siteThresholdConfig key p) e f} ≤
      keyMeasure (Sym2 V) {key | BondConnected G (siteThresholdConfig key p) u v} :=
  MeasureTheory.measure_mono
    (fun _ hkey => bondConnected_of_siteConnected_lineGraphSym2 he hkey hu hv)

/-! ## Strictness on the triangle -/

/-- The configuration on the triangle that closes the edge `s(0,1)` and opens
the other two. -/
def triangleGap : Sym2 (Fin 3) → Bool := fun x => if x = s(0, 1) then false else true

theorem triangleGap_bondConnected :
    BondConnected (⊤ : SimpleGraph (Fin 3)) triangleGap 0 1 := by
  refine ⟨SimpleGraph.Walk.cons (show (⊤ : SimpleGraph (Fin 3)).Adj 0 2 by decide)
    (SimpleGraph.Walk.cons (show (⊤ : SimpleGraph (Fin 3)).Adj 2 1 by decide)
      SimpleGraph.Walk.nil), ?_⟩
  intro e he
  simp only [SimpleGraph.Walk.edges_cons, SimpleGraph.Walk.edges_nil, List.mem_cons,
    List.not_mem_nil, or_false] at he
  rcases he with rfl | rfl
  · decide
  · decide

theorem triangleGap_not_siteConnected :
    ¬ SiteConnected (lineGraphSym2 (⊤ : SimpleGraph (Fin 3))) triangleGap s(0, 1) s(0, 1) := by
  rintro ⟨p, hp⟩
  have h := hp _ p.start_mem_support
  simp [triangleGap] at h

/-- **The domination is strict.**  On the triangle, two vertices are bond
connected around a closed edge, while the line-graph site event from that edge
to itself requires the edge to be open. -/
theorem bernProb_site_lineGraph_lt_bond_triangle {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) :
    bernProb p {ω : Sym2 (Fin 3) → Bool |
        SiteConnected (lineGraphSym2 (⊤ : SimpleGraph (Fin 3))) ω s(0, 1) s(0, 1)} <
      bernProb p {ω : Sym2 (Fin 3) → Bool |
        BondConnected (⊤ : SimpleGraph (Fin 3)) ω 0 1} := by
  refine bernProb_lt_of_subset hp0 hp1
    (siteConnected_lineGraph_subset_bondConnected (e := s(0, 1)) (f := s(0, 1))
      (by decide) (by simp) (by simp))
    triangleGap_bondConnected triangleGap_not_siteConnected

end BernoulliThresholdCoupling