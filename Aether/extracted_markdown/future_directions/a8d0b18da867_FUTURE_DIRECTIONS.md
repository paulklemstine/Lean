# Future Directions: Tropical Algorithmic Number Theory

## Overview

This document outlines concrete breakthrough research opportunities opened by the tropical quadratic sieve kernel. Each direction includes specific hypotheses, proof strategies, cross-domain connections, and actionable next steps.

---

## Direction 1: Tropical Number Field Sieve via Valuation Polyhedra

### Hypothesis
The relation-collection stage of the Number Field Sieve (NFS) — the most powerful known general-purpose factoring algorithm — can be tropicalized analogously to the quadratic sieve, with the valuation matrix generalized to a polytopal structure encoding algebraic norm valuations.

### Proof Strategy
1. Define the NFS sieve polynomial f(x) and its norm N(a, b) = Res(f, a - bx).
2. Build a *double* valuation matrix: one for the rational factor base, one for the algebraic factor base.
3. Prove that on *doubly smooth* inputs (both norms smooth), the tropical score equals the classical score.
4. Use the lattice structure of the sieve region to define a tropical polyhedron whose vertices correspond to smooth relations.

### Cross-Domain Connections
- **Tropical geometry**: Valuation polyhedra connect to Newton polytopes and tropical varieties of the NFS polynomial.
- **Lattice algorithms**: The NFS sieve region is a lattice; tropical scoring on lattice points connects to lattice point enumeration.
- **Cryptographic security**: Any efficiency gain in NFS relation collection directly impacts RSA and discrete-log security estimates.

### Actionable Next Steps
- Formalize the NFS norm function and its factorization support.
- Prove the double-support restriction theorem for algebraic + rational factor bases.
- Implement a tropical NFS scoring kernel and benchmark against classical implementations.

---

## Direction 2: Tropical Entropy and Information Content of Smooth Numbers

### Hypothesis
The *tropical entropy* H_T(n) = log(n) − Σ_{p ∈ FB} v_p(n) · log(p) is a meaningful complexity measure for integers relative to a factor base. It satisfies:
- H_T(n) = 0 iff n is B-smooth.
- H_T(n) ≈ log(largest prime factor > B) for "1-partial" relations.
- H_T(n) concentrates around log(n) for "random" integers.

The distribution of H_T over the sieve interval should connect to the Dickman-de Bruijn function ρ(u) and yield tropical analogues of classical smoothness probability estimates.

### Proof Strategy
1. Define H_T formally and prove H_T(n) = 0 ⟺ n is B-smooth.
2. Prove H_T is subadditive: H_T(mn) ≤ H_T(m) + H_T(n).
3. Connect the empirical distribution of H_T to the Dickman function via tropical analytic arguments.
4. Derive a tropical analogue of the Canfield-Erdős-Pomerance theorem on smoothness probabilities.

### Cross-Domain Connections
- **Information theory**: H_T has the form of a divergence measure between n's factorization and the factor base.
- **Statistical mechanics**: H_T is an "energy" in a statistical model where primes are modes and valuations are occupancies.
- **Coding theory**: Smooth numbers are "compressible" in the factor base alphabet; H_T measures incompressibility.

### Actionable Next Steps
- Prove the equivalence H_T(n) = 0 ⟺ B-smooth in Lean.
- Compute empirical H_T distributions for various N and B.
- Formulate and test a tropical Dickman function hypothesis.

---

## Direction 3: Certified Reduction from Smoothness Scoring to Min-Plus Shortest Path

### Hypothesis
There exists a formal reduction from the sieve scoring problem to the All-Pairs Shortest Path (APSP) problem in an appropriately constructed graph, such that:
- Nodes correspond to partial factorizations.
- Edge weights correspond to prime-valuation increments.
- The shortest path from "unfactored" to "fully factored" equals the tropical deficiency score.

### Proof Strategy
1. Construct the factorization DAG: nodes are partial products of factor-base primes, edges are multiplications by p^k with weight k · w(p).
2. Prove that the shortest path from 1 to n in this DAG equals classicalWeightScore(n, w) when n is smooth, and ∞ otherwise.
3. Use the tropical matrix-vector product as a single Bellman-Ford step, and iterated products as multi-step relaxation.
4. Prove formally that k iterations of tropical matrix-vector multiplication compute the k-hop shortest paths.

### Cross-Domain Connections
- **Graph algorithms**: Direct connection to Floyd-Warshall, Bellman-Ford, and Johnson's algorithm.
- **Dynamic programming**: The scoring DAG is a DP table; tropical matrix powers enumerate DP states.
- **Hardware**: APSP has highly optimized implementations on GPUs and FPGAs.

### Actionable Next Steps
- Formalize the factorization DAG and its path-weight correspondence.
- Prove the APSP-smoothness equivalence theorem.
- Benchmark tropical APSP implementations against classical sieve scoring.

---

