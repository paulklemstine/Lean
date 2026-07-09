/-
# Nontrivial cycles in Hamiltonian graphs with minimum degree ≥ 3

This file studies a **Hamiltonian graph** `G` on `n ≥ 3` vertices together with a
*fixed* Hamiltonian cycle, modelled as a `SimpleGraph` on the cyclic group `ZMod n`
whose consecutive-successor edges `i ~ i+1` are all present (`hcyc`).  A **chord** is
an edge that does not belong to this Hamiltonian cycle, i.e. an edge `a ~ b` with
`b ≠ a + 1` and `b ≠ a - 1`.

The research target
> a Hamiltonian graph with `δ(G) ≥ 3` contains a nontrivial cycle of length
> `n - O(n^{2/3})`
is far out of reach of a fully formal proof, but its qualitative core is provable and
is developed here from scratch:

* `every_vertex_has_chord` — minimum degree `≥ 3` forces a chord at every vertex
  (the Hamiltonian cycle already supplies two neighbours, so a third neighbour is a
  chord).  This is the "degree" input.
* `arcWalk` — the explicit walk `s → s+1 → ⋯ → s+k` along the Hamiltonian cycle.
* `chord_gives_cycle` — a chord `a ~ b` closes an arc of the Hamiltonian cycle into a
  genuine `IsCycle` of length `(b - a).val + 1`.  This is the "constructive" input.
* `hamiltonian_min_deg_three_long_nontrivial_cycle` — the headline: a Hamiltonian
  graph on `n ≥ 3` vertices with `δ(G) ≥ 3` contains a **nontrivial** cycle `c`
  (`c.length + 1 ≤ n`, so shorter than the whole Hamiltonian cycle) that is
  simultaneously **long**: `n + 2 ≤ 2 * c.length`, i.e. `c.length ≥ ⌈(n+2)/2⌉`.

The last theorem is a genuine (if quantitatively weak) instance of the research
statement: it is the "`n - O(n)`" version obtained by the elementary constructive
method, on which the poset / probabilistic refinements build.
-/
import Mathlib

open SimpleGraph

namespace HamiltonianNontrivialCycle

variable {n : ℕ} [NeZero n]

/-! ## The degree input: a chord exists at every vertex -/

/-- In a Hamiltonian graph (the cyclic successor edges `i ~ i+1` are present) with
minimum degree at least `3`, every vertex has a **chord**: a neighbour that is neither
the cyclic successor nor the cyclic predecessor.  (The hypotheses `hn` and `hcyc` are
part of the standing "Hamiltonian, `n ≥ 3`" setup; the pigeonhole argument itself only
needs `δ(G) ≥ 3`.) -/
theorem every_vertex_has_chord (hn : 3 ≤ n) (G : SimpleGraph (ZMod n)) [DecidableRel G.Adj]
    (hcyc : ∀ i : ZMod n, G.Adj i (i + 1))
    (hdeg : ∀ v : ZMod n, 3 ≤ G.degree v) (v : ZMod n) :
    ∃ w : ZMod n, G.Adj v w ∧ w ≠ v + 1 ∧ w ≠ v - 1 := by
  by_contra h
  push_neg at h
  have hsub : G.neighborFinset v ⊆ {v + 1, v - 1} := by
    intro w hw
    rw [mem_neighborFinset] at hw
    simp only [Finset.mem_insert, Finset.mem_singleton]
    by_cases hw1 : w = v + 1
    · exact Or.inl hw1
    · exact Or.inr (h w hw hw1)
  have hcard : G.degree v ≤ 2 := by
    have hle := Finset.card_le_card hsub
    rw [card_neighborFinset_eq_degree] at hle
    have h2 : ({v + 1, v - 1} : Finset (ZMod n)).card ≤ 2 :=
      (Finset.card_insert_le _ _).trans (by simp)
    omega
  have := hdeg v
  omega

