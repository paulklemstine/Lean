# Computational evidence

## Small-case calculations

Using zero-based indices, the supplied values and the candidate tail are:

| index | supplied | candidate |
|---:|---:|---:|
| 0 | 6 | 6 |
| 1 | 8 | 8 |
| 2 | 12 | 12 |
| 3 | 24 | 24 |
| 4 | 40 | 40 |
| 5 | 80 | 80 |
| 6 | 128 | 128 = 2^7 |
| 7 | 256 | 256 = 2^8 |
| 8 | 512 | 512 = 2^9 |
| 9 | 1024 | 1024 = 2^10 |
| 10 | 2048 | 2048 = 2^11 |
| 11 | 4096 | 4096 = 2^12 |
| 12 | 8192 | 8192 = 2^13 |
| 13 | 16384 | 16384 = 2^14 |
| 14 | 32768 | 32768 = 2^15 |
| 15 | 65536 | 65536 = 2^16 |
| 16 | 131072 | 131072 = 2^17 |
| 17 | 262144 | 262144 = 2^18 |
| 18 | 524288 | 524288 = 2^19 |
| 19 | 1048576 | 1048576 = 2^20 |
| 20 | 20971 | 2097152 = 2^21 |

Thus the candidate agrees with all supplied values from index 6 through index 19 and predicts
`2097152` next. The formal development proves this closed form and proves that `20971` is
incompatible with it.

## OEIS search result

No OEIS identifier is asserted. The problem supplies an OEIS-style description but no ID, and
an authoritative external database lookup was not available in this project. The unusual final
value prevents safely identifying the sequence from the terms alone.

## Counterexample hunt

The claimed doubling law was checked against every adjacent supplied pair in the proposed tail.
It holds from `128 -> 256` through `524288 -> 1048576`. The final transition is a counterexample
as literally written: `2 * 1048576 = 2097152`, not `20971`.

## Interpretation limit

No definitions of “good manifold,” “n-nice polytope,” or the maximization problem were supplied.
Consequently the computations support a conjectural numerical continuation only; they cannot
validate that the numbers actually solve the stated geometric extremal problem.
