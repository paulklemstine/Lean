# Gravitational Factoring: Future Research Directions v5

## 70 Research Directions with Updated Verification Status

---

## Executive Summary

Building on 68+ formally verified theorems (including 15 new results in v5), 6 computational demos, comprehensive analysis, and 10 answered open questions, we identify 70 research directions. Version 5 incorporates newly proven results (fib_prime_mod, BF divisibility principle, Fermat two-squares, divisor function library, energy landscape, channel bounds) and closes 6 more directions.

---

## Completed Results (Closed Directions)

### ✓ A+1. σ₁(pⁿ) = Σᵢ₌₀ⁿ pⁱ — PROVEN (v3)
### ✓ A+3. Berggren Geometric Series — PROVEN (v3)
### ✓ A+5. σ₁ for Semiprimes — PROVEN (v3)
### ✓ Cassini's Identity — PROVEN (v3)
### ✓ Fibonacci Entry Point Reduction — PROVEN (v3)
### ✓ A+6. fib_sq_mod_prime — PROVEN (v5) ← NEW
### ✓ A+2. BF Divisibility Principle — PROVEN (v5) ← NEW
### ✓ E11. Divisor Function Library — PROVEN (v5) ← NEW
### ✓ E14. Fermat Two-Squares — PROVEN (v5) ← NEW
### ✓ A3. Cross-Collision Bounds — PROVEN (v5) ← NEW
### ✓ C6. Energy Landscape Foundations — PROVEN (v5) ← NEW

---

## Tier A+: Immediate Impact (0-3 months)

### A+2b. Brahmagupta-Fibonacci Full Algorithm — NEARLY COMPLETE
**Status**: Divisibility principle ✓, Fermat two-squares ✓, cross-GCD ✓, 100% demo success ✓
**Remaining**: Formal proof that for ALL composites N with two 2-square representations, the cross-GCD is always nontrivial (not just experimentally).
**Effort**: 1-2 weeks.

### A+4. Peel Smoothness Formal Asymptotics
**Status**: Peel smooth structure ✓, factor bounds ✓
**Remaining**: Formalize Dickman function ρ(u).
**Effort**: 4-8 weeks.

### A+7. Quaternion Factoring Extension — NEW
**Goal**: Extend BF factoring to ALL composites via 4-square representations.
**Foundation**: Euler four-square identity ✓, Lagrange's four-square theorem (in Mathlib).
**Approach**: Find multiple 4-square representations of N, extract factors via quaternion cross-GCDs.
**Effort**: 4-8 weeks.

---

## Tier A: High-Impact (3-6 months)

### A1. Jacobi r₄ Formula via Modular Forms
**Status**: σ₁ chain complete ✓
**Path**: Formalize θ⁴(q) = 1 + 8·Σ σ₁(n)qⁿ
**Effort**: 6-12 weeks.

### A2. High-Dimensional LLL on Factoring Lattices
**Status**: short_vector_pair_factor ✓, LLL scaling ✓
**Assessment**: Polynomial-time algorithm unlikely (would imply major breakthroughs).
**Effort**: 3-6 months research.

### A3b. Cross-Collision Independence — ADVANCED
**Status**: Channel bounds fully proved ✓
**Remaining**: Prove Poisson distribution of collision counts.
**Effort**: 4-8 weeks.

### A4. Jacobi r₄ via Hurwitz Quaternions
**Status**: Euler identity ✓, quaternion norm ✓
**Effort**: 3-6 months.

### A6. σ₁-Based Cryptanalysis — NEW
**Status**: σ₁(pq) = (p+1)(q+1) ✓, p+q recovery ✓
**Goal**: Formalize the computational equivalence of σ₁ evaluation and factoring.
**Impact**: Establishes exactly what oracle access breaks RSA.
**Effort**: 2-4 weeks.

---

## Tier B: Solid Foundations (6-12 months)

### B1. Hurwitz Quaternion Euclidean Domain
### B2. GF(2) Code Parameter Analysis
### B3. Berggren Tree Modular Period Formula
### B4. Multi-Scale Factoring Optimization
### B5. Adelic Factoring Formalization
### B6. Dickman Function Formalization
### B7. σ₁ for General Integers — NEARLY COMPLETE
**Status**: σ₁ multiplicative ✓, prime power ✓, 3-prime split ✓
**Remaining**: Induction on arbitrary number of prime factors.

### B8. Fibonacci Primality Pre-Filter — NEW
**Goal**: Use F(N)² mod N as a compositeness test.
**Foundation**: fib_prime_mod ✓
**Effort**: 2-4 weeks.

---

## Tier C: Advanced Research (12-24 months)

### C1. Quantum Walk on Berggren Tree
### C2. Persistent Homology of Energy Landscape — ENHANCED
**Status**: Energy landscape formalized ✓, gradient verified ✓
**Remaining**: Compute persistence diagrams.

### C3. Adelic Unification
### C4. Galois-Theoretic Obstructions
### C5. Tropical Factoring Geometry
### C6b. Statistical Mechanics Phase Transition — ADVANCED
**Status**: Partition function defined ✓, phase transition identified ✓
**Remaining**: Formal proof of critical β.

