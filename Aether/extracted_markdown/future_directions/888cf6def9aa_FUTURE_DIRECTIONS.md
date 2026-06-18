# Future Directions: Proof DAGs and Mathematical Network Science

## Synthesis

This research cycle established a rigorous formal foundation for studying mathematical proofs as directed acyclic graphs. The eleven verified theorems span three mathematical domains — graph theory, order theory, and network science — and reveal that the structure of mathematical knowledge is governed by the same power-law hub dynamics found in scale-free networks. The most promising cross-domain connection is between the DAG edge bound (Theorem 2) and the HardnessLocalization catalog's `not_isAcyclic_of_connected_many_edges`: together, they establish that the boundary between DAG and non-DAG is exactly the n(n−1)/2 edge threshold, and crossing this threshold corresponds to the emergence of "proof cycles" (circular reasoning).

The power law hub dominance theorem (Theorem 10) is the deepest result of this cycle, connecting the degree distribution of proof DAGs to the fragility analysis of scale-free networks. This theorem is the shadow of a broader phenomenon: in any system where new elements preferentially attach to existing hubs (preferential attachment), the resulting network has a power-law degree distribution and is vulnerable to targeted hub removal. The next cycle should investigate whether Mathlib's actual dependency graph exhibits this structure empirically, and whether the theoretical bounds are tight.

The highest breakthrough potential lies in Direction 1 (Dilworth-DAG Bridge), which would connect proof DAG width to classical combinatorial optimization, and Direction 2 (Empirical Mathlib Analysis), which would ground the theoretical results in real data.

---

### Direction 1: Dilworth-DAG Bridge — Minimum Chain Covers and Proof Parallelism

**Conjecture**: In the proof DAG of any finite mathematical library, the minimum number of "proof chains" (totally ordered subsets) needed to cover all theorems equals the maximum number of mutually independent theorems (maximum antichain). This is Dilworth's theorem applied to the reachability partial order of the proof DAG. Furthermore, for Mathlib-scale libraries, the maximum antichain size grows as Θ(n / log n), where n is the number of declarations.

**Test**: (1) Formalize Dilworth's theorem for finite partial orders in Lean 4 (it exists in some form in Mathlib — verify and extend). (2) Apply it to the dagToPartialOrder construction from this cycle. (3) Extract the actual dependency DAG from Mathlib and compute the maximum antichain using König's theorem and bipartite matching.

**Impact**: If true, this gives a precise measure of the "parallelism" of mathematical knowledge — how many independent theorems can be proved simultaneously. The Θ(n / log n) growth rate would mean that parallelism scales almost linearly with library size, suggesting that mathematical knowledge is "wide" rather than "deep." If false, the failure would reveal unexpected structural constraints on proof dependencies.

**Catalog References**: `Catalog/Computation/ProofDAG.lean` (dagToPartialOrder, antichain_size_le_card), `Catalog/Pythagorean/HardnessLocalization.lean` (not_isAcyclic_of_connected_many_edges)

**Proof Strategy**: (1) Verify that Mathlib has `Finpartition.card_parts_le_card` or similar Dilworth formalization. (2) If not, formalize Dilworth's theorem via the standard induction proof: decompose by removing a maximal antichain, then apply induction. (3) Connect to dagToPartialOrder via the `le_antisymm` property. (4) For the empirical bound, extract Mathlib's declaration graph using `lake env printPaths` and custom tooling.

**Domain Bridges**: Order Theory ↔ Graph Theory ↔ Parallel Computation (Dilworth's theorem is equivalent to König's theorem for bipartite graphs, which connects to matching theory and scheduling)

**Lineage**: Builds on dagToPartialOrder and antichain_size_le_card from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Empirical Power Law Analysis of Mathlib's Dependency Graph

**Conjecture**: The in-degree distribution of Mathlib's dependency DAG follows a power law P(k) ~ k^{−γ} with γ ∈ [2.0, 3.0], and the top 10 hub declarations account for more than 30% of all transitive dependencies. Furthermore, removing any single top-10 hub renders more than 5% of all declarations unreachable from the remaining axioms.

**Test**: (1) Extract Mathlib's full declaration dependency graph (approximately 200,000 nodes, 2,000,000 edges). (2) Compute the in-degree distribution and fit a power law using the Clauset-Shalizi-Newman method. (3) Identify the top-10 hubs. (4) For each hub, compute the set of transitively dependent declarations. (5) Perform the Kolmogorov-Smirnov goodness-of-fit test for the power law hypothesis.

**Impact**: This would be the first rigorous empirical test of the "mathematics as scale-free network" hypothesis. A confirmed power law would validate the fragility analysis and suggest that mathematical knowledge has the same vulnerability profile as the internet. A failed power law (e.g., log-normal or exponential distribution) would be equally informative, suggesting that proof dependencies are more democratic than network science predicts.

**Catalog References**: `Catalog/Computation/ProofDAG.lean` (power_law_max_degree_bound, exists_hub_by_pigeonhole)

**Proof Strategy**: This is primarily computational. (1) Use `lake env printPaths` or parse `.olean` files to extract the dependency graph. (2) Implement the CSN power law fitting in Python. (3) Compare γ to the theoretical predictions. (4) The Lean component would formalize any discovered structural properties (e.g., "the top hub is `propext`" or "the dependency DAG has diameter ≤ 20").

