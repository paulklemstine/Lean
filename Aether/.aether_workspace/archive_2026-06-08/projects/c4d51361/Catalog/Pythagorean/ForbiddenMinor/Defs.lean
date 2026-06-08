/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Forbidden Minor Characterization: Definitions

Core definitions for the forbidden minor approach to resolution proof complexity.
Defines literals, clauses, CNF formulas, configurations, resolution steps,
configuration graphs, path minors, and resolution entropy.
-/
import Mathlib

open Finset

/-! ## Literals, Clauses, and CNF Formulas -/

/-- A literal over `n` boolean variables: either `pos i` (variable i) or `neg i` (¬ variable i). -/
inductive Literal (n : ℕ) where
  | pos : Fin n → Literal n
  | neg : Fin n → Literal n
  deriving DecidableEq, Fintype

/-- The negation of a literal. -/
def Literal.negate {n : ℕ} : Literal n → Literal n
  | .pos i => .neg i
  | .neg i => .pos i

theorem Literal.negate_negate {n : ℕ} (l : Literal n) : l.negate.negate = l := by
  cases l <;> rfl

theorem Literal.negate_ne_self {n : ℕ} (l : Literal n) : l.negate ≠ l := by
  cases l <;> simp [Literal.negate]

/-- A clause is a finite set of literals. -/
abbrev Clause (n : ℕ) := Finset (Literal n)

/-- A CNF formula is a finite set of clauses. -/
abbrev CNFFormula (n : ℕ) := Finset (Clause n)

/-- The empty clause (always falsified). -/
def emptyClause (n : ℕ) : Clause n := ∅

/-- A truth assignment maps variables to booleans. -/
def Assignment (n : ℕ) := Fin n → Bool

/-- A literal is satisfied by an assignment. -/
def Literal.satisfiedBy {n : ℕ} (l : Literal n) (σ : Assignment n) : Prop :=
  match l with
  | .pos i => σ i = true
  | .neg i => σ i = false

/-- A clause is satisfied if some literal in it is satisfied. -/
def Clause.satisfiedBy {n : ℕ} (C : Clause n) (σ : Assignment n) : Prop :=
  ∃ l ∈ C, Literal.satisfiedBy l σ

/-- A CNF formula is satisfied if all its clauses are satisfied. -/
def CNFFormula.satisfiedBy {n : ℕ} (F : CNFFormula n) (σ : Assignment n) : Prop :=
  ∀ C ∈ F, Clause.satisfiedBy C σ

/-- A CNF formula is unsatisfiable. -/
def CNFFormula.IsUnsat {n : ℕ} (F : CNFFormula n) : Prop :=
  ∀ σ : Assignment n, ¬F.satisfiedBy σ

/-! ## Resolution -/

/-- Resolve two clauses on a literal `l`: if `l ∈ C₁` and `l.negate ∈ C₂`,
    produce `(C₁ \ {l}) ∪ (C₂ \ {l.negate})`. Returns `none` if not resolvable. -/
def resolveOn {n : ℕ} (l : Literal n) (C₁ C₂ : Clause n) : Option (Clause n) :=
  if l ∈ C₁ ∧ l.negate ∈ C₂ then
    some ((C₁.erase l) ∪ (C₂.erase l.negate))
  else
    none

/-! ## Configurations and the Bounded Configuration Graph -/

/-- A configuration with space bound `s`: a set of at most `s` clauses. -/
structure Config (n s : ℕ) where
  clauses : Finset (Clause n)
  hsize : clauses.card ≤ s

instance {n s : ℕ} : DecidableEq (Config n s) := by
  intro a b
  cases a; cases b
  simp
  exact inferInstance

/-- The empty configuration. -/
def emptyConfig (n s : ℕ) : Config n s :=
  ⟨∅, by simp⟩

/-- Whether a configuration contains the empty clause. -/
def Config.hasEmptyClause {n s : ℕ} (cfg : Config n s) : Prop :=
  emptyClause n ∈ cfg.clauses

/-- Two configurations are adjacent in the bounded configuration graph if they
    differ by exactly one clause (add or remove). -/
def ConfigAdj {n s : ℕ} (C₁ C₂ : Config n s) : Prop :=
  C₁ ≠ C₂ ∧
  ((∃ c, C₂.clauses = C₁.clauses ∪ {c} ∧ c ∉ C₁.clauses) ∨
   (∃ c, C₁.clauses = C₂.clauses ∪ {c} ∧ c ∉ C₂.clauses))

theorem configAdj_symm {n s : ℕ} (C₁ C₂ : Config n s) :
    ConfigAdj C₁ C₂ → ConfigAdj C₂ C₁ := by
  intro ⟨hne, h⟩
  exact ⟨hne.symm, h.symm⟩

