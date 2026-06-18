# Future Research Directions

## Synthesis

This research cycle established the mathematical foundations of **proof search dimension** — a continuous measure of theorem difficulty based on the fractal geometry of successful proof paths. The key discovery is the **Fractal Phase Transition Theorem**: the search dimension D = log(k)/log(b) provides a complete classification of proof difficulty with sharp transitions at D = 0 (deterministic) and D = 1 (trivial), and smooth interpolation between them. The **Entropy-Dimension Bridge** connects this geometric quantity to information theory, showing D equals the ratio of search entropy to full tree entropy.

The most promising cross-domain connection is between the search dimension framework and the **ValuationDepthMeasure** from the Catalog's p-adic computation theory (`Computation/PadicValuationDepth.lean`). Both frameworks define complexity measures on tree-structured computations — the search dimension measures the "width" of successful paths (horizontal complexity), while valuation depth measures the "depth" of required operations (vertical complexity). A unified framework could provide two-dimensional complexity measures (width × depth) capturing both aspects simultaneously. This connects to the **UltrametricProofLearning** framework (`Speculative/AutoResearch/Bridges/UltrametricProofLearning.lean`) which already studies geometric decay of proof search.

The highest breakthrough potential lies in **Direction 1 (Heterogeneous Search Dimension)**, because real proof searches have non-uniform branching — modeling this heterogeneity could transform the theoretical framework from a toy model into a practical difficulty predictor for AI theorem provers.

---

### Direction 1: Heterogeneous Search Dimension via Lyapunov Exponents

**Conjecture**: For a proof search tree where the branching factor b_i and survival count k_i vary at each depth level i, the search dimension equals the Lyapunov exponent:

D = lim_{d→∞} (1/d) · Σᵢ₌₁ᵈ log(kᵢ) / (1/d) · Σᵢ₌₁ᵈ log(bᵢ)

and this limit exists for "ergodic" proof systems where the (b_i, k_i) sequence is stationary.

**Test**: Define a `HeterogeneousSearchModel` with sequences (b_i, k_i) for i = 1,...,d. Prove that when all b_i = b and k_i = k, this reduces to the uniform search dimension D = log(k)/log(b). Then prove existence of the Lyapunov exponent under stationarity assumptions. Compute the heterogeneous dimension for 100 Mathlib proofs by recording the tactic branching factor at each step.

**Impact**: If true, this provides the first practical difficulty metric for real-world theorem proving. If false, it reveals fundamental obstacles to predicting proof difficulty from local branching statistics.

**Catalog References**: `Bridges/FractalProofSearch/Defs.lean` (SearchDimension), `Bridges/FractalProofSearch/Theorems.lean` (fractal_phase_transition), `Bridges/ProofSearchComplexity.lean` (ProofSearchInstance)

**Proof Strategy**: 
1. Define `HeterogeneousSearchModel` with `b k : Fin d → ℕ` 
2. Define heterogeneous dimension as `(Σ log kᵢ) / (Σ log bᵢ)`
3. Prove reduction to uniform case
4. Use Kingman's subadditive ergodic theorem (may need to build from scratch) for existence of the limit under stationarity

**Domain Bridges**: Fractal geometry ↔ Ergodic theory ↔ Proof complexity

**Lineage**: Builds on `SearchDimension`, `entropy_dimension_bridge`, and `fractal_phase_transition` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Quantum Speedup of Proof Search via Dimension Halving

**Conjecture**: Grover's quantum search algorithm effectively halves the search dimension: if D is the classical search dimension, then the quantum search dimension is D_Q = (1 + D)/2. In particular, the quantum speedup factor for proof search is b^{d(1-D)/2} — a quadratic speedup in terms of the difficulty exponent, not just the search space size.

**Test**: Define a `QuantumSearchDimension` that accounts for amplitude amplification over the successful path set. Prove that the quantum query complexity for finding a proof in a b-ary tree of depth d with k surviving branches per node is O(√(b/k))^d = b^{d(1-D)/2}. Verify computationally for small trees (b ≤ 10, d ≤ 8).

**Impact**: If true, this provides a precise characterization of how quantum computing affects theorem proving — not just a generic quadratic speedup, but a dimension-dependent improvement. If false, it reveals structural barriers to quantum-accelerated theorem proving.

**Catalog References**: `Bridges/FractalProofSearch/Defs.lean` (SearchDimension), `Bridges/QuantumClassicalBridge.lean`

**Proof Strategy**:
1. Define quantum search dimension D_Q
2. Prove D_Q = (1 + D)/2 using Grover iteration count analysis
3. Show the quantum phase transition occurs at D = 0 (quantum search is trivial for D = 0 classical problems — contradicting the classical case)
4. This asymmetry would be a novel result

