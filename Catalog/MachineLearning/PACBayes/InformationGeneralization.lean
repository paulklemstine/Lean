/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Information-theoretic PAC-Bayes and description length

This file gives a finite, discrete formalization of the bridge from mutual
information to compression-based generalization bounds.  A learner is represented
by the joint law of its training sample and output hypothesis.  Its mutual
information is the expectation of the information density

  log (P(S,H) / (P(S) P(H))).

If a code length dominates this information density pointwise, then mutual
information is at most expected description length.  Consequently every
square-root PAC-Bayes bound expressed using mutual information is bounded by the
corresponding description-length expression.  The final results show that a
uniformly shorter description gives a no-worse generalization guarantee.
-/
import Mathlib

open Real BigOperators Finset

noncomputable section

namespace PACBayesInformation

/-- A strictly positive joint probability law of a training sample and a learned
hypothesis. Strict positivity keeps the finite information density free of endpoint
conventions. -/
structure JointLaw (Sample Hypothesis : Type*) [Fintype Sample] [Fintype Hypothesis] where
  probability : Sample → Hypothesis → ℝ
  probability_pos : ∀ s h, 0 < probability s h
  probability_sum_one : ∑ s, ∑ h, probability s h = 1

/-- The marginal law of the training sample. -/
def JointLaw.sampleMarginal {Sample Hypothesis : Type*}
    [Fintype Sample] [Fintype Hypothesis] (J : JointLaw Sample Hypothesis)
    (s : Sample) : ℝ :=
  ∑ h, J.probability s h

/-- The marginal law of the learned hypothesis. -/
def JointLaw.hypothesisMarginal {Sample Hypothesis : Type*}
    [Fintype Sample] [Fintype Hypothesis] (J : JointLaw Sample Hypothesis)
    (h : Hypothesis) : ℝ :=
  ∑ s, J.probability s h

/-- Pointwise information density between the training sample and learned hypothesis. -/
def informationDensity {Sample Hypothesis : Type*}
    [Fintype Sample] [Fintype Hypothesis] (J : JointLaw Sample Hypothesis)
    (s : Sample) (h : Hypothesis) : ℝ :=
  Real.log (J.probability s h /
    (J.sampleMarginal s * J.hypothesisMarginal h))

/-- Mutual information `I(S;H)` of the training sample and learned hypothesis. -/
def mutualInformation {Sample Hypothesis : Type*}
    [Fintype Sample] [Fintype Hypothesis] (J : JointLaw Sample Hypothesis) : ℝ :=
  ∑ s, ∑ h, J.probability s h * informationDensity J s h

/-- Expected description length of the hypothesis output by the learner. -/
def expectedDescriptionLength {Sample Hypothesis : Type*}
    [Fintype Sample] [Fintype Hypothesis] (J : JointLaw Sample Hypothesis)
    (length : Hypothesis → ℝ) : ℝ :=
  ∑ s, ∑ h, J.probability s h * length h

/-- The square-root complexity term appearing in information-theoretic PAC-Bayes
bounds. The complexity argument may include both mutual information and a
confidence penalty such as `log (1 / δ)`. -/
def generalizationRadius (sampleSize : ℕ) (complexity : ℝ) : ℝ :=
  Real.sqrt (complexity / (2 * (sampleSize : ℝ)))

/-- The basic compression inequality: a pointwise code-length upper bound on
information density bounds mutual information by expected description length. -/
theorem mutualInformation_le_expectedDescriptionLength
    {Sample Hypothesis : Type*} [Fintype Sample] [Fintype Hypothesis]
    (J : JointLaw Sample Hypothesis) (length : Hypothesis → ℝ)
    (hcode : ∀ s h, informationDensity J s h ≤ length h) :
    mutualInformation J ≤ expectedDescriptionLength J length := by
  simp only [mutualInformation, expectedDescriptionLength]
  apply Finset.sum_le_sum
  intro s hs
  apply Finset.sum_le_sum
  intro h hh
  exact mul_le_mul_of_nonneg_left (hcode s h) (le_of_lt (J.probability_pos s h))

/-- Replacing mutual information by an expected description-length bound can only
increase the PAC-Bayes radius. -/
theorem informationRadius_le_descriptionRadius
    {Sample Hypothesis : Type*} [Fintype Sample] [Fintype Hypothesis]
    (J : JointLaw Sample Hypothesis) (length : Hypothesis → ℝ)
    (sampleSize : ℕ) (confidencePenalty : ℝ)
    (hsample : 0 < sampleSize)
    (hcode : ∀ s h, informationDensity J s h ≤ length h) :
    generalizationRadius sampleSize (mutualInformation J + confidencePenalty) ≤
      generalizationRadius sampleSize
        (expectedDescriptionLength J length + confidencePenalty) := by
  simp only [generalizationRadius]
  apply Real.sqrt_le_sqrt
  apply div_le_div_of_nonneg_right _ (by positivity : 0 ≤ (2 : ℝ) * sampleSize)
  linarith [mutualInformation_le_expectedDescriptionLength J length hcode]

