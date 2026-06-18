# Future Directions: Topology of Proof Search as a Statistical Law

## Synthesis

The results established in this cycle—monotone average comparison (Theorem 1), scale invariance of normalized critical thresholds (Theorem 2), cycle rank emergence from edge surplus (Theorem 3), and edge-count invariance under graph isomorphism (Theorem 4)—together create a rigorous mathematical framework for understanding proof difficulty through topological statistics. The key conceptual advance is that theorem difficulty is not a property of individual statements but emerges from the *geometry of dependency neighborhoods*: specifically, from whether those neighborhoods lie in the tree-like regime (simple, navigable search spaces) or the cycle-rich regime (redundant, trapping search spaces).

This synthesis opens five specific research directions. The first two are grand challenges that, if resolved, would establish proof complexity through topological statistics as a new field. The remaining three are solid extensions building directly on the theorems proved here.

---

## Direction 1: Universality of Normalized Critical Thresholds

**Ambition**: Grand challenge / paradigm-shifting

**Conjecture**: For every sufficiently large theorem corpus (≥ 200 theorems) drawn from a single mathematical domain, equipped with a dependency-based semantic distance metric, the normalized critical threshold θ = ε*/diam(S) satisfies θ ∈ [0.15, 0.65]. Furthermore, the susceptibility profile dβ₁/dε is unimodal after normalization.

**Test**: Extract dependency graphs from at least 10 Mathlib domains (GroupTheory, RingTheory, Topology, MeasureTheory, Analysis, NumberTheory, Combinatorics, CategoryTheory, LinearAlgebra, Order). For each:
1. Compute all pairwise semantic distances using symmetric difference of dependency sets.
2. Build the full threshold filtration.
3. Compute the susceptibility profile and locate θ.
4. Test unimodality using the sign-change criterion.

**Impact**: If confirmed, this would be the first universal law of proof complexity—an empirical regularity analogous to universality classes in statistical physics. It would mean that the topology of theorem space is governed by domain-independent principles.

**Catalog References**:
- `Pythagorean/ProofTheoreticTopology/QuartileLocality.lean`: `normalizedCriticalThreshold_scale_invariant`
- `Catalog/Pythagorean/ProofTheoreticTopology/CycleWindowUniversality.lean`: `normalizedCycleRank_eq_of_matched_data`

**Proof Strategy**: Formalize a "universality theorem" stating that for finite metric spaces whose threshold filtrations have isomorphic graph sequences after normalization, the normalized critical thresholds agree. Then empirically test whether real theorem corpora fall into a single universality class. The scale invariance theorem (Theorem 2) provides the mathematical foundation; the next step is connecting it to structural properties of dependency graphs (degree distributions, clustering coefficients) that might explain *why* θ falls in a narrow band.

**Domain Bridges**: Statistical physics (universality classes, critical exponents), percolation theory (bond percolation threshold), topological data analysis (persistent homology stability).

**Lineage**: Extends `normalizedCriticalThreshold_scale_invariant` and `critical_threshold_exists_finite` from the catalog.

---

## Direction 2: The 2× Law as a Quantitative Phase Transition Bound

**Ambition**: Grand challenge / paradigm-shifting

**Conjecture**: For any theorem corpus with monotone timeout propensity (timeout probability increases with locality), the quartile ratio satisfies:

$$\frac{\text{TimeoutRate}(Q_{\text{high}})}{\text{TimeoutRate}(Q_{\text{low}})} \geq 2$$

with equality holding only in degenerate cases (uniform timeout distribution or concentrated at a single locality value).

**Test**: Run a standardized automated prover (e.g., Aesop with 60s timeout) on batches of ≥ 100 Mathlib theorems from at least 5 domains. For each domain:
1. Compute locality scores via dependency-graph cycle analysis.
2. Partition into quartiles.
3. Compute the quartile timeout ratio.
4. Run Fisher's exact test on the 2×2 contingency table.

A single domain with ratio < 2 and Fisher p ≥ 0.01 constitutes a refutation.

**Impact**: This would establish the first *quantitative* prediction of proof difficulty from purely structural (topological) features of theorem space. Unlike "hardness is correlated with complexity," this gives an exact lower bound.

**Catalog References**:
- `Pythagorean/ProofTheoreticTopology/QuartileLocality.lean`: `avgOn_monotone_le`
- `Catalog/Pythagorean/ProofTheoreticTopology/HardnessLocalization.lean`: `exists_vertex_pos_localCyclePressure`

**Proof Strategy**: The qualitative direction (avgOn_monotone_le) is already proved. For the quantitative 2× bound, formalize the following: under a sigmoid-type monotonicity assumption p(L) = σ(a(L - L₀)), the quartile ratio is bounded below by a function of the sigmoid steepness parameter a. When a ≥ a_crit (determined by the quartile width), the ratio exceeds 2. The key lemma is a quantitative version of the rearrangement inequality for sigmoid-weighted averages.

**Domain Bridges**: Information theory (mutual information between locality and timeout), statistical learning theory (PAC-style bounds on predictor accuracy), epidemiology (odds ratios in cohort studies).

**Lineage**: Extends `avgOn_monotone_le` to quantitative regime.

---

## Direction 3: Cycle Rank Onset as a Sharp Predictor of Timeout

**Ambition**: Solid extension

**Conjecture**: For each theorem t in a corpus, define its *local cycle rank* as the cycle rank of the threshold graph restricted to t's dependency neighborhood at the critical threshold ε*. Theorems with local cycle rank ≥ 2 have timeout rate at least 3× higher than theorems with local cycle rank 0.

**Test**: For a Mathlib domain with ≥ 150 theorems:
1. Compute the critical threshold ε*.
2. For each theorem, compute the local cycle rank at ε*.
3. Partition theorems by local cycle rank: {0}, {1}, {≥ 2}.
4. Compare timeout rates across these groups.

