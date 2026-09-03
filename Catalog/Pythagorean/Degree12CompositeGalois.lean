/-
# `Q(ζ₅₆)⁺` really has degree 12 and Galois group `C₆ × C₂`

The companion files model the degree-12 rung by the finite group `C₆ × C₂` and by
the reduced residues mod 56.  This file *justifies the model inside Lean*: it
constructs the field, its Galois group, the real subfield, and an explicit
isomorphism with `C₆ × C₂`.

Main results.

* `finrank_L56` : `[Q(ζ₅₆) : Q] = 24`.
* `orderOf_conj56 = 2` : the distinguished involution (the image of `-1` under the
  cyclotomic character) has order 2.
* `finrank_RealCyclo56` : `[Q(ζ₅₆)⁺ : Q] = 12`, where `Q(ζ₅₆)⁺` is defined as the
  fixed field of that involution.
* `unitsEquiv` : an explicit basis isomorphism `(ZMod 56)ˣ ≅ C₆ × C₂ × C₂`
  realised by `3`, `13`, `-1`.
* `GplusEquiv` : `(ZMod 56)ˣ / {±1} ≅ C₆ × C₂`.
* `galRealGroupEquiv` : `Gal(Q(ζ₅₆)⁺ / Q) ≅ C₆ × C₂` — the composite of the
  cyclotomic character, the Galois correspondence and the basis isomorphism.
* `not_isCyclic_galReal`, `card_galReal` : the group has order 12 and is **not**
  cyclic; this is the first non-cyclic, composite-order rung of the ladder.
-/
import Mathlib
import Pythagorean.Degree12Composite

set_option maxRecDepth 40000

namespace Catalog.Pythagorean.Degree12Composite

open Polynomial IntermediateField

/-! ## The cyclotomic field of conductor 56 -/

/-- `Q(ζ₅₆)`. -/
noncomputable abbrev L56 := CyclotomicField 56 ℚ

theorem cyclotomic56_irreducible : Irreducible (cyclotomic 56 ℚ) :=
  cyclotomic.irreducible_rat (by norm_num)

/-- `[Q(ζ₅₆) : Q] = φ(56) = 24`. -/
theorem finrank_L56 : Module.finrank ℚ L56 = 24 := by
  rw [IsCyclotomicExtension.finrank (n := 56) L56 cyclotomic56_irreducible]
  decide

/-- The cyclotomic character `Gal(Q(ζ₅₆)/Q) ≅ (ZMod 56)ˣ`. -/
noncomputable def galEquiv : (L56 ≃ₐ[ℚ] L56) ≃* (ZMod 56)ˣ :=
  IsCyclotomicExtension.autEquivPow (n := 56) L56 cyclotomic56_irreducible

/-- The involution corresponding to `-1`: complex conjugation. -/
noncomputable def conj56 : L56 ≃ₐ[ℚ] L56 := galEquiv.symm (-1)

theorem orderOf_conj56 : orderOf conj56 = 2 := by
  have h1 : orderOf (-1 : (ZMod 56)ˣ) = 2 := by
    haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
    refine orderOf_eq_prime (by ring_nf; simp) ?_
    intro h
    have h2 := congrArg Units.val h
    simp at h2
    revert h2
    decide
  rw [conj56, ← h1]
  exact MulEquiv.orderOf_eq galEquiv.symm (-1)

/-- The Galois group of a cyclotomic field is abelian. -/
theorem gal_comm (a b : L56 ≃ₐ[ℚ] L56) : a * b = b * a := by
  apply galEquiv.injective
  rw [map_mul, map_mul, mul_comm]

instance : (Subgroup.zpowers conj56).Normal :=
  ⟨fun n hn g => by
    have h : g * n * g⁻¹ = n := by rw [gal_comm g n, mul_assoc, mul_inv_cancel, mul_one]
    rwa [h]⟩

/-- The **real cyclotomic field** `Q(ζ₅₆)⁺`, defined as the fixed field of the
involution `conj56`. -/
noncomputable def RealCyclo56 : IntermediateField ℚ L56 :=
  IntermediateField.fixedField (Subgroup.zpowers conj56)

theorem finrank_L56_over_real : Module.finrank RealCyclo56 L56 = 2 := by
  haveI : FiniteDimensional ℚ L56 := IsCyclotomicExtension.finiteDimensional {56} ℚ L56
  rw [RealCyclo56, IntermediateField.finrank_fixedField_eq_card, Nat.card_zpowers,
    orderOf_conj56]

