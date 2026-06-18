# Future Research Directions

## Synthesis

This research cycle established a rigorous tropical spectral theory of directed graphs, providing 13 machine-verified theorems that form a coherent algebraic toolkit. The core achievement is the full algebraic foundation: min-plus matrix multiplication over `WithTop ℕ` is a monoid (identity + associativity), with power additivity (A^⊗(k+l) = A^⊗k ⊗ A^⊗l) as the key structural theorem. On this foundation, we built DAG vanishing (all positive moments are ⊤ for acyclic graphs), a linear lower bound on moments (μ_k ≥ k·w_min), weight monotonicity, and dense cycle forcing.

The most promising cross-domain connection is between **tropical spectral moments and renormalization group flow**. The existing Catalog work on coarse-graining stabilization (`Algebra/SpectralGraphTheory.lean`, Theorem `CoarseGrainChain.stabilizes`) guarantees that iterated quotient operations converge. Combined with our tropical moment monotonicity (Theorem `tropMoment_antitone_weight`), this suggests that tropical moments *also* stabilize under coarse-graining—providing a tropical analog of renormalization fixed points. The Catalog's tropical proof complexity work (`Physics/TropicalProofComplexity.lean`) provides a computational bridge: tropical spectral moments could serve as the complexity measure in proof-search bounds.

Direction 1 (Tropical Eigenvalue Theory) has the highest breakthrough potential because it would connect our moment-based invariants to a genuine eigenvalue theory—the tropical analog of the spectral theorem—opening the door to tropical analogs of Cheeger's inequality, expander characterizations, and mixing time bounds for directed graphs.

---

### Direction 1: Tropical Eigenvalue Theory for Directed Graphs

**Conjecture**: For a weighted directed graph G on n vertices with min-plus adjacency matrix A, define the *tropical eigenvalue* as λ_trop = lim_{k→∞} μ_k(G)/k, where μ_k is the k-th tropical spectral moment (minimum-weight closed walk of k edges). This limit exists and equals the minimum *cycle mean*: the minimum over all simple directed cycles C of (weight of C)/(length of C).

**Test**: 
1. Compute μ_k/k for k = 1, ..., 20 on random weighted directed graphs (n = 10, 50, 100) with edge weights drawn from Uniform({1,...,10}).
2. Independently compute the minimum cycle mean using Howard's algorithm.
3. Verify convergence: |μ_k/k - min cycle mean| → 0 as k → ∞.

**Impact**: If true, this establishes a tropical spectral theorem: a single scalar invariant (the tropical eigenvalue) governs the asymptotic behavior of all moments. This would enable tropical analogs of classical spectral bounds (Cheeger, Alon-Boppana) for directed graphs, which currently lack clean spectral theory.

**Catalog References**: `Shared/TropicalSpectralGraph/Theorems.lean` (tropical moments, lower bound), `Algebra/SpectralGraphTheory.lean` (classical walk counting), `Shared/Theorems.lean` (`tropical_power_monotone`)

**Proof Strategy**: 
1. Prove subadditivity: μ_{k+l} ≤ μ_k + μ_l (from walk composition).
2. Apply Fekete's lemma: subadditive sequences satisfy lim μ_k/k = inf μ_k/k.
3. Show inf μ_k/k equals the minimum cycle mean by constructing optimal cycles from optimal walks.
4. Key lemma: any walk of length ≥ n passes through a cycle, allowing extraction.

**Domain Bridges**: Tropical Algebra ↔ Spectral Graph Theory ↔ Optimization (min-cost cycle problems)

**Lineage**: Builds on `tropMoment_lower_bound` and `minPlusPow_add` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Cheeger Inequality

**Conjecture**: For a strongly connected weighted digraph G with tropical eigenvalue λ_trop and *tropical expansion* h_trop (defined as the minimum over all vertex subsets S of the total outgoing edge weight from S to V\S divided by |S|), there exist universal constants c₁, c₂ > 0 such that:
```
c₁ · h_trop ≤ λ_trop ≤ c₂ · h_trop²
```
This would be a tropical analog of the classical Cheeger inequality relating the spectral gap to edge expansion.

**Test**: Compute λ_trop and h_trop for:
1. Directed cycle graphs C_n (n = 5, 10, 20) with unit weights: expect λ_trop = 1, h_trop = 1.
2. Random d-regular digraphs: compare the ratio λ_trop/h_trop across instances.
3. Complete graphs K_n: expect both quantities to be O(1/n).

**Impact**: This would provide the first spectral-expansion equivalence for directed graphs via tropical methods, potentially resolving open questions about directed expander characterization.

**Catalog References**: `Shared/TropicalSpectralGraph/Theorems.lean`, `Algebra/ExtremalGraph/Theorems.lean` (`degree_energy_cauchy_schwarz`)

**Proof Strategy**: 
1. Define tropical expansion h_trop using min-plus edge weights.
2. Lower bound: Use the moment lower bound—high expansion forces all cycles through the cut, increasing cycle weight.
3. Upper bound: Construct an explicit short cycle from the expanding set witness.
4. May need tropical Cauchy-Schwarz inequality as an intermediate tool.

**Domain Bridges**: Tropical Algebra ↔ Combinatorics (Expander Graphs) ↔ Theoretical Computer Science (Derandomization)

