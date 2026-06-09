/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Scaling Laws: Definitions

This file introduces the mathematical framework for neural network scaling laws
derived from kernel spectral theory. The core insight is that the loss landscape
of a kernel method (and by extension, neural networks in the kernel regime) is
governed by the spectral decay of the associated kernel operator.

## Main Definitions

* `SpectralProfile` — A sequence of eigenvalues with prescribed decay properties,
  modeling the spectrum of a neural tangent or GP kernel.
* `BiasVarianceRegime` — The decomposition of test loss into bias (truncation error
  from finite model capacity) and variance (estimation error from finite data).
* `ComputeScalingProblem` — The optimization problem of allocating compute between
  model size and data under a fixed compute budget.

## Mathematical Background

In the infinite-width limit, neural networks become Gaussian processes whose kernel
K has eigendecomposition K(x,y) = Σ_k λ_k φ_k(x) φ_k(y). With P parameters, only
the top P eigenmodes are captured (bias ~ Σ_{k>P} λ_k), while N data points yield
estimation error (variance ~ P/N). The optimal P*(N) and the resulting loss scaling
L*(C) with compute C emerge from this spectral structure.
-/
import Mathlib

open Finset Real BigOperators

/-! ## Spectral Profile -/

/-- A `SpectralProfile` captures the eigenvalue spectrum of a kernel operator.
    It consists of a non-negative, non-increasing sequence of eigenvalues.
    This models the spectral decomposition of NTK or GP kernels. -/
structure SpectralProfile where
  /-- The k-th eigenvalue of the kernel -/
  eigenvalue : ℕ → ℝ
  /-- Eigenvalues are non-negative -/
  nonneg : ∀ k, 0 ≤ eigenvalue k
  /-- Eigenvalues are non-increasing (ordered by magnitude) -/
  eigenvalue_antitone : Antitone eigenvalue

namespace SpectralProfile

/-- The partial sum of the first P eigenvalues (captured variance).
    This represents the spectral mass captured by a P-parameter model. -/
noncomputable def partialSum (sp : SpectralProfile) (P : ℕ) : ℝ :=
  ∑ k ∈ Finset.range P, sp.eigenvalue k

/-- Tail sum: the total eigenvalue mass beyond the first P modes.
    For a summable spectrum, this is Σ_{k≥P} λ_k. -/
noncomputable def tailSum (sp : SpectralProfile) (P : ℕ) : ℝ :=
  ∑' k, sp.eigenvalue (k + P)

end SpectralProfile

/-! ## Bias-Variance Regime -/

/-- A `BiasVarianceRegime` models the test loss decomposition for a kernel method
    with P parameters trained on N data points. The total loss is:
      L(P, N) = L_inf + biasCoeff * P^(-biasExp) + varCoeff * P^(varExp) * N^(-1)

    where:
    - L_inf is the irreducible (Bayes-optimal) loss
    - biasCoeff * P^(-biasExp) is the approximation error (bias)
    - varCoeff * P^(varExp) * N^(-1) is the estimation error (variance)

    This structure is the mathematical core of neural scaling laws. -/
structure BiasVarianceRegime where
  /-- Irreducible loss (Bayes-optimal error) -/
  L_inf : ℝ
  /-- Coefficient for the bias (approximation) term -/
  biasCoeff : ℝ
  /-- Exponent for bias decay with model size -/
  biasExp : ℝ
  /-- Coefficient for the variance (estimation) term -/
  varCoeff : ℝ
  /-- Exponent for variance growth with model size (before dividing by N) -/
  varExp : ℝ
  /-- Irreducible loss is non-negative -/
  hL : 0 ≤ L_inf
  /-- Bias coefficient is positive -/
  hA : 0 < biasCoeff
  /-- Bias exponent is positive -/
  ha : 0 < biasExp
  /-- Variance coefficient is positive -/
  hB : 0 < varCoeff
  /-- Variance exponent is positive -/
  hb : 0 < varExp

