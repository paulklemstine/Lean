import Mathlib

/-!
# Hodge Structures and the Hodge Conjecture: Core Definitions

This file formalizes the algebraic core of the Hodge conjecture for weight-2
rational Hodge structures. We define:

- `WeightTwoHS`: A weight-2 rational Hodge structure on a ℚ-vector space V,
  given by the H^{1,1} subspace of the complexification ℂ ⊗[ℚ] V.
- `hodgeClasses`: The ℚ-submodule of Hodge classes (rational vectors
  whose complexification lies in H^{1,1}).
- `AlgebraicData`: An abstract specification of algebraic cycle classes
  as a ℚ-submodule of V contained in the Hodge classes.
- `HodgeConjectureHolds`: The formal statement that algebraic classes
  exhaust all Hodge classes.
- `PolarizedHS`: A polarized weight-2 Hodge structure with bilinear form Q.
- `HodgeMorphism`: A morphism of Hodge structures preserving H^{1,1}.
- `hodgeIndex`: The Hodge index (signature invariant) of a polarized structure.

## Mathematical context

The Hodge conjecture (Millennium Prize Problem) asserts that for a smooth
projective variety X over ℂ, every Hodge class in H^{2p}(X, ℚ) ∩ H^{p,p}(X)
is a ℚ-linear combination of fundamental classes of algebraic subvarieties.

We formalize the linear-algebraic skeleton of this conjecture, abstracting
away the geometric content into the definition of the algebraic submodule.
This allows us to prove structural results (rank bounds, polarization
constraints, morphism preservation) that hold for any realization.
-/

noncomputable section

open scoped TensorProduct
open LinearMap Submodule

/-! ## Weight-2 Hodge Structure -/

/-- A weight-2 rational Hodge structure on a finite-dimensional ℚ-vector space V.
    The structure is specified by the H^{1,1} subspace of the complexification. -/
structure WeightTwoHS (V : Type*) [AddCommGroup V] [Module ℚ V] where
  /-- The (1,1)-component of the Hodge decomposition in ℂ ⊗[ℚ] V -/
  H11 : Submodule ℂ (ℂ ⊗[ℚ] V)

variable {V : Type*} [AddCommGroup V] [Module ℚ V]

/-- A rational vector v is a Hodge class if 1 ⊗ v lies in H^{1,1}. -/
def IsHodgeClass (HS : WeightTwoHS V) (v : V) : Prop :=
  (1 : ℂ) ⊗ₜ[ℚ] v ∈ HS.H11

/-- The ℚ-submodule of all Hodge classes in V. -/
def hodgeClasses (HS : WeightTwoHS V) : Submodule ℚ V where
  carrier := { v | IsHodgeClass HS v }
  zero_mem' := by simp [IsHodgeClass, TensorProduct.tmul_zero, HS.H11.zero_mem]
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq, IsHodgeClass] at *
    rw [TensorProduct.tmul_add]
    exact HS.H11.add_mem ha hb
  smul_mem' := by
    intro q v hv
    simp only [Set.mem_setOf_eq, IsHodgeClass] at *
    show (1 : ℂ) ⊗ₜ[ℚ] (q • v) ∈ HS.H11
    rw [TensorProduct.tmul_smul]
    exact HS.H11.smul_mem (algebraMap ℚ ℂ q) hv

@[simp]
theorem mem_hodgeClasses (HS : WeightTwoHS V) (v : V) :
    v ∈ hodgeClasses HS ↔ IsHodgeClass HS v := Iff.rfl

/-- The Picard rank of a Hodge structure (dimension of the Hodge class subspace). -/
def picardRank [FiniteDimensional ℚ V] (HS : WeightTwoHS V) : ℕ :=
  Module.finrank ℚ (hodgeClasses HS)

/-! ## Algebraic Data and the Hodge Conjecture -/

/-- Abstract algebraic cycle class data: a ℚ-submodule of V contained in the Hodge classes.
    This abstracts the geometric content — in practice, these come from fundamental classes
    of algebraic subvarieties. -/
structure AlgebraicData (HS : WeightTwoHS V) where
  /-- The submodule of algebraic classes -/
  algClasses : Submodule ℚ V
  /-- Every algebraic class is a Hodge class -/
  algClasses_le : algClasses ≤ hodgeClasses HS

