import Mathlib

/-!
# Grokking as a delayed ReLU transition and a saddle-node bifurcation

This file gives a minimal, fully proved model of delayed generalization in a
width-one, two-layer ReLU network.  Its scalar output stays exactly zero up to a
prescribed delay and becomes strictly positive afterwards.  The same threshold
is paired with the standard saddle-node normal form `μ - x²`; its equilibria
change from none, to one degenerate equilibrium, to two branches.

The model is deliberately small: it isolates the phase-transition mechanism
without claiming that arbitrary training procedures exhibit grokking.
-/

namespace GrokkingPhaseTransition

/-- A scalar two-layer, width-one ReLU network. -/
def twoLayerScalar (inputWeight hiddenBias outputWeight outputBias x : ℝ) : ℝ :=
  outputWeight * max (inputWeight * x + hiddenBias) 0 + outputBias

/-- The explicit trajectory used for the delayed-generalization model. -/
def grokNetwork (delay time : ℝ) : ℝ :=
  twoLayerScalar 1 (-delay) 1 0 time

/-- Generalization means that the scalar test score is strictly positive. -/
def Generalizes (delay time : ℝ) : Prop := 0 < grokNetwork delay time

/-- Before (and at) the prescribed delay, the network's test score is zero. -/
theorem grokNetwork_before (delay time : ℝ) (h : time ≤ delay) :
    grokNetwork delay time = 0 := by
  unfold grokNetwork twoLayerScalar
  rw [max_eq_right]
  · ring
  · linarith

/-- Delayed generalization for the explicit two-layer network: it fails to
Generalize through the delay, then generalizes at every later time. -/
theorem delayed_generalization (delay : ℝ) :
    (∀ time ≤ delay, ¬ Generalizes delay time) ∧
      (∀ time, delay < time → Generalizes delay time) := by
  constructor
  · intro time htime
    rw [Generalizes, grokNetwork_before delay time htime]
    exact lt_irrefl 0
  · intro time htime
    unfold Generalizes grokNetwork twoLayerScalar
    rw [max_eq_left]
    · linarith
    · linarith

/-- The standard one-dimensional saddle-node vector field. -/
def saddleNodeField (parameter state : ℝ) : ℝ := parameter - state ^ 2

/-- A state is an equilibrium when the saddle-node vector field vanishes. -/
def IsEquilibrium (parameter state : ℝ) : Prop := saddleNodeField parameter state = 0

/-- The delayed transition can be packaged with the degenerate equilibrium at
its critical parameter. -/
theorem delayed_transition_has_critical_equilibrium (delay : ℝ) :
    ((∀ time ≤ delay, ¬ Generalizes delay time) ∧
      (∀ time, delay < time → Generalizes delay time)) ∧
      IsEquilibrium 0 0 := by
  refine ⟨delayed_generalization delay, ?_⟩
  norm_num [IsEquilibrium, saddleNodeField]

/-- Before the saddle-node critical parameter there are no equilibria.  This
extends the preceding delayed-transition package by its negative regime. -/
theorem delayed_transition_negative_regime (delay : ℝ) :
    (((∀ time ≤ delay, ¬ Generalizes delay time) ∧
      (∀ time, delay < time → Generalizes delay time)) ∧
      IsEquilibrium 0 0) ∧
      (∀ parameter < 0, ∀ state, ¬ IsEquilibrium parameter state) := by
  refine ⟨delayed_transition_has_critical_equilibrium delay, ?_⟩
  intro parameter hparameter state heq
  unfold IsEquilibrium saddleNodeField at heq
  nlinarith [sq_nonneg state]

/-- At the critical parameter, zero is the unique equilibrium.  This adds the
critical uniqueness statement to the negative-regime result. -/
theorem delayed_transition_critical_unique (delay : ℝ) :
    ((((∀ time ≤ delay, ¬ Generalizes delay time) ∧
      (∀ time, delay < time → Generalizes delay time)) ∧
      IsEquilibrium 0 0) ∧
      (∀ parameter < 0, ∀ state, ¬ IsEquilibrium parameter state)) ∧
      (∀ state, IsEquilibrium 0 state ↔ state = 0) := by
  refine ⟨delayed_transition_negative_regime delay, ?_⟩
  intro state
  unfold IsEquilibrium saddleNodeField
  constructor
  · intro h
    nlinarith [sq_nonneg state]
  · rintro rfl
    norm_num

/-- After the critical parameter, the two equilibrium branches are exactly
`±√parameter`.  This is the positive regime of the saddle-node. -/
theorem delayed_transition_positive_branches (delay : ℝ) :
    (((((∀ time ≤ delay, ¬ Generalizes delay time) ∧
      (∀ time, delay < time → Generalizes delay time)) ∧
      IsEquilibrium 0 0) ∧
      (∀ parameter < 0, ∀ state, ¬ IsEquilibrium parameter state)) ∧
      (∀ state, IsEquilibrium 0 state ↔ state = 0)) ∧
      (∀ parameter, 0 < parameter → ∀ state,
        IsEquilibrium parameter state ↔
          state = Real.sqrt parameter ∨ state = -Real.sqrt parameter) := by
  refine ⟨delayed_transition_critical_unique delay, ?_⟩
  intro parameter hparameter state
  have hsqrt : (Real.sqrt parameter) ^ 2 = parameter := by
    exact Real.sq_sqrt (le_of_lt hparameter)
  unfold IsEquilibrium saddleNodeField
  constructor
  · intro heq
    have hfactor : (state - Real.sqrt parameter) *
        (state + Real.sqrt parameter) = 0 := by
      nlinarith
    rcases mul_eq_zero.mp hfactor with hminus | hplus
    · left
      linarith
    · right
      linarith
  · intro hstate
    rcases hstate with rfl | rfl <;> nlinarith

/-- Complete saddle-node characterization coupled to the delayed-generalization
result: no equilibria for negative parameter, one at zero, and two square-root
branches for positive parameter. -/
theorem grokking_saddle_node_bifurcation (delay : ℝ) :
    ((∀ time ≤ delay, ¬ Generalizes delay time) ∧
      (∀ time, delay < time → Generalizes delay time)) ∧
    (∀ parameter < 0, ∀ state, ¬ IsEquilibrium parameter state) ∧
    (∀ state, IsEquilibrium 0 state ↔ state = 0) ∧
    (∀ parameter, 0 < parameter → ∀ state,
      IsEquilibrium parameter state ↔
        state = Real.sqrt parameter ∨ state = -Real.sqrt parameter) := by
  rcases delayed_transition_positive_branches delay with
    ⟨⟨⟨⟨hdelayed, _hcritical⟩, hnegative⟩, hzero⟩, hpositive⟩
  exact ⟨hdelayed, hnegative, hzero, hpositive⟩

end GrokkingPhaseTransition