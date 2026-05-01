import Mathlib

/-! # CatalogBuild.Algebra.Topology

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 8
-/


/-- [Section: # CatalogBuild.Algebra.Topology
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 8] -/
theorem unit_interval_compact : IsCompact (Set.Icc (0 : ℝ) 1) := by
  exact CompactIccSpace.isCompact_Icc




/-- [Section: # CatalogBuild.Algebra.Topology
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 8] -/
theorem compact_image_continuous {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    {f : X → Y} {K : Set X} (hK : IsCompact K) (hf : Continuous f) :
    IsCompact (f '' K) := by
      exact hK.image hf




theorem compact_attains_max {X : Type*} [TopologicalSpace X]
    {K : Set X} (hK : IsCompact K) (hne : K.Nonempty)
    {f : X → ℝ} (hf : ContinuousOn f K) :
    ∃ x ∈ K, ∀ y ∈ K, f y ≤ f x := by
      convert hK.exists_isMaxOn hne hf




theorem ivt {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Set.Icc a b))
    {v : ℝ} (hva : f a ≤ v) (hvb : v ≤ f b) :
    ∃ c ∈ Set.Icc a b, f c = v := by
      apply_rules [ intermediate_value_Icc ];
      aesop




theorem real_connected : ConnectedSpace ℝ := by
  infer_instance




theorem brouwer_1d (f : ℝ → ℝ) (hf : ContinuousOn f (Set.Icc 0 1))
    (hf_range : ∀ x ∈ Set.Icc (0:ℝ) 1, f x ∈ Set.Icc (0:ℝ) 1) :
    ∃ x ∈ Set.Icc (0:ℝ) 1, f x = x := by
      by_contra! h_contra;
      -- Define $g(x) = f(x) - x$.
      set g : ℝ → ℝ := fun x => f x - x;
      -- By the properties of the intermediate value theorem, since $g(0) = f(0) - 0 \geq 0$ and $g(1) = f(1) - 1 \leq 0$, there exists some $c \in [0, 1]$ such that $g(c) = 0$, i.e., $f(c) = c$.
      have h_ivt : ∃ c ∈ Set.Icc 0 1, g c = 0 := by
        apply_rules [ intermediate_value_Icc' ] <;> norm_num [ * ];
        · exact hf.sub continuousOn_id;
        · exact ⟨ sub_nonpos_of_le <| hf_range 1 ( by norm_num ) |>.2, sub_nonneg_of_le <| hf_range 0 ( by norm_num ) |>.1 ⟩;
      exact h_contra _ h_ivt.choose_spec.1 <| sub_eq_zero.mp h_ivt.choose_spec.2




theorem compact_metric_complete {X : Type*} [MetricSpace X] [CompactSpace X] :
    CompleteSpace X := by
      exact?




theorem compact_metric_totally_bounded {X : Type*} [MetricSpace X] [CompactSpace X] :
    TotallyBounded (Set.univ : Set X) := by
      exact isCompact_univ.totallyBounded


