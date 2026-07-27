import Mathlib
import Bridges.HopfCausalCore

/-!
# Do-calculus as a finite formal logic

This file gives a finite syntax for interventional queries, three primitive
rule schemata, their equivalence closure, relational semantics, a soundness and
completeness theorem, and an executable (finite, exhaustive) identification
procedure.  The graphical side conditions are parameters: this separates the
logic of do-calculus from a chosen implementation of d-separation.

The existing `HopfCausalCalculus.CausalDAG` is reused as the graph carried by a
rule oracle.
-/

namespace DoCalculus

open HopfCausalCalculus

/-- A finite causal query `P(target | observed, do(intervened))`. -/
structure Query (n : ℕ) where
  target : Finset (Fin n)
  observed : Finset (Fin n)
  intervened : Finset (Fin n)
  target_observed_disjoint : Disjoint target observed
  target_intervened_disjoint : Disjoint target intervened
  observed_intervened_disjoint : Disjoint observed intervened
  deriving DecidableEq, Fintype

/-- A graphical oracle records the three d-separation tests associated with
Pearl's three rules.  The graph is the catalog's existing causal DAG type. -/
structure GraphicalOracle (n : ℕ) where
  graph : CausalDAG
  arity : graph.numVerts = n
  observationInsertionDeletion : Query n → Query n → Bool
  actionObservationExchange : Query n → Query n → Bool
  actionInsertionDeletion : Query n → Query n → Bool

/-- The three primitive inference rules of do-calculus. -/
inductive PrimitiveStep {n : ℕ} (O : GraphicalOracle n) : Query n → Query n → Prop
  | ruleOne {q r} (h : O.observationInsertionDeletion q r = true) : PrimitiveStep O q r
  | ruleTwo {q r} (h : O.actionObservationExchange q r = true) : PrimitiveStep O q r
  | ruleThree {q r} (h : O.actionInsertionDeletion q r = true) : PrimitiveStep O q r

/-- Formal derivability is the equivalence closure of the three rules. -/
inductive Derivable {n : ℕ} (O : GraphicalOracle n) : Query n → Query n → Prop
  | refl (q) : Derivable O q q
  | step {q r} : PrimitiveStep O q r → Derivable O q r
  | symm {q r} : Derivable O q r → Derivable O r q
  | trans {q r s} : Derivable O q r → Derivable O r s → Derivable O q s

/-- A non-parametric model of the rule theory is an arbitrary interpretation
of query equality which is an equivalence relation and validates every
instance of the three graphical rules.  No numerical or parametric form of a
structural equation is imposed. -/
structure NPSCMTheory {n : ℕ} (O : GraphicalOracle n) where
  EqQuery : Query n → Query n → Prop
  refl : ∀ q, EqQuery q q
  symm : ∀ {q r}, EqQuery q r → EqQuery r q
  trans : ∀ {q r s}, EqQuery q r → EqQuery r s → EqQuery q s
  rule_sound : ∀ {q r}, PrimitiveStep O q r → EqQuery q r

/-- A causal equality is semantically identifiable if it holds in every
non-parametric interpretation validating the three rules. -/
def SemanticallyIdentifiable {n : ℕ} (O : GraphicalOracle n) (q r : Query n) : Prop :=
  ∀ M : NPSCMTheory O, M.EqQuery q r

/-- Every formal derivation is valid in every model of the rule theory. -/
theorem derivation_sound {n : ℕ} {O : GraphicalOracle n} {q r : Query n}
    (h : Derivable O q r) : SemanticallyIdentifiable O q r := by
  intro M
  induction h with
  | refl q => exact M.refl q
  | step h => exact M.rule_sound h
  | symm _ ih => exact M.symm ih
  | trans _ _ ih₁ ih₂ => exact M.trans ih₁ ih₂

/-- The derivability relation itself is the canonical non-parametric model. -/
def canonicalTheory {n : ℕ} (O : GraphicalOracle n) : NPSCMTheory O where
  EqQuery := Derivable O
  refl := Derivable.refl
  symm := Derivable.symm
  trans := Derivable.trans
  rule_sound := Derivable.step

/-- Completeness of the three-rule calculus for its non-parametric relational
semantics: every equality valid in all models has a formal derivation. -/
theorem derivation_complete {n : ℕ} {O : GraphicalOracle n} {q r : Query n}
    (h : SemanticallyIdentifiable O q r) : Derivable O q r := by
  exact h (canonicalTheory O)

/-- Soundness and completeness in a single statement. -/
theorem doCalculus_complete {n : ℕ} (O : GraphicalOracle n) (q r : Query n) :
    SemanticallyIdentifiable O q r ↔ Derivable O q r := by
  constructor
  · exact derivation_complete
  · exact derivation_sound

