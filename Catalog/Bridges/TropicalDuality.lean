/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Gelfand Reconstruction on Finite T₀ Spaces

This file establishes a finite tropical analogue of the classical Gelfand duality /
Nullstellensatz: on a finite type `X` equipped with a function semiring `X → S`
(where `S` is a nontrivial commutative semiring with no zero divisors),
we prove:

1. **Kernel–support duality for idempotent KME**: The kernel of a weighted KME functional
   equals the vanishing ideal of its support (`ker_kme_eq_vanishing_support`).

2. **Support recovery**: The support of the vanishing ideal of a set `F` recovers `F`
   (`supportOfIdeal_vanishingIdeal`).

3. **Galois anti-isomorphism**: Subsets of `X` are in order-reversing bijection with
   support-stable geometric-radical ideals of `X → S`
   (`setIdealOrderAntiIso`).

These results form the algebraic-geometric backbone for reconstructing finite spaces
from algebras of tropical/idempotent observables.
-/

import Mathlib

namespace TropicalDuality

/-! ## Setup and basic definitions -/

variable {X : Type*} {S : Type*}

section Definitions

variable [CommSemiring S]

/-- The function semiring of "sections" over a finite type. -/
abbrev KernelSectionSemiring (X S : Type*) [Fintype X] := X → S

/-- The vanishing ideal of a subset `F ⊆ X`: all functions that are zero on `F`. -/
def vanishingIdeal (F : Set X) : Ideal (X → S) where
  carrier := {f | ∀ x ∈ F, f x = 0}
  add_mem' := fun {f g} hf hg x hx => by simp [hf x hx, hg x hx]
  zero_mem' := fun _ _ => rfl
  smul_mem' := fun _ _ hf x hx => by simp [hf x hx]

/-- The support of an ideal: points where every function in the ideal vanishes. -/
def supportOfIdeal (I : Ideal (X → S)) : Set X :=
  {x | ∀ f ∈ I, f x = 0}

/-- An ideal is support-stable if it equals the vanishing ideal of its support. -/
def supportStable (I : Ideal (X → S)) : Prop :=
  vanishingIdeal (supportOfIdeal I) = I

/-- An ideal is geometrically radical if membership is determined by vanishing
on the support. -/
def geomRadical (I : Ideal (X → S)) : Prop :=
  ∀ f, (∀ x ∈ supportOfIdeal I, f x = 0) → f ∈ I

/-- Membership in a vanishing ideal is equivalent to vanishing on the set. -/
theorem mem_vanishingIdeal_iff (F : Set X) (f : X → S) :
    f ∈ vanishingIdeal F ↔ ∀ x ∈ F, f x = 0 :=
  Iff.rfl

end Definitions

section KME

variable [Fintype X] [CommSemiring S] [SemilatticeSup S] [OrderBot S]

/-- The support of a weight function: points where the weight is nonzero. -/
def supportOfMeasure (w : X → S) : Set X := {x | w x ≠ ⊥}

/-- The weighted KME functional: computes `sup_x (w x * f x)`. -/
def kmeFromWeight (w : X → S) (f : X → S) : S :=
  Finset.sup Finset.univ (fun x => w x * f x)

/-- The kernel of a KME functional: functions mapped to ⊥. -/
def kmeKernel (w : X → S) : Set (X → S) := {f | kmeFromWeight w f = ⊥}

end KME

section MonotoneLemmas

variable [CommSemiring S]

/-- `vanishingIdeal` is anti-monotone: larger sets have smaller vanishing ideals. -/
theorem vanishingIdeal_anti : Antitone (fun F : Set X => vanishingIdeal (S := S) F) :=
  fun _ _ hFG _ hf x hx => hf x (hFG hx)

/-- `supportOfIdeal` is anti-monotone: larger ideals have smaller supports. -/
theorem supportOfIdeal_anti : Antitone (fun I : Ideal (X → S) => supportOfIdeal I) :=
  fun _ _ hIJ _ hx f hf => hx f (hIJ hf)

/-- Any ideal is contained in the vanishing ideal of its support. -/
theorem le_vanishingIdeal_supportOfIdeal (I : Ideal (X → S)) :
    I ≤ vanishingIdeal (supportOfIdeal I) :=
  fun _ hf _ hx => hx _ hf

end MonotoneLemmas

section SupportRecovery

variable [DecidableEq X] [CommSemiring S] [Nontrivial S]

/-- Point indicator function: equals `1` at `x` and `0` elsewhere. -/
noncomputable def ptIndicator (x : X) : X → S :=
  fun y => if y = x then 1 else 0

omit [Nontrivial S] in
theorem ptIndicator_self (x : X) : ptIndicator (S := S) x x = 1 := by
  simp [ptIndicator]

omit [Nontrivial S] in
theorem ptIndicator_ne {x y : X} (h : y ≠ x) : ptIndicator (S := S) x y = 0 := by
  simp [ptIndicator, h]

omit [Nontrivial S] in
/-- The indicator of a point not in `F` belongs to the vanishing ideal of `F`. -/
theorem ptIndicator_mem_vanishingIdeal {x : X} {F : Set X} (hx : x ∉ F) :
    ptIndicator (S := S) x ∈ vanishingIdeal F := by
  intro y hy
  exact ptIndicator_ne (fun h => hx (h ▸ hy))

/-- **Support recovery**: The support of the vanishing ideal of `F` is exactly `F`. -/
theorem supportOfIdeal_vanishingIdeal (F : Set X) :
    supportOfIdeal (vanishingIdeal (S := S) F) = F := by
  ext x
  constructor
  · intro hx
    by_contra hxF
    have hmem := ptIndicator_mem_vanishingIdeal (S := S) hxF
    have := hx _ hmem
    simp [ptIndicator] at this
  · exact fun hx _ hf => hf x hx

