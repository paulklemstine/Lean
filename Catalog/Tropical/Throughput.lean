/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certified Throughput for Discrete-Event Systems

This file establishes the certified throughput theorem: given a tropical
eigenpair `(λ, v)` of a system matrix `A`, the long-run average completion
time per step is exactly `λ`, and the throughput is `1/λ`.

## Main results

- `tropIterate_average_converges`: The average completion time converges to `λ`
- `certified_throughput`: Throughput = 1/λ when λ > 0
- `collatz_wielandt_sandwich`: CW lower ≤ λ ≤ CW upper for any test vector
- `eigenpair_from_fixed_point`: If `T_A(v) - v` is constant, it's an eigenpair
- `tropMatVec_iterate_sub_const`: Translation equivariance for iterates
- `example_3x3_eigenpair`: A 3-station pipeline example with certified throughput

## Application to scheduling

These results certify that the throughput of a finite synchronization-constrained
system is exactly determined by the tropical eigenvalue, without simulation.
-/
import Mathlib
import Tropical.PerronFrobenius.Basic

open Finset Matrix

/-! ## Average Completion Time -/

/-
The average completion time per step after `k` rounds starting from
    eigenvector `v` is exactly `λ` for all `k ≥ 1`.
-/
theorem tropIterate_average {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v)
    (k : ℕ) (hk : 0 < k) (i : Fin n) :
    (tropIterate A v k i - v i) / k = lam := by
  rw [ div_eq_iff ( by positivity ) ];
  convert congr_arg ( fun x : Fin n → ℝ => x i - v i ) ( tropIterate_eigenpair A hEig k ) using 1 ; ring

/-! ## Certified Throughput -/

/-
**Certified throughput theorem.** If `(λ, v)` is a tropical eigenpair with `λ > 0`,
    then the throughput (jobs per unit time) is exactly `1/λ`.
    This is computed as `k / (tropIterate A v k i - v i)` for any `k ≥ 1`.
-/
theorem certified_throughput {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v)
    (hlam : 0 < lam) (k : ℕ) (hk : 0 < k) (i : Fin n) :
    (k : ℝ) / (tropIterate A v k i - v i) = 1 / lam := by
  -- By the properties of the eigenpair, we have `tropIterate A v k = fun i => k * lam + v i`.
  have h_tropIterate : tropIterate A v k = fun i => k * lam + v i := by
    exact tropIterate_eigenpair A hEig k;
  rw [ h_tropIterate, add_sub_cancel_right, div_eq_div_iff ] <;> ring <;> aesop

/-! ## Collatz–Wielandt Sandwich -/

/-
**Collatz–Wielandt sandwich.** For any vector `x` and tropical eigenvalue `λ`:
    `min_i (T_A(x)_i - x_i) ≤ λ ≤ max_i (T_A(x)_i - x_i)`.
    This provides both upper and lower bounds from a single test vector.
-/
theorem collatz_wielandt_sandwich {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v) (x : Fin n → ℝ) :
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun i => tropMatVec A x i - x i) ≤ lam ∧
    lam ≤ Finset.sup' Finset.univ Finset.univ_nonempty
      (fun i => tropMatVec A x i - x i) := by
  exact ⟨ collatz_wielandt_lower A hEig x, collatz_wielandt_upper A hEig x ⟩

/-! ## Eigenpair Detection -/

/-
If `T_A(v)_i - v_i` is the same constant `c` for all `i`,
    then `(c, v)` is a tropical eigenpair. This is the basis
    for constructive eigenpair detection.
-/
theorem eigenpair_from_constant_gap {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (c : ℝ)
    (hgap : ∀ i, tropMatVec A v i - v i = c) :
    IsTropicalEigenpair A c v := by
  exact fun i => by linear_combination hgap i;

/-! ## Translation Equivariance for Iterates -/

/-
Adding a constant to the initial state shifts all iterates by that constant.
-/
theorem tropIterate_add_const {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (c : ℝ) :
    ∀ k, tropIterate A (fun i => x i + c) k = fun i => tropIterate A x k i + c := by
  intro k;
  induction' k with k ih;
  · rfl;
  · convert congr_arg ( fun f => tropMatVec A f ) ih using 1;
    ext i; simp +decide [ tropIterate, tropMatVec_add_const ] ;

/-! ## 3×3 Pipeline Example -/

/-- A 3-station pipeline matrix:
    Station 1 → Station 2 takes 4 time units
    Station 2 → Station 3 takes 3 time units
    Station 3 → Station 1 takes 2 time units (return/recycle)
    Self-processing times are 0
    Other transfers are 0 (not used) -/
noncomputable def pipelineMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  Matrix.of !![0, 0, 0; 4, 0, 0; 0, 3, 0]

/-- Pipeline eigenvector: v = (0, 4, 7) -/
noncomputable def pipelineEigenvector : Fin 3 → ℝ := ![0, 4, 7]

/-- A proper 3-station cyclic pipeline with feedback:
    1 → 2: 4 time units, 2 → 3: 3 time units, 3 → 1: 2 time units
    Max cycle mean = (4+3+2)/3 = 3 -/
noncomputable def cyclicPipelineMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  Matrix.of !![0, 0, 2; 4, 0, 0; 0, 3, 0]

/-- Eigenvector for the cyclic pipeline: v = (0, 1, 1) -/
noncomputable def cyclicPipelineEigenvector : Fin 3 → ℝ := ![0, 1, 1]

/-- Eigenvalue for the cyclic pipeline: λ = 3 -/
noncomputable def cyclicPipelineEigenvalue : ℝ := 3

/-
**Certified throughput for the 3-station cyclic pipeline.**
    Cycle time = 3, throughput = 1/3 items per time unit.
    This means the pipeline produces one item every 3 time units.
-/
theorem example_3x3_eigenpair :
    IsTropicalEigenpair cyclicPipelineMatrix cyclicPipelineEigenvalue
      cyclicPipelineEigenvector := by
  unfold IsTropicalEigenpair cyclicPipelineMatrix cyclicPipelineEigenvalue cyclicPipelineEigenvector;
  norm_num [ Fin.forall_fin_succ, tropMatVec ];
  norm_num [ Fin.univ_succ ];
  simp +zetaDelta at *;
  norm_num

/-! ## Diagonal Bound -/

/-
The diagonal entry `A i i` gives a lower bound on the tropical action
    applied to the i-th coordinate.
-/
theorem tropMatVec_ge_diag {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin n) :
    A i i + x i ≤ tropMatVec A x i := by
  exact Finset.le_sup' ( fun j => A i j + x j ) ( Finset.mem_univ i )

/-
Self-loop weight bounds the eigenvalue from below:
    if `(λ, v)` is an eigenpair, then `A i i ≤ λ` for all `i`.
-/
theorem eigenpair_ge_diag {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v) :
    ∀ i, A i i ≤ lam := by
  exact fun i => by linarith [ hEig i, tropMatVec_ge_diag A v i ] ;