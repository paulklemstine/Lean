# Future Research Directions: Combinatorial Equilibrium Functors

## Synthesis

This cycle established the **Combinatorial Equilibrium Functor (CEF)** as a novel mathematical structure connecting Sperner-type combinatorial colorings with Nash equilibrium theory. The 12 formally verified theorems demonstrate that the CEF framework provides a rigorous bridge between discrete combinatorics and continuous game theory: the Convexity Theorem reveals expected payoffs as convex combinations of deviation payoffs, the Support Lemma characterizes equilibrium structure through positive-probability strategies, and the CEF Convergence Theorem shows that monotonically refined Sperner witnesses converge to exact Nash equilibria.

The most promising cross-domain connection is between the CEF convergence rate and computational complexity theory. The PPAD-completeness of Nash equilibria means that finding Sperner witnesses is computationally hard in general, but the CEF framework suggests that the *structure* of the convergence path — not just its existence — carries information about equilibrium multiplicity and stability. This connects to the Catalog's existing fixed-point theorems (`closure_has_least_fixed_point`, `exists_fixed_point_on_orbit_with_bound`) through the common theme of iterative approximation to fixed points.

The direction with highest breakthrough potential is Direction 1 (Tropical Game Theory), because tropical semirings naturally capture the "max-plus" structure of best-response correspondences, and this connection has not been explored in the formal verification literature. If the tropical Nash theorem holds, it would provide a purely algebraic framework for computing Nash equilibria that avoids the topological machinery entirely.

---

### Direction 1: Tropical Nash Equilibria

**Conjecture**: Every finite game has a "tropical Nash equilibrium" defined over the tropical semiring (ℝ ∪ {-∞}, max, +), where the Convexity Theorem holds with max replacing sum and addition replacing multiplication. Specifically, define tropical expected payoff as max_{s} (Σ_j log σ_j(s_j) + u_i(s)) and tropical deviation payoff as max_{s_{-i}} (Σ_{j≠i} log σ_j(s_j) + u_i(s_i, s_{-i})). Conjecture: the tropical analog of the Support Lemma holds — positive-probability strategies achieve the tropical maximum.

**Test**: Formalize tropical mixed strategies in Lean 4 using Mathlib's `Tropical` type. Prove the tropical Convexity Theorem. Test computationally on 2×2 games: does the tropical Nash equilibrium agree with the classical one on degenerate (all-integer payoff) games?

**Impact**: If true, provides a purely algebraic (no topology!) proof of Nash's theorem for generic games via tropical Sperner's lemma. If false, the failure mode reveals which games require genuinely topological reasoning.

**Catalog References**: `Tropical/`, `Algebra/Basic.lean`, `TropicalContraction.has_fixed_point_approach`

**Proof Strategy**: (1) Define tropical versions of MixedStrategy, expectedPayoff, deviationPayoff. (2) Prove tropical Convexity Theorem using properties of max and +. (3) Derive tropical Support Lemma. (4) Connect tropical fixed points to classical Nash via a "detropicalization" map.

**Domain Bridges**: Tropical Algebra <-> Game Theory <-> Combinatorics (Sperner)

**Lineage**: Builds on CEF framework from this cycle and existing tropical algebra infrastructure in `Tropical/`.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative CEF Convergence Rates

**Conjecture**: For generic 2-player m×n games, the CEF achieves max regret O(M/k) at refinement level k, where M = max|u_i(s)|. Moreover, this rate is tight: there exist games where the CEF cannot achieve regret o(1/k) at level k.

**Test**: (a) Prove the O(M/k) upper bound by bounding the diameter of Sperner simplices in the mixed strategy simplex. (b) Construct a family of 2×2 games where the optimal grid point at level k has regret exactly Θ(1/k). (c) Computationally verify on random 3×3 games by running CEF for k=1,...,20 and fitting the convergence rate.

**Impact**: If the O(1/k) rate is optimal, this connects to the computational complexity of Nash: any algorithm based on grid refinement inherits this rate, suggesting that faster methods must exploit algebraic structure beyond Sperner colorings. This would provide a formal separation between "topological" and "algebraic" approaches to Nash computation.

**Catalog References**: `Bridges/SpernerNashCore.lean`, `Bridges/SpernerNashTheorems.lean`

**Proof Strategy**: (1) Bound the Lipschitz constant of deviation payoffs with respect to the L∞ metric on the strategy simplex. (2) Use the mesh size to bound the L∞ distance from a Sperner witness center to the nearest Nash equilibrium. (3) For the lower bound, analyze games where the unique Nash equilibrium is irrational (e.g., payoffs designed to place Nash at (1/3, 1/3)).

