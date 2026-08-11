# Computational evidence: the star at a general rational boundary point

Setting: Euclid seeds `(m,n)` (`0 < n < m`, `gcd(m,n)=1`, `m+n` odd) plotted in the
Poincaré half-plane by `z(m,n) = (n+i)/m`, so `Re z = n/m`, `Im z = 1/m`.

For a rational boundary point `p/q` (lowest terms) put the **charge**

```
k = charge(p,q; m,n) = p*m - q*n ,
```

so that `p/q - Re z = (k/q) * Im z`: the seeds of a fixed charge lie on **one** Euclidean
ray emanating from `p/q`. This is the mechanism producing the radial lines that are seen
at `0`, `1`, and also at `0.5 = 1/2`, `0.333… = 1/3`, `0.2 = 1/5`, etc.

## 1. Which charges actually occur (parity quantisation)

Enumerating all seeds with `m ≤ 400` and collecting the charges `|k| ≤ 8`:

| `p/q` | `p+q` | realised charges with `|k| ≤ 8` |
|---|---|---|
| `0/1` | odd  | `-8,-7,-6,-5,-4,-3,-2,-1`  (one-sided) |
| `1/1` | even | `1,3,5,7`  (one-sided, odd only) |
| `1/2` | odd  | all of `-8 … 8`, including `0` |
| `1/3` | even | `-7,-5,-3,-1,1,3,5,7` (odd only, no `0`) |
| `2/3` | odd  | all of `-8 … 8` |
| `1/4` | odd  | all of `-8 … 8` |
| `1/5` | even | odd only |
| `2/5` | odd  | all |
| `3/5` | even | odd only |
| `3/4` | odd  | all |

**Observed law.** If `p+q` is odd every integer charge occurs; if `p+q` is even (i.e. `p`
and `q` are both odd) exactly the *odd* charges occur. The two classical stars are the
special cases `p/q = 0/1` (all charges `k = -n`) and `p/q = 1/1` (odd charges `k = m-n`).
The extreme points `0` and `1` give one-sided fans; every interior rational gives a
two-sided fan.

This is proved as `charge_odd_of_odd_odd`, `exists_seed_charge_gt` and
`charge_zero_iff_seed_eq` in `Catalog/Pythagorean/RationalStarPencil.lean` and
`Catalog/Pythagorean/RationalStarRealization.lean`.

## 2. Density along one spoke

Counting seeds with `m ≤ M = 20000` on the spoke of charge `k` at `p/q`, and dividing by
`M/q` (the number of admissible `m` in range), with `K = |k|`:

| `p/q` | `k` | count | count/(M/q) | `φ(K)/K` |
|---|---|---|---|---|
| `1/2` | `1` | 4999 | 0.4999 | 1.0 |
| `1/2` | `2` | 5000 | 0.5000 | 0.5 |
| `1/2` | `3` | 3333 | 0.3333 | 0.6667 |
| `1/2` | `5` | 3999 | 0.3999 | 0.8 |
| `1/2` | `6` | 3333 | 0.3333 | 0.3333 |
| `1/3` | `1` | 6666 | 0.9999 | 1.0 |
| `1/3` | `2` | 0    | 0      | 0.5 |
| `1/3` | `3` | 4444 | 0.6666 | 0.6667 |
| `1/5` | `5` | 3200 | 0.8000 | 0.8 |
| `2/5` | `3` | 1334 | 0.3335 | 0.6667 |
| `1/1` | `3` | 13332| 0.6666 | 0.6667 |

**Observed law.** The density is `φ(K)/K` except when `p+q` is odd *and* `K` is odd, where
it is `φ(K)/(2K)`. The explanation found (and proved) is the unimodular substitution
`(m,n) = (k b + s q, k a + s p)` with `p b - q a = 1`, under which

```
gcd(m,n) = gcd(k,s)      and      m + n = k(a+b) + s(p+q),
```

so the seeds on a spoke are indexed by the integers `s` coprime to `k` and (when `p+q` is
odd) of one fixed parity. The exact window count is `windowCount_eq_totient`.

## 3. Minimal spoke separation

For a star at `p/q` the possible distances from the vertical geodesic over `p/q` are
`arsinh(|k|/q)`. Hence the closest off-axis spoke sits at `arsinh(1/q)`, which decreases
in `q`: the star at a small denominator is *wide* and individually visible, while a large
denominator produces a pencil compressed into a sliver of width `arsinh(1/q)` around its
axis. That is why `0, 1, 1/2, 1/3, 1/5` are the conspicuous star centres in the plot.
Formalised as `arsinh_inv_q_le_distVLine` and `distVLine_le_of_charge_le`.

## 4. Counterexample hunt

* Searched all `p/q` with `q ≤ 12` and all seeds with `m ≤ 400`: no charge violating the
  parity law was found (consistent with `charge_odd_of_odd_odd`).
* Searched for a second seed of charge `0` at a fixed `p/q`: none exists — the axis of a
  star carries at most the single node `(m,n) = (q,p)` (proved:
  `charge_zero_iff_seed_eq`).
* All spokes with an admissible charge were found to be infinite in the range searched,
  matching `exists_seed_charge_gt`.

## 5. Second cycle: resolution and the Farey count

The Euclidean gap between two adjacent rays of the star at `p/q`, measured at plot height
`y = Im z`, is exactly `y/q` (`adjacent_ray_gap`). At `y = 0.5`:

| `q` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| gap `y/q` | 0.500 | 0.250 | 0.167 | 0.125 | 0.100 | 0.083 | 0.071 | 0.063 |

So at a plot resolution of one part in ten, only `q ≤ 5` is resolved; those centres are
`1/1, 1/2, 1/3, 2/3, 1/4, 3/4, 1/5, 2/5, 3/5, 4/5` — exactly the fans the eye picks out in
the rendered star map, together with `0`. The count of resolvable centres in `(0,1]` is the
Farey count `∑_{q ≤ Q} φ(q)`:

| `Q` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| `∑_{q≤Q} φ(q)` | 1 | 2 | 4 | 6 | 10 | 12 | 18 | 22 | 28 | 32 |

(OEIS A002088, the summatory totient; asymptotically `3Q²/π²`.) The value `10` at `Q = 5` is
formalised as `card_fareyStars_five`, and the general count as `card_fareyStars`.

## 6. Second cycle: transport of the stars

Under the covariance identity `chargeZ p q (B(m,n)) = chargeZ (T(p,q)) (m,n)` the three
Berggren moves act on the star parameter `(p,q)`. Iterating `T₁(p,q) = (2p-q, p)` on the
ladder `(k, k+1)`:

| `k` | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| `T₁ᵏ(k, k+1)` | `(0,1)` | `(0,1)` | `(0,1)` | `(0,1)` | `(0,1)` | `(0,1)` | `(0,1)` |

every rung lands on the `0`-star (`ladder_transport_zero_star`). Scanning all words of
length `≤ 9` in the three generators applied to `(1,1)` and to `(0,1)`, the parity of
`p + q` never changed — the invariant of `transWord_parity`; in particular no word carried
`(1,1)` to `(0,1)`, so the two principal fans are genuinely inequivalent.