/-! ## The constructive input: arcs of the Hamiltonian cycle -/

/-- The walk `s → s+1 → ⋯ → s+k` of length `k` along the Hamiltonian cycle. -/
def arcWalk (G : SimpleGraph (ZMod n)) (hcyc : ∀ i : ZMod n, G.Adj i (i + 1)) :
    (k : ℕ) → (s : ZMod n) → G.Walk s (s + (k : ZMod n))
  | 0, s => (Walk.nil).copy rfl (by simp)
  | k + 1, s =>
      (Walk.cons (hcyc s) (arcWalk G hcyc k (s + 1))).copy rfl (by push_cast; ring)

omit [NeZero n] in
@[simp] theorem arcWalk_length (G : SimpleGraph (ZMod n)) (hcyc : ∀ i : ZMod n, G.Adj i (i + 1))
    (k : ℕ) (s : ZMod n) : (arcWalk G hcyc k s).length = k := by
  induction k generalizing s with
  | zero => simp [arcWalk]
  | succ m ih => simp [arcWalk, ih]

/-
The support (vertex list) of `arcWalk` is `[s, s+1, …, s+k]`.
-/
omit [NeZero n] in
theorem arcWalk_support (G : SimpleGraph (ZMod n)) (hcyc : ∀ i : ZMod n, G.Adj i (i + 1))
    (k : ℕ) (s : ZMod n) :
    (arcWalk G hcyc k s).support = (List.range (k + 1)).map (fun i => s + (i : ZMod n)) := by
  induction' k with k ih generalizing s;
  · simp +decide [ arcWalk ];
  · simp_all +decide [ arcWalk, List.range_succ_eq_map ];
    induction ( List.range k ) <;> simp_all +decide;
    ring

/-
If `k + 1 ≤ n`, the `k+1` vertices of the arc are distinct, so the arc is a path.
-/
omit [NeZero n] in
theorem arcWalk_isPath (G : SimpleGraph (ZMod n)) (hcyc : ∀ i : ZMod n, G.Adj i (i + 1))
    (k : ℕ) (s : ZMod n) (hk : k + 1 ≤ n) : (arcWalk G hcyc k s).IsPath := by
  rw [ SimpleGraph.Walk.isPath_def ];
  convert List.Nodup.map_on _ ( List.nodup_range ) using 1;
  convert arcWalk_support G hcyc k s;
  rotate_left;
  use fun i => s + i;
  rotate_left;
  exact k + 1;
  · induction ( k + 1 ) <;> simp_all +decide [ List.range_succ ];
  · simp +decide [ ZMod.natCast_eq_natCast_iff' ];
    exact fun x hx y hy hxy => Nat.mod_eq_of_lt ( by linarith : x < n ) ▸ Nat.mod_eq_of_lt ( by linarith : y < n ) ▸ hxy

/-
The edges of `arcWalk` are the `k` consecutive Hamiltonian-cycle edges
`s(s+i, s+i+1)` for `i < k`.
-/
omit [NeZero n] in
theorem arcWalk_edges (G : SimpleGraph (ZMod n)) (hcyc : ∀ i : ZMod n, G.Adj i (i + 1))
    (k : ℕ) (s : ZMod n) :
    (arcWalk G hcyc k s).edges
      = (List.range k).map (fun i => s(s + (i : ZMod n), s + (i : ZMod n) + 1)) := by
  induction' k with k ih generalizing s <;> simp_all +decide [ arcWalk ];
  simp +decide [ List.range_succ_eq_map, add_assoc ];
  induction ( List.range k ) <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ]

