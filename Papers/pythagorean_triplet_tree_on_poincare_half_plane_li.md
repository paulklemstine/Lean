# Computational Evidence — Berggren tree in the Poincaré half-plane

All numbers below were produced by direct enumeration over Euclid seeds
`(m,n)` (`0 < n < m`, `gcd(m,n) = 1`, `m+n` odd), with
`z(m,n) = (n+i)/m` and `cosh d(i, z(m,n)) = (m²+n²+1)/(2m)`.
Every claim that ended up as a theorem is proved in the Lean files in
`Catalog/NumberTheory/`; the tables here are the exploratory data that led to
those statements, not a substitute for them.

---

## 1. The star lines (what "radiates" in the picture)

Two exact incidence identities explain the two visible pencils of collinear
points (proved: `BerggrenStarLines.hpoint_star_zero`, `hpoint_star_one`):

| pencil | invariant | Euclidean equation satisfied by `z = x + iy` |
|---|---|---|
| star at the ideal point `0` | `n` (fixed) | `x = n·y` |
| star at the ideal point `1` | `u = m − n` (fixed) | `1 − x = u·y` |

So the nodes with a fixed second Euclid coordinate `n` lie on the Euclidean ray
from `0` of slope `1/n`, and the nodes with a fixed `u = m−n` lie on the ray
from `1`. Both rays are **hypercycles**: the ray `x = n y` is at constant
hyperbolic distance `arsinh n` from the vertical geodesic `x = 0`.
Numerical check of the resulting minimal `cosh`-distance for the `1`-star of
charge `u = 3` (seed `(19,16)`):

```
min_s cosh d( z(19,16), 1 + i s )  = 3.16227773   (numeric minimisation)
sqrt(1 + u^2) = sqrt(10)           = 3.16227766   (proved value)
```

**Quantisation.** Searching all seeds with `m ≤ 400` we found arms of the
`1`-star only for **odd** charges `u`, and arms of the `0`-star for **every**
charge `n`. This asymmetry (proved: `star_one_param_iff`, `star_zero_param_iff`,
`stars_not_isometric`) is why the two stars look different in the picture even
though each is a parabolic pencil.

**Arm counts.** The number of *maximal arms* on a star line, i.e. residues
modulo the translation, was computed and matched Euler's totient exactly
(proved: `star_one_line_arm_count`, `star_zero_line_arm_count`):

| charge `n` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| arms on `0`-line, counted | 1 | 2 | 2 | 4 | 4 | 4 | 6 | 8 | 6 | 8 | 10 | 8 | 12 | 12 |
| `φ(2n)` | 1 | 2 | 2 | 4 | 4 | 4 | 6 | 8 | 6 | 8 | 10 | 8 | 12 | 12 |

## 2. The grid structure of the node set

In the coordinates `(u, n) = (m − n, n)` the seeds are exactly the pairs with
`u` odd and `gcd(u,n) = 1` (proved: `isSeed_iff_grid`). Verified by brute force
for all `u, n ≤ 40`: 0 discrepancies. Every node is therefore the intersection
of exactly one `1`-star line and one `0`-star line — the visible "lattice of
stars".

## 3. Steps along an arm tend to zero (parabolic regime)

Along the left spine `(k+2, k+1)` (a `B₁`-arm) the exact step is
`cosh d_k = 1 + 1/((k+2)(k+3))` (proved: `armL_step_cosh`,
`armL_step_tendsto_zero`):

| k | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| `cosh d_k` | 1.1666667 | 1.0833333 | 1.0500000 | 1.0333333 | 1.0238095 | 1.0178571 |
| `d_k` | 0.5696181 | 0.4054651 | 0.3149248 | 0.2574870 | 0.2177872 | 0.1887021 |

The steps shrink like `Θ(1/k)`: the arm is a *parabolic* orbit, and the picture
shows the points crowding into a single ideal point.

## 4. Steps along the Pell spine tend to `log(1+√2)` (hyperbolic regime)

Middle spine `μ_{k+1} = (2m+n, m)` from `(2,1)`; `S = m² − 2mn − n²`:

