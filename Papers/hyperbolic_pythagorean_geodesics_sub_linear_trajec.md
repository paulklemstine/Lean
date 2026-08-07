# Computational Evidence

All numbers below were produced with `#eval` inside the project's Lean/Mathlib environment
(`Float` arithmetic for the transcendental quantities, exact `Nat` arithmetic for the
number theory). They motivated — and constrained — the theorems that were subsequently
proved in `Catalog/Geometry/HyperbolicBerggrenGeodesics.lean`.

## 1. The distance formula and the `½ log c` law

Euclid seed `(m,n)` ↦ half-plane point `z(m,n) = (n + i)/m`, base point `i`.
Mathlib's `UpperHalfPlane.cosh_dist'` gives `cosh d = (m² + n² + 1)/(2m) = (c+1)/(2m)`.

Along the *left spine* `(2,1) → (3,2) → (4,3) → …` (depth `k` ↦ seed `(k+2, k+1)`):

| depth k | hypotenuse c | d = d_ℍ(i, z) | ½ log c | d − ½ log c |
|---|---|---|---|---|
| 0 | 5   | 0.962424 | 0.804719 | 0.157705 |
| 1 | 13  | 1.490996 | 1.282475 | 0.208522 |
| 2 | 25  | 1.847246 | 1.609438 | 0.237808 |
| 3 | 41  | 2.113748 | 1.856786 | 0.256962 |
| 4 | 61  | 2.325875 | 2.055437 | 0.270438 |
| 5 | 85  | 2.501745 | 2.221326 | 0.280419 |
| 6 | 113 | 2.651796 | 2.363694 | 0.288102 |
| 7 | 145 | 2.782560 | 2.488367 | 0.294193 |
| 8 | 181 | 2.898389 | 2.599249 | 0.299140 |

Observations that shaped the formal statement:

* The residual `d − ½ log c` stays in `[0.157, 0.30]`, comfortably inside the proved
  envelope `±log 2 = ±0.6931`. Numerically it increases monotonically towards `½ log 2 ≈ 0.3466`
  (the spine has `m/n → 1`, hence `m ≈ √(c/2)`), so the *constant* `log 2` in
  `hyperbolic_dist_eq_half_log_hypotenuse` is not tight for this branch — but it is proved
  for **all** seeds, where both `m ≈ √c` (residual `→ −? `) and `m ≈ √(c/2)` occur.
* Depth `k` versus hypotenuse `c = 2k² + 6k + 5`: the spine reaches hypotenuse `c` only at
  depth `≈ √(c/2)`. This **falsified** the naive reading of the mission statement
  ("`O(log N)` path length" understood as tree depth) and forced the correct formulation:
  it is the *hyperbolic* length, not the combinatorial depth, that is logarithmic.
  The corresponding negative result is `depth_not_bounded_by_distance`.

## 2. Counterexample hunt for "depth is `O(log c)`"

Searching the left spine directly: at depth `k` the hypotenuse is `2k² + 6k + 5`, so
`k / log c → ∞`. Explicitly `k = 8` already gives `c = 181`, `log c = 5.198`, while a
logarithmic-depth hypothesis with any fixed constant `C` fails for `k > C·log(2k²+6k+5)`.
This is a genuine counterexample, and it is formalised (`spine_hypotenuse`,
`depth_not_bounded_by_distance`).

## 3. Hypotenuse collisions and factorization

Enumerating all Euclid seeds with `m < 20` and grouping by `c = m² + n²`, the first
collisions `(N, seed₁, seed₂, gcd(N, m₁m₂ + n₁n₂))` are:

```
(65,  (7,4),   (8,1),  5)     (85,  (7,6),   (9,2),  5)
(145, (9,8),   (12,1), 29)    (185, (11,8),  (13,4), 5)
(221, (11,10), (14,5), 17)    (265, (12,11), (16,3), 5)
(205, (13,6),  (14,3), 5)     (365, (14,13), (19,2), 73)
(305, (16,7),  (17,4), 5)     (377, (16,11), (19,4), 29)
(425, (16,13), (19,8), 17)    (325, (17,6),  (18,1), 13)
```

In every sampled case `gcd(N, m₁m₂ + n₁n₂)` is a *non-trivial* divisor of `N`
(65 = 5·13, 85 = 5·17, 145 = 5·29, 221 = 13·17, 365 = 5·73, 377 = 13·29, …).
No counterexample was found. This is exactly the content of
`euler_two_representations_factor` / `berggren_collision_factors`, which are proved in
full generality; the case `N = 65` is additionally recorded as a verified Lean theorem
(`berggren_collision_65`, `berggren_collision_65_value`, `sixtyfive_not_prime`).

## 4. Sequences

The spine hypotenuses `5, 13, 25, 41, 61, 85, 113, 145, 181, …` are the centred square
numbers `2k² + 6k + 5` (`A001844` shifted), i.e. the hypotenuses of the classical
"near-isosceles" triples `(3,4,5), (5,12,13), (7,24,25), (9,40,41), …`. Their appearance as
a *single geodesic ray* in the half-plane is what makes the depth/distance gap possible.

## Status

Items 1–3 are numerical exploration; every claim that this project asserts as a result has
an independent, sorry-free Lean proof in `Catalog/Geometry/HyperbolicBerggrenGeodesics.lean`.
The tables above are evidence, not verification.

---

# Cycle II–III evidence

The tables below were produced the same way (`#eval` in the project's Lean/Mathlib
environment). They are evidence, not verification; every claim asserted as a result has a
sorry-free proof in `Catalog/Geometry/HyperbolicBerggrenGeodesicsII.lean` or
`Catalog/Geometry/HyperbolicBerggrenDensity.lean`.

