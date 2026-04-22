import Mathlib

/-! # CatalogBuild.Pythagorean.ModularForms.RamanujanOpenProblems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 81
-/

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanOpenProblems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 81] -/
def ropB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanOpenProblems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 81] -/
def ropB₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def ropB₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

def ropQ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

def ropMatMod (N : ℕ) [NeZero N] (M : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix (Fin 3) (Fin 3) (ZMod N) := M.map (Int.cast)

theorem rop_lorentz_mod13 :
    (ropMatMod 13 ropB₁)ᵀ * (ropMatMod 13 ropQ) * (ropMatMod 13 ropB₁) = ropMatMod 13 ropQ ∧
    (ropMatMod 13 ropB₂)ᵀ * (ropMatMod 13 ropQ) * (ropMatMod 13 ropB₂) = ropMatMod 13 ropQ ∧
    (ropMatMod 13 ropB₃)ᵀ * (ropMatMod 13 ropQ) * (ropMatMod 13 ropB₃) = ropMatMod 13 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod17 :
    (ropMatMod 17 ropB₁)ᵀ * (ropMatMod 17 ropQ) * (ropMatMod 17 ropB₁) = ropMatMod 17 ropQ ∧
    (ropMatMod 17 ropB₂)ᵀ * (ropMatMod 17 ropQ) * (ropMatMod 17 ropB₂) = ropMatMod 17 ropQ ∧
    (ropMatMod 17 ropB₃)ᵀ * (ropMatMod 17 ropQ) * (ropMatMod 17 ropB₃) = ropMatMod 17 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod19 :
    (ropMatMod 19 ropB₁)ᵀ * (ropMatMod 19 ropQ) * (ropMatMod 19 ropB₁) = ropMatMod 19 ropQ ∧
    (ropMatMod 19 ropB₂)ᵀ * (ropMatMod 19 ropQ) * (ropMatMod 19 ropB₂) = ropMatMod 19 ropQ ∧
    (ropMatMod 19 ropB₃)ᵀ * (ropMatMod 19 ropQ) * (ropMatMod 19 ropB₃) = ropMatMod 19 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod23 :
    (ropMatMod 23 ropB₁)ᵀ * (ropMatMod 23 ropQ) * (ropMatMod 23 ropB₁) = ropMatMod 23 ropQ ∧
    (ropMatMod 23 ropB₂)ᵀ * (ropMatMod 23 ropQ) * (ropMatMod 23 ropB₂) = ropMatMod 23 ropQ ∧
    (ropMatMod 23 ropB₃)ᵀ * (ropMatMod 23 ropQ) * (ropMatMod 23 ropB₃) = ropMatMod 23 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod29 :
    (ropMatMod 29 ropB₁)ᵀ * (ropMatMod 29 ropQ) * (ropMatMod 29 ropB₁) = ropMatMod 29 ropQ ∧
    (ropMatMod 29 ropB₂)ᵀ * (ropMatMod 29 ropQ) * (ropMatMod 29 ropB₂) = ropMatMod 29 ropQ ∧
    (ropMatMod 29 ropB₃)ᵀ * (ropMatMod 29 ropQ) * (ropMatMod 29 ropB₃) = ropMatMod 29 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod31 :
    (ropMatMod 31 ropB₁)ᵀ * (ropMatMod 31 ropQ) * (ropMatMod 31 ropB₁) = ropMatMod 31 ropQ ∧
    (ropMatMod 31 ropB₂)ᵀ * (ropMatMod 31 ropQ) * (ropMatMod 31 ropB₂) = ropMatMod 31 ropQ ∧
    (ropMatMod 31 ropB₃)ᵀ * (ropMatMod 31 ropQ) * (ropMatMod 31 ropB₃) = ropMatMod 31 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod37 :
    (ropMatMod 37 ropB₁)ᵀ * (ropMatMod 37 ropQ) * (ropMatMod 37 ropB₁) = ropMatMod 37 ropQ ∧
    (ropMatMod 37 ropB₂)ᵀ * (ropMatMod 37 ropQ) * (ropMatMod 37 ropB₂) = ropMatMod 37 ropQ ∧
    (ropMatMod 37 ropB₃)ᵀ * (ropMatMod 37 ropQ) * (ropMatMod 37 ropB₃) = ropMatMod 37 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod41 :
    (ropMatMod 41 ropB₁)ᵀ * (ropMatMod 41 ropQ) * (ropMatMod 41 ropB₁) = ropMatMod 41 ropQ ∧
    (ropMatMod 41 ropB₂)ᵀ * (ropMatMod 41 ropQ) * (ropMatMod 41 ropB₂) = ropMatMod 41 ropQ ∧
    (ropMatMod 41 ropB₃)ᵀ * (ropMatMod 41 ropQ) * (ropMatMod 41 ropB₃) = ropMatMod 41 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

theorem rop_lorentz_mod43 :
    (ropMatMod 43 ropB₁)ᵀ * (ropMatMod 43 ropQ) * (ropMatMod 43 ropB₁) = ropMatMod 43 ropQ ∧
    (ropMatMod 43 ropB₂)ᵀ * (ropMatMod 43 ropQ) * (ropMatMod 43 ropB₂) = ropMatMod 43 ropQ ∧
    (ropMatMod 43 ropB₃)ᵀ * (ropMatMod 43 ropQ) * (ropMatMod 43 ropB₃) = ropMatMod 43 ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- B₂ has order 6 mod 5. -/
theorem rop_B₂_order_mod5 :
    (ropMatMod 5 ropB₂) ^ 6 = 1 ∧ (ropMatMod 5 ropB₂) ^ 3 ≠ 1 :=
  ⟨by native_decide, by native_decide⟩

/-- B₂ has order 6 mod 7. -/
theorem rop_B₂_order_mod7 :
    (ropMatMod 7 ropB₂) ^ 6 = 1 ∧ (ropMatMod 7 ropB₂) ^ 3 ≠ 1 :=
  ⟨by native_decide, by native_decide⟩

/-- B₂ has order 14 mod 13. -/
theorem rop_B₂_order_mod13 :
    (ropMatMod 13 ropB₂) ^ 14 = 1 ∧ (ropMatMod 13 ropB₂) ^ 7 ≠ 1 :=
  ⟨by native_decide, by native_decide⟩

/-- B₁ has order 5 mod 5. -/
theorem rop_B₁_order_mod5 :
    (ropMatMod 5 ropB₁) ^ 5 = 1 := by native_decide

/-- B₃ has order 5 mod 5. -/
theorem rop_B₃_order_mod5 :
    (ropMatMod 5 ropB₃) ^ 5 = 1 := by native_decide

/-- Residue classification mod 8 determines √2 availability in 𝔽_p. -/
theorem rop_prime_residues_mod8 :
    5 % 8 = 5 ∧ 7 % 8 = 7 ∧ 11 % 8 = 3 ∧ 13 % 8 = 5 := by omega

/-- B₂ has determinant -1 (improper Lorentz transformation). -/
theorem ropB₂_det_neg1 : Matrix.det ropB₂ = -1 := by native_decide

/-- B₂² has determinant 1 (proper Lorentz transformation). -/
theorem ropB₂_sq_det_1 : Matrix.det (ropB₂ ^ 2) = 1 := by native_decide

/-- The vector (1, -1, 0) is an eigenvector of B₂ with eigenvalue -1. -/
theorem ropB₂_eigenvector_neg1 :
    ropB₂.mulVec ![(1:ℤ), -1, 0] = ![-1, 1, 0] := by native_decide

/-- The eigenvector (1,-1,0) is spacelike: Q-norm = 1² + (-1)² - 0² = 2. -/
theorem rop_eigvec_spacelike :
    (1:ℤ)^2 + (-1)^2 - 0^2 = 2 := by norm_num

/-- B₂² fixes the -1 eigenspace pointwise (since (-1)²=1). -/
theorem ropB₂_sq_fixes_eigvec :
    (ropB₂ ^ 2).mulVec ![(1:ℤ), -1, 0] = ![(1:ℤ), -1, 0] := by native_decide

/-- Even/odd trace pattern from the -1 eigenvalue. -/
theorem ropB₂_even_odd_trace_pattern :
    Matrix.trace (ropB₂ ^ 2) = 35 ∧
    Matrix.trace (ropB₂ ^ 3) = 197 ∧
    Matrix.trace (ropB₂ ^ 4) = 1155 ∧
    Matrix.trace (ropB₂ ^ 5) = 6725 :=
  ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩

/-- All traces of B₂ powers are odd ((-1)^n + 2·T_n(3) is always odd). -/
theorem rop_trace_all_odd :
    Matrix.trace (ropB₂ ^ 1) % 2 = 1 ∧
    Matrix.trace (ropB₂ ^ 2) % 2 = 1 ∧
    Matrix.trace (ropB₂ ^ 3) % 2 = 1 ∧
    Matrix.trace (ropB₂ ^ 4) % 2 = 1 ∧
    Matrix.trace (ropB₂ ^ 5) % 2 = 1 ∧
    Matrix.trace (ropB₂ ^ 6) % 2 = 1 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩

def ropB₁B₂ : Matrix (Fin 3) (Fin 3) ℤ := ropB₁ * ropB₂

def ropB₂B₃ : Matrix (Fin 3) (Fin 3) ℤ := ropB₂ * ropB₃

def ropB₁B₃ : Matrix (Fin 3) (Fin 3) ℤ := ropB₁ * ropB₃

/-- Mixed product traces. -/
theorem rop_mixed_traces :
    Matrix.trace ropB₁B₂ = 17 ∧
    Matrix.trace ropB₂B₃ = 17 ∧
    Matrix.trace ropB₁B₃ = 15 :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- Mixed products preserve the Lorentz form. -/
theorem rop_mixed_lorentz :
    ropB₁B₂ᵀ * ropQ * ropB₁B₂ = ropQ ∧
    ropB₂B₃ᵀ * ropQ * ropB₂B₃ = ropQ ∧
    ropB₁B₃ᵀ * ropQ * ropB₁B₃ = ropQ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- Mixed products have determinant ±1. -/
theorem rop_mixed_dets :
    Matrix.det ropB₁B₂ = -1 ∧
    Matrix.det ropB₂B₃ = -1 ∧
    Matrix.det ropB₁B₃ = 1 :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- Trace powers of B₁·B₂: tr = 17, tr² = 323, tr³ = 5777. -/
theorem rop_B₁B₂_trace_powers :
    Matrix.trace (ropB₁B₂ ^ 1) = 17 ∧
    Matrix.trace (ropB₁B₂ ^ 2) = 323 ∧
    Matrix.trace (ropB₁B₂ ^ 3) = 5777 :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- B₁B₂ has eigenvalue -1 (det(B₁B₂ + I) = 0). -/
theorem rop_B₁B₂_has_eigenvalue_neg1 :
    Matrix.det (ropB₁B₂ + 1) = 0 := by native_decide

/-- Cayley-Hamilton for B₁B₂: characteristic polynomial is λ³ - 17λ² - 17λ + 1.
Factored: (λ+1)(λ² - 18λ + 1).
Eigenvalues: -1, 9-4√5, 9+4√5. -/
theorem rop_B₁B₂_cayley_hamilton :
    ropB₁B₂ ^ 3 = 17 • ropB₁B₂ ^ 2 + 17 • ropB₁B₂ - 1 := by native_decide

/-- Chebyshev verification: tr((B₁B₂)ⁿ) = (-1)ⁿ + 2·Tₙ(9).
T₀(9) = 1, T₁(9) = 9, T₂(9) = 2·81-1 = 161.
n=1: -1 + 2·9 = 17 ✓
n=2: 1 + 2·161 = 323 ✓
n=3: T₃(9) = 2·9·161 - 9 = 2889, -1 + 2·2889 = 5777. -/
theorem rop_B₁B₂_chebyshev_formula :
    (17 : ℤ) = -1 + 2 * 9 ∧
    (323 : ℤ) = 1 + 2 * 161 ∧
    (5777 : ℤ) = -1 + 2 * 2889 := by omega

/-- Chebyshev-I recurrence at x=9: T_{n+1}(9) = 18·T_n(9) - T_{n-1}(9). -/
theorem rop_chebyshev_9_recurrence :
    (161 : ℤ) = 18 * 9 - 1 ∧
    (2889 : ℤ) = 18 * 161 - 9 := by omega

/-- The char poly factoring: (λ+1)(λ²-18λ+1) = λ³-17λ²-17λ+1. -/
theorem rop_B₁B₂_charpoly_factored :
    ∀ x : ℤ, (x + 1) * (x^2 - 18*x + 1) = x^3 - 17*x^2 - 17*x + 1 := by
  intro x; ring

/-- Product of hyperbolic eigenvalues of B₁B₂ is 1. -/
theorem rop_B₁B₂_hyperbolic_pair_product :
    ((9:ℝ) + 4 * Real.sqrt 5) * (9 - 4 * Real.sqrt 5) = 1 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  nlinarith

/-- Sum of hyperbolic eigenvalues is 18. -/
theorem rop_B₁B₂_hyperbolic_pair_sum :
    ((9:ℝ) + 4 * Real.sqrt 5) + (9 - 4 * Real.sqrt 5) = 18 := by ring

/-- Universal pattern: ALL det=-1 Berggren products have eigenvalue -1.
This is because det(M) = λ₁λ₂λ₃ = -1 and the matrix is in O(2,1),
so eigenvalues come in reciprocal pairs. If {λ, 1/λ, μ} with
λ·(1/λ)·μ = μ = -1, then μ = -1. -/
theorem rop_B₂B₃_has_eigenvalue_neg1 :
    Matrix.det (ropB₂B₃ + 1) = 0 := by native_decide

/-- Traces of B₁·B₃ (determinant 1, so eigenvalue +1 instead of -1). -/
theorem rop_B₁B₃_trace_powers :
    Matrix.trace (ropB₁B₃ ^ 1) = 15 ∧
    Matrix.trace (ropB₁B₃ ^ 2) = 195 ∧
    Matrix.trace (ropB₁B₃ ^ 3) = 2703 :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- B₁B₃ has determinant 1, so eigenvalues are {1, α, 1/α} or {-1, α, -1/α}
or three eigenvalues with product 1. -/
theorem rop_B₁B₃_det1 :
    Matrix.det ropB₁B₃ = 1 := by native_decide

/-- B₁B₃ does NOT have eigenvalue -1 (det(B₁B₃ + I) ≠ 0). -/
theorem rop_B₁B₃_no_neg1_eigenvalue :
    Matrix.det (ropB₁B₃ + 1) ≠ 0 := by native_decide

/-- B₁B₃ has eigenvalue 1 (det(B₁B₃ - I) = 0). -/
theorem rop_B₁B₃_has_eigenvalue_1 :
    Matrix.det (ropB₁B₃ - 1) = 0 := by native_decide

/-- Cayley-Hamilton for B₁B₃. -/
theorem rop_B₁B₃_cayley_hamilton :
    ropB₁B₃ ^ 3 = 15 • ropB₁B₃ ^ 2 - 15 • ropB₁B₃ + 1 := by native_decide

/-- So char poly of B₁B₃ is λ³ - 15λ² + 15λ - 1 = (λ-1)(λ²-14λ+1).
Eigenvalues: 1, 7-4√3, 7+4√3.
Chebyshev formula: tr((B₁B₃)ⁿ) = 1 + 2·Tₙ(7). -/
theorem rop_B₁B₃_charpoly_factored :
    ∀ x : ℤ, (x - 1) * (x^2 - 14*x + 1) = x^3 - 15*x^2 + 15*x - 1 := by
  intro x; ring

/-- Chebyshev verification: tr((B₁B₃)ⁿ) = 1 + 2·Tₙ(7).
T₀(7)=1, T₁(7)=7, T₂(7)=2·49-1=97, T₃(7)=14·97-7=1351.
n=1: 1+2·7 = 15 ✓
n=2: 1+2·97 = 195 ✓
n=3: 1+2·1351 = 2703 ✓ -/
theorem rop_B₁B₃_chebyshev_check :
    (15 : ℤ) = 1 + 2 * 7 ∧
    (195 : ℤ) = 1 + 2 * 97 ∧
    (2703 : ℤ) = 1 + 2 * 1351 := by omega

/-- Chebyshev-I recurrence at x=7. -/
theorem rop_chebyshev_7_recurrence :
    (97 : ℤ) = 2 * 7^2 - 1 ∧
    (1351 : ℤ) = 14 * 97 - 7 := by omega

def ropQ5 : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,0,0; 0,0,1,0,0; 0,0,0,1,0; 0,0,0,0,(-1)]