| k | `(m,n)` | `S` | `m_{k+1}/m_k` | step `d_k` | `log(1+√2) − d_k` |
|---|---|---|---|---|---|
| 0 | (2,1) | −1 | 2.500000000 | 0.962423650 | −8.11e−02 |
| 1 | (5,2) | +1 | 2.400000000 | 0.883822448 | −2.45e−03 |
| 2 | (12,5) | −1 | 2.416666667 | 0.883822448 | −2.45e−03 |
| 3 | (29,12) | +1 | 2.413793103 | 0.881445735 | −7.22e−05 |
| 4 | (70,29) | −1 | 2.414285714 | 0.881445735 | −7.22e−05 |
| 5 | (169,70) | +1 | 2.414201183 | 0.881375711 | −2.12e−06 |
| 6 | (408,169) | −1 | 2.414215686 | 0.881375711 | −2.12e−06 |
| 7 | (985,408) | +1 | 2.414213198 | 0.881373650 | −6.25e−08 |
| 8 | (2378,985) | −1 | 2.414213625 | 0.881373650 | −6.25e−08 |

Two observations drove the formalisation:

* `S = (−1)^{k+1}` exactly — the spine is the union of the two Pell families
  `(m−n)² − 2n² = ±1` (proved: `BerggrenSpineStep.pell_invariant`).
* the step lengths converge to `log(1+√2) = 0.8813735870…`, the translation
  length of the corresponding hyperbolic isometry (proved:
  `mspine_step_tendsto_log_silver`). Note the *pairing* of consecutive rows: the
  step depends on `m_k, m_{k+1}` only through their ratio plus a `1/(m_k m_{k+1})`
  correction, and the ratios straddle the silver ratio alternately.

The observed convergence rate of the ratio is `≈ (3−2√2)^k = 0.1716^k`, faster
than the `4^{-k}` we proved; the proved bound is what the elementary contraction
argument gives and is sufficient.

## 5. Counterexample hunt for the boundary limit set

**Question.** Do the nodes accumulate *only* on the two star tips `0` and `1`?

**Answer: no.** Dyadic seeds `(2^K, n)` with `n` odd are always seeds (no
coprimality or parity condition to check), and their slopes `n/2^K` are dense.
Approximating `t = π/4 = 0.7853981…`:

| K | `2^K` | `n` | seed? | `n/2^K − t` | `1/m` |
|---|---|---|---|---|---|
| 3 | 8 | 7 | yes | +0.0896018 | 0.125000 |
| 5 | 32 | 25 | yes | −0.0041482 | 0.031250 |
| 8 | 256 | 201 | yes | −0.0002419 | 0.003906 |
| 10 | 1024 | 805 | yes | +0.0007347 | 0.000977 |
| 12 | 4096 | 3217 | yes | +0.0000022 | 0.000244 |
| 13 | 8192 | 6433 | yes | −0.0001198 | 0.000122 |

This is exactly the construction formalised in
`BerggrenBoundaryLimitSet.seed_boundary_dense`: the limit set on the ideal
boundary is all of `[0,1]`, and the "stars" are only the most conspicuous
members of a continuum of radiating directions.

## 6. Boundary tips of constant Berggren words

Iterating a single generator on the slope `t = n/m`:

| generator | slope map | orbit of `t = 1/2` | limit | rate |
|---|---|---|---|---|
| `B₁` | `t ↦ 1/(2−t)` | 0.5, 0.666, 0.75, 0.8, … | `1` | `1 − t_k = Θ(1/k)` (parabolic) |
| `B₂` | `t ↦ 1/(2+t)` | 0.5, 0.4, 0.4166, 0.41379, … | `√2 − 1` | geometric |
| `B₃` | `t ↦ t/(1+2t)` | 0.5, 0.25, 0.1666, 0.125, … | `0` | `t_k = Θ(1/k)` (parabolic) |

Proved as `sL_rate_exact`, `sR_rate_exact`, `sM_iterate_dist`,
`boundary_tip_dichotomy`, and `no_polynomial_lower_bound_for_sM` (which rules
out the natural guess that the middle branch also converges at a polynomial
rate).

## 7. Residual window (sanity check against the source paper)

`ρ(m,n) = d(i, z(m,n)) − ½ log(m²+n²)` for the seeds tabulated in the source
paper: 0.157705, 0.208522, 0.033968, 0.079099, 0.145107, 0.007992, 0.091845,
0.080922, 0.079174 — all in `[0, ½ log 2) = [0, 0.34657)`; reproduced exactly.

## 8. Ball counts

Enumerating seeds with `cosh d ≤ cosh R`, i.e. `(m − cosh R)² + n² ≤ sinh² R`
(proved: `ball_iff_disc`):

| R | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|
| `#B(R) / e^{2R}` | 0.12890 | 0.13016 | 0.13012 | 0.13020 | 0.13024 | 0.13024 |

