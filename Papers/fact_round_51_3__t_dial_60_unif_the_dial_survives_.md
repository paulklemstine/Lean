# Computational Evidence

Small-case computations supporting the Lean development in `Catalog/Pythagorean/`
(`ZeroFitDialBalanced60.lean`, `ZeroFitDialWeightEnvelope60.lean`,
`ZeroFitDialBalancedClosure60.lean`, `ZeroFitDialHalfWeightBoundary60.lean`).

All numbers below were computed in exact rational arithmetic (Python `fractions.Fraction`)
before the corresponding statements were formalized. Everything that is *claimed* in the
project is proved in Lean; the tables here are exploratory scaffolding that guided the
constants, and the rows marked "formalized" are backed by a sorry-free Lean theorem.

## 1. The object

For a statistic with tie profile `m₀ ≥ m₁ ≥ …` (block sizes of equal values) over
`n = Σ mⱼ` observations, the Spearman tie ceiling is

```
ρ²  =  1 − 12 · Σⱼ (mⱼ³ − mⱼ) / 12 / (n³ − n)      (`spearmanSq_eq`)
```

* **Uniform draws** at bitlen `b`: the trailing-zero statistic `T` has the dyadic profile
  `2^{b-1}, 2^{b-2}, …, 1, 1`, ceiling `(6/7)(1 + 1/(2^b(2^b+1)))` — above `6/7`.
* **Balanced draws** at bitlen `b = 2v+2` (weight `v+1`): the profile is the hockey stick
  `mₖ = C(2v+1−k, v)`, `k = 0 … v+1` (`centralProfile v`).

## 2. Balanced ceilings, exact values

| `v` | bitlen | profile | `ρ²` exact | `ρ²` decimal | `(6/7 − ρ²)·v` |
|-----|--------|---------|------------|--------------|----------------|
| 1 | 4 | 3,2,1 | `6/7` | 0.857142… | 0.0000 |
| 2 | 6 | 10,6,3,1 | `563/665` | 0.846616… | 0.02105 |
| 3 | 8 | 35,20,10,4,1 | `1386/1633` | 0.848744… | 0.02519 |
| 4 | 10 | 126,70,35,15,5,1 | — | 0.850681… | 0.02584 |
| 10 | 22 | — | — | 0.854528… | 0.02615 |
| **29** | **60** | — | — | **0.856238…** | 0.02622 |
| 94 | 190 | — | — | 0.856863… | 0.02623 |
| 1000 | 2002 | — | — | 0.857116… | 0.02624 |

The rows `v = 1, 2, 3` are formalized exactly
(`balanced_ceiling_eq_six_sevenths_at_bitlen_four`, `spearmanSq_centralProfile_two`,
`spearmanSq_centralProfile_three`). The last column is empirically constant
(`≈ 0.02624 = 6/7 − 5/6·…`, numerically `→ 0.0262385…`), i.e. the deficit is `Θ(1/v)`;
this is what the two formalized bounds bracket:
`6/7 − 1/(15(v+1)) < ρ² < 6/7` (`balanced_ceiling_gt_sharp`, `balanced_ceiling_lt_all`).

## 3. Counterexample hunt: is `ρ² < 6/7` ever violated?

Swept `v = 2 … 1200` (bitlens 6 … 2402) in exact arithmetic: **no violation**; the minimum
of `6/7 − ρ²` over the sweep is `2.1866·10⁻⁵`, attained at the largest `v` tested, and the
gap decreases monotonically like `0.02624/v`. The boundary case `v = 1` gives equality `ρ² = 6/7`
exactly — hence the hypothesis `2 ≤ v` in `balanced_ceiling_lt_all`, which is sharp.

## 4. Counterexample hunt: fixed-weight robustness

