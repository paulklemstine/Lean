/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A connector: spectral edge/triangle supersaturation for *genuine* graphs

The companion file `EdgeSpectralSupersaturationTriangles.lean` proves the
edge-spectral supersaturation bound (constant `1/3`) and Nosal's endpoint at the
level of an *abstract eigenvalue multiset*, feeding the trace identities
`tr(A²) = 2m` and `tr(A³) = 6t` in as hypotheses.  That leaves a gap between the
linear-algebra statement and its combinatorial meaning: *why* are the traces of the
adjacency-matrix powers equal to twice the edge count and six times the triangle
count?

This file **closes that gap**, building the bridge that connects two a priori
separate worlds:

* **spectral / linear algebra** — traces of powers of the real symmetric adjacency
  matrix `A = adjMatrix ℝ G`, and its eigenvalues;
* **extremal combinatorics** — the edge count `#G.edgeFinset` and the triangle count
  `#(G.cliqueFinset 3)` of a finite simple graph `G`.

The two load-bearing bridge theorems are

* `trace_sq_adjMatrix_eq_two_mul_edges`  :  `tr(A²) = 2 · #edges`,
* `trace_cube_adjMatrix_eq_six_mul_triangles`  :  `tr(A³) = 6 · #triangles`.

The second is the interesting one: the trace of `A³` counts closed walks of length
`3`, and a purely combinatorial `6`-to-`1` count (each triangle admits `3!` ordered
traversals) turns this into six times the number of `3`-cliques.  The heart of the
argument is the graph-free fact `card_ordered_triples`: a `3`-element set underlies
exactly `6` ordered triples.

Feeding these two identities into the abstract eigenvalue inequality
(`matrix_eigen_supersat`, re-proved here for self-containedness) produces the
supersaturation bound stated **entirely in terms of the graph's own edge and
triangle counts**:

* `graph_triangle_supersaturation`       :  `λ · q ≤ 3 · #triangles`,
* `graph_triangle_supersaturation_sqrt`  :  `√m · q ≤ 3 · #triangles`,
* `graph_nosal`                          :  a triangle-free graph has `λ² ≤ m`.

Here `λ` is a distinguished eigenvalue dominating the spectrum in absolute value
(the Perron–Frobenius situation for a nonnegative symmetric matrix), `m = #edges`,
and `q = λ² − m` is the spectral excess.

## Main results

* `card_ordered_triples`                        — combinatorial `3! = 6` count.
* `trace_sq_adjMatrix_eq_two_mul_edges`         — `tr(A²) = 2m`.
* `trace_cube_adjMatrix_eq_six_mul_triangles`   — `tr(A³) = 6t`  (the bridge).
* `graph_triangle_supersaturation`              — `λ q ≤ 3t` for a real graph.
* `graph_triangle_supersaturation_sqrt`         — `√m q ≤ 3t`.
* `graph_nosal`                                 — triangle-free ⇒ `λ² ≤ m`.
* `completeGraph_three_counts`                  — `K₃` has `3` edges, `1` triangle.
-/
import Mathlib

namespace Catalog.Novelty.EdgeSpectralSupersaturationGraphBridge

open Finset SimpleGraph Matrix
open scoped BigOperators

/-! ### The abstract eigenvalue inequality (re-proved, self-contained)

These mirror the companion file; we reproduce them so this file compiles on its own. -/

/-- **Cubic domination.**  If `|μ| ≤ λ` then `μ³ ≥ -λ·μ²`. -/
theorem cube_lower (μ lam : ℝ) (h : |μ| ≤ lam) : -lam * μ ^ 2 ≤ μ ^ 3 := by
  nlinarith [sq_nonneg μ, abs_le.mp h]

/-- **Eigenvalue supersaturation inequality** over an arbitrary finite index type. -/
theorem eigen_supersat {ι : Type*} [Fintype ι] (μ : ι → ℝ) (j : ι) (lam : ℝ)
    (hlam : lam = μ j) (hbound : ∀ i, |μ i| ≤ lam) :
    2 * lam ^ 3 - lam * (∑ i, (μ i) ^ 2) ≤ ∑ i, (μ i) ^ 3 := by
  have key : ∀ i, (0 : ℝ) ≤ (μ i) ^ 3 + lam * (μ i) ^ 2 := fun i => by
    have := cube_lower (μ i) lam (hbound i); linarith
  have hsum : (μ j) ^ 3 + lam * (μ j) ^ 2 ≤ ∑ i, ((μ i) ^ 3 + lam * (μ i) ^ 2) :=
    Finset.single_le_sum (f := fun i => (μ i) ^ 3 + lam * (μ i) ^ 2)
      (fun i _ => key i) (Finset.mem_univ j)
  have hsplit : ∑ i, ((μ i) ^ 3 + lam * (μ i) ^ 2)
      = (∑ i, (μ i) ^ 3) + lam * (∑ i, (μ i) ^ 2) := by
    rw [Finset.sum_add_distrib, Finset.mul_sum]
  rw [hsplit, ← hlam] at hsum
  nlinarith [hsum]

