# Computational Evidence

## Bridge: factorial number system as a mixed-radix system

The bridge lemmas are transport-of-structure identities, so the evidence is
direct instantiation rather than a search.

### Small-case place-value check (`b i = i + 1`, running product `= i!`)

| position `i` | base `b i = i+1` | running product `∏_{j<i} b j` | factorial `i!` |
|:---:|:---:|:---:|:---:|
| 0 | 1 | 1 | 1 |
| 1 | 2 | 1 | 1 |
| 2 | 3 | 2 | 2 |
| 3 | 4 | 6 | 6 |
| 4 | 5 | 24 | 24 |

The running product of the bases `1,2,3,4,…` equals `0!,1!,2!,3!,…`, which is the
content of `factorial_radixProd` and underlies `value_eq`.

### Concrete value agreement

For the digit string `c = (0, 0, 1, 0, …)` at length `3`:
`value = 0·0! + 0·1! + 1·2! = 2` in both the mixed-radix and factorial readings.
This is exactly the checked `example` at the end of the bridge file.

### Validity coincidence

Mixed-radix validity at `b i = i+1` reads `c i < i+1`; factorial validity reads
`c i ≤ i`. On the natural numbers these are the identical constraint, confirmed by
`valid_iff` (a one-line reduction through `Nat.lt_succ_iff`).

## Fibonacci primitive divisors

Direct enumeration confirms the primitive-divisor property on the certified
range: for every `n` with `13 ≤ n ≤ 10000`, `F(n)` is either prime-indexed
(handled elementarily) or its computed "primitive part" exceeds `1`. This finite
verification is carried out inside the development (`primPart_check`,
`fib_coprime_part_pos_small`). The infinite tail `n > 10000` is *not* settled by
computation and remains the open growth estimate recorded in
`FUTURE_DIRECTIONS.md`.

No counterexample to any stated bridge identity was found in the sampled range.
