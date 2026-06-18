# Future Directions: Support Compression for Lorentzian Certification

## Synthesis

The support compression framework established here — identifying Lorentzian recursion leaves with matroid independent sets — opens a research program connecting discrete convexity, polynomial positivity, and computational complexity. The theorems proved (matroid bridge, uniform closed form, active variable bound) are the first steps in a broader vision: **discrete convexity as a complexity theory for polynomial certification.** Each direction below extends this vision in a different dimension: from matroids to general Lorentzian polynomials, from counting to algorithms, from pure mathematics to applications in physics and network science.

---

## Direction 1: Non-Multiaffine Extension via Weighted Support Analysis

**Conjecture:** For general homogeneous polynomials (not necessarily multiaffine) of degree $d$ in $n$ variables, there exists a weighted support measure $\sigma(f)$ such that the number of nonzero quadratic derivative leaves is bounded by $\sigma(f)$, and $\sigma(f)$ can be computed from the Newton polytope of $f$ in polynomial time.

**Test:** Define $\sigma(f)$ as the number of lattice points in the $(d-2)$-shadow of the Newton polytope. Compute this for specific families (power-sum polynomials, Schur polynomials, elementary symmetric polynomials) and compare with the actual nonzero leaf count. A disproof would be a polynomial where coefficient cancellation forces the leaf count below the Newton polytope prediction.

**Impact:** Would extend the support compression principle from multiaffine polynomials to all homogeneous polynomials, vastly expanding its applicability. This is essential for applications to Hodge theory and algebraic geometry, where multiaffineness is not guaranteed.

**Catalog References:** `Catalog/Pythagorean/SupportCompression.lean` (Theorem `nonzeroDerivativeLeafSet_eq_indep`), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`NewtonSupport`, `IsHomogeneousDeg`)

**Proof Strategy:** Generalize the support criterion by replacing exact containment with a dominated-support condition. For non-multiaffine polynomials, the key difficulty is coefficient cancellation: two surviving monomials might cancel in the derivative. Approach via the theory of *stable polynomials* or *completely log-concave* polynomials, where cancellation is structurally prevented.

**Domain Bridges:** Connects to algebraic geometry (Newton polytopes), optimization (lattice point enumeration), and convex geometry (mixed volumes).

**Lineage:** Builds directly on Theorem 1 (support criterion) by removing the multiaffine hypothesis.

**Ambition:** Grand challenge — would unify the multiaffine compression theory with the full Brändén-Huh framework.

---

## Direction 2: Efficient Independent-Set Counting for Structured Matroids

**Conjecture:** For graphic matroids of bounded-treewidth graphs, the number of independent $k$-sets can be computed in time $O(n^{O(\text{tw})})$, yielding a polynomial-time Lorentzian certification algorithm for basis polynomials of bounded-treewidth graphs.

**Test:** Implement dynamic-programming algorithms for independent-set counting on tree decompositions of graphs with treewidth $\leq 4$. Compare runtime with brute-force enumeration for random graphs and structured graphs (grids, planar graphs). The conjecture predicts polynomial speedup; failure would indicate that independent-set counting has superpolynomial lower bounds even for bounded treewidth.

**Impact:** Would provide the first provably efficient Lorentzian certification algorithm for an interesting class of matroids, converting the theoretical compression result into a practical tool.

**Catalog References:** `Catalog/Pythagorean/SupportCompression.lean` (Theorem `nonzeroDerivativeLeafSet_eq_indep`, Algorithm `countNonzeroQuadraticLeavesFromSupport`)

**Proof Strategy:** Use the deletion-contraction recurrence for matroid invariants combined with tree decomposition. The independent-set count satisfies a matroid Tutte-polynomial specialization, and the Tutte polynomial is polynomial-time computable for bounded-treewidth matroids.

**Domain Bridges:** Connects to parameterized complexity theory, graph algorithms, and Tutte polynomial computations.

**Lineage:** Extends the verified counting algorithm to structured cases with provable efficiency.

**Ambition:** Solid extension — uses established tools (treewidth, dynamic programming) in a new context.

---

## Direction 3: Partition Function Certification in Statistical Physics

**Conjecture:** The partition function $Z_M(\lambda) = \sum_{I \text{ indep}} \lambda^{|I|}$ of the *independence complex* of a matroid $M$ is a Lorentzian polynomial in the $\lambda_i$ variables (one per element), and the support compression principle reduces the certification cost from exponential to polynomial for sparse matroids arising in lattice models.

**The key insight is:** Matroid independence complexes are the natural setting for hard-core lattice gas models, and Lorentzian certification of the partition function would imply strong log-concavity of the independence sequence — a result with direct thermodynamic consequences (absence of phase transitions in certain regimes).

**Why now?** The Anari-Liu-Oveis Gharan-Vinzant result on log-concave polynomials [2021] already established connections between matroid theory and partition functions. Our support compression theorem provides the missing algorithmic component: not just that Lorentzian certification exists in principle, but that it's computationally feasible for sparse systems.

