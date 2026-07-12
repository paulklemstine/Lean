# Computational Evidence — Property B (hypergraph 2-colourability)

**Claim (Erdős 1963).** A hypergraph in which every edge has at least `k ≥ 1` vertices and
which has fewer than `2^{k-1}` edges admits a proper 2-colouring (no edge monochromatic).
Equivalently the extremal function satisfies `m(k) ≥ 2^{k-1}`, where `m(k)` is the least
number of edges of a non-2-colourable `k`-uniform hypergraph.

## 1. Small-case calculations of the threshold `2^{k-1}`

| k | 2^{k-1} | guaranteed 2-colourable if #edges < |
|---|---------|--------------------------------------|
| 1 | 1       | 0 edges (a size-1 edge is always monochromatic, so m(1)=1) |
| 2 | 2       | ≤ 1 edge  (a single edge {a,b}: colour a red, b blue) |
| 3 | 4       | ≤ 3 edges |
| 4 | 8       | ≤ 7 edges |
| 5 | 16      | ≤ 15 edges |
| 6 | 32      | ≤ 31 edges |

Known exact values / bounds of `m(k)`: `m(2)=3` (the triangle `K_3` viewed as three
2-edges is not 2-colourable), `m(3)=7` (the Fano plane), consistent with `m(k) ≥ 2^{k-1}`
(`m(3)=7 ≥ 4`, `m(2)=3 ≥ 2`).

## 2. The counting inequality that drives the proof

For a hypergraph on `N` vertices, colourings are the `2^N` subsets `R ⊆ {1,…,N}` (red set).
A fixed edge `e` with `|e| ≥ k` is monochromatic for exactly
`2^{N-|e|} + 2^{N-|e|} = 2^{N-|e|+1} ≤ 2^{N-k+1}` colourings (all-red or all-blue).
A union bound over `m` edges gives at most `m · 2^{N-k+1}` bad colourings, and

    m · 2^{N-k+1} < 2^{k-1} · 2^{N-k+1} = 2^{N}   ⟺   m < 2^{k-1},

using `(k-1)+(N-k+1) = N` for `1 ≤ k ≤ N`. So strictly fewer than `2^N` colourings are bad,
and a good colouring survives. This is exactly the exponent identity discharged by `omega`
in the Lean proof, and the two per-edge counts are `card_filter_superset` /
`card_filter_disjoint`.

## 3. Counterexample hunt on the hypothesis

- **`m = 2^{k-1}` (equality) is not enough.** For `k = 2`, `2^{k-1}=2`; the triangle
  `{{a,b},{b,c},{a,c}}` has `m = 3 > 2` and is *not* 2-colourable, and even `m(2)=3` shows the
  bound cannot be pushed to `<` at the threshold in general. The theorem correctly requires the
  strict `m < 2^{k-1}`.
- **`k = 1`.** `2^{0} = 1`, so the hypothesis forces `m = 0` (empty hypergraph), which is
  vacuously 2-colourable — matching the fact that any single 1-vertex edge is monochromatic
  under every colouring. The Lean statement handles this (`hk : 1 ≤ k`).
- **Edges larger than `k`.** Making an edge bigger only *reduces* its number of monochromatic
  colourings, so the theorem is stated in the sharp "`≥ k` vertices per edge" form; the usual
  `k`-uniform statement is the special case `PropertyB.property_B`.

## 4. Sanity check performed in Lean

`PropertyB.single_edge_two_colorable` (any edge of size `≥ 2` is properly 2-colourable) and
`PropertyB.property_B_three_edges_three_uniform` (any ≤ 3 triples on 6 vertices are
2-colourable) are proved as concrete corollaries, confirming the machinery fires on explicit
instances.