For every fixed-weight law with weight fraction `θ = w/b ∈ [1/2, 3/5]` and `v ≤ 60`
(all `(v, r)` with `r ≤ v` and `2(v+1) ≤ 3r`), the ceiling `ρ²(balancedBlocks v r)` was
computed: **zero violations** of `ρ² > 0.73`; the observed minimum is `0.7636…` at
`(v, r) = (2, 2)`. Since `0.85² = 0.7225 < 0.73`, the whole validation band `[0.55, 0.85]`
stays admissible under a draw law mis-balanced by up to ten percentage points. Formalized
as `weight_ceiling_ge` / `weight_envelope_60`.

## 4b. The half-weight phase boundary

Exact ceilings `ρ²(balancedBlocks v r)` across the whole weight axis (weight `w = v+1`,
bitlen `b = v+1+r`); `−` marks `ρ² < 6/7`, `=` marks equality, `+` marks `ρ² > 6/7`.

| `v` | `r=1` | `r=2` | `r=v` | `r=v+1` (balanced) | `r=v+2` | `r=2v` | `r=10v` |
|-----|-------|-------|-------|--------------------|---------|--------|---------|
| 1 | 0.75 − | 6/7 = | 0.75 − | 6/7 = | 0.90909 + | 6/7 = | 0.98507 + |
| 2 | 0.6 − | 0.76364 − | 0.76364 − | 0.84662 − | 0.89300 + | 0.89300 + | 0.99203 + |
| 3 | 0.5 − | 0.6875 − | 0.78922 − | 0.84874 − | 0.88630 + | 0.91145 + | 0.99394 + |
| 5 | 0.375 − | 0.56897 − | 0.81556 − | 0.85195 − | 0.87857 + | 0.92629 + | 0.99528 + |
| 10 | 0.23077 − | 0.39143 − | 0.83622 − | 0.85453 − | 0.86995 + | 0.93705 + | 0.99618 + |
| 20 | 0.13043 − | 0.23827 − | 0.84666 − | 0.85583 − | 0.86421 + | 0.94227 + | 0.99659 + |

The sign flips at exactly `r = v+2`, i.e. as soon as the weight drops below half the
bitlen — with no intermediate regime. Exhaustive exact-rational check for `v = 1 … 40` and
`r = 1 … 6v+5`: no `r ≤ v+1` with `ρ² > 6/7` and no `r ≥ v+2` with `ρ² ≤ 6/7`. The dense side
(`r ≤ v+1`, weight at least half) is formalized as `half_weight_boundary`; the smallest
sparse case (`v = 1, r = 3`, `ρ² = 10/11`) as `boundary_is_sharp`; the far sparse region
`r ≥ 2v+2` (weight fraction at most `1/3`) as `sparse_ceiling_gt`, leaving only the window
`1/3 < w/b < 1/2` unproved. The degenerate row
`v = 0` (weight 1) is excluded: its profile has no ties at all and `ρ² = 1`, which is why
`half_weight_boundary` carries the hypothesis `1 ≤ v`.

## 5. The Catalan spine (the cross-domain observation)

Blocks of the balanced profile, and the shortfall of the first step from exact halving:

| `v` | `Cat v` | `m₀ = C(2v+1,v)` | `m₁ = C(2v,v)` | `2m₁ − m₀` |
|-----|---------|------------------|----------------|------------|
| 1 | 1 | 3 | 2 | 1 |
| 2 | 2 | 10 | 6 | 2 |
| 3 | 5 | 35 | 20 | 5 |
| 4 | 14 | 126 | 70 | 14 |
| 5 | 42 | 462 | 252 | 42 |

