import Bridges.DominationPackingRatio

/-!
# The domination–packing ratio on the line: unit interval graphs

`Bridges.DominationPackingRatio` sets up the radius-`1` ball hypergraph of a graph, its
transversal number `γ` and matching number `ρ`, and proves Erdős–Pósa style bounds
`γ ≤ N·ρ` from *local packing bounds* of a metric representation
(`dominationNumber_le_mul_packingNumber_of_metricRep`).  For the plane this gave `γ ≤ 25·ρ`.

This file treats the one-dimensional case, i.e. **unit interval graphs** (indifference graphs):
graphs represented by points of `ℝ` with adjacency "distinct and at distance at most `1`".

## Main results

* `localPackingBound_real` — an interval of radius `2` contains at most `4` points that are
  pairwise more than `1` apart.  This improves the general Euclidean bound `5ⁿ` at `n = 1`
  from `5` to `4`, and `not_localPackingBound_real_three` shows `4` is optimal here: the four
  points `0, 11/10, 11/5, 33/10` lie within distance `2` of `2` and are pairwise more than `1`
  apart.
* `dominationNumber_le_four_mul_packingNumber` — hence `γ ≤ 4·ρ` for every unit interval graph,
  by the abstract metric engine.
* `IntervalRep`, `greedy_dominating_packing` — the sharp result, for *all* interval graphs, by
  the earliest-endpoint greedy: for every finite set `S` of vertices there are a packing
  `P ⊆ S` and a set `D` with `|D| ≤ |P|` dominating `S`.  The greedy step takes the vertex
  `u ∈ S` whose interval ends first, puts the vertex `d` whose interval ends last among those
  meeting `u` into `D` and `u` itself into `P`, and recurses on the vertices of `S` missed by
  `d`; those all start strictly to the right of `right d`, which is exactly what makes the
  balls of the chosen centres disjoint.
* `dominationNumber_eq_packingNumber_of_intervalRep` — **`γ(G) = ρ(G)` for every interval
  graph**, and `dominationNumber_eq_packingNumber_of_metricRep_real` for every unit interval
  graph (via `intervalRep_of_metricRep`): the domination–packing ratio is exactly `1` in
  dimension one, so the interesting behaviour of the ratio (`3` from below, `25` from above in
  our formalization) is a genuinely two-dimensional phenomenon.
-/

namespace DominationPacking

open Finset

variable {V : Type*}

/-! ## Balls of a metric representation are metric balls -/

/-- In a metric representation, the radius-`1` ball of `u` consists of the vertices whose
positions are at distance at most `1` from that of `u`. -/
lemma MetricRep.mem_ball_iff_dist_le_one {X : Type*} [MetricSpace X] {G : SimpleGraph V}
    (rep : MetricRep G X) {u w : V} :
    w ∈ ball G u ↔ dist (rep.pos w) (rep.pos u) ≤ 1 := by
  constructor
  · rintro (rfl | hadj)
    · simp
    · rw [dist_comm]; exact rep.dist_le_one hadj
  · intro h
    by_cases hwu : w = u
    · exact Or.inl hwu
    · exact Or.inr ((rep.adj_iff u w).2 ⟨fun h' => hwu h'.symm, by rwa [dist_comm]⟩)

/-! ## A sharp local packing bound on the line -/

