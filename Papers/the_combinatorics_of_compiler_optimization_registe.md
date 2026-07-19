# Computational Evidence

## Small-case calculations

The smallest useful diagnostic is the path on three vertices, with edges `0–1` and `1–2`.

| Quantity | Value |
|---|---:|
| Number of vertices | 3 |
| Maximum degree | 2 |
| Clique number | 2 |
| Chromatic number | 2 |
| Proposed value `Delta + 1` | 3 |

Thus the proposed equality with `Delta + 1` fails even for a chordal graph: the path is two-colorable although its maximum degree plus one is three. The accompanying theorem `path_three_refutes_degree_formula` establishes this finite case from an explicit coloring and degree calculation.

Additional boundary instances are consistent with the corrected picture:

| Graph | Chromatic number | Maximum degree + 1 | Clique number |
|---|---:|---:|---:|
| One isolated vertex | 1 | 1 | 1 |
| One edge | 2 | 2 | 2 |
| Three-vertex path | 2 | 3 | 2 |
| Triangle | 3 | 3 | 3 |

## OEIS search results

No sequence-valued invariant is central to the corrected theorem, so an OEIS identification would not add relevant evidence. The tested quantities are graph invariants on a single minimal obstruction rather than initial terms of a canonical integer sequence.

## Counterexample hunt

The universal degree formula was tested first against sparse trees because trees maximize the gap between local degree and global coloring demand. The three-vertex path immediately supplies a counterexample. This also refutes the associated claim that spilling is necessary whenever the register budget is below `Delta + 1`: two registers color this graph without spilling, despite `2 < 3`.

The claim that maximum-degree spilling always minimizes spill cost is not supported when costs are weighted. A high-degree, high-cost vertex can be more expensive to spill than several low-cost alternatives, so degree alone cannot determine a universal weighted optimum.

## Structural conclusion

The experiments support replacing the degree equality by two distinct statements: `Delta + 1` is a universal sufficient budget, while clique number is the exact budget for graphs carrying a perfect elimination ordering. The path example shows why these statements must not be conflated.
