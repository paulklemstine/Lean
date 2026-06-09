import Mathlib

/-!
# Multi-Sorted Signatures, Terms, and Algebras

This file defines the foundational structures for multi-sorted universal algebra:
multi-sorted signatures, well-sorted terms (indexed by sort), multi-sorted algebras,
evaluation, and substitution. Sort-safety is enforced by dependent types —
ill-sorted terms simply cannot be constructed.

## Main Definitions

- `MSig`: A multi-sorted algebraic signature with typed operations
- `MTerm S s`: Well-sorted terms of sort `s` over signature `S`
- `MAlg S`: A multi-sorted S-algebra
- `MTerm.eval`: Evaluation of terms in an algebra
- `MTerm.subst`: Sort-preserving substitution
- `SortedEnv`: Sort-respecting variable environment

## Key Properties

- Substitution is sort-preserving by construction (dependent types)
- Evaluation commutes with substitution (substitution lemma)
-/

open Finset

/-- A multi-sorted algebraic signature.
    - `Srt` is the set of sorts
    - `numOps` is the number of operation symbols
    - `arity` gives the number of arguments for each operation
    - `argSorts` gives the sort of each argument position
    - `resultSort` gives the result sort of each operation -/
structure MSig where
  /-- The set of sorts -/
  Srt : Type
  /-- Number of operations -/
  numOps : ℕ
  /-- Arity of each operation -/
  arity : Fin numOps → ℕ
  /-- Sort of each argument position -/
  argSorts : (f : Fin numOps) → Fin (arity f) → Srt
  /-- Result sort of each operation -/
  resultSort : Fin numOps → Srt

/-- Well-sorted terms over a multi-sorted signature, indexed by their sort.
    This is a dependent inductive type: `MTerm S s` is the type of terms
    of sort `s`. Ill-sorted terms are unrepresentable. -/
inductive MTerm (S : MSig) : S.Srt → Type
  /-- A variable of sort `s`, identified by a natural number index -/
  | var : (s : S.Srt) → ℕ → MTerm S s
  /-- An operation applied to well-sorted arguments -/
  | op : (f : Fin S.numOps) →
         (args : (i : Fin (S.arity f)) → MTerm S (S.argSorts f i)) →
         MTerm S (S.resultSort f)

/-- A multi-sorted S-algebra: a carrier type for each sort,
    with typed interpretations of each operation. -/
structure MAlg (S : MSig) where
  /-- Carrier set for each sort -/
  carrier : S.Srt → Type
  /-- Interpretation of each operation -/
  interp : (f : Fin S.numOps) →
           ((i : Fin (S.arity f)) → carrier (S.argSorts f i)) →
           carrier (S.resultSort f)

/-- A sorted environment: assigns a value of the appropriate carrier type
    to each variable of each sort. -/
def SortedEnv (S : MSig) (A : MAlg S) :=
  (s : S.Srt) → ℕ → A.carrier s

/-- Evaluate a well-sorted term in a multi-sorted algebra
    under a sorted environment. -/
def MTerm.eval {S : MSig} (A : MAlg S) (ρ : SortedEnv S A) :
    {s : S.Srt} → MTerm S s → A.carrier s
  | _, .var s n => ρ s n
  | _, .op f args => A.interp f (fun i => (args i).eval A ρ)

/-- A sorted substitution: maps each variable of sort `s` to a term of sort `s`. -/
def SortedSubst (S : MSig) := (s : S.Srt) → ℕ → MTerm S s

/-- Apply a sorted substitution to a term. The result has the same sort
    as the input — guaranteed by dependent types. -/
def MTerm.subst {S : MSig} (σ : SortedSubst S) :
    {s : S.Srt} → MTerm S s → MTerm S s
  | _, .var s n => σ s n
  | _, .op f args => .op f (fun i => (args i).subst σ)

/-- The substitution lemma for multi-sorted terms:
    evaluating a substituted term equals evaluating the original
    under the composed environment. -/
