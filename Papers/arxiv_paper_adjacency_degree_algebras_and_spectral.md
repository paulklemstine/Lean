# Computational Evidence — Adjacency-degree moments

All numbers below were produced by exploratory scripts (exact integer arithmetic) *before*
formalisation, to select which statements to prove.  They are **exploratory numerics, not
verified computations**; every claim that ended up in the deliverable is proved in Lean
(`Catalog/Physics/AdjacencyDegree/*.lean`, no `sorry`, only the standard axioms
`propext`, `Classical.choice`, `Quot.sound`).

## 1. Small-case moment tables

For a graph `G` write `m(w) = 𝟏ᵀ w(A_G, D_G) 𝟏` for a word `w` in the letters `A`
(adjacency) and `D` (degree).

| graph | degree sequence | `m(∅)` | `m(A)` | `m(D)` | `m(AA)` | `m(DD)` | `m(DAD)` | `m(ADA)` | `m(DADAD)` | `m(DAAD)` |
|---|---|---|---|---|---|---|---|---|---|---|
| `C₆` | 2,2,2,2,2,2 | 6 | 12 | 12 | 24 | 24 | 48 | 48 | 192 | 96 |
| `K₃ ⊔ K₃` | 2,2,2,2,2,2 | 6 | 12 | 12 | 24 | 24 | 48 | 48 | 192 | 96 |
| `P₄` | 1,1,2,2 | 4 | 6 | 6 | 10 | 10 | 16 | 18 | 44 | 26 |
| `K₁,₃` | 1,1,1,3 | 4 | 6 | 6 | 12 | 12 | 18 | 30 | 54 | 36 |
| `T₁` (8 vtx) | 1,1,1,1,2,2,3,3 | 8 | 14 | 14 | 30 | 30 | 58 | 74 | 258 | 124 |
| `T₂` (8 vtx) | 1,1,1,1,2,2,3,3 | 8 | 14 | 14 | 30 | 30 | 62 | 74 | 312 | 132 |

Observations that guided the formalisation:

* `C₆` and `K₃ ⊔ K₃` agree in **every** column.  Both are 2-regular on 6 vertices; this is the
  numerical shadow of the theorem `wordMoment_of_regular` (`m(w) = k^{|w|} n`), now proved in
  `RegularFailure.lean`.
* `T₁`, `T₂` are the two 8-vertex trees with degree sequence `(1,1,1,1,2,2,3,3)` used here; the
  pure-`A` and pure-`D` moments coincide but the first decorated caterpillar `DAD` already
  separates them (58 vs 62).  `DAD` is exactly `∑_{u~v} d_u d_v`, i.e. the joint degree
  distribution — this motivated `EdgeStatistics.lean`
  (`degreePairCount_eq_of_wordMoment_eq`).
* `m(A) = m(D) = 2|E|` and `m(DD) = ∑ d_v²` in every row, matching `moment_adjMatrix` and
  `moment_degMatrix_pow`.

## 2. Counterexample hunt (exhaustive, connected graphs, n ≤ 6)

Fingerprint = the vector of all moments `m(w)` for `|w| ≤ 6`.  Graphs were enumerated by
adjacency bitmask, filtered for connectivity, grouped by fingerprint, and each group was split
into isomorphism classes by brute-force permutation search.

| n | connected fingerprint classes | classes containing ≥ 2 isomorphism types |
|---|---|---|
| 3 | 2 | 0 |
| 4 | 6 | 0 |
| 5 | 21 | 0 |
| 6 | 109 | 3 |

The three colliding classes at `n = 6` (each: a triangle-free graph vs. a graph with two
triangles):

1. `{03,04,05,13,15,23,24}` vs `{01,02,05,15,23,24,34}` — degrees `(3,3,2,2,2,2)`, **not
   regular**;
2. `{03,04,05,13,14,15,23,24}` vs `{01,03,05,12,15,23,24,34}` — degrees `(3,3,3,3,2,2)`;
3. `K₃,₃` vs the triangular prism — 3-regular.

Pair 1 was formalised as `hex1`/`hex2` in `SixVertexWitness.lean`: both are connected and
non-regular, share the equitable quotient `B = [[1,2],[1,1]]` with class sizes `(2,4)`, and are
proved moment-equal in Lean via the general quotient theorem `wordMoment_eq_of_quot_eq`; they
are non-isomorphic because one is triangle-free.

No counterexample was found among connected graphs on ≤ 5 vertices.

## 3. Trees

A separate sweep enumerated all trees by Prüfer sequences, deduplicated them by the AHU
canonical form rooted at the centre(s), and grouped them by the fingerprint of all moments
`m(w)` with `|w| ≤ 7`.

| n | non-isomorphic trees | fingerprint classes | classes with ≥ 2 trees |
|---|---|---|---|
| 3 | 1 | 1 | 0 |
| 4 | 2 | 2 | 0 |
| 5 | 3 | 3 | 0 |
| 6 | 6 | 6 | 0 |
| 7 | 11 | 11 | 0 |
| 8 | 23 | 23 | 0 |
| 9 | 47 | 47 | 0 |

The tree counts reproduce the known sequence 1, 2, 3, 6, 11, 23, 47, which is a consistency
check on the enumeration.  No moment collision between non-isomorphic trees appears for
`n ≤ 9`; this is exploratory numerics only, and the corresponding general statement (McKay's
principal form) is listed as a conjecture in `FUTURE_DIRECTIONS.md` rather than claimed here.
The cases that *are* proved in Lean are the star family (`Synthesis.lean`) and the general
rigidity transfer results (`WalkStatistics.lean`, `CaterpillarRigidity.lean`).
