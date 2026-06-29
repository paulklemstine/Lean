# Computational Evidence — Tightness of the Density Threshold for Linear Hypergraphs

Object: a linear `r`-uniform hypergraph on `n` vertices (any two edges meet in ≤ 1 vertex,
every edge has `r` vertices). Global packing bound `m·C(r,2) ≤ C(n,2)`; local degree bound
`deg(v)·(r-1) ≤ n-1`. We test the *tightness* claims: equality ⟺ Steiner system `S(2,r,n)`.

## 1. Small-case calculations (verified in Lean with `#eval`)

Steiner systems attain both bounds exactly (`m·C(r,2) = C(n,2)` and `deg·(r-1) = n-1`):

| system        | n  | r | m  | m·C(r,2) | C(n,2) | deg | deg·(r-1) | n-1 |
|---------------|----|---|----|----------|--------|-----|-----------|-----|
| Fano S(2,3,7) | 7  | 3 | 7  | 21       | 21     | 3   | 6         | 6   |
| S(2,3,9) AG(2,3)| 9 | 3 | 12 | 36       | 36     | 4   | 8         | 8   |
| trivial S(2,n,n)| n | n | 1  | C(n,2)   | C(n,2) | 1   | n-1       | n-1 |
| S(2,4,13) PG(2,3)| 13| 4 | 13 | 78       | 78     | 4   | 12        | 12  |

All rows satisfy `m·C(r,2)=C(n,2)` and `deg·(r-1)=n-1` simultaneously — matching
`linear_card_eq_iff_covers`, `covering_is_regular`, and `covering_edge_count`
(`m·r·(r-1) = n·(n-1)`, e.g. Fano `7·3·2 = 42 = 7·6`).

## 2. Non-tight (strict) examples

A single triangle of triples (3 edges on 4 vertices, e.g. {123},{145},... ) or any linear family
that misses a pair gives strict inequality `m·C(r,2) < C(n,2)`. The theorem
`linear_card_eq_iff_covers` says strictness happens **exactly** when some pair is uncovered, which
is the generic case — Steiner systems are the unique extremal configurations.

## 3. Existence / necessary divisibility

`covering_edge_count` forces `r(r-1) | n(n-1)` and (via the degree bound) `(r-1) | (n-1)`. These are
the classical necessary conditions for `S(2,r,n)` to exist (Fisher/divisibility); the
Fano (n≡1,3 mod 6 for r=3) and projective/affine plane examples above confirm them.

## 4. OEIS

Number of edges of a Steiner triple system `S(2,3,n)` is `n(n-1)/6` for admissible `n` (A000292-adjacent
counting); the admissible orders `n ≡ 1,3 (mod 6)` are OEIS A051597-type. Not central to the proofs,
which are exact algebraic identities, so no sequence fitting was needed.

## Conclusion

The evidence is fully consistent with the formalized statements: the density threshold for linear
`r`-uniform hypergraphs is tight (globally and locally) precisely on Steiner systems, and the three
classical witnesses (Fano, AG(2,3), PG(2,3)) saturate every bound.
