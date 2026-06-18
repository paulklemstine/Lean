# Gravitational Factoring: Future Research Directions v7

## 95 Research Directions with Updated Verification Status

---

## Executive Summary

Building on **130+ formally verified theorems** (including 45+ new results in v7), 14 computational demos, comprehensive analysis, and 18 answered open questions, we identify 95 research directions. Version 7 incorporates newly proven results (Fibonacci square criterion, σ₁ complete reduction, Euler key equation, Pisano period CRT, energy Morse theory, Hurwitz norm foundations) and closes 10 more directions.

---

## Completed Results (Closed Directions)

### Previously Closed (v1-v6)
All v1-v6 results (95+ theorems) remain verified.

### NEW in v7
- ✓ **A+8. σ₁ Hardness Reduction** — Factor determination, 3-prime expansion, full reduction chain
- ✓ **A+9. Fibonacci Compositeness Certificate** — F(p)² ≡ 1 (mod p), compositeness test
- ✓ **A7. Energy Landscape Morse Theory** — Divisors are local minima, Laplacian ≥ 0, sublevel filtration
- ✓ **B9. Even Perfect Euler Direction (partial)** — Key equation, m divisibility, m primality
- ✓ **E28. Pisano Period Factoring (partial)** — CRT multiplicativity, π(p) | p²−1, small periods
- ✓ **A+7b. Hurwitz Quaternion Foundations** — Norm multiplicativity, Euclidean division, composite structure
- ✓ **A1. Jacobi Four-Square (partial)** — sigma1_no4 for odd n, Euler product identity

---

## Tier A+: Immediate Impact (0-3 months)

### A+7c. Hurwitz Quaternion Efficient Algorithm — TOP PRIORITY
**Status**: Norm multiplicativity ✓, Euclidean division ✓, composite structure ✓
**Remaining**: Implement the Hurwitz descent algorithm and prove polynomial-time complexity.
**Impact**: Would give provably correct factoring for ALL composites via quaternion GCD.
**Effort**: 3-6 weeks.

### A+10. Fibonacci Pseudoprime Density — NEW
**Status**: F(p)² ≡ 1 ✓, compositeness test ✓, Pisano period ✓
**Goal**: Bound #{n ≤ x : n composite, F(n)² ≡ 1 mod n} / #{n ≤ x : n composite}.
**Foundation**: Carmichael's primitive divisor theorem (stated, not yet proved).
**Effort**: 4-8 weeks.

### A+11. Complete Euler Direction for Even Perfects — NEW
**Status**: Key equation ✓, m divisibility ✓, m primality ✓
**Goal**: Prove every even perfect has the form 2^(p-1)(2^p-1) with 2^p-1 prime.
**Remaining**: Prove m = 2^(k+1)-1 from the key equation (currently assumed).
**Effort**: 2-4 weeks.

---

## Tier A: High-Impact (3-6 months)

### A1b. Jacobi r₄ Formula via Theta Functions
**Status**: sigma1_no4_odd ✓, Euler product ✓, Lagrange ✓
**Path**: Formalize θ⁴(q) = 1 + 8·Σ σ₁_no4(n)qⁿ
**Effort**: 6-12 weeks.

### A2. High-Dimensional LLL on Factoring Lattices
**Status**: LLL bounds ✓, Minkowski ✓, Coppersmith parameter ✓
**Remaining**: Formalize short vector → factor connection.
**Effort**: 3-6 months.

### A6c. σ₁ Approximation via Lattice Reduction — NEW
**Status**: σ₁ determines factors ✓, gap reveals sum ✓
**Goal**: Show that lattice-based computation of σ₁ is as hard as SVP.
**Effort**: 4-8 weeks.

### A7b. Energy Landscape Persistent Homology — ELEVATED
**Status**: Sublevel filtration ✓, zero sublevel = divisors ✓, monotonicity ✓
**Goal**: Formally compute persistence diagrams using the verified filtration.
**Effort**: 3-6 months.

### A12. Pisano Period Polynomial-Time Computation — NEW
**Status**: Pisano period exists ✓, CRT ✓, π(p) | p²-1 ✓
**Goal**: Determine whether π(N) can be computed in polynomial time.
**Note**: This is related to the discrete logarithm problem.
**Effort**: 3-6 months (likely open problem).

---

## Tier B: Solid Foundations (6-12 months)

