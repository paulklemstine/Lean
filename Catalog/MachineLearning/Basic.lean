/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Gradient Descent Convergence Theory

This file formalizes the convergence theory of gradient descent for strongly convex
quadratic functions, establishing the fundamental result that underpins optimization
in machine learning.

## Main Results

* `gd_error_eq` — The error of gradient descent on a quadratic `f(x) = (a/2)x²`
  with step size `η` satisfies `e_n = (1 - ηa)^n · e_0`
* `gd_contraction_factor_lt_one` — The contraction factor `|1 - ηa| < 1` when
  `0 < η < 2/a`
* `gd_converges` — Gradient descent converges: `x_n → x*`
* `gd_geometric_rate` — The convergence rate is geometric:
  `|x_n - x*| ≤ |1 - ηa|^n · |x_0 - x*|`
* `gd_optimal_step` — The optimal step size is `η = 1/a`, giving convergence in one step
* `gd_condition_number_bound` — For 2D quadratics with eigenvalues `μ ≤ L`,
  the optimal convergence rate is `(κ-1)/(κ+1)` where `κ = L/μ`

## References

* Nesterov, Y. (2004). *Introductory Lectures on Convex Optimization*
* Boyd, S. & Vandenberghe, L. (2004). *Convex Optimization*
-/

open Filter Topology Real

noncomputable section

/-!
## Part 1: Geometric Convergence of Linear Recurrences

We first establish that sequences satisfying `x_{n+1} = r · x_n` converge geometrically
when `|r| < 1`. This is the mathematical core of gradient descent convergence.
-/

/-
A geometric sequence `r^n * x₀` with `|r| < 1` converges to zero.
-/
theorem geom_seq_tendsto_zero {r x₀ : ℝ} (hr : |r| < 1) :
    Tendsto (fun n => r ^ n * x₀) atTop (nhds 0) := by
      simpa using tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr |> Filter.Tendsto.mul_const x₀

/-
Geometric bound: `|r^n * x₀| ≤ |r|^n * |x₀|`.
-/
theorem geom_seq_abs_bound (r x₀ : ℝ) (n : ℕ) :
    |r ^ n * x₀| = |r| ^ n * |x₀| := by
      rw [ abs_mul, abs_pow ]

/-
If `|r| < 1`, then `|r|^n → 0`.
-/
theorem geom_decay {r : ℝ} (hr : |r| < 1) :
    Tendsto (fun n => |r| ^ n) atTop (nhds 0) := by
      exact tendsto_pow_atTop_nhds_zero_of_lt_one ( abs_nonneg r ) hr

/-!
## Part 2: Gradient Descent on Quadratic Functions

We formalize gradient descent on the 1D quadratic `f(x) = (a/2) · x²` with `a > 0`.
The gradient is `f'(x) = a · x`, and the GD update is:

  `x_{n+1} = x_n - η · a · x_n = (1 - η·a) · x_n`

The minimizer is `x* = 0`, so the error is `e_n = x_n - 0 = x_n`.
-/

/-- The gradient descent iteration for `f(x) = (a/2)x²`:
    `gd_step a η x = x - η * (a * x) = (1 - η * a) * x` -/
def gd_step (a η : ℝ) (x : ℝ) : ℝ := x - η * (a * x)

/-- The n-th iterate of gradient descent starting from `x₀`. -/
def gd_iterate (a η : ℝ) (x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => gd_step a η (gd_iterate a η x₀ n)

/-- The gradient descent step simplifies to multiplication by `(1 - η * a)`. -/
theorem gd_step_eq (a η x : ℝ) : gd_step a η x = (1 - η * a) * x := by
  unfold gd_step; ring

/-
The n-th GD iterate equals `(1 - η*a)^n * x₀`.
-/
theorem gd_iterate_eq (a η x₀ : ℝ) (n : ℕ) :
    gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ := by
      induction' n with n ih;
      · aesop;
      · convert congr_arg ( fun x => ( 1 - η * a ) * x ) ih using 1 <;> ring;
        rw [ add_comm, show gd_iterate a η x₀ ( n + 1 ) = gd_step a η ( gd_iterate a η x₀ n ) by rfl, gd_step_eq ] ; ring

/-!
## Part 3: Convergence Analysis

The key insight: gradient descent converges when the contraction factor `|1 - η·a|`
is strictly less than 1, which holds precisely when `0 < η < 2/a`.
-/

/-
The contraction factor `|1 - η*a| < 1` when `0 < η*a < 2`.
-/
theorem contraction_factor_lt_one {η a : ℝ} (hηa_pos : 0 < η * a) (hηa_lt : η * a < 2) :
    |1 - η * a| < 1 := by
      exact abs_lt.mpr ⟨ by linarith, by linarith ⟩

/-
When `a > 0` and `0 < η < 2/a`, we have `0 < η*a < 2`.
-/
theorem step_size_valid {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a) :
    0 < η * a ∧ η * a < 2 := by
      constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ]

/-
**Main convergence theorem**: Gradient descent on `f(x) = (a/2)x²` converges
    to the minimizer `x* = 0` when the step size satisfies `0 < η < 2/a`.
