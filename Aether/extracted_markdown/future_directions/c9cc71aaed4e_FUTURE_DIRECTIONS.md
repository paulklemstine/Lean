# Future Directions: Support-Compressed Lorentzian Certification

## Synthesis

The discovery that Lorentzian recognition complexity for matroid basis polynomials is exactly controlled by the independent set complex opens a new interface between discrete convexity and analytic certification. The core principle — that exchange geometry prunes derivative search trees — is not specific to matroids. It should extend to any polynomial family whose Newton support satisfies the M-convex exchange property, and potentially to broader classes of discrete convex supports. The directions below explore this principle along five axes: extending the class of supports, sharpening the complexity bounds, connecting to statistical physics, building practical algorithms, and discovering new structural invariants. Each direction builds directly on the formalized theorems and uses them as a launching point for deeper investigation.

---

## Direction 1: M-Convex Support Compression Beyond Matroids

**Conjecture:** For any homogeneous polynomial $p$ of degree $r$ whose Newton support is M-convex (satisfies the symmetric exchange property), the number of nonzero quadratic derivative leaves is at most the number of $(r-2)$-element "independent" shadows of the M-convex set, and this count is bounded by $\binom{\omega}{r-2}$ where $\omega$ is the support width.

**The key insight is** that the M-convex exchange property, formalized in `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` as `IsMConvexExchangeNat`, forces the derivative survival set to inherit exchange-like structure, making it enumerable by shadow operations rather than brute-force differentiation.

**Why now?** The catalog now contains both the exchange property formalization (`IsMConvexExchangeNat`) and the support compression framework (`CertificateCompressionExchange`). Bridging them requires proving that the shadow of an M-convex set at each level satisfies a compressed exchange property — a focused technical challenge that the existing infrastructure makes tractable.

**Test:** Construct non-matroidal M-convex sets (e.g., integer points in a generalized polymatroid) and verify computationally that compression holds. A disproof would be an M-convex support where the leaf count matches the ambient bound despite the support being sparse.

**Impact:** This would extend the compression principle from matroids to the entire domain of discrete convex analysis, affecting algorithms for submodular optimization, network flows, and auction design.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`: `IsMConvexExchangeNat`, `NewtonSupport`
- `Catalog/Pythagorean/CertificateCompressionExchange.lean`: `NonzeroQuadraticLeafSet`, `supportCompressedLeafCount`
- `Catalog/Pythagorean/SupportCompression.lean`: `independentSetsOfSize`

**Proof Strategy:** Define the "shadow" of an M-convex set $S$ at level $k$ as $\{I \in \binom{[n]}{k} : \exists \beta \in S, I \leq \beta\}$. Prove this shadow satisfies a weakened exchange property using the M-convex exchange of $S$. Then bound its cardinality using the exchange structure.

**Domain Bridges:** Discrete convex analysis → algorithmic game theory (Walrasian equilibria); submodular optimization → machine learning (DPP sampling).

**Lineage:** Extends `derivative_survival_iff_independent` from matroid bases to general M-convex supports.

**Ambition:** Grand challenge — would unify support compression across all of discrete convex analysis.

---

## Direction 2: Phase Transitions in Compression Ratio

**Conjecture:** For graphic matroids of Erdős–Rényi random graphs $G(n, p)$, the compression ratio $\text{SCLC}(\mathcal{B}, r-2) / \binom{m}{r-2}$ undergoes a sharp phase transition near the connectivity threshold $p \sim \log(n)/n$, dropping from near-1 to near-0 as the graph becomes sparser.

**The key insight is** that the compression ratio measures the "density" of the independence complex relative to the ambient simplex, and this density is governed by the graph's cycle structure — which itself undergoes a phase transition at the connectivity threshold.

**Why now?** The formalized compression ratio (`compressionRatio` in `CertificateCompressionExchange.lean`) and the verified bound `compressionRatio_le_one` provide the formal framework. Computational experiments with the Python implementation can map the phase diagram.

**Test:** Compute compression ratios for $G(n, p)$ with $n = 20, 30, 50$ across $p \in [0.1, 0.9]$ and plot the ratio as a function of $p$. A sharp transition (ratio dropping from $>0.8$ to $<0.2$ in a narrow window) would confirm the conjecture.

**Impact:** Would connect Lorentzian certification complexity to random graph theory and percolation, identifying exactly when support compression becomes algorithmically powerful.

**Catalog References:**
- `Catalog/Pythagorean/CertificateCompressionExchange.lean`: `compressionRatio`, `compressionRatio_le_one`
- `Catalog/Pythagorean/SparseLeafCompression.lean`: `supportCompressedLeafCount_le_active_choose`

**Proof Strategy:** Use results from random graph theory on the expected number of forests of size $k$ in $G(n,p)$ to compute the expected compression ratio. Show that the expectation concentrates around its mean.

**Domain Bridges:** Random graph theory → network science (reliability of random networks); percolation theory → statistical physics.

**Lineage:** Builds on `nonzeroQuadLeafSet_card_le_active` and `compressionRatio_le_one`.

**Ambition:** Solid extension — connects formalized bounds to random graph asymptotics.

---

## Direction 3: Partition Function Certification in Statistical Physics

**Conjecture:** For the hard-core model on a graph $G$ at fugacity $\lambda$, the partition function $Z_G(\lambda) = \sum_{I \text{ independent}} \lambda^{|I|}$ admits Lorentzian certification whose complexity is controlled by the independent set complex of a derived matroid, with compression scaling polynomially in the graph's tree-width.

**The key insight is** that the independent set polynomial of a graph, while not directly a matroid basis polynomial, has a support structure that satisfies approximate exchange properties when the graph has bounded tree-width. This suggests that support compression extends to approximate Lorentzian certificates.

**Why now?** The formal bridge between support geometry and certification complexity (`derivative_survival_iff_independent`) provides the template. Extending from exact independence (matroids) to approximate independence (bounded tree-width graphs) is a natural generalization.

**Test:** Compute certification complexity for the hard-core model on grid graphs (tree-width $\sqrt{n}$) and compare to the ambient bound. Significant compression would validate the conjecture.

**Impact:** Would provide efficient Lorentzian certificates for partition functions in statistical physics, enabling rigorous verification of rapid mixing results for MCMC algorithms.

**Catalog References:**
- `Catalog/Pythagorean/CertificateCompressionExchange.lean`: `derivative_nonzero_iff_dominated_support`
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`: `lorentzian_quadratic_support_mconvex`

