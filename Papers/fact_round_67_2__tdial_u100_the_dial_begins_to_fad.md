# Computational evidence — TDIAL-U100 (round-67 #2, exp 540)

All computations below were run inside Lean 4 (`#eval` on exact `ℚ` arithmetic) against the
definitions that appear in `Catalog/Novelty/TDialU100RangeShape.lean`.  Nothing here is a
floating-point estimate except where a decimal is printed for readability; every claim that is
used in a theorem is proved symbolically in the Lean files.

## 1. The tie profile of an arbitrary range

`rangeBlocks n` is the 2-adic tie profile of the uniform range `{0,…,n−1}`.

| `n` | `rangeBlocks n` | sum |
|---|---|---|
| 8 | `[4, 2, 1, 1]` | 8 |
| 5 | `[2, 1, 1, 1]` | 5 |
| 100 | `[50, 25, 12, 6, 3, 2, 1, 1]` | 100 |

At `n = 2^b` it coincides with the dyadic profile `2^{b−1}, …, 1, 1` of
`Novelty.ZeroFitDialU64` (proved: `rangeBlocks_two_pow`).

## 2. The ceiling defect `devE n = Σ mⱼ³ − n³/7`

First values (exact rationals):

```
n      : 1     2     3     4     5      6     7    8     9      10    11
devE n : 6/7   6/7  -6/7   6/7  -48/7  -6/7  -12  6/7  -204/7 -48/7 -246/7
```

Observations, each of which became a theorem:

* `devE (2m) = devE m` — the defect depends only on the **odd part** of `n`
  (`devE_even`).  Checked: `devE 1000 = devE 125 = −43518/7`, `devE 96 = devE 3 = −6/7`.
* `devE (2^b) = 6/7` for `b = 0,…,11` (`devE_two_pow`), and `6/7` is never exceeded
  (`devE_le`), with equality exactly at powers of two (`devE_eq_iff_two_pow`).
* `7·devE` is an integer at every `n` tested: `6, 6, −6, 6, −48, −6, −84, 6, −204, …`
  (no OEIS lookup was possible in this offline environment; the sequence is recorded here for
  a later search).

## 3. Counterexample hunt for the fluctuation bound

Scan of `devE n / n²` for `1 ≤ n ≤ 3000`:

* minimum `−7932542/18516141 ≈ −0.428412` at `n = 2817`;
* no value below `−3/7 = −0.428571…` anywhere in the scan — consistent with the proved bound
  `devE n ≥ −(3/7) n²` (`devE_ge_sharp`), and no counterexample found.

The extremal family `nⱼ = 2^{j+1} + 1` (its halving chain `n ↦ (n+1)/2` stays odd all the way
down to 3) approaches the bound:

```
n        3        5        9       17       33       65      129      257      513     1025    2049    4097
E/n²  -0.0952  -0.2743  -0.3598  -0.3974  -0.4140  -0.4216  -0.4251  -0.4269  -0.4277 -0.4282 -0.4284 -0.4285
```

converging to `−3/7 = −0.428571…`, so the constant `3/7` is optimal
(`devE_extremal_family`).  The value at `n = 2817` (`−0.428412`) fits the same envelope.

## 4. The ceiling excess `ρ²(n) − 6/7`

```
n = 64   : 3/14560          ≈ 2.1e-4     (power of two, Θ(1/n²))
n = 63   : 1/192            ≈ 5.2e-3     (odd,           Θ(1/n))
n = 1024 : 3/3673600        ≈ 8.2e-7     (power of two)
n = 1023 : 769/2444288      ≈ 3.1e-4     (odd)
n = 100  : 131/388850       ≈ 3.4e-4
```

The dyadic/odd dichotomy (excess `Θ(1/n²)` versus `Θ(1/n)`) is visible already at `n = 63`
versus `n = 64`: a factor of about 25 at that size, and a factor above `10²⁸` at bitlen 100
(`range_shape_dichotomy_100`).

## 5. What this rules out for the recorded band miss

The recorded bitlen-100 pooled Spearman value is `0.544`, i.e. `ρ² ≈ 0.2959`.  Every ceiling
computed above is at least `6/7 ≈ 0.857`, and by `range_ceiling_upper` the ceiling of *any*
range of size `n ≥ 2¹⁰⁰` lies within `10⁻²⁹` of `6/7`.  No range shape, offset, modulus or
truncation of the draw window can account for the observed attenuation; the band miss must be
attributed to the response channel.

## 6. Cycle 3: the effective base at bitlen 100

Round 65 inverted the measured bitlen-76 value against the asymptotic `p`-adic ceiling
`padicLimit p = 3p/(p²+p+1)` and found the unique consistent base `p = 7`.  Repeating that
inversion with the bitlen-100 seed window `[0.528², 0.549²] = [0.278784, 0.301401]`:

```
p        padicLimit p = 3p/(p^2+p+1)
 2       6/7      ≈ 0.857143
 7       7/19     ≈ 0.368421
 8       24/73    ≈ 0.328767
 9       27/91    ≈ 0.296703     <-- inside the seed window
10       30/111   ≈ 0.270270
```

Base `9` is the unique base whose ceiling lies in the window (`effective_base_nine`); the
neighbours `8` and `10` bracket all three seeds (`seeds_bracketed_by_bases`), and monotonicity
of `padicLimit` (round 65) rules out every other base.  The gap between the two effective-base
ceilings is

```
7/19 - 27/91 = 124/1729 ≈ 0.071718
0.608^2 - 0.544^2       = 0.073728    (recorded drop in rho^2, bitlen 76 -> 100)
difference              ≈ 0.002010    <  0.003
```

so the recorded erosion over twenty-four bitlens is quantitatively one drift of the effective
base from `7` to `9` (`effective_base_drift_matches_drop`).  Cycle 3 also removes the main
caveat on that inversion: `padic_dominated_spearmanSq_lower` proves the `p`-adic ceiling for
*every* base-`p` dominated profile, not only for sample sizes of the form `p^b`.

## 7. Cycle 4: the floor-crossing forecast

Interpolating the `p`-adic ceiling to a real base, `padicLimitR t = 3t/(t²+t+1)`, and solving
`padicLimitR t = bandFloor² = 121/400 = 0.3025`:

```
t = 8.80  : 660/2181     ≈ 0.3026135   > 0.3025
t = 8.81  : 264300/874261 ≈ 0.3023130  < 0.3025
```

so the crossing base `t*` is bracketed by `8.80 < t* < 8.81` (and the quadratic
`121t² − 1079t + 121 = 0` has discriminant `1105677`, not a perfect square, so `t*` is
irrational — the crossing is proved to exist over `ℝ` by the intermediate value theorem, and
is unique by strict antitonicity).  Pushing `t*` through the linear drift calibration
`76 ↦ 7`, `100 ↦ 9`:

```
predicted first-miss bitlen = 76 + 12 (t* − 7) ∈ (97.6, 97.8)
observed: last clean rung 96, first band miss 100  (rung ladder of step 4)
```

The forecast lands strictly inside the observed window `(96, 100)`
(`floor_crossing_inside_observed_window`) and is falsifiable: it excludes a first miss at 96 or
earlier and at 100 or later on a step-4 ladder.
