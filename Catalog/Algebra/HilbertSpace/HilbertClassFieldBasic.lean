/-
  # Hilbert Class Field Infrastructure: From Ideal Class Groups to Galois Theory

  This file establishes the foundational algebraic infrastructure connecting
  ideal class groups to principality of ideals and to Galois groups of
  unramified abelian extensions, forming the formal gateway to Hilbert's
  12th problem and class field theory.

  ## Part I: Ideal Class Group Bridge

  * `subsingleton_classGroup_iff_isPrincipalIdealRing`: The class group of a Dedekind
    domain is trivial iff the ring is a PID.
  * `classGroup_trivial_iff_all_nonzero_ideals_principal`: Pointwise principality
    characterization.
  * `classGroup_trivial_of_all_principal` / `all_nonzero_ideals_principal_of_classGroup_trivial`:
    The two directions separately.
  * `classNumber_one_iff_pid`: Fintype.card version.

  ## Part II: Axiomatic Hilbert Class Field

  * `IsHilbertClassField`: Axiomatic structure for the Hilbert class field.
  * `IsHilbertClassField.natCard_galGroup_eq_natCard_classGroup`: [H:K] = h_K.
  * `IsHilbertClassField.galGroup_equiv`: Uniqueness of Galois group up to isomorphism.
  * `classGroup_character_to_galois_character`: Characters transfer via Artin isomorphism.

  ## Mathematical Context

  Hilbert's 12th problem asks for explicit generators of abelian extensions of
  number fields, generalizing Kronecker–Weber. The Hilbert class field H/K is
  characterized by Gal(H/K) ≅ Cl(K), and this file formalizes the algebraic
  infrastructure making this characterization precise.
-/

import Mathlib

open scoped nonZeroDivisors
open NumberField

noncomputable section

/-! ## Part I: Ideal Class Group Bridge -/

/-- The class group of a Dedekind domain is a subsingleton (trivial) if and only if
the ring is a principal ideal domain. This strengthens `card_classGroup_eq_one_iff`
by removing the `Fintype` hypothesis and using `Subsingleton` instead of cardinality. -/
theorem subsingleton_classGroup_iff_isPrincipalIdealRing
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R] :
    Subsingleton (ClassGroup R) ↔ IsPrincipalIdealRing R := by
  refine ⟨fun h ↦ ?_, fun h ↦ ?_⟩
  · exact ⟨fun I => by
      rcases eq_or_ne I ⊥ with (rfl | hI)
      · infer_instance
      · have := @ClassGroup.mk0_eq_one_iff R
        exact this (by simpa [Submodule.ne_bot_iff] using hI) |>.1 (Subsingleton.elim _ _)⟩
  · exact ⟨fun a b => Subsingleton.elim _ _⟩

/-- If every nonzero ideal of a Dedekind domain is principal, then the class group
is trivial. -/
theorem classGroup_trivial_of_all_principal
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R]
    (h : ∀ I : Ideal R, I ≠ ⊥ → Submodule.IsPrincipal I) :
    Subsingleton (ClassGroup R) := by
  have h_pid : IsPrincipalIdealRing R :=
    IsPrincipalIdealRing.of_prime_ne_bot fun P _ => h P
  exact (subsingleton_classGroup_iff_isPrincipalIdealRing R).mpr h_pid

/-- If the class group of a Dedekind domain is trivial, then every nonzero ideal
is principal. -/
theorem all_nonzero_ideals_principal_of_classGroup_trivial
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R]
    [Subsingleton (ClassGroup R)] :
    ∀ I : Ideal R, I ≠ ⊥ → Submodule.IsPrincipal I := by
  intro I hI_ne_bot
  have : ClassGroup.mk0 ⟨I, mem_nonZeroDivisors_iff_ne_zero.mpr hI_ne_bot⟩ = 1 :=
    Subsingleton.elim _ _
  exact (ClassGroup.mk0_eq_one_iff (mem_nonZeroDivisors_iff_ne_zero.mpr hI_ne_bot)).mp this

/-- The class group of a Dedekind domain is trivial if and only if every nonzero
ideal is principal. This is the ideal-theoretic shadow of class field theory. -/
theorem classGroup_trivial_iff_all_nonzero_ideals_principal
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R] :
    Subsingleton (ClassGroup R) ↔ ∀ I : Ideal R, I ≠ ⊥ → Submodule.IsPrincipal I := by
  constructor
  · exact fun _ I hI => all_nonzero_ideals_principal_of_classGroup_trivial R I hI
  · exact fun h => classGroup_trivial_of_all_principal R h

