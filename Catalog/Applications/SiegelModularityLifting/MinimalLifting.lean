import Mathlib
import Bridges.RingTheoryBridge

/-!
# Algebraic core of minimal ordinary modularity lifting

This chapter isolates the commutative-algebra mechanism underlying a minimal
modularity lifting theorem for genus-two ordinary systems.  The arithmetic
input of such a theorem is an identification of a universal deformation ring
with a Hecke algebra.  Once that identification is available, deformation
points and eigensystems are transported uniquely, finite freeness over the
weight algebra passes from one side to the other, and residual specialization
at a maximal weight ideal has no zero divisors.

The formulation deliberately separates these formal consequences from the
deep arithmetic work needed to establish the ring identification for stable
Yoshida residual representations.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): an `R = T` identification should simultaneously imply
three statements that are often presented separately: modularity of every
minimal ordinary deformation point, transfer of finite freeness over weight
space, and uniqueness of the corresponding ordinary family.

Experiment (Experimenter): deformation points were represented by algebra maps
out of `R`, eigensystems by algebra maps out of `T`, and the identification by
an algebra equivalence.  Precomposition with the equivalence and its inverse
produces mutually inverse correspondences.  Surjectivity of the structural map
also gives a second, presentation-independent uniqueness principle.

Analysis (Analyst): the common mechanism is effective descent along an
isomorphism (or, for uniqueness alone, along a surjection).  Freeness is not a
separate numerical accident: it is invariant under the underlying linear
equivalence.  Maximal specialization connects this deformation picture to the
geometry of weight space through the field structure of the residue ring.

Critique (Critic): none of the results asserts the arithmetic `R = T` input
without hypotheses.  In particular, the stable Yoshida, local ordinarity,
minimal ramification, and regular-weight arguments remain outside this
algebraic reduction.  The uniqueness theorem requires surjectivity; dropping
it permits two eigensystems to agree on the image while differing elsewhere.

Synthesis (Principal Investigator): one coherent transport theorem now packages
modularity, uniqueness, freeness, and residual integrality, making explicit
which conclusions are formal and which require arithmetic input.
-/

namespace SiegelMinimalLifting

universe u v w x

variable (Λ : Type u) (R : Type v) (T : Type w)
variable [CommRing Λ] [CommRing R] [CommRing T]
variable [Algebra Λ R] [Algebra Λ T]

/-- The algebraic output of an ordinary minimal `R = T` theorem: an
identification of the universal deformation ring `R` with the ordinary Hecke
algebra `T` over the weight algebra `Λ`. -/
structure RTDatum where
  comparison : R ≃ₐ[Λ] T

variable {Λ R T}

/-- A deformation point determines an eigensystem by transport across `R = T`. -/
noncomputable def deformationToEigenpacket (D : RTDatum Λ R T)
    {A : Type x} [CommRing A] [Algebra Λ A] (ρ : R →ₐ[Λ] A) : T →ₐ[Λ] A :=
  ρ.comp D.comparison.symm.toAlgHom

/-- An eigensystem determines a deformation point by transport across `R = T`. -/
noncomputable def eigenpacketToDeformation (D : RTDatum Λ R T)
    {A : Type x} [CommRing A] [Algebra Λ A] (φ : T →ₐ[Λ] A) : R →ₐ[Λ] A :=
  φ.comp D.comparison.toAlgHom

/-
The two transports are inverse on deformation points.
-/
theorem eigenpacket_deformation_inverse (D : RTDatum Λ R T)
    {A : Type x} [CommRing A] [Algebra Λ A] (ρ : R →ₐ[Λ] A) :
    eigenpacketToDeformation D (deformationToEigenpacket D ρ) = ρ := by
  ext x; exact (by
  convert congr_arg _ ( D.comparison.left_inv x ) using 1);

/-
The two transports are inverse on eigensystems.
-/
theorem deformation_eigenpacket_inverse (D : RTDatum Λ R T)
    {A : Type x} [CommRing A] [Algebra Λ A] (φ : T →ₐ[Λ] A) :
    deformationToEigenpacket D (eigenpacketToDeformation D φ) = φ := by
  ext t; exact (by
  convert congr_arg φ ( D.comparison.right_inv t ) using 1);

/-
**Abstract minimal modularity lifting theorem.** Every coefficient-valued
minimal ordinary deformation point arises from exactly one Hecke eigensystem.
This is the universal mapping consequence of `R = T`.
-/
theorem existsUnique_eigenpacket_of_deformation (D : RTDatum Λ R T)
    {A : Type x} [CommRing A] [Algebra Λ A] (ρ : R →ₐ[Λ] A) :
    ∃! φ : T →ₐ[Λ] A, eigenpacketToDeformation D φ = ρ := by
  refine' ⟨ deformationToEigenpacket D ρ, _, _ ⟩;
  · exact eigenpacket_deformation_inverse D ρ
  · unfold eigenpacketToDeformation deformationToEigenpacket;
    aesop

/-
Finite freeness of the Hecke algebra over weight space transfers to the
universal deformation ring through `R = T`.
-/
theorem deformationRing_free_of_hecke_free (D : RTDatum Λ R T)
    [Module.Free Λ T] : Module.Free Λ R := by
  -- Since D.comparison.symm is a linear equivalence, it preserves the free module structure. Therefore, if T is free, then R must also be free.
  have h_free : Module.Free Λ R := by
    have h_equiv : T ≃ₗ[Λ] R := D.comparison.symm.toLinearEquiv
    exact Module.Free.of_equiv h_equiv;
  exact h_free

/-
Conversely, freeness of the universal deformation ring transfers to the
Hecke algebra.
-/
theorem hecke_free_of_deformationRing_free (D : RTDatum Λ R T)
    [Module.Free Λ R] : Module.Free Λ T := by
  -- Apply the fact that if there's an isomorphism between two modules and one is free, then the other is free.
  apply Module.Free.of_equiv (D.comparison.toLinearEquiv)

/-
Two families agreeing on a surjective deformation-to-Hecke presentation are
identical.  This isolates the uniqueness step even before replacing the
surjection by an isomorphism.
-/
theorem eigenpacket_ext_of_surjective
    (q : R →ₐ[Λ] T) (hq : Function.Surjective q)
    {A : Type x} [CommRing A] [Algebra Λ A]
    (φ ψ : T →ₐ[Λ] A) (h : φ.comp q = ψ.comp q) : φ = ψ := by
  exact (AlgHom.cancel_right hq).mp h

/-- At a maximal ideal of the weight algebra, the residual weight ring is an
integral domain.  This links ordinary specialization to the standard
maximal-ideal/field correspondence. -/
theorem residualWeightRing_isDomain (m : Ideal Λ) [m.IsMaximal] :
    IsDomain (Λ ⧸ m) := by
  letI : Field (Λ ⧸ m) := RingTheoryBridge.quotient_field_of_maximal m
  exact RingTheoryBridge.field_imp_domain (Λ ⧸ m)

end SiegelMinimalLifting