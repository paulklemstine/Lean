# Future Research Directions

## Synthesis

This research cycle established a rigorous spectral theory of directed graphs for studying theorem dependency networks. We formalized walk counting algebra (the matrix-power recursion and composition theorem), proved DAG-specific spectral vanishing and walk-length bounds, developed degree variance as a hub-detection invariant with Cauchy-Schwarz foundations, and proved coarse-graining stabilization via well-ordering of ℕ. The 14 theorems proved (all machine-checked, sorry-free) form a coherent toolkit: walk counts provide the spectral data, degree variance detects structural asymmetry, quotient graphs implement coarse-graining, and the stabilization theorem guarantees convergence.

The most promising cross-domain connection is between **renormalization fixed points** and **proof network structure**. The stabilization theorem for coarse-graining chains is structurally identical to the existence of RG fixed points in statistical mechanics. The Catalog's existing work on tropical spectral theory (`Tropical/SpectralTheory.lean`, `Tropical/RenormalizationFlow.lean`) and EML complexity measures (`EML/AdvancedTheory.lean`) provide natural bridges: tropical eigenvalues could replace classical eigenvalues in the spectral moment framework, while EML complexity could provide a content-aware alternative to purely structural walk counts. Direction 1 (Tropical Spectral Moments) has the highest breakthrough potential because it connects three previously independent Catalog threads and leverages the min-plus algebra structure for faster computation.

---

### Direction 1: Tropical Spectral Moments of Dependency Graphs

**Conjecture**: For a directed graph G on n vertices with edge weights w(i,j) ∈ ℝ≥0, define the *tropical adjacency matrix* T where T(i,j) = w(i,j) under min-plus algebra (⊕ = min, ⊗ = +). The tropical spectral moments μ^trop_k = (1/n) · tr⊕(T^⊗k), where T^⊗k is the k-th min-plus matrix power and tr⊕ is the tropical trace (minimum of diagonal entries), satisfy: (i) μ^trop_k equals the minimum-weight closed walk of length k divided by n; (ii) for DAGs, the tropical walk of length k from i to j equals the minimum-cost path of exactly k edges; (iii) the tropical spectral distance d^trop_K satisfies the triangle inequality and defines a proper metric on weighted graphs.

**Test**: Compute tropical spectral moments for random DAGs on 50-200 vertices with edge weights drawn from Exp(1). Compare the tropical spectral distance between DAGs from different degree distributions (Erdős-Rényi vs. power-law) to the classical spectral distance. If tropical distances are more discriminating (have larger dynamic range), they are a better invariant.

