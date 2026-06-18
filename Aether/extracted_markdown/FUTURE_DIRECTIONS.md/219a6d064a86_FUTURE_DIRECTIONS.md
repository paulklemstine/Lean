# Future Directions: Formal Prime Gap Infrastructure

## Overview

This document identifies five falsifiable hypotheses emerging from our formalization of admissible tuple theory and CRT sieve infrastructure. Each hypothesis is precise enough to prove or disprove, and each would open significant new territory in machine-verified analytic-combinatorial number theory.

---

## Hypothesis 1: Decidability of Admissibility via Bounded Prime Checking

**Conjecture:** For any finite set `H : Finset ℕ`, admissibility is decidable by checking only primes `p ≤ |H|`. Formally:

```
Admissible H ↔ ∀ p : ℕ, Nat.Prime p → p ≤ H.card →
  ∃ a : ℕ, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0
```

**Status:** ✅ PROVED in this work (`admissible_iff_check_primes_le_card`).

**Extension conjecture:** This reduction can be strengthened to a `Decidable` instance, enabling `#eval` of admissibility for any concrete tuple.

**Test:** Implement a `DecidableEq`-based decision procedure for `Admissible` and register it as a `Decidable` instance. Verify with `#eval (Admissible ({0,2} : Finset ℕ))` returning `true`.

**Impact:** Would enable fully automated verification of admissible tuple databases, connecting formal proof to computational search. This is the gateway to certifying the Polymath 8 admissible tuple records.

---

## Hypothesis 2: CRT Realization with Explicit Density Bounds

**Conjecture:** For any admissible `k`-tuple `H` and prime bound `B`, the set of translates `n` avoiding all primes `p ≤ B` has density exactly

$$\delta = \prod_{p \leq B,\ p \text{ prime}} \left(1 - \frac{\nu_p(H)}{p}\right)$$

within the arithmetic progression `n ≡ a (mod M)` where `M = \prod_{p \leq B} p` and `a` is the CRT solution.

**Test:**
1. Formally define the density function `δ(H, B)` as the product above.
2. Prove that the number of solutions in `[1, M]` equals `δ · M` (this is a finite combinatorial identity).
3. Verify numerically for `H = {0,2}` and `B = 30`: predicted survivor count in `[1, 30#]` should match exact sieve count.

**Impact:** Would give the first formally verified quantitative sieve estimate — the natural-density backbone of the Selberg sieve. This is the key missing piece between our CRT avoidance theorem and actual sieve bounds.

---

## Hypothesis 3: Maynard Sieve Positivity as a Finite-Dimensional Optimization

**Conjecture:** The core of Maynard's bounded gap argument can be formalized as a purely finite-dimensional optimization problem:

Given an admissible `k`-tuple `H`, define weights `w : Fin k → ℝ` and moments:
- `S₁(w) = ∑ᵢ wᵢ²`  (diagonal second moment)
- `S₂(w) = (∑ᵢ wᵢ)²` (first moment squared)

There exists a combinatorial threshold `τ(k)` such that if `S₂(w) / S₁(w) > τ(k)`, then (under level-of-distribution hypotheses) at least two elements of some translate `n + H` are prime.

**Test:**
1. Formalize `S₁`, `S₂` as functions on `Fin k → ℝ`.
2. State and prove the purely algebraic inequality: for `k ≥ 2`, there exist weights with `S₂/S₁ > 1 + 1/(k-1)`.
3. Verify computationally that optimal weights for `k = 105` achieve ratio > 4, matching Maynard's result.

**Impact:** Would isolate the exact algebraic core of Maynard's breakthrough, independent of all analytic estimates. This is the single most impactful decomposition step for formal bounded gap theory.

---

## Hypothesis 4: Singular Series Positivity for Admissible Tuples

**Conjecture:** For any admissible `k`-tuple `H`, the truncated singular series

$$S_B(H) = \prod_{p \leq B,\ p \text{ prime}} \frac{1 - \nu_p(H)/p}{(1 - 1/p)^k}$$

is strictly positive for all `B`, and converges to a positive limit as `B → ∞`.

More precisely: `S_B(H) ≥ c(k) > 0` for an explicit constant depending only on `k = |H|`.

**Test:**
1. Prove positivity of each factor: for admissible `H`, `ν_p(H) < p` for all primes `p`, so `1 - ν_p(H)/p > 0`.
2. Prove the product converges by showing `∑_p |1 - factor_p| < ∞` (comparison with `∑ 1/p²`).
3. Numerically verify: for `H = {0,2}`, the series converges to the twin prime constant `C₂ ≈ 1.3203`.

**Impact:** Would give the first formalized connection between admissibility and the Hardy–Littlewood density prediction. The singular series is the bridge between local (mod p) structure and global (asymptotic) prime counts.

---

## Hypothesis 5: Minimal-Diameter Admissible Tuples and the Prime Gap Function

**Conjecture:** Let `D(k)` be the minimum diameter of an admissible `k`-tuple. Then:

1. `D(2) = 2` (twin primes, the unique minimizer is `{0, 2}`).
2. `D(k) ~ k log k` as `k → ∞` (matching the prime gaps heuristic).
3. For each `k`, the minimizer is unique up to translation and reflection.

**Test:**
1. Formally prove `D(2) = 2` by exhaustive search over 2-element subsets of `{0, ..., 2}`.
2. Compute `D(k)` for `k = 2, ..., 20` by systematic search and compare with known Polymath 8 records.
3. Test uniqueness conjecture: for `k = 3`, verify that `{0, 2, 6}` and `{0, 4, 6}` both achieve `D(3) = 6`, refuting uniqueness.

**Impact:** Connects the formal admissibility theory to the quantitative bounded gap problem. If `D(k)` can be certified for specific `k`, then the Maynard sieve directly gives certified prime gap bounds. The Polymath 8 project achieved `D(50) = 246`, which would yield the current best gap bound — but this has never been machine-verified.

---

## Meta-Direction: Analytic Prerequisites Roadmap

The following analytic ingredients are NOT currently available in Mathlib and would need to be built before any unconditional bounded gap result can be formalized:

| Ingredient | Status | Estimated Effort |
|-----------|--------|-----------------|
| Prime Number Theorem | ✅ In Mathlib | — |
| Dirichlet characters | ✅ In Mathlib | — |
| L-functions (basic) | Partial | 2–4 months |
| Bombieri–Vinogradov theorem | ❌ Not started | 6–12 months |
| Large sieve inequality | ❌ Not started | 3–6 months |
| Selberg sieve (basic) | ❌ Not started | 2–4 months |
| Maynard's multidimensional sieve | ❌ Not started | 6–12 months |
| Effective prime counting in APs | ❌ Not started | 4–8 months |

**Recommended attack order:** Large sieve → Selberg sieve → Bombieri–Vinogradov → Maynard sieve.

Each step has independent value and produces citable formal results.

---

## Summary

| # | Hypothesis | Difficulty | Impact |
|---|-----------|-----------|--------|
| 1 | Decidable admissibility | Easy | High — computational gateway |
| 2 | CRT density bounds | Medium | High — quantitative sieve |
| 3 | Maynard optimization | Medium-Hard | Very High — algebraic core |
| 4 | Singular series positivity | Medium | High — analytic bridge |
| 5 | Minimal diameter function | Variable | High — certified gap bounds |
