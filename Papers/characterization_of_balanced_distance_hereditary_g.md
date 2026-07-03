# Computational Evidence — the forbidden graph `\overline{3K₂}`

All computations below are over the six vertices `{0,1,2,3,4,5}` with the matched
pairs `{0,1}`, `{2,3}`, `{4,5}`. `3K₂` is the perfect matching on these pairs;
`\overline{3K₂}` is its complement.

## 1. Small-case calculations

### Adjacency matrix of `3K₂` (rows/cols 0..5), `1` = edge
```
    0 1 2 3 4 5
0 [ . 1 . . . . ]
1 [ 1 . . . . . ]
2 [ . . . 1 . . ]
3 [ . . 1 . . . ]
4 [ . . . . . 1 ]
5 [ . . . . 1 . ]
```
Every row sum is `1`  ⟹  `3K₂` is **1-regular** (a perfect matching).
Verified formally: `matching3_regular`.

### Adjacency matrix of `\overline{3K₂}` (the octahedron `K_{2,2,2}`)
```
    0 1 2 3 4 5
0 [ . . 1 1 1 1 ]
1 [ . . 1 1 1 1 ]
2 [ 1 1 . . 1 1 ]
3 [ 1 1 . . 1 1 ]
4 [ 1 1 1 1 . . ]
5 [ 1 1 1 1 . . ]
```
Every row sum is `4`  ⟹  `\overline{3K₂}` is **4-regular**.
Verified formally: `coMatching3_regular`.

### Unique non-neighbour table for `\overline{3K₂}`
| vertex `v` | its unique non-neighbour |
|---|---|
| 0 | 1 |
| 1 | 0 |
| 2 | 3 |
| 3 | 2 |
| 4 | 5 |
| 5 | 4 |

Each vertex has **exactly one** non-neighbour (its matched partner).
Verified formally: `coMatching3_nonadj_unique`.

## 2. Structural identification (OEIS / named-object search)

`\overline{3K₂}` is the complete tripartite graph `K_{2,2,2}`, classically known as
the **octahedron** / **cocktail-party graph** `K_{3×2}`. It is the unique
`4`-regular graph on `6` vertices with independence number `2`. Verified formally
as a graph isomorphism: `octahedronIso : coMatching3 ≃g completeMultipartiteGraph
(fun _ : Fin 3 => Fin 2)`.

(There is no numeric OEIS sequence to attach here — the object is a single named
graph, not a counting sequence.)

## 3. Counterexample hunt (induced `P₄`)

An induced path `a–b–c–d` requires its endpoint `a` to be **non-adjacent** to both
`c` and `d`. In `\overline{3K₂}` each vertex has only one non-neighbour, so `c` and
`d` would have to coincide — impossible. A brute check over all `6·5·4·3 = 360`
ordered `4`-tuples finds **no** induced `P₄`. Hence `\overline{3K₂}` is a cograph.
Verified formally (structurally, not by enumeration): `coMatching3_isP4Free`.

Conversely, `\overline{3K₂}` **does** contain an induced `4`-cycle, e.g.
`0 – 2 – 1 – 3 – 0`:
* edges `0–2, 2–1, 1–3, 3–0` are all present (different pairs), and
* the diagonals `0–1` and `2–3` are the non-edges.

So `\overline{3K₂}` is a *proper* cograph. Verified formally:
`coMatching3_has_induced_C4`.

## 4. Independence number

Any pairwise non-adjacent set of vertices of `\overline{3K₂}` must live inside a
single matched pair, so it has at most `2` elements: the independence number is `2`
(attained by any pair `{0,1}`, `{2,3}`, `{4,5}`). Verified formally:
`coMatching3_independent_card_le`.

## Summary

Every claim above is backed by a fully proved, `sorry`-free Lean theorem in
`ForbiddenSubgraph.lean` and `CographObstruction.lean`; the computations here are
the small-case evidence that motivated those theorems.