## 5. The sharpened trajectory window

Section 1 recorded the residual `d − ½ log c` along the spine rising monotonically through
`0.157, 0.208, …, 0.299` towards `½ log 2 = 0.34657`. That is exactly the width of the
window now proved for **all** seeds:

`0 ≤ d − ½ log c ≤ ½ log 2 + 1/(2c)`  (`trajectory_window`).

The lower end is attained in the limit `n/m → 0` (`m ≈ √c`, residual `→ 0`), the upper end
in the limit `n/m → 1` (`m ≈ √(c/2)`, the spine). The first cycle's `±log 2 = ±0.693` is
therefore loose by a factor of two on the upper side, and completely loose below.

## 6. Euler's double gcd: a collision splits `N` in two

For each pair of essentially distinct primitive representations `N = a²+b² = c²+d²` put
`P = ac+bd`, `Q = ad+bc`. Exhaustive check over all such pairs with seeds `m < 25`:

```
N     gcd(N,P)  gcd(N,Q)   product = N ?
65      5         13          yes
85      5         17          yes
145    29          5          yes
185     5         37          yes
205     5         41          yes
221    17         13          yes
265     5         53          yes
305     5         61          yes
325    13         25          yes
365    73          5          yes
377    29         13          yes
425    17         25          yes
445     5         89          yes
481    13         37          yes
485    97          5          yes
493    29         17          yes
505     5        101          yes
533    13         41          yes
545     5        109          yes
565     5        113          yes
697    17         41          yes
```

No counterexample was found, including for `N = 325 = 5²·13` and `N = 425 = 5²·17`, where
the split is `13 × 25` and `17 × 25` — the repeated prime stays inside one factor. This
motivated, and is now subsumed by, the proved theorem `euler_gcd_product`
(`gcd(N,P)·gcd(N,Q) = N` for odd `N` with two primitive representations).

## 7. The explicit infinite collision family

Seeds `(20j+9, 10j+2)` and `(20j+7, 10j+6)` both have hypotenuse `500j² + 400j + 85`:

```
j    N       gcd(N,P)   gcd(N,Q)   product = N ?
0    85         5          17         yes
1    985        5         197         yes
2    2885       5         577         yes
3    5785       5        1157         yes
```

The first factor is always `5` (proved: `collFamily_divisor`), the cofactor grows
quadratically, and the family witnesses `exists_collision_gt`: collisions occur at every
scale.

## 8. Seed density in the sieve box

Number of coprime pairs `(m, n)` with `m` even in `(2K, 4K]` and `n` odd in `[1, 2K]`:

```
K      count     count / K²
16       213      0.8320
64      3327      0.8123
128    13231      0.8078
```

