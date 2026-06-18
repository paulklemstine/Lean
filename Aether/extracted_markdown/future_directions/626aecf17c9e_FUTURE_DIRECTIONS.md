# Future Directions

## Synthesis

The constructive SNF correspondence for separated subsets reveals a fundamental principle: when support regions are disjoint (separated case), the tropical-harmonic and arithmetic classifications become algorithmically interchangeable through explicit coordinate transformations. This principle should extend far beyond the separated case. The five directions below trace a path from immediate generalizations (non-separated subsets) through deeper structural connections (metrized graphs, arithmetic statistics) to genuinely paradigm-shifting conjectures (tropical Hodge duality, quantum network invariants). Each direction builds on the formal infrastructure established in the catalog — the definitions of `SeparatedSet`, `CanonicalKernelQuotient`, `SmithNFData`, and the verified theorems about diagonal Laplacians and cokernel decompositions — and extends it into new mathematical territory.

---

## Direction 1: Non-Separated Extensions via Overlapping Support Theory

**Conjecture**: For an arbitrary nonempty vertex subset $S \subseteq V(G)$ (not necessarily separated), the canonical kernel quotient is isomorphic to the Laplacian cokernel $\mathbb{Z}^{|S|}/\mathrm{Im}(L_S)$, with the isomorphism tracked through a non-trivial SNF decomposition. The off-diagonal entries of $L_S$ encode the "interaction terms" between overlapping harmonic generators, and the SNF basis change diagonalizes these interactions.

**Test**: Enumerate all connected graphs with $n \leq 7$ and all nonempty subsets $S$ (not just separated ones). Compute $L_S$, its SNF, and verify that the invariant factors match the canonical kernel quotient structure. Check whether the transition matrices satisfy the TracksCanonicalGens predicate. A single failure would refute the conjecture.

**Impact**: This would extend the tropical-critical correspondence from independent sets to arbitrary vertex subsets, covering the full graph Jacobian rather than just its restriction to separated sets. It would make the correspondence a complete structural theorem rather than a partial one.

**Catalog References**: 
- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` — `SeparatedSet`, `restrictedLapMat`, `LaplacianCokernel`
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — `TropProjEquiv`, `disjoint_support_unique_up_to_tropProjEquiv`
- `Catalog/Pythagorean/TropicalBridge/Defs.lean` — `graphLaplacian`, `firingIndependentOn`

**Proof Strategy**: Decompose the restricted Laplacian $L_S = D + N$ where $D$ is the diagonal part (vertex degrees) and $N$ encodes adjacencies within $S$. Show that the SNF of $L_S$ can be computed by iteratively eliminating off-diagonal entries using unimodular row/column operations, tracking how each operation transforms the canonical generators.

**Domain Bridges**: Algebraic graph theory ↔ computational linear algebra; tropical geometry ↔ matroid theory (the independence condition generalizes from matroids to arbitrary sets).

**Lineage**: Directly extends `restrictedLap_sep_offdiag` and `cokernel_sep_cyclic` from the current work.

**Ambition**: ★★★ (Solid extension — well within reach with current technology)

---

## Direction 2: Metrized Graphs and Continuous Tropical Curves

**Conjecture**: For a metrized graph $(G, \ell)$ with edge lengths $\ell : E \to \mathbb{R}_{>0}$, the constructive SNF correspondence extends to a correspondence between the *continuous* tropical Jacobian $\mathrm{Jac}(\Gamma)$ (a real torus of dimension equal to the genus) and a suitable weighted Laplacian cokernel, with the invariant factors replaced by lattice invariants of the period matrix.

**The key insight is** that the discrete graph Laplacian is a combinatorial shadow of the continuous Laplacian on the metrized graph, and the SNF decomposition should "deform" continuously as edge lengths vary.

**Why now?** The catalog already has foundational definitions for graph Laplacians (`graphLaplacian` in Defs.lean) and the TropicalBridge framework handles both discrete and tropical objects. The new SNF correspondence provides the algebraic spine needed to track invariants through the continuous deformation.

**Test**: Implement a numerical computation of the period matrix of a metrized graph for small examples (genus ≤ 3). Compare the lattice invariants (successive minima, Hermite normal form) with the discrete SNF invariant factors in the limit of uniform edge lengths. Check whether the two agree up to a computable correction factor.

**Impact**: This would establish the tropical-critical correspondence at the level of tropical curves, connecting to the Baker-Norine Riemann-Roch theorem and the theory of divisors on metric graphs.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` — `SmithNFData`, `restrictedLapMat`
- `Catalog/Pythagorean/TropicalBridge/Stability.lean` — stability results for tropical structures

**Proof Strategy**: Define a weighted Laplacian $L_\ell$ with entries $-1/\ell(e)$ for edges and appropriate diagonal terms. Show that as edge lengths vary, the SNF invariant factors change in a controlled way (lower semicontinuity of divisibility).

**Domain Bridges**: Tropical geometry ↔ algebraic geometry; discrete math ↔ analysis on metric spaces.

**Lineage**: Extends the discrete `restrictedLap_sep_det` to the continuous setting.

**Ambition**: ★★★★ (Grand challenge — requires new analytical tools)

---

## Direction 3: Arithmetic Statistics of Graph Jacobians

**Conjecture**: The distribution of invariant factors of the graph Jacobian, over the ensemble of random Erdős-Rényi graphs $G(n, p)$, converges to the Cohen-Lenstra distribution as $n \to \infty$ for appropriate scaling of $p$.

**The key insight is** that the SNF correspondence converts the question about tropical-harmonic structure into a question about random integer matrices, where powerful tools from random matrix theory and arithmetic statistics apply.

