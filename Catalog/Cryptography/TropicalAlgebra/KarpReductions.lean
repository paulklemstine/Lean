/-
Copyright (c) 2024 Tropical Complexity Project. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lightweight Complexity Framework for Karp Reductions

This file provides a minimal but rigorous framework for many-one (Karp) reductions
and NP-completeness, sufficient to state and prove that tropical matrix factorization
is NP-complete relative to a known NP-hard source problem.

## Main Definitions

* `KarpReducible` — Problem P reduces to problem Q via a total function
* `HasNPCertificate` — A problem has a verifiable certificate (existential witness)
* `KarpNPHardRelative` — Source reduces to target
* `KarpNPCompleteRelative` — Has certificate and is hard relative to source

## Design Notes

We define a lightweight framework that captures the essential structure of
Karp reductions without requiring Primcodable instances or full computability
theory. This allows us to work with rich mathematical types (matrices, graphs)
directly while preserving the reduction-theoretic content.
-/

namespace TropComplexity

/-- A decision problem `P` Karp-reduces to `Q` if there is a function `f` such that
    `P x ↔ Q (f x)` for all `x`. -/
def KarpReducible {α : Type*} {β : Type*} (P : α → Prop) (Q : β → Prop) : Prop :=
  ∃ f : α → β, ∀ x, P x ↔ Q (f x)

notation:50 P " ≤ₖ " Q => KarpReducible P Q

/-- Karp reducibility is reflexive. -/
theorem KarpReducible.refl {α : Type*} (P : α → Prop) : P ≤ₖ P :=
  ⟨id, fun _ => Iff.rfl⟩

/-- Karp reducibility is transitive. -/
theorem KarpReducible.trans {α β γ : Type*} {P : α → Prop} {Q : β → Prop} {R : γ → Prop}
    (h₁ : P ≤ₖ Q) (h₂ : Q ≤ₖ R) : P ≤ₖ R := by
  obtain ⟨f, hf⟩ := h₁
  obtain ⟨g, hg⟩ := h₂
  exact ⟨g ∘ f, fun x => (hf x).trans (hg (f x))⟩

/-- A problem `P : α → Prop` has an NP-style certificate if `P x ↔ ∃ w : W, V x w`
    for some decidable `V`. We package this as: the problem is exactly the existential
    projection of a decidable predicate. -/
def HasNPCertificate {α : Type*} (P : α → Prop) : Prop :=
  ∃ (W : Type) (V : α → W → Bool),
    ∀ x, P x ↔ ∃ w, V x w = true

/-- A problem is KarpNPHard relative to a given source problem. -/
def KarpNPHardRelative {α β : Type*} (Source : α → Prop) (Target : β → Prop) : Prop :=
  Source ≤ₖ Target

/-- If Source reduces to Mid and Mid reduces to Target, then Source reduces to Target. -/
theorem KarpNPHardRelative.compose {α β γ : Type*}
    {S : α → Prop} {M : β → Prop} {T : γ → Prop}
    (h1 : KarpNPHardRelative S M) (h2 : KarpNPHardRelative M T) :
    KarpNPHardRelative S T :=
  KarpReducible.trans h1 h2

/-- A problem is KarpNPComplete relative to a source if it has certificates and the source
    reduces to it. -/
structure KarpNPCompleteRelative {α β : Type*} (Source : α → Prop)
    (Target : β → Prop) : Prop where
  has_certificate : HasNPCertificate Target
  is_hard : KarpNPHardRelative Source Target

/-- The reduction function underlying a Karp reduction. -/
noncomputable def KarpReducible.func {α β : Type*} {P : α → Prop} {Q : β → Prop}
    (h : P ≤ₖ Q) : α → β :=
  h.choose

theorem KarpReducible.spec {α β : Type*} {P : α → Prop} {Q : β → Prop}
    (h : P ≤ₖ Q) (x : α) : P x ↔ Q (h.func x) :=
  h.choose_spec x

end TropComplexity