The empirical density is `≈ 8/π² = 0.8106`. The proved sieve bound
(`card_seedBox_lower`) gives `count ≥ K²/4 = 0.25 K²` for `K ≥ 256` — a factor `3.2`
below the truth, which is the price of the crude telescoping estimates
`∑_{odd d ≥ 3} 1/d² ≤ 1/4` and `∑_{i<n} 1/(2i+3) ≤ √(2n+1) − 1`. The constant loss is
irrelevant for the growth exponent: it only changes `e^{2R}/300` into `e^{2R}/c` for a
smaller `c`.

## 9. Cycle IV: ball counts and semiprime collisions

Node counts inside the hyperbolic ball `B(R)` around `i` (all Euclid seeds `(m,n)` with
`cosh d = (m²+n²+1)/(2m) ≤ cosh R`), compared with the two bounds now proved,
`e^{2R}/300 ≤ #B(R) ≤ 4·e^{2R}`:

| `R` | `e^{2R}/300` | `#B(R)` (counted) | `4·e^{2R}` | `#B(R)/e^{2R}` |
|-----|--------------|-------------------|------------|----------------|
| 4   | 9.9          | 388               | 11 924     | 0.1302         |
| 5   | 73.4         | 2 866             | 88 106     | 0.1301         |
| 6   | 542.5        | 21 190            | 651 019    | 0.1302         |

(The counts were obtained by direct enumeration; they are exploratory numerics, not a Lean
verification.  The two bounding columns *are* theorems: `hyperbolic_ball_quadratic_growth`
and `ball_card_upper`.)  The ratio is strikingly stable at `0.1302`, and it has an exact
predicted value.  The ball condition `m²+n²+1 ≤ 2m cosh R` is the Euclidean disc of centre
`(cosh R, 0)` and radius `sinh R`; in polar coordinates it is `r = 2 cosh R · cos θ`, so the
part of it inside the wedge `0 < n < m` (i.e. `0 < θ < π/4`) has area
`sinh²R·(π/4 + 1/2) ≈ (π/4+1/2)/4 · e^{2R}`.  Multiplying by the density `4/π²` of coprime
opposite-parity lattice pairs gives

`#B(R) ~ (π+2)/(4π²) · e^{2R} = 0.130 24… · e^{2R}`,

which matches all three counted values to four decimals.  This *replaces* the constant
guessed in conjecture **D1** below.

For semiprime hypotenuses the collision splitting is exact.  Sample (both nodes primitive):

| `N = p·q` | node 1 | node 2 | `gcd(N, m₁m₂+n₁n₂)` | `gcd(N, m₁n₂+n₁m₂)` |
|-----------|--------|--------|---------------------|---------------------|
| `65=5·13` | (8,1)  | (7,4)  | 5                   | 13                  |
| `85=5·17` | (9,2)  | (7,6)  | 5                   | 17                  |
| `145=5·29`| (12,1) | (9,8)  | 29                  | 5                   |
| `221=13·17`|(14,5) | (11,10)| 17                  | 13                  |

Both orderings occur, which is exactly the disjunction proved in
`semiprime_collision_splits_exactly`.

## 10. Cycle V: the residual and branch monotonicity

Residual `resid(m,n) = d - ½ log c` against its slope model
`residAsym(m,n) = ½ log(1 + (n/m)²)`:

| `(m,n)` | `resid`  | `residAsym` | gap      | `1/c`    |
|---------|----------|-------------|----------|----------|
| (2,1)   | 0.157705 | 0.111572    | 0.046133 | 0.200000 |
| (4,1)   | 0.033968 | 0.030312    | 0.003656 | 0.058824 |
| (5,2)   | 0.079099 | 0.074210    | 0.004889 | 0.034483 |
| (9,4)   | 0.091845 | 0.090131    | 0.001714 | 0.010309 |
| (20,9)  | 0.092552 | 0.092201    | 0.000351 | 0.002079 |

Over the 721 Euclid seeds with `m < 60` the gap is always positive and always below `1/c`
(the largest observed value of `c·gap` is `0.4915`), matching `resid_sandwich`.

Branch monotonicity, same 721 seeds, counting violations of
"residual does not decrease along `B₁`", "does not increase along `B₂`", "does not increase
along `B₃`":

| branch | violations |
|--------|------------|
| `B₁`   | 0          |
| `B₂`   | 298        |
| `B₃`   | 0          |

