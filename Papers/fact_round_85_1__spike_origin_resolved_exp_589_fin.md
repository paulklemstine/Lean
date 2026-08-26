# Computational evidence (exploratory, pre-formalisation)

All numbers below come from short exploratory scripts run before formalisation.
They are **not** the verified artifacts; the verified statements are the Lean
theorems in `Catalog/Probability/Spike*.lean`, which are proved for all inputs,
not sampled. The role of this stage was to check that the intended lemmas were
true before spending proof effort on them.

## 1. Inclusion bound at first-decile window positions

Window: `j ∈ [isqrt N + 1, 3 isqrt N]`; first decile: `5 j ≤ 6 isqrt N`.
Claim tested: `25 (j² − N) ≤ 11 (isqrt N)²`, i.e. `v ≤ 0.44 s²`.

| sample | D1 positions checked | violations | max of `v / (0.44 s²)` |
|---|---|---|---|
| 20 000 random `N ∈ [10⁶, 10¹²]`, 4 D1 positions each | 80 000 | 0 | 1.000000 |

The maximum ratio `1.000000` is attained (at `N = s²`, `j = s + s/5` with
`5 ∣ s`), confirming that the constant `11/25` is sharp — this is the content of
`Spike.residue_edge_sharp`.

## 2. Bit-length forcing at 96-bit moduli

For 20 000 random `N ∈ [2⁹⁵, 2⁹⁶)`, taking the *last* first-decile position
(the worst case), the observed maximum of `bitlen(j² − N)` was **95**.
No first-decile residue ever reached bit length 96, matching the reported
`D1` band table (`≥ 96 : 0`) and formalised in `Spike.size_residue_lt_96`.

Deeper in the same window the situation reverses: at `N = 2⁹⁴`, `j = 3·2⁴⁷`
gives `v = 2⁹⁷`, bit length 98 (`Spike.exists_window_size_ge_96`).

## 3. Composition (Simpson) instance

Two bands in the shape forced by the geometry — a tiny-`v` band with a high
first-decile propensity and a large-`v` band with mechanically zero propensity:

| band | exposure `n` | band rate `p` | count `k = p n` | within-band rate ratio |
|---|---|---|---|---|
| tiny-`v` | 3000 | 0.53 | 1590 | 1.000 |
| large-`v` | 6594 | 0.00 | 0 | 1.000 |

* flat null `p₀ = 0.1`: expected `959.4`, observed `1590`
* flat-referenced excess `+630.6`; band-referenced excess `0.0`
* pooled rate ratio `1.6573`

Every within-band ratio is exactly 1, yet the pooled ratio is above 1.6.
Formalised as `Spike.Band.exists_pure_composition_spike`.

Reported-number check: `1.097 × 1.4924 = 1.63716…`, i.e. the matched ratio times
the composition factor reproduces the pooled `1.637` to four decimals
(`Spike.Band.rate_ratio_1637`).

## 4. Geometric (local Dickman-like) density: relative edge excess

Band of `2m` size cells, weights `r^i`; relative edge excess
`(lower − upper)/(lower + upper)`.

| `r` | `m` | measured | `(1 − rᵐ)/(1 + rᵐ)` | bound `m(1 − r)` |
|---|---|---|---|---|
| 0.5 | 2 | 0.600000 | 0.600000 | 1.000 |
| 0.5 | 8 | 0.992218 | 0.992218 | 4.000 |
| 0.9 | 2 | 0.104972 | 0.104972 | 0.200 |
| 0.9 | 8 | 0.398145 | 0.398145 | 0.800 |
| 0.99 | 2 | 0.010050 | 0.010050 | 0.020 |
| 0.99 | 8 | 0.040180 | 0.040180 | 0.080 |
| 0.999 | 8 | 0.004002 | 0.004002 | 0.008 |

