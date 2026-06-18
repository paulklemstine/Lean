# Future Directions: Sparse-Support Certificate Compression

## Synthesis

The discovery that Lorentzian recognition complexity for matroid basis polynomials is controlled by the independent-set complex opens a bridge between three mathematical domains: symbolic computation (recursive differentiation), combinatorial optimization (matroid theory), and discrete convex analysis (M-convexity). Each future direction below exploits a different facet of this bridge. The common thread is that **support geometry is a complexity resource**: the sparser and more structured the support, the cheaper the certification. This principle should extend well beyond matroids, potentially yielding a general complexity theory for polynomial inequalities governed by discrete convexity.

---

## Direction 1: M-Convex Extension — Beyond Matroids to General Lorentzian Supports

**Conjecture.** For any homogeneous polynomial $p$ of degree $r$ with nonneg coefficients whose Newton support $S$ satisfies the M-convex exchange property, the number of nonzero quadratic derivative leaves is exactly $|\{m \in \mathbb{Z}^n_{\geq 0} : |m| = r-2,\, \exists s \in S,\, m \leq s\}|$, and this set is the $(r-2)$-shadow of $S$ under the dominance order.

**Test.** Construct non-multiaffine M-convex supports (e.g., from polymatroid rank functions) and verify the identity computationally for degree up to 8 in up to 6 variables. Compare against direct polynomial differentiation.

**Impact.** This would unify support compression for all Lorentzian polynomials, not just matroid basis polynomials. It would make support compression a first-class tool in discrete convex analysis.

**Catalog References.**
- `Speculative/AutoResearch/LorentzianMConvex.lean` — `IsMConvexExchangeNat`, `NewtonSupport`
- `Pythagorean/SparseSupport/Theorems.lean` — `quadraticLeaves_eq_indepSets`

**Proof Strategy.** Generalize the monomial domination lemma to non-multiaffine supports. The key difficulty is coefficient cancellation: unlike the multiaffine case, monomials with the same exponent pattern can appear with different signs after differentiation. Use M-convexity to show that the exchange property prevents cancellation in the positive-coefficient regime.

**Domain Bridges.** Discrete convex analysis ↔ algebraic combinatorics ↔ optimization theory.

**Lineage.** Direct extension of Theorem 2 (quadraticLeaves_eq_indepSets).

**Ambition.** Grand challenge — would establish support compression as a general principle for the entire Lorentzian polynomial class.

**The key insight is** that M-convex exchange is not merely a geometric curiosity but a *complexity-theoretic pruning principle* that eliminates derivative branches before they are computed.

**Why now?** The formal infrastructure for M-convex sets and Lorentzian support theory now exists in the catalog, making machine-verified extension feasible for the first time.

---

## Direction 2: Graphic Matroid Leaf Counting via Tutte Polynomial Evaluations

**Conjecture.** For the graphic matroid of a connected graph $G$ with $m$ edges and $n$ vertices, the quadratic leaf count equals the number of forests of $G$ with exactly $n - 3$ edges, which can be expressed as a specialization of the Tutte polynomial: $T_G(1, 0)$ counts spanning trees, and the forest count is related to evaluations of the reliability polynomial.

**Test.** Compute the Tutte polynomial for paths, cycles, complete graphs, and Petersen graph. Extract forest counts of size $r - 2 = n - 3$ and compare with independent-set enumeration. Verify the relationship $|\mathcal{D}_{n-3}(\mathcal{B}(M(G)))| = \sum_{k} (-1)^k \binom{\cdot}{k} T_G(\cdot, \cdot)$ for small cases.

**Impact.** Would connect Lorentzian certification complexity to one of the most studied objects in algebraic graph theory, enabling transfer of decades of Tutte polynomial algorithms and closed-form results.

**Catalog References.**
- `Pythagorean/SparseSupport/Theorems.lean` — `quadraticLeaves_eq_indepSets`
- `Pythagorean/SparseSupport/Defs.lean` — `BasisFamily`, `SurvivingDerivSet`

**Proof Strategy.** Use the deletion-contraction recurrence for the Tutte polynomial, matching it to the deletion-contraction of the surviving derivative set. The forest count at size $k$ is the coefficient of $y^{m-k}$ in the reliability polynomial, which is a Tutte specialization.

**Domain Bridges.** Algebraic graph theory ↔ Lorentzian polynomial theory ↔ network reliability.

**Lineage.** Builds on Theorem 2 specialized to graphic matroids.

**Ambition.** Solid extension — connects to well-developed theory.

**The key insight is** that forest counting (an old problem) and Lorentzian certification complexity (a new problem) are the same problem in different clothes.

**Why now?** The exact identity between leaf counts and independent-set counts makes the connection to graph enumeration precise and non-speculative.

---

## Direction 3: Support Compression for Partition Functions in Statistical Physics

**Conjecture.** For the hard-core partition function $Z_G(\lambda) = \sum_{I \text{ independent}} \lambda^{|I|}$ of a graph $G$, the Lorentzian certification complexity (viewed as a multivariate polynomial in edge activities) is controlled by the independent-set complex of the *dual* matroid. For sparse interaction graphs (e.g., lattice models in $d$ dimensions), this yields polynomial-time certification of log-concavity properties relevant to phase transition analysis.

