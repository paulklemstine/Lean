import Mathlib
import MachineLearning.SemitotalDomination.BallPacking

/-!
# The domination–packing ratio `γ(G)/ρ(G)`

This file formalizes the *combinatorial and geometric core* of the Erdős–Pósa style question
studied in the paper *Domination-packing ratio for planar and unit disk graphs*:

> how large can `γ(G)/ρ(G)` be, where `γ` is the domination number (a transversal of the
> hypergraph of radius-`1` balls) and `ρ` is the packing number (a matching of the same
> hypergraph)?

We work with the catalog's own graph-theoretic vocabulary: `IsDominatingSet` / `dominationNumber`
(from `Novelty.TransmissionDominationTree`) and the unit disk / unit ball representations
`UnitDiskRep`, `UnitBallRep` (from `MachineLearning.SemitotalDomination.*`).

## Main results

* `ball`, `IsPacking`, `packingNumber` — the radius-`1` ball hypergraph and its matching number.
* `packingNumber_le_dominationNumber` — the trivial direction `ρ ≤ γ` of the duality
  (a transversal must hit each of the pairwise disjoint balls of a packing, injectively).
* `dominationNumber_le_mul_packingNumber` — **the engine**: if every "radius-2 neighbourhood"
  `{u | the balls of u and p meet}` can be dominated by at most `c` vertices, then `γ ≤ c · ρ`.
  The proof takes a *maximum* packing `P`, which is necessarily *maximal*, so the radius-2
  neighbourhoods of `P` cover `V`.
* `dominationNumber_le_maxDegree_succ_mul_packingNumber` — `γ ≤ (Δ+1)·ρ` for every finite graph
  (the closed neighbourhood of `p` dominates everything at distance `≤ 2` from `p`).
* `MetricRep`, `LocalPackingBound`, `dominationNumber_le_mul_packingNumber_of_metricRep` — the
  abstract geometric form: if `G` is represented by points of a metric space `X` (adjacency =
  "distinct and at distance at most `1`") and no ball of radius `2` of `X` contains more than
  `N` points pairwise more than `1` apart, then `γ ≤ N·ρ`.
* `dominationNumber_le_25_mul_packingNumber` — **`γ ≤ 25·ρ` for every unit disk graph**: a
  maximal independent subset of the radius-2 neighbourhood of `p` consists of points pairwise
  more than `1` apart inside a disk of radius `2`, so a Haar-measure volume count bounds it by
  `((2·2+1)/1)² = 25`.  This is a fully verified, quantitatively weaker version of the paper's
  bound `18√3/π ≈ 9.924`.
* `dominationNumber_le_five_pow_mul_packingNumber` — the same argument in `ℝⁿ`: `γ ≤ 5ⁿ·ρ` for
  unit ball graphs in `ℝⁿ` (for `n = 2` it re-derives the constant `25`).
* `wagner_domination_eq_three_mul_packing` — the **Wagner graph** `V₈` (the `8`-cycle plus its
  four main diagonals) satisfies `γ = 3`, `ρ = 1`, so the optimal constant in *any* such
  Erdős–Pósa bound is at least `3`, matching the best lower bound quoted in the paper.
* `cycle4_domination_eq_two_mul_packing` together with `cycle4_unitDiskRep` — the `4`-cycle is a
  unit disk graph with `γ = 2`, `ρ = 1`, so for unit disk graphs the optimal constant lies in
  the verified interval `[2, 25]`.
-/

namespace DominationPacking

open Finset SemitotalDomination

variable {V : Type*}

/-! ## The radius-`1` ball hypergraph -/

/-- The radius-`1` ball (closed neighbourhood) of `v`. -/
def ball (G : SimpleGraph V) (v : V) : Set V := {u | u = v ∨ G.Adj v u}

lemma mem_ball_iff {G : SimpleGraph V} {u v : V} : u ∈ ball G v ↔ u = v ∨ G.Adj v u := Iff.rfl

lemma mem_ball_self (G : SimpleGraph V) (v : V) : v ∈ ball G v := Or.inl rfl

/-- A **packing**: a set of vertices whose radius-`1` balls are pairwise disjoint. -/
def IsPacking (G : SimpleGraph V) (P : Finset V) : Prop :=
  ∀ u ∈ P, ∀ v ∈ P, u ≠ v → Disjoint (ball G u) (ball G v)

