# MetaFactoring: Recommended Future Research Directions

## A Systematic Roadmap for Extending the Multi-Lens Framework

---

## Executive Summary

Based on our formal verification of 100+ theorems across the MetaFactoring framework, we identify 12 high-impact research directions, organized by priority and difficulty. Each direction builds on machine-verified foundations and has been assessed for feasibility.

---

## Tier 1: Immediate Opportunities (6-12 months)

### 1.1 Dickman Function Formalization
**Impact:** Very High | **Difficulty:** Hard | **Prerequisites:** Mathlib analysis

**Goal:** Formalize the Dickman function ρ(u) satisfying the delay differential equation uρ'(u) = -ρ(u-1) for u > 1 with ρ(u) = 1 for u ∈ (0,1].

**Why it matters:** The Dickman function is the key to rigorous complexity analysis of GNFS (L[1/3, (64/9)^{1/3}]) and ECM. Without it, we cannot formally state the subexponential complexity bounds that underpin modern factoring.

**Approach:**
1. Define ρ as the unique solution to the delay DE on [0,∞)
2. Prove existence/uniqueness via Banach fixed-point or successive approximation
3. Establish the asymptotic ρ(u) ~ u^{-u} (Hildebrand-Tenenbaum)
4. Connect to smooth number counts: Ψ(x, y) ~ x·ρ(log x / log y)

**Milestones:**
- [ ] Define ρ on [0,2] (closed form: ρ(u) = 1 - ln u for u ∈ [1,2])
- [ ] Prove monotonicity and positivity
- [ ] Establish the integral equation equivalent
- [ ] Connect to smooth number counting

### 1.2 General Sub-Binary Recurrence Theorem
**Impact:** Medium | **Difficulty:** Medium | **Prerequisites:** Linear algebra, Perron-Frobenius

**Goal:** Prove Conjecture 1 in full generality: for any linear recurrence with nonneg coefficients and dominant root λ < 2, aₙ < 2^n eventually.

**Approach:** The dominant root λ determines the asymptotic growth aₙ ~ Cλⁿ. Since λ < 2, there exists N₀ such that Cλⁿ < 2ⁿ for all n ≥ N₀. The formal proof requires:
1. Companion matrix eigenvalue analysis
2. Jordan normal form bounds for the non-dominant terms
3. Explicit N₀ computation

**Already verified:** Fibonacci (λ = φ ≈ 1.618), Lucas (λ = φ), Tribonacci (λ ≈ 1.839).

### 1.3 Lens Composition Visualization Tool
**Impact:** Medium | **Difficulty:** Low | **Prerequisites:** Web development

**Goal:** Build an interactive web tool that visualizes how each lens constrains the factor search space for a given N.

**Features:**
- Input: composite number N
- Output: animated visualization of each lens's constraint
- Show: remaining search space after each lens application
- Demo: step-by-step factoring using the lens framework

---

## Tier 2: Medium-Term Goals (1-2 years)

### 2.1 Independence Conjecture Resolution
**Impact:** Very High | **Difficulty:** Very Hard | **Prerequisites:** Information theory, algebraic number theory

**Goal:** Resolve Conjecture 2: Is the maximum number of mutually independent factoring lenses Θ(log log N)?

**Approach (upper bound):** Show that any lens can be expressed as a function of the factorization (p, q), and that the mutual information between any two lenses is bounded below by I(L_i; L_j) ≥ c·log(log N)^{-1} for some constant c.

**Approach (lower bound):** Construct log log N independent lenses explicitly. Candidates:
1. Parity of p (1 bit)
2. p mod 3 (1 bit)
3. Legendre symbol (p/5) (1 bit)
4. ... continuing with small primes up to the k-th prime for k ≈ log log N

**Key insight:** The number of primes up to log N is ~ log N / log log N (prime number theorem). The residues mod these primes are nearly independent by CRT.

### 2.2 Quantum Circuit Integration
**Impact:** High | **Difficulty:** Hard | **Prerequisites:** Quantum computing, error correction

**Goal:** Design concrete quantum circuits that implement the classical lens preprocessing, and analyze the end-to-end qubit budget.

**Approach:**
1. For each lens, design a quantum oracle that encodes the constraint
2. Modify Grover's search to incorporate all 9 constraints
3. Analyze the circuit depth and qubit overhead
4. Compare with the brute-force Grover approach

**Expected result:** For RSA-2048, saving ~4.5 logical qubits translates to ~2,000 physical qubits at code distance 21, which is significant for near-term quantum computers.

### 2.3 Elliptic Divisibility Sequences
**Impact:** Medium | **Difficulty:** Hard | **Prerequisites:** Elliptic curve theory

**Goal:** Extend the Fibonacci-spectral bridge to elliptic divisibility sequences (EDS), which satisfy:
W_{m+n}·W_{m-n} = W_{m+1}·W_{m-1}·W_n² - W_{n+1}·W_{n-1}·W_m²

