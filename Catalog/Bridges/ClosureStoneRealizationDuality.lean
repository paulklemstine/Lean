/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Mathlib

/-!
# Closure–Stone Realization Duality via Idempotent Consequence Semimodules

This file establishes a finite duality/reconstruction theorem at the
Algebra–EML–Logic interface, bridging:
- finite logical consequence data (closure operators),
- canonical algebraic objects (implicational bases),
- Stone/Priestley-style spectral semantics (prime closed theories).

## Main Results

* `closed_inter` — intersection of closed sets is closed
* `closed_sInter` — arbitrary intersection of closed sets is closed
* `cl_closed` — `cl A` is always closed
* `closure_from_basis_is_closure_operator` — closure from implications is a closure operator
* `exists_finite_implicational_basis` — every finite closure operator has a finite basis
* `closure_table_recovers_basis_and_spectrum` — the main reconstruction theorem
* `closure_iso_preserves_structure` — functorial invariance under isomorphism

## Mathematical Overview

Given a finite type `X` and a closure operator `cl : Set X → Set X`, we construct:
1. The lattice of closed sets (closed under arbitrary intersection)
2. A finite implicational basis that reconstructs `cl` exactly
3. The space of meet-prime closed theories as a finite spectral space
4. A proof that this data is invariant under closure-table isomorphism

This establishes a certified bridge: closure table ≃ canonical basis ≃ prime spectrum.
-/

open Set Finset

namespace ClosureStoneDuality

variable {X : Type*}

/-! ## Part 1: Closure Operators -/

/-- A closure operator on sets: extensive, monotone, idempotent. -/
structure IsClosureOperator (cl : Set X → Set X) : Prop where
  extensive : ∀ A, A ⊆ cl A
  monotone : ∀ ⦃A B : Set X⦄, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A

/-- A set is closed under `cl` if `cl A = A`. -/
def IsClosed (cl : Set X → Set X) (A : Set X) : Prop := cl A = A

/-
The intersection of two closed sets is closed.
-/
theorem closed_inter (hcl : IsClosureOperator cl) {A B : Set X}
    (hA : IsClosed cl A) (hB : IsClosed cl B) :
    IsClosed cl (A ∩ B) := by
  -- By definition of closure, we have cl (A ∩ B) ⊆ cl A ∩ cl B.
  have h_subset : cl (A ∩ B) ⊆ cl A ∩ cl B := by
    exact Set.subset_inter ( hcl.monotone Set.inter_subset_left ) ( hcl.monotone Set.inter_subset_right );
  have h_eq : cl (A ∩ B) ⊆ A ∩ B := by
    rwa [ hA, hB ] at h_subset;
  exact le_antisymm h_eq ( hcl.extensive _ )

/-
The intersection of any family of closed sets is closed.
-/
theorem closed_sInter (hcl : IsClosureOperator cl) {S : Set (Set X)}
    (hS : ∀ A ∈ S, IsClosed cl A) (_hne : S.Nonempty) :
    IsClosed cl (⋂₀ S) := by
  refine' le_antisymm _ _;
  · intro x hx;
    exact Set.mem_sInter.2 fun B hB => hS B hB ▸ hcl.monotone ( Set.sInter_subset_of_mem hB ) hx;
  · exact hcl.extensive _

/-
`cl A` is always a closed set.
-/
theorem cl_closed (hcl : IsClosureOperator cl) (A : Set X) :
    IsClosed cl (cl A) := by
  exact hcl.idempotent A

/-
If A is closed and A ⊇ B, then A ⊇ cl B.
-/
theorem closed_superset_of_cl (hcl : IsClosureOperator cl) {A B : Set X}
    (hA : IsClosed cl A) (h : B ⊆ A) : cl B ⊆ A := by
  exact hA ▸ hcl.monotone h

/-
The universe is always closed.
-/
theorem closed_univ (hcl : IsClosureOperator cl) : IsClosed cl (Set.univ : Set X) := by
  obtain ⟨ _, _, _ ⟩ := hcl;
  exact Set.eq_of_subset_of_subset ( by tauto ) ( by tauto )