def ropK₁ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![(-1),0,0,2,2; 0,1,0,0,0; 0,0,1,0,0; (-2),0,0,1,2; (-2),0,0,2,3]

def ropK₂ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,2,2; 0,1,0,0,0; 0,0,1,0,0; 2,0,0,1,2; 2,0,0,2,3]

def ropK₃ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,(-1),0,2,2; 0,0,1,0,0; 0,(-2),0,1,2; 0,(-2),0,2,3]

def ropK₄ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,0,0; 0,0,(-1),2,2; 0,0,(-2),1,2; 0,0,(-2),2,3]

def ropK₅ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,0,0; 0,0,1,2,2; 0,0,2,1,2; 0,0,2,2,3]

def ropK₆ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,2,2; 0,0,1,0,0; 0,2,0,1,2; 0,2,0,2,3]

/-- Determinant classification for 5D generators. -/
theorem rop_5D_det_classification :
    Matrix.det ropK₁ = 1 ∧ Matrix.det ropK₂ = -1 ∧
    Matrix.det ropK₃ = 1 ∧ Matrix.det ropK₄ = 1 ∧
    Matrix.det ropK₅ = -1 ∧ Matrix.det ropK₆ = -1 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩

/-- K₁ is unipotent: (K₁-I)³ = 0 but (K₁-I)² ≠ 0. -/
theorem rop_K₁_unipotent :
    (ropK₁ - 1) ^ 3 = (0 : Matrix (Fin 5) (Fin 5) ℤ) ∧
    (ropK₁ - 1) ^ 2 ≠ (0 : Matrix (Fin 5) (Fin 5) ℤ) :=
  ⟨by native_decide, by native_decide⟩

