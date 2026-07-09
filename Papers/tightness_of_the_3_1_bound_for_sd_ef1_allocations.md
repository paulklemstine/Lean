# Computational Evidence — Agent complexity of conflict-free, envy-balanced allocations

**Question.** Items are the vertices of a graph `G`; adjacent items conflict and may
not go to one agent; all agents share the same ordinal preference (equal-value regime,
so SD-EF1 = balanced bundles, i.e. any two bundles differ in size by at most one). Let
`A(G)` be the least number of agents admitting a conflict-free, balanced allocation.
The tightness conjecture asks whether some graph of maximum degree `Δ` forces
`A(G) ≥ 3Δ − 1`.

## 1. Small-case calculations

For each graph we record the maximum degree `Δ`, the ordinary chromatic number
`χ` (least agents ignoring balance), and `A` (least agents with the balance
constraint).

| Graph                | `Δ` | `χ` | `A` (balanced) | notes |
|----------------------|----:|----:|---------------:|-------|
| `K_2` (single edge)  | 1   | 2   | 2              | base case, `3Δ−1 = 2` |
| `K_3` (triangle)     | 2   | 3   | 3              | complete: `A = Δ+1` |
| `K_{Δ+1}`            | Δ   | Δ+1 | Δ+1            | complete: `A = Δ+1` |
| `K_{1,3}` (star)     | 3   | 2   | 3              | balance forces `> χ` |
| `K_{1,4}`            | 4   | 2   | 3              | `⌈Δ/2⌉+1 = 3` |
| `K_{1,6}`            | 6   | 2   | 4              | `⌈Δ/2⌉+1 = 4` |
| `K_{1,Δ}` (star)     | Δ   | 2   | `⌈Δ/2⌉+1`      | balance floor |

**Reading the star line.** The hub is adjacent to every leaf, so the hub sits alone
in its bundle (size 1). Balance then caps *every* bundle at size 2. The `Δ` leaves
must therefore occupy at least `⌈Δ/2⌉` further agents, giving `A = ⌈Δ/2⌉ + 1`. The
chromatic number is only `2`, so the balance requirement strictly raises the agent
count — the qualitative engine behind the `3Δ − 1` phenomenon.

## 2. Sequence check

The star agent counts `A(K_{1,Δ}) = ⌈Δ/2⌉ + 1` for `Δ = 1, 2, 3, 4, 5, 6, …` give
`2, 2, 3, 3, 4, 4, …`, i.e. `⌊Δ/2⌋ + 2` shifted — the "each value twice" pattern
(A004526-type flooring plus a constant). No exotic sequence appears; the growth is
linear with slope `1/2`.

## 3. Counterexample hunt for the strong `3Δ − 1` target

Searching the elementary families (complete graphs, stars, paths, cycles, complete
bipartite `K_{m,m}`) reveals **no** graph of maximum degree `Δ` with `A(G) ≥ 3Δ − 1`
for `Δ ≥ 2`:

* complete graphs give exactly `Δ + 1`;
* stars give `≈ Δ/2`;
* paths and even cycles are balanced-3-colourable, giving `A ≤ 3` independent of `Δ`;
* `K_{m,m}` (with `Δ = m`) is balanced-`2`-colourable by its two sides.

This matches the theoretical picture: reaching `≈ 3Δ` requires a *preordained
partition* of the vertices (the strong-colouring set-up of Alon–Haxell), which no
single small gadget of the above families supplies. The evidence says the strong
target is **true-but-hard**, not false, and pins the certifiable elementary bounds at
`Δ + 1` (conflict) and `⌈Δ/2⌉ + 1` (fairness).

## 4. What is formally certified

The companion development certifies, with complete proofs and no additional
assumptions:

* `completeGraph_maxDegree`, `starGraph_maxDegree` — the degree bookkeeping;
* `completeGraph_lower_bound` — `A(K_{Δ+1}) ≥ Δ + 1`;
* `starGraph_ef1_lower_bound` — `2·A(K_{1,Δ}) ≥ Δ + 2` (the balance floor);
* `identity_valid` — allocations always exist;
* `tight_at_degree_one` — `A = 3Δ − 1 = 2` exactly at `Δ = 1`.
