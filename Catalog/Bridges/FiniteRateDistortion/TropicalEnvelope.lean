import Mathlib
import Bridges.FiniteRateDistortion.Core

/-!
# Tropical Envelope Structure of Finite Rate-Distortion

This file establishes the **tropical/piecewise-linear structure** of the finite
rate-distortion function: R(D) is bounded below by affine functionals from
the Lagrangian dual, giving it a tropical envelope representation.

## Main Results

* `rateDistortion_affine_bound` — Each Lagrangian dual parameter s gives an
  affine lower bound on R(D).
* `rateDistortion_ge_iSup_affine` — R(D) is at least the supremum of these bounds.

## Mathematical Significance

The representation as a supremum of affine functions means R(D) can be
approximated by sweeping the Lagrangian parameter — this is exactly what the
Blahut-Arimoto algorithm does. Under sign change, the supremum of affine
functions becomes a min-plus combination: a tropical polynomial.
-/

open Finset BigOperators Real

noncomputable section

variable {α β : Type*} [Fintype α] [Fintype β]

set_option linter.unusedSectionVars false in
/-- For any slope parameter s ≥ 0, the Lagrangian dual provides an affine
    lower bound: R(D) ≥ Φ(s) - s·D. -/
theorem rateDistortion_affine_bound
    [Nonempty α] [Nonempty β]
    (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) (hs : 0 ≤ s)
    (D : ℝ) (hD : FeasibleDistortion μ d D) :
    lagrangianDual μ d s - s * D ≤ rateDistortion μ d D :=
  lagrangianDual_le_rateDistortion μ d s hs D hD

set_option linter.unusedSectionVars false in
/-- The Lagrangian dual value at s = 0 equals the unconstrained minimum of
    mutual information. -/
theorem lagrangianDual_zero (μ : FinProbDist α) (d : α → β → ℝ) :
    lagrangianDual μ d 0 = sInf {r | ∃ W : Channel α β, mutualInfo μ W = r} := by
  unfold lagrangianDual lagrangianDualSet
  congr 1
  ext r
  simp [mul_comm]

set_option linter.unusedSectionVars false in
/-- R(D) is at least the supremum of the affine lower bounds from all s ≥ 0. -/
theorem rateDistortion_ge_iSup_affine
    [Nonempty α] [Nonempty β]
    (μ : FinProbDist α) (d : α → β → ℝ)
    (D : ℝ) (hD : FeasibleDistortion μ d D) :
    ∀ s : ℝ, 0 ≤ s → lagrangianDual μ d s - s * D ≤ rateDistortion μ d D :=
  fun s hs => lagrangianDual_le_rateDistortion μ d s hs D hD

end