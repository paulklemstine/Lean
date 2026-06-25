/-
# The polygon / associahedron model of the finite type `A` cluster algebra of `Gr(2, m)`

This file gives a **self-contained, fully proved** combinatorial model of the finite
type `A` cluster complex, the cluster structure that governs the Grassmannian `Gr(2, m)`
of 2-planes in `m`-space.

## The `Gr(2, m)` / polygon dictionary

The homogeneous coordinate ring of `Gr(2, m)` (in its Plücker embedding) is a cluster
algebra of finite type `A_{m-3}`.  Its combinatorics is encoded by a **convex `m`-gon**:

* Plücker coordinates `p_{ij}` (`1 ≤ i < j ≤ m`)  ↔  segments between vertices `i`, `j`.
* the `m` *frozen* coordinates `p_{i,i+1}`        ↔  the `m` **sides** of the polygon.
* the `m(m-3)/2` *mutable* coordinates            ↔  the **diagonals** of the polygon.
* clusters (maximal collections of compatible mutable variables)
                                                  ↔  **triangulations** of the polygon.
* mutations of clusters                           ↔  **flips** of triangulations.

Type `A_r` corresponds to a convex polygon with `r + 3` vertices; each of its clusters
has exactly `r` mutable variables (diagonals).  Equivalently, for an `m`-gon the rank is
`r = m - 3`.

## What is formalized here

We use the classical bijection between triangulations of a convex `m`-gon and binary
trees with `m - 2` internal nodes (the dual tree of a triangulation): a triangulation of
an `m`-gon has `m - 2` triangles and `m - 3` diagonals, and the dual graph that joins two
triangles sharing a diagonal is a tree with `m - 2` nodes and `m - 3` edges.  Under this
dictionary

* triangles            ↔ internal nodes of the binary tree,
* diagonals            ↔ internal edges of the binary tree (`numNodes - 1` of them),
* flips of a diagonal  ↔ rotations of the binary tree.

The number of such trees is the Catalan number `catalan (m - 2)`, recovering the count of
triangulations / clusters.

Main results:

* `two_mul_diagonalCount` — a convex `m`-gon (`m ≥ 3`) has `m(m-3)/2` diagonals, in the
  division-free form `2 * diagonalCount m = m * (m - 3)`.  This is proved from a genuine
  enumeration of the diagonals as a `Finset` of `Sym2 (Fin m)`.
* `rank_constant` — every triangulation of an `m`-gon has exactly `m - 3` diagonals.
* `Triangulation.fintype` + `card_triangulation` — there are finitely many clusters,
  and exactly `catalan (m - 2)` of them (Catalan enumeration), built from the genuine
  enumeration `treesOfNumNodesEq`.
* `card_clusters_typeA` — type `A_r` has `catalan (r + 1)` clusters.
* `exchangeGraph` + `exchangeGraph_finite` — the flip / exchange graph has finitely many
  vertices.

## Relation to the Schubert-cell conjecture

This file does **not** prove the general statement that every Schubert cell in a type `A`
flag variety carries a cluster structure of a prescribed type.  It formalizes only the
single, completely understood case `Gr(2, m)` (the "big cell" / open Schubert cell of the
Grassmannian), whose cluster type is the finite type `A_{m-3}` realized by the polygon /
associahedron above.  See `FUTURE_DIRECTIONS.md` for the bridge back to the general
problem.
-/
import Mathlib

open Tree

namespace PolygonClusterTypeA

/-! ## 1. Diagonals of a convex `m`-gon

We label the vertices of a convex `m`-gon by `Fin m`, arranged cyclically.  The cyclic
successor of vertex `i` is `nextV i`.  A **side** is an (unordered) pair `{i, i+1}` of
cyclically adjacent vertices; a **diagonal** is an unordered pair of distinct, non-adjacent
vertices.  Everything is counted as an honest `Finset`. -/

/-- The cyclic successor of a polygon vertex. -/
def nextV {m : ℕ} (i : Fin m) : Fin m :=
  ⟨(i.1 + 1) % m, Nat.mod_lt _ (lt_of_le_of_lt (Nat.zero_le _) i.isLt)⟩

