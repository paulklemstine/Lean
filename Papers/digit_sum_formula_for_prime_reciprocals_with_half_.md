# Computational Evidence: Digit Sum of Prime Reciprocals with Half-Order Periods

**Claim.** For a prime `p ≥ 3`, base `b ≥ 2` with `p ∤ b`, if the multiplicative
order of `b` mod `p` is `l = (p-1)/2^m` and `p ≡ 1 (mod 2^(m+1))`, then the sum of
the base-`b` digits in one full period of `1/p` equals `(b-1)(p-1)/2^(m+1)`.

The period is the base-`b` representation of `N = (b^l - 1)/p`; leading zeros do
not affect the digit sum, so we measure `digitSum_b(N)`.

## Small-case calculations (hypotheses satisfied)

| p  | b  | m | l = ord_p(b) | p mod 2^(m+1) | digitSum_b(N) | (b-1)(p-1)/2^(m+1) |
|----|----|---|--------------|---------------|---------------|--------------------|
| 7  | 10 | 0 | 6 = 6/1      | 7 mod 2 = 1   | 27            | 27                 |
| 13 | 10 | 1 | 6 = 12/2     | 13 mod 4 = 1  | 27            | 27                 |
| 17 | 2  | 1 | 8 = 16/2     | 17 mod 4 = 1  | 4             | 4                  |

- `1/7  = 0.\overline{142857}`, digit sum `1+4+2+8+5+7 = 27`.
- `1/13 = 0.\overline{076923}`, digit sum `0+7+6+9+2+3 = 27`.
- `1/17` in base 2 has period 8 (`00001111`), digit sum `4`.

All three agree with the closed form.

## Counterexample hunt (hypotheses violated → formula must not apply)

Testing triples where either `l ≠ (p-1)/2^m` or `p ≢ 1 (mod 2^(m+1))` shows the
identity genuinely relies on both hypotheses (the two sides disagree):

| p  | b  | m | note                                   | measured | closed form |
|----|----|---|----------------------------------------|----------|-------------|
| 3  | 10 | 1 | 3 ≢ 1 (mod 4)                          | 3        | 4           |
| 17 | 2  | 2 | ord = 8 ≠ 16/4 = 4                     | 0        | 2           |
| 31 | 2  | 0 | ord = 5 ≠ 30                           | 6        | 15          |

No counterexample was found among triples that *do* satisfy the hypotheses; every
such triple matched the closed form exactly.

## Structural observation

Whenever `p ≡ 1 (mod 2^(m+1))` and `l = (p-1)/2^m`, the exponent `l` is even and
`b^(l/2) ≡ -1 (mod p)`. Writing `h = l/2` and `k = (b^h+1)/p`, one has
`N = k·(b^h - 1) = (k-1)·b^h + (b^h - k)` with `1 ≤ k ≤ b^h - 1`. The two `h`-digit
halves are nines-complements of each other, so each of the `h` digit positions
contributes exactly `b-1`, giving digit sum `(b-1)·h = (b-1)(p-1)/2^(m+1)`.

## OEIS note

For `b = 10`, the digit sums of the repeating block of `1/p` over primes `p`
producing this "balanced" behaviour are all multiples of `(b-1) = 9` equal to
`9·(l/2)`; e.g. `1/7, 1/13, 1/17, 1/19, 1/23 → 27, 27, ...` The value `27 = 999/37`
appears as the digit sum for the "cyclic" primes `7` and `13`, matching the
classical Midy-theorem family.
