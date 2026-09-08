# Computational Evidence — the A/X crossing of the fork channel

All numbers below were produced with `Float` arithmetic inside Lean (`#eval`)
before any proof was attempted.  They are *evidence*, not verification; every
claim that survived was afterwards proved in Lean (see
`Catalog/Novelty/ForkChannelCrossingUniqueness.lean` and
`Catalog/Novelty/ForkChannelSecondCrossing.lean`).

## 0. The model

Both channels of a fork of arity `n` are degraded by the same **entropy
deficit** `δ n = 1/n²` (the collision probability of two independent uniform
probes of the ordered branch-pair set `[n] × [n]`), but *differently*:

| channel | formula | degradation |
|---|---|---|
| address `A n` | `log₂ n − 1 − δ n` | additive |
| exchange `X n` | `2 · (1 − δ n)` | multiplicative |

The whole comparison collapses onto the **resonance**
`R n = log₂ n + δ n`, since `A n − X n = R n − 3`.

## 1. Small-case table (integer arity)

`R n − 3` and `A n / X n`:

| n | R n − 3 | A n / X n |
|---|---|---|
| 2 | −1.750 | −0.167 |
| 3 | −1.304 | 0.196 |
| 4 | −0.938 | 0.474 |
| 5 | −0.678 | 0.652 |
| 6 | −0.557 | 0.716 |
| 7 | −0.173 | 0.912 |
| 8 | **+0.016** | **1.008** |
| 9 | +0.182 | 1.092 |
| 10 | +0.332 | 1.168 |
| 16 | +1.004 | 1.504 |
| 21 | +1.394 | 1.699 |

A single sign change between `n = 7` and `n = 8`, and `A/X` is increasing
throughout the sampled range.

## 2. Locating the crossing

Scanning `n = 7.00, 7.05, …, 8.00` in steps of `0.05`:

```
7.00 -0.172529   7.55 -0.065980
7.10 -0.152344   7.60 -0.056688
7.20 -0.132713   7.70 -0.038275
7.30 -0.113338   7.80 -0.020089
7.40 -0.094213   7.85 -0.011080
7.50 -0.075332   7.90 -0.002124
                 7.95 +0.006777
                 8.00 +0.015625
```

Sign change between `7.90` and `7.95`; linear interpolation gives
`r ≈ 7.9119`.  This is what suggested the dyadic bracket
`253/32 = 7.90625 < r < 7.921875 = 507/64`, later proved.

## 3. Divergence of the ratio

| n | 10 | 50 | 100 | 1000 |
|---|---|---|---|---|
| A n / X n | 1.168 | 2.323 | 2.822 | 4.483 |

Consistent with `A/X ~ (log₂ n)/2 → ∞`.

## 4. Counterexample hunt: is the crossing unique?

Scanning `R n − 3` on `(0, ∞)` revealed a **second sign change at small `n`**,
which the small-`n` sampling then pinned down *exactly*:

```
n = 0.25 :  R = -2 + 16   = 14      (> 3)
n = 0.50 :  R = -1 +  4   =  3      (= 3)   <-- exact crossing
n = 1.00 :  R =  0 +  1   =  1      (< 3)
n = 1.18 :  R ≈  0.2354 + 0.7215 ≈ 0.957  (minimum of R)
n = 2.00 :  R =  1 + 0.25 =  1.25   (< 3)
```

So the naive conjecture "there is exactly one crossing on `(0,∞)`" is **false**;
what is true is:

* on the physical range `n > 2` the crossing is unique (proved);
* on the whole positive axis there are exactly **two** crossings, `n = 1/2`
  (exactly solvable, common value `A = X = −6`) and the transcendental
  `r ∈ (7.90625, 7.921875)` (proved).

## 5. Integer certificates used

The comparison at integral arity `m ≥ 2` is *equivalent* to a single integer
inequality (`ForkChannel.integer_criterion`):

`X m < A m  ⟺  2 ^ (3m² − 1) < m ^ (m²)`.

| m | integer inequality | truth |
|---|---|---|
| 7 | `7 ^ 49  <  2 ^ 146`      | true (`7^49 ≈ 2^137.6`) |
| 8 | `2 ^ 191 <  8 ^ 64 = 2^192` | true |

The dyadic bracket uses two further certificates, both verified by `norm_num`
in Lean:

* `253 ^ 64009  < 2 ^ 511048`   (gives `r > 253/32`),
* `2 ^ 2309345  < 507 ^ 257049` (gives `r < 507/64`).

## 6. OEIS

No integer sequence in the classical sense arises here: the objects are two
real-analytic curves.  The only integer data are the certificate exponents
`3m² − 1` and `m²`, which are elementary quadratic sequences and were not
searched for in OEIS.