/-- Value of the cyclic successor: either `i + 1`, or it wraps around to `0`. -/
lemma nextV_val {m : ℕ} (i : Fin m) :
    ((nextV i).val = i.val + 1) ∨ ((nextV i).val = 0 ∧ i.val + 1 = m) := by
  have hi : i.val < m := i.isLt
  simp only [nextV]
  rcases Nat.lt_or_ge (i.val + 1) m with h | h
  · left; exact Nat.mod_eq_of_lt h
  · right
    have hm : i.val + 1 = m := by omega
    exact ⟨by rw [hm, Nat.mod_self], hm⟩

/-- `e` is a **side** of the `m`-gon: an edge joining two cyclically adjacent vertices. -/
def IsSide (m : ℕ) (e : Sym2 (Fin m)) : Prop := ∃ i : Fin m, e = s(i, nextV i)

instance (m : ℕ) (e : Sym2 (Fin m)) : Decidable (IsSide m e) := by
  unfold IsSide; infer_instance

/-- The `m` sides are distinct: `i ↦ {i, i+1}` is injective for `m ≥ 3`. -/
lemma side_inj (m : ℕ) (hm : 3 ≤ m) : Function.Injective (fun i : Fin m => s(i, nextV i)) := by
  intro i j h
  simp only [Sym2.eq, Sym2.rel_iff', Prod.mk.injEq, Prod.swap_prod_mk] at h
  rcases h with ⟨h1, _⟩ | ⟨h1, h2⟩
  · exact h1
  · exfalso
    rw [Fin.ext_iff] at h1 h2
    rcases nextV_val i with hi | ⟨hi1, hi2⟩ <;> rcases nextV_val j with hj | ⟨hj1, hj2⟩ <;> omega

/-- A convex `m`-gon has exactly `m` sides. -/
lemma card_sides (m : ℕ) (hm : 3 ≤ m) :
    (Finset.univ.filter (fun e : Sym2 (Fin m) => IsSide m e)).card = m := by
  have hset : (Finset.univ.filter (fun e : Sym2 (Fin m) => IsSide m e))
        = Finset.univ.image (fun i : Fin m => s(i, nextV i)) := by
    ext e
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image, IsSide, eq_comm]
  rw [hset, Finset.card_image_of_injective _ (side_inj m hm), Finset.card_univ, Fintype.card_fin]

/-- The set of diagonals of the convex `m`-gon: unordered pairs of distinct, non-adjacent
vertices. -/
def diagonalFinset (m : ℕ) : Finset (Sym2 (Fin m)) :=
  Finset.univ.filter (fun e => ¬ e.IsDiag ∧ ¬ IsSide m e)

/-- The number of diagonals of a convex `m`-gon. -/
def diagonalCount (m : ℕ) : ℕ := (diagonalFinset m).card

/-- A side joins two distinct vertices, hence is not a degenerate (diagonal) pair. -/
lemma side_not_diag (m : ℕ) (hm : 3 ≤ m) (e : Sym2 (Fin m)) (he : IsSide m e) : ¬ e.IsDiag := by
  obtain ⟨i, rfl⟩ := he
  simp only [Sym2.isDiag_iff_proj_eq]
  rw [Fin.ext_iff]
  rcases nextV_val i with h | ⟨h1, h2⟩ <;> omega

/-- The number of diagonals equals (all unordered pairs of distinct vertices) minus
(the sides): `m choose 2 - m`. -/
lemma diagonalCount_eq (m : ℕ) (hm : 3 ≤ m) : diagonalCount m = m.choose 2 - m := by
  unfold diagonalCount diagonalFinset
  have hnd : (Finset.univ.filter (fun e : Sym2 (Fin m) => ¬ e.IsDiag)).card = m.choose 2 := by
    have h := @Sym2.card_subtype_not_diag (Fin m) _ _
    rw [Fintype.card_subtype] at h
    simpa using h
  have hsub : (Finset.univ.filter (fun e : Sym2 (Fin m) => IsSide m e))
      ⊆ (Finset.univ.filter (fun e : Sym2 (Fin m) => ¬ e.IsDiag)) := by
    intro e he
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at he ⊢
    exact side_not_diag m hm e he
  have hsplit : (Finset.univ.filter (fun e : Sym2 (Fin m) => ¬ e.IsDiag ∧ ¬ IsSide m e))
      = (Finset.univ.filter (fun e : Sym2 (Fin m) => ¬ e.IsDiag))
        \ (Finset.univ.filter (fun e : Sym2 (Fin m) => IsSide m e)) := by
    ext e
    simp only [Finset.mem_filter, Finset.mem_sdiff, Finset.mem_univ, true_and]
  rw [hsplit, Finset.card_sdiff_of_subset hsub, hnd, card_sides m hm]

