import Bridges.DominationPackingInterval

/-!
# `γ = ρ` for forests: an abstract greedy criterion and the Meir–Moon theorem

`Bridges.DominationPackingRatio` sets up the radius-`1` ball hypergraph of a graph, its
transversal number `γ` (the domination number) and its matching number `ρ` (the packing
number), and proves Erdős–Pósa style bounds `γ ≤ c·ρ`.
`Bridges.DominationPackingInterval` proves the *exact* statement `γ = ρ` for interval graphs by
an earliest-endpoint greedy.

This file isolates the combinatorial content of that greedy in a single hypothesis and uses it
to prove the classical theorem of Meir and Moon: **the domination number and the packing number
of a forest coincide.**

## Main definitions and results

* `HasGreedyCover G c` — for every nonempty finite set `S` of vertices there is a vertex
  `u ∈ S` and a set of at most `c` vertices dominating *every* `s ∈ S` whose ball meets the ball
  of `u`.  In words: some vertex of `S` has the part of its radius-`2` neighbourhood lying in
  `S` dominated by `c` vertices.
* `dominationNumber_le_mul_packingNumber_of_greedyCover` — this hypothesis alone gives
  `γ(G) ≤ c·ρ(G)`: iterating the greedy step produces a packing `P` and a dominating set of size
  at most `c·|P|`.  It is a greedy (local, one-step) counterpart of the covering engine of
  `Bridges.DominationPackingRatio`.
* `HasGreedyDominator G` — the case `c = 1`, with a single dominator `d`, and
  `dominationNumber_eq_packingNumber_of_greedyDominator` — this hypothesis already gives
  `γ(G) = ρ(G)`.
* `intervalRep_hasGreedyDominator` — interval graphs satisfy the criterion (take for `u` the
  vertex whose interval ends first and for `d` the vertex whose interval ends last among those
  meeting `u`), so the interval-graph theorem is an instance.
* `hasGreedyDominator_of_isAcyclic` — **forests satisfy the criterion**: root each component,
  take for `u` a vertex of `S` of maximal depth and for `d` its parent.  The tree lemmas
  `dist_ne_of_adj_of_isAcyclic` (adjacent vertices have different depths) and
  `eq_of_adj_of_dist_succ` (a vertex has at most one parent) are what makes the radius-`2`
  neighbourhood of a deepest vertex collapse onto the closed neighbourhood of its parent.
* `dominationNumber_eq_packingNumber_of_isAcyclic` — **Meir–Moon**: `γ(F) = ρ(F)` for every
  finite forest `F`.  In particular the domination–packing ratio, which is at least `3` for
  general planar graphs, equals `1` on forests.
-/

namespace DominationPacking

open Finset SemitotalDomination SimpleGraph

variable {V : Type*}

/-! ## An abstract greedy criterion -/

/-- **The quantitative greedy criterion.**  For every nonempty finite set `S` of vertices there
are `u ∈ S` and a set `D` of at most `c` vertices dominating every `s ∈ S` whose radius-`1` ball
meets that of `u` — that is, dominating the part of the radius-`2` neighbourhood of `u` that
lives in `S`. -/
def HasGreedyCover (G : SimpleGraph V) (c : ℕ) : Prop :=
  ∀ S : Finset V, S.Nonempty → ∃ u ∈ S, ∃ D : Finset V, D.card ≤ c ∧
    ∀ s ∈ S, ¬ Disjoint (ball G u) (ball G s) → (s ∈ D ∨ ∃ d ∈ D, G.Adj d s)

/-- **The greedy criterion.**  The case `c = 1` of `HasGreedyCover`: for every nonempty finite
set `S` of vertices there are `u ∈ S` and a *single* vertex `d` such that every `s ∈ S` whose
radius-`1` ball meets that of `u` lies in the radius-`1` ball of `d`. -/
def HasGreedyDominator (G : SimpleGraph V) : Prop :=
  ∀ S : Finset V, S.Nonempty → ∃ u ∈ S, ∃ d : V,
    ∀ s ∈ S, ¬ Disjoint (ball G u) (ball G s) → s ∈ ball G d