So the middle branch is the odd one out.  The smallest violating seed is `(4,1)`, with
`resid(4,1) = 0.033968 < 0.091845 = resid(9,4)`; this is the counterexample formalised in
`resid_four_one_lt_resid_nine_four`.  The mechanism is transparent in slope coordinates:
`B₂` sends `t = n/m` to `1/(2+t)`, which is below `t` only when `t > √2 - 1 ≈ 0.4142`, and
`1/4 < √2 - 1`.

## 11. Cycle VI: the sharp sandwich and exact branch monotonicity

*(Numerical exploration, computed in 60-digit fixed-point arithmetic.  It is evidence only:
every statement quoted here that is claimed as a result is separately proved in
`Catalog/Geometry/HyperbolicBerggrenBranchExact.lean`.)*

**The sharp sandwich is essentially optimal.**  Cycle VI replaces the cycle-V error bound
`1/c` by `(n² + 1)/(c(c+1))`.  Over all 2898 Euclid seeds with `m < 120`, the ratio

`(resid − residAsym) / ((n²+1)/(c(c+1)))`

is always in `(0, 1]`, and its maximum is `0.9999729…`, attained at the seed `(119,118)` —
i.e. the bound is attained in the limit `n/m → 1` and cannot be improved by any constant
factor.

**Exact branch monotonicity, all 2898 seeds with `m < 120`.**

| statement                                                    | violations |
|--------------------------------------------------------------|------------|
| `resid(m,n) ≤ resid(2m−n, m)`   (`B₁`, unconditional)          | 0          |
| `resid(m+2n, n) ≤ resid(m,n)`   (`B₃`, unconditional)          | 0          |
| `B₂` moves as the sign of `2mn + n² − m²` predicts              | 0          |

**The boundary layer.**  The seeds with `m² = 2mn + n² + 1` — equivalently `(m−n)² = 2n²+1`,
the Pell family `(5,2), (29,12), (169,70), (985,408), …` — are the ones no real-variable
argument reaches.  For them the exact residual does increase along `B₂`, but by very little:

| `(m,n)`     | `resid(m,n)`      | `resid(2m+n,m)`   | increase        |
|-------------|-------------------|-------------------|-----------------|
| (5,2)       | 0.0790992590      | 0.0809220721      | 1.82 · 10⁻³     |
| (29,12)     | 0.0791735275      | 0.0792246230      | 5.11 · 10⁻⁵     |
| (169,70)    | 0.0791735919      | 0.0791750937      | 1.50 · 10⁻⁶     |
| (985,408)   | 0.07917359191     | 0.07917363612     | 4.42 · 10⁻⁸     |

The polynomial certificate used in `b2pell_poly` compares
`2m²(5m²+4mn+n²)(n²+1)` with `(m+n)²c(c+1)`; its relative margin is

| `(m,n)`   | left side            | right side           | margin  |
|-----------|----------------------|----------------------|---------|
| (5,2)     | 42250                | 42630                | 0.90 %  |
| (29,12)   | 1400172490           | 1632604010           | 16.60 % |
| (169,70)  | 54598208663050       | 63956783283822       | 17.14 % |
| (985,408) | 2140022895135258250  | 2507182393951115090  | 17.16 % |

so the whole difficulty of the boundary layer sits at the single seed `(5,2)`, where the
margin is under one percent; along the family the margin increases monotonically to its
limiting value `17.157 %`, the value at the limiting slope `n/m → √2 − 1`.

## 12. Cycle VII: the residual gap, two-sided

*(Numerical exploration in 60-digit arithmetic; the statements themselves are proved in
`Catalog/Geometry/HyperbolicBerggrenSandwichExact.lean`.)*

The gap `resid − residAsym` against its new two-sided bounds `n²/(c²+n²)` and `n²/(c(c−1))`,
with the cycle-VI bound `(n²+1)/(c(c+1))` for comparison:

| `(m,n)`    | lower `n²/(c²+n²)` | true gap      | upper `n²/(c(c−1))` | cycle-VI bound |
|------------|--------------------|---------------|---------------------|----------------|
| (2,1)      | 0.0384615          | 0.0461329     | 0.0500000           | 0.0666667      |
| (4,1)      | 0.00344828         | 0.00365553    | 0.00367647          | 0.00653595     |
| (5,2)      | 0.00473373         | 0.00488926    | 0.00492611          | 0.00574713     |
| (9,4)      | 0.00169761         | 0.00171377    | 0.00171821          | 0.00178834     |
| (20,9)     | 0.000349980        | 0.000350647   | 0.000350832         | 0.000353689    |
| (119,118)  | 1.765255 · 10⁻⁵    | 1.765302·10⁻⁵ | 1.765349 · 10⁻⁵     | 1.765350·10⁻⁵  |