**Lineage**: Extends `minPlusPow_lower_bound` and the dense cycle forcing theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Coarse-Graining Stability of Tropical Moments

**Conjecture**: For a weighted digraph G on n vertices and a partition P into m blocks, define the quotient graph Q = G/P with edge weight w_Q(a,b) = min_{i∈a, j∈b} w_G(i,j). Then the tropical moments satisfy:
```
μ_k(Q) ≤ μ_k(G)  for all k
```
Furthermore, iterated coarse-graining G = G₀ → G₁ → G₂ → ... produces a sequence of moments that stabilizes: ∃ K, ∀ k ≥ K, μ_k(G_j) = μ_k(G_{j+1}).

**Test**: 
1. Construct a random weighted digraph on n = 100 vertices.
2. Apply successive random balanced partitions: 100 → 50 → 25 → 12 → 6 → 3.
3. Track μ_2, μ_3, μ_4 through the sequence.
4. Verify monotonicity and eventual stabilization.

**Impact**: Would establish a tropical renormalization group for graph spectra, connecting to the Catalog's existing coarse-graining stabilization theorems and providing a bridge to statistical mechanics.

**Catalog References**: `Algebra/SpectralGraphTheory.lean` (`CoarseGrainChain.stabilizes`, `quotient_edge_bound`), `Shared/TropicalSpectralGraph/Theorems.lean` (`tropMoment_antitone_weight`)

**Proof Strategy**: 
1. Show that the quotient construction is weight-decreasing: w_Q(a,b) ≤ w_G(i,j) for appropriate (i,j).
2. Apply `tropMoment_antitone_weight` to get monotonicity.
3. Since tropical moments take values in WithTop ℕ and are bounded below by 0, a non-increasing sequence must stabilize.
4. The stabilization index K may depend on the initial graph's diameter.

**Domain Bridges**: Graph Theory ↔ Statistical Mechanics (Renormalization) ↔ Algebra (Quotient Structures)

**Lineage**: Directly combines `tropMoment_antitone_weight` with `CoarseGrainChain.stabilizes`.

**Ambition**: extension

---

### Direction 4: Tropical Spectral Gap and Mixing in Directed Markov Chains

**Conjecture**: For an ergodic directed graph G (strongly connected, aperiodic) with tropical eigenvalue λ_trop, define the *tropical mixing time* as T_mix = min{k : μ_k(G) < ∞ and (A^⊗k)_{ij} < ∞ for all i,j}. Then T_mix ≤ n/λ_trop when λ_trop > 0, providing a tropical analog of the spectral gap ↔ mixing time equivalence for Markov chains.

**Test**:
1. Compute T_mix and λ_trop for directed cycle graphs (expect T_mix = n, λ_trop = 1/n-like).
2. Compare with complete graphs (expect T_mix = 2, λ_trop = O(1)).
3. Test on Cayley graphs of small groups with various generating sets.

**Impact**: Would provide shortest-path-based mixing guarantees for directed processes, complementing the classical probabilistic approach.

**Catalog References**: `Shared/TropicalSpectralGraph/Theorems.lean`, `Computation/InfoEfficientAlgorithms.lean` (termination bounds)

**Proof Strategy**:
1. Use walk composition to relate T_mix to power structure.
2. Key inequality: if μ_k is finite, then A^⊗(nk) has all finite entries (by pigeonhole + composition).
3. Relate λ_trop to the rate at which min-plus powers fill in.

**Domain Bridges**: Tropical Algebra ↔ Probability (Markov Chains) ↔ Computation (Mixing Time)

**Lineage**: Extends `minPlusPow_add` and the DAG vanishing theorem.

**Ambition**: extension

---

### Direction 5: Computational Tropical Spectral Analysis of Mathlib

**Conjecture**: The dependency graph of Mathlib (as of v4.28.0), when augmented with unit-weight back-edges creating cycles, has tropical spectral moments μ_k that grow linearly in k with slope approximately equal to the average shortest-path distance. Furthermore, the moment growth rate is concentrated: for 90% of vertex pairs, the contribution to μ_k is within a factor of 2 of the mean.

**Test**:
1. Extract the Mathlib dependency DAG (≈100,000 nodes, ≈500,000 edges).
2. Augment with minimum back-edges: for each leaf node, add an edge back to its most distant ancestor with weight = path length.
3. Compute μ_2, ..., μ_10 using sparse min-plus matrix multiplication.
4. Fit a linear model μ_k ≈ α·k + β and measure R².
5. Compute the concentration: variance of per-vertex contributions to μ_k.

**Impact**: Would provide the first quantitative spectral analysis of a real mathematical knowledge base, potentially revealing structural properties of mathematical organization.

**Catalog References**: `Shared/TropicalSpectralGraph/Theorems.lean`, `Bridges/ProofSearchComplexity.lean` (`proof_length_counting_bound`)

**Proof Strategy**: Primarily computational; the mathematical content is in interpreting the results through the lens of the proved theorems (lower bounds, monotonicity, cycle forcing).

**Domain Bridges**: Graph Theory ↔ Mathematical Knowledge Management ↔ Data Science

**Lineage**: Applies all theorems from this cycle to concrete data.

**Ambition**: extension
