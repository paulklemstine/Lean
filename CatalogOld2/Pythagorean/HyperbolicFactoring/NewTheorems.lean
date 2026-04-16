/-! # CatalogBuild.Pythagorean.HyperbolicFactoring.NewTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 44
-/

import Mathlib

theorem pathMatrix_det_abs (p : BPath) : |Matrix.det (pathMatrix p)| = 1 := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih =>
    simp only [pathMatrix, Matrix.det_mul, abs_mul, dir_det_abs, ih, one_mul]


/-- **Parallel Independence:** Subtree computations are independent. -/
theorem parallel_independence (p₁ suffix : BPath) :
    tripleAt (p₁ ++ suffix) = pathMatrix p₁ *ᵥ (tripleAt suffix) := by
  simp [tripleAt, pathMatrix_append, mulVec_mulVec]


/-- **Parallel Composition:** Workers can combine results via matrix multiplication. -/
theorem parallel_composition (p₁ p₂ : BPath) :
    pathMatrix (p₁ ++ p₂) = pathMatrix p₁ * pathMatrix p₂ :=
  pathMatrix_append p₁ p₂


/-- Determinant is multiplicative across parallel path segments. -/
theorem parallel_det_compose (p₁ p₂ : BPath) :
    Matrix.det (pathMatrix (p₁ ++ p₂)) =
    Matrix.det (pathMatrix p₁) * Matrix.det (pathMatrix p₂) := by
  rw [pathMatrix_append, Matrix.det_mul]


/-- **Branch Disjointness:** B₁ and B₂ produce distinct hypotenuses. -/
theorem branch_disjoint_L_M (a b c : ℤ) (hb : b ≠ 0) :
    2 * a - 2 * b + 3 * c ≠ 2 * a + 2 * b + 3 * c := by omega


/-- B₁ and B₃ produce distinct hypotenuses when a ≠ b. -/
theorem branch_disjoint_L_R (a b c : ℤ) (hab : a ≠ b) :
    2 * a - 2 * b + 3 * c ≠ -2 * a + 2 * b + 3 * c := by omega


/-- B₂ and B₃ produce distinct hypotenuses when a ≠ 0. -/
theorem branch_disjoint_M_R (a b c : ℤ) (ha : a ≠ 0) :
    2 * a + 2 * b + 3 * c ≠ -2 * a + 2 * b + 3 * c := by omega


/-- 3^k ≥ 1. -/
theorem paths_at_depth (k : ℕ) : 3 ^ k ≥ 1 :=
  Nat.one_le_pow k 3 (by norm_num)


/-- The (3,1)-Lorentz metric. -/
def η₄ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, (-1)]


theorem η₄_involution : η₄ * η₄ = 1 := by native_decide


