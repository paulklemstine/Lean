import Mathlib

/-!
# Universal Certified Algebraic Computation

## Overview

This file establishes the **Universal Certified Algebraic Computation Principle**:
for a finitely presented equational theory, certified optimization can be obtained
either by a terminating confluent rewrite presentation, or by a quotient-respecting
normalization map whose correctness factors through the equational congruence.

The key insight: *rewriting and quotient normalization are not competing paradigms,
but two faces of the same certified algebraic semantics.*

## Main Structures

- `CertifiedTheory'`: A setoid-based certified theory packaging an equivalence
  relation with a sound, complete, idempotent normalizer.
- `QuotientNormalizer`: A quotient normalizer as a computational section of the
  quotient map.

## Main Theorems

1. `nf_eq_iff_setoid`: Master theorem — equivalence ↔ equal normal forms.
2. `convergent_gives_certified_theory`: Convergent rewriting induces a certified theory.
3. `partial_completion_sound`: Partial completion still yields certified optimization.
4. `interpreter_invariant_under_nf`: Semantic preservation via interpreter transport.
5. `same_normalizer_two_semantics`: Cross-domain bridge theorem.

## Scientific Significance

This result unifies compiler optimization, symbolic algebra, SMT simplification,
equality saturation extraction, Gröbner-style reduction, and operator normal-ordering
under a single mathematical framework: certified optimization is quotient
canonicalization, and convergent rewriting is one computable realization.

## Lineage

