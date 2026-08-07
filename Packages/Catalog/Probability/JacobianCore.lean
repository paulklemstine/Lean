import Mathlib

/-!
# Core infrastructure for the Jacobian Conjecture

The three Jacobian-Conjecture files in `Catalog/Probability/` (`DegreeTwo.lean`,
`Druzkowski.lean`, `Counterexamples.lean`) were written against a core module
providing the polynomial Jacobian, polynomial composition, polynomial
automorphisms and the induced map on algebras.  That module was missing from the
catalog (the file `Novelty/Core.lean` that they imported contains an unrelated
development about agreement subtrees).  This file supplies it.

## Main definitions

* `polyJacobian F` — the matrix `(∂Fᵢ/∂Xⱼ)` of a polynomial map.
* `jacDet F` — its determinant.
* `pcomp F G` — the composite polynomial map `F ∘ G`, i.e. `i ↦ F i (G)`.
* `IsPolyAut F G` — `F` and `G` are mutually inverse polynomial maps.
* `induced F` — the map on points of an arbitrary `R`-algebra defined by `F`.

## Main results

* `IsPolyAut.bijective_induced` — a polynomial automorphism induces a bijection
  on the points of every `R`-algebra.  This is the bridge that turns a formal
  polynomial identity into the geometric statement of the conjecture.
-/

open MvPolynomial

namespace JacobianConjecture

variable {n : ℕ} {R : Type*} [CommRing R]

/-- The Jacobian matrix `(∂Fᵢ/∂Xⱼ)` of a polynomial map. -/
noncomputable def polyJacobian (F : Fin n → MvPolynomial (Fin n) R) :
    Matrix (Fin n) (Fin n) (MvPolynomial (Fin n) R) :=
  Matrix.of fun i j => pderiv j (F i)

/-- The Jacobian determinant of a polynomial map. -/
noncomputable def jacDet (F : Fin n → MvPolynomial (Fin n) R) : MvPolynomial (Fin n) R :=
  (polyJacobian F).det

/-- Composition of polynomial maps: `pcomp F G` substitutes `G` into `F`. -/
noncomputable def pcomp (F G : Fin n → MvPolynomial (Fin n) R) :
    Fin n → MvPolynomial (Fin n) R :=
  fun i => aeval G (F i)

/-- `F` and `G` are mutually inverse polynomial maps. -/
structure IsPolyAut (F G : Fin n → MvPolynomial (Fin n) R) : Prop where
  comp_left : pcomp F G = X
  comp_right : pcomp G F = X

/-- The map on `A`-points induced by a polynomial map, for any `R`-algebra `A`. -/
noncomputable def induced (F : Fin n → MvPolynomial (Fin n) R)
    {A : Type*} [CommRing A] [Algebra R A] : (Fin n → A) → (Fin n → A) :=
  fun x i => aeval x (F i)

/-- Substituting a polynomial map and then evaluating is evaluation at the
substituted point. -/
theorem aeval_pcomp (F G : Fin n → MvPolynomial (Fin n) R)
    {A : Type*} [CommRing A] [Algebra R A] (x : Fin n → A) (i : Fin n) :
    aeval x (pcomp F G i) = aeval (fun j => aeval x (G j)) (F i) := by
  simp only [pcomp]
  rw [← MvPolynomial.comp_aeval (φ := (aeval x : MvPolynomial (Fin n) R →ₐ[R] A))]
  rfl

/-- `induced` turns composition of polynomial maps into composition of functions. -/
theorem induced_pcomp (F G : Fin n → MvPolynomial (Fin n) R)
    {A : Type*} [CommRing A] [Algebra R A] (x : Fin n → A) :
    induced (pcomp F G) x = induced F (induced G x) := by
  funext i
  simpa [induced] using aeval_pcomp F G x i

@[simp] theorem induced_X {A : Type*} [CommRing A] [Algebra R A] (x : Fin n → A) :
    induced (X : Fin n → MvPolynomial (Fin n) R) x = x := by
  funext i
  simp [induced]

/-- **Bridge theorem.**  A polynomial automorphism induces a bijection on the
points of every `R`-algebra. -/
theorem IsPolyAut.bijective_induced {F G : Fin n → MvPolynomial (Fin n) R}
    (h : IsPolyAut F G) (A : Type*) [CommRing A] [Algebra R A] :
    Function.Bijective (induced F (A := A)) := by
  have hFG : ∀ x : Fin n → A, induced F (induced G x) = x := by
    intro x
    rw [← induced_pcomp, h.comp_left, induced_X]
  have hGF : ∀ x : Fin n → A, induced G (induced F x) = x := by
    intro x
    rw [← induced_pcomp, h.comp_right, induced_X]
  exact ⟨fun a b hab => by rw [← hGF a, ← hGF b, hab], fun y => ⟨induced G y, hFG y⟩⟩

/-- The symmetric statement: `G` is an automorphism whenever `F` is. -/
theorem IsPolyAut.symm {F G : Fin n → MvPolynomial (Fin n) R} (h : IsPolyAut F G) :
    IsPolyAut G F :=
  ⟨h.comp_right, h.comp_left⟩

end JacobianConjecture