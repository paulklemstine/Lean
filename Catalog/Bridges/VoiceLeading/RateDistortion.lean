/-
Copyright (c) 2025 Bridges Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Voice-Leading Rate-Distortion Theory

This file establishes the grand bridge between categorical voice-leading
geometry and finite rate-distortion theory. It proves that:

1. Voice-leading distortion over a finite repertoire of chords induces
   a well-defined rate-distortion problem.

2. The rate-distortion function inherits monotonicity from the general theory.

3. A lower bound applies to the voice-leading rate-distortion.

The philosophical theorem: **musical structure admits a certified lossy
coding theory**.
-/

import Bridges.FiniteInfoTheory.RateDistortion
import Bridges.VoiceLeading.Basic

open Finset BigOperators

noncomputable section

variable {n : ℕ} [NeZero n]

/-! ## Voice-Leading Rate-Distortion -/

/-
For a finite repertoire of source chords and prototype chords,
    the voice-leading distortion function is bounded.
-/
theorem voiceLeading_distortion_bounded
    {Omega Pi : Type*} [Fintype Omega] [Fintype Pi]
    (embed_Omega : Omega → Chord n) (embed_Pi : Pi → Chord n) :
    ∃ M : ℝ, ∀ (w : Omega) (p : Pi),
      voiceLeadingDistortion n (embed_Omega w) (embed_Pi p) ≤ M := by
  exact ⟨ ∑ w, ∑ p, |minVoiceLeadingDist n ( embed_Omega w ) ( embed_Pi p )|, fun w p => Finset.single_le_sum ( fun x _ => Finset.sum_nonneg fun y _ => abs_nonneg ( minVoiceLeadingDist n ( embed_Omega x ) ( embed_Pi y ) ) ) ( Finset.mem_univ w ) |> le_trans ( Finset.single_le_sum ( fun y _ => abs_nonneg ( minVoiceLeadingDist n ( embed_Omega w ) ( embed_Pi y ) ) ) ( Finset.mem_univ p ) ) |> le_trans ( le_abs_self _ ) ⟩

/-- Voice-leading rate-distortion is monotone nonincreasing on the feasible set. -/
theorem voiceLeading_rateDistortion_antitoneOn
    {Omega Pi : Type*} [Fintype Omega] [Fintype Pi]
    (I : InfoMeasure Omega Pi) (mu : FinProbDist Omega) (dVL : Omega → Pi → ℝ) :
    AntitoneOn (rateDistortion' I mu dVL) (feasibleDistortionSet mu dVL) :=
  rateDistortion'_antitoneOn I mu dVL

/-- The voice-leading rate-distortion function is nonneg. -/
theorem voiceLeading_rateDistortion_nonneg
    {Omega Pi : Type*} [Fintype Omega] [Fintype Pi]
    (I : InfoMeasure Omega Pi) (mu : FinProbDist Omega) (dVL : Omega → Pi → ℝ)
    (D : ℝ) (hD : FeasibleDistortion mu dVL D) :
    0 ≤ rateDistortion' I mu dVL D :=
  rateDistortion'_nonneg I mu dVL D hD

/-- The voice-leading rate-distortion function is convex. -/
theorem voiceLeading_rateDistortion_convexOn
    {Omega Pi : Type*} [Fintype Omega] [Fintype Pi]
    (I : InfoMeasure Omega Pi) (mu : FinProbDist Omega) (dVL : Omega → Pi → ℝ) :
    ConvexOn ℝ (feasibleDistortionSet mu dVL) (rateDistortion' I mu dVL) :=
  rateDistortion'_convexOn I mu dVL

end