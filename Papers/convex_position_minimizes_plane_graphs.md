# Computational Evidence: Plane Graphs on Convex Points

## Combinatorial model

For `n` points in convex position (labeled `0, …, n-1` around the hull), a *chord*
is an unordered pair `{i, j}`. Two chords cross iff their endpoints strictly
interleave around the circle: `{a,b}` and `{c,d}` cross iff `a < c < b < d` (or the
symmetric version). A *plane graph* is a set of chords that is pairwise
non-crossing. Because convex position fixes the cyclic order, crossing depends only
on the labels — so the count of plane graphs on `n` convex points is a purely
combinatorial quantity `numPlane n`.

## Small-case calculations (verified in Lean via `#eval`)

| n | numPlane n |
|---|-----------|
| 3 | 8         |
| 4 | 48        |
| 5 | 352       |

These were computed directly from the definition (enumerate all subsets of the
`C(n,2)` chords, keep the non-crossing ones).

## OEIS search results

The sequence `1, 1, 2, 8, 48, 352, 2896, …` is **OEIS A054726**: "Number of
graphs on n nodes on a circle without crossing edges" (equivalently, non-crossing
graphs on n points in convex position). Our `numPlane 3 = 8`, `numPlane 4 = 48`,
`numPlane 5 = 352` match A054726 exactly, confirming the model is faithful.

A054726 is known to grow like `c · n^{-3/2} · β^n` with `β ≈ 11.6` — this is the
"~11.65^n" figure quoted for convex position in the research description.

## Lower-bound construction (the fan)

The fan triangulation from vertex `0` (all chords `{0,k}` together with all
boundary edges `{k,k+1}`) is plane and has `2n-3` edges. Every subset of a plane
graph is plane, so the number of plane graphs is at least `2^(2n-3)`.

Checks:
- n = 3: `2^(2·3-3) = 2^3 = 8 = numPlane 3` (bound is tight here).
- n = 4: `2^5 = 32 ≤ 48`.
- n = 5: `2^7 = 128 ≤ 352`.

## Directional evidence for the conjecture

A triangulation of a point set with `n` points and `h` on the convex hull has
`3n - 3 - h` edges (Euler's formula). All `2^(3n-3-h)` subsets are plane. This
lower bound is *decreasing* in `h`, and is minimized exactly at `h = n` (convex
position), where it equals `2^(2n-3)`. This monotonicity is the arithmetic core of
why convex position should minimize the plane-graph count, and is what we
formalize.

## Counterexample hunt

No counterexample to the formalized statements was found: `numPlane n ≥ 2^(2n-3)`
holds for all tested `n`, and the fan-subset bound `triLB n n ≤ triLB n h` for
`h ≤ n` held on all sampled `(n,h)`.
