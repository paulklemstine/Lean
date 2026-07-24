# Computational Evidence — Incidence-Capacity Obstruction for Hamilton Covers

## Setup

A *two-regular cover* of a graph `G` is a family of spanning subgraphs, each
two-regular (every vertex has degree exactly `2`), whose union contains every
edge of `G`. We study the minimum number `k` of layers, and the claim that

    k ≥ ⌈Δ(G) / 2⌉,   where Δ(G) is the maximum degree.

The mechanism is local: a single two-regular layer contributes exactly `2` to
each vertex's degree, so the `deg_G(v)` edges at a vertex `v` need at least
`⌈deg_G(v)/2⌉` layers.

## 1. Small-case calculations

| Graph                         | Δ  | ⌈Δ/2⌉ | achievable k | matches bound |
|-------------------------------|----|-------|--------------|---------------|
| Cycle `C_n` (n ≥ 3)           | 2  | 1     | 1            | yes           |
| Two edge-disjoint Ham. cycles | 4  | 2     | 2            | yes           |
| Complete graph `K_5`          | 4  | 2     | 2            | yes (2-factorization) |
| Complete graph `K_7`          | 6  | 3     | 3            | yes           |
| Complete graph `K_{2m+1}`     | 2m | m     | m            | yes (Walecki)  |

For odd complete graphs `K_{2m+1}` every vertex has even degree `2m`, and the
classical Walecki construction decomposes the edges into exactly `m` Hamilton
cycles — meeting `⌈Δ/2⌉ = m` with zero incidence defect.

## 2. Local parity defect

At the optimal layer count `k = ⌈Δ/2⌉`, the per-vertex incidence slack is

    2·⌈Δ/2⌉ − Δ = Δ mod 2 ∈ {0, 1}.

| Δ | ⌈Δ/2⌉ | 2·⌈Δ/2⌉ − Δ |
|---|-------|-------------|
| 2 | 1     | 0           |
| 3 | 2     | 1           |
| 4 | 2     | 0           |
| 5 | 3     | 1           |
| 6 | 3     | 0           |

This is the "zero-or-one incidence defect": even-degree vertices are covered
with no slack, odd-degree vertices carry exactly one unit of unavoidable slack
that any extension procedure must absorb. This matches the local-parity theorem
referenced in the research prompt.

## 3. Counterexample hunt

The lower bound `k ≥ ⌈Δ/2⌉` was tested against the graph families above and a
handful of small random graphs: no graph admits a two-regular cover with fewer
than `⌈Δ/2⌉` layers, because the vertex of maximum degree alone forces the
count. No counterexample exists — the bound is a hard capacity constraint, not a
heuristic.

## 4. Sharpness

The single-cycle case (`Δ = 2`, `k = 1`) shows the bound is attained, so it is
not vacuous. More generally the odd complete graphs show the bound is attained
for every even Δ. This is formalized as `single_layer_cover_sharp`.

## Conclusion

The computational evidence uniformly supports the deterministic lower bound and
the `Δ mod 2` parity law, both of which are proved in
`HamiltonCoverIncidenceCapacity.lean` with no additional hypotheses beyond
two-regularity of the layers and coverage of every edge.
