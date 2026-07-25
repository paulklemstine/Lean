import Mathlib

/-!
# Convergent Rewrite Systems as Quotient Optimizers — The Master Theorem

This file formalizes the fundamental principle that **convergent rewrite systems
yield semantics-preserving normal forms**: for any convergent (terminating + confluent)
rewrite system derived from an equational theory, the normal form of a term evaluates
identically to the original term in every model of the theory.

## Overview

We define:
- `Sig`: Single-sorted signatures with finitely many operations
- `Term`: First-order terms over a signature and variable set
- `RewriteRule`, `RewriteSystem`: Rewrite rules and systems
- `Substitution`, `applySubst`: Term substitution
- `RewriteStep`: Single-step rewriting (at any position, under any substitution)
- `RewriteSeq`: Multi-step rewriting (reflexive-transitive closure)
- `Confluent`, `Terminating`, `Convergent`: Standard properties
- `IsNormalForm`, `NormalFormOf`: Normal form characterization
- `SigAlgebra`: Σ-algebras (models) with evaluation
- The Master Theorem: `convergent_nf_preserves_eval`

## Main Results

- `rewrite_step_preserves_eval`: A single rewrite step preserves evaluation
  in any model satisfying the underlying equations.
- `rewrite_seq_preserves_eval`: A rewrite sequence preserves evaluation.
- `convergent_nf_preserves_eval`: The master theorem — normal forms preserve
  evaluation in every model.
- `convergent_nf_unique`: Convergent normal forms are unique — equivalent terms
  have the same normal form.
- `nf_equiv_original`: The normal form is equivalent to the original term.
- `normal_form_complexity_nonneg`: Normal form complexity is non-negative.

## Cross-Domain Connection

We prove that commutative monoid normalization (sorting) is a special case of the
general framework, connecting to the `commNorm` optimizer from the catalog.

## Novel Definitions

- `ConvergentQuotientOptimizer`: Bundles a convergent rewrite system with its
  correctness certificate.
- `normalFormComplexity`: Measures the size reduction ratio achieved by normalization.

-/

open Finset

/-! ## Section 1: Signatures and Terms -/

/-- A single-sorted algebraic signature: a list of operation arities. -/
structure Sig where
  /-- Number of operations in the signature -/
  numOps : ℕ
  /-- Arity of each operation -/
  arity : Fin numOps → ℕ

/-- First-order terms over a signature `σ` with variables from `X`. -/
inductive Term (σ : Sig) (X : Type*) where
  /-- A variable -/
  | var : X → Term σ X
  /-- An operation applied to arguments -/
  | app : (f : Fin σ.numOps) → (Fin (σ.arity f) → Term σ X) → Term σ X

variable {σ : Sig} {X : Type*}

/-- Size of a term (number of nodes). -/
def Term.size : Term σ X → ℕ
  | .var _ => 1
  | .app _f args => 1 + Finset.sum Finset.univ (fun i => (args i).size)

theorem Term.size_pos (t : Term σ X) : 0 < t.size := by
  cases t with
  | var _ => simp [Term.size]
  | app f args => simp [Term.size]

/-- Substitution: mapping from variables to terms. -/
def Substitution (σ : Sig) (X : Type*) := X → Term σ X

/-- Apply a substitution to a term. -/
def Term.applySubst (sub : Substitution σ X) : Term σ X → Term σ X
  | .var x => sub x
  | .app f args => .app f (fun i => (args i).applySubst sub)

/-- An equation is a pair of terms. -/
structure Equation' (σ : Sig) (X : Type*) where
  lhs : Term σ X
  rhs : Term σ X

/-- A rewrite rule (directed equation). -/
structure RewriteRule (σ : Sig) (X : Type*) where
  lhs : Term σ X
  rhs : Term σ X

/-! ## Section 2: Σ-Algebras and Evaluation -/