**Domain Bridges**: Quantum computation ↔ Fractal geometry ↔ Proof complexity

**Lineage**: Builds on `SearchDimension` and `proofComplexityLandscape` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Proof Search and Idempotent Dimension

**Conjecture**: The search dimension has a natural tropical (min-plus) analogue: the *tropical search dimension* D_trop = min_i(k_i) / max_i(b_i) measures the bottleneck difficulty of proof search. For uniform models, D_trop = k/b = b^{D-1}. The tropical dimension is always ≤ the classical dimension, and equality holds iff the search is uniform.

**Test**: Define `TropicalSearchDimension` using min-plus algebra. Prove the inequality D_trop ≤ D. Construct explicit examples where D_trop < D (heterogeneous search with bottlenecks). Show that the gap D - D_trop measures the "bottleneck severity" of the proof search.

**Impact**: Connects proof search theory to the Catalog's extensive tropical geometry infrastructure, enabling tools from tropical algebraic geometry to analyze proof difficulty.

**Catalog References**: `Bridges/TropicalSemiring.lean`, `Bridges/TropicalInformationTheory.lean`, `Bridges/FractalProofSearch/Defs.lean`

**Proof Strategy**:
1. Define `TropicalSearchDimension` using `min` and `max` over branching sequences
2. Prove D_trop ≤ D via AM-GM type inequality on logs
3. Characterize equality case
4. Connect to existing tropical structures in the Catalog

**Domain Bridges**: Tropical geometry ↔ Proof complexity ↔ Information theory

**Lineage**: Builds on `SearchDimension` and `searchDim_mono` from this cycle, connects to tropical infrastructure in the Catalog.

**Ambition**: extension

---

### Direction 4: Search Dimension as a Proof Complexity Measure

**Conjecture**: The search dimension is polynomially related to traditional proof complexity measures. Specifically, for a proof system P with proof length function ℓ_P(T):

log(ℓ_P(T)) = Θ(d(T) · (1 - D(T)) · log(b))

where d(T) is the minimum proof depth. In particular, the search dimension D determines the exponent of proof length growth.

**Test**: For the resolution proof system, compute D for random 3-SAT instances near the satisfiability threshold. The conjecture predicts D ≈ 1 - c·log(n)/n where n is the number of variables, consistent with the known exponential lower bounds on resolution proof length for random 3-SAT.

**Impact**: Would bridge fractal geometry and proof complexity theory, two currently disconnected fields. Would provide geometric intuition for known proof complexity lower bounds.

**Catalog References**: `Bridges/ProofSearchComplexity.lean` (ProofSearchInstance, fundamental_proof_search_bound), `Bridges/FractalProofSearch/Theorems.lean` (log_search_cost)

**Proof Strategy**:
1. Formalize the connection between search dimension and proof length via the log_search_cost theorem
2. Prove that for resolution, the branching factor equals the clause width
3. Estimate k for random 3-SAT using probabilistic arguments
4. Derive the resolution lower bound from the dimension estimate

**Domain Bridges**: Proof complexity ↔ Fractal geometry ↔ Computational complexity

**Lineage**: Builds on `log_search_cost`, `info_content_decomposition`, and `fractal_phase_transition` from this cycle.

**Ambition**: extension

---

### Direction 5: Empirical Fractal Dimension of Mathlib

**Conjecture**: The distribution of search dimensions across Mathlib theorems follows a beta distribution Beta(α, β) with α ≈ 5 and β ≈ 1, concentrated near D = 1 with a long left tail. The mean dimension is ≈ 0.85, and theorems with D < 0.5 are rare (<5%) but correspond to the deepest mathematical results.

**Test**: Implement the Monte Carlo dimension estimation protocol from Section 4.3 of the research paper on 1000 Mathlib theorems. Fit the empirical distribution to parametric families. Correlate D with other complexity metrics (proof length, import depth, number of dependencies).

**Impact**: First large-scale empirical measurement of proof search geometry. Would validate or refute the universality conjecture D ≈ 1 - c/n, and provide a practical difficulty calibration for AI theorem proving.

**Catalog References**: `Bridges/FractalProofSearch/Theorems.lean` (universality_consequence), `Bridges/ProofSearchComplexity.lean`

**Proof Strategy**: This is primarily an empirical direction. The main formal contribution would be:
1. Formalize the beta distribution conjecture as a Lean statement about limits of empirical distributions
2. Prove that the Monte Carlo estimator converges to the true dimension (law of large numbers argument)
3. Use the convergence result to bound the sample size needed for reliable estimation

**Domain Bridges**: Statistics ↔ Proof complexity ↔ Machine learning

**Lineage**: Builds on all results from this cycle, especially the universality conjecture.

**Ambition**: extension
