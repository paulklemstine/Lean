/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Bridges.PrimeConSpec.Basic

/-!
# Structure Sheaf on the Prime Congruence Spectrum

This file defines the sections on basic opens of the prime congruence spectrum
and the restriction maps between them, forming a presheaf on the basis of
basic opens.

## Main definitions

* `conOnBasicOpen x y`: The ring congruence obtained as the infimum of all primes in `D x y`.
* `sectionOnD x y`: The quotient type representing sections on `D x y`.
* `restrictD`: The restriction ring homomorphism between sections on nested basic opens.

## Main results

* `restrictD_id`: Restriction along the identity inclusion is the identity.
* `restrictD_comp`: Restriction is functorial (composable).
* `conOnBasicOpen_le_of_subset`: The congruence on a larger open is finer.
-/

universe u

open PrimeConSpec

variable {P : Type u} [CommSemiring P]

/-! ### Congruence on basic opens -/

/-- The ring congruence associated to a basic open `D x y`, defined as the infimum
(intersection) of all prime congruences in that open. An element of the quotient
`P / conOnBasicOpen x y` represents a "local value" well-defined on `D x y`. -/
noncomputable def conOnBasicOpen (x y : P) : RingCon P :=
  ⨅ (p : PrimeConSpec P) (_ : p ∈ basicOpen x y), p.con

/-- If `D x' y' ⊆ D x y`, then `conOnBasicOpen x y ≤ conOnBasicOpen x' y'`.
Fewer primes in the infimum means a coarser congruence. -/
theorem conOnBasicOpen_le_of_subset {x y x' y' : P}
    (h : basicOpen x' y' ⊆ basicOpen x y) :
    conOnBasicOpen x y ≤ conOnBasicOpen x' y' := by
  exact biInf_mono (fun p hp => h hp)

/-- Any prime in `D x y` refines the congruence `conOnBasicOpen x y`. -/
theorem conOnBasicOpen_le_prime {x y : P} {p : PrimeConSpec P}
    (hp : p ∈ basicOpen x y) : conOnBasicOpen x y ≤ p.con :=
  iInf_le_of_le p (iInf_le_of_le hp (le_refl _))

/-! ### Sections on basic opens -/

/-- The type of sections on the basic open `D x y`, defined as the quotient of `P`
by the congruence `conOnBasicOpen x y`. An element of `sectionOnD x y` represents
a "local proof value" that is well-defined on all primes not identifying `x` and `y`. -/
def sectionOnD (x y : P) : Type u :=
  (conOnBasicOpen x y).Quotient

noncomputable instance (x y : P) : CommSemiring (sectionOnD x y) := by
  unfold sectionOnD; infer_instance

/-- The canonical projection from `P` to sections on `D x y`. -/
noncomputable def toSectionOnD (x y : P) : P →+* sectionOnD x y :=
  (conOnBasicOpen x y).mk'

/-! ### Restriction maps -/

/-- The restriction map from sections on `D x y` to sections on `D x' y'`,
defined when `D x' y' ⊆ D x y`. This is the ring homomorphism induced by the
fact that the congruence on `D x y` refines the congruence on `D x' y'`. -/
noncomputable def restrictD {x y x' y' : P}
    (h : basicOpen x' y' ⊆ basicOpen x y) :
    sectionOnD x y →+* sectionOnD x' y' :=
  (conOnBasicOpen x y).lift (toSectionOnD x' y') (by
    intro a b hab
    change ((conOnBasicOpen x' y').toQuotient a : (conOnBasicOpen x' y').Quotient) =
      (conOnBasicOpen x' y').toQuotient b
    exact (conOnBasicOpen x' y').eq.mpr (conOnBasicOpen_le_of_subset h hab))

/-- The restriction map is compatible with the canonical projections:
`restrictD h (toSectionOnD x y a) = toSectionOnD x' y' a`. -/
theorem restrictD_comp_toSection {x y x' y' : P}
    (h : basicOpen x' y' ⊆ basicOpen x y) (a : P) :
    restrictD h (toSectionOnD x y a) = toSectionOnD x' y' a := by
  rfl

/-! ### Presheaf laws -/

/-- Restriction along the identity inclusion is the identity homomorphism. -/
theorem restrictD_id (x y : P) :
    restrictD (P := P) (x := x) (y := y) (x' := x) (y' := y) (le_refl _) = RingHom.id _ := by
  ext ⟨⟩; rfl

/-- Restriction is functorial: composing two restrictions equals the direct restriction.
This is the key presheaf compatibility condition. -/
theorem restrictD_comp {x y x' y' x'' y'' : P}
    (h₁ : basicOpen x' y' ⊆ basicOpen x y)
    (h₂ : basicOpen x'' y'' ⊆ basicOpen x' y') :
    (restrictD h₂).comp (restrictD h₁) =
      restrictD (Set.Subset.trans h₂ h₁) := by
  ext ⟨⟩; rfl