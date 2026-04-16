/-! # CatalogBuild.Algebra.OptimizationTheory

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 5
-/

import Mathlib

theorem sq_convex (a b : ℝ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (t * a + (1 - t) * b) ^ 2 ≤ t * a ^ 2 + (1 - t) * b ^ 2 := by
  nlinarith [ sq_nonneg ( a - b ), mul_nonneg ht0 ( sub_nonneg_of_le ht1 ) ] ;


theorem jensen_sq (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) :
    ((∑ i, x i) / n) ^ 2 ≤ (∑ i, (x i) ^ 2) / n := by
  -- Applying the Cauchy-Schwarz inequality in its generalized form for sequences in Euclidean space.
  have h_cauchy_schwarz : ∀ (u v : Fin n → ℝ), (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
    exact?;
  have := h_cauchy_schwarz ( fun _ => 1 ) x; simp_all +decide [ div_pow, mul_comm, mul_assoc, mul_left_comm, hn.ne' ] ;
  rw [ div_le_div_iff₀ ] <;> first | positivity | nlinarith;


/-- 2^n ≤ 4^n (gate count lower bound for n qubits). -/
theorem gate_count_lower_bound (n : ℕ) : 2 ^ n ≤ 4 ^ n :=
  Nat.pow_le_pow_left (by norm_num : 2 ≤ 4) n


/-- The trace is linear on matrices. -/
theorem trace_linear_2x2 (A B : Matrix (Fin 2) (Fin 2) ℝ) (c : ℝ) :
    Matrix.trace (c • A + B) = c * Matrix.trace A + Matrix.trace B := by
  simp [Matrix.trace_add, Matrix.trace_smul, smul_eq_mul]


/-- For f(x) = x²/2, one step of GD with step size 1 from x gives 0. -/
theorem gd_quadratic_one_step (x : ℝ) :
    x - 1 * x = (0 : ℝ) := by ring