open Matrix in
/-- **Trace of a matrix power equals the power sum of its eigenvalues** for a real
symmetric (Hermitian) matrix. -/
theorem trace_pow_eq_sum_pow_eigenvalues {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.IsHermitian) (k : ℕ) :
    (A ^ k).trace = ∑ i, (hA.eigenvalues i) ^ k := by
  have := hA.spectral_theorem
  conv_lhs => rw [this, ← map_pow]
  simp +decide [Matrix.trace_mul_comm, Matrix.mul_assoc]
  simp +decide [Matrix.trace, Matrix.diagonal_pow]

open Matrix in
/-- **Spectral supersaturation inequality for a real symmetric matrix.** -/
theorem matrix_eigen_supersat {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.IsHermitian) (j : n) (lam : ℝ)
    (hlam : lam = hA.eigenvalues j) (hbound : ∀ i, |hA.eigenvalues i| ≤ lam) :
    2 * lam ^ 3 - lam * (A ^ 2).trace ≤ (A ^ 3).trace := by
  have h2 := trace_pow_eq_sum_pow_eigenvalues A hA 2
  have h3 := trace_pow_eq_sum_pow_eigenvalues A hA 3
  have H := eigen_supersat (hA.eigenvalues) j lam hlam hbound
  rw [h2, h3]; exact H

/-! ### The combinatorial `3! = 6` count -/

variable {V : Type*} [Fintype V] [DecidableEq V]

omit [Fintype V] in
/-- **A `3`-element set has exactly three distinct representatives.**  If
`{v, b, a}` has cardinality `3` then `v, b, a` are pairwise distinct. -/
theorem triple_distinct (v b a : V) (h3 : ({v, b, a} : Finset V).card = 3) :
    v ≠ b ∧ v ≠ a ∧ b ≠ a := by
  have hv : v ∉ ({b, a} : Finset V) := by
    intro hv; rw [Finset.insert_eq_of_mem hv] at h3
    have : (#({b, a} : Finset V)) ≤ 2 := Finset.card_le_two; omega
  have h2 : (#({b, a} : Finset V)) = 2 := by
    rw [Finset.card_insert_of_notMem hv] at h3; omega
  have hba : b ≠ a := by rintro rfl; simp at h2
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hv
  exact ⟨hv.1, hv.2, hba⟩

/-- **Ordered representatives of a `3`-set.**  For a set `s` of cardinality `3`,
there are exactly `6` ordered triples `(x, y, z)` with `{x, y, z} = s` — the `3!`
permutations of its elements.  This graph-free lemma is what converts the count of
closed `3`-walks (ordered) into the count of triangles (unordered). -/
theorem card_ordered_triples (s : Finset V) (hs : s.card = 3) :
    (univ.filter (fun t : V × V × V => ({t.1, t.2.1, t.2.2} : Finset V) = s)).card = 6 := by
  obtain ⟨x, y, z, hxy, hxz, hyz, rfl⟩ := Finset.card_eq_three.mp hs
  have hset : (univ.filter (fun t : V × V × V => ({t.1, t.2.1, t.2.2} : Finset V) = {x, y, z}))
      = ({(x, y, z), (x, z, y), (y, x, z), (y, z, x), (z, x, y), (z, y, x)} :
          Finset (V × V × V)) := by
    ext ⟨a, b, c⟩
    simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton, Prod.mk.injEq]
    constructor
    · intro h
      have hx : x ∈ ({a, b, c} : Finset V) := by rw [h]; simp
      have hy : y ∈ ({a, b, c} : Finset V) := by rw [h]; simp
      have hz : z ∈ ({a, b, c} : Finset V) := by rw [h]; simp
      have ha : a ∈ ({x, y, z} : Finset V) := by rw [← h]; simp
      have hb : b ∈ ({x, y, z} : Finset V) := by rw [← h]; simp
      have hc : c ∈ ({x, y, z} : Finset V) := by rw [← h]; simp
      simp only [mem_insert, mem_singleton] at hx hy hz ha hb hc
      rcases ha with rfl | rfl | rfl <;> rcases hb with rfl | rfl | rfl <;>
        rcases hc with rfl | rfl | rfl <;> simp_all <;> tauto
    · rintro (⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ |
        ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩) <;>
        (ext w; simp only [mem_insert, mem_singleton]; try tauto)
  rw [hset]
  repeat rw [Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; tauto)]
  rfl

