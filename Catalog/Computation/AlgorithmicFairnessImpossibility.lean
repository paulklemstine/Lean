import Mathlib

/-!
# Calibration versus equalized odds

An algebraic formalization of the Chouldechova impossibility theorem.  A binary
classifier in a group is summarized by its prevalence, true-positive rate, and
false-positive rate.  Calibration is stated without division, so the definitions
also behave correctly when a predicted class has probability zero.
-/

namespace AlgorithmicFairness

/-- Population-level rates for a binary classifier on one group. -/
structure GroupRates where
  prevalence : ℝ
  truePositiveRate : ℝ
  falsePositiveRate : ℝ

/-- All rates have their probabilistic ranges. -/
def GroupRates.Valid (g : GroupRates) : Prop :=
  g.prevalence ∈ Set.Icc (0 : ℝ) 1 ∧
  g.truePositiveRate ∈ Set.Icc (0 : ℝ) 1 ∧
  g.falsePositiveRate ∈ Set.Icc (0 : ℝ) 1

/-- Probability of a positive prediction. -/
def GroupRates.positivePredictionRate (g : GroupRates) : ℝ :=
  g.prevalence * g.truePositiveRate +
    (1 - g.prevalence) * g.falsePositiveRate

/-- Probability of a negative prediction. -/
def GroupRates.negativePredictionRate (g : GroupRates) : ℝ :=
  (1 - g.prevalence) * (1 - g.falsePositiveRate) +
    g.prevalence * (1 - g.truePositiveRate)

/-- Positive calibration (predictive parity), expressed by cross multiplication. -/
def PositivelyCalibrated (g : GroupRates) (positiveValue : ℝ) : Prop :=
  g.prevalence * g.truePositiveRate =
    positiveValue * g.positivePredictionRate

/-- Negative calibration, the analogous condition among negative predictions. -/
def NegativelyCalibrated (g : GroupRates) (negativeValue : ℝ) : Prop :=
  (1 - g.prevalence) * (1 - g.falsePositiveRate) =
    negativeValue * g.negativePredictionRate

/-- Equalized odds says both conditional error profiles agree across groups. -/
def EqualizedOdds (a b : GroupRates) : Prop :=
  a.truePositiveRate = b.truePositiveRate ∧
  a.falsePositiveRate = b.falsePositiveRate

/-- Equal calibration uses common positive and negative predictive values. -/
def EquallyCalibrated (a b : GroupRates) : Prop :=
  ∃ positiveValue negativeValue : ℝ,
    PositivelyCalibrated a positiveValue ∧
    PositivelyCalibrated b positiveValue ∧
    NegativelyCalibrated a negativeValue ∧
    NegativelyCalibrated b negativeValue

/-- Positive calibration in two groups gives the key product identity. -/
lemma positive_calibration_product_identity
    (p₁ p₂ t f c : ℝ)
    (h₁ : p₁ * t = c * (p₁ * t + (1 - p₁) * f))
    (h₂ : p₂ * t = c * (p₂ * t + (1 - p₂) * f)) :
    c * f * (p₁ - p₂) = 0 := by
  linear_combination p₂ * h₁ - p₁ * h₂

/-- Negative calibration in two groups gives the dual product identity. -/
lemma negative_calibration_product_identity
    (p₁ p₂ t f c : ℝ)
    (h₁ : (1 - p₁) * (1 - f) =
      c * ((1 - p₁) * (1 - f) + p₁ * (1 - t)))
    (h₂ : (1 - p₂) * (1 - f) =
      c * ((1 - p₂) * (1 - f) + p₂ * (1 - t))) :
    c * (1 - t) * (p₁ - p₂) = 0 := by
  linear_combination (1 - p₁) * h₂ - (1 - p₂) * h₁

/-- A common nonzero positive predictive value, together with equalized odds
and unequal base rates, rules out false positives. -/
theorem equalizedOdds_calibration_forces_zero_fpr
    (a b : GroupRates)
    (hBase : a.prevalence ≠ b.prevalence)
    (hEO : EqualizedOdds a b)
    (c : ℝ) (hc : c ≠ 0)
    (ha : PositivelyCalibrated a c)
    (hb : PositivelyCalibrated b c) :
    a.falsePositiveRate = 0 ∧ b.falsePositiveRate = 0 := by
  obtain ⟨ht_eq, hf_eq⟩ := hEO
  unfold PositivelyCalibrated at ha hb
  unfold GroupRates.positivePredictionRate at ha hb
  rw [ht_eq, hf_eq] at ha
  have hprod := positive_calibration_product_identity
    a.prevalence b.prevalence b.truePositiveRate b.falsePositiveRate c ha hb
  have hdiff : a.prevalence - b.prevalence ≠ 0 := sub_ne_zero_of_ne hBase
  have hf_zero : b.falsePositiveRate = 0 := by
    have hmul := mul_eq_zero.mp hprod
    rcases hmul with hcb | hdiff'
    · rcases mul_eq_zero.mp hcb with hc' | hf''
      · exact absurd hc' hc
      · exact hf''
    · exact absurd hdiff' hdiff
  exact ⟨hf_eq.trans hf_zero, hf_zero⟩

