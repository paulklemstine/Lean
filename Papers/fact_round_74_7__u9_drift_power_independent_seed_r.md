# Computational evidence — Exp 569 / paper 216 (band-9 `x² − N` smoothness drift)

All numbers below were produced by short exploratory scripts (Python, seed `20260824`).
They are **exploratory**, not verified: every claim that this project asserts as
established is proved in Lean in `Catalog/Probability/U9Drift*.lean` and is marked as such.
The arithmetic of the reported intervals (coverage, deliverables, pooling, cluster
thresholds) is *entirely* re-derived inside Lean with exact rational arithmetic, so those
figures are verified rather than merely computed.

## 1. Arithmetic of the reported intervals (all re-proved in Lean)

| quantity | value | Lean theorem |
|---|---|---|
| pilot `1e6` CI | `[0.8630, 1.0389]`, centre `0.95095`, half width `0.08795` | `pilot1e6_center_eq`, `pilot1e6_halfWidth_eq` |
| replication `1e6` CI | `[0.919, 1.0101]`, centre `0.96455`, half width `0.04555` | `rep1e6_center_eq`, `rep1e6_halfWidth_eq` |
| pilot deliverable `max|edge−1|` | `0.1370` | `pilot1e6_edge` |
| replication deliverable | `0.0810` | `rep1e6_edge` |
| inverse-variance pooled point | `≈ 0.96167` | `joint_interval_upper_edge_lt` |
| inverse-variance pooled half width | `≈ 0.040447` | `joint_interval_upper_edge_lt` |
| pooled upper edge | `≈ 1.00212` (covers 1) | `joint_interval_covers_one` |
| candidate rate bracket (primary cut) | `[2.65701, 3.56128]·10⁻⁵` | `candidate_rate_pinned` |
| cluster threshold for a 1 % resolution | `2656` clusters (`20.75×` of 128) | `exact_cluster_threshold` |

Two adversarial catches came out of this re-derivation and are themselves theorems:

* the quoted candidate-rate bracket `[2.66, 3.56]·10⁻⁵` is rounded **inwards** and therefore
  is not an enclosure (`ledger_bracket_is_not_an_enclosure`); the outward-rounded
  `[2.65, 3.57]·10⁻⁵` is (`candidate_rate_safe_bracket`);
* the quoted joint point `≈ 0.97` is the **equal-weight** average of the two point
  estimates; inverse-variance weighting gives `≈ 0.981`, strictly closer to the null
  (`equal_weight_pooling_overstates_the_drift`), and the "√2-tightened" phrase does not
  apply because the two runs are not precision-matched
  (`sqrt_two_tightening_fails`).

## 2. Local density of `p | j² − N` (small cases)

For each odd prime `p` and random `N`, the number of residues `j mod p` with `p | j² − N`
was counted directly and compared with `1 + legendreSym(N, p)`:

```
p=    3 N mod p=    2 roots=0 1+chi=0
p=    3 N mod p=    0 roots=1 1+chi=1
p=    5 N mod p=    2 roots=0 1+chi=0
p=    5 N mod p=    1 roots=2 1+chi=2
p=    7 N mod p=    6 roots=0 1+chi=0
p=   11 N mod p=    9 roots=2 1+chi=2
p=   13 N mod p=    3 roots=2 1+chi=2
p=  101 N mod p=   31 roots=2 1+chi=2
p=  101 N mod p=   98 roots=0 1+chi=0
p= 1009 N mod p=  402 roots=2 1+chi=2
```

Agreement is exact in every case, as the Lean theorem `U9Drift.sqrtCount_eq` requires.

## 3. The multiplicative bias `∏_{p≤P}(1 + χ_p(N))`

Sampling `20000` random `N < 10¹²` and forming the product over the first `k` odd primes:

| k | empirical mean (theory 1) | empirical 2nd moment | theory `2^k` |
|---|---|---|---|
| 5 | 1.006 | 20.7 | 32 |
| 10 | 1.204 | 814.7 | 1024 |
| 15 | 0.410 | 3355.4 | 32768 |

The mean is close to `1` for small `k` and becomes *wildly unstable* by `k = 15` — with
20 000 draws the sample mean of a quantity with variance `2^15 − 1` is essentially
uninformative. This is precisely the content of `U9Drift.mean_signProd`,
`U9Drift.second_moment_signProd` and `U9Drift.variance_signProd`, and it is the reason a
smoothness-ratio study must resample whole `N`-clusters rather than pairs.

## 4. A miniature replication of the design (8 clusters, 48-bit `N`, `B = 5000`)

| N | candidate smooth | control smooth | ratio |
|---|---|---|---|
| 229871916547937 | 34 | 24 | 1.41 |
| 200807072042177 | 31 | 25 | 1.24 |
| 271077539025707 | 11 | 21 | 0.54 |
| 171670900995397 | 29 | 23 | 1.26 |
| 177569514804709 | 43 | 31 | 1.38 |
| 222373491782989 | 34 | 22 | 1.53 |
| 211186360025533 | 32 | 28 | 1.14 |
| 217876760921539 | 31 | 29 | 1.07 |

Pooled ratio `1.21`; per-`N` ratios span `[0.53, 1.53]` on only `6000` draws per cluster.
Two exploratory observations (not verified claims):

* the **between-cluster spread is far larger than the within-cluster Poisson noise**, in
  line with §3 — this is the empirical signature that the effective sample size is the
  cluster count;
* at this very small `u` the candidate pool is, if anything, *more* smooth than the
  control, i.e. the sign of any deviation at small `u` is opposite to the sub-1 drift
  reported at band 9. No conclusion is drawn from eight clusters; it is recorded only as a
  motivation for the direction-of-drift conjecture in `FUTURE_DIRECTIONS.md`.

## 5. Sign-test check

Enumerating all `2^k` split-half sign patterns, exactly two are constant for every
`k ≥ 1`, so the direction-stability p-value is `2^{1-k}`: `0.25, 0.125, 0.0625, 0.03125`
for `k = 3, 4, 5, 6`. Hence four agreeing split-halves cannot reach the 5 % level; six can.
This is proved in Lean (`U9Drift.card_allSame`,
`U9Drift.split_halves_needed_for_significance`), so the table is a redundancy check rather
than evidence.