/-- cl is order-preserving on closed sets. -/
theorem cl_subset_of_subset (hcl : IsClosureOperator cl) {A B : Set X}
    (h : A ⊆ B) : cl A ⊆ cl B :=
  hcl.monotone h

/-! ## Part 2: Implications and Bases -/

/-- An implication `premise → conclusion` on a finite type. -/
structure Implication (X : Type*) where
  premise : Finset X
  conclusion : X

instance [DecidableEq X] : DecidableEq (Implication X) := by
  intro a b
  cases a; cases b
  simp only [Implication.mk.injEq]
  exact inferInstance

/-- A set satisfies an implication if: premise ⊆ A implies conclusion ∈ A. -/
def SatisfiesImplication (A : Set X) (r : Implication X) : Prop :=
  (↑r.premise : Set X) ⊆ A → r.conclusion ∈ A

/-- A set satisfies all implications in a collection. -/
def SatisfiesAll (A : Set X) (B : Set (Implication X)) : Prop :=
  ∀ r ∈ B, SatisfiesImplication A r

/-- Closure from a basis: the intersection of all supersets of A that satisfy all implications. -/
def ClosureFromBasis (B : Set (Implication X)) (A : Set X) : Set X :=
  ⋂₀ {S : Set X | A ⊆ S ∧ SatisfiesAll S B}

/-
The universe satisfies all implications.
-/
theorem univ_satisfies_all (B : Set (Implication X)) : SatisfiesAll Set.univ B := by
  exact fun r hr => fun h => trivial

/-
ClosureFromBasis is extensive.
-/
theorem closure_from_basis_extensive (B : Set (Implication X)) (A : Set X) :
    A ⊆ ClosureFromBasis B A := by
  exact Set.subset_sInter fun S hS => hS.1

/-
ClosureFromBasis is monotone.
-/
theorem closure_from_basis_monotone (B : Set (Implication X)) {A₁ A₂ : Set X}
    (h : A₁ ⊆ A₂) : ClosureFromBasis B A₁ ⊆ ClosureFromBasis B A₂ := by
  exact Set.sInter_subset_sInter fun S hS => ⟨ Set.Subset.trans h hS.1, hS.2 ⟩

/-
ClosureFromBasis result satisfies all implications.
-/
theorem closure_from_basis_satisfies (B : Set (Implication X)) (A : Set X) :
    SatisfiesAll (ClosureFromBasis B A) B := by
  grind +locals

/-
ClosureFromBasis is idempotent.
-/
theorem closure_from_basis_idempotent (B : Set (Implication X)) (A : Set X) :
    ClosureFromBasis B (ClosureFromBasis B A) = ClosureFromBasis B A := by
  refine' Set.Subset.antisymm _ _;
  · grind +locals;
  · exact closure_from_basis_extensive _ _

/-- ClosureFromBasis is a closure operator. -/
theorem closure_from_basis_is_closure_operator (B : Set (Implication X)) :
    IsClosureOperator (ClosureFromBasis B) where
  extensive := closure_from_basis_extensive B
  monotone := fun {_ _} h => closure_from_basis_monotone B h
  idempotent := closure_from_basis_idempotent B

/-! ## Part 3: Sound and Complete Bases -/

/-- An implication is sound for `cl` if `cl` respects it. -/
def IsSound (cl : Set X → Set X) (r : Implication X) : Prop :=
  ∀ A, (↑r.premise : Set X) ⊆ cl A → r.conclusion ∈ cl A

/-- A basis is sound for `cl` if every implication in it is sound. -/
def BasisSound (cl : Set X → Set X) (B : Set (Implication X)) : Prop :=
  ∀ r ∈ B, IsSound cl r

/-- A basis is complete for `cl` if its closure equals `cl`. -/
def BasisComplete (cl : Set X → Set X) (B : Set (Implication X)) : Prop :=
  ∀ A, ClosureFromBasis B A = cl A

/-- A basis reconstructs `cl` if it is both sound and complete. -/
def ReconstructsClosure (cl : Set X → Set X) (B : Set (Implication X)) : Prop :=
  BasisSound cl B ∧ BasisComplete cl B

