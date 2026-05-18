/-
# HoTT Foundations: Basic Definitions

Core definitions for Homotopy Type Theory in Lean 4:
- Contractible types
- Fibers
- Quasi-equivalences (QEquiv)
- Singleton contraction

These form the foundational vocabulary on which the fundamental theorem
of identity types and the characterization of equivalences are built.
-/

import Mathlib

universe u v w

namespace HoTT

/-! ## Contractible types -/

/-- A type is contractible if it has a center of contraction and every element
    equals that center. This is the HoTT notion: a type with exactly one
    element up to paths. -/
def isContr (X : Sort u) : Prop :=
  ∃ center : X, ∀ y : X, y = center

/-! ## Fibers -/

/-- The homotopy fiber of `f` over `b`: the type of pairs `(a, p)` where
    `f a = b`. This is the central notion connecting functions to their
    homotopy-theoretic properties. -/
def fiber {A : Sort u} {B : Sort v} (f : A → B) (b : B) :=
  Σ' a : A, f a = b

/-! ## Quasi-equivalences -/

/-- A quasi-equivalence between types: a function with a two-sided inverse.
    This is the standard notion of equivalence in HoTT, capturing the idea
    that two types have "the same shape." -/
structure QEquiv (A : Sort u) (B : Sort v) where
  toFun    : A → B
  invFun   : B → A
  leftInv  : ∀ a : A, invFun (toFun a) = a
  rightInv : ∀ b : B, toFun (invFun b) = b

infixl:25 " ≃q " => QEquiv

namespace QEquiv

/-- The identity equivalence. -/
def refl (A : Sort u) : A ≃q A :=
  ⟨id, id, fun _ => Eq.refl _, fun _ => Eq.refl _⟩

/-- The inverse of an equivalence. -/
def symm {A : Sort u} {B : Sort v} (e : A ≃q B) : B ≃q A :=
  ⟨e.invFun, e.toFun, e.rightInv, e.leftInv⟩

/-- Composition of equivalences. -/
def trans {A : Sort u} {B : Sort v} {C : Sort w}
    (e₁ : A ≃q B) (e₂ : B ≃q C) : A ≃q C where
  toFun := e₂.toFun ∘ e₁.toFun
  invFun := e₁.invFun ∘ e₂.invFun
  leftInv a := by simp [Function.comp]; rw [e₂.leftInv, e₁.leftInv]
  rightInv c := by simp [Function.comp]; rw [e₁.rightInv, e₂.rightInv]

end QEquiv

/-! ## Singleton contraction -/

/-- The total space of pointed paths `Σ x, a = x` is contractible.
    This is one of the most basic facts in HoTT: the "based path space"
    centered at `a` has a unique element up to paths. -/
theorem singletonContraction {A : Sort u} (a : A) :
    isContr (Σ' x : A, a = x) := by
  refine ⟨⟨a, rfl⟩, ?_⟩
  intro ⟨x, p⟩
  cases p
  rfl

/-- The "reversed" singleton contraction: `Σ x, x = a` is also contractible. -/
theorem singletonContraction' {A : Sort u} (a : A) :
    isContr (Σ' x : A, x = a) := by
  refine ⟨⟨a, rfl⟩, ?_⟩
  intro ⟨x, p⟩
  cases p
  rfl

/-! ## Basic contractibility lemmas -/

/-- A contractible type is a subsingleton (any two elements are equal). -/
theorem isContr_subsingleton {X : Sort u} (h : isContr X) :
    ∀ a b : X, a = b := by
  obtain ⟨c, hc⟩ := h
  intro a b
  rw [hc a, hc b]

/-- If `X` is contractible, we can extract the center. -/
noncomputable def isContr_center {X : Sort u} (h : isContr X) : X :=
  h.choose

/-- Transport along a path: if `P : A → Sort v` and `p : a = b`,
    we can move `P a → P b`. This is the fundamental operation of
    dependent type theory that HoTT elevates to a first-class concept. -/
def transport {A : Sort u} (P : A → Sort v) {a b : A} (p : a = b) : P a → P b :=
  p ▸ id

/-- Transport preserves contractibility. -/
theorem transport_isContr {A : Sort u} (P : A → Sort v) {a b : A}
    (p : a = b) (h : isContr (P a)) : isContr (P b) := by
  subst p; exact h

/-! ## Sigma type lemmas -/

/-- Equality of sigma types from component equalities. -/
theorem psigma_eq {A : Sort u} {B : A → Sort v}
    {p q : Σ' a, B a} (h₁ : p.1 = q.1) (h₂ : transport B h₁ p.2 = q.2) :
    p = q := by
  cases p with | mk a b =>
  cases q with | mk a' b' =>
  simp at h₁
  subst h₁
  simp [transport] at h₂
  subst h₂
  rfl

/-! ## Equivalence preserves properties -/

/-- An equivalence preserves contractibility. -/
theorem qequiv_preserves_isContr {A : Sort u} {B : Sort v}
    (e : A ≃q B) (h : isContr A) : isContr B := by
  obtain ⟨c, hc⟩ := h
  exact ⟨e.toFun c, fun y => by rw [← e.rightInv y]; congr 1; exact hc _⟩

/-- An equivalence preserves subsingletonhood (being a proposition). -/
theorem qequiv_preserves_subsingleton {A : Sort u} {B : Sort v}
    (e : A ≃q B) (h : ∀ a b : A, a = b) : ∀ a b : B, a = b := by
  intro a b
  have := h (e.invFun a) (e.invFun b)
  rw [← e.rightInv a, ← e.rightInv b]
  congr 1

end HoTT