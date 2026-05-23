import Mathlib

/-!
# Sandwich Certificate Definitions

Core definitions for the monotone circuit sandwich framework:
certified sandwich families, completeness, and the certificate partial order.
-/

noncomputable section
open Classical

namespace SandwichUniversality

/-- A **monotone circuit profile** abstracts a monotone Boolean circuit
    to its size and evaluation function, with a monotonicity witness. -/
structure MonoCircuitProfile (α : Type*) [Preorder α] where
  size : ℕ
  eval : α → Bool
  mono_eval : Monotone eval

/-- A **certified sandwich family** for a Boolean function `f` consists of
    positive witnesses (where `f = true`) and negative witnesses (where `f = false`). -/
structure CertifiedSandwichFamily (α : Type*) [Preorder α] [Fintype α]
    (f : α → Bool) where
  Pos : Finset α
  Neg : Finset α
  pos_spec : ∀ x ∈ Pos, f x = true
  neg_spec : ∀ x ∈ Neg, f x = false

/-- A sandwich family **hits** a circuit if some witness disagrees with it. -/
def SandwichHitsCircuit {α : Type*} [Preorder α] [Fintype α]
    (f : α → Bool) (S : CertifiedSandwichFamily α f)
    (C : MonoCircuitProfile α) : Prop :=
  (∃ x ∈ S.Pos, C.eval x = false ∧ f x = true) ∨
  (∃ x ∈ S.Neg, C.eval x = true ∧ f x = false)

/-- A sandwich family is **complete up to size `s`** if it hits every
    monotone circuit of size ≤ `s`. -/
def SandwichCompleteUpTo {α : Type*} [Preorder α] [Fintype α]
    (f : α → Bool) (S : CertifiedSandwichFamily α f) (s : ℕ) : Prop :=
  ∀ C : MonoCircuitProfile α, C.size ≤ s → SandwichHitsCircuit f S C

/-- Pull back a sandwich family along an embedding. -/
def CertifiedSandwichFamily.pullback
    {α β : Type*} [Preorder α] [Preorder β] [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    {fβ : β → Bool}
    (S : CertifiedSandwichFamily β fβ)
    (e : α ↪ β) (fα : α → Bool)
    (hfun : ∀ x, fα x = fβ (e x)) :
    CertifiedSandwichFamily α fα where
  Pos := Finset.univ.filter (fun a => e a ∈ S.Pos)
  Neg := Finset.univ.filter (fun a => e a ∈ S.Neg)
  pos_spec := by
    intro x hx
    simp at hx
    rw [hfun]
    exact S.pos_spec _ hx
  neg_spec := by
    intro x hx
    simp at hx
    rw [hfun]
    exact S.neg_spec _ hx

/-- The certificate ordering: `S₁ ≤ S₂` iff `S₁.Pos ⊆ S₂.Pos ∧ S₁.Neg ⊆ S₂.Neg`. -/
def CertificateLE {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool}
    (S₁ S₂ : CertifiedSandwichFamily α f) : Prop :=
  S₁.Pos ⊆ S₂.Pos ∧ S₁.Neg ⊆ S₂.Neg

theorem certificateLE_refl {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool} (S : CertifiedSandwichFamily α f) :
    CertificateLE S S :=
  ⟨Finset.Subset.refl _, Finset.Subset.refl _⟩

theorem certificateLE_trans {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool} (S₁ S₂ S₃ : CertifiedSandwichFamily α f)
    (h₁₂ : CertificateLE S₁ S₂) (h₂₃ : CertificateLE S₂ S₃) :
    CertificateLE S₁ S₃ :=
  ⟨h₁₂.1.trans h₂₃.1, h₁₂.2.trans h₂₃.2⟩

theorem completeness_mono_certificate
    {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool}
    (S₁ S₂ : CertifiedSandwichFamily α f)
    (hle : CertificateLE S₁ S₂)
    {s : ℕ}
    (hcomp : SandwichCompleteUpTo f S₁ s) :
    SandwichCompleteUpTo f S₂ s := by
  intro C hC
  rcases hcomp C hC with (⟨x, hx₁, hx₂, hx₃⟩ | ⟨x, hx₁, hx₂, hx₃⟩)
  · exact Or.inl ⟨x, hle.1 hx₁, hx₂, hx₃⟩
  · exact Or.inr ⟨x, hle.2 hx₁, hx₂, hx₃⟩

end SandwichUniversality