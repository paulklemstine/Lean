# Future Research Directions: Spectral Renormalization of Proof Graphs

## Synthesis

This research cycle established the mathematical foundations for a spectral theory of proof graphs. We defined proof graphs, coarse-graining operations, renormalization flows, and universality classes, then proved key structural theorems: edge monotonicity under coarsening, spectral ratio boundedness, flow stabilization, the pseudo-metric structure of universality classes, and geometric spectral gap decay with vanishing. Computational experiments demonstrated that different random graph families produce distinguishable spectral signatures under renormalization, with intra-family distances consistently smaller than inter-family distances.

The most promising cross-domain connection from this cycle is the bridge between **spectral graph theory** and **proof complexity theory**. The spectral gap of a proof graph's Laplacian provides a natural, computable lower bound on proof length — analogous to the mixing time bound for random walks. This connects the combinatorial structure of proofs to algebraic invariants in a way that could yield new proof complexity lower bounds, complementing existing circuit-complexity and resolution-based approaches.

The highest breakthrough potential lies in Direction 1 (canonical coarsening), because the current random coarsening introduces significant noise that limits the discriminative power of the renormalization flow. A deterministic, spectrally-motivated coarsening scheme would dramatically sharpen the universality signal and potentially make the conjecture provable for specific theory families.

---

### Direction 1: Spectral Clustering as Canonical Coarsening

**Conjecture**: For any proof graph G with Laplacian L and Fiedler vector v₂ (eigenvector for λ₁), the coarse-graining induced by thresholding v₂ at its median produces a renormalization flow whose spectral ratio converges faster (in number of coarsening steps) than any random surjective coarsening, and the limiting spectral data is independent of the threshold value within a neighborhood of the median.

**Test**: Construct proof graphs for propositional logic fragments (e.g., resolution refutations of random 3-SAT instances at the satisfiability threshold). Compare the renormalization flows produced by (a) random surjective coarsening, (b) Fiedler-vector median cut, and (c) k-means clustering in the spectral embedding. Measure convergence rate of spectral ratios and inter-trial variance. The conjecture is refuted if Fiedler-based coarsening has higher variance or slower convergence than random coarsening.

**Impact**: A canonical coarsening would eliminate the largest source of noise in the current framework. If the limiting spectral data is genuinely coarsening-independent, it would constitute a computable invariant of the proof graph that could be used as a complexity measure for formal theories.

**Catalog References**: `Speculative/AutoResearch/SpectralRenormalization/Theorems.lean` (edge_count_coarsen_le, flow_size_stabilizes), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: 
1. Define the Fiedler coarsening formally as a specific CoarseGraining instance.
2. Prove that Fiedler coarsening minimizes the Rayleigh quotient of the coarsened graph's Laplacian (this follows from the Courant-Fischer characterization of eigenvalues).
3. Show that optimal coarsening with respect to the Rayleigh quotient produces the maximal spectral ratio in the quotient graph.
4. Use the pseudo-metric structure (Theorem 3.7) to bound the distance between flows produced by different coarsenings.

**Domain Bridges**: Spectral graph theory <-> Proof complexity <-> Optimization (spectral clustering)

**Lineage**: Builds on edge_count_coarsen_le and flow_size_stabilizes from this cycle. Extends the random coarsening experiments to deterministic schemes.

**Ambition**: grand_challenge

---

### Direction 2: Proof-Length Exponents from Spectral Decay Rates

**Conjecture**: For a formal theory T with proof graph G_T, if the spectral gap under canonical renormalization decays as λ₁(k) ~ C · r^k with contraction rate r, then for "generic" families of statements {φₙ} of syntactic length n, the shortest proof of φₙ has length L(φₙ) = Θ(n^α) where α = -1/log₂(r). In particular, theories with r close to 1 have near-linear proof lengths, while theories with small r have polynomial but high-exponent proof lengths.

**Test**: 
1. Compute contraction rates r for (a) propositional resolution, (b) equational logic of groups, (c) Presburger arithmetic fragments.
2. For each theory, select benchmark families: tautologies for propositional logic, word problems for groups, linear arithmetic statements for Presburger.
3. Measure actual proof lengths and fit power laws L(n) ~ n^α.
4. Compare predicted α = -1/log₂(r) with measured exponents.
The conjecture is refuted if the predicted exponents differ from measured ones by more than a factor of 2, or if the relationship is non-monotone.

**Impact**: This would provide the first *a priori* complexity predictor for proof search based purely on spectral data — without examining individual statements. It would transform automated theorem proving by enabling complexity-aware proof search strategies.

**Catalog References**: `Speculative/AutoResearch/SpectralRenormalization/Theorems.lean` (proof_complexity_spectral_bound, spectral_gap_vanishes), `Computation/PadicValuationDepth.lean`

