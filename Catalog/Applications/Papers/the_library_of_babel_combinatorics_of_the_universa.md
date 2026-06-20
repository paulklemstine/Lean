# Computational Evidence — Library of Babel Combinatorics

This cycle studied three quantitative facts about the universal library
(all strings of length `L` over a `b`-symbol alphabet). The evidence below was
produced with small-case Lean `#eval` exploration before the formal proofs.

## 1. The catalog threshold `b^L ≤ N·L`

A single volume has `L` cells but the library has `b^L` volumes.

| b | L | volumes `b^L` | cells in 1 book `L` | single book enough? | min books `⌈b^L/L⌉` |
|---|---|---------------|---------------------|---------------------|----------------------|
| 2 | 1 | 2             | 1                   | no                  | 2                    |
| 2 | 4 | 16            | 4                   | no                  | 4                    |
| 3 | 3 | 27            | 3                   | no                  | 9                    |
| 25| 1312000 | 25^1312000 | 1312000 | no | ⌈25^1312000 / 1312000⌉ |

For every `b ≥ 2, L ≥ 1` we have `L < b^L` (`Nat.lt_pow_self`), so no single
volume can index the library — the diagonal/pigeonhole obstruction. The exact
threshold for a distributed catalog over `N` books is `b^L ≤ N·L`
(`distributed_catalog_iff`), and `N = ⌈b^L/L⌉` always suffices
(`min_catalog_volumes_suffices`).

## 2. de Bruijn length of a universal volume

A universal volume of order `k` (containing every length-`k` window) must have
length `≥ b^k + k − 1`, because it has only `L − k + 1` windows but there are
`b^k` distinct patterns. Small cases of the minimal length `b^k + k − 1`:

| b | k | patterns `b^k` | minimal length `b^k+k−1` |
|---|---|----------------|--------------------------|
| 2 | 2 | 4              | 5                        |
| 2 | 3 | 8              | 10                       |
| 4 | 2 | 16             | 17                       |
| 4 | 3 | 64             | 66                       |

A greedy de Bruijn search (run in Lean `#eval`) produced the explicit optimal
order-2, 4-symbol word of length 17:

```
0 0 1 0 2 0 3 1 1 2 1 3 2 2 3 3 0
```

`native_decide` confirms it contains all 16 ordered pairs, so the lower bound 17
is tight (`deBruijn_min_length_b4_k2`). This is the linear (non-cyclic) de Bruijn
length `b^k + k − 1 = 17`; the cyclic sequence has length `b^k = 16`.

## 3. Probability of a meaningful proof

Fix a proof-pattern of length `k` (proof complexity) and draw a volume uniformly.
The probability it contains the pattern is sandwiched:

```
b^(−k)  ≤  P(contains)  ≤  (L − k + 1) · b^(−k).
```

Lower bound: all `b^(L−k)` volumes carrying the pattern at position 0 contain it,
giving `P ≥ b^(L−k)/b^L = b^(−k)`. Upper bound is the union bound over the
`L − k + 1` positions. The ratio between the bounds is exactly the book length
factor `L − k + 1`, confirming the conjectured order of magnitude
`Θ(|T| · b^(−k))`.

Small-case ratios `(L−k+1)` (gap between upper and lower bound) for `b = 25`:

| k | L | lower `25^(−k)` | upper `(L−k+1)·25^(−k)` |
|---|---|-----------------|--------------------------|
| 1 | 100 | 1/25          | 100/25 = 4               |
| 2 | 100 | 1/625         | 99/625 ≈ 0.158           |
| 5 | 1312000 | 25^(−5)   | 1311996 · 25^(−5)        |

No counterexamples were found in any sampled regime; the two-sided bound holds
for all `0 < b`, `k ≤ L`.
