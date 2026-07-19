# Computational evidence

## Small cases

For one-hot vectors `e_i` in dimension 12, direct coordinate expansion gives

| pair | squared Euclidean distance |
|---|---:|
| `e_i, e_i` | 0 |
| `e_i, e_j`, `i ≠ j` | 2 |

Thus, with squared threshold `r`, the Vietoris–Rips complex on any observed subset of the
12 one-hot pitch classes has the following complete table:

| threshold | simplices |
|---|---|
| `r < 2` | only the empty simplex and individual vertices |
| `r ≥ 2` | every subset (the full simplex) |

These calculations are proved for every finite dimension in
`Catalog/Computation/PersistentHarmony/Equidistant.lean`, not merely sampled numerically.
They reveal a counterexample to the motivating expectation: this literal one-hot encoding
cannot produce a scale interval containing a chordless cycle, because all distinct-pair edges
appear simultaneously.

A second exact check concerns sequence information. Converting a chord list to a point-cloud
`Finset` gives the same cloud after reversal or cyclic rotation. This is proved generically in
`Catalog/Computation/PersistentHarmony/SequenceInvariance.lean`.

## OEIS search

No integer sequence arises from these results, so an OEIS search is not applicable.

## Counterexample hunt

The universal equidistance theorem subsumes exhaustive testing of all `12 × 12` ordered pairs:
the only values are 0 on the diagonal and 2 off it. Therefore every selection of four distinct
pitch classes acquires its two diagonals at exactly the same threshold as its cycle edges.

## Dataset stage

No corpus of 100 Bach chorales, 100 pop songs, and 100 atonal works was supplied, and no
canonical chord extraction, normalization, metric, coefficient field, or statistical protocol
was specified. Consequently, the empirical genre thresholds were not presented as verified.
The formal results instead identify two model-design issues that should be resolved before such
a corpus experiment: one-hot pitch-class equidistance and loss of temporal order in an unordered
point cloud.
