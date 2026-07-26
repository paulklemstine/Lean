import Mathlib

/-!
# Certified Knuth-Bendix Completion: Automated Synthesis of Convergent Rewrite Systems

## Overview

This file formalizes the core theory of Knuth-Bendix completion at the level of
abstract rewrite systems (ARS). We establish:

1. **Newman's Lemma**: Terminating + locally confluent ⟹ confluent
2. **Equational theory preservation**: KB completion steps preserve the equational theory
3. **Convergent completion theorem**: Terminated completion yields a convergent system
4. **Bridge to certified optimization**: Convergent systems yield semantics-preserving normalizers

These results close the loop from equational specifications to certified optimizers:
  equations → KB completion → convergence certificate → normalizer → optimizer

## Design

We work at the level of abstract rewrite systems, parameterized by a type `T` and
a step relation `R : T → T → Prop`. This separates the logical structure of
completion from syntactic details of first-order terms, enabling the theorems
to apply to any concrete term algebra.

## Lineage

Builds on `Pythagorean/ConvergentRewriteOptimizer.lean` conceptually:
- Extends the `CertifiedNormalizer` / `RewriteSound` architecture
- The completion pipeline composes with the existing optimizer architecture
-/

open Relation

namespace KnuthBendix

/-! ## Part 1: Abstract Rewrite System Properties -/

/-- A relation is **terminating** (strongly normalizing) if the inverse is well-founded. -/
def IsTerminating {T : Type*} (R : T → T → Prop) : Prop :=
  WellFounded (fun a b => R b a)

/-- A term is in **normal form** w.r.t. `R` if no rule applies. -/
def IsNF {T : Type*} (R : T → T → Prop) (t : T) : Prop :=
  ∀ u, ¬R t u

/-- `R` is **locally confluent** if single-step divergences can be joined. -/
def IsLocallyConfluent {T : Type*} (R : T → T → Prop) : Prop :=
  ∀ ⦃t u₁ u₂ : T⦄, R t u₁ → R t u₂ →
    ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v

/-- `R` is **confluent** if all divergences can be joined. -/
def IsConfluent {T : Type*} (R : T → T → Prop) : Prop :=
  ∀ ⦃t u₁ u₂ : T⦄, ReflTransGen R t u₁ → ReflTransGen R t u₂ →
    ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v

/-- `R` is **convergent** if it is both terminating and confluent. -/
def IsConvergent {T : Type*} (R : T → T → Prop) : Prop :=
  IsTerminating R ∧ IsConfluent R

/-- Two terms are **joinable** if they share a common reduct. -/
def IsJoinable {T : Type*} (R : T → T → Prop) (a b : T) : Prop :=
  ∃ v, ReflTransGen R a v ∧ ReflTransGen R b v

/-- A rewrite relation is **sound** for an evaluation function if every
    single-step rewrite preserves evaluation in every model. -/
def IsSound {T A α : Type*} (R : T → T → Prop) (eval : (α → A) → T → A) : Prop :=
  ∀ ⦃s t : T⦄, R s t → ∀ (ι : α → A), eval ι s = eval ι t

/-- A **certified normalizer** packages a rewrite relation with a normal-form
    function and correctness witnesses. -/
structure CertifiedNorm (T : Type*) where
  /-- The oriented rewrite relation. -/
  R : T → T → Prop
  /-- The normal-form function. -/
  nf : T → T
  /-- The normal form is always in normal form. -/
  nf_normal : ∀ t, IsNF R (nf t)
  /-- `t` rewrites to `nf t`. -/
  nf_reduces : ∀ t, ReflTransGen R t (nf t)
  /-- Normal forms are unique. -/
  nf_unique : ∀ t u, IsNF R u → ReflTransGen R t u → u = nf t

/-! ## Part 2: Newman's Lemma -/

/-
If `t` is in normal form and `t →* u`, then `t = u`.
-/
theorem nf_of_rtc {T : Type*} {R : T → T → Prop} {t u : T}
    (hnf : IsNF R t) (h : ReflTransGen R t u) : t = u := by
  -- By induction on the length of the path from `t` to `u`.
  induction' h with u hu ih;
  · rfl;
  · exact False.elim ( hnf _ ( by subst_vars; assumption ) )

/-
**Newman's Lemma.** A terminating, locally confluent ARS is confluent.

This is the cornerstone of Knuth-Bendix completion. It reduces confluence
(a global property) to local confluence (checkable via critical pairs).

