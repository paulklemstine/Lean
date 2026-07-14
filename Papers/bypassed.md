# Computational Evidence — Fibonacci Pythagorean triples

## Construction under test

For each `n ≥ 0`, from four consecutive Fibonacci numbers `F n, F(n+1), F(n+2), F(n+3)`
form
* `a = F n · F(n+3)`
* `b = 2 · F(n+1) · F(n+2)`
* `c = F(n+1)² + F(n+2)²`

## Small-case table (n = 0..7)

| n | (a, b, c)      | a²+b²=c² | c = F(2n+3)? | a·b = 2·F n·F(n+1)·F(n+2)·F(n+3)? |
|---|----------------|----------|--------------|-----------------------------------|
| 0 | (0, 2, 2)      | ✓        | ✓ (F₃=2)     | ✓ |
| 1 | (3, 4, 5)      | ✓        | ✓ (F₅=5)     | ✓ |
| 2 | (5, 12, 13)    | ✓        | ✓ (F₇=13)    | ✓ |
| 3 | (16, 30, 34)   | ✓        | ✓ (F₉=34)    | ✓ |
| 4 | (39, 80, 89)   | ✓        | ✓ (F₁₁=89)   | ✓ |
| 5 | (105, 208, 233)| ✓        | ✓ (F₁₃=233)  | ✓ |
| 6 | (272, 546, 610)| ✓        | ✓ (F₁₅=610)  | ✓ |
| 7 | (715,1428,1597)| ✓        | ✓ (F₁₇=1597) | ✓ |

(These rows were generated and checked with an in-language evaluation of `Nat.fib`.)

## Observations

1. **Pythagorean.** `a² + b² = c²` holds in every sampled case; no counterexample found.
2. **Fibonacci hypotenuse.** The hypotenuse `c` is exactly the odd-indexed Fibonacci
   number `F(2n+3)`. The hypotenuses `2, 5, 13, 34, 89, 233, 610, 1597, …` are OEIS
   **A001519** (bisection of the Fibonacci sequence, `F(2n+1)`), starting at `F₃`.
3. **Area is a product.** The right-triangle area `a·b/2` equals the product of the four
   consecutive Fibonacci numbers `F n · F(n+1) · F(n+2) · F(n+3)`. For `n = 1..7` these
   are `6, 30, 240, 1560, 10920, 74256, 510510, …` (OEIS **A059389**, products of four
   consecutive Fibonacci numbers).
4. **Degeneracy.** Only `n = 0` gives a degenerate triple (`a = 0`); for `n ≥ 1` all
   three sides are positive.

## Why the identity is exact (pre-proof analysis)

Writing `p = F(n+2)`, `q = F(n+1)`, the recurrence gives `p − q = F n` and
`p + q = F(n+3)`, so `a = p² − q²`, `b = 2pq`, `c = p² + q²`: the standard Euclid
parametrisation. Hence `a² + b² = c²` is the polynomial identity
`(p²−q²)² + (2pq)² = (p²+q²)²`. The hypotenuse identity `c = F(2n+3)` is the case
`m = n+1` of `F(2m+1) = F(m)² + F(m+1)²`. The computational landscape matches the
algebra exactly, so we proceed to a formal proof.
