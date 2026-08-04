/-
Axiomatics of the Hilbert class field, and the unconditional cases.

Direction 1 of the research thread asks for a construction, for *every* number field `K`,
of a finite Galois extension `H/K` unramified at every finite prime together with an Artin
isomorphism `Gal(H/K) ≃* Cl(𝒪_K)`.  This file isolates that request as a bundled datum
`IsHilbertClassField K H` and proves what such a datum forces:

* its degree is the class number (`IsHilbertClassField.finrank_eq_classNumber`);
* its Galois group is abelian (`IsHilbertClassField.mul_comm`);
* it is trivial precisely when the class number is `1`
  (`IsHilbertClassField.bijective_algebraMap_iff`);
* two Hilbert class fields of the same base have the same degree
  (`IsHilbertClassField.finrank_eq_finrank`);
* the principal-ideal-ring case is realised by `H = K` (`IsHilbertClassField.self`), in
  particular over `ℚ` (`ratIsHilbertClassField`).

The arithmetic input is `NumberField.finrank_eq_one_of_isUnramifiedAt`, a Hermite–Minkowski
statement: **`ℚ` has no nontrivial everywhere-unramified extension**.  Consequently every
Hilbert class field datum over `ℚ` is trivial (`IsHilbertClassField.rat_finrank_eq_one`),
which is exactly the falsifiability test proposed in direction 1, passed over `ℚ`.
-/
import Mathlib

namespace Catalog.Pythagorean.HilbertClassField

open NumberField

section Minkowski

variable (K : Type*) [Field K] [NumberField K]

/-- If every prime of `𝒪_K` is unramified over `ℤ`, the different ideal is the unit ideal. -/
theorem differentIdeal_eq_top_of_isUnramifiedAt
    (h : ∀ (P : Ideal (𝓞 K)) (_ : P.IsPrime), Algebra.IsUnramifiedAt ℤ P) :
    differentIdeal ℤ (𝓞 K) = ⊤ := by
  by_contra hne
  obtain ⟨P, hPmax, hP⟩ := Ideal.ne_top_iff_exists_maximal.mp hne
  have hPprime : P.IsPrime := hPmax.isPrime
  have hdvd : P ∣ differentIdeal ℤ (𝓞 K) := Ideal.dvd_iff_le.mpr hP
  rw [dvd_differentIdeal_iff] at hdvd
  exact hdvd (h P hPprime)

/-- An everywhere-unramified number field has discriminant `±1`. -/
theorem natAbs_discr_eq_one_of_isUnramifiedAt
    (h : ∀ (P : Ideal (𝓞 K)) (_ : P.IsPrime), Algebra.IsUnramifiedAt ℤ P) :
    (discr K).natAbs = 1 := by
  rw [← NumberField.absNorm_differentIdeal K (𝓞 K),
    differentIdeal_eq_top_of_isUnramifiedAt K h, Ideal.absNorm_top]

/-- **Hermite–Minkowski.**  A number field unramified at every finite prime over `ℤ` is `ℚ`. -/
theorem finrank_eq_one_of_isUnramifiedAt
    (h : ∀ (P : Ideal (𝓞 K)) (_ : P.IsPrime), Algebra.IsUnramifiedAt ℤ P) :
    Module.finrank ℚ K = 1 := by
  by_contra hne
  have h2 : 1 < Module.finrank ℚ K := lt_of_le_of_ne Module.finrank_pos (Ne.symm hne)
  have h3 := NumberField.abs_discr_gt_two h2
  rw [Int.abs_eq_natAbs, natAbs_discr_eq_one_of_isUnramifiedAt K h] at h3
  norm_num at h3

end Minkowski

/-- A **Hilbert class field datum** for a number field `K`: a finite Galois extension `H/K`,
unramified at every finite prime of `H`, together with an Artin reciprocity isomorphism
`Gal(H/K) ≃* Cl(𝒪_K)`. -/
structure IsHilbertClassField (K H : Type*) [Field K] [NumberField K] [Field H] [NumberField H]
    [Algebra K H] where
  /-- `H/K` is a finite extension. -/
  finiteDimensional : FiniteDimensional K H
  /-- `H/K` is Galois. -/
  galois : IsGalois K H
  /-- `H/K` is unramified at every finite prime. -/
  unramified : ∀ (Q : Ideal (𝓞 H)) (_ : Q.IsPrime), Algebra.IsUnramifiedAt (𝓞 K) Q
  /-- Artin reciprocity: the Galois group is the ideal class group. -/
  artin : (H ≃ₐ[K] H) ≃* ClassGroup (𝓞 K)

namespace IsHilbertClassField

variable {K H : Type*} [Field K] [NumberField K] [Field H] [NumberField H] [Algebra K H]

