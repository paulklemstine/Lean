# Future Research Directions

## Synthesis

This research cycle established a rigorous bridge between Arrow's impossibility theorem and the positive curvature of the Fisher information manifold. The core insight is that the probability simplex, equipped with the Fisher metric, is isometric to a piece of the unit sphere via the embedding p ↦ √p. The positive sectional curvature (K = 1) of this sphere creates a geometric obstruction to non-dictatorial preference aggregation, providing a differential-geometric explanation for Arrow's classical combinatorial result.

The most promising cross-domain connection emerging from this cycle is the link between **discrete Ricci curvature on the permutohedron** and **algebraic ultrafilter theory**. The decisive family structure (equivalent to an ultrafilter) captures Arrow's conditions algebraically, while the Ollivier-Ricci curvature on the Cayley graph of the symmetric group captures the same obstruction geometrically. Proving the permutohedron curvature conjecture would complete this bridge, establishing that Arrow's theorem is truly a curvature theorem at both the continuous and discrete levels. This direction has the highest breakthrough potential because it would unify the algebraic (ultrafilter) and geometric (curvature) perspectives into a single framework, potentially yielding quantitative generalizations of Arrow's theorem.

The polarization index — measuring average Hellinger distance between voter preferences — provides a concrete, computable link between real-world election data and the abstract curvature theory. Computing polarization indices from actual polling data could empirically validate the curvature interpretation and predict when Arrow-type impossibilities will be most binding in practice.

---

### Direction 1: Alternative Discrete Curvature for the Permutohedron

**Background (from this cycle)**: The Ollivier-Ricci curvature conjecture for the Cayley graph of S_m was **FALSIFIED** computationally. For m=3, the curvature is 0 on all edges. For m=4, it is negative (≈ -2/3) on some edges. The positive curvature that drives Arrow's theorem lives on the **continuous** Fisher simplex (≅ S^{m-1}, K=1), not on the discrete Cayley graph. This gap is the key open problem.

**Conjecture**: While Ollivier-Ricci curvature fails, the **Lin-Lu-Yau curvature** (a modified Ricci curvature for graphs) of the Cayley graph of S_m with adjacent transpositions IS positive for m ≥ 3. Alternatively, the **Forman-Ricci curvature** (a combinatorial analog based on edge weights) is positive on the permutohedron cell complex.

**Test**: (1) Compute Lin-Lu-Yau curvature for the Cayley graph of S_3, S_4, S_5. The Lin-Lu-Yau curvature is defined as κ_LLY(x,y) = 1 - W₁(μ_x, μ_y)/d(x,y) where μ_x is a *lazy* random walk (with self-loop probability 1/(deg+1)). (2) Compute Forman curvature on the permutohedron cell complex. (3) If either is positive, it bridges the gap between continuous and discrete curvature.

**Impact**: Finding a discrete curvature notion that IS positive on the permutohedron would complete the bridge between Arrow's combinatorial proof and the geometric interpretation. If no natural discrete curvature is positive, this reveals a fundamental asymmetry between continuous and discrete social choice theory.

**Catalog References**: `FINAL/Pythagorean/CurvatureVariance.lean` (positive_curvature_degree_bound), `Bridges/MarginCosheaf.lean` (pointwise_positive_from_cover_and_local)

**Proof Strategy**: (1) Implement Lin-Lu-Yau curvature with the lazy random walk modification. (2) For the Forman curvature, use the cell complex structure of the permutohedron (faces, edges, vertices) to compute Forman's combinatorial Ricci curvature. (3) If positive, formalize the result in Lean using the existing curvature framework. (4) Key insight from the Ollivier failure: the neighborhoods in the Cayley graph are too sparse (degree m-1 for m! vertices) for the optimal transport coupling to detect curvature.

**Domain Bridges**: Discrete differential geometry (Lin-Lu-Yau, Forman curvature) ↔ Social choice theory ↔ Algebraic combinatorics

**Lineage**: Directly motivated by the falsification of the Ollivier-Ricci conjecture in this cycle. Builds on decisive_family_principal and the Fisher isometry.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative Arrow Relaxation via Curvature Bounds

**Conjecture**: For a social welfare function F on the probability simplex satisfying unanimity and ε-IIA (the social preference between alternatives a, b depends only on voters' preferences in an ε-ball of each voter's distribution), the maximum distance from the nearest dictatorial SWF is O(ε² · K), where K is the sectional curvature of the Fisher metric (K = 1 for the standard simplex).

More precisely: define the "dictatorship distance" of F as d_dict(F) = min_i sup_P H²(F(P), P_i). Then d_dict(F) ≤ C · ε² for some universal constant C depending only on the number of alternatives m.

**Test**: (1) Construct explicit ε-IIA SWFs (e.g., weighted averages on the simplex with ε-local weights) and compute their dictatorship distance. (2) Verify the ε² scaling numerically for m = 3, 4, 5 and various values of ε. (3) Attempt to prove the bound using the curvature comparison inequality on the sphere.

**Impact**: This would give the first quantitative version of Arrow's theorem with an explicit error bound. It would show that Arrow's impossibility is "soft" — small violations of IIA allow nearly-fair aggregation — and the degree of softness is controlled by curvature. Applications include designing practical voting systems with provable fairness guarantees.

**Catalog References**: `FINAL/Pythagorean/CurvatureVariance.lean`, `FINAL/Bridges/MarginCosheaf.lean`

**Proof Strategy**: (1) Formalize ε-IIA as a Lipschitz condition on the SWF restricted to pairs of alternatives. (2) Use the Toponogov comparison theorem on the sphere to bound the deviation of F from a geodesic (projection). (3) The key inequality is: on a space with K ≥ κ > 0, any ε-local map satisfying unanimity deviates from a projection by at most O(ε²/κ). (4) Establish the Toponogov comparison for the Fisher metric using the isometry with the sphere.

