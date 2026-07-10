# Computational Evidence — Register Allocation as Interval Colouring

We study interference graphs built from *live ranges*: each variable `i` occupies a closed
integer interval `[lo i, hi i]`, and two distinct variables interfere iff their intervals
overlap. The quantity `maxDepth` is the maximum number of intervals covering a common point.

## 1. Small-case calculations

| Live ranges (`[lo,hi]`)                      | max overlap (`maxDepth`) | clique # `ω` | chromatic # `χ` |
|----------------------------------------------|:------------------------:|:------------:|:---------------:|
| `[0,1] [2,3] [4,5]` (disjoint)               | 1                        | 1            | 1               |
| `[0,2] [1,3] [2,4]`                          | 2                        | 2            | 2               |
| `[0,3] [1,4] [2,5] [3,6]`                    | 2                        | 2            | 2               |
| `[0,5] [1,2] [1,2] [1,2]` (nested burst)     | 4                        | 4            | 4               |
| `[0,10] [0,10] [0,10]` (all live at once)    | 3                        | 3            | 3               |

In every instance `χ = ω = maxDepth`, exactly as proved (`chromaticNumber_eq_maxDepth`,
`cliqueNum_eq_maxDepth`). The deepest program point always carries a maximum clique, and a
single left-to-right scan colours the graph with that many registers.

## 2. Counterexample hunt for the *general* formula `χ = max(Δ+1, ω)`

The mission's conjecture `χ(G) = max(Δ+1, ω(G))` is **false for general graphs**, which is
why the interval (SSA) hypothesis is essential:

* **Cycle `C₅`**: `Δ+1 = 3`, `ω = 2`, so `max = 3`; and indeed `χ(C₅) = 3`. (Consistent, but
  only because `C₅` happens to need `Δ+1` colours.)
* **Petersen graph**: `Δ+1 = 4`, `ω = 2`, so the formula predicts `χ = 4`; but the true
  value is `χ = 3`. **This refutes the formula.**
* **Any triangle-free graph with `χ ≥ 3`** (Grötzsch graph, Mycielskians): `ω = 2` while
  `Δ` is large, so `max(Δ+1, ω)` grossly overestimates `χ`.

The pattern: `max(Δ+1, ω)` is only an *upper* envelope (Brooks + the clique bound), never an
identity for arbitrary graphs. It becomes an identity precisely on **perfect** graphs, and
interval graphs (contiguous live ranges) are perfect. There the sharp law is `χ = ω`, which
we further identify with the geometric maximum overlap.

## 3. Structural observation

For interval graphs the eliminating order "latest start first" is a perfect elimination
ordering: when the latest-starting variable is removed, all of its remaining interfering
neighbours are simultaneously live at its start point, hence pairwise overlapping. This is the
computational engine behind linear-scan register allocation and the reason its register count
is optimal.
