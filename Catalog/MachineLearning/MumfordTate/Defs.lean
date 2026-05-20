/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tensor Invariants and Mumford–Tate Groups: Core Definitions

This file formalizes the Tannakian principle that a weight-1 rational Hodge structure
is controlled by its tensor invariants. The Mumford–Tate group is recovered as
the subgroup of GL(W) that pointwise fixes all Hodge-class tensors.

## Main definitions

* `MumfordTate.conjugateEndo` — conjugation action of GL(W) on End(W)
* `MumfordTate.WeightOneHodgeData` — algebraic data of a weight-1 Hodge structure
* `MumfordTate.tensorInvariantStabilizer` — the subgroup of GL(W) fixing all Hodge
  endomorphisms (= pointwise centralizer in GL of the Hodge algebra)
* `MumfordTate.HasCMWitness` — witness for complex multiplication
-/

noncomputable section

namespace MumfordTate

variable {W : Type*} [AddCommGroup W] [Module ℚ W]

/-! ### Conjugation action -/

/-- The conjugation action of GL(W) on End(W): `conjugateEndo g φ = g ∘ φ ∘ g⁻¹`. -/
def conjugateEndo (g : W ≃ₗ[ℚ] W) (φ : Module.End ℚ W) : Module.End ℚ W :=
  g.toLinearMap ∘ₗ φ ∘ₗ g.symm.toLinearMap

@[simp]
lemma conjugateEndo_one (φ : Module.End ℚ W) :
    conjugateEndo (1 : W ≃ₗ[ℚ] W) φ = φ := by
  ext x; unfold conjugateEndo
  simp [show (1 : W ≃ₗ[ℚ] W).symm = (1 : W ≃ₗ[ℚ] W) from rfl]

lemma conjugateEndo_mul (g h : W ≃ₗ[ℚ] W) (φ : Module.End ℚ W) :
    conjugateEndo (g * h) φ = conjugateEndo g (conjugateEndo h φ) := by
  ext x; unfold conjugateEndo
  simp [LinearMap.comp_apply,
    show (g * h).symm = h.symm * g.symm from (mul_inv_rev g h ▸ rfl)]

/-- Conjugation preserves scalar endomorphisms. -/
lemma conjugateEndo_algebraMap (g : W ≃ₗ[ℚ] W) (a : ℚ) :
    conjugateEndo g (algebraMap ℚ (Module.End ℚ W) a) = algebraMap ℚ (Module.End ℚ W) a := by
  ext x; simp [conjugateEndo, Algebra.algebraMap_eq_smul_one]

/-- Conjugation equals the original iff the automorphism commutes with the endomorphism. -/
lemma conjugateEndo_eq_iff (g : W ≃ₗ[ℚ] W) (φ : Module.End ℚ W) :
    conjugateEndo g φ = φ ↔ g.toLinearMap ∘ₗ φ = φ ∘ₗ g.toLinearMap := by
  constructor
  · intro h
    ext x
    have := LinearMap.ext_iff.mp h (g x)
    simp [conjugateEndo, LinearMap.comp_apply] at this
    simpa [LinearMap.comp_apply]
  · intro h
    ext x
    simp [conjugateEndo, LinearMap.comp_apply]
    have := LinearMap.ext_iff.mp h (g.symm x)
    simp [LinearMap.comp_apply] at this
    exact this

lemma conjugateEndo_inv (g : W ≃ₗ[ℚ] W) (φ : Module.End ℚ W) :
    conjugateEndo g⁻¹ (conjugateEndo g φ) = φ := by
  rw [← conjugateEndo_mul, inv_mul_cancel, conjugateEndo_one]

/-! ### Weight-1 Hodge data -/

/-- A weight-1 rational Hodge structure on W, encoded as a ℚ-subalgebra of End(W)
representing the Hodge-compatible endomorphisms. These correspond to the (1,1) Hodge
classes in W ⊗ W∨. -/
structure WeightOneHodgeData (W : Type*) [AddCommGroup W] [Module ℚ W] where
  hodgeEndos : Subalgebra ℚ (Module.End ℚ W)

/-! ### Tensor-invariant stabilizer (pointwise) -/

/-- The tensor-invariant stabilizer: the subgroup of GL(W) that pointwise fixes
every Hodge-compatible endomorphism under conjugation. An element g is in the
stabilizer iff `g ∘ φ = φ ∘ g` for all Hodge-compatible φ.

This is the level-(1,1) approximation to the Mumford–Tate group, defined as
the centralizer of the Hodge endomorphism algebra in GL(W). -/
def tensorInvariantStabilizer (H : WeightOneHodgeData W) : Subgroup (W ≃ₗ[ℚ] W) where
  carrier := { g | ∀ φ ∈ H.hodgeEndos, conjugateEndo g φ = φ }
  mul_mem' := by
    intro g h hg hh φ hφ
    rw [conjugateEndo_mul, hh φ hφ, hg φ hφ]
  one_mem' := by
    intro φ _; exact conjugateEndo_one φ
  inv_mem' := by
    intro g hg φ hφ
    have h1 := hg φ hφ
    -- conjugateEndo g φ = φ, need conjugateEndo g⁻¹ φ = φ
    have key : φ = conjugateEndo g⁻¹ (conjugateEndo g φ) := (conjugateEndo_inv g φ).symm
    rw [h1] at key
    exact key.symm

@[simp]
lemma mem_tensorInvariantStabilizer (H : WeightOneHodgeData W) (g : W ≃ₗ[ℚ] W) :
    g ∈ tensorInvariantStabilizer H ↔
    ∀ φ ∈ H.hodgeEndos, conjugateEndo g φ = φ :=
  Iff.rfl

/-! ### CM witness -/

/-- A CM witness: a non-scalar Hodge-compatible endomorphism. -/
structure HasCMWitness (H : WeightOneHodgeData W) where
  φ : Module.End ℚ W
  φ_mem : φ ∈ H.hodgeEndos
  nonScalar : φ ∉ (⊥ : Subalgebra ℚ (Module.End ℚ W))

/-- The generic (non-CM) Hodge data: only scalar endomorphisms are Hodge-compatible. -/
def ScalarHodge : WeightOneHodgeData W where
  hodgeEndos := ⊥

/-- Ordering on Hodge data by inclusion of endomorphism algebras. -/
instance : LE (WeightOneHodgeData W) where
  le H₁ H₂ := H₁.hodgeEndos ≤ H₂.hodgeEndos

lemma le_def (H₁ H₂ : WeightOneHodgeData W) :
    H₁ ≤ H₂ ↔ H₁.hodgeEndos ≤ H₂.hodgeEndos := Iff.rfl

end MumfordTate