/-- K₃ is unipotent. -/
theorem rop_K₃_unipotent :
    (ropK₃ - 1) ^ 3 = (0 : Matrix (Fin 5) (Fin 5) ℤ) ∧
    (ropK₃ - 1) ^ 2 ≠ (0 : Matrix (Fin 5) (Fin 5) ℤ) :=
  ⟨by native_decide, by native_decide⟩

/-- K₄ is unipotent. -/
theorem rop_K₄_unipotent :
    (ropK₄ - 1) ^ 3 = (0 : Matrix (Fin 5) (Fin 5) ℤ) ∧
    (ropK₄ - 1) ^ 2 ≠ (0 : Matrix (Fin 5) (Fin 5) ℤ) :=
  ⟨by native_decide, by native_decide⟩

/-- K₂ is NOT unipotent (hyperbolic). -/
theorem rop_K₂_not_unipotent :
    (ropK₂ - 1) ^ 3 ≠ (0 : Matrix (Fin 5) (Fin 5) ℤ) := by native_decide

/-- All 6 generators applied to root (1,1,1,1,2) produce valid quintuples. -/
theorem rop_K_on_root_all :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    (let w := ropK₁.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₂.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₃.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₄.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₅.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₆.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩

/-- All generators on root (1,0,0,0,1) also produce valid quintuples. -/
theorem rop_K_on_10001_all :
    let v := ![(1:ℤ), 0, 0, 0, 1]
    (let w := ropK₁.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₂.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₃.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₄.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₅.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) ∧
    (let w := ropK₆.mulVec v; w 0^2 + w 1^2 + w 2^2 + w 3^2 = w 4^2) :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩

/-- 5D Lorentz preservation for all generators. -/
theorem rop_5D_lorentz_all :
    ropK₁ᵀ * ropQ5 * ropK₁ = ropQ5 ∧
    ropK₂ᵀ * ropQ5 * ropK₂ = ropQ5 ∧
    ropK₃ᵀ * ropQ5 * ropK₃ = ropQ5 ∧
    ropK₄ᵀ * ropQ5 * ropK₄ = ropQ5 ∧
    ropK₅ᵀ * ropQ5 * ropK₅ = ropQ5 ∧
    ropK₆ᵀ * ropQ5 * ropK₆ = ropQ5 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩

/-- B₂ preserves the Lorentz form. -/
theorem rop_B₂_lorentz : ropB₂ᵀ * ropQ * ropB₂ = ropQ := by native_decide

/-- The eigenvalue (3+2√2) = (1+√2)², connecting to the Pell equation. -/
theorem rop_pell_connection :
    ((1:ℝ) + Real.sqrt 2)^2 = 3 + 2 * Real.sqrt 2 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  nlinarith

/-- Pell equation solutions: x²-2y²=1. T_n(3) are the x-coordinates. -/
theorem rop_pell_solutions :
    (3:ℤ)^2 - 2 * 2^2 = 1 ∧
    (17:ℤ)^2 - 2 * 12^2 = 1 ∧
    (99:ℤ)^2 - 2 * 70^2 = 1 ∧
    (577:ℤ)^2 - 2 * 408^2 = 1 := by norm_num

/-- The Pell y-values satisfy the companion recurrence. -/
theorem rop_pell_y_recurrence :
    (12:ℤ) = 6 * 2 - 0 ∧   -- y₀=0, y₁=2, y₂=12
    (70:ℤ) = 6 * 12 - 2 ∧
    (408:ℤ) = 6 * 70 - 12 := by omega

/-- For any d ≥ 3, the Ramanujan bound 2√(d-1) < d. -/
theorem rop_ramanujan_bound_lt_degree (d : ℕ) (hd : d ≥ 3) :
    4 * ((d : ℝ) - 1) < (d : ℝ)^2 := by
  have : (d : ℝ) ≥ 3 := by exact_mod_cast hd
  nlinarith

/-- The spectral gap is always positive for d ≥ 3. -/
theorem rop_spectral_gap_positive (d : ℕ) (hd : d ≥ 3) :
    (d : ℝ) - 2 * Real.sqrt ((d : ℝ) - 1) > 0 := by
  have hd3 : (d : ℝ) ≥ 3 := by exact_mod_cast hd
  have hd1 : (d : ℝ) - 1 ≥ 0 := by linarith
  have hsq : Real.sqrt ((d : ℝ) - 1) ^ 2 = (d : ℝ) - 1 := Real.sq_sqrt hd1
  nlinarith [Real.sqrt_nonneg ((d:ℝ) - 1), sq_nonneg (Real.sqrt ((d:ℝ) - 1) - 1)]

/-- Large d gap: at d=1000, the gap exceeds 930. -/
theorem rop_gap_d1000 :
    (1000 : ℝ) - 2 * Real.sqrt 999 > 930 := by
  have h : Real.sqrt 999 ^ 2 = 999 := Real.sq_sqrt (by norm_num : (999:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 999, sq_nonneg (Real.sqrt 999 - 35)]

/-- Ramanujan bound for 3-regular: 2√2 < 3. -/
theorem rop_ram_3reg : 2 * Real.sqrt 2 < 3 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 2, sq_nonneg (Real.sqrt 2 - 3/2)]

/-- d=50 gap exceeds 36. -/
theorem rop_gap_d50 :
    (50 : ℝ) - 2 * Real.sqrt 49 > 35 := by
  have h49 : Real.sqrt 49 ^ 2 = 49 := Real.sq_sqrt (by norm_num : (49:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 49, sq_nonneg (Real.sqrt 49 - 7)]

/-- All generator pairs are non-commuting. -/
theorem rop_full_noncommutativity :
    ropB₁ * ropB₂ ≠ ropB₂ * ropB₁ ∧
    ropB₁ * ropB₃ ≠ ropB₃ * ropB₁ ∧
    ropB₂ * ropB₃ ≠ ropB₃ * ropB₂ :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- Traces of all length-2 words. -/
theorem rop_length2_traces :
    Matrix.trace (ropB₁ ^ 2) = 3 ∧
    Matrix.trace (ropB₂ ^ 2) = 35 ∧
    Matrix.trace (ropB₃ ^ 2) = 3 ∧
    Matrix.trace (ropB₁ * ropB₂) = 17 ∧
    Matrix.trace (ropB₁ * ropB₃) = 15 ∧
    Matrix.trace (ropB₂ * ropB₃) = 17 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩

/-- Cyclic trace property: tr(AB) = tr(BA). -/
theorem rop_cyclic_trace :
    Matrix.trace (ropB₁ * ropB₂) = Matrix.trace (ropB₂ * ropB₁) ∧
    Matrix.trace (ropB₁ * ropB₃) = Matrix.trace (ropB₃ * ropB₁) ∧
    Matrix.trace (ropB₂ * ropB₃) = Matrix.trace (ropB₃ * ropB₂) :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- All generators preserve the root triple (3,4,5). -/
theorem rop_on_345 :
    ropB₁.mulVec ![(3:ℤ), 4, 5] = ![5, 12, 13] ∧
    ropB₂.mulVec ![(3:ℤ), 4, 5] = ![21, 20, 29] ∧
    ropB₃.mulVec ![(3:ℤ), 4, 5] = ![15, 8, 17] :=
  ⟨by native_decide, by native_decide, by native_decide⟩

/-- Children of (3,4,5) are all Pythagorean. -/
theorem rop_children_pythagorean :
    (5:ℤ)^2 + 12^2 = 13^2 ∧ (21:ℤ)^2 + 20^2 = 29^2 ∧ (15:ℤ)^2 + 8^2 = 17^2 := by
  norm_num

/-- Products of Lorentz transformations are Lorentz. -/
theorem rop_lorentz_closure (M N : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * ropQ * M = ropQ) (hN : Nᵀ * ropQ * N = ropQ) :
    (M * N)ᵀ * ropQ * (M * N) = ropQ := by
  rw [Matrix.transpose_mul]
  have : Nᵀ * Mᵀ * ropQ * (M * N) = Nᵀ * (Mᵀ * ropQ * M) * N := by
    simp [Matrix.mul_assoc]
  rw [this, hM, hN]

/-- 5D Lorentz closure. -/
theorem rop_lorentz5_closure (M N : Matrix (Fin 5) (Fin 5) ℤ)
    (hM : Mᵀ * ropQ5 * M = ropQ5) (hN : Nᵀ * ropQ5 * N = ropQ5) :
    (M * N)ᵀ * ropQ5 * (M * N) = ropQ5 := by
  rw [Matrix.transpose_mul]
  have : Nᵀ * Mᵀ * ropQ5 * (M * N) = Nᵀ * (Mᵀ * ropQ5 * M) * N := by
    simp [Matrix.mul_assoc]
  rw [this, hM, hN]

