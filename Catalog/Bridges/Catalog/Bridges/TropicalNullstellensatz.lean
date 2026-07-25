/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Nullstellensatz for Function Semirings

This file establishes a tropical analogue of Hilbert's Nullstellensatz in the setting of
idempotent semirings of functions. The classical Nullstellensatz relates ideals in a
polynomial ring to algebraic varieties; here, we relate sets of functions vanishing at
points (measured by equality with `⊥`, the tropical zero) to their common zero loci.

## Main definitions

* `tropZeroSet` — the common tropical zero set of a finite family of functions
* `idealOfSet` — the set of all functions vanishing on a given subset
* `tropRadical` — the pointwise radical closure: functions that vanish wherever all
  members of a given set vanish
* `tropZeroSetInSubsemiring` — zero set restricted to a subsemiring
* `idealOfSetInSubsemiring` — vanishing ideal restricted to a subsemiring

## Main results

* `tropRadical_eq_idealOfSet_tropZeroSetPred` — the fundamental tropical Nullstellensatz:
  the tropical radical of a set of functions equals the ideal of its common zero set
* `tropRadical_fg_eq_idealOfSet_zeroSet` — the finitely generated version
* `mem_idealOfSet_zeroSet_iff_mem_tropRadical` — membership characterization
* `tropNullstellensatz_subsemiring` — the subsemiring corollary for EML function algebras
* `idealOfSet_zeroSet_galoisConnection` — Galois connection between zero sets and ideals

## Mathematical significance

This theorem is the algebra-geometry half of the tropical Stone–Weierstrass story.
Existing approximation results show that separating EML tropical function algebras
are rich enough to approximate observables. The Nullstellensatz direction says that
these algebras also remember **tropical varieties / decision regions / symbolic zero
sets**. Together they form an algebra-geometry dictionary for tropical mathematics.
-/

open Set Finset

universe u v

variable {X : Type u} {S : Type v}

/-! ### Core definitions -/

/-- The tropical zero set of a finite family of functions: the set of points where
all functions in the family evaluate to `⊥` (the tropical zero). -/
def tropZeroSet [Bot S] (I : Finset (X → S)) : Set X :=
  {x | ∀ f ∈ I, f x = ⊥}

/-- The ideal of a subset: all functions that vanish (evaluate to `⊥`) on every
point of the given set. This is the tropical analogue of the vanishing ideal. -/
def idealOfSet [Bot S] (Y : Set X) : Set (X → S) :=
  {f | ∀ x ∈ Y, f x = ⊥}

/-- The tropical radical of a set of functions: the set of all functions that vanish
wherever all members of `I` simultaneously vanish. This is the geometric radical —
it captures exactly the functions whose zero set contains the common zero set of `I`. -/
def tropRadical [Bot S] (I : Set (X → S)) : Set (X → S) :=
  {f | ∀ x, (∀ g ∈ I, g x = ⊥) → f x = ⊥}

/-! ### Membership lemmas -/

@[simp]
lemma mem_tropZeroSet_iff [Bot S] (G : Finset (X → S)) (x : X) :
    x ∈ tropZeroSet G ↔ ∀ f ∈ G, f x = ⊥ :=
  Iff.rfl

@[simp]
lemma mem_idealOfSet_iff [Bot S] (Y : Set X) (f : X → S) :
    f ∈ idealOfSet Y ↔ ∀ x ∈ Y, f x = ⊥ :=
  Iff.rfl

@[simp]
lemma mem_tropRadical_iff [Bot S] (I : Set (X → S)) (f : X → S) :
    f ∈ tropRadical I ↔ ∀ x, (∀ g ∈ I, g x = ⊥) → f x = ⊥ :=
  Iff.rfl

/-! ### Monotonicity and antitonicity -/

/-
The tropical radical is monotone: enlarging the generating set grows the radical,
because the common zero set shrinks, weakening the vanishing condition.
-/
theorem tropRadical_mono [Bot S] {I J : Set (X → S)} (hIJ : I ⊆ J) :
    tropRadical I ⊆ tropRadical J := by
  exact fun f hf x hx => hf x fun g hg => hx g ( hIJ hg )

