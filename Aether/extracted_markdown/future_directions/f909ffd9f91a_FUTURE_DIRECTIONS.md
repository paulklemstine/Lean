# Future Directions

## Synthesis

The topological depth-detection framework for layered volcano graphs opens a new interface between arithmetic geometry and topological data analysis. The proven results — that first cycle radius exactly recovers depth, that crater and floor vertices are topologically classifiable, and that this detection is stable under local perturbation — establish a foundation for five interconnected research directions. These range from concrete computational extensions (making the cycle profile fully computable, instantiating with actual isogeny graphs) through deep theoretical bridges (spectral-topological correspondence, higher-dimensional persistence) to potentially paradigm-shifting applications (cryptographic navigation, arithmetic moduli topology). Each direction builds on the formal definitions and theorems established in `Speculative/VolcanoPersistence.lean`, leveraging the machine-verified correctness guarantees as a foundation for further development.

---

## Direction 1: Spectral-Topological Correspondence for Arithmetic Graphs

**Conjecture.** For a layered volcano graph G with adjacency matrix A and non-backtracking operator B, the first cycle radius of a vertex v equals the smallest radius r such that the spectrum of B restricted to B_r(v) acquires a complex eigenvalue. More precisely, the spectral radius of the non-backtracking operator on the tree-like subgraph below the crater is exactly (ℓ-1)^{1/2}, and the appearance of crater cycles causes eigenvalue bifurcation detectable at radius = depth(v).

**Test.** Compute the non-backtracking spectrum of B_r(v) for volcano graphs with varying crater sizes and depths. Verify that the transition from purely real to complex spectrum occurs exactly at r = depth(v). Compare with the Ihara zeta function Z_G(u) = det(I - uB)^{-1} and check whether the first pole inside the Ramanujan bound corresponds to the crater cycle.

**Impact.** This would establish the first rigorous connection between persistent homology birth times and spectral graph transitions in arithmetic settings. It would link the Ihara zeta function — already connected to Ramanujan graph theory and number-theoretic L-functions — to topological data analysis, potentially yielding new bounds on mixing times and expansion properties of isogeny graphs.

**Catalog References.** `Speculative/VolcanoPersistence.lean` — LayeredVolcano structure, firstCycleRadius definition, stability theorem.

**Proof Strategy.** Define the non-backtracking operator on finite balls. Prove that for tree-structured balls, B has only real eigenvalues (this follows from the tree being bipartite-like). Show that adding a single cycle creates a complex conjugate pair. Use the stability theorem to localize the spectral transition.

**Domain Bridges.** Spectral graph theory ↔ Persistent homology ↔ Number theory (Ihara zeta functions, Ramanujan graphs).

**Lineage.** Builds on Hashimoto's non-backtracking matrix theory, Friedman's proof of Alon's conjecture, and the Euler characteristic bridge in our Theorem `eulerChar_eq_one_sub_cycleRank`.

**Ambition.** Grand challenge — would unify three major mathematical frameworks.

---

## Direction 2: Full Computable Cycle Profile via Graph Distance Infrastructure

**Conjecture.** The abstract cycle profile axiomatization in `VolcanoPersistence.lean` can be replaced by a fully computable cycle profile defined via BFS-distance balls, induced subgraph edge counting, and union-find connected components, and all main theorems can be re-proven with this concrete definition using only the structural properties of layered volcanoes.

**Test.** Implement in Lean 4: (1) `graphDist : V → V → ℕ` via BFS, (2) `ball : V → ℕ → Finset V` as vertices within distance r, (3) `inducedEdges : Finset V → Finset (V × V)` for the induced subgraph, (4) `connectedComponents : Finset V → ℕ` via union-find. Prove that for layered volcanoes, balls below the crater are trees (by induction on radius using the edge depth constraint), establishing `IsTreeBelowCrater` concretely.

**Impact.** This would yield a fully verified, end-to-end pipeline from graph input to depth prediction, with no axiomatized components. The verified algorithm could then be extracted to executable code for use in computational number theory and cryptographic analysis.

**Catalog References.** `Speculative/VolcanoPersistence.lean` — IsTreeBelowCrater, DetectsCyclesAtDepth, cycleProfile abstractions.

**Proof Strategy.** Build the graph distance infrastructure using Mathlib's `SimpleGraph` and `SimpleGraph.Walk` APIs. Prove tree structure of sub-crater balls by induction: at each radius increment, the new vertices added are children of existing vertices, and the unique-parent property (from the volcano structure) prevents cycles.

**Domain Bridges.** Formal verification ↔ Algorithm design ↔ Computational number theory.

**Lineage.** Direct extension of the current axiomatized framework. Prerequisite for Direction 3.

**Ambition.** Solid extension — primarily engineering with some nontrivial mathematical content in the tree induction.

---

## Direction 3: Arithmetic Instantiation with Elliptic Curve Isogeny Graphs

**Conjecture.** The LayeredVolcano structure can be instantiated with the actual ℓ-isogeny graph of ordinary elliptic curves over 𝔽_p, using Kohel's theorem that these graphs are volcanoes. Specifically, for p > 4ℓ² and ℓ ∤ disc(π), the connected component containing E is a volcano with depth equal to v_ℓ(f), where f is the conductor of End(E) and v_ℓ is the ℓ-adic valuation.

