# Future Directions: K-Fold Directional Log-Concavity Depth

## Synthesis

This research cycle established the theoretical foundations of the **Lorentzian depth invariant** for valuated matroids. The k-fold directional log-concavity hierarchy provides a graded refinement of Murota's M-convexity, with three formally verified structural theorems: hierarchy monotonicity, product stability, and the tropical bridge. The product stability theorem is particularly significant — it shows the k-fold classes form multiplicative monoids, which means the depth invariant is compatible with the most natural algebraic operation on valuated matroids.

The most promising cross-domain connection from this cycle is the **tropical bridge** (Theorem 4.3 in `Pythagorean/KFoldValuatedDepth.lean`). By showing that 1-fold DLC implies tropical convexity under the logarithmic map, we establish a formal link between the discrete curvature hierarchy and tropical geometry. This opens the door to importing tools from tropical algebraic geometry (Newton polytopes, tropical intersection theory) into the study of valuated matroid depth. The existing catalog work on tropical M-convexity (`Catalog/Pythagorean/TropicalMConvexity.lean`) and tropical exchange families (`Catalog/Pythagorean/ValuatedMatroidExchange.lean`) provides the infrastructure for this extension.

The highest breakthrough potential lies in **Direction 1** below: resolving whether the Lorentzian depth hierarchy collapses for M-convex functions. If depth ≥ 1 forces infinite depth (a "rigidity theorem"), it would reveal a deep structural principle connecting Murota's exchange axiom to Brändén-Huh's Lorentzian condition. If finite-depth examples exist, they would define a genuinely new matroid invariant.

---

### Direction 1: The Depth Rigidity Conjecture

**Conjecture**: For any function $f : \mathbb{Z}^n \to \mathbb{R}_{>0}$ with M-convex support that is 1-fold directionally log-concave (i.e., has depth ≥ 1), $f$ has infinite Lorentzian depth.

**Test**: Systematically enumerate valuated matroids on small ground sets ($n \leq 6$, rank $\leq 3$) and compute their depth. Focus on graphic matroid valuations for $K_4$, $K_5$, and the Petersen graph with random edge weights. If a single example achieves finite depth > 0, the conjecture is disproved. Run at least 10,000 random weight vectors per graph.

**Impact**: If true, this would be a new rigidity theorem: the exchange axiom (M-convexity) combined with first-order log-concavity forces all higher orders. This would fundamentally connect Murota's combinatorial axiomatics to Brändén-Huh's analytic conditions. If false, the counterexample depth would define a new invariant distinguishing matroids invisible to existing tools.

**Catalog References**: `Pythagorean/KFoldValuatedDepth.lean` (KFoldDirLogConcave, kfold_dir_mono, kfold_dir_mono_le), `Catalog/Pythagorean/ValuatedMatroidExchange.lean` (TropicalExchangeFamily), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave)

**Proof Strategy**: For the positive direction (rigidity), try to show that M-convex exchange + 1-fold DLC implies the ratio transform $R_i f$ has M-convex support and is 1-fold DLC, then use induction. The key lemma would be: "the ratio transform of an M-convex function with DLC-1 is again M-convex with DLC-1." This requires showing that the exchange axiom is preserved by the ratio transform. For the negative direction, construct explicit counterexamples using perturbations of uniform matroid valuations.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry <-> Discrete Convex Analysis

**Lineage**: Builds on `kfold_dir_mono`, `negLog_supermod_of_dirLC`, and the M-convex exchange structure from `ValuatedMatroidExchange.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Characterization of Depth via Tropical Hessian

**Conjecture**: The Lorentzian depth of a valuated matroid $f$ equals the largest $k$ such that the $k$-th iterated tropical Hessian of $-\log f$ is positive semidefinite at all points.

**Test**: For the multinomial valuation $(x_1 + \cdots + x_n)^d$ with $n = 3, d = 4, 5, 6$, compute the tropical Hessian $H_{ij}(m)$ at all lattice points $m$ in the support, then compute the tropical Hessian of the ratio-transformed function, and verify eigenvalue positivity. Compare the spectral gap (smallest eigenvalue) with the LC ratio $f(m+e)^2/(f(m) \cdot f(m+2e))$.

**Impact**: Would provide a linear-algebraic characterization of the depth invariant, replacing the recursive ratio-transform definition with a single matrix condition. This would make depth computable in $O(n^3)$ per point instead of $O(k \cdot n \cdot |S|)$.

**Catalog References**: `Pythagorean/KFoldValuatedDepth.lean` (tropicalize, negLog_supermod_of_dirLC), `Catalog/Pythagorean/LorentzianSpectralGap.lean` (lorentzian_dominates_log_concave)

**Proof Strategy**: Define the $k$-th tropical Hessian as the Hessian of the $k$-th iterated ratio transform. Show that positivity of the ratio transform's DLC condition is equivalent to PSD of the corresponding Hessian. This requires developing discrete calculus tools: the relationship between second differences and the Hessian matrix.

**Domain Bridges**: Tropical Geometry <-> Spectral Theory <-> Discrete Convex Analysis

**Lineage**: Builds on the tropical bridge theorem `negLog_supermod_of_dirLC` and spectral gap results from `LorentzianSpectralGap.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Product Stability and the Depth Monoid

