# Future Directions: Tropical Spectral Complexity Theory

## Structured Roadmap for Breakthrough Research

---

## Direction 1: Tropical Eigenvalues and Cycle Means for Finite Matrices

### Precise Theorem Target

Formalize the **tropical eigenvalue** of a finite n×n matrix M over ℝ (or ℕ∞) as:

$$\lambda^{\text{trop}}(M) = \min_{k=1}^{n} \min_{\text{cycles } C \text{ of length } k} \frac{\text{weight}(C)}{k}$$

Prove: for any matrix M encoding a transition system with T steps of computation, the tropical eigenvalue provides a lower bound on the amortized cost per step:

$$\lambda^{\text{trop}}(M) \leq \text{totalCost}(T) / T$$

### Why It Matters

The current work uses the minimum edge weight as a spectral-gap surrogate. True tropical eigenvalues (minimum cycle means) are strictly more informative: they capture the long-run average cost of cyclic behavior, which is exactly what determines the efficiency of iterated computations. This would upgrade the bridge from a single-step cost bound to a multi-step amortized bound.

### Builds On

- **Theorem 3.4** (pathCost_ge_minWeight_mul): The minimum edge weight bound is a single-step version. Tropical eigenvalues generalize this to cycles.
- **Definition of IsLayered**: For acyclic matrices, the tropical eigenvalue is +∞ (no cycles), so this direction primarily targets non-layered matrices encoding cyclic computations.

### Proof Strategy

1. Define `CycleMean M k C` for a cycle C of length k in M.
2. Define `tropicalEigenvalue M` as the infimum over all cycle means.
3. Prove the amortized cost theorem by decomposing any T-step path into cycle segments plus a remainder of length < n.
4. Use the existing `pathCost_ge_minWeight_mul` as the base case for the acyclic remainder.

### Cross-Domain Connections

- Max-plus control theory (Baccelli et al., 1992) uses tropical eigenvalues to analyze discrete-event systems.
- Scheduling theory uses cycle means to determine throughput of cyclic production systems.
- Dynamical systems theory uses Lyapunov exponents, of which tropical eigenvalues are a discrete analogue.

---

## Direction 2: Min-Plus Permanent as a Branching Program Complexity Measure

### Precise Theorem Target

Define a branching program matrix `M_BP : Matrix (Fin n) (Fin n) ℕ` where:
- Rows represent source states, columns represent target states
- M(i,j) = cost of the transition from state i to state j
- The matrix is NOT layered (branching programs allow backward edges)

Prove: if `minPlusPerm(M_BP) ≥ f(n)` for a super-linear function f, then any branching program computing the function encoded by M_BP requires width ≥ g(f(n)) for an explicit function g.

### Why It Matters

For non-layered matrices, the min-plus permanent is non-trivially positive, making it a meaningful complexity measure. Branching programs are equivalent to space-bounded computation (Barrington 1989), so permanent lower bounds would translate to space lower bounds. This is exactly the regime where the tropical bridge becomes powerful: the permanent captures the "assignment complexity" of the transition structure.

### Builds On

- **Theorem 3.9** (minPlusPerm_eq_zero_of_layered): Shows layered matrices have zero permanent. The contrapositive implies non-layered matrices (which include branching programs with backward edges) can have positive permanent.
- **Theorem 3.7** (minPlusPerm_le_trace): Provides upper bounds on the permanent, constraining the search space.

### Proof Strategy

1. Model a branching program of width w as a w×w transition matrix.
2. Show that the min-plus permanent of k composed transition matrices equals the min-plus permanent of their tropical matrix product.
3. Prove that high tropical permanent of the composed matrix implies many distinct transitions, hence large width.
4. Use the Hungarian algorithm to compute permanents efficiently for verification.

### Cross-Domain Connections

- Barrington's theorem (1989) connects bounded-width branching programs to NC¹.
- The assignment problem (permanent computation) connects to matching theory.
- Communication complexity lower bounds use similar matrix-rank arguments.

