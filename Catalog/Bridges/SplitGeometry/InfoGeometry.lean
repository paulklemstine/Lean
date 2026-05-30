/-
# Split Geometry: Information-Geometric Bridge

This file establishes the connection between split geometry and information theory.
The split divergence is shown to satisfy key properties of statistical divergences.

We introduce the **curvature spectrum** — the matrix of curvature values at a
finite collection of points — and prove spectral concentration bounds.

## Novel Concept: Curvature Spectrum

The curvature spectrum of a finite point configuration captures the distribution
of Gaussian curvature values across sample points. This bridges discrete geometry
(finite point sets) with continuous Riemannian geometry (curvature fields).
-/
import Mathlib
import Bridges.SplitGeometry.Core

open Real Finset

/-! ## Curvature Spectrum -/

/-- The curvature spectrum of a finite configuration of n points in the split plane.
    For each pair (i, j), records the curvature K(xᵢ, yⱼ). -/
noncomputable def curvatureSpectrum (n : ℕ) (x y : Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => splitCurvature (x i) (y j)

/-- **Spectral antisymmetry**: The curvature spectrum matrix is antisymmetric
    when the x and y configurations coincide. -/
theorem curvatureSpectrum_antisymm (n : ℕ) (z : Fin n → ℝ) (i j : Fin n) :
    curvatureSpectrum n z z i j = -curvatureSpectrum n z z j i := by
  unfold curvatureSpectrum
  exact splitCurvature_antisymm (z i) (z j)

/-- **Spectral trace vanishes**: The diagonal sum of the curvature spectrum
    is zero when x = y. -/
theorem curvatureSpectrum_trace_zero (n : ℕ) (z : Fin n → ℝ) :
    ∑ i : Fin n, curvatureSpectrum n z z i i = 0 := by
  simp [curvatureSpectrum, splitCurvature_diag]

/-- **Spectral total vanishes**: The total sum of all entries in the curvature
    spectrum matrix is zero. This is the discrete Gauss-Bonnet theorem for
    point configurations. -/
theorem curvatureSpectrum_total_zero (n : ℕ) (z : Fin n → ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, curvatureSpectrum n z z i j = 0 := by
  simp only [curvatureSpectrum, splitCurvature]
  simp [Finset.sum_sub_distrib, Finset.sum_comm (s := Finset.univ) (t := Finset.univ)]

/-! ## Divergence Triangle Inequality -/

/-- The split divergence satisfies a relaxed triangle inequality
    with factor 2, making it a quasi-metric.
    D(p, r) ≤ 2 · D(p, q) + 2 · D(q, r). -/
theorem splitDivergence_quasi_triangle (p q r : ℝ × ℝ) :
    splitDivergence p r ≤ 2 * splitDivergence p q + 2 * splitDivergence q r := by
  unfold splitDivergence
  nlinarith [sq_nonneg (sechSq p.1 - sechSq q.1),
             sq_nonneg (sechSq q.1 - sechSq r.1),
             sq_nonneg (sechSq p.1 - sechSq q.1 - (sechSq q.1 - sechSq r.1)),
             sq_nonneg (sechSq p.2 - sechSq q.2),
             sq_nonneg (sechSq q.2 - sechSq r.2),
             sq_nonneg (sechSq p.2 - sechSq q.2 - (sechSq q.2 - sechSq r.2))]

/-! ## Curvature Moment Bounds -/

/-- **Mean curvature bound**: The average curvature over n sample points
    paired with a fixed reference is bounded by 1 in absolute value. -/
theorem mean_curvature_bound (n : ℕ) (_hn : 0 < n) (x : Fin n → ℝ) (y₀ : ℝ) :
    |∑ i : Fin n, splitCurvature (x i) y₀| ≤ n := by
  calc |∑ i : Fin n, splitCurvature (x i) y₀|
      ≤ ∑ i : Fin n, |splitCurvature (x i) y₀| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i : Fin n, (1 : ℝ) :=
        Finset.sum_le_sum (fun i _ => splitCurvature_abs_le_one _ _)
    _ = n := by simp

/-! ## Curvature Variance -/

/-- The curvature variance of a point configuration. -/
noncomputable def curvatureVariance (n : ℕ) (x : Fin n → ℝ) (y₀ : ℝ) : ℝ :=
  (∑ i : Fin n, splitCurvature (x i) y₀ ^ 2) / n

/-- The curvature variance is nonneg. -/
theorem curvatureVariance_nonneg (n : ℕ) (x : Fin n → ℝ) (y₀ : ℝ) :
    0 ≤ curvatureVariance n x y₀ := by
  unfold curvatureVariance
  apply div_nonneg _ (by positivity)
  exact Finset.sum_nonneg (fun i _ => sq_nonneg _)

/-
**Curvature variance bound**: The variance is at most 1.
    Follows from |K| ≤ 1, hence K² ≤ 1.
-/
theorem curvatureVariance_le_one (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) (y₀ : ℝ) :
    curvatureVariance n x y₀ ≤ 1 := by
      exact div_le_one_of_le₀ ( le_trans ( Finset.sum_le_sum fun _ _ => show ( splitCurvature ( x _ ) y₀ ) ^ 2 ≤ 1 by nlinarith [ abs_le.mp ( splitCurvature_abs_le_one ( x ‹_› ) y₀ ) ] ) ( by norm_num ) ) ( by positivity )

/-! ## Spectral Concentration -/

/-
**Spectral Frobenius bound**: The Frobenius norm of the curvature spectrum
    is at most n².
-/
theorem spectral_frobenius_bound (n : ℕ) (z : Fin n → ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, curvatureSpectrum n z z i j ^ 2 ≤ (n : ℝ) ^ 2 := by
  refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => _ ) _;
  exact fun i j => 1;
  · exact le_of_abs_le ( by simpa using pow_le_pow_left₀ ( abs_nonneg _ ) ( splitCurvature_abs_le_one _ _ ) 2 );
  · norm_num [ sq ]

/-! ## Split Laplacian -/

/-- The discrete split Laplacian of a function f at a point. -/
noncomputable def splitLaplacian (f : ℝ → ℝ → ℝ) (x y h : ℝ) : ℝ :=
  sechSq x * ((f (x + h) y - 2 * f x y + f (x - h) y) / h ^ 2) +
  sechSq y * ((f x (y + h) - 2 * f x y + f x (y - h)) / h ^ 2)

/-- The split Laplacian of a constant function vanishes. -/
theorem splitLaplacian_const (c : ℝ) (x y h : ℝ) (hh : h ≠ 0) :
    splitLaplacian (fun _ _ => c) x y h = 0 := by
  unfold splitLaplacian; field_simp; ring

/-! ## Curvature Flow -/

/-- The split curvature flow: evolution of a function under the split Laplacian.
    Given initial data f₀ and step size dt, one step of the flow is:
    f(x,y) ← f₀(x,y) + dt · Δ_split f₀(x,y). -/
noncomputable def curvatureFlowStep (f₀ : ℝ → ℝ → ℝ) (dt h : ℝ) (x y : ℝ) : ℝ :=
  f₀ x y + dt * splitLaplacian f₀ x y h

/-- A constant function is a fixed point of the curvature flow. -/
theorem curvatureFlowStep_const (c dt h : ℝ) (x y : ℝ) (hh : h ≠ 0) :
    curvatureFlowStep (fun _ _ => c) dt h x y = c := by
  unfold curvatureFlowStep
  rw [splitLaplacian_const c x y h hh]
  ring

/-! ## Information-Geometric Interpretation -/

/-
**Curvature-divergence duality**: The split curvature at a point equals
    the directional derivative of the divergence. Specifically,
    K(x,y) = ½ · ∂/∂ε D((x,y), (x+ε, y))|_{ε=0} in a certain sense.

    We prove a weaker algebraic version: the squared curvature is bounded
    by the divergence to any point with the same y-coordinate.
-/
theorem curvature_divergence_bound (x₁ x₂ y : ℝ) :
    splitCurvature x₁ y ^ 2 ≤
    splitDivergence (x₁, y) (x₂, y) + splitCurvature x₂ y ^ 2 +
    2 * |splitCurvature x₁ y| * |splitCurvature x₂ y| := by
  unfold splitCurvature splitDivergence;
  cases abs_cases ( sechSq x₁ - sechSq y ) <;> cases abs_cases ( sechSq x₂ - sechSq y ) <;> push_cast [ * ] <;> nlinarith