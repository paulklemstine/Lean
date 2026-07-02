# Computational Evidence — Stern's Diatomic Sequence and the Fibonacci Bridge

All figures below were computed directly from the recursive definition
`s(0)=0, s(1)=1, s(2n)=s(n), s(2n+1)=s(n)+s(n+1)` before any formal proof was
attempted.

## 1. Small-case calculations

First 20 values of Stern's sequence `s(n)`:

```
n     : 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
s(n)  : 0 1 1 2 1 3 2 3 1 4  3  5  2  5  3  4  1  5  4  7
```

This is OEIS **A002487** (Stern's diatomic series / "fusc").

## 2. Conjecture checks

**H1 (coprimality).** `gcd(s(n), s(n+1)) = 1` was checked for all `n < 40`:
result `true` (no exceptions). → proved as `stern_coprime`.

**H2 (all-ones indices).** `s(2^n − 1)` for `n = 0..5`:
`[0, 1, 2, 3, 4, 5]`, i.e. `s(2^n − 1) = n`. Also `s(2^n)` for `n = 0..5`:
`[1, 1, 1, 1, 1, 1]`. → proved as `stern_pow_two_sub_one` (and helper `stern_pow_two`).

**H3 (even-index Fibonacci).** With Jacobsthal indices `J n = (4^n − 1)/3`
(`= 0, 1, 5, 21, 85, 341, …`), the values `s(J n)` for `n = 0..7`:
```
[0, 1, 3, 8, 21, 55, 144, 377]  =  F(0), F(2), F(4), F(6), F(8), F(10), F(12), F(14)
```
so `s(J n) = F(2n)`. → proved as `stern_jacobsthal_fib`.

**H5 (odd-index Fibonacci, surprising).** `s(2·J n + 1)` for `n = 0..7`:
```
[1, 2, 5, 13, 34, 89, 233, 610]  =  F(1), F(3), F(5), F(7), F(9), F(11), F(13), F(15)
```
so `s(2·J n + 1) = F(2n+1)`. → proved as `stern_jacobsthal_fib_odd`.

**H4 (row sums, deferred).** `∑_{i < 2^k} s(2^k + i)` for `k = 0..5`:
`[1, 3, 9, 27, 81, 243] = 3^k`. Verified computationally; left as a future
direction rather than a headline theorem.

## 3. OEIS references

* `s(n)` — A002487 (Stern's diatomic series).
* `J n = (4^n − 1)/3` — A002450 (Jacobsthal-like "repunits base 4").
* even/odd Fibonacci subsequences — A001906 (`F(2n)`), A001519 (`F(2n+1)`).

## 4. Counterexample hunt

No counterexamples were found to any of H1–H5 within the ranges tested
(`n < 40` for coprimality, `n ≤ 7`/`k ≤ 5` for the identities). The identities
are exact (not merely approximate), which is consistent with the clean
two-step linear recurrence shared by `(s(Jₙ), s(2Jₙ+1))` and `(F(2n), F(2n+1))`.
