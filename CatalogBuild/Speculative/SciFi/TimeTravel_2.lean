/-! # CatalogBuild.Speculative.SciFi.TimeTravel_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

noncomputable section

theorem contraction_has_fixedPoint {X : Type*} [MetricSpace X] [CompleteSpace X]
    [Nonempty X] {f : X → X} {q : ℝ} (hq : q ∈ Set.Ico (0 : ℝ) 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ q * dist x y) :
    ∃ x, f x = x := by
  -- By the properties of the contraction mapping, there exists a fixed point $x$ such that $f(x) = x$.
  have h_fixed_point : ∃ x, Filter.Tendsto (fun n => (f^[n]) (Classical.arbitrary X)) Filter.atTop (nhds x) := by
    refine' cauchySeq_tendsto_of_complete _;
    fapply cauchySeq_of_le_geometric;
    exacts [ q, dist ( Classical.arbitrary X ) ( f ( Classical.arbitrary X ) ), hq.2, fun n => Nat.recOn n ( by simp +decide ) fun n ihn => by rw [ Function.iterate_succ_apply', Function.iterate_succ_apply' ] ; exact le_trans ( hf _ _ ) ( by rw [ pow_succ' ] ; nlinarith [ hq.1 ] ) ];
  obtain ⟨ x, hx ⟩ := h_fixed_point;
  use x;
  refine' tendsto_nhds_unique _ hx;
  rw [ ← Filter.tendsto_add_atTop_iff_nat 1 ];
  simpa only [ Function.iterate_succ_apply' ] using Filter.Tendsto.comp ( show Filter.Tendsto f _ _ from by exact ( Metric.tendsto_nhds_nhds.mpr fun ε hε => by exact ⟨ ε, hε, by intro y hy; exact lt_of_le_of_lt ( hf _ _ ) ( by nlinarith [ hq.1, hq.2 ] ) ⟩ ) ) hx

/-
Uniqueness of fixed points for contraction mappings.
-/

theorem contraction_fixedPoint_unique {X : Type*} [MetricSpace X]
    {f : X → X} {q : ℝ} (hq : q < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ q * dist x y)
    {x₁ x₂ : X} (h₁ : f x₁ = x₁) (h₂ : f x₂ = x₂) : x₁ = x₂ := by
  contrapose! hf;
  exact ⟨ x₁, x₂, by simp [ * ] ⟩

/-! ## Knaster-Tarski: Monotone functions on complete lattices have fixed points -/

/-
Monotone endomorphisms on complete lattices have a least fixed point.
-/

theorem monotone_has_lfp {L : Type*} [CompleteLattice L] {f : L → L}
    (hf : Monotone f) : ∃ x, f x = x ∧ ∀ y, f y = y → x ≤ y := by
  refine' ⟨ sInf { x | f x ≤ x }, _, _ ⟩;
  · refine' le_antisymm _ _;
    · exact le_sInf fun x hx => hf ( sInf_le hx ) |> le_trans <| hx;
    · refine' sInf_le _;
      refine' hf _;
      exact le_sInf fun x hx => hf ( sInf_le hx ) |> le_trans <| hx;
  · exact fun y hy => sInf_le hy.le

/-! ## Brouwer-style: continuous self-maps of compact convex sets have fixed points

  This guarantees that if the space of possible universe-states is "ball-like"
  (compact and convex) and the evolution is continuous, then at least one
  self-consistent timeline exists. -/

/-
Every continuous self-map of a nonempty compact convex subset of ℝ has a fixed point
    (one-dimensional Brouwer / intermediate value theorem).
-/

theorem interval_fixedPoint {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Set.Icc a b))
    (hfa : a ≤ f a) (hfb : f b ≤ b)
    (hmap : ∀ x ∈ Set.Icc a b, f x ∈ Set.Icc a b) :
    ∃ x ∈ Set.Icc a b, f x = x := by
  -- Apply the intermediate value theorem to the continuous function $g(x) = f(x) - x$ on the interval $[a, b]$.
  have h_ivt : ∃ c ∈ Set.Icc a b, (f c - c) = 0 := by
    apply_rules [ intermediate_value_Icc' ];
    · exact hf.sub continuousOn_id;
    · constructor <;> linarith;
  simpa only [ sub_eq_zero ] using h_ivt


end
