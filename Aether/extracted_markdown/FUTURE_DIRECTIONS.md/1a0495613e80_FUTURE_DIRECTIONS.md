# Future Directions: Directional Depth Filtration for Valuated Matroids

## Synthesis

The directional depth filtration establishes a new graded invariant for valuated matroids, connecting iterated log-concavity, tropical convexity, and discrete exchange structure. The five directions below form a coherent research program: Direction 1 attacks the foundational conjecture (depth dichotomy), Direction 2 bridges to algebraic geometry via Lorentzian polynomials, Direction 3 extends the theory to handle zeros (the practical case for matroids), Direction 4 develops computational applications, and Direction 5 connects to information geometry and statistical physics. Together, they would transform the depth filtration from a theoretical invariant into a practical tool with applications across mathematics, optimization, and physics.

---

## Direction 1: Prove the Depth Dichotomy Conjecture for Graphical Matroids

**Conjecture:** For every graphical matroid with generic edge weights, the associated Boltzmann weight function has either infinite directional depth or depth exactly 1. No natural graphical matroid has depth exactly 2, 3, or any finite value > 1.

**Test:** Systematically enumerate all weighted graphical matroids on graphs up to 8 vertices and 12 edges. For each, compute depth up to level 6. Search specifically for theta graphs, K₄ minors, and Petersen-type structures, which are the most likely candidates for intermediate depth. A single example with depth exactly 2 falsifies the conjecture.

**Impact:** A proof would establish that the depth filtration captures a genuine dichotomy in combinatorial structure — analogous to the dichotomy between polynomial and exponential growth in group theory. A disproof (an explicit depth-2 example) would be equally valuable, revealing new combinatorial phenomena invisible to standard matroid invariants.

**Catalog References:** `ValuatedMatroidDepth/Theorems.lean` (exists_depth_one_not_depth_two), `ValuatedMatroidDepth/Defs.lean` (DirectionalDepthAtLeast, HasExactDepth)

**Proof Strategy:** For trees, prove infinite depth by induction on the number of edges, using the multiplicative structure of tree weight functions (they factor as products over edges). For cycles, use the cyclic symmetry to reduce to a one-parameter family and verify depth analytically. For the general case, attempt to show that overlapping circuits create a "depth barrier" at level 1 via explicit ratio transform computations.

**The key insight is** that graphical matroid weight functions have a product structure over edges that should interact with the multiplicative depth stability theorem to force infinite depth for forests, and the cycle structure should create a clean distinction at depth 1.

**Why now?** The multiplicative stability theorem (formally verified) provides the algebraic engine; the computational infrastructure exists to test thousands of small examples; and the connection to Lorentzian polynomials (Direction 2) provides theoretical guidance.

**Domain Bridges:** Combinatorial optimization (M-convexity detection), graph theory (structural graph theory via matroid depth)

**Lineage:** Builds directly on `directionalDepthAtLeast_mul` and `exists_depth_one_not_depth_two`

**Ambition:** Grand challenge — resolving this would establish depth as a fundamental matroid invariant

---

## Direction 2: Connect Infinite Depth to Lorentzian Polynomial Theory

**Conjecture:** If $P$ is a Lorentzian polynomial (in the sense of Brändén–Huh), then the coefficient function $f(m) = [x^m] P(x)$ has infinite directional depth whenever $f$ is everywhere positive.

**Test:** Verify computationally for all Lorentzian polynomials of degree ≤ 6 in ≤ 4 variables. The test cases include: elementary symmetric polynomials, volume polynomials of convex bodies, characteristic polynomials of matroids, and Schur polynomials.

**Impact:** This would provide the precise bridge between the algebraic (polynomial-level) Lorentzian theory and the combinatorial (coefficient-level) depth filtration. It would show that depth = ∞ is the coefficient shadow of the Hodge-Riemann positivity conditions, giving a new proof technique: to show a function has infinite depth, embed it as coefficients of a Lorentzian polynomial.

