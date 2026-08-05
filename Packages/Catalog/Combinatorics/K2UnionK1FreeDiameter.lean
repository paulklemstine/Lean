import Mathlib
import Bridges.GraphTheory.K2UnionIndependentFree
import Combinatorics.K2UnionK1FreeInvariants
import Combinatorics.K2UnionK1FreeParameter

/-!
# Metric consequences of `(K₂ ∪ kK₁)`-freeness

The files `Bridges.GraphTheory.K2UnionIndependentFree`,
`Combinatorics.K2UnionK1FreeInvariants` and `Combinatorics.K2UnionK1FreeParameter`
develop `(K₂ ∪ kK₁)`-freeness, its induced-copy interface, the toughness interface and
the numerical invariant `freeParam`. This file adds the *metric* consequences of the
forbidden configuration, which are exactly the statements one needs in order to know that
a graph in this class is "small in the metric sense" before running a path-exchange
argument.

The engine is elementary but useful in its own right:

* `not_adj_of_dist_add_two_le` — vertices whose distances from a common base point differ
  by at least two are non-adjacent;
* `exists_dist_eq` — every intermediate distance below `G.dist u w` is realised;
* `exists_indepSet_dist` — consequently, for `a + 2 * m ≤ G.dist u w` there is an
  independent set of `m + 1` vertices, all at distance at least `a` from `u`
  (take the vertices at distances `a, a + 2, …, a + 2m`).

From this we deduce:

* `dist_le_two_mul_of_free` — **a connected `(K₂ ∪ kK₁)`-free graph has diameter at most
  `2k`** (for `k ≥ 1`), together with the `ℕ∞`-valued form `ediam_le_two_mul_of_free`,
  the contrapositive `not_free_of_two_mul_lt_dist`, and the special case
  `dist_le_two_of_free_one`;
* `dist_le_two_mul_freeParam` — the invariant-free version `diam G ≤ 2 · freeParam G`,
  valid for every connected finite graph;
* `dist_lt_two_mul_indepNum` — the companion bound `diam G < 2 · α(G)`, proved by the
  same distance-layer argument and used to see that the previous bound is a genuine
  strengthening (`freeParam ≤ α`);
* `pathGraph_not_free` and `lt_freeParam_pathGraph` — the path on `2k + 2` vertices is
  not `(K₂ ∪ kK₁)`-free;
* `pathGraph_free` and `pathGraph_dist_eq` — **sharpness**: the path on `2k + 1`
  vertices *is* `(K₂ ∪ kK₁)`-free and its endpoints are at distance exactly `2k`, so the
  bound `2k` is attained for every `k ≥ 1` and cannot be lowered. The freeness proof runs
  through the elementary counting lemma `card_le_of_gap`, which bounds the size of a set
  of naturals lying in an interval and containing no two consecutive elements.
-/

open Finset SimpleGraph K2UnionIndependentFree K2UnionK1FreeInvariants
  K2UnionK1FreeParameter

namespace K2UnionK1FreeDiameter

variable {V : Type*} {G : SimpleGraph V}

/-! ## Distance layers -/

/-- Two vertices whose distances from a common base point differ by at least two are
non-adjacent. -/
theorem not_adj_of_dist_add_two_le {u x y : V} (h : G.dist u x + 2 ≤ G.dist u y) :
    ¬ G.Adj x y := by
  intro hadj
  rcases hadj.diff_dist_adj (u := u) with h' | h' | h' <;> omega

