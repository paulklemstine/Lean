# Computational Evidence: Topological Quantum Compiling

## Small-case calculations

The dimension expression supplied in the proposal is

\[
d(k,n)=(k-1)(n-1)+1.
\]

Its nearby values are:

| \(k\) | \(n\) | \(d(k,n)\) |
|---:|---:|---:|
| 3 | 4 | 7 |
| 4 | 4 | 10 |
| 5 | 3 | 9 |
| 5 | 4 | 13 |
| 5 | 5 | 17 |

In particular, the stated parameters give 13 rather than 3. This exact mismatch is also established by `proposed_dimension_formula_mismatch`.

## Matrix-data audit

No explicit normalization, fusion basis, sector choice, or matrices for the three braid generators were supplied. Therefore eigenvalues, determinants, braid relations, and the order of the proposed generator product cannot be tested reproducibly from the stated data. Supplying arbitrary matrices would test a different claim.

## Counterexample hunt

Two proposed implications fail as general tests:

1. An infinite-order element does not force density: the diagonal one-parameter subgroup of a higher-dimensional unitary group is infinite but lies in a proper closed subgroup.
2. Solovay--Kitaev does not establish density; it gives efficient approximation after density (and the relevant inverse-closure hypotheses) has already been proved.

The formal results therefore separate the infinite-order certificate from the proper-closed-subgroup obstruction to density.

## Sequence-database search

No integer sequence governs the central claim, so an OEIS search is not applicable. The relevant data are algebraic matrices and their topological closure, not a sequence of integer counts.

## Plots

A plot would add no information before concrete matrices and a metric-dependent approximation experiment are specified. The table above captures the only numerical formula in the proposal.
