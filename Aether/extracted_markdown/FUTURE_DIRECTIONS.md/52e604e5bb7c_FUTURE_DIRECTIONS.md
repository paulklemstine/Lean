# Future Research Directions

## Synthesis

This research cycle established the Stratified Dependency Algebra (SDA) as a novel mathematical framework for studying the structure of proof systems. The central result — the Hub Monotonicity Theorem — proves that in any finite directed acyclic graph (proof system), the number of transitive dependents strictly decreases along every dependency edge. This creates a rigid hierarchy: foundational results (axioms) are always the most depended-upon nodes, and every step away from the foundations strictly reduces reach.

The most promising cross-domain connection is between this work and the existing proof complexity results in the Catalog (particularly `TropicalProofComplexity` and `ProofSearchInformation`). The Hub Monotonicity Theorem provides a *structural* constraint on proof DAGs that complements the *complexity-theoretic* constraints in those results. Specifically, the `theorem_proof_duality` result relates proof search effort to the number of provable theorems, while our Hub Score Sum Identity relates individual hub scores to the total transitive closure size — these two perspectives could be unified into a single information-theoretic framework.

The direction with the highest breakthrough potential is Direction 1 (Empirical Power Law Verification), because it would either confirm or definitively refute the conjecture that mathematical proof networks are scale-free. Our theoretical results provide the exact quantities to measure (hub scores, strata, reach sets), making the empirical test precise rather than vague.

---

### Direction 1: Empirical Power Law Structure of Mathlib's Proof DAG

**Conjecture**: The hub score distribution of the Mathlib proof DAG (all ~150,000 declarations and their transitive dependencies) follows a power law P(k) ~ k^{-γ} with γ ∈ [2.0, 3.0].

**Test**: Extract the full dependency graph from Mathlib's `.olean` files or `lake env` output. For each declaration, compute the hub score (number of transitive dependents). Plot the complementary CDF on log-log axes. Fit a power law using the Clauset-Shalizi-Newman maximum likelihood method. Report the fitted γ and the p-value from the Kolmogorov-Smirnov goodness-of-fit test. If p < 0.1, the power law hypothesis is rejected.

**Impact**: If confirmed (γ ≈ 2.5), this would establish that mathematical proof networks share the scale-free property with biological networks, the internet, and social networks — suggesting a universal organizing principle. If refuted, this would show that proof networks have a fundamentally different topology, potentially log-normal or exponential, which would itself be informative about how mathematical knowledge grows.

**Catalog References**: `Physics/ProofDAG.lean` (hub score definitions and theorems), `Physics/ProofSearchInformation.lean` (theorem_proof_duality), `Physics/TropicalProofComplexity.lean` (tropical_proof_length_conjecture_special_case)

**Proof Strategy**: This is primarily computational, not proof-based. Write a Python/Lean script to:
1. Parse Mathlib's dependency graph from build artifacts.
2. Compute hub scores via BFS/DFS from each node.
3. Apply the Clauset-Shalizi-Newman fitting method (available in the `powerlaw` Python package).
4. Visualize results.

**Domain Bridges**: Physics (scale-free networks) <-> Computation (proof complexity) <-> EML (information-theoretic bounds)

**Lineage**: Builds on the Hub Score Monotonicity Theorem and Hub Score Sum Identity from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Fragility-Hub Duality and Critical Theorems

**Conjecture**: In any connected finite DAG with n ≥ 10 nodes, the maximum fragility (number of nodes made unreachable by removing a single hub) is at least √n. Equivalently, every sufficiently large proof system has a "critical theorem" whose removal invalidates at least √n other theorems.

**Test**: Construct random DAGs (Erdős-Rényi conditioned on acyclicity, preferential attachment DAGs, lattice DAGs) with n = 100, 1000, 10000. For each, compute the maximum fragility and check whether it exceeds √n. Also test on the actual Mathlib dependency graph.

**Impact**: If true, this would formalize the intuition that mathematics is inherently fragile — no proof system can distribute dependencies so evenly that removing any single theorem causes only minor damage. If false, it would mean "robust" proof systems exist, which would have implications for the design of fault-tolerant formal mathematics libraries.

