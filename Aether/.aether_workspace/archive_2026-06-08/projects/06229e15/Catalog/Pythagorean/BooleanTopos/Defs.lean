/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Boolean Topos Characterization of Determinism: Definitions

This file defines the core structures for characterizing determinism
as Booleanity of the internal logic of the behavioral nerve of a
labeled transition system (LTS).

## Main Definitions

* `DiamondDistributive` — Diamond distributes over conjunction for all actions
* `NerveSubobject` — Observable state-trace properties closed under transition
* `IsNerveComplement` — Complementarity of nerve subobjects
* `HasNerveExcludedMiddle` — Every nerve subobject has a complement
* `SelfBisimulation` — Bisimulation relation on a single LTS
* `SelfBisimilar` — Two states are bisimilar within the same LTS
* `BisimClosure` — Closure of a state predicate under bisimilarity
* `IsIdentityClosure` — Bisimulation closure acts as identity on all predicates

## Mathematical Context

The central insight is that **determinism = classical internal logic**:

- In a deterministic LTS, the diamond modality ⟨a⟩ distributes over
  conjunction, making the modal algebra Boolean.
- In a nondeterministic LTS, branching creates witnesses where
  ⟨a⟩(P ∧ Q) ⊊ ⟨a⟩P ∧ ⟨a⟩Q, a non-Boolean/non-distributive phenomenon
  analogous to quantum superposition.
- The bisimulation quotient topology is trivial (identity) exactly when
  the LTS is deterministic — nondeterminism creates nontrivial
  identifications that manifest as a non-identity closure operator.

This establishes a **logical taxonomy of computational systems** by their
subobject logic: deterministic = Boolean, nondeterministic = Heyting.
-/

import Pythagorean.TemporalAdjunction.Defs

namespace BooleanTopos

open TemporalAdjunction

universe u

variable {Act : Type u}

/-! ## Diamond Distributivity: The Boolean Criterion -/

/-- **Diamond Distributivity**: The diamond modality ⟨a⟩ distributes
    over conjunction (intersection) for all actions and all state predicates.

    This is the finite-model proxy for Booleanity of the subobject
    lattice in the nerve presheaf topos. In a Boolean topos, all
    lattice operations distribute; the failure of diamond to distribute
    over ∧ is the signature of non-Boolean internal logic.

    Categorically, this says the left adjoint (existential image) in the
    adjunction triple ⟨a⟩ ⊣ (ext_a)* ⊣ [a] preserves finite limits,
    which happens exactly when the transition relation is functional
    (i.e., deterministic). -/
def DiamondDistributive (L : LTS Act) : Prop :=
  ∀ (a : Act) (P Q : Set L.State),
    ltsDiamond L a (P ∩ Q) = ltsDiamond L a P ∩ ltsDiamond L a Q

/-! ## Nerve Subobjects: Observable Properties -/

/-- A **nerve subobject** of an LTS is a state predicate representing an
    observable behavioral property. This is the finite combinatorial proxy
    for a subobject of the nerve presheaf.

    The nerve of an LTS is the presheaf sending each trace to the set of
    states that can execute it. A subobject of this presheaf (a sub-presheaf)
    is determined at the state level by a predicate on states, with the
    morphism structure inherited from the LTS transitions.

    We wrap `Set L.State` to give it the intended categorical interpretation
    and to define the modal operations on it. -/
structure NerveSubobject (L : LTS Act) where
  /-- The carrier: a predicate on states -/
  carrier : Set L.State

namespace NerveSubobject

variable {L : LTS Act}

/-- The top nerve subobject: all states. -/
def top : NerveSubobject L := ⟨Set.univ⟩

/-- The bottom nerve subobject: no states. -/
def bot : NerveSubobject L := ⟨∅⟩

/-- Meet (conjunction) of nerve subobjects. -/
def inf (S T : NerveSubobject L) : NerveSubobject L :=
  ⟨S.carrier ∩ T.carrier⟩

/-- Join (disjunction) of nerve subobjects. -/
def sup (S T : NerveSubobject L) : NerveSubobject L :=
  ⟨S.carrier ∪ T.carrier⟩

/-- Complement of a nerve subobject. -/
def compl (S : NerveSubobject L) : NerveSubobject L :=
  ⟨S.carrierᶜ⟩

/-- The diamond lift of a nerve subobject through action `a`:
    `⟨a⟩S = {s | ∃ t, step s a t ∧ t ∈ S}` -/
