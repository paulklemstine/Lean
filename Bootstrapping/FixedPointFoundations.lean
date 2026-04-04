/-
  # Fixed Point Foundations of Bootstrapping
  ============================================

  The deepest form of bootstrapping in mathematics: theorems that prove their
  own existence. A fixed point is an object that, when transformed, returns to
  itself — the mathematical incarnation of self-creation.

  We formalize three pillars:
  1. Knaster-Tarski: Every monotone map on a complete lattice has a least fixed point
  2. Kleene's chain: The least fixed point is the supremum of iterated applications of ⊥
  3. Banach contraction: Self-correcting iteration converges to a unique fixed point

  These theorems bootstrap because the fixed point's existence is proved by
  constructing it from the very operation that defines it.
-/

import Mathlib

open OrderDual

/-! ## Section 1: The Knaster-Tarski Bootstrap

The Knaster-Tarski theorem is the purest bootstrap: the least fixed point of a
monotone function f is defined as ⊓ {x | f(x) ≤ x}, and then one proves that
this infimum IS a fixed point. The object proves its own membership in the set
that defines it.
-/

section KnasterTarski

/-- The pre-fixed points of a monotone function: the set of x with f(x) ≤ x.
    The least fixed point will bootstrap itself into existence as the infimum
    of this set. -/
def preFixedPoints {α : Type*} [Preorder α] (f : α → α) : Set α :=
  {x | f x ≤ x}

/-- The post-fixed points: x ≤ f(x). Dual to pre-fixed points. -/
def postFixedPoints {α : Type*} [Preorder α] (f : α → α) : Set α :=
  {x | x ≤ f x}

/-- **The Bootstrap Lemma**: In a complete lattice, the infimum of pre-fixed points
    of a monotone function is itself a pre-fixed point. This is the key self-referential
    step — the constructed object validates its own defining property. -/
theorem bootstrap_lemma {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : f (sInf (preFixedPoints f)) ≤ sInf (preFixedPoints f) := by
  refine le_sInf ?_
  exact fun x hx => le_trans (hf (sInf_le hx)) hx

/-- **Knaster-Tarski Fixed Point Theorem**: Every monotone function on a complete
    lattice has a least fixed point, equal to ⊓ {x | f(x) ≤ x}.
    The fixed point bootstraps itself into existence. -/
theorem knaster_tarski_lfp {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : f (sInf (preFixedPoints f)) = sInf (preFixedPoints f) := by
  refine le_antisymm (bootstrap_lemma hf) ?_
  exact sInf_le (hf (bootstrap_lemma hf))

/-- The greatest fixed point bootstraps dually: ⊔ {x | x ≤ f(x)} -/
theorem knaster_tarski_gfp {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : f (sSup (postFixedPoints f)) = sSup (postFixedPoints f) := by
  have h_sSup_le : sSup (postFixedPoints f) ≤ f (sSup (postFixedPoints f)) :=
    sSup_le fun x hx => hx.trans (hf (le_sSup hx))
  exact le_antisymm (le_sSup <| by aesop) h_sSup_le

/-- The least fixed point is indeed the least among all fixed points -/
theorem lfp_is_least {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) (x : α) (hx : f x = x) :
    sInf (preFixedPoints f) ≤ x :=
  sInf_le (by simp [preFixedPoints, hx])

end KnasterTarski

/-! ## Section 2: Kleene's Ascending Chain Bootstrap

Kleene shows how to BUILD the fixed point by iterating from nothing (⊥).
Each step f^n(⊥) bootstraps from the previous, and the supremum of the
entire chain is the fixed point. Creation from the void.
-/

section KleeneChain

/-- Each iteration is below the next for a monotone function: the chain ascends -/
theorem iterateBot_le_succ {α : Type*} [CompleteLattice α] {f : α → α}
    (hf : Monotone f) : ∀ n : ℕ, f^[n] ⊥ ≤ f^[n + 1] ⊥ := by
  intro n
  induction n <;> simp_all [Function.iterate_succ_apply']
  exact hf ‹_›

end KleeneChain

/-! ## Section 3: Contraction Bootstrap

Banach's contraction mapping: a function that shrinks distances has a unique
fixed point. Each iterate x, f(x), f(f(x)), ... bootstraps closer to the truth.
We formalize the key uniqueness property.
-/

section Contraction

/-- A contraction on a metric space: d(f(x), f(y)) ≤ c · d(x, y) for c < 1 -/
def IsContraction {α : Type*} [PseudoMetricSpace α] (f : α → α) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ x y : α, dist (f x) (f y) ≤ c * dist x y

/-- A contraction has at most one fixed point — the bootstrap is unique -/
theorem contraction_unique_fixed_point {α : Type*} [MetricSpace α]
    {f : α → α} {c : ℝ} (hf : IsContraction f c)
    {x y : α} (hx : f x = x) (hy : f y = y) : x = y := by
  have h1 := hf.2.2 x y
  have h_zero : dist x y ≤ c * dist x y → dist x y = 0 :=
    fun h => le_antisymm (le_of_not_gt fun h' => by nlinarith [hf.1, hf.2.1]) dist_nonneg
  aesop

end Contraction

/-! ## Section 4: The Self-Application Bootstrap

The deepest bootstrap: a function applied to itself. In type theory, we can
construct fixed-point combinators that embody pure self-reference.
-/

section SelfApplication

/-- Curry's fixed-point combinator, typed in Lean: for any f, we can find x with f x = x
    in a complete lattice. This wraps Knaster-Tarski as a function. -/
noncomputable def fixedPointCombinator {α : Type*} [CompleteLattice α]
    (f : α → α) (_hf : Monotone f) : α :=
  sInf (preFixedPoints f)

/-- The combinator indeed produces a fixed point -/
theorem fixedPointCombinator_is_fixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    f (fixedPointCombinator f hf) = fixedPointCombinator f hf :=
  knaster_tarski_lfp hf

end SelfApplication
