# Future Directions: Tropical Causal Optimization Research Roadmap

## Breakthrough Opportunities (ranked by impact)

### 1. Tropical Bellman-Ford Convergence in Exactly n-1 Steps for DAGs

**Theorem Statement**: For any `TropicalWeightedDAG n` with non-negative edge weights and source vertex `src`, `bellmanFordIterate G src (n-1)` is a fixed point of `bellmanFordStep G`, i.e., `bellmanFordStep G (bellmanFordIterate G src (n-1)) = bellmanFordIterate G src (n-1)`.

**Proof Strategy**:
1. Induction on topological order: process vertices in order of increasing rank
2. Show that after k steps, all vertices with rank ≤ k have correct distances
3. Use the non-negative weight condition to prevent negative-cost shortcuts
4. Key lemma: `bellmanFord_correct_at_rank` — after k steps, vertex with rank k has final distance

**Why This Is Revolutionary**: Provides a verified polynomial-time bound for causal identification. Connects DAG acyclicity (no negative cycles) to algorithmic convergence, bridging graph theory and fixed-point theory.

**Catalog Leverage**: Build on `bellmanFord_iterate_mono`, `bellmanFord_source_le_zero`, `fixedPoint_triangle`

**Research Mode**: prove

**Estimated Depth**: 4

---

### 2. Tropical Matrix Multiplication Associativity

**Theorem Statement**: `tropMinPlusMul (tropMinPlusMul A B) C = tropMinPlusMul A (tropMinPlusMul B C)` for all `A B C : Fin n → Fin n → TropicalCost`.

**Proof Strategy**:
1. Reduce to pointwise statement using `ext`
2. Show both sides equal `inf_{j,k} (A[i,j] + B[j,k] + C[k,l])`
3. Use distributivity of + over min and commutativity of inf
4. Key lemma: interchange of two `Finset.inf` with `tropPlus`

**Why This Is Revolutionary**: Establishes that tropical matrices form a semiring, enabling algebraic manipulation of shortest-path computations. This is the foundation for tropical linear algebra over DAGs.

**Catalog Leverage**: Build on `tropPlus_min_distrib_left`, `tropMinPlusMul`

**Research Mode**: prove

**Estimated Depth**: 3

---

### 3. Tropical Shortest Path = Kleene Star (DAG Completeness)

**Theorem Statement**: For a `TropicalWeightedDAG n`, `tropKleeneStar G.weight X Y` equals the true shortest-path distance from X to Y. Moreover, `tropMatPow G.weight k X Y = ⊤` for all `k ≥ n`.

**Proof Strategy**:
1. Paths in a DAG on n vertices have length < n (by topological ordering)
2. `tropMatPow M k` for k ≥ n must give ⊤ for non-diagonal entries
3. Induction on k, using the fact that any k-hop path must visit k+1 distinct vertices
4. Pigeonhole: k ≥ n implies some vertex is repeated, contradicting acyclicity

**Why This Is Revolutionary**: Proves the truncated Kleene star is exact for DAGs, not just an approximation. This means O(n⁴) all-pairs shortest paths with verified correctness.

**Catalog Leverage**: Build on `tropKleeneStar`, `tropMatPow`, `TropicalWeightedDAG.rank_edge`

**Research Mode**: prove

**Estimated Depth**: 4

---

### 4. Tropical Intervention Duality: do-Calculus Rules as Tropical Identities

**Theorem Statement**: Pearl's three rules of do-calculus correspond to identities in tropical matrix algebra:
- Rule 1 (Insertion/deletion of observations) ↔ tropical matrix conditioning
- Rule 2 (Action/observation exchange) ↔ tropical matrix row/column operations
- Rule 3 (Insertion/deletion of actions) ↔ tropical matrix submatrix extraction

**Proof Strategy**:
1. Formalize each rule as a tropical matrix identity
2. Prove each identity using the tropical semiring laws
3. Show completeness: any sequence of do-calculus derivations corresponds to a tropical matrix computation

**Why This Is Revolutionary**: Provides an algebraic foundation for do-calculus, replacing the graph-theoretic formulation with matrix algebra. This could lead to new do-calculus rules discoverable by matrix computation.

**Catalog Leverage**: Build on `interventionDAG`, `TropicalDSeparated`, `tropMinPlusMul`

**Research Mode**: formalize

**Estimated Depth**: 5

---

### 5. Tropical ReLU Neural Networks as Causal Models

