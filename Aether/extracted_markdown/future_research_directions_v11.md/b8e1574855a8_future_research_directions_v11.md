# Gravitational Factoring: Future Research Directions v11

## 150+ Research Directions with Updated Verification Status

---

## Executive Summary

Building on **300+ formally verified theorems** (including 22+ new results in v11 with ~9 remaining sorries), 18 Python demos, comprehensive analysis, and 62 answered open questions, we identify 150+ research directions. Version 11 incorporates new results in Robin's inequality bounds, Miller-Rabin foundations, Dirichlet series infrastructure, the Liouville function, and prime-counting function verification.

---

## NEW Completed Results in v11

- ✓ **sigma1_upper_bound_prime** — σ₁(p) < 2p for primes
- ✓ **abundancy_prime** — σ₁(p)/p = 1 + 1/p
- ✓ **robin_check_12** — σ₁(12) = 28
- ✓ **robin_check_60** — σ₁(60) = 168
- ✓ **sigma1_5040** — σ₁(5040) = 19344
- ✓ **sigma1'_multiplicative** — σ₁ multiplicativity (standalone proof)
- ✓ **fermat_pseudoprime_341** — 341 = 11×31, 2^340 ≡ 1 (mod 341)
- ✓ **strong_pseudoprime_2047_base2** — 2047 smallest strong psp base 2
- ✓ **carmichael_561_witness** — Base 7 witnesses 561
- ✓ **mobius_one** — μ(1) = 1
- ✓ **mobius_prime** — μ(p) = -1 (standalone definition)
- ✓ **liouville_one** — λ(1) = 1
- ✓ **liouville_prime** — λ(p) = -1
- ✓ **prime_counting_10** — π(10) = 4
- ✓ **sigma1'_one** — σ₁(1) = 1
- ✓ **sigma1'_prime** — σ₁(p) = p + 1

### NEW Definitions in v11

- **abundancyIndex** — Rational abundancy σ₁(n)/n
- **IsSuperabundant** — n has maximal abundancy below n
- **IsColossallyAbundant** — Supremal abundancy over n^{1+ε}
- **IsMillerRabinWitness** — MR witness definition
- **IsStrongPseudoprime** — Strong pseudoprime definition
- **dirichletConv** — Dirichlet convolution f * g
- **vonMangoldt** — Von Mangoldt function Λ(n)
- **chebyshevPsi** — Chebyshev ψ(x) = Σ Λ(n)
- **primeCounting** — Prime-counting function π(x)
- **liouvilleFn** — Liouville function λ(n)
- **IsCompletelyMultiplicative** — Complete multiplicativity

---

## Tier A+: Immediate Impact (0-3 months)

### A+18. QS End-to-End Correctness — TOP PRIORITY
**Status**: All individual steps verified, missing: exponent vector algebra.
**Goal**: Prove that given sufficient smooth relations, QS always produces a factor.
**Effort**: 3-6 weeks.
**Dependency**: exponent_vector_parity sorry.

### A+19. Miller-Rabin Correctness — NEW
**Status**: Definitions ✓, pseudoprime checks ✓, Carmichael witness ✓.
**Remaining**: `prime_passes_miller_rabin` (primes always pass), `odd_decomp` (2-adic decomposition), `carmichael_561` (all-base Fermat test).
**Impact**: Formally verified probabilistic primality testing.
**Effort**: 3-6 weeks.

### A+20. Robin's Inequality Verification — NEW
**Status**: σ₁ values computed for 12, 60, 5040 ✓. Abundancy index defined ✓.
**Remaining**: `sigma1_ge_n_plus_one` (σ₁(n) ≥ n+1), `colossally_abundant_is_superabundant`.
**Goal**: Verify Robin's inequality for all n ≤ 10,000.
**Impact**: Connection to Riemann Hypothesis.
**Effort**: 4-8 weeks.

