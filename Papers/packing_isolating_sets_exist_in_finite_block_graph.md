# Computational Evidence — Packing-Isolating Sets in Block Graphs

**Claim under study.** Every finite block graph has a vertex set `S` that is
simultaneously a 2-packing (closed neighborhoods of distinct members disjoint) and an
isolating set (every edge has an endpoint in `N[S]`).

## 1. Small-case calculations

### Paths `P_n` (trees; all blocks are `K₂`)
Using the periodic set `S = { i : i ≡ 1 (mod 3) }` (0-indexed):

| n | edges | S (indices ≡ 1 mod 3) | 2-packing? | isolating? |
|---|-------|------------------------|-----------|-----------|
| 1 | —     | ∅ ... {} (no index ≡1) → but P₁ has no edge | trivially | trivially |
| 2 | {0-1} | {1}                    | yes        | yes (N[1]={0,1}) |
| 3 | {0-1,1-2} | {1}                | yes        | yes (N[1]=all) |
| 4 | path  | {1}                    | yes        | edge 2-3: N[1]∋2 ✓ |
| 5 | path  | {1,4}                  | gap 3 ✓    | all edges covered ✓ |
| 6 | path  | {1,4}                  | gap 3 ✓    | edge 4-5: N[4]∋5 ✓ |
| 7 | path  | {1,4}                  | yes        | edge 5-6: N[4]∋5 ✓ |

Note the **backward witness** subtlety: for an edge `{a,a+1}` with `a ≡ 2 (mod 3)`,
coverage uses the vertex `a-1 ≡ 1 (mod 3)`, never overflowing the right endpoint.
This is why a *maximal* 2-packing need not be isolating — e.g. in `P₆` the two
endpoints `{0,5}` form a maximal 2-packing that leaves edge `{2,3}` uncovered — whereas
the *aligned* periodic set `{1,4}` works.

### Complete graphs `K_{n+1}` (single clique block)
Any single vertex `v` has `N[v] = V`, so `{v}` is dominating, hence isolating, and a
singleton is trivially a 2-packing. Verified for all `n` by the formal proof.

## 2. Counterexample hunt (necessity of the hypothesis)

Exhaustive search over all `2^|V|` vertex subsets:

| graph | block graph? | has packing-isolating set? |
|-------|--------------|----------------------------|
| `K₃`  | yes (one clique) | yes ({any vertex})     |
| `C₄`  | no           | yes ({any vertex}; N[v] leaves 1 isolated vertex) |
| `C₅`  | no           | **NO** (exhaustive `decide`) |
| `C₆`  | no           | yes ({0,3})                |

`C₅` is the decisive counterexample to dropping the block-graph hypothesis: it has
diameter 2 (so no 2-packing of size ≥ 2 exists) yet every single vertex leaves an
uncovered edge. This is formalized as `C5_no_packingIsolating` via a kernel `decide`.

## 3. OEIS

No integer sequence is the object of study here (the statement is a universally
quantified existence claim), so no OEIS lookup applies.

## 4. Summary

The computational evidence supports the conjecture on every block graph tested, and
sharply locates the boundary at `C₅`. The formal development proves the two structurally
extremal families (paths = chains of `K₂` blocks; complete graphs = a single clique
block) and the `C₅` necessity, leaving the general block-graph case as a documented
future direction.
