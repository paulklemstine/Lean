# Computational Evidence — Structure of Even Perfect Numbers

Concise numerical support for the theorems formalized in
`AbundancyIndex.lean` and `EvenPerfectStructure.lean`.

## 1. Small-case calculations

### Abundancy index `σ(n)/n`
| n  | σ(n) | abundancy | class      |
|----|------|-----------|------------|
| 1  | 1    | 1         | deficient  |
| 2  | 3    | 3/2       | deficient  |
| 4  | 7    | 7/4       | deficient  |
| 6  | 12   | 2         | **perfect**|
| 8  | 15   | 15/8      | deficient  |
| 12 | 28   | 7/3 ≈ 2.33| abundant   |
| 28 | 56   | 2         | **perfect**|

Confirms: prime powers (2,4,8) are all deficient (`primePow_deficient`); the
perfect numbers 6, 28 hit exactly 2 (`abundancy_eq_two_iff_perfect`); 12 is
abundant (`abundant_twelve`).

### Even perfect numbers as triangular numbers `T_m = m(m+1)/2`
| p (prime) | 2^p−1 (prime?) | n = 2^(p−1)(2^p−1) | m = 2^p−1 | T_m |
|-----------|----------------|--------------------|-----------|-----|
| 2         | 3   ✓          | 6                  | 3         | 6   |
| 3         | 7   ✓          | 28                 | 7         | 28  |
| 5         | 31  ✓          | 496                | 31        | 496 |
| 7         | 127 ✓          | 8128               | 127       | 8128|

Confirms `even_perfect_triangular` and `even_perfect_structure` (the exponent
`p` is prime in every row — `mersenne_exponent_prime`).

### Sum of reciprocals of divisors of a perfect number
- n = 6:  1/1 + 1/2 + 1/3 + 1/6 = 2.
- n = 28: 1/1 + 1/2 + 1/4 + 1/7 + 1/14 + 1/28 = 2.

Confirms `perfect_sum_reciprocal_divisors`.

## 2. OEIS references
- A000396 — perfect numbers: 6, 28, 496, 8128, 33550336, …
- A000043 — Mersenne exponents (primes p with 2^p−1 prime): 2, 3, 5, 7, 13, 17, …
- A000217 — triangular numbers; even perfects are the subsequence at index 2^p−1.
- A005100 / A005101 — deficient / abundant numbers.

## 3. Counterexample hunt
- "Every even perfect number is triangular": checked for the four known small
  even perfects above — no counterexample.
- "If 2^p−1 is prime then p is prime": tested p ≤ 64. Composite p (e.g. 4, 6, 8,
  9) give composite 2^p−1 (15, 63, 255, 511 = 7·73). No counterexample to the
  contrapositive; matches `mersenne_exponent_prime`.
- "A perfect number is a prime power": searched n ≤ 10000 — every perfect number
  (6, 28, 496, 8128) has ≥ 2 distinct prime factors. Confirms
  `perfect_not_isPrimePow` / `perfect_two_le_card_primeFactors`.

## 4. Note on odd perfect numbers
No odd perfect number is known; none exist below 10^1500 (LMFDB / distributed
searches). Our `perfect_two_le_card_primeFactors` is a proven (if weak) instance
of the same phenomenon underlying Nielsen's "≥ 101 distinct prime factors" bound
for odd perfects.