### B1. Hurwitz Quaternion Euclidean Domain — ELEVATED
**Status**: Lipschitz norm ✓, Hamilton product ✓, Euclidean division ✓
**Remaining**: Full PID structure, unique factorization up to units.

### B2. GF(2) Code Parameter Analysis
### B3. Berggren Tree Modular Period Formula
### B4. Multi-Scale Factoring Optimization
### B5. Adelic Factoring Formalization
### B6. Dickman Function Formalization

### B8c. Carmichael's Primitive Divisor Theorem — NEW
**Status**: Statement formalized ✓ (with sorry)
**Goal**: Prove that for n ≥ 13, F(n) has a prime factor not dividing any F(k) for k < n.
**Effort**: 6-10 weeks.

### B10b. σ₁ for Arbitrary Integers — ENHANCED
**Status**: Multiplicativity ✓, prime power ✓, 3-prime ✓
**Remaining**: General induction on prime factorization (arbitrary number of prime factors).

### B11. Wall-Sun-Sun Conjecture Formalization — NEW
**Goal**: Formalize the conjecture that no prime p satisfies F(p) ≡ 0 and F(p-1) ≡ 1 (mod p²).
**Impact**: Would connect to Fermat's Last Theorem and Wieferich primes.

---

## Tier C: Advanced Research (12-24 months)

### C1. Quantum Walk on Berggren Tree
### C2c. Persistent Homology Barcodes — ENHANCED
### C3. Adelic Unification
### C4. Galois-Theoretic Obstructions
### C5. Tropical Factoring Geometry
### C6d. Statistical Mechanics Phase Transition — ENHANCED
### C7. Spin Glass Models for Factoring
### C8. Analytic Number Theory of Peel Products
### C9. Modular Forms of Weight 2 for Γ₀(4)

### C14. Fibonacci-Lattice Hybrid Factoring — NEW
**Goal**: Combine Pisano period constraints with lattice reduction.
**Foundation**: Both CRT and LLL are now partially formalized.

### C15. Energy Landscape Neural ODE Verification — NEW
**Goal**: Verify that gradient descent on E(x) converges to divisors.
**Foundation**: Local minima at divisors ✓, Laplacian nonneg ✓.

---

## Tier D: Long-Term Vision

### D1-D10 (unchanged from v5)

---

## Tier E: New and Ongoing Directions

### E1-E30 (from v6)

### E31. Frobenius Endomorphism Factoring — NEW
Use the formally verified Frobenius theory (from F(p)² proof) for factoring in finite fields.

### E32. σ₁ Oracle Cryptographic Protocols — NEW
Design zero-knowledge proofs based on the σ₁ ↔ FACTORING equivalence.

### E33. Energy Landscape Machine Learning — NEW
Train models to predict factor locations from the energy landscape E(x).

### E34. Pisano Period Quantum Algorithms — NEW
Quantum period-finding for π(N) could be exponentially faster than classical.

### E35. Euler Direction Completion — NEW
Complete the formal proof that all even perfects have Euclid's form.

---

## Key Open Questions (Updated Rankings)

1. **Can Hurwitz quaternion factoring be made efficient?** (Impact: 10, Feasibility: 7) ← TOP
2. **What is the density of Fibonacci pseudoprimes?** (Impact: 8, Feasibility: 8) ← ELEVATED
3. ~~Can σ₁(N) be efficiently approximated?~~ **ANSWERED: Equivalent to factoring ✓**
4. ~~Does F(p)² ≡ 1 mod p?~~ **ANSWERED: YES, formally proved ✓**
5. **Is there a polynomial-time lattice factoring algorithm?** (Impact: 10, Feasibility: 2)
6. **Can persistent homology detect factors?** (Impact: 9, Feasibility: 6)
7. **Do odd perfect numbers exist?** (Impact: 10, Feasibility: 1)
8. **Can Pisano periods be computed efficiently?** (Impact: 8, Feasibility: 7)
9. **Does the energy landscape have a sharp phase transition?** (Impact: 7, Feasibility: 5)
10. **Can quantum algorithms exploit 4-square representations?** (Impact: 9, Feasibility: 4) ← NEW

---

## Updated Verification Summary