**Domain Bridges**: Network Science ↔ Mathematical Logic ↔ Library Science (the degree distribution of Mathlib parallels citation network analysis in bibliometrics)

**Lineage**: Builds on power_law_max_degree_bound from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Weighted Proof DAGs and Information-Theoretic Depth

**Conjecture**: Define the *information-theoretic depth* of a theorem T as the minimum total proof length (in bits) along any path from axioms to T in the proof DAG. Then the distribution of information-theoretic depths follows a log-normal distribution, not a power law, and the "deepest" theorem in Mathlib (maximum IT-depth) is in the analytic number theory or algebraic geometry sections.

**Test**: (1) Formalize weighted DAGs where each edge carries a weight (proof length). (2) Define IT-depth as the shortest weighted path from any source. (3) Prove that IT-depth is well-defined and computable in O(V + E) time. (4) Apply to Mathlib by using proof term size as edge weights.

**Impact**: IT-depth measures how much "accumulated knowledge" is needed to reach a theorem. Unlike simple graph distance, it accounts for proof difficulty. A log-normal distribution would suggest that proof difficulty compounds multiplicatively (each step multiplies the effort), while a power law would suggest additive compounding.

**Catalog References**: `Catalog/Computation/ProofDAG.lean` (all theorems), `Catalog/Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: (1) Extend FinDigraph with edge weights: `weight : V → V → ℕ`. (2) Define depth as `depth(v) = min over paths p from source to v of ∑ weight(e) for e in p`. (3) Prove existence and uniqueness via Bellman-Ford on DAGs (no negative edges). (4) Connect to the existing depth concept (unweighted case = all weights 1).

**Domain Bridges**: Information Theory ↔ Graph Theory ↔ Proof Complexity (IT-depth is analogous to Kolmogorov complexity for proofs)

**Lineage**: Extends the DAG layering and depth concepts from this cycle.

**Ambition**: extension

---

### Direction 4: Preferential Attachment Model for Growing Proof Libraries

**Conjecture**: The growth of mathematical libraries follows a preferential attachment process: when a new theorem is added, the probability that it depends on existing theorem T is proportional to T's current in-degree plus a constant α. Under this model, the resulting DAG has in-degree distribution P(k) ~ k^{−(2 + α)} for large k, and the optimal α for Mathlib is approximately 0.5 (giving γ ≈ 2.5).

**Test**: (1) Formalize the preferential attachment DAG model in Lean 4. (2) Prove that the expected degree distribution converges to a power law with the predicted exponent. (3) Simulate the model in Python and compare to Mathlib's actual growth history (using git commit timestamps).

**Impact**: If true, this would explain *why* mathematical knowledge has a power-law structure: it's because mathematicians naturally build on well-known results (preferential attachment). The fitted α would measure how much mathematicians favor "famous" theorems over "obscure" ones.

**Catalog References**: `Catalog/Computation/ProofDAG.lean` (power_law_max_degree_bound), `Catalog/Computation/OpenQuestionsResearch.lean` (mlc_power_law)

**Proof Strategy**: (1) Define the preferential attachment process as a stochastic sequence of FinDigraphs. (2) The expected degree distribution is known analytically — formalize the mean-field derivation. (3) The key lemma is that ∑_{t=1}^{T} 1/(t + α) ~ ln T, giving the power-law tail. (4) Compare predicted γ to empirical γ from Direction 2.

**Domain Bridges**: Probability Theory ↔ Network Science ↔ History of Mathematics (preferential attachment models the "Matthew effect" in mathematical reputation)

**Lineage**: Builds on power_law_max_degree_bound and extends the scale-free network analysis.

**Ambition**: extension

---

### Direction 5: Proof DAG Robustness Certificates

**Conjecture**: For any theorem T in a proof DAG G, define the *robustness* r(T) as the minimum number of hub vertices that must be removed to make T unreachable from all axioms. Then for most theorems in Mathlib, r(T) = 1 (fragile), but there exists a "robust core" of approximately 1% of theorems with r(T) ≥ 3 (resilient). The robust core consists primarily of basic logic and set theory.

**Test**: (1) Formalize robustness as a vertex connectivity measure in the proof DAG. (2) Prove that r(T) ≤ min(in-degree(T), number of axioms). (3) Prove that r(T) = 1 for any theorem whose proof uses exactly one hub. (4) Compute r(T) for all theorems in a moderate-sized sub-library.

**Impact**: Robustness certificates identify which parts of mathematics are "safe" and which are "fragile." A mostly-fragile library would motivate the development of alternative proof paths, analogous to redundant routing in communication networks.

**Catalog References**: `Catalog/Computation/ProofDAG.lean` (removeVertex_isDAG, dependent_count_ge_outDegree), `Catalog/Computation/SensitivityConjecture.lean` (large_subset_has_neighbor)

**Proof Strategy**: (1) Define r(T) as the minimum vertex cut between the source set and T. (2) Use Menger's theorem to relate r(T) to the maximum number of vertex-disjoint paths from sources to T. (3) The upper bound r(T) ≤ in-degree(T) follows from the cut characterization. (4) For the empirical analysis, use maximum flow algorithms.

**Domain Bridges**: Network Reliability ↔ Graph Theory ↔ Proof Theory (vertex connectivity in proof DAGs parallels fault tolerance in communication networks and redundancy in logical systems)

**Lineage**: Builds on removeVertex_isDAG and dependent_count_ge_outDegree from this cycle.

**Ambition**: extension
