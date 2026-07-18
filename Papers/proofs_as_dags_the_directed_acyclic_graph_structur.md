# Computational Evidence

## Small-case calculations

The formal counterexample family uses the strict total order on `n` vertices: there is an edge `i → j` exactly when `i < j`. Direct enumeration gives:

| `n` | edges | in-degrees | out-degrees | weakly connected after every one-vertex deletion? |
|---:|---:|---|---|---|
| 1 | 0 | 0 | 0 | yes |
| 2 | 1 | 0, 1 | 1, 0 | yes |
| 3 | 3 | 0, 1, 2 | 2, 1, 0 | yes |
| 4 | 6 | 0, 1, 2, 3 | 3, 2, 1, 0 | yes |
| 5 | 10 | 0, 1, 2, 3, 4 | 4, 3, 2, 1, 0 | yes |
| 6 | 15 | 0, 1, 2, 3, 4, 5 | 5, 4, 3, 2, 1, 0 | yes |
| 7 | 21 | 0, 1, 2, 3, 4, 5, 6 | 6, 5, 4, 3, 2, 1, 0 | yes |
| 8 | 28 | 0, 1, 2, 3, 4, 5, 6, 7 | 7, 6, 5, 4, 3, 2, 1, 0 | yes |

The edge counts follow `n(n-1)/2`. More importantly, after deleting any vertex, each two surviving vertices still have a direct edge in one orientation. This survives as the theorem `totalOrderDAG_robust_after_deletion`.

## Counterexample hunt

The claim that acyclicity itself makes a dependency network fragile fails throughout the tested family. Every tested order network is acyclic, yet no vertex deletion weakly disconnects its survivors. The proof establishes this for every finite `n`, not merely the table above.

A second warning concerns degree laws. These examples have a uniform one-per-degree profile rather than a power law. Consequently, no power-law exponent follows from the DAG axioms alone; such a claim must be tested against a precisely extracted corpus.

## Sequence lookup

The edge-count sequence `0, 1, 3, 6, 10, 15, 21, 28, …` is the triangular-number sequence, OEIS A000217. No external sequence identification is needed for the structural proofs.

## Scope of the evidence

No corpus-wide Mathlib dependency graph was extracted in this cycle, so the proposed numerical exponent and historical top-ten ranking remain untested empirical hypotheses. The calculations instead guided a rigorous boundary result: hierarchy is forced by acyclicity, while scale-free statistics and deletion fragility are not.
