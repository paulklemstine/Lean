# Computational Evidence

## Small cases

For `n = 0,…,8`, the pair `(n!, ⌈log₂(n!)⌉)` is:

| n | n! | entropy ceiling (bits) |
|---:|---:|---:|
| 0 | 1 | 0 |
| 1 | 1 | 0 |
| 2 | 2 | 1 |
| 3 | 6 | 3 |
| 4 | 24 | 5 |
| 5 | 120 | 7 |
| 6 | 720 | 10 |
| 7 | 5040 | 13 |
| 8 | 40320 | 16 |

The values were evaluated directly from the factorial and binary-ceiling definitions.
They agree with the decision-tree requirement that `h` binary comparisons distinguish at
most `2^h` possibilities.

## Comparison-count contrast

The usual worst-case comparison count `n(n−1)/2` for an unoptimized adjacent-swap sort,
compared with the entropy ceiling, gives:

| n | adjacent-swap comparisons | entropy ceiling |
|---:|---:|---:|
| 2 | 1 | 1 |
| 3 | 3 | 3 |
| 4 | 6 | 5 |
| 5 | 10 | 7 |
| 6 | 15 | 10 |
| 7 | 21 | 13 |
| 8 | 28 | 16 |

This gap does not establish extra thermodynamic work: repeated or redundant comparisons
need not erase independent information. The padding construction in the accompanying
result makes this distinction exact.

## Counterexample hunt

The claim “an algorithm making `C(n)` comparisons necessarily erases `C(n)` bits” fails
under redundant padding. A comparison tree can be replaced by a tree that asks any number
of extra comparisons and then continues with copies of the original tree. Its height grows
by the padding amount, while the sorting map—and therefore its input/output entropy
difference—does not change.

No counterexample was found to the surviving combinatorial claim
`⌈log₂(n!)⌉ ≤ comparison-tree height`; it follows structurally from
`n! ≤ leaves ≤ 2^height`.

## Sequence identification

The factorial sequence is OEIS A000142. The binary ceiling values above are the integer
ceilings of the base-two logarithms of A000142. No database result is used in the proofs.