against the heuristic constant `(π+2)/(4π²) = 0.1302375…`. The exact
asymptotic constant is **not** proved and is listed in `FUTURE_DIRECTIONS.md`.

## 9. Exhaustive search over periodic Berggren words

Using the `2×2` seed matrices `B₁ = [[2,−1],[1,0]]`, `B₂ = [[2,1],[1,0]]`,
`B₃ = [[1,2],[0,1]]`, we computed the per-step translation length
`(1/p)·log λ_w` for **all** `9840` words `w` of period `p ≤ 8`:

| rank | word | per-step `(1/p) log λ_w` |
|---|---|---|
| max | `2`, `22`, `222`, … | 0.8813735870 = `log(1+√2)` |
| next | `12`, `21`, `23`, `32` | 0.7218177 |
| … | `1113` | 0.5158593 |
| min found | `1^a 3 1^b` (`p = 8`) | 0.3460800 |

The maximum is attained **only** by the powers of `2` (the Pell spine). This is
the numerical basis for Conjecture 5 in `FUTURE_DIRECTIONS.md`; it is an
exploratory computation, not a Lean-verified fact — only the `2^∞` value
`log(1+√2)` is proved (`mspine_step_tendsto_log_silver`).

## 10. Collision distances and the divisor they reveal

For every odd `N < 20000` carrying two distinct Euclid seeds (925 values of `N`)
we computed the Euler pivot `P = m₁m₂ + n₁n₂`, the divisor `g = gcd(N,P)`, and the
hyperbolic distance between the two colliding nodes. In **every** case the exact
identity

```
cosh d(z₁,z₂)  =  1 + ((N² − P²) + (m₁ − m₂)²) / (2 m₁ m₂)
```

agreed with the direct two-node formula to machine precision, and both bounds
`cosh d ≥ 1 + g/2` and `d ≥ log g − log 2` held (all three are now proved in
`Catalog/NumberTheory/BerggrenCollisionDistance.lean`).

| N | `(m₁,n₁)` | `(m₂,n₂)` | `P` | `g` | `cosh d` | `d` | `log g − log 2` |
|---|---|---|---|---|---|---|---|
| 65 | (7,4) | (8,1) | 60 | 5 | 6.5893 | 2.5728 | 0.9163 |
| 85 | (7,6) | (9,2) | 75 | 5 | 13.7302 | 3.3114 | 0.9163 |
| 145 | (9,8) | (12,1) | 116 | 29 | 36.0833 | 4.2788 | 2.6741 |
| 221 | (11,10) | (14,5) | 204 | 17 | 24.4870 | 3.8909 | 2.1401 |
| 19225 | (123,64) | (136,27) | 18456 | 769 | 867.1184 | 7.4583 | 5.9519 |
| 19405 | (99,98) | (138,19) | 15524 | 3881 | 4962.2418 | 9.2028 | 7.5707 |
| 19945 | (108,91) | (141,8) | 15956 | 3989 | 4703.1992 | 9.1491 | 7.5981 |

The last two rows are the interesting ones: when the extracted divisor is large
(`g ≈ √N` or above), the bound `log g − log 2` already forces the two witnesses
to be almost as far apart as the radius `½ log N ≈ 4.95` of the annulus they live
in — a *balanced* collision is a maximally separated pair. This is the
quantitative form of the no-free-lunch principle proved as
`collision_dist_ge_half_log_of_large_divisor`.


## 11. A refuted guess (recorded because the refutation is informative)

Guess: `d(z₁,z₂) = log max(g, N/g) + O(1)` — "balanced factorisations put the two
witnesses far apart". **False.** Over the 2465 collisions with `N < 60000` the
quantity `d − log max(g, N/g)` ranges over `[−6.69, +4.53]`; the extreme negative
case is `N = 52565 = 5 · 10513`, where `d = 2.568` but `log max = 9.26`.

What *is* true (and now proved, `collision_cosh_two_sided`) is that the pivot
deficit `N − P` is the controlling parameter:
`(cosh d − 1)/(N − P)` was found to lie in `[1.0028, 1.7824]` over the same 2465
collisions, comfortably inside the proved window `[1/2, 2 + 2/(N−P)]`.

A second observation from the same sweep, currently unproved and recorded as
Conjecture 4: `gcd(N, |n₁m₂ − n₂m₁|) = gcd(N, m₁m₂ + n₁n₂)` in all 2465 cases.
