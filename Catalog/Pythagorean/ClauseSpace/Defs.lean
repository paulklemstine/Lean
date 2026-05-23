/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Clause-Space Certificates for Propositional Refutations

This file defines the core mathematical objects for a theory of
**clause-space certificates**: finite witnesses that a CNF formula is
unsatisfiable within a prescribed memory budget.

## Main definitions

* `ClauseSpace.Clause` — a propositional clause (disjunction of literals)
* `ClauseSpace.CNF` — a CNF formula (conjunction of clauses)
* `ClauseSpace.SpaceStep` — one-step transition in bounded-space proof search
* `ClauseSpace.SpaceCertificate` — a finite trace witnessing unsatisfiability
* `ClauseSpace.clauseSpaceRefutable` — existence of a bounded-space refutation
-/
import Mathlib

namespace ClauseSpace

/-! ## Clauses and CNF formulas -/

/-- A propositional clause: a disjunction of positive and negative literals.
    We represent a clause as two `Finset`s of variables: those appearing positively
    and those appearing negatively. We do NOT require disjointness; a clause with
    a variable in both `pos` and `neg` is tautological (always satisfied). -/
@[ext]
structure Clause (Var : Type) [DecidableEq Var] where
  pos : Finset Var
  neg : Finset Var

variable {Var : Type} [DecidableEq Var]

instance : DecidableEq (Clause Var) := fun c1 c2 => by
  rcases c1 with ⟨p1, n1⟩; rcases c2 with ⟨p2, n2⟩
  simp only [Clause.mk.injEq]; exact instDecidableAnd

/-- The empty clause, containing no literals. It is never satisfied. -/
def Clause.empty : Clause Var := ⟨∅, ∅⟩

/-- A clause is satisfied by an assignment `σ` if some positive literal
    evaluates to `true` or some negative literal evaluates to `false`. -/
def Clause.satisfiedBy (c : Clause Var) (σ : Var → Bool) : Prop :=
  (∃ v ∈ c.pos, σ v = true) ∨ (∃ v ∈ c.neg, σ v = false)

/-- Decidability of clause satisfaction. -/
instance Clause.decidableSatisfiedBy [Fintype Var] (c : Clause Var) (σ : Var → Bool) :
    Decidable (c.satisfiedBy σ) :=
  inferInstanceAs (Decidable ((∃ v ∈ c.pos, σ v = true) ∨ (∃ v ∈ c.neg, σ v = false)))

/-- The empty clause is never satisfied by any assignment. -/
theorem Clause.empty_not_satisfiedBy (σ : Var → Bool) :
    ¬ (Clause.empty : Clause Var).satisfiedBy σ := by
  simp [Clause.empty, Clause.satisfiedBy]

/-- The resolvent of `c1` and `c2` on variable `v`:
    combine all literals from both parents, removing `v` from both polarities. -/
def Clause.resolve (c1 c2 : Clause Var) (v : Var) : Clause Var :=
  ⟨(c1.pos ∪ c2.pos).erase v, (c1.neg ∪ c2.neg).erase v⟩

/-- A CNF formula is a finite set of clauses. -/
structure CNF (Var : Type) [DecidableEq Var] where
  clauses : Finset (Clause Var)

/-- A CNF formula is satisfiable if some assignment satisfies every clause. -/
def CNF.satisfiable (F : CNF Var) : Prop :=
  ∃ σ : Var → Bool, ∀ c ∈ F.clauses, c.satisfiedBy σ

/-- Semantic entailment: `F` entails `c` means every satisfying assignment of `F`
    also satisfies `c`. -/
def CNF.entails (F : CNF Var) (c : Clause Var) : Prop :=
  ∀ σ : Var → Bool, (∀ c' ∈ F.clauses, c'.satisfiedBy σ) → c.satisfiedBy σ

/-! ## Fintype instance for Clause -/

/-- Equivalence between `Clause Var` and `Finset Var × Finset Var`. -/
def Clause.equivProd : Clause Var ≃ Finset Var × Finset Var where
  toFun c := (c.pos, c.neg)
  invFun p := ⟨p.1, p.2⟩
  left_inv c := by cases c; simp
  right_inv p := by cases p; simp

instance [Fintype Var] : Fintype (Clause Var) :=
  Fintype.ofEquiv _ Clause.equivProd.symm

/-! ## Space transitions -/

/-- One-step transition in bounded-space proof search.
    - `download`: load an axiom clause from `F` into memory
    - `resolve`: add the resolvent of two in-memory clauses
    - `erase`: remove a clause from memory -/