---

## Direction 3: Tropical Spectral Gap and Expansion-Based Lower Bounds

### Precise Theorem Target

Define the **tropical spectral gap** for a matrix M as:

$$\gamma^{\text{trop}}(M) = \lambda_2^{\text{trop}}(M) - \lambda_1^{\text{trop}}(M)$$

where λ₁ and λ₂ are the two smallest tropical eigenvalues (minimum and second-minimum cycle means).

Prove: if γ_trop(M) ≥ γ > 0, then any matrix C that "simulates" M in fewer than ⌈γ⌉ layers satisfies a structural impossibility condition.

### Why It Matters

In classical spectral theory, a large spectral gap implies rapid mixing and good expansion. The tropical analogue should imply that the cost landscape has well-separated strata, preventing shallow circuits from reproducing the matrix's behavior. This is the most direct tropical analogue of expansion-based lower bounds (used extensively in communication complexity and streaming lower bounds).

### Builds On

- **Theorem 3.6** (tropical_bridge_path_cost): The current bridge uses minimum edge weight as a gap surrogate. A true spectral gap would be a more refined and powerful invariant.
- **Spectral gap surrogates** defined in the current formalization: the difference between minimum off-diagonal and minimum diagonal entries.

### Proof Strategy

1. Define tropical eigenvalues via the tropical characteristic polynomial or cycle mean formulation.
2. Prove that the spectral gap controls the "information propagation speed" in tropical matrix powers.
3. Show that k iterations of the tropical operator T_M(x)_i = min_j(M(i,j) + x_j) contract the value vector by at most a factor related to the spectral gap.
4. Deduce that reproducing the full contraction in fewer than ⌈γ⌉ steps is impossible.

### Cross-Domain Connections

- Expander graph theory (Hoory-Linial-Wigderson 2006) uses classical spectral gaps for lower bounds.
- Tropical semigroup theory (Gaubert-Katz 2007) studies contraction rates of tropical linear operators.
- Markov chain mixing time theory provides structural analogues.

---

## Direction 4: Certified Explicit Families with Superlinear Depth

### Precise Theorem Target

Construct an explicit family of n×n matrices F(n) such that:
1. F(n) encodes a natural computational problem (e.g., sorting, element distinctness, or a graph property)
2. The tropical permanent or spectral gap of F(n) grows super-linearly in n
3. The bridge theorem (or its extensions) certifies that depth(F(n)) ≥ ω(n)

### Why It Matters

The current results prove linear depth bounds (depth ≤ n − 1) for general layered matrices. An explicit family with certified super-linear depth would be a genuine complexity-theoretic result, comparable to known lower bounds for restricted models. The tropical framework would provide the *proof methodology*, not just the statement.

### Builds On

- **Theorem 3.10** (family_depth_cost_tradeoff): Shows that growing minimum weight forces growing path costs. To get super-linear depth, we need matrices where the growing weight interacts with the depth structure in a multiplicative rather than additive way.
- **Algorithm 1** (depth computation): Provides efficient verification of depth for specific matrix families.

### Proof Strategy

