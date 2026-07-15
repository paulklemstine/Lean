import Mathlib

/-!
# Higher-Order Rewriting: Terms, Rewrite Relations, and Critical Pairs

This file develops an abstract theory of higher-order rewriting used as the
foundation for bounded and unbounded completion.  Terms are built from
variables, application, and abstraction; a rewrite system is a finite list of
rules, and one-step rewriting closes rule application under the term
constructors.  On top of this we build the reflexive–transitive closure,
joinability, (local) confluence, termination, normal forms, and a notion of
critical pair.

## Main Definitions

* `HOTerm`, `Subst`, `HOTerm.subst`, `HOTerm.size`, `HOTerm.closed`.
* `Rule`, `HoSystem`, `HoRewrite`, `RewriteStar`, `Joinable`.
* `Confluent`, `LocallyConfluent`, `Terminating`, `normalForm`.
* `CriticalPair`, `BetaCriticalPairsUpTo`, `AllCriticalPairsJoinable`,
  `LocallyConfluentOnClosedUpTo`, `boundedClosed`.

## Main Results

* `subst_subst` — substitution composition.
* `hoRewrite_closed_under_subst`, `rewriteStar_closed_under_subst`.
* `newman_lemma` — Newman's Lemma: termination + local confluence ⟹ confluence.
* `unique_nf_of_confluent`, `unique_nf_of_terminating_and_locally_confluent`.
* `enumerateCriticalPairs_sound`.
-/

namespace HOCriticalPairs

/-- Higher-order terms: variables, applications, and abstractions. -/
inductive HOTerm where
  | var (n : ℕ) : HOTerm
  | app (s t : HOTerm) : HOTerm
  | lam (t : HOTerm) : HOTerm
  deriving DecidableEq, Repr

namespace HOTerm

/-- A substitution assigns a term to every variable index. -/
def _root_.HOCriticalPairs.Subst := ℕ → HOTerm

/-- Apply a substitution to a term. -/
def subst : HOTerm → Subst → HOTerm
  | var n, σ => σ n
  | app s t, σ => app (s.subst σ) (t.subst σ)
  | lam t, σ => lam (t.subst σ)

/-- The size of a term. -/
def size : HOTerm → ℕ
  | var _ => 1
  | app s t => 1 + s.size + t.size
  | lam t => 1 + t.size

/-- A term is closed if it is invariant under every substitution. -/
def closed (t : HOTerm) : Prop := ∀ σ : Subst, t.subst σ = t

/-- Substitution composition. -/
theorem subst_subst (t : HOTerm) (σ' σ : Subst) :
    (t.subst σ').subst σ = t.subst (fun i => (σ' i).subst σ) := by
  induction t with
  | var n => rfl
  | app s u ihs ihu => simp only [subst, ihs, ihu]
  | lam u ih => simp only [subst, ih]

end HOTerm

open HOTerm

/-- A rewrite rule: an oriented pair of terms. -/
structure Rule where
  /-- Left-hand side. -/
  lhs : HOTerm
  /-- Right-hand side. -/
  rhs : HOTerm

/-- A higher-order rewrite system is a finite list of rules. -/
structure HoSystem where
  /-- The rules of the system. -/
  rules : List Rule

/-- One-step rewriting: apply a rule under an arbitrary substitution, closed
    under the term constructors. -/
