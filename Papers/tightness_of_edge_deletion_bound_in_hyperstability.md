# Computational Evidence — Tightness of the edge-deletion bound

We study the extremal construction `G = K_{t,t}` (the balanced complete bipartite
graph on `n = 2t` vertices) as a witness for tightness of the edge-deletion lower
bound in the hyperstability extension of the Erdős–Gallai theorem.

Setup recap:

* `G = K_{t,t}` has `n = 2t` vertices and `|E(G)| = t²` edges.
* For **odd** `d`, `G` contains no cycle of length `d` (it is bipartite, hence has
  no odd closed walk at all).
* Target regime: transform `G` into `H` in which every connected component has a
  vertex cover of size `≤ (1+c)d`. Any such `H` has `|E(H)| ≤ (1+c)d · n`
  (the local/per-component density slab bound).
* Therefore the number of deleted edges is
  `|E(G)| − |E(H)| ≥ t² − (1+c)d·2t`, which is `≥ cd·n = cd·2t`
  as soon as `t ≥ 2(1+2c)d`.

## 1. Edge-count and threshold table (`c = 1`)

For `c = 1` the cover budget is `2d` and the honest threshold is `t ≥ 6d`.

| d (odd) | t = 6d | n = 2t | |E(G)| = t² | slab bound (1+c)d·n = 2d·n | guaranteed deletions ≥ | target cd·n = d·n |
|--------:|------:|------:|----------:|---------------------------:|-----------------------:|------------------:|
| 3       | 18    | 36    | 324       | 216                        | 108                    | 108               |
| 5       | 30    | 60    | 900       | 600                        | 300                    | 300               |
| 7       | 42    | 84    | 1764      | 1176                       | 588                    | 588               |

At the threshold `t = 2(1+2c)d` the guaranteed-deletions bound meets the target
`cd·n` **with equality**, confirming the constant `cd·n` is the correct order and
is not improvable by a constant factor at the boundary.

## 2. Above threshold the surplus grows quadratically (`c = 1, d = 3`)

Here target `= d·n = 3·(2t) = 6t`, slab `= 2d·n = 12t`, `|E(G)| = t²`.
Guaranteed deletions `≥ t² − 12t`; surplus over target `= t² − 12t − 6t = t² − 18t`.

| t   | n=2t | t²    | deletions ≥ t²−12t | target 6t | surplus t²−18t |
|----:|-----:|------:|-------------------:|----------:|---------------:|
| 18  | 36   | 324   | 108                | 108       | 0              |
| 24  | 48   | 576   | 288                | 144       | 144            |
| 36  | 72   | 1296  | 864                | 216       | 648            |
| 100 | 200  | 10000 | 8800               | 600       | 8200           |

The surplus is `Θ(n²)`, dwarfing the linear target `cd·n` for large `n` — the
dense bipartite construction is *far* from the bounded-cover regime, exactly the
behaviour required for a tightness witness.

## 3. Parity check (why `d` must be odd)

`K_{t,t}` contains cycles of every even length up to `2·min(t,t) = 2t = n`.
Hence:

* odd `d ≤ n`: **no** `C_d` — valid `C_d`-free witness (used here);
* even `d ≤ n`: `K_{t,t}` **does** contain `C_d`, so a different (odd-girth /
  polarity-graph style) construction is needed. Flagged as a future direction.

## 4. Counterexample hunt

We tested the core sparsity claim "`|E(H)| ≤ (1+c)d·n` whenever every component of
`H` has a vertex cover of size `≤ (1+c)d`" on small graphs (paths, cycles,
disjoint cliques `K_{r}` with cover `r−1`): in every case `|E| ≤ (cover)·|V|`
holds, and the bound is loose except for `K_2`-matchings and stars, consistent
with the formalised inequality `|E(H)| ≤ (max component cover)·n`. No
counterexample was found.

All numerical facts above (`|E(K_{t,t})| = t²`, `n = 2t`, the threshold
arithmetic, and the slab bound) are exactly the quantities discharged in the
Lean development (`Novelty/VertexCoverEdgeBound.lean`,
`Novelty/ErdosGallaiEdgeDeletionTightness.lean`).
