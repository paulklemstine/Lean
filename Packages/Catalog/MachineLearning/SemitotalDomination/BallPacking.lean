import MachineLearning.SemitotalDomination.Approximation

/-!
# Unit **ball** graphs in `ℝⁿ`: a `3ⁿ`-approximation for semitotal domination

The paper *Semitotal domination in unit disk graphs* works in the plane, where the geometric
input to the analysis is the packing fact "a closed unit disk contains at most `5` points that
are pairwise more than `1` apart" (`DiskPacking.lean`).

Since the combinatorial engine (`Greedy.lean`) and the counting bridge (`Approximation.lean`)
were isolated from the geometry — the latter only needs a `LocalIndependenceBound` — the whole
argument lifts verbatim to **any** dimension as soon as one has a packing constant.  This file
supplies such a constant for `ℝⁿ` by a *measure-theoretic volume argument*, which is a genuine
change of technique from the planar angular pigeonhole:

* `card_le_of_pairwise_far_in_ball`: in a finite-dimensional real normed space `E`, if `T` is a
  finite set of points inside a ball of radius `r` around `c` and any two distinct points of `T`
  are more than `δ` apart, then `|T| · δ ^ dim E ≤ (2r + δ) ^ dim E`.  Proof: the open balls of
  radius `δ/2` around the points of `T` are pairwise disjoint and all contained in the ball of
  radius `r + δ/2`, so Haar measure counts them.
* `UnitBallRep.localIndependenceBound`: for a unit ball graph in `ℝⁿ` the constant is `3ⁿ`
  (take `r = δ = 1`).
* `exists_semitotalDominatingSet_card_le_three_pow_mul`: consequently the same greedy BFS
  algorithm is a `3ⁿ`-approximation for minimum semitotal domination on unit ball graphs in
  `ℝⁿ`, and `γ_t2 ≤ 3ⁿ · γ`.

For `n = 2` this gives the (weaker) constant `9` by a completely different proof, which is a
useful independent sanity check on the planar constant `5`.
-/

namespace SemitotalDomination

open Finset MeasureTheory Metric

/-- **Volume packing bound.**  A ball of radius `r` in a `d`-dimensional real normed space
contains at most `((2r+δ)/δ)^d` points that are pairwise more than `δ` apart. -/
theorem card_le_of_pairwise_far_in_ball {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E] [Nontrivial E]
    (μ : Measure E) [μ.IsAddHaarMeasure]
    {c : E} {r delta : ℝ} (hd : 0 < delta) (hr : 0 ≤ r) (T : Finset E)
    (hb : ∀ x ∈ T, dist x c ≤ r) (hs : ∀ x ∈ T, ∀ y ∈ T, x ≠ y → delta < dist x y) :
    (T.card : ℝ) * delta ^ (Module.finrank ℝ E) ≤ (2 * r + delta) ^ (Module.finrank ℝ E) := by
  classical
  set d := Module.finrank ℝ E with hdd
  set e := delta / 2 with he
  have he0 : 0 < e := by positivity
  have hdisj : (T : Set E).PairwiseDisjoint (fun x => ball x e) := by
    intro x hx y hy hxy
    exact ball_disjoint_ball (by have := hs x hx y hy hxy; simp only [he]; linarith)
  have hsub : (⋃ x ∈ T, ball x e) ⊆ closedBall c (r + e) := by
    intro z hz
    simp only [Set.mem_iUnion] at hz
    obtain ⟨x, hx, hzx⟩ := hz
    have h1 : dist z x < e := mem_ball.mp hzx
    have h2 : dist x c ≤ r := hb x hx
    exact mem_closedBall.mpr (le_trans (dist_triangle z x c) (by linarith))
  have hmeas := measure_biUnion_finset (μ := μ) hdisj (fun b _ => measurableSet_ball)
  have hmono : μ (⋃ x ∈ T, ball x e) ≤ μ (closedBall c (r + e)) := measure_mono hsub
  rw [hmeas] at hmono
  have hball : ∀ x : E, μ (ball x e) = ENNReal.ofReal (e ^ d) * μ (ball 0 1) := fun x =>
    Measure.addHaar_ball μ x he0.le
  simp only [hball, Finset.sum_const, nsmul_eq_mul] at hmono
  rw [Measure.addHaar_closedBall μ c (by positivity), ← mul_assoc] at hmono
  have hpos : μ (ball (0 : E) 1) ≠ 0 := (measure_ball_pos μ 0 one_pos).ne'
  have hfin : μ (ball (0 : E) 1) ≠ ⊤ := measure_ball_lt_top.ne
  rw [ENNReal.mul_le_mul_iff_left hpos hfin] at hmono
  have hL : ((T.card : ENNReal)) * ENNReal.ofReal (e ^ d)
      = ENNReal.ofReal ((T.card : ℝ) * e ^ d) := by
    rw [ENNReal.ofReal_mul (by positivity), ENNReal.ofReal_natCast]
  rw [← hdd] at hmono
  rw [hL, ENNReal.ofReal_le_ofReal_iff (by positivity)] at hmono
  have h2 : (0:ℝ) < 2 ^ d := by positivity
  have hkey : ((T.card : ℝ) * e ^ d) * 2 ^ d ≤ (r + e) ^ d * 2 ^ d := by nlinarith [hmono]
  calc (T.card : ℝ) * delta ^ d = ((T.card : ℝ) * e ^ d) * 2 ^ d := by
        rw [he, mul_assoc, ← mul_pow]; ring_nf
    _ ≤ (r + e) ^ d * 2 ^ d := hkey
    _ = (2 * r + delta) ^ d := by rw [← mul_pow, he]; ring_nf