/-- The vanishing ideal map on sets is injective. -/
theorem vanishingIdeal_injective :
    Function.Injective (fun F : Set X => vanishingIdeal (S := S) F) := by
  intro F G h
  have h1 := supportOfIdeal_vanishingIdeal (S := S) F
  have h2 := supportOfIdeal_vanishingIdeal (S := S) G
  have : supportOfIdeal (vanishingIdeal (S := S) F) = supportOfIdeal (vanishingIdeal (S := S) G) :=
    congr_arg supportOfIdeal h
  rw [h1, h2] at this; exact this

end SupportRecovery

section IdealClassification

variable [CommSemiring S]

/-- `geomRadical` is equivalent to `supportStable`. -/
theorem geomRadical_iff_supportStable (I : Ideal (X → S)) :
    geomRadical I ↔ supportStable I := by
  constructor
  · exact fun h => le_antisymm (fun f hf => h f hf) (le_vanishingIdeal_supportOfIdeal I)
  · exact fun h f hf => h ▸ hf

variable [DecidableEq X] [Nontrivial S]

/-- Every vanishing ideal is support-stable. -/
theorem supportStable_vanishingIdeal (F : Set X) :
    supportStable (vanishingIdeal (S := S) F) := by
  unfold supportStable
  congr
  exact supportOfIdeal_vanishingIdeal F

/-- Every vanishing ideal is geometrically radical. -/
theorem geomRadical_vanishingIdeal (F : Set X) :
    geomRadical (vanishingIdeal (S := S) F) :=
  (geomRadical_iff_supportStable _).mpr (supportStable_vanishingIdeal F)

end IdealClassification

section KerKME

variable [Fintype X] [CommSemiring S] [SemilatticeSup S] [OrderBot S]
variable [NoZeroDivisors S]

/-- **Kernel–support duality**: The kernel of a weighted KME functional equals
the vanishing ideal of its support.

This is the tropical/idempotent analogue of the classical measure-theoretic fact:
"a nonneg integral vanishes iff the function vanishes on the support of the measure". -/
theorem ker_kme_eq_vanishing_support (w : X → S) (hbot : (⊥ : S) = (0 : S)) :
    kmeKernel w = (vanishingIdeal (supportOfMeasure w) : Ideal (X → S)) := by
  ext f
  constructor
  · intro hf x hx
    contrapose! hf
    refine ne_of_gt (lt_of_lt_of_le ?_ (Finset.le_sup (f := fun x => w x * f x)
      (Finset.mem_univ x)))
    exact lt_of_le_of_ne bot_le (Ne.symm <| by aesop)
  · intro hf
    simp [kmeKernel, kmeFromWeight]
    intro x; by_cases hx : w x = 0 <;> simp_all +decide [vanishingIdeal]
    exact hf x (by unfold supportOfMeasure; aesop)

end KerKME

section GaloisConnection

variable [DecidableEq X] [CommSemiring S] [Nontrivial S]

/-- Sets to support-stable ideals. -/
def setToIdeal : Set X → {I : Ideal (X → S) // supportStable I ∧ geomRadical I} :=
  fun F => ⟨vanishingIdeal F, supportStable_vanishingIdeal F, geomRadical_vanishingIdeal F⟩

/-- Support-stable ideals to sets. -/
def idealToSet : {I : Ideal (X → S) // supportStable I ∧ geomRadical I} → Set X :=
  fun I => supportOfIdeal I.1

/-- `idealToSet ∘ setToIdeal = id`. -/
theorem idealToSet_setToIdeal :
    ∀ F : Set X, idealToSet (setToIdeal (S := S) F) = F :=
  fun F => supportOfIdeal_vanishingIdeal F

/-- `setToIdeal ∘ idealToSet = id`. -/
theorem setToIdeal_idealToSet :
    ∀ I : {I : Ideal (X → S) // supportStable I ∧ geomRadical I},
      setToIdeal (idealToSet I) = I := by
  unfold setToIdeal idealToSet
  aesop

/-- **Finite tropical Gelfand reconstruction**: Subsets of `X` are in
order-reversing bijection with support-stable geometrically radical ideals
of the function semiring `X → S`. -/
noncomputable def setIdealEquiv :
    Set X ≃ {I : Ideal (X → S) // supportStable I ∧ geomRadical I} where
  toFun := setToIdeal
  invFun := idealToSet
  left_inv := idealToSet_setToIdeal
  right_inv := setToIdeal_idealToSet

/-- **Order anti-isomorphism**: the bijection `setIdealEquiv` reverses the
subset/ideal inclusion order. This packages the finite tropical Nullstellensatz
as a categorical equivalence.

Concretely: `F ⊆ G ↔ vanishingIdeal G ≤ vanishingIdeal F`. -/
noncomputable def setIdealOrderAntiIso :
    Set X ≃o OrderDual {I : Ideal (X → S) // supportStable I ∧ geomRadical I} where
  toEquiv := setIdealEquiv
  map_rel_iff' := by
    intro a b
    constructor <;> intro h
    · contrapose! h
      obtain ⟨x, hx₁, hx₂⟩ := Set.not_subset.mp h
      exact fun h => absurd (h (ptIndicator_mem_vanishingIdeal hx₂) x hx₁)
        (by simp +decide [ptIndicator_self])
    · exact SetLike.coe_mono (vanishingIdeal_anti h)

end GaloisConnection

end TropicalDuality