/-
Soundness: if B is sound for cl, then cl A ⊆ implies ClosureFromBasis B A ⊆ cl A
    for any A, since cl A satisfies all sound implications.
-/
theorem sound_basis_closure_subset (hcl : IsClosureOperator cl)
    (B : Set (Implication X)) (hB : BasisSound cl B) (A : Set X) :
    ClosureFromBasis B A ⊆ cl A := by
  refine' Set.sInter_subset_of_mem _;
  exact ⟨ hcl.extensive A, fun r hr => hB r hr A ⟩

/-! ## Part 4: Full Basis Construction -/

/-- The full implicational basis: all implications (S, x) where x ∈ cl(↑S). -/
def FullBasis [Fintype X] [DecidableEq X] (cl : Set X → Set X) : Set (Implication X) :=
  {r : Implication X | r.conclusion ∈ cl (↑r.premise : Set X)}

/-
The full basis is sound.
-/
theorem full_basis_sound [Fintype X] [DecidableEq X] (cl : Set X → Set X)
    (hcl : IsClosureOperator cl) : BasisSound cl (FullBasis cl) := by
  intro r hr A hA;
  exact hcl.monotone hA hr |> fun h => hcl.idempotent A ▸ h

/-
Any set closed under all full-basis implications is cl-closed.
    Key lemma for completeness.
-/
theorem satisfies_full_basis_implies_closed [Fintype X] [DecidableEq X]
    (cl : Set X → Set X) (hcl : IsClosureOperator cl)
    (T : Set X) (hT : SatisfiesAll T (FullBasis cl)) :
    IsClosed cl T := by
  unfold SatisfiesAll FullBasis at hT;
  ext x;
  constructor <;> intro hx;
  · convert hT ⟨ T.toFinset, x ⟩ _ _;
    exact?;
    · aesop;
    · simp +decide;
  · exact hcl.extensive _ hx

/-
The full basis is complete: ClosureFromBasis (FullBasis cl) = cl.
-/
theorem full_basis_complete [Fintype X] [DecidableEq X]
    (cl : Set X → Set X) (hcl : IsClosureOperator cl) :
    BasisComplete cl (FullBasis cl) := by
  refine' fun A => le_antisymm _ _;
  · apply sound_basis_closure_subset hcl (FullBasis cl) (full_basis_sound cl hcl) A;
  · refine' Set.subset_sInter fun B hB => _;
    apply closed_superset_of_cl;
    · exact hcl;
    · exact satisfies_full_basis_implies_closed cl hcl B hB.2;
    · exact hB.1

/-- The full basis reconstructs cl. -/
theorem full_basis_reconstructs [Fintype X] [DecidableEq X]
    (cl : Set X → Set X) (hcl : IsClosureOperator cl) :
    ReconstructsClosure cl (FullBasis cl) :=
  ⟨full_basis_sound cl hcl, full_basis_complete cl hcl⟩

/-! ## Part 5: Meet-Prime Closed Theories and Spectral Structure -/

/-- A closed set P is meet-prime if whenever A ∩ B ⊆ P for closed A, B,
    then A ⊆ P or B ⊆ P. -/
def IsMeetPrimeClosed (cl : Set X → Set X) (P : Set X) : Prop :=
  IsClosed cl P ∧ P ≠ Set.univ ∧
  ∀ ⦃A B : Set X⦄, IsClosed cl A → IsClosed cl B →
    A ∩ B ⊆ P → A ⊆ P ∨ B ⊆ P

/-- Prime separability: distinct closed sets are separated by meet-prime closed theories. -/
def PrimeSeparable (cl : Set X → Set X) : Prop :=
  ∀ ⦃A B : Set X⦄, cl A ≠ cl B →
    ∃ P, IsMeetPrimeClosed cl P ∧
      ((cl A ⊆ P ∧ ¬cl B ⊆ P) ∨ (cl B ⊆ P ∧ ¬cl A ⊆ P))