/-
The chord edge `s(s+k, s)` closing the arc is **not** one of the arc's
Hamiltonian-cycle edges, provided `2 ≤ k < n`.
-/
theorem arcWalk_chord_not_edge (G : SimpleGraph (ZMod n)) (hcyc : ∀ i : ZMod n, G.Adj i (i + 1))
    (k : ℕ) (s : ZMod n) (hk2 : 2 ≤ k) (hkn : k < n) :
    s(s + (k : ZMod n), s) ∉ (arcWalk G hcyc k s).edges := by
  simp_all +decide [ arcWalk_edges, List.mem_map ];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod, Fin.ext_iff ];
  intro x hx; constructor <;> intros <;> simp_all +decide [ Nat.mod_eq_of_lt ] ;
  · rw [ Nat.mod_eq_of_lt ] at * <;> linarith;
  · linarith

/-! ## A chord produces a nontrivial cycle -/

/-
A chord `a ~ b` (with `b ≠ a ± 1`) closes an arc of the Hamiltonian cycle into a
genuine cycle of length `(b - a).val + 1`.
-/
theorem chord_gives_cycle (G : SimpleGraph (ZMod n))
    (hcyc : ∀ i : ZMod n, G.Adj i (i + 1)) (a b : ZMod n)
    (hab : G.Adj a b) (h1 : b ≠ a + 1) (h2 : b ≠ a - 1) :
    ∃ c : G.Walk b b, c.IsCycle ∧ c.length = (b - a).val + 1 := by
  -- Set `k := (b - a).val`.
  set k := (b - a).val with hk;
  -- Now let `p : G.Walk a b := (arcWalk G hcyc k a).copy rfl hval`. Define `c := Walk.cons hab.symm p : G.Walk b b` (here `hab.symm : G.Adj b a`).
  obtain ⟨p, hp⟩ : ∃ p : G.Walk a b, p.IsPath ∧ p.length = k ∧ p.edges = (List.range k).map (fun i => s(a + (i : ZMod n), a + (i : ZMod n) + 1)) := by
    use (arcWalk G hcyc k a).copy rfl (by
    simp +zetaDelta at *)
    generalize_proofs at *;
    simp +decide [ arcWalk_length, arcWalk_edges ];
    apply arcWalk_isPath;
    exact Nat.succ_le_of_lt ( ZMod.val_lt _ );
  refine' ⟨ SimpleGraph.Walk.cons hab.symm p, _, _ ⟩ <;> simp_all +decide [ SimpleGraph.Walk.cons_isCycle_iff ];
  grind

/-
The two arcs cut out by a chord have lengths `(b-a).val` and `(a-b).val` which sum
to `n`; hence the two resulting cycles have lengths summing to `n + 2`.
-/
theorem chord_val_add (a b : ZMod n) (hab : a ≠ b) :
    (b - a).val + (a - b).val = n := by
  have h_val_neg : ∀ x : ZMod n, x ≠ 0 → x.val + (-x).val = n := by
    intro x hx; rw [ add_comm, ZMod.neg_val ] ; simp +decide [ hx ] ;
    rw [ Nat.sub_add_cancel ( show x.val ≤ n from x.val_lt.le ) ];
  convert h_val_neg ( b - a ) ( sub_ne_zero.mpr <| Ne.symm hab ) using 2
  rw [neg_sub]

/-! ## Headline theorem -/

/-
**Main theorem.** A Hamiltonian graph on `n ≥ 3` vertices (the cyclic successor
edges `i ~ i+1` are all present) with minimum degree at least `3` contains a
**nontrivial** cycle `c` — strictly shorter than the whole Hamiltonian cycle
(`c.length + 1 ≤ n`) — that is at the same time **long**: `n + 2 ≤ 2 * c.length`,
i.e. its length is at least `⌈(n+2)/2⌉ > n/2`.