## Direction 4: No-Go Theorems for Semiring-Linear Dependency Extraction

### Hypothesis
Beyond the idempotent-group triviality theorem (proved in this work), there exist sharper structural impossibility results:

1. **No nontrivial idempotent semiring with cancellation**: An idempotent semiring where a ⊕ b = a ⊕ c implies b = c is trivial. This would rule out even weaker forms of equation-solving in tropical settings.

2. **No tropical GF(2) analogue**: There is no nontrivial semiring S that is simultaneously idempotent and has exactly two elements with the field axioms of GF(2).

3. **Tropical rank deficiency**: The tropical rank of the exponent matrix (a well-studied concept in tropical linear algebra) does not coincide with the GF(2)-rank needed for the sieve's linear algebra stage, proving a rank-mismatch obstruction.

### Proof Strategy
1. Prove the cancellation result directly from idempotency: a ⊕ a = a and a ⊕ b = a ⊕ c gives a = a, so b = c only trivially.
2. For the GF(2) result, enumerate all two-element semirings and check that none are both idempotent and a field.
3. For tropical rank, construct explicit examples where tropical rank ≠ GF(2)-rank and prove that no faithful tropicalization of the rank can exist.

### Cross-Domain Connections
- **Tropical linear algebra**: Connects to the Gondran-Minoux theory of tropical matrices.
- **Matroid theory**: GF(2)-representable matroids vs. tropically representable matroids.
- **Complexity theory**: Structural barriers to semiring reductions between problems.

### Actionable Next Steps
- Formalize the cancellation impossibility theorem.
- Survey the tropical rank literature and identify formalizable results.
- Attempt to prove or disprove tropical-GF(2) rank agreement for random exponent matrices.

---

## Direction 5: Hardware-Realizable Tropical Cryptanalytic Kernels

### Hypothesis
A purpose-built min-plus systolic array can achieve higher throughput per watt than general-purpose CPUs for sieve relation scoring, due to the simplicity of the compare-and-add operations compared to general integer multiplication.

### Design
1. **Architecture**: A 2D systolic array where each processing element (PE) performs one comparison and one addition per clock cycle.
2. **Data flow**: Valuation matrix rows stream through the array; weight vector is broadcast. Each PE computes M(i,j) + w(j) and passes the running minimum to the right.
3. **Throughput**: For an array of width |FB|, one candidate is scored per clock cycle.

### Formal Verification Target
- Prove that the systolic array output matches tropicalMatVec for all inputs.
- Prove that the array completes R candidates in R + |FB| - 1 cycles (pipeline fill + drain).
- Formalize the gate count and prove it is O(|FB|) comparators + O(|FB|) adders.

### Cross-Domain Connections
- **VLSI design**: Systolic arrays are a well-understood architecture (Kung and Leiserson, 1979).
- **Neural network accelerators**: Modern TPUs use systolic arrays for matrix multiplication; the same silicon design methodology applies to min-plus arrays.
- **FPGA prototyping**: Min-plus operations map naturally to FPGA look-up tables and carry chains.

### Actionable Next Steps
- Design the systolic array architecture in RTL (Verilog/VHDL).
- Simulate with realistic sieve parameters (|FB| = 10000, R = 10^6).
- Compare throughput and power against CPU and GPU sieve implementations.
- Explore ASIC cost estimates for a dedicated tropical sieve chip.

---

## Cross-Cutting Research Themes

### Theme A: Tropical Cryptanalysis
Systematically investigate which stages of cryptanalytic algorithms (QS, NFS, lattice sieving, index calculus) admit tropical formulations, and whether the tropical formulation enables new attacks or defenses.

### Theme B: Semiring Complexity Theory
Develop a complexity theory for algebraic computations parameterized by the underlying semiring. Key question: what is the semiring-independent computational content of factoring?

### Theme C: Tropical Statistical Mechanics of Number Theory
Model the smooth-number distribution as a partition function in a statistical-mechanical system where primes are modes and valuations are occupancies. The tropical score is the ground-state energy. Investigate phase transitions as B varies.

### Theme D: Certified Program Transformations
Develop a framework for formally verifying that replacing ring arithmetic with semiring arithmetic preserves correctness for a specified class of inputs. The tropical-classical equivalence theorem is the first instance of such a certified transformation.

---

## Priority Ranking

| Priority | Direction | Estimated Effort | Expected Impact |
|----------|-----------|-----------------|-----------------|
| 1 | Tropical Entropy (Dir. 2) | Medium | High — new complexity measure |
| 2 | APSP Reduction (Dir. 3) | Medium | High — algorithmic transfer |
| 3 | No-Go Theorems (Dir. 4) | Low-Medium | High — structural boundaries |
| 4 | NFS Tropicalization (Dir. 1) | High | Very High — impacts RSA security |
| 5 | Hardware Kernels (Dir. 5) | High | Medium-High — practical impact |