**Catalog References:** `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave, geometric_kFoldLogConcave), `ValuatedMatroidDepth/Theorems.lean` (negLog_supermodular_of_mixedLC)

**Proof Strategy:** The key step is to show that if $P$ is Lorentzian, then $\partial_i P / P$ evaluated at the all-ones vector gives the ratio transform of the coefficient function. Since Lorentzian polynomials are closed under differentiation (the defining property), this should give a clean inductive argument: each ratio transform corresponds to a logarithmic derivative of a Lorentzian polynomial, which is again "Lorentzian-like."

**The key insight is** that the ratio transform at the coefficient level corresponds to the logarithmic derivative at the polynomial level, and the closure of Lorentzian polynomials under differentiation should translate directly into infinite depth of their coefficient functions.

**Why now?** The Brändén–Huh theory is mature and well-understood; the depth filtration provides the missing coefficient-level language; and the formal verification infrastructure allows rigorous checking of the translation between polynomial-level and coefficient-level conditions.

**Domain Bridges:** Algebraic geometry (Hodge theory), commutative algebra (polynomial positivity)

**Lineage:** Builds on `KFoldLogConcave.mul` from the 1D theory and `directionalDepthAtLeast_mul` from the multivariate theory

**Ambition:** Grand challenge — would unify two major threads in combinatorial algebraic geometry

---

## Direction 3: Extend Depth to Functions with Zeros via Support-Aware Filtration

**Conjecture:** There exists a natural extension of the depth filtration to functions with zeros (the generic case for matroid indicators), using support-restricted log-concavity conditions, that preserves multiplicative stability and exchange detection.

**Test:** Define "support-restricted depth" where log-concavity is only checked on the support (where $f > 0$). Verify that (a) multiplicative stability holds for support-compatible products, (b) the exchange theorem generalizes, and (c) uniform matroid indicators have well-defined depth under this extension.

**Impact:** The current theory requires everywhere-positive functions, which excludes most matroid weight functions (which are zero outside their bases). Extending to functions with zeros is essential for practical applications to actual valuated matroids.

**Catalog References:** `ValuatedMatroidDepth/Defs.lean` (exchangeClosedSupport, degreeSlice), `ValuatedMatroidDepth/Exchange.lean` (weak_exchange_of_depth_one)

**Proof Strategy:** Define a modified ratio transform that is 0 when $f(m) = 0$, and define "support-directional log-concavity" as: $f(m) \cdot f(m + 2e_i) \leq f(m + e_i)^2$ whenever $f(m) > 0$. Prove that this is closed under products of functions with compatible supports. The key difficulty is ensuring that the ratio transform's support is well-behaved.

**The key insight is** that the ratio transform naturally restricts to the support, and the exchange-closed support condition ensures that the support has enough structure for the ratio transforms to interact meaningfully.

**Why now?** The positive-function theory is now complete; the exchange infrastructure (exchange moves, degree preservation) is formally verified; and the uniform matroid computations provide concrete test cases.

**Domain Bridges:** Matroid theory (basis exchange), combinatorial optimization (sparse support structures)

**Lineage:** Directly extends `weak_exchange_of_depth_one` and `exchangeClosedSupport`

**Ambition:** Solid extension — necessary for practical applicability

---

## Direction 4: Efficient Depth Computation and Algorithmic Applications

**Conjecture:** For M-convex functions on degree slices of $\mathbb{N}^n$ with $n \leq 20$ and degree $d \leq 100$, the depth can be computed in polynomial time (polynomial in the support size) up to any fixed level $k$, using structure-exploiting algorithms.

**Test:** Implement branch-and-bound algorithms that exploit monotonicity of the ratio transform (Theorem 6: ratio non-increasing) to prune the search space. Compare with the naive $O(n^k \cdot S)$ algorithm on benchmark instances from matroid optimization.

**Impact:** Depth as a practical tool for combinatorial optimization: functions with higher depth should admit faster optimization algorithms. This would connect the abstract theory to algorithm design.

**Catalog References:** `ValuatedMatroidDepth/Exchange.lean` (ratio_nonincreasing_of_depth_one), `ValuatedMatroidDepth/Theorems.lean` (directionalDepthAtLeast_mul)

**Proof Strategy:** The ratio monotonicity theorem implies that the ratio transform values decrease along each direction. This means the log-concavity check can be pruned: once a ratio drops below a threshold, all subsequent values along that direction are bounded. Formalize this pruning as a verified algorithm.

**The key insight is** that ratio monotonicity (a consequence of depth ≥ 1) provides a structural invariant that can be exploited algorithmically, potentially reducing the exponential branching factor of depth computation.

**Why now?** The ratio monotonicity theorem is formally verified; the algorithmic infrastructure exists; and there is growing interest in certified algorithms for combinatorial optimization.

**Domain Bridges:** Algorithm design, certified computation, operations research

**Lineage:** Builds on `ratio_nonincreasing_of_depth_one` and the computational experiments in `demo.py`

**Ambition:** Solid extension — connects theory to practice

---

## Direction 5: Information-Geometric Interpretation of Depth

**Conjecture:** The directional depth of a probability distribution $f$ (normalized on a degree slice) equals the order of smoothness of the associated exponential family in the information-geometric sense. Specifically, infinite depth corresponds to the distribution belonging to an exponential family with a quadratic sufficient statistic.

**Test:** Compute depth for exponential families $f(m) \propto \exp(\theta \cdot T(m))$ with polynomial sufficient statistics $T$ of increasing degree. Verify that quadratic $T$ gives infinite depth, cubic gives finite depth, and the transition is sharp.

**Impact:** This would embed the depth filtration in the framework of information geometry (Amari–Nagaoka), connecting discrete convex analysis to differential geometry of statistical manifolds. It would provide a principled interpretation of depth in terms of statistical model complexity.

**Catalog References:** `ValuatedMatroidDepth/Theorems.lean` (ratio_energy_supermodular), `ValuatedMatroidDepth/Defs.lean` (ratioTransform)

**Proof Strategy:** For exponential families, $-\log f(m) = -\theta \cdot T(m) + \log Z(\theta)$. The ratio transform gives $R_i f(m) = \exp(\theta \cdot [T(m+e_i) - T(m)])$. If $T$ is quadratic, $T(m+e_i) - T(m)$ is affine in $m$, so $R_i f$ is an exponential-affine function, which is automatically log-concave. Iterate: the next ratio transform of an exponential-affine function is exponential-constant, which is trivially log-concave to all orders.

**The key insight is** that quadratic sufficient statistics produce ratio transforms that are exponential-linear, and exponential-linear functions have infinite depth because each subsequent ratio transform reduces the polynomial degree by 1, eventually reaching constants.

**Why now?** The formal connection between ratio transforms and chemical potentials (Theorem 4) is established; information geometry provides the natural mathematical framework; and the computational experiments confirm the quadratic/non-quadratic dichotomy.

**Domain Bridges:** Information geometry, statistical physics (exponential families), machine learning (natural gradient methods)

**Lineage:** Builds on `ratio_energy_supermodular` and the statistical mechanics interpretation

**Ambition:** Grand challenge — would bridge discrete convex analysis and information geometry
