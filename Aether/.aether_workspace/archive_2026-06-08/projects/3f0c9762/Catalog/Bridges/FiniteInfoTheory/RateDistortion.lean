/-
Copyright (c) 2025 Bridges Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite Rate-Distortion Theory: Structural Theorems

This file proves the key structural properties of the rate-distortion function
for finite alphabets:

1. **Monotonicity**: `R(D)` is nonincreasing in `D`.
2. **Convexity**: `R(D)` is convex on the feasible distortion interval.
3. **Nonnegativity**: `R(D) ≥ 0`.
-/

import Bridges.FiniteInfoTheory.Basic

open Finset BigOperators Real

noncomputable section

variable {α β : Type*} [Fintype α] [Fintype β]

/-! ## Monotonicity of the Rate-Distortion Function -/

/-- The feasible distortion set is upward closed. -/
theorem feasibleDistortion_mono (μ : FinProbDist α) (d : α → β → ℝ)
    {D D' : ℝ} (hD : FeasibleDistortion μ d D) (hDD' : D ≤ D') :
    FeasibleDistortion μ d D' := by
  obtain ⟨K, hK⟩ := hD
  exact ⟨K, le_trans hK hDD'⟩

/-- Rate-distortion (as infimum over feasible set) is nonincreasing
    on the feasible set: larger distortion budget ⟹ smaller required rate.

    The proof uses the fact that the feasible kernel set grows with `D`,
    so the infimum can only decrease. -/
theorem rateDistortion'_antitoneOn (I : InfoMeasure α β)
    (μ : FinProbDist α) (d : α → β → ℝ) :
    AntitoneOn (rateDistortion' I μ d) (feasibleDistortionSet μ d) := by
  intro D hD D' hD' hDD'
  unfold rateDistortion'
  apply csInf_le_csInf
  · exact ⟨0, fun r ⟨K, _, hKr⟩ => hKr ▸ I.measure_nonneg μ K⟩
  · obtain ⟨K, hK⟩ := hD
    exact ⟨I.measure μ K, K, hK, rfl⟩
  · intro r ⟨K, hKD, hKr⟩
    exact ⟨K, le_trans hKD hDD', hKr⟩

/-! ## Expected distortion is linear in the kernel mixture -/

/-
Expected distortion is affine in the kernel mixture parameter.
-/
theorem expectedDistortion_mix (μ : FinProbDist α) (d : α → β → ℝ)
    (K₁ K₂ : StochasticKernel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (K₁.mix K₂ t ht0 ht1).expectedDistortion μ d =
      t * K₁.expectedDistortion μ d + (1 - t) * K₂.expectedDistortion μ d := by
  simp +decide [ StochasticKernel.expectedDistortion, Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_assoc, mul_left_comm, mul_add, add_mul, ht0, ht1 ];
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by rw [ StochasticKernel.mix ] ; ring;

/-! ## Convexity of Rate-Distortion -/

/-- The feasible distortion set is convex. -/
theorem feasibleDistortionSet_convex (μ : FinProbDist α) (d : α → β → ℝ) :
    Convex ℝ (feasibleDistortionSet μ d) := by
  intro D₁ hD₁ D₂ hD₂ t s ht hs hts
  obtain ⟨K₁, hK₁⟩ := hD₁
  obtain ⟨K₂, hK₂⟩ := hD₂
  refine ⟨K₁.mix K₂ t ht (by linarith), ?_⟩
  rw [expectedDistortion_mix]
  have hsub : s = 1 - t := by linarith
  calc t * K₁.expectedDistortion μ d + (1 - t) * K₂.expectedDistortion μ d
      ≤ t * D₁ + (1 - t) * D₂ := by
        apply add_le_add
        · exact mul_le_mul_of_nonneg_left hK₁ ht
        · exact mul_le_mul_of_nonneg_left hK₂ (by linarith)
    _ = t * D₁ + s * D₂ := by rw [hsub]

/-
The rate-distortion function is convex on the feasible distortion set.
-/
theorem rateDistortion'_convexOn (I : InfoMeasure α β)
    (μ : FinProbDist α) (d : α → β → ℝ) :
    ConvexOn ℝ (feasibleDistortionSet μ d) (rateDistortion' I μ d) := by
  constructor
  · exact feasibleDistortionSet_convex μ d
  · intro D₁ hD₁ D₂ hD₂ t s ht hs hts
    refine' le_of_forall_pos_le_add fun ε ε0 => _;
    -- By definition of $R(D)$, there exist $K₁$ and $K₂$ such that $K₁$ is feasible at $D₁$ and $K₂$ is feasible at $D₂$, and $I(K₁) \leq R(D₁) + \frac{\epsilon}{2}$ and $I(K₂) \leq R(D₂) + \frac{\epsilon}{2}$.
    obtain ⟨K₁, hK₁⟩ : ∃ K₁ : StochasticKernel α β, K₁.expectedDistortion μ d ≤ D₁ ∧ I.measure μ K₁ ≤ rateDistortion' I μ d D₁ + ε / 2 := by
      have := exists_lt_of_csInf_lt ( show { r : ℝ | ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D₁ ∧ I.measure μ K = r }.Nonempty from ?_ ) ( lt_add_of_pos_right _ ( half_pos ε0 ) );
      · rcases this with ⟨ a, ⟨ K₁, hK₁, rfl ⟩, ha ⟩ ; exact ⟨ K₁, hK₁, ha.le ⟩ ;
      · exact ⟨ _, ⟨ hD₁.choose, hD₁.choose_spec, rfl ⟩ ⟩
    obtain ⟨K₂, hK₂⟩ : ∃ K₂ : StochasticKernel α β, K₂.expectedDistortion μ d ≤ D₂ ∧ I.measure μ K₂ ≤ rateDistortion' I μ d D₂ + ε / 2 := by
      have := exists_lt_of_csInf_lt ( show { r : ℝ | ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D₂ ∧ I.measure μ K = r }.Nonempty from ?_ ) ( show InfSet.sInf { r : ℝ | ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D₂ ∧ I.measure μ K = r } < InfSet.sInf { r : ℝ | ∃ K : StochasticKernel α β, K.expectedDistortion μ d ≤ D₂ ∧ I.measure μ K = r } + ε / 2 from lt_add_of_pos_right _ ( half_pos ε0 ) );
      · rcases this with ⟨ a, ⟨ K₂, hK₂₁, rfl ⟩, hK₂₂ ⟩ ; exact ⟨ K₂, hK₂₁, hK₂₂.le ⟩ ;
      · exact ⟨ _, ⟨ hD₂.choose, hD₂.choose_spec, rfl ⟩ ⟩;
    -- By definition of $R(D)$, we have $R(tD₁ + sD₂) \leq I(K₁.mix K₂ t)$.
    have hR_le_I_mix : rateDistortion' I μ d (t • D₁ + s • D₂) ≤ I.measure μ (K₁.mix K₂ t ht (by linarith)) := by
      refine' csInf_le _ _;
      · exact ⟨ 0, by rintro x ⟨ K, hK, rfl ⟩ ; exact I.measure_nonneg μ K ⟩;
      · refine' ⟨ _, _, rfl ⟩;
        convert add_le_add ( mul_le_mul_of_nonneg_left hK₁.1 ht ) ( mul_le_mul_of_nonneg_left hK₂.1 hs ) using 1 ; ring;
        convert expectedDistortion_mix μ d K₁ K₂ t ht ( by linarith ) using 1 ; rw [ ← hts ] ; ring;
    -- By definition of $I$, we have $I(K₁.mix K₂ t) \leq t * I(K₁) + s * I(K₂)$.
    have hI_mix_le : I.measure μ (K₁.mix K₂ t ht (by linarith)) ≤ t * I.measure μ K₁ + s * I.measure μ K₂ := by
      simpa [ show s = 1 - t by linarith ] using I.measure_convex μ K₁ K₂ t ht ( by linarith );
    norm_num [ show t = 1 - s by linarith ] at *;
    nlinarith

/-! ## Nonneg lower bound -/

/-- The rate-distortion function is nonneg when the feasible set is nonempty. -/
theorem rateDistortion'_nonneg (I : InfoMeasure α β)
    (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ)
    (hD : FeasibleDistortion μ d D) :
    0 ≤ rateDistortion' I μ d D := by
  apply le_csInf
  · exact ⟨I.measure μ hD.choose, hD.choose, hD.choose_spec, rfl⟩
  · intro r ⟨K, _, hKr⟩
    rw [← hKr]
    exact I.measure_nonneg μ K

/-! ## Tropical / Piecewise-Linear Structures -/

/-- A tropical affine functional: represents `D ↦ slope * D + intercept`. -/
structure TropicalAffine where
  slope : ℝ
  intercept : ℝ

/-- Evaluate a tropical affine functional at a point. -/
def TropicalAffine.eval (f : TropicalAffine) (D : ℝ) : ℝ :=
  f.slope * D + f.intercept

end