/-- The **packing number** `ρ(G)`: the largest number of pairwise disjoint radius-`1` balls. -/
noncomputable def packingNumber [Fintype V] (G : SimpleGraph V) : ℕ :=
  sSup {k | ∃ P : Finset V, IsPacking G P ∧ P.card = k}

lemma packingSet_nonempty [Fintype V] (G : SimpleGraph V) :
    {k | ∃ P : Finset V, IsPacking G P ∧ P.card = k}.Nonempty :=
  ⟨0, ∅, by simp [IsPacking], rfl⟩

lemma packingSet_bddAbove [Fintype V] (G : SimpleGraph V) :
    BddAbove {k | ∃ P : Finset V, IsPacking G P ∧ P.card = k} := by
  refine ⟨Fintype.card V, ?_⟩
  rintro k ⟨P, -, rfl⟩
  simpa using Finset.card_le_univ P

/-- Every packing is at most as large as the packing number. -/
lemma card_le_packingNumber [Fintype V] {G : SimpleGraph V} {P : Finset V} (hP : IsPacking G P) :
    P.card ≤ packingNumber G :=
  le_csSup (packingSet_bddAbove G) ⟨P, hP, rfl⟩

/-- The packing number is attained. -/
lemma exists_packing_card_eq [Fintype V] (G : SimpleGraph V) :
    ∃ P : Finset V, IsPacking G P ∧ P.card = packingNumber G := by
  obtain ⟨P, hP, hcard⟩ := Nat.sSup_mem (packingSet_nonempty G) (packingSet_bddAbove G)
  exact ⟨P, hP, hcard⟩

lemma one_le_packingNumber [Fintype V] [Nonempty V] (G : SimpleGraph V) :
    1 ≤ packingNumber G := by
  classical
  obtain ⟨v⟩ := ‹Nonempty V›
  have : IsPacking G {v} := by
    intro a ha b hb hab
    simp only [Finset.mem_singleton] at ha hb
    exact absurd (ha.trans hb.symm) hab
  simpa using card_le_packingNumber this

/-! ## Balls meet exactly at graph distance at most two

This identifies our definitions with the textbook ones: a packing is a set of vertices that are
pairwise at distance at least `3` (a *2-packing*), and the hypothesis of the engine below
concerns exactly the radius-`2` neighbourhoods.  `Within2` is the catalog's combinatorial
"distance at most two" relation.
-/

/-- Two radius-`1` balls meet exactly when their centres are at distance at most `2`. -/
theorem not_disjoint_ball_iff_within2 {G : SimpleGraph V} {u v : V} :
    ¬ Disjoint (ball G u) (ball G v) ↔ Within2 G u v := by
  constructor
  · intro h
    obtain ⟨w, hwu, hwv⟩ := Set.not_disjoint_iff.mp h
    rcases hwu with rfl | hadju
    · rcases hwv with rfl | hadjv
      · exact Within2.refl G _
      · exact (Within2.of_adj hadjv).symm
    · rcases hwv with rfl | hadjv
      · exact Within2.of_adj hadju
      · exact Within2.of_adj_adj hadju hadjv.symm
  · intro h
    rw [Set.not_disjoint_iff]
    rcases h with rfl | hadj | ⟨w, h1, h2⟩
    · exact ⟨u, mem_ball_self G u, mem_ball_self G u⟩
    · exact ⟨v, Or.inr hadj, mem_ball_self G v⟩
    · exact ⟨w, Or.inr h1, Or.inr h2.symm⟩

/-- A packing is exactly a set of vertices that are pairwise at distance at least `3`. -/
theorem isPacking_iff_pairwise_not_within2 {G : SimpleGraph V} {P : Finset V} :
    IsPacking G P ↔ ∀ u ∈ P, ∀ v ∈ P, u ≠ v → ¬ Within2 G u v := by
  constructor
  · intro h u hu v hv huv hw
    exact (not_disjoint_ball_iff_within2.mpr hw) (h u hu v hv huv)
  · intro h u hu v hv huv
    by_contra hd
    exact h u hu v hv huv (not_disjoint_ball_iff_within2.mp hd)

/-! ## `ρ ≤ γ`: the easy direction of the Erdős–Pósa duality -/

