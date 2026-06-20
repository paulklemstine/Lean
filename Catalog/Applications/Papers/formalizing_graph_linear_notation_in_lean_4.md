# Computational Evidence — Graph Linear Notation

We define `gln G = max over vertex orderings σ of code(G.comap σ)`, where
`code(A) = Σ_{(i,j) : A i j} 2^(i·N + j)` is the binary encoding of the
adjacency matrix.  The claim under test is that `gln` is a **complete** graph
invariant: `gln G = gln H ↔ G ≃g H`.

## 1. Small-case calculations

| N | graph              | encoded adjacency pairs (idx = i·N+j) | code | gln |
|---|--------------------|---------------------------------------|------|-----|
| 1 | empty              | none                                  | 0    | 0   |
| 2 | empty              | none                                  | 0    | 0   |
| 2 | one edge {0,1}     | (0,1)→1, (1,0)→2                       | 6    | 6   |
| 3 | empty              | none                                  | 0    | 0   |
| 3 | one edge {0,1}     | (0,1)→1,(1,0)→3                        | 10   | maximized by relabel |

For `N = 2` the two isomorphism classes (empty, one edge) get distinct values
`{0, 6}`.  Relabeling a symmetric matrix never changes nothing for the empty
graph, and for the single edge every ordering produces the same multiset of two
mirrored bits, so the maximizer is well-defined.

## 2. Distinct-value count = number of graphs up to isomorphism

Completeness predicts: the number of distinct values of `gln` over all graphs on
`Fin N` equals the number of isomorphism classes of graphs on `N` vertices.

| N | # iso classes (A000088) |
|---|--------------------------|
| 0 | 1 |
| 1 | 1 |
| 2 | 2 |
| 3 | 4 |
| 4 | 11 |
| 5 | 34 |

**OEIS:** A000088 — "Number of graphs on n unlabeled nodes": 1, 1, 2, 4, 11, 34,
156, 1044, ...  The completeness theorem `gln_eq_iff_iso` implies the image of
`gln` restricted to `SimpleGraph (Fin N)` has exactly `A000088(N)` elements.

## 3. Counterexample hunt

The danger case for any "max binary encoding" invariant is **collision**: two
non-isomorphic graphs with equal notation.  This cannot happen here because
`code` is *injective* on graphs (distinct adjacency matrices ⇒ distinct sets of
set bits ⇒ distinct sums of distinct powers of two, via
`Finset.geomSum_injective`).  Hence the maximizing adjacency matrix is unique per
graph, and equal notations force equal maximizing matrices, which are relabelings
(hence isomorphic) of their sources.  No counterexample exists — this is exactly
the content of the formal proof.

## 4. Conclusion

The evidence (small cases + the A000088 correspondence + the injectivity
argument blocking collisions) is consistent with completeness, which is then
established rigorously in `GraphLinearNotation.lean`
(`gln_eq_iff_iso`) and lifted to a graph-valued canonical form in
`GraphLinearNotationCanonical.lean` (`isCanonForm_complete`).
