# Computational Evidence

## Small-case calculations

For a one-hyperplane central arrangement, proper face flags relative to either chamber are repetitions of the center. A flag of length `m` has bidegree `(m,m)`, so there is one endpoint generator in every diagonal bidegree `(m,m)`.

For the Boolean arrangement of two coordinate hyperplanes, model zero sets by subsets of `{1,2}`. Weakly increasing nonempty flags ending in `{1,2}` satisfy the terminal-support rule. Examples are:

| Flag | Profile | Rank degree (cardinality weight) | Length degree | Hamming transition length |
|---|---:|---:|---:|---:|
| `[{1,2}]` | `(1,1)` | 2 | 2 | 0 |
| `[{1},{1,2}]` | `(2,1)` | 3 | 3 | 1 |
| `[{2},{1,2}]` | `(1,2)` | 3 | 3 | 1 |
| `[{1},{1},{1,2}]` | `(3,1)` | 4 | 4 | 1 |

In each row, the profile support is the terminal set. Appending `{1,2}` increases both profile coordinates by one and shifts rank and length by `(2,2)`.

## Sequence search

No one-dimensional sequence is central to the claims proved here, so an OEIS identification is not applicable. The relevant data are multigraded flag counts rather than a canonical scalar sequence.

## Counterexample hunt

Dropping nesting immediately breaks terminal support: the sequence `[{1},{2}]` has profile support `{1,2}` but terminal set `{2}`. Dropping nonemptiness leaves no terminal set. These examples show that both hypotheses in the terminal-support theorem are sharp.

The central append/delete operation was checked on all displayed flags: appending the full zero set preserves nesting, increments every profile coordinate, and has deletion of the last entry as its inverse.

## Geometric table

For the nested path `{1} ⊆ {1,2}`, the Hamming transition has length `1`, and `1 + |{1}| = |{1,2}|`. Repetitions contribute zero Hamming length, so `{1} ⊆ {1} ⊆ {1,2}` has total transition length `1` as well. This is the finite pattern generalized by the telescoping theorem.
