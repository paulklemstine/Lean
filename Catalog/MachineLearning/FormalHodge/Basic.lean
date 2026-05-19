import Mathlib

/-!
# Formal Hodge Theory: Basic Definitions

This file defines the core structures for abstract weight-2 rational Hodge structures
and their Hodge classes.

- `WeightTwoHodgeData V`: a ℂ-submodule H^{1,1} of ℂ ⊗[ℚ] V
- `IsHodge11`: a rational vector is a Hodge class if 1 ⊗ v ∈ H^{1,1}
- `HodgeClasses`: the ℚ-submodule of all Hodge classes
- `PicardRank`: the ℚ-dimension of the Hodge class submodule
-/

noncomputable section

open scoped TensorProduct

/-- A weight-2 Hodge data on a ℚ-vector space V.
    We track only the H^{1,1} subspace since it determines the Hodge classes. -/
structure WeightTwoHodgeData (V : Type*) [AddCommGroup V] [Module ℚ V] where
  /-- The H^{1,1} subspace of the complexification ℂ ⊗[ℚ] V -/
  H11 : Submodule ℂ (ℂ ⊗[ℚ] V)

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]

/-- A rational vector v is a Hodge class if 1 ⊗ v ∈ H^{1,1}. -/
def IsHodge11 (HD : WeightTwoHodgeData V) (v : V) : Prop :=
  (1 : ℂ) ⊗ₜ[ℚ] v ∈ HD.H11

/-- The submodule of Hodge classes: rational vectors whose complexification lies in H^{1,1}. -/
def HodgeClasses (HD : WeightTwoHodgeData V) : Submodule ℚ V where
  carrier := {v | IsHodge11 HD v}
  zero_mem' := by
    simp only [Set.mem_setOf_eq, IsHodge11, TensorProduct.tmul_zero]
    exact HD.H11.zero_mem
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq, IsHodge11] at *
    rw [TensorProduct.tmul_add]
    exact HD.H11.add_mem ha hb
  smul_mem' := by
    intro q v hv
    simp only [Set.mem_setOf_eq, IsHodge11] at *
    show (1 : ℂ) ⊗ₜ[ℚ] (q • v) ∈ HD.H11
    rw [TensorProduct.tmul_smul]
    exact HD.H11.smul_mem (algebraMap ℚ ℂ q) hv

omit [FiniteDimensional ℚ V] in
theorem mem_hodgeClasses_iff (HD : WeightTwoHodgeData V) (v : V) :
    v ∈ HodgeClasses HD ↔ IsHodge11 HD v :=
  Iff.rfl

/-- The Picard rank of a Hodge structure. -/
def PicardRank (HD : WeightTwoHodgeData V) : ℕ :=
  Module.finrank ℚ (HodgeClasses HD)

/-- A polarized weight-2 Hodge data additionally carries a bilinear form Q on V. -/
structure PolarizedWeightTwoHodgeData (V : Type*) [AddCommGroup V] [Module ℚ V]
    extends WeightTwoHodgeData V where
  /-- The polarization bilinear form -/
  Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ
  /-- Symmetry -/
  Q_symm : ∀ x y, Q x y = Q y x
  /-- Nondegeneracy: Q(x, ·) = 0 implies x = 0 -/
  Q_nondeg : ∀ x, (∀ y, Q x y = 0) → x = 0

/-- The orthogonal complement of a submodule with respect to a bilinear form Q. -/
def orthogonalComplement (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ) (W : Submodule ℚ V) : Submodule ℚ V where
  carrier := {v | ∀ w ∈ W, Q v w = 0}
  zero_mem' := by simp [map_zero]
  add_mem' := by
    intro a b ha hb w hw
    simp only [Set.mem_setOf_eq] at *
    simp [map_add, ha w hw, hb w hw]
  smul_mem' := by
    intro c a ha w hw
    simp only [Set.mem_setOf_eq] at *
    simp [map_smul, ha w hw]

/-- The transcendental lattice is the orthogonal complement of the Hodge classes. -/
def TranscendentalLattice (HD : PolarizedWeightTwoHodgeData V) : Submodule ℚ V :=
  orthogonalComplement HD.Q (HodgeClasses HD.toWeightTwoHodgeData)

end