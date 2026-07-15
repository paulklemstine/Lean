# Computational Evidence

## Small-case calculations

For a commutative construction on `n` labels, outputs are indexed by unordered pairs with repetition. The first values of the resulting ceiling are:

| `n` | ordered inputs `n²` | unordered-pair ceiling `n(n+1)/2` |
|---:|---:|---:|
| 1 | 1 | 1 |
| 2 | 4 | 3 |
| 3 | 9 | 6 |
| 4 | 16 | 10 |
| 5 | 25 | 15 |
| 6 | 36 | 21 |

For the direct-sum count described in the paper, the two disjoint ray populations have sizes nineteen and four, hence their union has size twenty-three.

## Sequence identification

The unordered-pair ceilings form the triangular-number sequence `1, 3, 6, 10, 15, 21, …`, OEIS A000217 with the index shifted to begin at `n = 1`.

## Counterexample hunt

The universal symmetric ceiling was checked by exhaustive enumeration of the upper-triangular index set on six labels: it contains exactly twenty-one pairs. Any output map can only identify additional pairs and therefore cannot increase this count. This exhaustive finite count is included in the accompanying mathematical development.

The direct-sum claim was tested at the level of finite sets: without disjointness, additivity fails whenever the two images overlap; with disjointness, union cardinality is exactly additive. Thus the disjoint-support hypothesis is necessary.

## Collision accounting

Starting from twenty-one unordered pairs, one fiber containing three pair indices decreases the number of distinct outputs by two and gives nineteen, provided all remaining fibers are singletons. This explains the cardinality effect of the reported coincidence `v₀₁ = v₂₅ = v₃₄`; verification that it is the unique nontrivial collision depends on the explicit matrix entries, which were not included in the supplied abstract.
