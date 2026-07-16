# Computational Evidence

## Small-case calculations

For a symmetric array of order `n`, the number of unordered index pairs is `n(n+1)/2`.

| `n` | unordered pairs |
|---:|---:|
| 1 | 1 |
| 2 | 3 |
| 3 | 6 |
| 4 | 10 |
| 5 | 15 |
| 6 | 21 |

At order six, identifying the three positions `(0,1)`, `(2,5)`, and `(3,4)` as one fiber removes two labels from the twenty-one unordered positions, leaving nineteen. A disjoint direct-sum split with nineteen labels in one summand and four in the other gives twenty-three.

## Counterexample hunt

Exhaustive evaluation of the finite index certificates found no counterexample:

| certificate | computed value |
|---|---:|
| upper-triangular pairs in `Fin 6 × Fin 6` | 21 |
| representatives after erasing `(2,5)` and `(3,4)` | 19 |
| disjoint tagged union `Fin 19 ⊕ Fin 4` | 23 |

The first two calculations are reflected by closed finite theorems in `SchurBound.lean` and `Cardinalities.lean`. The tagged-union result is proved structurally from disjointness and injectivity of the two tags.

## Sequence search

The unordered-pair counts are the triangular numbers `1, 3, 6, 10, 15, 21, …`, OEIS A000217 with the initial zero omitted. This sequence is relevant because commutativity makes a Schur-product label depend only on an unordered pair.

## Scope of the evidence

These calculations test the range-counting mechanism, not the paper's numerical matrix coordinates. The analytic theorem in `SchurBound.lean` separately proves that normalized Schur products of unimodular orthogonal columns form a quantum Latin square under explicit hypotheses.
