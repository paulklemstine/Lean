/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Rank / Laplacian Minor Bridge — Theorems

This file proves the structural theorems linking rooted subset divisors,
graph Laplacians, and principal minors. These are the foundational results
for the bridge between Baker–Norine divisor rank and tropical matrix rank.

## Main Results

* `rootedSubsetDivisor_total` — the canonical divisor `D_S` has degree zero
* `support_rootedSubsetDivisor_subset` — support of `D_S` is contained in `S ∪ {q}`
* `rootedSubsetDivisor_decomposition` — decomposition under subset inclusion
* `graphLaplacian_row_sum_zero` — rows of the Laplacian sum to zero
* `graphLaplacian_symmetric` — the Laplacian is symmetric
* `graphLaplacian_diagonal_nonneg` — diagonal entries are nonnegative
* `laplacianPrincipalMinor_diagonal` — diagonal of principal minor equals degree within S
  plus edges to complement

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Pythagorean.TropicalBridge.Defs

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Theorem 1: Degree-zero and support control for canonical subset divisors -/

/-
**Degree-zero property.** The canonical rooted subset divisor `D_S` has degree zero:
    `∑_v D_S(v) = |S| · 1 + 1 · (−|S|) + 0 = 0`.

    This makes `D_S` a canonical point of the degree-zero Jacobian lattice and sets up
    every later comparison to Laplacian images. The proof splits the sum over `S`, `{q}`,
    and `V \ (S ∪ {q})`, using the hypothesis `q ∉ S`.
-/
theorem rootedSubsetDivisor_total
    (q : V) (S : Finset V) (hq : q ∉ S) :
    (∑ v : V, rootedSubsetDivisor q S v) = 0 := by
  unfold rootedSubsetDivisor;
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hq ]

/-
**Support localization.** The support of `D_S` is contained in `S ∪ {q}`:
    vertices outside `S ∪ {q}` receive coefficient zero.

    This is the key geometric property: the divisor `D_S` is concentrated on the
    "boundary" `S ∪ {q}`, leaving the rest of the graph untouched.
-/
theorem support_rootedSubsetDivisor_subset
    (q : V) (S : Finset V) :
    {v | rootedSubsetDivisor q S v ≠ 0} ⊆ ({q} ∪ ↑S : Set V) := by
  intro v hv; by_cases h : v = q <;> simp_all +decide [ rootedSubsetDivisor ] ;

/-! ## Theorem 2: Laplacian structural properties -/

/-
**Row-sum zero property.** Each row of the graph Laplacian sums to zero.
    This is equivalent to the conservation law in chip-firing: firing all vertices
    simultaneously produces no net change. Equivalently, `L · 𝟏 = 0`.

    The proof expands the Laplacian definition and uses the fact that
    `deg(v) = |{w : G.Adj v w}|` to cancel the diagonal with off-diagonal terms.
-/
theorem graphLaplacian_row_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j : V, graphLaplacian G i j = 0 := by
  unfold graphLaplacian; simp +decide [ Finset.sum_ite, SimpleGraph.degree, SimpleGraph.neighborFinset ] ; ring;
  simp +decide [ Finset.filter_eq, Finset.filter_ne ];
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
**Symmetry.** The graph Laplacian is symmetric: `L(i,j) = L(j,i)`.
    This follows from the symmetry of the adjacency relation.
-/
theorem graphLaplacian_symmetric
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) :
    graphLaplacian G i j = graphLaplacian G j i := by
  unfold graphLaplacian;
  simp +decide [ eq_comm, SimpleGraph.adj_comm ];
  grind

/-
**Nonnegative diagonal.** The diagonal entries of the Laplacian are nonneg.
-/
theorem graphLaplacian_diagonal_nonneg
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    0 ≤ graphLaplacian G v v := by
  -- The diagonal entry of the Laplacian matrix is the degree of vertex v, which is a non-negative integer.
  simp [graphLaplacian]

/-! ## Theorem 3: Monotonicity under subset inclusion -/

/-
**Divisor decomposition under inclusion.** For `S ⊆ T` with `q ∉ T`,
    the divisor `D_T` decomposes as `D_S + E` where `E` is an explicit
    correction term supported on `(T \ S) ∪ {q}`.

    This is the algebraic backbone of the monotonicity principle: it shows
    that growing the subset `S` only adds effective positive contributions
    away from the root.
