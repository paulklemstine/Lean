/-! # CatalogBuild.Bridges.TopologicalRobustnessBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 8
-/

import Mathlib

/-- A continuous function on a nonempty compact set attains its supremum.
In robustness terms: the worst-case perturbation exists. -/
theorem compact_attains_sup {X : Type*} [MetricSpace X]
    {s : Set X} (hs : IsCompact s) (hne : s.Nonempty)
    {f : X → ℝ} (hf : ContinuousOn f s) :
    ∃ x ∈ s, ∀ y ∈ s, f y ≤ f x :=
  hs.exists_isMaxOn hne hf


/-- A continuous function on a nonempty compact set attains its infimum.
In robustness terms: the best-case output exists. -/
theorem compact_attains_inf {X : Type*} [MetricSpace X]
    {s : Set X} (hs : IsCompact s) (hne : s.Nonempty)
    {f : X → ℝ} (hf : ContinuousOn f s) :
    ∃ x ∈ s, ∀ y ∈ s, f x ≤ f y :=
  hs.exists_isMinOn hne hf


/-- A continuous function on a compact set is bounded above.
In robustness terms: worst-case norm is finite. -/
theorem compact_bounded_above {X : Type*} [MetricSpace X]
    {s : Set X} (hs : IsCompact s) (hne : s.Nonempty)
    {f : X → ℝ} (hf : ContinuousOn f s) :
    ∃ M, ∀ x ∈ s, f x ≤ M := by
  obtain ⟨x, _, hmax⟩ := hs.exists_isMaxOn hne hf
  exact ⟨f x, hmax⟩


/-- A continuous function on a compact set is bounded below. -/
theorem compact_bounded_below {X : Type*} [MetricSpace X]
    {s : Set X} (hs : IsCompact s) (hne : s.Nonempty)
    {f : X → ℝ} (hf : ContinuousOn f s) :
    ∃ m, ∀ x ∈ s, m ≤ f x := by
  obtain ⟨x, _, hmin⟩ := hs.exists_isMinOn hne hf
  exact ⟨f x, hmin⟩


/-- Closed balls in ℝ are compact (perturbation neighborhoods are compact).
This justifies worst-case analysis over closed ball perturbations. -/
theorem closedBall_compact_real (x : ℝ) (r : ℝ) :
    IsCompact (Metric.closedBall x r) :=
  isCompact_closedBall x r


/-- Closed intervals [a, b] are compact in ℝ. -/
theorem Icc_compact_real (a b : ℝ) :
    IsCompact (Set.Icc a b) :=
  isCompact_Icc


/-- The norm of a continuous function on a compact set is bounded.
‖f(x)‖ ≤ M for all x ∈ K compact.
Fundamental for certified robustness: classifier output is bounded
on any compact input set. -/
theorem norm_bounded_on_compact {X : Type*} [MetricSpace X]
    {s : Set X} (hs : IsCompact s) (hne : s.Nonempty)
    {E : Type*} [SeminormedAddGroup E]
    {f : X → E} (hf : Continuous f) :
    ∃ M, ∀ x ∈ s, ‖f x‖ ≤ M := by
  have h_cont : ContinuousOn (fun x => ‖f x‖) s :=
    Continuous.continuousOn (Continuous.norm hf)
  obtain ⟨x, _, hmax⟩ := hs.exists_isMaxOn hne h_cont
  exact ⟨‖f x‖, hmax⟩


/-- A Lipschitz function on a compact set is bounded.
If f is K-Lipschitz and K is compact, then |f(x)| ≤ M for some M.
Connects Lipschitz continuity (ResNet) to compact worst-case analysis. -/
theorem lipschitz_bounded {X : Type*} [MetricSpace X]
    {s : Set X} (hs : IsCompact s) (hne : s.Nonempty)
    {K : NNReal} {f : X → ℝ} (hf : LipschitzWith K f) :
    ∃ M, ∀ x ∈ s, |f x| ≤ M := by
  -- |f| is continuous when f is continuous
  have h_abs : ContinuousOn (fun x => |f x|) s :=
    (LipschitzWith.continuous hf).abs.continuousOn
  obtain ⟨x, _, hmax⟩ := hs.exists_isMaxOn hne h_abs
  exact ⟨|f x|, hmax⟩

