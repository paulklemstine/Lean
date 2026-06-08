/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Tropical Büchi–Elgot Theorem: Core Definitions

This file establishes the foundational definitions for a tropical (min-plus)
analogue of the classical Büchi–Elgot theorem for finite words.

## Main Definitions

* `MinPlusAutomaton` — finite weighted automaton over the min-plus semiring
* `WMSOFormula` — weighted MSO formulas with tropical semantics
* `TropicallyRecognizable` — cost functions realized by min-plus automata
* `WMSODefinable` — cost functions definable by weighted MSO sentences

## Overview

In the tropical world:
- **truth** becomes **cost** (0 = true, ⊤ = false)
- **disjunction** becomes **minimization** (choosing the cheaper option)
- **conjunction** becomes **tropical addition** (accumulating costs)
- **existential quantification** becomes **optimization** (finding the cheapest witness)
-/

import Mathlib

namespace TropicalMSO

open Classical

/-- Weight type for tropical (min-plus) semiring computations.
    `0` represents "true" / zero cost, `⊤` represents "false" / infinite cost. -/
abbrev Weight := WithTop ℕ

/-! ## Min-Plus Automata -/

/-- A finite weighted automaton over the min-plus (tropical) semiring.
    States `Q` are finite, and weights are in `WithTop ℕ`. -/
structure MinPlusAutomaton (α : Type) where
  /-- State type -/
  Q : Type
  /-- States form a finite type -/
  [instFintype : Fintype Q]
  /-- States have decidable equality -/
  [instDecEq : DecidableEq Q]
  /-- Initial weight for each state (⊤ means not an initial state) -/
  init : Q → Weight
  /-- Transition weight for (source, letter, target) triples -/
  step : Q → α → Q → Weight
  /-- Final/accepting weight for each state (⊤ means not accepting) -/
  final : Q → Weight

attribute [instance] MinPlusAutomaton.instFintype MinPlusAutomaton.instDecEq

/-- Cost of a run (sequence of states) through the automaton on a given word.
    The total cost is: init(q₀) + Σᵢ step(qᵢ, wᵢ, qᵢ₊₁) + final(qₙ).
    Any ⊤ component makes the entire run cost ⊤. -/
noncomputable def MinPlusAutomaton.runCost (A : MinPlusAutomaton α)
    (w : List α) (run : Fin (w.length + 1) → A.Q) : Weight :=
  A.init (run ⟨0, by omega⟩) +
  (Finset.univ.sum fun (i : Fin w.length) =>
    A.step (run ⟨i.val, by omega⟩) (w.get i) (run ⟨i.val + 1, by omega⟩)) +
  A.final (run ⟨w.length, by omega⟩)

/-- Evaluation of a min-plus automaton: the minimum cost over all possible runs.
    This implements the standard min-plus automaton semantics for finite words. -/
noncomputable def MinPlusAutomaton.eval (A : MinPlusAutomaton α)
    (w : List α) : Weight :=
  ⨅ (run : Fin (w.length + 1) → A.Q), A.runCost w run

/-- A cost function `f : List α → Weight` is **tropically recognizable** if there exists
    a finite min-plus automaton whose evaluation equals `f`. -/
def TropicallyRecognizable [Fintype α] [DecidableEq α]
    (f : List α → Weight) : Prop :=
  ∃ A : MinPlusAutomaton α, ∀ w, A.eval w = f w

/-! ## Weighted MSO Formulas -/

/-- Weighted MSO formulas over finite words with tropical semantics.

    The syntax mirrors classical MSO, but the semantics are tropicalized:
    - `bot` evaluates to `⊤` (infinite cost / false)
    - `top` evaluates to `0` (zero cost / true)
    - `letter a x` checks if position `x` has letter `a`
    - `mem x X` checks if position `x` is in set `X`
    - `le_pos x y` checks if position `x ≤ y`
    - `eq_pos x y` checks if position `x = y`
    - `succ x y` checks if `y = x + 1`
    - `and φ ψ` computes `φ + ψ` (tropical conjunction = cost accumulation)
    - `or φ ψ` computes `φ ⊓ ψ` (tropical disjunction = minimization)
    - `existsFO x φ` computes `⨅ᵢ φ[x↦i]` (minimize over positions)
    - `existsSO X φ` computes `⨅_S φ[X↦S]` (minimize over subsets)

    Variables are indexed by `Nat`. First-order variables range over word positions.
    Second-order variables range over finite sets of word positions. -/
