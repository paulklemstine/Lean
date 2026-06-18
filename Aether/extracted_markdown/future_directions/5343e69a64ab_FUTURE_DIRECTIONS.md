# Future Directions: Directional Depth Theory for Valuated Matroids

## Synthesis

The directional depth filtration established in this work creates a new invariant for functions on integer lattice points that simultaneously captures iterated log-concavity, tropical convexity persistence, and proto-Lorentzian structure. The five directions below form a coherent program: Direction 1 (Lorentzian connection) provides the algebraic foundation, Direction 2 (support-aware depth) extends applicability to combinatorial objects with zeros, Direction 3 (algorithmic applications) delivers computational impact, Direction 4 (phase transitions) bridges to statistical physics, and Direction 5 (categorical structure) provides the abstract framework unifying them all. Together, they constitute a research program to develop **higher discrete curvature theory** as a new subfield spanning combinatorics, tropical geometry, and mathematical physics.

---

## Direction 1: Infinite Depth Characterization via Lorentzian Polynomials

**Conjecture**: Every function arising as the coefficient function of a Lorentzian polynomial (in the sense of Brändén–Huh) has infinite directional depth. Conversely, infinite depth on a degree slice with exchange-closed support characterizes Lorentzian-origin valuations among all valuated matroids.

**The key insight is** that the Hessian contraction property of Lorentzian polynomials — the defining recursive condition that all directional derivatives preserve the Lorentzian sign pattern — is structurally parallel to our depth recursion, where ratio transforms (discrete logarithmic derivatives) preserve log-concavity. Establishing this equivalence would show that depth = ∞ is precisely the discrete shadow of the Lorentzian condition.

**Why now?** The recent proof by Brändén–Huh that Lorentzian polynomials are closed under a wide class of linear operators provides exactly the tool needed to show that ratio transforms (which are multiplicative analogs of differentiation) preserve the Lorentzian condition. The theory of completely log-concave polynomials by Anari–Liu–Oveis Gharan–Vinzant gives complementary techniques for the converse direction.

**Test**: Implement the Lorentzian polynomial checker for small (n ≤ 5, d ≤ 6) examples and verify that every Lorentzian coefficient function has depth exceeding any tested bound. Construct a non-Lorentzian function of infinite depth (if one exists) to disprove the converse, or prove the converse for n = 2.

**Impact**: This would establish depth as the correct discrete analog of Lorentzian polynomial theory, creating a bridge between Hodge theory and tropical convexity.

**Catalog References**: `Pythagorean/ValuatedMatroidDepth/Theorems.lean` — `directionalDepthAtLeast_mul`, `negLog_supermodular_of_depth_one`; `Catalog/Pythagorean/HigherOrderLogConcavity.lean` — `KFoldLogConcave.mul`, `geometric_kFoldLogConcave`.

**Proof Strategy**: For the forward direction, use induction on depth. At each level, the Hessian contraction gives a Lorentzian polynomial whose coefficients are the ratio-transformed values. For the converse, show that infinite depth + exchange-closure implies the tropical Plücker relations, which characterize Lorentzian polynomials by the Dress–Wenzel theorem.

**Domain Bridges**: Algebraic geometry (Hodge–Riemann relations), matroid theory (Chow ring positivity).

**Lineage**: Extends Brändén–Huh 2020, Adiprasito–Huh–Katz 2018.

**Ambition**: grand_challenge — would unify two major threads in modern combinatorics.

---

## Direction 2: Support-Aware Depth for Functions with Zeros

**Conjecture**: There exists a well-defined notion of "support-aware directional depth" for functions f : (α → ℕ) → ℝ≥0 that may have zeros, such that: (a) it agrees with ordinary depth on globally positive functions, (b) it is ≥ 1 for all M-convex functions, and (c) it is multiplicative.