-/
theorem gd_converges {a η : ℝ} (ha : 0 < a) (hη_pos : 0 < η) (hη_lt : η < 2 / a)
    (x₀ : ℝ) : Tendsto (gd_iterate a η x₀) atTop (nhds 0) := by
      -- Use `gd_iterate_eq` to rewrite the sequence as `(1 - η * a) ^ n * x₀`.
      have h_seq_eq : ∀ n, gd_iterate a η x₀ n = (1 - η * a) ^ n * x₀ :=
        fun n => gd_iterate_eq a η x₀ n
      rw [ show gd_iterate a η x₀ = _ from funext h_seq_eq ] ; exact geom_seq_tendsto_zero ( by rw [ abs_lt ] ; constructor <;> nlinarith [ mul_div_cancel₀ 2 ha.ne' ] )

/-
**Geometric convergence rate**: `|x_n| ≤ |1 - ηa|^n · |x₀|`.
-/
theorem gd_geometric_rate (a η x₀ : ℝ) (n : ℕ) :
    |gd_iterate a η x₀ n| = |1 - η * a| ^ n * |x₀| := by
      rw [ gd_iterate_eq, abs_mul, abs_pow ]

/-
**Optimal step size**: When `η = 1/a`, gradient descent converges in one step:
    the contraction factor is 0, so `x₁ = 0`.
-/
theorem gd_optimal_one_step {a : ℝ} (ha : 0 < a) (x₀ : ℝ) :
    gd_iterate a (1 / a) x₀ 1 = 0 := by
      exact show x₀ - 1 / a * ( a * x₀ ) = 0 from by ring_nf; norm_num [ ha.ne' ] ;

/-
For `η = 1/a`, all iterates after the first are 0.
-/
theorem gd_optimal_all_zero {a : ℝ} (ha : 0 < a) (x₀ : ℝ) (n : ℕ) (hn : 0 < n) :
    gd_iterate a (1 / a) x₀ n = 0 := by
      convert gd_iterate_eq a ( 1 / a ) x₀ n using 1 ; norm_num [ ha.ne' ];
      aesop

/-!
## Part 4: Condition Number and Two-Dimensional Analysis

For the 2D quadratic `f(x,y) = (a/2)x² + (b/2)y²` with `0 < μ ≤ L` (eigenvalues),
the optimal step size is `η = 2/(μ + L)` and the convergence rate is
`(L - μ)/(L + μ) = (κ - 1)/(κ + 1)` where `κ = L/μ` is the condition number.
-/

/-- The condition number `κ = L/μ` for eigenvalues `μ ≤ L`. -/
def conditionNumber (μ L : ℝ) : ℝ := L / μ

/-- The optimal convergence rate for a 2D quadratic with eigenvalues `μ` and `L`. -/
def optimalRate (μ L : ℝ) : ℝ := (L - μ) / (L + μ)

/-
The optimal convergence rate equals `(κ-1)/(κ+1)`.
-/
theorem optimal_rate_eq_condition {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
    optimalRate μ L = (conditionNumber μ L - 1) / (conditionNumber μ L + 1) := by
      unfold optimalRate conditionNumber;
      grind

/-
The optimal rate is in `[0, 1)` when `0 < μ ≤ L`.
-/
theorem optimal_rate_nonneg {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
    0 ≤ optimalRate μ L := by
      exact div_nonneg ( by linarith ) ( by linarith )

theorem optimal_rate_lt_one {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
    optimalRate μ L < 1 := by
      exact div_lt_one ( by positivity ) |>.2 ( by linarith )

/-
Well-conditioned problems (κ ≈ 1) converge fast: rate = 0 when μ = L.
-/
theorem optimal_rate_well_conditioned (μ : ℝ) :
    optimalRate μ μ = 0 := by
      unfold optimalRate; ring

/-- The optimal step size for a 2D quadratic is `2/(μ + L)`. -/
def optimalStepSize (μ L : ℝ) : ℝ := 2 / (μ + L)

/-
With the optimal step size `η = 2/(μ+L)`, the contraction factors for
    both coordinates are `±(L-μ)/(L+μ)`, giving the optimal rate.
-/
theorem optimal_step_contraction_small {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
    1 - optimalStepSize μ L * μ = optimalRate μ L := by
      unfold optimalStepSize optimalRate; rw [ div_mul_eq_mul_div, one_sub_div ] ; ring ; positivity;

theorem optimal_step_contraction_large {μ L : ℝ} (hμ : 0 < μ) (hL : 0 < L) :
    1 - optimalStepSize μ L * L = -(optimalRate μ L) := by
      grind +locals

/-
**Fundamental bound**: The number of iterations needed to reduce error by factor ε
    is proportional to κ · log(1/ε), where κ is the condition number. This is captured
    by the fact that log(1/rate) ≈ 2/κ for large κ.
-/
theorem iteration_complexity_bound {μ L : ℝ} (hμ : 0 < μ) (hμL : μ ≤ L) :
    optimalRate μ L ≤ 1 - 2 / (conditionNumber μ L + 1) := by
      unfold optimalRate conditionNumber;
      rw [ one_sub_div, div_le_div_iff₀ ] <;> nlinarith [ mul_div_cancel₀ L hμ.ne' ]

end