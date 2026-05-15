import Mathlib

/-!
# Cut Metrics and Conditional Negative Definiteness

This file establishes the foundational engine for the spectral theory of novelty:
the **cut metric quadratic identity**. For any subset S of a finite index set and any
zero-sum vector x, the quadratic form of the cut metric equals -2 times the square
of the partial sum over S. This immediately implies conditional negative semidefiniteness
of any nonnegative weighted combination of cut metrics.

## Main Results

* `cut_metric_quad_identity` — The quadratic form identity for cut metrics on zero-sum vectors
* `condNeg_of_nonneg_cut_sum` — Nonneg weighted sums of cut metrics are cond. neg. semidef.

## Tags

ultrametric geometry, spectral theory, conditionally negative definite kernels,
hierarchical clustering, compression duality, cut metrics
-/

open Finset BigOperators

/-- A cut metric on `Fin n` induced by a subset `S`: equals 1 when exactly one of the
    two points lies in S, and 0 otherwise. This is the fundamental building block for
    decomposing ultrametric distances into hierarchical scales. -/
noncomputable def cutMetric {n : ℕ} (S : Finset (Fin n)) (i j : Fin n) : ℝ :=
  if (i ∈ S ∧ j ∉ S) ∨ (j ∈ S ∧ i ∉ S) then 1 else 0

/-- The cut metric is symmetric. -/
theorem cutMetric_symm {n : ℕ} (S : Finset (Fin n)) (i j : Fin n) :
    cutMetric S i j = cutMetric S j i := by
  simp only [cutMetric]
  split <;> split <;> simp_all <;> tauto

/-- The cut metric vanishes on the diagonal. -/
theorem cutMetric_self {n : ℕ} (S : Finset (Fin n)) (i : Fin n) :
    cutMetric S i i = 0 := by
  simp [cutMetric]

/-
**Cut Metric Quadratic Identity (Engine Lemma)**.
For any subset S ⊆ Fin n and any zero-sum real vector x,
the quadratic form of the cut metric equals -2(∑_{i ∈ S} x_i)².

This is the core engine driving the spectral theory of novelty:
it shows that each hierarchical scale contributes a nonpositive
quadratic energy to zero-sum vectors.
-/
theorem cut_metric_quad_identity {n : ℕ} (S : Finset (Fin n))
    (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
    ∑ i : Fin n, ∑ j : Fin n, x i * x j * cutMetric S i j =
      -2 * (∑ i ∈ S, x i) ^ 2 := by
  -- Split the double sum into four parts based on membership in S: (i ∈ S, j ∈ S), (i ∈ S, j ∉ S), (i ∉ S, j ∈ S), (i ∉ S, j ∉ S).
  have h_split : ∑ i, ∑ j, x i * x j * (cutMetric S i j) = (∑ i ∈ S, ∑ j ∈ Sᶜ, x i * x j) + (∑ i ∈ Sᶜ, ∑ j ∈ S, x i * x j) := by
    -- We can split the double sum into two separate sums based on membership in S and its complement.
    have h_split : ∑ i, ∑ j, x i * x j * (cutMetric S i j) = ∑ i, ∑ j, (if i ∈ S then if j ∉ S then x i * x j else 0 else if j ∈ S then x i * x j else 0) := by
      exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by unfold cutMetric; aesop;
    simp_all +decide [ Finset.sum_ite, Finset.filter_mem_eq_inter, Finset.filter_not ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Finset.compl_eq_univ_sdiff ];
    ring;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Finset.compl_eq_univ_sdiff ];
  ring

/-- A single cut metric is conditionally negative semidefinite:
its quadratic form on zero-sum vectors is nonpositive. -/
theorem cut_metric_condNeg {n : ℕ} (S : Finset (Fin n))
    (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
    ∑ i : Fin n, ∑ j : Fin n, x i * x j * cutMetric S i j ≤ 0 := by
  rw [cut_metric_quad_identity S x hx]
  nlinarith [sq_nonneg (∑ i ∈ S, x i)]

/-
**Weighted Cut Sum Conditional Negative Semidefiniteness**.
Any nonnegative weighted sum of cut metrics is conditionally negative semidefinite
on zero-sum vectors. This abstracts the core spectral property of hierarchical
decompositions: novelty measured through hierarchical scales always produces
nonpositive quadratic energy on centered observations.
-/
theorem condNeg_of_nonneg_cut_sum {n m : ℕ}
    (w : Fin m → ℝ) (S : Fin m → Finset (Fin n))
    (hw : ∀ t, 0 ≤ w t)
    (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
    ∑ i : Fin n, ∑ j : Fin n, x i * x j * (∑ t : Fin m, w t * cutMetric (S t) i j) ≤ 0 := by
  -- By swapping the order of summation we can factor out the weights $w_t$ and apply the cut_metric_condNeg theorem.
  have h_sum_swap : ∑ i, ∑ j : Fin n, x i * x j * (∑ t, w t * cutMetric (S t) i j) = ∑ t, w t * (∑ i : Fin n, ∑ j : Fin n, x i * x j * cutMetric (S t) i j) := by
    simp +decide only [Finset.mul_sum _ _ _, mul_left_comm];
    exact?;
  exact h_sum_swap.symm ▸ Finset.sum_nonpos fun t _ => mul_nonpos_of_nonneg_of_nonpos ( hw t ) ( cut_metric_condNeg ( S t ) x hx )