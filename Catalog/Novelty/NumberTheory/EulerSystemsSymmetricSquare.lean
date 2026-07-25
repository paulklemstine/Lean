import Mathlib

/-!
# Abstract algebra around Euler systems and symmetric-square functional equations

This file isolates three algebraic mechanisms occurring in work on Euler systems for
symmetric squares of Hida families:

* norm relations survive specialization when the specialization commutes with norm maps;
* an involutive algebraic functional equation transports a characteristic-element
  divisibility back to the original side;
* a deliberately bold “symmetric square is faithful” conjecture is false, with the
  precise ambiguity over an integral domain being multiplication by `-1`.

These are abstract consequences rather than a formal construction of Hida families,
Galois cohomology, Selmer groups, or the paper's non-trivial Euler-system classes.
-/

namespace HidaSymSquare

section EulerSystemSpecialization

variable {R S : Type*} [CommRing R] [CommRing S]
variable {I : Type*} {M N : I → Type*}
variable [∀ i, AddCommGroup (M i)] [∀ i, Module R (M i)]
variable [∀ i, AddCommGroup (N i)] [∀ i, Module S (N i)]

/-- A single abstract Euler-system norm relation. -/
def NormRelation (c : ∀ i, M i) (norm : ∀ i j, M j →ₗ[R] M i)
    (eulerFactor : I → I → R) (i j : I) : Prop :=
  norm i j (c j) = eulerFactor i j • c i

/-
Specialization preserves an Euler-system norm relation, provided specialization
commutes with the transition map and carries the Euler factor to its specialized value.
-/
theorem normRelation_specializes
    (algebraMap : R →+* S)
    (c : ∀ i, M i) (norm : ∀ i j, M j →ₗ[R] M i)
    (eulerFactor : I → I → R) (i j : I)
    (specialize : ∀ k, M k →+ N k)
    (normS : N j →+ N i)
    (hNorm : ∀ x, specialize i (norm i j x) = normS (specialize j x))
    (hScalar : ∀ (r : R) (x : M i),
      specialize i (r • x) = algebraMap r • specialize i x)
    (hrel : NormRelation c norm eulerFactor i j) :
    normS (specialize j (c j)) =
      algebraMap (eulerFactor i j) • specialize i (c i) := by
  rw [ ← hScalar, ← hNorm, hrel ]

/-
A nonzero specialization certifies that the original Euler-system class is nonzero.
-/
theorem nonzero_of_nonzero_specialization
    (specialize : M i →+ N i) (x : M i) (hx : specialize x ≠ 0) : x ≠ 0 := by
  aesop

/-- An abstract Euler system is a family satisfying all specified norm relations. -/
def EulerSystem (c : ∀ i, M i) (norm : ∀ i j, M j →ₗ[R] M i)
    (eulerFactor : I → I → R) : Prop :=
  ∀ i j, NormRelation c norm eulerFactor i j

/-
The entire family of norm relations specializes simultaneously.
-/
theorem eulerSystem_specializes
    (algebraMap : R →+* S)
    (c : ∀ i, M i) (norm : ∀ i j, M j →ₗ[R] M i)
    (eulerFactor : I → I → R)
    (specialize : ∀ k, M k →+ N k)
    (normS : ∀ i j, N j →+ N i)
    (hNorm : ∀ i j x, specialize i (norm i j x) = normS i j (specialize j x))
    (hScalar : ∀ i (r : R) (x : M i),
      specialize i (r • x) = algebraMap r • specialize i x)
    (hsys : EulerSystem c norm eulerFactor) :
    ∀ i j, normS i j (specialize j (c j)) =
      algebraMap (eulerFactor i j) • specialize i (c i) := by
  exact fun i j => hNorm i j ( c j ) ▸ hScalar i _ _ ▸ hsys i j ▸ rfl

/-
Non-triviality detected at any specialization implies non-triviality of the family.
-/
theorem eulerSystem_nontrivial_of_specialization
    (c : ∀ i, M i) (specialize : ∀ i, M i →+ N i)
    (h : ∃ i, specialize i (c i) ≠ 0) : ∃ i, c i ≠ 0 := by
  exact h.imp fun i hi => by contrapose! hi; simp +decide [ hi ] ;

end EulerSystemSpecialization

section FunctionalEquation

variable {A : Type*} [CommRing A]

/-
Divisibility is preserved by a ring automorphism.
-/
theorem map_dvd_map (ι : A ≃+* A) {x y : A} (h : x ∣ y) : ι x ∣ ι y := by
  exact ι.map_dvd h

/-
Divisibility can be reflected through an involutive functional equation.  In an
Iwasawa-theoretic reading, `L` is a p-adic L-function and `C` a characteristic element.
-/
theorem involutive_functional_equation_divisibility
    (ι : A ≃+* A) (hinv : ∀ x, ι (ι x) = x) {L C : A}
    (hdual : ι L ∣ ι C) : L ∣ C := by
  obtain ⟨ k, hk ⟩ := hdual;
  exact ⟨ ι k, by simpa [ hinv ] using congr_arg ι hk ⟩

/-
An involution transports divisibility in both directions.
-/
theorem involutive_divisibility_iff
    (ι : A ≃+* A) (hinv : ∀ x, ι (ι x) = x) {x y : A} :
    ι x ∣ ι y ↔ x ∣ y := by
  grind +suggestions

/-
If both characteristic and analytic elements satisfy functional equations up to
units, then a divisibility on the dual side implies the original divisibility.
-/
theorem functional_equation_up_to_units
    (ι : A ≃+* A) (hinv : ∀ x, ι (ι x) = x)
    {L C Ldual Cdual u v : A}
    (hu : IsUnit u) (hv : IsUnit v)
    (hL : Ldual = u * ι L) (hC : Cdual = v * ι C)
    (hdual : Ldual ∣ Cdual) : L ∣ C := by
  convert involutive_functional_equation_divisibility ι hinv _
  simp_all +decide

end FunctionalEquation

section ContrarianConjectures

/-- Bold conjecture (disproved below): taking a symmetric square should remember an
integer exactly. -/
def SymmetricSquareFaithful : Prop := ∀ x y : ℤ, x ^ 2 = y ^ 2 → x = y

/-
Counterexample to exact faithfulness: `1` and `-1` have the same square.
-/
theorem symmetricSquareFaithful_false : ¬ SymmetricSquareFaithful := by
  exact fun h => by have := h 1 ( -1 ) ; norm_num at this;

/-
The corrected theorem: over any integral domain, equality of symmetric-square
parameters has exactly the unavoidable sign ambiguity.
-/
theorem symmetricSquare_eq_iff_sign {D : Type*} [CommRing D] [IsDomain D]
    (x y : D) : x ^ 2 = y ^ 2 ↔ x = y ∨ x = -y := by
  rw [ sq_eq_sq_iff_eq_or_eq_neg ]

/-
Consequently symmetric square becomes faithful after quotienting by sign, expressed
here as equality of the two-element sign orbits.
-/
theorem symmetricSquare_sign_orbit {D : Type*} [CommRing D] [IsDomain D]
    {x y : D} (h : x ^ 2 = y ^ 2) : ({x, -x} : Set D) = {y, -y} := by
  grind +suggestions

end ContrarianConjectures

end HidaSymSquare