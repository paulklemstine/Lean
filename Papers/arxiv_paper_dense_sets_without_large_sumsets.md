# Computational evidence

## Small-case calculations

For universes of cardinality `N = 3,…,8`, all subsets were enumerated.  A fixed
two-element set occurred in respectively `2, 4, 8, 16, 32, 64` subsets, exactly
matching `2^(N-2)`.  The total powerset sizes were `8, 16, 32, 64, 128, 256`.

| `N` | all subsets | supersets of a fixed 2-set | predicted `2^(N-2)` | subsets of size `< ceil(N/2)` |
|---:|---:|---:|---:|---:|
| 3 | 8 | 2 | 2 | 4 |
| 4 | 16 | 4 | 4 | 5 |
| 5 | 32 | 8 | 8 | 16 |
| 6 | 64 | 16 | 16 | 22 |
| 7 | 128 | 32 | 32 | 64 |
| 8 | 256 | 64 | 64 | 93 |

For the interval pairs `A = B = {0,…,k-1}`, direct enumeration for `k = 1,…,5`
gave sumset cardinalities `1, 3, 5, 7, 9`.  These equal `2k-1`, confirming that
the integer sumset lower bound used in the uniform estimate is sharp.

## Counterexample hunt

The exact fixed-configuration count was tested for every subset `T` of every
universe through cardinality eight; no counterexample was found.  The hypotheses
`T ⊆ U` and nonemptiness of both sumset factors are necessary.  Dropping the
first makes the count zero rather than a power of two.  Dropping nonemptiness
permits an empty sumset, invalidating the `|A+B| ≥ |A|+|B|-1` interpretation.

## Sequence search

The fixed-configuration counts form the elementary powers-of-two sequence.  No
specialized sequence identification is needed: the values arise directly by
choosing an arbitrary subset of the complement `U \ T`.

## Interpretation

The calculations support the two exact combinatorial inputs: containment costs
one binary choice for each point outside the fixed configuration, and arithmetic
progressions attain equality in integer sumset growth.  They also illustrate the
main limitation: a raw union bound must pay for every candidate pair, motivating
structural compression of the candidate family at logarithmic thresholds.
