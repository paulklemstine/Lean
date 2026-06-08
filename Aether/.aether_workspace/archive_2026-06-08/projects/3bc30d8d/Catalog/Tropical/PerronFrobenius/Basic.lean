/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Perron–Frobenius: Core Theorems

This file establishes the fundamental algebraic and spectral properties of
the max-plus tropical matrix-vector action over finite real matrices.

## Main results

- `tropMatVec_add_const`: Translation equivariance `T_A(x + c) = T_A(x) + c`
- `tropMatVec_mono`: Monotonicity of the tropical action
- `tropMatVec_le_iff`: Characterization of `T_A(x)_i ≤ b`
- `tropMatVec_exists_maximizer`: Existence of a maximizing predecessor
- `tropIterate_eigenpair`: **Exact linear growth along eigenvectors** —
  the core scheduling theorem
- `tropIterate_eigenpair_growth`: Per-step growth rate is exactly `λ`
- `collatz_wielandt_upper`: Upper Collatz–Wielandt bound on eigenvalues
- `collatz_wielandt_lower`: Lower Collatz–Wielandt bound on eigenvalues
- `eigenpair_1x1`: Eigenpair for 1×1 systems
- `example_2x2_eigenpair`: Certified eigenpair for a concrete manufacturing cell
- `example_2x2_eigenvalue_eq_maxCycleMean`: Eigenvalue = max cycle mean (2×2 case)

## Application

These theorems together certify the throughput of finite-state discrete-event
systems: the tropical eigenvalue is the exact asymptotic cycle time, verified
by machine-checked proof rather than simulation or approximation.
-/
import Mathlib
import Tropical.PerronFrobenius.Defs

open Finset Matrix

/-! ## Translation Equivariance -/

/-
The tropical action commutes with scalar translation:
    `T_A(x + c·𝟏) = T_A(x) + c·𝟏`.
    This is the key property making tropical eigenvalues well-defined
    as growth rates independent of absolute timing.
