# Future Directions: Verified Langlands Functoriality

## Overview

This document identifies five specific, testable scientific hypotheses arising from our formal verification of symmetric-square transfer for GL(2) Satake parameters. Each direction is a falsifiable claim with a clear computational or formal test.

---

## Conjecture 1: Explicit Hecke Polynomial Formula for Sym^n

**Conjecture:** For every n ≥ 2, the Euler factor coefficients of the Sym^n transfer can be expressed as explicit polynomials in the Hecke trace a = α + β and determinant ω = αβ. Specifically, the k-th coefficient c_k of L(Sym^n π, T)^{-1} equals (-1)^k · e_k(α^n, α^{n-1}β, ..., β^n), where e_k is the k-th elementary symmetric polynomial, and this can be rewritten as a polynomial in (a, ω) of degree at most nk/2 in a and k in ω.

**Test:** For n = 2, 3, 4, compute the explicit polynomial expressions symbolically using computer algebra. Verify that the total degree in (a, ω) matches the prediction. For n = 3, the Euler factor should be a degree-4 polynomial in T with coefficients expressible as polynomials in a and ω. Implement symbolic computation in SageMath or SymPy and verify coefficient-by-coefficient.

**Impact:** If true, this provides a complete computational recipe for all symmetric power L-function data from Hecke eigenvalues alone, enabling efficient computation of L-function coefficients for analytic number theory applications (moments of L-functions, subconvexity bounds, etc.).

---

## Conjecture 2: Formal Temperedness Preservation for All Sym^n

**Conjecture:** For every n ≥ 1, if |α| = |β| = 1, then all n+1 parameters of Sym^n(α, β) have absolute value 1. That is, |α^{n-k} β^k| = 1 for all 0 ≤ k ≤ n.

**Test:** This is straightforward to prove formally in Lean 4 by induction on k, using the multiplicativity of the complex norm: |α^{n-k} β^k| = |α|^{n-k} · |β|^k = 1^{n-k} · 1^k = 1. Formalize this as a single theorem parametric in n and verify it compiles.

**Impact:** If formally verified, this establishes that symmetric power transfer preserves the Ramanujan conjecture at all levels — a key structural ingredient for the automorphic theory of symmetric power L-functions. Combined with the Ramanujan conjecture for GL(2) (Deligne's theorem for holomorphic forms), this gives temperedness of all symmetric power lifts at unramified places.

---

## Conjecture 3: Coefficient Growth Rate Under Iterated Transfer

**Conjecture:** For Satake parameters with max(|α|, |β|) = M > 1, the maximum coefficient norm of the Sym^n Euler factor grows as O(M^{n(n+1)/2}). More precisely:

max_k |c_k(Sym^n)| ≤ C(n) · M^{n(n+1)/2}

where C(n) is a combinatorial constant depending only on n (specifically, related to binomial coefficients).

**Test:** Numerically compute the maximum coefficient norm for M = 1.1, 1.5, 2.0 and n = 2, 3, ..., 10. Fit the growth rate as a function of n and M. Compare with the predicted bound. A deviation at large n or M would suggest the bound is not tight.

**Impact:** Precise coefficient growth bounds are essential for the analytic theory of automorphic L-functions, particularly for establishing bounds on L-functions in the critical strip. Formal verification of such bounds would provide rigorous foundations for analytic number theory.

---

## Conjecture 4: Algebraic Circuit Complexity of Sym^n Coefficient Map

**Conjecture:** Any algebraic circuit over ℂ computing the Sym^n coefficient map (a, ω) ↦ (c_1, ..., c_{n+1}) requires at least ⌊n²/4⌋ multiplication gates.

**Test:** For small n (2 ≤ n ≤ 6), construct explicit algebraic circuits computing the coefficient map and count multiplication gates. Compare with the lower bound. Use the Baur-Strassen theorem (derivative complexity) to derive formal lower bounds from the degree structure of the coefficient polynomials.

**Impact:** If true, this establishes that functorial transfer has intrinsic computational complexity growing quadratically with the symmetric power degree. This connects the Langlands program to algebraic complexity theory in a novel way, suggesting that the difficulty of computing L-function data is not merely practical but structural.

---

## Conjecture 5: Formal Rankin-Selberg Factorization

**Conjecture:** The Euler factor of the Rankin-Selberg convolution L(π × π, T)^{-1} factors as:

L(π × π, T)^{-1} = L(Sym²π, T)^{-1} · L(∧²π, T)^{-1}

where L(∧²π, T)^{-1} = (1 - ωT) is the exterior square Euler factor. In terms of Satake parameters:

(1 - α²T)(1 - αβT)²(1 - β²T) = [(1 - α²T)(1 - αβT)(1 - β²T)] · (1 - αβT)

**Test:** Formalize both sides as polynomials in Lean 4. Prove the factorization by polynomial algebra (coefficient comparison or direct ring computation). This should be achievable with the same techniques used in our current development.

**Impact:** This factorization is the local analogue of the global decomposition L(π × π, s) = L(Sym²π, s) · L(∧²π, s), which is a foundational identity in the theory of automorphic L-functions. Formal verification would establish the first machine-checked instance of L-function factorization, opening the door to formalizing the Rankin-Selberg method — one of the most powerful tools in analytic number theory.

---

## Prioritization

| Priority | Conjecture | Difficulty | Value |
|----------|-----------|------------|-------|
| 1 | Conjecture 2 (Sym^n temperedness) | Low | High — immediate generalization |
| 2 | Conjecture 5 (Rankin-Selberg) | Medium | Very High — opens new theory |
| 3 | Conjecture 1 (Sym^n Hecke formula) | Medium | High — computational recipe |
| 4 | Conjecture 3 (Growth rate) | Medium-High | Medium — analytic applications |
| 5 | Conjecture 4 (Circuit complexity) | High | Medium — cross-domain |

Conjectures 1 and 2 are the most immediately tractable and should be pursued first. Conjecture 5 would represent the most significant theoretical advance.
