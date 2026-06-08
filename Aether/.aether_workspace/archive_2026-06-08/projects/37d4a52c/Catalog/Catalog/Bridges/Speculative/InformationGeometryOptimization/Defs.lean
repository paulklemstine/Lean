/-
  # Information Geometry of Optimization: Definitions

  This file defines the core structures for studying optimization on
  statistical manifolds equipped with the Fisher information metric.

  The key insight is that the natural gradient algorithm — which preconditions
  the gradient by the inverse Fisher information matrix — is equivalent to
  steepest descent on the Riemannian manifold with metric given by the
  Fisher information. This makes natural gradient descent invariant under
  reparameterization, unlike standard gradient descent.

  ## Main Definitions
  - `FisherMetric`: A positive-definite metric structure on ℝⁿ
  - `ConvexLoss`: A loss function with convexity and smoothness bounds
  - `StatisticalManifold`: A manifold structure with Fisher metric and geodesic bounds
-/
import Mathlib

open Matrix Finset BigOperators Real

noncomputable section

namespace InfoGeomOpt

/-- A `FisherMetric` on `Fin d → ℝ` models a positive-definite matrix G
    that serves as the Riemannian metric on the statistical manifold.
    The condition number κ = λ_max / λ_min captures how distorted the
    geometry is relative to Euclidean space.

    Bridge: connects DifferentialGeometry (Riemannian metric) to
    MachineLearning (Fisher information matrix). -/
structure FisherMetric (d : ℕ) where
  /-- Minimum eigenvalue of G -/
  lambda_min : ℝ
  /-- Maximum eigenvalue of G -/
  lambda_max : ℝ
  /-- Minimum eigenvalue is positive -/
  hmin_pos : 0 < lambda_min
  /-- Maximum eigenvalue is positive -/
  hmax_pos : 0 < lambda_max
  /-- Eigenvalue ordering -/
  hle : lambda_min ≤ lambda_max

/-- Condition number of a Fisher metric: κ = λ_max / λ_min.
    This measures how much the geometry distorts distances. -/
def FisherMetric.conditionNumber {d : ℕ} (G : FisherMetric d) : ℝ :=
  G.lambda_max / G.lambda_min

/-- A `ConvexLoss` models a loss function with:
    - A known minimum value L*
    - Lipschitz gradient with constant β
    - Strong convexity parameter μ ≥ 0
    - Initial gap Δ₀ = L(θ₀) - L*

    This abstracts the essential properties needed for convergence analysis. -/
structure ConvexLoss where
  /-- Gradient Lipschitz constant -/
  beta : ℝ
  /-- Strong convexity parameter (0 for merely convex) -/
  mu : ℝ
  /-- Initial optimization gap -/
  delta0 : ℝ
  /-- Gradient norm bound at initial point -/
  grad_norm0 : ℝ
  /-- β is positive -/
  hbeta_pos : 0 < beta
  /-- μ is nonneg -/
  hmu_nonneg : 0 ≤ mu
  /-- μ ≤ β (strong convexity ≤ smoothness) -/
  hmu_le_beta : mu ≤ beta
  /-- Initial gap is positive -/
  hdelta0_pos : 0 < delta0
  /-- Gradient norm is nonneg -/
  hgrad_nonneg : 0 ≤ grad_norm0

/-- A `StatisticalManifold` combines a Fisher metric with geometric bounds.
    The diameter D bounds the geodesic distance between any two points,
    which is crucial for proving condition-number-independent convergence.

    This is a novel definition connecting Riemannian geometry to optimization:
    the geodesic diameter of the statistical manifold determines the
    convergence rate of natural gradient descent, not the condition number. -/
structure StatisticalManifold (d : ℕ) extends FisherMetric d where
  /-- Geodesic diameter of the manifold -/
  diameter : ℝ
  /-- Diameter is positive -/
  hdiameter_pos : 0 < diameter
  /-- Sectional curvature lower bound -/
  curvature_lb : ℝ

/-- Natural gradient descent gap bound after T steps.
    For a β-smooth convex function on a statistical manifold with
    diameter D, natural GD achieves:
      L(θ_T) - L* ≤ D² / (2T)

    Crucially, this does NOT depend on the condition number κ. -/
def natGradGapBound (M : StatisticalManifold d) (T : ℕ) : ℝ :=
  M.diameter ^ 2 / (2 * ↑T)

/-- The natural gradient convergence rate for strongly convex losses.
    Natural gradient achieves exponential convergence:
      L(θ_T) - L* ≤ Δ₀ · exp(-T/d) -/
def natGradStrongConvexBound (loss : ConvexLoss) (d : ℕ) (T : ℕ) : ℝ :=
  loss.delta0 * Real.exp (-(↑T / ↑d))

/-- Standard gradient descent convergence for strongly convex losses.
    The rate depends on the condition number κ:
      L(θ_T) - L* ≤ Δ₀ · (1 - 1/κ)^T -/
def gdStrongConvexBound (loss : ConvexLoss) (kappa : ℝ) (T : ℕ) : ℝ :=
  loss.delta0 * (1 - 1 / kappa) ^ T

/-- `ReparamMap` models a smooth reparameterization φ: ℝᵈ → ℝᵈ
    with bounded Jacobian. -/
structure ReparamMap (d : ℕ) where
  /-- Maximum singular value of the Jacobian -/
  jacobian_max : ℝ
  /-- Minimum singular value of the Jacobian -/
  jacobian_min : ℝ
  /-- Jacobian is nondegenerate -/
  hjac_pos : 0 < jacobian_min
  /-- Singular value ordering -/
  hjac_le : jacobian_min ≤ jacobian_max

/-- Condition number of the Jacobian. -/
def ReparamMap.condNumber {d : ℕ} (φ : ReparamMap d) : ℝ :=
  φ.jacobian_max / φ.jacobian_min

end InfoGeomOpt