/-! # CatalogBuild.Bridges.SpectralReciprocity

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Trace of A with zero diagonal is zero. -/
theorem trace_adj_diagonal' {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, A i i = 0) : Matrix.trace A = 0 := by
  simp [Matrix.trace, Matrix.diag_apply, hdiag]


/-- Tr(A²) = Σᵢⱼ Aᵢⱼ · Aⱼᵢ. -/
theorem trace_sq_eq_sum {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.trace (A * A) = ∑ i : Fin n, ∑ j : Fin n, A i j * A j i := by
  simp [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply]


/-- Partial Euler product. -/
def partialEulerProduct (f : ℕ → ℂ) (primes : Finset ℕ) (s : ℂ) : ℂ :=
  ∏ p ∈ primes, (1 - f p * (↑p : ℂ) ^ (-s))⁻¹


/-- The Euler product for the trivial character. -/
theorem euler_product_trivial_char (primes : Finset ℕ) (s : ℂ) :
    partialEulerProduct (fun _ => 1) primes s =
    ∏ p ∈ primes, (1 - (↑p : ℂ) ^ (-s))⁻¹ := by
  simp [partialEulerProduct]


/-- A Hecke operator at a prime. -/
structure HeckeOperator (n : ℕ) where
  matrix : Matrix (Fin n) (Fin n) ℂ
  prime : ℕ
  is_prime : Nat.Prime prime


/-- [Section: # CatalogBuild.Bridges.SpectralReciprocity
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10] -/
theorem ramanujan_gap_explicit (q : ℕ) (hq : q ≥ 1) :
    (q : ℝ) + 1 - 2 * Real.sqrt q ≥ ((Real.sqrt q : ℝ) - 1) ^ 2 := by
  linarith [ Real.mul_self_sqrt ( Nat.cast_nonneg q ) ]


/-- [Section: # CatalogBuild.Bridges.SpectralReciprocity
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10] -/
theorem ramanujan_gap_nonneg (q : ℕ) (hq : q ≥ 1) :
    (q : ℝ) + 1 - 2 * Real.sqrt q ≥ 0 := by
  nlinarith [ sq_nonneg ( Real.sqrt q - 1 ), Real.mul_self_sqrt ( Nat.cast_nonneg q ) ]


/-- The Spectral-Arithmetic Bridge. -/
structure SpectralArithmeticBridge where
  regularity : ℕ
  eigenvalue_distribution : ℕ → ℝ → ℝ
  plancherel_limit : ℝ → ℝ
  convergence : ∀ x : ℝ, Filter.Tendsto
    (fun n => eigenvalue_distribution n x) Filter.atTop (nhds (plancherel_limit x))


/-- The Selberg-Ihara correspondence. -/
structure SelbergIharaBridge where
  continuous_side : String
  discrete_side : String
  correspondence : String


/-- [Section: # CatalogBuild.Bridges.SpectralReciprocity
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10] -/
def selbergIharaInstances : List SelbergIharaBridge :=
  [ { continuous_side := "Hyperbolic surface"
      discrete_side := "Regular graph G"
      correspondence := "Quotient by arithmetic group" },
    { continuous_side := "Closed geodesics"
      discrete_side := "Prime cycles"
      correspondence := "Length spectrum" } ]


end
