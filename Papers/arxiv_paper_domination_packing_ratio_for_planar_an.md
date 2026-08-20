# Computational evidence: the domination–packing ratio γ/ρ

All numbers in this file come from ad-hoc Python enumeration and are **exploratory only**.
Everything that is claimed as a *result* of this project is proved in Lean and lives in
`Catalog/Bridges/DominationPacking*.lean`; the statements marked "verified in Lean" below are
the ones that were subsequently formalized and machine-checked.

Definitions used by the scripts: for a finite simple graph `G`,
`N[v] = {v} ∪ N(v)`, `γ(G)` = least size of a set meeting every `N[v]`,
`ρ(G)` = largest number of vertices with pairwise disjoint `N[v]`.

## 1. Exhaustive search over all small graphs

For every labelled graph on `n ≤ 6` vertices we computed `γ` and `ρ` by brute force over all
vertex subsets and recorded the maximum of `γ/ρ`.

| n | max γ/ρ | extremal example |
|---|---------|------------------|
| 2 | 1       | `K₂`, `2K₁`      |
| 3 | 1       | —                |
| 4 | 2       | `C₄` (γ = 2, ρ = 1) |
| 5 | 2       | `C₄` (as an induced piece) |
| 6 | 2       | `C₄` (as an induced piece) |

So `γ/ρ = 2` is the best that can be done with at most six vertices.
`C₄` has `γ = 2`, `ρ = 1` — **verified in Lean** (`cycle4_dominationNumber`,
`cycle4_packingNumber`), together with an explicit unit disk realization of `C₄` on the corners
of a `4/5 × 21/25` rectangle (sides `4/5`, `21/25 ≤ 1`; diagonals `29/25 > 1`).

## 2. Ratio 3: minimum order is 8

We enumerated **all** `2^21` labelled graphs on `n = 7` vertices and filtered for
`ρ = 1` (all closed neighbourhoods pairwise meet) together with `γ ≥ 3`
(no one- or two-element dominating set).  The search returned **no** such graph, so no graph on
at most 7 vertices has `γ/ρ ≥ 3`.

A randomized search on `n = 8` immediately produced examples; greedy edge deletion reduced one
to a `3`-regular graph on 8 vertices with 12 edges, which we identified as the **Wagner graph**
`V₈` (the 8-cycle `0-1-⋯-7-0` plus the four main diagonals `i ∼ i+4`):

```
γ(V₈) = 3   (e.g. {0,1,2} dominates; no 2-set does)
ρ(V₈) = 1   (all 8 closed neighbourhoods pairwise meet)
```

Both facts are **verified in Lean** by `decide` (`wagner_dominationNumber`,
`wagner_packingNumber`), and the ratio statement `γ = 3ρ` is
`wagner_domination_eq_three_mul_packing`.  This matches the lower bound `3` quoted in the paper
(for planar and unit disk graphs; `V₈` itself is not planar).

## 3. Searching for a unit disk graph with ratio 3

We sampled ≈2·10⁵ random point sets of 6–10 points with rational coordinates in a
`3 × 3` box, built the unit disk graph (exact rational comparison of squared distances against
`1`, degenerate configurations with distance exactly `1` discarded) and computed `γ`, `ρ`.
No configuration with `γ/ρ ≥ 3` was found; the best observed was `γ/ρ = 2` (realized by `C₄`).
This is consistent with — but of course no evidence for — the paper's remark that the best known
lower bound for unit disk graphs is `3`; the known constructions are larger than 10 points.

## 4. Unbounded ratio for general graphs

The "spread graph" `S(k,t)` (a clique on `k` indices, an independent set of all `t`-subsets, an
index joined to the subsets containing it) was checked by hand for small `k` (the values of `γ`
below are the proved lower bound `k−t+1` together with the matching explicit dominating set
consisting of `k−t+1` indices):

| k | t | ρ | γ (computed) | k−t+1 (proved lower bound) |
|---|---|---|--------------|-----------------------------|
| 4 | 3 | 1 | 2            | 2                           |
| 6 | 4 | 1 | 3            | 3                           |
| 8 | 5 | 1 | 4            | 4                           |

The pattern `γ ≥ k − t + 1` with `ρ = 1` is **verified in Lean** in general
(`spreadGraph_packingNumber`, `spreadGraph_dominationNumber_ge`), giving graphs with `ρ = 1` and
arbitrarily large `γ`.

## 5. Sanity check of the geometric constant

The verified unit disk bound is `γ ≤ 25 ρ`, obtained from the volume count
"at most `((2·2+1)/1)² = 25` points pairwise more than `1` apart in a disk of radius `2`".
Numerically, the true maximum for that configuration is `19` (hexagonal-type arrangements), and
the paper's global constant is `18√3/π ≈ 9.924`, so the verified constant is off by a factor of
about `2.5` from the state of the art and by `25/19` from what the same proof scheme could give
with an optimal planar packing count.