def Q₄ (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2


theorem quad_null_cone (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    Q₄ a b c d = 0 := by simp [Q₄]; linarith


/-- A 4×4 generator extending B₂. -/
def G₄ : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 2, 0, 2; 2, 1, 0, 2; 0, 0, 1, 0; 2, 2, 0, 3]


theorem G₄_preserves_η₄ : G₄ᵀ * η₄ * G₄ = η₄ := by native_decide

theorem G₄_det : Matrix.det G₄ = -1 := by native_decide


/-- A second 4×4 generator: boost in the (1,3)-plane. -/
def G₄' : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 2, 2; 0, 1, 0, 0; 2, 0, 1, 2; 2, 0, 2, 3]


theorem G₄'_preserves_η₄ : G₄'ᵀ * η₄ * G₄' = η₄ := by native_decide

theorem G₄'_det : Matrix.det G₄' = -1 := by native_decide


theorem R₁₂_preserves_η₄ : R₁₂ᵀ * η₄ * R₁₂ = η₄ := by native_decide

theorem R₁₂_det : Matrix.det R₁₂ = 1 := by native_decide


theorem R₂₃_preserves_η₄ : R₂₃ᵀ * η₄ * R₂₃ = η₄ := by native_decide

theorem R₂₃_det : Matrix.det R₂₃ = 1 := by native_decide


/-- Composition preserves η₄. -/
theorem compose_preserves_η₄ :
    (G₄ * R₁₂)ᵀ * η₄ * (G₄ * R₁₂) = η₄ := by native_decide


/-- **Quadruple Factoring Identity.** -/
theorem quad_factoring (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith


/-- **Enhanced Factoring:** Quadruples give THREE independent factoring identities. -/
theorem quad_triple_factoring (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 ∧
    (d - b) * (d + b) = a ^ 2 + c ^ 2 ∧
    (d - a) * (d + a) = b ^ 2 + c ^ 2 := by
  constructor <;> [skip; constructor] <;> nlinarith


theorem G₄_generates_quadruple :
    let v := (![1, 2, 2, 3] : Fin 4 → ℤ)
    let w := G₄ *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 = w 3 ^ 2 := by native_decide


theorem quad_branching (k : ℕ) : 4 ^ k ≥ 3 ^ k :=
  Nat.pow_le_pow_left (by norm_num : 3 ≤ 4) k


theorem berggren_lattice_automorphism (d : BDir) :
    IsUnit (Matrix.det (dirMatrix d)) := by
  cases d <;> simp [dirMatrix, B₁, B₂, B₃] <;> native_decide


theorem pathMatrix_lattice_automorphism (p : BPath) :
    IsUnit (Matrix.det (pathMatrix p)) := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih =>
    rw [pathMatrix, Matrix.det_mul]
    exact IsUnit.mul (berggren_lattice_automorphism d) ih


theorem pythagorean_as_null_vector (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 - c ^ 2 = 0 := by linarith


theorem B₁_inv_correct : B₁_inv * B₁ = 1 := by native_decide

theorem B₁_inv_correct' : B₁ * B₁_inv = 1 := by native_decide

theorem B₁_inv_preserves_Q : B₁_invᵀ * Q * B₁_inv = Q := by native_decide


theorem perfect_lorentz_basis (p : BPath) :
    (pathMatrix p)ᵀ * Q * (pathMatrix p) = Q :=
  pathMatrix_preserves_Q p


/-- **Descent Terminates.** -/
theorem descent_terminates (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 5 < c) :
    -2 * a - 2 * b + 3 * c < c := by nlinarith [sq_nonneg a, sq_nonneg b]


theorem quantum_vs_classical (k : ℕ) (hk : 0 < k) :
    3 ^ k > k := by
  induction k with
  | zero => omega
  | succ n ih =>
    cases n with
    | zero => simp
    | succ m =>
      calc 3 ^ (m + 2) = 3 * 3 ^ (m + 1) := by ring
        _ ≥ 3 * (m + 2) := by omega
        _ ≥ m + 3 := by omega


theorem path_factorization (d : BDir) (ds : BPath) :
    pathMatrix (d :: ds) = dirMatrix d * pathMatrix ds := rfl


theorem quantum_walk_step_preserves (d : BDir) (p : BPath) :
    ((dirMatrix d * pathMatrix p)ᵀ * Q * (dirMatrix d * pathMatrix p)) = Q := by
  change (pathMatrix (d :: p))ᵀ * Q * pathMatrix (d :: p) = Q
  exact pathMatrix_preserves_Q (d :: p)


def countM : BPath → ℕ
  | [] => 0
  | .M :: ds => 1 + countM ds
  | _ :: ds => countM ds


/-- **Determinant Parity Theorem.** -/
theorem det_parity (p : BPath) :
    Matrix.det (pathMatrix p) = (-1) ^ (countM p) := by
  induction p with
  | nil => simp [pathMatrix, countM]
  | cons d ds ih =>
    simp only [pathMatrix, Matrix.det_mul, ih]
    cases d
    all_goals simp [dirMatrix, countM, det_B₁, det_B₂, det_B₃]
    ring


/-- LR paths (no M-steps). -/
def isLRPath : BPath → Prop
  | [] => True
  | .L :: ds => isLRPath ds
  | .R :: ds => isLRPath ds
  | .M :: _ => False


/-- **LR-Submonoid Theorem:** LR-paths have determinant +1. -/
theorem LR_path_det_one (p : BPath) (h : isLRPath p) :
    Matrix.det (pathMatrix p) = 1 := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih =>
    cases d with
    | L => simp [pathMatrix, dirMatrix, Matrix.det_mul, det_B₁, ih (by exact h)]
    | R => simp [pathMatrix, dirMatrix, Matrix.det_mul, det_B₃, ih (by exact h)]
    | M => exact absurd h (by simp [isLRPath])


theorem shortcut_injective (p : BPath) :
    Function.Injective (fun v => pathMatrix p *ᵥ v) := by
  -- The determinant of the path matrix is either 1 or -1, which means the matrix is invertible.
  have h_det : Matrix.det (pathMatrix p) = 1 ∨ Matrix.det (pathMatrix p) = -1 := by
    have h_det_abs : |Matrix.det (pathMatrix p)| = 1 := by
      exact?;
    grind;
  cases' h_det with h_det h_det;
  · exact fun v w h => by simpa [ h_det ] using congr_arg ( fun v => ( pathMatrix p ) ⁻¹.mulVec v ) h;
  · exact fun v w h => by simpa [ h_det ] using congr_arg ( fun v => ( pathMatrix p ) ⁻¹.mulVec v ) h;


theorem root_null : lorentzInner root root = 0 := by simp [lorentzInner, root]

