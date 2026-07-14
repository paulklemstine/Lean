# Computational Evidence

## Bridge: factorial number system as a mixed-radix system

The bridge `MixedRadixFactorialBridge.lean` identifies the factorial (factoradic)
number system with the mixed-radix system whose bases are `b i = i + 1`.

### Running-product identity

The place values of the mixed-radix system with bases `b i = i + 1` are the
factorials, since the running product telescopes:

| k | ∏_{i<k} (i+1) | k! |
|---|---------------|----|
| 0 | 1             | 1  |
| 1 | 1             | 1  |
| 2 | 2             | 2  |
| 3 | 6             | 6  |
| 4 | 24            | 24 |
| 5 | 120           | 120|

This confirms `radixProd (·+1) k = k!`, the only nontrivial ingredient behind the
place-value agreement `value_eq`.

### Validity agreement

Mixed-radix validity at base `i+1` requires `c i < i + 1`, i.e. `c i ≤ i`, which is
exactly the factoradic bound. Sampled digit strings:

- `c = (0,1,2,3,...)` is valid in both systems.
- `c = (0,0,3,...)` fails both at position 2 (needs `c 2 ≤ 2`).

### Uniqueness cross-check (small cases)

Every `n < k!` has a unique valid factoradic representation of length `k`.
For `k = 4` (so `n < 24`) the extracted digits reproduce `n`:

| n  | (c0,c1,c2,c3) | value |
|----|---------------|-------|
| 0  | (0,0,0,0)     | 0     |
| 1  | (0,1,0,0)     | 1     |
| 5  | (0,1,2,0)     | 5     |
| 23 | (0,1,2,3)     | 23    |

These agree with the mixed-radix extraction at bases `(1,2,3,4)`, confirming the
re-derived uniqueness theorem `factorial_value_unique_via_mixed`.

## Carmichael primitive divisors of Fibonacci numbers

The composite case `fib_carmichael_composite` is verified computationally for all
`13 ≤ n ≤ 10000` by the finite certificate `primPart_check` (a strip-based
computation of the primitive part). For every composite `n` in this range the
primitive part exceeds `1`, exhibiting a primitive prime divisor. The tail
`n > 10000` is the general primitive-divisor theorem and is documented as the sole
remaining open step.
