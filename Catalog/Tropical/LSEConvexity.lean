import Mathlib
import Tropical.NeuralNetworks.NDimLogSumExp
import Tropical.NeuralNetworks.SoftMaxConvergence
import Tropical.NeuralNetworks.TropicalSemiringHom

/-! # Convexity and Monotonicity of LogSumExp

Fundamental analytical properties:
1. LSE is increasing in each argument (monotonicity)
2. LSE is symmetric in its arguments
3. softMax is symmetric in its arguments
4. LSE gap formula and bounds (re-exports)
5. LSE sub-additivity and shift invariance (re-exports)
6. Tropical max super-additivity (re-export)
7. Weighted LSE bounds (re-exports)
-/

noncomputable section

open Real

namespace LSEConvexity

/-- LSE is increasing in the first argument -/
theorem logsumexp_mono_left (a b a' : ℝ) (hab : a ≤ a') :
    log (exp a + exp b) ≤ log (exp a' + exp b) :=
  log_le_log (add_pos (exp_pos a) (exp_pos b))
    (add_le_add (exp_le_exp.mpr hab) le_rfl)

/-- LSE is increasing in the second argument -/
theorem logsumexp_mono_right (a b b' : ℝ) (hbb' : b ≤ b') :
    log (exp a + exp b) ≤ log (exp a + exp b') :=
  log_le_log (add_pos (exp_pos a) (exp_pos b))
    (add_le_add le_rfl (exp_le_exp.mpr hbb'))

/-- LSE is symmetric: LSE(a, b) = LSE(b, a) -/
theorem logsumexp_symm (a b : ℝ) :
    log (exp a + exp b) = log (exp b + exp a) := by
  rw [add_comm]

/-- softMax is symmetric in its arguments -/
theorem softMax_symm (c x₁ x₂ : ℝ) (_hc : 0 < c) :
    SoftMaxConvergence.softMax c x₁ x₂ = SoftMaxConvergence.softMax c x₂ x₁ := by
  unfold SoftMaxConvergence.softMax
  rw [add_comm (exp (c * x₁)) (exp (c * x₂))]

/-- LSE gap is exactly log(1 + exp(-|a-b|)) from max (re-export) -/
theorem logsumexp_gap_from_max (a b : ℝ) :
    log (exp a + exp b) = max a b + log (1 + exp (-|a - b|)) :=
  NDimLogSumExp.logsumexp_two_point a b

/-- LSE gap is non-negative (re-export) -/
theorem logsumexp_gap_bounded_below (x₁ x₂ : ℝ) :
    (0 : ℝ) ≤ log (exp x₁ + exp x₂) - max x₁ x₂ :=
  NDimLogSumExp.logsumexp_gap_nonneg x₁ x₂

/-- LSE gap is at most log(2) (re-export) -/
theorem logsumexp_gap_bounded (x₁ x₂ : ℝ) :
    log (exp x₁ + exp x₂) - max x₁ x₂ ≤ log 2 :=
  NDimLogSumExp.logsumexp_gap_le x₁ x₂

/-- LSE sub-additivity (re-export) -/
theorem logsumexp_subadd (a b c d : ℝ) :
    log (exp (a + b) + exp (c + d)) ≤
    log (exp a + exp c) + log (exp b + exp d) :=
  TropicalSemiringHom.logsumexp_subadd a b c d

/-- LSE shift invariance (re-export) -/
theorem logsumexp_shift (a b d : ℝ) :
    log (exp (a + d) + exp (b + d)) = log (exp a + exp b) + d :=
  TropicalSemiringHom.logsumexp_shift a b d

/-- Tropical max super-additivity (re-export) -/
theorem tropical_max_superadd (x₁ x₂ y₁ y₂ : ℝ) :
    max x₁ x₂ + max y₁ y₂ ≥ max (x₁ + y₁) (x₂ + y₂) :=
  TropicalSemiringHom.tropical_max_superadd x₁ x₂ y₁ y₂

/-- Weighted LSE upper bound (re-export) -/
theorem weighted_logsumexp_upper (w₁ w₂ x₁ x₂ : ℝ) (hw₁ : 0 < w₁) (hw₂ : 0 < w₂) :
    log (w₁ * exp x₁ + w₂ * exp x₂) ≤ max (x₁ + log w₁) (x₂ + log w₂) + log 2 :=
  TropicalSemiringHom.weighted_logsumexp_upper w₁ w₂ x₁ x₂ hw₁ hw₂

/-- Weighted LSE lower bound (re-export) -/
theorem weighted_logsumexp_lower (w₁ w₂ x₁ x₂ : ℝ) (hw₁ : 0 < w₁) (hw₂ : 0 < w₂) :
    max (x₁ + log w₁) (x₂ + log w₂) ≤ log (w₁ * exp x₁ + w₂ * exp x₂) :=
  TropicalSemiringHom.weighted_logsumexp_lower w₁ w₂ x₁ x₂ hw₁ hw₂

end LSEConvexity