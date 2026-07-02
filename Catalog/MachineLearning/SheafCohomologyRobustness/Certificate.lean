/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Certified L∞ Adversarial Robustness for Linear Scores

This module proves the local certified-robustness engine that the cohomological
gluing of `Cohomology.lean` transports across a cover.  Working over the input
space `Fin d → ℝ` with the L∞ (max-coordinate) metric, a binary classifier is
the sign of a linear score `score w x = ∑ᵢ wᵢ xᵢ`.

The dual norm controlling L∞ perturbations of a linear functional is the L¹ norm
of the weights, `‖w‖₁ = ∑ᵢ |wᵢ|`.  We prove:

* `score_linf_lipschitz` : `|score w x − score w y| ≤ ‖w‖₁ · r` whenever
  `x` and `y` differ by at most `r` in every coordinate (an L∞ ball of radius
  `r`).  This is the exact Lipschitz constant of a linear score in L∞ geometry.

* `linf_certified_pos` / `linf_certified_neg` : if the margin `|score w x₀|`
  strictly exceeds `‖w‖₁ · r`, then the predicted sign is invariant under every
  L∞-perturbation of radius ≤ `r`.

* `linf_certified_radius` : packaged certificate — the predicate
  `0 < score w ·` (the class label) is constant on the L∞ ball of radius `r`
  around `x₀`.  The certified radius is `|score w x₀| / ‖w‖₁`.

* `certified_radius_lower_bound` : an explicit lower bound on the certified
  radius via the margin and the weight L¹ norm.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): "An L∞ certified radius is exactly margin divided by
  the L¹ weight norm, and this is tight" — the dual-norm robustness law.
* Experiment (Experimenter): proved the Lipschitz bound by
  `|∑ wᵢ Δxᵢ| ≤ ∑ |wᵢ| |Δxᵢ| ≤ (∑ |wᵢ|) r` (`Finset.abs_sum_le_sum_abs` +
  monotone sum), then converted margin > Lipschitz-gap into sign stability via
  `abs_lt`.
* Analysis (Analyst): the certificate is *one-sided per region* — it certifies a
  ball, not a global radius.  Globalisation requires gluing across the cover,
  which is where `Cohomology.lean`'s `H¹` enters (see `Bridge.lean`).
* Critique (Critic): could `linf_certified_pos` be vacuous when `‖w‖₁ = 0`?  No —
  then `score ≡ 0`, `hpos : 0 < 0` is impossible, so the hypotheses are never
  vacuously exploited; the live content is the genuine `‖w‖₁ > 0` case.
* Synthesis (PI): margin/`‖w‖₁` is the per-region stalk radius; min over regions
  is the global radius once the nerve has vanishing `H¹`.
-/

import Mathlib

open BigOperators Finset

namespace SheafCohomologyRobustness

variable {d : ℕ}

/-- The linear score of a binary classifier with weight vector `w` at input `x`:
`score w x = ∑ᵢ wᵢ xᵢ`.  The predicted label is `0 < score w x`. -/
def score (w x : Fin d → ℝ) : ℝ := ∑ i, w i * x i

/-- The L¹ norm of the weight vector, `‖w‖₁ = ∑ᵢ |wᵢ|`.  It is the dual norm
controlling L∞ perturbations of the linear score. -/
def weightL1 (w : Fin d → ℝ) : ℝ := ∑ i, |w i|

theorem weightL1_nonneg (w : Fin d → ℝ) : 0 ≤ weightL1 w :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-! ## §1. The L∞ Lipschitz bound for a linear score -/

/-- **L∞ Lipschitz bound.**  If `x` and `y` lie within an L∞ ball of radius `r`
(`|xᵢ − yᵢ| ≤ r` for every coordinate), then the scores differ by at most
`‖w‖₁ · r`.  This is the exact modulus of continuity of a linear score in L∞
geometry. -/
theorem score_linf_lipschitz (w x y : Fin d → ℝ) (r : ℝ)
    (hxy : ∀ i, |x i - y i| ≤ r) :
    |score w x - score w y| ≤ weightL1 w * r := by
  have hdiff : score w x - score w y = ∑ i, w i * (x i - y i) := by
    unfold score; rw [← Finset.sum_sub_distrib]; congr 1; funext i; ring
  rw [hdiff, weightL1]
  calc |∑ i, w i * (x i - y i)| ≤ ∑ i, |w i * (x i - y i)| :=
          Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, |w i| * r := by
        apply Finset.sum_le_sum
        intro i _
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (hxy i) (abs_nonneg _)
    _ = (∑ i, |w i|) * r := by rw [Finset.sum_mul]

