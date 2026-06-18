# Future Directions: Tropical Perron–Frobenius for Certified Systems

## Research Roadmap

This document outlines 5 concrete breakthrough research directions opened by the formalization of tropical Perron–Frobenius theory for discrete-event systems.

---

## Direction 1: Certified Karp Algorithm for Maximum Cycle Mean

### Hypothesis
A formally verified implementation of Karp's O(n³) algorithm for computing the maximum cycle mean can be built on top of the existing tropical eigenpair framework, producing machine-checked throughput certificates for arbitrary finite systems.

### Proof Strategy
1. **Formalize walks and walk weights.** Define `Walk n k` as a function `Fin (k+1) → Fin n` with adjacency, and `walkWeight A w` as the sum of edge weights along the walk. Prove that `tropPow A k i j` equals the maximum weight of a length-k walk from j to i.

2. **Formalize Karp's formula.** Prove the classical identity:
   ```
   maxCycleMean A = max_i min_{0≤k<n} (D(n,i) - D(k,i)) / (n - k)
   ```
   where `D(k,i)` is the maximum weight walk of length k ending at i. This reduces the spectral problem to finite optimization.

3. **Connect to eigenpair.** Prove that the value produced by Karp's formula equals the eigenvalue of the tropical eigenpair from `exists_tropical_eigenpair_eq_maxCycleMean`.

4. **Executable extraction.** Use Lean's code generation to produce an executable certified algorithm.

### Cross-Domain Connections
- **Algorithmics**: First verified implementation of a classical graph optimization algorithm
- **Real-time systems**: Certified worst-case execution time bounds
- **Operations research**: Verified cycle time computation for scheduling

### Estimated Difficulty
Medium. The key challenge is formalizing the walk/path enumeration and connecting it to tropical matrix powers. The algebraic infrastructure is already in place.

---

## Direction 2: Min-Plus Duality and Certified Latency Bounds

### Hypothesis
The duality between max-plus (throughput) and min-plus (latency) tropical algebras can be formalized, yielding certified two-sided performance envelopes: throughput from max-plus, worst-case latency from min-plus.

### Proof Strategy
1. **Define min-plus operations.** `minPlusMatVec A x i = min_j (A i j + x j)` and the corresponding eigenpair theory.

2. **Prove duality.** For any matrix A, the min-plus eigenvalue of A equals the negative of the max-plus eigenvalue of -A. Formalize this as:
   ```lean
   theorem minplus_maxplus_duality :
     minPlusEigenvalue A = -maxPlusEigenvalue (-A)
   ```

3. **Performance envelopes.** Combine max-plus and min-plus analysis to produce two-sided bounds:
   ```
   k * λ_min + v_min ≤ x_k ≤ k * λ_max + v_max
   ```
   This gives both throughput guarantees and latency guarantees.

4. **Network calculus connection.** Show that the min-plus eigenpair corresponds to the service curve in network calculus, connecting to deterministic queueing theory.

### Cross-Domain Connections
- **Network calculus**: Formal service curves and arrival curves
- **Queueing theory**: Deterministic delay bounds for FIFO systems
- **Embedded systems**: Worst-case response time certification

### Estimated Difficulty
Medium-Low. The min-plus theory mirrors the max-plus theory almost exactly. The main work is the duality proof and the performance envelope theorem.

---

## Direction 3: Eventual Periodicity of Tropical Matrix Powers

### Hypothesis
For irreducible matrices over ℝ, tropical matrix powers become eventually periodic (after normalization by the eigenvalue): there exists T and p such that for all k ≥ T, `tropPow A (k+p) = p·λ + tropPow A k`. This is the tropical analogue of the Perron–Frobenius convergence theorem.

### Proof Strategy
1. **Normalize.** Define `B = A - λ·J` where J is the tropical identity and λ is the eigenvalue. Show that B has eigenvalue 0.

2. **Prove nilpotency on the critical graph complement.** On the non-critical part of the graph, the normalized matrix B is "tropically nilpotent" — its powers eventually reach -∞ (in extended tropical) or become dominated by the critical part.

3. **Prove periodicity on the critical graph.** The critical graph (edges achieving the eigenpair equation) has a well-defined cyclicity σ, and the powers restricted to the critical graph are periodic with period σ.