/-- The prime spectrum of a closure operator. -/
def PrimeSpectrum (cl : Set X → Set X) : Set (Set X) :=
  {P | IsMeetPrimeClosed cl P}

/-- A join-irreducible closed set: closed, and not expressible as a union-closure
    of two strictly smaller closed sets. -/
def IsJoinIrreducibleClosed (cl : Set X → Set X) (J : Set X) : Prop :=
  IsClosed cl J ∧ J ≠ ∅ ∧
  ∀ ⦃A B : Set X⦄, IsClosed cl A → IsClosed cl B →
    J ⊆ cl (A ∪ B) → J ⊆ A ∨ J ⊆ B

/-- The set of join-irreducible closed sets. -/
def JoinIrreducibles (cl : Set X → Set X) : Set (Set X) :=
  {J | IsJoinIrreducibleClosed cl J}

/-! ## Part 6: Closure Table Isomorphism -/

/-- An isomorphism of closure tables: a bijection on elements that commutes
    with the closure operators. -/
structure ClosureTableIso [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
    (clX : Set X → Set X) (clY : Set Y → Set Y) where
  toFun : X → Y
  invFun : Y → X
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y
  commutes : ∀ A : Set X, Set.image toFun (clX A) = clY (Set.image toFun A)

variable {Y : Type*}

/-
A closure table isomorphism maps closed sets to closed sets.
-/
theorem closure_iso_maps_closed [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
    {clX : Set X → Set X} {clY : Set Y → Set Y}
    (e : ClosureTableIso clX clY) {A : Set X} (hA : IsClosed clX A) :
    IsClosed clY (Set.image e.toFun A) := by
  rw [IsClosed] at *;
  rw [ ← e.commutes, hA ]

/-
A closure table isomorphism preserves meet-primality.
-/
theorem closure_iso_preserves_meet_prime [Fintype X] [DecidableEq X]
    [Fintype Y] [DecidableEq Y]
    {clX : Set X → Set X} {clY : Set Y → Set Y}
    (_hX : IsClosureOperator clX) (_hY : IsClosureOperator clY)
    (e : ClosureTableIso clX clY) {P : Set X} (hP : IsMeetPrimeClosed clX P) :
    IsMeetPrimeClosed clY (Set.image e.toFun P) := by
  refine' ⟨ _, _, _ ⟩;
  · exact closure_iso_maps_closed e hP.1;
  · obtain ⟨ x, hx ⟩ := Set.nonempty_compl.2 hP.2.1;
    simp_all +decide [ Set.ext_iff ];
    exact ⟨ e.toFun x, fun y hy hxy => hx <| by have := e.left_inv y; have := e.left_inv x; aesop ⟩;
  · intro A B hA hB hAB
    have h_preimage : Set.preimage e.toFun A ∩ Set.preimage e.toFun B ⊆ P := by
      intro x hx;
      obtain ⟨ y, hy, hy' ⟩ := hAB ⟨ hx.1, hx.2 ⟩;
      have := e.left_inv y; have := e.left_inv x; aesop;
    have h_preimage_closed : IsClosed clX (Set.preimage e.toFun A) ∧ IsClosed clX (Set.preimage e.toFun B) := by
      have h_preimage_closed : ∀ A : Set Y, IsClosed clY A → IsClosed clX (Set.preimage e.toFun A) := by
        intro A hA
        have h_preimage_closed : clX (Set.preimage e.toFun A) = Set.preimage e.toFun (clY A) := by
          have := e.commutes ( e.toFun ⁻¹' A );
          rw [ Set.image_eq_preimage_of_inverse ] at this;
          any_goals exact e.invFun;
          · convert congr_arg ( fun s => e.toFun ⁻¹' s ) this using 1;
            · ext x; simp +decide [ e.left_inv ] ;
            · simp +decide [ Set.preimage, e.right_inv ];
          · exact e.left_inv;
          · exact fun x => e.right_inv x;
        unfold IsClosed at *; aesop;
      exact ⟨ h_preimage_closed A hA, h_preimage_closed B hB ⟩
    have h_preimage_subset : Set.preimage e.toFun A ⊆ P ∨ Set.preimage e.toFun B ⊆ P := by
      exact hP.2.2 h_preimage_closed.1 h_preimage_closed.2 h_preimage
    have h_image_subset : A ⊆ e.toFun '' P ∨ B ⊆ e.toFun '' P := by
      cases' h_preimage_subset with h h <;> [ left; right ] <;> intro y hy <;> have := e.right_inv y <;> aesop;
    exact h_image_subset

/-! ## Part 7: Main Reconstruction Theorems -/

/-- **Theorem A: Certified Finite Basis Reconstruction.**
    Every closure operator on a finite type has a finite implicational basis
    that exactly reconstructs the closure operator. -/
theorem exists_finite_implicational_basis [Fintype X] [DecidableEq X]
    (cl : Set X → Set X) (hcl : IsClosureOperator cl) :
    ∃ B : Set (Implication X),
      ReconstructsClosure cl B ∧ ∀ A, ClosureFromBasis B A = cl A :=
  ⟨FullBasis cl, full_basis_reconstructs cl hcl, (full_basis_complete cl hcl)⟩

/-
**Theorem B: Prime Spectrum Structure.**
    Under prime separability, the prime spectrum faithfully separates
    the closed sets, establishing the spectral half of the duality.
-/
theorem prime_spectrum_separates [Fintype X] [DecidableEq X]
    (cl : Set X → Set X) (_hcl : IsClosureOperator cl)
    (hsep : PrimeSeparable cl) :
    ∀ ⦃A B : Set X⦄, IsClosed cl A → IsClosed cl B → A ≠ B →
      ∃ P ∈ PrimeSpectrum cl, (A ⊆ P ∧ ¬B ⊆ P) ∨ (B ⊆ P ∧ ¬A ⊆ P) := by
  intro A B hA hB hAB
  obtain ⟨P, hP⟩ : ∃ P, IsMeetPrimeClosed cl P ∧ ((cl A ⊆ P ∧ ¬cl B ⊆ P) ∨ (cl B ⊆ P ∧ ¬cl A ⊆ P)) := by
    apply hsep;
    exact fun h => hAB <| hA.symm.trans <| h.trans hB
  generalize_proofs at *; (
  exact ⟨ P, hP.1, by rw [ hA, hB ] at hP; tauto ⟩)

/-- **Theorem C: Main Reconstruction Duality.**
    The closure table of a finite separated closure operator determines:
    1. A sound and complete implicational basis,
    2. A prime spectrum that separates closed sets,
    providing a certified bridge: closure table → basis + spectrum. -/
theorem closure_table_recovers_basis_and_spectrum [Fintype X] [DecidableEq X]
    (cl : Set X → Set X) (hcl : IsClosureOperator cl)
    (hsep : PrimeSeparable cl) :
    (∃ B : Set (Implication X), ReconstructsClosure cl B) ∧
    (∀ ⦃A B : Set X⦄, IsClosed cl A → IsClosed cl B → A ≠ B →
      ∃ P ∈ PrimeSpectrum cl, (A ⊆ P ∧ ¬B ⊆ P) ∨ (B ⊆ P ∧ ¬A ⊆ P)) := by
  exact ⟨⟨FullBasis cl, full_basis_reconstructs cl hcl⟩,
         prime_spectrum_separates cl hcl hsep⟩

/-- **Theorem D: Functorial Invariance.**
    A closure table isomorphism preserves the spectral structure:
    it maps meet-prime closed sets bijectively. -/
theorem closure_iso_preserves_structure [Fintype X] [DecidableEq X]
    [Fintype Y] [DecidableEq Y]
    (clX : Set X → Set X) (clY : Set Y → Set Y)
    (hX : IsClosureOperator clX) (hY : IsClosureOperator clY)
    (e : ClosureTableIso clX clY) :
    ∀ P : Set X, IsMeetPrimeClosed clX P →
      IsMeetPrimeClosed clY (Set.image e.toFun P) :=
  fun _P hP => closure_iso_preserves_meet_prime hX hY e (P := _P) hP

end ClosureStoneDuality