# Computational Evidence: Power-of-Two Matching Counts

## Small cases (verified directly in the formal development)

| Graph | Vertices | Perfect matchings | Power of two? |
|-------|----------|-------------------|---------------|
| `C₄` (quadrilateral) | 4 | 2 | `2¹` |
| `C₆` (hexagon)       | 6 | 2 | `2¹` |
| `blockGraph (Fin n) C₄` | `4n` | `2ⁿ` | `2ⁿ` |

The two base counts `matchCount C4 = 2` and `matchCount C6 = 2` are obtained by
exhaustive evaluation of the fixed-point-free adjacency-respecting involutions.
The block counts follow from the multiplicative law
`matchCount (blockGraph ι G) = matchCount G ^ card ι`.

## The two matchings of an even cycle

For `C₄` on vertices `0,1,2,3` the two perfect matchings are
`{01, 23}` and `{12, 30}`; for `C₆` they are the two alternating sets of
non-adjacent edges. Every even cycle has exactly these two, which is why each is a
"two-matching gadget".

## Sequence check

The block-of-quadrilaterals counts `1, 2, 4, 8, 16, …` (as the block count
`n = 0,1,2,3,4,…`) are the powers of two, OEIS A000079. No other value appears,
consistent with the theorem.

## Counterexample hunt

The general claim "every connected graph has a power-of-two matching count" is
false (e.g. the path `P₄` has 1 matching but `K₄` has 3, not a power of two), which
is exactly why the hypothesis restricts to superpositions of two-matching gadgets.
Within the block model no counterexample exists: the multiplicative law is exact.
