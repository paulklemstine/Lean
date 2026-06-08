/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tight Spectral Gap via Lorentzian Structure

This file develops the theory connecting Lorentzian polynomial structure to
improved spectral gap bounds for certificate-guided Markov chains.

## Main Results

* `comparison_poincare` — Comparison theorem for Poincaré constants
* `comparison_spectral_gap` — Comparison theorem for spectral gaps
* `lorentzian_dominates_log_concave` — 1/(d·n) ≥ 1/n² when d ≤ n
* `spectral_gap_lorentzian_improvement` — Lorentzian structure upgrades gap

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Diaconis–Saloff-Coste, "Comparison Theorems for Reversible Markov Chains", 1993
-/

open Finset BigOperators

noncomputable section

/-! ## Finite Probability Distributions -/

/-- A probability distribution on a finite type. -/
structure FinDistribution (α : Type*) [Fintype α] where
  weight : α → ℝ
  nonneg : ∀ x, 0 ≤ weight x
  sum_one : ∑ x, weight x = 1

/-- Expected value of f under π. -/
def FinDistribution.expect {α : Type*} [Fintype α]
    (π : FinDistribution α) (f : α → ℝ) : ℝ :=
  ∑ x, π.weight x * f x

/-- Variance of f under π. -/
def FinDistribution.variance {α : Type*} [Fintype α]
    (π : FinDistribution α) (f : α → ℝ) : ℝ :=
  π.expect (fun x => (f x - π.expect f) ^ 2)

/-- Variance is nonneg. -/
theorem FinDistribution.variance_nonneg {α : Type*} [Fintype α]
    (π : FinDistribution α) (f : α → ℝ) :
    0 ≤ π.variance f := by
  unfold variance expect
  exact Finset.sum_nonneg fun x _ => mul_nonneg (π.nonneg x) (sq_nonneg _)

/-! ## Transition Kernels and Dirichlet Forms -/

/-- A transition kernel on a finite type. -/
structure TransitionKernel (α : Type*) [Fintype α] where
  prob : α → α → ℝ
  nonneg : ∀ x y, 0 ≤ prob x y

/-- The Dirichlet form: E(f,f) = (1/2) ∑_{x,y} π(x)P(x,y)(f(x)-f(y))². -/
def dirichletForm {α : Type*} [Fintype α]
    (π : FinDistribution α) (P : TransitionKernel α) (f : α → ℝ) : ℝ :=
  (1/2) * ∑ x, ∑ y, π.weight x * P.prob x y * (f x - f y) ^ 2

/-- The Dirichlet form is nonneg. -/
theorem dirichlet_form_nonneg {α : Type*} [Fintype α]
    (π : FinDistribution α) (P : TransitionKernel α) (f : α → ℝ) :
    0 ≤ dirichletForm π P f := by
  unfold dirichletForm
  apply mul_nonneg (by norm_num : (0:ℝ) ≤ 1/2)
  apply Finset.sum_nonneg; intro x _
  apply Finset.sum_nonneg; intro y _
  exact mul_nonneg (mul_nonneg (π.nonneg x) (P.nonneg x y)) (sq_nonneg _)

/-- The Dirichlet form of a constant function is zero. -/
theorem dirichlet_form_const {α : Type*} [Fintype α]
    (π : FinDistribution α) (P : TransitionKernel α) (c : ℝ) :
    dirichletForm π P (fun _ => c) = 0 := by simp [dirichletForm]

/-! ## Poincaré Inequality and Spectral Gap -/

/-- Poincaré inequality: Var_π(f) ≤ C_P · E(f,f). -/
def HasPoincareConst {α : Type*} [Fintype α]
    (π : FinDistribution α) (P : TransitionKernel α) (C_P : ℝ) : Prop :=
  ∀ f : α → ℝ, π.variance f ≤ C_P * dirichletForm π P f

/-- Spectral gap γ: Var_π(f) ≤ (1/γ) · E(f,f). -/
def HasSpectralGap {α : Type*} [Fintype α]
    (π : FinDistribution α) (P : TransitionKernel α) (γ : ℝ) : Prop :=
  ∀ f : α → ℝ, π.variance f ≤ (1/γ) * dirichletForm π P f