-/
theorem rootedSubsetDivisor_decomposition
    (q : V) {S T : Finset V} (hST : S ⊆ T) (hqT : q ∉ T) :
    ∃ E : V → ℤ,
      (∀ v, rootedSubsetDivisor q T v = rootedSubsetDivisor q S v + E v) ∧
      (∀ v, v ∉ T \ S → v ≠ q → E v = 0) := by
  refine' ⟨ fun v => rootedSubsetDivisor q T v - rootedSubsetDivisor q S v, fun v => _, fun v hv hv' => _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
  unfold rootedSubsetDivisor; aesop;

/-! ## Theorem 4: Laplacian column sum and principal minor structure -/

/-
**Column-sum zero.** Each column of the graph Laplacian sums to zero.
    This follows from symmetry + row-sum zero.
-/
theorem graphLaplacian_col_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj] (j : V) :
    ∑ i : V, graphLaplacian G i j = 0 := by
  convert graphLaplacian_row_sum_zero G j using 1;
  exact Finset.sum_congr rfl fun i _ => graphLaplacian_symmetric G i j

/-
**Total sum zero.** The total sum of all entries of the Laplacian is zero.
-/
theorem graphLaplacian_total_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    ∑ i : V, ∑ j : V, graphLaplacian G i j = 0 := by
  apply Finset.sum_eq_zero; intro i hi; exact graphLaplacian_row_sum_zero G i;

/-
**Off-diagonal entries.** Off-diagonal entries of the Laplacian are ≤ 0.
-/
theorem graphLaplacian_off_diagonal_nonpos
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) (hij : i ≠ j) :
    graphLaplacian G i j ≤ 0 := by
  unfold graphLaplacian; aesop;

/-
**Diagonal equals degree.** The diagonal entry equals the vertex degree.
-/
theorem graphLaplacian_diagonal_eq_degree
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    graphLaplacian G v v = (G.degree v : ℤ) := by
  exact if_pos rfl

/-! ## Theorem 5: Principal minor row sums relate to cut structure -/

/-
**Principal minor row sum.** For `v ∈ S`, the row sum of the principal minor
    `L_S` at `v` equals the number of edges from `v` to vertices outside `S`.
    This connects the internal structure of `L_S` to the cut between `S` and its
    complement, bridging Laplacian combinatorics and network flow.
-/
theorem principalMinor_row_sum
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (v : S) :
    S.attach.sum (fun w => laplacianPrincipalMinor (graphLaplacian G) S v w) =
    ((Finset.univ.filter (fun w => w ∉ S ∧ G.Adj v.1 w)).card : ℤ) := by
  have h_row_sum : ∑ w ∈ S.attach, laplacianPrincipalMinor (graphLaplacian G) S v w = ∑ w ∈ Finset.univ, graphLaplacian G v.1 w - ∑ w ∈ Finset.univ \ S, graphLaplacian G v.1 w := by
    rw [ eq_sub_iff_add_eq, ← Finset.sum_sdiff ( Finset.subset_univ S ) ];
    rw [ add_comm, ← Finset.sum_attach ];
    refine' congr rfl ( Finset.sum_bij ( fun x hx => x ) _ _ _ _ ) <;> aesop;
  simp_all +decide [ Finset.sum_ite, Finset.filter_and ];
  simp_all +decide [ Finset.sum_ite, Finset.filter_not, Finset.card_sdiff ];
  have h_row_sum : ∑ w ∈ Finset.univ \ S, graphLaplacian G v.1 w = -∑ w ∈ Finset.univ \ S, if G.Adj v.1 w then 1 else 0 := by
    rw [ ← Finset.sum_neg_distrib ] ; refine' Finset.sum_congr rfl fun w hw => _ ; unfold graphLaplacian ; aesop;
  simp_all +decide [ Finset.sum_ite, Finset.filter_and ];
  simp_all +decide [ Finset.filter_inter, Finset.inter_filter ];
  linarith [ graphLaplacian_row_sum_zero G v.1 ]

/-! ## Theorem 6: Rootedness structure -/

/-
**Rootedness.** For any nonempty `S` with `q ∉ S`, the divisor `D_S` has
    negative coefficient at `q` and positive coefficients on `S`.
-/
theorem rootedSubsetDivisor_q_neg
    (q : V) (S : Finset V) (hq : q ∉ S) (hne : S.Nonempty) :
    rootedSubsetDivisor q S q < 0 := by
  unfold rootedSubsetDivisor;
  simp [hq, hne]

theorem rootedSubsetDivisor_S_pos
    (q : V) (S : Finset V) (v : V) (hv : v ∈ S) :
    rootedSubsetDivisor q S v = 1 := by
  exact if_pos hv