/-- The bounded configuration graph as a SimpleGraph. -/
noncomputable def bConfGraph (n s : ℕ) : SimpleGraph (Config n s) :=
  SimpleGraph.fromRel (fun C₁ C₂ => ConfigAdj C₁ C₂)

/-! ## Path Minors -/

/-- A path minor of width `w` in a graph `G`: a sequence of supernodes (vertex sets),
    each of size ≥ `w`, pairwise disjoint, with edges between consecutive supernodes.
    This captures the notion that the graph contains a "thick path" as a minor. -/
structure PathMinorOfWidth {α : Type*} (G : SimpleGraph α) (w : ℕ) where
  /-- Number of supernodes -/
  len : ℕ
  /-- The supernodes, indexed by Fin len -/
  supernodes : Fin len → Finset α
  /-- Supernodes are pairwise disjoint -/
  h_disjoint : ∀ i j : Fin len, i ≠ j → Disjoint (supernodes i) (supernodes j)
  /-- Each supernode has at least `w` vertices -/
  h_width : ∀ i : Fin len, w ≤ (supernodes i).card
  /-- len ≥ 2 for a nontrivial path -/
  h_len : 2 ≤ len
  /-- Consecutive supernodes have an edge between them -/
  h_adjacent : ∀ (i : Fin len), (hi : (i : ℕ) + 1 < len) →
    ∃ u ∈ supernodes i, ∃ v ∈ supernodes ⟨i + 1, hi⟩, G.Adj u v

/-! ## Clause Space -/

/-- Reachability in the configuration graph: a sequence of adjacent configurations. -/
inductive ConfigReachable {n s : ℕ} : Config n s → Config n s → Prop where
  | refl : ∀ c, ConfigReachable c c
  | step : ∀ c₁ c₂ c₃, ConfigAdj c₁ c₂ → ConfigReachable c₂ c₃ → ConfigReachable c₁ c₃

/-- A refutation at space `s` is a path from empty config to one containing the empty clause. -/
def HasRefutationAtSpace {n : ℕ} (_F : CNFFormula n) (s : ℕ) : Prop :=
  ∃ cfg : Config n s, ConfigReachable (emptyConfig n s) cfg ∧ cfg.hasEmptyClause

/-- The clause space of a formula: minimum `s` admitting a refutation. -/
noncomputable def clauseSpace {n : ℕ} (F : CNFFormula n) : ℕ :=
  sInf {s | HasRefutationAtSpace F s}

/-! ## Resolution Entropy and Mutual Information -/

/-- Resolution entropy of a configuration: log of the number of clauses. -/
noncomputable def resEntropy {n s : ℕ} (cfg : Config n s) : ℝ :=
  Real.log (cfg.clauses.card : ℝ)

/-- Resolution mutual information between two configurations, defined via
    inclusion-exclusion on clause sets. This is a set-theoretic analogue of
    Shannon mutual information. -/
noncomputable def resMutualInfo {n s : ℕ} (C₁ C₂ : Config n s) : ℝ :=
  Real.log ((C₁.clauses ∪ C₂.clauses).card : ℝ)
  - Real.log (C₁.clauses.card : ℝ)
  - Real.log (C₂.clauses.card : ℝ)
  + Real.log ((C₁.clauses ∩ C₂.clauses).card : ℝ)

/-! ## Pigeonhole Principle Formula -/

/-- The pigeonhole principle formula PHPₙⁿ⁺¹: n+1 pigeons into n holes.
    Uses n*(n+1) boolean variables; variable (p*n + h) means pigeon p goes to hole h.
    Each pigeon gets a clause saying it must go to some hole. -/
def phpFormula (n : ℕ) : CNFFormula (n * (n + 1)) :=
  (Finset.univ : Finset (Fin (n + 1))).image fun p =>
    (Finset.univ : Finset (Fin n)).image fun h =>
      Literal.pos ⟨p.val * n + h.val, by
        calc p.val * n + h.val
            < p.val * n + n := by omega
          _ = (p.val + 1) * n := by ring
          _ ≤ (n + 1) * n := by nlinarith [p.isLt]
          _ = n * (n + 1) := by ring⟩

/-! ## Maximum Path Minor Width -/

/-- The maximum path minor width in a graph (noncomputable). -/
noncomputable def maxPathMinorWidth {α : Type*} (G : SimpleGraph α) : ℕ :=
  sSup {w | Nonempty (PathMinorOfWidth G w)}

/-! ## Algorithm specification: computePathMinorWidth -/

/-- Specification: computePathMinorWidth returns a lower bound on the max path minor width. -/
structure PathMinorWidthLowerBound {α : Type*} (G : SimpleGraph α) (result : ℕ) : Prop where
  /-- The result is achievable -/
  achievable : result = 0 ∨ Nonempty (PathMinorOfWidth G result)