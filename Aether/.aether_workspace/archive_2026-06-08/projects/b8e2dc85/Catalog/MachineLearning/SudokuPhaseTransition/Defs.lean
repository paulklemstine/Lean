/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Constraint Satisfaction Phase Transitions: Definitions

This file formalizes the mathematical framework for studying phase transitions
in constraint satisfaction problems (CSPs), with Sudoku as the motivating example.

## Main Definitions

* `CSPInstance` — A constraint satisfaction problem instance
* `PartialAssignment` — Partial filling of an n×n grid
* `IsLatinSquare` — Latin square validity
* `criticalDensity` — The conjectured phase transition density d_c(n) = (n²-1)/n²
* `MonotoneSatSystem` — Monotone satisfiability system
* `PhaseRegime` — Classification into SAT/CRITICAL/UNSAT phases
* `ConstraintEntropy` — Information-theoretic entropy of constraint systems

## Mathematical Significance

Random CSP instances exhibit sharp phase transitions. This framework formalizes
the structural properties governing these transitions, connecting constraint
satisfaction to graph coloring and information theory.
-/

open Finset BigOperators

noncomputable section

namespace CSPPhaseTransition

/-! ## Core CSP Framework -/

/-- A **constraint satisfaction problem instance** with uniform domain. -/
structure CSPInstance (V : Type*) [Fintype V] [DecidableEq V] where
  /-- Domain size (uniform domain) -/
  domainSize : ℕ
  /-- Domain is non-trivial -/
  domainPos : 0 < domainSize
  /-- Constraint scopes: each constraint involves a set of variables -/
  scopes : Finset (Finset V)
  /-- Constraint predicate -/
  valid : Finset V → (V → Fin domainSize) → Prop

/-- A complete assignment satisfies a CSP if it satisfies all constraints. -/
def CSPInstance.IsSatisfied {V : Type*} [Fintype V] [DecidableEq V]
    (inst : CSPInstance V) (f : V → Fin inst.domainSize) : Prop :=
  ∀ S ∈ inst.scopes, inst.valid S f

/-- A CSP instance is satisfiable if a satisfying assignment exists. -/
def CSPInstance.Satisfiable {V : Type*} [Fintype V] [DecidableEq V]
    (inst : CSPInstance V) : Prop :=
  ∃ f : V → Fin inst.domainSize, inst.IsSatisfied f

/-! ## Latin Square and Sudoku Structure -/

/-- The cells of an n×n grid. -/
abbrev GridCell (n : ℕ) := Fin n × Fin n

/-- A **partial assignment** on an n×n grid with values in Fin n. -/
structure PartialAssignment (n : ℕ) where
  /-- The set of filled cells -/
  filled : Finset (GridCell n)
  /-- The values assigned to filled cells -/
  values : GridCell n → Fin n

/-- The **density** of a partial assignment: fraction of filled cells. -/
def PartialAssignment.density {n : ℕ} (pa : PartialAssignment n) : ℚ :=
  (pa.filled.card : ℚ) / ((n : ℚ) * n)

/-- A complete assignment **extends** a partial assignment. -/
def extends_partial {n : ℕ} (f : GridCell n → Fin n) (pa : PartialAssignment n) : Prop :=
  ∀ c ∈ pa.filled, f c = pa.values c

/-- A complete assignment is a **valid Latin square**. -/
def IsLatinSquare {n : ℕ} (f : GridCell n → Fin n) : Prop :=
  (∀ i : Fin n, Function.Injective (fun j => f (i, j))) ∧
  (∀ j : Fin n, Function.Injective (fun i => f (i, j)))

/-- A partial assignment is **consistent** if extendable to a Latin square. -/
def PartialAssignment.IsConsistent {n : ℕ} (pa : PartialAssignment n) : Prop :=
  ∃ f : GridCell n → Fin n, extends_partial f pa ∧ IsLatinSquare f

/-! ## Phase Transition Framework -/

/-- The **critical density** for n×n grids: d_c(n) = (n²-1)/n². -/
def criticalDensity (n : ℕ) : ℚ := ((n ^ 2 - 1 : ℤ) : ℚ) / (n ^ 2 : ℚ)

/-- Phase classification for CSP instances. -/
inductive PhaseRegime where
  | SAT      -- Under-constrained
  | CRITICAL -- At the phase transition
  | UNSAT    -- Over-constrained
  deriving DecidableEq, Repr

/-- Classify density relative to the critical threshold. -/
def classifyPhase (n : ℕ) (d : ℚ) : PhaseRegime :=
  if d < criticalDensity n - 1 / (n ^ 2 : ℚ) then PhaseRegime.SAT
  else if d > criticalDensity n + 1 / (n ^ 2 : ℚ) then PhaseRegime.UNSAT
  else PhaseRegime.CRITICAL

/-! ## Monotone Satisfiability System -/

/-- A **monotone satisfiability system** captures the structural property:
    more filled cells → fewer valid completions. -/
structure MonotoneSatSystem where
  /-- Grid size parameter -/
  gridSize : ℕ
  /-- Grid size is positive -/
  gridPos : 0 < gridSize
  /-- Expected number of valid completions given k pre-filled cells -/
  completionCount : ℕ → ℝ
  /-- Monotonicity: more filled cells → fewer completions -/
  monotone : ∀ k₁ k₂ : ℕ, k₁ ≤ k₂ → k₂ ≤ gridSize ^ 2 →
    completionCount k₂ ≤ completionCount k₁
  /-- Non-negativity -/
  nonneg : ∀ k, 0 ≤ completionCount k

/-- Satisfiability probability at k filled cells. -/
def satProbability (sys : MonotoneSatSystem) (k : ℕ) : ℝ :=
  if sys.completionCount 0 = 0 then 0
  else sys.completionCount k / sys.completionCount 0

/-! ## Constraint Entropy -/

/-- **Constraint entropy** measures information content of the constraint system.
    H(n, k) = log₂(completions with k filled) / log₂(n^(n²-k))
    Normalized to [0,1]: 1 = no constraints effective, 0 = fully determined. -/
def constraintEntropy (n k : ℕ) (completions : ℝ) : ℝ :=
  if n ≤ 1 ∨ k ≥ n ^ 2 then 0
  else completions / (n ^ (n ^ 2 - k) : ℝ)

/-! ## Constraint Graph Structure -/

/-- Constraint graph degree: each cell conflicts with 2(n-1) others. -/
def constraintDegree (n : ℕ) : ℕ := 2 * (n - 1)

/-- Total vertices in the constraint graph. -/
def constraintGraphVertices (n : ℕ) : ℕ := n ^ 2

/-- Total edges in the constraint graph. -/
def constraintGraphEdges (n : ℕ) : ℕ := n ^ 2 * (n - 1)

/-- The constraint ratio α for Latin squares. -/
def constraintRatioSimple (n : ℕ) : ℚ := ((n - 1 : ℤ) : ℚ)

end CSPPhaseTransition