**Proof sketch.** Well-founded induction on `t` using termination.
Given `t →* u₁` and `t →* u₂`, if either path is trivial, done.
Otherwise `t → s₁ →* u₁` and `t → s₂ →* u₂`. Local confluence
gives a join of `s₁, s₂` at some `w`. Inductive hypothesis on `s₁`
(smaller than `t`) joins `w` and `u₁` at some `v₁`. Then inductive
hypothesis on `w` (reachable from `s₂`, smaller than `t`) joins `v₁`
with the path from `s₂` to `u₂`.
-/
theorem newman_lemma {T : Type*} {R : T → T → Prop}
    (h_term : IsTerminating R)
    (h_local : IsLocallyConfluent R) :
    IsConfluent R := by
  have h_ind : ∀ t, (∀ s, R t s → ∀ u₁ u₂, ReflTransGen R s u₁ → ReflTransGen R s u₂ → ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v) → ∀ u₁ u₂, ReflTransGen R t u₁ → ReflTransGen R t u₂ → ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v := by
    intro t ht u₁ u₂ hu₁ hu₂
    by_cases h_cases : u₁ = t ∨ u₂ = t;
    · grind;
    · obtain ⟨s₁, hs₁⟩ : ∃ s₁, R t s₁ ∧ ReflTransGen R s₁ u₁ := by
        have h_nf_of_rtc : ∀ (t u : T), ReflTransGen R t u → t = u ∨ ∃ s, R t s ∧ ReflTransGen R s u := by
          intro t u htu
          induction' htu with t u htu ih;
          · exact Or.inl rfl;
          · grind;
        exact h_nf_of_rtc t u₁ hu₁ |> Or.rec ( fun h => False.elim ( h_cases <| Or.inl h.symm ) ) fun h => h
      obtain ⟨s₂, hs₂⟩ : ∃ s₂, R t s₂ ∧ ReflTransGen R s₂ u₂ := by
        have := hu₂.cases_head; aesop;
      obtain ⟨ w, hw₁, hw₂ ⟩ := h_local hs₁.1 hs₂.1;
      obtain ⟨v₁, hv₁⟩ : ∃ v₁, ReflTransGen R u₁ v₁ ∧ ReflTransGen R w v₁ := by
        exact ht s₁ hs₁.1 u₁ w hs₁.2 hw₁
      obtain ⟨v₂, hv₂⟩ : ∃ v₂, ReflTransGen R v₁ v₂ ∧ ReflTransGen R u₂ v₂ := by
        exact ht s₂ hs₂.1 v₁ u₂ ( hw₂.trans hv₁.2 ) hs₂.2
      use v₂;
      exact ⟨ hv₁.1.trans hv₂.1, hv₂.2 ⟩;
  intro t u₁ u₂ h₁ h₂;
  contrapose! h_ind;
  obtain ⟨t, ht⟩ : ∃ t, (∃ u₁ u₂, ReflTransGen R t u₁ ∧ ReflTransGen R t u₂ ∧ ∀ v, ReflTransGen R u₁ v → ¬ReflTransGen R u₂ v) ∧ ∀ s, R t s → ¬(∃ u₁ u₂, ReflTransGen R s u₁ ∧ ReflTransGen R s u₂ ∧ ∀ v, ReflTransGen R u₁ v → ¬ReflTransGen R u₂ v) := by
    have := h_term.has_min { t | ∃ u₁ u₂, ReflTransGen R t u₁ ∧ ReflTransGen R t u₂ ∧ ∀ v, ReflTransGen R u₁ v → ¬ReflTransGen R u₂ v } ⟨ t, u₁, u₂, h₁, h₂, h_ind ⟩;
    exact ⟨ this.choose, this.choose_spec.1, fun s hs hs' => this.choose_spec.2 s hs' hs ⟩;
  exact ⟨ t, fun s hs u₁ u₂ hu₁ hu₂ => Classical.not_not.1 fun h => ht.2 s hs ⟨ u₁, u₂, hu₁, hu₂, fun v hv₁ hv₂ => h ⟨ v, hv₁, hv₂ ⟩ ⟩, ht.1 ⟩