/-- Every distance below `G.dist u w` is realised by some vertex. -/
theorem exists_dist_eq {u w : V} (hr : G.Reachable u w) {i : ℕ} (hi : i ≤ G.dist u w) :
    ∃ x, G.dist u x = i := by
  classical
  induction hd : G.dist u w generalizing w with
  | zero =>
      refine ⟨u, ?_⟩
      have hi0 : i = 0 := by omega
      simp [hi0]
  | succ d ih =>
      rcases Nat.lt_or_ge i (d + 1) with hlt | hge
      · obtain ⟨p, hp⟩ := hr.exists_walk_length_eq_dist
        have hnil : ¬ p.Nil := by
          rw [SimpleGraph.Walk.nil_iff_length_eq, hp, hd]; omega
        have hadj : G.Adj p.penultimate w := SimpleGraph.Walk.adj_penultimate hnil
        have hlen : p.dropLast.length = d := by
          rw [SimpleGraph.Walk.dropLast, SimpleGraph.Walk.take_length, hp, hd]
          omega
        have hrx : G.Reachable u p.penultimate := ⟨p.dropLast⟩
        have hle : G.dist u p.penultimate ≤ d := hlen ▸ SimpleGraph.dist_le p.dropLast
        have hge2 : d ≤ G.dist u p.penultimate := by
          have h2 := hadj.reachable.dist_triangle_right (G := G) u
          have h1 : G.dist p.penultimate w = 1 := SimpleGraph.dist_eq_one_iff_adj.mpr hadj
          omega
        exact ih hrx (by omega) (le_antisymm hle hge2)
      · exact ⟨w, by omega⟩

/-- **Distance layers give independent sets.** If `u` and `w` are at distance at least
`a + 2 * m`, then the vertices at distances `a, a + 2, …, a + 2 * m` from `u` form an
independent set of size `m + 1`, each element being at distance at least `a` from `u`. -/
theorem exists_indepSet_dist {u w : V} (hr : G.Reachable u w) (a m : ℕ)
    (h : a + 2 * m ≤ G.dist u w) :
    ∃ I : Finset V, I.card = m + 1 ∧ G.IsIndepSet (I : Set V) ∧
      ∀ x ∈ I, a ≤ G.dist u x := by
  classical
  have hex : ∀ j : ℕ, ∃ x : V, j ≤ m → G.dist u x = a + 2 * j := by
    intro j
    by_cases hj : j ≤ m
    · obtain ⟨x, hx⟩ := exists_dist_eq hr (i := a + 2 * j) (by omega)
      exact ⟨x, fun _ => hx⟩
    · exact ⟨u, fun hj' => absurd hj' hj⟩
  choose f hf using hex
  have hfd : ∀ j ∈ Finset.range (m + 1), G.dist u (f j) = a + 2 * j := by
    intro j hj
    simp only [Finset.mem_range] at hj
    exact hf j (by omega)
  refine ⟨(Finset.range (m + 1)).image f, ?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injOn, Finset.card_range]
    intro i hi j hj hij
    have h1 := hfd i hi
    have h2 := hfd j hj
    rw [hij] at h1
    omega
  · intro x hx y hy hne hadj
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_range] at hx hy
    obtain ⟨i, hi, rfl⟩ := hx
    obtain ⟨j, hj, rfl⟩ := hy
    have h1 := hfd i (Finset.mem_range.mpr hi)
    have h2 := hfd j (Finset.mem_range.mpr hj)
    have hij : i ≠ j := by rintro rfl; exact hne rfl
    rcases Nat.lt_or_ge i j with hlt | hge
    · exact not_adj_of_dist_add_two_le (u := u) (by omega) hadj
    · exact not_adj_of_dist_add_two_le (u := u) (by omega) hadj.symm
  · intro x hx
    simp only [Finset.mem_image, Finset.mem_range] at hx
    obtain ⟨j, hj, rfl⟩ := hx
    have := hfd j (Finset.mem_range.mpr hj)
    omega

/-! ## The diameter bound -/

/-- **Main theorem.** In a `(K₂ ∪ kK₁)`-free graph with `k ≥ 1`, any two vertices in the
same connected component are at distance at most `2 * k`. -/
theorem dist_le_two_mul_of_free {k : ℕ} (hk : 1 ≤ k) (hfree : IsK2UnionK1Free G k)
    {u w : V} (hr : G.Reachable u w) : G.dist u w ≤ 2 * k := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨v, hv⟩ := exists_dist_eq hr (i := 1) (by omega)
  have hadj : G.Adj u v := SimpleGraph.dist_eq_one_iff_adj.mp hv
  obtain ⟨I, hcard, hI, hdist⟩ := exists_indepSet_dist hr 3 (k - 1) (by omega)
  refine hfree hadj I (by omega) hI ?_
  intro x hx
  have hx3 : 3 ≤ G.dist u x := hdist x hx
  refine ⟨fun h => ?_, not_adj_of_dist_add_two_le (u := u) (by omega)⟩
  have : G.dist u x = 1 := SimpleGraph.dist_eq_one_iff_adj.mpr h
  omega