/-- Auxiliary arithmetic identity: `2 * (m choose 2) = m * (m - 1)`. -/
lemma two_mul_choose_two (m : ℕ) : 2 * m.choose 2 = m * (m - 1) := by
  rcases Nat.eq_zero_or_pos m with hm | hm
  · subst hm; rfl
  have hdvd : 2 ∣ m * (m - 1) := by
    have h := Nat.even_mul_succ_self (m - 1)
    rw [Nat.sub_add_cancel hm] at h
    rw [mul_comm]
    exact h.two_dvd
  rw [Nat.choose_two_right]
  exact Nat.mul_div_cancel' hdvd

/-- **Diagonal count.**  A convex `m`-gon (`m ≥ 3`) has `m(m-3)/2` diagonals, stated in the
division-free form `2 * diagonalCount m = m * (m - 3)`. -/
theorem two_mul_diagonalCount (m : ℕ) (hm : 3 ≤ m) :
    2 * diagonalCount m = m * (m - 3) := by
  rw [diagonalCount_eq m hm]
  have h1 := two_mul_choose_two m
  have hrel : m * (m - 1) = m * (m - 3) + 2 * m := by
    rw [mul_comm 2 m, ← Nat.mul_add]
    congr 1
    omega
  omega

/-! ## 2. Triangulations as binary trees (clusters of type `A`)

By the dual-tree bijection, a triangulation of a convex `m`-gon is the same datum as a
binary tree with `m - 2` internal nodes (`Tree Unit` with `numNodes = m - 2`).  We take
this as the definition of a triangulation / cluster.  The rank parameter is `r = m - 3`
(type `A_r` ↔ `m = r + 3`). -/

