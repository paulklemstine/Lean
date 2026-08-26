# Experiment E-1: Empirical Complexity Map of Classical Factoring

**Date**: 2026-08-26 · **Seed**: 20260826 · **Harness**: `e1_complexity_map.py`
**Tooling**: gmpy2 2.3.0, GMP-ECM (/usr/bin/ecm)

## Hypotheses & Results

### H1 — Pollard-Brent rho scales as O(√p) — CONFIRMED
Balanced semiprimes, median wall-clock of 5 trials per size:

| N bits | 30 | 36 | 42 | 48 | 54 | 60 | 66 |
|---|---|---|---|---|---|---|---|
| time (s) | 0.0001 | 0.0002 | 0.0005 | 0.0008 | 0.0057 | 0.0194 | 0.0440 |

Log-log slope: time grew ×440 while N grew ×2³⁶ → empirical exponent
log₂(440)/36 ≈ **0.26** vs theoretical 0.25. ✔
Unbalanced arm (p fixed ~2³², q swept 48→128b): no q-trend (variance = random-
walk luck) → rho cost is a function of the smaller factor, independent of N. ✔

### H2 — GMP-ECM depends on factor size, not modulus size — CONFIRMED
Fixed p ~ 2³⁰, B1=5000, 20 curves:

| N bits | 94 | 158 | 222 | 286 |
|---|---|---|---|---|
| time (s) | 0.035 | 0.031 | 0.019 | 0.032 |

Flat within noise across a 3× modulus range. ✔ (Factor-dependence is the
defining property the FACT program's barrier framework predicts: any method
that reads structure off N alone is dead; ECM survives because its lottery is
over curve group orders near p.)

## Anomalies
- ECM at tiny factors (p ≤ 2²⁰, balanced 30–40b moduli): 0/3 finds at
  B1=11k/30 curves — unexpected; hypothesis: stage-2 overhead dominates at
  trivial sizes and/or output-format edge cases. Flagged for E-2's adaptive
  scheduler to absorb.

## Implications for method design
The two surviving classical mechanisms are exactly:
1. **Birthday paradox over walks** (rho): √p — parallelizable (van Oorschot–Wiener)
2. **Smoothness lotteries over random algebraic structures** (ECM): L_p[1/2,√2]
and sieved smoothness over polynomial families (NFS): L_N[1/3,(64/9)^{1/3}].
Any NEW method must either (a) find a fresh randomness source whose group/
structure orders are "smoother on average" than elliptic curves, or (b)
schedule known mechanisms optimally across the unknown-factor-size posterior.
E-2 pursues (b); (a) is the open frontier.
