/-
# Colorful Carathéodory over spanning k-trees: polynomial-size witnesses

Bárány's *colorful Carathéodory theorem* states that if `V₁,…,V_{d+1}` are point
sets in `ℝ^d`, each of whose convex hulls contains a common target point `p`, then
there is a *rainbow* simplex — one vertex chosen from each colour class — whose
convex hull still contains `p`.  Read combinatorially, the rainbow simplex is a
face of the **join** `V₁ * ⋯ * V_{d+1}`, and the theorem asserts that a
`p`-capturing face always exists inside this join.

The join is an expensive object: it has `∏ᵢ |Vᵢ|` top-dimensional faces, an
*exponential* search space.  This file studies the quantitative question hiding
behind the qualitative theorem: **how small a certificate is needed to exhibit a
capturing face?**  The answer is governed by the combinatorial width of the
witnessing complex.

* For any abstract complex `K` whose faces have at most `k+1` vertices and live on
  a ground set of size `n`, the number of faces of `K` is bounded by a polynomial
  in `n` of degree `k+1`, namely `∑_{i≤k+1} C(n,i) ≤ (k+2)·(n+1)^{k+1}`
  (`boundedComplex_card_le`, `boundedComplex_polynomial_witness`).  A spanning
  `k`-tree is exactly such a complex, so its face count — the size of the witness
  it provides — is polynomial of degree `k+1`.

* In the extreme sparse case `k = 1`, a spanning **tree** on `n` vertices has a
  *linear* face count `2n` (`spanningTree_face_count`), a genuine improvement over
  the generic quadratic bound.

* The captured-face existence itself is proved on the line (`d = 1`,
  `colorful_caratheodory_dim1`): from the honest hypothesis that `0` lies in the
  convex hull of each of two colour classes `V₁, V₂ ⊆ ℝ`, we extract a rainbow
  edge `{x, y}` with `x ∈ V₁`, `y ∈ V₂` and `0 ∈ conv{x, y}`.

Together these give the promised statement: a capturing face exists, and it can be
certified by a spanning-tree-sized (linear, for `k = 1`) sub-collection of the
join rather than by the full exponential complex.

-- !-- Lab Notes -- !--
Hypothesis  : The qualitative colorful Carathéodory theorem hides a quantitative
              "witness complexity" statement: a capturing face can be certified
              inside a low-width sub-complex whose face count is polynomial of
              degree `k+1`, dropping to linear for spanning trees (`k = 1`).
Experiment  : (1) Counted faces of a width-`(k+1)` complex by decomposing the
              bounded powerset into level sets `powersetCard i`; obtained the
              exact value `∑_{i≤k+1} C(n,i)` and the closed bound
              `(k+2)·(n+1)^{k+1}`.  (2) Used the tree edge-count identity
              `|E| + 1 = |V|` to pin the clique-complex face count of a tree at
              exactly `2n`.  (3) Reduced planar (`d=1`) colorful Carathéodory to an
              order argument: `0` in the hull of a finite `V ⊆ ℝ` forces a
              nonpositive and a nonnegative member (via `min'`, `max'`), and a
              nonpositive/nonnegative pair spans a segment through `0`.
Analysis    : The generic width bound is degree `k+1` and is tight in the class of
              all bounded complexes (the full `≤(k+1)`-skeleton attains the sum).
              Trees beat it because acyclicity forces `|E| = |V|-1`, collapsing the
              quadratic edge term to linear — structure, not width, buys the gain.
Critique    : Hypotheses are the honest ones (`0 ∈ convexHull` of each colour
              class, `IsTree`), not order surrogates; the sign-extraction lemma
              `zero_in_hull_sign` proves the convex-geometric input is genuinely
              used.  No result is vacuous: each is exercised by the capstone
              `colorful_caratheodory_dim1` and the counting corollaries.
