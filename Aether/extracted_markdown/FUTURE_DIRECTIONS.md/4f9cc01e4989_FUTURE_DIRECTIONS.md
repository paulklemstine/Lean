# Future Directions: Proof-Theoretic Locality and Hardness Prediction

## Synthesis

The theorems established in this cycle—the Neighborhood Cyclomatic Bound, the Tree Characterization, Subgraph Monotonicity, and the Critical Threshold Existence—provide the structural skeleton for a quantitative theory of proof difficulty. The key insight is that cyclic complexity in dependency graphs is *bounded locally* (by vertex degree) and *maximized globally* at a critical threshold ε*. The following directions extend this foundation in five ways: (1) empirical validation against real theorem libraries, (2) universality of the phase transition across domains, (3) connection between locality and proof technique type, (4) metric geometry of theorem spaces, and (5) algorithmic exploitation for proof search guidance. Each direction is designed to be falsifiable: a negative result would reshape the theory, not merely fail to extend it.

---

## Direction 1: Quantitative Hardness-Locality Correlation

**Conjecture:** For theorem libraries sampled from `Mathlib.GroupTheory` with ≥ 200 theorems, the Spearman rank correlation between proof-theoretic locality `L_{G_{S,ε*}}(x)` and bounded proof-search time `h(x)` (10-second `aesop` timeout) satisfies ρ ≥ 0.3.

**Test:** 
1. Sample 200+ theorems from `Mathlib.GroupTheory`.
2. Define semantic distance via symmetric difference of dependency sets.
3. Build threshold graphs at all distinct distances, compute ε*.
4. Compute `L(x)` for each theorem at threshold ε*.
5. Run `aesop` with a 10-second timeout on each theorem (after stripping its proof).
6. Compute Spearman ρ between locality rank and proof-time rank.
7. Compute 95% bootstrap CI for ρ.
8. **Refutation criterion:** If the 95% CI contains 0, or the point estimate ρ < 0.15, the conjecture is refuted.
9. **Stronger prediction:** The high-locality quartile (top 25% by L(x)) has timeout rate ≥ 2× the low-locality quartile, with Fisher exact test p < 0.01.

**Impact:** If confirmed, this provides the first *structural* predictor of theorem difficulty, moving beyond syntactic complexity metrics (proof length, term size) to topological ones. If refuted, it constrains the theory to specific graph families or distance metrics.

**Catalog References:** 
- `Catalog/Pythagorean/ProofTheoreticTopology/LocalityCorrelation.lean`: `proofTheoreticLocality`, `critical_threshold_exists_finite`
- `Catalog/Pythagorean/ProofTheoreticTopology/Theorems.lean`: `graphCycleRank_pos_of_connected_many_edges`

**Proof Strategy:** Computational; requires infrastructure for extracting dependency graphs from Mathlib and running bounded provers.

**Domain Bridges:** Proof complexity ↔ Network science ↔ Statistical hypothesis testing

**Lineage:** Builds directly on the formalized `proofTheoreticLocality` definition and the `critical_threshold_exists_finite` theorem.

**Ambition:** ★★★☆☆ (Solid extension — testable within weeks)

---

## Direction 2: Universality of the Critical Threshold Phase Transition

**Conjecture:** The normalized cyclomatic density φ(ε) exhibits a unimodal phase transition for *every* Mathlib domain with ≥ 100 theorems, and the critical threshold ε* satisfies ε*/diam(S) ∈ [0.2, 0.6] across all domains, where diam(S) is the diameter of the metric space.

**Test:**
1. Select 5+ Mathlib domains: `GroupTheory`, `RingTheory`, `Topology`, `MeasureTheory`, `Analysis`.
2. For each domain, compute the transition profile φ(ε) at all distinct distances.
3. Test unimodality: φ(ε) should have a unique global maximum.
4. Compute ε*/diam(S) for each domain.
5. **Refutation criterion:** If any domain has a bimodal φ(ε), or if ε*/diam(S) falls outside [0.1, 0.8] for any domain, the universality conjecture is weakened. If ε*/diam(S) varies by more than a factor of 5 across domains, it is refuted.

**Impact:** If universal, the critical threshold is a *domain-invariant* of mathematical knowledge, analogous to critical exponents in statistical mechanics. This would suggest a deep structural law governing the organization of mathematical theories.

**Catalog References:**
- `Catalog/Pythagorean/ProofTheoreticTopology/LocalityCorrelation.lean`: `normalizedCyclomaticDensity`, `SemanticThresholdGraph`
- `Catalog/Pythagorean/ProofTheoreticTopology/Theorems.lean`: `exists_intermediate_cycle_phase`

**Proof Strategy:** Computational for the empirical test. A theoretical proof of unimodality might use the piecewise-constant structure of φ(ε) together with convexity arguments on the marginal contribution of each new edge.

**Domain Bridges:** Statistical mechanics (percolation theory) ↔ Graph theory ↔ Library science

**Lineage:** Extends the `exists_intermediate_cycle_phase` theorem from specific instances to a universal law.

**Ambition:** ★★★★☆ (Grand challenge — could reveal universal structure)

---

## Direction 3: Locality vs. Proof Technique Type

