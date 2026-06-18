# Future Directions: Support-Compressed Lorentzian Certificates

## Synthesis

The discovery that Lorentzian recognition complexity for matroid basis polynomials equals the independent-set count at rank $r-2$ opens a new interface between discrete convex analysis, algorithmic complexity, and polynomial certification. The five directions below form a coherent research program: Direction 1 builds the polynomial-level bridge that our combinatorial theorems currently bypass; Direction 2 specializes to graph theory, connecting certificate complexity to classical graph enumeration; Direction 3 pursues compositionality, the key to scaling; Direction 4 bridges to statistical physics, where partition-function certification has immediate applications; and Direction 5 is the grand challenge—recasting discrete convexity itself as a complexity theory for symbolic inequalities.

---

## Direction 1: End-to-End Polynomial Derivative Formalization

**Conjecture:** For any multiaffine polynomial $p = \sum_{\beta \in S} c_\beta x^\beta$ with $c_\beta > 0$ for all $\beta \in S$, the iterated partial derivative $\partial^\alpha p$ is nonzero if and only if $\exists \beta \in S: \alpha \leq \beta$ (componentwise), with the proof proceeding entirely within the MvPolynomial API.

**Test:** Formalize the monomial derivative lemma ($\partial^\alpha(x^\beta) = 0$ unless $\alpha \leq \beta$) using `MvPolynomial.pderiv`, prove the non-cancellation property for polynomials with distinct monomials and positive coefficients, and derive the support criterion as a consequence. The test passes if the full chain from `MvPolynomial.coeff` to the independence predicate compiles without sorry.

**Impact:** Closes the formalization gap between our combinatorial theorem and the actual polynomial objects. Makes the result directly applicable to any Lean 4 project working with multivariate polynomials.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`coeff_pderiv_eq`, `newtonSupport_pderiv_eq`), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (`iteratedPDeriv`).

**Proof Strategy:** Induction on the number of variables differentiated. Base case: single partial derivative, using `coeff_pderiv_eq` from the catalog. Inductive step: compose with the next derivative, using the fact that the support of the intermediate result is exactly $\{\beta - \alpha' : \alpha' \leq \beta, \beta \in S\}$ where $\alpha'$ is the partial derivative applied so far.

**Domain Bridges:** Connects formal methods (Lean 4) with symbolic computation (polynomial arithmetic).

**Lineage:** Extends `coeff_pderiv_eq` and `newtonSupport_pderiv_eq` from the LorentzianMConvex catalog.

**Ambition:** Solid extension — completes an existing proof chain.

---

## Direction 2: Graphic Matroid Forests and Kirchhoff Connections

**Conjecture:** For the graphic matroid of a connected graph $G$ with $m$ edges and $n$ vertices (rank $r = n - 1$), the quadratic leaf count equals the number of forests of size $r - 2 = n - 3$ in $G$, and this quantity satisfies

$$\text{leafCount}(G) = \sum_{e, f} \tau(G / e / f)$$

where $\tau$ denotes the number of spanning trees and the sum ranges over pairs of edges whose contraction leaves a connected graph. This connects certificate complexity to a deletion-contraction invariant computable via Kirchhoff's matrix-tree theorem.

**Test:** Verify computationally for all graphs on $\leq 7$ vertices that the forest count equals the Kirchhoff-based formula. Formalize the identity for trees (where $\text{leafCount} = \binom{n-1}{n-3}$) and cycles (where the formula has a closed form involving $n$).

**Impact:** Converts Lorentzian certification complexity into a classical graph invariant, enabling the use of spectral graph theory and Kirchhoff's theorem for complexity analysis. Could lead to polynomial-time computation of certificate sizes for planar graphs.

**Catalog References:** `Pythagorean/SparseLorentzianCertificates.lean` (`BasisFamily`, `indepCount`).

**Proof Strategy:** Use the matrix-tree theorem to express spanning tree counts as determinants. The forest count at size $r-2$ is a sum of cofactors of the graph Laplacian. Relate this sum to a deletion-contraction recursion.

**Domain Bridges:** Graph theory ↔ algebraic complexity, spectral graph theory ↔ certificate enumeration.

**Lineage:** Builds on `leafCount_uniformMatroid` and the graphic matroid constructor.

**Ambition:** Solid extension with potential for surprising connections to spectral theory.

---

## Direction 3: Compositional Certificates via Matroid Operations

**Conjecture:** For the direct sum $M_1 \oplus M_2$ of two matroids, the quadratic leaf count satisfies

$$\text{leafCount}(M_1 \oplus M_2) = \sum_{k=0}^{r_1 - 2} \text{indepCount}(M_1, k) \cdot \text{indepCount}(M_2, r_2 - 2 - k + r_1 - 2 - k)$$

(with appropriate index adjustments), and for the matroid 2-sum, a corresponding but more complex multiplicative formula holds. This would enable modular certificate computation.