/-- The degree of a Hilbert class field is the class number. -/
theorem finrank_eq_classNumber (h : IsHilbertClassField K H) :
    Module.finrank K H = classNumber K := by
  haveI := h.galois
  have h1 : Nat.card (H ≃ₐ[K] H) = Module.finrank K H := IsGalois.card_aut_eq_finrank K H
  have h2 : Nat.card (H ≃ₐ[K] H) = Nat.card (ClassGroup (𝓞 K)) := Nat.card_congr h.artin.toEquiv
  have h3 : Nat.card (ClassGroup (𝓞 K)) = classNumber K := by rw [Nat.card_eq_fintype_card]; rfl
  rw [← h1, h2, h3]

/-- Any two Hilbert class fields of `K` have the same degree over `K`. -/
theorem finrank_eq_finrank {H' : Type*} [Field H'] [NumberField H'] [Algebra K H']
    (h : IsHilbertClassField K H) (h' : IsHilbertClassField K H') :
    Module.finrank K H = Module.finrank K H' :=
  (h.finrank_eq_classNumber).trans (h'.finrank_eq_classNumber).symm

/-- The Galois group of a Hilbert class field is abelian, since the class group is. -/
theorem mul_comm (h : IsHilbertClassField K H) (σ τ : H ≃ₐ[K] H) : σ * τ = τ * σ := by
  apply h.artin.injective
  rw [h.artin.map_mul, h.artin.map_mul]
  exact CommMonoid.mul_comm (h.artin σ) (h.artin τ)

/-- A Hilbert class field is trivial exactly when the class number is `1`. -/
theorem bijective_algebraMap_iff (h : IsHilbertClassField K H) :
    Function.Bijective (algebraMap K H) ↔ classNumber K = 1 := by
  rw [← h.finrank_eq_classNumber]
  have hinj : Function.Injective (algebraMap K H) := RingHom.injective _
  constructor
  · intro hbij
    let e : K ≃ₗ[K] H := LinearEquiv.ofBijective (Algebra.linearMap K H) hbij
    rw [← LinearEquiv.finrank_eq e, Module.finrank_self]
  · intro hfrob
    haveI : FiniteDimensional K H := h.finiteDimensional
    refine ⟨hinj, ?_⟩
    have hdim : Module.finrank K ↥(LinearMap.range (Algebra.linearMap K H)) = 1 := by
      rw [LinearMap.finrank_range_of_inj (RingHom.injective _)]
      exact Module.finrank_self K
    have h_eq : LinearMap.range (Algebra.linearMap K H) = ⊤ := by
      apply Submodule.eq_top_of_finrank_eq
      rw [hdim, hfrob]
    exact LinearMap.range_eq_top.mp h_eq

end IsHilbertClassField

/-- If `𝒪_K` is a principal ideal ring then `K` is its own Hilbert class field. -/
noncomputable def IsHilbertClassField.self (K : Type*) [Field K] [NumberField K]
    [IsPrincipalIdealRing (𝓞 K)] : IsHilbertClassField K K where
  finiteDimensional := inferInstance
  galois := inferInstance
  unramified := fun Q _ => Algebra.FormallyUnramified.instLocalization Q.primeCompl
  artin := by
    have h1 : Unique (K ≃ₐ[K] K) := uniqueOfSubsingleton 1
    have h2 : Unique (ClassGroup (𝓞 K)) :=
      @uniqueOfSubsingleton _ NormalizedGCDMonoid.subsingleton_classGroup 1
    exact MulEquiv.ofUnique

instance : IsPrincipalIdealRing (𝓞 ℚ) :=
  NumberField.classNumber_eq_one_iff.mp Rat.classNumber_eq

/-- `ℚ` is its own Hilbert class field. -/
noncomputable def ratIsHilbertClassField : IsHilbertClassField ℚ ℚ :=
  IsHilbertClassField.self ℚ

/-- Unramifiedness over `𝒪_ℚ` is unramifiedness over `ℤ`. -/
theorem isUnramifiedAt_int_of_isUnramifiedAt_ratRingOfIntegers
    {H : Type*} [Field H] [NumberField H] (Q : Ideal (𝓞 H)) [Q.IsPrime]
    (h : Algebra.IsUnramifiedAt (𝓞 ℚ) Q) : Algebra.IsUnramifiedAt ℤ Q := by
  have h0 : Algebra.FormallyUnramified ℤ (𝓞 ℚ) :=
    Algebra.FormallyUnramified.of_surjective (Algebra.ofId ℤ (𝓞 ℚ))
      (Rat.int_algebraMap_surjective (𝓞 ℚ))
  exact Algebra.FormallyUnramified.comp ℤ (𝓞 ℚ) (Localization.AtPrime Q)

/-- **Falsifiability test over `ℚ`.**  Every Hilbert class field datum over `ℚ` is trivial:
this is forced by Hermite–Minkowski, and is consistent with `classNumber ℚ = 1`. -/
theorem IsHilbertClassField.rat_finrank_eq_one {H : Type*} [Field H] [NumberField H]
    (h : IsHilbertClassField ℚ H) : Module.finrank ℚ H = 1 :=
  finrank_eq_one_of_isUnramifiedAt H fun P hP =>
    isUnramifiedAt_int_of_isUnramifiedAt_ratRingOfIntegers (Q := P) (h.unramified P hP)

end Catalog.Pythagorean.HilbertClassField