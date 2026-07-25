# Computational Evidence: Five-Qubit Radial Geometry

## Small-case calculations

The tested radial model is the path on four vertices:

| Endpoint pair | Shortest-path length |
|---|---:|
| 0–0 | 0 |
| 0–1 | 1 |
| 0–2 | 2 |
| 0–3 | 3 |

For the `[[5,1,3]]` parameters, the endpoint length is therefore the code distance `d = 3`. The quantum Singleton budget also closes exactly:

`2d + k = 2·3 + 1 = 7 = 5 + 2 = n + 2`.

The standard Tanner presentation has five variable vertices and four check vertices, hence nine vertices. The radial path has four vertices. Their vertex sets cannot be bijective, so no graph isomorphism can identify these two finite graphs.

## OEIS search results

No OEIS search is relevant. The central object is a fixed finite graph metric and a coding-theoretic inequality, not a newly observed integer sequence.

## Counterexample hunt

The strongest literal proposal—identifying the five-qubit Tanner graph with the four-vertex radial chain—fails immediately by vertex cardinality (`9 ≠ 4`). This counterexample is independent of the Tanner incidence relation.

A second failure mode concerns the claimed equivalence between an entropy equality and the Singleton bound. The bound is an inequality. Exact equality follows only under an additional Singleton-saturation hypothesis, and regional entropy is not determined by `[[n,k,d]]` alone.

## Table of tested logical implications

| Proposed implication | Outcome | Required condition |
|---|---|---|
| Code distance gives geodesic length | Conditional | Explicit metric realization |
| Singleton gives a geodesic capacity bound | Survives | Metric realization |
| Singleton gives exact area/entropy equality | Fails in general | Singleton saturation plus an entropy dictionary |
| `[[5,1,3]]` admits a length-three radial model | Survives | Four-vertex path construction |
| Five-qubit Tanner graph is that radial model | Fails | Vertex-cardinality obstruction |

The finite calculations are supported by the accompanying theorem file, where the endpoint distance is established using an explicit three-edge walk and an inductive lower bound on every competing walk.
