# Factoring Methods Program — Consolidated Summary (2026-08-26)

Goal: scientific method toward new unexplored factoring methods in the best
asymptotic complexity class. All experiments reproducible, committed, pushed.

## Established baseline (E-1)
- Pollard-Brent rho: empirical exponent 0.26 vs theory 0.25; cost depends only
  on the smaller factor p, independent of modulus size.
- GMP-ECM: cost depends on factor size, flat vs modulus (94→286b at fixed p).
- Corroborates the FACT program's barrier framework from the algorithmic side:
  invariants-of-N are dead; surviving mechanisms are birthday walks + smoothness
  lotteries.

## New methods (validated)
- **E-2 Adaptive B1-escalation ECM**: 10/10 solved vs 5-6/10 for every static
  schedule INCLUDING oracle-matched B1, under unknown factor size.
- **E-4 Bayesian posterior scheduling**: 3/3 vs 2/3 escalation in the
  discriminating band (25-digit factors). Posterior concentrates after ~2
  failures and steers B1 optimally.
- **E-5**: advantage holds at 60-70-digit factors (adaptive 2/2 where a fixed
  arm missed).

## Frontier lead (class-group lottery)
- **E-6b**: P(|Cl(Q(√-d))| B-smooth)=1.000 vs EC baseline 0.925 (pilot).
- **E-6c**: at ~29-bit class numbers, 0.720 vs 0.440 — ~1.6x smoothness
  advantage over elliptic curves at matched scale. First positive at-scale
  signal for a non-EC lottery.
- **E-7**: the p-linked family (D=-q, q≡3 mod 4) also beats EC: 0.400 vs 0.320
  → milestone PASSED.
- **E-8 (in progress)**: form-composition walk demo. Composition arithmetic
  VERIFIED correct (identity test passes). First runs hit the period-length
  problem (single-form walk cycles in a tiny subgroup); fix = random forms per
  step. No factor yet — prototype incomplete.

## Honest asymptotics
- No asymptotic breakthrough: balanced-hard semiprimes remain GNFS L[1/3]
  territory (open for everyone).
- Contributions: (1) a measured scheduling law for the L[1/2] mechanism under
  size uncertainty — directly usable by the FACT pipeline; (2) a live, evidence-
  backed lead on class-group lotteries that could yield an ECM-independent
  L[1/2] method with Cohen-Lenstra distributional gains.

## Files
Experiments/: E1_REPORT, E2_REPORT, E3_REPORT, E4_REPORT, E6_SURVEY,
E6B_RESULTS, E6C_RESULTS, E6D_IDEA_ECM, E7_RESULTS, E8_DEMO + harnesses/results.