**Conjecture:** High-locality theorems (L(x) > median) are disproportionately proved using induction or by_contra tactics, while low-locality theorems are disproportionately proved using direct computation (simp, norm_num, ring). Specifically, the odds ratio (induction | high-locality) / (induction | low-locality) > 2.0.

**Test:**
1. For 500+ Mathlib theorems with known proofs, classify the dominant proof technique.
2. Compute L(x) at the critical threshold.
3. Split theorems into high/low locality groups at the median.
4. Compute the odds ratio for induction/by_contra usage across groups.
5. **Refutation criterion:** If the odds ratio is < 1.5 or if the chi-squared test p > 0.05, the conjecture is refuted.

**Impact:** If confirmed, locality predicts not just *how hard* a theorem is but *what kind of proof it needs*. This has immediate applications for proof-search strategy: allocate induction-heavy tactics to high-locality targets.

**Catalog References:**
- `Catalog/Pythagorean/ProofTheoreticTopology/LocalityCorrelation.lean`: `cyclomaticNumber_closedNeighborhood_bound`, `proofTheoreticLocality`
- `Catalog/Pythagorean/ProofTheoreticTopology/HardnessLocalization.lean`: `cycle_creates_long_walk`

**Proof Strategy:** Computational. The theoretical basis is that cyclic neighborhoods force "looping" arguments (induction), while tree-like neighborhoods permit "straight-line" arguments (computation).

**Domain Bridges:** Proof theory ↔ Machine learning (tactic prediction) ↔ Cognitive science (proof comprehension)

**Lineage:** Extends the hardness-localization hypothesis from a scalar prediction (time) to a categorical prediction (technique).

**Ambition:** ★★★☆☆ (Solid extension with immediate practical value)

---

## Direction 4: Gromov-Hausdorff Dimension of Theorem Spaces

**Conjecture:** The critical threshold ε* of a theorem metric space (S, d) satisfies ε* ~ C · |S|^{1/dim_GH(S)} where dim_GH(S) is the Gromov-Hausdorff dimension of the metric space and C is a domain-dependent constant.

**Test:**
1. For 5+ Mathlib domains, estimate dim_GH(S) via box-counting on the pairwise distance matrix.
2. Compute ε* for each domain.
3. Fit the power-law relationship ε* = C · |S|^{1/d} with d as a free parameter.
4. Compare the fitted d with the box-counting estimate of dim_GH.
5. **Refutation criterion:** If the power-law fit has R² < 0.5, or if the fitted d differs from dim_GH by more than a factor of 3, the conjecture is refuted.

**Impact:** If confirmed, this connects proof complexity to *metric geometry*: the dimension of the theorem space determines the scaling of the critical threshold. This would link proof-theoretic locality to the geometric Langlands program (through the metric geometry of algebraic structures).

**Catalog References:**
- `Catalog/Pythagorean/ProofTheoreticTopology/LocalityCorrelation.lean`: `SemanticThresholdGraph`, `critical_threshold_exists_finite`

**Proof Strategy:** The theoretical argument uses the fact that in a d-dimensional metric space, the number of pairs at distance ≤ ε grows as ε^d. The critical threshold balances the growth of edges against the growth of cyclomatic number.

**Domain Bridges:** Metric geometry (Gromov-Hausdorff theory) ↔ Graph theory ↔ Proof complexity ↔ Tropical geometry

**Lineage:** A grand challenge extending the semantic threshold graph framework to continuous geometry.

**Ambition:** ★★★★★ (Paradigm-shifting — could unify proof complexity with geometric analysis)

---

## Direction 5: Locality-Guided Proof Search Algorithm

**Conjecture:** An `aesop`-like prover augmented with locality-based prioritization (spending 3× more time on high-locality subgoals) achieves ≥ 15% higher success rate than unmodified `aesop` on a benchmark of 500 theorems from mixed Mathlib domains.

**Test:**
1. Implement a modified `aesop` that pre-computes locality coefficients for all goal terms.
2. Weight the search budget by locality: high-locality subgoals get 3× the timeout.
3. Run both modified and unmodified `aesop` on 500 randomly sampled Mathlib theorems.
4. Compare success rates with McNemar's test.
5. **Refutation criterion:** If the improvement is < 5% or McNemar's p > 0.05, the conjecture is refuted.

**Impact:** Direct practical impact on automated theorem proving. If confirmed, locality coefficients become a standard feature in proof search heuristics.

**Catalog References:**
- `Catalog/Pythagorean/ProofTheoreticTopology/LocalityCorrelation.lean`: `computeLocalityCoefficients`, `findCriticalThreshold`
- `Catalog/Pythagorean/ProofTheoreticTopology/HardnessLocalization.lean`: `exists_vertex_pos_localCyclePressure`

**Proof Strategy:** Engineering + benchmarking. The theoretical basis is the cycle-trapping theorem from `HardnessLocalization.lean`.

**Domain Bridges:** Proof search algorithms ↔ Graph theory ↔ Operations research (resource allocation)

**Lineage:** The culmination of the hardness-localization program: from structural theorems to working software.

**Ambition:** ★★★★☆ (High impact but requires significant engineering)
