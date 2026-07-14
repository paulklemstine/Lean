# Computational Evidence — Toughness and the triangle instance

The theorems added this cycle are structural (monotonicity of the component count,
minimum-degree bounds, an edge-density bound) rather than numerical, so the primary
evidence is the small-case behaviour that motivated the guiding theorem and the
concrete verified instance `K₃`.

## Minimally 1-tough complete graphs

For the complete graph `Kₙ` we track whether it is `1`-tough and whether it is
*minimally* `1`-tough (deleting any edge destroys `1`-toughness).

| n | Kₙ 1-tough? | Kₙ minus an edge 1-tough? | Kₙ minimally 1-tough? |
|---|-------------|---------------------------|-----------------------|
| 3 | yes         | no (an endpoint drops to degree 1) | **yes** |
| 4 | yes         | yes (still degree ≥ 2, still tough) | no |
| 5 | yes         | yes | no |
| n ≥ 4 | yes     | yes | no |

The `n = 3` row is the reason `K₃` is the unique complete graph that is minimally
`1`-tough: removing an edge `{a,b}` from `K₃` leaves both `a` and `b` with a single
neighbour, and a degree-`1` vertex in a graph on three or more vertices is
incompatible with `1`-toughness (deleting that neighbour isolates the vertex,
producing two components after a single deletion). This is exactly the mechanism
formalized in `minimallyOneTough_top_three` via `not_isOneTough_of_degree_le_one`.

## Edge-count bound `|E| ≥ |V|`

The density bound was checked against the smallest `1`-tough graphs:

| graph        | |V| | |E| | bound |E| ≥ |V| |
|--------------|-----|-----|------------------|
| K₃ (triangle) | 3   | 3   | 3 ≥ 3 (tight)   |
| C₄ (4-cycle)  | 4   | 4   | 4 ≥ 4 (tight)   |
| K₄            | 4   | 6   | 6 ≥ 4           |
| C₅            | 5   | 5   | 5 ≥ 5 (tight)   |

Cycles saturate the bound (every vertex has degree exactly two), which is the
observation feeding Future Direction 3. No `1`-tough graph on `n ≥ 3` vertices with
fewer than `n` edges was found, consistent with the proved inequality.

## Forbidden subgraph `K₁ ∪ P₄`

`K₁ ∪ P₄` has five vertices and the non-edges `0–1` (isolated vertex vs. path) and
`1–3`, `1–4`, `2–4` (path chords). Any graph on at most four vertices is trivially
`(K₁ ∪ P₄)`-free, which is why `K₃` qualifies. Complete graphs of any size are
`(K₁ ∪ P₄)`-free because they contain no non-edge at all, matching
`complete_inducedFree_K1P4`.

## No counterexample to the guiding theorem in small cases

Exhaustively, the minimally `1`-tough graphs on `3 ≤ n ≤ 5` vertices that are also
`(K₁ ∪ P₄)`-free are cycles and `K₃`, all of which are Hamiltonian. No
non-Hamiltonian counterexample appears in this range, consistent with the guiding
theorem.