/-- Contrapositive of the diameter bound: two vertices far apart witness a forbidden
induced copy. -/
theorem not_free_of_two_mul_lt_dist {k : ℕ} (hk : 1 ≤ k) {u w : V} (hr : G.Reachable u w)
    (h : 2 * k < G.dist u w) : ¬ IsK2UnionK1Free G k :=
  fun hfree => absurd (dist_le_two_mul_of_free hk hfree hr) (not_le.mpr h)

/-- A `(K₂ ∪ K₁)`-free graph has diameter at most two. -/
theorem dist_le_two_of_free_one (hfree : IsK2UnionK1Free G 1) {u w : V}
    (hr : G.Reachable u w) : G.dist u w ≤ 2 := by
  simpa using dist_le_two_mul_of_free le_rfl hfree hr

/-- The `ℕ∞`-valued diameter of a connected `(K₂ ∪ kK₁)`-free graph is at most `2 * k`. -/
theorem ediam_le_two_mul_of_free (hG : G.Connected) {k : ℕ} (hk : 1 ≤ k)
    (hfree : IsK2UnionK1Free G k) : G.ediam ≤ (2 * k : ℕ) := by
  refine SimpleGraph.ediam_le_iff.mpr fun u v => ?_
  have hr : G.Reachable u v := hG.preconnected u v
  rw [← hr.coe_dist_eq_edist]
  exact_mod_cast dist_le_two_mul_of_free hk hfree hr

/-- The invariant form: the diameter of a connected finite graph is at most twice its
freeness parameter. -/
theorem dist_le_two_mul_freeParam [Finite V] (hG : G.Connected) (u w : V) :
    G.dist u w ≤ 2 * freeParam G := by
  rcases Nat.eq_zero_or_pos (freeParam G) with h0 | hpos
  · have hbot : G = ⊥ := freeParam_eq_zero_iff.mp h0
    subst hbot
    simp [SimpleGraph.dist_bot]
  · exact dist_le_two_mul_of_free hpos (freeParam_spec G) (hG.preconnected u w)

/-- The companion bound: in a connected finite graph the diameter is smaller than twice
the independence number. -/
theorem dist_lt_two_mul_indepNum [Finite V] [Nonempty V] (hG : G.Connected) (u w : V) :
    G.dist u w < 2 * G.indepNum := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨I, hcard, hI, -⟩ :=
    exists_indepSet_dist (hG.preconnected u w) 0 G.indepNum (by omega)
  have hle : I.card ≤ G.indepNum := SimpleGraph.IsIndepSet.card_le_indepNum hI
  omega

/-! ## Sharpness -/

/-- **Sharpness.** The path on `2k + 2` vertices, whose diameter is `2k + 1`, is not
`(K₂ ∪ kK₁)`-free: the edge `{0, 1}` together with the vertices `3, 5, …, 2k + 1` is a
forbidden induced copy. Hence the bound `2k` of `dist_le_two_mul_of_free` is best
possible. -/
theorem pathGraph_not_free (k : ℕ) :
    ¬ IsK2UnionK1Free (pathGraph (2 * k + 2)) k := by
  classical
  intro hfree
  have hadj : (pathGraph (2 * k + 2)).Adj ⟨0, by omega⟩ ⟨1, by omega⟩ :=
    SimpleGraph.pathGraph_adj.mpr (Or.inl rfl)
  set F : Fin k → Fin (2 * k + 2) :=
    fun j => ⟨2 * (j : ℕ) + 3, by have := j.isLt; omega⟩ with hF
  have hFval : ∀ j : Fin k, (F j : ℕ) = 2 * (j : ℕ) + 3 := fun j => rfl
  have hFinj : Function.Injective F := by
    intro i j hij
    have := congrArg (fun x : Fin (2 * k + 2) => (x : ℕ)) hij
    simp only [hFval] at this
    exact Fin.ext (by omega)
  refine hfree hadj (Finset.univ.image F) ?_ ?_ ?_
  · rw [Finset.card_image_of_injective _ hFinj, Finset.card_univ, Fintype.card_fin]
  · intro x hx y hy hne hxy
    simp only [Finset.coe_image, Finset.coe_univ, Set.image_univ, Set.mem_range] at hx hy
    obtain ⟨i, rfl⟩ := hx
    obtain ⟨j, rfl⟩ := hy
    have hij : (i : ℕ) ≠ (j : ℕ) := fun h => hne (congrArg F (Fin.ext h))
    rw [SimpleGraph.pathGraph_adj, hFval, hFval] at hxy
    omega
  · intro x hx
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hx
    obtain ⟨j, rfl⟩ := hx
    constructor <;> rw [SimpleGraph.pathGraph_adj] <;>
      simp only [hFval] <;> omega

