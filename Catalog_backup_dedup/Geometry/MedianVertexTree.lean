import Mathlib

/-!
# The Median Vertex Uniqueness Theorem for trees

For three vertices `a b c` of a tree there is a unique *median* vertex `m`, i.e. a unique
vertex lying simultaneously on the metric interval between each pair of the three vertices.

The metric interval between `u` and `v` is
`interval G u v = {w | dist u w + dist w v = dist u v}`,
the set of vertices lying on some shortest `u`–`v` walk.

The development is deliberately *non-circular*: the main theorem
`tree_median_existsUnique` is proved from primitive Mathlib tree facts
(`SimpleGraph.IsTree.existsUnique_path`, connectivity, shortest-walk facts) only, via a
chain of helper lemmas with names distinct from the main theorem.
-/

open SimpleGraph

namespace MedianVertexTree

variable {V : Type*} {G : SimpleGraph V}

/-- The metric interval between `u` and `v`: vertices on a shortest `u`–`v` walk. -/
def interval (G : SimpleGraph V) (u v : V) : Set V :=
  {w | G.dist u w + G.dist w v = G.dist u v}

@[simp] lemma mem_interval {u v w : V} :
    w ∈ interval G u v ↔ G.dist u w + G.dist w v = G.dist u v := Iff.rfl

lemma left_mem_interval (u v : V) : u ∈ interval G u v := by
  simp [interval]

lemma right_mem_interval (u v : V) : v ∈ interval G u v := by
  simp [interval]

lemma mem_interval_comm {u v w : V} : w ∈ interval G u v ↔ w ∈ interval G v u := by
  simp only [interval, Set.mem_setOf_eq]
  rw [G.dist_comm (u := u) (v := w), G.dist_comm (u := w) (v := v), G.dist_comm (u := u) (v := v)]
  omega

/-
In a tree, every simple path between two vertices realises the distance, i.e. is a geodesic.
-/
lemma tree_path_length_eq_dist (hT : G.IsTree) {u v : V} (p : G.Walk u v) (hp : p.IsPath) :
    p.length = G.dist u v := by
  obtain ⟨q, hq⟩ : ∃ q : G.Walk u v, q.length = G.dist u v := by
    convert hT.1 u v |> fun h => h.exists_walk_length_eq_dist;
  have h_unique : ∀ r s : G.Walk u v, r.IsPath → s.IsPath → r = s := by
    exact fun r s hr hs => ExistsUnique.unique ( hT.existsUnique_path u v ) hr hs;
  rw [ ← hq, h_unique p q hp (q.isPath_of_length_eq_dist hq) ]

/-- The unique simple path between `u` and `v` in a tree. -/
noncomputable def treePath (hT : G.IsTree) (u v : V) : G.Walk u v :=
  (hT.existsUnique_path u v).choose

lemma treePath_isPath (hT : G.IsTree) (u v : V) : (treePath hT u v).IsPath :=
  (hT.existsUnique_path u v).choose_spec.1

/-- Uniqueness of paths in a tree: any path equals the canonical `treePath`. -/
lemma eq_treePath (hT : G.IsTree) {u v : V} (p : G.Walk u v) (hp : p.IsPath) :
    p = treePath hT u v :=
  (hT.existsUnique_path u v).choose_spec.2 p hp

lemma treePath_length (hT : G.IsTree) (u v : V) :
    (treePath hT u v).length = G.dist u v :=
  tree_path_length_eq_dist hT _ (treePath_isPath hT u v)

/-
**Step 2.** Metric-interval / path-support equivalence: a vertex is on the metric interval
between `u` and `v` iff it lies on the unique `u`–`v` path.
-/
lemma mem_interval_iff_mem_treePath_support (hT : G.IsTree) (u v w : V) :
    w ∈ interval G u v ↔ w ∈ (treePath hT u v).support := by
  constructor <;> intro h;
  · -- Let `q1` and `q2` be the tree paths from `u` to `w` and from `w` to `v`, respectively.
    set q1 := treePath hT u w
    set q2 := treePath hT w v;
    -- By definition of `treePath`, we know that `q1.append q2` is a path from `u` to `v`.
    have hq1q2_path : (q1.append q2).IsPath := by
      convert SimpleGraph.Walk.isPath_of_length_eq_dist _ _;
      rw [ ← h, SimpleGraph.Walk.length_append, treePath_length hT, treePath_length hT ];
    exact eq_treePath hT _ hq1q2_path ▸ by aesop;
  · -- By definition of `treePath`, we know that `treePath hT u v` is a path from `u` to `v`.
    have h_path : (treePath hT u v).IsPath := by
      grind +suggestions;
    obtain ⟨q₁, q₂, hq⟩ : ∃ q₁ : G.Walk u w, ∃ q₂ : G.Walk w v, (treePath hT u v) = q₁.append q₂ := by
      have := SimpleGraph.Walk.mem_support_iff_exists_append.mp h;
      exact this;
    grind +suggestions

