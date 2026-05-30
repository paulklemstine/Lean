/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Sudoku Spectral Gap: Definitions

This file defines the core mathematical structures for analyzing Sudoku puzzles
through the lens of spectral graph theory and Markov chain mixing.

## Novel Definitions

* `ConstraintSystem` — Abstract constraint satisfaction framework on finite types
* `SolutionSet` — The set of all valid assignments satisfying constraints
* `ConstraintDensity` — Ratio of fixed cells to total cells
* `StochasticMatrix` — Stochastic matrix for swap-based Markov chain on solutions
* `SpectralGapData` — Gap between largest and second-largest eigenvalue
* `MixingTimeBound` — Number of steps to reach ε-closeness to stationarity
* `PhaseRegime` — Classification of constraint density into fast/critical/frozen phases

## Cross-Domain Connections

* Combinatorics ↔ Spectral theory: constraint structure determines eigenvalue gaps
* Information theory ↔ Markov chains: solution entropy controls mixing behavior
* Statistical physics ↔ Puzzles: phase transitions in constraint satisfaction
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

namespace SudokuSpectralGap

/-! ## Part I: Abstract Constraint Satisfaction Systems -/

/-- A constraint system on a finite type of cells with values from a finite type.
    This captures the essential structure of Sudoku and similar CSPs. -/
structure ConstraintSystem (Cell Value : Type) [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value] where
  /-- The set of cells that are pre-filled (clues) -/
  clues : Finset Cell
  /-- The value assigned to each clue cell -/
  clueValue : Cell → Value

/-- An assignment maps every cell to a value -/
def Assignment (Cell Value : Type) := Cell → Value

/-- An assignment is compatible with clues if it agrees on clue cells -/
def compatibleWithClues {Cell Value : Type} [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value]
    (cs : ConstraintSystem Cell Value) (a : Assignment Cell Value) : Prop :=
  ∀ c ∈ cs.clues, a c = cs.clueValue c

/-- The constraint density: ratio of clue cells to total cells -/
def constraintDensity {Cell Value : Type} [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value]
    (cs : ConstraintSystem Cell Value) : ℚ :=
  cs.clues.card / Fintype.card Cell

/-! ## Part II: Solution Counting and Monotonicity -/

/-- The solution set of a constraint system (as a set of assignments) -/
def SolutionSetPred {Cell Value : Type} [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value]
    (cs : ConstraintSystem Cell Value) (isValid : (Cell → Value) → Prop) :
    Set (Cell → Value) :=
  {a | isValid a ∧ compatibleWithClues cs a}

/-! ## Part III: Spectral Gap and Mixing Infrastructure -/

/-- A finite stochastic matrix (transition kernel) on states indexed by Fin n -/
structure StochasticMatrix (n : ℕ) where
  /-- The transition probabilities -/
  mat : Fin n → Fin n → ℝ
  /-- All entries are non-negative -/
  nonneg : ∀ i j, 0 ≤ mat i j
  /-- Each row sums to 1 -/
  row_sum : ∀ i, ∑ j, mat i j = 1

/-- A doubly stochastic matrix: both row and column sums are 1 -/
structure DoublyStochasticMatrix (n : ℕ) extends StochasticMatrix n where
  /-- Each column also sums to 1 -/
  col_sum : ∀ j, ∑ i, mat i j = 1

/-- The spectral gap of a stochastic matrix, defined as 1 - λ₂
    where λ₂ is the second largest eigenvalue magnitude.
    We abstract this as a real number satisfying certain properties. -/
structure SpectralGapData (n : ℕ) where
  /-- The stochastic matrix -/
  kernel : StochasticMatrix n
  /-- The spectral gap value -/
  gap : ℝ
  /-- The spectral gap is non-negative -/
  gap_nonneg : 0 ≤ gap
  /-- The spectral gap is at most 1 -/
  gap_le_one : gap ≤ 1

/-- The mixing time bound: number of steps to reach ε-closeness to stationarity.
    For a doubly stochastic chain with spectral gap γ, the mixing time is
    O((1/γ) · log(n/ε)). -/
def mixingTimeBound (gap : ℝ) (ε : ℝ) (n : ℕ) : ℝ :=
  if gap > 0 then (1 / gap) * (Real.log n + Real.log (1 / ε))
  else 0

/-- Phase regime classification based on constraint density -/
inductive PhaseRegime where
  | underconstrained : PhaseRegime  -- d < d_c: many solutions, fast mixing
  | critical : PhaseRegime          -- d ≈ d_c: few solutions, slow mixing
  | overconstrained : PhaseRegime   -- d > d_c: unique solution, frozen
  deriving DecidableEq, Repr

/-- Classify a constraint density into a phase regime -/
def classifyPhase (density : ℚ) : PhaseRegime :=
  if density < 17 / 81 then PhaseRegime.underconstrained
  else if density < 30 / 81 then PhaseRegime.critical
  else PhaseRegime.overconstrained

/-- The Sudoku critical density: 17 clues out of 81 cells -/
def sudokuCriticalDensity : ℚ := 17 / 81

/-- The Sudoku frozen density: approximately 30 clues out of 81 cells -/
def sudokuFrozenDensity : ℚ := 30 / 81

/-! ## Part IV: Entropy of Solution Distributions -/

/-- Shannon entropy of a finite probability distribution -/
def shannonEntropy {n : ℕ} (p : Fin n → ℝ) : ℝ :=
  -∑ i, if p i > 0 then p i * Real.log (p i) else 0

/-- The uniform distribution on Fin n -/
def uniformDist (n : ℕ) [NeZero n] : Fin n → ℝ :=
  fun _ => 1 / n

/-- The log-Sobolev constant of a Markov chain, which gives stronger
    concentration than the spectral gap alone -/
structure LogSobolevData (n : ℕ) extends SpectralGapData n where
  /-- The log-Sobolev constant -/
  lsConst : ℝ
  /-- The log-Sobolev constant is non-negative -/
  lsConst_nonneg : 0 ≤ lsConst
  /-- The log-Sobolev constant is at most twice the spectral gap
      (this is a standard relationship) -/
  ls_le_gap : lsConst ≤ 2 * gap

/-! ## Part V: L2 Distance and Contraction -/

/-- L2 distance between two distributions -/
def l2Dist {n : ℕ} (p q : Fin n → ℝ) : ℝ :=
  Real.sqrt (∑ i, (p i - q i) ^ 2)

/-- The Dirichlet form of a function with respect to a stochastic matrix -/
def dirichletForm {n : ℕ} (P : StochasticMatrix n) (f : Fin n → ℝ)
    (mu : Fin n → ℝ) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, mu i * P.mat i j * (f j - f i) ^ 2

/-- Variance of a function under a distribution -/
def varianceDist {n : ℕ} (f : Fin n → ℝ) (mu : Fin n → ℝ) : ℝ :=
  let mean := ∑ i, mu i * f i
  ∑ i, mu i * (f i - mean) ^ 2

/-- A Poincaré inequality: the spectral gap controls variance via the Dirichlet form -/
structure PoincareInequality (n : ℕ) where
  /-- The stochastic matrix -/
  kernel : StochasticMatrix n
  /-- The stationary distribution -/
  stationary : Fin n → ℝ
  /-- The Poincaré constant -/
  poinConst : ℝ
  /-- The constant is positive -/
  poinConst_pos : 0 < poinConst
  /-- The inequality: Var(f) ≤ (1/c) · E(f, f) -/
  inequality : ∀ f : Fin n → ℝ,
    varianceDist f stationary ≤ (1 / poinConst) * dirichletForm kernel f stationary

end SudokuSpectralGap

end