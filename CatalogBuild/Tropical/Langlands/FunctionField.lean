/-! # CatalogBuild.Tropical.Langlands.FunctionField

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 13
-/

import Mathlib

noncomputable section

/-- The Abel-Jacobi map -/
def abelJacobi (n g : ℕ) (D : Fin n → ℤ) (embedding : Fin n → Fin g → ℝ) :
    TropicalJacobian g :=
  fun j => ∑ v : Fin n, (D v : ℝ) * embedding v j


/-- Abel-Jacobi is linear in the divisor -/
theorem abelJacobi_linear (n g : ℕ) (D₁ D₂ : Fin n → ℤ)
    (embedding : Fin n → Fin g → ℝ) (j : Fin g) :
    abelJacobi n g (fun v => D₁ v + D₂ v) embedding j =
    abelJacobi n g D₁ embedding j + abelJacobi n g D₂ embedding j := by
  simp [abelJacobi, Finset.sum_add_distrib, Int.cast_add, add_mul]


/-- A tropical Hecke eigensheaf on the Jacobian -/
structure TropicalHeckeEigensheaf (g : ℕ) where
  toFun : TropicalJacobian g → ℝ
  eigenvalues : Fin g → ℝ
  eigen_property : ∀ x : TropicalJacobian g, ∀ i : Fin g,
    toFun (fun j => x j + if j = i then 1 else 0) = toFun x + eigenvalues i


/-- [Section: # CatalogBuild.Tropical.Langlands.FunctionField
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 13] -/
def linearEigensheaf (g : ℕ) (coeffs : Fin g → ℝ) : TropicalHeckeEigensheaf g where
  toFun := fun x => ∑ i : Fin g, coeffs i * x i
  eigenvalues := coeffs
  eigen_property := by
    intro x i
    simp only
    simp +decide [ mul_add, Finset.sum_add_distrib ]


/-- The tropical geometric Langlands for GL_1 -/
def tropGeometricLanglands_GL1 (g : ℕ) :
    TropicalHeckeEigensheaf g → (Fin g → ℝ) :=
  fun E => E.eigenvalues


/-- The correspondence is injective on linear eigensheaves -/
theorem tropGeoLanglands_injective (g : ℕ) (E₁ E₂ : TropicalHeckeEigensheaf g)
    (hlin₁ : E₁.toFun = fun x => ∑ i, E₁.eigenvalues i * x i)
    (hlin₂ : E₂.toFun = fun x => ∑ i, E₂.eigenvalues i * x i)
    (h : tropGeometricLanglands_GL1 g E₁ = tropGeometricLanglands_GL1 g E₂) :
    E₁.toFun = E₂.toFun := by
  simp [tropGeometricLanglands_GL1] at h
  rw [hlin₁, hlin₂, h]


/-- The tropical Hitchin base for GL_n: sum of eigenvalues -/
def tropHitchinBase (n : ℕ) (eigenvalues : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, eigenvalues i


/-- [Section: # CatalogBuild.Tropical.Langlands.FunctionField
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 13] -/
theorem tropHitchin_fiber_convex (n : ℕ) (target : ℝ) :
    Convex ℝ { x : Fin n → ℝ | ∑ i, x i = target } := by
  intro x hx y hy a b ha hb hab;
  simp_all +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _ ];
  linear_combination' hab * target


/-- For GL_n, the duality is the identity (self-dual) -/
def tropFunctionFieldDuality (g n : ℕ) :
    (Fin g → Fin n → ℝ) → (Fin g → Fin n → ℝ) := id


/-- The duality is an involution -/
theorem tropFunctionFieldDuality_invol (g n : ℕ) (x : Fin g → Fin n → ℝ) :
    tropFunctionFieldDuality g n (tropFunctionFieldDuality g n x) = x := by
  simp [tropFunctionFieldDuality]


/-- Degree of a tropical divisor -/
def tropicalDegree (n : ℕ) (D : Fin n → ℤ) : ℤ :=
  ∑ v : Fin n, D v


/-- Degree is additive -/
theorem tropicalDegree_add (n : ℕ) (D₁ D₂ : Fin n → ℤ) :
    tropicalDegree n (fun v => D₁ v + D₂ v) = tropicalDegree n D₁ + tropicalDegree n D₂ := by
  simp [tropicalDegree, Finset.sum_add_distrib]


/-- Degree of zero divisor is zero -/
theorem tropicalDegree_zero (n : ℕ) :
    tropicalDegree n (fun _ => 0) = 0 := by
  simp [tropicalDegree]


end