**The key insight is** that the current theory requires positivity to define ratio transforms (avoiding 0/0). By restricting the log-concavity condition to the "tropical support" — the set of multi-indices where f is positive — and defining the ratio transform only on the interior of this support, one can extend depth to functions with zeros. The exchange-closed support condition (already formalized) provides the correct notion of "well-behaved boundary."

**Why now?** The weak exchange theorem proved in our formalization already connects exchange-closed support to the depth machinery. The missing piece is a careful treatment of boundary effects in the ratio transform, which requires techniques from tropical convexity theory (specifically, the theory of tropical linear spaces as developed by Speyer and Sturmfels).

**Test**: Implement support-aware depth for uniform matroid indicators U(r, n) and verify that the depth is consistently 1 (matching the dichotomy conjecture). Check that the multiplicativity theorem extends to the support-aware setting for products of matroid indicators.

**Impact**: Would make the depth invariant applicable to all valuated matroids, not just positive-valued ones.

**Catalog References**: `Pythagorean/ValuatedMatroidDepth/Defs.lean` — `ExchangeClosedSupport`, `ExchangeMove`; `Pythagorean/ValuatedMatroidDepth/Theorems.lean` — `weak_exchange_of_depth_one`, `exchangeMove_degree`.

**Proof Strategy**: Define SupportAwareDepth by replacing the universal quantifiers in DirectionalLogConcave with quantifiers restricted to the tropical support. Prove multiplicativity by showing that the support of a product is the intersection of supports, and that exchange-closure is preserved under intersection.

**Domain Bridges**: Tropical geometry (tropical linear spaces), discrete convex analysis (M-convex functions).

**Lineage**: Extends Murota 2003, Dress–Wenzel 1992.

**Ambition**: solid_extension — necessary infrastructure for applying the theory to real matroid problems.

---

## Direction 3: Depth as a Convexity Certificate in Discrete Optimization

**Conjecture**: For discrete optimization problems on M-convex domains, the directional depth of the objective function provides a quantitative convergence guarantee: depth-k functions admit optimization algorithms with convergence rate O(n^k / ε) on domains of dimension n.