1. Define F(n) using a combinatorial construction (e.g., based on error-correcting codes, expander graphs, or number-theoretic functions).
2. Prove that the minimum edge weight of F(n) grows with n (e.g., as Θ(log n) or Θ(n^ε)).
3. Prove that the graph structure of F(n) forces paths of length Ω(n) (e.g., by connectivity arguments).
4. Combine: depth ≥ Ω(n) and path cost ≥ Ω(n · log n), yielding a certified super-linear cost bound.
5. If the cost budget is externally bounded (e.g., by the problem's information content), derive depth ≥ ω(n).

### Cross-Domain Connections

- Explicit expander constructions (Lubotzky-Phillips-Sarnak 1988, Margulis 1988).
- Coding theory bounds (Singleton, Hamming, Plotkin bounds on code parameters).
- Ramsey theory for explicit combinatorial lower bounds.

---

## Direction 5: Tropical Geometry of Circuit Polytopes

### Precise Theorem Target

Define the **tropical circuit polytope** of an n×n matrix M as:

$$P^{\text{trop}}(M) = \{x \in \mathbb{R}^n : T_M(x) = x\}$$

where T_M is the tropical linear operator T_M(x)_i = min_j(M(i,j) + x_j).

Prove: the dimension of the tropical circuit polytope provides a lower bound on the circuit depth needed to compute the min-plus matrix-vector product defined by M.

### Why It Matters

This connects tropical *geometry* (not just algebra) to circuit complexity. The tropical polytope captures the "fixed-point structure" of the operator, which encodes the steady-state behavior of the computation. Low-dimensional polytopes correspond to "simple" computations with few degrees of freedom; high-dimensional polytopes correspond to "complex" computations requiring many sequential steps to reach equilibrium.

### Builds On

- **All current theorems**: The path-cost bounds and layered structure results provide the algebraic foundation. The geometric direction adds a topological/dimensional perspective.
- **Tropical geometry literature** (Develin-Sturmfels 2004, Joswig 2021): Provides the mathematical framework for tropical polytopes and their combinatorics.

### Proof Strategy

1. Define the tropical operator T_M and its fixed-point set in Lean.
2. Prove that the dimension of the fixed-point set (as a tropical polytope) is bounded by the number of distinct eigenvalues of M.
3. Relate the number of eigenvalues to the cycle structure of the support graph.
4. Show that computing T_M^k (k-fold iteration) in fewer than k layers requires the circuit to "compress" the polytope, which is impossible when the dimension exceeds the depth.

### Cross-Domain Connections

- Tropical convexity (Develin-Sturmfels 2004) provides the geometric framework.
- Polyhedral combinatorics connects to integer programming and optimization complexity.
- Fixed-point theory (Tarski, Knaster-Tarski) provides structural results about iterative computations.
- The Bellman equation in dynamic programming is a tropical fixed-point equation.

---

## Summary Table

| Direction | Key Invariant | Target Result | Difficulty | Impact |
|-----------|--------------|---------------|------------|--------|
| 1. Tropical Eigenvalues | Cycle mean | Amortized cost bounds | Medium | High — enables iterated computation analysis |
| 2. Branching Programs | Min-plus permanent | Space lower bounds | High | Very High — connects to P vs. PSPACE |
| 3. Spectral Gap | Tropical gap | Expansion-based depth bounds | High | Very High — tropical analogue of spectral methods |
| 4. Explicit Families | Growing weight | Superlinear depth certification | Medium-High | High — first explicit tropical lower bound |
| 5. Circuit Polytopes | Polytope dimension | Geometric depth bounds | Very High | Transformative — new geometric complexity theory |

---

## Team Directive

Create a research team with the following roles:

1. **Tropical Algebraist**: Formalize tropical eigenvalue theory (Direction 1) and spectral gap definitions (Direction 3) in Lean.
2. **Complexity Theorist**: Design explicit matrix families (Direction 4) and model branching programs (Direction 2).
3. **Tropical Geometer**: Develop the polytope theory (Direction 5) and connect to existing tropical geometry literature.
4. **Formal Verification Specialist**: Maintain the Lean codebase, verify new theorems, and optimize proof automation.
5. **Algorithm Designer**: Implement efficient algorithms for tropical invariant computation and benchmarking.

**Iteration cycle**: Each team member proposes 2-3 concrete lemmas per week, verified in Lean. Monthly synthesis meetings identify cross-connections and redirect effort toward the most promising avenue.

**Success metrics**:
- Directions 1, 4: achievable within 3-6 months
- Directions 2, 3: achievable within 6-12 months
- Direction 5: 12-24 month horizon, with partial results along the way

**Hypothesis validation**: Before investing in any direction, test the key hypothesis with concrete 5×5 to 10×10 matrix computations. Use the Python algorithms to verify that the proposed invariant actually grows as predicted for explicit families.
