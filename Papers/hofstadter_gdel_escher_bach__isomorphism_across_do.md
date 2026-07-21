# Computational Evidence

## Small-case calculations

A universal Boolean presentation on `n` codes would need its `n` evaluation rows to represent all `2^n` Boolean predicates. The first values are:

| codes `n` | available rows | Boolean predicates |
|---:|---:|---:|
| 0 | 0 | 1 |
| 1 | 1 | 2 |
| 2 | 2 | 4 |
| 3 | 3 | 8 |
| 4 | 4 | 16 |
| 5 | 5 | 32 |
| 6 | 6 | 64 |

The calculations and the first seven strict inequalities are reproduced in `ComputationalEvidence.lean`.

## Sequence search

The predicate counts are the powers of two, `1, 2, 4, 8, 16, 32, 64, …` (OEIS A000079). No less elementary sequence arose from the experiment.

## Counterexample hunt

No finite positive code size through six has enough rows. The zero-code case also fails because the empty table cannot represent the unique predicate on the empty type. This evidence suggested the anti-diagonal argument. The general theorem closes the search for every code type, finite or infinite: a row representing `a ↦ not (eval a a)` contradicts itself at its own code.

## Interpretation

This experiment tests a boundary condition rather than the cultural identifications themselves. It shows that the universality premise in the fixed-point bridge is restrictive: Boolean semantics cannot support it. The cross-domain theorem therefore requires a semantic domain in which every endomorphism under consideration can admit a fixed point.