/-- **Degree 12.**  `[Q(ζ₅₆)⁺ : Q] = 12`. -/
theorem finrank_RealCyclo56 : Module.finrank ℚ RealCyclo56 = 12 := by
  haveI : FiniteDimensional ℚ L56 := IsCyclotomicExtension.finiteDimensional {56} ℚ L56
  have htower := Module.finrank_mul_finrank ℚ RealCyclo56 L56
  rw [finrank_L56_over_real, finrank_L56] at htower
  omega

/-! ## The basis isomorphism `(ZMod 56)ˣ ≅ C₆ × C₂ × C₂` -/

/-- The unit `3`, of order 6. -/
def u3 : (ZMod 56)ˣ := ⟨3, 19, by decide, by decide⟩

/-- The unit `13`, of order 2 and independent of `3` and `-1`. -/
def u13 : (ZMod 56)ˣ := ⟨13, 13, by decide, by decide⟩

/-- The basis parametrisation, valued in units. -/
noncomputable def eMap (t : ZMod 6 × ZMod 2 × ZMod 2) : (ZMod 56)ˣ :=
  u3 ^ t.1.val * u13 ^ t.2.1.val * (-1) ^ t.2.2.val

theorem val_eMap (t : ZMod 6 × ZMod 2 × ZMod 2) :
    ((eMap t : (ZMod 56)ˣ) : ZMod 56) = basisMap t := by
  simp [eMap, basisMap, u3, u13]

theorem basisMap_add : ∀ t s : ZMod 6 × ZMod 2 × ZMod 2,
    basisMap (t + s) = basisMap t * basisMap s := by decide

/-- The basis parametrisation is a group homomorphism `C₆ × C₂ × C₂ → (ZMod 56)ˣ`. -/
noncomputable def unitsHom : Multiplicative (ZMod 6 × ZMod 2 × ZMod 2) →* (ZMod 56)ˣ where
  toFun t := eMap t.toAdd
  map_one' := by
    apply Units.ext
    rw [val_eMap]
    decide
  map_mul' t s := by
    apply Units.ext
    rw [Units.val_mul, val_eMap, val_eMap, val_eMap]
    exact basisMap_add _ _

theorem unitsHom_bijective : Function.Bijective unitsHom := by
  rw [Fintype.bijective_iff_injective_and_card]
  refine ⟨fun t s h => ?_, by rw [ZMod.card_units_eq_totient]; decide⟩
  have hval : basisMap t.toAdd = basisMap s.toAdd := by
    rw [← val_eMap, ← val_eMap]
    exact congrArg Units.val h
  exact Multiplicative.toAdd.injective (basisMap_injective hval)

/-- **Structure of the unit group**: `(ZMod 56)ˣ ≅ C₆ × C₂ × C₂`, with the factors
generated by `3`, `13` and `-1`. -/
noncomputable def unitsEquiv : Multiplicative (ZMod 6 × ZMod 2 × ZMod 2) ≃* (ZMod 56)ˣ :=
  MulEquiv.ofBijective unitsHom unitsHom_bijective

/-- Forgetting the `±` factor. -/
def projHom : Multiplicative (ZMod 6 × ZMod 2 × ZMod 2) →* Multiplicative (ZMod 6 × ZMod 2) where
  toFun t := Multiplicative.ofAdd (t.toAdd.1, t.toAdd.2.1)
  map_one' := rfl
  map_mul' _ _ := rfl

/-- The projection `(ZMod 56)ˣ → C₆ × C₂` whose kernel is `{±1}`. -/
noncomputable def chi : (ZMod 56)ˣ →* Multiplicative (ZMod 6 × ZMod 2) :=
  projHom.comp unitsEquiv.symm.toMonoidHom

theorem chi_surjective : Function.Surjective chi := by
  intro y
  refine ⟨unitsEquiv (Multiplicative.ofAdd (y.toAdd.1, y.toAdd.2, 0)), ?_⟩
  simp [chi, projHom]

theorem unitsEquiv_neg_one :
    unitsEquiv (Multiplicative.ofAdd ((0 : ZMod 6), (0 : ZMod 2), (1 : ZMod 2))) = -1 := by
  apply Units.ext
  show ((eMap (0, 0, 1) : (ZMod 56)ˣ) : ZMod 56) = _
  rw [val_eMap]
  decide

