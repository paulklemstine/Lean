# Computational Evidence — INTERVAL-HINTS-TWO-NUMBERS

All numbers below are scratch computations (Python, exact `Fraction` arithmetic where noted). They
were used to choose the statements; every one of the closed forms they test is proved in Lean
(`Catalog/Logic/IntervalHintsTwoNumbers.lean`). The computations themselves are not Lean-checked.

## 1. Brute force over every search order (M = 6, W = 2, exact rationals)

| α | committed (window-first) cost | optimum over all 720 orders | closed form `(W+1+(1-α)M)/2` |
|---|---|---|---|
| 1/2 | 3 | 3 | 3 |
| 1/3 (= W/M) | 7/2 | 7/2 | 7/2 |
| 1/4 | **15/4** | **13/4** | 15/4 |

The committed procedure stops being optimal exactly when α < W/M (`committed_not_optimal`).

## 2. Uniform-prior exact speedup vs continuum law (M = 10⁴)

| α \ w | 0.02 exact / `1/(1-α+w)` | 0.05 exact / continuum |
|---|---|---|
| 0.50 | 1.923 / 1.923 | 1.818 / 1.818 |
| 0.75 | 3.703 / 3.704 | 3.333 / 3.333 |
| 0.90 | 8.327 / 8.333 | 6.663 / 6.667 |
| 1.00 | 49.76 / 50.00 | 19.96 / 20.00 |

Coverage ceilings `1/(1-α)` = 2, 4, 10: the reported min-law table (1.86/3.50/7.41) lies under them.

## 3. Min-law, perfect coverage, aligned blocks (M = 10⁴)

| w | exact `(M+1)(2M+1)/((W+1)(3M-W+1))` | continuum `2/(w(3-w))` | reported (grid / MC) |
|---|---|---|---|
| 0.02 | 33.39 | 33.56 | 29.13 / 34.0 |
| 0.05 | 13.53 | 13.56 | 13.12 |
| 0.10 | 6.89 | 6.90 | 7.11 |
| 0.20 | 3.57 | 3.57 | 3.96 |

The reported table parametrises width by μ/M and does not use aligned blocks, so it is not the same
model. At w = 0.02 the aligned-block value is closer to the reported Monte-Carlo value (34.0) than to
the grid value (29.13).

## 4. Counterexample hunt
* "Committed procedure Bayes-optimal in every cell": fails for α < w (table 1). It holds for every
  cell of the reported table because all of them have α ≥ 0.5 > w.
* "5.19× ⇔ ~90% reliability at 2–5% width": under the uniform prior the iso-line `1-α+w = 1/5.19`
  gives α ∈ (0.827, 0.858). At α = 0.9 the continuum speedup is ≥ 6.67 > 5.19.

OEIS: not applicable (the sequences are rational functions of M).
