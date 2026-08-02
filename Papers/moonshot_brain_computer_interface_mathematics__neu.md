# Computational evidence: sparse neural coding

The formal target is the capacity of binary neural patterns under an energy
(spike-count) constraint.

## Small-case calculations

For `N` neurons and budget `k`, the predicted count is

`B(N,k) = ∑_{j=0}^k binom(N,j)`.

| `N` | `k` | weight-layer sizes | `B(N,k)` |
|---:|---:|---|---:|
| 4 | 0 | 1 | 1 |
| 4 | 1 | 1, 4 | 5 |
| 4 | 2 | 1, 4, 6 | 11 |
| 5 | 2 | 1, 5, 10 | 16 |
| 8 | 2 | 1, 8, 28 | 37 |
| 10 | 1 | 1, 10 | 11 |
| 10 | 2 | 1, 10, 45 | 56 |
| 10 | 3 | 1, 10, 45, 120 | 176 |

The cases `B(4,0)=1`, `B(4,1)=5`, and `B(4,2)=11` are also checked inside
`Catalog/Novelty/NeuralCoding/SparseEnergyTradeoff.lean` after rewriting by the
general exact-count theorem.

For exact energy `k`, the count is `binom(N,k)`. Representative checks of the
polynomial ceiling `binom(N,k) ≤ N^k` are:

| `(N,k)` | `binom(N,k)` | `N^k` |
|---|---:|---:|
| (5,2) | 10 | 25 |
| (10,3) | 120 | 1000 |
| (20,4) | 4845 | 160000 |

## OEIS search result

For fixed budget `k=2`, the sequence is

`B(N,2) = 1 + N + binom(N,2) = 1, 2, 4, 7, 11, 16, 22, ...`,

the centered polygonal numbers (OEIS A000124, with indexing beginning at
`N=0`). This identification is evidence only; no OEIS fact is used by the Lean
proof.

## Counterexample hunt

The exact-energy universal claim `binom(N,k) ≤ N^k` was checked conceptually at
the edge cases `k=0`, `N=0`, and `k>N`, as well as the representative table
above. No counterexample was found. The final Lean theorem proves the claim for
all natural `N,k`, so the result does not depend on this finite search.

## Shape of the capacity curve

At fixed `N`, exact weight-layer capacities follow the symmetric binomial row,
peaking near `N/2`. At fixed small `k`, exact sparse capacity is polynomial in
`N` (degree `k`), while unrestricted binary capacity is exponential (`2^N`).
This motivates the proved energy–information statement: the full exact-`k`
layer carries at most `log₂ N` bits per spike.
