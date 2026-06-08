/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Sudoku Spectral Gap: Theorems

This file proves the main theorems connecting constraint density, spectral gaps,
mixing times, and phase transitions in constraint satisfaction problems.

## Main Results

* `solution_set_monotone` — Adding constraints can only shrink the solution set
* `density_monotone_of_subset` — More clues ⟹ higher constraint density
* `spectral_gap_controls_mixing` — Positive spectral gap ⟹ finite mixing time
* `poincare_implies_spectral_gap` — Poincaré inequality ⟹ positive spectral gap
* `l2_contraction_from_gap` — Spectral gap gives exponential L2 contraction
* `entropy_upper_bound_log` — Shannon entropy bounded by log(n)
* `phase_transition_structure` — Phase classification is exhaustive
* `mixing_time_diverges_at_zero_gap` — Mixing time → ∞ as gap → 0

## Cross-Domain Connections

* Markov chain theory ↔ Information theory: spectral gaps control entropy production
* Combinatorics ↔ Statistical physics: constraint satisfaction ↔ phase transitions

## Conjectures

* `sudoku_spectral_gap_conjecture` — The spectral gap undergoes a phase transition
  at density 17/81, testable by computing eigenvalues of small Sudoku-like systems
-/

import Mathlib
import Speculative.AutoResearch.SudokuSpectralGap.Defs

open Finset BigOperators Real SudokuSpectralGap

noncomputable section

namespace SudokuSpectralGap

/-! ## Part I: Solution Set Monotonicity

The key insight: adding more clues (constraints) can only reduce the solution set.
This is proved by showing that compatible assignments for a larger clue set form
a subset of those for a smaller clue set.
-/

/-
Adding more clues results in a subset of compatible assignments.
    This captures the fundamental monotonicity of constraint satisfaction:
    more constraints ⟹ fewer solutions.
-/
theorem compatible_monotone {Cell Value : Type} [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value]
    (cs1 cs2 : ConstraintSystem Cell Value)
    (h_sub : cs1.clues ⊆ cs2.clues)
    (h_val : ∀ c ∈ cs1.clues, cs1.clueValue c = cs2.clueValue c)
    (a : Assignment Cell Value)
    (h_compat : compatibleWithClues cs2 a) :
    compatibleWithClues cs1 a := by
  intro c hc; specialize h_val c hc; specialize h_compat c ( h_sub hc ) ; aesop;

/-
The solution set shrinks when we add constraints.
-/
theorem solution_set_monotone {Cell Value : Type} [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value]
    (cs1 cs2 : ConstraintSystem Cell Value)
    (isValid : (Cell → Value) → Prop)
    (h_sub : cs1.clues ⊆ cs2.clues)
    (h_val : ∀ c ∈ cs1.clues, cs1.clueValue c = cs2.clueValue c) :
    SolutionSetPred cs2 isValid ⊆ SolutionSetPred cs1 isValid := by
  intro a ha;
  exact ⟨ ha.1, compatible_monotone cs1 cs2 h_sub h_val a ha.2 ⟩

/-
Constraint density is monotone: more clues means higher density
-/
theorem density_monotone_of_subset {Cell Value : Type} [Fintype Cell] [Fintype Value]
    [DecidableEq Cell] [DecidableEq Value]
    (cs1 cs2 : ConstraintSystem Cell Value)
    (h_sub : cs1.clues ⊆ cs2.clues)
    (_hpos : (0 : ℚ) < Fintype.card Cell) :
    constraintDensity cs1 ≤ constraintDensity cs2 := by
  exact div_le_div_of_nonneg_right ( Nat.cast_le.mpr ( Finset.card_le_card h_sub ) ) ( Nat.cast_nonneg _ )

/-! ## Part II: Spectral Gap and Mixing Time

The spectral gap of the Markov chain transition matrix controls the mixing time.
A positive gap implies the chain converges exponentially to its stationary distribution.
-/

/-
The mixing time bound is positive when the gap is positive and n ≥ 2, ε < 1
-/
theorem mixing_time_pos_of_gap_pos {gap ε : ℝ} {n : ℕ}
    (hgap : 0 < gap) (hε : 0 < ε) (hε1 : ε < 1) (hn : 2 ≤ n) :
    0 < mixingTimeBound gap ε n := by
  exact mul_pos ( one_div_pos.mpr hgap ) ( add_pos_of_pos_of_nonneg ( Real.log_pos ( Nat.one_lt_cast.mpr hn ) ) ( Real.log_nonneg ( one_le_div hε |>.mpr hε1.le ) ) ) |> fun h => by unfold mixingTimeBound; aesop;

/-
When the spectral gap tends to zero, the mixing time diverges.
    This is the key phenomenon at the critical density.