/-- Consequently the freeness parameter of the path on `2k + 2` vertices exceeds `k`. -/
theorem lt_freeParam_pathGraph (k : ℕ) :
    k < freeParam (pathGraph (2 * k + 2)) := by
  by_contra hcon
  exact pathGraph_not_free k (freeParam_le_iff.mp (not_lt.mp hcon))

/-- **A counting lemma.** A set of naturals contained in the interval `[a, b]` and
containing no two consecutive elements has at most `(b - a) / 2 + 1` elements. -/
theorem card_le_of_gap {I : Finset ℕ} {a b : ℕ}
    (hgap : ∀ x ∈ I, ∀ y ∈ I, x < y → x + 2 ≤ y)
    (hlow : ∀ x ∈ I, a ≤ x) (hhigh : ∀ x ∈ I, x ≤ b) :
    2 * I.card ≤ (b - a) + 2 := by
  classical
  have hsub : I.image (fun x => (x - a) / 2) ⊆ Finset.range ((b - a) / 2 + 1) := by
    intro y hy
    simp only [Finset.mem_image] at hy
    obtain ⟨x, hx, rfl⟩ := hy
    have h1 := hlow x hx
    have h2 := hhigh x hx
    simp only [Finset.mem_range]
    omega
  have hinj : Set.InjOn (fun x => (x - a) / 2) I := by
    intro x hx y hy hxy
    by_contra hne
    simp only at hxy
    rcases Nat.lt_or_ge x y with h | h
    · have := hgap x hx y hy h
      have h1 := hlow x hx
      omega
    · have hlt : y < x := by omega
      have := hgap y hy x hx hlt
      have h1 := hlow y hy
      omega
  have hcard : I.card ≤ (b - a) / 2 + 1 :=
    calc I.card = (I.image (fun x => (x - a) / 2)).card := (Finset.card_image_of_injOn hinj).symm
    _ ≤ ((b - a) / 2 + 1) := by simpa using Finset.card_le_card hsub
  omega

