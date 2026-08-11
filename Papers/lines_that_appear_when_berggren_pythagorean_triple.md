# Computational evidence: the radial lines of the Berggren star map

All data below was produced by direct enumeration of Euclid seeds
`{(m,n) : 0 < n < m, gcd(m,n) = 1, m+n odd}` (the nodes of the Berggren tree under the
Euclid embedding `z(m,n) = (n+i)/m` into the Poincaré half-plane).

Throughout, for a boundary rational `p/q` in lowest terms we call

    k(p,q;m,n) = q·n − p·m      the **star charge**,

because `Re z − p/q = (k/q)·Im z`, i.e. the node lies on the Euclidean ray out of the ideal
point `p/q` whose "parameter" is `k/q`, at hyperbolic distance `arsinh(|k|/q)` from the
geodesic over `p/q`.

## A. The charge spectrum is a parity class (the quantisation law)

Enumerating all seeds with `m ≤ 800` and recording which charges `|k| ≤ 8` actually occur:

| p/q | predicted spectrum | observed charges with `|k| ≤ 8` |
|---|---|---|
| 0/1 | all (k > 0) | 1,2,3,4,5,6,7,8 |
| 1/1 | odd (k < 0) | −7,−5,−3,−1 |
| 1/2 | all | −8 … 8 (every integer) |
| 1/3 | odd | ±1, ±3, ±5, ±7 |
| 2/3 | all | −8 … 8 |
| 1/4 | all | −8 … 8 |
| 3/4 | all | −8 … 8 |
| 1/5 | odd | ±1, ±3, ±5, ±7 |
| 2/5 | all | −8 … 8 |
| 3/5 | odd | ±1, ±3, ±5, ±7 |
| 1/7, 3/7, 5/7 | odd | ±1, ±3, ±5, ±7 |
| 2/7, 4/7, 6/7 | all | −8 … 8 |

**Observed law.** The realised charges at `p/q` are *all* integers when `p+q` is odd, and
*exactly the odd* integers when `p+q` is even (i.e. when `p` and `q` are both odd).
Endpoints are one-sided (`k > 0` at `0/1`, `k < 0` at `1/1`) because `0 < n < m`.

This is proved in `Catalog/Cryptography/BerggrenStars/RationalStars.lean`
(`charge_odd_of_odd_odd` for the inclusion, `exists_seed_of_charge` for the converse).

## B. The resolution (visibility) ranking

Adjacent rays of the star at `p/q` differ in `sinh(distance)` by

    δ(p/q) = 1/q   if p+q is odd,        δ(p/q) = 2/q   if p+q is even.

Ranking the rationals of `[0,1]` by `δ`:

| p/q | 1/1 | 0/1 | 1/3 | 1/2 | 1/5 | 3/5 | 2/3 | 1/7,3/7,5/7 | 1/4,3/4 |
|---|---|---|---|---|---|---|---|---|---|
| δ | 2 | 1 | 0.667 | 0.5 | 0.4 | 0.4 | 0.333 | 0.286 | 0.25 |

The rationals with `δ ≥ 2/5` are exactly `0, 1/5, 1/3, 1/2, 3/5, 1`; numerically
`0, 0.2, 0.333, 0.5, 0.6, 1`. The stars reported as visible in the rendered picture were
at `0`, `0.2`, `0.33`, `0.5`, `1` — the predicted list, and the prediction `0.6` is the one
further testable consequence. Note that `1/4 = 0.25` is *not* in the list even though its
denominator is smaller than `5`: even denominators are penalised because a `p+q` odd star
has half the spacing of a `p+q` even one. This is the sharpest observable signature of
the law, and it matches the reported picture.

Formalised as `visible_rationals` in `RationalStars.lean`.

## C. The explicit ray construction

Bezout data `q·x − p·y = 1` and `A = 1 + k(x+y) + 2k²j` give the family

    (m, n) = (q·A + y·k,  p·A + x·k),

whose charge is `k` for every `j`. Example `p/q = 2/5`, `k = 3`, `(x,y) = (1,2)`:

| A | (m,n) | seed? | charge |
|---|---|---|---|
| 4 | (26,11) | yes | 3 |
| 10 | (56,23) | yes | 3 |
| 16 | (86,35) | yes | 3 |

(The intermediate `A = 7, 13` are the values killed by the parity condition; the arithmetic
progression `A ≡ 1 mod 2k` used in the formal proof selects exactly the good ones.)

The key identity behind coprimality is that `[[q,y],[p,x]]` has determinant `1`, so
`gcd(m,n) = gcd(A,k)`; taking `A ≡ 1 (mod k)` forces `gcd(m,n) = 1`.

## D. Step lengths along a rational ray

Consecutive lattice points of the ray at `p/q` of charge `k` are `(m,n)` and `(m+tq, n+tp)`;
their *seed cross product* is exactly `t·k`, so

    cosh(step) = (t²k² + m² + (m+tq)²) / (2m(m+tq)) → 1,

i.e. the hyperbolic steps tend to `0`: each ray is an infinite path of shrinking steps
gliding into the ideal point `p/q`. Sample (`p/q = 2/5`, `k = 1`; here `p+q` is odd, so
every *second* lattice point of the line is a seed, `t = 2`, cross product `2`):

| step | cosh(step) | length |
|---|---|---|
| (12,5)→(22,9) | 1.19697 | 0.61778 |
| (22,9)→(32,13) | 1.07386 | 0.38203 |
| (32,13)→(42,17) | 1.03869 | 0.27729 |
| (52,21)→(62,25) | 1.01613 | 0.17936 |

Formalised as `cosh_step_along_star_ray` / `step_along_star_ray_tendsto_zero` in
`RationalStarRays.lean`.

## E. OEIS

The counting function of maximal arms per star line at `0` and `1` is `φ(2q)`
(A062570), consistent with the catalog's earlier `StarMultiplicity` results; no new
sequence is claimed here. The charge spectra of Section A are arithmetic progressions,
not new sequences.
