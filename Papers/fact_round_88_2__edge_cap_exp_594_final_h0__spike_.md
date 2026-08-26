# Computational evidence — edge-spike censoring and the three-bin defect

All numbers below were produced with Lean `#eval` on `Float` mirrors of the
definitions that appear in the two formal files
(`Catalog/MachineLearning/EdgeSpikeCensoring.lean`,
`Catalog/MachineLearning/EdgeSpikeKernelDefect.lean`):

```lean
def truncF (b t : Float) : Float := (1 - Float.exp (-(b*t))) / (1 - Float.exp (-b))
def edgeF  (rho t b : Float) : Float := (1-rho)*t + rho * truncF b t
def limF   (rho t : Float) : Float := (1-rho)*t + rho
def binLL  (h p : Float) : Float := h * Float.log p + (1-h) * Float.log (1-p)
def geomF  (r : Float) (j : Nat) : Float := (r^j.toFloat) / (1 + r + r^2)
def mixF   (rho r : Float) (j : Nat) : Float := (1-rho)/3 + rho * geomF r j
def defF   (x y z : Float) : Float := x*z - y*y
```

Parameters chosen to mirror the audited configuration: edge-bin width
`t = 1/28` (28 bins), edge mass `rho = 0.476`, pooled sample `n = 9594`.

## 1. Edge mass saturates: the observable ceiling

| cap `b` | 10 | 20 | 40 | 80 | ceiling `b→∞` |
|---|---|---|---|---|---|
| `edgeF 0.476 (1/28) b` | 0.16168 | 0.26169 | 0.38064 | 0.46738 | 0.49471 |

The model edge probability is strictly increasing in `b` and converges to
`(1-rho)t + rho`, exactly as proved (`truncExpCDF_strictMonoOn`,
`truncExpCDF_tendsto`).

## 2. Log-likelihood profile is monotone and flattens

Per-observation `binLL h p` at the worst case `h =` ceiling:

| cap `b` | 10 | 20 | 40 | 80 | ceiling |
|---|---|---|---|---|---|
| `binLL` | −0.99056 | −0.81651 | −0.71991 | −0.69459 | −0.69309 |

Monotone increasing, never attaining the ceiling value — the numerical face of
`binLogLik_cap_riding` and `no_finite_maximiser`.  Total (× n = 9594)
log-likelihood still available above a cap:

* above cap 20: 1184.1 nats, above cap 40: 257.3, above cap 80: **14.4**.

The remaining deficit shrinks by a factor ≈ 0.22 per 20 units of cap, i.e.
faster than the proved envelope `exp(-b t)` (`exp(-20/28) = 0.49`): near the
ceiling the log-likelihood deficit is quadratic in the probability gap, so the
observed rate is ≈ `exp(-2 b t)`.  The proved bound `cap_gain_le` is therefore
valid but conservative.  With this geometry the audited ladder can
only move by a fraction of an AICc unit between caps 40 and 80, which is what
was observed (`-101.28 → -101.33`).

## 3. Three-bin log-convexity defect

`defect x y z = x z − y²` on three equal bins.

| configuration | defect |
|---|---|
| single law, `r = 0.3` | 0.000000 |
| mixture `rho = 0.476, r = 0.3` | 0.029309 |
| closed form `rho(1−rho)/3 · (1−r)²/(1+r+r²)` | 0.029309 |
| mixture, `r = 0.5` | 0.011877 |
| mixture, `r = 0.05` | 0.071292 |
| proved uniform bound `rho(1−rho)/21` (valid for `r ≤ 1/2`) | 0.011877 |
| proved separation `rho(1−rho)/84` | 0.002969 |

The single-law defect is 0 to machine precision at every rate tested
(`defect_geom_eq_zero`), while the mixture defect is bounded away from 0
uniformly in the steepness once `r ≤ 1/2` (`defect_mix_ge`).  Note the bound
`rho(1−rho)/21` is attained exactly at `r = 1/2`, so it is sharp.

## 4. Steepness valley

At `rho = 0.476`, comparing bin vectors at `b = 40` and `b = 80`
(`r = exp(-b/3)`):

* bin 0 difference: −1.0e−6, bin 1 difference: 1.0e−6;
* proved bound `4 rho exp(-40/3)` = 3.0e−6.

So the two very different steepnesses are indistinguishable at the 1e−6 level in
the observable, while `n = 9594` samples resolve probabilities only to
≈ `1/√n ≈ 1e−2`.  This is the quantitative reason the bootstrap CI ran to the
cap.

## 5. Counterexample hunt

* Searched for a single-law parameter reproducing a mixture bin vector: none can
  exist, since the defect is a continuous invariant that is identically zero on
  the single-law family and strictly positive on the mixture (checked over
  `r ∈ {0.05, 0.1, …, 0.95}` numerically, proved in general).
* Searched for an interior maximiser of the profile likelihood at `h ≥` ceiling:
  none found for `b` up to `10^3`, consistent with `no_finite_maximiser`.
* Conversely, for `h` strictly below the ceiling an interior optimum does exist
  and is unique — proved as `unique_steepness_of_bracket`.  The failure audited
  is a tolerance/boundary effect, not a failure of the population map.

No OEIS-relevant integer sequence arises in this problem.