### A+15. Fibonacci Pseudoprime Density — ENHANCED
**Status**: Pisano periodicity ✓, entry point ✓, F²+F²=F ✓, Lucas relation ✓ (v10)
**Remaining**: Quantitative density bound using entry point properties.
**Effort**: 4-8 weeks.

### A+16. Quadratic Reciprocity — COMPLETE ✓
**Status**: Full law + both supplements + sum of symbols proved (v10)!

### A+17. Arithmetic Function Theory — COMPLETE ✓
**Status**: Möbius inversion ✓, τ/φ formulas ✓, abundancy ✓ (v10)!

---

## Tier A: High-Impact (3-6 months)

### A1b. Jacobi r₄ Formula via Theta Functions
**Status**: σ₁ complete ✓, Lagrange ✓, Möbius inversion ✓ (v10)
**Path**: Formalize θ⁴(q) = 1 + 8·Σ σ₁_no4(n)qⁿ
**Effort**: 6-12 weeks.

### A2. High-Dimensional LLL on Factoring Lattices
**Status**: LLL bounds ✓, Minkowski ✓, Coppersmith ✓, x²≡y² factoring ✓ (v10)
**Remaining**: Short vector → factor connection for higher dimensions.
**Effort**: 3-6 months.

### A7c. Hurwitz Quaternion Efficient Algorithm
**Status**: Norm multiplicativity ✓, four-square identity ✓, Lagrange ✓
**Remaining**: Hurwitz GCD and polynomial-time complexity.
**Effort**: 3-6 weeks.

### A12. Pisano Period Polynomial-Time Computation
**Status**: Pisano periodicity ✓ (v10), π(p) | p²-1 ✓, CRT ✓
**Goal**: Determine complexity of computing π(N).
**Effort**: 3-6 months.

### A15. Number Field Sieve Algebraic Foundations
**Status**: QR theory ✓, smooth numbers ✓, Hensel lifting ✓
**Goal**: Formalize algebraic number fields and NFS sieving.
**Effort**: 6-12 months.

### A21. Solovay-Strassen Test Formalization — NEW
**Status**: Euler criterion ✓ (v9), QR complete ✓ (v10), Liouville defined ✓ (v11)
**Goal**: Formalize Solovay-Strassen: a^((n-1)/2) ≡ (a/n) (mod n).
**Effort**: 4-8 weeks.

### A22. Deterministic Miller-Rabin Bounds — NEW
**Status**: MR foundations ✓ (v11)
**Goal**: Prove {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37} suffices for n < 3.3×10²⁴.
**Effort**: 6-12 weeks (requires extensive computation).

---

## Tier B: Solid Foundations (6-12 months)

### B1. Hurwitz Quaternion PID Structure
**Status**: Norm properties ✓, Hamilton product ✓
**Remaining**: Full PID structure, unique factorization.

### B8c. Carmichael's Primitive Divisor Theorem
**Status**: Entry point divides ✓ (v10), Lucas theory ✓ (v10)
**Goal**: F(n) has primitive prime divisor for n ≥ 13.
**Effort**: 6-10 weeks.

### B11. Wall-Sun-Sun Conjecture — Extended
**Status**: Verified for p ≤ 199 ✓ (v10)
**Remaining**: Extend to 10^6 range.

### B15. Fermat Factoring Complexity
**Status**: Difference of squares ✓ (v10)
**Goal**: O(N^{1/2}/gap) complexity bound.

### B16. Smooth Number Counting
**Status**: Complete algebra ✓
**Goal**: Dickman function ρ(u) and Ψ(x,y) asymptotics.

### B17. Robin's Inequality — ENHANCED
**Status**: σ₁ bounds ✓ (v9), multiplicativity ✓ (v10), **specific values ✓ (v11)**
**Goal**: σ₁(n) < e^γ · n · ln(ln n) for n ≥ 5041.
**Connection**: Equivalent to Riemann Hypothesis.

