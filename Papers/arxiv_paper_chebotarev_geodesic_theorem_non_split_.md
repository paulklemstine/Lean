# Computational evidence

All numbers below were produced with `#eval` inside the project's Lean/Mathlib environment
(`Float` arithmetic for the analytic quantities, exact `Finset` computation for the group
theory).  They are exploratory data, not proofs; the corresponding proved statements are named
after each block.

## 1. The record chain of exponents for the prime geodesic theorem

```
(25/36, 71/102, 7/10, 35/48, 3/4)
= (0.694444, 0.696078, 0.700000, 0.729167, 0.750000)
```

The exponent `25/36` of the paper is the smallest of the chain, and the gaps are genuinely
small (`71/102 - 25/36 ≈ 0.0016`), which is why a *strict* comparison lemma rather than a
numeric approximation is needed.
Proved: `ChebotarevGeodesic.record_chain`, `ChebotarevGeodesic.exponent_25_36_implies_classical`.

## 2. Conjugacy classes of a non-abelian Galois group (`S₃`)

```
|S₃|                            = 6
multiset of conjugacy class sizes = [1, 2, 3]
number of conjugacy classes       = 3
sum of class sizes                = 6
```

So the Chebotarev densities are `1/6, 1/3, 1/2`, summing to `1`.  This is the finite check
behind the general statement that the densities partition the total mass.
Proved (for every finite group): `ChebotarevGeodesic.sum_classSize`,
`ChebotarevGeodesic.sum_classDensity`; abelian case:
`ChebotarevGeodesic.classDensity_of_comm`.

## 3. Absorption of logarithms by `x^δ`

Testing `log x ≤ x^δ / δ` at `δ = 0.01`:

| `x`     | `log x`   | `x^{0.01}/0.01` |
|---------|-----------|-----------------|
| `10^6`  | 13.815511 | 114.815362      |
| `10^12` | 27.631021 | 131.825674      |

The right-hand side wins comfortably already at moderate `x`, and the ratio only improves.
Proved: `ChebotarevGeodesic.log_le_rpow_div`, `ChebotarevGeodesic.log_pow_le`,
`ChebotarevGeodesic.hasErrorExponent_of_log_pow_bound`.

## 4. Counterexample hunt: is the exponent `25/36` a real restriction?

Comparing the admissible error size with a hypothetical `x^{9/10}` error at `x = 10^8`:

```
x^{25/36} = 3.59e5     x^{9/10} = 1.58e7
```

A factor of ~44 already at `x = 10^8`, growing like `x^{0.2056}`.  So the predicate
"has error exponent `25/36`" is *not* satisfied by an error term of size `x^{9/10}`; no
counterexample to the sharpness claim was found, and the claim is now a theorem.
Proved: `ChebotarevGeodesic.not_hasErrorExponent_of_growth`,
`ChebotarevGeodesic.sharpness_example`,
`ChebotarevGeodesic.optimalExponent_25_36_realized`.

## 5. OEIS

No integer sequence is attached to the objects studied here (the data are real exponents and
conjugacy-class densities), so no OEIS search was applicable.  The class-size data of §2 is of
course the partition data of `S₃` (`[1,2,3]`), not a sequence under investigation.

## 6. Cycle 4–5 data: the log staircase and the equidistribution rate

All numbers below were again produced with `#eval` (`Float` arithmetic).

Rigidity in the log parameter — the ratio between an `x^θ (log x)^k` error and an
`x^θ (log x)^{k-1}` error is `log x`, which is unbounded:

```
log(10^6)  = 13.815511
log(10^8)  = 18.420681
log(10^12) = 27.631021
```

So no constant `C` can satisfy `x^θ (log x)^k ≤ C x^θ (log x)^{k-1}` for all large `x`.
Proved: `ChebotarevGeodesic.not_hasLogErrorExponent_mdl_of_lt_log`,
`ChebotarevGeodesic.hasLogErrorExponent_mdl_iff`, `ChebotarevGeodesic.mdl_corner_25_36`.

Size of a `25/36` error with three log factors at `x = 10^8`:

```
x^{25/36}              = 3.5938e5
x^{25/36} (log x)^3    = 2.2463e9
```

The log powers cost several orders of magnitude at accessible `x`, yet do not move the
optimal exponent (`ChebotarevGeodesic.optimalExponent_log_pow`) — exactly the phenomenon the
two-parameter staircase isolates.

Equidistribution rate (conjecture C4, now proved): with `θ = 25/36` and main term of size
`x^β`, `β = 1`, the relative error of the class proportions decays like

```
x^{25/36 - 1} at x = 10^12  =  2.15e-4
```

Proved: `ChebotarevGeodesic.hasErrorExponent_ratio`,
`ChebotarevGeodesic.chebotarev_density_rate`.

## 7. Cycle 6–7 data: the half-plane error term `exp √(log x)`

The classification of admissible regions (cycle 7) needs an error term that beats *every*
fixed power of `log x` but *no* power of `x`.  The candidate is `exp √(log x)`.  The table
below was produced with `#eval` (`Float` arithmetic); the columns are
`exp √(log x)`, `(log x)^3` and `x^{0.05}`.

```
x = 10^8     73.1              6.25e3            2.51
x = 10^30    4.07e3            3.30e5            31.6
x = 10^100   3.89e6            1.22e7            1.00e5
x = 10^300   2.60e11           3.30e8            1.00e15
```

Reading the table: `exp √(log x)` overtakes `(log x)^3` between `10^100` and `10^300` (the
crossover is genuine but astronomically slow — this is why the phenomenon is invisible in any
numerical experiment on a real counting function), while it stays far below `x^{0.05}` at
every scale.  Both halves are proved:

* `ChebotarevGeodesic.exp_sqrt_log_le_rpow` and
  `ChebotarevGeodesic.hasLogErrorExponent_sqrtLogModel` — subpolynomial;
* `ChebotarevGeodesic.eventually_lt_exp_sqrt` and
  `ChebotarevGeodesic.not_hasLogErrorExponent_sqrtLogModel` — superlogarithmic.

Consequently `logExponentRegion (sqrtLogModel M θ) M = {(θ', k) : θ' > θ}` — an open
half-plane with no corner (`ChebotarevGeodesic.logExponentRegion_sqrtLogModel`,
`ChebotarevGeodesic.logCornerSet_sqrtLogModel`), which together with the model term
`K x^θ (log x)^k` (corner `(θ, k)`) and an exponential error term (empty region) realizes all
three shapes allowed by the classification `ChebotarevGeodesic.logExponentRegion_eq`.

A caveat recorded honestly: these `Float` numbers are exploratory only.  Every claim above
that is asserted as a fact is backed by the corresponding sorry-free Lean theorem; the table
itself is not part of any proof.