/-- **The trivial direction of the duality.**  A dominating set must contain a vertex of every
radius-`1` ball, and the balls of a packing are pairwise disjoint, so `ρ(G) ≤ γ(G)`. -/
theorem packingNumber_le_dominationNumber [Fintype V] (G : SimpleGraph V) :
    packingNumber G ≤ dominationNumber G := by
  classical
  have hne : {k | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = k}.Nonempty :=
    ⟨Finset.univ.card, Finset.univ, fun v => Or.inl (Finset.mem_univ v), rfl⟩
  obtain ⟨D, hD, hDcard⟩ := Nat.sInf_mem hne
  obtain ⟨P, hP, hPcard⟩ := exists_packing_card_eq G
  have hchoice : ∀ p : V, ∃ d, d ∈ D ∧ d ∈ ball G p := by
    intro p
    rcases hD p with h | ⟨d, hd, hadj⟩
    · exact ⟨p, h, mem_ball_self G p⟩
    · exact ⟨d, hd, Or.inr hadj.symm⟩
  choose f hf1 hf2 using hchoice
  have hinj : Set.InjOn f P := by
    intro a ha b hb hab
    by_contra hne'
    have hdisj := hP a ha b hb hne'
    rw [Set.disjoint_left] at hdisj
    exact hdisj (hf2 a) (hab ▸ hf2 b)
  calc packingNumber G = P.card := hPcard.symm
    _ ≤ D.card := Finset.card_le_card_of_injOn f (fun a _ => hf1 a) hinj
    _ = dominationNumber G := hDcard

/-! ## The engine: local covers of radius-2 neighbourhoods -/

/-- A *maximum* packing is *maximal*: every vertex has its ball meeting the ball of some
packing vertex (equivalently, is at distance at most `2` from the packing). -/
lemma exists_meeting_of_maximum [Fintype V] {G : SimpleGraph V} {P : Finset V}
    (hP : IsPacking G P) (hcard : P.card = packingNumber G) (v : V) :
    ∃ p ∈ P, ¬ Disjoint (ball G v) (ball G p) := by
  classical
  by_contra hcon
  push_neg at hcon
  have hvP : v ∉ P := by
    intro hv
    have hd := hcon v hv
    rw [Set.disjoint_left] at hd
    exact hd (mem_ball_self G v) (mem_ball_self G v)
  have hins : IsPacking G (insert v P) := by
    intro a ha b hb hab
    simp only [Finset.mem_insert] at ha hb
    rcases ha with rfl | ha
    · rcases hb with rfl | hb
      · exact absurd rfl hab
      · exact hcon b hb
    · rcases hb with rfl | hb
      · exact (hcon a ha).symm
      · exact hP a ha b hb hab
  have h1 : (insert v P).card = packingNumber G + 1 := by
    rw [Finset.card_insert_of_notMem hvP, hcard]
  have h2 : (insert v P).card ≤ packingNumber G := card_le_packingNumber hins
  omega