/-
If two paths meet only at their shared endpoint, their concatenation is a path.
-/
lemma isPath_append_of_support_inter {u v w : V} (p : G.Walk u v) (q : G.Walk v w)
    (hp : p.IsPath) (hq : q.IsPath) (hdisj : ∀ x, x ∈ p.support → x ∈ q.support → x = v) :
    (p.append q).IsPath := by
  grind +suggestions

/-
The metric interval in a tree is finite (it is the support of a path).
-/
lemma interval_finite (hT : G.IsTree) (u v : V) : (interval G u v).Finite := by
  rw [ show interval G u v = { w | w ∈ ( treePath hT u v ).support } from Set.ext fun w => ( mem_interval_iff_mem_treePath_support hT u v w ) ] ; exact ( treePath hT u v ).support.finite_toSet;

/-
**Comparability / collinearity.** Two vertices on the geodesic from `a` to `b` are comparable:
one lies on the geodesic from `a` to the other.
-/
lemma interval_comparable (hT : G.IsTree) {a b x y : V}
    (hx : x ∈ interval G a b) (hy : y ∈ interval G a b) :
    x ∈ interval G a y ∨ y ∈ interval G a x := by
  by_contra! hxy;
  obtain ⟨p₁, hp₁⟩ : ∃ p₁ : G.Walk a x, p₁.IsPath ∧ ∃ p₂ : G.Walk x y, p₂.IsPath ∧ ∃ p₃ : G.Walk y b, p₃.IsPath ∧ p₁.append (p₂.append p₃) = treePath hT a b := by
    grind +suggestions;
  grind +suggestions

/-
Distance from `a` is injective on the geodesic `interval G a b`.
-/
lemma interval_dist_injective (hT : G.IsTree) {a b x y : V}
    (hx : x ∈ interval G a b) (hy : y ∈ interval G a b) (h : G.dist a x = G.dist a y) :
    x = y := by
  by_cases hxy : x ∈ interval G a y;
  · have h_reachable : G.Reachable x y := by
      exact hT.1 x y;
    grind +suggestions;
  · have := interval_comparable hT hx hy; simp_all +decide ;
    exact this.elim ( fun h => hxy.1 h.symm ) fun h => h ( hxy.2.symm )

/-
**Crux disjointness lemma.** If `m` is a distance-maximal common vertex of the geodesics
`interval G a b` and `interval G a c`, then the geodesics `interval G b m` and `interval G m c`
meet only at `m`.
-/
lemma meeting_disjoint (hT : G.IsTree) {a b c m x : V}
    (hmb : m ∈ interval G a b) (hmc : m ∈ interval G a c)
    (hmax : ∀ z, z ∈ interval G a b → z ∈ interval G a c → G.dist a z ≤ G.dist a m)
    (hxbm : x ∈ interval G b m) (hxmc : x ∈ interval G m c) : x = m := by
  by_contra h_neq;
  have h_dist_eq : G.dist a x = G.dist a m + G.dist m x := by
    have h_dist_eq : G.dist a x ≤ G.dist a m + G.dist m x := by
      exact (hT.isConnected).dist_triangle
    have h_dist_eq : G.dist a b ≤ G.dist a x + G.dist x b := by
      exact (hT.isConnected).dist_triangle
    simp_all +decide [ interval ];
    linarith [ show G.dist b x = G.dist x b from by rw [ SimpleGraph.dist_comm ], show G.dist x m = G.dist m x from by rw [ SimpleGraph.dist_comm ], show G.dist m b = G.dist b m from by rw [ SimpleGraph.dist_comm ] ];
  have h_dist_eq : x ∈ interval G a b ∧ x ∈ interval G a c := by
    simp_all +decide [ SimpleGraph.dist_comm ];
    grind;
  have := hmax x h_dist_eq.1 h_dist_eq.2;
  simp_all +decide [ SimpleGraph.dist_comm ];
  exact this.elim ( fun h => h_neq h.symm ) fun h => h ( hT.1 m x )

