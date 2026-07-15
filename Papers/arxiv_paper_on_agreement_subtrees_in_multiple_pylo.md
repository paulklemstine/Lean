# Computational evidence

The formal development proves structural statements rather than conjectural numerical
bounds, so exhaustive computation is not needed for correctness. Still, the following
small cases check the intended threshold semantics.

| number of trees `k` | ambient leaves `N` | requested leaves `n` | conclusion |
|---:|---:|---:|---|
| 1 | 0 | 0 | threshold holds |
| 1 | 3 | 3 | threshold holds |
| 1 | 3 | 4 | impossible by cardinality |
| arbitrary | `N` | `n > N` | impossible by cardinality |

The first three instances follow from the proved exact formula
`IsAgreementThreshold N 1 n ↔ n ≤ N`. The final row follows from
`agreementThreshold_size_bound`.

No OEIS sequence arises from these structural lemmas. A counterexample hunt for the
universal monotonicity claims is unnecessary beyond cardinality edge cases: both are
proved for arbitrary finite split systems, a strictly more general setting than binary
phylogenetic-tree split systems. In particular, empty systems, empty leaf sets, and
one-tree families are included rather than silently excluded.
