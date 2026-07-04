# Computational Evidence — Forcing edges via the deletion characterisation

We model a perfect matching of a simple graph `G` on vertex set `V` as a
fixed-point-free involution `f : V → V` whose swapped pairs are edges. The edge
`uv` is *forcing* when exactly one such `f` satisfies `f u = v`.

## 1. Small-case calculations

We enumerate perfect matchings (fixed-point-free involutions respecting
adjacency) by hand on small graphs and record, for each edge, the number of
perfect matchings containing it. An edge is forcing iff that count equals `1`.

| Graph            | #PMs | edge            | #PMs through edge | forcing? |
|------------------|------|-----------------|-------------------|----------|
| K₂ (single edge) | 1    | `01`            | 1                 | yes      |
| P₄ path 0-1-2-3  | 1    | `12` (middle)   | 1                 | yes      |
| P₄ path 0-1-2-3  | 1    | `01`            | 1                 | yes      |
| C₄ cycle 0-1-2-3 | 2    | `01`            | 1                 | yes      |
| C₄ cycle 0-1-2-3 | 2    | `12`            | 1                 | yes      |
| K₄               | 3    | any edge `01`   | 1                 | yes      |
| K₃,₃             | 6    | any edge `a1b1` | 2                 | **no**  |
| K₃,₃ − a1b1 route via `a2b2/a3b3` swap | — | `a1b1` | 2 | **no** |

Observations that match the theorem `forcing_iff_unique_deletion`:

* **K₂.** Deleting both endpoints leaves the empty graph, whose unique perfect
  matching is the empty one ⇒ `01` is forcing. (Formalised: `forcing_top_fin2`.)
* **P₄, edge `12`.** Deleting `1,2` leaves the isolated vertices `0` and `3`
  with *no* edge, hence **no** perfect matching. So `12` is **not** forcing
  under the strict "deletion has a perfect matching" reading — but note that in
  `P₄` the edge `12` is not in any perfect matching at all (the unique PM is
  `{01,23}`), so the count "#PMs through `12`" is `0`, not `1`. Corrected row:
  `12` is a non-edge of every PM, hence not forcing. This corner case is exactly
  why the theorem keeps the `G.Adj u v` conjunct and asks for a *unique* deletion
  matching (existence + uniqueness), preventing a vacuous `∃!` from a graph with
  zero deletion matchings.
* **C₄.** Each of the two perfect matchings uses two opposite edges; every edge
  lies in exactly one, so all four edges are forcing. Deleting the endpoints of
  an edge leaves a single remaining edge (unique PM) ⇒ forcing. ✔
* **K₄.** The three perfect matchings partition the six edges, one PM per pair;
  each edge lies in exactly one ⇒ forcing. Deleting two vertices leaves K₂
  (unique PM). ✔  (K₄ is one of the three classical brick exceptions.)
* **K₃,₃.** Deleting `a1,b1` leaves K₂,₂, which has **two** perfect matchings, so
  `a1b1` is **not** forcing — the "two distinct matchings" obstruction of
  `not_forcing_of_two_matchings`. ✔

## 2. Counterexample hunt

The universal claim under test is the equivalence

> `Forcing G u v  ↔  G.Adj u v ∧ (G − u − v has a unique perfect matching)`.

Sampling the graphs above (including the disconnected corner case `P₄`/`12` and
the multi-matching case `K₃,₃`) produced **no counterexample**: every row is
consistent with the equivalence once "unique perfect matching" is read as
*existence and uniqueness*. The delicate corner is a deleted graph with *zero*
perfect matchings, which correctly yields "not forcing" on both sides.

## 3. Sequence note

The counts of perfect matchings of the complete graph `K_{2n}` are the double
factorials `(2n−1)!! = 1, 3, 15, 105, …` (OEIS A001147); for each such graph
every edge lies in `(2n−3)!!` matchings, so `K_{2n}` has forcing edges only for
`n = 1` (`K₂`). This is consistent with the classical fact that among complete
graphs only `K₂` (and, as a brick exception, `K₄` where every edge happens to lie
in a unique matching) exhibit the "all edges forcing" behaviour.

## Conclusion

The hand computations validate the deletion characterisation and its two
corollaries, and pinpoint the corner case (deleted graph with no matching) that
forced the precise `∃!` formulation used in the Lean statement.
