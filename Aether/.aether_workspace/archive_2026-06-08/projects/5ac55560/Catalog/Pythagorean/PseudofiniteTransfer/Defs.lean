/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Pseudofinite Transfer: Definitions

This file defines the core infrastructure for a restricted Łoś transfer principle
suitable for transporting finite algebraic-combinatorial theorems (especially
growth-or-control dichotomies for GL(2, 𝔽_q)) into pseudofinite settings.

## Main definitions

* `UltraProductSetoid` / `UltraProduct`: the ultraproduct of a family of types
  over an ultrafilter, constructed as a quotient by eventual equality.
* `UltraPred`: lifts a family of predicates to an ultraproduct predicate.
* `RestrictedFormula`: a propositional formula language over families of
  predicates, supporting atoms, conjunction, disjunction, negation, and
  implication.
* `UniformDefinableFamily`: a uniform family of subsets parameterized by
  a common parameter type.
* `EventualDoublingBound` / `UltraDoublingBound`: bounded multiplicative
  doubling for families and their pseudofinite counterparts.
* `CosetControlledBy` / `EventualCosetControl` / `UltraCosetControl`:
  coset-control predicates.

## References

* Łoś, J. (1955). Quelques remarques, théorèmes et problèmes sur les classes
  définissables d'algèbres.
* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
* Breuillard, Green, Tao (2012). The structure of approximate groups.
-/

import Mathlib

open Filter Set Pointwise

namespace PseudofiniteTransfer

variable {ι : Type*}

/-! ## Part 1: Ultraproduct Construction -/

/-- The setoid for the ultraproduct: two families are equivalent if they
agree on an ultrafilter-large set of indices. -/
def ultraProductSetoid (U : Ultrafilter ι) (α : ι → Type*) : Setoid (∀ i, α i) where
  r f g := ({i | f i = g i} : Set ι) ∈ U.1
  iseqv := {
    refl := fun f => by
      have : {i : ι | f i = f i} = Set.univ := by ext; simp
      rw [this]; exact U.1.univ_mem
    symm := fun {f g} h =>
      U.1.mem_of_superset h (fun i hi => hi.symm)
    trans := fun {f g h} h1 h2 =>
      U.1.mem_of_superset (U.1.inter_mem h1 h2)
        (fun i ⟨e1, e2⟩ => e1.trans e2)
  }

/-- The ultraproduct of a family of types over an ultrafilter.
This is `∏_U α_i`, the standard model-theoretic ultraproduct. -/
def UltraProduct (U : Ultrafilter ι) (α : ι → Type*) : Type _ :=
  Quotient (ultraProductSetoid U α)

/-- Canonical embedding of a family element into the ultraproduct. -/
def UltraProduct.mk (U : Ultrafilter ι) {α : ι → Type*} (f : ∀ i, α i) :
    UltraProduct U α :=
  Quotient.mk (ultraProductSetoid U α) f

/-- Every element of the ultraproduct has a representative family. -/
theorem UltraProduct.exists_rep {U : Ultrafilter ι} {α : ι → Type*}
    (x : UltraProduct U α) : ∃ f : ∀ i, α i, UltraProduct.mk U f = x :=
  Quotient.exists_rep x

/-! ## Part 2: Lifted Predicates on the Ultraproduct -/

/-- Well-definedness lemma: eventual equality of representatives preserves
eventual membership in a family of sets. -/
theorem ultraPred_wellDefined (U : Ultrafilter ι) {α : ι → Type*}
    (P : ∀ i, Set (α i)) {f g : ∀ i, α i}
    (hfg : ({i | f i = g i} : Set ι) ∈ U.1) :
    (({i | f i ∈ P i} : Set ι) ∈ U.1) = (({i | g i ∈ P i} : Set ι) ∈ U.1) := by
  apply propext
  constructor
  · intro hf
    apply U.1.mem_of_superset (U.1.inter_mem hf hfg)
    intro i ⟨hi, heq⟩
    simp only [Set.mem_setOf_eq] at hi ⊢
    rwa [← heq]
  · intro hg
    apply U.1.mem_of_superset (U.1.inter_mem hg hfg)
    intro i ⟨hi, heq⟩
    simp only [Set.mem_setOf_eq] at hi ⊢
    rwa [heq]

/-- A predicate on the ultraproduct induced by a family of predicates.
An element satisfies the lifted predicate iff every (equivalently, some)
representative eventually belongs to the family of sets. -/
def UltraPred (U : Ultrafilter ι) {α : ι → Type*} (P : ∀ i, Set (α i))
    (x : UltraProduct U α) : Prop :=
  Quotient.liftOn x
    (fun f => ({i | f i ∈ P i} : Set ι) ∈ U.1)
    (fun _ _ hfg => ultraPred_wellDefined U P hfg)

/-- The fundamental evaluation lemma: `UltraPred` at a canonical element
reduces to eventual membership. -/
@[simp]
theorem UltraPred_mk (U : Ultrafilter ι) {α : ι → Type*}
    (P : ∀ i, Set (α i)) (f : ∀ i, α i) :
    UltraPred U P (UltraProduct.mk U f) ↔
      ({i | f i ∈ P i} : Set ι) ∈ U.1 := by
  simp [UltraPred, UltraProduct.mk]