**Proof Strategy:** Define an "approximate basis family" for the independent set complex of a bounded tree-width graph. Prove that the resulting approximate compression ratio is polynomially bounded in tree-width using tree decomposition techniques.

**Domain Bridges:** Statistical physics → Markov chain Monte Carlo; graph theory → quantum computing (tensor networks).

**Lineage:** Extends the matroid basis polynomial framework to general partition functions.

**Ambition:** Grand challenge — would bridge Lorentzian polynomial theory to statistical mechanics.

---

## Direction 4: Graphic Matroid Leaf Counts as Forest Enumerators

**Conjecture:** For the graphic matroid of a graph $G$ with $m$ edges and rank $r = |V| - 1$, the quadratic leaf count equals the number of forests in $G$ with $r - 2$ edges, and this count is bounded by $O(m^2 \cdot r^{r-4})$ for sparse graphs with $m = O(r)$.

**The key insight is** that independent $(r-2)$-sets in the graphic matroid are exactly the $(r-2)$-edge forests of $G$, and forest enumeration has well-developed algorithmic and asymptotic theory.

**Why now?** The formalized bijection between leaves and independent sets (`leafCount_eq_indepCount`) immediately specializes to graphic matroids, where independent sets are forests. The missing piece is the asymptotic bound, which can be attacked using matrix-tree theorem generalizations.

**Test:** For complete bipartite graphs $K_{a,b}$ with $a + b = n$, compute the forest count $f_{r-2}(K_{a,b})$ and compare to $\binom{ab}{r-2}$. The ratio should decrease as $a/b$ increases (more asymmetric = sparser effective structure).

**Impact:** Would provide explicit, graph-theoretic complexity bounds for Lorentzian certification of graphic matroid polynomials, with applications to network reliability and flow optimization.

**Catalog References:**
- `Catalog/Pythagorean/CertificateCompressionExchange.lean`: `leafCount_eq_indepCount`, `BasisFamily.indepSets`
- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean`: `BasisFamily.indepCount`

**Proof Strategy:** Express forest counts using the matrix-tree theorem (eigenvalues of the Laplacian) and derive asymptotic bounds for sparse graph families. Formalize the connection between graphic matroid independent sets and graph forests.

**Domain Bridges:** Graph theory → network reliability; algebraic graph theory → spectral methods.

**Lineage:** Direct specialization of `leafCount_eq_indepCount` to graphic matroids.

**Ambition:** Solid extension — connects the general theory to a specific, well-studied combinatorial counting problem.

---

## Direction 5: Certified Lorentzian Recognition via Support Oracles

**Conjecture:** There exists a polynomial-time algorithm for certifying the Lorentzian property of a polynomial $p$ given only oracle access to its support and an independence oracle for the support's matroid structure, without ever evaluating the polynomial's coefficients.

**The key insight is** that the support compression theorems show the Lorentzian recognition tree depends only on the support geometry, not on the coefficients. For multiaffine polynomials with positive coefficients, the recursion tree is entirely determined by the independence structure of the support.

**Why now?** The formalized algorithm `countNonzeroQuadraticLeavesFromBases` already implements support-compressed counting without polynomial arithmetic. The next step is to show that the quadratic leaf *checks* (not just counting) can also be done via support oracles plus a small number of coefficient queries.

**Test:** Implement a prototype oracle-based Lorentzian certifier and compare its query complexity to the full symbolic algorithm. For matroids with efficient independence oracles (graphic, linear, transversal), measure the total number of coefficient queries needed.

**Impact:** Would enable Lorentzian certification for very large polynomials that are too expensive to compute explicitly, but whose support structure is known (e.g., from a matroid representation).

**Catalog References:**
- `Catalog/Pythagorean/CertificateCompressionExchange.lean`: `countNonzeroQuadraticLeavesFromBases`, `countFromBases_eq_card`
- `Catalog/Pythagorean/SupportCompression.lean`: `countNonzeroQuadraticLeavesFromBases_correct`

**Proof Strategy:** Show that for each surviving quadratic leaf, the Hessian check reduces to evaluating a bounded number of polynomial coefficients (at most $\binom{r}{2}$). Combined with support-compressed enumeration, this gives total query complexity $O(|\mathcal{I}_{r-2}| \cdot r^2)$.

**Domain Bridges:** Computational complexity → property testing; matroid oracles → optimization.

**Lineage:** Extends the verified algorithm from counting to full certification.

**Ambition:** Solid extension with grand-challenge implications — if polynomial-time oracle-based certification is possible, it changes the practical landscape of log-concavity verification.
