# Computational Evidence

## Small cases

The number of length-`k` codes is the product of digit radices `1·2···k = k!`.

| `k` | code radices | number of codes | number of permutations |
|---:|:---|---:|---:|
| 0 | empty | 1 | 1 |
| 1 | 1 | 1 | 1 |
| 2 | 1,2 | 2 | 2 |
| 3 | 1,2,3 | 6 | 6 |
| 4 | 1,2,3,4 | 24 | 24 |
| 5 | 1,2,3,4,5 | 120 | 120 |

These six code counts are certified by `small_card_counts` in
`Catalog/Pythagorean/FactorialLehmerClassification.lean`; the general equality
is `card_factorialCode`.

For `k = 3`, the evaluations are exactly `0,1,2,3,4,5`: the digits have bounds
`c₀=0`, `c₁∈{0,1}`, `c₂∈{0,1,2}`, and value `c₁ + 2c₂`.

## Sequence identification

The counts `1, 1, 2, 6, 24, 120, ...` are the factorial numbers, OEIS A000142.

## Counterexample hunt

No small counterexample occurs for `k = 0,...,5`. More strongly, the Lean proof
is universal: `codeValue_lt` bounds every code value, `codeValue_injective`
proves distinct codes have distinct values, and `card_factorialCode` proves the
domain and `[0,k!)` have equal finite cardinality. The equivalence
`lehmerEquiv` then classifies every permutation for every natural `k`.
