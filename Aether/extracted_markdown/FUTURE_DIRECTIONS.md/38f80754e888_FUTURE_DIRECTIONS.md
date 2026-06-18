# Future Directions: High-Dimensional Expansion via Canonical Cochains

## Synthesis

The canonical filling method establishes a bridge between combinatorial routing data and spectral expansion in simplicial complexes. The three proven theorems — discrete Stokes, congestion bound, and Poincaré inequality — form a complete pipeline: routing → congestion → spectral gap. The computational experiments reveal that this pipeline produces meaningful bounds (conservative but valid) and exhibits clean scaling laws on complete complexes.

The key open challenge is **tightness**: the certified bound from canonical fillings can be much weaker than the actual spectral gap. Closing this gap requires either better cycle families, tighter Cauchy-Schwarz applications, or fundamentally new ideas about routing in higher dimensions.

The five directions below range from solid extensions (improving the certified bound, extending to random complexes) to paradigm-shifting conjectures (a higher-dimensional Cheeger inequality from fillings, quantum code certification via congestion).

---

## Direction 1: Optimal Routing and the Higher-Dimensional Cheeger Inequality

**Conjecture:** For any pure d-dimensional simplicial complex X, the optimal canonical filling congestion (minimized over all cycle families and fillings) is equivalent, up to polynomial factors, to the cosystolic expansion constant. Specifically:

$$\frac{1}{C_{\text{opt}}} \leq \lambda_1^+ \leq \text{poly}(d) \cdot \frac{1}{C_{\text{opt}}}$$

where C_opt is the minimum spectral routing constant over all framed fillings.

**Test:** Compute C_opt for the complete 2-complex on n = 4,...,10 vertices using semidefinite programming (the optimization over cycle families with frame bound is a convex problem). Compare with the actual spectral gap λ₁⁺ = n. If the ratio λ₁⁺ · C_opt stays bounded, the conjecture is confirmed for these cases. If it grows without bound, the conjecture is false.

**Impact:** This would be a higher-dimensional Cheeger inequality proved via canonical fillings — a fundamentally new characterization of spectral expansion in terms of combinatorial routing.

**Catalog References:** `Pythagorean/CayleyExpander/HDExpansion.lean` (Theorem `poincare_from_filling`, `spectralGap_ge_inv`)

**Proof Strategy:** Use the structure theory of optimal fillings (they must satisfy a linear programming optimality condition) together with the known Hodge decomposition to relate optimal congestion to the inverse spectral gap. The lower bound is already proved; the upper bound requires showing that every spectral gap implies a good routing.

**Domain Bridges:** Connects to optimization (SDP relaxations of routing problems), coding theory (minimum-distance bounds via fillings), and numerical linear algebra (optimal preconditioning).

**Lineage:** Direct extension of the main theorem `poincare_from_filling`. The graph-level analogue is the Cheeger inequality, which relates the spectral gap to the combinatorial expansion (edge boundary / volume).

**Ambition:** Grand challenge. If proved, this would be a field-defining result in high-dimensional combinatorics.

---

## Direction 2: Canonical Fillings for Random Simplicial Complexes

**Conjecture:** For the Linial-Meshulam random 2-complex on n vertices with edge density p = c/n (c > threshold), the canonical filling congestion with respect to the natural cycle basis satisfies W = O(n log n), and the spectral gap satisfies λ₁⁺ = Ω(1) with high probability.

**The key insight is...** that random complexes should have near-optimal routing because their boundary matrices have good conditioning properties (analogous to how random graphs have good expansion). The minimum-norm fillings should distribute load uniformly due to the pseudorandom structure.

**Why now?** The Linial-Meshulam model is well-understood homologically (phase transition for H₁ vanishing at p ∼ 2 log n / n), and recent breakthroughs on spectral gaps of random complexes [KO20] provide the target bounds. The canonical filling method gives a new route to these results via explicit combinatorial certificates.

**Test:** Generate 100 random 2-complexes on n = 20 vertices for various edge densities p. Compute canonical fillings and congestion. Plot W vs p and compare with the spectral gap. Check whether W = O(n log n) holds above the homological threshold.

**Impact:** A new proof technique for random complex spectral gaps. Could lead to explicit constructions of high-dimensional expanders via derandomization of the canonical filling argument.

**Catalog References:** `Pythagorean/CayleyExpander/HDExpansion.lean` (all theorems), `Pythagorean/CayleyExpander/CanonicalPaths.lean` (graph-level analogue)