This is the elementary constructive core of the research statement (a chord decomposes
the Hamiltonian cycle into two arcs, and the longer arc gives a cycle of length
`≥ ⌈(n+2)/2⌉`).
-/
theorem hamiltonian_min_deg_three_long_nontrivial_cycle
    (hn : 3 ≤ n) (G : SimpleGraph (ZMod n)) [DecidableRel G.Adj]
    (hcyc : ∀ i : ZMod n, G.Adj i (i + 1)) (hdeg : ∀ v : ZMod n, 3 ≤ G.degree v) :
    ∃ (v : ZMod n) (c : G.Walk v v), c.IsCycle ∧ c.length + 1 ≤ n ∧ n + 2 ≤ 2 * c.length := by
  obtain ⟨ b, hb ⟩ := every_vertex_has_chord hn G hcyc hdeg 0;
  -- From the chord `a ~ b`, construct two cycles `c1` and `c2` of lengths `(b - a).val + 1` and `(a - b).val + 1`, respectively.
  obtain ⟨c1, hc1⟩ := chord_gives_cycle G hcyc 0 b hb.left hb.right.left hb.right.right
  obtain ⟨c2, hc2⟩ := chord_gives_cycle G hcyc b 0 hb.left.symm (by
  grind +ring) (by
  grind);
  have h_sum : (b - 0).val + (0 - b).val = n := by
    convert chord_val_add 0 b _ using 1 ; aesop;
  cases le_total c1.length c2.length <;> [ exact ⟨ 0, c2, hc2.1, by linarith [ SimpleGraph.Walk.IsCycle.three_le_length hc1.1, SimpleGraph.Walk.IsCycle.three_le_length hc2.1 ], by linarith [ SimpleGraph.Walk.IsCycle.three_le_length hc1.1, SimpleGraph.Walk.IsCycle.three_le_length hc2.1 ] ⟩ ; exact ⟨ b, c1, hc1.1, by linarith [ SimpleGraph.Walk.IsCycle.three_le_length hc1.1, SimpleGraph.Walk.IsCycle.three_le_length hc2.1 ], by linarith [ SimpleGraph.Walk.IsCycle.three_le_length hc1.1, SimpleGraph.Walk.IsCycle.three_le_length hc2.1 ] ⟩ ]

/-! ## Corollaries -/

/-- **Existence of a nontrivial cycle.** A Hamiltonian graph on `n ≥ 3` vertices with
`δ(G) ≥ 3` contains a cycle that is neither too short (`3 ≤ length`) nor the whole
Hamiltonian cycle (`length < n`). -/
theorem exists_nontrivial_cycle
    (hn : 3 ≤ n) (G : SimpleGraph (ZMod n)) [DecidableRel G.Adj]
    (hcyc : ∀ i : ZMod n, G.Adj i (i + 1)) (hdeg : ∀ v : ZMod n, 3 ≤ G.degree v) :
    ∃ (v : ZMod n) (c : G.Walk v v), c.IsCycle ∧ 3 ≤ c.length ∧ c.length < n := by
  obtain ⟨v, c, hcyc', hshort, hlong⟩ :=
    hamiltonian_min_deg_three_long_nontrivial_cycle hn G hcyc hdeg
  exact ⟨v, c, hcyc', hcyc'.three_le_length, by omega⟩

/-- **A cycle spanning more than half the graph.** Under the same hypotheses there is a
nontrivial cycle whose length exceeds `n / 2` (in fact `2 * length ≥ n + 2`). -/
theorem exists_cycle_longer_than_half
    (hn : 3 ≤ n) (G : SimpleGraph (ZMod n)) [DecidableRel G.Adj]
    (hcyc : ∀ i : ZMod n, G.Adj i (i + 1)) (hdeg : ∀ v : ZMod n, 3 ≤ G.degree v) :
    ∃ (v : ZMod n) (c : G.Walk v v), c.IsCycle ∧ n < 2 * c.length ∧ c.length < n := by
  obtain ⟨v, c, hcyc', hshort, hlong⟩ :=
    hamiltonian_min_deg_three_long_nontrivial_cycle hn G hcyc hdeg
  exact ⟨v, c, hcyc', by omega, by omega⟩

end HamiltonianNontrivialCycle