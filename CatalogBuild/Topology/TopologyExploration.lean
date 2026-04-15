/-! # CatalogBuild.Topology.TopologyExploration

Auto-generated from theorem catalog database.
Domain: Topology
Declarations: 8
-/

import Mathlib

/-- [Section: ## §1: Metric Space Fundamentals] -/
theorem discrete_metric_triangle (α : Type*) [DecidableEq α] (x y z : α) :
    (if x = z then (0 : ℝ) else 1) ≤
    (if x = y then 0 else 1) + (if y = z then 0 else 1) := by
  grind +ring


/-- [Section: ## §2: Compactness] -/
theorem closed_subset_compact' {α : Type*} [TopologicalSpace α]
    {K S : Set α} (hK : IsCompact K) (hS : IsClosed S) (hSK : S ⊆ K) :
    IsCompact S := by
  exact?


/-- ℝ is connected. -/
theorem Icc_connected' (a b : ℝ) (h : a ≤ b) : IsConnected (Set.Icc a b) := by
  apply_rules [ isConnected_Icc ]


/-- [Section: ## §3: Connectedness] -/
theorem connected_image' {α β : Type*} [TopologicalSpace α] [TopologicalSpace β]
    {f : α → β} {S : Set α} (hf : Continuous f) (hS : IsConnected S) :
    IsConnected (f '' S) := by
  exact hS.image _ hf.continuousOn


/-- [Section: ## §5: Topological Properties of Number-Theoretic Sets] -/
theorem integers_closed' : IsClosed (Set.range (Int.cast : ℤ → ℝ)) := by
  refine' isClosed_of_closure_subset fun x hx => _;
  rw [ mem_closure_iff_seq_limit ] at hx;
  obtain ⟨ y, hy, hy' ⟩ := hx;
  choose f hf using hy;
  -- Since $f$ is a sequence of integers, it must be eventually constant.
  have h_const : ∃ m : ℤ, ∀ᶠ n in atTop, f n = m := by
    have h_const : CauchySeq f := by
      have h_const : CauchySeq (fun n => (f n : ℝ)) := by
        simpa only [ hf ] using hy'.cauchy_map;
      rw [ Metric.cauchySeq_iff ] at *;
      convert h_const using 1;
    rw [ Metric.cauchySeq_iff ] at h_const;
    obtain ⟨ N, hN ⟩ := h_const 1 zero_lt_one;
    exact ⟨ f N, Filter.eventually_atTop.mpr ⟨ N, fun n hn => by simpa [ sub_eq_iff_eq_add ] using Int.le_antisymm ( Int.le_of_lt_add_one <| by rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith [ abs_lt.mp <| hN n hn N le_rfl ] ) ( Int.le_of_lt_add_one <| by rw [ ← @Int.cast_lt ℝ ] ; push_cast; linarith [ abs_lt.mp <| hN n hn N le_rfl ] ) ⟩ ⟩;
  simp +zetaDelta at *;
  exact ⟨ h_const.choose, tendsto_nhds_unique ( by rw [ Filter.tendsto_congr' ( Filter.eventuallyEq_of_mem ( Filter.Ici_mem_atTop h_const.choose_spec.choose ) fun n hn => by rw [ ← hf, h_const.choose_spec.choose_spec n hn ] ) ] ; exact tendsto_const_nhds ) hy' ⟩


theorem rationals_dense' : Dense (Set.range (Rat.cast : ℚ → ℝ)) := by
  convert Rat.denseRange_cast using 1;
  all_goals infer_instance


/-- Product of compact spaces is compact (Tychonoff for finite products). -/
theorem product_compact' {α β : Type*} [TopologicalSpace α] [TopologicalSpace β]
    [CompactSpace α] [CompactSpace β] : CompactSpace (α × β) := inferInstance


/-- [Section: ## §7: Cantor's Theorem] -/
theorem cantor_diagonal' {α : Type*} (f : α → Set α) : ¬ Function.Surjective f := by
  by_contra! h_surj;
  -- By Cantor's theorem, there exists a subset $S$ of $\alpha$ that is not in the range of $f$.
  obtain ⟨S, hS⟩ : ∃ S : Set α, S ∉ Set.range f := by
    exact ⟨ { x | ¬x ∈ f x }, fun ⟨ y, hy ⟩ => by have := congr_arg ( fun s => y ∈ s ) hy; simp +decide at this ⟩
  generalize_proofs at *; (
  exact hS ( h_surj S ))
