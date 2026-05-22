/-
# Curvature Variance Decomposition and Discrete Uniformization

This file establishes foundational results connecting curvature variance
to discrete uniformization theory, with cross-domain bridges to
Pythagorean number theory.

## Main Results

* `sq_dist_decomposition` — ‖f - c‖² = Var(f) + n·(f̄ - c)²
* `variance_eq_zero_iff` — Var(f) = 0 ↔ f is constant
* `optimal_target_is_mean` — The mean minimizes squared distance
* `gauss_bonnet_mean_curvature` — Mean curvature = 2πχ/n
* `equicurved_iff` — Equicurved ↔ zero variance
* `pythagorean_acute_angle_sum` — arctan(a/b) + arctan(b/a) = π/2
* `curvatureStep_preserves_sum` — Edge flip preserves total curvature

## References

* Regge, T. "General Relativity Without Coordinates"
* Glickenstein, D. "Discrete conformal variations and scalar curvature
  on piecewise flat surfaces"
-/

import Mathlib

open Finset Real BigOperators

namespace CurvatureVariance

/-! ## Part 1: Abstract Variance Theory on Finite Types

We work with functions `Fin n → ℝ` and prove algebraic decomposition
theorems for squared norms and variance. -/

variable {n : ℕ}

/-- Mean of a real-valued function on `Fin n`. -/
noncomputable def fmean (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) : ℝ :=
  (∑ i : Fin n, f i) / n

/-- Variance of a function on `Fin n`: sum of squared deviations from mean. -/
noncomputable def fvariance (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, (f i - fmean hn f) ^ 2

/-- Squared ℓ² distance from a function to a constant. -/
def sqDistToConst (f : Fin n → ℝ) (c : ℝ) : ℝ :=
  ∑ i : Fin n, (f i - c) ^ 2

/-- The sum of deviations from the mean is zero. -/
theorem sum_deviation_from_mean (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) :
    ∑ i : Fin n, (f i - fmean hn f) = 0 := by
  simp [fmean, Finset.sum_sub_distrib, Finset.sum_const,
        nsmul_eq_mul, mul_div_cancel₀ _ hn, sub_self]

/-- Variance is always nonnegative. -/
theorem variance_nonneg (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) :
    0 ≤ fvariance hn f :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-
**Variance Decomposition Theorem**: The squared distance from f to any
    constant c decomposes as the variance plus n times the squared distance
    between the mean and c.

    ‖f - c‖² = Var(f) + n · (f̄ - c)²

    This is the discrete analogue of the bias-variance decomposition.
-/
theorem sq_dist_decomposition (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) (c : ℝ) :
    sqDistToConst f c = fvariance hn f + ↑n * (fmean hn f - c) ^ 2 := by
  unfold sqDistToConst fvariance fmean;
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_assoc, mul_div_cancel₀ _ hn ] ; ring;
  simp +decide [ ← Finset.sum_mul, ← Finset.mul_sum, ← Finset.sum_div, sq, mul_assoc, mul_comm, mul_left_comm, hn ] ; ring;

/-
**Zero Variance Characterization**: Variance is zero iff f is constant.

    Var(f) = 0  ↔  ∀ i, f i = f̄

    This characterizes equicurved surfaces.
-/
theorem variance_eq_zero_iff (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) :
    fvariance hn f = 0 ↔ ∀ i : Fin n, f i = fmean hn f := by
  constructor <;> intro h <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, fvariance ];
  exact fun i => sub_eq_zero.mp ( h i )

/-
**Optimal Target Theorem**: The mean minimizes the squared distance
    among all constant targets.
-/
theorem optimal_target_is_mean (hn : (n : ℝ) ≠ 0) (f : Fin n → ℝ) (c : ℝ) :
    fvariance hn f ≤ sqDistToConst f c := by
  rw [ sq_dist_decomposition ];
  exact le_add_of_nonneg_right ( mul_nonneg ( Nat.cast_nonneg _ ) ( sq_nonneg _ ) )

/-
**Pointwise Deviation Bound**: Each value's deviation from the mean is
    bounded by the total variance.
-/
theorem pointwise_deviation_le_variance (hn : (n : ℝ) ≠ 0)
    (f : Fin n → ℝ) (j : Fin n) :
    (f j - fmean hn f) ^ 2 ≤ fvariance hn f := by
  convert Finset.single_le_sum ( fun i _ => sq_nonneg ( f i - fmean hn f ) ) ( Finset.mem_univ j ) using 1

/-! ## Part 2: Gauss-Bonnet Constraints on Curvature -/

/-- A curvature profile satisfying the discrete Gauss-Bonnet condition. -/
structure GaussBonnetProfile (n : ℕ) where
  /-- Curvature at each vertex -/
  curvature : Fin n → ℝ
  /-- Euler characteristic -/
  eulerChar : ℤ
  /-- Gauss-Bonnet constraint -/
  gauss_bonnet : ∑ i : Fin n, curvature i = 2 * π * (eulerChar : ℝ)