theorem chi_ker : chi.ker = Subgroup.zpowers (-1 : (ZMod 56)ˣ) := by
  have hcases : ∀ z : ZMod 2, z = 0 ∨ z = 1 := by decide
  apply le_antisymm
  · intro u hu
    rw [MonoidHom.mem_ker, chi, MonoidHom.comp_apply] at hu
    set t := unitsEquiv.symm u with ht
    have h1 : t.toAdd.1 = 0 ∧ t.toAdd.2.1 = 0 := by
      have h := congrArg Multiplicative.toAdd hu
      simpa [projHom, Prod.ext_iff] using h
    have hu' : u = unitsEquiv (Multiplicative.ofAdd (0, 0, t.toAdd.2.2)) := by
      have h2 : Multiplicative.ofAdd ((0 : ZMod 6), (0 : ZMod 2), t.toAdd.2.2) = t := by
        apply Multiplicative.toAdd.injective
        simp [Prod.ext_iff, h1.1, h1.2]
      rw [h2, ht, MulEquiv.apply_symm_apply]
    rcases hcases t.toAdd.2.2 with h | h
    · rw [hu', h]
      have h3 : unitsEquiv (Multiplicative.ofAdd ((0 : ZMod 6), (0 : ZMod 2), (0 : ZMod 2))) = 1 := by
        simp [show Multiplicative.ofAdd ((0 : ZMod 6), (0 : ZMod 2), (0 : ZMod 2)) = 1 from rfl]
      rw [h3]
      exact Subgroup.one_mem _
    · rw [hu', h, unitsEquiv_neg_one]
      exact Subgroup.mem_zpowers _
  · rw [Subgroup.zpowers_le, MonoidHom.mem_ker, ← unitsEquiv_neg_one]
    show projHom (unitsEquiv.symm (unitsEquiv _)) = 1
    rw [MulEquiv.symm_apply_apply]
    rfl

/-- **`G⁺ = (ZMod 56)ˣ / {±1} ≅ C₆ × C₂`.** -/
noncomputable def GplusEquiv :
    ((ZMod 56)ˣ ⧸ Subgroup.zpowers (-1 : (ZMod 56)ˣ)) ≃* Multiplicative (ZMod 6 × ZMod 2) :=
  (QuotientGroup.quotientMulEquivOfEq chi_ker.symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective chi chi_surjective)

/-! ## The Galois group of the real field -/

/-- Galois correspondence: `Gal(Q(ζ₅₆)⁺/Q) ≅ (ZMod 56)ˣ / {±1}`. -/
noncomputable def galRealEquiv :
    (RealCyclo56 ≃ₐ[ℚ] RealCyclo56) ≃* ((ZMod 56)ˣ ⧸ Subgroup.zpowers (-1 : (ZMod 56)ˣ)) := by
  haveI : FiniteDimensional ℚ L56 := IsCyclotomicExtension.finiteDimensional {56} ℚ L56
  haveI : IsGalois ℚ L56 := IsCyclotomicExtension.isGalois {56} ℚ L56
  exact (IsGalois.normalAutEquivQuotient (K := ℚ) (L := L56) (Subgroup.zpowers conj56)).symm.trans
    (QuotientGroup.congr (Subgroup.zpowers conj56) (Subgroup.zpowers (-1 : (ZMod 56)ˣ)) galEquiv
      (by rw [MonoidHom.map_zpowers]; congr 1; exact galEquiv.apply_symm_apply (-1)))

/-- **The main structural theorem of this rung**:
`Gal(Q(ζ₅₆)⁺ / Q) ≅ C₆ × C₂`. -/
noncomputable def galRealGroupEquiv :
    (RealCyclo56 ≃ₐ[ℚ] RealCyclo56) ≃* Multiplicative (ZMod 6 × ZMod 2) :=
  galRealEquiv.trans GplusEquiv

/-- **`Gal(Q(ζ₅₆)⁺/Q) ≅ C₆ × C₂`**, stated as an isomorphism claim. -/
theorem gal_real_isomorphic_C6xC2 :
    Nonempty ((RealCyclo56 ≃ₐ[ℚ] RealCyclo56) ≃* Multiplicative (ZMod 6 × ZMod 2)) :=
  ⟨galRealGroupEquiv⟩

/-- The Galois group has order 12. -/
theorem card_galReal : Nat.card (RealCyclo56 ≃ₐ[ℚ] RealCyclo56) = 12 := by
  rw [Nat.card_congr galRealGroupEquiv.toEquiv]
  exact card_Gplus

/-- **Non-cyclicity.**  `Gal(Q(ζ₅₆)⁺/Q)` is an abelian group of order 12 which is not
cyclic — the first composite-order, non-cyclic rung. -/
theorem not_isCyclic_galReal : ¬ IsCyclic (RealCyclo56 ≃ₐ[ℚ] RealCyclo56) := by
  intro h
  have h2 : IsCyclic (Multiplicative (ZMod 6 × ZMod 2)) :=
    isCyclic_of_surjective galRealGroupEquiv galRealGroupEquiv.surjective
  exact not_isAddCyclic (isCyclic_multiplicative_iff.1 h2)

end Catalog.Pythagorean.Degree12Composite