/-- **The engine.**  If for every vertex `p` the set of vertices whose ball meets the ball of `p`
(i.e. the vertices at distance at most `2` from `p`) can be dominated by at most `c` vertices,
then `γ(G) ≤ c · ρ(G)`. -/
theorem dominationNumber_le_mul_packingNumber [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    {c : ℕ}
    (hcov : ∀ p : V, ∃ Dp : Finset V, Dp.card ≤ c ∧
      ∀ u : V, ¬ Disjoint (ball G u) (ball G p) → (u ∈ Dp ∨ ∃ d ∈ Dp, G.Adj d u)) :
    dominationNumber G ≤ c * packingNumber G := by
  classical
  choose Dp hDp1 hDp2 using hcov
  obtain ⟨P, hP, hPcard⟩ := exists_packing_card_eq G
  have hdom : IsDominatingSet G (P.biUnion Dp) := by
    intro v
    obtain ⟨p, hp, hmeet⟩ := exists_meeting_of_maximum hP hPcard v
    rcases hDp2 p v hmeet with h | ⟨d, hd, hadj⟩
    · exact Or.inl (Finset.mem_biUnion.mpr ⟨p, hp, h⟩)
    · exact Or.inr ⟨d, Finset.mem_biUnion.mpr ⟨p, hp, hd⟩, hadj⟩
  have hcard : (P.biUnion Dp).card ≤ c * packingNumber G := by
    calc (P.biUnion Dp).card ≤ ∑ p ∈ P, (Dp p).card := Finset.card_biUnion_le
      _ ≤ ∑ _p ∈ P, c := Finset.sum_le_sum (fun p _ => hDp1 p)
      _ = P.card * c := by rw [Finset.sum_const, smul_eq_mul]
      _ = c * packingNumber G := by rw [hPcard, Nat.mul_comm]
  exact le_trans (Nat.sInf_le ⟨P.biUnion Dp, hdom, rfl⟩) hcard

/-- The engine, phrased with the catalog's distance-`≤ 2` relation: if the ball of radius `2`
around every vertex `p` can be dominated by at most `c` vertices, then `γ ≤ c·ρ`. -/
theorem dominationNumber_le_mul_packingNumber_of_within2 [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} {c : ℕ}
    (hcov : ∀ p : V, ∃ Dp : Finset V, Dp.card ≤ c ∧
      ∀ u : V, Within2 G u p → (u ∈ Dp ∨ ∃ d ∈ Dp, G.Adj d u)) :
    dominationNumber G ≤ c * packingNumber G := by
  refine dominationNumber_le_mul_packingNumber (fun p => ?_)
  obtain ⟨Dp, hcard, hdom⟩ := hcov p
  exact ⟨Dp, hcard, fun u hu => hdom u (not_disjoint_ball_iff_within2.mp hu)⟩

/-- **Bounded degree bound.**  For every finite graph, `γ ≤ (Δ+1)·ρ`: the closed neighbourhood of
a packing vertex `p` dominates every vertex at distance at most `2` from `p`. -/
theorem dominationNumber_le_maxDegree_succ_mul_packingNumber [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    dominationNumber G ≤ (G.maxDegree + 1) * packingNumber G := by
  refine dominationNumber_le_mul_packingNumber (fun p => ⟨insert p (G.neighborFinset p), ?_, ?_⟩)
  · have hnot : p ∉ G.neighborFinset p := by simp
    rw [Finset.card_insert_of_notMem hnot, SimpleGraph.card_neighborFinset_eq_degree]
    have := G.degree_le_maxDegree p
    omega
  · intro u hmeet
    rw [Set.not_disjoint_iff] at hmeet
    obtain ⟨w, hwu, hwp⟩ := hmeet
    have hwmem : w ∈ insert p (G.neighborFinset p) := by
      rcases hwp with rfl | h
      · exact Finset.mem_insert_self _ _
      · exact Finset.mem_insert_of_mem (by rwa [SimpleGraph.mem_neighborFinset])
    rcases hwu with rfl | h
    · exact Or.inl hwmem
    · exact Or.inr ⟨w, hwmem, h.symm⟩

/-! ## Maximal independent sets inside a radius-2 neighbourhood -/

/-- Every finite vertex set has a maximal independent subset: it is independent and dominates
the whole set. -/
lemma exists_maximal_indep_subset [Fintype V] [DecidableEq V] {G : SimpleGraph V} (T : Finset V) :
    ∃ I ⊆ T, (∀ x ∈ I, ∀ y ∈ I, ¬ G.Adj x y) ∧ ∀ u ∈ T, u ∈ I ∨ ∃ d ∈ I, G.Adj d u := by
  classical
  set F := T.powerset.filter (fun S => ∀ x ∈ S, ∀ y ∈ S, ¬ G.Adj x y) with hF
  have hne : F.Nonempty := ⟨∅, by simp [hF]⟩
  obtain ⟨I, hIF, hImax⟩ := F.exists_max_image Finset.card hne
  rw [hF, Finset.mem_filter, Finset.mem_powerset] at hIF
  refine ⟨I, hIF.1, hIF.2, ?_⟩
  intro u hu
  by_contra hcon
  push_neg at hcon
  obtain ⟨huI, hno⟩ := hcon
  have hins : insert u I ∈ F := by
    rw [hF, Finset.mem_filter, Finset.mem_powerset]
    refine ⟨Finset.insert_subset hu hIF.1, ?_⟩
    intro x hx y hy
    simp only [Finset.mem_insert] at hx hy
    rcases hx with rfl | hx
    · rcases hy with rfl | hy
      · exact G.irrefl
      · intro hadj; exact hno y hy hadj.symm
    · rcases hy with rfl | hy
      · intro hadj; exact hno x hx hadj
      · exact hIF.2 x hx y hy
  have hlt : I.card < (insert u I).card := by
    rw [Finset.card_insert_of_notMem huI]; omega
  have := hImax _ hins
  omega

/-! ## An abstract metric engine

The unit disk and unit ball arguments are two instances of one statement: if `G` is represented
in a metric space `X` by points, with adjacency "distinct and at distance at most `1`", and if
no ball of radius `2` in `X` contains more than `N` points that are pairwise more than `1`
apart, then `γ(G) ≤ N·ρ(G)`.
-/

/-- A **unit distance representation** of `G` in a metric space `X`: vertices are points of `X`
and two distinct vertices are adjacent exactly when their distance is at most `1`. -/
structure MetricRep (G : SimpleGraph V) (X : Type*) [MetricSpace X] where
  /-- the position of each vertex -/
  pos : V → X
  /-- adjacency is "distinct and at distance at most one" -/
  adj_iff : ∀ u v, G.Adj u v ↔ u ≠ v ∧ dist (pos u) (pos v) ≤ 1

/-- `X` has **local packing bound** `N`: no ball of radius `2` in `X` contains more than `N`
points that are pairwise more than `1` apart. -/
def LocalPackingBound (X : Type*) [MetricSpace X] (N : ℕ) : Prop :=
  ∀ (c : X) (T : Finset X), (∀ x ∈ T, dist x c ≤ 2) →
    (∀ x ∈ T, ∀ y ∈ T, x ≠ y → 1 < dist x y) → T.card ≤ N

namespace MetricRep

variable {X : Type*} [MetricSpace X] {G : SimpleGraph V}

lemma dist_le_one (rep : MetricRep G X) {u v : V} (h : G.Adj u v) :
    dist (rep.pos u) (rep.pos v) ≤ 1 := ((rep.adj_iff u v).1 h).2

lemma one_lt_dist (rep : MetricRep G X) {u v : V} (hne : u ≠ v) (h : ¬ G.Adj u v) :
    1 < dist (rep.pos u) (rep.pos v) := by
  by_contra hle
  exact h ((rep.adj_iff u v).2 ⟨hne, not_lt.mp hle⟩)

/-- If the balls of `u` and `p` meet, their representing points are at distance at most `2`. -/
lemma dist_le_two_of_meet (rep : MetricRep G X) {u p : V}
    (h : ¬ Disjoint (ball G u) (ball G p)) : dist (rep.pos u) (rep.pos p) ≤ 2 := by
  rw [Set.not_disjoint_iff] at h
  obtain ⟨w, hwu, hwp⟩ := h
  have h1 : dist (rep.pos u) (rep.pos w) ≤ 1 := by
    rcases hwu with rfl | hadj
    · simp
    · exact rep.dist_le_one hadj
  have h2 : dist (rep.pos w) (rep.pos p) ≤ 1 := by
    rcases hwp with rfl | hadj
    · simp
    · rw [dist_comm]; exact rep.dist_le_one hadj
  calc dist (rep.pos u) (rep.pos p)
      ≤ dist (rep.pos u) (rep.pos w) + dist (rep.pos w) (rep.pos p) := dist_triangle _ _ _
    _ ≤ 2 := by linarith

/-- **Local cover from a local packing bound.**  A maximal independent subset of the vertices at
distance at most `2` from `p` dominates them, and consists of at most `N` vertices. -/
theorem localCover [Fintype V] [DecidableEq V] {N : ℕ} (rep : MetricRep G X)
    (hN : LocalPackingBound X N) (p : V) :
    ∃ Dp : Finset V, Dp.card ≤ N ∧
      ∀ u : V, ¬ Disjoint (ball G u) (ball G p) → (u ∈ Dp ∨ ∃ d ∈ Dp, G.Adj d u) := by
  classical
  set T : Finset V := Finset.univ.filter (fun u => ¬ Disjoint (ball G u) (ball G p)) with hT
  obtain ⟨I, hIT, hIindep, hIdom⟩ := exists_maximal_indep_subset (G := G) T
  refine ⟨I, ?_, ?_⟩
  · have hinj : Set.InjOn rep.pos I := by
      intro x hx y hy hxy
      by_contra hne
      have hgt := rep.one_lt_dist hne (hIindep x hx y hy)
      rw [hxy] at hgt
      simp only [dist_self] at hgt
      linarith
    have hcard : (I.image rep.pos).card = I.card := Finset.card_image_of_injOn hinj
    rw [← hcard]
    refine hN (rep.pos p) _ ?_ ?_
    · intro z hz
      obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
      have hxT : x ∈ T := hIT hx
      rw [hT, Finset.mem_filter] at hxT
      exact rep.dist_le_two_of_meet hxT.2
    · intro z hz w hw hzw
      obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
      obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hw
      have hxy : x ≠ y := by rintro rfl; exact hzw rfl
      exact rep.one_lt_dist hxy (hIindep x hx y hy)
  · intro u hu
    have huT : u ∈ T := by rw [hT, Finset.mem_filter]; exact ⟨Finset.mem_univ u, hu⟩
    exact hIdom u huT

end MetricRep

/-- **The metric Erdős–Pósa bound.**  `γ(G) ≤ N·ρ(G)` for every graph represented in a metric
space with local packing bound `N`. -/
theorem dominationNumber_le_mul_packingNumber_of_metricRep [Fintype V] [DecidableEq V]
    {X : Type*} [MetricSpace X] {G : SimpleGraph V} {N : ℕ} (rep : MetricRep G X)
    (hN : LocalPackingBound X N) : dominationNumber G ≤ N * packingNumber G :=
  dominationNumber_le_mul_packingNumber (fun p => rep.localCover hN p)

/-! ## Geometric local packing bounds -/

/-- **The plane has local packing bound `25`.**  A disk of radius `2` contains at most
`((2·2+1)/1)² = 25` points that are pairwise more than `1` apart: the open disks of radius `1/2`
around them are disjoint and contained in a disk of radius `5/2`. -/
theorem localPackingBound_complex : LocalPackingBound ℂ 25 := by
  intro c T hb hs
  have hvol := card_le_of_pairwise_far_in_ball (MeasureTheory.volume : MeasureTheory.Measure ℂ)
    (c := c) (r := 2) (delta := 1) one_pos (by norm_num) T hb hs
  rw [Complex.finrank_real_complex] at hvol
  have hle : (T.card : ℝ) ≤ 25 := by
    norm_num at hvol ⊢
    linarith
  exact_mod_cast hle

/-- **`ℝⁿ` has local packing bound `5ⁿ`.** -/
theorem localPackingBound_euclidean {n : ℕ} (hn : 0 < n) :
    LocalPackingBound (EuclideanSpace ℝ (Fin n)) (5 ^ n) := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  intro c T hb hs
  have hvol := card_le_of_pairwise_far_in_ball
    (MeasureTheory.volume : MeasureTheory.Measure (EuclideanSpace ℝ (Fin n)))
    (c := c) (r := 2) (delta := 1) one_pos (by norm_num) T hb hs
  rw [finrank_euclideanSpace, Fintype.card_fin] at hvol
  have hle : (T.card : ℝ) ≤ 5 ^ n := by
    simp only [one_pow, mul_one] at hvol
    calc (T.card : ℝ) ≤ (2 * 2 + 1) ^ n := hvol
      _ = 5 ^ n := by norm_num
  exact_mod_cast hle

/-- A unit disk representation is a metric representation in `ℂ`. -/
def metricRep_of_unitDiskRep [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    (rep : UnitDiskRep G) : MetricRep G ℂ where
  pos := rep.pos
  adj_iff := rep.adj_iff

/-- A unit ball representation is a metric representation in `ℝⁿ`. -/
def metricRep_of_unitBallRep [Fintype V] [DecidableEq V] {G : SimpleGraph V} {n : ℕ}
    (rep : UnitBallRep G n) : MetricRep G (EuclideanSpace ℝ (Fin n)) where
  pos := rep.pos
  adj_iff := rep.adj_iff

/-- **Main theorem (unit disk graphs).**  `γ(G) ≤ 25·ρ(G)` for every unit disk graph.
This is a fully verified, weaker version of the paper's bound `γ/ρ ≤ 18√3/π ≈ 9.924`. -/
theorem dominationNumber_le_25_mul_packingNumber [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    (rep : UnitDiskRep G) : dominationNumber G ≤ 25 * packingNumber G :=
  dominationNumber_le_mul_packingNumber_of_metricRep (metricRep_of_unitDiskRep rep)
    localPackingBound_complex

/-- The ratio form of the unit disk bound. -/
theorem ratio_le_25 [Fintype V] [DecidableEq V] {G : SimpleGraph V} (rep : UnitDiskRep G)
    (hpos : 0 < packingNumber G) :
    (dominationNumber G : ℚ) / (packingNumber G : ℚ) ≤ 25 := by
  have h := dominationNumber_le_25_mul_packingNumber rep
  have hq : (dominationNumber G : ℚ) ≤ 25 * (packingNumber G : ℚ) := by exact_mod_cast h
  have hp : (0 : ℚ) < (packingNumber G : ℚ) := by exact_mod_cast hpos
  rw [div_le_iff₀ hp]
  linarith

/-- **Main theorem in `ℝⁿ`.**  `γ(G) ≤ 5ⁿ·ρ(G)` for every unit ball graph in `ℝⁿ`. -/
theorem dominationNumber_le_five_pow_mul_packingNumber [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} {n : ℕ} (hn : 0 < n) (rep : UnitBallRep G n) :
    dominationNumber G ≤ 5 ^ n * packingNumber G :=
  dominationNumber_le_mul_packingNumber_of_metricRep (metricRep_of_unitBallRep rep)
    (localPackingBound_euclidean hn)


/-! ## Decidability, for the concrete examples -/

instance decidableMemBall {V : Type*} [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]
    (v u : V) : Decidable (u ∈ ball G v) :=
  inferInstanceAs (Decidable (u = v ∨ G.Adj v u))

instance decidableDisjointBall {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (u v : V) : Decidable (Disjoint (ball G u) (ball G v)) := by
  refine decidable_of_iff (∀ w : V, w ∈ ball G u → w ∉ ball G v) ?_
  rw [Set.disjoint_left]

instance decidableIsPacking {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (P : Finset V) : Decidable (IsPacking G P) :=
  inferInstanceAs (Decidable (∀ u ∈ P, ∀ v ∈ P, u ≠ v → Disjoint (ball G u) (ball G v)))

instance decidableIsDominatingSet {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (D : Finset V) : Decidable (IsDominatingSet G D) :=
  inferInstanceAs (Decidable (∀ v, v ∈ D ∨ ∃ d ∈ D, G.Adj d v))

/-- If all radius-`1` balls pairwise meet then `ρ = 1` (for a nonempty graph). -/
lemma packingNumber_eq_one_of_pairwise_meet [Fintype V] [Nonempty V] {G : SimpleGraph V}
    (h : ∀ u v : V, u ≠ v → ¬ Disjoint (ball G u) (ball G v)) : packingNumber G = 1 := by
  classical
  refine le_antisymm ?_ (one_le_packingNumber G)
  refine csSup_le (packingSet_nonempty G) ?_
  rintro k ⟨P, hP, rfl⟩
  by_contra hlt
  push_neg at hlt
  obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp hlt
  exact h a b hab (hP a ha b hb hab)

/-- A lower bound on `γ` from a decidable check over all dominating sets. -/
lemma le_dominationNumber_of_forall [Fintype V] {G : SimpleGraph V} {m : ℕ}
    (h : ∀ D : Finset V, IsDominatingSet G D → m ≤ D.card) : m ≤ dominationNumber G := by
  classical
  have hne : {k | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = k}.Nonempty :=
    ⟨Finset.univ.card, Finset.univ, fun v => Or.inl (Finset.mem_univ v), rfl⟩
  obtain ⟨D, hD, hDcard⟩ := Nat.sInf_mem hne
  have := h D hD
  rw [hDcard] at this
  exact this

/-! ## The Wagner graph: `γ = 3`, `ρ = 1` -/

set_option maxRecDepth 100000

/-- Adjacency of the **Wagner graph** `V₈` (Möbius ladder `M₄`): the `8`-cycle `0-1-⋯-7-0`
together with the four main diagonals `i ∼ i+4`. -/
def wagnerAdj (i j : Fin 8) : Prop :=
  (i.val + 1) % 8 = j.val ∨ (j.val + 1) % 8 = i.val ∨ (i.val + 4) % 8 = j.val

instance : DecidableRel wagnerAdj := fun i j => by unfold wagnerAdj; infer_instance

lemma wagnerAdj_symm : ∀ i j : Fin 8, wagnerAdj i j → wagnerAdj j i := by decide

lemma wagnerAdj_irrefl : ∀ i : Fin 8, ¬ wagnerAdj i i := by decide

/-- The Wagner graph `V₈`. -/
def wagner : SimpleGraph (Fin 8) where
  Adj := wagnerAdj
  symm := fun {i j} h => wagnerAdj_symm i j h
  loopless := ⟨wagnerAdj_irrefl⟩

instance : DecidableRel wagner.Adj := inferInstanceAs (DecidableRel wagnerAdj)

/-- In the Wagner graph any two distinct closed neighbourhoods meet, so `ρ(V₈) = 1`. -/
theorem wagner_packingNumber : packingNumber wagner = 1 :=
  packingNumber_eq_one_of_pairwise_meet (by decide)

/-- The Wagner graph has domination number `3`. -/
theorem wagner_dominationNumber : dominationNumber wagner = 3 := by
  refine le_antisymm ?_ (le_dominationNumber_of_forall (by decide))
  refine Nat.sInf_le ⟨{0, 1, 2}, by decide, by decide⟩

/-- **Lower bound `3` for the domination–packing ratio.**  The Wagner graph `V₈` has
`γ = 3 = 3·ρ`, so no Erdős–Pósa bound `γ ≤ c·ρ` can hold with `c < 3`. -/
theorem wagner_domination_eq_three_mul_packing :
    dominationNumber wagner = 3 * packingNumber wagner := by
  rw [wagner_dominationNumber, wagner_packingNumber]

/-! ## The `4`-cycle as a unit disk graph: `γ = 2`, `ρ = 1` -/

/-- Adjacency of the `4`-cycle. -/
def cycle4Adj (i j : Fin 4) : Prop := (i.val + 1) % 4 = j.val ∨ (j.val + 1) % 4 = i.val

instance : DecidableRel cycle4Adj := fun i j => by unfold cycle4Adj; infer_instance

lemma cycle4Adj_symm : ∀ i j : Fin 4, cycle4Adj i j → cycle4Adj j i := by decide

lemma cycle4Adj_irrefl : ∀ i : Fin 4, ¬ cycle4Adj i i := by decide

/-- The `4`-cycle `C₄`. -/
def cycle4 : SimpleGraph (Fin 4) where
  Adj := cycle4Adj
  symm := fun {i j} h => cycle4Adj_symm i j h
  loopless := ⟨cycle4Adj_irrefl⟩

instance : DecidableRel cycle4.Adj := inferInstanceAs (DecidableRel cycle4Adj)

/-- The four corners of a `4/5 × 21/25` rectangle: the sides have length `4/5` and `21/25`,
both at most `1`, while the diagonals have length `29/25 > 1`. -/
noncomputable def cycle4Pos : Fin 4 → ℂ := ![⟨0, 0⟩, ⟨4/5, 0⟩, ⟨4/5, 21/25⟩, ⟨0, 21/25⟩]

/-- `C₄` is a unit disk graph. -/
noncomputable def cycle4_unitDiskRep : UnitDiskRep cycle4 where
  pos := cycle4Pos
  adj_iff := by
    intro u v
    fin_cases u <;> fin_cases v <;>
      simp [cycle4, cycle4Adj, cycle4Pos, Complex.dist_eq_re_im] <;> norm_num

theorem cycle4_packingNumber : packingNumber cycle4 = 1 :=
  packingNumber_eq_one_of_pairwise_meet (by decide)

theorem cycle4_dominationNumber : dominationNumber cycle4 = 2 := by
  refine le_antisymm ?_ (le_dominationNumber_of_forall (by decide))
  exact Nat.sInf_le ⟨{0, 1}, by decide, by decide⟩

/-- **Lower bound `2` for unit disk graphs.**  `C₄` is a unit disk graph with `γ = 2 = 2·ρ`;
combined with `dominationNumber_le_25_mul_packingNumber` the optimal unit-disk constant lies
in the verified interval `[2, 25]`. -/
theorem cycle4_domination_eq_two_mul_packing :
    dominationNumber cycle4 = 2 * packingNumber cycle4 := by
  rw [cycle4_dominationNumber, cycle4_packingNumber]

end DominationPacking