Refutation: if the {≥ 2} group does not have at least 3× the timeout rate of the {0} group, or if the difference is not statistically significant (Fisher p ≥ 0.05).

**Impact**: This connects the abstract cycle rank invariant to a concrete, actionable prediction. It would validate the hardness-localization hypothesis with a stronger signal than quartile analysis alone.

**Catalog References**:
- `Pythagorean/ProofTheoreticTopology/QuartileLocality.lean`: `cycleRankZ_pos_of_connected_many_edges`
- `Catalog/Pythagorean/ProofTheoreticTopology/HardnessLocalization.lean`: `exists_vertex_pos_localCyclePressure`, `total_cyclePressure_pos_of_connected_many_edges`

**Proof Strategy**: Formalize the relationship between local cycle rank and the averaging theorem: prove that if the local cycle rank function is positively correlated with timeout propensity, then the cycle rank partition gives a finer prediction than the quartile partition. Use Theorem 3 (cycleRankZ_pos_of_connected_many_edges) to establish the existence of the cycle-rich regime, then prove that the transition from rank 0 to rank ≥ 2 corresponds to crossing the susceptibility peak.

**Domain Bridges**: Algebraic topology (Betti numbers as complexity measures), Markov chain theory (hitting times in cycle-rich subgraphs), graph theory (cycle space decomposition).

**Lineage**: Directly extends `cycleRankZ_pos_of_connected_many_edges` and `graphCycleRank_pos_of_connected_many_edges`.

---

## Direction 4: Robustness Under Alternative Distance Metrics

**Ambition**: Solid extension

**Conjecture**: The qualitative predictions (quartile separation, phase transition structure, cycle rank onset) are robust under the following perturbations of the theorem-distance metric:
1. Replacing symmetric difference with Jaccard distance.
2. Using edit distance on proof terms instead of dependency sets.
3. Using embedding-based cosine distance from neural theorem provers.

Specifically, the normalized critical threshold θ changes by at most 20% across these metrics, and the quartile ratio remains ≥ 2.

**Test**: For a fixed Mathlib domain with ≥ 100 theorems:
1. Compute θ and the quartile ratio under each of the three alternative metrics.
2. Compare to the baseline (symmetric difference metric).
3. Check that θ variations are within 20% and ratios are all ≥ 2.

Refutation: any metric variant that gives θ outside [0.8θ_baseline, 1.2θ_baseline] or quartile ratio < 1.5.

**Impact**: Robustness across metrics would strengthen the claim that the topological structure is intrinsic to theorem space, not an artifact of the specific distance measure. This is the key test of whether we are observing a genuine phenomenon or a measurement artifact.

**Catalog References**:
- `Pythagorean/ProofTheoreticTopology/QuartileLocality.lean`: `thresholdGraphQ_scale_equiv` (indirectly, via the parametric stability)
- `Catalog/Pythagorean/ProofTheoreticTopology/CycleWindowUniversality.lean`: `cycleRank_stable_under_component_perturbation`

**Proof Strategy**: Formalize a stability theorem: if two distance functions d₁ and d₂ satisfy |d₁(x,y) - d₂(x,y)| ≤ δ for all x,y, then the threshold graphs at ε and ε ± δ bound the graph of the other metric. Use the perturbation stability theorems from the catalog to bound the change in cycle rank and critical threshold.

**Domain Bridges**: Metric geometry (Gromov-Hausdorff distance), machine learning (kernel robustness), coding theory (Hamming vs. edit distance).

**Lineage**: Extends `cycleRank_stable_under_component_perturbation` to general metric perturbations.

---

## Direction 5: Higher-Dimensional Persistent Homology of Theorem Space

**Ambition**: Solid extension with long-term grand challenge potential

**Conjecture**: The Vietoris-Rips complex of a theorem corpus (built from dependency distances) has nontrivial H₂ (second homology) that correlates with theorems requiring lemma chains of depth ≥ 3. The first Betti number β₁ predicts single-step timeout, while β₂ predicts multi-step proof failure.

**Test**: For a Mathlib domain with ≥ 50 theorems:
1. Build the Vietoris-Rips complex at the critical threshold ε*.
2. Compute H₀, H₁, H₂ using a persistent homology library (e.g., Ripser).
3. Correlate β₂ with the fraction of theorems requiring intermediate lemmas.

Refutation: if β₂ = 0 for all reasonable thresholds, or if β₂ does not correlate (Spearman ρ < 0.1) with multi-step proof failure.

**Impact**: This would extend the 1-dimensional theory (cycle rank = β₁) to a full persistent homology framework, creating the first topological data analysis of proof space. The cycle rank results established here would become the β₁ special case of a general homological theory of proof difficulty.

**Catalog References**:
- `Pythagorean/ProofTheoreticTopology/QuartileLocality.lean`: `cycleRankZ_pos_of_connected_many_edges` (β₁ case)
- `Catalog/Pythagorean/ProofTheoreticTopology/HigherHomology.lean`: (for higher-dimensional extensions)

**Proof Strategy**: Formalize the Vietoris-Rips complex as a simplicial complex and define higher Betti numbers. Prove that β₁ of the Rips complex at threshold ε equals the cycle rank of the threshold graph at ε (establishing that the current theory is the 1-skeleton specialization). Then develop the β₂ theory by analyzing 2-simplices formed by triangles in the dependency graph.

**Domain Bridges**: Algebraic topology (simplicial homology), topological data analysis (persistent diagrams, barcodes), computational geometry (Vietoris-Rips complexes), homotopy type theory (computational content of homological invariants).

**Lineage**: Extends the β₁ theory (cycle rank) to full persistent homology.