**Test.** Formalize in Lean 4: (1) the Deuring correspondence between isogeny classes and ideal classes, (2) Kohel's volcano structure theorem (Theorem 2.1 in Kohel 1996), (3) the identification of depth with v_ℓ(conductor). Instantiate the LayeredVolcano structure and obtain the depth-detection theorem as a corollary about actual elliptic curves.

**Impact.** This would be the first machine-verified proof of a nontrivial result in isogeny volcano theory. It would validate the abstract framework against the arithmetic reality and provide a foundation for formal verification of isogeny-based cryptographic protocols.

**Catalog References.** `Speculative/VolcanoPersistence.lean` — full theorem package. Mathlib's `EllipticCurve` and `Isogeny` modules (currently limited but growing).

**Proof Strategy.** Kohel's theorem has several steps: (1) ordinary curves have CM by orders in imaginary quadratic fields, (2) ℓ-isogenies correspond to ideal class actions, (3) the resulting graph structure is determined by the ℓ-adic conductor. Each step would be a separate formalization module.

**Domain Bridges.** Algebraic number theory ↔ Formal verification ↔ Cryptography.

**Lineage.** Builds on Direction 2 (computable cycle profile) and the current abstract framework.

**Ambition.** Grand challenge — requires substantial new Mathlib infrastructure for CM theory and isogenies.

---

## Direction 4: Higher-Dimensional Persistent Homology of Volcano Flag Complexes

**Conjecture.** The flag (clique) complex of the ball B_r(v) in a layered volcano exhibits higher-dimensional topological features that encode finer arithmetic data beyond the conductor. Specifically, the second Betti number β₂ of the flag complex may detect the structure of the class group of the endomorphism ring, not just its conductor.

**Test.** For small volcano graphs (crater size ≤ 6, depth ≤ 3, branching ≤ 3): (1) Compute the full persistent homology of the flag complex filtration using standard TDA software (Ripser, GUDHI). (2) Compare β₂ birth-death pairs with class group structure. (3) Check whether volcanoes with isomorphic β₁ persistence but different β₂ persistence correspond to curves with the same conductor but different class group structure.

**Impact.** If β₂ or higher Betti numbers carry arithmetic information, this would establish persistent homology as a complete invariant for endomorphism ring data, not just a conductor detector. This would be a major conceptual breakthrough.

**Catalog References.** `Speculative/VolcanoPersistence.lean` — CycleProfileFn abstraction (generalize to higher dimensions), eulerChar_eq_one_sub_cycleRank (generalize via inclusion-exclusion).

**Proof Strategy.** Define the flag complex functor from graphs to simplicial complexes. Prove that trees have contractible flag complexes (hence trivial homology in all degrees). Show that the crater cycle creates a nontrivial 1-cycle in the flag complex, reproducing the β₁ result. Investigate whether higher-order cliques in the crater create higher-dimensional cycles.

**Domain Bridges.** Algebraic topology ↔ Arithmetic geometry ↔ Topological data analysis.

**Lineage.** Natural extension of the β₁-based depth detection to the full homological spectrum.

**Ambition.** Grand challenge — the connection between β₂ and class groups is speculative but would be transformative if true.

---

## Direction 5: Cryptographic Depth Oracle and Isogeny Navigation

**Conjecture.** The topological depth predictor can be used as an efficient oracle for navigating isogeny volcanoes in cryptographic protocols. Specifically, in CSIDH-like protocols where the group action of the ideal class group on ordinary curves is the security foundation, a local depth oracle would allow: (1) efficient crater ascent (walk uphill until firstCycleRadius = 0), (2) efficient depth verification (confirm a claimed depth without computing the endomorphism ring), (3) detection of "trap" vertices where the local structure is misleading.

**Test.** Implement the depth predictor for ℓ-isogeny graphs of ordinary curves over 𝔽_p for p ≈ 2^256. Measure: (1) computation time vs. direct endomorphism ring computation, (2) accuracy on non-exceptional vertices, (3) false positive/negative rates on exceptional vertices. Compare with Sutherland's volcanic navigation algorithm.

**Impact.** A local, efficient depth oracle would have immediate applications in isogeny-based cryptography: security analysis, protocol optimization, and potentially new attack or defense strategies based on topological signatures.

**Catalog References.** `Speculative/VolcanoPersistence.lean` — predictDepth algorithm, predictDepth_correct theorem, stability theorem (enabling local computation).

**Proof Strategy.** The key challenge is efficiency: computing β₁(B_r(v)) requires exploring the ball and counting cycles. For isogeny graphs with small ℓ, the ball size grows as O(ℓ^r), so the algorithm is exponential in depth. Investigate whether cycle detection can be done incrementally (adding one radius at a time) to avoid recomputation, and whether heuristic early-termination criteria can improve practical performance.

**Domain Bridges.** Cryptography ↔ Graph algorithms ↔ Topological data analysis.

**Lineage.** Direct application of the verified algorithm from Section 8.

**Ambition.** Solid extension with high practical impact — implementation-focused but mathematically grounded.