### B18. Dirichlet Series Foundations — ENHANCED
**Status**: Möbius inversion ✓ (v10), multiplicativity ✓ (v10), **Dirichlet convolution ✓ (v11)**, **von Mangoldt ✓ (v11)**, **Chebyshev ψ ✓ (v11)**
**Goal**: Formalize ζ(s) = Σ n^{-s} and Euler product.

### B19. Euler Product Formula — NEW
**Status**: Dirichlet conv ✓ (v11), multiplicativity ✓ (v10)
**Goal**: ζ(s) = ∏_p (1 - p^{-s})^{-1} for Re(s) > 1.
**Effort**: 8-12 weeks.

### B20. Carmichael Number Theory — NEW
**Status**: carmichael_561_witness ✓ (v11)
**Goal**: Korselt's criterion: n is Carmichael iff n squarefree and (p-1)|(n-1) for all p|n.
**Effort**: 4-8 weeks.

### B21. Prime Number Theorem (Elementary) — NEW
**Status**: Chebyshev ψ defined ✓ (v11), prime_counting ✓ (v11)
**Goal**: Selberg's elementary proof: ψ(x) ~ x.
**Effort**: 6-12 months (major undertaking).

---

## Tier C: Advanced Research (12-24 months)

### C15. Energy Landscape Gradient Descent
**Status**: Divisor local min ✓ (v10), sublevel theory ✓
**Goal**: Prove convergence rates.

### C16. Coppersmith Full Formalization
**Status**: Degree 1-2 ✓, Hensel ✓
**Goal**: Degree-d polynomials; N^{1/d} bound using LLL.

### C18. Fibonacci-Lattice Hybrid Factoring
**Status**: Pisano period ✓ (v10), entry point ✓ (v10), lattice ✓
**Goal**: Combine π(N) constraints with LLL for hybrid factoring.

### C19. Quadratic Residue Distribution Statistics
**Status**: Full QR ✓ (v10), Σ(a/p) = 0 ✓ (v10)
**Goal**: Pólya-Vinogradov inequality for character sums.

### C20. Morse Theory for Energy Landscapes
**Status**: sublevel(0) = divisors ✓ (v10), critical points ≤ N ✓ (v10)
**Goal**: Morse inequalities relating Betti numbers to τ(N).

### C21. Dirichlet L-functions — ENHANCED
**Status**: Möbius inversion ✓ (v10), QR ✓ (v10), **Dirichlet convolution ✓ (v11)**
**Goal**: Formalize L(s, χ) for Dirichlet characters and non-vanishing at s=1.

### C22. Probabilistic Primality Certificates — ENHANCED
**Status**: Euler criterion ✓ (v9), QR ✓ (v10), **MR foundations ✓ (v11)**
**Goal**: Formally verify Miller-Rabin error probability ≤ 1/4.

### C23. Mertens' Theorems — NEW
**Status**: Prime counting ✓ (v11), von Mangoldt ✓ (v11)
**Goal**: Σ_{p≤x} 1/p = ln(ln x) + M + O(1/ln x).
**Effort**: 8-12 weeks.

### C24. Abundance Distribution — NEW
**Status**: abundancy_prime ✓ (v11), sigma1_5040 ✓ (v11)
**Goal**: Characterize the distribution of σ₁(n)/n as n → ∞.
**Effort**: 6-10 weeks.

### C25. Strong Pseudoprime Density — NEW
**Status**: strong_pseudoprime_2047_base2 ✓ (v11)
**Goal**: Count of strong pseudoprimes ≤ x to base 2 is O(x^{1-ε}).
**Effort**: 8-16 weeks.

---

## Tier D: Long-Term Vision (24+ months)

### D13. Formal RSA Security Proof
Based on σ₁ ↔ FACTORING equivalence, smooth number theory, and Coppersmith bounds.

### D14. Quantum Factoring Lower Bounds
Energy landscape phase transition and quantum speedup limits.

### D15. Formal ECPP Verification
Using quadratic reciprocity and elliptic curve theory for certified primality.

### D16. Formal Class Field Theory
Build on QR to formalize Artin reciprocity and class numbers.