/-
The ideal-of-set operator is antitone: enlarging the set shrinks the ideal.
-/
theorem idealOfSet_anti [Bot S] {Y Z : Set X} (hYZ : Y ⊆ Z) :
    @idealOfSet X S _ Z ⊆ @idealOfSet X S _ Y := by
  exact fun f hf x hx => hf x ( hYZ hx )

/-! ### The fundamental inclusions -/

/-
Every function in `I` vanishes on the common zero set of `I`.
-/
theorem subset_idealOfSet_zeroSetPred [Bot S] (I : Set (X → S)) :
    I ⊆ idealOfSet (X := X) (S := S) {x | ∀ g ∈ I, g x = ⊥} := by
  exact fun f hf => fun x hx => hx f hf

/-
Every point in `Y` belongs to the zero set of the ideal of `Y`.
-/
theorem subset_zeroSetPred_idealOfSet [Bot S] (Y : Set X) :
    Y ⊆ {x : X | ∀ f ∈ @idealOfSet X S _ Y, f x = ⊥} := by
  exact fun x hx f hf => hf x hx

/-! ### The Tropical Nullstellensatz -/

/-
**Tropical Nullstellensatz (function-semiring version).**
The tropical radical of a set of functions `I` equals the ideal of its common zero set.
This is the fundamental algebra-geometry correspondence in tropical function theory:
the radical closure is precisely captured by the geometric vanishing condition.
-/
theorem tropRadical_eq_idealOfSet_tropZeroSetPred [Bot S] (I : Set (X → S)) :
    tropRadical I = idealOfSet (X := X) (S := S) {x | ∀ g ∈ I, g x = ⊥} := by
  grind +extAll

/-
**Tropical Nullstellensatz (finitely generated version).**
For a finite family of generators `G`, the tropical radical of the set of generators
equals the ideal of their common zero set.
-/
theorem tropRadical_fg_eq_idealOfSet_zeroSet [Bot S] (G : Finset (X → S)) :
    tropRadical (↑G : Set (X → S)) = idealOfSet (tropZeroSet G) := by
  convert tropRadical_eq_idealOfSet_tropZeroSetPred ( G : Set ( X → S ) )

/-
Membership characterization combining both directions of the Nullstellensatz.
-/
theorem mem_idealOfSet_zeroSet_iff_mem_tropRadical [Bot S]
    (G : Finset (X → S)) (f : X → S) :
    f ∈ idealOfSet (tropZeroSet G) ↔ ∀ x, (∀ g ∈ G, g x = ⊥) → f x = ⊥ := by
  exact mem_idealOfSet_iff (tropZeroSet G) f

/-! ### Galois connection -/

/-
The Galois connection between subsets of `X` and subsets of `X → S`:
a set of functions is contained in the ideal of `Y` if and only if `Y` is contained
in the common zero set of those functions.
-/
theorem idealOfSet_zeroSet_galoisConnection [Bot S]
    (J : Set (X → S)) (Y : Set X) :
    J ⊆ @idealOfSet X S _ Y ↔ Y ⊆ {x | ∀ f ∈ J, f x = ⊥} := by
  -- To prove the equivalence, we split it into two implications.
  apply Iff.intro;
  · exact fun h x hx f hf => h hf x hx;
  · exact fun h f hf x hx => h hx f hf

/-
The ideal of the zero set equals the tropical radical.
-/
theorem idealOfSet_zeroSetPred_eq_tropRadical [Bot S] (I : Set (X → S)) :
    idealOfSet (X := X) (S := S) {x | ∀ g ∈ I, g x = ⊥} = tropRadical I := by
  -- Apply the theorem that states the equality between the ideal of the zero set and the tropical radical.
  apply (tropRadical_eq_idealOfSet_tropZeroSetPred I).symm

/-! ### Idempotence of the closure operators -/

/-
Applying the zero-set-then-ideal operator twice is idempotent.
-/
theorem tropRadical_idempotent [Bot S] (I : Set (X → S)) :
    tropRadical (tropRadical I) = tropRadical I := by
  grind +locals

/-! ### Closure properties of idealOfSet -/

/-
The zero function belongs to the ideal of any set.
-/
theorem zero_mem_idealOfSet [Bot S] (Y : Set X) :
    (fun _ : X => (⊥ : S)) ∈ @idealOfSet X S _ Y := by
  exact fun x hx => rfl