**Why it matters:** EDS are the natural elliptic curve analogue of Fibonacci numbers. Understanding their periodicity modulo primes could strengthen the ECM lens and create new Fibonacci-ECM bridges.

### 2.4 Tropical Geometry Deep Dive
**Impact:** High | **Difficulty:** Hard | **Prerequisites:** Algebraic geometry, valuations

**Goal:** Formalize the connection between tropical geometry and factoring via Newton polygons.

**Key idea:** The Newton polygon of a polynomial f(x) = aₙxⁿ + ... + a₀ has slopes determined by the p-adic valuations of the roots. For factoring N, the polynomial x² - N has roots ±√N, and the tropical structure of these roots constrains the p-adic structure of the factors.

---

## Tier 3: Long-Term Vision (2-5 years)

### 3.1 Post-Quantum Lens Framework
**Impact:** Very High | **Difficulty:** Very Hard | **Prerequisites:** Lattice cryptography

**Goal:** Adapt the multi-lens framework from integer factoring to lattice problems (LWE, NTRU, SVP).

**Key observation:** Both factoring and LWE reduce to finding short vectors in lattices. A "tropical lens for lattices" could work as follows:
- Define a "lattice smoothness" analogue of number smoothness
- Use tropical valuations of lattice coordinates as constraints
- Apply Babai's nearest plane algorithm within each lens-constrained region

### 3.2 Formal Complexity Lower Bounds
**Impact:** Very High | **Difficulty:** Open Problem | **Prerequisites:** Computational complexity

**Goal:** Prove formal lower bounds on factoring that account for multi-lens information.

**The dream result:** "No algorithm using k independent 1-bit lenses can factor n-bit integers in time o(2^{(n-k)/2})." This would establish that multi-lens methods can achieve at most polynomial improvement over brute force.

**Reality check:** Such a result would essentially resolve the P vs NP question for factoring, so this is extremely ambitious. However, conditional lower bounds (e.g., under the Exponential Time Hypothesis) might be feasible.

### 3.3 Machine Learning Lens Selection
**Impact:** Medium | **Difficulty:** Medium | **Prerequisites:** ML, formal methods

**Goal:** Train neural networks to predict the optimal lens ordering for a given target N.

**Data generation:** Use the formal framework to generate exact training data:
- Input: Features of N (size, residues mod small primes, tropical profile)
- Output: Optimal lens ordering (measured by total cost)

**Architecture:** Graph neural network where nodes represent lenses and edges represent compatibility constraints.

### 3.4 Automated Lens Discovery
**Impact:** Very High | **Difficulty:** Very Hard | **Prerequisites:** AI for mathematics

**Goal:** Use automated reasoning to discover new factoring lenses beyond the nine currently known.

**Approach:** Define a "lens" formally as a function L: ℕ → {0,1} that is efficiently computable and correlates with some bit of the factorization. Then search for such functions using:
1. Symbolic regression over number-theoretic functions
2. Reinforcement learning with factoring success as reward
3. Large language model-guided conjecture generation

---

## Cross-Cutting Themes

### Theme A: Formalization as Discovery
The act of formal verification repeatedly generates new mathematical questions. We recommend that future work continue the practice of machine verification, using Lean 4 + Mathlib as the standard. Formalization should not be an afterthought — it should be integral to the research process.

### Theme B: Computational Validation
Every conjecture should be tested computationally before formal proof is attempted. Our Python demos provide a template for rapid experimentation.

### Theme C: Interdisciplinary Connections
The nine lenses span nine areas of mathematics. Future work should actively seek connections between these areas. For example:
- **Tropical + Spectral:** p-adic analysis of character sums
- **Fibonacci + Elliptic:** Elliptic divisibility sequences
- **Lattice + Division Algebra:** Algebraic number theory of norm forms
- **Orbit + Quantum:** Quantum walk-based cycle detection

---

## Summary Table

| # | Direction | Impact | Difficulty | Timeline |
|---|-----------|--------|------------|----------|
| 1.1 | Dickman Function | Very High | Hard | 6-12 mo |
| 1.2 | General Sub-Binary | Medium | Medium | 6-12 mo |
| 1.3 | Visualization Tool | Medium | Low | 3-6 mo |
| 2.1 | Independence Conjecture | Very High | Very Hard | 1-2 yr |
| 2.2 | Quantum Circuits | High | Hard | 1-2 yr |
| 2.3 | Elliptic Div. Sequences | Medium | Hard | 1-2 yr |
| 2.4 | Tropical Deep Dive | High | Hard | 1-2 yr |
| 3.1 | Post-Quantum Lenses | Very High | Very Hard | 2-5 yr |
| 3.2 | Complexity Lower Bounds | Very High | Open Problem | 2-5 yr |
| 3.3 | ML Lens Selection | Medium | Medium | 1-3 yr |
| 3.4 | Automated Lens Discovery | Very High | Very Hard | 3-5 yr |

---

*All foundational theorems referenced in this document have been machine-verified in Lean 4 with Mathlib.*
