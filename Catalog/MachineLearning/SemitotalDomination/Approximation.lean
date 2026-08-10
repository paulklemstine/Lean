import Mathlib
import MachineLearning.SemitotalDomination.Defs
import MachineLearning.SemitotalDomination.Greedy
import MachineLearning.SemitotalDomination.DiskPacking

/-!
# A verified 5-approximation for minimum semitotal domination on unit disk graphs

This file combines

* the combinatorial engine (`MachineLearning.SemitotalDomination.Greedy`): the greedy
  BFS-layered maximal independent set is a *semitotal* dominating set, and
* the geometric engine (`MachineLearning.SemitotalDomination.DiskPacking`): a closed unit disk
  cannot contain six pairwise `1`-separated points,

into the main theorem of the paper *Semitotal domination in unit disk graphs*:

> for a connected unit disk graph with at least two vertices there is a semitotal dominating set
> of size at most `5 · γ_t2(G)` (`exists_semitotalDominatingSet_card_le_five_mul`),

together with the structural consequence `γ_t2(G) ≤ 5 · γ(G)`
(`semitotalDominationNumber_le_five_mul_dominationNumber`).

The bridge between the two engines is `card_le_five_mul_card_of_dominating`:
in a unit disk graph, *every* independent set has at most `5` times as many vertices as *every*
dominating set, because each dominator can "own" at most `5` pairwise non-adjacent vertices of
its closed neighbourhood.
-/

namespace SemitotalDomination

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-- A **unit disk representation** of a graph: vertices are points of the plane (modelled as `ℂ`)
and two distinct vertices are adjacent exactly when their distance is at most `1`. -/
structure UnitDiskRep (G : SimpleGraph V) where
  /-- the position of each vertex in the plane -/
  pos : V → ℂ
  /-- adjacency is "distinct and at distance at most one" -/
  adj_iff : ∀ u v, G.Adj u v ↔ u ≠ v ∧ dist (pos u) (pos v) ≤ 1

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Non-adjacent distinct vertices of a unit disk graph are more than `1` apart. -/
lemma UnitDiskRep.one_lt_dist (rep : UnitDiskRep G) {u v : V} (hne : u ≠ v)
    (hadj : ¬ G.Adj u v) : 1 < dist (rep.pos u) (rep.pos v) := by
  by_contra h
  exact hadj ((rep.adj_iff u v).mpr ⟨hne, not_lt.mp h⟩)

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Adjacent vertices of a unit disk graph are at most `1` apart. -/
lemma UnitDiskRep.dist_le_one (rep : UnitDiskRep G) {u v : V} (hadj : G.Adj u v) :
    dist (rep.pos u) (rep.pos v) ≤ 1 := ((rep.adj_iff u v).mp hadj).2

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Independence of a `Finset`, spelled out. -/
lemma isIndepSet_iff {S : Finset V} :
    G.IsIndepSet (S : Set V) ↔ ∀ a ∈ S, ∀ b ∈ S, ¬ G.Adj a b := by
  unfold SimpleGraph.IsIndepSet Set.Pairwise
  exact ⟨fun h a ha b hb hab => h ha hb hab.ne hab, fun h a ha b hb _ hab => h a ha b hb hab⟩

omit [Fintype V] [DecidableRel G.Adj] in
/-- **Local packing bound.**  In a unit disk graph, the closed neighbourhood of a vertex contains
at most `5` pairwise non-adjacent vertices. -/
theorem card_le_five_of_indep_in_closed_nbhd (rep : UnitDiskRep G) (d : V) {I : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hd : ∀ x ∈ I, x = d ∨ G.Adj d x) : I.card ≤ 5 := by
  rw [isIndepSet_iff] at hI
  classical
  have hinj : Set.InjOn rep.pos I := by
    intro x hx y hy hxy
    by_contra hne
    have hgt := rep.one_lt_dist hne (hI x (Finset.mem_coe.mp hx) y (Finset.mem_coe.mp hy))
    rw [hxy] at hgt
    simp only [dist_self] at hgt
    linarith
  have hcard : (I.image rep.pos).card = I.card := Finset.card_image_of_injOn hinj
  rw [← hcard]
  refine card_le_five_of_pairwise_far (rep.pos d) _ ?_ ?_
  · intro p hp
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hp
    rcases hd x hx with rfl | hadj
    · simp
    · rw [dist_comm]; exact rep.dist_le_one hadj
  · intro p hp q hq hpq
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hp
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hq
    have hxy : x ≠ y := by rintro rfl; exact hpq rfl
    exact rep.one_lt_dist hxy (hI x hx y hy)