**Proof Strategy:** Show that the boundary matrix of the random complex satisfies a Restricted Isometry Property (RIP), which implies that least-norm fillings have bounded weight. Use matrix concentration inequalities (Tropp's theorem) for the RIP bound.

**Domain Bridges:** Connects to compressed sensing (RIP for boundary matrices), random matrix theory, and probabilistic combinatorics.

**Lineage:** Extension of the deterministic framework to random settings. Parallels the use of canonical paths for random graphs.

**Ambition:** Solid extension with potential for breakthrough insights.

---

## Direction 3: Quantum LDPC Code Certification via Congestion

**Conjecture:** For a family of quantum LDPC codes based on simplicial complexes (such as the codes of Dinur et al. [DHLV23]), the canonical filling congestion provides a polynomial-time computable certificate of the code distance. Specifically, if the congestion satisfies W ≤ C for a polynomial C(n), then the code distance is at least n/C.

**The key insight is...** that in a quantum code, a logical error is a non-trivial cycle, and the code distance is the minimum weight of such a cycle. A canonical filling with low congestion shows that every cycle can be "explained" by a bounded-weight chain, which constrains how small cycles can be.

**Why now?** Quantum LDPC codes have achieved breakthrough parameters [DHLV23, PK22], but verifying their properties (distance, decoding efficiency) remains computationally challenging. The canonical filling method provides an alternative certification approach that is inherently combinatorial and potentially more efficient.

**Test:** Implement the balanced product construction of quantum LDPC codes for small parameters. Compute canonical fillings for the syndrome cycles and compare the certified distance bound with the actual distance. Check whether the congestion grows polynomially.

**Impact:** A new framework for quantum code analysis that avoids the need for exhaustive distance computation. Could lead to practical certification tools for quantum error correction laboratories.

**Catalog References:** `Pythagorean/CayleyExpander/HDExpansion.lean` (Theorem `routing_congestion_controls_decoder_energy`), `Pythagorean/CayleyExpander/Defs.lean`

**Proof Strategy:** Connect the filling weight to the systolic constant of the complex via the weight-area inequality. Use the Poincaré inequality to bound the smallest cycle weight from below.

**Domain Bridges:** Quantum information theory (code distance), homological algebra (systolic geometry), computational complexity (certification).

**Lineage:** Extension of the decoder energy bound to distance certification. Builds on the cross-domain connection established in Theorem `routing_congestion_controls_decoder_energy`.

**Ambition:** Grand challenge. A positive result would open a new approach to the quantum PCP conjecture.

---

## Direction 4: Sparse Hodge Solvers via Canonical Fillings

**Conjecture:** For a simplicial complex with bounded congestion canonical fillings, the Hodge Laplacian system Lx = b can be solved in nearly-linear time using the fillings as a sparse preconditioner. Specifically, if the spectral routing constant is C, then preconditioned conjugate gradient converges in O(√C · log(1/ε)) iterations, each costing O(nnz(∂)) where nnz is the number of nonzeros in the boundary matrix.

**The key insight is...** that canonical fillings define a bounded lifting operator R from cycles to chains (R = fill composed with projection to cycle space), and the operator R^T R serves as an effective preconditioner for the upper Laplacian ∂₂∂₂^T. The congestion bound directly controls the condition number of the preconditioned system.

**Why now?** Solving Hodge Laplacian systems is increasingly important in computational topology, discrete differential geometry, and machine learning (e.g., Hodge-theoretic ranking). Current methods rely on generic sparse solvers without exploiting the topological structure. Canonical fillings provide structure-aware preconditioning.

**Test:** Implement the filling-based preconditioner for complete 2-complexes and random 2-complexes. Compare the number of CG iterations with unpreconditioned CG and with algebraic multigrid. Measure wall-clock time for n = 50, 100, 200.

**Impact:** A new class of topology-aware numerical solvers with provable convergence guarantees. Could accelerate Hodge decomposition in TDA pipelines.

**Catalog References:** `Pythagorean/CayleyExpander/HDExpansion.lean` (Theorem `poincare_from_filling` gives the condition number bound)

**Proof Strategy:** Show that the preconditioned operator has eigenvalues in [1/C, 1], use standard CG convergence theory.

**Domain Bridges:** Numerical linear algebra (preconditioning, iterative methods), computational topology (Hodge decomposition), machine learning (Hodge-theoretic ranking, graph neural networks on simplicial complexes).

**Lineage:** Extension of the spectral gap bound to computational complexity. Parallels the use of Laplacian solvers (Spielman-Teng) for graph problems.

**Ambition:** Solid extension with immediate practical applications.

---

## Direction 5: Persistent Canonical Fillings for Topological Data Analysis

**Conjecture:** For a filtered simplicial complex (as in persistent homology), canonical fillings at each filtration step can be chosen to be "compatible" across steps, producing a *persistent* canonical filling that tracks how topological features are born, persist, and die. The congestion of persistent fillings controls a new "persistent spectral gap" that quantifies the robustness of topological features.

**The key insight is...** that persistent homology tracks cycles through a filtration, and at each step, the cycle either persists (its filling can be extended) or dies (it becomes a boundary). A persistent canonical filling tracks the evolving fillings across the filtration, and its congestion provides a new measure of feature significance that combines topological persistence with spectral robustness.

**Why now?** Persistent homology is the dominant tool in TDA, but it provides only topological information (birth/death times). Spectral information (how "well-connected" a feature is) is complementary but hard to compute. Persistent canonical fillings would bridge these two perspectives, providing both topological and spectral information from a single combinatorial object.

**Test:** Implement persistent canonical fillings for Vietoris-Rips complexes of point clouds sampled from a torus, sphere, and figure-eight. Compare the persistent congestion with the persistence diagram. Check whether high-persistence features also have low congestion (as predicted by the theory).

**Impact:** A new invariant for TDA that combines topological and spectral information. Could improve feature selection in applied TDA pipelines.

**Catalog References:** `Pythagorean/CayleyExpander/HDExpansion.lean` (all definitions and theorems provide the single-step framework)

**Proof Strategy:** Use the stability of optimal fillings (as solutions to a convex optimization problem) to show that small changes in the filtration produce small changes in the filling. Bound the total variation of the persistent filling across the filtration.

**Domain Bridges:** Topological data analysis (persistent homology), statistics (robust feature detection), computational geometry (Vietoris-Rips complexes), materials science (porous media characterization).

**Lineage:** Extension from a single complex to a filtered family. Represents a bridge between the algebraic (homological) and analytic (spectral) perspectives on topological features.

**Ambition:** Grand challenge. Would unify two of the most important tools in applied topology.