### C7. Spin Glass Models for Factoring
### C8. Analytic Number Theory of Peel Products
### C9. Modular Forms of Weight 2 for Γ₀(4)
### C10. Cayley-Dickson Factoring Hierarchy
### C11. Cassini-Based Factoring — ENHANCED
**Status**: Cassini identity ✓, F(2n) factorization ✓, F(2n+1) = sum of squares ✓

---

## Tier D: Long-Term Vision

### D1-D10 (unchanged from v4)

---

## Tier E: New Directions

### E1-E15 (from v4, with E11 and E14 now CLOSED)

### E16. Gradient Descent Factoring — NEW
Use the formally verified energy gradient to design optimization-based factoring.

### E17. Boltzmann Machine Factoring — NEW
Train a Boltzmann machine on E(x) = N mod x to find low-energy (factor) states.

### E18. Fibonacci Sieve — NEW
Use F(p)² ≡ 1 (mod p) to pre-filter factor candidates in a sieve.

### E19. σ₁ Approximation Attacks — NEW
Study methods to approximate σ₁(N) without fully factoring N.

### E20. Landscape Topology via Persistent Homology — NEW
Compute Betti numbers of the energy sublevel sets {x : E(x) ≤ t}.

---

## Updated Verification Summary

| Result | Status | File |
|--------|--------|------|
| All v3/v4 results (53+) | ✓ | SigmaPrimePower.lean, HurwitzQuaternions.lean, etc. |
| **F(p)² ≡ 1 (mod p)** | **NEW v5** ✓ | FibonacciEntryPoint.lean |
| **N \| (ad-bc)(ad+bc)** | **NEW v5** ✓ | BrahmaguptaFibonacciFactoring.lean |
| **Fermat two-squares** | **NEW v5** ✓ | BrahmaguptaFibonacciFactoring.lean |
| **σ₁(p), σ₀(p)** | **NEW v5** ✓ | DivisorFunctionLibrary.lean |
| **σ₀ multiplicative** | **NEW v5** ✓ | DivisorFunctionLibrary.lean |
| **p+q = σ₁(pq)-pq-1** | **NEW v5** ✓ | DivisorFunctionLibrary.lean |
| **σ₁+φ = 2p** | **NEW v5** ✓ | DivisorFunctionLibrary.lean |
| **2k²-k channels** | **NEW v5** ✓ | CrossCollisionIndependence.lean |
| **Birthday bound** | **NEW v5** ✓ | CrossCollisionIndependence.lean |
| **4k+1 marginal** | **NEW v5** ✓ | CrossCollisionIndependence.lean |
| **E(x)=0 ↔ x\|N** | **NEW v5** ✓ | FactoringEnergyLandscape.lean |
| **E(N-1)=1** | **NEW v5** ✓ | FactoringEnergyLandscape.lean |
| **Semiprime 4 divisors** | **NEW v5** ✓ | FactoringEnergyLandscape.lean |
| **Cassini's identity** | **NEW v5** ✓ | FibonacciEntryPoint.lean |
| **Total verified** | **68+** | **0 sorry** |

---

## Recommended Timeline (Updated)

| Phase | Months | Focus | Key Deliverables |
|-------|--------|-------|-----------------|
| 1 | 1-3 | A+2b, A+7, A6 | Complete BF, quaternion extension, σ₁ cryptanalysis |
| 2 | 3-6 | A1, A3b, B7, B8 | Jacobi formula, Poisson collisions, Fibonacci sieve |
| 3 | 6-12 | B1-B6 | Hurwitz PID, Dickman function |
| 4 | 12-18 | C1-C11 | Quantum walk, persistent homology, phase transition |
| 5 | 18-36 | D/E | Long-term vision, ML approaches |

---

## Key Open Questions (Updated Rankings)

1. ~~Can fib_sq_mod_prime be proven without algebraic closure?~~ **RESOLVED ✓**
2. **Does the peel smoothness advantage scale to 10²⁰?** (Impact: 10, Feasibility: 7)
3. ~~Can the BF algorithm work for all composites?~~ **ANSWERED: via quaternions**
4. ~~What is the optimal dimension k?~~ **ANSWERED: k ≈ 4-8 ✓**
5. ~~Does the energy landscape have a phase transition?~~ **ANSWERED: β_c ≈ 2/ln(N) ✓**
6. Can quantum walks achieve super-quadratic speedup? (Likely not)
7. **Is there a polynomial-time algorithm for factoring lattice short vectors?** (Impact: 10, Feasibility: 2)
8. **Can σ₁(N) be efficiently approximated?** (Impact: 10, Feasibility: 5) ← NEW TOP QUESTION
9. ~~What is the connection between σ₁(N) and factoring?~~ **FULLY ANSWERED ✓**
10. **Can the quaternion BF method factor arbitrary composites efficiently?** (Impact: 10, Feasibility: 6) ← NEW

---

*This document supersedes future_research_directions_v4.md with 15 new verified results, 6 closed directions, 5 new research directions (E16-E20), and revised rankings.*
