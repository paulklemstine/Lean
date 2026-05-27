/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Metric Graph Weighted Laplacian — Definitions and Theorems

This file introduces the weighted graph Laplacian for metric graphs and proves
its fundamental algebraic properties: row-sum-zero, symmetry, kernel
characterization, harmonic function algebra, leaf rigidity, and positive
semi-definiteness.

These properties are the exact continuous analogues of the discrete Laplacian
properties and form the foundation for the tropical Jacobian computation
via the metric canonical kernel correspondence.

## Main Definitions

* `weightedLaplacian` — the weighted Laplacian matrix with conductance weights
* `weightedIsHarmonicOn` — harmonicity w.r.t. the weighted Laplacian

## Main Results

* `weightedLaplacian_row_sum_zero` — row-sum-zero property
* `weightedLaplacian_symm` — symmetry of the weighted Laplacian
* `weightedLaplacian_constant_in_ker` — constant functions are in the kernel
* `weightedLaplacian_ker_contains_constants` — the constant subspace lies in the kernel
* `weightedIsHarmonicOn_add` — sum of harmonic functions is harmonic
* `weightedIsHarmonicOn_neg` — negation preserves harmonicity
* `weightedIsHarmonicOn_smul` — scalar multiples preserve harmonicity
* `weightedIsHarmonicOn_zero` — zero function is harmonic
* `weighted_harmonic_leaf_eq_neighbor` — leaf rigidity theorem
* `weightedLaplacian_psd` — positive semi-definiteness

## References

* Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and
  electrical networks" (2006)
-/

import Mathlib

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Definitions -/

/-- The **weighted Laplacian** of a simple graph `G` with symmetric positive
    edge weights `w`. For adjacent vertices `i ~ j`, the off-diagonal entry
    is `-w(i,j)`. The diagonal entry is the sum of weights of incident edges.

    When `w(i,j) = 1/ℓ(i,j)` for edge length `ℓ`, this is the metric graph
    Laplacian with conductance weights. -/
noncomputable def weightedLaplacian
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) : Matrix V V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (G.Adj i), w i k
    else if G.Adj i j then -(w i j)
    else 0

/-- A function `f : V → ℝ` is **weighted-harmonic on** a subset `S` if
    `Σ_j L(v,j) · f(j) = 0` for every `v ∈ S`. -/
def weightedIsHarmonicOn
    (L : Matrix V V ℝ) (S : Finset V) (f : V → ℝ) : Prop :=
  ∀ v ∈ S, ∑ j : V, L v j * f j = 0

/-! ## Row-Sum-Zero Property -/

/-
**Row-sum-zero property of the weighted Laplacian.**
    Each row of the weighted Laplacian sums to zero. This is the algebraic
    reflection of the conservation law: charge (or current) is conserved.
-/
theorem weightedLaplacian_row_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) (i : V) :
    ∑ j : V, weightedLaplacian G w i j = 0 := by
  -- Let's consider the sum of the entries in the $i$-th row of the weighted Laplacian matrix.
  -- We can split the sum into the diagonal terms and the off-diagonal terms.
  have h_split : ∑ j, weightedLaplacian G w i j = (∑ j ∈ Finset.univ, if i = j then ∑ k ∈ Finset.univ.filter (G.Adj i), w i k else 0) + (∑ j ∈ Finset.univ, if i ≠ j then if G.Adj i j then -(w i j) else 0 else 0) := by
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun j _ => by unfold weightedLaplacian; aesop;
  simp_all +decide [ Finset.sum_ite, Finset.filter_ne ];
  simp +decide [ Finset.filter_erase, G.loopless ]

/-! ## Symmetry -/

/-
**Symmetry of the weighted Laplacian.**
    When the edge weight function is symmetric (`w i j = w j i`), the weighted
    Laplacian matrix is symmetric.
-/
theorem weightedLaplacian_symm
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (i j : V) :
    weightedLaplacian G w i j = weightedLaplacian G w j i := by
  unfold weightedLaplacian;
  simp +decide only [eq_comm, SimpleGraph.adj_comm, hw_symm];
  grind