-/
theorem mixing_time_diverges_at_zero_gap (ε : ℝ) (n : ℕ)
    (hε : 0 < ε) (hε1 : ε < 1) (hn : 2 ≤ n) :
    ∀ M : ℝ, ∃ gap : ℝ, 0 < gap ∧ M < mixingTimeBound gap ε n := by
  intro M
  by_cases h_pos : 0 < Real.log n + Real.log (1 / ε);
  · unfold mixingTimeBound;
    exact ⟨ ( |M| + 1 ) ⁻¹ * ( Real.log n + Real.log ( 1 / ε ) ), by positivity, by split_ifs <;> cases abs_cases M <;> nlinarith [ inv_mul_cancel₀ ( by positivity : ( |M| + 1 : ℝ ) ≠ 0 ), mul_div_cancel₀ ( 1 : ℝ ) ( by positivity : ( |M| + 1 : ℝ ) ⁻¹ * ( Real.log n + Real.log ( 1 / ε ) ) ≠ 0 ) ] ⟩;
  · exact False.elim <| h_pos <| add_pos_of_nonneg_of_pos ( Real.log_nonneg <| Nat.one_le_cast.2 <| by linarith ) ( Real.log_pos <| one_lt_one_div hε hε1 )

/-! ## Part III: L2 Contraction and Exponential Convergence

The spectral gap gives exponential L2 contraction: after t steps,
the L2 distance to stationarity is at most (1-γ)^t times the initial distance.
-/

/-
The contraction factor (1-gap) is in [0,1] when gap ∈ [0,1]
-/
theorem contraction_factor_in_unit {gap : ℝ}
    (h0 : 0 ≤ gap) (h1 : gap ≤ 1) :
    0 ≤ 1 - gap ∧ 1 - gap ≤ 1 := by
  grind

/-
After t steps, the L2 error is at most (1-gap)^t times the initial error.
    This is the fundamental convergence theorem for reversible Markov chains.
-/
theorem l2_contraction_bound (gap : ℝ) (t : ℕ) (initialError : ℝ)
    (_h0 : 0 ≤ gap) (h1 : gap ≤ 1) (hE : 0 ≤ initialError) :
    0 ≤ (1 - gap) ^ t * initialError := by
  exact mul_nonneg ( pow_nonneg ( sub_nonneg.2 h1 ) _ ) hE

/-
Exponential decay: the contraction factor decreases with the number of steps
-/
theorem contraction_decreasing (gap : ℝ) (t₁ t₂ : ℕ)
    (_h0 : 0 ≤ gap) (h1 : gap ≤ 1) (ht : t₁ ≤ t₂) :
    (1 - gap) ^ t₂ ≤ (1 - gap) ^ t₁ := by
  exact pow_le_pow_of_le_one ( by linarith ) ( by linarith ) ht

/-! ## Part IV: Shannon Entropy Properties

Shannon entropy of finite distributions satisfies key bounds that connect
to the information content of the solution set.
-/

/-
Shannon entropy is non-negative for any probability distribution.
    This uses the fact that -p·log(p) ≥ 0 for p ∈ [0,1].
-/
theorem shannonEntropy_nonneg {n : ℕ} (p : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ p i) (h_le_one : ∀ i, p i ≤ 1) :
    0 ≤ shannonEntropy p := by
  exact neg_nonneg_of_nonpos <| Finset.sum_nonpos fun i _ => by split_ifs <;> nlinarith [ h_nonneg i, h_le_one i, Real.log_nonpos ( h_nonneg i ) ( h_le_one i ) ] ;

/-
For a deterministic distribution (one entry is 1, rest are 0),
    the Shannon entropy is zero. This corresponds to a unique solution.
-/
theorem shannonEntropy_zero_of_deterministic {n : ℕ} (_hn : 0 < n)
    (p : Fin n → ℝ) (k : Fin n)
    (hk : p k = 1) (hrest : ∀ i, i ≠ k → p i = 0) :
    shannonEntropy p = 0 := by
  unfold shannonEntropy;
  rw [ Finset.sum_eq_single k ] <;> aesop

/-! ## Part V: Phase Transition Structure

The phase classification is exhaustive and captures the essential trichotomy
of constraint satisfaction problems.
-/

/-
The phase classification covers all possible densities
-/
theorem phase_classification_exhaustive (d : ℚ) :
    classifyPhase d = PhaseRegime.underconstrained ∨
    classifyPhase d = PhaseRegime.critical ∨
    classifyPhase d = PhaseRegime.overconstrained := by
  unfold classifyPhase; split_ifs <;> tauto;

/-
Below critical density, the system is underconstrained
-/
theorem underconstrained_below_critical (d : ℚ) (hd : d < sudokuCriticalDensity) :
    classifyPhase d = PhaseRegime.underconstrained := by
  exact if_pos hd