theorem MTerm.eval_subst {S : MSig} {A : MAlg S}
    {ρ : SortedEnv S A} {σ : SortedSubst S}
    {s : S.Srt} (t : MTerm S s) :
    (t.subst σ).eval A ρ = t.eval A (fun s' n => (σ s' n).eval A ρ) := by
  induction t with
  | var s n => simp [MTerm.subst, MTerm.eval]
  | op f args ih => simp [MTerm.subst, MTerm.eval, ih]

/-- Size of a multi-sorted term (number of nodes). -/
def MTerm.size {S : MSig} : {s : S.Srt} → MTerm S s → ℕ
  | _, .var _ _ => 1
  | _, .op f args => 1 + Finset.sum Finset.univ (fun i => (args i).size)

/-- Every term has positive size. -/
theorem MTerm.size_pos {S : MSig} {s : S.Srt} (t : MTerm S s) :
    0 < t.size := by
  cases t with
  | var _ _ => simp [MTerm.size]
  | op f args => simp [MTerm.size]

/-! ## Multi-Sorted Equations and Rewrite Rules -/

/-- A multi-sorted equation: a pair of terms of the same sort. -/
structure MSEquation (S : MSig) where
  /-- The sort of both sides -/
  eqSort : S.Srt
  /-- Left-hand side -/
  lhs : MTerm S eqSort
  /-- Right-hand side -/
  rhs : MTerm S eqSort

/-- A multi-sorted rewrite rule: a directed equation between
    terms of the same sort. Sort-preservation is by construction. -/
structure MSRule (S : MSig) where
  /-- The sort of both sides -/
  ruleSort : S.Srt
  /-- Left-hand side (pattern) -/
  lhs : MTerm S ruleSort
  /-- Right-hand side (replacement) -/
  rhs : MTerm S ruleSort

/-- An algebra satisfies a multi-sorted equation if both sides evaluate
    the same under every sorted environment. -/
def MAlg.satisfiesEq {S : MSig} (A : MAlg S) (eq : MSEquation S) : Prop :=
  ∀ (ρ : SortedEnv S A), eq.lhs.eval A ρ = eq.rhs.eval A ρ

/-- An algebra satisfies a set of equations. -/
def MAlg.satisfiesAll {S : MSig} (A : MAlg S) (E : Set (MSEquation S)) : Prop :=
  ∀ eq ∈ E, A.satisfiesEq eq

/-! ## Rewrite Steps and Sequences -/

/-- A single rewrite step in a multi-sorted system.
    Sort-preservation is automatic: both sides of every rule have the same sort,
    and rewriting inside an operation preserves argument sorts.
    This is the multi-sorted **subject reduction theorem** by construction. -/
