# Future Directions: Overlapping Support Theory

## Synthesis

The overlap interaction framework established here — decomposing the restricted Laplacian as L_S = D_S + Ω_S and proving this characterizes separation — opens a systematic pathway from local tropical correspondence theorems to a complete algebraic dictionary for arbitrary vertex subsets. The five directions below form a coherent research program: Direction 1 extends the algebraic structure to weighted and directed settings; Direction 2 connects the interaction spectrum to spectral clustering; Direction 3 bridges to electrical network theory via effective resistance; Direction 4 pursues the grand challenge of a full Jacobian reconstruction from overlap data; and Direction 5 extends to higher-dimensional combinatorial structures. Together, these directions aim to establish overlap interaction theory as a fundamental tool in algebraic graph theory, connecting tropical geometry, chip-firing, spectral methods, and discrete physics.

---

## Direction 1: Weighted and Directed Overlap Theory

**Conjecture:** For weighted graphs with edge weights w(e) ∈ ℤ₊, the overlap interaction matrix generalizes to Ω_S(i,j) = −w(s_i, s_j), the decomposition L_S = D_S + Ω_S still holds, and the separation characterization becomes Ω_S = 0 ⟺ no edges within S. For directed graphs, Ω_S is no longer symmetric, and the asymmetry encodes net flow direction between overlapping generators.

**Test:** Implement the weighted restricted Laplacian for random weighted graphs on n ≤ 8 vertices. Verify the decomposition theorem computationally. For directed graphs, check whether the SNF of the asymmetric Ω_S still classifies the cokernel structure.

**Impact:** Extends the theory to the natural setting of electrical networks (where resistances vary), communication networks (where link capacities differ), and flow networks (where direction matters). Would make the overlap framework applicable to virtually all practical graph models.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapSupport.lean` (Theorem `restrictedLap_decomposition`), `Pythagorean/TropicalBridge/Defs.lean` (`graphLaplacian` definition).

**Proof Strategy:** The decomposition L_S = D_S + Ω_S is purely structural and should extend directly. The energy nonnegativity proof requires modification: the AM-GM argument still works when weights are positive, as w(e)(x_i − x_j)² ≥ 0. For directed graphs, use the symmetrized Laplacian (L + L^T)/2 for energy analysis.

**Domain Bridges:** Electrical network theory (weighted Kirchhoff equations), operations research (network flow optimization), Markov chain theory (directed Laplacian governs random walks).

**Lineage:** Direct extension of the unweighted decomposition theorem in `OverlapSupport.lean`.

**Ambition:** Solid extension. The key insight is that the decomposition L_S = D_S + Ω_S is algebraic, not combinatorial, and weight generalization is natural. Why now? The formalized unweighted case provides the template, and weighted graph Laplacians are well-studied in Mathlib.

---

## Direction 2: Interaction Spectrum as Clustering Invariant

**Conjecture:** The eigenvalues of the interaction matrix Ω_S (the "interaction spectrum") provide a finer measure of subset cohesion than classical conductance or expansion. Specifically, the spectral gap of −Ω_S (which is a positive semidefinite matrix for subsets that form subgraphs) predicts clustering quality better than the algebraic connectivity of the induced subgraph, because Ω_S captures only internal coupling without external degree noise.

**Test:** For random graphs G(n, p) with planted clusters, compute the interaction spectrum of the planted clusters and compare its predictive power against standard spectral measures (algebraic connectivity, normalized cut). Measure correlation with ground-truth clustering quality across 1000 random instances.

**Impact:** Would provide a theoretically grounded alternative to heuristic cohesion measures in spectral clustering. The overlap framework gives a principled decomposition of the Rayleigh quotient into internal and boundary contributions.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapSupport.lean` (Theorem `overlapEnergy_decomposition`, definition `overlapInteractionMat`).

**Proof Strategy:** Prove that the second eigenvalue of −Ω_S bounds the edge expansion of the induced subgraph G[S], analogous to the Cheeger inequality but for the internal coupling matrix alone. This may require adapting the classical Cheeger proof to the restricted setting.

**Domain Bridges:** Machine learning (spectral clustering), network science (community detection), data analysis (manifold learning on graphs).

**Lineage:** Extends the energy decomposition theorem to spectral analysis.

**Ambition:** Solid extension with potential for paradigm shift if the interaction spectrum outperforms existing measures.

---

## Direction 3: Effective Resistance from Overlap Decomposition

**Conjecture:** The effective resistance between two vertices u, v in a graph can be expressed purely in terms of the overlap interaction data of strategically chosen subsets S containing u and v. Specifically, R_eff(u,v) = (e_{uv}^T L_S^{-1} e_{uv}) where e_{uv} is the unit flow vector, and this inverse can be computed from the SNF decomposition of L_S together with the overlap/self-energy split.

**Test:** For all connected graphs on n ≤ 7 vertices, compute effective resistances via the standard Laplacian pseudoinverse and via the restricted Laplacian inverse on subsets S = {u, v}. Verify agreement and analyze how the decomposition L_S = D_S + Ω_S partitions the resistance into self and interaction contributions.