**Domain Bridges**: Computation (complexity) <-> Game Theory <-> Analysis (approximation theory)

**Lineage**: Direct extension of CEF Convergence Theorem from this cycle.

**Ambition**: extension

---

### Direction 3: Multi-Player Sperner Colorings and the Dimension of Equilibrium Sets

**Conjecture**: For n-player games, the equilibrium set is generically a manifold of dimension d where d is determined by a combinatorial formula involving the number of players and strategy sizes. Specifically, conjecture: for generic games, dim(Nash(G)) = Σ_i (|support(σ_i)| - 1) - (number of binding best-response constraints).

**Test**: (a) Formalize the notion of "generic game" (payoffs in general position). (b) Prove that for 2-player 2×2 games with generic payoffs, the Nash equilibrium set is finite (0-dimensional). (c) Construct a 3-player game where the Nash set is 1-dimensional and verify computationally.

**Impact**: Understanding the dimension of equilibrium sets is fundamental to equilibrium selection and refinement theory. The Sperner coloring approach provides a combinatorial tool for counting dimensions via the Euler characteristic of colored simplicial complexes.

**Catalog References**: `Bridges/SpernerNashCore.lean`, `Geometry/`

**Proof Strategy**: (1) Define generic games via algebraic independence of payoffs. (2) Use the best-response characterization (Theorem 3.6) to express Nash as a semialgebraic set. (3) Apply the implicit function theorem to count dimensions. (4) Connect to Sperner coloring via the Euler characteristic.

**Domain Bridges**: Algebraic Geometry <-> Game Theory <-> Topology (dimension theory)

**Lineage**: Builds on nash_iff_support_best_response and nash_support_lemma from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Regret Spectra and Equilibrium Stability

**Conjecture**: The "regret spectrum" — the multiset of regrets across all player-strategy pairs — characterizes Nash equilibrium stability. Specifically, conjecture: a Nash equilibrium σ is asymptotically stable under replicator dynamics if and only if its regret spectrum (viewed as a function of perturbation direction) is negative definite in a suitable sense.

**Test**: (a) Define the regret spectrum formally as a function from perturbation directions to regret vectors. (b) Compute the regret spectrum Jacobian at Nash equilibria of 2×2 and 3×3 games. (c) Verify computationally that negative definiteness correlates with stability under simulated replicator dynamics.

**Impact**: Currently, equilibrium stability analysis requires eigenvalue computation of the Jacobian of the best-response dynamics. If regret spectra provide equivalent information, this gives a more computationally accessible and combinatorially interpretable stability criterion.

**Catalog References**: `Bridges/SpernerNashCore.lean` (regretSpectrum, equilibriumDistance definitions)

**Proof Strategy**: (1) Formalize replicator dynamics as an ODE on the strategy simplex. (2) Compute the Jacobian of the replicator dynamics in terms of regret derivatives. (3) Show that the regret spectrum Hessian determines the sign structure of the Jacobian eigenvalues.

**Domain Bridges**: Dynamical Systems <-> Game Theory <-> Linear Algebra (spectral theory)

**Lineage**: Builds on regret, regretSpectrum, equilibriumDistance definitions from this cycle.

**Ambition**: extension

---

### Direction 5: Constructive Nash via Sperner Path-Following

**Conjecture**: There exists a polynomial-time algorithm for finding ε-approximate Nash equilibria in 2-player games based on Sperner path-following, with complexity O(n² · log(1/ε)) where n = max(|S₁|, |S₂|).

**Test**: (a) Implement the Sperner path-following algorithm (start from boundary, follow the unique Sperner path to a fully-colored simplex). (b) Analyze the path length for random 2-player games. (c) Compare runtime with the Lemke-Howson algorithm and support enumeration on games with n = 5, 10, 20, 50 strategies.

**Impact**: If true, this would be a major breakthrough in algorithmic game theory, as the best known algorithms for exact Nash are exponential (Lemke-Howson) and the polynomial-time algorithms for approximate Nash (Lipton-Markakis-Mehta) give much weaker approximation guarantees. If false (which is more likely given PPAD-hardness), the analysis of where the path-following gets stuck would provide structural insights into the hardness landscape of Nash computation.

**Catalog References**: `Bridges/SpernerNashTheorems.lean`, `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: (1) Formalize Sperner path-following as a sequence of adjacent simplices sharing all but one color. (2) Bound path length using the structure of the best-response coloring. (3) Connect to the Lemke-Howson algorithm via the complementary pivot interpretation.

**Domain Bridges**: Computation (algorithms) <-> Combinatorics (Sperner paths) <-> Game Theory

**Lineage**: Builds on CEF framework and the existing `InfoEfficientAlgorithm` structure in the Catalog.

**Ambition**: grand_challenge
