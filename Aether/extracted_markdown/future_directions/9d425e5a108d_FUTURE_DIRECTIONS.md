# Future Directions: Support Compression for Lorentzian Certification

## Synthesis

The central discovery — that nonzero quadratic leaves of matroid basis polynomials biject with independent sets — opens a new research axis connecting *discrete convex analysis*, *algorithmic complexity theory*, and *polynomial certification*. The key conceptual transition is from viewing Lorentzian recognition as a symbolic algebra procedure to viewing it as a combinatorial enumeration problem governed by the geometry of the support.

The directions below form a coherent program: Direction 1 extends the exact bijection to the most natural specialized class (graphic matroids → forests), Direction 2 pushes from exact counts to asymptotic complexity in random settings, Direction 3 develops the underlying structural mechanism (M-convex exchange) as a standalone pruning theory, Direction 4 bridges to statistical physics via partition function certification, and Direction 5 is the grand challenge that unifies the program into a general complexity-theoretic framework for discrete convexity.

---

## Direction 1: Graphic Matroid Forest Correspondence

**Conjecture.** For every connected graph $G$ on $n$ vertices with $m$ edges, the number of nonzero quadratic leaves of the graphic matroid basis polynomial equals the number of forests of $G$ with exactly $n - 3$ edges (i.e., spanning forests minus 2 edges). Moreover, this count admits a determinantal formula via a minor of the Laplacian matrix of $G$.

**Test.** Compute the $(n-3)$-forest count and the nonzero leaf count for:
- All graphs on ≤ 8 vertices (exhaustive enumeration via nauty/McKay);
- Random Erdős–Rényi graphs $G(n, p)$ for $n \in \{10, 20, 50\}$ and $p \in \{0.1, 0.3, 0.5, 0.9\}$;
- Grid graphs, Petersen graph, and Cayley graphs of small groups.
Verify exact equality in every case. Test the determinantal formula against explicit Laplacian computation.

**Impact.** This would provide a closed-form (or at least efficiently computable) expression for certification complexity of any graphic matroid, reducing a combinatorial enumeration problem to linear algebra. It would also connect Lorentzian certification to the rich theory of graph Laplacians and Kirchhoff's theorem.

**Catalog References.**
- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` — `leafCount_uniformMatroid`, `indepCount_le_active_choose`
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` — `NewtonSupport`, `IsMConvexExchangeNat`

**Proof Strategy.** Establish a bijection between independent $(r-2)$-sets of the graphic matroid and forests of size $r-2$. The key step is showing that a set of edges is independent in the graphic matroid iff it forms a forest, which is the defining property. Then apply Kirchhoff's generalized matrix-tree theorem (which counts forests of a given size via principal minors of the Laplacian) to obtain the determinantal formula.

**Domain Bridges.** Algebraic graph theory, spectral graph theory, electrical network theory.

**Lineage.** Builds directly on Theorem 4.1 (independent set bijection) from the current work.

**Ambition.** Solid extension — the mathematical machinery exists; the contribution is connecting two known theories through the lens of support compression.

---

## Direction 2: Asymptotic Compression in Random Matroids

