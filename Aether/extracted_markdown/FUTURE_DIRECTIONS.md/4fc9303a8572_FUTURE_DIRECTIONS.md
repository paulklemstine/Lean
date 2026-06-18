# Future Directions: Support Certificate Compression for Matroid Basis Polynomials

## Synthesis

The support certificate compression theory reveals that Lorentzian recognition complexity is not an ambient-space phenomenon but a combinatorial invariant of the polynomial's support geometry. This opens five research directions, spanning from concrete algorithmic improvements (forest counting, graphic matroid specialization) through structural extensions (M-convex compression, iterated derivative non-cancellation) to paradigm-shifting conjectures (discrete convexity as complexity theory, partition function tractability). Each direction builds on the formally verified core — the bijection between surviving derivative leaves and independent sets — and extends it toward new domains. The unifying theme is that **exchange geometry controls computational complexity**, a principle that should hold far beyond the matroid basis polynomial setting.

---

## Direction 1: Forest Counting and Graphic Matroid Specialization

**Conjecture:** For a graphic matroid arising from a connected graph $G = (V, E)$ with $n = |E|$ edges and rank $r = |V| - 1$, the nonzero quadratic leaf count equals the number of forests in $G$ with exactly $r - 2$ edges, and this count can be computed in polynomial time using a generalized matrix-tree theorem.

**Test:** Implement the generalized Kirchhoff matrix-tree computation for forests of prescribed size on benchmark graph families (paths, cycles, complete graphs, grid graphs, Petersen graph). Compare the polynomial-time computation to brute-force enumeration. Verify that for all tested cases, the forest count equals the independent $(r-2)$-set count from the support compression theorem.

**Impact:** If confirmed, this provides a polynomial-time algorithm for exact Lorentzian leaf counting for graphic matroids, reducing the complexity from $O(\binom{n}{r-2})$ to $O(|V|^3)$ via matrix operations. This would make Lorentzian recognition practical for graphs with thousands of edges.

**Catalog References:**
- `Catalog/Pythagorean/SupportCertificateCompression.lean`: `leafCount_eq_indepCount`, `supportCompressedLeafCount_le_active_choose`
- `Catalog/Pythagorean/SparseLorentzianCertificates.lean`: `BasisFamily.indepCount`

**Proof Strategy:** Define the forest polynomial $F_G(x, q) = \sum_F q^{|F|} \prod_{e \in F} x_e$ where the sum is over all forests of $G$. Show that the coefficient of $q^{r-2}$ in $F_G(1, q)$ equals the leaf count. Then relate $F_G$ to the determinant of a weighted Laplacian via the matrix-tree theorem for forests.