/-- **The path on `2k + 1` vertices is `(K₂ ∪ kK₁)`-free.** Deleting the four positions
`a - 1, a, a + 1, a + 2` around an edge `{a, a + 1}` leaves two intervals whose
non-consecutive subsets have at most `k - 1` elements in total. -/
theorem pathGraph_free (k : ℕ) : IsK2UnionK1Free (pathGraph (2 * k + 1)) k := by
  classical
  intro u v huv I hcard hI hanti
  have huv' := SimpleGraph.pathGraph_adj.mp huv
  set a := min (u : ℕ) (v : ℕ) with ha
  have hale : a + 1 ≤ 2 * k := by
    have hu := u.isLt; have hv := v.isLt; omega
  set J : Finset ℕ := I.image Fin.val with hJ
  have hJcard : J.card = k := by
    rw [hJ, Finset.card_image_of_injective _ Fin.val_injective, hcard]
  have hJmem : ∀ x ∈ J, x ≤ 2 * k ∧ (x + 2 ≤ a ∨ a + 3 ≤ x) := by
    intro x hx
    simp only [hJ, Finset.mem_image] at hx
    obtain ⟨z, hz, rfl⟩ := hx
    obtain ⟨h1, h2⟩ := hanti z hz
    rw [SimpleGraph.pathGraph_adj] at h1 h2
    push_neg at h1 h2
    have := z.isLt
    omega
  have hJgap : ∀ x ∈ J, ∀ y ∈ J, x < y → x + 2 ≤ y := by
    intro x hx y hy hxy
    simp only [hJ, Finset.mem_image] at hx hy
    obtain ⟨z, hz, rfl⟩ := hx
    obtain ⟨w, hw, rfl⟩ := hy
    have hne : z ≠ w := by rintro rfl; omega
    have hnadj : ¬ (pathGraph (2 * k + 1)).Adj z w :=
      hI (by exact_mod_cast hz) (by exact_mod_cast hw) hne
    rw [SimpleGraph.pathGraph_adj] at hnadj
    push_neg at hnadj
    omega
  set L := J.filter (fun x => x < a) with hL
  set H := J.filter (fun x => ¬ (x < a)) with hH
  have hsum : L.card + H.card = k := by
    rw [hL, hH, Finset.card_filter_add_card_filter_not, hJcard]
  have hLbound : 2 * L.card ≤ a := by
    rcases Nat.lt_or_ge a 2 with hsmall | hbig
    · have hempty : L = ∅ := by
        rw [Finset.eq_empty_iff_forall_notMem]
        intro x hx
        simp only [hL, Finset.mem_filter] at hx
        have := hJmem x hx.1
        omega
      simp [hempty]
    · have := card_le_of_gap (I := L) (a := 0) (b := a - 2)
        (fun x hx y hy hxy =>
          hJgap x (Finset.mem_filter.mp hx).1 y (Finset.mem_filter.mp hy).1 hxy)
        (fun x _ => Nat.zero_le x)
        (fun x hx => by
          have h1 := hJmem x (Finset.mem_filter.mp hx).1
          have h2 := (Finset.mem_filter.mp hx).2
          omega)
      omega
  have hHbound : 2 * H.card ≤ 2 * k - a - 1 := by
    rcases Nat.lt_or_ge (2 * k) (a + 3) with hsmall | hbig
    · have hempty : H = ∅ := by
        rw [Finset.eq_empty_iff_forall_notMem]
        intro x hx
        simp only [hH, Finset.mem_filter] at hx
        have := hJmem x hx.1
        omega
      simp [hempty]
    · have := card_le_of_gap (I := H) (a := a + 3) (b := 2 * k)
        (fun x hx y hy hxy =>
          hJgap x (Finset.mem_filter.mp hx).1 y (Finset.mem_filter.mp hy).1 hxy)
        (fun x hx => by
          have h1 := hJmem x (Finset.mem_filter.mp hx).1
          have h2 := (Finset.mem_filter.mp hx).2
          omega)
        (fun x hx => (hJmem x (Finset.mem_filter.mp hx).1).1)
      omega
  omega

/-- Vertex labels change by at most one along an edge of a path graph, so the label
difference is a lower bound for the length of any walk. -/
theorem val_sub_le_walk_length {n : ℕ} {i j : Fin n} (p : (pathGraph n).Walk i j) :
    (j : ℕ) - (i : ℕ) ≤ p.length := by
  induction p with
  | nil => simp
  | @cons x y z h p ih =>
      have hadj := SimpleGraph.pathGraph_adj.mp h
      simp only [SimpleGraph.Walk.length_cons]
      omega

/-- The distance between two vertices of a path graph is at least their label
difference. -/
theorem pathGraph_dist_ge {n : ℕ} (i j : Fin (n + 1)) :
    (j : ℕ) - (i : ℕ) ≤ (pathGraph (n + 1)).dist i j := by
  obtain ⟨p, hp⟩ := ((pathGraph_connected n).preconnected i j).exists_walk_length_eq_dist
  have := val_sub_le_walk_length p
  omega

/-- **Sharpness of the diameter bound.** For every `k ≥ 1` the path on `2k + 1` vertices
is `(K₂ ∪ kK₁)`-free and its two endpoints are at distance exactly `2k`; hence the bound
of `dist_le_two_mul_of_free` is attained. -/
theorem pathGraph_dist_eq (k : ℕ) (hk : 1 ≤ k) :
    (pathGraph (2 * k + 1)).dist ⟨0, by omega⟩ ⟨2 * k, by omega⟩ = 2 * k := by
  refine le_antisymm ?_ ?_
  · exact dist_le_two_mul_of_free hk (pathGraph_free k)
      ((pathGraph_connected (2 * k)).preconnected _ _)
  · simpa using pathGraph_dist_ge (n := 2 * k) ⟨0, by omega⟩ ⟨2 * k, by omega⟩

end K2UnionK1FreeDiameter