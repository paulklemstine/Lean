# Computational Evidence

## Small cases

The formal development uses the labelled, rooted, oriented count of closed walks of length five. The following standard examples calibrate the normalisation.

| Graph | Order | Maximum degree | Closed length-five walks | Bound \(|V|\Delta^4\) |
|---|---:|---:|---:|---:|
| Empty graph on five vertices | 5 | 0 | 0 | 0 |
| Single edge plus three isolated vertices | 5 | 1 | 0 | 5 |
| Pentagon \(C_5\) | 5 | 2 | 10 | 80 |
| Complete bipartite graph \(K_{2,3}\) | 5 | 3 | 0 | 405 |

For \(C_5\), each of five roots supports two oriented traversals, giving ten labelled rooted orientations. Bipartite examples have no odd closed walks.

## Sequence search

No new integer sequence is needed: for cycle graphs \(C_n\), the closed length-five count is zero unless \(n=5\), when it is ten. This finite calibration does not motivate an OEIS identification.

## Counterexample hunt

The universal estimate is structurally protected: after choosing a root, each of four successive vertices has at most \(\Delta\) choices, and demanding that the last vertex close back to the root only removes candidates. Thus neither loops, repeated vertices, irregular degrees, nor isolated vertices can violate the estimate. The edge cases \(\Delta=0\) and an empty vertex type are included because the argument performs no division.

## Interpretation

The evidence highlights that \(|V|\Delta^4\) is the correct ambient scale but not a sharp triangle-free constant. Obtaining the paper's sharp coefficient requires exploiting triangle-freeness and positive-semidefinite relations among local types, rather than extension counting alone.
