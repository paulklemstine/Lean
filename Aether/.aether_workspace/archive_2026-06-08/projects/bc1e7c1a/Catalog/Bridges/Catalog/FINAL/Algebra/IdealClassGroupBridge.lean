/-
  # Ideal Class Group Bridge: From Class Groups to Hilbert Class Field Theory

  This file establishes the foundational algebraic infrastructure connecting
  ideal class groups to the principality of ideals in Dedekind domains,
  forming the algebraic kernel from which Hilbert class field theory grows.

  ## Main Results

  * `subsingleton_classGroup_iff_isPrincipalIdealRing`: The class group of a Dedekind
    domain is trivial if and only if the ring is a principal ideal domain.

  * `classGroup_trivial_iff_all_nonzero_ideals_principal`: The class group is trivial
    if and only if every nonzero ideal is principal — the pointwise characterization.

  * `classGroup_trivial_of_all_principal`: If every nonzero ideal is principal,
    then the class group is trivial.

  * `all_nonzero_ideals_principal_of_classGroup_trivial`: Conversely, if the class
    group is trivial, every nonzero ideal is principal.

  * `classNumber_one_iff_pid`: For a Dedekind domain with finite class group,
    the class number equals one if and only if the ring is a PID.

  These results form the algebraic foundation for Hilbert class field theory:
  the Hilbert class field H/K is characterized by the property that every ideal
  class of K becomes principal in H, so Gal(H/K) ≅ Cl(K). The triviality
  characterization is the "base case" of this correspondence.

  ## Mathematical Context

  Hilbert's 12th problem asks for explicit generators of abelian extensions of
  number fields, generalizing Kronecker–Weber (which handles ℚ via roots of unity).
  The first invariant is the Hilbert class field, characterized by:
  1. H/K is finite abelian
  2. H/K is unramified at all finite places
  3. Every ideal class of K becomes principal in H
  4. Gal(H/K) ≅ Cl(K) canonically

  This file formalizes the algebra making property (3) precise and connects it
  to the class group quotient, creating the formal gateway for future work on
  Artin reciprocity, ray class fields, and eventually the Langlands program.
-/

import Mathlib

open scoped nonZeroDivisors

/-! ## Subsingleton characterization of the class group -/

/-- The class group of a Dedekind domain is a subsingleton (trivial) if and only if
the ring is a principal ideal domain. This is the fundamental bridge between
the abstract quotient structure and concrete ideal generation.

This strengthens `card_classGroup_eq_one_iff` by removing the `Fintype` hypothesis
and using `Subsingleton` instead of cardinality. -/
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
is trivial. This is one direction of the fundamental characterization. -/
theorem classGroup_trivial_of_all_principal
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R]
    (h : ∀ I : Ideal R, I ≠ ⊥ → Submodule.IsPrincipal I) :
    Subsingleton (ClassGroup R) := by
  have h_pid : IsPrincipalIdealRing R :=
    IsPrincipalIdealRing.of_prime_ne_bot fun P _ => h P
  exact (subsingleton_classGroup_iff_isPrincipalIdealRing R).mpr h_pid

/-- If the class group of a Dedekind domain is trivial, then every nonzero ideal
is principal. This converts abstract class group data into ideal generation. -/
theorem all_nonzero_ideals_principal_of_classGroup_trivial
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R]
    [Subsingleton (ClassGroup R)] :
    ∀ I : Ideal R, I ≠ ⊥ → Submodule.IsPrincipal I := by
  intro I hI_ne_bot
  have : ClassGroup.mk0 ⟨I, mem_nonZeroDivisors_iff_ne_zero.mpr hI_ne_bot⟩ = 1 :=
    Subsingleton.elim _ _
  exact (ClassGroup.mk0_eq_one_iff (mem_nonZeroDivisors_iff_ne_zero.mpr hI_ne_bot)).mp this

/-- The class group of a Dedekind domain is trivial if and only if every nonzero
ideal is principal. This is the pointwise characterization that converts between
the abstract quotient and concrete ideal arithmetic.

This theorem is the ideal-theoretic shadow of class field theory: when the class
group is trivial, there are no nontrivial unramified abelian extensions, and
conversely. -/
theorem classGroup_trivial_iff_all_nonzero_ideals_principal
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R] :
    Subsingleton (ClassGroup R) ↔ ∀ I : Ideal R, I ≠ ⊥ → Submodule.IsPrincipal I := by
  constructor
  · exact fun _ I hI => all_nonzero_ideals_principal_of_classGroup_trivial R I hI
  · exact fun h => classGroup_trivial_of_all_principal R h

/-- For a Dedekind domain with finite class group, class number one is equivalent to
being a principal ideal domain. This specializes the subsingleton characterization
to the computable setting. -/
theorem classNumber_one_iff_pid
    (R : Type*) [CommRing R] [IsDomain R] [IsDedekindDomain R]
    [Fintype (ClassGroup R)] :
    Fintype.card (ClassGroup R) = 1 ↔ IsPrincipalIdealRing R :=
  card_classGroup_eq_one_iff