**Domain Bridges:** Network reliability (forest counting = reliability polynomial coefficients), spectral graph theory (Laplacian eigenvalues control forest counts), electrical network theory (Kirchhoff's theorem).

**Lineage:** Extends the uniform matroid closed form (Theorem 3) to the most important non-uniform matroid family.

**Ambition:** High — this would be a significant result in algorithmic matroid theory.

**The key insight is** that the matrix-tree theorem already implicitly counts forests, and the support compression theorem reinterprets this count as a certification complexity measure.

**Why now?** The formal verification of the leaf count identity provides the rigorous bridge between derivative-based certification and forest counting, and Mathlib's growing graph theory library provides the infrastructure for graphic matroid formalization.

---

## Direction 2: M-Convex Support Compression Beyond Matroids

**Conjecture:** For any homogeneous polynomial with nonneg coefficients whose Newton support is M-convex (satisfies the symmetric exchange property), the nonzero quadratic leaf count is at most $\binom{\omega}{d-2}$ where $\omega$ is the support width (number of active coordinates) and $d$ is the degree. Moreover, the M-convex exchange structure provides a recursive decomposition of the leaf set that enables sublinear-time certification.

**Test:** Construct M-convex supports that are not matroid basis supports (e.g., from generalized permutohedra, polymatroid rank functions, or valuated matroid theory). Compute leaf counts and verify the $\binom{\omega}{d-2}$ bound. Search for M-convex supports where the bound is tight.

**Impact:** This would extend support compression from matroids to the full class of M-convex polynomials, which includes Schur polynomials, volume polynomials of polytopes, and multivariate Tutte polynomials. It would establish discrete convex analysis as a universal tool for Lorentzian certification.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`: `IsMConvexExchangeNat`, `NewtonSupport`
- `Catalog/Pythagorean/SupportCertificateCompression.lean`: `supportCompressedLeafCount_le_active_choose`

**Proof Strategy:** Use the M-convex exchange property to show that the "shadow" of the support at depth $d - 2$ (the set of $(d-2)$-level finsupps dominated by some support element) is contained in the $(d-2)$-skeleton of the convex hull of active coordinates. The exchange property guarantees that this shadow is itself M-convex or at least hereditary.

**Domain Bridges:** Discrete convex analysis (Murota's theory), tropical geometry (tropical convexity of support sets), algebraic combinatorics (Schur positivity and Lorentzianity).

**Lineage:** Directly extends the active variable bound (Theorem 4) using the M-convex structure from the existing catalog.

**Ambition:** Grand challenge — this would unify matroid-specific and general support compression.

**The key insight is** that M-convex exchange is not just a combinatorial axiom but a pruning principle for derivative search trees, and the shadow of an M-convex set inherits structural properties that control its size.

**Why now?** The `IsMConvexExchangeNat` definition and the `lorentzian_quadratic_support_mconvex` theorem (currently sorry'd in the catalog) provide the starting point. Completing this theorem would immediately yield the M-convex compression bound.

---

## Direction 3: Iterated Derivative Non-Cancellation for Positive Sums

**Conjecture:** For any multiaffine homogeneous polynomial $p = \sum_{\beta \in S} c_\beta x^\beta$ with $c_\beta > 0$ for all $\beta \in S$, and any multiindex $\alpha$ with $|\alpha| \leq \deg(p)$:

$$\partial^\alpha p \neq 0 \iff \exists \beta \in S,\ \alpha \leq \beta$$

Moreover, when $\alpha \leq \beta$ and both are 0/1 vectors, the surviving terms have distinct exponent vectors $\beta - \alpha$, so no cancellation is possible.

**Test:** Verify computationally for random multiaffine polynomials with positive coefficients, varying $n$ from 5 to 20 and degree from 3 to 10. For each, enumerate all multiindices $\alpha$ and check that the derivative is nonzero iff some support element dominates $\alpha$.

**Impact:** This completes the formal bridge between the polynomial-level derivative criterion (Theorem 1) and the combinatorial counting (Theorem 2). Currently the bridge is stated at the combinatorial level; this conjecture would verify it at the MvPolynomial level.

**Catalog References:**
- `Catalog/Pythagorean/SupportCertificateCompression.lean`: `pderiv_monomial_eq_zero_of_exp_zero`, `monomial_pderiv_nonzero_iff`
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`: `coeff_pderiv_eq`

**Proof Strategy:** Induction on $|\alpha|$. Base case: single derivative, proved by `monomial_pderiv_nonzero_iff`. Inductive step: show that $\partial_{x_i}(\partial^{\alpha'} p)$ is a sum of terms $c_\beta \cdot \text{(falling factorial)} \cdot x^{\beta - \alpha' - e_i}$ for $\beta \geq \alpha' + e_i$. Since $\beta$ are distinct, $\beta - \alpha' - e_i$ are distinct, and positive coefficients prevent cancellation.

**Domain Bridges:** Algebraic combinatorics (divided differences and non-cancellation), computer algebra (symbolic differentiation complexity).

**Lineage:** Extends the single-step monomial derivative results to the full iterated case.

**Ambition:** Moderate — this is a natural next step that completes the formal theory.

**The key insight is** that multiaffine positive-coefficient polynomials have an *injective derivative map*: different surviving monomials produce different terms in the derivative, so no cancellation can occur.

**Why now?** The single-step derivative lemmas are already verified, and Mathlib's `MvPolynomial.pderiv` API provides the infrastructure for the inductive argument.

---

## Direction 4: Discrete Convexity as a Complexity Theory for Symbolic Inequalities

**Conjecture:** For any recursive algebraic certification problem (Lorentzian recognition, real-rootedness verification, Hurwitz stability testing, complete monotonicity checking), the certificate complexity is controlled by the support geometry of the input polynomial. Specifically, if the support satisfies discrete convexity (M-convexity or a related exchange property), then the certificate tree admits support-driven pruning that reduces its size from ambient-combinatorial to support-combinatorial.

**Test:** Formalize the recursion trees for at least two other algebraic certification problems (e.g., real-rootedness via Sturm chains, Hurwitz stability via Routh-Hurwitz criteria). For each, identify the support-level criterion for branch survival. Compute leaf counts for polynomial families with M-convex support and compare to ambient counts.

**Impact:** This would establish a new paradigm: **discrete convexity as a complexity theory**. Just as classical complexity theory classifies problems by time/space resources, this would classify symbolic certification problems by support-geometric resources. It would unify disparate algebraic verification algorithms under a single combinatorial framework.

**Catalog References:**
- `Catalog/Pythagorean/SupportCertificateCompression.lean`: all main theorems
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`: `IsRecursivelyLorentzian`

**Proof Strategy:** Develop a general framework of "support-parametrized recursion trees" where each node is labeled by a multiindex and survival is determined by a support predicate. Prove a meta-theorem: if the support predicate satisfies a monotonicity/exchange property, then the recursion tree admits compressed traversal.

**Domain Bridges:** Computational complexity theory (certificate complexity, proof complexity), algebraic geometry (Newton polytopes and support structure), optimization (interior point methods and barrier function certification).

**Lineage:** Grand generalization of the matroid leaf count identity.

**Ambition:** Grand challenge — paradigm-shifting.

**The key insight is** that recursive algebraic certification always involves a recursion tree whose branches are indexed by derivative multiindices, and the survival of each branch depends only on the support geometry — not on the coefficient values — whenever the coefficients satisfy a positivity or non-cancellation condition.

**Why now?** The matroid case provides the first complete worked example. The formal verification infrastructure (Lean 4 + Mathlib) makes it possible to state and check precise meta-theorems about recursion tree structure.

---

## Direction 5: Partition Function Tractability via Support Compression

**Conjecture:** For partition functions arising from combinatorial ensembles with matroid structure (network reliability polynomials, chromatic polynomials, Potts model partition functions), the Lorentzian certification cost is controlled by low-order graph invariants (number of forests, number of spanning subgraphs of bounded cyclomatic complexity) rather than by the total number of terms in the partition function.

**Test:** For random graphs $G(n, p)$ with $n = 20$-$50$ and varying $p$:
1. Compute the basis generating polynomial (= sum over spanning trees).
2. Count nonzero quadratic leaves via the support compression algorithm.
3. Compare to the number of spanning trees (ambient complexity).
4. Correlate leaf count with graph-theoretic invariants (treewidth, cyclomatic number, algebraic connectivity).

**Impact:** If the leaf count is controlled by treewidth or similar invariants, this provides the first formal connection between structural graph theory and Lorentzian certification complexity. It would also have implications for approximate counting and sampling algorithms: strong log-concavity (implied by Lorentzianity) guarantees rapid mixing, and efficient certification of Lorentzianity would provide verifiable guarantees for MCMC samplers.

**Catalog References:**
- `Catalog/Pythagorean/SupportCertificateCompression.lean`: `leafCount_uniformMatroid`, `supportCompressedLeafCount_le_active_choose`
- `Catalog/Pythagorean/SparseLorentzianCertificates.lean`: `BasisFamily.indepCount`

**Proof Strategy:** For bounded-treewidth graphs, use the structure theorem (tree decomposition) to bound the number of independent $(r-2)$-sets. The key step is showing that a tree decomposition of width $w$ implies that the number of forests of size $k$ is $O(n \cdot (w+1)^k)$, which is polynomial for fixed $w$ and $k$.

**Domain Bridges:** Statistical physics (partition functions, phase transitions, rapid mixing), network science (reliability, resilience), coding theory (weight enumerators of linear codes as matroid invariants), probabilistic combinatorics (random graph structure).

**Lineage:** Applies the exact leaf count identity to physical/engineering systems.

**Ambition:** High — bridges formal mathematics and applied science.

**The key insight is** that thermodynamically natural partition functions (those arising from physical systems with local interactions) have matroid structure with bounded treewidth, and the support compression theorem converts this structural sparsity into computational tractability.

**Why now?** The convergence of (1) the support compression theorem, (2) mature graph decomposition algorithms, and (3) growing interest in certified log-concavity for sampling makes this a ripe direction. The verified leaf counting algorithm can be immediately applied to real graph data.
