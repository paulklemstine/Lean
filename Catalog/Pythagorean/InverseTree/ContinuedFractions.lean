import Mathlib

/-! # CatalogBuild.Pythagorean.InverseTree.ContinuedFractions

Auto-generated from theorem catalog database.
Domain: Pythagorean/InverseTree
Declarations: 23
-/

/-- Berggren 2×2 matrix M₁ acting on Euclid parameters (m,n). -/
def cfM₁ : Matrix (Fin 2) (Fin 2) ℤ :=
  !![2, -1; 1, 0]

/-- Berggren 2×2 matrix M₂. -/
def cfM₂ : Matrix (Fin 2) (Fin 2) ℤ :=
  !![2, 1; 1, 0]

/-- Berggren 2×2 matrix M₃. -/
def cfM₃ : Matrix (Fin 2) (Fin 2) ℤ :=
  !![1, 2; 0, 1]

/-- The SL(2,ℤ) generator T = [[1,1],[0,1]]. -/
def cfT : Matrix (Fin 2) (Fin 2) ℤ :=
  !![1, 1; 0, 1]

/-- The SL(2,ℤ) generator S = [[0,-1],[1,0]]. -/
def cfS : Matrix (Fin 2) (Fin 2) ℤ :=
  !![0, -1; 1, 0]

/-- M₁ has determinant 1 (it's in SL(2,ℤ)). -/
theorem cfM1_det : Matrix.det cfM₁ = 1 := by
  native_decide

/-- M₂ has determinant -1. -/
theorem cfM2_det : Matrix.det cfM₂ = -1 := by
  native_decide

/-- M₃ has determinant 1 (it's in SL(2,ℤ)). -/
theorem cfM3_det : Matrix.det cfM₃ = 1 := by
  native_decide

/-- T has determinant 1. -/
theorem cfT_det : Matrix.det cfT = 1 := by
  native_decide

/-- S has determinant 1. -/
theorem cfS_det : Matrix.det cfS = 1 := by
  native_decide

/-- M₃ equals T², directly connecting the Berggren tree to continued fractions.
T generates translations z ↦ z + 1 in the modular group, so T² is z ↦ z + 2.
This means Branch 3 of the tree corresponds to a double shift in the CF expansion. -/
theorem M3_is_T_squared : cfM₃ = cfT * cfT := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [cfM₃, cfT, Matrix.mul_apply, Fin.sum_univ_two]

/-- M₁⁻¹ = [[0,1],[-1,2]] (as integer matrix). -/
def cfM₁_inv : Matrix (Fin 2) (Fin 2) ℤ :=
  !![0, 1; -1, 2]

/-- M₃⁻¹ = [[1,-2],[0,1]] = T⁻² . -/
def cfM₃_inv : Matrix (Fin 2) (Fin 2) ℤ :=
  !![1, -2; 0, 1]

/-- M₁⁻¹ is the actual inverse of M₁. -/
theorem cfM1_inv_correct : cfM₁ * cfM₁_inv = 1 := by
  native_decide

/-- M₃⁻¹ is the actual inverse of M₃. -/
theorem cfM3_inv_correct : cfM₃ * cfM₃_inv = 1 := by
  native_decide

/-- ST⁻²S⁻¹ computed explicitly: gives the lower-triangular generator of Γ_θ. -/
theorem ST2S_explicit : cfS * (cfT * cfT) * cfS = !![((-1) : ℤ), 0; 2, -1] := by
  native_decide

/-- M₁² is in SL(2,ℤ) (since det(M₁) = -1, det(M₁²) = 1). -/
theorem cfM1_sq_det : Matrix.det (cfM₁ * cfM₁) = 1 := by
  rw [Matrix.det_mul, cfM1_det]; norm_num

/-- M₁² computed explicitly: the "double step" for branch 1. -/
theorem cfM1_squared : cfM₁ * cfM₁ = !![(3 : ℤ), -2; 2, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [cfM₁, Matrix.mul_apply, Fin.sum_univ_two]

/-- M₃ acting on (m, n) gives (m + 2n, n) — a shift by 2 in the ratio m/n. -/
theorem M3_action (m n : ℤ) :
    cfM₃.mulVec ![m, n] = ![m + 2 * n, n] := by
  ext i; fin_cases i <;> simp [cfM₃, Matrix.mulVec, Fin.sum_univ_two] <;> ring

/-- M₁ acting on (m, n) gives (2m - n, m). -/
theorem M1_action (m n : ℤ) :
    cfM₁.mulVec ![m, n] = ![2 * m - n, m] := by
  ext i; fin_cases i <;> simp [cfM₁, Matrix.mulVec, Fin.sum_univ_two] <;> ring

/-- The Euclid parameters of the root triple (3, 4, 5) are (2, 1). -/
theorem root_euclid_params :
    (2 : ℤ) ^ 2 - 1 ^ 2 = 3 ∧ 2 * 2 * 1 = 4 ∧ (2 : ℤ) ^ 2 + 1 ^ 2 = 5 := by
  norm_num

/-- The trivial triple for odd N has Euclid parameters m = (N+1)/2, n = (N-1)/2. -/
theorem trivial_euclid_params (N : ℤ) (hN : N % 2 = 1) (hN_pos : 1 < N) :
    let m := (N + 1) / 2
    let n := (N - 1) / 2
    m - n = 1 := by
  simp only
  have h2 : (2 : ℤ) ∣ (N + 1) := by omega
  have h3 : (2 : ℤ) ∣ (N - 1) := by omega
  have hm : (N + 1) / 2 * 2 = N + 1 := Int.ediv_mul_cancel h2
  have hn : (N - 1) / 2 * 2 = N - 1 := Int.ediv_mul_cancel h3
  omega

/-- The trivial triple satisfies the difference-of-squares identity. -/
theorem trivial_diff_of_squares (N : ℤ) (hN : N % 2 = 1) :
    let m := (N + 1) / 2
    let n := (N - 1) / 2
    m ^ 2 - n ^ 2 = N := by
  simp only
  have h2 : (2 : ℤ) ∣ (N + 1) := by omega
  have h3 : (2 : ℤ) ∣ (N - 1) := by omega
  have hm : (N + 1) / 2 * 2 = N + 1 := Int.ediv_mul_cancel h2
  have hn : (N - 1) / 2 * 2 = N - 1 := Int.ediv_mul_cancel h3
  nlinarith [sq_abs ((N + 1) / 2), sq_abs ((N - 1) / 2)]

