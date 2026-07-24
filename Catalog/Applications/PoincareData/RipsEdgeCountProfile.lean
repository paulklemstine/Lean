/-
  # Rips Edge-Count Profile

  This file completes the combinatorial content latent in the earlier Rips edge-count
  development by packaging the *edge-count profile* of the Vietoris–Rips 1-skeleton
  (`ripsGraph`) on a finite metric space.

  For a finite metric space `α`, the function

  `edgeCountProfile α : ℕ → ℕ`

  records, for each integer threshold `r`, the number of edges of `ripsGraph α (r : ℝ)`.
  We count edges via `SimpleGraph.edgeSet` together with `Set.ncard`, which carries no
  finiteness side conditions in its statements (the relevant finiteness is supplied on
  demand from `[Fintype α]`, since `Sym2 α` is then finite). This keeps the API smooth
  and free of `Fintype`/`Decidable` instance diamonds.

  ## Main results

  * `edgeCountProfile`            — the edge-count profile of the Rips graph.
  * `edgeCountProfile_le`         — monotonicity in the threshold: `r ≤ s → profile r ≤ profile s`.
  * `edgeCountProfile_mono`       — the order-theoretic packaging `Monotone (edgeCountProfile α)`.
  * `edgeCountProfile_zero`       — at threshold `0` the Rips graph has no edges.
  * `edgeCountProfile_le_card_sym2` — a uniform upper bound by `Fintype.card (Sym2 α)`.

  The monotonicity statement `edgeCountProfile_mono` is the clean order-theoretic
  replacement for the awkward "tropical monotonicity" packaging considered earlier.
-/
import Catalog.Applications.PoincareData.MetricFiltration

open Finset Set

noncomputable section

/-- The **edge-count profile** of a finite metric space `α`: for an integer threshold
    `r`, the number of edges of the Rips graph `ripsGraph α (r : ℝ)`.

    Edges are counted as the natural-number cardinality (`Set.ncard`) of the graph's
    `edgeSet ⊆ Sym2 α`. -/
noncomputable def edgeCountProfile (α : Type*) [Fintype α] [DecidableEq α] [MetricSpace α]
    (r : ℕ) : ℕ :=
  (ripsGraph α (r : ℝ)).edgeSet.ncard

/-- **Monotonicity of the edge count.** If `r ≤ s`, then the Rips graph at threshold `r`
    is a subgraph of the one at threshold `s` (by `ripsGraph_mono`), so it has no more
    edges. -/
theorem edgeCountProfile_le (α : Type*) [Fintype α] [DecidableEq α] [MetricSpace α]
    {r s : ℕ} (h : r ≤ s) :
    edgeCountProfile α r ≤ edgeCountProfile α s := by
  unfold edgeCountProfile
  exact Set.ncard_le_ncard
    (SimpleGraph.edgeSet_mono (ripsGraph_mono (by exact_mod_cast h))) (Set.toFinite _)

/-- The edge-count profile is monotone. This is the order-theoretic packaging of
    `edgeCountProfile_le`. -/
theorem edgeCountProfile_mono (α : Type*) [Fintype α] [DecidableEq α] [MetricSpace α] :
    Monotone (edgeCountProfile α) := fun _ _ h => edgeCountProfile_le α h

/-- **Zero-threshold lemma.** At threshold `0` the Rips graph on a metric space is empty
    (`ripsGraph_bot_of_metric`), hence has no edges. -/
theorem edgeCountProfile_zero (α : Type*) [Fintype α] [DecidableEq α] [MetricSpace α] :
    edgeCountProfile α 0 = 0 := by
  unfold edgeCountProfile
  rw [show ((0 : ℕ) : ℝ) = (0 : ℝ) by norm_num, ripsGraph_bot_of_metric]
  simp

/-- **Uniform upper bound.** The number of edges never exceeds the number of unordered
    pairs `Fintype.card (Sym2 α)`, since every edge lies in `Sym2 α`. -/
theorem edgeCountProfile_le_card_sym2 (α : Type*) [Fintype α] [DecidableEq α] [MetricSpace α]
    (r : ℕ) :
    edgeCountProfile α r ≤ Fintype.card (Sym2 α) := by
  unfold edgeCountProfile
  calc (ripsGraph α (r : ℝ)).edgeSet.ncard ≤ (Set.univ : Set (Sym2 α)).ncard :=
        Set.ncard_le_ncard (Set.subset_univ _) (Set.toFinite _)
    _ = Fintype.card (Sym2 α) := by rw [Set.ncard_univ]; exact Nat.card_eq_fintype_card

end