# Computational Evidence: Repaired Anti-Fibonacci → Squares & Pythagorean Triples

## Object

The **repaired anti-Fibonacci rule** (from `Logic.RepairedAntiFibonacciClassification`)
is the greedy process: start at `a 0 = 1`; at each step take the *least* value
strictly greater than the current term that is not a sum of two previously seen
terms. The earlier cycle proved rigidity: the unique trajectory is

```
a n = 2n + 1     →     1, 3, 5, 7, 9, 11, 13, ...
```

## 1. Small-case calculations

Terms `a n = 2n+1`:

| n      | 0 | 1 | 2 | 3 | 4 | 5  | 6  |
|--------|---|---|---|---|---|----|----|
| a n    | 1 | 3 | 5 | 7 | 9 | 11 | 13 |

Partial sums `S n = ∑_{k<n} a k`:

| n   | 0 | 1 | 2 | 3 | 4  | 5  | 6  | 7  |
|-----|---|---|---|---|----|----|----|----|
| S n | 0 | 1 | 4 | 9 | 16 | 25 | 36 | 49 |

So `S n = n²` exactly — the ancient identity "sum of the first n odd numbers is a
perfect square", here *derived from* the greedy dynamics rather than assumed.

Consecutive-square gaps: `a n = (n+1)² − n²`.

## 2. OEIS

- Trajectory `1, 3, 5, 7, 9, ...` = odd numbers, **A005408**.
- Partial sums `0, 1, 4, 9, 16, 25, ...` = squares, **A000290**.

## 3. Pythagorean bridge

Each term is the odd leg of a Pythagorean triple `(a n, 2n²+2n, 2n²+2n+1)`:

| n | a n | even leg 2n²+2n | hyp 2n²+2n+1 | check                         |
|---|-----|-----------------|--------------|-------------------------------|
| 1 | 3   | 4               | 5            | 3²+4²=9+16=25=5²              |
| 2 | 5   | 12              | 13           | 5²+12²=25+144=169=13²         |
| 3 | 7   | 24              | 25           | 7²+24²=49+576=625=25²         |
| 4 | 9   | 40              | 41           | 9²+40²=81+1600=1681=41²       |

Even leg and hypotenuse are consecutive integers, so each is a *primitive* triple,
and `(a n)² = (even leg) + (hypotenuse)` (odd-leg parametrisation). This is the
classic list of primitive triples with consecutive leg/hypotenuse, **A005408 /
A046092 / A001844**.

## 4. Counterexample hunt

The proven statements are `a n = 2n+1` corollaries verified for all sampled `n`
above with no exception; the closed form makes every claim an algebraic identity,
so no counterexample exists. Formalised in
`Bridges/RepairedAntiFibonacciSquares.lean` (builds `sorry`-free).