4. **Combine.** Show that for k ≥ (n-1)², `tropPow B k` depends only on k mod σ, giving eventual periodicity.

### Cross-Domain Connections
- **Dynamical systems**: Formal periodic orbit theory
- **Manufacturing**: Steady-state production rate certification
- **Automata theory**: Connection to counter automata periodicity

### Estimated Difficulty
High. This requires deep structural theory about the critical graph and its cyclicity. The key technical challenge is formalizing the partition into critical and non-critical components.

---

## Direction 4: Formal Comparison with Classical Perron–Frobenius

### Hypothesis
The tropical Perron–Frobenius theorem is a "degeneration" of the classical Perron–Frobenius theorem for nonneg real matrices, obtained by the logarithmic limit (Maslov dequantization). This can be formalized as a convergence theorem: the classical Perron root of `exp(A/ε)` converges to `exp(λ/ε)` as ε → 0.

### Proof Strategy
1. **State the classical PF theorem.** If A is an n×n nonneg irreducible matrix, it has a positive eigenvalue ρ(A) (the Perron root) with a positive eigenvector.

2. **Define the dequantization map.** For ε > 0, define `A_ε(i,j) = exp(A(i,j)/ε)` and show this is a positive matrix.

3. **Prove the tropical limit.** Show that `ε · log(ρ(A_ε)) → λ(A)` as ε → 0, where λ(A) is the tropical eigenvalue (max cycle mean).

4. **Connect eigenvectors.** Show that `ε · log(v_ε)` converges to the tropical eigenvector.

### Cross-Domain Connections
- **Statistical mechanics**: Tropical limit = zero-temperature limit
- **Optimization**: Log-sum-exp → max as temperature → 0
- **Machine learning**: Softmax → hardmax limiting behavior

### Estimated Difficulty
Very High. This requires both the classical Perron–Frobenius theorem (partially in Mathlib) and nontrivial analysis (limits, logarithms, matrix exponentials). However, even partial results (e.g., for 2×2 matrices) would be valuable.

---

## Direction 5: Integration with Timed Automata and Synchronous Dataflow

### Hypothesis
The tropical eigenpair framework can be extended to certify performance properties of timed automata and synchronous dataflow (SDF) graphs, providing a bridge between tropical algebra and formal methods for cyber-physical systems.

### Proof Strategy
1. **Formalize SDF graphs.** Define synchronous dataflow graphs as a type, with actors (nodes), channels (edges), production/consumption rates, and initial tokens.

2. **Reduction to tropical.** Prove that the throughput of a consistent SDF graph equals the maximum cycle mean of an associated tropical matrix, where the matrix encodes execution times and token ratios.

3. **Timed automata connection.** For a restricted class of timed automata (event graphs / marked graphs), prove that the minimum cycle time equals the tropical eigenvalue of the timing matrix.

4. **Compositional analysis.** Prove that series and parallel composition of event graphs corresponds to tropical matrix operations, enabling modular throughput certification.

### Cross-Domain Connections
- **VLSI design**: Certified throughput for hardware pipelines
- **Signal processing**: Verified streaming computation rates
- **Embedded systems**: Formal timing analysis for safety-critical software
- **Railway signaling**: Certified timetable feasibility

### Estimated Difficulty
High. The SDF/timed automata formalization is substantial, but the reduction to tropical matrices is well-established in the literature. A starting point would be to formalize the event graph → tropical matrix reduction for a concrete class of systems.

---

## Priority Ordering

1. **Direction 1** (Karp algorithm) — most immediately achievable, builds directly on current work
2. **Direction 2** (min-plus duality) — mirrors existing infrastructure, doubles the applicability
3. **Direction 5** (SDF integration) — highest practical impact for systems verification
4. **Direction 3** (eventual periodicity) — deepest mathematical content
5. **Direction 4** (classical comparison) — most theoretically ambitious, longest timeline

## Team Structure Recommendation

- **Core algebra team**: Directions 1, 2 — extend the tropical matrix library
- **Systems verification team**: Direction 5 — build the application bridge
- **Structural theory team**: Directions 3, 4 — deepen the mathematical foundations

Each direction should begin with a concrete 2×2 or 3×3 worked example before attempting the general case. The Collatz–Wielandt framework from the current work provides a unifying certification mechanism across all directions.