/-- Specialization to the unit ball of `ℝⁿ`: at most `3ⁿ` points of a closed unit ball are
pairwise more than `1` apart. -/
theorem card_le_three_pow_of_pairwise_far {n : ℕ} (hn : 0 < n)
    (c : EuclideanSpace ℝ (Fin n)) (T : Finset (EuclideanSpace ℝ (Fin n)))
    (hb : ∀ x ∈ T, dist x c ≤ 1) (hs : ∀ x ∈ T, ∀ y ∈ T, x ≠ y → 1 < dist x y) :
    T.card ≤ 3 ^ n := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  have hrank : Module.finrank ℝ (EuclideanSpace ℝ (Fin n)) = n := by simp [finrank_euclideanSpace]
  have h := card_le_of_pairwise_far_in_ball (volume : Measure (EuclideanSpace ℝ (Fin n)))
    (c := c) (r := 1) (delta := 1) one_pos zero_le_one T hb hs
  rw [hrank] at h
  have h' : (T.card : ℝ) ≤ ((3 : ℕ) ^ n : ℕ) := by
    push_cast
    norm_num at h ⊢
    linarith [h]
  exact_mod_cast h'

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-- A **unit ball representation** of a graph in `ℝⁿ`: vertices are points of `ℝⁿ` and two
distinct vertices are adjacent exactly when their distance is at most `1`. -/
structure UnitBallRep (G : SimpleGraph V) (n : ℕ) where
  /-- the position of each vertex in `ℝⁿ` -/
  pos : V → EuclideanSpace ℝ (Fin n)
  /-- adjacency is "distinct and at distance at most one" -/
  adj_iff : ∀ u v, G.Adj u v ↔ u ≠ v ∧ dist (pos u) (pos v) ≤ 1

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Adjacent vertices of a unit ball graph are at distance at most `1`. -/
lemma UnitBallRep.dist_le_one {n : ℕ} (rep : UnitBallRep G n) {u v : V} (h : G.Adj u v) :
    dist (rep.pos u) (rep.pos v) ≤ 1 := ((rep.adj_iff u v).1 h).2

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Non-adjacent distinct vertices of a unit ball graph are more than `1` apart. -/
lemma UnitBallRep.one_lt_dist {n : ℕ} (rep : UnitBallRep G n) {u v : V} (hne : u ≠ v)
    (h : ¬ G.Adj u v) : 1 < dist (rep.pos u) (rep.pos v) := by
  by_contra hle
  exact h ((rep.adj_iff u v).2 ⟨hne, le_of_not_gt hle⟩)

