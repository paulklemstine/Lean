# Computational Evidence

## Small-case calculations

Consider three theorems labeled `0`, `1`, and `2`.

| Corpus records | Vertices | Edges | Two-simplex present? | Pairwise graph |
|---|---:|---:|---:|---|
| `{0,1}`, `{0,2}`, `{1,2}` | 3 | 3 | No | Complete |
| `{0,1}`, `{0,2}`, `{1,2}`, `{0,1,2}` | 3 | 3 | Yes | Complete |

Thus adding one joint citation fills the triangle while leaving every pairwise adjacency unchanged. This is the smallest example in which graph projection loses higher-order co-citation information.

For a corpus on `n` theorems, the number of possible `k`-simplices is bounded by `n choose (k+1)`. The first few universal ceilings are:

| `n` | vertices | edges | triangles | tetrahedra |
|---:|---:|---:|---:|---:|
| 1 | 1 | 0 | 0 | 0 |
| 2 | 2 | 1 | 0 | 0 |
| 3 | 3 | 3 | 1 | 0 |
| 4 | 4 | 6 | 4 | 1 |
| 5 | 5 | 10 | 10 | 5 |
| 6 | 6 | 15 | 20 | 15 |

In particular, dimension `k ≥ n` has no simplices and hence no positive Betti number. This directly contradicts a positive power law asserted uniformly over all dimensions.

## OEIS search results

The face ceilings form the rows of Pascal's triangle, sequence A007318. The relevant terms are binomial coefficients rather than unrestricted powers.

## Counterexample hunt

The universal exact claim `β_k = n^(k+1)` fails for every nonempty finite corpus by choosing `k = n`: the left side vanishes because no `(n+1)`-vertex face exists, while the right side is positive. The same witness defeats every positive constant-factor lower bound required uniformly in `k`.

A separate semantic counterexample is immediate: relabeling theorem vertices preserves all homology while it may exchange any proposed interpretation of communities or paradigm shifts. Consequently, semantic interpretations require external labels and cannot follow from topology alone.

## Tables and plots

The table above is sufficient for the finite obstruction. No numerical plot is needed because the decisive behavior is exact vanishing at and above the vertex count, not an estimated trend.