/-
A distance-maximal common vertex of `interval G a b` and `interval G a c` lies on
`interval G b c`.
-/
lemma meeting_mem_interval (hT : G.IsTree) {a b c m : V}
    (hmb : m ∈ interval G a b) (hmc : m ∈ interval G a c)
    (hmax : ∀ z, z ∈ interval G a b → z ∈ interval G a c → G.dist a z ≤ G.dist a m) :
    m ∈ interval G b c := by
  -- By `mem_interval_iff_mem_treePath_support`, $x \in \text{interval } G b m$ and $x \in \text{interval } G m c$, so conclude $x = m$.
  have h_walk_append : (treePath hT b m).append (treePath hT m c) = treePath hT b c := by
    apply eq_treePath hT;
    apply isPath_append_of_support_inter;
    · exact treePath_isPath hT b m;
    · exact treePath_isPath hT m c;
    · intros x hx_b_m hx_m_c
      have hx_interval_b_m : x ∈ interval G b m :=
        mem_interval_iff_mem_treePath_support hT b m x |>.2 hx_b_m
      have hx_interval_m_c : x ∈ interval G m c := by
        exact mem_interval_iff_mem_treePath_support hT m c x |>.2 hx_m_c
      exact meeting_disjoint hT hmb hmc hmax hx_interval_b_m hx_interval_m_c;
  convert mem_interval_iff_mem_treePath_support hT b c m |>.2 ?_ using 1;
  simp +decide [ ← h_walk_append ]

/-
**Existence** of a median vertex.
-/
lemma median_exists (hT : G.IsTree) (a b c : V) :
    ∃ m, m ∈ interval G a b ∧ m ∈ interval G b c ∧ m ∈ interval G a c := by
  obtain ⟨m, hm⟩ : ∃ m : V, m ∈ interval G a b ∧ m ∈ interval G a c ∧ ∀ z ∈ interval G a b ∩ interval G a c, G.dist a z ≤ G.dist a m := by
    obtain ⟨m, hm⟩ : ∃ m, m ∈ interval G a b ∩ interval G a c ∧ ∀ z ∈ interval G a b ∩ interval G a c, G.dist a z ≤ G.dist a m := by
      apply_rules [ Set.exists_max_image ];
      · exact Set.Finite.inter_of_left ( interval_finite hT a b ) _;
      · exact ⟨ a, left_mem_interval _ _, left_mem_interval _ _ ⟩;
    exact ⟨ m, hm.1.1, hm.1.2, hm.2 ⟩;
  refine' ⟨ m, hm.1, _, hm.2.1 ⟩;
  apply meeting_mem_interval;
  exacts [ hT, hm.1, hm.2.1, fun z hz1 hz2 => hm.2.2 z ⟨ hz1, hz2 ⟩ ]

/-
**Uniqueness** of the median vertex.
-/
lemma median_unique (hT : G.IsTree) {a b c m m' : V}
    (hm : m ∈ interval G a b ∧ m ∈ interval G b c ∧ m ∈ interval G a c)
    (hm' : m' ∈ interval G a b ∧ m' ∈ interval G b c ∧ m' ∈ interval G a c) :
    m = m' := by
  apply interval_dist_injective hT hm.left hm'.left;
  grind +suggestions

/-- **Median Vertex Uniqueness Theorem for trees.** For three vertices of a tree there is a
unique vertex lying on the metric interval between each of the three pairs. -/
theorem tree_median_existsUnique (hT : G.IsTree) (a b c : V) :
    ∃! m : V, m ∈ interval G a b ∧ m ∈ interval G b c ∧ m ∈ interval G a c := by
  obtain ⟨m, hm⟩ := median_exists hT a b c
  exact ⟨m, hm, fun m' hm' => (median_unique hT hm' hm)⟩

end MedianVertexTree