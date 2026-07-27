/-
# Quadratic forms over number fields: local-global infrastructure

This file develops kernel-checked algebraic consequences needed by a future full
place-theoretic Hasse--Minkowski theorem.  It uses Mathlib's `QuadraticForm`,
`QuadraticMap.Anisotropic`, isometric equivalences, and scalar extension.

The actual construction of all completions of a number field and the arithmetic
reciprocity theorem are not currently part of Mathlib.  The results here therefore
establish unconditional invariance and scalar-extension foundations on which a
future place-theoretic Hasse--Minkowski theorem can be built.
-/

import Mathlib

open scoped TensorProduct

namespace QuadraticFormsNumberFields

open QuadraticMap

noncomputable section

local instance invertibleTwoOfCharZero
    (F : Type*) [Field F] [CharZero F] : Invertible (2 : F) :=
  invertibleOfNonzero (by norm_num)

variable {K L V W : Type*}

section Isometry

variable [Field K] [AddCommGroup V] [Module K V]
variable [AddCommGroup W] [Module K W]

/-- An isometric equivalence preserves anisotropy in both directions. -/
theorem anisotropic_iff_of_isometryEquiv
    {Q : QuadraticForm K V} {Q' : QuadraticForm K W}
    (e : Q.IsometryEquiv Q') : Q.Anisotropic ↔ Q'.Anisotropic := by
  let e' := e.toLinearEquiv
  have he : ∀ x, Q' (e' x) = Q x := fun x => e.2 x
  constructor
  · intro hQ x hx
    have h1 : Q (e'.symm x) = Q' x :=
      (he (e'.symm x)).symm.trans (by rw [e'.apply_symm_apply])
    rw [hx] at h1
    have h2 : e'.symm x = 0 := hQ _ h1
    exact e'.symm.injective (by simpa using h2)
  · intro hQ' x hx
    have h1 : Q' (e' x) = Q x := he x
    rw [hx] at h1
    have h2 : e' x = 0 := hQ' _ h1
    exact e'.injective (by simpa using h2)

/-- Equivalently, an isometric equivalence preserves existence of a nonzero zero. -/
theorem isotropic_iff_of_isometryEquiv
    {Q : QuadraticForm K V} {Q' : QuadraticForm K W}
    (e : Q.IsometryEquiv Q') : (¬ Q.Anisotropic) ↔ ¬ Q'.Anisotropic := by
  exact not_iff_not.mpr (anisotropic_iff_of_isometryEquiv e)

end Isometry

section ScalarExtension

variable [Field K] [Field L] [Algebra K L]
variable [Invertible (2 : K)]
variable [AddCommGroup V] [Module K V]

/-- A nonzero zero of a quadratic form remains a nonzero zero after extending scalars
along a field extension.  This is the elementary forward implication in every
local-global isotropy theorem. -/
theorem not_anisotropic_baseChange_of_not_anisotropic
    (Q : QuadraticForm K V) (hQ : ¬ Q.Anisotropic) :
    ¬ (Q.baseChange L).Anisotropic := by
  unfold QuadraticMap.Anisotropic at *
  push_neg at hQ ⊢
  obtain ⟨v, hvQ, hv⟩ := hQ
  let w : L ⊗[K] V := TensorProduct.tmul K (1 : L) v
  refine ⟨w, ?_, ?_⟩
  · show (QuadraticForm.baseChange L Q) (1 ⊗ₜ[K] v) = 0
    simp [QuadraticForm.baseChange, hvQ]
  · aesop

/-- Contrapositively, anisotropy after a field extension implies anisotropy over the
original field. -/
theorem anisotropic_of_baseChange_anisotropic
    (Q : QuadraticForm K V) (hQ : (Q.baseChange L).Anisotropic) :
    Q.Anisotropic := by
  by_contra h
  exact not_anisotropic_baseChange_of_not_anisotropic Q h hQ

end ScalarExtension

section NumberFields

variable [Field K] [NumberField K]
variable [Field L] [Algebra K L]
variable [AddCommGroup V] [Module K V]

/-- Scalar-extension isotropy from an arbitrary algebraic number field to any field
extension (and hence, in particular, to any algebraic number-field extension). -/
theorem numberField_isotropy_ascends
    (Q : QuadraticForm K V) (hQ : ¬ Q.Anisotropic) :
    ¬ (Q.baseChange L).Anisotropic := by
  exact not_anisotropic_baseChange_of_not_anisotropic Q hQ

/-- Scalar-extension anisotropy descends to an arbitrary algebraic number field
from any field extension (and hence from any algebraic number-field extension). -/
theorem numberField_anisotropy_descends
    (Q : QuadraticForm K V) (hQ : (Q.baseChange L).Anisotropic) :
    Q.Anisotropic := by
  exact anisotropic_of_baseChange_anisotropic Q hQ

end NumberFields

end

end QuadraticFormsNumberFields