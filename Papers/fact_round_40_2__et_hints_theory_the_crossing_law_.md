# Computational evidence — the crossing law (paper 146, exp 480)

All computations below used exact rational arithmetic (Python `fractions`, seed 20260828). They were run as exploration before the Lean proofs were written. Every claim listed here is proved in `Catalog/Shared/IntervalHintsCrossingLaw.lean`; the tables themselves are exploration data, not Lean artifacts.

## 1. Gate values \(\alpha_{\min}(s) = 1 - 2/(3s)\)

| s | 2 | 3 | 5.19 | 10 |
|---|---|---|---|---|
| \(\alpha_{\min}(s)\) | 0.6667 | 0.7778 | 0.871548 | 0.9333 |

At \(\alpha = 0.90\) the crossing width is \(\mu/M = 0.9 - \alpha_{\min}(5.19) = 0.0284522\). Lean: `paper137_gate`, `paper137_width`.

Finite-\(M\) gate \(\alpha^M_{\min}(5.19) = 1 - (M+1)(2M+1)/(3M^2 s)\): 0.87090 at \(M = 300\) and 0.87153 at \(M = 10^4\), converging to the continuum gate. Lean: `finite_reliability_gate`, `alphaMinM_tendsto`.

## 2. Closed form compared with brute-force summation at \(M = 300\)

| W | α | committed cost = \((W+1+(1-α)M)/2\)? | \(S_M\) (direct sum) | \(S_M\) (closed form) |
|---|---|---|---|---|
| 9 | 0.90 | yes (exact) | 5.025028 | 5.025028 |
| 30 | 0.87 | yes (exact) | 2.871444 | 2.871444 |
| 1 | 0.50 | yes (exact) | 1.322376 | 1.322376 |

Lean: `pricedSpeedupM_eq`.

## 3. Bayes cost over all orders (\(M = 6\), all 720 orders)

There are 55 cells (\(W = 1..5\), \(\alpha \in \{0, 0.1, \dots, 1\}\)). In all 55 of them the Bayes optimum equals \(\min\big((W+1+(1-\alpha)M)/2,\ (M-W+1+\alpha M)/2\big)\). Lean: `bayes_cost_exact`.

## 4. Counterexample hunt

- **Conservative pricing**: 300 random positive posteriors at \(M = 6\), with the Bayes optimum taken over all 720 orders. The largest ratio Bayes/stipulated was 0.9632, so no counterexample was found. Lean: `optCost_le_stipulated`, `conservative_pricing`.
- **One-sided Bayes gate**: this one fails. At \(M = 4, W = 2, \alpha = 0\) the Bayes speedup is 5/4, while \(\alpha^4_{\min}(5/4) = 1/4 > 0\). Lean: `one_sided_gate_fails_for_bayes`. The corrected statement is `bayes_two_sided_gate`.
- **Displacement law**: checked on all 720 orders at \(M = 6, W = 2, \alpha = 1/2\) with no violations. Interleaving at \(M = 8, W = 3\) has excess \(12/25 = (a-b)\,W(W-1)/2\). Lean: `displacement_law`, `interleaved_closed_form`.

## OEIS

There is no integer sequence here worth an OEIS search: the window-slot minimum \(W(W+1)/2\) is just the triangular numbers (A000217).