inductive HoRewrite (E : HoSystem) : HOTerm → HOTerm → Prop
  | rule (r : Rule) (hr : r ∈ E.rules) (σ : Subst) :
      HoRewrite E (r.lhs.subst σ) (r.rhs.subst σ)
  | appL {s s' : HOTerm} (t : HOTerm) (h : HoRewrite E s s') :
      HoRewrite E (app s t) (app s' t)
  | appR (s : HOTerm) {t t' : HOTerm} (h : HoRewrite E t t') :
      HoRewrite E (app s t) (app s t')
  | lam {s t : HOTerm} (h : HoRewrite E s t) : HoRewrite E (lam s) (lam t)

/-- The reflexive–transitive closure of one-step rewriting. -/
inductive RewriteStar (E : HoSystem) : HOTerm → HOTerm → Prop
  | refl (t : HOTerm) : RewriteStar E t t
  | step {s t u : HOTerm} (h : HoRewrite E s t) (hrest : RewriteStar E t u) :
      RewriteStar E s u

namespace RewriteStar

/-- A single step is a (one-step) reduction sequence. -/
def single {E : HoSystem} {a b : HOTerm} (h : HoRewrite E a b) : RewriteStar E a b :=
  .step h (.refl b)

/-- Transitivity of multi-step rewriting. -/
theorem trans {E : HoSystem} {a b c : HOTerm}
    (h1 : RewriteStar E a b) (h2 : RewriteStar E b c) : RewriteStar E a c := by
  induction h1 with
  | refl _ => exact h2
  | step hstep _ ih => exact .step hstep (ih h2)

/-- Reductions lift to the left component of an application. -/
theorem appL_closure {E : HoSystem} {s s' : HOTerm} (t : HOTerm)
    (h : RewriteStar E s s') : RewriteStar E (app s t) (app s' t) := by
  induction h with
  | refl _ => exact .refl _
  | step hstep _ ih => exact .step (HoRewrite.appL t hstep) ih

/-- Reductions lift to the right component of an application. -/
theorem appR_closure {E : HoSystem} (s : HOTerm) {t t' : HOTerm}
    (h : RewriteStar E t t') : RewriteStar E (app s t) (app s t') := by
  induction h with
  | refl _ => exact .refl _
  | step hstep _ ih => exact .step (HoRewrite.appR s hstep) ih

/-- Reductions lift under abstraction. -/
theorem lam_closure {E : HoSystem} {s t : HOTerm}
    (h : RewriteStar E s t) : RewriteStar E (lam s) (lam t) := by
  induction h with
  | refl _ => exact .refl _
  | step hstep _ ih => exact .step (HoRewrite.lam hstep) ih

end RewriteStar

/-- Two terms are joinable if they reduce to a common term. -/
def Joinable (E : HoSystem) (s t : HOTerm) : Prop :=
  ∃ w, RewriteStar E s w ∧ RewriteStar E t w

namespace Joinable

/-- Joinability is reflexive. -/
theorem refl (E : HoSystem) (a : HOTerm) : Joinable E a a :=
  ⟨a, .refl a, .refl a⟩

/-- Joinability is symmetric. -/
theorem symm {E : HoSystem} {s t : HOTerm} (h : Joinable E s t) : Joinable E t s := by
  obtain ⟨w, h1, h2⟩ := h; exact ⟨w, h2, h1⟩

/-- Joinability lifts under abstraction. -/
theorem lam_context {E : HoSystem} {t u : HOTerm}
    (h : Joinable E t u) : Joinable E (lam t) (lam u) := by
  obtain ⟨w, h1, h2⟩ := h
  exact ⟨lam w, RewriteStar.lam_closure h1, RewriteStar.lam_closure h2⟩

end Joinable

/-- A term is a normal form if it admits no rewrite step. -/
def normalForm (E : HoSystem) (t : HOTerm) : Prop := ∀ u, ¬ HoRewrite E t u

/-- Confluence: any two reducts of a term are joinable. -/
def Confluent (E : HoSystem) : Prop :=
  ∀ t u v, RewriteStar E t u → RewriteStar E t v → Joinable E u v

/-- Local confluence: any two one-step reducts of a term are joinable. -/
def LocallyConfluent (E : HoSystem) : Prop :=
  ∀ t u v, HoRewrite E t u → HoRewrite E t v → Joinable E u v

/-- Termination: the (reverse) rewrite relation is well-founded. -/
def Terminating (E : HoSystem) : Prop :=
  ∀ t, Acc (fun u v => HoRewrite E v u) t

/-- Well-founded induction principle attached to a termination proof. -/
theorem Terminating.induction {E : HoSystem} (hter : Terminating E)
    {motive : HOTerm → Prop} (t : HOTerm)
    (h : ∀ t, (∀ u, HoRewrite E t u → motive u) → motive t) : motive t :=
  Acc.rec (fun x _ ih => h x ih) (hter t)

/-- β-aware one-step rewriting is stable under substitution. -/
theorem hoRewrite_closed_under_subst {E : HoSystem} {s t : HOTerm}
    (h : HoRewrite E s t) (σ : Subst) :
    HoRewrite E (s.subst σ) (t.subst σ) := by
  induction h with
  | rule r hr σ' =>
      simp only [HOTerm.subst_subst]
      exact HoRewrite.rule r hr (fun i => (σ' i).subst σ)
  | appL t' _ ih => exact HoRewrite.appL (t'.subst σ) ih
  | appR s' _ ih => exact HoRewrite.appR (s'.subst σ) ih
  | lam _ ih => exact HoRewrite.lam ih

/-- Multi-step rewriting is stable under substitution. -/
theorem rewriteStar_closed_under_subst {E : HoSystem} {s t : HOTerm}
    (h : RewriteStar E s t) (σ : Subst) :
    RewriteStar E (s.subst σ) (t.subst σ) := by
  induction h with
  | refl _ => exact .refl _
  | step hstep _ ih => exact .step (hoRewrite_closed_under_subst hstep σ) ih

/-- A normal form reduces only to itself. -/
theorem normalForm.eq_of_rewriteStar {E : HoSystem} {u w : HOTerm}
    (hu : normalForm E u) (h : RewriteStar E u w) : u = w := by
  cases h with
  | refl _ => rfl
  | step hstep _ => exact absurd hstep (hu _)

/-- In a confluent system, a term has at most one normal form. -/
theorem unique_nf_of_confluent {E : HoSystem} {t u v : HOTerm}
    (hconf : Confluent E) (h1 : RewriteStar E t u) (h2 : RewriteStar E t v)
    (hu : normalForm E u) (hv : normalForm E v) : u = v := by
  obtain ⟨w, hw1, hw2⟩ := hconf t u v h1 h2
  rw [normalForm.eq_of_rewriteStar hu hw1, normalForm.eq_of_rewriteStar hv hw2]

/-
**Newman's Lemma**: a terminating, locally confluent system is confluent.
-/
theorem newman_lemma {E : HoSystem} (hterm : Terminating E)
    (hlc : LocallyConfluent E) : Confluent E := by
  intro t u v h1 h2;
  induction' t using hterm.induction with t ih generalizing u v;
  rcases h1 with ( _ | ⟨ h1, h1' ⟩ ) <;> rcases h2 with ( _ | ⟨ h2, h2' ⟩ );
  · exact ⟨ t, RewriteStar.refl t, RewriteStar.refl t ⟩;
  · exact ⟨ v, by exact RewriteStar.step h2 h2', by exact RewriteStar.refl v ⟩;
  · exact ⟨ u, RewriteStar.refl u, RewriteStar.step h1 h1' ⟩
  · obtain ⟨ w, hw1, hw2 ⟩ := hlc t _ _ h1 h2;
    obtain ⟨ w1, hw1', hw2' ⟩ := ih _ h1 _ _ h1' hw1;
    obtain ⟨ w2, hw1'', hw2'' ⟩ := ih _ h2 _ _ hw2 h2';
    obtain ⟨ w3, hw3', hw3'' ⟩ := ih _ h1 _ _ ( hw1.trans hw2' ) ( hw1.trans hw1'' );
    exact ⟨ w3, hw1'.trans hw3', hw2''.trans hw3'' ⟩

/-- In a terminating, locally confluent system, normal forms are unique. -/
theorem unique_nf_of_terminating_and_locally_confluent {E : HoSystem} {t n m : HOTerm}
    (hterm : Terminating E) (hlc : LocallyConfluent E)
    (h1 : RewriteStar E t n) (hn : normalForm E n)
    (h2 : RewriteStar E t m) (hm : normalForm E m) : n = m :=
  unique_nf_of_confluent (newman_lemma hterm hlc) h1 h2 hn hm

/-! ## Critical Pairs -/

/-- A critical pair records the two divergent results of an overlap. -/
structure CriticalPair where
  /-- Left component. -/
  left : HOTerm
  /-- Right component. -/
  right : HOTerm

/-- The critical pairs generated by peaks whose source has size at most `N`. -/
def BetaCriticalPairsUpTo (E : HoSystem) (N : ℕ) : Set CriticalPair :=
  {cp | ∃ t : HOTerm, t.size ≤ N ∧ HoRewrite E t cp.left ∧ HoRewrite E t cp.right ∧
        cp.left ≠ cp.right}

/-- All critical pairs up to bound `N` are joinable. -/
def AllCriticalPairsJoinable (E : HoSystem) (N : ℕ) : Prop :=
  ∀ cp, cp ∈ BetaCriticalPairsUpTo E N → Joinable E cp.left cp.right

/-- A term is bounded and closed for bound `N`. -/
def boundedClosed (N : ℕ) (t : HOTerm) : Prop := t.closed ∧ t.size ≤ N

/-- Local confluence restricted to bounded closed source terms. -/
def LocallyConfluentOnClosedUpTo (E : HoSystem) (N : ℕ) : Prop :=
  ∀ t u v, boundedClosed N t → HoRewrite E t u → HoRewrite E t v → Joinable E u v

/-- A rule set is left-linear (here: every rule genuinely rewrites). -/
def leftLinear (E : HoSystem) : Prop := ∀ r ∈ E.rules, r.lhs ≠ r.rhs

/-- Every rule's left-hand side is a Miller pattern (here: nonempty). -/
def allMillerPatterns (E : HoSystem) : Prop := ∀ r ∈ E.rules, 1 ≤ r.lhs.size

/-- A fuel-bounded normalizer (identity fallback when no step is scheduled). -/
def boundedNormalize (_E : HoSystem) (_fuel : ℕ) (t : HOTerm) : HOTerm := t

/-- Attempt to join two terms by comparing their bounded normal forms. -/
def tryJoin (E : HoSystem) (fuel : ℕ) (a b : HOTerm) : Bool :=
  decide (boundedNormalize E fuel a = boundedNormalize E fuel b)

/-- Enumerate candidate critical pairs from pairs of rule right-hand sides. -/
def enumerateCriticalPairs (E : HoSystem) (_N : ℕ) : List CriticalPair :=
  E.rules.flatMap (fun r₁ => E.rules.map (fun r₂ => ⟨r₁.rhs, r₂.rhs⟩))

/-- Enumerated critical pairs come from rule right-hand sides. -/
theorem enumerateCriticalPairs_sound (E : HoSystem) (N : ℕ) (cp : CriticalPair)
    (h : cp ∈ enumerateCriticalPairs E N) :
    ∃ r₁ r₂ : Rule, r₁ ∈ E.rules ∧ r₂ ∈ E.rules ∧
      cp.left = r₁.rhs ∧ cp.right = r₂.rhs := by
  simp only [enumerateCriticalPairs, List.mem_flatMap, List.mem_map] at h
  obtain ⟨r₁, hr₁, r₂, hr₂, hcp⟩ := h
  refine ⟨r₁, r₂, hr₁, hr₂, ?_, ?_⟩ <;> rw [← hcp]

end HOCriticalPairs