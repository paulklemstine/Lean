/-
# Sandwich Certificates: Definitions

This file was previously an unresolved pointer (`../../Pythagorean/SandwichDefs.lean`)
and therefore did not compile.  It is restored here with the definitions that
`Pythagorean.PosetTheory.CertificatePosetWQO` (Section 11) consumes:
the type of certified sandwich families, the certificate ordering, the notion of
completeness, and monotonicity of completeness along the certificate order.

A *sandwich certificate family* for a Boolean function `f : α → Bool` on a
preordered finite type records a finite set `Pos` of witnesses on which `f` is
true and a finite set `Neg` of witnesses on which `f` is false.  A point `x` is
*decided* by the family when some positive witness sits below it or some
negative witness sits above it — i.e. when `x` is sandwiched by the recorded
witnesses.  Enlarging the family can only decide more points, which is the
monotonicity principle the certificate poset is built on.
-/

import Mathlib

noncomputable section

open Classical Finset

namespace SandwichUniversality

variable {α : Type*} [Preorder α] [Fintype α] [DecidableEq α] {f : α → Bool}

/-- A family of positive and negative witnesses for the Boolean function `f`. -/
structure CertifiedSandwichFamily (α : Type*) [Preorder α] [Fintype α]
    [DecidableEq α] (f : α → Bool) where
  /-- Points at which `f` is known to be true. -/
  Pos : Finset α
  /-- Points at which `f` is known to be false. -/
  Neg : Finset α
  /-- Positive witnesses really are positive. -/
  pos_true : ∀ x ∈ Pos, f x = true
  /-- Negative witnesses really are negative. -/
  neg_false : ∀ x ∈ Neg, f x = false

/-- The certificate ordering: one family refines another when it contains all of
its positive and all of its negative witnesses. -/
def CertificateLE (S₁ S₂ : CertifiedSandwichFamily α f) : Prop :=
  S₁.Pos ⊆ S₂.Pos ∧ S₁.Neg ⊆ S₂.Neg

theorem certificateLE_refl (S : CertifiedSandwichFamily α f) :
    CertificateLE S S :=
  ⟨Finset.Subset.refl _, Finset.Subset.refl _⟩

theorem certificateLE_trans {S₁ S₂ S₃ : CertifiedSandwichFamily α f}
    (h₁ : CertificateLE S₁ S₂) (h₂ : CertificateLE S₂ S₃) :
    CertificateLE S₁ S₃ :=
  ⟨h₁.1.trans h₂.1, h₁.2.trans h₂.2⟩

/-- No point can be both a positive and a negative witness. -/
theorem pos_disjoint_neg (S : CertifiedSandwichFamily α f) :
    Disjoint S.Pos S.Neg := by
  rw [Finset.disjoint_left]
  intro x hx hx'
  have h1 := S.pos_true x hx
  have h2 := S.neg_false x hx'
  simp [h1] at h2

/-- `x` is *decided* by the family when it is sandwiched by recorded witnesses:
a positive witness lies below it, or a negative witness lies above it. -/
def Decided (S : CertifiedSandwichFamily α f) (x : α) : Prop :=
  (∃ p ∈ S.Pos, p ≤ x) ∨ (∃ n ∈ S.Neg, x ≤ n)

/-- The finite set of points decided by a family. -/
def decidedSet (S : CertifiedSandwichFamily α f) : Finset α :=
  Finset.univ.filter (fun x => Decided S x)

theorem mem_decidedSet {S : CertifiedSandwichFamily α f} {x : α} :
    x ∈ decidedSet S ↔ Decided S x := by
  simp [decidedSet]

/-- Refining the certificate family decides more points. -/
theorem decided_mono {S₁ S₂ : CertifiedSandwichFamily α f}
    (h : CertificateLE S₁ S₂) {x : α} (hx : Decided S₁ x) : Decided S₂ x := by
  rcases hx with ⟨p, hp, hpx⟩ | ⟨n, hn, hxn⟩
  · exact Or.inl ⟨p, h.1 hp, hpx⟩
  · exact Or.inr ⟨n, h.2 hn, hxn⟩

theorem decidedSet_subset {S₁ S₂ : CertifiedSandwichFamily α f}
    (h : CertificateLE S₁ S₂) : decidedSet S₁ ⊆ decidedSet S₂ := by
  intro x hx
  exact mem_decidedSet.2 (decided_mono h (mem_decidedSet.1 hx))

/-- A family is *complete up to `s`* when it decides at least `s` points. -/
def SandwichCompleteUpTo (f : α → Bool) (S : CertifiedSandwichFamily α f)
    (s : ℕ) : Prop :=
  s ≤ (decidedSet S).card

/-- **Completeness is monotone along the certificate order.** -/
theorem completeness_mono_certificate (S₁ S₂ : CertifiedSandwichFamily α f)
    (h : CertificateLE S₁ S₂) {s : ℕ} (hs : SandwichCompleteUpTo f S₁ s) :
    SandwichCompleteUpTo f S₂ s :=
  hs.trans (Finset.card_le_card (decidedSet_subset h))

/-- Every family is complete up to `0`, and a family that decides every point of
a finite type is complete up to the cardinality of that type. -/
theorem sandwichCompleteUpTo_card_of_forall
    (S : CertifiedSandwichFamily α f) (h : ∀ x : α, Decided S x) :
    SandwichCompleteUpTo f S (Fintype.card α) := by
  have : decidedSet S = Finset.univ := by
    apply Finset.eq_univ_of_forall
    intro x; exact mem_decidedSet.2 (h x)
  simp [SandwichCompleteUpTo, this, Finset.card_univ]

end SandwichUniversality

end