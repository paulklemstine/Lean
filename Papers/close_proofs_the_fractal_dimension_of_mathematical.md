# Computational Evidence

This mission filled `sorry` placeholders left by an earlier cycle. The two files
touched concern (a) the mixed-radix / factorial number-system bridge and (b)
Carmichael's primitive-divisor theorem for Fibonacci numbers.

## 1. Mixed-radix ↔ factorial bridge

For bases `b i = i + 1` the running product `∏_{j<i} b j` equals `i!`, so the
mixed-radix value coincides with the factorial-system value.

Small cases (`value b c k = ∑_{i<k} c i · ∏_{j<i} b j`):

| k | ∏_{j<k}(j+1) | k!  |
|---|--------------|-----|
| 0 | 1            | 1   |
| 1 | 1            | 1   |
| 2 | 2            | 2   |
| 3 | 6            | 6   |
| 4 | 24           | 24  |
| 5 | 120          | 120 |

Digit example: `c = (0,1,2,1,...)` with `k = 4` gives
`0·1 + 1·1 + 2·2 + 1·6 = 11`, matching the factoradic value `1·1! + 2·2! + 1·3! = 11`.
This confirms `value_eq`. Validity `c i < i+1 ↔ c i ≤ i` is immediate
(`valid_iff`), and uniqueness transports along these identities
(`factorial_value_unique_via_mixed`). All three are proved and use only the
standard axioms `propext`, `Classical.choice`, `Quot.sound`.

## 2. Carmichael primitive divisors (Fibonacci)

The primitive part `primPart n` is `fib n` with all factors from proper-divisor
Fibonacci numbers `fib d` (d | n, 0 < d < n) stripped out. Carmichael's theorem
says `fib n` has a primitive prime divisor for every `n > 12`, equivalently
`1 < primPart n`.

Spot check of the primitive part (primitive prime divisors in brackets):

| n  | fib n | primitive divisor |
|----|-------|-------------------|
| 5  | 5     | 5                 |
| 7  | 13    | 13                |
| 8  | 21    | 7                 |
| 10 | 55    | 11                |
| 11 | 89    | 89                |
| 13 | 233   | 233               |
| 14 | 377   | 29                |
| 15 | 610   | 61                |

The only `n > 0` **without** a primitive divisor are `n ∈ {1, 2, 6, 12}`
(F_6 = 8 = 2^3, F_12 = 144 = 2^4·3^2 — both reuse only the primes 2, 3 seen
earlier). The catalog file discharges `13 ≤ n ≤ 10000` by a `native_decide`
computation over `primPart`; the infinite composite tail `n > 10000` is the
content of the general theorem and is discussed in `FUTURE_DIRECTIONS.md`.
