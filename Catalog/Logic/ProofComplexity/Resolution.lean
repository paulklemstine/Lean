import Mathlib

/-!
# Proof Complexity I: The Resolution Proof System

This file formalizes the **resolution** refutation system for propositional CNF
formulas and proves its **soundness**: every resolution refutation of a CNF
certifies that the CNF is unsatisfiable.

Resolution is the proof system underlying virtually all modern CDCL SAT solvers:
a SAT solver that reports "UNSAT" is, in effect, producing (a trace equivalent to)
a resolution refutation.  Soundness is the theorem that makes such a certificate
trustworthy.

## Main definitions

* `ProofComplexity.Lit`        : a literal (a variable with a polarity).
* `ProofComplexity.Clause`     : a clause, i.e. a disjunction of literals.
* `ProofComplexity.CNF`        : a CNF formula, i.e. a conjunction of clauses.
* `ProofComplexity.resolvent`  : the resolvent of two clauses on a pivot variable.
* `ProofComplexity.Derivable`  : the set of clauses derivable from a CNF.
* `ProofComplexity.Refutation` : a derivation of the empty clause.

## Main results

* `resolvent_sound`   : the resolvent of two satisfied clauses is satisfied
                        (the semantic heart of the system).
* `derivable_sound`   : every derivable clause is implied by the CNF.
* `refutation_sound`  : a CNF admitting a resolution refutation is unsatisfiable.
* `unit_refutation`   : the canonical refutation of `{x} ∧ {¬x}`, witnessing that
                        the system is non-vacuous.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A faithful, list-based resolution calculus can be
given a one-line semantic soundness proof per inference rule, with the empty
clause acting as the bottom (always-false) clause.

Experiment (Experimenter): Encoded literals as `(variable, polarity)` pairs,
clauses as `List Lit`, and the resolvent as the concatenation of the two parents
with the complementary pivot literals filtered out.  The crucial observation
discovered during experimentation is that the resolvent soundness lemma does
**not** require the pivot to actually occur in the parents — a clean
strengthening that removes side conditions.

Analysis (Analyst): Soundness reduces to a two-way case split on the truth value
of the pivot variable; the parent that is "blocked" on the pivot literal must be
satisfied by some *other* literal, which survives the filter.  This is exactly the
informal textbook argument, now machine-checked.