**Why now?** The catalog already contains a Cohen-Lenstra module (`Catalog/Pythagorean/CohenLenstra/`) and the new SNF correspondence provides the bridge needed to connect graph Jacobian computations to Cohen-Lenstra predictions.

**Test**: Generate 10,000 random graphs $G(n, 1/2)$ for $n = 10, 20, 50, 100$. Compute the distribution of the largest invariant factor $d_1$ (the exponent of the critical group). Compare with the Cohen-Lenstra prediction $\Pr[p^k \mid d_1] = \prod_{i=1}^k (1 - p^{-i})^{-1}$ for primes $p$.

**Impact**: This would establish a new bridge between combinatorial probability and number-theoretic statistics, showing that the "random" behavior of graph invariants mirrors the "random" behavior of ideal class groups.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` — `SmithNFData.invariantFactors`
- `Catalog/Pythagorean/CohenLenstra/Defs.lean` — Cohen-Lenstra distributions

**Proof Strategy**: Use the moment method: compute the expected number of elements of order $p^k$ in $\mathrm{Jac}(G(n,p))$ and show convergence to the Cohen-Lenstra moments.

**Domain Bridges**: Combinatorial probability ↔ number theory; random matrix theory ↔ tropical geometry.

**Lineage**: Bridges the CohenLenstra catalog module to the TropicalBridge framework.

**Ambition**: ★★★★★ (Paradigm-shifting — connects two major research programs)

---

## Direction 4: Electrical Network Synthesis via Tropical Coordinates

**Conjecture**: Given a target finite abelian group $A$, there exists an efficient algorithm to construct a graph $G$ and a separated subset $S$ such that the critical group restricted to $S$ is isomorphic to $A$, and the construction is optimal in the sense of minimizing $|V(G)|$.

**The key insight is** that the SNF correspondence, run in reverse, converts the algebraic problem (finding a matrix with prescribed invariant factors) into a combinatorial problem (finding a graph with prescribed vertex degrees at a separated set).

**Why now?** The constructive SNF correspondence makes the reverse direction algorithmic: to realize $A = \bigoplus \mathbb{Z}/d_i$, construct a graph where a separated set has vertices of degrees $d_1, \ldots, d_k$. The graph realization problem for degree sequences is classical (Erdős-Gallai theorem).

**Test**: For all finite abelian groups of order $\leq 100$, find the minimum-vertex graph realizing that group as a separated critical subgroup. Check whether the solution is unique up to isomorphism.

**Impact**: This would provide a constructive synthesis method for discrete networks with prescribed algebraic invariants — directly applicable to electrical network design, where impedance matching requires specific group-theoretic properties.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` — `cokernel_sep_cyclic`, `restrictedLap_sep_det`
- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` — chip-firing equivalence

**Proof Strategy**: Use the Erdős-Gallai theorem to construct a graph with the required degree sequence at the separated set. Show that the degrees uniquely determine the separated critical subgroup.

**Domain Bridges**: Graph theory ↔ electrical engineering; algebra ↔ network synthesis.

**Lineage**: Reverses the direction of `cokernel_sep_cyclic`.

**Ambition**: ★★★ (Solid extension with practical applications)

---

## Direction 5: Tropical Hodge Theory and Discrete Differential Forms

**Conjecture**: The canonical kernel quotient, generalized from functions to higher-degree differential forms on graphs (via the discrete de Rham complex), satisfies a tropical Hodge decomposition: every form decomposes uniquely into a harmonic part, an exact part, and a co-exact part, and the harmonic space is isomorphic to a combinatorial cohomology group via an explicit SNF-tracked map.

**The key insight is** that our 0-form (function-level) correspondence is the degree-0 case of a general tropical Hodge correspondence that should hold in all degrees. The diagonal structure of $L_S$ for separated sets is the degree-0 shadow of a more general block-diagonal structure in the full Hodge Laplacian.

**Why now?** The formalization of the discrete Laplacian in the catalog (`graphLap'`, `graphLaplacianMat_row_sum_zero`) and the cokernel decomposition (`diagonal_cokernel_structure`) provide the necessary degree-0 building blocks. Extending to higher degrees requires defining the edge Laplacian and the boundary/coboundary operators, which is well within the capabilities of the Lean/Mathlib framework.

**Test**: For small graphs (|V| ≤ 6), compute the discrete Hodge Laplacian in degrees 0, 1, and 2. Verify that the harmonic space dimensions match the Betti numbers. Compute the SNF of each Hodge Laplacian and check whether the invariant factors satisfy a duality relation $d_i^{(k)} = d_{n-i}^{(n-k)}$ (discrete Poincaré duality).

**Impact**: This would establish a fully constructive discrete Hodge theory with explicit arithmetic coordinates, opening a route to tropical proofs of topological invariants and certified computation of homology groups.

**Catalog References**:
- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` — all definitions and theorems
- `Catalog/Pythagorean/TropicalBridge/TropicalKernelRigidity.lean` — tropical projective equivalence

**Proof Strategy**: Define the edge Laplacian $L_1 = B^T B + B' (B')^T$ where $B$ is the boundary operator. Show that $L_1$ restricted to a "separated edge set" is diagonal, then apply the same SNF correspondence.

**Domain Bridges**: Tropical geometry ↔ algebraic topology; discrete mathematics ↔ Hodge theory; graph theory ↔ differential geometry.

**Lineage**: Extends the degree-0 correspondence to all degrees.

**Ambition**: ★★★★★ (Grand challenge — would unify tropical, arithmetic, and topological perspectives)