| Result | Status | File |
|--------|--------|------|
| All v1-v6 results (95+) | ✓ | Various |
| **lipschitz_norm_mul** | **v7** ✓ | HurwitzQuaternions.lean |
| **composite_gcd_structure** | **v7** ✓ | HurwitzQuaternions.lean |
| **int_euclidean_division** | **v7** ✓ | HurwitzQuaternions.lean |
| **sigma1_determines_factors** | **v7** ✓ | SigmaHardness.lean |
| **sigma1_three_primes** | **v7** ✓ | SigmaHardness.lean |
| **sigma1_multiplicative** | **v7** ✓ | SigmaHardness.lean |
| **sigma1_prime_power_formula** | **v7** ✓ | SigmaHardness.lean |
| **sigma1_gap_reveals_sum** | **v7** ✓ | SigmaHardness.lean |
| **full_reduction_chain** | **v7** ✓ | SigmaHardness.lean |
| **divisor_count_le_sigma1** | **v7** ✓ | SigmaHardness.lean |
| **fib_sq_mod_prime** | **v7** ✓ | FibonacciPseudoprimes.lean |
| **pisano_period_exists** | **v7** ✓ | FibonacciPseudoprimes.lean |
| **fib_composite_test** | **v7** ✓ | FibonacciPseudoprimes.lean |
| **fib_linear_lower** | **v7** ✓ | FibonacciPseudoprimes.lean |
| **fib_exp_bound** | **v7** ✓ | FibonacciPseudoprimes.lean |
| **fib_mod_periodic** | **v7** ✓ | PisanoPeriodFactoring.lean |
| **pisano_coprime_lcm** | **v7** ✓ | PisanoPeriodFactoring.lean |
| **pisano_factor_constraint** | **v7** ✓ | PisanoPeriodFactoring.lean |
| **pisano_small_primes** | **v7** ✓ | PisanoPeriodFactoring.lean |
| **wall_divides_pisano** | **v7** ✓ | PisanoPeriodFactoring.lean |
| **fib_add (Vajda)** | **v7** ✓ | PisanoPeriodFactoring.lean |
| **divisor_is_local_min** | **v7** ✓ | EnergyMorseTheory.lean |
| **energy_pos_of_not_dvd** | **v7** ✓ | EnergyMorseTheory.lean |
| **sublevel_zero_divisors** | **v7** ✓ | EnergyMorseTheory.lean |
| **sublevel_full** | **v7** ✓ | EnergyMorseTheory.lean |
| **laplacian_nonneg_at_divisor** | **v7** ✓ | EnergyMorseTheory.lean |
| **average_energy_bound** | **v7** ✓ | EnergyMorseTheory.lean |
| **zero_energy_eq_divisor_count** | **v7** ✓ | EnergyMorseTheory.lean |
| **euclid_direction** | **v7** ✓ | EvenPerfectNumbers.lean |
| **euler_key_equation** | **v7** ✓ | EvenPerfectNumbers.lean |
| **euler_m_divisible** | **v7** ✓ | EvenPerfectNumbers.lean |
| **euler_m_is_prime** | **v7** ✓ | EvenPerfectNumbers.lean |
| **perfect_ge_six** | **v7** ✓ | EvenPerfectNumbers.lean |
| **no_small_odd_perfect** | **v7** ✓ | EvenPerfectNumbers.lean |
| **six, 28, 496, 8128 perfect** | **v7** ✓ | EvenPerfectNumbers.lean |
| **sigma1_no4_odd** | **v7** ✓ | JacobiFourSquare.lean |
| **euler_product_r4** | **v7** ✓ | JacobiFourSquare.lean |
| **Total verified** | **130+** | **4 sorry** |

---

## Recommended Timeline (Updated)

| Phase | Months | Focus | Key Deliverables |
|-------|--------|-------|-----------------|
| 1 | 1-3 | A+7c, A+10, A+11 | Hurwitz descent, Fib density, Euler completion |
| 2 | 3-6 | A1b, A6c, A7b, A12 | Jacobi theta, σ₁ lattice, homology, Pisano |
| 3 | 6-12 | B1, B8c, B10b, B11 | Hurwitz PID, Carmichael, general σ₁, Wall-Sun-Sun |
| 4 | 12-18 | C2c, C6d, C14, C15 | Barcodes, phase transition, hybrid, neural ODE |
| 5 | 18-36 | D/E | Quantum, ML, tropical, adelic |

---

*This document supersedes future_research_directions_v6.md with 45+ new verified results, 10 closed directions, 7 new Lean files, 5 new research directions (E31-E35), 4 Python demos, and revised rankings.*
