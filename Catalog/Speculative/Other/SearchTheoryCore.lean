/-! # CatalogBuild.Speculative.Other.SearchTheoryCore

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 5
-/

import Mathlib

noncomputable section

/-- The cumulative searched region up to time n. -/
def SearchStrategy.cumulative {α : Type*} [MeasurableSpace α]
    (s : SearchStrategy α) (n : ℕ) : Set α :=
  ⋃ i ∈ Finset.range (n + 1), s.region i



/-- A search strategy covers the space if eventually everything is searched. -/
def SearchStrategy.isCovering {α : Type*} [MeasurableSpace α]
    (s : SearchStrategy α) : Prop :=
  ∀ x : α, ∃ n : ℕ, x ∈ s.region n



/-- The cumulative region is monotonically increasing. -/
theorem SearchStrategy.cumulative_mono {α : Type*} [MeasurableSpace α]
    (s : SearchStrategy α) : Monotone s.cumulative := by
  intro m n hmn x hx
  simp only [cumulative, Set.mem_iUnion, Finset.mem_range] at hx ⊢
  obtain ⟨i, hi, hxi⟩ := hx
  exact ⟨i, by omega, hxi⟩



/-- A covering strategy has union equal to univ. -/
theorem SearchStrategy.covering_iff_union_univ {α : Type*} [MeasurableSpace α]
    (s : SearchStrategy α) :
    s.isCovering ↔ (⋃ n, s.region n) = Set.univ := by
  constructor
  · intro h; ext x; simp only [Set.mem_iUnion, Set.mem_univ, iff_true]; exact h x
  · intro h x
    have : x ∈ ⋃ n, s.region n := by rw [h]; exact Set.mem_univ x
    exact Set.mem_iUnion.mp this



/-- Detection probability is monotonically increasing in time. -/
theorem detectionProbability_mono {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (s : SearchStrategy α) :
    Monotone (fun n => μ (s.cumulative n)) := by
  intro m n hmn
  exact measure_mono (s.cumulative_mono hmn)



end
