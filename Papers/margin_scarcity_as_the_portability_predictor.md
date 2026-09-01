# Computational evidence — margin scarcity vs. weight distance as portability predictors

All numbers below were produced by exact rational (`ℚ`) arithmetic evaluated in Lean
(`#eval`), with a final `Float` conversion only for display. Nothing here is a proof;
the proofs are in `Catalog/Applications/MarginScarcityPortability.lean` and
`Catalog/Applications/MarginScarcityCorrelation.lean`.

Helper definitions used for the evaluations:

```lean
def mean (l : List ℚ) : ℚ := l.sum / l.length
def cov (f g : List ℚ) : ℚ :=
  ((f.zip g).map (fun p => (p.1 - mean f) * (p.2 - mean g))).sum / f.length
def var (f : List ℚ) : ℚ := cov f f
```

## 1. The two-block dissociation (small-case calculation)

The family realised by `margin_predicts_norm_does_not` at `D = 10`, `d = 1/10`:
damage `(0, 1)`, margin-uncertified fraction `(0, 1)`, weight distance `(10, 0.1)`.

```lean
#eval (cov [0, 1] [0, 1], cov [10, 1/10] [0, 1])
-- (1 / 4, -99 / 40)
```

Exactly the two closed forms proved in Lean: `cov(margin, damage) = 1/4` and
`cov(distance, damage) = −(D − d)/4 = −(10 − 0.1)/4 = −2.475`. The margin statistic
orders the two blocks correctly; the norm statistic orders them backwards.

## 2. A five-block synthetic family (does the sign survive more blocks?)

Blocks 1–2 use the NET-54 measured damages (tail arm `0.4557`, bulk arm `0.1615`);
blocks 3–5 are synthetic. The margin predictor is the damage plus a nonnegative
screen slack; the weight distances are chosen with the dead/live-direction effect in
mind (large distance in harmless directions).

| block | damage | margin predictor | slack | weight distance |
|---|---|---|---|---|
| 1 (tail) | 0.4557 | 0.4557 | 0.0000 | 1.2 |
| 2 (bulk) | 0.1615 | 0.2000 | 0.0385 | 3.1 |
| 3 | 0.0300 | 0.0900 | 0.0600 | 0.5 |
| 4 | 0.2200 | 0.2500 | 0.0300 | 0.8 |
| 5 | 0.0100 | 0.0600 | 0.0500 | 4.4 |

```lean
#eval ((var dam5).toFloat, (cov pred5 dam5).toFloat, (cov dist5 dam5).toFloat)
-- (0.025850, 0.022610, -0.094382)
```

`cov(margin, damage) = +0.02261 > 0`, `cov(distance, damage) = −0.09438 < 0`: the
sign dissociation is not an artefact of having only two blocks.

## 3. The proved lower bound, checked numerically

The screen slack is confined to `[0, 0.06]`, so `famCov_margin_lower_bound` with
`eta = 0.06` certifies

```
cov(pred, dam) ≥ Var(dam) − (eta/2)·√Var(dam) = 0.025850 − 0.03·0.160779 = 0.021026
```

```lean
#eval ((var dam5).toFloat - 0.03 * Float.sqrt (var dam5).toFloat)   -- 0.021026
```

and the measured covariance `0.022610` indeed exceeds it. The bound is not tight
here (slack `0.0016`), which is expected: Cauchy–Schwarz is attained only when the
slack is exactly proportional to the centred damage.

## 4. Popoviciu bound for the slack variance

`famVar_le_of_range` claims `Var(e) ≤ eta²/4` for `e ∈ [0, eta]`. On the slack vector
of §2 (padded to a five-block comparison at `eta = 0.06`):

```lean
#eval ((var [(0:ℚ), 6/100, 6/100, 3/100, 5/100]).toFloat, (0.06*0.06/4 : Float))
-- (0.000520, 0.000900)
```

`0.000520 ≤ 0.000900`. Extremal case `e = (0, eta, 0, eta, …)` saturates it.

## 5. NET-54 two-arm instantiation

```lean
#eval ((var [4557/10000, 1615/10000]).toFloat,
       Float.sqrt (var [4557/10000, 1615/10000]).toFloat)
-- (0.021638, 0.147100)
```

So on the two measured arms the covariance of the margin screen with damage is
certified positive for every screen slack `eta < 2·0.14710 = 0.29420`. The tail arm
saturates its screen exactly (`net54_margin_scarcity`: damage `= 0.4557 =` certified
margin-scarcity lower bound), i.e. `eta = 0` on that arm.

## 6. Counterexample hunt for the screen inequality

The screen `damage ≤ uncertifiedFrac` was attacked from two sides before being
proved:

* *reverse inequality?* — refuted: `margin_screen_is_conservative` exhibits
  `uncertifiedFrac = 1` with `damage = 0` (two identical low-margin copies of a
  block: margins fail everywhere, yet nothing moves). So no lower bound on damage
  in terms of margin scarcity exists.
* *improvable by a constant?* — refuted: `margin_screen_attained` exhibits
  `uncertifiedFrac = damage = 1`, so no `c < 1` with `damage ≤ c·uncertifiedFrac`
  can hold.

For the norm route the hunt succeeded immediately and became a theorem: the
dead-direction block (`feat = (1,0)`, perturbation in coordinate 2) has arbitrarily
large weight distance and zero damage, while the live-direction block has arbitrarily
small distance and total damage — `weight_distance_not_monotone`, and its sharp
corollary `no_weight_distance_bound` (any damage bound depending only on weight
distance is `≥ 1` everywhere, hence vacuous).

## 7. No OEIS sequence

The objects here are real-valued measured fractions and covariances, not integer
sequences; no OEIS lookup applies.
