/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Causal Closure Operators for Finite Reversible Systems

This file develops the theory of causal closure operators on partial orders
equipped with an involution (reversal). The key construction is the **combined
causal closure** operator, formed by composing forward closure with
backward closure, and the proof that it is idempotent when
the component closures commute.

## Main definitions

* `ClosureOp` — a bundled closure operator (extensive, monotone, idempotent)
* `InteriorOp` — a bundled interior operator (reductive, monotone, idempotent)
* `CausalClosureData` — forward closure + backward closure + involution
* `causalClosure` — the combined causal closure operator
* `CausalFixedPoint` — the subtype of elements fixed by causal closure

## Main results

* `combined_closure_idempotent_of_comm` — combined closure is idempotent when components commute
* `causalClosure_extensive` — causal closure is extensive
* `causalClosure_monotone` — causal closure is monotone
* `causalEquiv_equivalence` — causal equivalence is an equivalence relation
* `fixedPoint_equiv_completion` — fixed points biject with the causal completion
-/

import Mathlib

/-! ## Closure and Interior Operators -/

/-- A closure operator on a partial order: extensive, monotone, idempotent. -/
structure ClosureOp (α : Type*) [Preorder α] where
  /-- The closure function. -/
  cl : α → α
  /-- Closure is extensive: `a ≤ cl a`. -/
  le_cl : ∀ a, a ≤ cl a
  /-- Closure is monotone. -/
  cl_mono : Monotone cl
  /-- Closure is idempotent: `cl (cl a) = cl a`. -/
  cl_idem : ∀ a, cl (cl a) = cl a

/-- An interior operator on a partial order: reductive, monotone, idempotent. -/
structure InteriorOp (α : Type*) [Preorder α] where
  /-- The interior function. -/
  int : α → α
  /-- Interior is reductive: `int a ≤ a`. -/
  int_le : ∀ a, int a ≤ a
  /-- Interior is monotone. -/
  int_mono : Monotone int
  /-- Interior is idempotent: `int (int a) = int a`. -/
  int_idem : ∀ a, int (int a) = int a

namespace ClosureOp

variable {α : Type*} [Preorder α] (c : ClosureOp α)

/-- An element is a fixed point of the closure if `cl a = a`. -/
def IsFixed (a : α) : Prop := c.cl a = a

/-- `cl a` is always a fixed point. -/
theorem cl_isFixed (a : α) : c.IsFixed (c.cl a) := c.cl_idem a

/-- Closure applied to a fixed point is the identity. -/
theorem cl_fixed {a : α} (h : c.IsFixed a) : c.cl a = a := h

end ClosureOp

/-! ## Involutive Reversal -/

/-- An involution on a type. -/
structure OrderInvolution (α : Type*) where
  /-- The reversal function. -/
  rev : α → α
  /-- Reversal is involutive. -/
  rev_involutive : Function.Involutive rev

namespace OrderInvolution

variable {α : Type*} (ι : OrderInvolution α)

/-- Reversal is a bijection. -/
theorem rev_bijective : Function.Bijective ι.rev :=
  ι.rev_involutive.bijective

/-- Applying reversal twice yields the identity. -/
@[simp]
theorem rev_rev (a : α) : ι.rev (ι.rev a) = a := ι.rev_involutive a

end OrderInvolution

/-! ## Causal Closure Data -/

/-- The data for a causal closure system: forward closure, backward closure, and reversal. -/
structure CausalClosureData (α : Type*) [Preorder α] where
  /-- Forward closure operator. -/
  fwd : ClosureOp α
  /-- Backward closure operator. -/
  bwd : ClosureOp α
  /-- Time reversal involution. -/
  inv : OrderInvolution α

namespace CausalClosureData

variable {α : Type*} [PartialOrder α] (D : CausalClosureData α)

/-- The combined causal closure: apply forward closure then backward closure. -/
def causalClosure : α → α := D.bwd.cl ∘ D.fwd.cl

/-- Causal closure is extensive. -/
theorem causalClosure_extensive (a : α) : a ≤ D.causalClosure a := by
  exact le_trans (D.fwd.le_cl a) (D.bwd.le_cl (D.fwd.cl a))

/-- Causal closure is monotone. -/
theorem causalClosure_monotone : Monotone D.causalClosure :=
  fun _ _ hab => D.bwd.cl_mono (D.fwd.cl_mono hab)

/-- When forward and backward closures commute, causal closure is idempotent.
    This is the central algebraic lemma. -/
theorem causalClosure_idempotent
    (comm : D.fwd.cl ∘ D.bwd.cl = D.bwd.cl ∘ D.fwd.cl) :
    ∀ a, D.causalClosure (D.causalClosure a) = D.causalClosure a := by
  intro a
  simp only [causalClosure, Function.comp]
  have hcomm : ∀ x, D.fwd.cl (D.bwd.cl x) = D.bwd.cl (D.fwd.cl x) :=
    fun x => congr_fun comm x
  -- Goal: bwd.cl (fwd.cl (bwd.cl (fwd.cl a))) = bwd.cl (fwd.cl a)
  conv_lhs => rw [show D.fwd.cl (D.bwd.cl (D.fwd.cl a)) = D.bwd.cl (D.fwd.cl (D.fwd.cl a)) from hcomm _]
  rw [D.fwd.cl_idem, D.bwd.cl_idem]