namespace BiasVarianceRegime

/-- The total loss at model size P and data size N. -/
noncomputable def loss (r : BiasVarianceRegime) (P N : ℝ) : ℝ :=
  r.L_inf + r.biasCoeff * P ^ (-r.biasExp) + r.varCoeff * P ^ r.varExp * N⁻¹

/-- The bias component of the loss -/
noncomputable def biasLoss (r : BiasVarianceRegime) (P : ℝ) : ℝ :=
  r.biasCoeff * P ^ (-r.biasExp)

/-- The variance component of the loss -/
noncomputable def varLoss (r : BiasVarianceRegime) (P N : ℝ) : ℝ :=
  r.varCoeff * P ^ r.varExp * N⁻¹

/-- Loss equals irreducible plus bias plus variance -/
theorem loss_eq (r : BiasVarianceRegime) (P N : ℝ) :
    r.loss P N = r.L_inf + r.biasLoss P + r.varLoss P N := by
  simp [loss, biasLoss, varLoss]

end BiasVarianceRegime

/-! ## Compute Scaling Problem -/

/-- A `ComputeScalingProblem` represents the problem of optimally allocating
    a fixed compute budget C between model parameters P and training tokens D,
    subject to the constraint C = scaleFactor * P * D (e.g., scaleFactor = 6
    for typical transformer training). The loss is a two-term power law:
      L(P, D) = A * P^(-a) + B * D^(-b) -/
structure ComputeScalingProblem where
  /-- Coefficient for model-size scaling -/
  A : ℝ
  /-- Exponent for model-size scaling -/
  a : ℝ
  /-- Coefficient for data-size scaling -/
  B : ℝ
  /-- Exponent for data-size scaling -/
  b : ℝ
  /-- The compute-to-PD ratio (typically 6 for transformers) -/
  scaleFactor : ℝ
  hA : 0 < A
  ha : 0 < a
  hB : 0 < B
  hb : 0 < b
  hS : 0 < scaleFactor

namespace ComputeScalingProblem

/-- The loss function L(P, D) = A * P^(-a) + B * D^(-b) -/
noncomputable def loss (p : ComputeScalingProblem) (P D : ℝ) : ℝ :=
  p.A * P ^ (-p.a) + p.B * D ^ (-p.b)

/-- The compute constraint: C = scaleFactor * P * D -/
def computeConstraint (p : ComputeScalingProblem) (P D C : ℝ) : Prop :=
  C = p.scaleFactor * P * D

/-- The harmonic scaling exponent: optimal loss scales as C^(-harmonicExp). -/
noncomputable def harmonicExp (p : ComputeScalingProblem) : ℝ :=
  p.a * p.b / (p.a + p.b)

/-- The optimal model-size exponent: P* proportional to C^(optModelExp) -/
noncomputable def optModelExp (p : ComputeScalingProblem) : ℝ :=
  p.b / (p.a + p.b)

/-- The optimal data-size exponent: D* proportional to C^(optDataExp) -/
noncomputable def optDataExp (p : ComputeScalingProblem) : ℝ :=
  p.a / (p.a + p.b)

end ComputeScalingProblem

/-! ## Power-Law Composition -/

/-- A `PowerLaw` represents a function f(x) = C * x^(-e) for x > 0,
    modeling individual scaling relationships. -/
structure PowerLaw where
  coeff : ℝ
  exp : ℝ
  hcoeff : 0 < coeff
  hexp : 0 < exp

namespace PowerLaw

/-- Evaluate the power law at a point -/
noncomputable def eval (f : PowerLaw) (x : ℝ) : ℝ :=
  f.coeff * x ^ (-f.exp)

/-- Two-term loss: f(x) + g(C/x) -/
noncomputable def twoTermLoss (f g : PowerLaw) (C x : ℝ) : ℝ :=
  f.eval x + g.eval (C / x)

end PowerLaw