omit [Fintype V] [DecidableRel G.Adj] in
/-- **Local packing bound in `ℝⁿ`.**  The closed neighbourhood of a vertex of a unit ball graph
contains at most `3ⁿ` pairwise non-adjacent vertices. -/
theorem card_le_three_pow_of_indep_in_closed_nbhd {n : ℕ} (hn : 0 < n) (rep : UnitBallRep G n)
    (d : V) {I : Finset V} (hI : G.IsIndepSet (I : Set V))
    (hd : ∀ x ∈ I, x = d ∨ G.Adj d x) : I.card ≤ 3 ^ n := by
  classical
  rw [isIndepSet_iff] at hI
  have hinj : Set.InjOn rep.pos I := by
    intro x hx y hy hxy
    by_contra hne
    have hgt := rep.one_lt_dist hne (hI x (Finset.mem_coe.mp hx) y (Finset.mem_coe.mp hy))
    rw [hxy] at hgt
    simp only [dist_self] at hgt
    linarith
  have hcard : (I.image rep.pos).card = I.card := Finset.card_image_of_injOn hinj
  rw [← hcard]
  refine card_le_three_pow_of_pairwise_far hn (rep.pos d) _ ?_ ?_
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

omit [Fintype V] [DecidableRel G.Adj] in
/-- A unit ball graph in `ℝⁿ` has local independence bound `3ⁿ`. -/
theorem UnitBallRep.localIndependenceBound {n : ℕ} (hn : 0 < n) (rep : UnitBallRep G n) :
    LocalIndependenceBound G (3 ^ n) :=
  fun d _ hI hd => card_le_three_pow_of_indep_in_closed_nbhd hn rep d hI hd

/-- **Main theorem in dimension `n`.**  For a connected unit ball graph in `ℝⁿ` with at least two
vertices, the greedy BFS algorithm returns a semitotal dominating set of size at most
`3ⁿ · γ_t2(G)`. -/
theorem exists_semitotalDominatingSet_card_le_three_pow_mul {n : ℕ} (hn : 0 < n)
    (rep : UnitBallRep G n) (hconn : G.Connected) (hV : 1 < Fintype.card V) :
    ∃ S : Finset V, IsSemitotalDominatingSet G S ∧
      S.card ≤ 3 ^ n * semitotalDominationNumber G :=
  exists_semitotalDominatingSet_card_le_mul (rep.localIndependenceBound hn) hconn hV

/-- The greedy output itself obeys the `3ⁿ` guarantee. -/
theorem greedyMIS_card_le_three_pow_mul {n : ℕ} (hn : 0 < n) (rep : UnitBallRep G n)
    (hconn : G.Connected) {r : V} (hne : greedyMIS G r ≠ {r}) :
    (greedyMIS G r).card ≤ 3 ^ n * semitotalDominationNumber G :=
  greedyMIS_card_le_mul (rep.localIndependenceBound hn) hconn hne

/-- Structural corollary in dimension `n`: `γ_t2(G) ≤ 3ⁿ · γ(G)` for connected unit ball
graphs with at least two vertices. -/
theorem semitotalDominationNumber_le_three_pow_mul_dominationNumber {n : ℕ} (hn : 0 < n)
    (rep : UnitBallRep G n) (hconn : G.Connected) (hV : 1 < Fintype.card V) :
    semitotalDominationNumber G ≤ 3 ^ n * dominationNumber G := by
  refine semitotalDominationNumber_le_mul_dominationNumber (rep.localIndependenceBound hn)
    ?_ hconn hV
  calc 2 ≤ 3 ^ 1 := by norm_num
    _ ≤ 3 ^ n := Nat.pow_le_pow_right (by norm_num) hn

end SemitotalDomination