/-- The mean curvature of a Gauss-Bonnet profile is 2πχ/n. -/
theorem gauss_bonnet_mean_curvature (hn : (n : ℝ) ≠ 0)
    (P : GaussBonnetProfile n) :
    fmean hn P.curvature = 2 * π * (P.eulerChar : ℝ) / n := by
  simp [fmean, P.gauss_bonnet]

/-
**Equicurved Characterization**: A Gauss-Bonnet profile has zero variance
    iff every vertex has curvature 2πχ/n.
-/
theorem equicurved_iff (hn : (n : ℝ) ≠ 0) (P : GaussBonnetProfile n) :
    (∀ i : Fin n, P.curvature i = 2 * π * (P.eulerChar : ℝ) / n) ↔
    fvariance hn P.curvature = 0 := by
  rw [ variance_eq_zero_iff hn P.curvature ];
  rw [ gauss_bonnet_mean_curvature hn P ]

/-
For equicurved profiles, the distance to the equicurved target is zero.
-/
theorem equicurved_zero_dist (hn : (n : ℝ) ≠ 0) (P : GaussBonnetProfile n)
    (h : fvariance hn P.curvature = 0) :
    sqDistToConst P.curvature (2 * π * (P.eulerChar : ℝ) / n) = 0 := by
  rw [ sq_dist_decomposition, h, gauss_bonnet_mean_curvature ] <;> aesop

/-! ## Part 3: Novel Definition — Discrete Conformal Class -/

/-- A discrete conformal class: the set of curvature profiles achievable
    from a reference profile via local combinatorial moves (edge flips).
    All profiles share the same Euler characteristic by Gauss-Bonnet. -/
structure DiscreteConformalClass (n : ℕ) where
  /-- Euler characteristic shared by all profiles -/
  eulerChar : ℤ
  /-- The set of achievable curvature profiles -/
  profiles : Set (Fin n → ℝ)
  /-- All profiles satisfy Gauss-Bonnet -/
  gauss_bonnet_invariant :
    ∀ K ∈ profiles, ∑ i : Fin n, K i = 2 * π * (eulerChar : ℝ)
  /-- The class is nonempty -/
  nonempty : profiles.Nonempty

/-
Within a discrete conformal class, all profiles have the same mean.
-/
theorem conformal_class_same_mean (hn : (n : ℝ) ≠ 0)
    (C : DiscreteConformalClass n) (K₁ K₂ : Fin n → ℝ)
    (h₁ : K₁ ∈ C.profiles) (h₂ : K₂ ∈ C.profiles) :
    fmean hn K₁ = fmean hn K₂ := by
  convert congr_arg ( fun x : ℝ => x / n ) ( C.gauss_bonnet_invariant K₁ h₁ ) using 1;
  convert congr_arg ( fun x : ℝ => x / n ) ( C.gauss_bonnet_invariant K₂ h₂ ) using 1

/-
Within a conformal class, minimum variance minimizes distance to target.
-/
theorem min_variance_minimizes_dist (hn : (n : ℝ) ≠ 0)
    (C : DiscreteConformalClass n)
    (K₁ K₂ : Fin n → ℝ) (h₁ : K₁ ∈ C.profiles) (h₂ : K₂ ∈ C.profiles)
    (h_var : fvariance hn K₁ ≤ fvariance hn K₂) :
    sqDistToConst K₁ (2 * π * (C.eulerChar : ℝ) / n)
    ≤ sqDistToConst K₂ (2 * π * (C.eulerChar : ℝ) / n) := by
  convert add_le_add_right h_var ( n * ( fmean hn K₁ - 2 * Real.pi * C.eulerChar / n ) ^ 2 ) using 1;
  · convert sq_dist_decomposition hn K₁ ( 2 * Real.pi * C.eulerChar / n ) using 1 ; ring;
  · convert sq_dist_decomposition hn K₂ ( 2 * Real.pi * C.eulerChar / n ) using 1;
    rw [ add_comm, conformal_class_same_mean hn C K₁ K₂ h₁ h₂ ]

/-! ## Part 4: Cross-Domain — Pythagorean Triples and Angle Defects -/

/-
**Pythagorean Acute Angle Sum**: For positive reals a, b, the two
    complementary arctangent values sum to π/2:
      arctan(a/b) + arctan(b/a) = π/2

    This is the bridge between number theory (a²+b²=c²) and geometry
    (angle defects). When (a,b,c) is a Pythagorean triple, these are
    the acute angles of the right triangle.
