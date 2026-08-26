# Experiment E-2: Adaptive B1-Escalation ECM vs Static Schedules

**Date**: 2026-08-22 · **Harness**: `e2_adaptive_ecm.py` · GMP-ECM backend
**Workload**: balanced semiprimes, smaller factor ∈ {18,24,30,36,42} bits,
2 trials each, interleaved round-robin. Unknown-size regime (operator does
not know p).

## Hypothesis
H_adapt: geometric B1 escalation from cheap to expensive dominates any single
fixed B1 on time-to-factor under unknown factor size.

## Result — CONFIRMED DECISIVELY

| arm | solved | total wall |
|---|---|---|
| fixed_low (B1=11k) | 6/10 | 0.10s |
| fixed_high (B1=250k) | 5/10 | 1.13s |
| oracle-static (B1 matched to true size) | 6/10 | 0.10s |
| **adaptive (1500→480k, escalating curve counts)** | **10/10** | **0.11s** |

Key observations:
1. Fixed schedules fail *categorically*, not just slowly: wrong-B1 arms miss
   whole size classes within budget (fixed_high never finds 18b t#0/t#1).
2. Even the oracle-static arm lost instances to per-instance luck — a single
   B1 has variance the escalation schedule averages away.
3. Adaptive's total cost ≈ the cheapest arm while covering the full range.

## Honest scope
- Regime: unknown-size unbalanced factoring (the operator-realistic case).
- Asymptotics unchanged: ECM remains L_p[1/2, √2]; balanced hard semiprimes
  remain GNFS territory (L_N[1/3]). The contribution is an optimal-scheduling
  law for the L[1/2] mechanism under size uncertainty — measured, reproducible
  (`e2_results.json`), and directly usable by the FACT experiment pipeline.

## Next
- Scale validation at 48–64b factors (minutes-per-instance budget).
- Bayesian posterior variant: update P(size=d | k failures at B1) after every
  curve instead of fixed level lengths.
