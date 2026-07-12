# Computational Evidence: codegree inverse and clique-density lower bounds

## 1. The inclusion–exclusion inverse `deg u + deg v ≤ n + codeg(u,v)`

For an edge `uv`, `codeg(u,v) = |N(u) ∩ N(v)|` is the number of triangles on `uv`.
Small checks on named graphs (n = number of vertices):

| Graph            | n | edge uv            | deg u | deg v | codeg | deg u + deg v | n + codeg |
|------------------|---|--------------------|-------|-------|-------|---------------|-----------|
| K4               | 4 | any edge           | 3     | 3     | 2     | 6             | 6         |
| C5 (5-cycle)     | 5 | any edge           | 2     | 2     | 0     | 4             | 5         |
| K_{3,3}          | 6 | any edge           | 3     | 3     | 0     | 6             | 6         |
| Petersen         |10 | any edge           | 3     | 3     | 0     | 6             | 10        |
| complete K5      | 5 | any edge           | 4     | 4     | 3     | 8             | 8         |

In every row `deg u + deg v ≤ n + codeg` holds, with equality exactly on complete graphs and
complete bipartite graphs (where `N(u) ∪ N(v)` fills the whole vertex set). This equality case is
the "critical threshold" flagged in the mission framing.

## 2. Forced-triangle threshold `deg u + deg v > n ⇒ triangle on uv`

Sharpness: `K_{3,3}` has `deg u + deg v = 6 = n` on every edge and is triangle-free, so the strict
inequality `> n` cannot be relaxed to `≥ n`. Adding one vertex adjacent to an edge's neighbourhood
pushes the sum to `7 > 6` and immediately creates a triangle. This matches
`not_cliqueFree_three_of_deg_sum` (strict `<`) and `mantel_local` (the `≤ n` extremal bound).

## 3. Ordered-triangle identity `∑_u ∑_{v∈N(u)} codeg(u,v) = 6 · (#triangles)`

- K4: each of 4 vertices has degree 3; for each ordered adjacent `(u,v)`, `codeg = 2`. Ordered
  adjacent pairs `= 4·3 = 12`, so LHS `= 12·2 = 24 = 6·4`, and K4 has 4 triangles. ✓
- K5: ordered adjacent pairs `= 5·4 = 20`, each `codeg = 3`, LHS `= 60 = 6·10`, and K5 has
  `C(5,3) = 10` triangles. ✓
- C5: every `codeg = 0`, LHS `= 0 = 6·0`, C5 is triangle-free. ✓

The factor `6 = 3!` is the number of orderings of a triangle's three vertices; each unordered
triangle contributes exactly six ordered mutually-adjacent triples.

## 4. Goodman-type global bound

Combining 1 and 3 termwise gives
`∑_u ∑_{v∈N(u)} (deg u + deg v) ≤ n · (∑_u deg u) + 6·(#triangles)`,
i.e. `∑_v deg(v)^2` on the left (since `∑_{v∈N(u)} deg u = deg(u)^2` and the symmetric term sums to
`∑ deg^2` as well), yielding the classical statement that the triangle count is bounded below by a
quadratic in the degree sequence. Spot check on K4: LHS `= ∑_u ∑_{v∈N(u)}(3+3) = 12·6 = 72`;
RHS `= 4·(4·3) + 6·4 = 48 + 24 = 72`. Equality on complete graphs, as expected. ✓

## Conclusion
No counterexamples were found to any claimed inequality across complete, cyclic, bipartite, and
Petersen test cases. All equality cases occur exactly where `N(u) ∪ N(v)` saturates the vertex set,
confirming the "critical threshold" reading of the codegree inverse.