/-- The dual calibration condition rules out false negatives. -/
theorem equalizedOdds_negativeCalibration_forces_full_tpr
    (a b : GroupRates)
    (hBase : a.prevalence ≠ b.prevalence)
    (hEO : EqualizedOdds a b)
    (c : ℝ) (hc : c ≠ 0)
    (ha : NegativelyCalibrated a c)
    (hb : NegativelyCalibrated b c) :
    a.truePositiveRate = 1 ∧ b.truePositiveRate = 1 := by
  obtain ⟨ht_eq, hf_eq⟩ := hEO
  unfold NegativelyCalibrated at ha hb
  unfold GroupRates.negativePredictionRate at ha hb
  rw [ht_eq, hf_eq] at ha
  have hprod := negative_calibration_product_identity
    a.prevalence b.prevalence b.truePositiveRate b.falsePositiveRate c ha hb
  have hdiff : a.prevalence - b.prevalence ≠ 0 := sub_ne_zero_of_ne hBase
  have ht_one : b.truePositiveRate = 1 := by
    rcases mul_eq_zero.mp hprod with hct | hdiff'
    · rcases mul_eq_zero.mp hct with hc' | ht'
      · exact absurd hc' hc
      · linarith
    · exact absurd hdiff' hdiff
  exact ⟨ht_eq.trans ht_one, ht_one⟩

/-- **Chouldechova's impossibility theorem.**  For groups with different base
rates, a nondegenerate classifier satisfying equalized odds and equal positive
and negative calibration must be perfect: its FPR is zero and its TPR is one in
both groups.  Thus, unless prediction is perfect, the fairness requirements are
incompatible. -/
theorem chouldechova_impossibility
    (a b : GroupRates)
    (hBase : a.prevalence ≠ b.prevalence)
    (hEO : EqualizedOdds a b)
    (hCal : EquallyCalibrated a b)
    (hPositiveValue : ∀ c, PositivelyCalibrated a c →
      PositivelyCalibrated b c → c ≠ 0)
    (hNegativeValue : ∀ c, NegativelyCalibrated a c →
      NegativelyCalibrated b c → c ≠ 0) :
    a.falsePositiveRate = 0 ∧ b.falsePositiveRate = 0 ∧
      a.truePositiveRate = 1 ∧ b.truePositiveRate = 1 := by
  obtain ⟨positiveValue, negativeValue, haPos, hbPos, haNeg, hbNeg⟩ := hCal
  have hFpr := equalizedOdds_calibration_forces_zero_fpr a b hBase hEO
    positiveValue (hPositiveValue positiveValue haPos hbPos) haPos hbPos
  have hTpr := equalizedOdds_negativeCalibration_forces_full_tpr a b hBase hEO
    negativeValue (hNegativeValue negativeValue haNeg hbNeg) haNeg hbNeg
  exact ⟨hFpr.1, hFpr.2, hTpr.1, hTpr.2⟩

/-- Contrapositive form: a nonperfect, nondegenerate classifier cannot satisfy
both equalized odds and equal calibration when base rates differ. -/
theorem calibration_and_equalizedOdds_incompatible
    (a b : GroupRates)
    (hBase : a.prevalence ≠ b.prevalence)
    (hCal : EquallyCalibrated a b)
    (hPositiveValue : ∀ c, PositivelyCalibrated a c →
      PositivelyCalibrated b c → c ≠ 0)
    (hNegativeValue : ∀ c, NegativelyCalibrated a c →
      NegativelyCalibrated b c → c ≠ 0)
    (hImperfect : a.falsePositiveRate ≠ 0 ∨ a.truePositiveRate ≠ 1) :
    ¬ EqualizedOdds a b := by
  intro hEO
  have hPerfect := chouldechova_impossibility a b hBase hEO hCal
    hPositiveValue hNegativeValue
  exact hImperfect.elim (fun h => h hPerfect.1) (fun h => h hPerfect.2.2.1)

end AlgorithmicFairness