/-- Any information-theoretic PAC-Bayes generalization guarantee transfers to the
corresponding expected-description-length guarantee. -/
theorem generalization_from_expected_description
    {Sample Hypothesis : Type*} [Fintype Sample] [Fintype Hypothesis]
    (J : JointLaw Sample Hypothesis) (length : Hypothesis → ℝ)
    (sampleSize : ℕ) (confidencePenalty gap : ℝ)
    (hsample : 0 < sampleSize)
    (hcode : ∀ s h, informationDensity J s h ≤ length h)
    (hPAC : gap ≤ generalizationRadius sampleSize
      (mutualInformation J + confidencePenalty)) :
    gap ≤ generalizationRadius sampleSize
      (expectedDescriptionLength J length + confidencePenalty) := by
  exact le_trans hPAC (informationRadius_le_descriptionRadius J length sampleSize confidencePenalty hsample hcode)

/-- If every hypothesis has a description of length at most `maxLength`, the
expected-description result yields a bound using that single maximum length. -/
theorem generalization_from_max_description
    {Sample Hypothesis : Type*} [Fintype Sample] [Fintype Hypothesis]
    (J : JointLaw Sample Hypothesis) (length : Hypothesis → ℝ)
    (sampleSize : ℕ) (confidencePenalty gap maxLength : ℝ)
    (hsample : 0 < sampleSize)
    (hcode : ∀ s h, informationDensity J s h ≤ length h)
    (hlength : ∀ h, length h ≤ maxLength)
    (hPAC : gap ≤ generalizationRadius sampleSize
      (mutualInformation J + confidencePenalty)) :
    gap ≤ generalizationRadius sampleSize (maxLength + confidencePenalty) := by
  -- First, transfer to expected description length bound
  have h1 : gap ≤ generalizationRadius sampleSize (expectedDescriptionLength J length + confidencePenalty) :=
    generalization_from_expected_description J length sampleSize confidencePenalty gap hsample hcode hPAC
  -- Now show expectedDescriptionLength J length ≤ maxLength
  have h2 : expectedDescriptionLength J length ≤ maxLength := by
    simp only [expectedDescriptionLength]
    calc ∑ s, ∑ h, J.probability s h * length h
        ≤ ∑ s, ∑ h, J.probability s h * maxLength := by
          apply Finset.sum_le_sum
          intro s _
          apply Finset.sum_le_sum
          intro h _
          exact mul_le_mul_of_nonneg_left (hlength h) (le_of_lt (J.probability_pos s h))
      _ = maxLength * ∑ s, ∑ h, J.probability s h := by
          rw [Finset.mul_sum _ _ _]
          apply Finset.sum_congr rfl
          intro s _
          rw [Finset.mul_sum _ _ _]
          apply Finset.sum_congr rfl
          intro h _
          ring
      _ = maxLength := by rw [J.probability_sum_one, mul_one]
  have h3 : expectedDescriptionLength J length + confidencePenalty ≤ maxLength + confidencePenalty := by linarith [h2]
  exact le_trans h1 (Real.sqrt_le_sqrt (div_le_div_of_nonneg_right h3 (by positivity : (0 : ℝ) ≤ 2 * sampleSize)))

/-- Shorter uniform descriptions imply a no-worse generalization bound. This is the
end-to-end compression-to-information-to-generalization statement: starting from
an information-theoretic PAC-Bayes guarantee, a code bounded by `shortLength`
also gives every looser bound with `shortLength ≤ longLength`. -/
theorem shorter_descriptions_imply_better_generalization
    {Sample Hypothesis : Type*} [Fintype Sample] [Fintype Hypothesis]
    (J : JointLaw Sample Hypothesis) (length : Hypothesis → ℝ)
    (sampleSize : ℕ) (confidencePenalty gap shortLength longLength : ℝ)
    (hsample : 0 < sampleSize)
    (hcode : ∀ s h, informationDensity J s h ≤ length h)
    (hlength : ∀ h, length h ≤ shortLength)
    (hshort : shortLength ≤ longLength)
    (hPAC : gap ≤ generalizationRadius sampleSize
      (mutualInformation J + confidencePenalty)) :
    gap ≤ generalizationRadius sampleSize (longLength + confidencePenalty) := by
  -- First, transfer to expected description length bound with shortLength
  have h1 : gap ≤ generalizationRadius sampleSize (shortLength + confidencePenalty) :=
    generalization_from_max_description J length sampleSize confidencePenalty gap shortLength hsample hcode hlength hPAC
  -- Now use that shortLength ≤ longLength to get the final bound
  exact le_trans h1 (Real.sqrt_le_sqrt (div_le_div_of_nonneg_right (by linarith) (by positivity : (0 : ℝ) ≤ 2 * sampleSize)))

end PACBayesInformation