**Test:** Compute the partition function for graphic matroids of small Ising-model lattices. Verify Lorentzian positivity by exhaustive leaf checking, then compare the compressed leaf count with the ambient count. The conjecture predicts that lattice sparsity translates to certification sparsity.

**Impact:** Would connect formal verification of polynomial positivity to predictions in statistical mechanics, providing mathematically certified bounds on phase transition parameters.

**Catalog References:** `Catalog/Pythagorean/SupportCompression.lean`, `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`IsMConvexExchangeNat`)

**Proof Strategy:** Extend the basis polynomial framework to the full independence complex polynomial. Use the matroid truncation operation to relate independent sets of different sizes to basis polynomials of truncated matroids.

**Domain Bridges:** Statistical physics (partition functions, phase transitions), probability (log-concave distributions), algorithm design (MCMC sampling).

**Lineage:** Extends Theorem 2 (matroid bridge) from bases to the full independence complex.

**Ambition:** Grand challenge — bridges formal mathematics to physics.

---

## Direction 4: Network Reliability and Coding Theory

**Conjecture:** For the graphic matroid of a network $G$, the compressed Lorentzian leaf count equals the number of forests of size $r-2$ in $G$, and this count is bounded by $O(m^{r-2}/((r-2)!)$ where $m$ is the number of edges, with the constant depending only on the maximum degree of $G$.

**The key insight is:** Network reliability polynomials measure the probability that a random subnetwork remains connected. They are specializations of the matroid basis polynomial. Certifying that these polynomials are Lorentzian would imply monotonicity properties of reliability under edge additions — a natural engineering desideratum.

**Why now?** Modern communication networks have highly structured topologies (small-world, scale-free). The support compression theorem means that Lorentzian certification for these networks could exploit the structural sparsity of their graphic matroids, making certification feasible for networks of practical size.

**Test:** Compute forest counts and compressed leaf counts for:
- Erdős-Rényi random graphs $G(n, p)$ with $p = c/n$ (sparse regime)
- Barabási-Albert preferential attachment graphs
- Grid graphs $P_m \times P_n$
Compare with the ambient bound $\binom{m}{r-2}$ and verify the degree-dependent upper bound.

**Impact:** Would provide certified reliability bounds for network design, with applications to telecommunications, power grid resilience, and distributed computing.

**Catalog References:** `Catalog/Pythagorean/SupportCompression.lean` (all main theorems)

**Proof Strategy:** Use the matrix-tree theorem (forest enumeration as determinants) combined with the matroid bridge theorem. Degree bounds follow from the Kirchhoff matrix structure of graphic matroids.

**Domain Bridges:** Network science (reliability), coding theory (representable matroids over finite fields), electrical engineering (impedance networks).

**Lineage:** Specializes the general matroid bridge to graphic matroids with explicit combinatorial bounds.

**Ambition:** Solid extension — connects to existing engineering applications.

---

## Direction 5: M-Convex Pruning as a General Complexity Principle

**Conjecture:** For any polynomial $f$ whose Newton support is M-convex, the Lorentzian recognition tree can be pruned to at most $|\text{supp}(f)| \cdot r^{O(1)}$ leaves, where $|\text{supp}(f)|$ is the support cardinality and $r$ is the degree — independent of the ambient dimension $n$.

**The key insight is:** M-convexity is not just a property of matroid supports. It arises for supports of determinantal polynomials, mixed discriminants, and capacity polynomials in combinatorial optimization. If M-convex exchange forces pruning in general — not just for matroids — then we have a universal complexity principle for Lorentzian certification.

**Why now?** The LorentzianMConvex file in the catalog already establishes the basic M-convex exchange framework and connects it to Lorentzian quadratic polynomials. The support compression theorem provides the first concrete instance of exchange-driven pruning. Generalizing from matroids to arbitrary M-convex sets is the natural next step.

**Test:** Construct non-matroidal M-convex sets (e.g., from integral polymatroids or valuated matroids). Compute the Lorentzian leaf count for polynomials with these supports and verify the conjectured bound. A disproof would be an M-convex set where the leaf count scales with $\binom{n}{r-2}$ despite small support.

**Impact:** Would establish M-convex exchange as a general complexity-theoretic principle, connecting discrete convex analysis to computational algebra in a new way.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`IsMConvexExchangeNat`, `lorentzian_quadratic_support_mconvex`), `Catalog/Pythagorean/SupportCompression.lean`

**Proof Strategy:** Prove that M-convex exchange implies a "shadow containment" property: the $(d-2)$-shadow of an M-convex set is controlled by the set itself, not the ambient space. This is a discrete analogue of the Brunn-Minkowski inequality for M-convex sets.

**Domain Bridges:** Discrete convex analysis (Murota's theory), combinatorial optimization (submodular functions), algebraic combinatorics (Schubert calculus).

**Lineage:** Synthesizes the matroid bridge theorem with the M-convex exchange framework, aiming for a unified theory.

**Ambition:** Grand challenge — would establish a new complexity theory for discrete convexity.
