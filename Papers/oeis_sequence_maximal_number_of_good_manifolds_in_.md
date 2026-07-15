# Computational evidence

## Small cases and indexing

The supplied data were interpreted with zero-based indices. The first twenty entries are:

| index range | values |
|---|---|
| 0–5 | 6, 8, 12, 24, 40, 80 |
| 6–10 | 128, 256, 512, 1024, 2048 |
| 11–15 | 4096, 8192, 16384, 32768, 65536 |
| 16–19 | 131072, 262144, 524288, 1048576 |

For every tested index `6 ≤ n ≤ 19`, the value is exactly `2^(n+1)`, and consecutive values have ratio 2. The corresponding extrapolated index-20 value is `2^21 = 2097152`.

## Catalog/OEIS anchoring

No OEIS identifier is asserted. The supplied final token `20971` appears truncated relative to the unambiguous power-of-two continuation `2097152`. Without a definition of “good manifold” or “n-nice polytope,” the finite list alone cannot establish that the inferred model is the intended geometric sequence.

## Counterexample hunt

The literal index-20 entry is `20971`, whereas the inferred model gives `2097152`. It therefore falsifies both of these universal claims:

1. every displayed term from index 6 equals `2^(n+1)`;
2. every displayed term from index 6 satisfies `a(n+1)=2a(n)`.

The Lean development verifies the first twenty matches, the mismatch at index 20, and the impossibility of any function that both reproduces all 21 literal entries and obeys the doubling recurrence from index 6.

## Table near the discrepancy

| n | reported | `2^(n+1)` | match? |
|---:|---:|---:|:---:|
| 17 | 262144 | 262144 | yes |
| 18 | 524288 | 524288 | yes |
| 19 | 1048576 | 1048576 | yes |
| 20 | 20971 | 2097152 | no |
