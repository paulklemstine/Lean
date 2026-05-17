/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Galois Obstruction Theory: From Non-Solvable Groups to Non-Solvability by Radicals

This file connects group-theoretic non-solvability to the impossibility of solving
polynomial equations by radicals. It provides the formal bridge from Galois groups
to the Abel-Ruffini theorem.

## Main results

* `galGroup_not_solvable_of_equiv_S5`: If the Galois group of a polynomial is
  isomorphic to S₅, then it is not solvable.
* `not_solvableByRad_root_of_Gal_not_solvable`: An irreducible polynomial whose
  Galois group is not solvable has no root solvable by radicals.
* `not_solvableByRad_of_galGroup_equiv_S5`: The main obstruction theorem combining
  the above.

## Key definitions

* `PolynomialSolvableByRadicals`: A polynomial is solvable by radicals if all its
  roots in a splitting field are solvable by radicals.
-/

import Mathlib
import GaloisSolvability.GroupSolvability

open Polynomial Subgroup

/-! ## Definition of Solvability by Radicals for Polynomials -/

/-- A polynomial over a field K is solvable by radicals if every root of f in
    the algebraic closure is in the solvable-by-radicals subfield.
    This captures the classical notion: f is solvable by radicals iff all its
    roots can be expressed using field operations and n-th roots starting from K. -/
def PolynomialSolvableByRadicals (K : Type*) [Field K]
    {E : Type*} [Field E] [Algebra K E]
    (f : Polynomial K) : Prop :=
  ∀ α : E, Polynomial.aeval α f = 0 → IsSolvableByRad K α

/-! ## Non-solvability Transfer -/

/-
If the Galois group of a polynomial f (as automorphisms of its splitting field)
is isomorphic as a group to Equiv.Perm (Fin 5), then the Galois group is not solvable.
This is the key link: S₅ non-solvability transfers through any group isomorphism.
-/
theorem galGroup_not_solvable_of_mulEquiv_S5
    (f : Polynomial ℚ)
    (hG : Nonempty (f.Gal ≃* Equiv.Perm (Fin 5))) :
    ¬ IsSolvable f.Gal := by
  convert not_solvable_perm_fin_five using 1;
  constructor <;> intro h <;> cases' h with n hn;
  · obtain ⟨ n, hn ⟩ := n;
    -- Since the derived series of f.Gal is trivial at step n, the derived series of Equiv.Perm (Fin 5) must also be trivial at step n.
    have h_derived_series : derivedSeries (Equiv.Perm (Fin 5)) n = ⊥ := by
      have h_derived_series_trivial : ∀ (G H : Type) [Group G] [Group H] (e : G ≃* H), derivedSeries H n = Subgroup.map e.toMonoidHom (derivedSeries G n) := by
        intros G H _ _ e;
        refine' Nat.recOn n _ _ <;> simp_all +decide [ derivedSeries ];
        simp +decide [ Subgroup.map_commutator ];
      rw [ h_derived_series_trivial _ _ hG.some, hn, Subgroup.map_bot ];
    exact ⟨ n, h_derived_series ⟩;
  · exact False.elim <| not_solvable_perm_fin_five <| by rcases n with ⟨ n, hn ⟩ ; exact ⟨ n, hn ⟩ ;

/-! ## From Non-Solvable Galois Group to Non-Solvability by Radicals -/

/-
An irreducible polynomial whose Galois group is not solvable has no root
that is solvable by radicals in any field extension.
This is the contrapositive of the fundamental theorem of Abel-Ruffini:
if a root were solvable by radicals, then its minimal polynomial (which divides f)
would have a solvable Galois group, contradicting the non-solvability of f's
Galois group.
-/
theorem not_solvableByRad_root_of_Gal_not_solvable
    {K : Type*} [Field K] [CharZero K]
    (f : Polynomial K)
    (hf_irred : Irreducible f)
    (hG : ¬ IsSolvable f.Gal) :
    ∀ α : f.SplittingField, Polynomial.aeval α f = 0 → ¬ IsSolvableByRad K α := by
  intro α hαG;
  contrapose! hG;
  have := solvableByRad.isSolvable' hf_irred hαG hG;
  grind

/-! ## The Main Obstruction Theorem -/

/-- **Galois Obstruction Theorem**: An irreducible polynomial over ℚ whose Galois
group is isomorphic to S₅ is not solvable by radicals.

This is the concrete precursor to the full Abel-Ruffini theorem. It says:
if f ∈ ℚ[X] is irreducible and Gal(f) ≅ S₅, then there is no expression
involving +, -, ×, ÷, and n-th roots that produces a root of f.

The proof combines two facts:
1. S₅ is not solvable (group theory)
2. If a root were solvable by radicals, the Galois group would be solvable
   (Galois theory, contrapositive) -/
theorem not_solvableByRad_of_galGroup_equiv_S5
    (f : Polynomial ℚ)
    (hf_irred : Irreducible f)
    (hG : Nonempty (f.Gal ≃* Equiv.Perm (Fin 5))) :
    ∀ α : f.SplittingField, Polynomial.aeval α f = 0 → ¬ IsSolvableByRad ℚ α := by
  intro α hα habs
  exact not_solvableByRad_root_of_Gal_not_solvable f hf_irred
    (galGroup_not_solvable_of_mulEquiv_S5 f hG) α hα habs

/-! ## Galois Correspondence as Order Anti-Isomorphism -/

/-- The Galois correspondence: for a finite Galois extension L/K, the lattice
of intermediate fields is anti-isomorphic to the lattice of closed subgroups
of the Galois group.

This is the Fundamental Theorem of Galois Theory in its order-theoretic form.
It encodes the deep duality between field structure and symmetry structure
that underlies all of Galois theory. -/
theorem galois_correspondence_orderIso
    (K L : Type*) [Field K] [Field L] [Algebra K L]
    [FiniteDimensional K L] [IsGalois K L] :
    Nonempty (IntermediateField K L ≃o (Subgroup (L ≃ₐ[K] L))ᵒᵈ) :=
  ⟨IsGalois.intermediateFieldEquivSubgroup⟩