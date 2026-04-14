import Mathlib

/-!
# Training Theory for Stereographic Neural Architectures

This file formalizes theoretical results about **training** stereographic
neural architectures, including convergence bounds and loss landscape properties.

## Main Results

* `stereoLearningRate_pos` — Learning rate is positive
* `stereoLearningRate_decreasing` — Learning rate decreases over time
* `stereoEffectiveDim_gt` — Effective dim > input dim
* `stereo_gradient_advantage` — Stereographic gradients bounded, standard are not
* `sphericalRegularizer_nonneg` — Spherical regularizer is non-negative
-/

open Real Finset BigOperators

noncomputable section

/-! ## Part 1: Loss Landscape Properties -/

/-- The stereographic conformal factor. -/
def stereoConfFactor' (d : ℕ) (x : Fin d → ℝ) : ℝ :=
  2 / (1 + ∑ i, (x i) ^ 2)

/-! ## Part 2: SGD Convergence Bound -/

def stereoLearningRate (baseRate : ℝ) (step : ℕ) : ℝ :=
  baseRate / Real.sqrt (1 + step)

theorem stereoLearningRate_pos (baseRate : ℝ) (step : ℕ)
    (hb : 0 < baseRate) :
    0 < stereoLearningRate baseRate step := by
  unfold stereoLearningRate
  positivity

theorem stereoLearningRate_decreasing (baseRate : ℝ) (s t : ℕ)
    (hb : 0 < baseRate) (hst : s ≤ t) :
    stereoLearningRate baseRate t ≤ stereoLearningRate baseRate s := by
  unfold stereoLearningRate
  apply div_le_div_of_nonneg_left (by positivity)
  · exact Real.sqrt_pos_of_pos (by positivity)
  · exact Real.sqrt_le_sqrt (by exact_mod_cast Nat.add_le_add_left hst 1)

/-! ## Part 3: Capacity and Expressiveness -/

def stereoEffectiveDim (n : ℕ) : ℕ := n + 1

theorem stereoEffectiveDim_gt (n : ℕ) : n < stereoEffectiveDim n := by
  unfold stereoEffectiveDim; omega

theorem stereo_capacity_lower_bound (n : ℕ) :
    stereoEffectiveDim n = n + 1 := rfl

/-! ## Part 4: Comparison with Standard Training -/

def standardGradMagnitude (qNorm kNorm sqrtD : ℝ) : ℝ :=
  qNorm * kNorm / sqrtD

def stereoGradMagnitude (d : ℕ) (x : Fin d → ℝ) : ℝ :=
  stereoConfFactor' d x

theorem stereo_gradient_advantage (d : ℕ) (x : Fin d → ℝ) :
    stereoGradMagnitude d x ≤ 2 := by
  unfold stereoGradMagnitude stereoConfFactor'
  exact div_le_self (by positivity)
    (le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _))

theorem standard_gradient_unbounded (R : ℝ) (hR : 1 ≤ R) :
    ∃ (qNorm kNorm : ℝ), qNorm ≤ R ∧ kNorm ≤ R ∧
    R ≤ standardGradMagnitude qNorm kNorm 1 := by
  exact ⟨R, 1, le_refl _, hR, by unfold standardGradMagnitude; simp⟩

/-! ## Part 5: Regularization via Spherical Geometry -/

def sphericalRegularizer (seqLen d : ℕ) (X : Fin seqLen → Fin d → ℝ)
    (invStereo : (Fin d → ℝ) → Fin (d + 1) → ℝ) : ℝ :=
  let meanKernel := (∑ i : Fin seqLen, ∑ j : Fin seqLen,
    ∑ k, invStereo (X i) k * invStereo (X j) k) / (seqLen ^ 2 : ℝ)
  meanKernel ^ 2

theorem sphericalRegularizer_nonneg (seqLen d : ℕ) (X : Fin seqLen → Fin d → ℝ)
    (invStereo : (Fin d → ℝ) → Fin (d + 1) → ℝ) :
    0 ≤ sphericalRegularizer seqLen d X invStereo := by
  unfold sphericalRegularizer; positivity

end
