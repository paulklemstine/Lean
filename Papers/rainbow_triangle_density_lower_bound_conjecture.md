# Computational Evidence — Rainbow triangle density bound

All numbers below were computed in Lean (`#eval`) against the formal definition
`rtBound n = ((n-1)*(n-3) + 7) / 8` and `Nat.choose`.

## 1. Small-case table of the bound `⌈(n-1)(n-3)/8⌉`

| n  | rtBound n | C(n,3) = rt(properly-coloured Kₙ) |
|----|-----------|------------------------------------|
| 3  | 0         | 1   |
| 4  | 1         | 4   |
| 5  | 1         | 10  |
| 6  | 2         | 20  |
| 7  | 3         | 35  |
| 8  | 5         | 56  |
| 9  | 6         | 84  |
| 10 | 8         | 120 |
| 11 | 10        | 165 |
| 12 | 13        | 220 |
| 13 | 15        | 286 |
| 14 | 18        | 364 |
| 15 | 21        | 455 |

Observations:
* `rtBound n = 0` iff `n ≤ 3` (formalised as `rtBound_zero_iff`); the bound becomes
  non-trivial from `n = 4`.
* `rtBound n ≤ C(n,3)` holds with large slack (formalised as `rtBound_le_choose`); a
  properly coloured complete graph has *all* `C(n,3)` triangles rainbow, so it satisfies
  the conjectured inequality with room to spare.
* The conjecture's tightness comes from non-complete graphs / non-proper colourings in the
  regime `δc(G) = ⌈(n+1)/2⌉`, which the complete-graph family does not probe.

## 2. The bound sequence

The values `rtBound 3, rtBound 4, … = 0,1,1,2,3,5,6,8,10,13,15,18,21,…`
are the integer ceilings `⌈(n-1)(n-3)/8⌉`.  We deliberately do **not** assert an OEIS
identifier, since we did not verify one against the database; the closed form
`⌈(n-1)(n-3)/8⌉` is the authoritative description and is what is proven in `Bound.lean`.

## 3. Counterexample hunt (within the formalised family)

For properly edge-coloured complete graphs `Kₙ` we checked the conjectured inequality
`rt(G) ≥ rtBound n` for all `n` in the table: it holds in every case (and is proven in
general as `complete_proper_conjecture`).  No counterexample exists in this family because
`rt = C(n,3) ≥ rtBound n` unconditionally.

## 4. Hypothesis regime check

A properly coloured `Kₙ` has colour degree `n - 1` at every vertex.  For `n ≥ 3`,
`n - 1 ≥ ⌈(n+1)/2⌉`, so the family lies inside the conjecture's hypothesis
`δc(G) ≥ (n+1)/2` (formalised as `complete_proper_meets_hypothesis`).  Hence the family is a
*genuine* witness: it satisfies both the hypothesis and the conclusion.
