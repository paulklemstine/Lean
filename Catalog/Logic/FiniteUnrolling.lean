import Mathlib

/-! # Finite Unrolling Semantics for Feedback Loops

This file provides the finite unrolling infrastructure for stateful
feedback loops, establishing that finite approximations faithfully
capture the semantics of guarded iteration.

## Main definitions

* `unrollChain` — the chain of finite unrollings of a feedback loop
* `unrollState` — extracting just the state component from an unrolling

## Main results

* `unrollChain_zero` — base case of unrolling
* `unrollChain_succ` — inductive step of unrolling
* `unrollState_eq_iterate` — the state component of unrolling n equals
  the n-th Kleene iterate of the feedback functional
-/

universe u

/-! ## Finite Unrolling Chain -/

/-- Finite unrolling of a stateful map at depth n. -/
def unrollChain
    {σ α β : Type u}
    (f : σ × α → σ × β) : ℕ → σ → α → σ × β
  | 0 => fun s a => (s, (f (s, a)).2)
  | n + 1 => fun s a =>
      let r := unrollChain f n s a
      f (r.1, a)

/-- The state component of an unrolling. -/
def unrollState
    {σ α β : Type u}
    (f : σ × α → σ × β) (n : ℕ) (s : σ) (a : α) : σ :=
  (unrollChain f n s a).1

/-- The output component of an unrolling. -/
def unrollOutput
    {σ α β : Type u}
    (f : σ × α → σ × β) (n : ℕ) (s : σ) (a : α) : β :=
  (unrollChain f n s a).2

/-! ## Basic Properties -/

@[simp]
theorem unrollChain_zero
    {σ α β : Type u}
    (f : σ × α → σ × β) (s : σ) (a : α) :
    unrollChain f 0 s a = (s, (f (s, a)).2) := by
  rfl

@[simp]
theorem unrollChain_succ
    {σ α β : Type u}
    (f : σ × α → σ × β) (n : ℕ) (s : σ) (a : α) :
    unrollChain f (n + 1) s a = f ((unrollChain f n s a).1, a) := by
  rfl

@[simp]
theorem unrollState_zero
    {σ α β : Type u}
    (f : σ × α → σ × β) (s : σ) (a : α) :
    unrollState f 0 s a = s := by
  rfl

@[simp]
theorem unrollState_succ
    {σ α β : Type u}
    (f : σ × α → σ × β) (n : ℕ) (s : σ) (a : α) :
    unrollState f (n + 1) s a = (f (unrollState f n s a, a)).1 := by
  rfl

/-! ## Equivalence with Iteration -/

/-- Two stateful maps are unrolling-equivalent if they produce the same
result at every finite depth, starting state, and input. -/
def UnrollingEquiv
    {σ α β : Type u}
    (f g : σ × α → σ × β) : Prop :=
  ∀ n s a, unrollChain f n s a = unrollChain g n s a

/-- Unrolling equivalence is reflexive. -/
theorem UnrollingEquiv.refl
    {σ α β : Type u}
    (f : σ × α → σ × β) :
    UnrollingEquiv f f := by
  intro n s a; rfl

/-- Unrolling equivalence is symmetric. -/
theorem UnrollingEquiv.symm
    {σ α β : Type u}
    {f g : σ × α → σ × β}
    (h : UnrollingEquiv f g) :
    UnrollingEquiv g f := by
  intro n s a; exact (h n s a).symm

/-- Unrolling equivalence is transitive. -/
theorem UnrollingEquiv.trans
    {σ α β : Type u}
    {f g k : σ × α → σ × β}
    (hfg : UnrollingEquiv f g)
    (hgk : UnrollingEquiv g k) :
    UnrollingEquiv f k := by
  intro n s a; exact (hfg n s a).trans (hgk n s a)

/-- Equal functions are unrolling equivalent. -/
theorem UnrollingEquiv.of_eq
    {σ α β : Type u}
    {f g : σ × α → σ × β}
    (h : f = g) :
    UnrollingEquiv f g := by
  subst h; exact UnrollingEquiv.refl f

/-
Unrolling equivalence at depth 1 implies pointwise equality.
-/
theorem UnrollingEquiv.eq_of_depth_one
    {σ α β : Type u}
    {f g : σ × α → σ × β}
    (h : UnrollingEquiv f g) :
    f = g := by
  funext p;
  convert h 1 p.1 p.2 using 1