-/
theorem pythagorean_acute_angle_sum (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    Real.arctan (a / b) + Real.arctan (b / a) = π / 2 := by
  rw [ ← eq_sub_iff_add_eq', Real.arctan_eq_of_tan_eq ];
  · simp +decide [ Real.tan_pi_div_two_sub ];
  · constructor <;> linarith [ Real.arctan_pos.2 ( div_pos ha hb ), Real.arctan_lt_pi_div_two ( a / b ) ]

/-- **Right-angle vertex curvature**: At a vertex of degree d where all
    incident triangles contribute a right angle (π/2), the curvature is
    2π(1 - d/4). -/
theorem right_angle_vertex_curvature (d : ℕ) :
    2 * π - ↑d * (π / 2) = 2 * π * (1 - (d : ℝ) / 4) := by
  ring

/-- For a flat right-angle vertex, the degree must be 4. -/
theorem flat_right_angle_degree {d : ℕ} :
    2 * π - ↑d * (π / 2) = 0 ↔ (d : ℝ) = 4 := by
  constructor
  · intro h; nlinarith [Real.pi_pos]
  · intro h; rw [h]; ring

/-- **Pythagorean Curvature Identity**: For a vertex surrounded by k right
    triangles each from the Pythagorean triple (a,b,c), the total angle
    contribution from the acute angle α = arctan(b/a) is k·α.
    The curvature is then 2π - k·α. When k·α = 2π, we get zero curvature
    (a flat vertex).

    This theorem states the constraint: if a right-angle vertex has degree d
    and positive curvature, then d < 4. -/
theorem positive_curvature_degree_bound {d : ℕ} :
    0 < 2 * π - ↑d * (π / 2) ↔ d < 4 := by
  constructor
  · intro h
    by_contra hle
    push_neg at hle
    have : (4 : ℝ) ≤ d := by exact_mod_cast hle
    nlinarith [Real.pi_pos]
  · intro h
    have : (d : ℝ) < 4 := by exact_mod_cast h
    nlinarith [Real.pi_pos]

/-! ## Part 5: Curvature Flow -/

/-- A curvature update step: redistributes curvature between vertices i and j
    by parameter t ∈ [0,1]. Models the effect of an edge flip. -/
noncomputable def curvatureStep (f : Fin n → ℝ) (i j : Fin n) (t : ℝ) :
    Fin n → ℝ :=
  fun k => if k = i then f i + t * (f j - f i)
           else if k = j then f j + t * (f i - f j)
           else f k

/-
A curvature step preserves total curvature (Gauss-Bonnet invariance).
-/
theorem curvatureStep_preserves_sum (f : Fin n → ℝ) (i j : Fin n)
    (hij : i ≠ j) (t : ℝ) :
    ∑ k : Fin n, curvatureStep f i j t k = ∑ k : Fin n, f k := by
  unfold curvatureStep;
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', * ];
  rw [ ← Finset.sum_erase_add _ _ ( Finset.mem_univ i ), ← Finset.sum_erase_add _ _ ( Finset.mem_erase_of_ne_of_mem hij.symm ( Finset.mem_univ j ) ) ] ; split_ifs <;> simp_all +decide ; ring

/-- At t = 1/2, the curvature step equalizes curvature at i and j. -/
theorem curvatureStep_half_equalizes (f : Fin n → ℝ) (i j : Fin n)
    (hij : i ≠ j) :
    curvatureStep f i j (1/2) i = curvatureStep f i j (1/2) j := by
  simp only [curvatureStep, Ne.symm hij, ↓reduceIte]; ring

/-- A curvature step at t=0 is the identity. -/
theorem curvatureStep_zero (f : Fin n → ℝ) (i j : Fin n) :
    curvatureStep f i j 0 = f := by
  ext k; simp [curvatureStep]; split_ifs <;> subst_eqs <;> rfl

/-- Curvature step does not change values outside {i, j}. -/
theorem curvatureStep_unchanged (f : Fin n → ℝ) (i j : Fin n)
    (t : ℝ) (k : Fin n) (hki : k ≠ i) (hkj : k ≠ j) :
    curvatureStep f i j t k = f k := by
  simp [curvatureStep, hki, hkj]

/-! ## Part 6: Testable Conjecture -/

/-- Helper: n ≠ 0 from 4 ≤ n. -/
theorem ne_zero_of_four_le (hn : 4 ≤ n) : (n : ℝ) ≠ 0 := by
  have : 0 < n := by omega
  positivity

/-- **Conjecture (Discrete Uniformization Spectral Gap)**:
    For any curvature profile K on n ≥ 4 vertices satisfying Gauss-Bonnet
    for genus 0, there exist vertices i ≠ j such that the t=1/2 curvature
    step reduces variance by at least Var(K)/n².

    **Computational test**: For n = 4,...,20, enumerate integer curvature
    profiles summing to 4π (or approximate), compute variance and minimum
    reduction, verify the ratio ≥ 1/n². -/
def spectralGapConjecture : Prop :=
  ∀ (n : ℕ) (hn : 4 ≤ n) (K : Fin n → ℝ),
    (∑ i, K i = 4 * π) →
    let hn' := ne_zero_of_four_le hn
    (0 < fvariance hn' K) →
    ∃ i j : Fin n, i ≠ j ∧
      fvariance hn' K - fvariance hn' (curvatureStep K i j (1/2))
      ≥ fvariance hn' K / n ^ 2

end CurvatureVariance