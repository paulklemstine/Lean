# Computational Evidence — Möbius trichotomy for log-behaviour of combinatorial totals

We test the central claim: for a positive sequence obeying a first-order
multiplicative recurrence `(α n + β)·a(n+1) = (γ n + δ)·a(n)`, the sign of the
**Möbius discriminant** `Δ = γβ − αδ` determines the log-behaviour of the
sequence (`Δ > 0` strictly log-convex, `Δ = 0` log-linear, `Δ < 0` strictly
log-concave).

The discriminant of a sequence at index `n` is
`D(n) = a(n)·a(n+2) − a(n+1)²`: `D > 0` ⇔ log-convex, `D = 0` ⇔ log-linear,
`D < 0` ⇔ log-concave.

## 1. Catalan numbers `Cₙ`  —  `(n+2)Cₙ₊₁ = (4n+2)Cₙ`,  `Δ = 4·2 − 1·2 = 6`

| n | Cₙ | Cₙ₊₁ | Cₙ₊₂ | D(n) = Cₙ·Cₙ₊₂ − Cₙ₊₁² |
|---|----|----|----|----|
| 0 | 1 | 1 | 2 | 1·2 − 1 = **+1** |
| 1 | 1 | 2 | 5 | 1·5 − 4 = **+1** |
| 2 | 2 | 5 | 14 | 2·14 − 25 = **+3** |
| 3 | 5 | 14 | 42 | 5·42 − 196 = **+14** |
| 4 | 14 | 42 | 132 | 14·132 − 1764 = **+84** |

All positive ⇒ strictly log-convex, matching `Δ = 6 > 0`. (OEIS A000108.)

## 2. Central binomial coefficients `C(2n,n)`  —  `Δ = 4·1 − 1·2 = 2`

| n | cbₙ | cbₙ₊₁ | cbₙ₊₂ | D(n) |
|---|----|----|----|----|
| 0 | 1 | 2 | 6 | 1·6 − 4 = **+2** |
| 1 | 2 | 6 | 20 | 2·20 − 36 = **+4** |
| 2 | 6 | 20 | 70 | 6·70 − 400 = **+20** |
| 3 | 20 | 70 | 252 | 20·252 − 4900 = **+140** |

All positive ⇒ strictly log-convex, matching `Δ = 2 > 0`. (OEIS A000984.)

## 3. Factorials `n!`  —  `1·(n+1)! = (n+1)·n!`,  `Δ = 1·1 − 0·1 = 1`

| n | n! | (n+1)! | (n+2)! | D(n) |
|---|----|----|----|----|
| 0 | 1 | 1 | 2 | 1·2 − 1 = **+1** |
| 1 | 1 | 2 | 6 | 1·6 − 4 = **+2** |
| 2 | 2 | 6 | 24 | 2·24 − 36 = **+12** |
| 3 | 6 | 24 | 120 | 6·120 − 576 = **+144** |

All positive ⇒ strictly log-convex, matching `Δ = 1 > 0`. (OEIS A000142.)

## 4. Powers `2ⁿ`  —  `1·2ⁿ⁺¹ = 2·2ⁿ`,  `Δ = 0·2 − 0·1 = 0`

| n | 2ⁿ | 2ⁿ⁺¹ | 2ⁿ⁺² | D(n) |
|---|----|----|----|----|
| 0 | 1 | 2 | 4 | 1·4 − 4 = **0** |
| 1 | 2 | 4 | 8 | 2·8 − 16 = **0** |
| 2 | 4 | 8 | 16 | 4·16 − 64 = **0** |

Identically zero ⇒ log-linear, matching `Δ = 0`. (OEIS A000079.)

## 5. Reciprocal factorials `1/n!`  —  `(n+1)·a(n+1) = a(n)`,  `Δ = 0·1 − 1·1 = −1`

| n | 1/n! | 1/(n+1)! | 1/(n+2)! | D(n) = a(n)·a(n+2) − a(n+1)² |
|---|----|----|----|----|
| 0 | 1 | 1 | 1/2 | 1·(1/2) − 1 = **−1/2** |
| 1 | 1 | 1/2 | 1/6 | 1·(1/6) − 1/4 = **−1/12** |
| 2 | 1/2 | 1/6 | 1/24 | (1/2)(1/24) − 1/36 = **−1/144** |

All negative ⇒ strictly log-concave, matching `Δ = −1 < 0`. (OEIS A000142 reciprocals.)

## 6. Counterexample hunt

The claim is universally quantified over the recurrence class, not over all
sequences. We searched for a positive recurrence sequence violating the
sign-matching rule by scanning integer coefficient tuples
`(α,β,γ,δ) ∈ {0,1,2}⁴` with `α n + β > 0`; in every case the observed sign of
`D(n)` on the first ten indices agreed with the sign of `Δ = γβ − αδ`, and was
*constant in `n`* (never flipping sign), consistent with the theorem's
`n`-independent discriminant. No counterexample was found.

## Conclusion

The numerics confirm the sign-matching rule across all five classical families
and support the sharper structural observation formalized in the theorem: the
sign of `D(n)` is *constant in `n`* and equal to `sign(Δ)`, because under the
recurrence the ratio difference is the fixed constant `Δ` up to a positive
factor.
