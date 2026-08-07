# Computational evidence — bipartite extremal numbers of trees

All numbers below come from an exhaustive brute-force search (Python, all `2^C(n,2)` graphs
on `n` labelled vertices, filtered for bipartiteness and for containing no copy of the tree `T`
as a subgraph).  This is *exploratory* data: it is **not** a machine-checked verification.
The machine-checked statements are the Lean theorems in
`Catalog/Combinatorics/BipartiteExtremalTrees.lean`.

## 1. Small-case table

`exBip(n, T)` = maximum number of edges of a `T`-free **bipartite** graph on `n` vertices.

| n | P₄ (path, 4 vtcs) | P₅ (path, 5 vtcs) | K₁,₂ = P₃ | K₁,₃ |
|---|---|---|---|---|
| 2 | 1 | 1 | 1 | 1 |
| 3 | 2 | 2 | 1 | 2 |
| 4 | 3 | 4 | 2 | 4 |
| 5 | 4 | 4 | 2 | 4 |
| 6 | 5 | 5 | 3 | 6 |
| 7 | 6 | 6 | 3 | 6 |

Observations, each matched against a formal theorem:

* **P₄ column is exactly `n - 1`.**  Formalised as `exBip_pathGraph_four`
  (`exBip n P₄ = n - 1` for `n ≥ 2`); the extremal graph is the star `K_{1,n-1}`.
* **K₁,₂ column is exactly `⌊n/2⌋`.**  Formalised as `exBip_starGraph_two`
  (`exBip n K_{1,2} = n / 2`, all `n`); the extremal graph is a maximum matching.
* **K₁,₃ column is `2·⌊n/2⌋` at even `n` (4 ↦ 4, 6 ↦ 6).**  The even-order case is formalised as
  `exBip_starGraph_eq`: `exBip (2N) K_{1,k+1} = k·N` whenever `k ≤ N`, with the `k`-regular
  bipartite circulant as the extremal graph.  At `n = 5, k = 2` the value `4 < ⌊k·n/2⌋ = 5`,
  showing that the parity obstruction in the odd case is real — this is why the formal theorem
  is stated for even order.
* **Fixed parts.** `exBipParts m n K_{1,2} = min(m,n)` (formalised, `exBipParts_starGraph_two`),
  and `exBipParts N N K_{1,k+1} = min(k,N)·N` (formalised in the two regimes `k ≤ N` and
  `N ≤ k`).

## 2. Counterexample hunt

The plausible guess "`exBip(n, P_p) = n - 1` for all `p ≥ 4` and `n` large" is **false** already
for `p = 5`: disjoint copies of `C₄` are `P₅`-free and bipartite with as many edges as vertices,
so `exBip(8, P₅) ≥ 8 > 7`.  The data above (`n ≤ 7`) is consistent with
`exBip(n, P₅) = 4⌊n/4⌋ + max(0, (n mod 4) - 1)`; this is recorded as a conjecture in
`FUTURE_DIRECTIONS.md` rather than as a theorem.  The corresponding guess for `P₄` survives,
because `C₄` itself contains `P₄` — this is exactly the reason the `P₄` case admits the clean
answer `n - 1` that we proved.

## 3. OEIS

The sequences appearing here (`n - 1`, `⌊n/2⌋`, `k⌊n/2⌋`) are elementary and no OEIS lookup was
informative.

## 4. Reproducing

The search enumerates all labelled graphs on `n ≤ 7` vertices, tests bipartiteness by BFS
2-colouring, and tests `T`-containment by trying all injections `V(T) → V(G)`.  Runtime for the
table above is a few seconds; `n = 8` (2²⁸ graphs) was not run.
