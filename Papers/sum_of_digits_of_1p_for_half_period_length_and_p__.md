# Computational Evidence — half-period digit sum of `1/p`

Setup: for a prime `p` and base `b` with `p ∤ b`, the base-`b` expansion of `1/p` is
purely periodic with period `d = ord_p(b)`.  The digit sum of one period is
`D(p,b) = Σ_{k=0}^{d-1} ⌊b·(b^k mod p) / p⌋`.  The claim under study:

> if `d = (p-1)/2` and `p ≡ 1 (mod 4)`, then `D(p,b) = (b-1)(p-1)/4`.

## 1. Small-case calculations (half-period, `p ≡ 1 mod 4`)

Every row below has `ord_p(b) = (p-1)/2`, `p ≡ 1 (mod 4)`, `p ∤ b`.
Columns: `p, b, d, D(p,b), (b-1)(p-1)/4`.

```
(5,  4,  2,  3,  3)
(13, 4,  6,  9,  9)
(17, 2,  8,  4,  4)
(29, 4, 14, 21, 21)
(29, 5, 14, 28, 28)
(29, 6, 14, 35, 35)
(37, 3, 18, 18, 18)
(37, 4, 18, 27, 27)
(41, 2, 20, 10, 10)
(41, 5, 20, 40, 40)
```

The computed digit sum matches `(b-1)(p-1)/4` in **every** case.

## 2. Necessity of `p ≡ 1 (mod 4)` (counterexample hunt)

Repeating the search with the *same* order condition `ord_p(b) = (p-1)/2` but for
primes `p ≡ 3 (mod 4)` breaks the identity.  Columns: `p, b, d, D(p,b), (b-1)(p-1)/4`.

```
(7,  4,  3,  3,  4)     <- mismatch
(11, 3,  5,  4,  5)     <- mismatch
(11, 4,  5,  6,  7)     <- mismatch
(11, 5,  5,  8, 10)     <- mismatch
(19, 4,  9, 12, 13)     <- mismatch
(23, 3, 11,  8, 11)     <- mismatch
(31, 7, 15, 36, 45)     <- mismatch
```

So the residue condition `p ≡ 1 (mod 4)` is genuinely load-bearing: it is exactly what
makes `(p-1)/4` an integer and forces the quarter-period power `b^{(p-1)/4} ≡ -1`, which
in turn pairs the remainders `r_k` with `r_{k+(p-1)/4} = p - r_k`.  For `p ≡ 3 (mod 4)`
that pairing is unavailable and the digit sum is smaller.

## 3. Full-reptend companion (`ord_p(b) = p-1`)

For primitive-root bases the digit sum is the maximal `(b-1)(p-1)/2`, e.g.
`p=7, b=3`: `d=6`, `D = 6 = (3-1)(7-1)/2`.  This is the `d = p-1` sibling result and is
also formalized (`DigitSumFullPeriod.digitSum_full_period`).

## 4. OEIS

The half-period digit-sum values `(b-1)(p-1)/4` are not a single fixed integer sequence
(they depend on two parameters).  For fixed `b = 10` and `p` ranging over the relevant
primes the period digit sums of `1/p` connect to the general "digit sum of the repetend of
1/n" family (cf. OEIS A036275 for repetends); no dedicated OEIS entry is required for the
closed form itself, which is elementary once established.

## 5. Method note

All numbers above were produced by direct evaluation in `ℕ` (`#eval`) of the same
`digitSum` definition that appears in the Lean files, and the two representative rows
`(5,4)` and `(13,4)` are additionally machine-checked theorems
(`digitSum_five_four`, `digitSum_thirteen_four`).