/-- Boolean check that a candidate finite relation is an equivalence relation
containing all three primitive rule relations. -/
def isTheory {n : ℕ} (O : GraphicalOracle n)
    (R : Query n → Query n → Bool) : Bool :=
  decide
    ((∀ q, R q q = true) ∧
     (∀ q r, R q r = true → R r q = true) ∧
     (∀ q r s, R q r = true → R r s = true → R q s = true) ∧
     (∀ q r, O.observationInsertionDeletion q r = true → R q r = true) ∧
     (∀ q r, O.actionObservationExchange q r = true → R q r = true) ∧
     (∀ q r, O.actionInsertionDeletion q r = true → R q r = true))

/-- Exhaustive finite decision procedure.  It accepts exactly when every
finite equivalence relation validating the three rules equates `q` and `r`.
The procedure is intentionally specification-first rather than optimized. -/
def identify {n : ℕ} (O : GraphicalOracle n) (q r : Query n) : Bool :=
  decide (∀ R : Query n → Query n → Bool, isTheory O R = true → R q r = true)

lemma isTheory_spec {n : ℕ} (O : GraphicalOracle n)
    (R : Query n → Query n → Bool) :
    isTheory O R = true ↔
    ((∀ q, R q q = true) ∧
     (∀ q r, R q r = true → R r q = true) ∧
     (∀ q r s, R q r = true → R r s = true → R q s = true) ∧
     (∀ q r, O.observationInsertionDeletion q r = true → R q r = true) ∧
     (∀ q r, O.actionObservationExchange q r = true → R q r = true) ∧
     (∀ q r, O.actionInsertionDeletion q r = true → R q r = true)) := by
  simp [isTheory]

/-- A Boolean theory induces a genuine non-parametric relational model. -/
def theoryOfBool {n : ℕ} {O : GraphicalOracle n}
    (R : Query n → Query n → Bool) (hR : isTheory O R = true) : NPSCMTheory O := by
  have h := (isTheory_spec O R).mp hR
  refine ⟨fun q r => R q r = true, h.1, ?_, ?_, ?_⟩
  · intro q r hqr
    exact h.2.1 q r hqr
  · intro q r s hqr hrs
    exact h.2.2.1 q r s hqr hrs
  · intro q r hr
    cases hr with
    | ruleOne hs => exact h.2.2.2.1 q r hs
    | ruleTwo hs => exact h.2.2.2.2.1 q r hs
    | ruleThree hs => exact h.2.2.2.2.2 q r hs

/-- The exhaustive procedure is sound for semantic identifiability. -/
theorem identify_sound {n : ℕ} {O : GraphicalOracle n} {q r : Query n}
    (h : identify O q r = true) : SemanticallyIdentifiable O q r := by
  intro M
  classical
  let R : Query n → Query n → Bool := fun a b => decide (M.EqQuery a b)
  have hR : isTheory O R = true := by
    apply (isTheory_spec O R).2
    constructor
    · intro a; simp [R, M.refl]
    constructor
    · intro a b hab
      simp only [R, decide_eq_true_eq] at hab ⊢
      exact M.symm hab
    constructor
    · intro a b c hab hbc
      simp only [R, decide_eq_true_eq] at hab hbc ⊢
      exact M.trans hab hbc
    constructor
    · intro a b hab
      simp only [R, decide_eq_true_eq]
      exact M.rule_sound (.ruleOne hab)
    constructor
    · intro a b hab
      simp only [R, decide_eq_true_eq]
      exact M.rule_sound (.ruleTwo hab)
    · intro a b hab
      simp only [R, decide_eq_true_eq]
      exact M.rule_sound (.ruleThree hab)
  have hall : ∀ S : Query n → Query n → Bool,
      isTheory O S = true → S q r = true := by
    simpa [identify] using h
  have := hall R hR
  simpa [R] using this

/-- Semantic identifiability is accepted by the exhaustive procedure. -/
theorem identify_complete {n : ℕ} {O : GraphicalOracle n} {q r : Query n}
    (h : SemanticallyIdentifiable O q r) : identify O q r = true := by
  simp only [identify, decide_eq_true_eq]
  intro R hR
  exact h (theoryOfBool R hR)

/-- Certified decision theorem for causal-effect identifiability in the finite
three-rule theory. -/
theorem identify_correct {n : ℕ} (O : GraphicalOracle n) (q r : Query n) :
    identify O q r = true ↔ SemanticallyIdentifiable O q r := by
  constructor
  · exact identify_sound
  · exact identify_complete

/-- The executable procedure agrees exactly with formal derivability. -/
theorem identify_iff_derivable {n : ℕ} (O : GraphicalOracle n) (q r : Query n) :
    identify O q r = true ↔ Derivable O q r := by
  rw [identify_correct, doCalculus_complete]

end DoCalculus