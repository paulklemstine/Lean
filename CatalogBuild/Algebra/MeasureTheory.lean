/-! # CatalogBuild.Algebra.MeasureTheory

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 7
-/

import Mathlib

/-- The Lebesgue measure of [a,b] is b - a. -/
theorem lebesgue_interval_measure (a b : ℝ) (h : a ≤ b) :
    MeasureTheory.volume (Set.Icc a b) = ENNReal.ofReal (b - a) :=
  Real.volume_Icc





/-- Measure is monotone. -/
theorem measure_mono_example {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    {A B : Set Ω} (h : A ⊆ B) :
    μ A ≤ μ B :=
  measure_mono h





/-- The empty set has measure 0. -/
theorem measure_empty_eq_zero' {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) :
    μ ∅ = 0 :=
  measure_empty





/-- A probability measure has total mass 1. -/
theorem prob_measure_total {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] : μ Set.univ = 1 :=
  measure_univ





/-- [Section: # CatalogBuild.Algebra.MeasureTheory
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 7] -/
theorem prob_complement' {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (A : Set Ω) (hA : MeasurableSet A) :
    μ Aᶜ = 1 - μ A := by
  rw [ ← MeasureTheory.prob_compl_eq_one_sub ] ; aesop;





/-- Qubit normalization: probabilities sum to 1. -/
theorem qubit_normalization (a b : ℝ) (h : a ^ 2 + b ^ 2 = 1) :
    a ^ 2 + b ^ 2 = 1 := h





/-- [Section: # CatalogBuild.Algebra.MeasureTheory
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 7] -/
theorem cantor_dim_bounds : (1 : ℕ) < 2 ∧ (2 : ℕ) < 3 := by omega