Over all 2898 Euclid seeds with `m < 120` the two-sided bound holds without exception, and the
relative width `(upper − lower)/gap` is at most `0.2501`, attained at the root seed `(2,1)`;
it decays like `2/(c−1)`, as `resid_gap_two_sided_ratio` asserts.  The comparison with the
cycle-VI column shows where the gain lies: at small slope (`(4,1)`) the old bound overestimates
by a factor `1.79`, while the new one is within `0.6 %`.

## Cycle VIII exploration — the depth function (unverified numerics, except where a theorem is cited)

All numbers below were produced by an independent script implementing the inverse Berggren
move `parentSeed` exactly as it is defined in
`Catalog/Geometry/HyperbolicBerggrenTreeDepth.lean`, and are *evidence*, not verification;
the corresponding statements that are actually proved are named in each item.

**1. Termination of the parent map (evidence for `seed_reaches`).**
For all **8076** Euclid seeds with `m < 200`, iterating `parentSeed` reaches the root `(2,1)`
in finitely many steps — no cycles, no escapes.  This is what the Lean proof establishes in
general, by strong induction on `m` via `parentSeed_fst_lt`.

**2. The size bounds at each depth (evidence for `reaches_fst_le`, `reaches_hypot_le`).**

| seed `(m,n)` | depth `k` | hypotenuse `c` | `2·3^k` | `8·9^k` |
|--------------|-----------|----------------|---------|---------|
| (2,1)        | 0         | 5              | 2       | 8       |
| (3,2)        | 1         | 13             | 6       | 72      |
| (4,1)        | 1         | 17             | 6       | 72      |
| (5,2)        | 1         | 29             | 6       | 72      |
| (12,5)       | 2         | 169            | 18      | 648     |
| (29,12)      | 3         | 985            | 54      | 5832    |
| (70,29)      | 4         | 5741           | 162     | 52488   |
| (169,70)     | 5         | 33461          | 486     | 472392  |
| (20,1)       | 9         | 401            | 39366   | ≈3.1·10⁹ |
| (101,100)    | 99        | 20201          | ≈3.4·10⁴⁷ | ≈2.4·10⁹⁵ |

`m ≤ 2·3^k` and `c ≤ 8·9^k` hold on all 8076 seeds with zero violations.  The last two rows
show how loose the bound becomes on the two parabolic spines — precisely the phenomenon that
makes the reverse inequality false (cycle I).

**3. The Pell spine is the fast branch (evidence for `mspine_hypot_ge`,
`berggren_depth_logarithmic_reach`).**  `mspine k` computes to
`(2,1), (5,2), (12,5), (29,12), (70,29), (169,70)` — the Pell numbers — with hypotenuses
`5, 29, 169, 985, 5741, 33461` (the NSW numbers), all `≥ 4^{k+1}`.  Depth `k` therefore
reaches size `≈ 5.83^k`, so size `N` is reached at depth `≤ log₂ N`.

**4. Refutation of the continued-fraction law (theorem `no_universal_depth_cfSum_law`).**
With `Σaᵢ` the sum of the partial quotients of `n/m`:

| family | seed at depth `k` | slope | `Σaᵢ` | `depth / Σaᵢ` |
|--------|-------------------|-------|-------|----------------|
| pure `B₃` | `(2k+2, 1)`   | `1/(2k+2)` | `2k+2` | `→ 1/2` |
| pure `B₂` | `(P_{k+1}, P_k)` | `→ √2 − 1` | `2k+2` | `→ 1/2` |
| pure `B₁` | `(k+2, k+1)`  | `(k+1)/(k+2)` | `k+2` | `→ 1` |

Over all 8076 seeds with `m < 200` the deviation `depth − Σaᵢ` covers `[−100, −2]` and the
deviation `depth − Σ⌈aᵢ/2⌉` covers `[−4, +97]`; both extremes scale linearly with the search
bound, so neither `λ = 1` nor `λ = 1/2` — nor, by the theorem, any other constant — gives a
bounded error.
