# Computational Evidence — good-manifold count of an `n`-nice polytope

## 1. Small-case calculations

The supplied data (21 terms, `n = 1 … 21`):

```
n     : 1  2   3   4   5   6    7    8    9    10    11    12    13     14 …
a(n)  : 6  8  12  24  40  80  128  256  512  1024  2048  4096  8192  16384 …
```

Comparing each term with `2^n`:

| n | a(n) | 2^n | a(n) − 2^n |
|---|------|-----|------------|
| 1 | 6    | 2   | 4 |
| 2 | 8    | 4   | 4 |
| 3 | 12   | 8   | 4 |
| 4 | 24   | 16  | 8 |
| 5 | 40   | 32  | 8 |
| 6 | 80   | 64  | 16 |
| 7 | 128  | 128 | 0 |
| 8 | 256  | 256 | 0 |
| … | …    | …   | 0 |
| 21| 2097152 | 2097152 | 0 |

So the sequence has a finite **irregular head** (`n = 1 … 6`) and from `n = 7`
on is *exactly* `2^n`. The final tabulated term confirms `a(21) = 2097152 = 2^21`
(the source text truncates it to `20971…`).

## 2. OEIS-style observation

The tail is the powers of two `A000079` shifted to start at `2^7`. The head
`6, 8, 12, 24, 40, 80` is the finite exceptional prefix that distinguishes this
"good-manifold" count from the pure power-of-two sequence.

## 3. Checks performed (in Lean, by `#eval` / `decide`)

- `((List.range 22).drop 1).map goodCount` equals the 21 supplied terms
  (theorem `goodCount_data`, proved by `decide`).
- `∑_{k=7}^{12} goodCount k = 2^13 − 2^7` (`#eval` returned `true`); the general
  identity is `goodCount_partialSum`.
- The head `6,8,12,24,40,80` is strictly increasing and dominates
  `2,4,8,16,32,64`.

## 4. Counterexample hunt

- Closed form `a(n) = 2^n` for `n ≥ 7`: checked against all tabulated tail terms;
  no counterexample.
- Global lower bound `2^n ≤ a(n)` for `n ≥ 1`: verified on the head and proved on
  the tail — no counterexample.
- Super-exponentiality: instantiating the catalog predicate `SuperExp` at base
  `c = 2` produces the contradiction `2^n < 2^n` on the tail, so the sequence is
  **not** super-exponential (confirmed as a theorem, not just numerically).

## 5. Summary

The evidence supports a clean description: a six-term exceptional head followed by
the exact exponential law `2^n`, giving growth type `Θ(2^n)` — one tier below the
factorial/super-exponential regime.