/-- An element is causally complete if it is fixed by causal closure. -/
def IsCausallyComplete (a : α) : Prop := D.causalClosure a = a

/-- The subtype of causally complete elements. -/
def CausalFixedPoint := { a : α // D.IsCausallyComplete a }

/-- Causal closure always produces causally complete elements (when closures commute). -/
theorem causalClosure_produces_fixed
    (comm : D.fwd.cl ∘ D.bwd.cl = D.bwd.cl ∘ D.fwd.cl)
    (a : α) : D.IsCausallyComplete (D.causalClosure a) :=
  D.causalClosure_idempotent comm a

end CausalClosureData

/-! ## Causal Equivalence and Completion -/

/-- Two elements are causally equivalent if they have the same causal closure. -/
def causalEquiv {α : Type*} [PartialOrder α] (D : CausalClosureData α) : α → α → Prop :=
  fun a b => D.causalClosure a = D.causalClosure b

/-- Causal equivalence is an equivalence relation. -/
theorem causalEquiv_equivalence {α : Type*} [PartialOrder α]
    (D : CausalClosureData α) : Equivalence (causalEquiv D) where
  refl _ := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

/-- Causal equivalence as a `Setoid`. -/
def causalSetoid {α : Type*} [PartialOrder α] (D : CausalClosureData α) : Setoid α where
  r := causalEquiv D
  iseqv := causalEquiv_equivalence D

/-- The causal completion: quotient by causal equivalence. -/
def CausalCompletion {α : Type*} [PartialOrder α] (D : CausalClosureData α) :=
  Quotient (causalSetoid D)

/-- The causal closure of any element is causally equivalent to that element. -/
theorem causalClosure_equiv_self {α : Type*} [PartialOrder α]
    (D : CausalClosureData α)
    (comm : D.fwd.cl ∘ D.bwd.cl = D.bwd.cl ∘ D.fwd.cl)
    (a : α) : causalEquiv D (D.causalClosure a) a := by
  exact D.causalClosure_idempotent comm a

/-- The canonical injection from fixed points to the completion is injective. -/
theorem fixedPointToCompletion_injective {α : Type*} [PartialOrder α]
    (D : CausalClosureData α) :
    Function.Injective (fun (x : D.CausalFixedPoint) =>
      Quotient.mk (causalSetoid D) x.val) := by
  intro ⟨a, ha⟩ ⟨b, hb⟩ h
  have := Quotient.exact h
  change D.causalClosure a = D.causalClosure b at this
  rw [ha, hb] at this
  exact Subtype.ext this

/-- The canonical projection from the completion to fixed points. -/
noncomputable def completionToFixedPoint {α : Type*} [PartialOrder α]
    (D : CausalClosureData α)
    (comm : D.fwd.cl ∘ D.bwd.cl = D.bwd.cl ∘ D.fwd.cl) :
    CausalCompletion D → D.CausalFixedPoint :=
  Quotient.lift
    (fun a => ⟨D.causalClosure a, D.causalClosure_produces_fixed comm a⟩)
    (fun _ _ h => Subtype.ext h)

/-- Fixed points are in bijection with the causal completion. -/
theorem fixedPoint_equiv_completion {α : Type*} [PartialOrder α]
    (D : CausalClosureData α)
    (comm : D.fwd.cl ∘ D.bwd.cl = D.bwd.cl ∘ D.fwd.cl) :
    Function.Bijective (completionToFixedPoint D comm) := by
  constructor
  · intro a b h
    induction a using Quotient.ind with | _ a => ?_
    induction b using Quotient.ind with | _ b => ?_
    simp only [completionToFixedPoint, Quotient.lift_mk] at h
    apply Quotient.sound
    show causalEquiv D a b
    exact Subtype.mk.inj h
  · intro ⟨a, ha⟩
    exact ⟨Quotient.mk _ a, Subtype.ext ha⟩

/-- The causal completion map is universal: any map to a target that
    identifies causally equivalent elements factors uniquely through the completion. -/
theorem causalCompletion_universal {α : Type*} [PartialOrder α]
    (D : CausalClosureData α)
    {T : Type*} (f : α → T)
    (hf : ∀ a b, causalEquiv D a b → f a = f b) :
    ∃! g : CausalCompletion D → T,
      ∀ a, g (Quotient.mk (causalSetoid D) a) = f a := by
  refine ⟨Quotient.lift f hf, fun _ => rfl, fun g' hg' => ?_⟩
  ext q
  induction q using Quotient.ind with
  | _ a => simp [Quotient.lift_mk, hg' a]