/-- The **local independence number** of a graph is bounded by `k` when no closed neighbourhood
contains more than `k` pairwise non-adjacent vertices. -/
def LocalIndependenceBound (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∀ d : V, ∀ I : Finset V, G.IsIndepSet (I : Set V) → (∀ x ∈ I, x = d ∨ G.Adj d x) → I.card ≤ k

omit [Fintype V] [DecidableRel G.Adj] in
/-- **The bridge, in general form.**  If no closed neighbourhood of `G` contains more than `k`
pairwise non-adjacent vertices, then every independent set is at most `k` times as large as
every dominating set.  (Each dominator "owns" at most `k` vertices of the independent set.) -/
theorem card_le_mul_card_of_localIndependenceBound {k : ℕ}
    (hloc : LocalIndependenceBound G k) {I D : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hD : IsDominatingSet G D) : I.card ≤ k * D.card := by
  classical
  have hex : ∀ x : V, ∃ d, d ∈ D ∧ (d = x ∨ G.Adj d x) := by
    intro x
    rcases hD x with h | ⟨d, hd, hadj⟩
    · exact ⟨x, h, Or.inl rfl⟩
    · exact ⟨d, hd, Or.inr hadj⟩
  choose f hf1 hf2 using hex
  refine Finset.card_le_mul_card_image_of_maps_to (f := f) (fun a _ => hf1 a) k ?_
  intro b _
  refine hloc b _ ?_ ?_
  · rw [isIndepSet_iff]
    rw [isIndepSet_iff] at hI
    intro a ha c hc
    exact hI a (Finset.mem_filter.mp ha).1 c (Finset.mem_filter.mp hc).1
  · intro x hx
    have hfx : f x = b := (Finset.mem_filter.mp hx).2
    rcases hf2 x with h | h
    · exact Or.inl (hfx ▸ h).symm
    · exact Or.inr (hfx ▸ h)

omit [Fintype V] [DecidableRel G.Adj] in
/-- Unit disk graphs have local independence number at most `5`. -/
theorem UnitDiskRep.localIndependenceBound (rep : UnitDiskRep G) :
    LocalIndependenceBound G 5 :=
  fun d _ hI hd => card_le_five_of_indep_in_closed_nbhd rep d hI hd

omit [Fintype V] [DecidableRel G.Adj] in
/-- **The bridge.**  In a unit disk graph every independent set is at most `5` times as large as
every dominating set. -/
theorem card_le_five_mul_card_of_dominating (rep : UnitDiskRep G) {I D : Finset V}
    (hI : G.IsIndepSet (I : Set V)) (hD : IsDominatingSet G D) : I.card ≤ 5 * D.card :=
  card_le_mul_card_of_localIndependenceBound rep.localIndependenceBound hI hD

/-- The greedy BFS maximal independent set is an independent set. -/
lemma greedyMIS_isIndepSet (r : V) : G.IsIndepSet ((greedyMIS G r : Finset V) : Set V) := by
  rw [isIndepSet_iff]
  exact greedyMIS_indep r

/-- If the greedy BFS set degenerates to `{r}`, then `r` dominates the whole graph and the pair
`{r, x}` is a semitotal dominating set of size `2` for any neighbour `x` of `r`. -/
theorem exists_pair_semitotalDominatingSet_of_singleton {r : V}
    (hsingle : greedyMIS G r = {r}) (hV : 1 < Fintype.card V) :
    ∃ S : Finset V, IsSemitotalDominatingSet G S ∧ S.card = 2 := by
  have hdom : IsDominatingSet G ({r} : Finset V) := hsingle ▸ greedyMIS_isDominatingSet r
  obtain ⟨x, hx⟩ : ∃ x : V, x ≠ r := Fintype.exists_ne_of_one_lt_card hV r
  have hadj : G.Adj r x := by
    rcases hdom x with h | ⟨d, hd, hadj⟩
    · exact absurd (Finset.mem_singleton.mp h) hx
    · rwa [Finset.mem_singleton.mp hd] at hadj
  refine ⟨{r, x}, ⟨?_, ?_⟩, ?_⟩
  · exact IsDominatingSet.mono hdom (by intro y hy; simp at hy; simp [hy])
  · intro v hv
    simp only [Finset.mem_insert, Finset.mem_singleton] at hv
    rcases hv with rfl | rfl
    · exact ⟨x, by simp, hadj.ne', Within2.of_adj hadj.symm⟩
    · exact ⟨r, by simp, hadj.ne, Within2.of_adj hadj⟩
  · rw [Finset.card_insert_of_notMem (by simpa using (Ne.symm hx)), Finset.card_singleton]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- A graph with at least one vertex has local independence number at least `1`. -/
lemma one_le_of_localIndependenceBound {k : ℕ} (hloc : LocalIndependenceBound G k) (r : V) :
    1 ≤ k := by
  have hindep : G.IsIndepSet ((({r} : Finset V)) : Set V) := by
    rw [isIndepSet_iff]
    intro a ha b hb
    simp only [Finset.mem_singleton] at ha hb
    subst ha; subst hb
    exact G.irrefl
  simpa using hloc r {r} hindep (by simp)

/-- **Guarantee for the algorithm's output, in the graph-based input model.**
The returned set `greedyMIS G r` is defined purely in terms of the abstract graph: no geometric
coordinates are used by the construction.  Only the *analysis* uses a bound on the local
independence number (for unit disk graphs, `k = 5`). -/
theorem greedyMIS_card_le_mul {k : ℕ} (hloc : LocalIndependenceBound G k) (hconn : G.Connected)
    {r : V} (hne : greedyMIS G r ≠ {r}) :
    (greedyMIS G r).card ≤ k * semitotalDominationNumber G := by
  have hS := greedyMIS_isSemitotalDominatingSet hconn r hne
  obtain ⟨T, hT, hTcard⟩ := exists_semitotal_card_eq (G := G) ⟨_, hS⟩
  rw [← hTcard]
  exact card_le_mul_card_of_localIndependenceBound hloc (greedyMIS_isIndepSet r) hT.1

/-- **Main theorem, general form.**  For a connected graph whose closed neighbourhoods contain no
more than `k` pairwise non-adjacent vertices and which has at least two vertices, the greedy BFS
algorithm returns a semitotal dominating set of size at most `k · γ_t2(G)`. -/
theorem exists_semitotalDominatingSet_card_le_mul {k : ℕ} (hloc : LocalIndependenceBound G k)
    (hconn : G.Connected) (hV : 1 < Fintype.card V) :
    ∃ S : Finset V, IsSemitotalDominatingSet G S ∧
      S.card ≤ k * semitotalDominationNumber G := by
  haveI hne : Nonempty V := Fintype.card_pos_iff.mp (by omega)
  obtain ⟨r⟩ := id hne
  have hk1 : 1 ≤ k := one_le_of_localIndependenceBound hloc r
  by_cases hsingle : greedyMIS G r = {r}
  · obtain ⟨S, hS, hcard⟩ := exists_pair_semitotalDominatingSet_of_singleton hsingle hV
    refine ⟨S, hS, ?_⟩
    have h2 : 2 ≤ semitotalDominationNumber G := two_le_semitotalDominationNumber ⟨S, hS⟩
    have := Nat.mul_le_mul hk1 h2
    omega
  · exact ⟨greedyMIS G r, greedyMIS_isSemitotalDominatingSet hconn r hsingle,
      greedyMIS_card_le_mul hloc hconn hsingle⟩

/-- **Structural corollary, general form.**  For `k ≥ 2` (note that `k = 1` genuinely fails: the
complete graph `K₂` has `γ = 1` and `γ_t2 = 2`). -/
theorem semitotalDominationNumber_le_mul_dominationNumber {k : ℕ}
    (hloc : LocalIndependenceBound G k) (hk : 2 ≤ k) (hconn : G.Connected)
    (hV : 1 < Fintype.card V) :
    semitotalDominationNumber G ≤ k * dominationNumber G := by
  have hdomne : {j | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = j}.Nonempty :=
    ⟨Finset.univ.card, Finset.univ, fun v => Or.inl (Finset.mem_univ v), rfl⟩
  obtain ⟨D, hD, hDcard⟩ := Nat.sInf_mem hdomne
  have hDcard' : D.card = dominationNumber G := hDcard
  haveI hne : Nonempty V := Fintype.card_pos_iff.mp (by omega)
  obtain ⟨r⟩ := id hne
  by_cases hsingle : greedyMIS G r = {r}
  · obtain ⟨S, hS, hcard⟩ := exists_pair_semitotalDominatingSet_of_singleton hsingle hV
    have h1 : semitotalDominationNumber G ≤ 2 := hcard ▸ semitotalDominationNumber_le_card hS
    have h2 : 1 ≤ dominationNumber G := by
      rw [← hDcard']
      rcases Finset.eq_empty_or_nonempty D with rfl | ⟨d, hd⟩
      · exact absurd (hD r) (by simp)
      · exact Finset.card_pos.mpr ⟨d, hd⟩
    have := Nat.mul_le_mul hk h2
    omega
  · have hS : IsSemitotalDominatingSet G (greedyMIS G r) :=
      greedyMIS_isSemitotalDominatingSet hconn r hsingle
    calc semitotalDominationNumber G ≤ (greedyMIS G r).card :=
          semitotalDominationNumber_le_card hS
      _ ≤ k * D.card := card_le_mul_card_of_localIndependenceBound hloc (greedyMIS_isIndepSet r) hD
      _ = k * dominationNumber G := by rw [hDcard']

/-- **Main theorem: the 5-approximation guarantee.**
For a connected unit disk graph with at least two vertices, the greedy BFS algorithm returns a
semitotal dominating set of size at most `5 · γ_t2(G)`. -/
theorem exists_semitotalDominatingSet_card_le_five_mul (rep : UnitDiskRep G)
    (hconn : G.Connected) (hV : 1 < Fintype.card V) :
    ∃ S : Finset V, IsSemitotalDominatingSet G S ∧
      S.card ≤ 5 * semitotalDominationNumber G :=
  exists_semitotalDominatingSet_card_le_mul rep.localIndependenceBound hconn hV

/-- The guarantee for the algorithm's output on unit disk graphs. -/
theorem greedyMIS_card_le_five_mul (rep : UnitDiskRep G) (hconn : G.Connected) {r : V}
    (hne : greedyMIS G r ≠ {r}) :
    (greedyMIS G r).card ≤ 5 * semitotalDominationNumber G :=
  greedyMIS_card_le_mul rep.localIndependenceBound hconn hne

/-- **Structural corollary.**  For a connected unit disk graph with at least two vertices the
semitotal domination number is at most five times the domination number. -/
theorem semitotalDominationNumber_le_five_mul_dominationNumber (rep : UnitDiskRep G)
    (hconn : G.Connected) (hV : 1 < Fintype.card V) :
    semitotalDominationNumber G ≤ 5 * dominationNumber G :=
  semitotalDominationNumber_le_mul_dominationNumber rep.localIndependenceBound (by norm_num)
    hconn hV

end SemitotalDomination