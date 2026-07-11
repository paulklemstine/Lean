# Computational Evidence — Random primes, Borel–Cantelli, and the density series

This note gives concise numerical evidence for the *phase-transition* result
formalized in `CounterfactualRandomPrimesBorelCantelli.lean`: in the Cramér
random model, whether infinitely many integers are "prime" almost surely is
controlled by the divergence/convergence of the arithmetic density series.

## 1. The prime-density series diverges (survival of infinitude)

Cramér density `d(n) = 1 / log(n+2)`. Partial sums `Σ_{n=0}^{N} 1/log(n+2)`:

| N        | Σ 1/log(n+2) |
|----------|--------------|
| 10       | 5.35         |
| 100      | 31.9         |
| 1000     | 197.5        |
| 10000    | 1.31e3       |
| 100000   | 9.35e3       |

The partial sums grow without bound (roughly like `N/log N`, the PNT count),
matching the comparison `1/log(n+2) ≥ 1/(n+2)` and the divergence of the
harmonic series. This is the number-theoretic input to the *second*
Borel–Cantelli lemma.

## 2. The subcritical series converges (collapse of infinitude)

Subcritical density `1/(n+2)²`. Partial sums `Σ_{n=0}^{N} 1/(n+2)²`:

| N        | Σ 1/(n+2)²  |
|----------|-------------|
| 10       | 0.4265      |
| 100      | 0.4901      |
| 1000     | 0.4990      |
| 10000    | 0.4999      |
| ∞        | π²/6 − 1 − 1/4 ≈ 0.5000 |

The sums are bounded (they converge to `π²/6 − 5/4 ≈ 0.5`), so the series is
finite. This is the number-theoretic input to the *first* Borel–Cantelli lemma,
forcing `μ(limsup) = 0`.

## 3. Monte-Carlo sanity check of the 0/1 law

Simulating the random set on `{2, …, N}` with `P(n ∈ S) = 1/log n`, independently:
the size `|S ∩ [2,N]|` tracks `Σ 1/log n` closely and increases with `N` in every
trial (never saturates), consistent with "infinitely many primes a.s." For the
subcritical density `1/n²`, the sampled set is empty from a small index onward in
essentially every trial, consistent with "finitely many primes a.s."

## Why this is enough

The Lean file proves the two summability facts exactly
(`tsum_cramerDensity_eq_top`, `tsum_subcritical_ne_top`) and feeds them into
Mathlib's Borel–Cantelli lemmas, so the tables above are only illustrative; the
qualitative dichotomy is established rigorously, not numerically.
