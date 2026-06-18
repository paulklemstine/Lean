# Future Directions: Support-Compressed Lorentzian Certification

## Synthesis

The derivative survival theorem establishes a fundamental bridge between polynomial certification complexity and matroid combinatorics. By proving that nonzero quadratic derivative leaves of basis generating polynomials are in exact bijection with independent (r−2)-sets, we open five distinct research frontiers. These range from immediate extensions (graphic matroid specialization, asymptotic bounds) to paradigm-shifting conjectures (discrete convexity as complexity theory, tropical certificate geometry). The unifying thread is that **support geometry controls computational cost** — a principle that should extend far beyond the matroid setting, into statistical physics, coding theory, and algorithmic convex optimization.

---

## Direction 1: Graphic Matroid Forest Counting

**Conjecture:** For a connected graph G with m edges and n vertices, the nonzero quadratic leaf count of B_{M(G)} equals the number of forests on m edges of size n−3 (i.e., spanning forests minus 2 edges). Equivalently:

$$\text{SCLC}(M(G)) = \#\{F \subseteq E(G) : |F| = n-3,\ F \text{ is acyclic}\}$$

Moreover, for sparse graphs (m = O(n)), this count grows as O(n^{n-3}) at most, while the ambient count C(m, n−3) can grow much faster.

**Test:** Compute the forest count for random Erdős–Rényi graphs G(n, p) at various edge densities p, and compare to the ambient count C(m, n−3). Plot the ratio as a function of edge density. The conjecture predicts a phase transition: below a critical density, the ratio converges to 0 as n → ∞.

