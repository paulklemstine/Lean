# Future Directions: Directional Depth Filtration for Valuated Matroids

## Synthesis

The directional depth filtration creates a new bridge between three historically separate mathematical traditions: discrete convex analysis (Murota), tropical geometry (Maclagan–Sturmfels), and Hodge-theoretic positivity (Brändén–Huh). The five proved theorems establish the algebraic backbone (multiplicative stability), the tropical bridge (neglog supermodularity), and hierarchy strictness. The following directions extend this foundation in complementary ways: Direction 1 aims to close the loop between depth and Lorentzian polynomials, providing a characterization theorem. Direction 2 pushes the tropical bridge into full M-convexity refinement. Direction 3 builds the algorithmic infrastructure needed for large-scale computation. Direction 4 connects depth to sampling and Markov chain theory, opening applications in statistics and physics. Direction 5 explores the grand challenge of a tropical Hodge theory built on depth layers. Together, these directions form a coherent program that could establish higher discrete curvature theory as a new subfield.

---

## Direction 1: Infinite Depth ↔ Lorentzian Polynomial Characterization

**Conjecture:** A positive function $f$ on $\mathbb{N}^\alpha$ supported on a degree-$d$ slice has infinite directional depth if and only if the homogeneous polynomial $P_f(x) = \sum_m f(m) x^m$ is Lorentzian in the sense of Brändén–Huh.

**The key insight is** that infinite depth — persistence of log-concavity under all iterated ratio transforms — is the discrete analog of complete positivity of the Hessian quadratic form at every point of the support, which is exactly the defining condition of Lorentzian polynomials.

**Why now?** The machinery of Lorentzian polynomials [BH20] provides the algebraic-geometric tools, while our formalized depth filtration provides the combinatorial tools. The ratio transform $R_i$ corresponds to the operator $\partial/\partial x_i$ on polynomials (up to normalization), so depth corresponds to the order up to which partial derivatives preserve log-concavity — precisely the recursive characterization of Lorentzian polynomials.

**Test:** Implement the Lorentzian polynomial check for small polynomial families (multinomial coefficients, basis generating polynomials of graphical matroids) and verify agreement with computed directional depth. A single disagreement falsifies the conjecture.

**Impact:** If true, this would give an elementary, iterative characterization of Lorentzian polynomials — currently defined through algebraic geometry. This could make Lorentzian polynomial theory accessible to combinatorialists and computer scientists without algebraic geometry background.

**Catalog References:** `ValuatedMatroidDepth/Theorems.lean` (directionalDepthAtLeast_mul, exists_depth_one_not_depth_two).

**Proof Strategy:** Forward direction (Lorentzian ⟹ infinite depth): use the recursive characterization of Lorentzian polynomials. Reverse direction (infinite depth ⟹ Lorentzian): this is harder and may require new theory connecting the ratio transform to the operator $x_i \partial/\partial x_i$ on polynomials.

**Domain Bridges:** Algebraic geometry (Lorentzian polynomials), combinatorics (matroid theory), real algebraic geometry (positive polynomials).

**Lineage:** Extends Theorem 5 (hierarchy strictness) and Theorem 1 (multiplicative stability).

**Ambition:** Grand challenge. If successful, this unifies two of the most powerful tools in modern combinatorics.

---

## Direction 2: Full M-Convexity Refinement via Depth Layers

**Conjecture:** For a function $f$ on the degree-$d$ slice with exchange-closed support, depth $\geq k$ implies a quantitative strengthening of the M-convexity exchange axiom involving $k$-step neighborhoods rather than single exchanges.

**The key insight is** that each depth layer provides an additional constraint on the tropicalized valuation $v = -\log f$, and these constraints should correspond to multi-step exchange inequalities that refine Murota's single-step axiom.

**Why now?** The weak exchange theorem connecting depth 1 and supermodularity to M-convexity exchange is implicit in our Theorem 2. Formalizing the full chain — from depth $k$ to $k$-step exchange — would require developing the theory of exchange neighborhoods on degree slices, which is tractable given our infrastructure.

**Test:** For graphical matroids with known M-convexity structure, verify that depth $k$ implies the $k$-step exchange inequality computationally.

**Impact:** Would establish the depth filtration as a proper refinement of discrete convex analysis, with applications to faster algorithms for M-convex optimization.

**Catalog References:** `ValuatedMatroidDepth/Defs.lean` (exchangeClosedSupport, exchangeMove, degreeSlice).

**Proof Strategy:** Define $k$-step exchange neighborhoods inductively. Show that depth $k$ with supermodularity gives $k$-step descent inequalities via iterated application of the tropical bridge theorem.

**Domain Bridges:** Discrete convex analysis (Murota), combinatorial optimization (submodular function minimization), auction theory (Walrasian equilibria).

**Lineage:** Direct extension of Theorems 2 and 3.

**Ambition:** Solid extension. Achievable within one research cycle with the current infrastructure.

---

## Direction 3: Efficient Depth Computation for Structured Families

**Conjecture:** For graphical matroids on graphs with $n$ vertices and $m$ edges, the directional depth can be determined in time polynomial in $n$ and $m$ (for fixed depth bound $k$).