**Conjecture**: The set of valuated matroids with depth exactly $k$ forms a proper subset of those with depth $\geq k$, and the product of two matroids with depths $k_1$ and $k_2$ has depth exactly $\min(k_1, k_2)$.

**Test**: Construct explicit families $f_k$ with depth exactly $k$ (assuming Direction 1's conjecture is false). Verify that $f_k \cdot f_\ell$ has depth $\min(k, \ell)$ computationally. If Direction 1's conjecture is true, reformulate: show that the product stability theorem is tight (depth of product = min of depths) for functions beyond the M-convex setting.

**Impact**: Would show that the depth defines a *filtration* on the monoid of valuated matroids under pointwise product, with each filtration level being a proper sub-monoid. This algebraic structure would connect to the theory of filtered algebras and could have applications in algebraic combinatorics.

**Catalog References**: `Pythagorean/KFoldValuatedDepth.lean` (kfold_dir_mul, ratioTransform_mul), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave.mul)

**Proof Strategy**: The upper bound (depth of product ≥ min of depths) is already proved as `kfold_dir_mul`. For the lower bound (depth of product ≤ min of depths), construct an explicit witness: a test point where the $(k+1)$-th ratio transform fails log-concavity for the product, using the fact that it fails for the shallower factor.

**Domain Bridges**: Algebra <-> Combinatorics

**Lineage**: Directly extends `kfold_dir_mul` and `KFoldLogConcave.mul`.

**Ambition**: extension

---

### Direction 4: Depth and Matroid Duality

**Conjecture**: For a valuated matroid $f$ on the bases of a matroid $M$ with Lorentzian depth $k$, the dual valuated matroid $f^*$ (defined on the bases of the dual matroid $M^*$) also has Lorentzian depth $k$.

**Test**: For graphic matroids of small graphs (cycles $C_4, C_5$; complete bipartite $K_{2,3}$), compute the depth of the graphic matroid valuation and its dual (co-graphic matroid valuation). Check equality.

**Impact**: Depth invariance under duality would be a strong structural result, connecting the invariant to the rich theory of matroid duality. It would also constrain the set of possible depth values: since duality is an involution, depth would need to be preserved by complementation of the basis family.

**Catalog References**: `Pythagorean/KFoldValuatedDepth.lean` (ValuatedMatroidFn, LorentzianDepth), `Catalog/Pythagorean/SupportTuttePolynomial.lean`

**Proof Strategy**: Show that the ratio transform commutes with matroid duality (up to sign/direction reversal). The key identity would be: $R_i f^*(m) = 1/R_{n-i} f(\bar{m})$ where $\bar{m}$ is the complementary exponent vector. This requires careful work with the duality involution on exponent vectors.

**Domain Bridges**: Matroid Theory <-> Tropical Geometry

**Lineage**: Extends the ValuatedMatroidFn structure from this cycle.

**Ambition**: extension

---

### Direction 5: Applications to Network Reliability and Phase Transitions

**Conjecture**: For the reliability polynomial $R_G(p_1, \ldots, p_m)$ of a connected graph $G$, the Lorentzian depth of the coefficient function (organized by edge failure count) is at least the edge-connectivity $\lambda(G)$ of $G$.

**Test**: Compute depth for complete graphs $K_n$ ($n = 3, 4, 5, 6$), cycle graphs $C_n$, and Petersen graph. Verify that depth ≥ edge-connectivity in each case. Also compute depth for the Ising model partition function on path and cycle graphs with varying coupling constants $J$.

**Impact**: Would provide a new quantitative measure of network robustness with a rigorous mathematical foundation. The connection to edge-connectivity would mean that higher-order log-concavity conditions encode structural connectivity information. For statistical physics, it would connect the depth hierarchy to the nature of phase transitions.

**Catalog References**: `Pythagorean/KFoldValuatedDepth.lean` (KFoldDirLogConcave), `Catalog/Pythagorean/ShadowHodgeULC.lean` (log_concave_ratio_antitone)

**Proof Strategy**: For the reliability polynomial, use the fact that edge-connectivity $\lambda$ means there are $\lambda$ edge-disjoint paths between any pair of vertices. Each path contributes a "layer" of log-concavity to the coefficient sequence. Formalize this by showing that the reliability polynomial factors (approximately) into $\lambda$ terms, each of which is 1-fold DLC, and invoke product stability.

**Domain Bridges**: Graph Theory <-> Statistical Physics <-> Discrete Convex Analysis

**Lineage**: Extends the tropical bridge theorem and connects to the shadow/Hodge theory in `ShadowHodgeULC.lean`.

**Ambition**: extension