def diamond (a : Act) (S : NerveSubobject L) : NerveSubobject L :=
  ⟨ltsDiamond L a S.carrier⟩

/-- The box lift of a nerve subobject through action `a`:
    `[a]S = {s | ∀ t, step s a t → t ∈ S}` -/
def boxOp (a : Act) (S : NerveSubobject L) : NerveSubobject L :=
  ⟨ltsBox L a S.carrier⟩

/-- Extensional equality of nerve subobjects. -/
theorem ext {S T : NerveSubobject L} (h : S.carrier = T.carrier) : S = T := by
  cases S; cases T; congr

/-- The diamond operation on nerve subobjects agrees with ltsDiamond. -/
theorem diamond_carrier (a : Act) (S : NerveSubobject L) :
    (S.diamond a).carrier = ltsDiamond L a S.carrier := rfl

end NerveSubobject

/-! ## Complementarity and Excluded Middle -/

/-- Two nerve subobjects are **complementary** if they partition the state space:
    their meet is bottom and their join is top. This is the lattice-theoretic
    formulation of excluded middle for the pair (S, T). -/
def IsNerveComplement (S T : NerveSubobject L) : Prop :=
  S.inf T = NerveSubobject.bot ∧ S.sup T = NerveSubobject.top

/-- **Modal Excluded Middle** for an LTS: the diamond modality preserves
    complementation, meaning that for every observable S and every action a,
    ⟨a⟩S and ⟨a⟩(Sᶜ) are "complementary modulo observability".

    More precisely, this says diamond distributes over conjunction,
    which is the Booleanity condition for the modal algebra. -/
def HasModalExcludedMiddle (L : LTS Act) : Prop :=
  ∀ (a : Act) (S : NerveSubobject L),
    (S.diamond a).inf (S.compl.diamond a) =
    (S.inf S.compl).diamond a

/-! ## Self-Bisimulation -/

/-- A relation R on states of a single LTS is a **self-bisimulation** if
    it satisfies the zigzag condition: related states can match each other's
    transitions while preserving R. -/
structure SelfBisimulation (L : LTS Act) (R : L.State → L.State → Prop) : Prop where
  /-- Forward: if R s t and s →[a] s', then ∃ t' with t →[a] t' and R s' t' -/
  zig : ∀ s t a s', R s t → L.step s a s' → ∃ t', L.step t a t' ∧ R s' t'
  /-- Backward: if R s t and t →[a] t', then ∃ s' with s →[a] s' and R s' t' -/
  zag : ∀ s t a t', R s t → L.step t a t' → ∃ s', L.step s a s' ∧ R s' t'

/-- Two states of the same LTS are **bisimilar** if there exists a
    self-bisimulation relating them. -/
def SelfBisimilar (L : LTS Act) (s t : L.State) : Prop :=
  ∃ R : L.State → L.State → Prop, SelfBisimulation L R ∧ R s t

/-- **Bisimulation closure** of a state predicate: the set of all states
    bisimilar to some state in the original predicate.

    This is the closure operator on `Set L.State` induced by the
    bisimilarity equivalence relation. In topos-theoretic terms, it
    corresponds to the Lawvere–Tierney topology associated with the
    bisimulation quotient. -/
def BisimClosure (L : LTS Act) (P : Set L.State) : Set L.State :=
  {t | ∃ s ∈ P, SelfBisimilar L s t}

/-- The bisimulation closure is the **identity operator** on all predicates.
    This means bisimilarity implies equality of states — the
    Lawvere–Tierney topology is trivial.

    In categorical terms, the associated sheaf condition is trivially
    satisfied, meaning every presheaf is already a sheaf. -/
def IsIdentityClosure (L : LTS Act) : Prop :=
  ∀ P : Set L.State, BisimClosure L P = P

/-- **Bisimilarity is equality**: an equivalent formulation of
    the identity closure condition. -/
def BisimIsEquality (L : LTS Act) : Prop :=
  ∀ s t : L.State, SelfBisimilar L s t → s = t

/-! ## Total LTS -/

/-- An LTS is **total** for action `a` at state `s` if there exists
    at least one `a`-successor of `s`. -/
def TotalAt (L : LTS Act) (s : L.State) (a : Act) : Prop :=
  ∃ t, L.step s a t

/-- An LTS is **total** if every state has at least one successor for
    every action. -/
def TotalLTS (L : LTS Act) : Prop :=
  ∀ s a, TotalAt L s a

end BooleanTopos