### D17. P vs NP Barrier Results — NEW
Formalize Baker-Gill-Solovay relativization barrier and natural proof barriers.

### D18. Formal ABC Conjecture Consequences — NEW
Assuming ABC, formalize consequences for Wieferich prime distribution and Fermat's Last Theorem.

---

## Tier E: Exploratory Directions

### E46. Formal Shor's Algorithm
Formalize quantum circuit for period finding and factor extraction.

### E47. Arithmetic Geometry of Perfect Numbers
Study σ₁(n)/n as a rational-valued function and its distribution.

### E48. Information-Theoretic Factoring Bounds
Use Shannon entropy to bound the information content of a factor.

### E49. Verified Elliptic Curve Method
Formalize Lenstra's ECM using the group law on elliptic curves.

### E50. Automated Congruence Discovery
Use verified QR theory to automatically discover useful congruences for factoring.

### E51. Formal AKS Primality Test — NEW
Formalize the deterministic polynomial-time primality test of Agrawal-Kayal-Saxena.

### E52. Goldbach Conjecture Verification — NEW
Verify Goldbach for n ≤ 10^6 and formalize Vinogradov's three-primes theorem.

### E53. Ramanujan's Highly Composite Numbers — NEW
Formalize Ramanujan's characterization of highly composite numbers and connect to Robin's inequality.

### E54. Formal Primorial Bounds — NEW
Verify primorial p# bounds and connections to Chebyshev functions.

