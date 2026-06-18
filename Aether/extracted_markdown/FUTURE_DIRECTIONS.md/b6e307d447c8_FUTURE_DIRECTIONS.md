# Future Directions: Tropical Spectral Theory

## 1. Karp Formula Formalization

**Theorem Statement:**
For an irreducible matrix `W : Matrix (Fin n) (Fin n) ℝ`,
$$\rho_{\mathrm{trop}}(W) = \lim_{k \to \infty} \max_i \frac{W^{\otimes k}_{ii}}{k}$$
where $W^{\otimes k}$ denotes the $k$-fold tropical matrix power (max-plus product).

**Proof Strategy:**
- Define tropical matrix power iteratively: $(W^{\otimes k})_{ij} = \max_{\text{walks of length } k} \sum W_{i_t i_{t+1}}$.
- Show the sequence $\max_i W^{\otimes k}_{ii} / k$ is eventually periodic (by pigeonhole on vertex sequences).
- Prove convergence to the maximum cycle mean using the walk decomposition lemmas already formalized.
- Leverage `walkWt_split` and `bestWalk_n_le_potential` from the current project.

**Cross-Domain Impact:**
- Provides a certified algorithm for computing tropical spectral radius via matrix powering.
- Connects to mean-payoff game value iteration and scheduling algorithms.
- Enables formal verification of convergence bounds in discrete-event simulation.

---

## 2. Tropical Eigenvector Existence

**Theorem Statement:**
If $W$ is irreducible (the directed graph of $W$ is strongly connected), then there exists $x : \text{Fin}\ n \to \mathbb{R}$ such that
$$\forall i,\ (W \otimes x)_i = x_i + \rho_{\mathrm{trop}}(W).$$

**Proof Strategy:**
- Use the potential construction from the current work as a starting point.
- Under irreducibility, the potential achieves equality on at least one critical cycle.
- Formalize the notion of critical graph (edges where equality holds in $W_{ij} + x_j = x_i + \lambda$).
- Prove that normalizing the potential by subtracting the minimum yields an eigenvector.
- Key lemma: in an irreducible graph with all cycle means $\leq \lambda$, there exists a cycle with mean exactly $\lambda$.

**Cross-Domain Impact:**
- Eigenvectors are steady-state synchronization vectors in timed event graphs.
- Connects to Howard's policy iteration algorithm for mean-payoff games.
- Foundation for tropical convexity and tropical linear algebra geometry.

---

## 3. Mean-Payoff Game Bridge

**Theorem Statement:**
For a two-player zero-sum mean-payoff game with vertices $V = V_{\max} \sqcup V_{\min}$ and edge weights $w$, the game value satisfies a min-max Collatz–Wielandt principle:
$$\mathrm{val}(v) = \min_{y} \max_{i} \frac{\text{cycle weight under strategy } y}{k}$$

**Proof Strategy:**
- Generalize the Bellman operator from $T(x)_i = \max_j (A_{ij} + x_j)$ to the Shapley operator $S(x)_i = \max_j (A_{ij} + x_j)$ for max-vertices and $S(x)_i = \min_j (A_{ij} + x_j)$ for min-vertices.
- Prove a two-sided Collatz–Wielandt bound: the game value lies between the max-player's and min-player's optimal cycle means.
- Formalize positional determinacy as a consequence.
- Use the walk decomposition framework, generalized to alternating optimization.

**Cross-Domain Impact:**
- Certified verification of game-solving algorithms (Zwick-Paterson, strategy iteration).
- Formal foundation for reactive synthesis and model checking with quantitative objectives.
- Connection to tropical semiring duality and min-max algebra.

---

## 4. Certified Scheduling Duality

**Theorem Statement:**
A system of difference constraints $x_j - x_i \leq c_{ij}$ for $(i,j) \in E$ is feasible if and only if every directed cycle in $(V, E)$ has non-negative total $c$-weight.

**Proof Strategy:**
- This is exactly the "hard direction" of our Collatz–Wielandt theorem, restated for general weighted digraphs (not necessarily complete).
- Generalize the potential construction to sparse graphs: define $x_i$ via shortest-path distances from a root vertex.
- Formalize Bellman–Ford's algorithm as the constructive witness.
- Prove correctness: if no negative cycle exists, Bellman–Ford terminates and produces a feasible assignment.
- Key challenge: formalizing the negative-cycle detection step.

**Cross-Domain Impact:**
- Certified optimization for job-shop scheduling and project planning (CPM/PERT).
- Formal verification of timing analysis in digital circuits (static timing analysis).
- Foundation for SMT solving over difference logic (certified certificates).

---

## 5. Tropical Neural Operators and Spectral Bounds

**Theorem Statement (Conjecture):**
For a composition of tropical linear maps $T_k(x)_i = \max_j (W^{(k)}_{ij} + x_j)$, the asymptotic growth rate of $T_K \circ \cdots \circ T_1(0)$ is bounded by the maximum of the individual tropical spectral radii:
$$\limsup_{K \to \infty} \frac{\|T_K \circ \cdots \circ T_1(0)\|_\infty}{K} \leq \max_k \rho_{\mathrm{trop}}(W^{(k)}).$$

**Proof Strategy:**
- Use the Collatz–Wielandt characterization to bound each layer's growth.
- Formalize the composition of order-preserving additively homogeneous maps.
- Prove a submultiplicativity property for tropical operator norms.
- Connect to the joint spectral radius in the tropical setting.
- Investigate whether the `relu_preserves_tropical_max` pattern from the existing catalog extends to deep compositions.

**Cross-Domain Impact:**
- Certified robustness bounds for tropical (ReLU-based) neural networks.
- Connection between tropical geometry and deep learning expressivity.
- Foundation for tropical optimization in machine learning pipelines.
- Opens a program toward tropical Krein–Rutman theory for nonlinear operators.

---

## Research Team Directive

Each direction above represents a 2–4 week research sprint. The recommended approach:

1. **Week 1:** Formalize definitions and state theorems with `sorry`. Verify the skeleton compiles.
2. **Week 2:** Prove the key lemmas using the decomposition strategy. Test with `#eval` on small examples.
3. **Week 3:** Complete all proofs and verify with `#print axioms`. Clean up and document.
4. **Week 4:** Write applications, connect to existing Mathlib infrastructure, and prepare for upstreaming.

Cross-pollination between directions is essential: the walk decomposition framework (walkWt, walkVert, walkWt_split) built in this project is reusable across all five directions. The potential construction generalizes directly to directions 1, 2, and 4.
