# Computational Evidence — Uniqueness of Minimal Median Decompositions

This note records the small-case computations that motivated the formal development
in `Core.lean` and `GraphMedian.lean`. The central object is the ternary median
`m(a,b,c) = (a⊓b) ⊔ (b⊓c) ⊔ (c⊓a)` and the claim that, in a distributive lattice /
hypercube, it is the **unique** element lying on all three pairwise geodesics.

## 1. The median is the coordinatewise majority (hypercube `Boolⁿ`)

For Boolean vectors the median is computed coordinatewise, and per coordinate it is
the majority of the three bits:

| a | b | c | m = maj(a,b,c) | in {a,b}? | in {b,c}? | in {a,c}? |
|---|---|---|-----|-----------|-----------|-----------|
| 0 | 0 | 0 | 0 | ✓ | ✓ | ✓ |
| 0 | 0 | 1 | 0 | ✓ | ✓ | ✓ |
| 0 | 1 | 0 | 0 | ✓ | ✓ | ✓ |
| 0 | 1 | 1 | 1 | ✓ | ✓ | ✓ |
| 1 | 0 | 0 | 0 | ✓ | ✓ | ✓ |
| 1 | 0 | 1 | 1 | ✓ | ✓ | ✓ |
| 1 | 1 | 0 | 1 | ✓ | ✓ | ✓ |
| 1 | 1 | 1 | 1 | ✓ | ✓ | ✓ |

Every row has the median agreeing with both endpoints of each pair, i.e. it lies in
the coordinatewise interval of each pair. This is exactly `cubeMed_between` and the
per-coordinate engine behind `hamming_between_iff`.

## 2. A worked geodesic-uniqueness check in `Q₃` (the 3-cube)

Take `a = 000`, `b = 011`, `c = 101` (as bit strings).
- `a⊓b = 000`, `b⊓c = 001`, `c⊓a = 000`, so `m = 000 ⊔ 001 ⊔ 000 = 001`.
- Hamming distances: `d(a,b)=2`, `d(b,c)=2`, `d(a,c)=2`.
- Check `m = 001` is between each pair:
  - `d(a,m)+d(m,b) = d(000,001)+d(001,011) = 1+1 = 2 = d(a,b)` ✓
  - `d(b,m)+d(m,c) = d(011,001)+d(001,101) = 1+1 = 2 = d(b,c)` ✓
  - `d(a,m)+d(m,c) = d(000,001)+d(001,101) = 1+1 = 2 = d(a,c)` ✓
- Exhaustive search over all 8 vertices of `Q₃` shows `001` is the **only** vertex on
  all three geodesics — matching `cube_existsUnique_median`.

## 3. `C₄ = Q₂` is a median graph (no counterexample at dimension 2)

A natural worry: is the 4-cycle a counterexample to median uniqueness? It is not —
`C₄` is exactly the 2-cube `Q₂`, hence median. For `a=01, b=10, c=11`:
`m = (01⊓10)⊔(10⊓11)⊔(11⊓01) = 00 ⊔ 10 ⊔ 01 = 11`, and `11` is the unique vertex on
all three geodesics. This is why the formal boundary in the Lab Notes is placed at
*non-distributivity* (e.g. the lattices `M₃`, `N₅`), not at small cycles.

## 4. Counterexample hunt — where uniqueness fails

The universal claim "every triple has a unique median" is **false** outside median
graphs. Two representative failures:
- **`K₃` (triangle):** for three pairwise-adjacent vertices `a,b,c` (all distances 1),
  no vertex satisfies all three betweenness equalities, so a median does *not exist*.
  This is the metric shadow of `cubeGraph_cliqueFree_three`: a triangle cannot embed
  in any hypercube.
- **Non-distributive lattices `M₃`/`N₅`:** the join-of-meets and meet-of-joins forms
  of the median differ, so the interval intersection is not a singleton and the median
  is not unique. This pinpoints distributivity as the exact hypothesis (`medL_eq_infForm`).

## 5. OEIS note

The number of triangle-free... is not the relevant sequence here; the directly
relevant count is the order of the hypercube `Q_n`, `|V(Q_n)| = 2ⁿ`
(OEIS A000079: 1, 2, 4, 8, 16, 32, …), the vertex set on which the median operation
acts. No new integer sequence is produced by this cycle; the content is structural
(uniqueness), not enumerative.

## Conclusion

All small cases support the formalized statements: the coordinatewise median is the
unique vertex on the three pairwise geodesics of a hypercube, and uniqueness degrades
exactly when distributivity fails. These observations are discharged in Lean with zero
`sorry` in `Core.lean` (`medL_unique`) and `GraphMedian.lean`
(`cube_existsUnique_median`).
