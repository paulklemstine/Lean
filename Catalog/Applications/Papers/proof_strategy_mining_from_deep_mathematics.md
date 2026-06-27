# Computational Evidence

This cycle produced two clusters of formal results. The evidence below was used to fix the
correct statements *before* formalization.

## 1. Strong divisibility sequences (primitive-divisor schema)

A sequence `a : ℕ → ℕ` is a *strong divisibility sequence* when
`gcd (a m) (a n) = a (gcd m n)`.

**Fibonacci, `gcd(F m, F n) = F(gcd m n)`** (Mathlib `Nat.fib_gcd`):

| m | n | gcd m n | F m | F n | gcd(F m,F n) | F(gcd m n) |
|---|---|---------|-----|-----|--------------|------------|
| 6 | 9 | 3       | 8   | 34  | 2            | 2          |
| 8 | 12| 4       | 21  | 144 | 3            | 3          |
| 10|15 | 5       | 55  | 610 | 5            | 5          |

**Mersenne-type `2^n - 1`** (Mathlib `Nat.pow_sub_one_gcd_pow_sub_one`):

| m | n | 2^m-1 | 2^n-1 | gcd | 2^(gcd m n)-1 |
|---|---|-------|-------|-----|----------------|
| 6 | 9 | 63    | 511   | 7   | 7   (gcd=3)    |
| 8 |12 | 255   | 4095  | 15  | 15  (gcd=4)    |

Both confirm the gcd identity, so the abstract schema applies verbatim to each, which is
what `fib_isStrongDivSeq` and `pow_sub_one_isStrongDivSeq` certify.

**Entry points / primitive indices.** For Fibonacci: `p=11` first divides `F 10 = 55`, so
its entry point is `10`; `11 ∤ F k` for `0 < k < 10`. This is the non-vacuous content of
`primitive_iff_entryPt_eq` instantiated at Fibonacci.

## 2. Erdős–Straus families

Goal: `4/n = 1/x + 1/y + 1/z` with positive integers.

| n | residue | (x, y, z) | check |
|---|---------|-----------|-------|
| 6 | even (2·3)   | (3, 6, 6)   | 1/3+1/6+1/6 = 2/3 = 4/6 |
| 10| even (2·5)   | (5,10,10)   | 1/5+1/10+1/10 = 2/5 = 4/10 |
| 3 | 3 mod 4 (k=0)| (1, 6, 6)   | 1+1/6+1/6 = 4/3 |
| 7 | 3 mod 4 (k=1)| (2,28,28)   | 1/2+1/28+1/28 = 4/7 |
| 11| 3 mod 4 (k=2)| (3,66,66)   | 1/3+1/66+1/66 = 4/11 |

**Counterexample hunt.** No counterexample is possible inside the proven families: the two
identities `4/(2m)=1/m+1/(2m)+1/(2m)` and `4/(4k+3)=1/(k+1)+1/(2n(k+1))+1/(2n(k+1))` are
polynomial identities verified by `ring`. The classes that resist a *single* parametric
identity are `n ≡ 1 (mod 4)` (and, mod 24, the residue `1`); these are deliberately left
outside the combined theorem, marking the true open boundary.

OEIS: the count of representations of `4/n` is OEIS A073101; the conjecture's exceptional
residues mod 840 relate to A192787-style sieves. We did not rely on any OEIS lookup beyond
sanity checks.
