# Computational evidence — TDIAL-U108 (round-69 #2, exp 544)

All numbers below were produced with Lean `#eval` (`Float`/`Rat` arithmetic) during the
exploration stage. They are *evidence*, not proof: every claim that is asserted as a result of
this cycle is proved as a Lean theorem in `Catalog/Physics/TDialU108BandLoss.lean` and
`Catalog/Physics/TDialU108Deepening.lean` (both compile with 0 `sorry`, axioms
`propext / Classical.choice / Quot.sound` only).

## 1. The ladder and its steps

| bitlen | 96 | 100 | 104 | **108** | 112 | 116 | 120 |
|---|---|---|---|---|---|---|---|
| pooled ρ(T, rate) | 0.5739 | 0.5436 | 0.5005 | **0.4880** | 0.4621 | 0.4847 | 0.43636 |
| step | — | −0.0303 | −0.0431 | **−0.0125** | −0.0259 | +0.0226 | −0.0484 |

Computed step vector: `[-0.0303, -0.0431, -0.0125, -0.0259, +0.0226, -0.04834]`.

Observations used downstream:

* the U108 step is the smallest-magnitude negative step of the first five rungs
  (→ *deceleration*, formalised in `fade_decelerates_at_u108`);
* the sign flip at 116 means the raw ladder is **not** antitone
  (→ `ladder_not_antitone`, the honest boundary of the plateau model).

## 2. Gram certificate vs. advantage certificate at U108

With `a = corr(T, rate) = 0.488`, `b = corr(count, rate) = 0.396` (advantage `+0.092`):

```
Gram bound       a·b + √((1−a²)(1−b²))  = 0.994737
advantage bound  1 − (a−b)²/2           = 0.995768
difference                               = 0.001031
(√(1−a²) − √(1−b²))² / 2                 = 0.001031   ← matches exactly
```

The exact coincidence of the last two lines is what suggested (and is proved by)
`gram_gap_eq`. The proof shows the advantage bound is precisely the AM–GM relaxation
`√(pq) ≤ (p+q)/2` of the Gram bound with `p = 1−a²`, `q = 1−b²`.

The Lean theorem `u108_decorrelation_certificate` states the slightly rounded, provable form
`c ≤ 0.9949 < 0.995768`.

## 3. Plateau windows as a function of the deceleration ratio

Lower edge `0.488 − 0.0259/(1−r)` (upper edge is always `0.488`):

| r | 0.3 | 0.4 | **0.5** | 0.6 |
|---|---|---|---|---|
| lower edge | 0.4510 | 0.4448 | **0.4362** | 0.4233 |

The pre-registered ratio bound `r ≤ 1/2` gives the window `[0.4362, 0.488]`.

Counterexample hunt / retrodiction check on the two rungs measured *after* the forecast:

* `116 : 0.4847` ∈ [0.4362, 0.488] ✓ (clears the top edge by 0.0033)
* `120 : 0.43636` ∈ [0.4362, 0.488] ✓ (clears the bottom edge by **0.00016**)

(Cycle 3 sharpens this: the *attainable* plateau set is exactly `[0.4362, 0.4621]`, so the
116 value `0.4847` is a rebound rather than a plateau, consistent with `ladder_not_antitone`.)

So the window is tight rather than vacuous — a slightly stronger ratio assumption
(`r ≤ 0.49`, lower edge 0.43722) would have been **falsified** by the 120 rung. This is
recorded in `u108_window_contains_later_rungs`, and the sharpness of the edge itself in
`plateau_window_edge_attained` / `u108_lower_edge_attained`.

## 4. Pooling: heterogeneity inflation

Using the three per-seed readings recorded one rung later (U112: `0.409 / 0.509 / 0.460`,
the closest published per-seed triple to the first heterogeneous rung):

```
arithmetic mean                      = 0.459333
Fisher-z (rapidity) pooled estimate  = 0.460306   >  mean   (gap +0.00097)
```

consistent with `fisherPool3_ge_mean` and the strict form `fisherPool2_gt_mean_of_ne`.
Both remain far below the `0.55` floor, as forced by `fisherPool3_le_max`.

Composition vs. averaging at `x = y = 0.4`:

```
rapidity average    tanh((artanh 0.4 + artanh 0.4)/2) = 0.400000  < 0.55
Einstein/Fisher sum (0.4 + 0.4)/(1 + 0.16)            = 0.689655  > 0.55
```

This is the guarded boundary theorem `pool_vs_compose_dichotomy`.

## 5. OEIS

No integer sequence arises in this cycle (all objects are real-valued correlation ladders),
so no OEIS lookup applies.