**Impact:** Would provide a new computational route to effective resistances that factors through the overlap decomposition. For large graphs with small subsets of interest, computing L_S^{-1} is much cheaper than the full pseudoinverse.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapSupport.lean` (energy decomposition), `Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` (`DiscretePotentialFlow`).

**Proof Strategy:** For the 2×2 case S = {u,v}, the restricted Laplacian is [[d_u, −a], [−a, d_v]] where a = 1 if u ~ v and 0 otherwise. The inverse is explicit: (1/det) [[d_v, a], [a, d_u]]. R_eff = (d_u + d_v − 2a)/det. This decomposes cleanly into degree and interaction terms.

**Domain Bridges:** Electrical network theory (Kirchhoff's laws), random walks (commute time = 2m · R_eff), network robustness (effective resistance as connectivity measure).

**Lineage:** Connects the algebraic overlap framework to the physical interpretation in `TropicalKernelRigidity.lean` (equilibrium_iff_harmonic).

**Ambition:** Solid extension. The key insight is that the 2×2 restricted Laplacian already contains effective resistance information, and the overlap decomposition provides a canonical way to separate degree effects from adjacency effects. Why now? The formalized energy decomposition makes the separation rigorous.

---

## Direction 4: Full Jacobian Reconstruction from Overlap Data (Grand Challenge)

**Conjecture:** The graph Jacobian Jac(G) = ℤ^{n-1} / Im(L') (where L' is the reduced Laplacian) can be reconstructed from the collection of restricted cokernels {ℤ^{|S|} / Im(L_S)} as S ranges over all subsets of a fixed size k ≥ 2. More precisely, there exists a finite collection of subsets S_1, ..., S_m of size k = ⌈n/2⌉ such that the invariant factors of the restricted Laplacians L_{S_i} collectively determine the invariant factors of L'.

**Test:** For all connected graphs on n ≤ 7 vertices, compute the Jacobian from the reduced Laplacian and compare with the invariant factors obtained from all size-⌈n/2⌉ subsets. Determine the minimum number of subsets needed to recover the full Jacobian.

**Impact:** Would transform the computation of graph Jacobians from a single large matrix problem to a collection of smaller matrix problems, potentially enabling distributed computation. More fundamentally, it would show that the Jacobian is *locally determined* by overlap data on moderate-size subsets.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapSupport.lean` (full framework), `Pythagorean/TropicalBridge/Defs.lean` (`graphLaplacian`, `firingIndependentOn`).

**Proof Strategy:** The restricted Laplacian L_S is a principal submatrix of L, so its determinant is a sum of products of complementary minors by the Cauchy-Binet formula. The collection of all such determinants determines the characteristic polynomial of L and hence its nonzero eigenvalues. Since the invariant factors are determined by the GCDs of all minors (by the theory of elementary divisors), sufficiently many restricted Laplacian determinants should determine the full set of invariant factors.

**Domain Bridges:** Algebraic number theory (class group computation via local data), tropical geometry (reconstructing divisor theory from local charts), computational algebra (distributed SNF computation).

**Lineage:** Ultimate synthesis of the overlap decomposition with the Jacobian theory in Baker-Norine.

**Ambition:** Grand challenge. The key insight is that restricted Laplacians are "local views" of the global Laplacian, and the overlap framework provides the language to glue these local views together. Why now? The formalized characterization of separation and the energy decomposition provide the rigorous foundation for a gluing theory.

---

## Direction 5: Simplicial Overlap Theory (Grand Challenge)

**Conjecture:** The overlap interaction framework extends from graphs (1-dimensional simplicial complexes) to higher-dimensional simplicial complexes. For a simplicial complex K and a subset S of its k-cells, the restricted k-Laplacian L_S^{(k)} decomposes as D_S^{(k)} + Ω_S^{(k)}, where the interaction matrix Ω_S^{(k)} encodes adjacency between k-cells (sharing a (k−1)-face). The separation characterization, energy decomposition, and SNF analysis all generalize, with the invariant factors of L_S^{(k)} determining the restricted homology of K at S.

**Test:** Implement the higher Laplacian for random 2-dimensional simplicial complexes on n ≤ 10 vertices. Verify the decomposition theorem for the 1-Laplacian (edge Laplacian) on subsets of edges. Compare the restricted homology computed via SNF of L_S^{(1)} with the actual first homology of the induced subcomplex.

**Impact:** Would open the entire field of topological data analysis to overlap interaction methods. The energy decomposition would provide a principled way to measure "topological cohesion" of subsets of simplices, with applications to persistent homology and topological machine learning.

**Catalog References:** `Pythagorean/TropicalBridge/OverlapSupport.lean` (graph-level framework as template).

**Proof Strategy:** The combinatorial Laplacian Δ_k = ∂_{k+1}∂_{k+1}^T + ∂_k^T∂_k on k-chains decomposes similarly: the diagonal encodes the "degree" of each k-cell (number of cofaces + faces), and the off-diagonal encodes adjacency. The key challenge is defining "separation" for k-cells (no shared (k−1)-faces?) and proving the energy decomposition with appropriate positivity.

**Domain Bridges:** Topological data analysis (persistent homology), algebraic topology (simplicial homology computation), mathematical physics (lattice gauge theory, where the 1-Laplacian governs gauge field dynamics).

**Lineage:** Conceptual extension of the graph-level framework to arbitrary dimensions.

**Ambition:** Grand challenge / paradigm-shifting. The key insight is that the decomposition L = D + Ω is not a graph-specific accident but a structural feature of combinatorial Laplacians in any dimension. Why now? The graph-level formalization provides the blueprint, and higher Laplacians are increasingly important in topological data analysis.