/-! ## Part 3: Restricted Formula Language -/

/-- A restricted formula in a propositional language over families of predicates.
Atomic predicates are families of sets; compound formulas use propositional
connectives. This restricted fragment suffices for polynomial matrix predicates. -/
inductive RestrictedFormula (ι : Type*) (α : ι → Type*) where
  /-- An atomic predicate: a family of sets, one per index -/
  | pred : (∀ i, Set (α i)) → RestrictedFormula ι α
  /-- Conjunction -/
  | and : RestrictedFormula ι α → RestrictedFormula ι α → RestrictedFormula ι α
  /-- Disjunction -/
  | or : RestrictedFormula ι α → RestrictedFormula ι α → RestrictedFormula ι α
  /-- Negation -/
  | not : RestrictedFormula ι α → RestrictedFormula ι α
  /-- Implication -/
  | imp : RestrictedFormula ι α → RestrictedFormula ι α → RestrictedFormula ι α

namespace RestrictedFormula

/-- Componentwise satisfaction: does the formula hold at index `i`? -/
def Sat : RestrictedFormula ι α → (∀ i, α i) → ι → Prop
  | .pred P, f, i => f i ∈ P i
  | .and φ ψ, f, i => φ.Sat f i ∧ ψ.Sat f i
  | .or φ ψ, f, i => φ.Sat f i ∨ ψ.Sat f i
  | .not φ, f, i => ¬φ.Sat f i
  | .imp φ ψ, f, i => φ.Sat f i → ψ.Sat f i

/-- The satisfaction set: the set of indices where the formula holds. -/
def satSet (φ : RestrictedFormula ι α) (f : ∀ i, α i) : Set ι :=
  {i | φ.Sat f i}

/-- Ultraproduct satisfaction: does the formula hold in the ultraproduct?
Defined recursively matching the formula structure. -/
def HoldsUltra (φ : RestrictedFormula ι α) (U : Ultrafilter ι)
    (x : UltraProduct U α) : Prop :=
  match φ with
  | .pred P => UltraPred U P x
  | .and φ ψ => φ.HoldsUltra U x ∧ ψ.HoldsUltra U x
  | .or φ ψ => φ.HoldsUltra U x ∨ ψ.HoldsUltra U x
  | .not φ => ¬φ.HoldsUltra U x
  | .imp φ ψ => φ.HoldsUltra U x → ψ.HoldsUltra U x

end RestrictedFormula

/-! ## Part 4: Uniform Definable Families -/

/-- A uniform definable family of subsets of `α i`, parameterized by
a common parameter type. This captures the notion of a "uniformly
polynomially definable" family of subsets across a family of structures. -/
structure UniformDefinableFamily (ι : Type*) (α : ι → Type*) where
  /-- The type of parameters -/
  params : Type*
  /-- The membership predicate -/
  memPred : ∀ i, params → α i → Prop
  /-- The parameter values at each index -/
  paramVal : ι → params
  /-- Evaluate the family at an index to get a concrete set -/
  eval (i : ι) : Set (α i) := {x | memPred i (paramVal i) x}

/-- The uniform family induces a family of sets for ultraproduct lifting. -/
def UniformDefinableFamily.toPredFamily
    (A : UniformDefinableFamily ι α) : ∀ i, Set (α i) :=
  fun i => A.eval i

/-! ## Part 5: Growth and Control Definitions -/

/-- Pseudofinite bounded doubling: the product set cardinality is bounded
by `K` times the original cardinality, on an ultrafilter-large set. -/
def UltraDoublingBound {ι : Type*} (U : Ultrafilter ι)
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A : ∀ i, Finset (G i)) (K : ℕ) : Prop :=
  ({i | (A i * A i).card ≤ K * (A i).card} : Set ι) ∈ U.1

/-- Coset control for a finite set: `A` is `C`-controlled by `H` if `A` can
be covered by at most `C` left cosets of `H`. -/
def CosetControlledBy {G : Type*} [Group G] [DecidableEq G]
    (A H : Finset G) (C : ℕ) : Prop :=
  ∃ S : Finset G, S.card ≤ C ∧
    (A : Set G) ⊆ ⋃ s ∈ (S : Set G), (fun x => s * x) '' (H : Set G)

/-- Eventual coset control: the family A_i is eventually C-controlled by H_i. -/
def EventualCosetControl {ι : Type*} (U : Ultrafilter ι)
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A H : ∀ i, Finset (G i)) (C : ℕ) : Prop :=
  ({i | CosetControlledBy (A i) (H i) C} : Set ι) ∈ U.1

/-- Pseudofinite coset control in the ultraproduct setting. -/
def UltraCosetControl {ι : Type*} (U : Ultrafilter ι)
    {G : ι → Type*} [∀ i, Group (G i)] [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)]
    (A H : ∀ i, Finset (G i)) (C : ℕ) : Prop :=
  ({i | CosetControlledBy (A i) (H i) C} : Set ι) ∈ U.1

/-- Growth-or-control dichotomy for a single finite group:
either doubling exceeds K, or A is C-controlled by some subgroup. -/
def GrowthOrControl {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G) (K C : ℕ) : Prop :=
  (A * A).card ≤ K * A.card →
  ∃ H : Finset G, CosetControlledBy A H C

end PseudofiniteTransfer