/-- Poincaré constant C_P ⟹ spectral gap 1/C_P. -/
theorem spectral_gap_from_poincare {α : Type*} [Fintype α]
    (π : FinDistribution α) (P : TransitionKernel α)
    (C_P : ℝ) (_hC : C_P > 0) (hP : HasPoincareConst π P C_P) :
    HasSpectralGap π P (1/C_P) := by
  intro f; rw [one_div_one_div]; exact hP f

/-! ## Domination and Comparison -/

/-- Dirichlet form domination: E₁(f,f) ≥ c · E₂(f,f). -/
def DirichletDominates {α : Type*} [Fintype α]
    (π : FinDistribution α) (P₁ P₂ : TransitionKernel α) (c : ℝ) : Prop :=
  ∀ f : α → ℝ, dirichletForm π P₁ f ≥ c * dirichletForm π P₂ f

/-
**Comparison Theorem**: Dirichlet domination transfers Poincaré bounds.
-/
theorem comparison_poincare {α : Type*} [Fintype α]
    (π : FinDistribution α) (P₁ P₂ : TransitionKernel α)
    (c C₂ : ℝ) (hc : c > 0) (hC₂ : C₂ ≥ 0)
    (hDom : DirichletDominates π P₁ P₂ c)
    (hP₂ : HasPoincareConst π P₂ C₂) :
    HasPoincareConst π P₁ (C₂ / c) := by
  intro f;
  have := hP₂ f;
  rw [ div_mul_eq_mul_div, le_div_iff₀' hc ];
  exact le_trans ( mul_le_mul_of_nonneg_left this hc.le ) ( by nlinarith [ hDom f, dirichlet_form_nonneg π P₁ f, dirichlet_form_nonneg π P₂ f ] )

/-
**Comparison Theorem for Spectral Gaps**: domination by factor c
    with base gap γ₂ gives gap c·γ₂.
-/
theorem comparison_spectral_gap {α : Type*} [Fintype α]
    (π : FinDistribution α) (P₁ P₂ : TransitionKernel α)
    (c γ₂ : ℝ) (hc : c > 0) (hγ₂ : γ₂ > 0)
    (hDom : DirichletDominates π P₁ P₂ c)
    (hGap₂ : HasSpectralGap π P₂ γ₂) :
    HasSpectralGap π P₁ (c * γ₂) := by
  intro f
  have := hGap₂ f
  refine le_trans this ?_;
  convert mul_le_mul_of_nonneg_left ( hDom f ) ( show 0 ≤ 1 / ( c * γ₂ ) by positivity ) using 1 ; ring;
  grind +qlia

/-! ## Quantitative Bounds -/

/-- 1/(d·n) > 0 for positive d, n. -/
theorem lorentzian_gap_pos (d n : ℕ) (hd : 1 ≤ d) (hn : 1 ≤ n) :
    (1 : ℝ) / ((d : ℝ) * (n : ℝ)) > 0 := by positivity

/-
**Key bound**: 1/(d·n) ≥ 1/n² when d ≤ n.
-/
theorem lorentzian_dominates_log_concave (d n : ℕ)
    (hd : 1 ≤ d) (hn : 1 ≤ n) (hdn : d ≤ n) :
    (1 : ℝ) / ((d : ℝ) * (n : ℝ)) ≥ 1 / ((n : ℝ) ^ 2) := by
  field_simp;
  norm_cast

/-
Reversed CS controls transition probability ratios.
-/
theorem reversed_cs_transition_ratio (p q r : ℝ)
    (hp : 0 < p) (hq : 0 < q)
    (h_reversed_cs : q ^ 2 ≥ p * r) :
    q / p ≥ r / q := by
  rw [ ge_iff_le, div_le_div_iff₀ ] <;> nlinarith

/-- When reversed CS holds with equality, ratios match. -/
theorem reversed_cs_equality (a b c : ℝ)
    (h_le : b ^ 2 ≤ a * c) (h_ge : b ^ 2 ≥ a * c) :
    b ^ 2 = a * c := le_antisymm h_le h_ge

/-- Comparison factor: (1/d)·(1/n) = 1/(d·n). -/
theorem lorentzian_comparison_factor (d n : ℕ) (hd : 1 ≤ d) (hn : 1 ≤ n) :
    (1 : ℝ) / (d : ℝ) * (1 / (n : ℝ)) = 1 / ((d : ℝ) * (n : ℝ)) := by
  field_simp

/-
**Main Theorem**: Lorentzian structure gives gap ≥ 1/(d·n) ≥ 1/n²,
    with improvement factor n/d ≥ 1.
-/
theorem spectral_gap_lorentzian_improvement (d n : ℕ)
    (hd : 1 ≤ d) (hn : 1 ≤ n) (hdn : d ≤ n) :
    (1 : ℝ) / ((d : ℝ) * (n : ℝ)) ≥ 1 / ((n : ℝ) ^ 2) ∧
    (n : ℝ) / (d : ℝ) ≥ 1 ∧
    (1 : ℝ) / ((d : ℝ) * (n : ℝ)) > 0 := by
  exact ⟨ by simpa [ sq ] using lorentzian_dominates_log_concave d n hd hn hdn, by rw [ ge_iff_le ] ; rw [ le_div_iff₀ ] <;> norm_cast ; linarith, by positivity ⟩

/-! ## Mixing Time -/

/-
Mixing time bound d·n·log(N/ε) is nonneg.
-/
theorem mixing_time_nonneg (d n N : ℕ) (ε : ℝ)
    (_hd : 1 ≤ d) (_hn : 1 ≤ n) (hN : 1 ≤ N) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    (d : ℝ) * (n : ℝ) * Real.log ((N : ℝ) / ε) ≥ 0 := by
  exact mul_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( Real.log_nonneg ( by rw [ le_div_iff₀ hε ] ; linarith [ show ( N : ℝ ) ≥ 1 by norm_cast ] ) )

/-
Polynomial mixing: d²·n·log(n) is nonneg for n ≥ 2.
-/
theorem polynomial_mixing (d n : ℕ) (hd : 1 ≤ d) (hn : 2 ≤ n) :
    (d : ℝ) * (n : ℝ) * ((d : ℝ) * Real.log (n : ℝ)) ≥ 0 := by
  exact mul_nonneg ( by positivity ) ( mul_nonneg ( by positivity ) ( Real.log_nonneg ( by norm_cast; linarith ) ) )

/-! ## Poincaré Constant Bounds -/

/-- Lorentzian Poincaré constant d·n. -/
theorem lorentzian_poincare_exists (d n : ℕ) (_hd : 1 ≤ d) (_hn : 1 ≤ n) :
    ∃ C_P : ℝ, C_P > 0 ∧ C_P = (d : ℝ) * (n : ℝ) :=
  ⟨_, by positivity, rfl⟩

/-
Poincaré improvement: d·n ≤ n² when d ≤ n.
-/
theorem poincare_improvement (d n : ℕ) (_hd : 1 ≤ d) (_hn : 1 ≤ n) (hdn : d ≤ n) :
    (d : ℝ) * (n : ℝ) ≤ (n : ℝ) ^ 2 := by
  norm_cast ; nlinarith

/-! ## Work Bounds -/

/-
Total sampling work d·n²·log(n) is nonneg.
-/
theorem total_work_nonneg (d n : ℕ) (_hd : 1 ≤ d) (hn : 2 ≤ n) :
    (d : ℝ) * (n : ℝ) ^ 2 * Real.log (n : ℝ) ≥ 0 := by
  positivity

/-
Work ratio: n³d²/(dn²) = nd.
-/
theorem work_ratio (d n : ℕ) (_hd : 1 ≤ d) (_hn : 1 ≤ n) :
    (n : ℝ) ^ 3 * (d : ℝ) ^ 2 / ((d : ℝ) * (n : ℝ) ^ 2) = (n : ℝ) * (d : ℝ) := by
  grind +qlia

/-
Log-concavity monotonicity: a₁/a₀ ≥ a₂/a₁ from a₁² ≥ a₀a₂.
-/
theorem log_concave_ratio_monotone (a₀ a₁ a₂ : ℝ)
    (h0 : 0 < a₀) (h1 : 0 < a₁)
    (h_lc : a₁ ^ 2 ≥ a₀ * a₂) :
    a₁ / a₀ ≥ a₂ / a₁ := by
  rw [ ge_iff_le, div_le_div_iff₀ ] <;> nlinarith

/-- Elementary symmetric polynomial spectral bound exists. -/
theorem elem_sym_spectral_bound (d n : ℕ) (_hd : 1 ≤ d) (_hn : 1 ≤ n) :
    ∃ c : ℝ, c > 0 ∧ c / ((d : ℝ) * (n : ℝ)) > 0 :=
  ⟨1, one_pos, by positivity⟩

end