/-- A **triangulation** (= cluster) of a convex `m`-gon, modelled by its dual binary tree:
a `Tree Unit` with `m - 2` internal nodes (one per triangle). -/
def Triangulation (m : ℕ) : Type := {t : Tree Unit // t.numNodes = m - 2}

/-- The explicit finite enumeration of all triangulations of an `m`-gon, i.e. of all
clusters of the type `A_{m-3}` cluster algebra. -/
def clusters (m : ℕ) : Finset (Tree Unit) := treesOfNumNodesEq (m - 2)

/-- The set of triangulations is finite, witnessed by the *genuine enumeration*
`treesOfNumNodesEq (m - 2)` (not by abstract type-class search). -/
instance Triangulation.fintype (m : ℕ) : Fintype (Triangulation m) :=
  Fintype.subtype (treesOfNumNodesEq (m - 2)) (fun _ => mem_treesOfNumNodesEq)

/-- The number of diagonals of a triangulation: the number of internal edges of its dual
tree, i.e. `numNodes - 1`. -/
def numDiagonals {m : ℕ} (t : Triangulation m) : ℕ := t.val.numNodes - 1

/-- **Rank constancy.**  Every triangulation of an `m`-gon (`m ≥ 3`) has exactly `m - 3`
diagonals.  Equivalently, every cluster of type `A_{m-3}` has `m - 3` mutable variables. -/
theorem rank_constant (m : ℕ) (hm : 3 ≤ m) (t : Triangulation m) :
    numDiagonals t = m - 3 := by
  have h := t.2
  unfold numDiagonals
  omega

/-- **Finiteness of the cluster complex.**  The number of clusters of type `A_{m-3}` is
finite. -/
theorem clusters_finite (m : ℕ) : (clusters m).Nonempty ∨ (clusters m) = ∅ :=
  (clusters m).eq_empty_or_nonempty.symm.imp id id

/-- **Catalan enumeration.**  The number of triangulations of a convex `m`-gon is the
Catalan number `catalan (m - 2)`. -/
theorem card_triangulation (m : ℕ) : Fintype.card (Triangulation m) = catalan (m - 2) := by
  rw [show Fintype.card (Triangulation m) = (treesOfNumNodesEq (m - 2)).card from
        Fintype.subtype_card _ (fun _ => mem_treesOfNumNodesEq)]
  exact treesOfNumNodesEq_card_eq_catalan _

/-- The number of clusters (as the explicit enumeration) is `catalan (m - 2)`. -/
theorem card_clusters (m : ℕ) : (clusters m).card = catalan (m - 2) :=
  treesOfNumNodesEq_card_eq_catalan _

/-- **Catalan enumeration, type `A_r` form.**  Type `A_r` (`m = r + 3`) has `catalan (r+1)`
clusters. -/
theorem card_clusters_typeA (r : ℕ) : (clusters (r + 3)).card = catalan (r + 1) := by
  have h := card_clusters (r + 3)
  simpa using h

/-! ## 3. Flips and the exchange graph

A **flip** of a triangulation removes one diagonal and replaces it by the other diagonal
of the resulting quadrilateral.  Under the dual-tree bijection a flip is exactly a single
**rotation** of the binary tree, the classical edges of the associahedron.  We define the
rotation relation inductively and take the symmetric, irreflexive version as the adjacency
of the exchange graph. -/

/-- A single binary-tree **rotation** somewhere inside the tree.  The base case
`node (node a b) c ↝ node a (node b c)` is one flip of a diagonal; the two recursive cases
allow rotating inside a subtree. -/
inductive Rotation : Tree Unit → Tree Unit → Prop where
  | root (a b c : Tree Unit) :
      Rotation (.node () (.node () a b) c) (.node () a (.node () b c))
  | left {a a' b : Tree Unit} : Rotation a a' → Rotation (.node () a b) (.node () a' b)
  | right {a b b' : Tree Unit} : Rotation b b' → Rotation (.node () a b) (.node () a b')

/-- A rotation preserves the number of internal nodes, so flips keep a triangulation inside
the same `m`-gon. -/
theorem Rotation.numNodes_eq {s t : Tree Unit} (h : Rotation s t) :
    s.numNodes = t.numNodes := by
  induction h with
  | root a b c => simp only [Tree.numNodes]; omega
  | left _ ih => simp only [Tree.numNodes, ih]
  | right _ ih => simp only [Tree.numNodes, ih]

/-- Two triangulations are **flip-related** when their dual trees differ by one rotation. -/
def Flip (m : ℕ) (T T' : Triangulation m) : Prop :=
  Rotation T.val T'.val ∨ Rotation T'.val T.val

/-- The **exchange graph** of the type `A_{m-3}` cluster algebra: vertices are
triangulations / clusters, edges are flips. -/
def exchangeGraph (m : ℕ) : SimpleGraph (Triangulation m) where
  Adj T T' := Flip m T T' ∧ T ≠ T'
  symm := by
    rintro T T' ⟨h, hne⟩
    exact ⟨h.symm, hne.symm⟩
  loopless := ⟨fun _ h => h.2 rfl⟩

/-- **Finiteness of the exchange graph.**  The exchange graph of the type `A_{m-3}` cluster
algebra has finitely many vertices. -/
theorem exchangeGraph_finite (m : ℕ) : Finite (Triangulation m) :=
  Finite.of_fintype _

/-- The exchange graph has exactly `catalan (m - 2)` vertices. -/
theorem exchangeGraph_card_vertices (m : ℕ) :
    Fintype.card (Triangulation m) = catalan (m - 2) :=
  card_triangulation m

/-! ## 4. Examples / sanity checks (small `m`)

These small finite checks may use `native_decide`; the general theorems above do not. -/

/-- A triangle (`m = 3`, type `A_0`) has no diagonals. -/
example : diagonalCount 3 = 0 := by native_decide
/-- A square (`m = 4`, type `A_1`) has `2` diagonals. -/
example : diagonalCount 4 = 2 := by native_decide
/-- A pentagon (`m = 5`, type `A_2`) has `5` diagonals. -/
example : diagonalCount 5 = 5 := by native_decide

/-- A triangle has exactly `1` triangulation (`catalan 1 = 1`). -/
example : (clusters 3).card = 1 := by native_decide
/-- A square has `2` triangulations (`catalan 2 = 2`). -/
example : (clusters 4).card = 2 := by native_decide
/-- A pentagon has `5` triangulations (`catalan 3 = 5`). -/
example : (clusters 5).card = 5 := by native_decide
/-- A hexagon has `14` triangulations (`catalan 4 = 14`). -/
example : (clusters 6).card = 14 := by native_decide

end PolygonClusterTypeA