Critique (Critic): Soundness alone could be vacuous if `Derivable` were empty, so
`unit_refutation` exhibits a concrete non-trivial refutation.  Completeness (the
converse) and quantitative *lower* bounds (Haken's theorem) are genuinely harder
and are recorded in `FUTURE_DIRECTIONS.md` rather than asserted here.

Synthesis (PI): Resolution = (literals, clauses, resolvent, derivability) with a
fully verified soundness pipeline `resolvent_sound ⟹ derivable_sound ⟹
refutation_sound`, reused downstream for the pigeonhole principle.
-/

namespace ProofComplexity

/-- A literal: a propositional variable `v` together with a polarity `pos`.
`pos = true` denotes the positive literal `v`, `pos = false` the negation `¬v`. -/
structure Lit (V : Type*) where
  v : V
  pos : Bool
deriving DecidableEq

variable {V : Type*}

/-- A literal is satisfied by an assignment `a` when `a` matches its polarity. -/
def Lit.eval (a : V → Bool) (l : Lit V) : Bool := a l.v == l.pos

/-- A clause is a disjunction of literals, represented as a list. -/
abbrev Clause (V : Type*) := List (Lit V)

/-- A CNF formula is a conjunction of clauses, represented as a list. -/
abbrev CNF (V : Type*) := List (Clause V)

/-- A clause is satisfied by `a` when at least one of its literals is. -/
def Clause.sat (a : V → Bool) (C : Clause V) : Prop := ∃ l ∈ C, l.eval a = true

/-- A CNF is satisfied by `a` when every clause is. -/
def CNF.sat (a : V → Bool) (F : CNF V) : Prop := ∀ C ∈ F, Clause.sat a C

/-- A CNF is satisfiable when some assignment satisfies it. -/
def CNF.Satisfiable (F : CNF V) : Prop := ∃ a, F.sat a

/-- The empty clause is satisfied by no assignment (it is the `⊥` of the system). -/
theorem not_sat_nil (a : V → Bool) : ¬ Clause.sat a ([] : Clause V) := by
  rintro ⟨l, hl, _⟩
  exact List.not_mem_nil hl

variable [DecidableEq V]

/-- The **resolvent** of `C1` and `C2` on pivot variable `p`: take `C1` with the
positive pivot literal removed, and `C2` with the negative pivot literal removed,
and disjoin them. -/
def resolvent (C1 C2 : Clause V) (p : V) : Clause V :=
  C1.filter (· ≠ ⟨p, true⟩) ++ C2.filter (· ≠ ⟨p, false⟩)

/-- **Soundness of the resolution rule.** If an assignment satisfies both parents,
then it satisfies their resolvent. -/
theorem resolvent_sound (a : V → Bool) (C1 C2 : Clause V) (p : V)
    (h1 : Clause.sat a C1) (h2 : Clause.sat a C2) :
    Clause.sat a (resolvent C1 C2 p) := by
  unfold resolvent Clause.sat
  by_cases hp : a p = true
  · obtain ⟨l, hlC2, hl⟩ := h2
    refine ⟨l, ?_, hl⟩
    rw [List.mem_append]; right; rw [List.mem_filter]
    refine ⟨hlC2, ?_⟩
    simp only [ne_eq, decide_not, Bool.not_eq_eq_eq_not, Bool.not_true,
      decide_eq_false_iff_not]
    rintro rfl
    simp [Lit.eval, hp] at hl
  · simp only [Bool.not_eq_true] at hp
    obtain ⟨l, hlC1, hl⟩ := h1
    refine ⟨l, ?_, hl⟩
    rw [List.mem_append]; left; rw [List.mem_filter]
    refine ⟨hlC1, ?_⟩
    simp only [ne_eq, decide_not, Bool.not_eq_eq_eq_not, Bool.not_true,
      decide_eq_false_iff_not]
    rintro rfl
    simp [Lit.eval, hp] at hl

/-- `Derivable F C` holds when clause `C` can be derived from the clauses of `F`
by repeated resolution. -/
inductive Derivable (F : CNF V) : Clause V → Prop
  | base {C : Clause V} : C ∈ F → Derivable F C
  | res {C1 C2 : Clause V} (p : V) :
      Derivable F C1 → Derivable F C2 → Derivable F (resolvent C1 C2 p)

/-- **Soundness of derivation.** Every clause derivable from `F` is a semantic
consequence of `F`. -/
theorem derivable_sound {F : CNF V} {C : Clause V} (h : Derivable F C) :
    ∀ a, F.sat a → Clause.sat a C := by
  intro a ha
  induction h with
  | base hC => exact ha _ hC
  | res p _ _ ih1 ih2 => exact resolvent_sound a _ _ p ih1 ih2

/-- A **resolution refutation** of `F` is a derivation of the empty clause. -/
def Refutation (F : CNF V) : Prop := Derivable F []

/-- **Soundness of resolution refutations.** If `F` has a resolution refutation,
then `F` is unsatisfiable. -/
theorem refutation_sound {F : CNF V} (h : Refutation F) : ¬ F.Satisfiable := by
  rintro ⟨a, ha⟩
  exact not_sat_nil a (derivable_sound h a ha)

/-- The canonical contradiction `{x} ∧ {¬x}` has a one-step resolution refutation,
witnessing that the calculus actually derives the empty clause. -/
theorem unit_refutation (x : V) :
    Refutation ([[⟨x, true⟩], [⟨x, false⟩]] : CNF V) := by
  have h : resolvent ([⟨x, true⟩] : Clause V) [⟨x, false⟩] x = [] := by
    simp [resolvent]
  have d : Derivable ([[⟨x, true⟩], [⟨x, false⟩]] : CNF V)
      (resolvent [⟨x, true⟩] [⟨x, false⟩] x) :=
    Derivable.res x
      (Derivable.base (C := [⟨x, true⟩]) (by simp))
      (Derivable.base (C := [⟨x, false⟩]) (by simp))
  rwa [h] at d

/-- Consistency check: the canonical contradiction is genuinely unsatisfiable. -/
theorem unit_unsat (x : V) :
    ¬ CNF.Satisfiable ([[⟨x, true⟩], [⟨x, false⟩]] : CNF V) :=
  refutation_sound (unit_refutation x)

end ProofComplexity