**Conjecture.** For the graphic matroid of $G(n, c/n)$ with $c > 1$ (supercritical regime), the compression ratio
$$\rho(n, c) = \frac{\#\{(n-3)\text{-forests of } G\}}{\binom{m}{n-3}}$$
satisfies $\rho(n, c) \to 0$ exponentially fast as $n \to \infty$ for fixed $c$. Specifically, $\log \rho(n, c) = -\Theta(n)$ with an explicit constant depending on $c$.

The key insight is that in sparse random graphs, the vast majority of $(n-3)$-element edge subsets contain cycles, so the fraction of forests is exponentially small.

**Why now?** The exact bijection theorem (our Theorem 4.1) converts the question of Lorentzian certification complexity into a question about forest counting, which is precisely the type of problem that probabilistic combinatorics has developed powerful tools to attack (e.g., the method of moments, entropy bounds, the Aizenman-Wehr technique).

**Test.** Monte Carlo estimation of $\rho(n, c)$ for $n \in \{50, 100, 200, 500\}$ and $c \in \{1.5, 2, 3, 5\}$. Fit $\log \rho$ to a linear function of $n$ and estimate the slope. Compare with the entropy-based prediction $\rho \sim \exp(-n \cdot H(c))$ where $H$ is the "cycle entropy" function.

**Impact.** This would establish that Lorentzian certification of random graphic matroids is *exponentially easier* than the worst case, providing the first average-case complexity result for Lorentzian recognition.

**Catalog References.**
- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` — `indepCount_le_choose`

**Proof Strategy.** Use the first-moment method: the expected number of $(n-3)$-forests in $G(n, c/n)$ is $\binom{m}{n-3} \cdot \Pr[\text{random }(n-3)\text{-subset is acyclic}]$. Estimate the acyclicity probability using the matrix-tree theorem or by direct calculation of the probability that a uniform random edge subset avoids all cycles of length $\leq k$, then take $k \to \infty$.

**Domain Bridges.** Random graph theory, probabilistic combinatorics, average-case complexity.

**Lineage.** Extends Direction 1 from exact to asymptotic.

**Ambition.** Solid extension with potential for surprising constants.

---

## Direction 3: M-Convex Exchange as a Universal Pruning Principle

**Conjecture.** For any polynomial $p$ whose Newton support $S$ satisfies the M-convex exchange property, the recursion tree for Lorentzian recognition can be pruned to at most $|S| \cdot n^{d-2}$ leaves (where $d$ is the degree and $|S|$ is the support size), a bound that is polynomial in $|S|$ and $n$ separately.

The key insight is that M-convex exchange constrains the "shadow" of the support — the set of lower-degree monomials reachable by differentiation — far more tightly than an arbitrary support of the same size. Each surviving derivative branch corresponds to a point in the iterated shadow, and M-convex exchange forces shadows to grow at most linearly at each step.

**Why now?** The M-convex exchange property is already formalized in the catalog (`IsMConvexExchangeNat`), and the pruning mechanism for the matroid basis case provides the first concrete example. Generalizing from matroids (where $S$ consists of 0/1 vectors) to arbitrary M-convex supports requires extending the support-domination criterion to non-multiaffine settings.

**Test.** Construct M-convex supports that are not matroid-type (e.g., transportation polytope lattice points) and compute the exact leaf count versus the conjectured bound. Test with:
- Integer points of Birkhoff polytopes (doubly stochastic matrices);
- Support of elementary symmetric polynomials composed with power maps;
- Truncated M-convex sets (restrict support to a sublattice).

**Impact.** This would establish M-convexity as a *complexity-theoretic* notion: membership in the M-convex class would guarantee efficient Lorentzian certification. This is a new role for discrete convex analysis in computational complexity.

**Catalog References.**
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` — `IsMConvexExchangeNat`, `lorentzian_quadratic_support_mconvex`
- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` — `derivative_nonzero_iff_dominated_support`

**Proof Strategy.** Define the $k$-th shadow of an M-convex set $S$ as $\sigma_k(S) = \{\alpha : |\alpha| = |\beta| - k, \alpha \leq \beta \text{ for some } \beta \in S\}$. Prove by induction on $k$ that $|\sigma_k(S)| \leq |S| \cdot \binom{n}{k}$ using the exchange property to control the growth rate. The key lemma is that for M-convex $S$, the fiber $\{\beta \in S : \alpha \leq \beta\}$ has bounded size for each $\alpha \in \sigma_k(S)$.

**Domain Bridges.** Discrete convex analysis, combinatorial optimization, computational complexity.

**Lineage.** Grand challenge generalizing the matroid-specific results to all M-convex supports.

**Ambition.** Grand challenge — would redefine the role of M-convexity in complexity theory.

---

## Direction 4: Partition Function Certification in Statistical Physics

**Conjecture.** For the hard-core model on a graph $G$ at fugacity $\lambda$, the partition function $Z_G(\lambda) = \sum_{I \text{ independent}} \lambda^{|I|}$ (which is related to but distinct from the matroid basis polynomial) admits a Lorentzian certificate whose complexity is controlled by the independence number and the graph's spectral gap. Specifically, the certification cost is $O(\alpha(G)^2 \cdot n)$ where $\alpha(G)$ is the independence number.

The key insight is that the support of the multivariate independence polynomial is the independent-set complex, and for graphs with small independence number, this complex is low-dimensional, forcing the Lorentzian recursion tree to collapse.

**Why now?** Recent work (Anari et al.) has connected Lorentzian/completely log-concave polynomials to rapid mixing of Markov chains for sampling from partition functions. Our support compression theorem provides the missing link: it explains *why* the Lorentzian property can be certified efficiently for the partition functions that arise in practice (those with sparse/structured supports).

**Test.** For lattice models on $\mathbb{Z}^d$ lattices of increasing size:
- Compute the independence polynomial and its Lorentzian certificate complexity;
- Compare with the hard-core model phase transition threshold $\lambda_c(d)$;
- Test whether the certification cost diverges at $\lambda_c$ (suggesting a "certification phase transition").

**Impact.** This would create a formal bridge between Lorentzian polynomial theory and statistical physics, potentially providing new computational methods for locating phase transitions.

**Catalog References.**
- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` — `supportCompression_le_active_choose`
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` — `NewtonSupport`

**Proof Strategy.** Adapt the support compression framework from matroid bases to independent sets. The key difficulty is that independent-set families do not generally form matroids (they lack the augmentation property), so M-convexity cannot be assumed. Instead, use the Dobrushin-Lanford-Ruelle framework to control correlations and bound the shadow growth directly.

**Domain Bridges.** Statistical mechanics, phase transitions, sampling algorithms, computational physics.

**Lineage.** Extends the matroid framework to the broader class of graph independence polynomials.

**Ambition.** Grand challenge — bridges two major mathematical fields through a shared computational lens.

---

## Direction 5: Discrete Convexity as a Complexity Theory for Symbolic Inequalities

**Conjecture.** There exists a hierarchy of discrete convexity classes $\mathcal{C}_1 \subset \mathcal{C}_2 \subset \cdots$ (ordered by generality) such that for each class $\mathcal{C}_k$:
1. Membership in $\mathcal{C}_k$ is decidable in $f_k(|S|, n)$ time.
2. Lorentzian certification of any polynomial with support in $\mathcal{C}_k$ requires at most $g_k(|S|, n)$ quadratic leaf checks.
3. The functions $f_k, g_k$ are explicitly computable, with $g_k$ strictly decreasing in $k$ (stronger convexity → cheaper certification).

The key insight is that support convexity is not a single property but a hierarchy, with M-convexity (exchange property) at one end and arbitrary convexity at the other. Each level of the hierarchy imposes progressively stronger constraints on the shadow structure, yielding progressively tighter certification bounds.

**Why now?** The matroid case ($\mathcal{C}_1$ = M-convex sets with 0/1 entries) is now formally verified. The transportation polytope case ($\mathcal{C}_2$ = general M-convex sets) is the natural next step, and discrete convex analysis provides the mathematical framework. No one has previously attempted to use discrete convexity as a complexity classification tool for polynomial properties.

**Test.** For each class in the hierarchy:
- Construct explicit polynomial families with support in the class;
- Compute exact leaf counts and compare with the class-specific bound;
- Verify that the bounds are tight (construct matching lower bounds).

**Impact.** This would establish a new branch of complexity theory — "discrete convex complexity" — that classifies polynomial certification problems by the convexity of their support rather than by the algebraic structure of their coefficients. It would unify matroid theory, discrete optimization, and algebraic combinatorics under a single computational framework.

**Catalog References.**
- `Catalog/Pythagorean/MatroidBasisLeafCompression.lean` — all theorems
- `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` — `IsMConvexExchangeNat`

**Proof Strategy.** Define the hierarchy using iterated exchange properties: $\mathcal{C}_k$ consists of sets satisfying the $(k+1)$-fold exchange property (for any pair of elements differing in $\leq k+1$ coordinates, there exists a compensating swap in each coordinate). Prove shadow bounds for each level by induction on the exchange depth. The base case $k = 1$ (M-convexity) is the current work.

**Domain Bridges.** Computational complexity, discrete optimization, algebraic combinatorics, convex geometry.

**Lineage.** Grand unification of all preceding directions.

**Ambition.** Paradigm-shifting — would create a new field at the intersection of discrete mathematics and complexity theory.
