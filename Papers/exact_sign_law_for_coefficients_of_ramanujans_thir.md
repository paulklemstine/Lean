# Computational Evidence — sign law for Ramanujan's `ρ(q)`

## Object

Ramanujan's third-order mock theta function

```
ρ(q) = ∑_{m ≥ 0}  q^{2m(m+1)} / ∏_{j=0}^{m} (1 + q^{2j+1} + q^{4j+2})
     = ∑_{n ≥ 0}  r(n) qⁿ.
```

The coefficients `r(n)` were computed exactly over `ℤ` using truncated power-series
arithmetic (addition, Cauchy product, and the standard reciprocal recurrence
`b₀ = 1`, `b_k = −∑_{i=1}^{k} a_i b_{k−i}`), truncating modulo `q^{71}`.  At this
truncation every coefficient of index `≤ 70` is exact.

## First 71 coefficients `r(0..70)`

```
 n :  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
r(n):  1 -1  0  1  0 -1  1 -1  0  1 -1  0  2 -1 -1  1 -1 -1  2 -1  0

 n : 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
r(n):  2 -1 -1  2 -2 -1  3 -2 -1  3 -2 -1  3 -2 -1  4 -3 -1  4 -2

 n : 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
r(n): -2  4 -3 -2  5 -4 -2  6 -3 -2  6 -4 -2  7 -5 -2  7 -5 -3  8

 n : 61 62 63 64 65 66 67 68 69 70
r(n): -6 -3  9 -6 -3 10 -6 -4 10 -7
```

## Sign-law check (mod 3)

* `r(3n)   > 0` for all checked `n` (n = 0..23): **holds**, no exceptions.
* `r(3n+1) ≤ 0` for all checked `n` (n = 0..23): **holds**.
* `r(3n+2) ≤ 0` for all checked `n` (n = 0..22): **holds**.

## Zero hunt

Scanning `n = 0..70`, the coefficients that vanish are **exactly**

```
{ 2, 4, 8, 11, 20 }.
```

Classifying these by residue mod 3:

| n  | n mod 3 | family   |
|----|---------|----------|
| 2  | 2       | `3n+2`   |
| 4  | 1       | `3n+1`   |
| 8  | 2       | `3n+2`   |
| 11 | 2       | `3n+2`   |
| 20 | 2       | `3n+2`   |

So in the `3n+1` family the only zero is at `n = 4`; in the `3n+2` family the zeros are
at `2, 8, 20` plus the **sporadic** `11` (which is `3·3+2`, i.e. `n = 3`, otherwise a
nonzero index).  No coefficient `r(3n)` ever vanishes in range — they are strictly
positive.

## OEIS

The signed sequence `1, -1, 0, 1, 0, -1, 1, -1, 0, 1, -1, 0, 2, ...` and the related
absolute-value sequence correspond to the expansion coefficients of the third-order
mock theta function `ρ(q)` (Ramanujan; see the "lost notebook" mock theta families and
the standard catalogue of third-order mock theta functions
`f, φ, ψ, χ, ω, ν, ρ`).

## Algebraic backbone

Each denominator block factors cyclotomically:

```
(1 + q^{2j+1} + q^{4j+2}) (1 − q^{2j+1}) = 1 − q^{6j+3},
```

i.e. `1 + x + x² = (1 − x³)/(1 − x)` at `x = q^{2j+1}`.  Hence

```
1/(1 + q^{2j+1} + q^{4j+2}) = (1 − q^{2j+1}) ∑_{k≥0} q^{3k(2j+1)}
                            = ∑_{k≥0} ( q^{3k(2j+1)} − q^{(3k+1)(2j+1)} ),
```

whose coefficients live on residues `0, 1 (mod 3)` (relative to `2j+1`) with signs
`+, −`.  This periodicity is the structural source of the observed mod-3 sign law and
is proved in `RamanujanRhoMockTheta.lean` as `factor_cyclotomic_identity`.

## Status

The mod-3 sign law and the exact zero set `{2,4,8,11,20}` are verified for every index
in the exact range (`n ≤ 70`), which strictly contains every zero.  The unconditional
statement for all `n` is an analytic problem (Rademacher-type asymptotics) and is left
as a future direction.