**Domain Bridges**: Riemannian geometry (comparison theorems) ↔ Social choice (Arrow's relaxations) ↔ Optimization (approximation theory)

**Lineage**: Builds on the Fisher isometry (fisher_embedding_dist_sq) and the curvature-obstructed aggregation concept (CurvatureObstructedAggregation).

**Ambition**: grand_challenge

---

### Direction 3: Fisher Curvature of Empirical Election Data

**Conjecture**: The polarization index of real-world election preference data (from ranked-choice voting datasets) is positively correlated with empirical violations of IIA (measured by frequency of rank-reversal paradoxes), with the relationship mediated by the Fisher curvature of the empirical preference distribution.

**Test**: (1) Obtain ranked-choice voting datasets (e.g., Scottish local elections, Australian Senate, PrefLib repository). (2) Compute the empirical distribution over rankings and its Fisher embedding. (3) Compute the polarization index. (4) Count IIA violations (instances where adding/removing a candidate changes the winner). (5) Fit a regression model: IIA_violations ~ f(polarization_index). (6) Verify the curvature-mediation hypothesis: polarization → curvature → IIA violations.

**Impact**: This would provide the first empirical validation of the curvature interpretation of Arrow's theorem. If the correlation is strong, it would establish polarization as a practical predictor of voting paradoxes, with direct applications to electoral system design.

**Catalog References**: `Geometry/ArrowCurvature.lean` (polarizationIndex, bhattacharyyaCoeff)

**Proof Strategy**: Primarily empirical/computational. (1) Implement the polarization index computation for ranked-choice data (convert rankings to probability distributions via Plackett-Luce or similar models). (2) Use bootstrap sampling to estimate confidence intervals. (3) For the theoretical component, prove that the polarization index is a lower bound on the probability of IIA violations under a natural random profile model.

**Domain Bridges**: Statistics (Fisher information, empirical distributions) ↔ Political science (voting paradoxes, electoral systems) ↔ Differential geometry (curvature of the simplex)

**Lineage**: Extends the polarization theory (polarization_nonneg, consensus_zero_polarization) to empirical data.

**Ambition**: extension

---

### Direction 4: Curvature Obstruction for Multi-Issue Social Choice

**Conjecture**: For multi-issue social choice (where voters rank bundles of positions across k issues), the preference space is (Δ^{m-1})^k (a product of simplices). The Fisher curvature of this product space is the maximum of the individual curvatures. Arrow's impossibility extends to multi-issue voting whenever at least one issue has m ≥ 3 alternatives, and the curvature obstruction on that issue "infects" the entire product space.

**Test**: (1) Formalize the product Fisher metric on (Δ^{m-1})^k. (2) Prove that the product inherits positive curvature. (3) Prove or disprove that decisive families on the product space are principal. (4) Construct explicit counter-examples if the conjecture is false (e.g., issue-by-issue majority rule on the product space).

**Impact**: This would extend the curvature framework to realistic multi-dimensional social choice settings (budget allocation, policy platforms), where Arrow's theorem is known to generalize but the geometric interpretation has not been developed.

**Catalog References**: `FINAL/Pythagorean/CurvatureVariance.lean`, `Geometry/ArrowCurvature.lean`

**Proof Strategy**: (1) Use the fact that products of positively curved spaces are positively curved (in the product metric). (2) Show that decisive families on product spaces decompose into decisive families on each factor. (3) Apply the decisive_family_principal theorem to each factor. (4) Key technical challenge: the intersection closure property may not hold for the product decisive family, requiring additional structure.

**Domain Bridges**: Product geometry (Riemannian products) ↔ Multi-dimensional voting theory ↔ Algebraic ultrafilter theory

**Lineage**: Builds on decisive_family_principal and the Fisher isometry results.

**Ambition**: extension

---

### Direction 5: Tropical Arrow Theorem

**Conjecture**: Arrow's impossibility theorem has a tropical analog. In tropical geometry, the "tropical simplex" (the max-plus analog of the probability simplex) has a natural metric structure. The tropical curvature of this space is non-negative, and a "tropical decisive family" (defined using max-plus operations instead of standard addition) on a finite set is principal.

**Test**: (1) Define the tropical simplex and its natural metric (Hilbert projective metric or Thompson metric). (2) Compute the curvature of the tropical simplex. (3) Define tropical decisive families using max-plus operations. (4) Prove or disprove that tropical decisive families on finite sets are principal. (5) If true, determine whether the tropical proof gives additional insight into the classical theorem.

**Impact**: This would establish a new connection between tropical geometry and social choice theory, potentially revealing combinatorial structures hidden by the classical formulation. The tropical perspective may simplify the curvature computation and make the geometric argument more transparent.

**Catalog References**: `Tropical/` (existing tropical geometry in the Catalog)

**Proof Strategy**: (1) The Hilbert metric on the tropical simplex is known to have non-positive curvature (in the Busemann sense). This may actually DISPROVE the conjecture, showing that Arrow's theorem is specific to the Fisher (positive curvature) setting. (2) If so, this negative result is equally interesting: it would show that curvature sign is the crucial ingredient, and tropical geometry is on the "wrong side" of the curvature divide. (3) Alternative: use the Thompson metric instead, which may have positive curvature.

**Domain Bridges**: Tropical geometry ↔ Social choice theory ↔ Metric geometry (Hilbert/Thompson metrics)

**Lineage**: Novel direction inspired by the curvature framework and the existing tropical geometry in the Catalog.

**Ambition**: extension