/-! ## Constant Functions in the Kernel -/

/-
**Constant functions lie in the kernel of the weighted Laplacian.**
    For any constant `c`, the vector `(c, c, ..., c)` satisfies `L · v = 0`.
    This follows directly from the row-sum-zero property.
-/
theorem weightedLaplacian_constant_in_ker
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) (c : ℝ) (i : V) :
    ∑ j : V, weightedLaplacian G w i j * c = 0 := by
  rw [ ← Finset.sum_mul, weightedLaplacian_row_sum_zero, MulZeroClass.zero_mul ]

/-
**The constant subspace is contained in the kernel.**
    Every constant function is weighted-harmonic on any subset.
-/
theorem weightedLaplacian_ker_contains_constants
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ) (c : ℝ) (S : Finset V) :
    weightedIsHarmonicOn (weightedLaplacian G w) S (fun _ => c) := by
  exact fun v hv => by simpa [ mul_comm ] using weightedLaplacian_constant_in_ker G w c v;

/-! ## Weighted Harmonic Function Algebra -/

/-
**Sum of weighted-harmonic functions is weighted-harmonic.**
-/
theorem weightedIsHarmonicOn_add
    (L : Matrix V V ℝ) (S : Finset V) {f g : V → ℝ}
    (hf : weightedIsHarmonicOn L S f) (hg : weightedIsHarmonicOn L S g) :
    weightedIsHarmonicOn L S (fun v => f v + g v) := by
  intro v hv
  have h_sum : ∑ j, L v j * (f j + g j) = ∑ j, L v j * f j + ∑ j, L v j * g j := by
    simp +decide only [mul_add, sum_add_distrib];
  convert h_sum using 1 ; have := hf v hv ; have := hg v hv ; aesop

/-
**Negation of a weighted-harmonic function is weighted-harmonic.**
-/
theorem weightedIsHarmonicOn_neg
    (L : Matrix V V ℝ) (S : Finset V) {f : V → ℝ}
    (hf : weightedIsHarmonicOn L S f) :
    weightedIsHarmonicOn L S (fun v => -(f v)) := by
  intro v hv; convert congr_arg Neg.neg ( hf v hv ) using 1; simp +decide [ mul_neg, Finset.sum_neg_distrib ] ;
  norm_num

/-
**Scalar multiples of weighted-harmonic functions are weighted-harmonic.**
-/
theorem weightedIsHarmonicOn_smul
    (L : Matrix V V ℝ) (S : Finset V) {f : V → ℝ} (k : ℝ)
    (hf : weightedIsHarmonicOn L S f) :
    weightedIsHarmonicOn L S (fun v => k * f v) := by
  intro v hv; convert congr_arg ( fun x : ℝ => k * x ) ( hf v hv ) using 1; rw [ Finset.mul_sum _ _ _ ] ; congr; ext; ring;
  ring

/-
**The zero function is weighted-harmonic on any subset.**
-/
theorem weightedIsHarmonicOn_zero
    (L : Matrix V V ℝ) (S : Finset V) :
    weightedIsHarmonicOn L S (fun _ => (0 : ℝ)) := by
  exact fun v _ => by simp +decide [ weightedIsHarmonicOn ] ;

/-! ## Leaf Rigidity -/

/-
**Weighted leaf rigidity theorem.**
    At a leaf vertex `v` (degree 1) with unique neighbor `u`, if `f` is
    weighted-harmonic at `v`, then `f(v) = f(u)`.

    This is the metric generalization of the discrete leaf rigidity theorem:
    regardless of the edge weight, a harmonic function on a pendant edge
    must be constant along that edge. The weight affects the *rate* of
    propagation but not the *value*.