**Impact**: If the tropical spectral framework is richer than the classical one, it provides a natural bridge between the min-plus algebra (deeply developed in the Catalog's tropical geometry work) and graph spectral theory. The tropical moments are also faster to compute (min-plus matrix multiplication avoids overflow issues). If the tropical spectral distance fails to be a metric, it identifies a fundamental obstruction in min-plus spectral theory.

**Catalog References**: `Tropical/SpectralTheory.lean`, `Tropical/MinPlusSpectral.lean`, `Tropical/RenormalizationFlow.lean`

**Proof Strategy**: (1) Define tropical walk count via min-plus matrix power recursion, mirroring `DGraph.walkCount`. (2) Prove the tropical composition theorem T^{k+l} = T^k ⊗ T^l by induction on l, analogous to `walkCount_add`. (3) For the DAG case, use topological ordering to show the minimum-weight walk of length k is the minimum over all length-k paths. (4) For the metric property, prove the triangle inequality by composing walks: d(G₁, G₃) ≤ d(G₁, G₂) + d(G₂, G₃) via subadditivity of the max-of-differences.

**Domain Bridges**: Tropical geometry ↔ Spectral graph theory ↔ Proof network analysis

**Lineage**: Builds on `DGraph.walkCount`, `DGraph.walkCount_add`, `DGraph.spectralDistance_symm` from this cycle, and tropical spectral theory from the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Degree Entropy Monotonicity Under Coarse-Graining

**Conjecture**: Define the *degree entropy* of a directed graph G on n vertices as H(G) = -Σ_i (d_i / E) · log(d_i / E), where d_i = outDeg(i) and E = Σ d_i is the total edge count. For any partition P that merges vertices within the same SCC, the quotient graph satisfies H(quotient(G, P)) ≤ H(G). That is, coarse-graining never increases degree entropy. The inequality is strict whenever the partition merges vertices with different out-degrees.

**Test**: Compute degree entropy for random graphs on 100 vertices under 10 rounds of SCC-based coarse-graining. Track the entropy sequence. If monotonicity holds for 10,000 random instances, the conjecture is strongly supported. A single counterexample (entropy increasing after coarse-graining) refutes it.

**Impact**: If true, degree entropy provides a Lyapunov function for the coarse-graining dynamics, analogous to the c-theorem in 2D conformal field theory (which says the central charge decreases under RG flow). This would be the first rigorous "c-theorem analog" for proof networks. If false, it identifies when coarse-graining creates artifactual hub structure.

**Catalog References**: `EML/AdvancedTheory.lean` (ensemble complexity as entropy-like measure), `Bridges/RenormalizationUniversality.lean`

**Proof Strategy**: (1) Define degree entropy formally over ℚ (using rational logarithm approximations or working in ℝ). (2) Express the quotient degree distribution as a function of the original: d'_b = |{(i,j) : blockOf(i)=b, blockOf(j)≠b, adj(i,j)}|. (3) Show by log-sum inequality that merging two vertices with degrees d₁, d₂ into one with degree d₁+d₂-overlap produces entropy decrease. (4) The strict inequality follows from strict convexity of x·log(x).

**Domain Bridges**: Information theory ↔ Graph coarse-graining ↔ Statistical mechanics (c-theorem)

**Lineage**: Builds on `DGraph.degreeVariance_nonneg`, `DGraph.quotient_edge_bound`, `CoarseGrainChain.stabilizes` from this cycle.

**Ambition**: extension

---

### Direction 3: Spectral Gap of DAG Normalized Laplacians

**Conjecture**: For a DAG G on n vertices with maximum out-degree Δ, define the normalized Laplacian L = I - D^{-1/2} A D^{-1/2} (where D is the diagonal degree matrix, with convention D^{-1/2}_{ii} = 0 when d_i = 0). The smallest nonzero eigenvalue λ₁(L) — the *spectral gap* — satisfies λ₁(L) ≥ 1/n. Moreover, the spectral gap is achieved (λ₁ = 1/n) if and only if G is a path graph (total order on n vertices).

**Test**: Compute the spectral gap numerically for all DAGs on n = 5, 6, 7 vertices (exhaustive enumeration feasible up to n ≈ 8). Check whether 1/n is a tight lower bound and which graphs achieve it.

**Impact**: A spectral gap lower bound for DAG Laplacians would provide quantitative mixing-time estimates for random walks on proof dependencies. The characterization of the extremal case (path = total order) would connect to proof complexity: a "linear" theory (where each theorem depends on exactly one predecessor) has the smallest spectral gap, meaning information propagates most slowly.

**Catalog References**: `Computation/PadicValuationDepth.lean` (depth measures), `Algebra/AlgebraicCircuitComplexity.lean` (depth lower bounds)

**Proof Strategy**: (1) Define the DAG normalized Laplacian in Lean using Mathlib's matrix API. (2) Show that all eigenvalues of L lie in [0, 2] (standard for normalized Laplacians). (3) For the lower bound, use the Cheeger inequality for directed graphs: λ₁ ≥ h²/(2Δ) where h is the edge expansion. (4) Show that DAGs have expansion ≥ 1/n (each cut separating source from sink must have at least one edge, and the graph has n vertices). (5) For the extremal characterization, show that the path graph achieves h = 1/n and equality in Cheeger.

**Domain Bridges**: Spectral graph theory ↔ Proof complexity ↔ Algebraic circuit complexity

**Lineage**: Builds on `DGraph.dag_no_closed_walks`, `DGraph.dag_walk_length_bound`, `DGraph.degreeVariance_eq_zero_iff_regular` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Walk-Based Complexity Measures for Formal Proofs

**Conjecture**: Define the *walk complexity* of a theorem T in a dependency graph G as W(T) = Σ_{k=1}^{n-1} walkCount(k, T, ·) / k!, where the sum is over all walk lengths and the factorial normalization ensures convergence. Then W(T) satisfies: (i) W(T) ≥ outDeg(T) with equality iff T has no transitive dependencies; (ii) W(T) ≤ e^{outDeg(T)} (exponential bound from walk composition); (iii) the ratio W(T)/outDeg(T) measures the "depth contribution" of T, distinguishing deep theorems (high ratio) from shallow ones (ratio ≈ 1).

**Test**: Compute W(T) for theorems in a real formal library. Correlate with existing proof complexity measures (proof length, tactic count). If W captures structural complexity beyond simple dependency counting, it's a novel and useful invariant.

**Impact**: Current proof complexity measures (number of lines, tactic count, etc.) are syntactic and don't capture logical depth. Walk complexity is purely structural and graph-theoretic. If it correlates with human intuitions of "deep" vs. "shallow" theorems, it provides a content-independent measure of mathematical importance.

**Catalog References**: `EML/AdvancedTheory.lean` (ensemble complexity), `Computation/PadicValuationDepth.lean` (depth measures)

**Proof Strategy**: (1) Define walk complexity using the existing `walkCount` infrastructure. (2) For bound (i), note that walkCount(1, T, j) = adjNat(T, j), and all higher-order walks are non-negative. (3) For bound (ii), use the walk composition theorem and bound each walkCount(k, T, j) ≤ Δ^k, giving W(T) ≤ Σ Δ^k/k! ≤ e^Δ. (4) For the depth interpretation, analyze path graphs vs. wide graphs.

**Domain Bridges**: Graph theory ↔ Proof complexity ↔ EML complexity theory

**Lineage**: Builds on `DGraph.walkCount_add`, `DGraph.dag_walk_length_bound`, `DGraph.sum_outDeg_eq_edgeCount` from this cycle.

**Ambition**: extension

---

### Direction 5: Categorical Coarse-Graining Functors

**Conjecture**: The coarse-graining operation defines a functor F : DGraph → DGraph (where DGraph is the category of directed graphs with graph homomorphisms) satisfying: (i) F is an endofunctor; (ii) F ∘ F ∘ ... ∘ F stabilizes in finitely many iterations (already proved for vertex count); (iii) the fixed points of F form a full subcategory equivalent to the category of finite partially ordered sets; (iv) the spectral moments define a natural transformation from the coarse-graining functor to a sequence functor, making the spectral universality conjecture a statement about the image of this natural transformation.

**Test**: Formalize the category of finite directed graphs in Lean using Mathlib's category theory library. Verify that the quotient-graph construction respects morphisms (functoriality). Check whether the fixed-point category is indeed equivalent to finite posets by examining all fixed points of the SCC coarse-graining on graphs with ≤ 8 vertices.

**Impact**: A categorical formulation would unify the ad-hoc constructions (quotient graphs, partitions, walk counts) into a coherent framework. The natural transformation interpretation of spectral moments would make universality a consequence of naturality — a much deeper structural insight than the current analytic formulation.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean` (closure systems as categorical structures), `EML/KolmogorovArnoldEMLDeep.lean` (chain operations)

**Proof Strategy**: (1) Use Mathlib's `CategoryTheory` library to define the category of DGraphs. (2) Show that `quotientGraph` is a morphism (preserves adjacency in the appropriate sense). (3) Show functoriality: quotient of quotient equals quotient of composed partition. (4) Characterize fixed points: G is a fixed point iff every SCC is a single vertex, iff G is a DAG, iff G is a partial order (with the transitive closure). (5) For the natural transformation, show that spectral moment computation commutes with coarse-graining up to controllable error.

**Domain Bridges**: Category theory ↔ Graph theory ↔ Renormalization physics ↔ Order theory

**Lineage**: Builds on `quotientGraph`, `CoarseGrainChain.stabilizes`, and the full walk counting algebra from this cycle.

**Ambition**: grand_challenge