-/
theorem tropMatVec_add_const {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (c : ℝ) :
    tropMatVec A (fun i => x i + c) = fun i => tropMatVec A x i + c := by
  unfold tropMatVec;
  simp +decide [ add_assoc, Finset.sup'_add ]

/-! ## Monotonicity -/

/-
The tropical action is order-preserving:
    if `x ≤ y` pointwise, then `T_A(x) ≤ T_A(y)` pointwise.
    Scheduling interpretation: larger completion times propagate forward.
-/
theorem tropMatVec_mono {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {x y : Fin n → ℝ}
    (hle : ∀ i, x i ≤ y i) :
    ∀ i, tropMatVec A x i ≤ tropMatVec A y i := by
  -- Apply the monotonicity of the supremum to each component.
  intros i
  simp [tropMatVec];
  exact Finset.exists_max_image Finset.univ ( fun j => A i j + y j ) ⟨ i, Finset.mem_univ i ⟩ |> fun ⟨ j, hj ⟩ => ⟨ j, fun k => by linarith [ hle k, hj.2 k ( Finset.mem_univ k ) ] ⟩

/-! ## Eigenvector Characterization Lemmas -/

/-
`T_A(x)_i ≤ b` iff every summand `A_{ij} + x_j ≤ b`.
-/
theorem tropMatVec_le_iff {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin n) (b : ℝ) :
    tropMatVec A x i ≤ b ↔ ∀ j, A i j + x j ≤ b := by
  exact ⟨ fun h j => le_trans ( Finset.le_sup' ( fun j => A i j + x j ) ( Finset.mem_univ j ) ) h, fun h => Finset.sup'_le _ _ fun j _ => h j ⟩

/-
There exists `j` achieving the maximum in `T_A(x)_i`.
-/
theorem tropMatVec_exists_maximizer {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin n) :
    ∃ j, tropMatVec A x i = A i j + x j := by
  have h_max : ∃ j ∈ Finset.univ, ∀ k ∈ Finset.univ, A i k + x k ≤ A i j + x j := by
    exact Finset.exists_max_image _ _ ⟨ i, Finset.mem_univ _ ⟩;
  obtain ⟨ j, hj₁, hj₂ ⟩ := h_max; exact ⟨ j, le_antisymm ( Finset.sup'_le _ _ fun k hk => hj₂ k <| Finset.mem_univ k ) <| Finset.le_sup' ( fun k => A i k + x k ) hj₁ ⟩ ;

/-! ## Linear Growth Along Eigenvectors — The Scheduling Theorem -/

/-
**Certified linear growth theorem.**
    If `(λ, v)` is a tropical eigenpair of `A`, then the k-th iterate
    of the system starting from `v` equals `kλ + v` exactly.

    **Scheduling interpretation:** After `k` synchronization rounds,
    every task's completion time is exactly `k · λ + v_i`, where `λ`
    is the cycle time and `v_i` is the initial phase offset.
    The throughput is `1/λ` tasks per unit time.
-/
theorem tropIterate_eigenpair {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v) :
    ∀ k, tropIterate A v k = fun i => k * lam + v i := by
  -- We proceed by induction on $k$.
  intro k
  induction' k with k ih;
  · aesop;
  · -- Apply the induction hypothesis and the definition of tropMatVec.
    have h_step : tropMatVec A (fun i => k * lam + v i) = fun i => k * lam + tropMatVec A v i := by
      convert tropMatVec_add_const A v ( k * lam ) using 1;
      · ac_rfl;
      · grind;
    simp_all +decide [ add_mul, add_assoc, tropIterate ];
    exact funext fun i => congr_arg _ ( hEig i )

/-
Per-step growth rate is exactly `λ`.
-/
theorem tropIterate_eigenpair_growth {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v) :
    ∀ k i, tropIterate A v (k + 1) i - tropIterate A v k i = lam := by
  -- We use the two results we already have about `tropIterate`:
  -- - The previous statement of how `tropIterate` grows along eigenvectors
  -- - The definition of `IsTropicalEigenpair`
  intro k i
  rw [tropIterate_eigenpair A hEig k, tropIterate_eigenpair A hEig (k + 1)]
  simp;
  ring

/-! ## Collatz–Wielandt Bounds -/

/-
**Collatz–Wielandt upper bound.** For any tropical eigenvalue `λ` and any
    vector `x`, we have `λ ≤ max_i (T_A(x)_i - x_i)`.
    This gives a certified upper bound on the cycle time from any test vector.
-/
theorem collatz_wielandt_upper {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v) (x : Fin n → ℝ) :
    lam ≤ Finset.sup' Finset.univ Finset.univ_nonempty
      (fun i => tropMatVec A x i - x i) := by
  -- Let $i_0$ be the index that minimizes $(x - v)$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, x i₀ - v i₀ ≤ x i - v i := by
    simpa using Finset.exists_min_image Finset.univ ( fun i => x i - v i ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩;
  refine' le_trans _ ( Finset.le_sup' _ ( Finset.mem_univ i₀ ) );
  -- By definition of $i₀$, we have $A i₀ j + x j \geq A i₀ j + v j + (x i₀ - v i₀)$ for all $j$.
  have h_ineq : ∀ j, A i₀ j + x j ≥ A i₀ j + v j + (x i₀ - v i₀) := by
    exact fun j => by linarith [ hi₀ j ] ;
  -- By definition of $i₀$, we have $T_A(x)_{i₀} \geq T_A(v)_{i₀} + (x i₀ - v i₀)$.
  have h_T_ineq : tropMatVec A x i₀ ≥ tropMatVec A v i₀ + (x i₀ - v i₀) := by
    unfold tropMatVec;
    simp +zetaDelta at *;
    exact Exists.elim ( Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) fun j => A i₀ j + v j ) fun j hj => ⟨ j, by linarith [ h_ineq j ] ⟩;
  linarith [ hEig i₀ ]

/-
**Collatz–Wielandt lower bound.** For any tropical eigenvalue `λ` and any
    vector `x`, we have `min_i (T_A(x)_i - x_i) ≤ λ`.
    This gives a certified lower bound on the cycle time from any test vector.
-/
theorem collatz_wielandt_lower {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) {lam : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A lam v) (x : Fin n → ℝ) :
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun i => tropMatVec A x i - x i) ≤ lam := by
  -- Let $i_0$ be such that $x_{i_0} - v_{i_0}$ is maximal.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, x i - v i ≤ x i₀ - v i₀ := by
    simpa using Finset.exists_max_image Finset.univ ( fun i => x i - v i ) ( Finset.univ_nonempty );
  -- Then for all $j$, $x_j - v_j \leq x_{i₀} - v_{i₀}$, i.e., $x_j \leq v_j + (x_{i₀} - v_{i₀})$.
  have h_le : ∀ j, x j ≤ v j + (x i₀ - v i₀) := by
    exact fun j => by linarith [ hi₀ j ] ;
  -- Then $T_A(x)_{i₀} \leq T_A(v)_{i₀} + (x_{i₀} - v_{i₀})$.
  have h_trop_le : tropMatVec A x i₀ ≤ tropMatVec A v i₀ + (x i₀ - v i₀) := by
    convert tropMatVec_mono A h_le i₀ using 1;
    exact Eq.symm ( tropMatVec_add_const A v ( x i₀ - v i₀ ) ▸ by norm_num );
  exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ i₀ ) ) ( by linarith [ hEig i₀ ] )

/-! ## 1×1 Case -/

/-
For a 1×1 matrix `[[a]]`, `(a, fun _ => 0)` is a tropical eigenpair.
-/
theorem eigenpair_1x1 (a : ℝ) :
    IsTropicalEigenpair (Matrix.of !![a]) a (fun _ : Fin 1 => 0) := by
  -- Show that `a` is an eigenvalue of `!![a]` with eigenvector `0`.
  unfold IsTropicalEigenpair;
  -- Simplify the definition of tropMatVec for the 1x1 matrix.
  simp [tropMatVec]

/-! ## Concrete 2×2 Example: Manufacturing Cell -/

/-- A 2×2 matrix modeling a two-machine manufacturing cell:
    `A = [[0, 2], [3, 0]]`.
    - Self-processing times are 0
    - Transfer 2→1 takes 2 time units
    - Transfer 1→2 takes 3 time units -/
noncomputable def exampleMatrix : Matrix (Fin 2) (Fin 2) ℝ :=
  Matrix.of !![0, 2; 3, 0]

/-- Eigenvector: `v = (0, 1/2)`. -/
noncomputable def exampleEigenvector : Fin 2 → ℝ := ![0, 1/2]

/-- Eigenvalue (cycle time): `λ = 5/2 = 2.5`. -/
noncomputable def exampleEigenvalue : ℝ := 5 / 2

/-
**Certified throughput for the 2×2 manufacturing cell.**
    Cycle time = 5/2, throughput = 2/5 parts per time unit.
-/
theorem example_2x2_eigenpair :
    IsTropicalEigenpair exampleMatrix exampleEigenvalue exampleEigenvector := by
  intro i;
  fin_cases i <;> norm_num [ Finset.univ_fin2, tropMatVec, exampleMatrix, exampleEigenvector, exampleEigenvalue ]

/-
The eigenvalue equals the maximum cycle mean for the 2×2 example:
    `5/2 = max(0, 0, (2+3)/2) = 5/2`.
-/
theorem example_2x2_eigenvalue_eq_maxCycleMean :
    exampleEigenvalue = maxCycleMean_2 exampleMatrix := by
  unfold maxCycleMean_2 exampleMatrix exampleEigenvalue; norm_num;