/-! ### Bridge 1: `tr(A²) = 2 · #edges` -/

/-- **Edge bridge.**  For a finite simple graph `G`, the trace of the square of its
adjacency matrix (over `ℝ`) is twice the number of edges.  The diagonal of `A²`
records vertex degrees, and the handshake lemma sums them to `2m`. -/
theorem trace_sq_adjMatrix_eq_two_mul_edges (G : SimpleGraph V) [DecidableRel G.Adj] :
    (G.adjMatrix ℝ ^ 2).trace = 2 * (G.edgeFinset.card : ℝ) := by
  rw [pow_two]
  unfold Matrix.trace
  simp only [Matrix.diag_apply]
  rw [show (∑ i, (G.adjMatrix ℝ * G.adjMatrix ℝ) i i) = ∑ i, ((G.degree i : ℝ)) from by
    apply Finset.sum_congr rfl; intro i _; rw [adjMatrix_mul_self_apply_self]]
  rw [← Nat.cast_sum, SimpleGraph.sum_degrees_eq_twice_card_edges]
  push_cast; ring

/-! ### Bridge 2: `tr(A³) = 6 · #triangles` -/

/-- **Closed `3`-walks are `6`-to-`1` over triangles.**  The number of ordered
triples `(v, b, a)` forming a cyclically adjacent triple equals six times the number
of `3`-cliques.  Each triangle contributes its `3! = 6` orderings; conversely every
such ordered triple has a triangle as its underlying vertex set. -/
theorem card_cyclic_triples_eq_six_mul_triangles
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (univ.filter (fun t : V × V × V =>
        G.Adj t.1 t.2.2 ∧ G.Adj t.2.2 t.2.1 ∧ G.Adj t.2.1 t.1)).card
      = 6 * (G.cliqueFinset 3).card := by
  set T := univ.filter (fun t : V × V × V =>
        G.Adj t.1 t.2.2 ∧ G.Adj t.2.2 t.2.1 ∧ G.Adj t.2.1 t.1) with hT
  have hmap : ∀ t ∈ T, ({t.1, t.2.1, t.2.2} : Finset V) ∈ G.cliqueFinset 3 := by
    rintro ⟨v, b, a⟩ ht
    rw [hT, mem_filter] at ht
    obtain ⟨_, h1, h2, h3⟩ := ht
    have hva : v ≠ a := h1.ne
    have hab : a ≠ b := h2.ne
    have hbv : b ≠ v := h3.ne
    rw [mem_cliqueFinset_iff, isNClique_iff]
    refine ⟨?_, ?_⟩
    · rw [isClique_iff]
      intro p hp q hq hpq
      simp only [coe_insert, Set.mem_insert_iff, coe_singleton, Set.mem_singleton_iff] at hp hq
      rcases hp with rfl | rfl | rfl <;> rcases hq with rfl | rfl | rfl <;>
        first
        | exact absurd rfl hpq
        | exact h1 | exact h1.symm | exact h2 | exact h2.symm | exact h3 | exact h3.symm
    · rw [Finset.card_insert_of_notMem (by simp [Ne.symm hbv, hva]),
          Finset.card_insert_of_notMem (by simp [Ne.symm hab]), Finset.card_singleton]
  rw [Finset.card_eq_sum_card_fiberwise hmap]
  have hfib : ∀ s ∈ G.cliqueFinset 3,
      (T.filter (fun t => ({t.1, t.2.1, t.2.2} : Finset V) = s)).card = 6 := by
    intro s hs
    rw [mem_cliqueFinset_iff, isNClique_iff] at hs
    obtain ⟨hclique, hcard⟩ := hs
    rw [isClique_iff] at hclique
    have heq : (T.filter (fun t => ({t.1, t.2.1, t.2.2} : Finset V) = s))
         = (univ.filter (fun t : V × V × V => ({t.1, t.2.1, t.2.2} : Finset V) = s)) := by
      ext ⟨v, b, a⟩
      simp only [hT, mem_filter, mem_univ, true_and]
      constructor
      · rintro ⟨_, he⟩; exact he
      · intro he
        have hv : v ∈ s := by rw [← he]; simp
        have hb : b ∈ s := by rw [← he]; simp
        have ha : a ∈ s := by rw [← he]; simp
        have hcard3 : ({v, b, a} : Finset V).card = 3 := by rw [he]; exact hcard
        obtain ⟨hvb, hva, hba⟩ := triple_distinct v b a hcard3
        exact ⟨⟨hclique hv ha hva, hclique ha hb hba.symm, hclique hb hv hvb.symm⟩, he⟩
    rw [heq, card_ordered_triples s hcard]
  rw [Finset.sum_congr rfl hfib, Finset.sum_const, smul_eq_mul, mul_comm]