inductive MSStep {S : MSig} (rules : Set (MSRule S)) :
    {s : S.Srt} → MTerm S s → MTerm S s → Prop where
  /-- Rewrite at the root using a rule and substitution -/
  | atRoot (r : MSRule S) (hr : r ∈ rules) (σ : SortedSubst S) :
      MSStep rules (r.lhs.subst σ) (r.rhs.subst σ)
  /-- Rewrite inside an argument of an operation -/
  | inArg (f : Fin S.numOps)
      (args args' : (i : Fin (S.arity f)) → MTerm S (S.argSorts f i))
      (i : Fin (S.arity f))
      (hstep : MSStep rules (args i) (args' i))
      (hrest : ∀ j, j ≠ i → args' j = args j) :
      MSStep rules (.op f args) (.op f args')

/-- Multi-step multi-sorted rewriting: reflexive-transitive closure. -/
inductive MSSeq {S : MSig} (rules : Set (MSRule S)) :
    {s : S.Srt} → MTerm S s → MTerm S s → Prop where
  /-- Zero steps -/
  | refl {s : S.Srt} (t : MTerm S s) : MSSeq rules t t
  /-- One step followed by more steps -/
  | step {s : S.Srt} {a b c : MTerm S s} :
      MSStep rules a b → MSSeq rules b c → MSSeq rules a c

/-- Transitivity of multi-sorted rewrite sequences. -/
theorem MSSeq.trans {S : MSig} {rules : Set (MSRule S)}
    {s : S.Srt} {a b c : MTerm S s}
    (h1 : MSSeq rules a b) (h2 : MSSeq rules b c) :
    MSSeq rules a c := by
  induction h1 with
  | refl _ => exact h2
  | step hs _ ih => exact .step hs (ih h2)

/-! ## Normal Forms and Convergence -/

/-- A multi-sorted term is a normal form if it cannot be rewritten. -/
def MSIsNF {S : MSig} (rules : Set (MSRule S)) {s : S.Srt} (t : MTerm S s) : Prop :=
  ∀ u, ¬ MSStep rules t u

/-- A term reduces to a normal form. -/
def MSNFOf {S : MSig} (rules : Set (MSRule S)) {s : S.Srt}
    (t u : MTerm S s) : Prop :=
  MSSeq rules t u ∧ MSIsNF rules u

/-- Multi-sorted confluence. -/
def MSConfluent {S : MSig} (rules : Set (MSRule S)) : Prop :=
  ∀ (s : S.Srt) (a t₁ t₂ : MTerm S s),
    MSSeq rules a t₁ → MSSeq rules a t₂ →
    ∃ u, MSSeq rules t₁ u ∧ MSSeq rules t₂ u

/-- Multi-sorted termination. -/
def MSTerminating {S : MSig} (rules : Set (MSRule S)) : Prop :=
  ∀ (s : S.Srt) (t : MTerm S s),
    Acc (fun a b => MSStep rules b a) t

/-- A multi-sorted rewrite system is convergent if confluent and terminating. -/
structure MSConvergent {S : MSig} (rules : Set (MSRule S)) : Prop where
  confluent : MSConfluent rules
  terminating : MSTerminating rules

/-- The rules are derived from a set of equations. -/
def MSDerivedFrom {S : MSig} (rules : Set (MSRule S))
    (E : Set (MSEquation S)) : Prop :=
  ∀ r ∈ rules, (⟨r.ruleSort, r.lhs, r.rhs⟩ : MSEquation S) ∈ E ∨
               (⟨r.ruleSort, r.rhs, r.lhs⟩ : MSEquation S) ∈ E

/-! ## Semantic Equivalence -/

/-- Two terms of the same sort are semantically equivalent under E. -/
def MSSemanticEquiv {S : MSig} (E : Set (MSEquation S))
    {s : S.Srt} (t₁ t₂ : MTerm S s) : Prop :=
  ∀ (A : MAlg S), A.satisfiesAll E →
    ∀ (ρ : SortedEnv S A), t₁.eval A ρ = t₂.eval A ρ

theorem MSSemanticEquiv.refl {S : MSig} {E : Set (MSEquation S)}
    {s : S.Srt} (t : MTerm S s) : MSSemanticEquiv E t t :=
  fun _ _ _ => rfl

theorem MSSemanticEquiv.symm {S : MSig} {E : Set (MSEquation S)}
    {s : S.Srt} {t₁ t₂ : MTerm S s}
    (h : MSSemanticEquiv E t₁ t₂) : MSSemanticEquiv E t₂ t₁ :=
  fun A hA ρ => (h A hA ρ).symm

theorem MSSemanticEquiv.trans' {S : MSig} {E : Set (MSEquation S)}
    {s : S.Srt} {t₁ t₂ t₃ : MTerm S s}
    (h1 : MSSemanticEquiv E t₁ t₂) (h2 : MSSemanticEquiv E t₂ t₃) :
    MSSemanticEquiv E t₁ t₃ :=
  fun A hA ρ => (h1 A hA ρ).trans (h2 A hA ρ)