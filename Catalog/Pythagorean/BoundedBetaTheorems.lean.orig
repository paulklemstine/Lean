/-
# Bounded Beta-Reduction Semantics: Main Theorems

## Main Results

1. **Finiteness (Theorem 1)**: The set of terms reachable from any term within
   `d` steps of β-reduction is finite.

2. **Weak bisimilarity (Theorem 2)**: β-equivalent terms yield weakly
   bisimilar bounded FTS, without needing Church-Rosser.

3. **Modal invariance (Theorem 3)**: (a) Strong bisimilar FTS satisfy the
   same modal formulas. (b) Weakly bisimilar FTS satisfy the same weak
   modal formulas (where ◇ means multi-step reachability). (c) β-equivalent
   terms preserve all weak modal observations.
-/

import Pythagorean.BoundedBetaDefs

/-! ## Auxiliary Lemmas -/

/-
Each lambda term has only finitely many one-step β-reducts.
-/
theorem finite_betaStep_successors (t : Lam) :
    Set.Finite {u : Lam | BetaStep t u} := by
  induction' t with x t u ih_t ih_u₂ t ih;
  · exact Set.finite_empty.subset fun u hu => by cases hu;
  · refine Set.Finite.subset ( ih_t.image ( fun x => x.app u ) |> Set.Finite.union <| ih_u₂.image ( fun x => t.app x ) |> Set.Finite.union <| Set.finite_singleton ( match t with | .lam x body => body.subst x u | _ => .var 0 ) ) ?_;
    rintro v ( h | h | h ) <;> simp_all +decide;
  · exact Set.Finite.subset ( Set.Finite.image ( fun u => Lam.lam t u ) ‹_› ) fun u hu => by cases hu ; tauto;

/-
Reachable set at depth d+1 decomposes.
-/
theorem reachableWithin_succ_subset (d : Nat) (t : Lam) :
    {u | ReachableWithin (d + 1) t u} ⊆
      {u | ReachableWithin d t u} ∪
      ⋃ v ∈ {w | ReachableWithin d t w}, {u | BetaStep v u} := by
  intro u hu
  cases hu;
  · exact Or.inl <| ReachableWithin.refl _ _;
  · aesop

/-
BetaStep prepends to reachability.
-/
theorem reachableWithin_prepend {d : Nat} {t u v : Lam}
    (hs : BetaStep t u) (hr : ReachableWithin d u v) :
    ReachableWithin (d + 1) t v := by
  induction' hr with d t u v w hr ih hstep';
  · exact ReachableWithin.step ( ReachableWithin.refl _ _ ) hs;
  · exact ReachableWithin.step ( ‹BetaStep t v → ReachableWithin ( u + 1 ) t w› hs ) hstep'

/-! ## Theorem 1: Finiteness of Bounded Beta-Reduct Systems -/

/-
**Theorem 1** (Finiteness of bounded β-reduct systems):
    For every lambda term `t` and depth bound `d`, the set of terms
    reachable from `t` by at most `d` one-step β-reductions is finite.
    This theorem turns operational semantics into finite-state mathematics.

    Proof by induction on `d`:
    - Base: only `t` is reachable in 0 steps.
    - Step: the `(d+1)`-reachable set is covered by the `d`-reachable set
      plus one-step successors. By induction and finite branching, all finite.
-/
theorem finite_states_of_bounded_beta
    (d : Nat) (t : Lam) :
    Set.Finite {u : Lam | ReachableWithin d t u} := by
  induction' d with d ih generalizing t;
  · exact Set.Finite.subset ( Set.finite_singleton t ) fun u hu => by cases hu; aesop;
  · exact Set.Finite.subset ( Set.Finite.union ( ih t ) ( Set.Finite.biUnion ( ih t ) fun u hu => finite_betaStep_successors u ) ) ( reachableWithin_succ_subset d t )

/-! ## Theorem 2: β-Equivalence → Weak Bisimilarity -/