**The key insight is** that direct sum decomposes the independent-set complex into a join of the individual complexes, and certificate complexity should decompose accordingly.

**Why now?** The identification of leaf count with independent-set count makes this decomposition question precise and testable.

**Test:** Verify computationally for all matroid direct sums on $\leq 10$ elements. Formalize the direct sum case in Lean 4.

**Impact:** Enables certificates for large matroids built from small pieces, reducing exponential enumeration to polynomial combination of sub-certificates.

**Catalog References:** `Pythagorean/SparseLorentzianCertificates.lean` (`indepCount`, `BasisFamily`).

**Proof Strategy:** For direct sums, an independent set decomposes as a disjoint union of independent sets in each component. The $(r-2)$-sets decompose by how many elements come from each component, giving a convolution formula.

**Domain Bridges:** Matroid decomposition theory ↔ modular verification, connecting to graph decomposition in network science.

**Lineage:** Extends the basis family framework to matroid operations.

**Ambition:** Grand challenge — would transform how large-scale certification is done.

---

## Direction 4: Partition Function Certification in Statistical Physics

**Conjecture:** For the random cluster model partition function $Z_G(q, v) = \sum_{A \subseteq E} q^{k(A)} v^{|A|}$ of a sparse graph $G$, the Lorentzian certification complexity (measured by nonzero quadratic leaves) is polynomially bounded in the number of edges $m$ when $G$ has bounded treewidth, even though the ambient bound is exponential.

**The key insight is** that bounded treewidth implies bounded independent-set complexity for the associated matroid, and our support compression theorem converts this structural sparsity into certificate compression.

**Why now?** The explicit connection between leaf count and independent-set count makes treewidth-based bounds directly applicable, leveraging decades of algorithmic results on bounded-treewidth graphs.

**Test:** Compute certification complexity for grid graphs $P_k \times P_l$ of increasing size and verify polynomial scaling. Compare with the exponential ambient bound.

**Impact:** Would provide the first provably efficient Lorentzian certification for a physically relevant class of partition functions, with applications to approximate counting and sampling in statistical physics.

**Catalog References:** `Pythagorean/SparseLorentzianCertificates.lean` (all main theorems), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`IsMConvexExchangeNat`).

**Proof Strategy:** Use the bounded-treewidth hypothesis to bound the number of independent sets via dynamic programming on tree decompositions. Combine with the support compression theorem.

**Domain Bridges:** Statistical physics ↔ matroid theory ↔ parameterized complexity. Connects Lorentzian polynomial theory to the Potts model and percolation theory.

**Lineage:** Extends the graphic matroid specialization to weighted polynomials and physical partition functions.

**Ambition:** Grand challenge — would open Lorentzian methods to the statistical physics community.

---

## Direction 5: Discrete Convexity as Complexity Theory for Symbolic Inequalities

**Conjecture:** There exists a hierarchy of support structures—from M-convex sets (matroid bases) through L-convex and integrally convex sets to general Newton polytopes—such that the Lorentzian certification complexity of a polynomial is controlled by the position of its support in this hierarchy. Specifically, M-convex supports yield the strongest compression (independent-set complexity), while general supports admit no compression beyond the ambient bound.

**The key insight is** that M-convexity is not merely a geometric property of the support but a *complexity-theoretic* property governing how efficiently Lorentzian certificates can be compressed. The exchange axiom is a pruning principle for derivative search trees.

**Why now?** Our work provides the first concrete instance (M-convex → matroid independence → leaf count), and the M-convex exchange theory in the catalog (`IsMConvexExchangeNat`) provides the formal starting point.

**Test:** Define a "certificate compression ratio" for polynomials with various support types (M-convex, L-convex, integrally convex, arbitrary). Compute this ratio for random instances of each type and test whether the hierarchy prediction holds.

**Impact:** Would establish a new field: *combinatorial certificate complexity*, where the difficulty of proving polynomial inequalities is classified by the discrete geometry of the support. This bridges discrete convex analysis, algebraic complexity theory, and formal verification.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (`IsMConvexExchangeNat`, `NewtonSupport`), `Pythagorean/SparseLorentzianCertificates.lean` (all main theorems).

**Proof Strategy:** Start with M-convex (proved). For L-convex, use the L-convex exchange property to characterize derivative survival. For integrally convex, show that the support criterion still holds but the combinatorial complexity increases. For general supports, construct adversarial examples where no compression is possible.

**Domain Bridges:** Discrete convex analysis (Murota) ↔ algebraic complexity theory ↔ formal verification ↔ combinatorial optimization. Potentially connects to circuit complexity through polynomial identity testing.

**Lineage:** The culmination of the entire research line, synthesizing support compression, M-convexity, and certification complexity.

**Ambition:** Grand challenge — would create a new subfield at the intersection of discrete mathematics and complexity theory.