/-- **The greedy algorithm.**  Under the quantitative greedy criterion, every finite set `S` of
vertices admits a packing `P ⊆ S` and a set `D` with `|D| ≤ c·|P|` that dominates `S`:
repeatedly spend `c` dominators on the whole radius-`2` neighbourhood of the greedy vertex `u`,
and bank `u` itself as a packing centre. -/
theorem greedy_dominating_packing_of_greedyCover [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} {c : ℕ} (hG : HasGreedyCover G c) :
    ∀ (n : ℕ) (S : Finset V), S.card ≤ n →
      ∃ D P : Finset V, P ⊆ S ∧ IsPacking G P ∧ D.card ≤ c * P.card ∧
        ∀ v ∈ S, v ∈ D ∨ ∃ d ∈ D, G.Adj d v := by
  intro n
  induction n with
  | zero =>
    intro S hS
    have hSe : S = ∅ := Finset.card_eq_zero.mp (Nat.le_zero.mp hS)
    subst hSe
    exact ⟨∅, ∅, by simp, by simp [IsPacking], by simp, by simp⟩
  | succ n ih =>
    intro S hS
    rcases S.eq_empty_or_nonempty with rfl | hne
    · exact ⟨∅, ∅, by simp, by simp [IsPacking], by simp, by simp⟩
    classical
    obtain ⟨u, huS, Dc, hDc, hcov⟩ := hG S hne
    have hucov : u ∈ Dc ∨ ∃ d ∈ Dc, G.Adj d u :=
      hcov u huS (Set.not_disjoint_iff.mpr ⟨u, mem_ball_self G u, mem_ball_self G u⟩)
    set S' : Finset V := S.filter (fun x => ¬ (x ∈ Dc ∨ ∃ d ∈ Dc, G.Adj d x)) with hS'def
    have hS'sub : S' ⊆ S := Finset.filter_subset _ _
    have huS' : u ∉ S' := by
      rw [hS'def, Finset.mem_filter]
      exact fun h => h.2 hucov
    have hcard' : S'.card ≤ n := by
      have hlt : S'.card < S.card :=
        Finset.card_lt_card ⟨hS'sub, fun hsub => huS' (hsub huS)⟩
      omega
    obtain ⟨D', P', hP'sub, hP'pack, hcardD, hdom'⟩ := ih S' hcard'
    have hdisj : ∀ p ∈ P', Disjoint (ball G u) (ball G p) := by
      intro p hp
      by_contra hcon
      have hpS' : p ∈ S' := hP'sub hp
      have h1 := hcov p (hS'sub hpS') hcon
      exact (Finset.mem_filter.mp hpS').2 h1
    have huP' : u ∉ P' := fun h => huS' (hP'sub h)
    refine ⟨Dc ∪ D', insert u P', ?_, ?_, ?_, ?_⟩
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
    · have hcardP : (insert u P').card = P'.card + 1 := Finset.card_insert_of_notMem huP'
      calc (Dc ∪ D').card ≤ Dc.card + D'.card := Finset.card_union_le _ _
        _ ≤ c + c * P'.card := by omega
        _ = c * (P'.card + 1) := by ring
        _ = c * (insert u P').card := by rw [hcardP]
    · intro v hvS
      by_cases hv : v ∈ Dc ∨ ∃ d ∈ Dc, G.Adj d v
      · rcases hv with hmem | ⟨d, hd, hadj⟩
        · exact Or.inl (Finset.mem_union_left _ hmem)
        · exact Or.inr ⟨d, Finset.mem_union_left _ hd, hadj⟩
      · have hvS' : v ∈ S' := by rw [hS'def, Finset.mem_filter]; exact ⟨hvS, hv⟩
        rcases hdom' v hvS' with h | ⟨e, he, hadj⟩
        · exact Or.inl (Finset.mem_union_right _ h)
        · exact Or.inr ⟨e, Finset.mem_union_right _ he, hadj⟩

/-- **`γ ≤ c·ρ` from the quantitative greedy criterion.**  With `c = 1` this is the exact
statement `γ = ρ`; larger `c` interpolates towards the Erdős–Pósa bounds for geometric graph
classes. -/
theorem dominationNumber_le_mul_packingNumber_of_greedyCover [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} {c : ℕ} (hG : HasGreedyCover G c) :
    dominationNumber G ≤ c * packingNumber G := by
  obtain ⟨D, P, -, hPpack, hcard, hdom⟩ :=
    greedy_dominating_packing_of_greedyCover hG (Fintype.card V) Finset.univ (by simp)
  have h1 : dominationNumber G ≤ D.card :=
    Nat.sInf_le ⟨D, fun v => hdom v (Finset.mem_univ v), rfl⟩
  exact h1.trans (hcard.trans (Nat.mul_le_mul_left c (card_le_packingNumber hPpack)))

/-- The greedy criterion is the case `c = 1` of the quantitative one. -/
theorem hasGreedyCover_one_of_greedyDominator [DecidableEq V] {G : SimpleGraph V}
    (hG : HasGreedyDominator G) : HasGreedyCover G 1 := by
  intro S hne
  obtain ⟨u, huS, d, hd⟩ := hG S hne
  refine ⟨u, huS, {d}, by simp, ?_⟩
  intro s hsS hmeet
  rcases hd s hsS hmeet with rfl | hadj
  · exact Or.inl (Finset.mem_singleton_self _)
  · exact Or.inr ⟨d, Finset.mem_singleton_self _, hadj⟩

/-- `γ ≤ ρ` for every graph satisfying the greedy criterion. -/
theorem dominationNumber_le_packingNumber_of_greedyDominator [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (hG : HasGreedyDominator G) :
    dominationNumber G ≤ packingNumber G := by
  have := dominationNumber_le_mul_packingNumber_of_greedyCover
    (hasGreedyCover_one_of_greedyDominator hG)
  simpa using this

/-- **The greedy criterion forces the domination–packing ratio to be exactly `1`.** -/
theorem dominationNumber_eq_packingNumber_of_greedyDominator [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (hG : HasGreedyDominator G) :
    dominationNumber G = packingNumber G :=
  le_antisymm (dominationNumber_le_packingNumber_of_greedyDominator hG)
    (packingNumber_le_dominationNumber G)

/-! ## Interval graphs satisfy the criterion

This re-derives `dominationNumber_eq_packingNumber_of_intervalRep` from the abstract engine:
the earliest-endpoint greedy step is exactly an instance of `HasGreedyDominator`.
-/

/-- Interval graphs satisfy the greedy criterion: take for `u` the vertex of `S` whose interval
ends first and for `d` the vertex whose interval ends last among those meeting `u`. -/
theorem intervalRep_hasGreedyDominator [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    (rep : IntervalRep G) : HasGreedyDominator G := by
  classical
  intro S hne
  obtain ⟨u, huS, hu⟩ := S.exists_min_image (fun x => rep.right x) hne
  set N : Finset V := Finset.univ.filter
    (fun x => rep.left x ≤ rep.right u ∧ rep.left u ≤ rep.right x) with hN
  have huN : u ∈ N := by
    rw [hN, Finset.mem_filter]
    exact ⟨Finset.mem_univ u, rep.left_le_right u, rep.left_le_right u⟩
  obtain ⟨d, hdN, hd⟩ := N.exists_max_image (fun x => rep.right x) ⟨u, huN⟩
  have hdmem : rep.left d ≤ rep.right u ∧ rep.left u ≤ rep.right d := by
    rw [hN, Finset.mem_filter] at hdN; exact hdN.2
  refine ⟨u, huS, d, ?_⟩
  intro s hsS hmeet
  obtain ⟨w, hwu, hws⟩ := Set.not_disjoint_iff.mp hmeet
  have hwN : w ∈ N := by
    rw [hN, Finset.mem_filter]
    exact ⟨Finset.mem_univ w, rep.mem_ball_iff_meet.1 hwu⟩
  have hwd : rep.right w ≤ rep.right d := hd w hwN
  have hws' := rep.mem_ball_iff_meet.1 hws
  have hus : rep.right u ≤ rep.right s := hu s hsS
  exact rep.mem_ball_iff_meet.2 ⟨le_trans hws'.2 hwd, le_trans hdmem.1 hus⟩

/-! ## Rooted-tree lemmas

Throughout, "depth" means `G.dist r ·` for a fixed root `r`, and all statements are relative to
the component of `r` (vertices unreachable from `r` are irrelevant: their balls never meet).
-/

section Tree

variable [DecidableEq V] {G : SimpleGraph V}

/-- A shortest walk can be taken to be a path. -/
lemma exists_geodesic_path {r x : V} (h : G.Reachable r x) :
    ∃ p : G.Walk r x, p.IsPath ∧ p.length = G.dist r x := by
  obtain ⟨p, hp⟩ := h.exists_walk_length_eq_dist
  refine ⟨p.bypass, p.bypass_isPath, le_antisymm ?_ (SimpleGraph.dist_le _)⟩
  exact hp ▸ p.length_bypass_le

/-- Every vertex of a geodesic splits its length: distances add along a shortest walk. -/
lemma dist_add_dist_of_mem_geodesic {r x v : V} (p : G.Walk r x)
    (hp : p.length = G.dist r x) (hv : v ∈ p.support) :
    G.dist r v + G.dist v x = G.dist r x := by
  have hsplit := p.take_spec hv
  have hlen : (p.takeUntil v hv).length + (p.dropUntil v hv).length = p.length := by
    rw [← SimpleGraph.Walk.length_append, hsplit]
  have h1 : G.dist r v ≤ (p.takeUntil v hv).length := SimpleGraph.dist_le _
  have h2 : G.dist v x ≤ (p.dropUntil v hv).length := SimpleGraph.dist_le _
  have hreach : G.Reachable r v := ⟨p.takeUntil v hv⟩
  have h3 : G.dist r x ≤ G.dist r v + G.dist v x := hreach.dist_triangle_left x
  omega

/-- A vertex on a geodesic from `r` to `x`, other than `x` itself, is strictly closer to `r`. -/
lemma dist_lt_of_mem_geodesic_support {r x v : V} (p : G.Walk r x)
    (hp : p.length = G.dist r x) (hv : v ∈ p.support) (hne : v ≠ x) :
    G.dist r v < G.dist r x := by
  have hsum := dist_add_dist_of_mem_geodesic p hp hv
  have hpos : 0 < G.dist v x := by
    rcases Nat.eq_zero_or_pos (G.dist v x) with h | h
    · rcases SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable.mp h with rfl | hnr
      · exact absurd rfl hne
      · exact absurd (⟨p.dropUntil v hv⟩ : G.Reachable v x) hnr
    · exact h
  omega

omit [DecidableEq V] in
/-- Adjacent vertices are at distance at most one apart in depth. -/
lemma dist_le_succ_of_adj {r a b : V} (hra : G.Reachable r a) (hab : G.Adj a b) :
    G.dist r b ≤ G.dist r a + 1 := by
  have h1 : G.dist a b ≤ 1 := by
    simpa using SimpleGraph.dist_le (SimpleGraph.Walk.cons hab SimpleGraph.Walk.nil)
  exact le_trans (hra.dist_triangle_left b) (by omega)

/-- **In a forest, adjacent vertices have different depths.**  Otherwise the geodesic to one of
them, extended by the edge, would be a second path to the other one. -/
lemma dist_ne_of_adj_of_isAcyclic (hac : G.IsAcyclic) {r x y : V}
    (hrx : G.Reachable r x) (hxy : G.Adj x y) : G.dist r x ≠ G.dist r y := by
  intro heq
  obtain ⟨p, hpath, hlen⟩ := exists_geodesic_path hrx
  have hy : y ∉ p.support := by
    intro hmem
    have := dist_lt_of_mem_geodesic_support p hlen hmem hxy.ne'
    omega
  have hq : (p.concat hxy).IsPath := hpath.concat hy hxy
  obtain ⟨q, hqpath, hqlen⟩ := exists_geodesic_path (hrx.trans hxy.reachable)
  have hpaths := (SimpleGraph.isAcyclic_iff_path_unique.mp hac)
    (⟨p.concat hxy, hq⟩ : G.Path r y) ⟨q, hqpath⟩
  have hwalk : p.concat hxy = q := congrArg Subtype.val hpaths
  have hlen2 : (p.concat hxy).length = q.length := congrArg SimpleGraph.Walk.length hwalk
  rw [SimpleGraph.Walk.length_concat, hlen, hqlen] at hlen2
  omega

/-- **In a forest, a vertex has at most one parent**: two neighbours of `w` that are both one
step closer to the root coincide. -/
lemma eq_of_adj_of_dist_succ (hac : G.IsAcyclic) {r w x y : V}
    (hrw : G.Reachable r w) (hxw : G.Adj x w) (hyw : G.Adj y w)
    (hx : G.dist r x + 1 = G.dist r w) (hy : G.dist r y + 1 = G.dist r w) : x = y := by
  have hrx : G.Reachable r x := hrw.trans hxw.symm.reachable
  have hry : G.Reachable r y := hrw.trans hyw.symm.reachable
  obtain ⟨p, hpp, hpl⟩ := exists_geodesic_path hrx
  obtain ⟨q, hqp, hql⟩ := exists_geodesic_path hry
  have hwp : w ∉ p.support := by
    intro hmem
    have := dist_add_dist_of_mem_geodesic p hpl hmem
    omega
  have hwq : w ∉ q.support := by
    intro hmem
    have := dist_add_dist_of_mem_geodesic q hql hmem
    omega
  have h1 : (p.concat hxw).IsPath := hpp.concat hwp hxw
  have h2 : (q.concat hyw).IsPath := hqp.concat hwq hyw
  have hpaths := (SimpleGraph.isAcyclic_iff_path_unique.mp hac)
    (⟨p.concat hxw, h1⟩ : G.Path r w) ⟨q.concat hyw, h2⟩
  have hwalk : p.concat hxw = q.concat hyw := congrArg Subtype.val hpaths
  have hpen := congrArg SimpleGraph.Walk.penultimate hwalk
  rwa [SimpleGraph.Walk.penultimate_concat, SimpleGraph.Walk.penultimate_concat] at hpen

/-- Every vertex at positive depth has a parent: a neighbour one step closer to the root. -/
lemma exists_dist_parent {r x : V} (hrx : G.Reachable r x) (hpos : 0 < G.dist r x) :
    ∃ d : V, G.Adj d x ∧ G.dist r d + 1 = G.dist r x := by
  obtain ⟨p, -, hlen⟩ := exists_geodesic_path hrx
  have hnn : ¬ p.reverse.Nil := by
    rw [SimpleGraph.Walk.nil_iff_length_eq, SimpleGraph.Walk.length_reverse]
    omega
  refine ⟨p.reverse.snd, (SimpleGraph.Walk.adj_snd hnn).symm, ?_⟩
  have htail : p.reverse.tail.length + 1 = p.reverse.length :=
    SimpleGraph.Walk.length_tail_add_one hnn
  have hrev : p.reverse.length = G.dist r x := by
    rw [SimpleGraph.Walk.length_reverse, hlen]
  have hle : G.dist r p.reverse.snd ≤ p.reverse.tail.reverse.length :=
    SimpleGraph.dist_le _
  rw [SimpleGraph.Walk.length_reverse] at hle
  have hreach : G.Reachable r p.reverse.snd := ⟨p.reverse.tail.reverse⟩
  have hadj : G.Adj p.reverse.snd x := (SimpleGraph.Walk.adj_snd hnn).symm
  have hge : G.dist r x ≤ G.dist r p.reverse.snd + 1 := dist_le_succ_of_adj hreach hadj
  omega

end Tree

/-! ## Forests satisfy the greedy criterion: the Meir–Moon theorem -/

/-- **Forests satisfy the greedy criterion.**  Root the component of an arbitrary vertex `r` of
`S`, take for `u` a vertex of `S ∩ component(r)` of maximal depth, and for `d` the parent of `u`
(or `u = r` itself if `u` is the root).  Every `s ∈ S` at distance at most `2` from `u` is then
in the closed neighbourhood of `d`: a neighbour of `u` in `S` is necessarily its parent, and a
vertex of `S` at distance `2` from `u` either hangs off the parent of `u` or is a second parent
of a child of `u`, hence equals `u`. -/
theorem hasGreedyDominator_of_isAcyclic [Fintype V] [DecidableEq V] {G : SimpleGraph V}
    (hac : G.IsAcyclic) : HasGreedyDominator G := by
  classical
  intro S hne
  obtain ⟨r, hrS⟩ := hne
  set C : Finset V := S.filter (fun x => G.Reachable r x) with hCdef
  have hrC : r ∈ C := by
    rw [hCdef, Finset.mem_filter]
    exact ⟨hrS, SimpleGraph.Reachable.refl r⟩
  obtain ⟨u, huC, hu⟩ := C.exists_max_image (fun x => G.dist r x) ⟨r, hrC⟩
  have huS : u ∈ S := (Finset.mem_filter.mp huC).1
  have hru : G.Reachable r u := (Finset.mem_filter.mp huC).2
  -- a vertex of `S` whose ball meets that of `u` is reachable and no deeper than `u`
  have hkey : ∀ s ∈ S, ¬ Disjoint (ball G u) (ball G s) →
      G.Reachable r s ∧ G.dist r s ≤ G.dist r u ∧
        (s = u ∨ G.Adj u s ∨ ∃ z : V, G.Adj u z ∧ G.Adj s z) := by
    intro s hsS hmeet
    obtain ⟨w, hwu, hws⟩ := Set.not_disjoint_iff.mp hmeet
    have hwu' : w = u ∨ G.Adj u w := hwu
    have hws' : w = s ∨ G.Adj s w := hws
    have hrw : G.Reachable r w := by
      rcases hwu' with hw | hadj
      · exact hw ▸ hru
      · exact hru.trans hadj.reachable
    have hrs : G.Reachable r s := by
      rcases hws' with hw | hadj
      · exact hw ▸ hrw
      · exact hrw.trans hadj.symm.reachable
    have hsC : s ∈ C := by
      rw [hCdef, Finset.mem_filter]
      exact ⟨hsS, hrs⟩
    refine ⟨hrs, hu s hsC, ?_⟩
    rcases hwu' with hwu1 | hwu2
    · rcases hws' with hws1 | hws2
      · exact Or.inl (hws1.symm.trans hwu1)
      · exact Or.inr (Or.inl ((hwu1 ▸ hws2 : G.Adj s u).symm))
    · rcases hws' with hws1 | hws2
      · exact Or.inr (Or.inl (hws1 ▸ hwu2))
      · exact Or.inr (Or.inr ⟨w, hwu2, hws2⟩)
  rcases Nat.eq_zero_or_pos (G.dist r u) with hzero | hpos
  · -- `u` is the root: it is its own dominator
    have hur : u = r := by
      rcases SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable.mp hzero with h | h
      · exact h.symm
      · exact absurd hru h
    refine ⟨u, huS, u, ?_⟩
    intro s hsS hmeet
    obtain ⟨hrs, hsle, -⟩ := hkey s hsS hmeet
    have hs0 : G.dist r s = 0 := by omega
    have : s = r := by
      rcases SimpleGraph.dist_eq_zero_iff_eq_or_not_reachable.mp hs0 with h | h
      · exact h.symm
      · exact absurd hrs h
    exact Or.inl (this.trans hur.symm)
  · obtain ⟨d, hdu, hdist⟩ := exists_dist_parent hru hpos
    refine ⟨u, huS, d, ?_⟩
    intro s hsS hmeet
    obtain ⟨hrs, hsle, hcase⟩ := hkey s hsS hmeet
    -- a neighbour of `u` that is no deeper than `u` must be the parent `d`
    have hnbr : ∀ t : V, G.Reachable r t → G.dist r t ≤ G.dist r u → G.Adj t u → t = d := by
      intro t hrt htle hadj
      have hne := dist_ne_of_adj_of_isAcyclic hac hrt hadj
      have hle2 : G.dist r u ≤ G.dist r t + 1 := dist_le_succ_of_adj hrt hadj
      have htd : G.dist r t + 1 = G.dist r u := by omega
      exact eq_of_adj_of_dist_succ hac hru hadj hdu htd hdist
    rcases hcase with hsu | hadjus | ⟨z, hadj, hsz⟩
    · -- `s = u`, dominated by its parent
      exact Or.inr (by rw [hsu]; exact hdu)
    · -- `s` is a neighbour of `u`, hence the parent `d` itself
      exact Or.inl (hnbr s hrs hsle hadjus.symm)
    · -- `u - z - s` is a walk of length two
      have hrz : G.Reachable r z := hru.trans hadj.reachable
      have hzne : G.dist r z ≠ G.dist r u := (dist_ne_of_adj_of_isAcyclic hac hru hadj).symm
      have hz1 : G.dist r z ≤ G.dist r u + 1 := dist_le_succ_of_adj hru hadj
      have hz2 : G.dist r u ≤ G.dist r z + 1 := dist_le_succ_of_adj hrz hadj.symm
      rcases Nat.lt_or_ge (G.dist r z) (G.dist r u) with hlt | hge
      · -- `z` is the parent of `u`, hence `z = d`
        have hzd : z = d := hnbr z hrz (by omega) hadj.symm
        exact Or.inr (by rw [← hzd]; exact hsz.symm)
      · -- `z` is a child of `u`; then `s` is a second parent of `z`, so `s = u`
        have hzsucc : G.dist r u + 1 = G.dist r z := by omega
        have hs1 : G.dist r z ≤ G.dist r s + 1 := dist_le_succ_of_adj hrs hsz
        have hssucc : G.dist r s + 1 = G.dist r z := by omega
        have hsu : s = u := eq_of_adj_of_dist_succ hac hrz hsz hadj hssucc hzsucc
        exact Or.inr (by rw [hsu]; exact hdu)

/-- **Meir–Moon: the domination number and the packing number of a finite forest agree.**
Consequently the domination–packing ratio, which is at least `3` in general (and at least `2`
already for unit disk graphs), collapses to `1` on acyclic graphs. -/
theorem dominationNumber_eq_packingNumber_of_isAcyclic [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (hac : G.IsAcyclic) :
    dominationNumber G = packingNumber G :=
  dominationNumber_eq_packingNumber_of_greedyDominator (hasGreedyDominator_of_isAcyclic hac)

/-- `γ ≤ ρ` for forests; combined with `packingNumber_le_dominationNumber` this is the equality
above. -/
theorem dominationNumber_le_packingNumber_of_isAcyclic [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (hac : G.IsAcyclic) :
    dominationNumber G ≤ packingNumber G :=
  le_of_eq (dominationNumber_eq_packingNumber_of_isAcyclic hac)

/-- `γ(T) = ρ(T)` for every finite tree. -/
theorem dominationNumber_eq_packingNumber_of_isTree [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} (ht : G.IsTree) :
    dominationNumber G = packingNumber G :=
  dominationNumber_eq_packingNumber_of_isAcyclic ht.IsAcyclic

/-! ## A concrete forest: the star

A graph all of whose edges meet one fixed vertex is acyclic, and stars are the basic example.
(Forests are genuinely more general than the interval graphs of
`Bridges.DominationPackingInterval`: a subdivided claw is a tree but not an interval graph.)
-/

/-- A graph in which every edge is incident to one fixed vertex `c` is acyclic: a cycle would
have to pass through `c` twice, since the first and last steps of a cycle based at a vertex
`≠ c` would both have to go to `c`. -/
theorem isAcyclic_of_star [DecidableEq V] {G : SimpleGraph V} {c : V}
    (h : ∀ u v : V, G.Adj u v → u = c ∨ v = c) : G.IsAcyclic := by
  have key : ∀ (w : V) (q : G.Walk w w), q.IsCycle → w = c := by
    intro w q hq
    by_contra hwc
    have h1 : G.Adj w q.snd := SimpleGraph.Walk.adj_snd hq.not_nil
    have h2 : G.Adj q.penultimate w := SimpleGraph.Walk.adj_penultimate hq.not_nil
    have e1 : q.snd = c := by rcases h _ _ h1 with h' | h'; exacts [absurd h' hwc, h']
    have e2 : q.penultimate = c := by rcases h _ _ h2 with h' | h'; exacts [h', absurd h' hwc]
    exact hq.snd_ne_penultimate (e1.trans e2.symm)
  intro v p hp
  have hv : v = c := key v p hp
  have hsnd : G.Adj v p.snd := SimpleGraph.Walk.adj_snd hp.not_nil
  have hmem : p.snd ∈ p.support := SimpleGraph.Walk.getVert_mem_support p 1
  have hrot := key p.snd (p.rotate hmem) (hp.rotate hmem)
  rw [← hv] at hrot
  exact hsnd.ne' hrot

/-- The star `K_{1,n}`: a centre `none` joined to `n` leaves. -/
def starGraph (n : ℕ) : SimpleGraph (Option (Fin n)) where
  Adj u v := (u = none ∧ v ≠ none) ∨ (v = none ∧ u ≠ none)
  symm := by
    intro u v h
    rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inr ⟨h1, h2⟩
    · exact Or.inl ⟨h1, h2⟩
  loopless := ⟨by
    rintro u (⟨h1, h2⟩ | ⟨h1, h2⟩) <;> exact h2 h1⟩

lemma starGraph_isAcyclic (n : ℕ) : (starGraph n).IsAcyclic := by
  classical
  refine isAcyclic_of_star (c := (none : Option (Fin n))) ?_
  intro u v h
  rcases h with ⟨h1, -⟩ | ⟨h1, -⟩
  · exact Or.inl h1
  · exact Or.inr h1

/-- The centre alone dominates the star. -/
lemma starGraph_isDominatingSet_center (n : ℕ) :
    IsDominatingSet (starGraph n) {(none : Option (Fin n))} := by
  classical
  intro v
  rcases v with - | i
  · exact Or.inl (Finset.mem_singleton_self _)
  · exact Or.inr ⟨none, Finset.mem_singleton_self _, Or.inl ⟨rfl, by simp⟩⟩

/-- **A concrete instance of the forest theorem**: for the star `K_{1,n}` both the domination
number and the packing number equal `1`. -/
theorem starGraph_dominationNumber_eq_one (n : ℕ) :
    dominationNumber (starGraph n) = 1 ∧ packingNumber (starGraph n) = 1 := by
  classical
  have hle : dominationNumber (starGraph n) ≤ 1 :=
    Nat.sInf_le ⟨{none}, starGraph_isDominatingSet_center n, Finset.card_singleton _⟩
  have heq : dominationNumber (starGraph n) = packingNumber (starGraph n) :=
    dominationNumber_eq_packingNumber_of_isAcyclic (starGraph_isAcyclic n)
  have hge : 1 ≤ packingNumber (starGraph n) := one_le_packingNumber _
  omega

/-! ## Sharpness of the criterion

The greedy criterion is a genuine restriction: the `4`-cycle, a unit disk graph with `γ = 2` and
`ρ = 1`, fails it.  So `HasGreedyDominator` separates the classes on which the
domination–packing ratio collapses to `1` from the geometric classes studied in the paper.
-/

/-- The `4`-cycle does **not** satisfy the greedy criterion: it has `γ = 2` and `ρ = 1`. -/
theorem not_hasGreedyDominator_cycle4 : ¬ HasGreedyDominator cycle4 := by
  intro h
  have := dominationNumber_eq_packingNumber_of_greedyDominator h
  rw [cycle4_dominationNumber, cycle4_packingNumber] at this
  omega

/-- Consequently the `4`-cycle is not a forest — a machine-checked consistency check of the
Meir–Moon theorem against the extremal unit disk example of
`Bridges.DominationPackingRatio`. -/
theorem not_isAcyclic_cycle4 : ¬ cycle4.IsAcyclic := fun h =>
  not_hasGreedyDominator_cycle4 (hasGreedyDominator_of_isAcyclic h)

end DominationPacking