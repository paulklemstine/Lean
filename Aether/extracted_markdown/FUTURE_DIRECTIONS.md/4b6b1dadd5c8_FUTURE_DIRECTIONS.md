# Future Directions

## Overview

This document identifies five falsifiable hypotheses emerging from our formal infrastructure for primes of the form n² + 1. Each hypothesis is specific enough to test and daring enough to matter.

---

## Hypothesis 1: Local-to-Global Sieve Hypothesis

**Conjecture**: Any integer polynomial family formalized as `LocallyAdmissible` (no fixed prime divisor) and satisfying a certified level-of-distribution axiom (the polynomial's values are well-distributed in arithmetic progressions up to level X^{1-ε}) admits infinitely many values with Ω ≤ 2 (at most two prime factors with multiplicity).

**Test**: Instantiate the framework on three polynomial families:
1. f(n) = n² + 1 (the main target; Iwaniec proved Ω ≤ 2 in 1978).
2. f(a, b) = a² + b⁴ (Friedlander–Iwaniec proved primality; Ω ≤ 2 follows a fortiori).
3. f(n) = n² + n + 1 (a "toy" case where local admissibility holds and sieve bounds should be computable).

Formalize the abstract sieve interface: given LocallyAdmissible(f) and LevelOfDistribution(f, θ) with θ > 1/2, derive Ω(f(n)) ≤ 2 infinitely often. The hypothesis fails if no clean abstract interface suffices — i.e., if each polynomial requires ad hoc analytic arguments that cannot be modularized.

**Impact**: If true, this would create a reusable formal "sieve engine" that reduces the problem of producing almost-primes from any admissible polynomial to proving a single analytic estimate (the level of distribution).

---

## Hypothesis 2: Certified Semiprime Density Lower Bound

**Conjecture**: The count of n ≤ X with Ω(n² + 1) ≤ 2 satisfies

$$|\{n \leq X : \Omega(n^2 + 1) \leq 2\}| \geq C \cdot \frac{X}{(\log X)^2}$$

for some explicit computable constant C > 0, for all X ≥ X₀.

**Test**: Using `demo.py`, compute the count for X = 10³, 10⁴, 10⁵, 10⁶ and fit a lower bound of the form C · X / (log X)². Determine whether the ratio Count / (X / (log X)²) stabilizes or grows. Specific predictions:
- At X = 10⁴: count ≥ 350 (semiprimes + primes)
- At X = 10⁵: count ≥ 2800
- At X = 10⁶: count ≥ 22000

The hypothesis is refuted if the ratio decays to zero, which would indicate that the density is lower than (log X)^{-2}.

**Impact**: An explicit lower bound would be the first certified quantitative result toward Iwaniec's theorem, usable in verified cryptographic applications requiring guaranteed semiprime generation rates.

---

## Hypothesis 3: Splitting-Prime Universality

**Conjecture**: For every irreducible polynomial f ∈ ℤ[X] such that f has no fixed prime divisor, the set of primes dividing values of f lies (for all sufficiently large primes) in a finite union of Chebotarev-type congruence classes determined by the Galois group of the splitting field of f.

**Test**:
1. For f(n) = n² + 1: the splitting field is ℚ(i) with Galois group ℤ/2ℤ. Primes that split are exactly those ≡ 1 (mod 4). Verified formally (Theorem C).
2. For f(n) = n² + 3: the splitting field is ℚ(√-3) with Galois group ℤ/2ℤ. Primes dividing values should be exactly those ≡ 1 (mod 3) (plus q = 3). Test computationally for n ≤ 10⁵.
3. For f(n) = n³ - 2: the splitting field is ℚ(∛2, ω) with Galois group S₃. Primes dividing values should have Frobenius in specific conjugacy classes. Test computationally.

The hypothesis is falsified if a prime outside the predicted congruence classes appears as a divisor for some irreducible polynomial. (Note: this is actually a theorem — the Chebotarev density theorem — but formalizing it and connecting it to our admissibility framework would be a major advance.)

**Impact**: Would create a formal "automatic congruence law generator" for any polynomial, mechanizing one of the most powerful tools in algebraic number theory.

---

## Hypothesis 4: Friedlander–Iwaniec Bridge Completeness

**Conjecture**: The minimal formal infrastructure needed for the Friedlander–Iwaniec theorem (infinitely many primes a² + b⁴) already implies, as abstract consequences, both local admissibility (Theorem B) and the prime-support congruence law (Theorem C) for n² + 1. That is, n² + 1 is a formal specialization of the a² + b⁴ framework obtained by setting b = 1 and replacing a with n.

**Test**:
1. Formalize n² + 1 as the special case a² + b⁴ with b = 1 (noting a² + 1⁴ = a² + 1).
2. Derive Theorems B and C from abstract properties of the a² + b⁴ framework alone.
3. Check whether the congruence law for a² + b⁴ (which must also involve primes ≡ 1 mod 4 for odd prime divisors not dividing b) specializes correctly.

The hypothesis is refuted if the abstract framework requires modification or additional axioms to handle the one-variable specialization, indicating that the two forms require genuinely independent infrastructure.

**Impact**: If true, future formalization efforts could target the more general form first and obtain n² + 1 results for free, potentially halving the total formalization burden for this area of number theory.

---

## Hypothesis 5: Gaussian Integer Proof Compression

**Conjecture**: Recasting n² + 1 as the Gaussian integer norm N(n + i) = (n + i)(n − i) yields strictly shorter formal proofs of the congruence selection law (Theorem C) than the purely modular arithmetic approach, measured by total lines of Lean code including all required imports and helper lemmas.

**Test**:
1. **Modular arithmetic proof** (current): Uses ZMod.exists_sq_eq_neg_one_iff and multiplicative order arguments. Measure total proof length including all dependencies.
2. **Gaussian integer proof** (proposed): Import GaussianInt from Mathlib. Show that if q | N(n+i) and q is an odd prime, then q is not a Gaussian prime (since it would need to divide n+i or n-i, forcing q | 2i, contradiction). Hence q splits in ℤ[i], and split primes satisfy q ≡ 1 (mod 4). Measure total proof length.

The hypothesis is refuted if the Gaussian integer proof is longer or requires more lemmas, which could happen if Mathlib's Gaussian integer library has gaps requiring substantial bridging code.

**Impact**: Would establish that algebraic number theory infrastructure in Lean is mature enough to provide computational advantages over elementary methods, guiding future formalization strategy toward algebraic rather than analytic approaches where possible.

---

## Priority Ranking

1. **Hypothesis 4** (Bridge Completeness) — Highest priority. Can be tested immediately by attempting the formal specialization. Would have the largest impact on reducing future work.
2. **Hypothesis 5** (Proof Compression) — High priority. Can be tested now with existing Mathlib. Direct practical implications for proof engineering.
3. **Hypothesis 2** (Density Bound) — Medium priority. Computational testing is immediate; formalization requires sieve infrastructure.
4. **Hypothesis 3** (Universality) — Medium priority. Deeply connected to existing mathematics; computational testing is straightforward.
5. **Hypothesis 1** (Sieve Engine) — Longest-term but highest potential impact. Requires substantial new Lean infrastructure.