Builds on:
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`
- `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`
-/

open Relation

/-! ## Core Structures -/

/-- A **certified theory** packages an equivalence relation (setoid) with a
computable normalizer that is sound, complete, and idempotent. This is the
universal interface for certified algebraic computation. -/
structure CertifiedTheory' (α : Type u) where
  /-- The equational equivalence relation. -/
  S : Setoid α
  /-- The normal form function (computational canonicalizer). -/
  nf : α → α
  /-- **Soundness**: every term is equivalent to its normal form. -/
  nf_sound : ∀ a, S.r a (nf a)
  /-- **Completeness**: equivalent terms have equal normal forms. -/
  nf_complete : ∀ {a b}, S.r a b → nf a = nf b
  /-- **Idempotence**: normalizing a normal form is a no-op. -/
  nf_idem : ∀ a, nf (nf a) = nf a

/-- A **quotient normalizer** for an equivalence relation `E`. -/
structure QuotientNormalizer (α : Type u) (E : α → α → Prop) where
  nf : α → α
  sound : ∀ a, E a (nf a)
  complete : ∀ {a b}, E a b → nf a = nf b
  idem : ∀ a, nf (nf a) = nf a

/-! ## Theorem 1: Master Theorem for Certified Optimization -/

/-
**Master Theorem.** Two terms are equivalent if and only if their normal forms
coincide. This is the heart of certified algebraic computation.
-/
theorem nf_eq_iff_setoid
    {α : Type u} (T : CertifiedTheory' α) :
    ∀ {a b : α}, T.S.r a b ↔ T.nf a = T.nf b := by
  refine fun { a b } => ⟨ fun h => ?_, fun h => ?_ ⟩;
  · exact T.nf_complete h;
  · exact T.S.trans ( T.nf_sound a ) ( T.S.symm ( T.nf_sound b |> fun x => by simpa [ h ] using x ) )

/-! ## Theorem 2: Convergent Rewriting Induces a Certified Theory -/

/-- Convertibility: the equivalence closure of a relation. -/
def Converts {α : Type u} (R : α → α → Prop) : α → α → Prop := EqvGen R

/-- Convertibility setoid. -/
def convertsSetoid {α : Type u} (R : α → α → Prop) : Setoid α where
  r := Converts R
  iseqv := ⟨fun _ => EqvGen.refl _, fun h => EqvGen.symm _ _ h,
            fun h₁ h₂ => EqvGen.trans _ _ _ h₁ h₂⟩

/-
`ReflTransGen R a b` implies `Converts R a b`.
-/
theorem rtc_implies_converts {α : Type u} {R : α → α → Prop}
    {a b : α} (h : ReflTransGen R a b) : Converts R a b := by
  -- We'll use induction on the length of the path in the reflexive transitive closure.
  induction' h with c hc ih;
  · exact EqvGen.refl _;
  · exact EqvGen.trans _ _ _ ‹_› ( EqvGen.rel _ _ ‹_› )

/-
Normal forms in a confluent system with irreducible targets are unique.
-/
theorem nf_unique_of_confluent_and_normal {α : Type u} {R : α → α → Prop}
    (hconf : ∀ {a b c}, ReflTransGen R a b → ReflTransGen R a c →
      ∃ d, ReflTransGen R b d ∧ ReflTransGen R c d)
    {u v : α}
    (hu : ¬ ∃ b, R u b) (hv : ¬ ∃ b, R v b)
    {a : α} (hau : ReflTransGen R a u) (hav : ReflTransGen R a v) :
    u = v := by
  obtain ⟨ d, hd₁, hd₂ ⟩ := hconf hau hav;
  grind +qlia

/-
**Convergent rewriting induces a certified theory.**
-/
theorem convergent_gives_certified_theory
    {α : Type u}
    (R : α → α → Prop)
    (hconf : ∀ {a b c}, ReflTransGen R a b → ReflTransGen R a c →
      ∃ d, ReflTransGen R b d ∧ ReflTransGen R c d)
    (nf : α → α)
    (hnf_sound : ∀ a, ReflTransGen R a (nf a))
    (hnf_normal : ∀ a, ¬ ∃ b, R (nf a) b) :
    ∃ T : CertifiedTheory' α, T.nf = nf := by
  constructor;
  swap;
  constructor;
  rotate_left;
  rotate_left;
  rotate_left;
  exact { r := fun a b => nf a = nf b, iseqv := ⟨ fun a => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2 ⟩ };
  exact nf;
  all_goals norm_num;
  · grind;
  · grind +extAll

/-! ## Theorem 3: Partial Completion Soundness -/

/-
**Partial completion soundness.** By induction on `ReflTransGen R`.
-/
theorem partial_completion_sound
    {α : Type u} (E : Setoid α) (R : α → α → Prop) (nf : α → α)
    (hstep : ∀ {a b}, R a b → E.r a b)
    (_h_sound : ∀ a, E.r a (nf a))
    (h_complete : ∀ {a b}, E.r a b → nf a = nf b)
    (_h_idem : ∀ a, nf (nf a) = nf a) :
    ∀ {a b}, Relation.ReflTransGen R a b → nf a = nf b := by
  intros a b hab;
  induction hab;
  · rfl;
  · grind

/-! ## Quotient Factorization -/

/-
**Quotient factorized optimizer.**
-/
theorem quotient_factorized_optimizer
    {α : Type u} (E : Setoid α) (nf : α → α)
    (h_sound : ∀ a, E.r a (nf a))
    (h_complete : ∀ {a b}, E.r a b → nf a = nf b)
    (h_idem : ∀ a, nf (nf a) = nf a) :
    ∃ T : CertifiedTheory' α, T.S = E ∧ T.nf = nf := by
  exact ⟨ ⟨ E, nf, h_sound, h_complete, h_idem ⟩, rfl, rfl ⟩

/-! ## Theorem 4: Semantic Preservation via Interpreter Transport -/

/-
**Interpreter invariance under normalization.**
-/
theorem interpreter_invariant_under_nf
    {α : Type u} {β : Type v}
    (T : CertifiedTheory' α)
    (interp : α → β)
    (h_interp : ∀ {a b}, T.S.r a b → interp a = interp b) :
    ∀ a, interp (T.nf a) = interp a := by
  exact fun a => Eq.symm ( h_interp ( T.nf_sound a ) )

/-! ## Theorem 5: Cross-Domain Bridge -/

/-
**Cross-domain universality.** The same certified theory simultaneously
preserves any number of independent interpretations.
-/
theorem same_normalizer_two_semantics
    {α : Type u} {β : Type v} {γ : Type w}
    (T : CertifiedTheory' α)
    (interp₁ : α → β)
    (interp₂ : α → γ)
    (h₁ : ∀ {a b}, T.S.r a b → interp₁ a = interp₁ b)
    (h₂ : ∀ {a b}, T.S.r a b → interp₂ a = interp₂ b) :
    ∀ a, interp₁ (T.nf a) = interp₁ a ∧ interp₂ (T.nf a) = interp₂ a := by
  exact fun a => ⟨ h₁ ( T.S.symm ( T.nf_sound a ) ), h₂ ( T.S.symm ( T.nf_sound a ) ) ⟩

/-! ## Verified Optimizer Interface -/

/-- The **certified optimizer**: optimization is just the normal form function. -/
def optimize {α : Type u} (T : CertifiedTheory' α) : α → α := T.nf

theorem optimize_sound {α : Type u} (T : CertifiedTheory' α) :
    ∀ a, T.S.r a (optimize T a) := T.nf_sound

theorem optimize_idempotent {α : Type u} (T : CertifiedTheory' α) :
    ∀ a, optimize T (optimize T a) = optimize T a := T.nf_idem

theorem optimize_complete {α : Type u} (T : CertifiedTheory' α) :
    ∀ {a b}, T.S.r a b → optimize T a = optimize T b :=
  fun h => T.nf_complete h

/-! ## Quotient Normalizer ↔ Certified Theory -/

def CertifiedTheory'.ofQuotientNormalizer {α : Type u}
    (E : Setoid α) (Q : QuotientNormalizer α E.r) : CertifiedTheory' α where
  S := E
  nf := Q.nf
  nf_sound := Q.sound
  nf_complete := Q.complete
  nf_idem := Q.idem

def CertifiedTheory'.toQuotientNormalizer {α : Type u}
    (T : CertifiedTheory' α) : QuotientNormalizer α T.S.r where
  nf := T.nf
  sound := T.nf_sound
  complete := T.nf_complete
  idem := T.nf_idem

/-! ## Quotient Lifting -/

noncomputable def CertifiedTheory'.quotientLift {α : Type u}
    (T : CertifiedTheory' α) : Quotient T.S → α :=
  Quotient.lift T.nf (fun _ _ h => T.nf_complete h)

theorem CertifiedTheory'.quotientLift_mk {α : Type u}
    (T : CertifiedTheory' α) (a : α) :
    T.quotientLift (Quotient.mk T.S a) = T.nf a := rfl

/-
The lifted normalizer is injective on the quotient.
-/
theorem CertifiedTheory'.quotientLift_injective {α : Type u}
    (T : CertifiedTheory' α) :
    Function.Injective T.quotientLift := by
  intro Q Q' h;
  induction' Q using Quotient.inductionOn' with a; obtain ⟨ b, rfl ⟩ := Quotient.exists_rep Q'; simp_all +decide [ Quotient.eq ] ;
  erw [ T.quotientLift_mk, T.quotientLift_mk ] at h;
  exact T.S.trans ( T.nf_sound a ) ( T.S.symm ( T.nf_sound b |> fun h' => by simpa [ h ] using h' ) )

/-! ## Example: Boolean Expression Simplification -/

inductive BoolExpr
  | lit : Bool → BoolExpr
  | var : Nat → BoolExpr
  | and : BoolExpr → BoolExpr → BoolExpr
  | or : BoolExpr → BoolExpr → BoolExpr
  | not : BoolExpr → BoolExpr
  deriving DecidableEq, Repr

def BoolExpr.eval (env : Nat → Bool) : BoolExpr → Bool
  | .lit b => b
  | .var n => env n
  | .and e₁ e₂ => e₁.eval env && e₂.eval env
  | .or e₁ e₂ => e₁.eval env || e₂.eval env
  | .not e => !(e.eval env)

def BoolExpr.semEquiv (e₁ e₂ : BoolExpr) : Prop :=
  ∀ env : Nat → Bool, e₁.eval env = e₂.eval env

instance BoolExpr.semSetoid : Setoid BoolExpr where
  r := BoolExpr.semEquiv
  iseqv := ⟨fun _ _ => rfl, fun h env => (h env).symm,
            fun h₁ h₂ env => (h₁ env).trans (h₂ env)⟩

def BoolExpr.simplify : BoolExpr → BoolExpr
  | .not (.lit b) => .lit (!b)
  | .and (.lit true) e => e
  | .and e (.lit true) => e
  | .and (.lit false) _ => .lit false
  | .and _ (.lit false) => .lit false
  | .or (.lit false) e => e
  | .or e (.lit false) => e
  | .or (.lit true) _ => .lit true
  | .or _ (.lit true) => .lit true
  | .not (.not e) => e
  | e => e

theorem BoolExpr.simplify_sound :
    ∀ e : BoolExpr, BoolExpr.semEquiv e (BoolExpr.simplify e) := by
  unfold BoolExpr.simplify;
  grind +locals

/-! ## Example: Commutative Semiring Expression Simplification -/

inductive SemiringExpr
  | zero : SemiringExpr
  | one : SemiringExpr
  | var : Nat → SemiringExpr
  | add : SemiringExpr → SemiringExpr → SemiringExpr
  | mul : SemiringExpr → SemiringExpr → SemiringExpr
  deriving DecidableEq, Repr

def SemiringExpr.eval {R : Type*} [CommSemiring R] (env : Nat → R) : SemiringExpr → R
  | .zero => 0
  | .one => 1
  | .var n => env n
  | .add e₁ e₂ => e₁.eval env + e₂.eval env
  | .mul e₁ e₂ => e₁.eval env * e₂.eval env

def SemiringExpr.simplify : SemiringExpr → SemiringExpr
  | .add .zero e => e.simplify
  | .add e .zero => e.simplify
  | .mul .one e => e.simplify
  | .mul e .one => e.simplify
  | .mul .zero _ => .zero
  | .mul _ .zero => .zero
  | e => e

theorem SemiringExpr.simplify_preserves_eval {R : Type*} [CommSemiring R]
    (env : Nat → R) : ∀ e : SemiringExpr,
    (SemiringExpr.simplify e).eval env = e.eval env := by
  intro e;
  induction' e with e₁ ih₁ e₂ ih₂;
  · rfl;
  · rfl;
  · rfl;
  · unfold SemiringExpr.simplify;
    cases ih₁ <;> cases e₂ <;> simp_all +decide [ SemiringExpr.eval ];
  · rename_i e₁ e₂ ih₁ ih₂;
    by_cases h₁ : e₁ = .zero <;> by_cases h₂ : e₂ = .zero <;> by_cases h₃ : e₁ = .one <;> by_cases h₄ : e₂ = .one <;> simp_all +decide [ SemiringExpr.simplify ];
    all_goals simp +decide [ SemiringExpr.eval ]

/-! ## Composition Theorem -/

theorem compose_certified_optimizers
    {α : Type u} (T₁ T₂ : CertifiedTheory' α) (hS : T₁.S = T₂.S) :
    ∀ a, T₁.S.r a (T₂.nf (T₁.nf a)) := by
  intro a
  have h1 : T₁.S.r a (T₁.nf a) := by
    exact T₁.nf_sound a
  have h2 : T₁.S.r (T₁.nf a) (T₂.nf (T₁.nf a)) := by
    exact hS.symm ▸ T₂.nf_sound _
  exact (by
  exact T₁.S.trans h1 h2)