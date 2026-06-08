/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Adjunction: Definitions

This file defines the core structures for the Temporal Adjunction framework,
which interprets the Hennessy-Milner diamond ⟨a⟩ and box [a] modalities as
the left and right adjoints to the pullback along trace extension morphisms
in the presheaf topos PSh(Exp_Act).

## Main Definitions

* `TraceProp` — Trace-indexed propositions (subobjects of the terminal presheaf)
* `pullbackExt` — Pullback along trace extension by action a
* `diamond` — Diamond modality ⟨a⟩ (left adjoint to pullback)
* `box` — Box modality [a] (right adjoint to pullback)
* `diamondMulti` / `boxMulti` — Multi-step modalities for trace words
* `TraceSieve` — Upward-closed trace predicates (sieves in the experiment category)
* `heytingImpl` — Heyting implication on sieves (temporal "unless" operator)
* `ltsDiamond` / `ltsBox` — State-level modalities for labeled transition systems

## Mathematical Context

In the presheaf topos PSh(Exp_Act) over the category of finite traces,
the trace extension morphism ext_a : σ → σ·a induces a pullback functor
(ext_a)^* on subobjects. The diamond ⟨a⟩ is its left adjoint and the box
[a] is its right adjoint, giving the adjunction triple:

    ⟨a⟩ ⊣ (ext_a)^* ⊣ [a]

The Heyting implication in the subobject classifier Ω recovers the temporal
"unless" operator, connecting topos-internal logic to temporal logic.
-/

import Mathlib

namespace TemporalAdjunction

universe u

variable {Act : Type*}

/-! ## Labeled Transition Systems

We include self-contained LTS definitions to avoid dependency on external
catalog files, while maintaining compatibility with the YonedaBisimulation
framework. -/

/-- A labeled transition system over action type `Act` with state type `State`. -/
structure LTS (Act : Type u) where
  /-- The type of states -/
  State : Type u
  /-- The transition relation: `step s a s'` means state `s` can transition
      to state `s'` via action `a` -/
  step : State → Act → State → Prop

/-- A trace is a finite sequence of actions. -/
abbrev Trace (Act : Type u) := List Act

/-- Hennessy-Milner logic formulas. -/
inductive HMFormula (Act : Type*) : Type _ where
  | tt : HMFormula Act
  | conj : HMFormula Act → HMFormula Act → HMFormula Act
  | neg : HMFormula Act → HMFormula Act
  | diamond : Act → HMFormula Act → HMFormula Act

/-- Satisfaction relation for HM formulas. -/
def HMSatisfies {Act : Type*} (P : LTS Act) : P.State → HMFormula Act → Prop
  | _, HMFormula.tt => True
  | s, HMFormula.conj φ ψ => HMSatisfies P s φ ∧ HMSatisfies P s ψ
  | s, HMFormula.neg φ => ¬ HMSatisfies P s φ
  | s, HMFormula.diamond a φ => ∃ s', P.step s a s' ∧ HMSatisfies P s' φ