**Catalog References**: `Physics/ProofDAG.lean` (fragility definitions, fragility'_le_hubScore), `FINAL/Pythagorean/HardnessLocalization.lean` (not_isAcyclic_of_connected_many_edges)

**Proof Strategy**: Formalize the fragility lower bound by:
1. Proving that in a connected DAG, the hub with maximum hub score h_max has fragility ≥ h_max - d_out(hub), where d_out is its out-degree.
2. Proving that h_max ≥ √n for connected DAGs (this requires showing that the transitive closure has ≥ n edges in a connected DAG, then using the Hub Score Sum Identity).
3. Combining these bounds.

**Domain Bridges**: Computation (fault tolerance) <-> Physics (fragility/robustness) <-> Cryptography (dependency analysis)

**Lineage**: Builds on fragility'_le_hubScore and hubScore_strict_mono from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Weighted Hub Scores and Proof Complexity

**Conjecture**: Define the *weighted hub score* hw(v) = Σ_{w ∈ R(v)} c(w), where c(w) is the proof complexity (length) of w. Then the weighted hub monotonicity theorem still holds: if E(u,v), then hw(v) < hw(u), provided c is strictly positive.

**Test**: Formalize weighted hub scores in Lean 4 and prove the weighted monotonicity theorem. Then compute weighted hub scores on the Mathlib dependency graph using proof term sizes as weights.

**Impact**: Weighted hub scores capture not just how many theorems depend on a result, but how *hard* those theorems are. A theorem that supports many easy corollaries might have a lower weighted hub score than one supporting fewer but harder results. This gives a more nuanced measure of "mathematical importance."

**Catalog References**: `Physics/ProofDAG.lean` (hub score theory), `Physics/TropicalProofComplexity.lean` (proof length bounds)

**Proof Strategy**: Extend the reachSet theory to carry weights. The key lemma is that R(v) ⊂ R(u) still holds when E(u,v), so the weighted sum over R(v) is strictly less than the weighted sum over R(u) (since the missing element v has positive weight).

**Domain Bridges**: Computation (proof complexity) <-> Physics (weighted networks)

**Lineage**: Direct extension of hubScore_strict_mono from this cycle.

**Ambition**: extension

---

### Direction 4: Categorical Structure of DAG Morphisms

**Conjecture**: The category **FinDAG** (finite DAGs as objects, DAG homomorphisms as morphisms) has finite products and coproducts. Moreover, the hub score function defines a functor from **FinDAG** to the poset category (ℕ, ≤).

**Test**: Formalize the category of finite DAGs in Lean 4. Show that:
1. The product G₁ × G₂ is the categorical product (with vertex set α₁ × α₂ and edge (a₁,a₂) → (b₁,b₂) iff E₁(a₁,b₁) ∧ E₂(a₂,b₂)).
2. The coproduct is the disjoint union (already partially formalized as sumDAG).
3. Hub score is functorial (preserves the ordering structure).

**Impact**: Establishing the categorical structure of proof DAGs would connect this work to the rich theory of categories and functors, potentially enabling tools like adjunctions and limits to study proof organization.

**Catalog References**: `Physics/ProofDAG.lean` (sumDAG, singletonDAG), `Bridges/SymplecticCertificateAlgebra.lean` (algebraic structures)

**Proof Strategy**: 
1. Define DAG homomorphisms f : G₁ → G₂ as functions preserving edges.
2. Verify the identity and composition axioms.
3. Construct products and coproducts explicitly.
4. Show hub score is monotone under surjective homomorphisms.

**Domain Bridges**: Algebra (category theory) <-> Physics (proof DAGs) <-> Logic (proof transformations)

**Lineage**: Builds on the algebraic structure (singletonDAG, sumDAG) from this cycle.

**Ambition**: extension

---

### Direction 5: Information-Theoretic Lower Bounds on DAG Depth

**Conjecture**: Any finite DAG with n nodes and transitive closure size T has depth at least log₂(T/n). Equivalently, no "shallow" proof system can have a dense transitive closure.

**Test**: Formalize this bound in Lean 4. Check computationally on random DAGs and on the Mathlib dependency graph.

**Impact**: This would provide an information-theoretic lower bound on proof depth — the minimum number of "layers of reasoning" needed to achieve a given level of interconnection. It would complement the existing proof length lower bounds in the Catalog.

**Catalog References**: `Physics/ProofDAG.lean` (transitiveClosureSize, Hub Score Sum Identity), `Physics/ProofSearchInformation.lean` (theorem_proof_duality), `Physics/TropicalProofComplexity.lean` (proof length bounds)

**Proof Strategy**: 
1. In a stratified DAG with depth d, each node at stratum k can reach at most n_{k+1} + n_{k+2} + ... + n_d nodes, where n_j is the width at stratum j.
2. By the Hub Score Sum Identity, T = Σ h(v).
3. Using the arithmetic-geometric mean inequality and the constraint Σ n_j = n, derive T ≤ n · d · (n/d), giving d ≥ T/n².
4. A tighter bound using the exponential growth of reachability in dense DAGs should yield d ≥ log₂(T/n).

**Domain Bridges**: Computation (complexity theory) <-> Physics (information bounds) <-> EML (entropy of mathematical structures)

**Lineage**: Builds on Hub Score Sum Identity and stratum theory from this cycle.

**Ambition**: extension