**Test.** Compute support compression for the multivariate independence polynomial of grid graphs $G_{k \times k}$ for $k = 3, 4, 5$. Compare the leaf count against the ambient worst case and measure scaling with $k$.

**Impact.** Would provide the first rigorous complexity bounds for certifying log-concavity of partition functions, with implications for the Lee-Yang program and the theory of phase transitions.

**Catalog References.**
- `Pythagorean/SparseSupport/Theorems.lean` — `supportCompressedLeafCount_le_active_choose`
- `Speculative/AutoResearch/LorentzianMConvex.lean` — `IsMConvexExchangeNat`

**Proof Strategy.** Model the independence polynomial as a sum over independent sets in a cographic or transversal matroid. Apply the active variable bound (Theorem 4) using the bounded-degree structure of lattice graphs. The key step is showing that the support of the multivariate independence polynomial has M-convex structure in the relevant regime.

**Domain Bridges.** Statistical physics ↔ matroid theory ↔ computational complexity.

**Lineage.** Extends Theorem 4 to physical partition functions.

**Ambition.** Grand challenge — would bridge formal combinatorics with theoretical physics.

**The key insight is** that thermodynamic partition functions encode combinatorial structures whose support geometry determines certification complexity, not the physical dimension or temperature.

**Why now?** Recent work on log-concavity of partition functions (e.g., Anari–Liu–Oveis Gharan–Vinzant) provides the mathematical framework; support compression provides the complexity tool.

---

## Direction 4: Algorithmic Independence Oracle Compression

**Conjecture.** For matroids representable over a field $\mathbb{F}$, the independence oracle can be replaced by a rank computation (Gaussian elimination), reducing the per-query cost to $O(r^3)$. Combined with support compression, this yields an overall Lorentzian certification algorithm running in $O(\binom{n}{r-2} \cdot r^3)$ time, which for sparse matroids with $r = O(\log n)$ is $O(n^{O(\log n)})$ — quasi-polynomial.

**Test.** Implement the rank-based independence oracle for representable matroids and benchmark against the explicit basis enumeration approach for graphic matroids up to 20 edges.

**Impact.** Would yield practical Lorentzian certification for representable matroids of moderate rank, directly applicable to linear algebraic applications (network coding, linear matroid optimization).

**Catalog References.**
- `Pythagorean/SparseSupport/Defs.lean` — `BasisFamily.Indep`, `countNonzeroQuadraticLeavesFromSupport`

**Proof Strategy.** For a matroid represented by a matrix $A$ over $\mathbb{F}$, independence of $I$ is equivalent to $\text{rank}(A_I) = |I|$, computable in $O(r^3)$. The total cost is $\binom{n}{r-2}$ oracle calls. For graphic matroids, use union-find to check acyclicity in $O(r \cdot \alpha(n))$ per query.

**Domain Bridges.** Linear algebra ↔ matroid theory ↔ algorithm design.

**Lineage.** Practical implementation of the verified algorithm from Theorem 2.

**Ambition.** Solid extension — directly implementable.

**The key insight is** that the independence oracle transforms support-compressed leaf counting from a combinatorial enumeration into a sequence of linear algebra computations, each of which is fast.

**Why now?** The correctness theorem for the counting algorithm is now formally verified, providing a solid foundation for optimized implementations.

---

## Direction 5: Coding Theory — Weight Enumerators and Lorentzian Certificates

**Conjecture.** The weight enumerator polynomial of a linear code $C$ over $\mathbb{F}_q$ — which counts codewords by Hamming weight — is Lorentzian when $C$ arises from a representable matroid. The support compression theorem applied to the corresponding matroid reduces Lorentzian certification of weight enumerators to counting independent sets in the code's matroid, connecting code structure to polynomial inequality certification.

**Test.** Compute weight enumerators for Hamming codes, Reed-Muller codes, and BCH codes of small length. Verify Lorentzian property and compare support-compressed leaf counts against ambient bounds.

**Impact.** Would connect Lorentzian polynomial theory to coding theory, potentially yielding new constraints on weight distributions and new decoding-related inequalities.

**Catalog References.**
- `Pythagorean/SparseSupport/Theorems.lean` — full theorem suite
- `Speculative/AutoResearch/LorentzianMConvex.lean` — M-convexity framework

**Proof Strategy.** Linear codes define representable matroids; the weight enumerator is closely related to the Tutte polynomial. Use the matroid representation to apply Theorem 2, then translate the independent-set count into code-theoretic language (e.g., information sets, minimal codewords).

**Domain Bridges.** Coding theory ↔ matroid theory ↔ Lorentzian polynomial theory.

**Lineage.** Novel cross-domain application of the full theorem suite.

**Ambition.** Grand challenge — would open an entirely new application domain for support compression.

**The key insight is** that the matroid underlying a linear code determines both its error-correcting capability and its Lorentzian certification complexity, suggesting deep connections between code performance and polynomial geometry.

**Why now?** The formal bridge between matroid bases and Lorentzian leaves is now established; the remaining step is to instantiate it for code-theoretic matroids.
