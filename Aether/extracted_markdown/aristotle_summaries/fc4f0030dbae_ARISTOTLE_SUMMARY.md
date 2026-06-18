# Summary of changes for run 9d5497af-885a-4e0b-8e59-28e7cc6a5846
I extended the Arrow-curvature theory with a new, fully-proved Lean file and a research roadmap.

## New file: `Bridges/ArrowCurvature/Curvature.lean`
This builds on the existing `Bridges/ArrowCurvature/Defs.lean` (`Tournament`, `IsTransitive`, `Has3Cycle`, and the equivalence `tournament_trans_iff_no_3cycle`) and promotes the binary "transitive vs. has-a-Condorcet-cycle" distinction into a continuous, real-valued **curvature** invariant.

Definitions:
- `IsCyclicTriple` / `cyclicTriples` — the 3-element vertex subsets whose induced sub-tournament is a directed 3-cycle.
- `curvature : Tournament n → ℝ` — the fraction of 3-subsets that are cyclic, i.e. `κ(T) = |cyclicTriples| / C(n,3)`.

Theorems (all proved, no `sorry`, only the standard axioms `propext`, `Classical.choice`, `Quot.sound`):
- `card_triples_eq_choose` — the denominator equals `C(n,3)`.
- `cyclicTriples_subset`, `cyclicTriples_card_le` — basic counting bounds.
- `curvature_nonneg`, `curvature_le_one`, `curvature_mem_Icc` — `κ(T) ∈ [0,1]`.
- `has3cycle_le` — a 3-cycle forces `3 ≤ n`.
- `cyclicTriples_nonempty_iff_has3cycle` — a cyclic 3-subset exists iff the tournament has a 3-cycle.
- `curvature_eq_zero_iff_no_3cycle` and `curvature_eq_zero_iff_transitive` — **rigidity**: `κ(T) = 0` exactly when `T` is transitive (so the transitive/"dictatorial" tournaments are precisely the curvature-zero points).
- `curvature_pos_iff_has3cycle` — `0 < κ(T)` exactly when a Condorcet cycle exists.
- `curvature_three_dichotomy` — on 3 alternatives `κ(T) ∈ {0,1}`, with the maximum `κ = 1` attained by the 3-vertex Condorcet cycle.

Each main theorem carries a brief `-- !-- ... -- !--` proof-sketch comment, and a module docstring explains how the work connects to and extends the catalog's existing tournament definitions.

Note on the requested foundational `sorry`: the transitivity ↔ 3-cycle-freeness equivalence in `Defs.lean` was already complete in the project, so no change was needed there; the curvature theory is layered directly on top of it. The only remaining `sorry` in `Defs.lean` is the pre-existing deep `arrow_curvature_conjecture`, which I left untouched and instead address as a research direction.

## `Bridges/ArrowCurvature/FUTURE_DIRECTIONS.md`
A narrative listing five testable, falsifiable conjectures extending the work, each with a "key insight" and "why now" justification: (1) the exact ordered/unordered counting bridge `cycleCount = 3·|cyclicTriples|`; (2) the Kendall–Babington-Smith ceiling `sup κ → 1/4`; (3) the quantitative Arrow bound `E[κ] ≥ 1/(4m)` for non-dictatorial rules; (4) a metric "spectral gap" isolating dictatorships at `κ = 0`; and (5) a single-peaked (Black's theorem) flatness statement in curvature form.

The new file compiles cleanly (verified with a full build of the `Bridges.ArrowCurvature.Curvature` module) and contains zero `sorry`s.