inductive WMSOFormula (α : Type) : Type 1
  | bot : WMSOFormula α
  | top : WMSOFormula α
  | letter (a : α) (x : Nat) : WMSOFormula α
  | mem (x : Nat) (X : Nat) : WMSOFormula α
  | le_pos (x y : Nat) : WMSOFormula α
  | eq_pos (x y : Nat) : WMSOFormula α
  | succ (x y : Nat) : WMSOFormula α
  | and : WMSOFormula α → WMSOFormula α → WMSOFormula α
  | or : WMSOFormula α → WMSOFormula α → WMSOFormula α
  | existsFO (x : Nat) : WMSOFormula α → WMSOFormula α
  | existsSO (X : Nat) : WMSOFormula α → WMSOFormula α

/-- Semantics of a weighted MSO formula given a word and variable assignments.

    First-order assignment `σ : Nat → Nat` maps FO variables to positions.
    Second-order assignment `τ : Nat → Finset Nat` maps SO variables to sets of positions.

    Atomic predicates yield `0` when satisfied and `⊤` when not.
    Positions that fall outside the word bounds yield `⊤`. -/
noncomputable def WMSOFormula.evalWith [DecidableEq α] (φ : WMSOFormula α)
    (w : List α) (σ : Nat → Nat) (τ : Nat → Finset Nat) : Weight :=
  match φ with
  | .bot => ⊤
  | .top => 0
  | .letter a x =>
      if h : σ x < w.length then
        if w.get ⟨σ x, h⟩ = a then 0 else ⊤
      else ⊤
  | .mem x X => if σ x ∈ τ X then 0 else ⊤
  | .le_pos x y => if σ x ≤ σ y ∧ σ x < w.length ∧ σ y < w.length then 0 else ⊤
  | .eq_pos x y => if σ x = σ y ∧ σ x < w.length then 0 else ⊤
  | .succ x y => if σ y = σ x + 1 ∧ σ x < w.length ∧ σ y < w.length then 0 else ⊤
  | .and φ ψ => φ.evalWith w σ τ + ψ.evalWith w σ τ
  | .or φ ψ => φ.evalWith w σ τ ⊓ ψ.evalWith w σ τ
  | .existsFO x φ => ⨅ (i : Fin w.length), φ.evalWith w (Function.update σ x i.val) τ
  | .existsSO X φ =>
      ⨅ (S : Finset (Fin w.length)),
        φ.evalWith w σ (Function.update τ X (S.image Fin.val))

/-- Evaluation of a weighted MSO formula as a sentence (no free variables).
    Uses default assignments (position 0 for FO, empty set for SO). -/
noncomputable def WMSOFormula.eval [DecidableEq α] (φ : WMSOFormula α)
    (w : List α) : Weight :=
  φ.evalWith w (fun _ => 0) (fun _ => ∅)

/-- A cost function `f : List α → Weight` is **weighted MSO-definable** if there exists
    a weighted MSO formula whose evaluation (as a sentence) equals `f`. -/
def WMSODefinable [DecidableEq α] (f : List α → Weight) : Prop :=
  ∃ φ : WMSOFormula α, φ.eval = f

/-! ## Automaton Constructions -/

/-- Union automaton: computes the minimum of two automata's costs.
    States are the disjoint union `A.Q ⊕ B.Q`. -/
noncomputable def MinPlusAutomaton.union (A B : MinPlusAutomaton α) :
    MinPlusAutomaton α where
  Q := A.Q ⊕ B.Q
  init := Sum.elim A.init B.init
  step := fun s a t =>
    match s, t with
    | .inl q, .inl q' => A.step q a q'
    | .inr q, .inr q' => B.step q a q'
    | _, _ => ⊤
  final := Sum.elim A.final B.final

/-- Product automaton: computes the sum of two automata's costs.
    States are pairs `A.Q × B.Q`. -/
noncomputable def MinPlusAutomaton.product (A B : MinPlusAutomaton α) :
    MinPlusAutomaton α where
  Q := A.Q × B.Q
  init := fun ⟨q, r⟩ => A.init q + B.init r
  step := fun ⟨q, r⟩ a ⟨q', r'⟩ => A.step q a q' + B.step r a r'
  final := fun ⟨q, r⟩ => A.final q + B.final r

end TropicalMSO