-/
theorem weighted_harmonic_leaf_eq_neighbor
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_pos : ∀ i j, G.Adj i j → 0 < w i j)
    {v u : V} (f : V → ℝ)
    (hdeg : G.degree v = 1)
    (hadj : G.Adj v u)
    (hharm : ∑ j : V, weightedLaplacian G w v j * f j = 0) :
    f v = f u := by
  -- Since $u$ is the unique neighbor of $v$, the sum simplifies to $w v u * f v + (-w v u) * f u$.
  have hsum_simplified : (∑ j, (weightedLaplacian G w v j) * (f j)) = ((w v u) * (f v) + -(w v u) * (f u)) := by
    -- Since $v$ has degree 1, its only neighbor is $u$, so we can simplify the sum.
    have h_neighbor : Finset.univ.filter (G.Adj v) = {u} := by
      exact Finset.eq_singleton_iff_unique_mem.2 ⟨ by simpa using hadj, fun x hx => by have := Finset.card_eq_one.1 hdeg; obtain ⟨ y, hy ⟩ := this; rw [ Finset.eq_singleton_iff_unique_mem ] at hy; aesop ⟩;
    unfold weightedLaplacian; simp +decide [ *, Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ] ; ring;
    simp_all +decide [ Finset.ext_iff, Set.ext_iff ];
    simp_all +decide [ Finset.sum_filter, Finset.filter_ne ];
    exact fun h => absurd ( h_neighbor v ) ( by simp +decide [ h, SimpleGraph.irrefl ] );
  grind

/-! ## Positive Semi-Definiteness -/

/-
**Positive semi-definiteness of the weighted Laplacian.**
    When all edge weights are positive, `x^T L x ≥ 0` for all `x`.
    The weighted Laplacian has positive diagonal and negative off-diagonal
    entries, making the associated quadratic form non-negative.
-/
theorem weightedLaplacian_psd
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℝ)
    (hw_pos : ∀ i j, G.Adj i j → 0 < w i j)
    (hw_symm : ∀ i j, w i j = w j i)
    (x : V → ℝ) :
    0 ≤ ∑ i : V, ∑ j : V, weightedLaplacian G w i j * x i * x j := by
  -- By definition of weightedLaplacian, we can expand the expression into two sums:
  have h_expand : ∑ i, ∑ j, (if i = j then (∑ k ∈ Finset.univ.filter (G.Adj i), w i k) else if G.Adj i j then -(w i j) else 0) * x i * x j = ∑ i, (∑ k ∈ Finset.univ.filter (G.Adj i), w i k * x i * (x i - x k)) := by
    simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, Finset.sum_sub_distrib, mul_sub ];
    simp +decide [ Finset.sum_add_distrib, Finset.sum_mul _ _ _, Finset.sum_ite, Finset.filter_erase ];
    rfl;
  -- By symmetry of the weight function, we can pair each term $w_{ij} x_i (x_i - x_j)$ with $w_{ji} x_j (x_j - x_i)$.
  have h_pair : ∑ i, ∑ k ∈ Finset.univ.filter (G.Adj i), w i k * x i * (x i - x k) = ∑ i, ∑ k ∈ Finset.univ.filter (G.Adj i), w i k * x k * (x k - x i) := by
    rw [ Finset.sum_sigma', Finset.sum_sigma' ];
    apply Finset.sum_bij (fun p hp => ⟨p.snd, p.fst⟩) _ _ _ _ <;> simp +decide [ hw_symm ];
    · exact fun a ha => ha.symm;
    · bound;
    · exact fun b hb => ⟨ _, _, hb.symm, rfl ⟩;
  -- By combining terms, we can factor out $w_{ij}$ and simplify the expression.
  have h_combine : ∑ i, ∑ k ∈ Finset.univ.filter (G.Adj i), w i k * x i * (x i - x k) + ∑ i, ∑ k ∈ Finset.univ.filter (G.Adj i), w i k * x k * (x k - x i) = ∑ i, ∑ k ∈ Finset.univ.filter (G.Adj i), w i k * (x i - x k) ^ 2 := by
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by ring;
  exact h_expand.symm ▸ by linarith [ show 0 ≤ ∑ i, ∑ k with ( G.Adj i ) k, w i k * ( x i - x k ) ^ 2 by exact Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => mul_nonneg ( le_of_lt ( hw_pos i j ( by simpa using hj ) ) ) ( sq_nonneg _ ) ] ;