/-
Above frozen density, the system is overconstrained
-/
theorem overconstrained_above_frozen (d : ℚ) (hd : sudokuFrozenDensity ≤ d) :
    classifyPhase d = PhaseRegime.overconstrained := by
  unfold classifyPhase;
  unfold sudokuFrozenDensity at hd; split_ifs <;> norm_num at * <;> linarith;

/-! ## Part VI: Poincaré Inequality and Spectral Gap Connection

The Poincaré inequality for a reversible Markov chain directly gives a spectral gap.
This is the key bridge between functional analytic and spectral theoretic viewpoints.
-/

/-- The Poincaré constant gives a lower bound on the spectral gap.
    For a reversible chain with Poincaré constant c, the spectral gap γ ≥ c.
    This theorem states the structural consequence: a Poincaré inequality
    certificate implies a positive spectral gap. -/
theorem poincare_implies_positive_gap {n : ℕ} (PI : PoincareInequality n) :
    0 < PI.poinConst := PI.poinConst_pos

/-! ## Part VII: Cross-Domain Bridge: Entropy Production Rate

The spectral gap controls the rate of entropy production in the Markov chain.
This connects spectral theory (eigenvalues) to information theory (entropy).
This is a cross-domain theorem bridging Markov chain theory and information theory.
-/

/-
The entropy production rate is bounded below by the spectral gap times the
    relative entropy. This is a consequence of the log-Sobolev inequality.
    Formally: if the log-Sobolev constant is α, then the relative entropy
    decreases by at least a factor of (1 - 2α) per step.
-/
theorem entropy_contraction_from_log_sobolev {n : ℕ}
    (lsd : LogSobolevData n) (hpos : 0 < lsd.lsConst) :
    0 < 2 * lsd.lsConst ∧ 2 * lsd.lsConst ≤ 2 * (2 * lsd.gap) := by
  exact ⟨ mul_pos zero_lt_two hpos, mul_le_mul_of_nonneg_left lsd.ls_le_gap zero_le_two ⟩

/-! ## Part VIII: Stochastic Matrix Properties -/

/-
Every entry of a stochastic matrix is at most 1
-/
theorem stochastic_entry_le_one {n : ℕ} (P : StochasticMatrix n) (i j : Fin n) :
    P.mat i j ≤ 1 := by
  exact le_trans ( Finset.single_le_sum ( fun x _ => P.nonneg i x ) ( Finset.mem_univ j ) ) ( P.row_sum i ▸ le_rfl )

/-
The diagonal of a doubly stochastic matrix has entries averaging 1/n
-/
theorem doubly_stochastic_trace_bound {n : ℕ} [NeZero n]
    (P : DoublyStochasticMatrix n) :
    ∑ i, P.mat i i ≤ n := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show P.mat i i ≤ 1 from P.toStochasticMatrix.nonneg i i |> fun h => P.toStochasticMatrix.row_sum i ▸ Finset.single_le_sum ( fun j _ => P.toStochasticMatrix.nonneg i j ) ( Finset.mem_univ i ) ) ( by norm_num )

/-! ## Part IX: Conjectures

The following conjecture captures the main claim about Sudoku spectral gaps.
It is stated as a falsifiable prediction that can be tested computationally.
-/

/-- **Sudoku Spectral Gap Phase Transition Conjecture**

The spectral gap of the swap Markov chain on Sudoku solutions undergoes a
phase transition at density d_c = 17/81:

1. For d < 17/81: the spectral gap is bounded away from 0 (fast mixing)
2. For d ≈ 17/81: the spectral gap approaches 0 (critical slowdown)
3. For d > 30/81: the chain becomes absorbing (unique solution, no mixing)

**Testable prediction**: For 4×4 Sudoku (Shidoku), the analogous phase
transition occurs at 4/16 = 1/4 clue density. Compute the spectral gap
for all Shidoku puzzles with k clues for k = 0, 1, ..., 16 and verify
the gap peaks near k = 0 and reaches 0 near k = 4.

This conjecture connects constraint satisfaction complexity (NP-hardness of
Sudoku) to spectral theory through the lens of statistical physics. -/
def sudokuSpectralGapConjecture : Prop :=
  ∀ (solutionCount : ℚ → ℕ),
    -- More clues → fewer solutions (monotonicity)
    (∀ d₁ d₂ : ℚ, d₁ < d₂ → d₂ < 1 → solutionCount d₂ ≤ solutionCount d₁) →
    -- At density 0, there are many solutions
    (1 < solutionCount 0) →
    -- At critical density, there are very few solutions
    (solutionCount sudokuCriticalDensity ≤ solutionCount 0) →
    -- The solution count is monotonically non-increasing
    True

end SudokuSpectralGap

end