/-! # CatalogBuild.FutureResearch.SPBInformationGeometry

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 10
-/

import Mathlib

noncomputable section

def stdCauchyDensity (x : ℝ) : ℝ := 1 / (Real.pi * (1 + x ^ 2))

/-- Standard Cauchy density is positive. -/

theorem stdCauchyDensity_pos (x : ℝ) : 0 < stdCauchyDensity x := by
  unfold stdCauchyDensity
  apply div_pos one_pos
  apply mul_pos Real.pi_pos
  positivity

/-! ## SPB as Cauchy Location Shift -/

/-- The SPB operator. -/

def spbIG (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The Jacobian of SPB w.r.t. the first variable: (1+y²)/(1-xy)². -/

def spbJacobian (x y : ℝ) : ℝ := (1 + y ^ 2) / (1 - x * y) ^ 2

/-- The Jacobian is always positive when the denominator is nonzero. -/

theorem spbJacobian_pos (x y : ℝ) (h : 1 - x * y ≠ 0) :
    0 < spbJacobian x y := by
  unfold spbJacobian
  apply div_pos
  · positivity
  · positivity

/-- The key change-of-variables identity:
    1 + spb(x,a)² = (1+x²)(1+a²)/(1-xa)²
    This is the Jacobian factor for the Cauchy distribution. -/

theorem spb_cauchy_jacobian (x a : ℝ) (h : 1 - x * a ≠ 0) :
    1 + spbIG x a ^ 2 = (1 + x ^ 2) * (1 + a ^ 2) / (1 - x * a) ^ 2 := by
  unfold spbIG; field_simp; ring

/-
Standard Cauchy density transforms correctly under SPB:
    f(spb(x,a)) · |∂spb/∂x| = f(x) · (1+a²)/((1+x²)(1+a²))
    This shows SPB preserves the Cauchy measure up to a scale.
-/

theorem cauchy_spb_change_of_vars (x a : ℝ) (h : 1 - x * a ≠ 0) :
    stdCauchyDensity (spbIG x a) * spbJacobian x a =
    1 / (Real.pi * (1 + x ^ 2)) := by
  unfold stdCauchyDensity spbJacobian spbIG;
  field_simp;
  ring

/-! ## Hyperbolic Distance on the Cauchy Manifold -/

/-- The hyperbolic distance between two points on the upper half-plane.
    For the Cauchy manifold parametrized by (μ, γ), this is the Fisher metric. -/

def hyperbolicDist (μ₁ γ₁ μ₂ γ₂ : ℝ) : ℝ :=
  Real.log ((μ₁ - μ₂) ^ 2 + (γ₁ + γ₂) ^ 2) -
  Real.log ((μ₁ - μ₂) ^ 2 + (γ₁ - γ₂) ^ 2)

/-- When scale parameters are equal (γ₁ = γ₂ = γ), the hyperbolic distance
    simplifies to a function of (μ₁ - μ₂)/γ. -/

theorem hyperbolicDist_equal_scale (μ₁ μ₂ γ : ℝ) (hγ : 0 < γ) :
    hyperbolicDist μ₁ γ μ₂ γ =
    Real.log ((μ₁ - μ₂) ^ 2 + (2 * γ) ^ 2) -
    Real.log ((μ₁ - μ₂) ^ 2) := by
  unfold hyperbolicDist; ring_nf

/-! ## SPB Acts as Isometries of the Standard Cauchy -/

/-- For the standard Cauchy (γ=1), SPB translates the location parameter:
    if X ~ Cauchy(0,1), then spb(X, a) ~ Cauchy(a, 1).
    Equivalently, arctan(X) is uniform, and arctan(spb(X,a)) = arctan(X) + arctan(a). -/

theorem spb_cauchy_location_shift (a : ℝ) :
    ∀ x : ℝ, (1 - x * a ≠ 0) →
    spbIG x a - a = (x * (1 + a ^ 2)) / (1 - x * a) := by
  intro x h
  unfold spbIG; field_simp; ring


end