**Theorem Statement**: A ReLU neural network with n neurons computes a tropical polynomial. The tropical semiring structure of the network defines a causal DAG where layer connections are causal edges with tropical weights equal to the neural network weights.

**Proof Strategy**:
1. Show ReLU(x) = max(0, x) is a tropical polynomial operation
2. Composition of ReLU layers = tropical matrix multiplication
3. The resulting causal DAG has topological ordering from the layer structure
4. d-separation in the tropical DAG = feature independence in the network

**Why This Is Revolutionary**: Bridges neural network interpretability with causal inference. Every trained ReLU network implicitly defines a causal model, and the causal structure can be read off from the tropical geometry.

**Catalog Leverage**: Build on `TropicalWeightedDAG`, `tropMinPlusMul`, existing tropical neural network formalization in `Catalog/Tropical/NeuralNetworks/`

**Research Mode**: formalize

**Estimated Depth**: 5

---

### 6. Quantum Tropical Causal Inference via Maslov Dequantization

**Theorem Statement**: The tropical causal framework is the ℏ → 0 limit of a quantum causal framework. Specifically, replacing min with log-sum-exp (soft-min) gives a "quantum" causal model that converges to the tropical model as temperature → 0.

**Proof Strategy**:
1. Define `softMin_τ(a,b) = -τ · log(exp(-a/τ) + exp(-b/τ))`
2. Show `lim_{τ→0} softMin_τ(a,b) = min(a,b)`
3. Define quantum causal effect as the soft-min shortest path
4. Prove convergence of quantum effects to tropical effects

**Why This Is Revolutionary**: Creates a smooth (differentiable) version of causal inference that can be trained with gradient descent, while the limiting tropical version provides exact combinatorial answers.

**Catalog Leverage**: Build on `Catalog/Tropical/QuantumTropicalComputation.lean`, tropical semiring foundations

**Research Mode**: formalize

**Estimated Depth**: 4

---

### 7. Tropical Causal Robustness Certificates for Adversarial ML

**Theorem Statement**: For a tropical causal model with Lipschitz constant L (= minimum finite causal strength), any ε-perturbation of inputs produces at most (L+ε)-perturbation of outputs. This provides a formal certified robustness guarantee.

**Proof Strategy**:
1. Define Lipschitz constant as minimum finite entry of tropical Kleene star
2. Show that edge weight perturbation ε changes shortest paths by at most n·ε
3. Apply to causal models: perturbation of interventions has bounded effect
4. Connect to certified robustness literature

**Why This Is Revolutionary**: Provides the first formal connection between tropical geometry and adversarial robustness. Tropical shortest-path distances become Lipschitz constants for causal models.

**Catalog Leverage**: Build on `CausalRobustness`, `tropicalCausalStrength`, `robustness_monotone`

**Research Mode**: prove

**Estimated Depth**: 3

## Under-explored Territory

### Tropical Causal Discovery from Data
The current formalization assumes the DAG structure is known. Extending to **learning** the DAG from observational data (tropical score-based structure learning) is wide open.

### Tropical Counterfactuals
Counterfactual reasoning ("what would have happened if...") in the tropical semiring could provide efficient algorithms for computing counterfactual costs.

### Tropical Causal Fairness
Defining fairness constraints as tropical path cost constraints could yield polynomial-time algorithms for fair causal inference.

## Cross-Domain Bridges

### Tropical Geometry ↔ Persistent Homology
Tropical Kleene star computation is related to persistence modules. The tropical shortest-path distance could define a new persistence metric for topological data analysis.

### Tropical Causality ↔ Information Theory
The tropical semiring is the "zero-temperature" limit of the log-sum-exp semiring used in information theory. Causal information flow could be quantified tropically.

### Tropical Optimization ↔ Lattice Cryptography
Tropical matrix problems (shortest vector in tropical lattices) connect to lattice-based cryptography. Post-quantum secure causal proofs may be achievable.

## Open Problems Encountered

1. **Bellman-Ford exact convergence**: We proved monotonicity but not exact convergence in n-1 steps. This requires a careful induction on topological order.

2. **Tropical matrix associativity**: Not proven in this cycle. The proof requires interchanging two infima, which needs careful handling of WithTop ℝ lattice operations.

3. **Optimal intervention NP-hardness**: Finding the minimum-cost *subset* of variables to intervene on (when the subset must satisfy a constraint) may be NP-hard. We haven't formalized this lower bound.

4. **Tropical d-separation completeness**: We haven't proven that tropical d-separation captures *all* conditional independencies implied by the DAG — only that it captures path-based ones.
