import Mathlib

/-! # CatalogBuild.Speculative.SciFi.TemporalAndTimeTravel

Unified from TemporalLogic, TemporalLogic_2, TimeTravel, and TimeTravel_2.
Order-theoretic properties of time, fixed-point theorems, and contraction mapping.
-/}

noncomputable section

-- ---------------------------------------------------------------------------
-- Temporal logic and causal structure
-- ---------------------------------------------------------------------------

/-- Cycles in a partial order collapse to equality. -/
theorem partial_order_cycle {E : Type*} [PartialOrder E]
    {a b : E} (hab : a ≤ b) (hba : b ≤ a) : a = b :=
  le_antisymm hab hba

/-- Strict orders exclude backward causation. -/
theorem no_time_travel_strict_order {E : Type*} [PartialOrder E]
    {a b : E} (hab : a < b) : ¬(b ≤ a) := by
  intro h
  exact absurd (le_antisymm (le_of_lt hab) h) (ne_of_lt hab)

/-- No self-causation in a preorder. -/
theorem no_self_causation {α : Type*} [Preorder α] (a : α) :
    ¬ (a < a) := by
  by_contra h_contra
  have h_le : a ≤ a := le_rfl
  simp_all +decide [lt_iff_le_and_ne]

/-- Timelines are total orders. -/
theorem timeline_total {α : Type*} [LinearOrder α] (a b : α) :
    a ≤ b ∨ b ≤ a := by
  exact?

/-- The past of any event is linear (tree property). -/
theorem past_is_linear {α : Type*} [Preorder α]
    (h_tree : ∀ a b c : α, a ≤ c → b ≤ c → (a ≤ b ∨ b ≤ a))
    (c : α) (a b : α) (ha : a ≤ c) (hb : b ≤ c) :
    a ≤ b ∨ b ≤ a := by
  exact h_tree a b c ha hb

/-- Causality is transitive. -/
theorem causal_diamond_between {α : Type*} [PartialOrder α]
    (a b c : α) (h1 : a ≤ c) (h2 : c ≤ b) : a ≤ b := by
  exact le_trans h1 h2

/-- Two events are in "parallel timelines" if neither influences the other. -/
def parallel_timelines {α : Type*} [PartialOrder α] (a b : α) : Prop :=
  ¬(a ≤ b) ∧ ¬(b ≤ a)

theorem parallel_symmetric {α : Type*} [PartialOrder α] (a b : α) :
    parallel_timelines a b ↔ parallel_timelines b a := by
  exact ⟨fun h ↦ ⟨h.2, h.1⟩, fun h ↦ ⟨h.2, h.1⟩⟩

/-- Linear orders have no parallel timelines. -/
theorem no_parallel_in_linear_order {α : Type*} [LinearOrder α] (a b : α) :
    ¬ parallel_timelines a b := by
  exact fun h => h.1 (le_total a b |> Or.resolve_right <| h.2)

/-- The greatest lower bound of two past events exists in a complete lattice. -/
theorem past_glb_exists {T : Type*} [ConditionallyCompleteLattice T]
    (a b : T) (h : BddBelow ({a, b} : Set T)) :
    ∃ c, c ≤ a ∧ c ≤ b ∧ ∀ d, d ≤ a → d ≤ b → d ≤ c := by
  refine' ⟨InfSet.sInf {a, b}, _, _, _⟩
  · exact csInf_le h (Set.mem_insert _ _)
  · exact csInf_le h (Set.mem_insert_of_mem _ (Set.mem_singleton _))
  · exact fun d ha hb => le_csInf ⟨a, by simp +decide⟩ fun x hx => by aesop

/-- Preorders allow causal loops between equivalent events. -/
theorem preorder_allows_loops {E : Type*} [Preorder E]
    {a b : E} (hab : a ≤ b) (hba : b ≤ a) :
    a ≤ b ∧ b ≤ a :=
  ⟨hab, hba⟩

-- ---------------------------------------------------------------------------
-- Fixed-point theorems for time-travel consistency
-- ---------------------------------------------------------------------------