The closed form matches exactly and the linear bound holds throughout; both are
formalised (`Spike.Gradient.geometric_relativeEdge`,
`Spike.Gradient.relativeEdge_le_linear`). The qualitative reading is the one the
reanalysis needs: a *steep* local size density (small `r`, i.e. the truncation
boundary) manufactures a visible left-edge weight; a *flat* one (`r → 1`, deep
interior) manufactures none.

## 5. No OEIS sequence

No integer sequence of independent interest arises here; the arithmetic content
is the single inequality `25 v ≤ 11 s²` and its bit-length corollary, so no OEIS
lookup was performed.

## Addendum (continuation cycle): quantile identity and extremal composition

**Quantile identity, exhaustive check.** For all `N < 200` and all thresholds
`x < 200` (40 000 pairs) the closed form was verified inside Lean by `decide`:

```
#{ j ∈ [isqrt N + 1, 3·isqrt N] : j² − N ≤ x } = min(3·isqrt N, isqrt(N+x)) − isqrt N
```

with result `true`. The general statement is now proved for all `N, x` as
`Spike.Quantile.card_sublevel`.

**Decile counts on the divisible moduli `N = (5m)²`.** Triples
`(first-decile count, window size, #{v ≤ 11m²})` for `m = 0, …, 11`:

| m | decile | window | v ≤ 11m² |
|---|--------|--------|----------|
| 0 | 0 | 0 | 0 |
| 1 | 1 | 10 | 1 |
| 2 | 2 | 20 | 2 |
| 3 | 3 | 30 | 3 |
| 5 | 5 | 50 | 5 |
| 8 | 8 | 80 | 8 |
| 11 | 11 | 110 | 11 |

The decile is exactly a tenth, and the positional and magnitude counts agree
identically — proved as `Spike.Quantile.firstDecile_is_a_tenth` and
`Spike.Quantile.card_residue_le_eq_firstDecile_card`.

**Composition ceiling.** With `p0 = 0.1` and band rates capped at `0.14924`,
the composition factor cannot exceed `1.4924`; combined with a matched
within-band ratio `≤ 1.097` the pooled ratio ceiling is `1.638 ≥ 1.637`
(observed). Attainment requires all exposure on the maximal-rate band — the
configuration the window geometry forces. Formalised as
`Spike.Band.Extremal.round85_ceiling` and
`Spike.Band.Extremal.compositionFactor_eq_max_iff_concentrated`.

## Addendum (this cycle): the quantile law rate and the composition share

**Sharpness of the Kolmogorov bound.** Exploratory scan (not a formal
verification) of the empirical fraction
`F_M(x) = #{ j ∈ W(M²) : j² − M² ≤ x } / (2M)` against the limit c.d.f.
`(√(1+y) − 1)/2` at `x = ⌊y M²⌋`, over `y = 0, 0.01, …, 8`:

| M | max\|F_M − limit\| | bound 1/(2M) |
|---|---------------------|--------------|
| 10 | 0.05000 | 0.05 |
| 100 | 0.00499 | 0.005 |
| 1000 | 0.00050 | 0.0005 |
| 10000 | 0.00005 | 0.00005 |

The proved bound `Spike.Quantile.quantile_law_error` is therefore not merely
correct but essentially attained: the discrete quantile function tracks the
continuum law to within one window position and no better. The convergence
itself is `Spike.Quantile.quantile_tendsto`, and at the decile level `y = 11/25`
the value `1/10` is attained exactly (`Spike.Quantile.decile_law_exact`).

**Composition share, arithmetically.** With matched ratio `R = 1.097`,
flat-null expectation `p0·∑n = 959.4` and flat excess `604.76`, the proved
inequality `composition ≥ (flatExcess − (R−1)·p0·∑n)/R` gives
`composition ≥ (604.76 − 93.0618)/1.097 = 466.45`, i.e. at least `77.1 %` of the
excess; the band-referenced bookkeeping of the round reports
`604.76 − 129.66 = 475.1`, comfortably inside the bound. Formalised as
`Spike.Band.Share.composition_lower_bound` and
`Spike.Band.Share.round85_composition_share`.
