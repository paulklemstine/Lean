# Computational Evidence — Chromatic Polynomial of the Friendship Graph

## The object

The **friendship (windmill) graph** `F_n` is `n` triangles sharing one common central vertex.
In the "emotions" reading, `chromVal n q` counts assignments of `q` emotions to the `2n+1` people
so that no two friends share an emotion.

## Conjectured closed form

    P(F_n, q) = q · ((q-1)(q-2))^n

Reasoning: the centre takes any of `q` emotions; each triangle's two outer vertices must both differ
from the centre and from each other, giving `(q-1)(q-2)` ordered choices per triangle, and the `n`
triangles are independent.

## Small-case brute force (via the honest definition `chromVal`)

Evaluating the *definition* `chromVal n q = #{proper colourings}` directly (Lean `#eval`) against the
closed form `q·((q-1)(q-2))^n` for `n ∈ {0,1,2,3}`, `q ∈ {0,…,5}` gives an exact match in every cell:

| n \ q | 0 | 1 | 2 | 3  | 4   | 5    |
|-------|---|---|---|----|-----|------|
| 0     | 0 | 1 | 2 | 3  | 4   | 5    |
| 1     | 0 | 0 | 0 | 6  | 24  | 60   |
| 2     | 0 | 0 | 0 | 12 | 144 | 720  |
| 3     | 0 | 0 | 0 | 24 | 864 | 8640 |

(Both `chromVal` and the formula produce identical tables; no discrepancy found.)

## The `q = 6` case (six basic emotions)

`P(F_n, 6) = 6 · (5·4)^n = 6 · 20^n`:  `120, 2400, 48000, …` for `n = 1, 2, 3`.
Matches the brute-force count. This is the value asserted by the original conjecture.

## Sanity checks / edge cases

- `n = 0` (lone centre): `P = q`, correct (one vertex, `q` colours).
- `q = 2`, `n ≥ 1`: `2·0^n = 0` — a triangle is not 2-colourable, so no assignment exists. Correct.
- `q = 1`: always `0` for `n ≥ 1`; the formula gives `1·(0·(-1))^n = 0` (natural subtraction), correct.

## OEIS

The `q = 6` row `6, 120, 2400, 48000, …` is `6·20^n`; the general two-variable form is the standard
windmill/friendship chromatic polynomial and needs no external table.

## Conclusion

The closed form is confirmed on all tested cases with no counterexample. The Lean development
`Catalog/Novelty/FriendshipChromaticPolynomial.lean` proves it for all `n, q` bijectively.
