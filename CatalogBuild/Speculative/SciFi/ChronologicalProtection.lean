/-! # CatalogBuild.Speculative.SciFi.ChronologicalProtection

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 1
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.ChronologicalProtection
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 1
Research Arc: Temporal Computation
Novelty: 0.95] -/
theorem chronological_protection_recurrence
    {X : Type*} [MeasurableSpace X]
    (μ : MeasureTheory.Measure X) [MeasureTheory.IsProbabilityMeasure μ]
    (f : X → X) (hf : MeasureTheory.MeasurePreserving f μ μ)
    (s : Set X) (hs : MeasurableSet s) (hμs : 0 < μ s) :
    ∀ᵐ x ∂μ, x ∈ s → ∃ᶠ n in Filter.atTop, f^[n] x ∈ s := by
  exact MeasureTheory.Conservative.ae_mem_imp_frequently_image_mem ( MeasureTheory.MeasurePreserving.conservative hf ) hs.nullMeasurableSet
