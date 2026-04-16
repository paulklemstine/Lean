/-! # CatalogBuild.Speculative.IdempotentCollapse.OptimalCollapse

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 4
-/

import Mathlib

noncomputable section

/-- Total displacement caused by a map on a finite metric space. -/
def collapseDisplacement {α : Type*} [Fintype α] [PseudoMetricSpace α] (f : α → α) : ℝ :=
  ∑ x : α, dist x (f x)



/-- [Section: # CatalogBuild.Speculative.IdempotentCollapse.OptimalCollapse
Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 4] -/
theorem zero_displacement_is_id {α : Type*} [Fintype α] [MetricSpace α]
    (f : α → α) (hf : ∀ x, f (f x) = f x)
    (hd : collapseDisplacement f = 0) : ∀ x, f x = x := by
      -- Since the sum of non-negative terms is zero, each term must be zero.
      have h_zero : ∀ x, dist x (f x) = 0 := by
        rw [ eq_comm, collapseDisplacement ] at hd;
        exact fun x => hd.symm ▸ Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => dist_nonneg ) |>.1 rfl x ( Finset.mem_univ x );
      exact fun x => dist_eq_zero.mp ( h_zero x ) ▸ rfl



theorem collapse_transport_bound {α : Type*} [Fintype α] [PseudoMetricSpace α]
    [BoundedSpace α] (f : α → α) :
    collapseDisplacement f ≤
    (Fintype.card α : ℝ) * Metric.diam (Set.univ : Set α) := by
      -- Each term in the sum is a distance, and by the definition of diameter, each distance is less than or equal to the diameter.
      have h_dist_le_diam : ∀ x : α, dist x (f x) ≤ ENNReal.toReal ( EMetric.diam ( Set.univ : Set α ) ) := by
        intro x;
        refine' le_trans _ ( ENNReal.toReal_mono _ <| Metric.edist_le_ediam_of_mem ( Set.mem_univ x ) ( Set.mem_univ ( f x ) ) );
        · rw [ edist_dist ];
          rw [ ENNReal.toReal_ofReal ( dist_nonneg ) ];
        · simp +decide [ EMetric.diam ];
          simp +decide [ ediam ];
          rw [ iSup_eq_top ];
          simp +decide [ edist_dist ];
          exact ⟨ ENNReal.ofReal ( SupSet.sSup ( Set.range fun p : α × α => dist p.1 p.2 ) ), ENNReal.ofReal_lt_top, fun x y => ENNReal.ofReal_le_ofReal ( le_csSup ( Set.finite_range _ |> Set.Finite.bddAbove ) ( Set.mem_range_self ( x, y ) ) ) ⟩;
      convert Finset.sum_le_sum fun x _ => h_dist_le_diam x using 1 ; simp +decide [ collapseDisplacement ];
      exact Or.inl rfl



/-- Composing with any map can only shrink the range. -/
theorem idempotent_range_inclusion {α : Type*} (f g : α → α) :
    range (f ∘ g) ⊆ range f := by
  intro x ⟨y, hy⟩; exact ⟨g y, hy⟩



end