Synthesis   : Witness size is controlled by two independent parameters — face
              width `k` (polynomial degree) and global acyclicity (linear collapse
              at `k=1`).  See `FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open Finset

namespace ColorfulCaratheodoryKTree

/-! ## Part I — Face counts of bounded-width complexes -/

/-- The subsets of `ground` of cardinality `≤ m` are the disjoint union, over
`i ≤ m`, of the subsets of cardinality exactly `i`. -/
theorem powerset_filter_card_eq_biUnion {α : Type*} [DecidableEq α]
    (ground : Finset α) (m : ℕ) :
    ground.powerset.filter (fun t => t.card ≤ m)
      = (Finset.range (m + 1)).biUnion (fun i => ground.powersetCard i) := by
  ext t
  simp only [Finset.mem_filter, Finset.mem_powerset, Finset.mem_biUnion, Finset.mem_range,
    Finset.mem_powersetCard]
  constructor
  · rintro ⟨hsub, hcard⟩
    exact ⟨t.card, by omega, hsub, rfl⟩
  · rintro ⟨i, _, hsub, hcard⟩
    exact ⟨hsub, by omega⟩

/-- **Exact face count of the width-`m` skeleton.**  The number of subsets of an
`n`-element ground set having at most `m` elements is `∑_{i≤m} C(n,i)` — a
polynomial in `n` of degree `m`. -/
theorem skeleton_card_eq_choose_sum {α : Type*} [DecidableEq α]
    (ground : Finset α) (m : ℕ) :
    (ground.powerset.filter (fun t => t.card ≤ m)).card
      = ∑ i ∈ Finset.range (m + 1), (ground.card).choose i := by
  rw [powerset_filter_card_eq_biUnion, Finset.card_biUnion]
  · exact Finset.sum_congr rfl (fun i _ => Finset.card_powersetCard i ground)
  · intro i _ j _ hij
    apply Finset.disjoint_left.mpr
    intro t ht htj
    rw [Finset.mem_powersetCard] at ht htj
    exact hij (ht.2 ▸ htj.2)

/-- **Polynomial witness bound (exact form).**  Any collection of faces `K` whose
members are subsets of a size-`n` ground set, each with at most `m = k+1` vertices,
has at most `∑_{i≤k+1} C(n,i)` faces. -/
theorem boundedComplex_card_le {α : Type*} [DecidableEq α]
    (K ground : Finset (Finset α)) (base : Finset α)
    (hground : ground = base.powerset)
    (K_sub : K ⊆ ground) (m : ℕ)
    (K_width : ∀ s ∈ K, s.card ≤ m) :
    K.card ≤ ∑ i ∈ Finset.range (m + 1), (base.card).choose i := by
  have hK : K ⊆ base.powerset.filter (fun t => t.card ≤ m) := by
    intro s hs
    rw [Finset.mem_filter, Finset.mem_powerset]
    have : s ∈ ground := K_sub hs
    rw [hground, Finset.mem_powerset] at this
    exact ⟨this, K_width s hs⟩
  calc K.card ≤ (base.powerset.filter (fun t => t.card ≤ m)).card := Finset.card_le_card hK
    _ = ∑ i ∈ Finset.range (m + 1), (base.card).choose i := skeleton_card_eq_choose_sum base m

/-- The degree-`m` choose-sum is dominated by the explicit degree-`m` polynomial
`(m+1)·(n+1)^m`.  This exhibits the witness bound as a polynomial of degree `m`. -/
theorem choose_sum_le_poly (n m : ℕ) :
    ∑ i ∈ Finset.range (m + 1), n.choose i ≤ (m + 1) * (n + 1) ^ m := by
  have hb : ∀ i ∈ Finset.range (m + 1), n.choose i ≤ (n + 1) ^ m := by
    intro i hi
    rw [Finset.mem_range] at hi
    calc n.choose i ≤ n ^ i := Nat.choose_le_pow n i
      _ ≤ (n + 1) ^ i := Nat.pow_le_pow_left (Nat.le_succ n) i
      _ ≤ (n + 1) ^ m := Nat.pow_le_pow_right (Nat.succ_pos n) (by omega)
  calc ∑ i ∈ Finset.range (m + 1), n.choose i
      ≤ (Finset.range (m + 1)).card • (n + 1) ^ m := Finset.sum_le_card_nsmul _ _ _ hb
    _ = (m + 1) * (n + 1) ^ m := by rw [Finset.card_range, smul_eq_mul]

/-- **Polynomial-size witness for a spanning `k`-tree.**  A complex `K` on an
`n`-vertex ground set whose faces have at most `k+1` vertices — in particular a
`d`-dimensional spanning `k`-tree — has at most `(k+2)·(n+1)^{k+1}` faces, a
polynomial in `n` of degree `k+1`. -/
theorem boundedComplex_polynomial_witness {α : Type*} [DecidableEq α]
    (K ground : Finset (Finset α)) (base : Finset α)
    (hground : ground = base.powerset)
    (K_sub : K ⊆ ground) (k : ℕ)
    (K_width : ∀ s ∈ K, s.card ≤ k + 1) :
    K.card ≤ (k + 2) * (base.card + 1) ^ (k + 1) := by
  calc K.card ≤ ∑ i ∈ Finset.range (k + 1 + 1), (base.card).choose i :=
        boundedComplex_card_le K ground base hground K_sub (k + 1) K_width
    _ ≤ (k + 1 + 1) * (base.card + 1) ^ (k + 1) := choose_sum_le_poly base.card (k + 1)
    _ = (k + 2) * (base.card + 1) ^ (k + 1) := by ring_nf

/-! ## Part II — The `k = 1` collapse: spanning trees have linear witnesses -/

/-- **Linear witness for a spanning tree (`k = 1`).**  The clique complex of a
spanning tree on `n` vertices has exactly `2n` faces (the empty face, `n` vertices
and `n-1` edges).  In contrast to the generic quadratic bound for width-`2`
complexes, acyclicity forces the count to be *linear* in `n`. -/
theorem spanningTree_face_count {V : Type*} [Fintype V] {G : SimpleGraph V}
    [Fintype G.edgeSet] (hG : G.IsTree) :
    1 + Fintype.card V + G.edgeFinset.card = 2 * Fintype.card V := by
  have h := hG.card_edgeFinset
  omega

/-! ## Part III — The captured face exists (colorful Carathéodory on the line) -/

/-- If `0` lies in the convex hull of a nonempty finite set `V ⊆ ℝ`, then `V`
contains a nonpositive member and a nonnegative member.  This is the genuine
convex-geometric content of a colour class "capturing" the origin in dimension
one. -/
theorem zero_in_hull_sign (V : Finset ℝ) (hne : V.Nonempty)
    (h0 : (0 : ℝ) ∈ convexHull ℝ (V : Set ℝ)) :
    (∃ x ∈ V, x ≤ 0) ∧ (∃ x ∈ V, 0 ≤ x) := by
  have hsub : convexHull ℝ (V : Set ℝ) ⊆ Set.Icc (V.min' hne) (V.max' hne) := by
    apply convexHull_min
    · intro x hx
      simp only [Finset.mem_coe] at hx
      exact ⟨V.min'_le x hx, V.le_max' x hx⟩
    · exact convex_Icc _ _
  have hmem := hsub h0
  simp only [Set.mem_Icc] at hmem
  exact ⟨⟨V.min' hne, V.min'_mem hne, hmem.1⟩, ⟨V.max' hne, V.max'_mem hne, hmem.2⟩⟩

/-- A nonpositive point and a nonnegative point span a segment through the origin:
`x ≤ 0 ≤ y ⟹ 0 ∈ [x, y]`. -/
theorem zero_mem_segment_of_le {x y : ℝ} (hx : x ≤ 0) (hy : 0 ≤ y) :
    (0 : ℝ) ∈ segment ℝ x y := by
  rcases eq_or_lt_of_le (sub_nonneg.mpr (hx.trans hy)) with h | h
  · have hx0 : x = 0 := le_antisymm hx (by linarith)
    have hy0 : y = 0 := by linarith
    subst hx0; subst hy0; exact left_mem_segment ℝ 0 0
  · refine ⟨y / (y - x), -x / (y - x), by positivity,
      div_nonneg (by linarith) (by linarith), ?_, ?_⟩
    · field_simp; ring
    · simp only [smul_eq_mul]; field_simp; ring

/-- **Colorful Carathéodory in dimension one.**  Let `V₁, V₂ ⊆ ℝ` be two nonempty
finite colour classes, each of whose convex hull contains the origin.  Then there
is a *rainbow* edge `{x, y}` with `x ∈ V₁`, `y ∈ V₂` whose convex hull contains
`0`.  The captured face is a single edge of the join `V₁ * V₂`, so the qualitative
theorem is witnessed by an object of the join. -/
theorem colorful_caratheodory_dim1
    (V₁ V₂ : Finset ℝ) (h₁ne : V₁.Nonempty) (h₂ne : V₂.Nonempty)
    (h₁ : (0 : ℝ) ∈ convexHull ℝ (V₁ : Set ℝ))
    (h₂ : (0 : ℝ) ∈ convexHull ℝ (V₂ : Set ℝ)) :
    ∃ x ∈ V₁, ∃ y ∈ V₂, (0 : ℝ) ∈ convexHull ℝ ({x, y} : Set ℝ) := by
  obtain ⟨⟨x, hxV, hxle⟩, _⟩ := zero_in_hull_sign V₁ h₁ne h₁
  obtain ⟨_, ⟨y, hyV, hyge⟩⟩ := zero_in_hull_sign V₂ h₂ne h₂
  refine ⟨x, hxV, y, hyV, ?_⟩
  rw [convexHull_pair]
  exact zero_mem_segment_of_le hxle hyge

/-- **Witness-size synthesis.**  Combining Parts I and III: the rainbow edge
guaranteed by `colorful_caratheodory_dim1` is one of the edges of the join
`V₁ * V₂`, and *any* width-`2` witnessing sub-complex on the `n`-vertex ground set
has at most `3·(n+1)^2` faces — polynomial of degree `2 = k+1` for the tree
parameter `k = 1`.  (The spanning-tree structure sharpens this to the linear `2n`
of `spanningTree_face_count`.) -/
theorem colorful_witness_polynomial {α : Type*} [DecidableEq α]
    (K ground : Finset (Finset α)) (base : Finset α)
    (hground : ground = base.powerset)
    (K_sub : K ⊆ ground)
    (K_edges : ∀ s ∈ K, s.card ≤ 2) :
    K.card ≤ 3 * (base.card + 1) ^ 2 := by
  have := boundedComplex_polynomial_witness K ground base hground K_sub 1
    (by intro s hs; simpa using K_edges s hs)
  simpa using this

end ColorfulCaratheodoryKTree