/-- Two states are HM-equivalent if they satisfy the same formulas. -/
def HMEquiv {Act : Type*} (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∀ φ : HMFormula Act, HMSatisfies P s φ ↔ HMSatisfies Q t φ

/-! ## Trace-Level Propositions and Modal Operations -/

/-- A trace-indexed proposition: a predicate on finite traces.
    In the presheaf topos PSh(Exp_Act), this corresponds to a global section
    of a subobject of the terminal presheaf. -/
abbrev TraceProp (Act : Type*) := List Act → Prop

/-- Pointwise conjunction of trace propositions. -/
def TraceProp.conj (P Q : TraceProp Act) : TraceProp Act :=
  fun σ => P σ ∧ Q σ

/-- Pointwise disjunction of trace propositions. -/
def TraceProp.disj (P Q : TraceProp Act) : TraceProp Act :=
  fun σ => P σ ∨ Q σ

/-- Pointwise negation of trace propositions. -/
def TraceProp.neg (P : TraceProp Act) : TraceProp Act :=
  fun σ => ¬ P σ

/-! ## The Adjunction Triple: ⟨a⟩ ⊣ (ext_a)^* ⊣ [a] -/

/-- Pullback along trace extension by action `a`:
    `(ext_a)^*(P)(σ) = P(σ ++ [a])`.
    This is the inverse image functor along the morphism `ext_a : σ → σ·a`
    in the experiment category. -/
def pullbackExt (a : Act) (P : TraceProp Act) : TraceProp Act :=
  fun σ => P (σ ++ [a])

/-- **Diamond modality** ⟨a⟩ (left adjoint to pullback):
    `⟨a⟩P(τ) ≡ ∃ σ, τ = σ ++ [a] ∧ P(σ)`.
    At the trace level, the diamond says: "this trace ends with action `a`,
    and the property P held before that action." -/
def diamond (a : Act) (P : TraceProp Act) : TraceProp Act :=
  fun τ => ∃ σ, τ = σ ++ [a] ∧ P σ

/-- **Box modality** [a] (right adjoint to pullback):
    `[a]P(τ) ≡ ∀ σ, τ = σ ++ [a] → P(σ)`.
    At the trace level, the box says: "if this trace ends with action `a`,
    then the property P necessarily held before that action." -/
def box (a : Act) (P : TraceProp Act) : TraceProp Act :=
  fun τ => ∀ σ, τ = σ ++ [a] → P σ

/-! ## Multi-Step Modalities -/

/-- Multi-step diamond: `⟨w⟩P(τ) ≡ ∃ σ, τ = σ ++ w ∧ P(σ)`. -/
def diamondMulti (w : List Act) (P : TraceProp Act) : TraceProp Act :=
  fun τ => ∃ σ, τ = σ ++ w ∧ P σ

/-- Multi-step box: `[w]P(τ) ≡ ∀ σ, τ = σ ++ w → P(σ)`. -/
def boxMulti (w : List Act) (P : TraceProp Act) : TraceProp Act :=
  fun τ => ∀ σ, τ = σ ++ w → P σ

/-! ## Sieves and the Heyting Algebra -/

/-- A trace predicate is **upward-closed** (a sieve on σ in the experiment category)
    if whenever it holds for a trace and that trace is a prefix of another,
    it also holds for the extension. -/
def IsUpwardClosed (P : TraceProp Act) : Prop :=
  ∀ σ τ, P σ → σ <+: τ → P τ

/-- A **TraceSieve** rooted at σ is an upward-closed set of extensions of σ.
    This is a sieve on σ in the experiment category Exp_Act^op, and corresponds
    to an element of the subobject classifier Ω(σ) in the presheaf topos.

    This is a novel definition that bridges categorical sieve theory with
    temporal logic: each sieve encodes a "set of possible futures" from trace σ. -/
structure TraceSieve (Act : Type*) (σ : List Act) where
  /-- The carrier: a predicate on traces -/
  carrier : List Act → Prop
  /-- All elements of the sieve extend σ -/
  mem_extends : ∀ τ, carrier τ → σ <+: τ
  /-- The sieve is upward-closed: if τ ∈ S and τ ⊑ ρ, then ρ ∈ S -/
  upward_closed : ∀ τ ρ, carrier τ → τ <+: ρ → carrier ρ

/-- The maximal sieve on σ: all extensions of σ. -/
def TraceSieve.top (σ : List Act) : TraceSieve Act σ where
  carrier := fun τ => σ <+: τ
  mem_extends := fun _ h => h
  upward_closed := fun _ _ h1 h2 => List.IsPrefix.trans h1 h2

/-- The empty sieve on σ. -/
def TraceSieve.bot (σ : List Act) : TraceSieve Act σ where
  carrier := fun _ => False
  mem_extends := fun _ h => absurd h id
  upward_closed := fun _ _ h _ => absurd h id

/-- Intersection of sieves. -/
def TraceSieve.inf (S₁ S₂ : TraceSieve Act σ) : TraceSieve Act σ where
  carrier := fun τ => S₁.carrier τ ∧ S₂.carrier τ
  mem_extends := fun τ ⟨h, _⟩ => S₁.mem_extends τ h
  upward_closed := fun τ ρ ⟨h1, h2⟩ hpre =>
    ⟨S₁.upward_closed τ ρ h1 hpre, S₂.upward_closed τ ρ h2 hpre⟩

/-- Union of sieves. -/
def TraceSieve.sup (S₁ S₂ : TraceSieve Act σ) : TraceSieve Act σ where
  carrier := fun τ => S₁.carrier τ ∨ S₂.carrier τ
  mem_extends := fun τ h => by
    rcases h with h | h
    · exact S₁.mem_extends τ h
    · exact S₂.mem_extends τ h
  upward_closed := fun τ ρ h hpre => by
    rcases h with h | h
    · exact Or.inl (S₁.upward_closed τ ρ h hpre)
    · exact Or.inr (S₂.upward_closed τ ρ h hpre)

/-- The **Heyting implication** on trace predicates:
    `(P ⇒ Q)(σ) ≡ ∀ τ, σ <+: τ → P τ → Q τ`.

    This is the temporal **"unless"** operator: `P ⇒ Q` holds at trace σ
    if and only if, for all future extensions τ of σ, whenever P holds
    at τ then Q also holds at τ. -/
def heytingImpl (P Q : TraceProp Act) : TraceProp Act :=
  fun σ => ∀ τ, σ <+: τ → P τ → Q τ

/-- The **Heyting negation** on trace predicates:
    `¬ₕP(σ) ≡ ∀ τ, σ <+: τ → ¬P(τ)`.
    At σ, the Heyting negation of P holds iff P fails at all extensions of σ. -/
def heytingNeg (P : TraceProp Act) : TraceProp Act :=
  fun σ => ∀ τ, σ <+: τ → ¬ P τ

/-! ## LTS-Level Modalities -/

/-- The **diamond modality** on LTS states:
    `⟨a⟩P(s)` iff there exists an a-successor s' of s with s' ∈ P. -/
def ltsDiamond (L : LTS Act) (a : Act) (P : Set L.State) : Set L.State :=
  {s | ∃ s', L.step s a s' ∧ s' ∈ P}

/-- The **box modality** on LTS states:
    `[a]P(s)` iff all a-successors s' of s satisfy s' ∈ P. -/
def ltsBox (L : LTS Act) (a : Act) (P : Set L.State) : Set L.State :=
  {s | ∀ s', L.step s a s' → s' ∈ P}

/-- An LTS is **deterministic at state s for action a** if s has at most
    one a-successor. -/
def DeterministicAt (L : LTS Act) (s : L.State) (a : Act) : Prop :=
  ∀ s₁ s₂, L.step s a s₁ → L.step s a s₂ → s₁ = s₂

/-- An LTS is **fully deterministic** if every state is deterministic
    for every action. -/
def FullyDeterministic (L : LTS Act) : Prop :=
  ∀ s a, DeterministicAt L s a

/-- Convert an HM formula to a state predicate (set of satisfying states). -/
noncomputable def hmToPred (L : LTS Act) : HMFormula Act → Set L.State :=
  fun φ => {s | HMSatisfies L s φ}

end TemporalAdjunction