# Computational Evidence: the octahedral obstruction to clique-Helliness

## 1. The graph under study

`\overline{3K₂}` is the complement of a perfect matching on six vertices. With the
matching taken to be `{0,1}, {2,3}, {4,5}`, two vertices are adjacent in `\overline{3K₂}`
exactly when they lie in *different* pairs. This is the octahedron `K_{2,2,2}` (the
`3`-part complete multipartite graph with parts of size `2`).

## 2. Maximal cliques

A set is a clique iff it contains at most one vertex from each pair. The maximal cliques are
therefore the `2 · 2 · 2 = 8` triangles obtained by choosing one vertex from each pair:

```
{0,2,4} {0,2,5} {0,3,4} {0,3,5} {1,2,4} {1,2,5} {1,3,4} {1,3,5}
```

Every triangle is maximal: adding any fourth vertex forces two vertices from the same pair,
which are non-adjacent.

## 3. Failure of the Helly property (counterexample hunt)

Take the three triangles

```
T1 = {0,2,4},  T2 = {0,3,5},  T3 = {1,2,5}.
```

Pairwise intersections:

```
T1 ∩ T2 = {0},   T1 ∩ T3 = {2},   T2 ∩ T3 = {5}.
```

All three are nonempty, so the family is **pairwise intersecting**. However

```
T1 ∩ T2 ∩ T3 = ∅,
```

so there is **no common vertex**. This is precisely a violation of the Helly property for
the family of maximal cliques, i.e. the octahedron is not clique-Helly. This is the smallest
such example (six vertices).

## 4. Small-case check of the implication "hereditarily clique-Helly ⇒ `\overline{3K₂}`-free"

- Graphs on `≤ 5` vertices contain no induced `\overline{3K₂}` (it has six vertices), and a
  direct enumeration confirms all of them are clique-Helly, hence hereditarily clique-Helly.
- The octahedron on six vertices is the first graph that is *not* hereditarily clique-Helly,
  and it is exactly an induced `\overline{3K₂}`. So the forbidden-subgraph implication is
  tight at six vertices.

## 5. Note on the reverse implication

The converse ("`\overline{3K₂}`-free ⇒ hereditarily clique-Helly") is **false** in general:
there exist `\overline{3K₂}`-free graphs that contain other minimal non-clique-Helly
configurations (the "ocular"/Hajós graphs). A single forbidden induced subgraph does not
characterize hereditary clique-Helliness for arbitrary graphs; the reference's equivalence
is special to distance-hereditary graphs. This is why only the forward implication is
established here for all graphs.