/-
In a convergent system, normal forms are unique.
-/
theorem unique_nf {T : Type*} {R : T → T → Prop}
    (h_conv : IsConvergent R)
    {t u₁ u₂ : T}
    (hn₁ : IsNF R u₁) (hn₂ : IsNF R u₂)
    (h₁ : ReflTransGen R t u₁) (h₂ : ReflTransGen R t u₂) :
    u₁ = u₂ := by
  -- By the confluence property, there exists a common reduct `v` such that `u₁ →* v` and `u₂ →* v`.
  obtain ⟨v, hv₁, hv₂⟩ : ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v := by
    exact h_conv.2 h₁ h₂;
  -- By the uniqueness of normal forms, since `u₁` and `u₂` are both in normal form and reduce to `v`, they must be equal.
  have h_unique : u₁ = v := by
    exact?
  have h_unique' : u₂ = v := by
    exact?
  rw [h_unique, h_unique']

/-
In a terminating system, every term has a normal form.
-/
theorem exists_nf {T : Type*} {R : T → T → Prop}
    (h_term : IsTerminating R) (t : T) :
    ∃ u, IsNF R u ∧ ReflTransGen R t u := by
  -- We can prove this using well-founded induction on `t` with respect to the well-founded relation `R`.
  induction' t using h_term.induction with t ih;
  by_cases h : ∃ x, R t x;
  · exact Exists.elim h fun x hx => by obtain ⟨ u, hu₁, hu₂ ⟩ := ih x hx; exact ⟨ u, hu₁, hu₂.head hx ⟩ ;
  · exact ⟨ t, fun u hu => h ⟨ u, hu ⟩, by rfl ⟩

/-
A convergent system has a unique normal form for each term.
-/
theorem convergent_unique_nf {T : Type*} {R : T → T → Prop}
    (h_conv : IsConvergent R) (t : T) :
    ∃! u, IsNF R u ∧ ReflTransGen R t u := by
  obtain ⟨ u, hu ⟩ := exists_nf h_conv.1 t;
  refine' ⟨ u, hu, fun v hv => unique_nf h_conv hv.1 hu.1 hv.2 hu.2 ⟩

/-! ## Part 3: Multi-step Soundness -/

/-
Multi-step rewrite soundness: if single steps preserve evaluation,
    so does the reflexive-transitive closure.
-/
theorem rtc_sound {T A α : Type*}
    {R : T → T → Prop} {eval : (α → A) → T → A}
    (hR : IsSound R eval)
    {s t : T} (hst : ReflTransGen R s t) :
    ∀ (ι : α → A), eval ι s = eval ι t := by
  induction' hst with t ht ih;
  · exact fun _ => rfl;
  · exact fun ι => by rw [ ‹∀ ι, eval ι s = eval ι t› ι, hR ‹_› ι ] ;

/-
The master optimizer theorem: a convergent sound rewrite system's normalizer
    preserves evaluation.
-/
theorem convergent_optimizer {T A α : Type*}
    (N : CertifiedNorm T)
    {eval : (α → A) → T → A}
    (hR : IsSound N.R eval) :
    ∀ (t : T) (ι : α → A), eval ι (N.nf t) = eval ι t := by
  exact fun t ι => Eq.symm ( rtc_sound hR ( N.nf_reduces t ) ι )

/-! ## Part 4: Equational Theory -/

/-- The **equational theory** of `R` is the equivalence closure of `R`. -/
def EqTheory {T : Type*} (R : T → T → Prop) : T → T → Prop := EqvGen R

/-- A single rewrite step is in the equational theory. -/
theorem step_in_eqtheory {T : Type*} {R : T → T → Prop} {a b : T}
    (h : R a b) : EqTheory R a b :=
  EqvGen.rel _ _ h

/-
The reflexive-transitive closure is contained in the equational theory.
-/
theorem rtc_sub_eqtheory {T : Type*} {R : T → T → Prop} {a b : T}
    (h : ReflTransGen R a b) : EqTheory R a b := by
  induction h;
  · exact EqvGen.refl _;
  · exact EqvGen.trans _ _ _ ‹_› ( EqvGen.rel _ _ ‹_› )

/-
In a convergent system, two terms have the same normal form iff they are
in the same equational theory class.
-/
theorem nf_eq_iff_eqtheory {T : Type*} {R : T → T → Prop}
    (h_conv : IsConvergent R)
    (nf : T → T)
    (h_nf_nf : ∀ t, IsNF R (nf t))
    (h_nf_red : ∀ t, ReflTransGen R t (nf t))
    {s t : T} :
    nf s = nf t ↔ EqTheory R s t := by
  constructor;
  · intro h_eq_nf
    have h_eq_nf_s : EqTheory R s (nf s) := by
      exact rtc_sub_eqtheory ( h_nf_red s )
    have h_eq_nf_t : EqTheory R t (nf t) := by
      exact rtc_sub_eqtheory ( h_nf_red t )
    rw [h_eq_nf] at h_eq_nf_s
    exact (by
    exact EqvGen.trans _ _ _ h_eq_nf_s ( EqvGen.symm _ _ h_eq_nf_t ));
  · intro h;
    apply unique_nf h_conv (h_nf_nf s) (h_nf_nf t) (h_nf_red s);
    induction h;
    · exact ReflTransGen.trans ( ReflTransGen.single ‹_› ) ( h_nf_red _ );
    · exact h_nf_red _;
    · grind +suggestions;
    · grind +suggestions

/-! ## Part 5: Completion State and Steps -/

/-- A **completion state** for Knuth-Bendix completion. -/
structure CompletionState (T : Type*) where
  /-- Oriented rewrite rules. -/
  rules : T → T → Prop
  /-- Pending equations. -/
  pending : T → T → Prop

/-- The combined theory of a completion state. -/
def CompletionState.theory {T : Type*} (S : CompletionState T) : T → T → Prop :=
  fun a b => S.rules a b ∨ S.pending a b

/-- A completion state is **finished** if no equations are pending. -/
def CompletionState.isFinished {T : Type*} (S : CompletionState T) : Prop :=
  ∀ a b, ¬S.pending a b

/-- A **KB completion step** preserves the equational theory. -/
structure KBStep {T : Type*} (S S' : CompletionState T) : Prop where
  theory_preserved : ∀ a b, EqTheory S'.theory a b ↔ EqTheory S.theory a b

/-- A **completion sequence** is a chain of KB steps. -/
def CompletionSequence {T : Type*} (S S' : CompletionState T) : Prop :=
  ReflTransGen (fun X Y => KBStep X Y) S S'

/-! ## Part 6: Completion Correctness -/

/-
**A sequence of KB steps preserves the equational theory.**
-/
theorem sequence_preserves_theory {T : Type*}
    {S S' : CompletionState T} (h : CompletionSequence S S') :
    ∀ a b, EqTheory S'.theory a b ↔ EqTheory S.theory a b := by
  induction h;
  · grind;
  · rename_i a b h₁ h₂ h₃;
    exact fun x y => Iff.trans ( h₂.theory_preserved x y ) ( h₃ x y )

/-
When completion finishes, the rules' equational theory equals
    the finished state's theory (since pending is empty).
-/
theorem finished_rules_eq_theory {T : Type*}
    {S : CompletionState T} (h_fin : S.isFinished) :
    ∀ a b, EqTheory S.rules a b ↔ EqTheory S.theory a b := by
  intro a b;
  constructor <;> intro h;
  · exact EqvGen.mono ( fun x y hxy => Or.inl hxy ) h;
  · convert h using 1;
    ext a b; simp +decide [ CompletionState.theory, h_fin ] ;
    exact fun h => False.elim ( h_fin a b h )

/-
**The Capstone Theorem: Terminated KB completion yields a convergent system.**

If completion runs from `S₀` to `S_final` where:
- Each step preserves the equational theory
- The final state has no pending equations
- The final rules are terminating
- The final rules are locally confluent (all critical pairs joined)

Then the final system is convergent and has the same equational theory.
-/
theorem kb_completion_correct {T : Type*}
    {S₀ S_final : CompletionState T}
    (h_seq : CompletionSequence S₀ S_final)
    (h_finished : S_final.isFinished)
    (h_term : IsTerminating S_final.rules)
    (h_local : IsLocallyConfluent S_final.rules) :
    IsConvergent S_final.rules ∧
    (∀ a b, EqTheory S_final.rules a b ↔ EqTheory S₀.theory a b) := by
  -- First part (IsConvergent S_final.rules): Use ⟨h_term, newman_lemma h_term h_local⟩.
  apply And.intro;
  · exact ⟨ h_term, newman_lemma h_term h_local ⟩;
  · exact fun a b => Iff.trans ( finished_rules_eq_theory h_finished a b ) ( sequence_preserves_theory h_seq a b )

/-! ## Part 7: Bridge to Certified Optimizer -/

/-- **A convergent ARS yields a `CertifiedNorm`.**

This bridges KB completion to certified optimization. -/
noncomputable def convergentToCertifiedNorm {T : Type*}
    {R : T → T → Prop}
    (_h_conv : IsConvergent R)
    (nf : T → T)
    (h_nf_normal : ∀ t, IsNF R (nf t))
    (h_nf_reduces : ∀ t, ReflTransGen R t (nf t))
    (h_nf_unique : ∀ t u, IsNF R u → ReflTransGen R t u → u = nf t) :
    CertifiedNorm T where
  R := R
  nf := nf
  nf_normal := h_nf_normal
  nf_reduces := h_nf_reduces
  nf_unique := h_nf_unique

/-
**KB completion composes with certified optimization.**

The full pipeline: equations → completion → convergent system → normalizer → optimizer.
-/
theorem kb_certified_optimizer {T A α : Type*}
    {R : T → T → Prop} {eval : (α → A) → T → A}
    (_h_conv : IsConvergent R)
    (h_sound : IsSound R eval)
    (nf : T → T)
    (_h_nf_normal : ∀ t, IsNF R (nf t))
    (h_nf_reduces : ∀ t, ReflTransGen R t (nf t))
    (_h_nf_unique : ∀ t u, IsNF R u → ReflTransGen R t u → u = nf t) :
    ∀ (t : T) (ι : α → A), eval ι (nf t) = eval ι t := by
  intros t ι
  apply Eq.symm
  apply rtc_sound h_sound (h_nf_reduces t) ι

/-
The normalizer is idempotent.
-/
theorem nf_idempotent' {T : Type*} (N : CertifiedNorm T) :
    ∀ t, N.nf (N.nf t) = N.nf t := by
  intro t;
  apply Eq.symm;
  apply N.nf_unique;
  · exact N.nf_normal t;
  · rfl

/-
Two terms with the same normal form evaluate identically.
-/
theorem eval_eq_of_nf_eq' {T A α : Type*}
    (N : CertifiedNorm T)
    {eval : (α → A) → T → A}
    (hR : IsSound N.R eval)
    {s t : T} (h : N.nf s = N.nf t) :
    ∀ (ι : α → A), eval ι s = eval ι t := by
  -- By the convergent_optimizer theorem, we have that eval ι (N.nf s) = eval ι s and eval ι (N.nf t) = eval ι t.
  have h_eval_nf : ∀ (ι : α → A), eval ι (N.nf s) = eval ι s ∧ eval ι (N.nf t) = eval ι t := by
    exact fun ι => ⟨ convergent_optimizer N hR s ι, convergent_optimizer N hR t ι ⟩;
  grind

/-! ## Part 8: Concrete Example — Boolean Ring Rewriting -/

/-- A simple term type for Boolean ring expressions. -/
inductive BoolTerm
  | var : Nat → BoolTerm
  | zero : BoolTerm
  | one : BoolTerm
  | add : BoolTerm → BoolTerm → BoolTerm
  | mul : BoolTerm → BoolTerm → BoolTerm
  deriving DecidableEq, Repr

/-- Evaluation of Boolean ring terms in `ZMod 2`. -/
def BoolTerm.eval (ι : Nat → ZMod 2) : BoolTerm → ZMod 2
  | .var n => ι n
  | .zero => 0
  | .one => 1
  | .add e₁ e₂ => e₁.eval ι + e₂.eval ι
  | .mul e₁ e₂ => e₁.eval ι * e₂.eval ι

/-- The idempotency rewrite: `x * x → x` (valid in Boolean rings). -/
inductive BoolIdemRewrite : BoolTerm → BoolTerm → Prop
  | idem (e : BoolTerm) : BoolIdemRewrite (.mul e e) e

/-
The idempotency rewrite is sound in `ZMod 2`.
-/
theorem boolIdem_sound :
    IsSound BoolIdemRewrite (fun (ι : Nat → ZMod 2) => BoolTerm.eval ι) := by
  intro s t h;
  cases h;
  simp +decide [ BoolTerm.eval ];
  intro ι; have := Fin.exists_fin_two.mp ⟨ BoolTerm.eval ι t, rfl ⟩ ; aesop;

/-- The involution rewrite: `x + x → 0` (valid in characteristic 2). -/
inductive BoolInvolRewrite : BoolTerm → BoolTerm → Prop
  | invol (e : BoolTerm) : BoolInvolRewrite (.add e e) .zero

/-
The involution rewrite is sound in `ZMod 2`.
-/
theorem boolInvol_sound :
    IsSound BoolInvolRewrite (fun (ι : Nat → ZMod 2) => BoolTerm.eval ι) := by
  intro s t h; cases h; simp +decide [ BoolTerm.eval ] ;
  grind

end KnuthBendix