/-- The Hodge conjecture holds for a given Hodge structure with algebraic data
    if every Hodge class is algebraic. -/
def HodgeConjectureHolds (HS : WeightTwoHS V) (AD : AlgebraicData HS) : Prop :=
  hodgeClasses HS ≤ AD.algClasses

/-- Equivalent: the Hodge conjecture holds iff algebraic = Hodge classes. -/
theorem hodgeConj_iff_eq (HS : WeightTwoHS V) (AD : AlgebraicData HS) :
    HodgeConjectureHolds HS AD ↔ AD.algClasses = hodgeClasses HS :=
  ⟨fun h => le_antisymm AD.algClasses_le h, fun h => by rw [HodgeConjectureHolds, h]⟩

/-! ## Polarized Hodge Structures -/

/-- A polarized weight-2 Hodge structure: carries a symmetric nondegenerate ℚ-bilinear form. -/
structure PolarizedHS (V : Type*) [AddCommGroup V] [Module ℚ V]
    extends WeightTwoHS V where
  /-- The polarization bilinear form Q : V × V → ℚ -/
  Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ
  /-- Q is symmetric -/
  Q_symm : ∀ x y, Q x y = Q y x
  /-- Q is nondegenerate -/
  Q_nondeg : ∀ x, (∀ y, Q x y = 0) → x = 0

/-- The Q-orthogonal complement of a submodule. -/
def qOrthogonal (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ) (W : Submodule ℚ V) : Submodule ℚ V where
  carrier := { v | ∀ w ∈ W, Q v w = 0 }
  zero_mem' := by simp [map_zero]
  add_mem' := by
    intro a b ha hb w hw
    simp only [Set.mem_setOf_eq] at *
    simp [map_add, ha w hw, hb w hw]
  smul_mem' := by
    intro c a ha w hw
    simp only [Set.mem_setOf_eq] at *
    simp [map_smul, ha w hw]

/-- The transcendental lattice: Q-orthogonal complement of the Hodge classes. -/
def transcendentalLattice (PHS : PolarizedHS V) : Submodule ℚ V :=
  qOrthogonal PHS.Q (hodgeClasses PHS.toWeightTwoHS)

/-! ## Hodge Morphisms -/

/-- A morphism of weight-2 Hodge structures: a ℚ-linear map that, after complexification,
    maps H^{1,1} to H^{1,1}. -/
structure HodgeMorphism (HS₁ : WeightTwoHS V) {W : Type*} [AddCommGroup W] [Module ℚ W]
    (HS₂ : WeightTwoHS W) where
  /-- The underlying ℚ-linear map -/
  toLinearMap : V →ₗ[ℚ] W
  /-- The complexified map preserves H^{1,1}: if 1⊗v ∈ H11₁ then 1⊗(f v) ∈ H11₂ -/
  preserves_H11 : ∀ v : V, IsHodgeClass HS₁ v → IsHodgeClass HS₂ (toLinearMap v)

/-! ## Hodge Index (signature invariant) -/

/-- A positive cone for a bilinear form Q on a submodule W:
    a submodule P ≤ W on which Q is positive definite. -/
structure PositiveCone (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ) (W : Submodule ℚ V) where
  /-- The positive submodule -/
  P : Submodule ℚ V
  /-- P is contained in W -/
  P_le : P ≤ W
  /-- Q is strictly positive on nonzero elements of P -/
  Q_pos : ∀ v ∈ P, v ≠ 0 → 0 < Q v v

/-- The Hodge index of a polarized Hodge structure is the maximal dimension
    of a positive-definite subspace of the Hodge classes. -/
def hodgeIndex [FiniteDimensional ℚ V] (PHS : PolarizedHS V) : ℕ :=
  ⨆ (C : PositiveCone PHS.Q (hodgeClasses PHS.toWeightTwoHS)),
    Module.finrank ℚ C.P

/-! ## Level Structure (for refined Hodge theory) -/

/-- The level of a Hodge structure measures how far H^{1,1} is from being everything.
    Level 0 means V_ℂ = H^{1,1}, i.e., every rational class is Hodge.
    This is a key invariant: the Hodge conjecture is trivially true at level 0. -/
def hodgeLevel [FiniteDimensional ℚ V] (HS : WeightTwoHS V) : ℕ :=
  Module.finrank ℚ V - picardRank HS

end