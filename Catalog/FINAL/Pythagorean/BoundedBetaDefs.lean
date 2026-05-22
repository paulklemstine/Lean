/-
# Bounded Beta-Reduction Semantics: Definitions

Defines core structures for extracting finite transition systems from lambda
calculus terms under bounded β-reduction.
-/

import Mathlib

/-- Lambda calculus terms with named variables. -/
inductive Lam : Type where
  | var : Nat → Lam
  | app : Lam → Lam → Lam
  | lam : Nat → Lam → Lam
  deriving DecidableEq, Repr

namespace Lam

/-- The size of a lambda term (number of constructors). -/
def size : Lam → Nat
  | var _ => 1
  | app t u => 1 + t.size + u.size
  | lam _ t => 1 + t.size

/-- Substitution of term `s` for variable `x` in term `t`. -/
def subst (t : Lam) (x : Nat) (s : Lam) : Lam :=
  match t with
  | var n => if n = x then s else var n
  | app t₁ t₂ => app (t₁.subst x s) (t₂.subst x s)
  | lam y body =>
    if y = x then lam y body
    else lam y (body.subst x s)

end Lam

/-- One-step β-reduction. -/
inductive BetaStep : Lam → Lam → Prop where
  | beta (x : Nat) (body arg : Lam) :
      BetaStep (.app (.lam x body) arg) (body.subst x arg)
  | appLeft {t t' : Lam} (u : Lam) (h : BetaStep t t') :
      BetaStep (.app t u) (.app t' u)
  | appRight (t : Lam) {u u' : Lam} (h : BetaStep u u') :
      BetaStep (.app t u) (.app t u')
  | lamBody (x : Nat) {t t' : Lam} (h : BetaStep t t') :
      BetaStep (.lam x t) (.lam x t')

/-- β-equivalence: the equivalence closure of BetaStep. -/
inductive BetaEq : Lam → Lam → Prop where
  | refl (t : Lam) : BetaEq t t
  | step {t u : Lam} (h : BetaStep t u) : BetaEq t u
  | symm {t u : Lam} (h : BetaEq t u) : BetaEq u t
  | trans {t u v : Lam} (h₁ : BetaEq t u) (h₂ : BetaEq u v) : BetaEq t v

/-- Bounded reachability: `u` is reachable from `t` within `d` β-steps. -/
inductive ReachableWithin : Nat → Lam → Lam → Prop where
  | refl (d : Nat) (t : Lam) : ReachableWithin d t t
  | step {d : Nat} {t v u : Lam}
      (h₁ : ReachableWithin d t v) (h₂ : BetaStep v u) :
      ReachableWithin (d + 1) t u

/-- If `u` is reachable from `t` within 0 steps, then `u = t`. -/
theorem reachableWithin_zero_iff {t u : Lam} :
    ReachableWithin 0 t u ↔ u = t := by
  constructor
  · intro h; cases h with | refl => rfl
  · rintro rfl; exact ReachableWithin.refl 0 _

/-
ReachableWithin is monotone in the depth bound.
-/
theorem ReachableWithin.mono {d₁ d₂ : Nat} {t u : Lam}
    (h : ReachableWithin d₁ t u) (hle : d₁ ≤ d₂) :
    ReachableWithin d₂ t u := by
  induction' hle with d₂ hle ih;
  · assumption;
  · -- If $u$ is reachable from $t$ within $d₂$ steps, then $u$ is also reachable from $t$ within $d₂+1$ steps by adding one more step.
    have h_step : ∀ {d : ℕ} {t u : Lam}, ReachableWithin d t u → ReachableWithin (d + 1) t u := by
      intros d t u h; exact (by
      induction' h with d t u h ih;
      · exact ReachableWithin.refl _ _;
      · exact ReachableWithin.step ‹_› ‹_›);
    exact h_step ih

/-
Reachable terms are β-equivalent to the source.
-/
theorem reachableWithin_betaEq {d : Nat} {t u : Lam}
    (h : ReachableWithin d t u) : BetaEq t u := by
  induction' h with d' t' u' h₁ h₂ h₃;
  · constructor;
  · exact BetaEq.trans ‹_› ( BetaEq.step ‹_› )

/-- The bounded reduct system of term `t` at depth `d`:
    the subtype of terms reachable within d steps. -/
def BoundedReductSystem (d : Nat) (t : Lam) : Type :=
  {u : Lam // ReachableWithin d t u}

/-- The state set of a bounded reduct system. -/
def boundedStateSet (d : Nat) (t : Lam) : Set Lam :=
  {u | ReachableWithin d t u}

/-- A Finite Transition System with a distinguished initial state. -/
structure FTS where
  State : Type
  init : State
  step : State → State → Prop

/-- Extract an FTS from a lambda term at bounded depth. -/
noncomputable def toFTS (d : Nat) (t : Lam) : FTS where
  State := Lam
  init := t
  step := fun s₁ s₂ => ReachableWithin d t s₁ ∧ ReachableWithin d t s₂ ∧ BetaStep s₁ s₂

/-- Bisimulation relation between two FTS. -/
def Bisimilar (A B : FTS) : Prop :=
  ∃ R : A.State → B.State → Prop,
    R A.init B.init ∧
    (∀ a b, R a b → ∀ a', A.step a a' → ∃ b', B.step b b' ∧ R a' b') ∧
    (∀ a b, R a b → ∀ b', B.step b b' → ∃ a', A.step a a' ∧ R a' b')

/-
Bisimilarity is reflexive.
-/
theorem Bisimilar.rfl' (A : FTS) : Bisimilar A A := by
  use fun a b => a = b;
  grind

/-- Bisimilarity is symmetric. -/
theorem Bisimilar.symm' {A B : FTS} (h : Bisimilar A B) : Bisimilar B A := by
  obtain ⟨R, hInit, hFwd, hBwd⟩ := h
  exact ⟨fun b a => R a b, hInit,
    fun b a hr b' hb => hBwd a b hr b' hb,
    fun b a hr a' ha => hFwd a b hr a' ha⟩

/-- Bisimilarity is transitive. -/
theorem Bisimilar.trans' {A B C : FTS} (h₁ : Bisimilar A B) (h₂ : Bisimilar B C) :
    Bisimilar A C := by
  obtain ⟨R₁, hInit₁, hFwd₁, hBwd₁⟩ := h₁
  obtain ⟨R₂, hInit₂, hFwd₂, hBwd₂⟩ := h₂
  refine ⟨fun a c => ∃ b, R₁ a b ∧ R₂ b c, ⟨B.init, hInit₁, hInit₂⟩, ?_, ?_⟩
  · rintro a c ⟨b, hr₁, hr₂⟩ a' ha
    obtain ⟨b', hb, hr₁'⟩ := hFwd₁ a b hr₁ a' ha
    obtain ⟨c', hc, hr₂'⟩ := hFwd₂ b c hr₂ b' hb
    exact ⟨c', hc, b', hr₁', hr₂'⟩
  · rintro a c ⟨b, hr₁, hr₂⟩ c' hc
    obtain ⟨b', hb, hr₂'⟩ := hBwd₂ b c hr₂ c' hc
    obtain ⟨a', ha, hr₁'⟩ := hBwd₁ a b hr₁ b' hb
    exact ⟨a', ha, b', hr₁', hr₂'⟩

/-- Simple modal logic formulas. -/
inductive ModalFormula : Type where
  | top : ModalFormula
  | neg : ModalFormula → ModalFormula
  | conj : ModalFormula → ModalFormula → ModalFormula
  | diamond : ModalFormula → ModalFormula

namespace ModalFormula

/-- The modal depth of a formula. -/
def depth : ModalFormula → Nat
  | top => 0
  | neg φ => φ.depth
  | conj φ ψ => max φ.depth ψ.depth
  | diamond φ => φ.depth + 1

end ModalFormula

/-- Satisfaction of a modal formula at a state in an FTS. -/
def SatisfiesFTS (A : FTS) : A.State → ModalFormula → Prop
  | _, .top => True
  | s, .neg φ => ¬ SatisfiesFTS A s φ
  | s, .conj φ ψ => SatisfiesFTS A s φ ∧ SatisfiesFTS A s ψ
  | s, .diamond φ => ∃ s', A.step s s' ∧ SatisfiesFTS A s' φ

/-- A modal formula holds at the initial state of an FTS. -/
def HoldsAtInit (A : FTS) (φ : ModalFormula) : Prop :=
  SatisfiesFTS A A.init φ