/-- **The line has local packing bound `4`.**  If every element of `T` is within distance `2`
of `c` and the elements are pairwise more than `1` apart, then `|T| ≤ 4`: the map
`x ↦ min ⌊x - (c - 2)⌋ 3` is injective on `T` with values in `{0, 1, 2, 3}`. -/
theorem localPackingBound_real : LocalPackingBound ℝ 4 := by
  intro c T hb hs
  classical
  set f : ℝ → ℕ := fun x => min (⌊x - (c - 2)⌋).toNat 3 with hf
  have hmaps : ∀ x ∈ T, f x ∈ Finset.range 4 := by
    intro x _
    simp only [hf, Finset.mem_range]
    omega
  have hinj : ∀ x ∈ T, ∀ y ∈ T, f x = f y → x = y := by
    -- it suffices to rule out `x < y`
    have key : ∀ x ∈ T, ∀ y ∈ T, x < y → f x ≠ f y := by
      intro x hx y hy hxy
      have hbx : |x - c| ≤ 2 := by rw [← Real.dist_eq]; exact hb x hx
      have hby : |y - c| ≤ 2 := by rw [← Real.dist_eq]; exact hb y hy
      have hxc : c - 2 ≤ x ∧ x ≤ c + 2 := by
        rw [abs_le] at hbx; constructor <;> linarith [hbx.1, hbx.2]
      have hyc : c - 2 ≤ y ∧ y ≤ c + 2 := by
        rw [abs_le] at hby; constructor <;> linarith [hby.1, hby.2]
      have hgap : 1 < y - x := by
        have := hs x hx y hy (ne_of_lt hxy)
        rw [Real.dist_eq, abs_of_neg (by linarith : x - y < 0)] at this
        linarith
      have ha0 : 0 ≤ x - (c - 2) := by linarith [hxc.1]
      have hb4 : y - (c - 2) ≤ 4 := by linarith [hyc.2]
      have hab : (x - (c - 2)) + 1 < y - (c - 2) := by linarith
      have hfloor_a : (0 : ℤ) ≤ ⌊x - (c - 2)⌋ := Int.floor_nonneg.2 ha0
      have hstep : ⌊x - (c - 2)⌋ + 1 ≤ ⌊y - (c - 2)⌋ := by
        have hrw : ⌊x - (c - 2)⌋ + 1 = ⌊(x - (c - 2)) + 1⌋ := by rw [Int.floor_add_one]
        rw [hrw]
        exact Int.floor_le_floor (le_of_lt hab)
      have ha2 : ⌊x - (c - 2)⌋ ≤ 2 := by
        by_contra hcon
        push_neg at hcon
        have h3 : (3 : ℝ) ≤ x - (c - 2) := by
          have h3' : (3 : ℤ) ≤ ⌊x - (c - 2)⌋ := by omega
          calc (3 : ℝ) = ((3 : ℤ) : ℝ) := by norm_num
            _ ≤ (⌊x - (c - 2)⌋ : ℝ) := by exact_mod_cast h3'
            _ ≤ x - (c - 2) := Int.floor_le _
        linarith
      simp only [hf]
      omega
    intro x hx y hy hfxy
    rcases lt_trichotomy x y with h | h | h
    · exact absurd hfxy (key x hx y hy h)
    · exact h
    · exact absurd hfxy.symm (key y hy x hx h)
  calc T.card = (T.image f).card := (Finset.card_image_of_injOn hinj).symm
    _ ≤ (Finset.range 4).card := Finset.card_le_card (by
        intro k hk
        obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hk
        exact hmaps x hx)
    _ = 4 := by simp

/-- The constant `4` in `localPackingBound_real` cannot be improved: the four points
`0, 11/10, 11/5, 33/10` are within distance `2` of `2` and pairwise more than `1` apart. -/
theorem not_localPackingBound_real_three : ¬ LocalPackingBound ℝ 3 := by
  intro h
  have hcard := h 2 ({0, 11/10, 11/5, 33/10} : Finset ℝ) (by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl | rfl | rfl <;>
        · rw [Real.dist_eq]; rw [abs_le]; constructor <;> norm_num) (by
      intro x hx y hy hxy
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx hy
      rw [Real.dist_eq]
      rcases hx with rfl | rfl | rfl | rfl <;> rcases hy with rfl | rfl | rfl | rfl <;>
        first
          | exact absurd rfl hxy
          | (rw [lt_abs]; norm_num))
  have : ({0, 11/10, 11/5, 33/10} : Finset ℝ).card = 4 := by norm_num
  omega