/-- For a Dedekind domain with finite class group, class number one is equivalent to
being a principal ideal domain. -/
theorem classNumber_one_iff_pid
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R]
    [Fintype (ClassGroup R)] :
    Fintype.card (ClassGroup R) = 1 ↔ IsPrincipalIdealRing R :=
  card_classGroup_eq_one_iff

/-! ## Part II: Axiomatic Hilbert Class Field Structure -/

/-- A structure axiomatizing the Hilbert class field. An extension L/K is a Hilbert
class field if it is finite, Galois, abelian (commutative Galois group), and the
Galois group is isomorphic to the class group of K's ring of integers. -/
structure IsHilbertClassField
    (K L : Type*) [Field K] [Field L] [NumberField K] [NumberField L]
    [Algebra K L] : Prop where
  /-- The extension L/K is finite-dimensional -/
  finiteDimensional : FiniteDimensional K L
  /-- The extension L/K is Galois -/
  isGalois : IsGalois K L
  /-- The Galois group Gal(L/K) is commutative -/
  galGroupComm : ∀ (σ τ : L ≃ₐ[K] L), σ.trans τ = τ.trans σ
  /-- There exists a group isomorphism between Cl(K) and Gal(L/K) -/
  artinIso : Nonempty (ClassGroup (𝓞 K) ≃* (L ≃ₐ[K] L))

/-- The cardinality of the Galois group of a Hilbert class field equals the
cardinality of the class group: |Gal(H/K)| = |Cl(K)| = h_K. -/
theorem IsHilbertClassField.natCard_galGroup_eq_natCard_classGroup
    {K L : Type*} [Field K] [Field L] [NumberField K] [NumberField L]
    [Algebra K L] (hHCF : IsHilbertClassField K L) :
    Nat.card (L ≃ₐ[K] L) = Nat.card (ClassGroup (𝓞 K)) := by
  have h := hHCF.artinIso
  obtain ⟨e⟩ := h
  exact (Nat.card_congr e.toEquiv).symm

/-- When the class group is trivial, the Galois group of any Hilbert class field
has cardinality 1. -/
theorem IsHilbertClassField.natCard_galGroup_eq_one_of_classGroup_subsingleton
    {K L : Type*} [Field K] [Field L] [NumberField K] [NumberField L]
    [Algebra K L] (hHCF : IsHilbertClassField K L)
    [Subsingleton (ClassGroup (𝓞 K))] :
    Nat.card (L ≃ₐ[K] L) = 1 := by
  rw [hHCF.natCard_galGroup_eq_natCard_classGroup]
  exact Nat.card_unique

/-- Two Hilbert class fields of the same number field have isomorphic Galois
groups, since both are isomorphic to Cl(K). -/
theorem IsHilbertClassField.galGroup_equiv
    {K L : Type*} [Field K] [Field L] [NumberField K] [NumberField L]
    [Algebra K L] (hHCF : IsHilbertClassField K L)
    {L' : Type*} [Field L'] [NumberField L'] [Algebra K L']
    (hHCF' : IsHilbertClassField K L') :
    Nonempty ((L ≃ₐ[K] L) ≃* (L' ≃ₐ[K] L')) := by
  have h1 := hHCF.artinIso
  have h2 := hHCF'.artinIso
  obtain ⟨e1⟩ := h1
  obtain ⟨e2⟩ := h2
  exact ⟨e1.symm.trans e2⟩

/-- If K has trivial class group and L/K is a Hilbert class field, then
every nonzero ideal of 𝓞 K is already principal. -/
theorem IsHilbertClassField.all_ideals_principal_of_trivial_classGroup
    {K L : Type*} [Field K] [Field L] [NumberField K] [NumberField L]
    [Algebra K L] (_hHCF : IsHilbertClassField K L)
    [Subsingleton (ClassGroup (𝓞 K))] :
    ∀ I : Ideal (𝓞 K), I ≠ ⊥ → Submodule.IsPrincipal I :=
  all_nonzero_ideals_principal_of_classGroup_trivial (𝓞 K)

/-! ## Part III: Class Group Characters and Galois Characters -/

/-- Given a Hilbert class field structure, every character of the class group
induces a character of the Galois group via the Artin isomorphism. This is
the abelian case of the Langlands correspondence: unramified Hecke characters
correspond to 1-dimensional Galois representations. -/
def classGroup_character_to_galois_character
    {K L : Type*} [Field K] [Field L] [NumberField K] [NumberField L]
    [Algebra K L] (hHCF : IsHilbertClassField K L)
    (χ : ClassGroup (𝓞 K) →* ℂˣ) : (L ≃ₐ[K] L) →* ℂˣ :=
  χ.comp (Classical.choice hHCF.artinIso).symm.toMonoidHom

end