**Proof Strategy**:
1. Formalize the connection between spectral gap and random walk mixing time (Cheeger's inequality for directed graphs).
2. Prove that mixing time provides a lower bound on derivation length between spectrally separated vertices.
3. Connect the renormalization contraction rate to the mixing time at each scale via the decay bound (Theorem 3.8).
4. Derive the power law exponent from the multi-scale mixing time hierarchy.

**Domain Bridges**: Proof complexity <-> Random walks <-> Statistical physics (critical exponents)

**Lineage**: Builds on proof_complexity_spectral_bound and spectral_gap_vanishes from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Spectral Wasserstein Distance Between Theories

**Conjecture**: Define the spectral distance between two theories T₁, T₂ as the Wasserstein-1 distance between the normalized eigenvalue distributions of their proof graph Laplacians at a fixed complexity bound N. This distance is a metric on the space of theories (up to bi-interpretability), and theories that are "close" in this metric admit efficient inter-translations: if d_W(T₁, T₂) < ε, then any proof of length L in T₁ can be translated to a proof of length O(L/ε) in T₂.

**Test**: 
1. Compute eigenvalue distributions for propositional logic with different rule sets (e.g., resolution vs. Frege systems).
2. Compute Wasserstein distances between these distributions.
3. For known inter-translation results (e.g., Frege can polynomially simulate resolution), check whether the translation overhead correlates with spectral distance.
The conjecture is refuted if spectrally close theories have exponential translation gaps, or if spectrally distant theories have polynomial translations.

**Impact**: A computable metric on theories would enable automated theory comparison and selection — choosing the "easiest" theory in which to prove a given statement.

**Catalog References**: `Speculative/AutoResearch/SpectralRenormalization/Theorems.lean` (sameUniversalityClass_trans, spectralRatio_le_one)

**Proof Strategy**:
1. Define the normalized eigenvalue measure μ_T for a theory T at bound N.
2. Prove that μ_T is invariant under re-axiomatization (up to the universality conjecture).
3. Establish the connection between Wasserstein distance and inter-translation complexity via optimal transport duality.

**Domain Bridges**: Optimal transport <-> Proof complexity <-> Model theory (bi-interpretability)

**Lineage**: Extends the universality class pseudo-metric from this cycle to a full metric using Wasserstein distance instead of L∞.

**Ambition**: extension

---

### Direction 4: Tropical Spectral Theory of Proof Graphs

**Conjecture**: Replace the standard (real) Laplacian eigenvalue problem with the tropical (min-plus) eigenvalue problem on the proof graph's weighted adjacency matrix (weights = proof lengths). The tropical spectral radius equals the minimum average weight of a directed cycle (critical cycle mean), and this tropical invariant is *exactly* preserved under coarse-graining (not just approximately, as with real eigenvalues). Moreover, the tropical spectral radius of the proof graph gives a tight lower bound on the amortized proof complexity per derivation step.

**Test**:
1. Implement tropical eigenvalue computation for small proof graphs.
2. Verify exact preservation under multiple coarsening schemes.
3. Compare tropical spectral radius with observed amortized proof lengths.
The conjecture is refuted if tropical eigenvalues change under coarsening, or if the lower bound is not tight.

**Impact**: Exact (rather than approximate) spectral invariants under renormalization would provide the strongest possible form of the universality conjecture. The tropical framework connects to existing work on tropical geometry and proof complexity.

**Catalog References**: `Tropical/Matrix/PowerStabilization.lean` (tropPow_one_step_stable), `Speculative/AutoResearch/CycleEigenvalue.lean` (exists_bounded_cycle_mean_le), `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`

**Proof Strategy**:
1. Define the tropical Laplacian for proof graphs.
2. Prove that the critical cycle mean is preserved under block quotients (this should follow from the fact that any cycle in the quotient lifts to a cycle in the original with the same minimum average weight).
3. Connect the tropical spectral radius to proof complexity via amortized analysis.
4. Leverage the existing `tropPow_one_step_stable` result to establish fixed-point convergence.

**Domain Bridges**: Tropical geometry <-> Spectral graph theory <-> Proof complexity

**Lineage**: Builds on the tropical power stabilization theorem and cycle eigenvalue bounds from the catalog, combined with the proof graph framework from this cycle.

**Ambition**: extension

---

### Direction 5: Computational Complexity of Spectral Classification

**Conjecture**: Computing the universality class of a proof graph (i.e., determining its renormalization flow to within ε in the pseudo-metric) is PSPACE-complete in the size of the theory's axiom set, even for propositional theories. However, approximating the spectral ratio to within constant factor is in P (via power iteration on the Laplacian).

**Test**:
1. Prove PSPACE-hardness by reduction from QBF: encode a quantified Boolean formula as a proof graph whose spectral ratio encodes the formula's truth value.
2. Implement polynomial-time spectral ratio approximation and verify convergence on proof graphs of increasing size.
The conjecture is refuted if an exact polynomial-time algorithm exists, or if the approximation fails to converge.

**Impact**: Understanding the computational complexity of spectral classification would determine whether the framework can be used practically for automated theorem proving, or only theoretically as an existence result.

**Catalog References**: `Computation/GravityOracle.lean` (geodesic_oracle_idempotent), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**:
1. Formalize the decision problem: "Is the spectral ratio of the proof graph above threshold τ?"
2. Show PSPACE membership by observing that the Laplacian can be computed in polynomial space.
3. Show PSPACE-hardness via a reduction from TQBF.

**Domain Bridges**: Computational complexity <-> Spectral graph theory <-> Proof complexity

**Lineage**: Builds on the spectral ratio bounds (spectralRatio_le_one, spectralRatio_nonneg) from this cycle.

**Ambition**: extension
