/-! # CatalogBuild.Algebra.Factoring.TetrabranchTree

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 13
-/

import Mathlib

/-- Berggren M₂ as a function on ℤ³. -/
def berggrenM₂ (v : Fin 3 → ℤ) : Fin 3 → ℤ := fun i =>
  match i with
  | 0 => v 0 + 2 * v 1 + 2 * v 2
  | 1 => 2 * v 0 + v 1 + 2 * v 2
  | 2 => 2 * v 0 + 2 * v 1 + 3 * v 2


/-- M₁ preserves the light cone. -/
theorem M₁_preserves_null (v : Fin 3 → ℤ) (h : isNull v) :
    isNull (berggrenM₁ v) := by
  simp only [isNull, minkowskiQ, berggrenM₁] at h ⊢; nlinarith


/-- M₂ preserves the light cone. -/
theorem M₂_preserves_null (v : Fin 3 → ℤ) (h : isNull v) :
    isNull (berggrenM₂ v) := by
  simp only [isNull, minkowskiQ, berggrenM₂] at h ⊢; nlinarith


/-- M₃ preserves the light cone. -/
theorem M₃_preserves_null (v : Fin 3 → ℤ) (h : isNull v) :
    isNull (berggrenM₃ v) := by
  simp only [isNull, minkowskiQ, berggrenM₃] at h ⊢; nlinarith


/-- **The 4th branch preserves the light cone.** The parent/time-reversal map
keeps vectors on the null surface. A photon traced backward is still a photon. -/
theorem parent_preserves_null (v : Fin 3 → ℤ) (h : isNull v) :
    isNull (berggrenParent v) := by
  simp only [isNull, minkowskiQ, berggrenParent] at h ⊢; nlinarith


/-- All four branch operations preserve the full Minkowski form (not just the null set).
They are all discrete Lorentz transformations in O(2,1;ℤ). -/
theorem all_branches_preserve_minkowski (v : Fin 3 → ℤ) :
    minkowskiQ (berggrenM₁ v) = minkowskiQ v ∧
    minkowskiQ (berggrenM₂ v) = minkowskiQ v ∧
    minkowskiQ (berggrenM₃ v) = minkowskiQ v ∧
    minkowskiQ (berggrenParent v) = minkowskiQ v := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp [minkowskiQ, berggrenM₁, berggrenM₂, berggrenM₃, berggrenParent] <;> ring


/-- The parent map is the inverse of M₂: M₂⁻¹ ∘ M₂ = id.
"The 4th branch reverses the 2nd branch." -/
theorem parent_inverse_M₂ (v : Fin 3 → ℤ) :
    berggrenParent (berggrenM₂ v) = v := by
  ext i; fin_cases i <;> simp [berggrenParent, berggrenM₂] <;> ring


/-- Conversely, M₂ ∘ M₂⁻¹ = id. -/
theorem M₂_inverse_parent (v : Fin 3 → ℤ) :
    berggrenM₂ (berggrenParent v) = v := by
  ext i; fin_cases i <;> simp [berggrenParent, berggrenM₂] <;> ring


/-- A path in the 4-branch (tetrabranch) Pythagorean spacetime tree.
Three branches go forward in "time" (increasing hypotenuse),
one branch goes backward (decreasing hypotenuse). -/
inductive TetraPath where
  | root : TetraPath
  | spatial₁ : TetraPath → TetraPath   -- M₁: forward spatial branch 1
  | spatial₂ : TetraPath → TetraPath   -- M₂: forward spatial branch 2
  | spatial₃ : TetraPath → TetraPath   -- M₃: forward spatial branch 3
  | temporal : TetraPath → TetraPath   -- M₂⁻¹: backward temporal branch
  deriving Repr


/-- Evaluate a tetrabranch path to get the ℤ³ vector. -/
def tetraEval : TetraPath → (Fin 3 → ℤ)
  | .root      => ![3, 4, 5]
  | .spatial₁ p => berggrenM₁ (tetraEval p)
  | .spatial₂ p => berggrenM₂ (tetraEval p)
  | .spatial₃ p => berggrenM₃ (tetraEval p)
  | .temporal p => berggrenParent (tetraEval p)


/-- **Main theorem**: Every node in the tetrabranch tree lies on the light cone.
The spacetime tree lives entirely on the null surface — every node is a photon state. -/
theorem tetrabranch_on_light_cone (p : TetraPath) : isNull (tetraEval p) := by
  induction p with
  | root => exact root_is_null
  | spatial₁ p ih => exact M₁_preserves_null _ ih
  | spatial₂ p ih => exact M₂_preserves_null _ ih
  | spatial₃ p ih => exact M₃_preserves_null _ ih
  | temporal p ih => exact parent_preserves_null _ ih


/-- The M₂ spatial branch increases the hypotenuse (energy grows forward in time). -/
theorem spatial_branch_increases_hypotenuse (v : Fin 3 → ℤ)
    (ha : 0 < v 0) (hb : 0 < v 1) (hc : 0 < v 2) :
    v 2 < (berggrenM₂ v) 2 := by
  simp [berggrenM₂]; linarith


/-- The spacetime interval along any path is zero (photon condition).
Discrete version of ds² = 0 for light. -/
theorem photon_interval_zero (p : TetraPath) :
    (tetraEval p) 0 ^ 2 + (tetraEval p) 1 ^ 2 - (tetraEval p) 2 ^ 2 = 0 := by
  have h := tetrabranch_on_light_cone p
  simp [isNull, minkowskiQ] at h; linarith


