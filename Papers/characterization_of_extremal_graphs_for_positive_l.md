# Computational Evidence: the matching–clique join and the curvature extremal count

All numbers below were computed directly from the formal construction `H(k)` on
`n = 4k` vertices (block `A` = perfect matching on `2k` vertices, block `B` = clique
`K_{2k}`, complete bipartite join between the blocks).

## 1. Small-case edge counts

| k | n = 4k | edges of H(k) = 6k² | claimed T(n) = (n−2)²/2 | C(n,2) |
|---|--------|---------------------|--------------------------|--------|
| 1 | 4      | 6                   | 2                        | 6      |
| 2 | 8      | 24                  | 18                       | 28     |
| 3 | 12     | 54                  | 50                       | 66     |
| 4 | 16     | 96                  | 98                       | 120    |
| 5 | 20     | 150                 | 162                      | 190    |

Observations.
- The construction has `6k² = 3n²/8` edges, verified against the concrete graph at
  `k = 3` (54 edges).
- The claimed threshold `T(n) = (n−2)²/2 = 2(2k−1)²` is **never** equal to `6k²`: their
  difference `6k² − 2(2k−1)² = −2k² + 8k − 2` has no integer root. For `k ≥ 5` the claim
  even exceeds the construction's edge count, and for `k ≤ 3` it is smaller. This refutes
  the identification of `H(k)` with the extremal count.

## 2. Where does `T(n)` live?

`T(n) = (n−2)²/2 = C(n,2) − (3n−4)/2`. So an extremal graph achieving `T(n)` is the
complete graph with only `(3n−4)/2 = Θ(n)` edges removed. The matching–clique join, by
contrast, removes `C(2k,2) − k = Θ(n²)` edges inside block `A` alone. Hence the true
maximiser is **near-complete**, not the sparse matching–clique join. This is the central
computational finding driving the future directions.

## 3. Local common-neighbour profile (triangles per edge)

For `k = 3` (n = 12, so `2k = 6`, `4k−2 = 10`), computed from the concrete graph:

| edge type      | common neighbours | formula |
|----------------|-------------------|---------|
| matching (A–A) | 6                 | 2k      |
| join (A–B)     | 6                 | 2k      |
| clique (B–B)   | 10                | 4k−2    |

The matching edges (together with the join edges) are the locally sparsest, with `2k`
triangles versus `4k−2` for clique edges. Discrete Lin–Lu–Yau curvature is an increasing
function of the local triangle count relative to endpoint degrees, so the sparsest edges
are exactly the curvature-minimising ones — consistent with the conjecture's claim (4) that
the non-positively-curved edge lies inside the matching.

## 4. Parity / existence check

A perfect matching on the `n/2` vertices of block `A` requires `n/2` to be even, i.e.
`4 ∣ n`. So the family does not exist for `n ≡ 2 (mod 4)` (e.g. `n = 10, 14`), contradicting
the blanket claim "for all even `n ≥ 12`". The formal graph is built on `n = 4k` precisely
to respect this obstruction.

## 5. OEIS

The edge sequence `6k²` (`6, 24, 54, 96, 150, …`) is `6·A000290` (six times the squares);
the vertex sequence `4k` is trivial. No deeper sequence match is relevant here.