/-! ## §2. Sign stability inside the certified ball -/

/-- **Positive-class certificate.**  If the margin `|score w x₀|` strictly
exceeds `‖w‖₁ · r` and `x` is within L∞ radius `r` of `x₀`, then a positive score
at `x₀` forces a positive score at `x`: the positive prediction is certified. -/
theorem linf_certified_pos (w x x₀ : Fin d → ℝ) (r : ℝ)
    (hball : ∀ i, |x i - x₀ i| ≤ r)
    (hmargin : weightL1 w * r < |score w x₀|)
    (hpos : 0 < score w x₀) :
    0 < score w x := by
  have hlip : |score w x - score w x₀| ≤ weightL1 w * r :=
    score_linf_lipschitz w x x₀ r hball
  rw [abs_of_pos hpos] at hmargin
  have h2 : |score w x - score w x₀| < score w x₀ := lt_of_le_of_lt hlip hmargin
  linarith [(abs_lt.mp h2).1]

/-- **Negative-class certificate.**  Symmetrically, a negative score at `x₀` is
preserved throughout the certified L∞ ball. -/
theorem linf_certified_neg (w x x₀ : Fin d → ℝ) (r : ℝ)
    (hball : ∀ i, |x i - x₀ i| ≤ r)
    (hmargin : weightL1 w * r < |score w x₀|)
    (hneg : score w x₀ < 0) :
    score w x < 0 := by
  have hlip : |score w x - score w x₀| ≤ weightL1 w * r :=
    score_linf_lipschitz w x x₀ r hball
  rw [abs_of_neg hneg] at hmargin
  have h2 : |score w x - score w x₀| < -score w x₀ := lt_of_le_of_lt hlip hmargin
  linarith [(abs_lt.mp h2).2]

/-- **Certified L∞ robustness radius (packaged).**  When the margin exceeds
`‖w‖₁ · r`, the binary label predicate `fun z => 0 < score w z` is constant on the
entire L∞ ball of radius `r` about `x₀`.  Hence no adversarial perturbation of
L∞-norm ≤ `r` can flip the prediction. -/
theorem linf_certified_radius (w x₀ : Fin d → ℝ) (r : ℝ) (hr : 0 ≤ r)
    (hmargin : weightL1 w * r < |score w x₀|) :
    ∀ x, (∀ i, |x i - x₀ i| ≤ r) → ((0 < score w x) ↔ (0 < score w x₀)) := by
  intro x hball
  rcases lt_trichotomy (score w x₀) 0 with h | h | h
  · constructor
    · intro hx; exact absurd (linf_certified_neg w x x₀ r hball hmargin h) (by linarith)
    · intro hx; exact absurd hx (by linarith)
  · rw [h, abs_zero] at hmargin
    have : 0 ≤ weightL1 w * r := mul_nonneg (weightL1_nonneg w) hr
    linarith
  · constructor
    · intro _; exact h
    · intro _; exact linf_certified_pos w x x₀ r hball hmargin h

/-- **Explicit certified radius.**  If `‖w‖₁ > 0`, then any radius
`r < |score w x₀| / ‖w‖₁` is certified.  This exhibits `|score w x₀| / ‖w‖₁`
as the certified L∞ robustness radius. -/
theorem certified_radius_lower_bound (w x₀ : Fin d → ℝ) (r : ℝ)
    (hw : 0 < weightL1 w) (hr : r < |score w x₀| / weightL1 w) :
    weightL1 w * r < |score w x₀| := by
  rw [lt_div_iff₀ hw] at hr
  linarith [hr]

end SheafCohomologyRobustness