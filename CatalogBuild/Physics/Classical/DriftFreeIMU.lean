/-! # CatalogBuild.Physics.Classical.DriftFreeIMU

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 3
-/

import Mathlib

/-- In any group, the product of a list times the product of the reversed
list of inverses equals 1. This is the abstract checksum identity. -/
theorem group_reversal_identity {G : Type*} [Group G] (L : List G) :
    L.prod * (L.map (·⁻¹)).reverse.prod = 1 := by
  induction' L using List.reverseRecOn with G _ ih <;> simp +decide [*, mul_assoc]

/-- The trace of the n×n identity matrix equals n. -/

theorem trace_identity_eq (n : ℕ) :
    Matrix.trace (1 : Matrix (Fin n) (Fin n) ℝ) = (n : ℝ) := by
  simp +decide [Matrix.trace]

/-- **The Drift-Free IMU Checksum Theorem.**
    For any finite sequence of invertible matrices M₁, …, Mₖ ∈ GL(n,ℝ),
    tr(M₁⋯Mₖ · Mₖ⁻¹⋯M₁⁻¹) = n. For 3×3 rotation matrices, this is 3. -/

theorem imu_checksum {n : ℕ} (L : List (GL (Fin n) ℝ)) :
    Matrix.trace ((L.prod : GL (Fin n) ℝ) * (L.map (·⁻¹)).reverse.prod).1 = (n : ℝ) := by
  rw [group_reversal_identity]
  convert trace_identity_eq n