/-- Knaster–Tarski: monotone functions on complete lattices have a least fixed point. -/
theorem monotone_has_lfp {L : Type*} [CompleteLattice L] {f : L → L}
    (hf : Monotone f) : ∃ x, f x = x ∧ ∀ y, f y = y → x ≤ y := by
  refine' ⟨sInf {x | f x ≤ x}, _, _⟩
  · refine' le_antisymm _ _
    · exact le_sInf fun x hx => hf (sInf_le hx) |> le_trans <| hx
    · refine' sInf_le _
      refine' hf _
      exact le_sInf fun x hx => hf (sInf_le hx) |> le_trans <| hx
  · exact fun y hy => sInf_le hy.le

/-- Iteration stabilizes at a fixed point. -/
theorem iterate_at_fixed_point {X : Type*} (f : X → X)
    (x : X) (hx : f x = x) (n : ℕ) :
    f^[n] x = x := by
  exact Function.iterate_fixed hx n

/-- Self-consistency bootstrap: f(f(x)) = f(x) at a fixed point. -/
theorem bootstrap_self_consistent {X : Type*} (f : X → X)
    (x : X) (hfx : f x = x) :
    f (f x) = f x := by
  grind +suggestions

/-- Banach fixed-point theorem for contractions on complete metric spaces. -/
theorem contraction_has_fixedPoint {X : Type*} [MetricSpace X] [CompleteSpace X]
    [Nonempty X] {f : X → X} {q : ℝ} (hq : q ∈ Set.Ico (0 : ℝ) 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ q * dist x y) :
    ∃ x, f x = x := by
  have h_fixed_point : ∃ x, Filter.Tendsto (fun n => (f^[n]) (Classical.arbitrary X)) Filter.atTop (nhds x) := by
    refine' cauchySeq_tendsto_of_complete _
    fapply cauchySeq_of_le_geometric
    exacts [q, dist (Classical.arbitrary X) (f (Classical.arbitrary X)), hq.2,
      fun n => Nat.recOn n (by simp +decide) fun n ihn => by
        rw [Function.iterate_succ_apply', Function.iterate_succ_apply']
        exact le_trans (hf _ _) (by rw [pow_succ']; nlinarith [hq.1])]
  obtain ⟨x, hx⟩ := h_fixed_point
  use x
  refine' tendsto_nhds_unique _ hx
  rw [← Filter.tendsto_add_atTop_iff_nat 1]
  simpa only [Function.iterate_succ_apply'] using Filter.Tendsto.comp
    (show Filter.Tendsto f _ _ from by exact (Metric.tendsto_nhds_nhds.mpr fun ε hε =>
      by exact ⟨ε, hε, by intro y hy; exact lt_of_le_of_lt (hf _ _) (by nlinarith [hq.1, hq.2])⟩)) hx

/-- Contractions have unique fixed points. -/
theorem contraction_fixedPoint_unique {X : Type*} [MetricSpace X]
    {f : X → X} {q : ℝ} (hq : q < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ q * dist x y)
    {x₁ x₂ : X} (h₁ : f x₁ = x₁) (h₂ : f x₂ = x₂) : x₁ = x₂ := by
  contrapose! hf
  exact ⟨x₁, x₂, by simp [*]⟩

/-- Brouwer/IVT-style fixed point on a closed interval. -/
theorem interval_fixedPoint {f : ℝ → ℝ} {a b : ℝ} (hab : a ≤ b)
    (hf : ContinuousOn f (Set.Icc a b))
    (hfa : a ≤ f a) (hfb : f b ≤ b)
    (hmap : ∀ x ∈ Set.Icc a b, f x ∈ Set.Icc a b) :
    ∃ x ∈ Set.Icc a b, f x = x := by
  have h_ivt : ∃ c ∈ Set.Icc a b, (f c - c) = 0 := by
    apply_rules [intermediate_value_Icc']
    · exact hf.sub continuousOn_id
    · constructor <;> linarith
  simpa only [sub_eq_zero] using h_ivt

end
