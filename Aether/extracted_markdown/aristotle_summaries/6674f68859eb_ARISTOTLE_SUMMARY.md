# Summary of changes for run 7ad98b5a-7450-48e0-8b80-3348db6f18ee
Delivered a new, fully-compiling Lean 4 file `Catalog/Computation/ProofPhaseTransitions.lean` plus `FUTURE_DIRECTIONS.md`.

The referenced base file did not actually exist (cold start), so I built both the deterministic skeleton and a genuinely new graded refinement, all proven with no `sorry` on any result (verified by build; key theorems depend only on the standard axioms propext / Classical.choice / Quot.sound).

Contents of the Lean file:
- Consequence relation `Derivable T = ReflTransGen T` with reflexivity, transitivity, and relation-monotonicity.
- Digraph reachability `EDeriv` with the monotone-Boolean-function core `ederiv_mono` / `ederiv_upward_closed`.
- The barrier method: `Closed`, `closed_preserved`, and `barrier_not_derivable` (a closed separating set certifies non-derivability).
- A NEW graded/length-indexed closure `DerivIn` (length exactly n) and `DerivLen` (length ≤ L), with `derivIn_derivable`, `derivable_derivIn` (ReflTransGen is graded), edge/length monotonicity (`derivIn_mono`, `derivLen_mono_len`, `derivLen_mono_rel`), and `ederivLen_mono` showing length-bounded reachability is still a monotone Boolean function.
- The KEY result `derivIn_potential`: a height function increasing by exactly 1 along each axiom pins down the exact derivation length, yielding the diameter lower bound `chain_min_length` — no derivation of 0 ⟶ n in the chain is shorter than n — together with the matching achievability `chain_derivLen`.
- The explicit chain `chainEdges` with `chain_card`, `mem_chainEdges`, `chain_reach`/`chain_derivable`, and the minimal-certificate / criticality theorem `chain_edge_critical` (deleting any single axiom destroys 0 ⟶ n, proved via the down-set barrier).

Each theorem carries a 1–2 sentence proof-sketch comment in `-- !-- ... -- !--` blocks, and worked `example` uses are included. `FUTURE_DIRECTIONS.md` lists five falsifiable conjectures (joint density×length phase diagram, potential = minimum-proof-length duality, Horn/hypergraph thresholds, a criticality-index monotonicity law, and a separate diameter-driven proof-length transition), each with a "The key insight is..." sentence and a "Why now?" justification referencing the proven results.

Note: the Lean sources live under the `Catalog/` subproject; I added a `.lake` symlink there so the subproject reuses the prebuilt Mathlib, allowing the new module to compile.