**The key insight is** that graphical matroid structure — particularly the relationship between graph connectivity and matroid circuits — should allow the log-concavity check to be reduced to graph-theoretic conditions, avoiding the exponential enumeration of multi-indices.

**Why now?** Our brute-force algorithm works for small examples but scales poorly. The graph-theoretic structure of spanning tree polynomials (Kirchhoff's matrix-tree theorem) suggests that ratio transforms of graphical matroid functions can be expressed in terms of modified Laplacians, enabling spectral methods.

**Test:** Implement a spectral method for computing the ratio transform of spanning tree polynomials and compare runtime with the brute-force algorithm on graphs up to 20 vertices.

**Impact:** Would make depth computation practical for real-world network optimization and statistical mechanics applications.

**Catalog References:** `demo.py` (graphical_matroid function), `algorithms.py` (compute_directional_depth).

**Proof Strategy:** Express the spanning tree polynomial as $\det(L)$ (Kirchhoff). Show that the ratio transform corresponds to a rank-1 update of the Laplacian. Use Cauchy's interlacing theorem or Sylvester's determinant identity to bound the log-concavity check.

**Domain Bridges:** Spectral graph theory, numerical linear algebra, network science.

**Lineage:** Builds on computational experiments in demo.py.

**Ambition:** Solid extension. The spectral approach is well-established for related problems.

---

## Direction 4: Depth and Markov Chain Mixing Times

**Conjecture:** For a positive function $f$ on the degree-$d$ slice with depth $\geq k$, the natural basis-exchange Markov chain (Metropolis–Hastings with target $f$) mixes in time $O(n^{c/k})$ for some constant $c$.

**The key insight is** that depth measures the convexity of the energy landscape $-\log f$ at multiple scales. Deeper convexity should translate to faster mixing, because the Markov chain has stronger drift toward equilibrium at every renormalization level.

**Why now?** Recent breakthroughs in sampling from log-concave distributions (Lovász–Vempala, Lee–Vempala) have established deep connections between geometric properties of distributions and mixing times. Our depth filtration provides a finer geometric invariant that could yield tighter mixing time bounds.

**Test:** Implement basis-exchange Markov chains for graphical matroids with varying depth. Measure empirical mixing times and correlate with computed depth.

**Impact:** Would provide the first quantitative connection between higher log-concavity and sampling efficiency, with applications to statistical inference, Bayesian computation, and physics simulation.

**Catalog References:** `ValuatedMatroidDepth/Theorems.lean` (ratio_energy_supermodular for the response convexity that drives mixing).

**Proof Strategy:** Use the Poincaré inequality approach. Show that depth $k$ implies a Poincaré constant bound via iterated comparison of Dirichlet forms, leveraging the tower of supermodular potentials from the tropical bridge.

**Domain Bridges:** Probability theory (Markov chains), statistical mechanics (Glauber dynamics), theoretical computer science (counting/sampling).

**Lineage:** Extension of Theorem 4 (response convexity) to dynamical consequences.

**Ambition:** Grand challenge. The connection between discrete convexity and mixing times is an active frontier.

---

## Direction 5: Tropical Hodge Theory from Depth Layers

**Conjecture:** The depth filtration induces a tropical analog of the Hodge filtration on the cohomology of a toric variety, with depth $k$ corresponding to the $k$-th Hodge level.

**The key insight is** that the iterated ratio transform $R_{i_1} \circ \cdots \circ R_{i_k}$ produces functions that play the role of mixed partial derivatives $\partial_{i_1} \cdots \partial_{i_k}(-\log f)$, and the log-concavity conditions on these iterates are discrete analogs of the Hodge-Riemann bilinear relations at level $k$.

**Why now?** Adiprasito, Huh, and Katz [AHK18] proved the Hodge-Riemann relations for matroids using algebraic geometry. Our depth filtration provides a purely combinatorial route to the same phenomena, suggesting that the Hodge structure might be accessible through elementary ratio-transform operations.

**Test:** For matroids associated to toric varieties (e.g., uniform matroids associated to projective spaces), verify that depth levels correspond to the Hodge levels of the cohomology ring.

**Impact:** Would establish a new, elementary foundation for tropical Hodge theory, potentially leading to constructive proofs of the Kähler package for matroids.

**Catalog References:** `ValuatedMatroidDepth/Theorems.lean` (negLog_supermodular_of_mixedLC as the first level of the Hodge correspondence).

**Proof Strategy:** Define a tropical cohomology ring using the iterated ratio transforms as differential operators. Show that the Hodge-Riemann bilinear form at level $k$ corresponds to the log-concavity condition at depth $k$. Use the multiplicative stability theorem to establish the hard Lefschetz property.

**Domain Bridges:** Algebraic geometry (Hodge theory), tropical geometry (tropical cohomology), combinatorial algebraic geometry (matroid Chow rings).

**Lineage:** Grand synthesis of all five main theorems.

**Ambition:** Grand challenge. If successful, this would be a major breakthrough connecting elementary combinatorial operations to deep algebraic geometry.
