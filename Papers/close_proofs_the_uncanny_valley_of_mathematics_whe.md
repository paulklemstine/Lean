# Computational Evidence — The Uncanny Valley Model

We model *acceptance* as a function of *human-likeness* `x` by the cubic

    UV(x) = x³ − 3x.

Mori's uncanny valley predicts: acceptance rises, hits a local peak (the
"almost-human"), drops sharply into a valley, then recovers past the peak.

## 1. Landmark values

| x    | UV(x) | role                                   |
|------|-------|----------------------------------------|
| −3   | −18   | far from human, low acceptance         |
| −1   |   2   | **near-human peak** (local max)        |
|  0   |   0   | descending through the valley          |
|  1   |  −2   | **valley bottom** (local min)          |
|  2   |   2   | recovery equals the earlier peak       |
|  3   |  18   | full recovery, far surpasses the peak  |

The classic N-with-a-dip shape is visible: −18 → 2 → −2 → 2 → 18.

## 2. Critical points (calculus check, informal)

UV′(x) = 3x² − 3 = 3(x−1)(x+1), zero at x = ±1.
Local max at x = −1 (UV = 2), local min at x = 1 (UV = −2). Confirms the two
turning points bracketing the valley.

## 3. Driving factorizations (verified by `ring`)

    UV(x) − 2 = (x − 2)(x + 1)²     ⟹ UV(x) > 2 for x > 2 (full recovery)
    UV(x) + 2 = (x − 1)²(x + 2)     ⟹ UV(x) ≥ −2 for x ≥ −2 (valley is the min)
    UV(b) − UV(a) = (b − a)(a² + ab + b² − 3)   (difference/monotonicity engine)

The symmetric quadratic a² + ab + b² compared to 3 controls the sign of every
difference: it is < 3 on the open box (−1,1)² off the diagonal (descent) and > 3
when both points lie in [1,∞) or (−∞,−1] (ascent/recovery).

## 4. Counterexample hunt

The universal claims proved are the three monotonicity regimes plus the drop and
recovery. Sampling `UV` on a grid of 0.01 steps over [−4, 4] shows:
- strictly increasing on [−4, −1] and on [1, 4],
- strictly decreasing on [−1, 1],
- UV(1) = −2 < 2 = UV(−1) (the drop holds),
- UV(x) > UV(−1) for all sampled x > 2 (full recovery holds).
No counterexample to any stated theorem was found.

## 5. Remark

`UV` is the minimal (degree-3, integer-coefficient) polynomial realizing the
uncanny-valley shape with clean rational landmarks, which is why it yields
fully elementary `ring`/`nlinarith` proofs.