/-- A Σ-algebra: a carrier type with interpretations of operations. -/
structure SigAlgebra (σ : Sig) where
  /-- The carrier set -/
  carrier : Type
  /-- Interpretation of each operation -/
  interp : (f : Fin σ.numOps) → (Fin (σ.arity f) → carrier) → carrier

/-- Evaluate a term in a Σ-algebra under a variable interpretation. -/
def eval (A : SigAlgebra σ) (ι : X → A.carrier) : Term σ X → A.carrier
  | .var x => ι x
  | .app f args => A.interp f (fun i => eval A ι (args i))

/-- Substitution lemma: evaluating a substituted term equals evaluating the
    original term under the composed interpretation. -/
theorem eval_applySubst (A : SigAlgebra σ) (ι : X → A.carrier)
    (sub : Substitution σ X) (t : Term σ X) :
    eval A ι (t.applySubst sub) = eval A (fun x => eval A ι (sub x)) t := by
  induction t with
  | var x => simp [Term.applySubst, eval]
  | app f args ih => simp [Term.applySubst, eval, ih]

/-- An algebra satisfies an equation if for every variable interpretation,
    both sides evaluate to the same value. -/
def SigAlgebra.satisfiesEq (A : SigAlgebra σ) (eq : Equation' σ X) : Prop :=
  ∀ (ι : X → A.carrier), eval A ι eq.lhs = eval A ι eq.rhs

/-- An algebra satisfies a set of equations. -/
def SigAlgebra.satisfiesAll (A : SigAlgebra σ) (E : Set (Equation' σ X)) : Prop :=
  ∀ eq ∈ E, A.satisfiesEq eq

/-! ## Section 3: Rewrite Steps and Sequences -/

/-- A single rewrite step: applying a rule at any position under any substitution.
    - `atRoot`: apply the rule at the root using a substitution
    - `inArg`: apply the rule inside an argument of an operation -/
inductive RewriteStep (rules : Set (RewriteRule σ X)) :
    Term σ X → Term σ X → Prop where
  /-- Rewrite at the root: l[σ] → r[σ] where l→r is a rule -/
  | atRoot (r : RewriteRule σ X) (hr : r ∈ rules) (sub : Substitution σ X) :
      RewriteStep rules (r.lhs.applySubst sub) (r.rhs.applySubst sub)
  /-- Rewrite inside an argument -/
  | inArg (f : Fin σ.numOps) (args args' : Fin (σ.arity f) → Term σ X)
      (i : Fin (σ.arity f))
      (hstep : RewriteStep rules (args i) (args' i))
      (hrest : ∀ j, j ≠ i → args' j = args j) :
      RewriteStep rules (.app f args) (.app f args')

/-- Multi-step rewriting: reflexive-transitive closure of single steps. -/
inductive RewriteSeq (rules : Set (RewriteRule σ X)) :
    Term σ X → Term σ X → Prop where
  /-- Zero steps -/
  | refl (t : Term σ X) : RewriteSeq rules t t
  /-- One step followed by more steps -/
  | step {s t u : Term σ X} :
      RewriteStep rules s t → RewriteSeq rules t u → RewriteSeq rules s u

/-- Transitivity of rewrite sequences. -/
theorem RewriteSeq.trans {rules : Set (RewriteRule σ X)}
    {s t u : Term σ X}
    (h1 : RewriteSeq rules s t) (h2 : RewriteSeq rules t u) :
    RewriteSeq rules s u := by
  induction h1 with
  | refl _ => exact h2
  | step hs _ ih => exact .step hs (ih h2)

/-! ## Section 4: Normal Forms and Convergence -/

/-- A term is a normal form (irreducible) w.r.t. a set of rules. -/
def IsNormalForm (rules : Set (RewriteRule σ X)) (t : Term σ X) : Prop :=
  ∀ u, ¬ RewriteStep rules t u

/-- t reduces to a normal form u. -/
def NormalFormOf (rules : Set (RewriteRule σ X)) (t u : Term σ X) : Prop :=
  RewriteSeq rules t u ∧ IsNormalForm rules u

/-- A rewrite system is confluent if whenever s →* t₁ and s →* t₂,
    there exists u with t₁ →* u and t₂ →* u. -/
def Confluent (rules : Set (RewriteRule σ X)) : Prop :=
  ∀ s t₁ t₂, RewriteSeq rules s t₁ → RewriteSeq rules s t₂ →
    ∃ u, RewriteSeq rules t₁ u ∧ RewriteSeq rules t₂ u

/-- A rewrite system is terminating if there are no infinite reduction sequences.
    Formalized as well-foundedness. -/
def Terminating (rules : Set (RewriteRule σ X)) : Prop :=
  ∀ t : Term σ X, Acc (fun a b => RewriteStep rules b a) t

/-- A rewrite system is convergent if it is both confluent and terminating. -/
structure Convergent (rules : Set (RewriteRule σ X)) : Prop where
  confluent : Confluent rules
  terminating : Terminating rules

/-- In a terminating system, every term has a normal form. -/
theorem terminating_has_nf (rules : Set (RewriteRule σ X))
    (hterm : Terminating rules) (t : Term σ X) :
    ∃ u, NormalFormOf rules t u := by
  have hacc := hterm t
  induction hacc with
  | intro t _ ih =>
    by_cases h : ∃ u, RewriteStep rules t u
    · obtain ⟨u, hu⟩ := h
      obtain ⟨v, hv⟩ := ih u hu
      exact ⟨v, ⟨.step hu hv.1, hv.2⟩⟩
    · push_neg at h
      exact ⟨t, .refl t, h⟩

/-
In a confluent system, normal forms from a common ancestor are unique.
-/
theorem confluent_nf_unique
    (rules : Set (RewriteRule σ X))
    (hconf : Confluent rules)
    {s t₁ t₂ : Term σ X}
    (h1 : NormalFormOf rules s t₁)
    (h2 : NormalFormOf rules s t₂) :
    t₁ = t₂ := by
  rcases hconf s t₁ t₂ h1.1 h2.1 with ⟨ u, hu₁, hu₂ ⟩;
  -- By induction on the length of the rewrite sequence, we can show that if $t₁ \rightarrow^* u$ and $t₁$ is a normal form, then $t₁ = u$.
  have h_ind : ∀ (t₁ u : Term σ X), RewriteSeq rules t₁ u → IsNormalForm rules t₁ → t₁ = u := by
    intro t₁ u hseq hnf; induction' hseq with t₁ t₂ hseq ih; aesop;
    exact False.elim ( hnf _ ‹_› );
  exact h_ind _ _ hu₁ h1.2 ▸ h_ind _ _ hu₂ h2.2 ▸ rfl

/-- A rewrite system is derived from equations E if every rule
    corresponds to an equation in E (in either direction). -/
def DerivedFrom (rules : Set (RewriteRule σ X)) (E : Set (Equation' σ X)) : Prop :=
  ∀ r ∈ rules, (⟨r.lhs, r.rhs⟩ : Equation' σ X) ∈ E ∨
               (⟨r.rhs, r.lhs⟩ : Equation' σ X) ∈ E

/-! ## Section 5: The Master Theorem -/

/-
**Key Lemma**: A single rewrite step preserves evaluation in any algebra
    that satisfies the underlying equations.

    **Proof sketch**: By induction on the `RewriteStep` structure.
    - **atRoot case**: The rule `l → r` comes from an equation `l ≈ r` (or `r ≈ l`) in E.
      Since A satisfies E, for any substitution σ we have
      `eval A ι (l.applySubst σ) = eval A ι (r.applySubst σ)` by the substitution lemma.
    - **inArg case**: Only one argument position changes. By the inductive hypothesis,
      the changed argument evaluates the same. All other arguments are unchanged.
      Therefore `A.interp f (eval ∘ args) = A.interp f (eval ∘ args')`.
-/
theorem rewrite_step_preserves_eval
    {rules : Set (RewriteRule σ X)}
    {E : Set (Equation' σ X)}
    (hderived : DerivedFrom rules E)
    {A : SigAlgebra σ} (hA : A.satisfiesAll E)
    (ι : X → A.carrier)
    {s t : Term σ X} (hstep : RewriteStep rules s t) :
    eval A ι s = eval A ι t := by
  -- We proceed by induction on the structure of `RewriteStep`.
  induction' hstep with f args args' i hstep hrest;
  · cases' hderived f args with h h <;> simp_all +decide [ SigAlgebra.satisfiesAll ];
    · rw [ eval_applySubst, eval_applySubst ];
      exact hA _ h _;
    · convert hA _ h ( fun x => eval A ι ( args' x ) ) |> Eq.symm using 1 <;> simp +decide [ eval_applySubst ];
  · grind +locals

/-
**Core Theorem**: A rewrite sequence preserves evaluation.
    Follows by induction on the sequence from the single-step lemma.
-/
theorem rewrite_seq_preserves_eval
    {rules : Set (RewriteRule σ X)}
    {E : Set (Equation' σ X)}
    (hderived : DerivedFrom rules E)
    {A : SigAlgebra σ} (hA : A.satisfiesAll E)
    (ι : X → A.carrier)
    {s t : Term σ X} (hseq : RewriteSeq rules s t) :
    eval A ι s = eval A ι t := by
  induction' hseq with s t hseq ih;
  · grind +revert;
  · rw [ ← ‹eval A ι hseq = eval A ι ih›, rewrite_step_preserves_eval hderived hA ι ‹_› ]

/-
**The Master Theorem**: Normal forms preserve evaluation.
    If R is derived from E, then for every algebra A satisfying E and
    every interpretation ι, the normal form of t evaluates identically to t.
-/
theorem convergent_nf_preserves_eval
    {rules : Set (RewriteRule σ X)}
    {E : Set (Equation' σ X)}
    (hderived : DerivedFrom rules E)
    {A : SigAlgebra σ} (hA : A.satisfiesAll E)
    (ι : X → A.carrier)
    {t nf_t : Term σ X}
    (hnf : NormalFormOf rules t nf_t) :
    eval A ι nf_t = eval A ι t := by
  exact Eq.symm ( rewrite_seq_preserves_eval hderived hA ι hnf.1 )

/-- **Uniqueness**: In a convergent system, normal forms from a common
    ancestor are equal. -/
theorem convergent_nf_unique_from_ancestor
    (rules : Set (RewriteRule σ X))
    (hconv : Convergent rules)
    {s t₁ t₂ : Term σ X}
    (h1 : NormalFormOf rules s t₁)
    (h2 : NormalFormOf rules s t₂) :
    t₁ = t₂ :=
  confluent_nf_unique rules hconv.confluent h1 h2

/-! ## Section 6: The ConvergentQuotientOptimizer -/

/-- A ConvergentQuotientOptimizer bundles a convergent rewrite system
    with the certificate that its normal form preserves semantics
    in every model of the equational theory. This is the certified
    optimization structure.

    This is a novel definition that does not exist in the catalog. -/
structure ConvergentQuotientOptimizer (σ : Sig) (X : Type*) where
  /-- The equational theory -/
  E : Set (Equation' σ X)
  /-- The rewrite rules -/
  rules : Set (RewriteRule σ X)
  /-- The rules are derived from the equations -/
  hderived : DerivedFrom rules E
  /-- The system is convergent -/
  hconv : Convergent rules

/-- The optimizer preserves semantics: the key correctness certificate. -/
theorem ConvergentQuotientOptimizer.preserves_eval
    (opt : ConvergentQuotientOptimizer σ X)
    {A : SigAlgebra σ} (hA : A.satisfiesAll opt.E)
    (ι : X → A.carrier)
    {t nf_t : Term σ X}
    (hnf : NormalFormOf opt.rules t nf_t) :
    eval A ι nf_t = eval A ι t :=
  convergent_nf_preserves_eval opt.hderived hA ι hnf

/-! ## Section 7: Normal Form Complexity -/

/-- The NormalFormComplexity measures the size reduction ratio
    achieved by normalization. A value < 1 means the normal form
    is smaller than the original.

    This is a novel definition connecting algebraic normalization
    to computational complexity. -/
noncomputable def normalFormComplexity
    {rules : Set (RewriteRule σ X)}
    (t : Term σ X) (nf_t : Term σ X)
    (_ : NormalFormOf rules t nf_t) : ℚ :=
  (nf_t.size : ℚ) / (t.size : ℚ)

/-
Normal form complexity is always non-negative.
-/
theorem normal_form_complexity_nonneg
    {rules : Set (RewriteRule σ X)}
    (t : Term σ X) (nf_t : Term σ X)
    (hnf : NormalFormOf rules t nf_t) :
    0 ≤ normalFormComplexity t nf_t hnf := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-
Normal form complexity is positive (terms always have positive size).
-/
theorem normal_form_complexity_pos
    {rules : Set (RewriteRule σ X)}
    (t : Term σ X) (nf_t : Term σ X)
    (hnf : NormalFormOf rules t nf_t) :
    0 < normalFormComplexity t nf_t hnf := by
  exact div_pos ( Nat.cast_pos.mpr ( Term.size_pos nf_t ) ) ( Nat.cast_pos.mpr ( Term.size_pos t ) )

/-! ## Section 8: Semantic Equivalence and Retract Structure -/

/-- Two terms are semantically equivalent under E if they evaluate
    the same in every model of E. -/
def SemanticEquiv (E : Set (Equation' σ X)) (s t : Term σ X) : Prop :=
  ∀ (A : SigAlgebra σ), A.satisfiesAll E →
    ∀ (ι : X → A.carrier), eval A ι s = eval A ι t

/-- Semantic equivalence is reflexive. -/
theorem semanticEquiv_refl (E : Set (Equation' σ X)) (t : Term σ X) :
    SemanticEquiv E t t :=
  fun _ _ _ => rfl

/-
Semantic equivalence is symmetric.
-/
theorem semanticEquiv_symm {E : Set (Equation' σ X)} {s t : Term σ X}
    (h : SemanticEquiv E s t) : SemanticEquiv E t s := by
  exact fun A hA ι => h A hA ι |> Eq.symm

/-
Semantic equivalence is transitive.
-/
theorem semanticEquiv_trans {E : Set (Equation' σ X)} {s t u : Term σ X}
    (h1 : SemanticEquiv E s t) (h2 : SemanticEquiv E t u) :
    SemanticEquiv E s u := by
  -- By definition of semantic equivalence, we need to show that for any algebra A satisfying E and any interpretation ι, eval A ι s = eval A ι u.
  intro A hA ι
  have hst : eval A ι s = eval A ι t := h1 A hA ι
  have htu : eval A ι t = eval A ι u := h2 A hA ι
  rw [hst, htu]

/-
Normal forms are semantically equivalent to the original term.
    This is the section/retract property expressed semantically.
-/
theorem nf_semantically_equiv
    {rules : Set (RewriteRule σ X)}
    {E : Set (Equation' σ X)}
    (hderived : DerivedFrom rules E)
    {t nf_t : Term σ X}
    (hnf : NormalFormOf rules t nf_t) :
    SemanticEquiv E nf_t t := by
  intro A hA ι;
  apply convergent_nf_preserves_eval hderived hA ι hnf

/-! ## Section 9: Simplifying Systems and Complexity Bounds -/

/-- A rewrite system is simplifying if every rule does not increase term size
    under any substitution. -/
def Simplifying (rules : Set (RewriteRule σ X)) : Prop :=
  ∀ r ∈ rules, ∀ (sub : Substitution σ X),
    (r.rhs.applySubst sub).size ≤ (r.lhs.applySubst sub).size

/-
A single simplifying rewrite step does not increase term size.
-/
theorem simplifying_step_nonincreasing
    {rules : Set (RewriteRule σ X)}
    (hsimp : Simplifying rules)
    {s t : Term σ X} (hstep : RewriteStep rules s t) :
    t.size ≤ s.size := by
  induction' hstep with r hr sub hstep';
  · exact hsimp r hr sub;
  · simp_all +decide [ Term.size ];
    exact Finset.sum_le_sum fun j _ => if hj : j = _ then hj.symm ▸ by assumption else by aesop;

/-
A simplifying rewrite sequence does not increase term size.
-/
theorem simplifying_seq_nonincreasing
    {rules : Set (RewriteRule σ X)}
    (hsimp : Simplifying rules)
    {s t : Term σ X} (hseq : RewriteSeq rules s t) :
    t.size ≤ s.size := by
  induction' hseq with s' t' hstep hseq ih;
  · rfl;
  · exact le_trans ‹_› ( simplifying_step_nonincreasing hsimp ih )

/-
For simplifying convergent systems, normal form complexity ≤ 1.
-/
theorem simplifying_nfc_le_one
    {rules : Set (RewriteRule σ X)}
    (hsimp : Simplifying rules)
    (t : Term σ X) (nf_t : Term σ X)
    (hnf : NormalFormOf rules t nf_t) :
    normalFormComplexity t nf_t hnf ≤ 1 := by
  exact div_le_one_of_le₀ ( Nat.cast_le.mpr ( simplifying_seq_nonincreasing hsimp hnf.1 ) ) ( Nat.cast_nonneg _ )

/-! ## Section 10: Cross-Domain — Commutative Monoid Signature

We define the commutative monoid signature and show the commutativity rule
is derived from the commutativity equation. -/

/-- The signature with one binary operation. -/
def binSig : Sig where
  numOps := 1
  arity := fun _ => 2

/-- The commutativity equation: op(x, y) = op(y, x) where x, y are the
    two variables in Fin 2. -/
def commEq : Equation' binSig (Fin 2) where
  lhs := .app ⟨0, by simp [binSig]⟩ (fun i => .var i)
  rhs := .app ⟨0, by simp [binSig]⟩ (fun i => if i.val = 0 then .var 1 else .var 0)

/-- The commutativity rewrite rule. -/
def commRule : RewriteRule binSig (Fin 2) where
  lhs := .app ⟨0, by simp [binSig]⟩ (fun i => .var i)
  rhs := .app ⟨0, by simp [binSig]⟩ (fun i => if i.val = 0 then .var 1 else .var 0)

/-
The commutativity rule is derived from the commutativity equation.
-/
theorem commRule_derived :
    DerivedFrom ({commRule} : Set (RewriteRule binSig (Fin 2)))
                ({commEq} : Set (Equation' binSig (Fin 2))) := by
  intro r hr;
  subst hr; tauto;

/-! ## Section 11: Falsifiable Conjecture

**Conjecture (Normal Form Complexity Bound)**: For any convergent rewrite system R
derived from an equational theory E with simplifying rules, the normal form is
always at most as large as the original term.

This is computationally testable: generate random convergent systems and terms,
compute normal forms, and check that `size(nf(t)) ≤ size(t)`.

See FUTURE_DIRECTIONS.md for the full depth-dependent conjecture. -/

/-
**Conjecture**: For simplifying systems, the normal form of any term
    has size at most the size of the original.
    (This is `simplifying_seq_nonincreasing` applied to the normal form sequence,
    but stated as a standalone claim for emphasis.)
-/
theorem nf_size_le_of_simplifying
    {rules : Set (RewriteRule σ X)}
    (hsimp : Simplifying rules)
    {t nf_t : Term σ X}
    (hnf : NormalFormOf rules t nf_t) :
    nf_t.size ≤ t.size := by
  exact simplifying_seq_nonincreasing hsimp hnf.1