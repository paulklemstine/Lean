# Computational Evidence — Cycle-containing families of vectors

## Setup recap

For an alphabet `[b] = Fin b` and length `k`, each ordered pair of vectors
`u, v ∈ [b]^k` defines a bipartite graph on `[b] ⊔ [b]`: coordinate `i`
contributes the edge `inl (u i) — inr (v i)`.  A pair is **cycle-containing**
when this graph contains a cycle.  A family `C ⊆ [b]^k` is **cyclic** when every
pair of distinct members is cycle-containing.  We write `M_b(k)` for the maximum
size of a cyclic family.

## 1. Small-case calculations (binary alphabet `b = 2`)

For `b = 2` the bipartite graph has 4 possible edges and its only possible cycle
is the 4-cycle of `K₂,₂`; hence a pair is cycle-containing iff **all four
patterns** `(0,0), (0,1), (1,0), (1,1)` occur among the coordinates
(*qualitative independence*).  Exhaustive maximum-clique computation over the
"qualitative-independence graph" on the `2^k` binary vectors gives:

| k | M₂(k) |
|---|-------|
| 2 | 1     |
| 3 | 1     |
| 4 | 3     |
| 5 | 4     |
| 6 | 10    |
| 7 | 15    |

Observations:
* `M₂(k) = 1` for `k ≤ 3` — no pair can exhibit four patterns with `< 4`
  coordinates.  (Formalized: `cyclicFamily_card_le_one_of_small`.)
* The first nontrivial value is `M₂(4) = 3`, attained by the explicit triple
  `{0011, 0101, 0110}`.  (Formalized as a genuine cyclic family:
  `exists_cyclicFamily_card_three`.)

## 2. The girth threshold (all `b`)

Across every alphabet size, a single cycle-containing pair already forces
`k ≥ 4`, because the bipartite graph is triangle-free (even bipartite) so its
shortest cycle has length `4`, requiring `4` distinct edges from `4` distinct
coordinates.  This is the alphabet-uniform fact `containsCycle_k_ge_four`.
It matches the table: `M_b(k) = 1` whenever `k ≤ 3`.

## 3. OEIS search

The binary sequence `1, 1, 3, 4, 10, 15` (offset `k = 2`) is the clique number of
the qualitative-independence graph.  A definitive OEIS identification was not
established with confidence, so no OEIS ID is asserted here; the values are
reported as directly computed.

## 4. Counterexample hunt

* The universal claim "`ContainsCycle u v → 4 ≤ k`" was tested against the
  formal proof rather than sampling, and holds with no exceptions (it is proved
  for all `b, k`).
* The triple `{0011, 0101, 0110}` was checked exhaustively (`decide`): all three
  pairs realise all four patterns, and the family has exactly three elements.

## Notes

Computations used a bitset Bron–Kerbosch maximum-clique routine over the
`2^k`-vertex qualitative-independence graph; runtimes are negligible through
`k = 7` and grow as expected beyond.  The exact extremal value `N_b(k)` for large
`k` (the full research conjecture) was **not** resolved computationally and is
left as an open target in `FUTURE_DIRECTIONS.md`.