**The key insight is** that depth measures the "smoothness" of the discrete energy landscape. In continuous optimization, higher regularity (Lipschitz gradient, Lipschitz Hessian, etc.) gives faster convergence. The depth filtration is the discrete analog: depth 1 gives convexity (gradient descent works), depth 2 gives convex Hessian (Newton's method works), and higher depth should give even faster methods.

**Why now?** Recent work on discrete convex optimization (Murota's algorithm for M-convex minimization, and the AHK framework for matroid intersection) provides the algorithmic foundation. The depth theory provides the missing "regularity certificate" that these algorithms implicitly assume but do not measure.

**Test**: Implement a depth-aware steepest descent algorithm for M-convex minimization. Compare convergence on depth-1 vs. depth-∞ functions on degree slices of dimension n ∈ {5, ..., 15}. Verify that higher depth correlates with faster convergence.

**Impact**: Would give the first quantitative connection between the algebraic structure of a valuated matroid and the computational complexity of optimization over it.

**Catalog References**: `Pythagorean/ValuatedMatroidDepth/Theorems.lean` — `negLog_supermodular_of_depth_one`, `ratio_energy_supermodular`.

**Proof Strategy**: For depth 1, use the supermodularity of −log f to show that steepest descent converges in O(n/ε) steps (analogous to gradient descent for convex functions). For depth 2, use the supermodularity of the ratio transform to show that a Newton-like method converges in O(log(n/ε)) steps.

**Domain Bridges**: Combinatorial optimization (matroid intersection), algorithmic game theory (gross substitutes).

**Lineage**: Extends Murota 2003, Anari et al. 2021.

**Ambition**: solid_extension — directly actionable with existing algorithmic tools.

---

## Direction 4: Depth and Phase Transitions in Statistical Mechanics

**Conjecture**: For the Ising model partition function on a graph G at inverse temperature β, the directional depth is infinite for β < β_c (high-temperature phase) and drops to 1 at β = β_c (the critical point). The depth transition precisely detects the phase transition.

**The key insight is** that the partition function Z(m) = Σ exp(−βH(σ)) viewed as a function of external field parameters m is deeply log-concave in the high-temperature phase (where the system is essentially a product measure) and loses higher-order log-concavity at the phase transition (where long-range correlations destroy the factorization structure that powers the multiplicativity theorem).

**Why now?** The recent proof of the Lee–Yang theorem for the Ising model (Bencs, Buys, Peters 2024) and the connection between log-concavity and strong spatial mixing (Anari et al. 2021) provide the technical tools to relate depth to correlation decay. Our multiplicativity theorem gives the key structural input: product measures (independent systems) have infinite depth, so the question reduces to understanding how interactions degrade depth.

**Test**: Compute the directional depth of the Ising partition function on the 4 × 4 grid at temperatures β ∈ {0.1, 0.2, ..., 2.0}. Plot depth vs. β and compare the depth transition with the known critical temperature. Repeat for the triangular and hexagonal lattices.

**Impact**: Would establish depth as a statistical-mechanical order parameter, providing a new lens for understanding phase transitions that is complementary to correlation length, susceptibility, and free energy analysis.

**Catalog References**: `Pythagorean/ValuatedMatroidDepth/Theorems.lean` — `ratio_energy_supermodular`, `directionalDepthAtLeast_mul`.

**Proof Strategy**: In the high-temperature phase (β small), use cluster expansion to approximate Z as a product of local partition functions, each with infinite depth (by the multiplicativity theorem). Show that the cluster expansion preserves depth to all orders. At β_c, construct an explicit ratio transform that violates log-concavity using the divergent susceptibility.

**Domain Bridges**: Statistical mechanics (phase transitions, Lee–Yang theory), information geometry (Fisher information).

**Lineage**: Extends Lee–Yang 1952, Anari et al. 2021.

**Ambition**: grand_challenge — would connect combinatorial curvature to physics in a novel way.

---

## Direction 5: Categorical Depth and Functoriality

**Conjecture**: The depth filtration is functorial with respect to the category of valuated matroids and their morphisms (weak maps, strong maps, and tropical linear maps). Specifically, depth is non-increasing under weak maps and non-decreasing under strong maps.

**The key insight is** that the ratio transform commutes with pullback along matroid morphisms (at least the "product-preserving" ones), so the depth filtration should be compatible with the categorical structure of matroids. This would make depth a true invariant of the matroid, not just of a particular representation.

**Why now?** The recent development of tropical scheme theory (Giansiracusa–Giansiracusa, Lorscheid) and the functorial perspective on matroids (Baker–Bowler theory of matroids over hyperfields) provides the categorical framework needed to state and prove functoriality. Our multiplicativity theorem already proves one case: the product construction is a special case of a strong map, and depth is preserved.

**Test**: Verify functoriality for the deletion/contraction operations on small valuated matroids (n ≤ 6). Check whether depth is preserved, decreased, or increased under deletion and contraction.

**Impact**: Would embed the depth filtration into the modern categorical framework for matroid theory, opening connections to K-theory and motivic invariants of matroids.

**Catalog References**: `Pythagorean/ValuatedMatroidDepth/Defs.lean` — all definitions; `Pythagorean/ValuatedMatroidDepth/Theorems.lean` — `directionalDepthAtLeast_mul`.

**Proof Strategy**: Define the relevant matroid morphism categories. For weak maps, show that the pullback of a log-concave function is log-concave (this is a known result in discrete convexity). For strong maps, show that the pushforward preserves the ratio transform structure.

**Domain Bridges**: Category theory (functorial invariants), algebraic K-theory (matroid K-theory), algebraic geometry (tropical schemes).

**Lineage**: Extends Baker–Bowler 2019, Dress–Wenzel 1992.

**Ambition**: solid_extension — provides conceptual clarity and connects to active research programs.
