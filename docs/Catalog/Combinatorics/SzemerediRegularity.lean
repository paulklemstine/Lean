/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib.Combinatorics.SimpleGraph.Regularity.Lemma

/-! # Szemerédi's regularity lemma

The effective equitable-partition form: the upper bound on the number of parts
depends only on `ε` and the requested lower bound `l`, not on the graph.
-/

open Finpartition Finset Fintype
open SzemerediRegularity

namespace Catalog.Combinatorics.ExtremalGraphTheory

variable {α : Type*} [DecidableEq α] [Fintype α]

/-- **Szemerédi's regularity lemma.** Every finite graph with at least `l`
vertices admits an equitable `ε`-uniform partition into between `l` and
`bound ε l` parts. -/
theorem szemeredi_regularity_lemma (G : SimpleGraph α) [DecidableRel G.Adj]
    {ε : ℝ} {l : ℕ} (hε : 0 < ε) (hl : l ≤ card α) :
    ∃ P : Finpartition univ,
      P.IsEquipartition ∧ l ≤ #P.parts ∧ #P.parts ≤ bound ε l ∧
        P.IsUniform G ε := by
  exact szemeredi_regularity G hε hl

end Catalog.Combinatorics.ExtremalGraphTheory