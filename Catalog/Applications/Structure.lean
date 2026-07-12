import Novelty.TotalRainbowForest.Defs

/-!
# Structure of minimal obstructions to total rainbow forests

Main result: every **minimal obstruction** is a **single monochromatic cycle**
(with isolated vertices allowed).  This is the corrected form of the conjecture
"every minimal edge-colored graph that does not admit a total rainbow forest is a
single monochromatic cycle": the correct invariant being obstructed is
*acyclicity of every colour class*, equivalently the absence of a monochromatic
cycle.

-- !-- Lab Notes -- !--
Analysis (Analyst):
  The proof turns entirely on a robustness principle for cycles under edge
  deletion.  Take a monochromatic cycle `c` of colour `k`.  If `G` had an edge
  `e ∈ G.edgeSet` NOT lying on `c`, then `c` survives verbatim inside
  `G.deleteEdges {e}` (all of `c`'s edges are `≠ e`, so `Walk.transfer` carries
  the cycle across and `Walk.IsCycle.transfer` keeps it a cycle; monochromaticity
  is preserved because the edge multiset is unchanged).  That would exhibit a
  monochromatic cycle after deleting `e`, contradicting minimality.  Hence every
  edge of `G` lies on `c`, i.e. `G.edgeSet = c.edges`, and monochromaticity of
  the whole graph follows from that of `c`.

  Why the naive "rainbow spanning forest" reading fails (see H2 in Defs.lean):
  there, deleting an edge can help by *lowering the matroid rank* (disconnecting
  the graph), so monochromatic paths are also minimal obstructions.  Passing to
  the colour-class-acyclicity invariant removes that loophole because forests are
  automatically obstruction-free, so deletions only ever help by breaking a cycle.

Critique (Critic):
  * Not vacuous / not `True`: the hypothesis `MinObstruction` is inhabited — a
    monochromatic `C_n` (n ≥ 3) is one (verified by hand, ComputationalEvidence).
  * No `native_decide`/`decide`-only proof: the argument uses `by_contra`,
    `Walk.transfer`, and `Walk.IsCycle.transfer` on an arbitrary vertex type `V`
    and colour type `κ` (no finiteness/decidability assumed).
  * Corner cases: `c.IsCycle` guarantees `c.edges` is nonempty and repetition-free,
    so `MonoWalk` via `∃ k` is genuinely "all edges equal"; isolated vertices are
    permitted because only `edgeSet` is constrained.

Synthesis (PI):
  Minimal obstructions to total rainbow forests are exactly the monochromatic
  cycles (necessity here; the monochromatic `C_n` witnesses realisability).  The
  clean statement requires the *colour-class-acyclic* invariant rather than the
  literal "rainbow spanning forest" one.
-/

namespace Catalog.Novelty.TotalRainbowForest

open SimpleGraph

variable {V : Type*} {κ : Type*}

/-- **Structure theorem.**  A minimal obstruction to admitting a total rainbow
forest is a single monochromatic cycle (with isolated vertices allowed): its
edge set equals the edge set of one cyclic walk, and all edges share a colour. -/
theorem minObstruction_isMonoCycleGraph {G : SimpleGraph V} {col : Sym2 V → κ}
    (h : MinObstruction G col) : IsMonoCycleGraph G col := by
  obtain ⟨⟨v, c, hcyc, k, hmono⟩, hmin⟩ := h
  -- Every edge of `G` must lie on the monochromatic cycle `c`.
  have hGc : ∀ e, e ∈ G.edgeSet ↔ e ∈ c.edges := by
    intro e
    refine ⟨fun heG => ?_, fun hec => c.edges_subset_edgeSet hec⟩
    by_contra hec
    -- If `e` is off `c`, the whole cycle survives deleting `e`.
    have hsub : ∀ f ∈ c.edges, f ∈ (G.deleteEdges {e}).edgeSet := by
      intro f hf
      rw [edgeSet_deleteEdges]
      refine ⟨c.edges_subset_edgeSet hf, ?_⟩
      simp only [Set.mem_singleton_iff]
      rintro rfl
      exact hec hf
    exact hmin e heG
      ⟨v, c.transfer _ hsub, hcyc.transfer hsub, k, by rw [Walk.edges_transfer]; exact hmono⟩
  exact ⟨v, c, hcyc, hGc, k, fun e he => hmono e ((hGc e).1 he)⟩

end Catalog.Novelty.TotalRainbowForest