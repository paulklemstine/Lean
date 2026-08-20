/-
# Intermediate fields of a Hilbert class field datum

This file deepens the catalog's conditional Hilbert class field reciprocity interface.  Given an
Artin reciprocity isomorphism between `Gal(H/K)` and the ideal class group, it proves that every
intermediate extension `K ≤ L ≤ H` is Galois and abelian, and that its degree divides the class
number of `K`.
-/

import Catalog.NumberTheory.HilbertClassFieldLanglands

open NumberField

namespace HilbertClassFieldIntermediate

noncomputable section

variable (K : Type*) [Field K] [NumberField K]
variable (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]

omit [NumberField K] [FiniteDimensional K H] [IsGalois K H] in
/-- Every fixing subgroup in a Hilbert class field datum is normal: Artin reciprocity identifies
its ambient Galois group with the abelian ideal class group. -/
theorem fixingSubgroup_normal
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : L.fixingSubgroup.Normal := by
  refine ⟨fun σ hσ τ => ?_⟩
  have hconj : τ * σ * τ⁻¹ = σ := by
    rw [HilbertClassFieldLanglands.galoisGroup_commutative K H e τ σ,
      mul_assoc, mul_inv_cancel, mul_one]
  rw [hconj]
  exact hσ

omit [NumberField K] [FiniteDimensional K H] in
/-- Every intermediate extension of a Hilbert class field datum is Galois over the base. -/
theorem intermediate_isGalois
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : IsGalois K L :=
  (InfiniteGalois.normal_iff_isGalois L).mp (fixingSubgroup_normal K H e L)

omit [NumberField K] [FiniteDimensional K H] in
/-- Every intermediate extension of a Hilbert class field datum has abelian Galois group. -/
theorem intermediate_galoisGroup_commutative
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H)
    (σ τ : L ≃ₐ[K] L) : σ * τ = τ * σ := by
  letI : IsGalois K L := intermediate_isGalois K H e L
  letI : Normal K L := IsGalois.to_normal
  have hs := AlgEquiv.restrictNormalHom_surjective (F := K) (K₁ := L) H
  obtain ⟨σ', rfl⟩ := hs σ
  obtain ⟨τ', rfl⟩ := hs τ
  rw [← map_mul, ← map_mul,
    HilbertClassFieldLanglands.galoisGroup_commutative K H e σ' τ']

/-- Degrees in every intermediate tower factor the class number exactly. -/
theorem intermediate_degree_factorization
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    Module.finrank K L * Module.finrank L H = classNumber K := by
  rw [Module.finrank_mul_finrank K L H,
    HilbertClassFieldReciprocity.finrank_eq_classNumber K H e]

/-- The degree of every intermediate extension of a Hilbert class field datum divides the class
number of the base field. -/
theorem intermediate_finrank_dvd_classNumber
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    Module.finrank K L ∣ classNumber K := by
  rw [← HilbertClassFieldReciprocity.finrank_eq_classNumber K H e]
  exact ⟨Module.finrank L H, (Module.finrank_mul_finrank K L H).symm⟩

/-- The relative degree from an intermediate field to the Hilbert class field also divides the
class number of the base field. -/
theorem top_finrank_dvd_classNumber
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    Module.finrank L H ∣ classNumber K := by
  rw [← HilbertClassFieldReciprocity.finrank_eq_classNumber K H e]
  exact ⟨Module.finrank K L, (Module.finrank_mul_finrank K L H).symm.trans
    (Nat.mul_comm _ _)⟩

end

end HilbertClassFieldIntermediate