/-- **Triangle bridge.**  For a finite simple graph `G`, the trace of the cube of its
adjacency matrix (over `ℝ`) is six times the number of triangles (`3`-cliques).  This
is the spectral–combinatorial connector: `tr(A³)` counts closed walks of length `3`,
and each triangle contributes exactly `3! = 6` of them. -/
theorem trace_cube_adjMatrix_eq_six_mul_triangles (G : SimpleGraph V) [DecidableRel G.Adj] :
    (G.adjMatrix ℝ ^ 3).trace = 6 * ((G.cliqueFinset 3).card : ℝ) := by
  have hexp : (G.adjMatrix ℝ ^ 3).trace
      = ∑ v, ∑ b, ∑ a, (G.adjMatrix ℝ v a) * (G.adjMatrix ℝ a b) * (G.adjMatrix ℝ b v) := by
    rw [show (3 : ℕ) = 2 + 1 from rfl, pow_succ, pow_two]
    unfold Matrix.trace
    simp only [Matrix.diag_apply]
    apply Finset.sum_congr rfl; intro v _
    rw [Matrix.mul_apply]
    apply Finset.sum_congr rfl; intro b _
    rw [Matrix.mul_apply, Finset.sum_mul]
  have hcount : (∑ v, ∑ b, ∑ a, (G.adjMatrix ℝ v a) * (G.adjMatrix ℝ a b) * (G.adjMatrix ℝ b v))
      = ((univ.filter (fun t : V × V × V =>
          G.Adj t.1 t.2.2 ∧ G.Adj t.2.2 t.2.1 ∧ G.Adj t.2.1 t.1)).card : ℝ) := by
    rw [Finset.card_filter]
    push_cast
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl; intro v _
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl; intro b _
    apply Finset.sum_congr rfl; intro a _
    simp only [adjMatrix_apply]
    by_cases h1 : G.Adj v a <;> by_cases h2 : G.Adj a b <;> by_cases h3 : G.Adj b v <;>
      simp [h1, h2, h3]
  rw [hexp, hcount, card_cyclic_triples_eq_six_mul_triangles]
  push_cast; ring

/-! ### The graph-theoretic supersaturation theorems

Combining the two trace bridges with the abstract eigenvalue inequality gives
supersaturation bounds phrased entirely in terms of a graph's own edge and triangle
counts.  `lam` is a distinguished eigenvalue dominating the spectrum in absolute
value (the Perron–Frobenius situation for the nonnegative symmetric adjacency
matrix), which we take as the hypothesis `hbound`. -/

/-- **Edge-spectral triangle supersaturation for a graph (constant `1/3`).**  Let `G`
be a finite simple graph with real adjacency matrix `A`, and let `lam = μ j` be a
spectrum-dominating eigenvalue (`|μ i| ≤ lam` for all `i`).  Writing `m` for the edge
count and `q = lam² − m` for the spectral excess, the number of triangles `t`
satisfies `lam · q ≤ 3 · t`. -/
theorem graph_triangle_supersaturation (G : SimpleGraph V) [DecidableRel G.Adj]
    (hA : (G.adjMatrix ℝ).IsHermitian) (j : V) (lam q : ℝ)
    (hlam : lam = hA.eigenvalues j) (hbound : ∀ i, |hA.eigenvalues i| ≤ lam)
    (hq : lam ^ 2 = (G.edgeFinset.card : ℝ) + q) :
    lam * q ≤ 3 * ((G.cliqueFinset 3).card : ℝ) := by
  have hEig := matrix_eigen_supersat (G.adjMatrix ℝ) hA j lam hlam hbound
  rw [trace_sq_adjMatrix_eq_two_mul_edges, trace_cube_adjMatrix_eq_six_mul_triangles] at hEig
  have hcube : lam ^ 3 = lam * ((G.edgeFinset.card : ℝ) + q) := by rw [← hq]; ring
  nlinarith [hEig, hcube]

