# Computational evidence: union-closed families on three points

## Encoding and exhaustive small-case calculation

A subset of a three-element universe was encoded by a 3-bit integer `0,…,7`,
and a family by an 8-bit integer `0,…,255`. Binary union is bitwise OR. An
exhaustive enumeration tested binary union-closure and element frequencies for
all 256 families.

| quantity | count |
|---|---:|
| all families on three points | 256 |
| union-closed families | 122 |
| union-closed families with a nonempty member | 120 |
| preceding families containing no singleton | 22 |
| counterexamples to Frankl's property | 0 |

The distribution of the 122 union-closed families by number of members is:

| family size | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| count | 1 | 8 | 19 | 27 | 28 | 22 | 12 | 4 | 1 |

The formal proof in `Catalog/Novelty/FranklSmallUniverse.lean` kernel-checks the
finite residual case with `decide`; the singleton case is proved structurally by
an injection in `Catalog/Novelty/FranklUnionClosed.lean`.

## Boolean cubes

For the full powerset of an `n`-element universe, the first values of
`|𝒫([n])|` and the total cardinality of all members are:

| n | number of subsets | total member size |
|---:|---:|---:|
| 0 | 1 | 0 |
| 1 | 2 | 1 |
| 2 | 4 | 4 |
| 3 | 8 | 12 |
| 4 | 16 | 32 |
| 5 | 32 | 80 |
| 6 | 64 | 192 |

These agree with `2^n` and `n·2^(n-1)`, respectively. The identities are proved
symbolically in `Catalog/Novelty/FranklLattice.lean`.

## OEIS search

The powerset counts `1, 2, 4, 8, 16, …` are OEIS A000079 (powers of two). The
union-closed-family count `122` is used only as a finite sanity check here; no
OEIS identification is needed by any theorem.

## Counterexample hunt

The exhaustive three-point search found no counterexample. This computational
observation is not used as unchecked evidence: the corresponding finite
proposition is proved by kernel reduction in Lean.
