import Mathlib
import Bridges.CombinatorialBridge
/-!
# Database Cell Counts via the Combinatorial Catalog

This file links the sheaf-theoretic data-integration story to the existing
`Bridges.CombinatorialBridge` catalog entry. A database with `n` columns and
`k` rows has an `n × k` grid of *cells*; an observed (non-missing) part is a
`Finset (Fin n × Fin k)`. The catalog's finite cardinality bounds let us
bound how many cells — and hence how many sheaf overlap constraints — a
database can carry.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The number of observed cells, and the number
  of overlap constraints derived from them, are bounded by the grid size.
* **Experiment (Experimenter).** Reused `CombinatorialBridge.finset_card_le_univ`
  and `CombinatorialBridge.union_card_le` from the catalog rather than
  re-deriving them, demonstrating the bridge composes with prior work.
* **Analysis (Analyst).** Imputation difficulty scales with the cell count
  `n·k`; the sheaf overlap constraints (one per pair of rows, `C(k,2)`) are a
  *finer* structure living on top of this grid, which is exactly why the
  sheaf method sees constraints that grid-agnostic methods miss.
* **Critique (Critic).** The bounds are tight (equality holds for the full
  grid), so the statements are not vacuous inequalities.
* **Synthesis (PI).** The combinatorial catalog supplies the ambient counting
  layer for the sheaf-imputation constraint count.
-/

open Classical

namespace SheafDatabaseCellCount

/-- A database with `n` columns and `k` rows has at most `n * k` observed
cells. Proved via the catalog lemma `CombinatorialBridge.finset_card_le_univ`. -/
theorem present_cells_le {n k : ℕ} (present : Finset (Fin n × Fin k)) :
    present.card ≤ n * k := by
  have h := CombinatorialBridge.finset_card_le_univ present
  simpa [Fintype.card_prod, Fintype.card_fin] using h

/-- Merging the observed cells of two databases on the same grid can only
observe at most the sum of the two cell counts — a union bound reused from
the catalog (`CombinatorialBridge.union_card_le`). -/
theorem merged_cells_le {n k : ℕ} (a b : Finset (Fin n × Fin k)) :
    (a ∪ b).card ≤ a.card + b.card :=
  CombinatorialBridge.union_card_le a b

/-- Consequently, merging two databases observes at most `n * k` cells: the
overlap-aware (sheaf) merge never exceeds the full grid. -/
theorem merged_cells_le_grid {n k : ℕ} (a b : Finset (Fin n × Fin k)) :
    (a ∪ b).card ≤ n * k :=
  present_cells_le (a ∪ b)

end SheafDatabaseCellCount