/-
The ideal of a set is closed under pointwise addition when `⊥ + ⊥ = ⊥`.
-/
theorem idealOfSet_add_closed [Add S] [Bot S]
    (hbot : (⊥ : S) + ⊥ = ⊥)
    (Y : Set X) {f g : X → S}
    (hf : f ∈ @idealOfSet X S _ Y) (hg : g ∈ @idealOfSet X S _ Y) :
    (f + g) ∈ @idealOfSet X S _ Y := by
  exact fun x hx => by aesop;

/-
The ideal of a set is closed under pointwise scalar multiplication
when `⊥` is absorbing for multiplication (i.e., `s * ⊥ = ⊥`).
-/
theorem idealOfSet_smul_closed [Mul S] [Bot S]
    (hbot : ∀ s : S, s * ⊥ = ⊥)
    (Y : Set X) {f g : X → S}
    (hf : f ∈ @idealOfSet X S _ Y) :
    (fun x => g x * f x) ∈ @idealOfSet X S _ Y := by
  exact fun x hx => by simp +decide [ hf x hx, hbot ] ;

/-! ### Subsemiring formulation for EML algebras -/

section Subsemiring

variable [Semiring S] [Bot S]

/-- The tropical zero set restricted to functions in a subsemiring `A`. -/
def tropZeroSetInSubsemiring
    {A : Subsemiring (X → S)} (G : Finset A) : Set X :=
  {x | ∀ g ∈ G, (g : X → S) x = ⊥}

/-- The vanishing ideal restricted to a subsemiring `A`: elements of `A` that
vanish on all points of `Y`. -/
def idealOfSetInSubsemiring
    (A : Subsemiring (X → S)) (Y : Set X) : Set A :=
  {f | ∀ x ∈ Y, (f : X → S) x = ⊥}

@[simp]
lemma mem_tropZeroSetInSubsemiring_iff
    {A : Subsemiring (X → S)} (G : Finset A) (x : X) :
    x ∈ tropZeroSetInSubsemiring G ↔ ∀ g ∈ G, (g : X → S) x = ⊥ :=
  Iff.rfl

@[simp]
lemma mem_idealOfSetInSubsemiring_iff
    (A : Subsemiring (X → S)) (Y : Set X) (f : A) :
    f ∈ idealOfSetInSubsemiring A Y ↔ ∀ x ∈ Y, (f : X → S) x = ⊥ :=
  Iff.rfl

/-
**Tropical Nullstellensatz for subsemirings (EML corollary).**
For a subsemiring `A` of `X → S` (e.g., an EML function algebra) and a finite family
of generators `G ⊆ A`, the vanishing ideal of the common zero set equals the set of
elements whose coercion to functions vanishes wherever all generators do.
-/
theorem tropNullstellensatz_subsemiring
    (A : Subsemiring (X → S))
    (G : Finset A) :
    idealOfSetInSubsemiring A (tropZeroSetInSubsemiring G) =
      {f : A | ∀ x, (∀ g ∈ G, (g : X → S) x = ⊥) → (f : X → S) x = ⊥} := by
  -- To prove the equality, we can use the ext tactic, which allows us to show that every element of one set is in the other and vice versa.
  ext f
  simp [idealOfSetInSubsemiring, tropZeroSetInSubsemiring]

end Subsemiring

/-! ### Vanishing congruence -/

/-- The vanishing congruence on functions relative to a set `Y`:
two functions are equivalent if they agree on their vanishing behavior on `Y`. -/
def vanishingCongr [Bot S] (Y : Set X) : Setoid (X → S) where
  r f g := ∀ x ∈ Y, (f x = ⊥ ↔ g x = ⊥)
  iseqv := {
    refl := fun _ _ _ => Iff.rfl
    symm := fun h x hx => (h x hx).symm
    trans := fun h₁ h₂ x hx => (h₁ x hx).trans (h₂ x hx)
  }

/-
The vanishing congruence on the zero set of `G` is characterized by
the pointwise iff condition on `tropZeroSet G`.
-/
theorem vanishingCongr_zeroSet_iff [Bot S] (G : Finset (X → S))
    (f g : X → S) :
    (vanishingCongr (tropZeroSet G)).r f g ↔
      ∀ x ∈ tropZeroSet G, (f x = ⊥ ↔ g x = ⊥) := by
  rfl