The last column is `Cat v` on the nose, and `m₀ = (2v+1)·Cat v`, so the *relative* defect
is exactly `1/(2v+1)`. Catalan numbers are OEIS **A000108** (1, 1, 2, 5, 14, 42, 132, …);
the head sequence `m₀ = 3, 10, 35, 126, 462` is OEIS **A001700**/**A088218**-adjacent
(`C(2n+1,n)`), and the profile itself is a hockey-stick slice of Pascal's triangle. No
new/unindexed sequence appeared. Formalized as `head_block_eq_catalan`,
`second_block_eq_catalan`, `catalan_halving_defect`.

## 6. The deficit invariant, tested before formalizing

The engine of the unconditional bound is

```
49(v+1)·8·m_r³  ≤  49(v+1)·(7·Σ_{i≤r} m_i³ + 1) + 24(1 + 7(v−r))·m_r³      (r ≤ v)
```

Checked exhaustively for `1 ≤ v ≤ 59` and all `0 ≤ r ≤ v` (1770 instances): **0 violations**.
The coefficient `24(1+7(v−r))/(49(v+1))` is not tuned — it is the fixed point of the
recursion `e_{s−1} = (s−1) + e_s/8` forced by the Weierstrass estimate on the step ratios,
which is why the inductive step in `loss_invariant` closes with exact equality.

## 7. Recorded experimental numbers (round-51 #3, exp 521)

| quantity | value | Lean witness |
|----------|-------|--------------|
| Spearman(T, rate), uniform, bitlen 60 | 0.669 [0.634, 0.705] | `pooled60`, `round51_inside_band` |
| advantage of `T` over count | +0.151 [0.107, 0.193] | `advantage60`, `round51_advantage_positive` |
| validation band | [0.55, 0.85] | `envelope_band_admissible` |
| balanced ceiling at bitlen 60 | 0.856238… | `envelope_60_strict` |
| uniform ceiling at bitlen 60 | `(6/7)(1+1/(2⁶⁰(2⁶⁰+1)))` | `dyadic_spearmanSq` |

All recorded readings lie strictly below both ceilings, so the reported correlation is not
a tie-geometry artefact; and under the balanced law the count baseline's ceiling is exactly
`0` (`count_dial_collapse`), so the advantage of `T` is structurally forced there.

## 8. Closing the weight window (cycles 6–7)

The undecided band of cycle 5 was `1/3 < w/b < 1/2`, i.e. `v+2 ≤ r ≤ 2v+1`. Two exact
rational sweeps guided the closing argument.

**(a) The geometric envelope.** Because the block ratio `m_{j-1}/m_j = j/(v+j)` increases
with `j`, the whole tail is dominated by the geometric series with the largest ratio
`q = r/(v+r)`:

```
Σⱼ mⱼ³ · ((v+r)³ − r³)  ≤  m₀³ (v+r)³ .
```

Checked exactly for `1 ≤ v ≤ 40`, `0 ≤ r ≤ 6v+5` (about 5000 instances): **0 violations**.
Formalized as `geom_cube_bound`.

**(b) The window inequality.** Feeding (a) and the head-to-total identity
`n(v+1) = m₀(v+r+1)` into `ρ² > 6/7` reduces the whole window to

```
7 (v+1)³ (v+r)³  <  (v+r+1)³ ((v+r)³ − r³) .
```

Ratio `RHS/LHS` at the boundary `r = v+2`:

| `v` | 1 | 2 | 10 | 20 | 100 |
|-----|---|---|----|----|-----|
| ratio | 4625/3584 = 1.2905 | 52136/40824 = 1.2771 | 1.09397 | 1.05018 | 1.01058 |

The ratio decreases to `1`, so the estimate is tight to first order exactly at the phase
boundary — with `r = cv` and `v → ∞` the inequality reads `3c² + 3c + 1 > 7`, i.e. `c > 1`,
i.e. weight fraction below one half. Substituting `v = a+1`, `r = a+3+s` makes every
coefficient of `RHS − LHS` positive (constant term `1041`), which is how
`window_algebra_sharp` is proved. Formalized as `window_ceiling_gt`, and combined with the
dense side as `dial_sign_iff` / `half_weight_dichotomy`.

**(c) The scaling law across the boundary.** Writing `r = v+1+k`, exact values of
`343·v·(ρ²(v, v+1+k) − 6/7)`:

| `k` | `v = 50` | `v = 100` | `v = 200` | `v = 400` | `v = 800` | limit |
|-----|----------|-----------|-----------|-----------|-----------|-------|
| −2 | −137.36 | −136.18 | −135.59 | −135.29 | −135.15 | −135 |
| −1 | −71.966 | −71.984 | −71.992 | −71.996 | −71.998 | −72 |
| 0 | −8.9958 | −8.9980 | −8.9990 | −8.9995 | −8.9998 | −9 |
| 1 | 51.671 | 52.813 | 53.401 | 53.699 | 53.849 | 54 |
| 2 | 110.14 | 113.48 | 115.21 | 116.10 | 116.55 | 117 |
| 3 | 166.52 | 173.02 | 176.45 | 178.21 | 179.10 | 180 |

The limits `−135, −72, −9, 54, 117, 180` form an arithmetic progression of common difference
`63 = 9·7`, suggesting

```
lim_{v→∞} v (ρ²(v, v+1+k) − 6/7) = 9(7k − 1)/343 .
```

`k = 0` reproduces the Catalan deficit constant `−9/343` measured in section 5, and the zero
of the law falls at the fractional index `k = 1/7`, strictly between the lattice points
`k = 0` and `k = 1` — the quantitative reason the sign flip happens at `r = v+2`. The proved
rate `ρ² − 6/7 > 1/(7(2v+3))` (`window_gap_quantitative`) gives `v(ρ² − 6/7) > 1/14`,
the same order as the conjectured `54/343` at `k = 1`.

These limits come from exact `fractions.Fraction` arithmetic on the profiles; the limit
values `9(7k−1)/343` are extrapolations and are *not* formally verified — they appear only
as a conjecture in `FUTURE_DIRECTIONS.md`.

## 9. The alphabet-size generalisation (cycle 8)

Exact ceilings of the `q`-adic trailing-zero profile of uniform length-`b` words, computed
from the closed form `ρ²(q,b) = (3q/(q²+q+1))(1 + 1/(q^b(q^b+1)))` and cross-checked against
direct cube-sum evaluation of the profile:

| `q` | `3q/(q²+q+1)` | `b = 1` | `b = 2` | `b = 4` | `b = 8` |
|-----|----------------|---------|---------|---------|---------|
| 2 | 6/7 = 0.857143 | 1.000000 | 0.900000 | 0.860294 | 0.857156 |
| 3 | 9/13 = 0.692308 | 0.750000 | 0.700000 | 0.692412 | 0.692308 |
| 4 | 12/21 = 0.571429 | 0.600000 | 0.573529 | 0.571437 | 0.571429 |
| 10 | 30/111 = 0.270270 | 0.272727 | 0.270297 | 0.270270 | 0.270270 |

`q = 2` reproduces the catalog's binary formula exactly (`radix_spearmanSq_binary`), and the
`b = 1` entry `1.000000` is correct: length-one binary words carry no ties.
Largest ceiling over all `q ≥ 3, b ≥ 2` is `0.7` (at `q = 3, b = 2`), which is below
`0.85² = 0.7225` — this is `band_is_binary_specific`.

**Composition sweep (evidence for the next conjecture).** For the `q`-ary law that is
uniform on length-`b` words with exactly `z` zeros, compare the sign of
`ρ² − 3q/(q²+q+1)` with the sign of `z/b − 1/q`, over `2 ≤ q ≤ 6`, `2 ≤ b ≤ 22`,
`1 ≤ z ≤ b−1` (about 1500 laws): **0 mismatches**. On the critical line `z/b = 1/q` the
ceiling equals the constant only at `(q,b,z) = (2,4,2)`, is above it at `(2,2,1)`, and is
below it in all 28 remaining cases — exactly the binary pattern proved in
`Pythagorean.ZeroFitDialHalfWeightBoundary60`. This sweep is exact-rational but the general
statement is *not* formally verified; it appears as direction 2 of `FUTURE_DIRECTIONS.md`.