/-- **The `√m` scaling.**  With nonnegative spectral excess `q ≥ 0`, the graph
triangle count satisfies `√m · q ≤ 3 · t`, the shape of the sharp conjecture
`t ≥ (1 - ε) q √m`, here with constant `1/3`. -/
theorem graph_triangle_supersaturation_sqrt (G : SimpleGraph V) [DecidableRel G.Adj]
    (hA : (G.adjMatrix ℝ).IsHermitian) (j : V) (lam q : ℝ)
    (hlam : lam = hA.eigenvalues j) (hbound : ∀ i, |hA.eigenvalues i| ≤ lam)
    (hq : lam ^ 2 = (G.edgeFinset.card : ℝ) + q) (hqnn : 0 ≤ q) :
    Real.sqrt (G.edgeFinset.card : ℝ) * q ≤ 3 * ((G.cliqueFinset 3).card : ℝ) := by
  have hln : 0 ≤ lam := le_trans (abs_nonneg (hA.eigenvalues j)) (hlam ▸ hbound j)
  have hbase := graph_triangle_supersaturation G hA j lam q hlam hbound hq
  have hsqrt : Real.sqrt (G.edgeFinset.card : ℝ) ≤ lam := by
    rw [show (G.edgeFinset.card : ℝ) = lam ^ 2 - q by linarith]
    calc Real.sqrt (lam ^ 2 - q) ≤ Real.sqrt (lam ^ 2) := Real.sqrt_le_sqrt (by linarith)
      _ = lam := by rw [Real.sqrt_sq hln]
  nlinarith [mul_le_mul_of_nonneg_right hsqrt hqnn, hbase]

/-- **Nosal's inequality for a graph.**  A triangle-free graph (`#(G.cliqueFinset 3)
= 0`) with spectrum-dominating eigenvalue `lam` satisfies `lam² ≤ m`, i.e.
`lam ≤ √m`. -/
theorem graph_nosal (G : SimpleGraph V) [DecidableRel G.Adj]
    (hA : (G.adjMatrix ℝ).IsHermitian) (j : V) (lam : ℝ)
    (hlam : lam = hA.eigenvalues j) (hbound : ∀ i, |hA.eigenvalues i| ≤ lam)
    (htri : (G.cliqueFinset 3).card = 0) :
    lam ^ 2 ≤ (G.edgeFinset.card : ℝ) := by
  have hln : 0 ≤ lam := le_trans (abs_nonneg (hA.eigenvalues j)) (hlam ▸ hbound j)
  have hEig := matrix_eigen_supersat (G.adjMatrix ℝ) hA j lam hlam hbound
  rw [trace_sq_adjMatrix_eq_two_mul_edges, trace_cube_adjMatrix_eq_six_mul_triangles, htri] at hEig
  simp only [Nat.cast_zero, mul_zero] at hEig
  have hmnn : (0 : ℝ) ≤ (G.edgeFinset.card : ℝ) := by positivity
  nlinarith [hEig, hln, hmnn]

/-! ### A concrete instance: the complete graph `K₃`

`K₃ = (⊤ : SimpleGraph (Fin 3))` has `3` edges and exactly `1` triangle, certifying
that the bridge identities are non-vacuous: `tr(A²) = 6 = 2·3` and `tr(A³) = 6 = 6·1`.
-/

/-- The complete graph on three vertices has `3` edges and `1` triangle. -/
theorem completeGraph_three_counts :
    ((⊤ : SimpleGraph (Fin 3)).edgeFinset).card = 3 ∧
    ((⊤ : SimpleGraph (Fin 3)).cliqueFinset 3).card = 1 := by
  constructor <;> decide

/-- For `K₃`, the triangle bridge specialises to `tr(A³) = 6`. -/
theorem completeGraph_three_trace_cube :
    ((⊤ : SimpleGraph (Fin 3)).adjMatrix ℝ ^ 3).trace = 6 := by
  rw [trace_cube_adjMatrix_eq_six_mul_triangles]
  rw [show ((⊤ : SimpleGraph (Fin 3)).cliqueFinset 3).card = 1 from by decide]
  norm_num

/-- For `K₃`, the edge bridge specialises to `tr(A²) = 6`. -/
theorem completeGraph_three_trace_sq :
    ((⊤ : SimpleGraph (Fin 3)).adjMatrix ℝ ^ 2).trace = 6 := by
  rw [trace_sq_adjMatrix_eq_two_mul_edges]
  rw [show ((⊤ : SimpleGraph (Fin 3)).edgeFinset).card = 3 from by decide]
  norm_num

end Catalog.Novelty.EdgeSpectralSupersaturationGraphBridge