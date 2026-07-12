# Computational Evidence — Property B extremal function `m(k)`

The Erdős extremal function `m(k)` is the least number of edges of a non-2-colourable
`k`-uniform hypergraph (a `k`-uniform hypergraph with **no** proper red/blue vertex colouring
that leaves every edge bichromatic). This cycle packages `m(k)` as an explicit natural number
and determines its first two values.

## 1. Small-case values

Known values of `m(k)` (Property B / "chromatic number of hypergraphs" literature):

| k | m(k) | witness of the upper bound |
|---|------|----------------------------|
| 1 | 1    | the single vertex-edge `{{0}}` |
| 2 | 3    | the triangle `{{0,1},{1,2},{0,2}}` |
| 3 | 7    | the Fano plane |
| 4 | 23   | (Östergård, computational) |

General bounds: `2^{k-1} ≤ m(k)` (Erdős 1963, first moment) and
`m(k) = Θ(2^k · √(k/log k))` (Radhakrishnan–Srinivasan / Erdős upper bound).

The lower bound `2^{k-1} ≤ m(k)` was established in the previous cycle. This cycle proves the
two **exact** values `m(1) = 1` and `m(2) = 3`, formalised via a genuine infimum
`m k := sInf {c | ∃ N H, H is k-uniform, #H = c, H non-2-colourable}`.

## 2. Verifying `m(1) = 1`

* Lower bound: `2^{1-1} = 1 ≤ m(1)` (specialisation of the general bound).
* Upper bound: the one-edge hypergraph `{{0}}` on `Fin 1` is non-2-colourable, because its
  single edge `{0}` is entirely red when `0` is red and entirely blue when `0` is blue — checked
  by exhausting the `2^1 = 2` colourings. Hence `1 ∈ mSet 1` and `m(1) ≤ 1`.

## 3. Verifying `m(2) = 3`

* Upper bound: the triangle has `3` edges and is non-2-colourable — of any red/blue split of its
  three vertices, two share a colour and that pair is an edge. Checked by exhausting the
  `2^3 = 8` colourings (`decide`). Hence `3 ∈ mSet 2` and `m(2) ≤ 3`.
* Sharp lower bound `m(2) ≥ 3`: **every graph (2-uniform hypergraph) with at most 2 edges is
  2-colourable.** Two distinct 2-element edges span ≤ 4 vertices and cannot form a cycle
  (which needs ≥ 3 edges), so the graph is a forest and hence bipartite. Explicit colouring:
  - if the two edges share a vertex `v`, colour `R = {v}` red (both edges then meet `R` in a
    single vertex, so neither is monochromatic);
  - if the two edges are disjoint, pick one vertex from each: `R = {a₁, a₂}`.

  Exhaustive small check (the only "shapes" of a ≤2-edge graph up to isomorphism): empty graph,
  single edge, path `a–b–c`, matching `a–b  c–d`. Each is 2-colourable. No 2-edge graph is
  non-2-colourable, so no element of `mSet 2` is `< 3`.

## 4. Counterexample hunt

The universal claim under test is "every 2-uniform hypergraph with `≤ 2` edges is 2-colourable".
Enumerating all graphs on `≤ 4` vertices with `≤ 2` edges (there are finitely many up to the
labelling of `Fin N`) yields **no** non-2-colourable example; the smallest non-2-colourable
graph is the 3-edge triangle. This matches `m(2) = 3` and no counterexample was found.

## 5. Formalised results (`Catalog/Cryptography/PropertyBExtremal.lean`)

* `m`, `mSet` — the extremal function as an `sInf`.
* `m_ge` — `2^{k-1} ≤ m(k)` (general lower bound, repackaged).
* `two_colorable_of_card_le_two` — every ≤2-edge graph is 2-colourable (new; the sharp step).
* `m_one : m 1 = 1`, `m_two : m 2 = 3` — the two exact values.
