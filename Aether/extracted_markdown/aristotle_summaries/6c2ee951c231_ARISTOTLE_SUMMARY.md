# Summary of changes for run 8c536f20-6594-4b8c-a20b-08704d430dbe
Added a new self-contained Lean 4 development on the Unique Games Conjecture (UGC), MAX-CUT, and the value/SDP gap, in `Cryptography/UniqueGamesMaxCut.lean` (namespace `UniqueGames`), plus a companion `Cryptography/UniqueGamesMaxCut_FUTURE_DIRECTIONS.md`. The module builds cleanly with no `sorry` and depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

The UGC itself is a major open problem, so it is not claimed as proved; instead the file rigorously establishes the unconditional mathematical facts that frame it.

Core definitions:
- `UniqueGame k`: a constraint (multi)graph where each edge carries a permutation of the `k` labels.
- `UniqueGame.Sat` / `satCount`: when a labeling satisfies an edge, and how many edges it satisfies.
- `maxCutGame`: MAX-CUT as the `k = 2`, all-swap unique game; `trivialGame`: identity-constraint games.

Theorems proved (all complete, no sorry):
1. `UniqueGame.constraint_graph_card` — each edge constraint is functional and bijective: exactly `k` of the `k²` label pairs satisfy it (the precise meaning of "unique").
2. `UniqueGame.edge_sat_card` — for an edge with distinct endpoints, a uniformly random labeling satisfies it with probability exactly `1/k` (`k · #{sat} = #{all labelings}`), proved via an explicit equivalence `(labelings) ≃ Fin k × {satisfying labelings}`.
3. `UniqueGame.satCount_sum` — double-counting identity exchanging the sum over labelings and edges.
4. `UniqueGame.exists_assignment_sat_ge` — the random-assignment soundness floor: every no-self-loop unique game on `k ≥ 1` labels has a labeling satisfying at least a `1/k` fraction of constraints. This is the unconditional baseline the soundness side of UGC must beat.
5. `UniqueGame.exists_value_ge_inv_k` — the rational "value ≥ 1/k" reformulation.
6. `maxCut_sat_iff_cut` — the MAX-CUT bridge: an edge is satisfied iff its endpoints get different labels (the edge is cut).
7. `maxCut_exists_cut_half` — corollary: every graph has a cut containing at least half its edges.
8. `trivialGame_perfect` — completeness side: identity-constraint games are perfectly satisfiable (value 1), so the `[1-ε, ε]` decision gap of UGC is non-vacuous.

Proof sketches are included inline as `-- !-- ... -- !--` comments. The work synthesizes with the existing cryptography catalog (referencing `Cryptography.HardnessHierarchy` and `Cryptography.CutCryptography`) by adding the inapproximability/gap layer on top of the project's hardness line.

`UniqueGamesMaxCut_FUTURE_DIRECTIONS.md` gives five testable, falsifiable research conjectures extending the work (tightness of the 1/k floor via concentration; a formal SDP relaxation and integrality-gap object; the Goemans–Williamson 0.878 rounding bound; parallel repetition / label amplification; long-code dictatorship tests), each with a "key insight" and "why now" justification.