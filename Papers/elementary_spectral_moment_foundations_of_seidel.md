# Computational evidence

The formal development includes the small-case calculation as the theorem
`fin3_complete_empty_cubic_witness`; it is kernel-checked rather than reported
from an external script.

| graph on three vertices | odd/even edge parity | `tr(S³)` | parity sum |
|---|---:|---:|---:|
| complete graph `K₃` | odd (3 edges) | `-6` | `-6` |
| empty graph | even (0 edges) | `6` | `6` |

There are six ordered triples with three distinct vertices. Each contributes
`-1` for `K₃` and `+1` for the empty graph; all repeated-vertex triples
contribute zero. This agrees exactly with the spectral trace computation.

## Counterexample hunt

No counterexample is possible after the general symbolic proof: the trace is
expanded into its finite triple sum and every summand is proved equal to the
parity weight. The concrete order-three theorem checks both extreme adjacency
relations and both sides of the connector independently.

## OEIS search

No sequence is introduced by the theorem, so an OEIS search is not applicable.
The result is an identity for every finite adjacency relation rather than a
one-parameter numerical sequence.