**Impact:** This would connect Lorentzian certification complexity to classical graph enumeration (Cayley's formula, matrix tree theorem), enabling existing graph-theoretic algorithms to be repurposed for polynomial certification.

**Catalog References:** `Pythagorean/CertificateCompression.lean` (Theorem 1: `derivByList_basisGenPoly_ne_zero_iff`), `Speculative/AutoResearch/LorentzianMConvex.lean` (M-convex exchange).

**Proof Strategy:** Define the graphic matroid formally via `SimpleGraph.Matroid` (to be developed). Prove that independence in the graphic matroid equals acyclicity. Then apply Theorem 1 to identify leaves with forests.

**Domain Bridges:** Graph theory, algebraic graph theory (Kirchhoff's theorem), network reliability.

**Lineage:** Extends the derivative survival theorem from abstract basis families to graph-specific combinatorics.

**Ambition:** Extension — directly builds on proven infrastructure. Grand challenge component: connecting to Kirchhoff's matrix tree theorem.

---

## Direction 2: Discrete Convexity as Certificate Complexity Theory

**Conjecture:** For any homogeneous polynomial f with nonneg coefficients whose Newton support S is M-convex, the certificate complexity (number of nonzero degree-(d−2) derivative leaves) is at most:

$$\text{CC}(f) \leq \max_{\alpha \in S} |\{I \subseteq \text{supp}(\alpha) : |I| = d-2\}|^{O(1)}$$

where the bound depends polynomially on the local combinatorics of S, not on the ambient dimension n.

**The key insight is** that M-convex exchange constrains the "shadow" of the support under differentiation, so that derivative branches cannot proliferate faster than the exchange structure allows. This would make M-convexity a *computational* property, not just a geometric one.

**Why now?** The derivative survival theorem (Theorem 1) proves the matroid case exactly. The M-convex exchange property (`IsMConvexExchangeNat` in the catalog) is already formalized. The gap is proving that exchange controls derivative shadows for general M-convex sets, not just matroid indicator sets.

**Test:** Compute derivative leaf counts for polynomials with M-convex but non-matroidal supports (e.g., Schur polynomials, elementary symmetric polynomials of non-uniform degree). Compare to ambient counts.

**Impact:** Would establish discrete convexity as a *complexity-theoretic* tool, with applications to optimization, machine learning (log-concave sampling), and algorithmic algebra.

**Catalog References:** `Speculative/AutoResearch/LorentzianMConvex.lean` (`IsMConvexExchangeNat`, `lorentzian_quadratic_support_mconvex`), `Pythagorean/CertificateCompression.lean`.

**Proof Strategy:** Generalize the non-cancellation argument from indicator monomials (0/1 exponents) to arbitrary M-convex supports. The key step is showing that the "shifted shadow" map β ↦ β − α preserves distinctness within M-convex families.

**Domain Bridges:** Discrete convex analysis, combinatorial optimization, machine learning (log-concave distribution sampling).

**Lineage:** Combines the M-convex formalization from `LorentzianMConvex.lean` with the certificate compression framework.

**Ambition:** Grand challenge — would redefine the relationship between discrete geometry and computational complexity.

---

## Direction 3: Statistical Physics Partition Function Certification

**Conjecture:** For the partition function Z_G(β) of a ferromagnetic Ising model on graph G at inverse temperature β, the Lorentzian certification cost (derivative leaf count) is polynomial in the number of edges, not exponential in the number of vertices.

**The key insight is** that ferromagnetic Ising partition functions are log-concave (in appropriate coordinates) and their supports are constrained by the graph structure. The derivative survival theorem, extended to these partition functions, should yield a polynomial certificate.

**Why now?** Log-concavity of Ising partition functions was established by recent work connecting them to Lorentzian polynomials. Our framework provides the first quantitative control on certification cost. The barrier was the absence of a support-geometric analysis of the derivative tree.

**Test:** Compute the partition function for small Ising models (complete graphs K_n, lattice grids) and count the nonzero derivative branches. Verify that the count is polynomial in graph parameters.

**Impact:** Polynomial-time certification of partition function properties would have immediate applications in approximate counting, sampling algorithms (MCMC convergence bounds), and computational phase transition detection.

**Catalog References:** `Pythagorean/CertificateCompression.lean`, `Speculative/AutoResearch/LorentzianMConvex.lean`.

**Proof Strategy:** Express the Ising partition function as a sum over configurations with positive coefficients. Apply the derivative survival criterion. Use the graph structure to bound the number of independent configurations of a given size.

**Domain Bridges:** Statistical physics, approximate counting, MCMC algorithms, condensed matter physics.

**Lineage:** Extends the matroid-specific results to general graph-structured partition functions.

**Ambition:** Grand challenge — would bridge formal mathematics and computational statistical physics.

---

## Direction 4: Tropical Certificate Geometry

**Conjecture:** The tropical variety of a Lorentzian polynomial's support (the piecewise-linear locus in ℝⁿ dual to the Newton polytope) determines the derivative tree structure. Specifically, the tropical intersection number of the support with the "derivative hyperplane arrangement" equals the nonzero leaf count.

**The key insight is** that tropicalization preserves the combinatorial shadow of differentiation. A derivative ∂^α f is nonzero iff α lies in the tropical variety's "inner shadow," and the leaf count is the number of lattice points in this shadow at the appropriate degree.

**Why now?** Tropical geometry of Lorentzian polynomials has been studied by Brändén–Huh, but the connection to *computational* complexity (derivative tree size) is new. Our theorem provides the first exact result (for matroids) that validates the tropical prediction.

**Test:** For matroid polytopes (base polytopes), compute the tropical shadow and verify it matches the independent-set count from Theorem 2.

**Impact:** Would provide a geometric visualization of certificate complexity, potentially enabling dimension-reduction techniques from tropical geometry to speed up Lorentzian certification.

**Catalog References:** `Pythagorean/CertificateCompression.lean` (`NonzeroQuadraticLeafSet` concept), `Speculative/AutoResearch/LorentzianMConvex.lean`.

**Proof Strategy:** Formalize the Newton polytope of the basis generating polynomial. Show its normal fan structure encodes the derivative tree. Use the theory of mixed volumes to compute intersection numbers.

**Domain Bridges:** Tropical geometry, algebraic geometry, combinatorial optimization (matroid polytopes).

**Lineage:** Provides geometric interpretation of the combinatorial certificate compression.

**Ambition:** Extension with grand-challenge elements — requires developing new connections between tropical geometry and complexity theory.

---

## Direction 5: Error-Correcting Code Weight Enumerators

**Conjecture:** For a linear code C over F_q with weight enumerator W_C(x, y), the Lorentzian certification cost of the homogenized weight enumerator is controlled by the code's minimum distance and dual distance. Specifically:

$$\text{SCLC}(W_C) \leq C(n, d^{\perp} - 2)$$

where d^⊥ is the minimum distance of the dual code.

**The key insight is** that the support of a weight enumerator is constrained by the MacWilliams identities, which impose M-convexity-like exchange properties on the coefficient sequence. Codes with large minimum distance have sparse supports, leading to compressed certificates.

**Why now?** The connection between matroid basis polynomials and code weight enumerators (via representable matroids over F_q) is classical. Our certificate compression framework provides the first quantitative link between coding parameters and certification complexity.

**Test:** Compute certificate complexity for Hamming codes, Reed–Solomon codes, and random linear codes. Compare to ambient C(n, r−2) counts.

**Impact:** Would provide new tools for verifying code optimality and understanding the structure of good codes through the lens of polynomial certification.

**Catalog References:** `Pythagorean/CertificateCompression.lean` (Theorem 4: `indepCount_le_active_choose`).

**Proof Strategy:** Represent the code's matroid as a representable matroid over F_q. Apply the support compression bound. Use coding-theoretic bounds (Singleton, Plotkin) to estimate the independent-set count.

**Domain Bridges:** Coding theory, information theory, combinatorial optimization.

**Lineage:** Applies the active variable bound (Theorem 4) to a new domain.

**Ambition:** Extension — applies existing theorems to an important new class of examples.