/-- Weak bisimulation: each step can be matched by zero or more steps. -/
def WeakBisimilar (A B : FTS) : Prop :=
  ∃ R : A.State → B.State → Prop,
    R A.init B.init ∧
    (∀ a b, R a b → ∀ a', A.step a a' →
      ∃ b', Relation.ReflTransGen B.step b b' ∧ R a' b') ∧
    (∀ a b, R a b → ∀ b', B.step b b' →
      ∃ a', Relation.ReflTransGen A.step a a' ∧ R a' b')

/-- Weak simulation (one direction). -/
def WeakSimulates (A B : FTS) : Prop :=
  ∃ R : A.State → B.State → Prop,
    R A.init B.init ∧
    (∀ a b, R a b → ∀ a', A.step a a' →
      ∃ b', Relation.ReflTransGen B.step b b' ∧ R a' b')

/-- BetaEq is preserved under β-reduction on the left. -/
theorem betaEq_step_left {a b a' : Lam}
    (hR : BetaEq a b) (hs : BetaStep a a') : BetaEq a' b :=
  BetaEq.trans (BetaEq.symm (BetaEq.step hs)) hR

/-- BetaEq is preserved under β-reduction on the right. -/
theorem betaEq_step_right {a b b' : Lam}
    (hR : BetaEq a b) (hs : BetaStep b b') : BetaEq a b' :=
  BetaEq.trans hR (BetaEq.step hs)

/-
**Theorem 2a**: If `BetaStep t u`, then `toFTS d u` is weakly simulated
    by `toFTS (d+1) t`.
-/
theorem betaStep_weak_simulation
    (d : Nat) {t u : Lam} (h : BetaStep t u) :
    WeakSimulates (toFTS d u) (toFTS (d + 1) t) := by
  refine' ⟨ fun a b => ( a = u ∧ b = t ) ∨ a = b, _, _ ⟩ <;> simp +decide [ toFTS ];
  rintro a b ( ⟨ rfl, rfl ⟩ | rfl ) a' ha ha' h;
  · use a';
    refine' ⟨ _, Or.inr rfl ⟩;
    have h_path : ReachableWithin (d + 1) b a ∧ ReachableWithin (d + 1) b a' ∧ BetaStep a a' := by
      exact ⟨ reachableWithin_prepend ‹_› ( ReachableWithin.refl _ _ ), reachableWithin_prepend ‹_› ha', h ⟩;
    have h_path : Relation.ReflTransGen (fun s₁ s₂ => ReachableWithin (d + 1) b s₁ ∧ ReachableWithin (d + 1) b s₂ ∧ BetaStep s₁ s₂) b a := by
      exact .single ⟨ ReachableWithin.refl _ _, h_path.1, by assumption ⟩;
    exact h_path.tail ( by tauto );
  · refine' ⟨ a', _, _ ⟩;
    · exact .single ⟨ by exact reachableWithin_prepend ‹_› ha, by exact reachableWithin_prepend ‹_› ha', h ⟩;
    · grind +extAll

/-
**Theorem 2b** (β-equivalence implies weak bisimilarity):
    β-equivalent terms produce weakly bisimilar bounded FTS.

    The bisimulation relation is `R a b ↔ BetaEq a b`.
    When BetaEq a b and BetaStep a a', we match with zero steps (b' = b),
    since BetaEq a' b holds by `betaEq_step_left`.
    When BetaEq a b and BetaStep b b', we match with zero steps (a' = a),
    since BetaEq a b' holds by `betaEq_step_right`.

    This captures the key insight: β-equivalence is a behavioral invariant
    under bounded observation. The finite structure up to stuttering is
    preserved because the equivalence relation absorbs individual steps.

    Remarkably, this does NOT require Church-Rosser.
-/
theorem beta_equiv_weakBisimilar_toFTS
    (d : Nat) {t u : Lam}
    (hβ : BetaEq t u) :
    WeakBisimilar (toFTS d t) (toFTS d u) := by
  use fun a b => BetaEq a b;
  refine' ⟨ hβ, _, _ ⟩;
  · intro a b hab a' ha';
    use b;
    exact ⟨ by rfl, betaEq_step_left hab ha'.2.2 ⟩;
  · intro a b hab b' hb';
    exact ⟨ a, by tauto, betaEq_step_right hab hb'.2.2 ⟩

/-! ## Theorem 3: Modal Invariance -/

/-
**Theorem 3a**: Bisimilar states satisfy the same modal formulas.
    Proof by induction on formula structure.
-/
theorem bisimilar_states_satisfy_same_formulas
    {A B : FTS} (R : A.State → B.State → Prop)
    (hFwd : ∀ a b, R a b → ∀ a', A.step a a' → ∃ b', B.step b b' ∧ R a' b')
    (hBwd : ∀ a b, R a b → ∀ b', B.step b b' → ∃ a', A.step a a' ∧ R a' b')
    (a : A.State) (b : B.State) (hr : R a b)
    (φ : ModalFormula) :
    SatisfiesFTS A a φ ↔ SatisfiesFTS B b φ := by
  induction' φ with φ ψ ihφ ihψ generalizing a b <;> simp_all +decide [ SatisfiesFTS ];
  · rw [ ψ a b hr ];
  · grind +extAll;
  · grind +qlia

/-
Bisimilar FTS satisfy the same modal formulas at initial states.
-/
theorem bisimilar_preserves_modal_theory
    {A B : FTS} (h : Bisimilar A B) (φ : ModalFormula) :
    HoldsAtInit A φ ↔ HoldsAtInit B φ := by
  apply bisimilar_states_satisfy_same_formulas;
  exact h.choose_spec.2.1;
  · exact h.choose_spec.2.2;
  · exact h.choose_spec.1

/-- Weak modal satisfaction: diamond means multi-step reachability.
    This is the correct modal logic for weak bisimulation. -/
def WeakSatisfiesFTS (A : FTS) : A.State → ModalFormula → Prop
  | _, .top => True
  | s, .neg φ => ¬ WeakSatisfiesFTS A s φ
  | s, .conj φ ψ => WeakSatisfiesFTS A s φ ∧ WeakSatisfiesFTS A s ψ
  | s, .diamond φ => ∃ s', Relation.ReflTransGen A.step s s' ∧ WeakSatisfiesFTS A s' φ

/-- Weak modal holding at initial state. -/
def WeakHoldsAtInit (A : FTS) (φ : ModalFormula) : Prop :=
  WeakSatisfiesFTS A A.init φ

/-
**Theorem 3b**: Weakly bisimilar states satisfy the same weak modal formulas.
    This is the Hennessy-Milner theorem for weak bisimulation.
-/
theorem weakBisimilar_states_satisfy_same_weak_formulas
    {A B : FTS} (R : A.State → B.State → Prop)
    (hFwd : ∀ a b, R a b → ∀ a', A.step a a' →
      ∃ b', Relation.ReflTransGen B.step b b' ∧ R a' b')
    (hBwd : ∀ a b, R a b → ∀ b', B.step b b' →
      ∃ a', Relation.ReflTransGen A.step a a' ∧ R a' b')
    (a : A.State) (b : B.State) (hr : R a b)
    (φ : ModalFormula) :
    WeakSatisfiesFTS A a φ ↔ WeakSatisfiesFTS B b φ := by
  -- Apply the lemma to rewrite the goal in terms of the relation R.
  have h_rewrite : ∀ a b, R a b → ∀ φ, WeakSatisfiesFTS A a φ ↔ WeakSatisfiesFTS B b φ := by
    intro a b hr φ; induction' φ with φ ψ hφ hψ generalizing a b;
    · exact iff_of_true trivial trivial;
    · simp +decide [ WeakSatisfiesFTS, ψ a b hr ];
    · simp +decide [ *, WeakSatisfiesFTS ];
      grind;
    · constructor <;> rintro ⟨ a', ha', ha'' ⟩;
      · have h_lift : ∀ a b, R a b → ∀ a', Relation.ReflTransGen A.step a a' → ∃ b', Relation.ReflTransGen B.step b b' ∧ R a' b' := by
          intros a b hr a' ha'
          induction' ha' with a'' a''' ha'' ha''' ih;
          · exact ⟨ b, by rfl, hr ⟩;
          · obtain ⟨ b', hb', hb'' ⟩ := ih; obtain ⟨ b'', hb'', hb''' ⟩ := hFwd _ _ hb'' _ ha'''; exact ⟨ b'', hb'.trans hb'', hb''' ⟩ ;
        grind +locals;
      · -- By induction on the path from b to a', we can show that there exists a path from a to some a'' such that R a'' a'.
        have h_path : ∀ b' : B.State, Relation.ReflTransGen B.step b b' → ∃ a'' : A.State, Relation.ReflTransGen A.step a a'' ∧ R a'' b' := by
          intro b' hb'
          induction' hb' with b'' hb'' ih;
          · exact ⟨ a, by rfl, hr ⟩;
          · obtain ⟨ a'', ha'', ha''' ⟩ := ‹_›; obtain ⟨ a''', ha''', ha'''' ⟩ := hBwd _ _ ha''' _ ‹_›; exact ⟨ a''', ha''.trans ha''', ha'''' ⟩ ;
        grind +locals;
  exact h_rewrite a b hr φ

/-
Weakly bisimilar FTS satisfy the same weak modal formulas at initial states.
-/
theorem weakBisimilar_preserves_weak_modal_theory
    {A B : FTS} (h : WeakBisimilar A B) (φ : ModalFormula) :
    WeakHoldsAtInit A φ ↔ WeakHoldsAtInit B φ := by
  -- Let's obtain the relation R from the hypothesis h.
  obtain ⟨R, hR⟩ := h;
  apply weakBisimilar_states_satisfy_same_weak_formulas R hR.2.1 hR.2.2 A.init B.init hR.1

/-
**Main Theorem** (β-equivalence preserves weak modal properties):
    β-equivalent lambda terms preserve all weak modal observations
    at any bounded depth. This is the bridge from higher-order rewriting
    to finite-state temporal logic verification.
-/
theorem beta_equiv_preserves_weak_modal_properties
    (d : Nat) {t u : Lam}
    (hβ : BetaEq t u) (φ : ModalFormula) :
    WeakHoldsAtInit (toFTS d t) φ ↔ WeakHoldsAtInit (toFTS d u) φ := by
  convert weakBisimilar_preserves_weak_modal_theory _ _;
  convert beta_equiv_weakBisimilar_toFTS d hβ using 1


-- !-- Merged from BoundedBetaDefs.lean (auto-dedup) -- !--

# Bounded Beta-Reduction Semantics: Definitions
Defines core structures for extracting finite transition systems from lambda
calculus terms under bounded β-reduction.
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
/-- If `u` is reachable from `t` within 0 steps, then `u = t`. -/
theorem reachableWithin_zero_iff {t u : Lam} :
    ReachableWithin 0 t u ↔ u = t := by
  · intro h; cases h with | refl => rfl
  · rintro rfl; exact ReachableWithin.refl 0 _
ReachableWithin is monotone in the depth bound.
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
Reachable terms are β-equivalent to the source.
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
    (∀ a b, R a b → ∀ a', A.step a a' → ∃ b', B.step b b' ∧ R a' b') ∧
    (∀ a b, R a b → ∀ b', B.step b b' → ∃ a', A.step a a' ∧ R a' b')
Bisimilarity is reflexive.
theorem Bisimilar.rfl' (A : FTS) : Bisimilar A A := by
  use fun a b => a = b;
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
  | s, .neg φ => ¬ SatisfiesFTS A s φ
  | s, .conj φ ψ => SatisfiesFTS A s φ ∧ SatisfiesFTS A s ψ
  | s, .diamond φ => ∃ s', A.step s s' ∧ SatisfiesFTS A s' φ
/-- A modal formula holds at the initial state of an FTS. -/
def HoldsAtInit (A : FTS) (φ : ModalFormula) : Prop :=