inductive SpaceStep (F : CNF Var) : Finset (Clause Var) → Finset (Clause Var) → Prop where
  | download (mem : Finset (Clause Var)) (c : Clause Var) (hc : c ∈ F.clauses) :
      SpaceStep F mem (insert c mem)
  | resolve (mem : Finset (Clause Var)) (c1 c2 : Clause Var) (v : Var)
      (h1 : c1 ∈ mem) (h2 : c2 ∈ mem)
      (hv_pos : v ∈ c1.pos) (hv_not_neg : v ∉ c1.neg)
      (hv_neg : v ∈ c2.neg) (hv_not_pos : v ∉ c2.pos) :
      SpaceStep F mem (insert (Clause.resolve c1 c2 v) mem)
  | erase (mem : Finset (Clause Var)) (c : Clause Var) (hc : c ∈ mem) :
      SpaceStep F mem (mem.erase c)

/-! ## Space certificates -/

/-- A space certificate is a finite trace of memory configurations
    witnessing that `F` is unsatisfiable within memory bound `s`. -/
structure SpaceCertificate (F : CNF Var) (s : ℕ) where
  trace : List (Finset (Clause Var))
  nonempty : trace ≠ []
  starts_empty : trace.head nonempty = ∅
  ends_with_empty_clause : Clause.empty ∈ trace.getLast nonempty
  bounded : ∀ mem ∈ trace, Finset.card mem ≤ s
  valid_steps : List.IsChain (SpaceStep F) trace

/-- A CNF is clause-space refutable in space `s` if a valid space certificate exists. -/
def clauseSpaceRefutable (F : CNF Var) (s : ℕ) : Prop :=
  Nonempty (SpaceCertificate F s)

/-! ## Number of clauses and configurations -/

/-- A disjoint clause is one where `pos` and `neg` are disjoint.
    These correspond to non-tautological clauses. -/
def Clause.isDisjoint (c : Clause Var) : Prop := Disjoint c.pos c.neg

instance [Fintype Var] (c : Clause Var) : Decidable c.isDisjoint :=
  inferInstanceAs (Decidable (Disjoint c.pos c.neg))

/-- The set of all disjoint clauses over `Var`. -/
noncomputable def disjointClauses [Fintype Var] : Finset (Clause Var) :=
  Finset.univ.filter Clause.isDisjoint

/-- Number of clauses over `Var` (all, including non-disjoint). -/
noncomputable def numAllClauses (Var : Type) [DecidableEq Var] [Fintype Var] : ℕ :=
  Fintype.card (Clause Var)

/-- Number of disjoint clauses over `Var`. -/
noncomputable def numDisjointClauses (Var : Type) [DecidableEq Var] [Fintype Var] : ℕ :=
  (disjointClauses (Var := Var)).card

/-! ## Configuration space -/

/-- The number of bounded-memory configurations of size at most `s`
    over the clause universe of `Var`. -/
noncomputable def cardSpaceConfigs (Var : Type) [DecidableEq Var] [Fintype Var] (s : ℕ) : ℕ :=
  ((Finset.univ : Finset (Finset (Clause Var))).filter (fun S => S.card ≤ s)).card

/-! ## Ternary encoding of disjoint clauses -/

/-- Encode a clause as a function `Var → Fin 3`:
    0 = absent, 1 = positive, 2 = negative.
    For non-disjoint clauses, if a variable appears in both, we encode as 1. -/
def Clause.toTernary [Fintype Var] (c : Clause Var) : Var → Fin 3 :=
  fun v =>
    if v ∈ c.pos then 1
    else if v ∈ c.neg then 2
    else 0

/-! ## Space graph and reachability -/

/-- The space graph: a directed graph on bounded-memory configurations
    where edges are valid space steps. -/
def spaceGraphRel [Fintype Var] (F : CNF Var) (s : ℕ) :
    Finset (Clause Var) → Finset (Clause Var) → Prop :=
  fun mem1 mem2 => SpaceStep F mem1 mem2 ∧ mem1.card ≤ s ∧ mem2.card ≤ s

/-- The empty configuration. -/
def emptyConfig : Finset (Clause Var) := ∅

/-- A configuration is a goal if it contains the empty clause. -/
def isGoalConfig (mem : Finset (Clause Var)) : Prop :=
  Clause.empty ∈ mem

/-- Multi-step reachability in the space graph. -/
inductive SpaceReachable (F : CNF Var) (s : ℕ) :
    Finset (Clause Var) → Finset (Clause Var) → Prop where
  | refl (mem : Finset (Clause Var)) (hb : mem.card ≤ s) :
      SpaceReachable F s mem mem
  | step (mem1 mem2 mem3 : Finset (Clause Var))
      (h12 : SpaceStep F mem1 mem2) (hb1 : mem1.card ≤ s) (hb2 : mem2.card ≤ s)
      (h23 : SpaceReachable F s mem2 mem3) :
      SpaceReachable F s mem1 mem3

/-! ## Potential function on configurations -/

/-- A simple potential function: the total number of literals across all clauses
    in the configuration. Useful for complexity analysis. -/
def spacePotential (mem : Finset (Clause Var)) : ℕ :=
  mem.sum (fun c => c.pos.card + c.neg.card)

end ClauseSpace