/-- **`γ ≤ 4·ρ` for unit interval graphs.**  A quantitative improvement, in dimension one, of
the general Euclidean bound `γ ≤ 5ⁿ·ρ`. -/
theorem dominationNumber_le_four_mul_packingNumber [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (rep : MetricRep G ℝ) :
    dominationNumber G ≤ 4 * packingNumber G :=
  dominationNumber_le_mul_packingNumber_of_metricRep rep localPackingBound_real

/-! ## Interval graphs and the greedy algorithm: `γ = ρ`

The greedy argument below works for *all* interval graphs, not only the unit interval graphs of
the previous section, so we set it up in that generality and specialize afterwards.
-/

/-- An **interval representation** of `G`: vertex `v` gets the closed interval
`[left v, right v]`, and two distinct vertices are adjacent exactly when their intervals meet. -/
structure IntervalRep (G : SimpleGraph V) where
  /-- the left endpoint of the interval of a vertex -/
  left : V → ℝ
  /-- the right endpoint of the interval of a vertex -/
  right : V → ℝ
  /-- the intervals are nonempty -/
  left_le_right : ∀ v, left v ≤ right v
  /-- adjacency is "distinct, with meeting intervals" -/
  adj_iff : ∀ u v, G.Adj u v ↔ u ≠ v ∧ (left u ≤ right v ∧ left v ≤ right u)

/-- The radius-`1` ball of `u` consists of the vertices whose interval meets that of `u`. -/
lemma IntervalRep.mem_ball_iff_meet {G : SimpleGraph V} (rep : IntervalRep G) {u w : V} :
    w ∈ ball G u ↔ (rep.left w ≤ rep.right u ∧ rep.left u ≤ rep.right w) := by
  constructor
  · rintro (rfl | hadj)
    · exact ⟨rep.left_le_right w, rep.left_le_right w⟩
    · exact ⟨((rep.adj_iff u w).1 hadj).2.2, ((rep.adj_iff u w).1 hadj).2.1⟩
  · intro h
    by_cases hwu : w = u
    · exact Or.inl hwu
    · exact Or.inr ((rep.adj_iff u w).2 ⟨fun h' => hwu h'.symm, h.2, h.1⟩)

/-- **The greedy algorithm on interval graphs.**  For every finite set `S` of vertices there are
a packing `P ⊆ S` and a set `D` with `|D| ≤ |P|` that dominates `S`.  The greedy step takes the
vertex `u ∈ S` whose interval ends first, dominates it by the vertex `d` whose interval ends
last among those meeting `u`, and recurses on the vertices of `S` that `d` misses; those all
start strictly to the right of `right d`, which is exactly what keeps the balls of the chosen
centres pairwise disjoint. -/
theorem greedy_dominating_packing [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    (rep : IntervalRep G) :
    ∀ (n : ℕ) (S : Finset V), S.card ≤ n →
      ∃ D P : Finset V, P ⊆ S ∧ IsPacking G P ∧ D.card ≤ P.card ∧
        ∀ v ∈ S, v ∈ D ∨ ∃ d ∈ D, G.Adj d v := by
  intro n
  induction n with
  | zero =>
    intro S hS
    have hSe : S = ∅ := Finset.card_eq_zero.mp (Nat.le_zero.mp hS)
    subst hSe
    exact ⟨∅, ∅, by simp, by simp [IsPacking], le_rfl, by simp⟩
  | succ n ih =>
    intro S hS
    rcases S.eq_empty_or_nonempty with rfl | hne
    · exact ⟨∅, ∅, by simp, by simp [IsPacking], le_rfl, by simp⟩
    classical
    obtain ⟨u, huS, hu⟩ := S.exists_min_image (fun x => rep.right x) hne
    set N : Finset V := Finset.univ.filter
      (fun x => rep.left x ≤ rep.right u ∧ rep.left u ≤ rep.right x) with hN
    have huN : u ∈ N := by
      rw [hN, Finset.mem_filter]
      exact ⟨Finset.mem_univ u, rep.left_le_right u, rep.left_le_right u⟩
    obtain ⟨d, hdN, hd⟩ := N.exists_max_image (fun x => rep.right x) ⟨u, huN⟩
    have hdmem : rep.left d ≤ rep.right u ∧ rep.left u ≤ rep.right d := by
      rw [hN, Finset.mem_filter] at hdN; exact hdN.2
    set S' : Finset V := S.filter
      (fun x => ¬ (rep.left x ≤ rep.right d ∧ rep.left d ≤ rep.right x)) with hS'
    have hS'sub : S' ⊆ S := Finset.filter_subset _ _
    have huS' : u ∉ S' := by
      rw [hS', Finset.mem_filter]
      rintro ⟨-, hcon⟩
      exact hcon ⟨hdmem.2, hdmem.1⟩
    have hcard' : S'.card ≤ n := by
      have hlt : S'.card < S.card :=
        Finset.card_lt_card ⟨hS'sub, fun hsub => huS' (hsub huS)⟩
      omega
    obtain ⟨D', P', hP'sub, hP'pack, hcardD, hdom'⟩ := ih S' hcard'
    -- every remaining vertex starts strictly to the right of `right d`
    have hfar : ∀ x ∈ S', rep.right d < rep.left x := by
      intro x hx
      rw [hS', Finset.mem_filter] at hx
      have hux : rep.right u ≤ rep.right x := hu x hx.1
      by_contra hcon
      push_neg at hcon
      exact hx.2 ⟨hcon, le_trans hdmem.1 hux⟩
    -- hence the new ball is disjoint from the ones already chosen
    have hdisj : ∀ p ∈ P', Disjoint (ball G u) (ball G p) := by
      intro p hp
      rw [Set.disjoint_left]
      intro w hwu hwp
      have hwN : w ∈ N := by
        rw [hN, Finset.mem_filter]
        exact ⟨Finset.mem_univ w, rep.mem_ball_iff_meet.1 hwu⟩
      have hwd : rep.right w ≤ rep.right d := hd w hwN
      have hwp' := rep.mem_ball_iff_meet.1 hwp
      have hpf := hfar p (hP'sub hp)
      linarith [hwp'.2]
    refine ⟨insert d D', insert u P', ?_, ?_, ?_, ?_⟩
    · exact Finset.insert_subset huS (hP'sub.trans hS'sub)
    · intro a ha b hb hab
      simp only [Finset.mem_insert] at ha hb
      rcases ha with rfl | ha
      · rcases hb with rfl | hb
        · exact absurd rfl hab
        · exact hdisj b hb
      · rcases hb with rfl | hb
        · exact (hdisj a ha).symm
        · exact hP'pack a ha b hb hab
    · have huP' : u ∉ P' := fun h => huS' (hP'sub h)
      calc (insert d D').card ≤ D'.card + 1 := Finset.card_insert_le _ _
        _ ≤ P'.card + 1 := by omega
        _ = (insert u P').card := (Finset.card_insert_of_notMem huP').symm
    · intro v hvS
      by_cases hv : rep.left v ≤ rep.right d ∧ rep.left d ≤ rep.right v
      · rcases rep.mem_ball_iff_meet.2 hv with rfl | hadj
        · exact Or.inl (Finset.mem_insert_self _ _)
        · exact Or.inr ⟨d, Finset.mem_insert_self _ _, hadj⟩
      · have hvS' : v ∈ S' := by rw [hS', Finset.mem_filter]; exact ⟨hvS, hv⟩
        rcases hdom' v hvS' with h | ⟨e, he, hadj⟩
        · exact Or.inl (Finset.mem_insert_of_mem h)
        · exact Or.inr ⟨e, Finset.mem_insert_of_mem he, hadj⟩

/-- `γ ≤ ρ` for interval graphs. -/
theorem dominationNumber_le_packingNumber_of_intervalRep [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (rep : IntervalRep G) :
    dominationNumber G ≤ packingNumber G := by
  obtain ⟨D, P, -, hPpack, hcard, hdom⟩ :=
    greedy_dominating_packing rep (Fintype.card V) Finset.univ (by simp)
  have h1 : dominationNumber G ≤ D.card :=
    Nat.sInf_le ⟨D, fun v => hdom v (Finset.mem_univ v), rfl⟩
  exact h1.trans (hcard.trans (card_le_packingNumber hPpack))

/-- **The domination–packing ratio of an interval graph is exactly `1`.**  Together with
`packingNumber_le_dominationNumber` (`ρ ≤ γ`, valid for all graphs) the greedy construction
gives `γ(G) = ρ(G)` for every interval graph. -/
theorem dominationNumber_eq_packingNumber_of_intervalRep [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (rep : IntervalRep G) :
    dominationNumber G = packingNumber G :=
  le_antisymm (dominationNumber_le_packingNumber_of_intervalRep rep)
    (packingNumber_le_dominationNumber G)

/-- A unit interval graph is an interval graph: replace the point `pos v` by the interval
`[pos v - 1/2, pos v + 1/2]`, two of which meet exactly when the points are at distance at most
`1`. -/
noncomputable def intervalRep_of_metricRep {G : SimpleGraph V} (rep : MetricRep G ℝ) : IntervalRep G where
  left v := rep.pos v - 1 / 2
  right v := rep.pos v + 1 / 2
  left_le_right v := by linarith
  adj_iff u v := by
    rw [rep.adj_iff u v, Real.dist_eq, abs_le]
    constructor
    · rintro ⟨hne, h1, h2⟩
      exact ⟨hne, by linarith, by linarith⟩
    · rintro ⟨hne, h1, h2⟩
      exact ⟨hne, by linarith, by linarith⟩

/-- **`γ(G) = ρ(G)` for every unit interval graph**: the domination–packing ratio is exactly `1`
in dimension one, so the interesting behaviour of the ratio (at least `3` from below, at most
`25` from above in this formalization) is a genuinely two-dimensional phenomenon. -/
theorem dominationNumber_eq_packingNumber_of_metricRep_real [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (rep : MetricRep G ℝ) :
    dominationNumber G = packingNumber G :=
  dominationNumber_eq_packingNumber_of_intervalRep (intervalRep_of_metricRep rep)

/-! ## A concrete unit interval graph: the path -/

/-- The path `Pₙ` is a unit interval graph: place vertex `i` at the real number `i`. -/
def pathMetricRep (n : ℕ) : MetricRep (SimpleGraph.pathGraph n) ℝ where
  pos i := (i : ℕ)
  adj_iff u v := by
    rw [SimpleGraph.pathGraph_adj, Real.dist_eq]
    constructor
    · rintro (h | h)
      · have hne : u ≠ v := by
          intro he; rw [he] at h; omega
        refine ⟨hne, ?_⟩
        have hcast : ((v : ℕ) : ℝ) = ((u : ℕ) : ℝ) + 1 := by exact_mod_cast h.symm
        rw [hcast]
        rw [abs_le]
        constructor <;> linarith
      · have hne : u ≠ v := by
          intro he; rw [he] at h; omega
        refine ⟨hne, ?_⟩
        have hcast : ((u : ℕ) : ℝ) = ((v : ℕ) : ℝ) + 1 := by exact_mod_cast h.symm
        rw [hcast]
        rw [abs_le]
        constructor <;> linarith
    · rintro ⟨hne, hle⟩
      rw [abs_le] at hle
      have h1 : ((u : ℕ) : ℝ) ≤ ((v : ℕ) : ℝ) + 1 := by linarith [hle.2]
      have h2 : ((v : ℕ) : ℝ) ≤ ((u : ℕ) : ℝ) + 1 := by linarith [hle.1]
      have h1' : (u : ℕ) ≤ (v : ℕ) + 1 := by exact_mod_cast h1
      have h2' : (v : ℕ) ≤ (u : ℕ) + 1 := by exact_mod_cast h2
      have hne' : (u : ℕ) ≠ (v : ℕ) := fun h => hne (Fin.ext h)
      omega

/-- Non-vacuity of the greedy theorem: it re-derives `γ(Pₙ) = ρ(Pₙ)` for every path. -/
theorem pathGraph_dominationNumber_eq_packingNumber_of_greedy (n : ℕ) :
    dominationNumber (SimpleGraph.pathGraph n) = packingNumber (SimpleGraph.pathGraph n) :=
  dominationNumber_eq_packingNumber_of_metricRep_real (pathMetricRep n)

end DominationPacking