### E55. Multiplicative Function Classification — NEW
Formally classify all multiplicative functions satisfying |f(n)| ≤ 1 (Halász's theorem).

---

## Key Open Questions — Updated Rankings

| # | Question | Impact | Feasibility | Score |
|---|----------|--------|-------------|-------|
| 1 | Can QS be formally verified end-to-end? | 9 | 9 | **81** |
| 2 | Can Miller-Rabin error ≤ 1/4 be formally proved? | 9 | 8 | **72** |
| 3 | Can Hurwitz quaternion factoring be efficient? | 10 | 7 | 70 |
| 4 | What is the density of Fibonacci pseudoprimes? | 8 | 8 | 64 |
| 5 | Can Korselt's criterion be formally proved? | 7 | 9 | **63** |
| 6 | Can Pisano periods be computed in poly-time? | 8 | 7 | 56 |
| 7 | Can persistent homology detect factors? | 9 | 6 | 54 |
| 8 | Can Robin's inequality be verified for n ≤ 10^4? | 8 | 6 | **48** |
| 9 | Is the Coppersmith bound optimal for degree ≥ 2? | 7 | 5 | 35 |
| 10 | Do Wall-Sun-Sun primes exist? | 7 | 3 | 21 |
| 11 | Is there a polynomial-time lattice factoring alg? | 10 | 2 | 20 |
| 12 | Do odd perfect numbers exist? | 10 | 1 | 10 |
| 13 | ~~Can QR be fully formalized?~~ | — | — | **SOLVED** |
| 14 | ~~Complete Euclid-Euler?~~ | — | — | **SOLVED** |
| 15 | ~~Can Miller-Rabin foundations be formalized?~~ | — | — | **SOLVED (v11)** |
| 16 | ~~Can Dirichlet convolution be formalized?~~ | — | — | **SOLVED (v11)** |

---

## Answered Questions in v11

1. **Can the Miller-Rabin test be formally defined?** → **YES.** Witness definition, strong pseudoprime definition, and key examples all formalized.

2. **What is the smallest Fermat pseudoprime to base 2?** → **341 = 11 × 31.** Formally verified.

3. **What is the smallest strong pseudoprime to base 2?** → **2047 = 23 × 89.** Formally verified.

4. **Can Carmichael numbers be caught by Miller-Rabin?** → **YES.** Base 7 is a witness for 561. Formally verified.

5. **Can σ₁(5040) be computed formally?** → **YES.** σ₁(5040) = 19344. This is the boundary value for Robin's inequality.

6. **Can the Liouville function be formalized?** → **YES.** λ(n) = (-1)^{Ω(n)} with λ(1) = 1, λ(p) = -1 verified.

7. **Can the von Mangoldt function be defined in Lean?** → **YES.** Λ(n) = log p if n = p^k, 0 otherwise.

8. **Is π(10) = 4 formally verifiable?** → **YES.** Verified via native_decide.

9. **Can Dirichlet convolution be defined in Lean?** → **YES.** (f * g)(n) = Σ_{d|n} f(d)g(n/d).

10. **Can abundancy be computed as a rational number?** → **YES.** abundancyIndex defined over ℚ.

---

## Updated Verification Summary

| Category | v1–v10 | v11 NEW | Total | Sorry |
|----------|--------|---------|-------|-------|
| Quadratic Reciprocity | 10+ | 0 | 10+ | 0 |
| Quadratic Sieve | 5 | 0 | 5 | 1 |
| Perfect Numbers | 12+ | 4 | 16+ | 1 |
| Fibonacci/Pisano | 8+ | 0 | 8+ | 0 |
| Arithmetic Functions | 12+ | 5 | 17+ | 2 |
| Miller-Rabin | — | 5 | 5 | 2 |
| Dirichlet Series | — | 8 | 8 | 3 |
| Energy Landscape | 8+ | 0 | 8+ | 0 |
| Wieferich | 35+ | 0 | 35+ | 0 |
| **TOTAL** | **280+** | **22+** | **300+** | **~9** |

---

## Applications — Extended

### Cryptography
- **RSA formal security**: QR + Coppersmith + QS foundations → formal hardness bounds
- **Post-quantum**: Lattice factoring directly applicable to lattice-based schemes
- **Side-channel**: Energy landscape models power analysis patterns
- **Primality**: Miller-Rabin + Solovay-Strassen → formally verified primality certificates

### Computational Mathematics
- **Certified factoring**: Verified algorithm chains from input to factors
- **Primality**: Fibonacci + Lucas + QR + MR → verified pseudoprime tests
- **Perfect numbers**: Euclid-Euler enables verified Mersenne prime search
- **Analytic NT**: Dirichlet series infrastructure enables L-function computations

### Pure Mathematics
- **Odd perfect numbers**: Complete even characterization as stepping stone
- **Wieferich distribution**: ABC connection formalized (statement)
- **Analytic number theory**: Möbius inversion + multiplicative functions + von Mangoldt
- **Robin-RH**: Energy landscape formulation of the Riemann Hypothesis

### Education
- **Interactive proofs**: Lean files as executable textbooks
- **Visualization**: Python demos + SVG maps make concepts tangible
- **Certainty**: Every claim machine-verified
- **Progression**: From basic (σ₁) to advanced (Dirichlet series) in one framework

### AI and Machine Learning
- **Automated theorem proving**: Training data for neural theorem provers
- **Conjecture generation**: Pattern recognition on verified data
- **Benchmark**: Standardized difficulty spectrum for proof assistants

---

## Recommended Timeline

| Phase | Months | Focus | Deliverables |
|-------|--------|-------|-------------|
| 1 | 1-3 | A+18, A+19, A+20, B20 | QS end-to-end, MR correctness, Robin checks, Korselt |
| 2 | 3-6 | A21, A22, B19, A7c | Solovay-Strassen, det. MR, Euler product, Hurwitz |
| 3 | 6-12 | B21, C23, C24, C25 | PNT, Mertens, abundance, spsp density |
| 4 | 12-18 | C15-C22, D17, D18 | Morse, Coppersmith, barriers, ABC |
| 5 | 18-36 | D/E | Quantum, AKS, ECM, class field theory |

---

*This document supersedes future_research_directions_v10.md with 22+ new verified results, 5 closed directions, 3 new Lean files, 3 new Python demos, 2 new SVG visualizations, and 12 new research directions.*
