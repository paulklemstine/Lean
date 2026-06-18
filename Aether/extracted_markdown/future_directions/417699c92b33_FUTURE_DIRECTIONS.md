# Future Directions: M-Convexity Inheritance and Hessian Shadows

## Synthesis

The M-convexity inheritance theorem reveals that second-derivative aggregation preserves the exact combinatorial exchange geometry of discrete optimization domains. This creates a new functorial pathway from Lorentzian positivity (algebraic geometry) through M-convex exchange systems (discrete optimization) to polynomial-time algorithms. The five directions below extend this bridge in complementary ways: deeper into algebraic structure (Direction 1), broader across optimization theory (Direction 2), into the physics of negative dependence (Direction 3), toward tropical geometry (Direction 4), and into algorithmic game theory (Direction 5).

---

## Direction 1: Higher-Order Shadow Cascades and M-Convex Towers

**Conjecture:** For any M-convex set S with constant degree d ≥ k, the k-step shadow ∂ᵏS = ∂(∂(...∂(S)...)) is M-convex.

**Test:** Verify computationally for U(r,n) with n ≤ 10 and k up to d. Check whether the exchange graph diameter changes predictably with k.

**Impact:** Would establish an infinite tower of M-convex sets descending from any starting set, creating a "discrete derivative calculus" with guaranteed algorithmic tractability at every level. This would mean every Lorentzian polynomial generates a polynomial-length cascade of efficiently optimizable combinatorial state spaces.

**The key insight is** that the compositional structure of our proof (two-step = one-step twice) immediately generalizes, but the base case needs re-verification at each step because the exchange witnesses change.

**Why now?** The formalization infrastructure (definitions, helper lemmas, commutation identities) is now in place, making inductive generalization feasible.

**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (Theorems 1-3)

**Proof Strategy:** Induction on k, using the one-step inheritance as the inductive step. The key lemma (exchange commutation through shadows) is already proved.

**Domain Bridges:** Tropical geometry (erosion of Newton polytopes), algebraic K-theory (filtrations of exchange systems)

**Lineage:** Direct extension of Theorems 1-2 in the current work.

**Ambition:** solid_extension

---

## Direction 2: Valuated M-Convexity and Weighted Shadow Morphisms

**Conjecture:** For a valuated matroid (M, ω) with M-convex support and valuation ω satisfying a convexity condition, the weighted Hessian shadow AgSh(S, A) inherits valuated M-convexity when A is compatible with ω.

**Test:** Compute valuated exchange graphs for graphic matroids with random valuations under positive weight matrices. Check whether the "discrete concavity" of the valuation is preserved through the shadow.

**Impact:** Would extend the inheritance theorem from set-level M-convexity to function-level M♮-convexity, connecting to the full power of Murota's discrete convex duality. This would enable Fenchel-type duality for Hessian-derived optimization problems.

**The key insight is** that the shadow operation on supports is the combinatorial projection of a differentiation operator on valuated functions, and M♮-convexity is preserved under projections in Murota's framework.

**Why now?** Valuated matroid theory has matured significantly with recent work by Baker-Bowler, and the categorical framework for morphisms between valuated matroids is now available.

**Catalog References:** `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (anti-cancellation), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean`

**Proof Strategy:** Extend the support-level shadow to include coefficient tracking. Use anti-cancellation to ensure support exactness, then verify the valuated exchange axiom using the convexity of ω.

**Domain Bridges:** Tropical geometry (tropicalization of Hessians), algebraic geometry (Newton-Okounkov bodies)

**Lineage:** Builds on anti-cancellation results and the set-level inheritance theorem.

**Ambition:** grand_challenge

---

## Direction 3: Negative Dependence and Hessian Markov Chains

**Conjecture:** If μ is a strongly log-concave distribution (equivalently, its generating polynomial is Lorentzian), then the "Hessian response distribution" defined by the aggregate Hessian has M-convex support, enabling polynomial-time mixing of local Markov chains on the Hessian state space.

**Test:** Simulate Glauber dynamics on the support of AgHess(p, I) for determinantal point process generating polynomials. Measure mixing times and compare with the theoretical O(n log n) bound guaranteed by M-convexity.

**Impact:** Would provide a new class of efficiently sampleable distributions derived from strongly log-concave measures, with applications to experimental design, diversity sampling, and Monte Carlo methods in machine learning.

**The key insight is** that M-convexity of the support is precisely the condition needed for the "down-up walk" and similar local Markov chains to mix in polynomial time, by the framework of Anari-Liu-Oveis Gharan-Vinzant.

**Why now?** The connection between Lorentzian polynomials and rapid mixing was established in 2021-2023, but the role of Hessian shadows as derived sampling domains has not been explored.

**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (Theorem 5, matroid application)

**Proof Strategy:** Use the inheritance theorem to establish M-convexity of the Hessian support, then invoke known mixing time bounds for exchange walks on M-convex sets.

**Domain Bridges:** Statistical physics (partition functions), machine learning (determinantal sampling), probability (negative association)

**Lineage:** Combines the inheritance theorem with Anari et al.'s mixing time results.

**Ambition:** grand_challenge

---

## Direction 4: Tropical Hessians and Newton Polytope Erosion

**Conjecture:** The two-step shadow of an M-convex set S equals the integer points of the Minkowski difference Newton(S) ⊖ Δ₂, where Δ₂ is the second dilate of the standard simplex, intersected with the hyperplane of degree d-2.

**Test:** Compute Newton polytopes and Minkowski differences for matroid basis polytopes. Verify that the integer points of the eroded polytope match the two-step shadow exactly.

**Impact:** Would provide a polyhedral-geometric characterization of the shadow operation, connecting M-convexity inheritance to the tropical geometry of Newton subdivisions and enabling the use of polyhedral computation tools.

**The key insight is** that the shadow operation α ↦ α - eᵢ - eⱼ is a Minkowski subtraction at the tropical level, and the M-convexity of integer points in generalized polymatroids is preserved under such operations.

**Why now?** Tropical Hodge theory has recently been developed by Adiprasito-Huh-Katz, providing the geometric framework to interpret derivative shadows as erosion operations on Newton polytopes.

**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (shadow definitions)

**Proof Strategy:** Show that the shadow equals the lattice points of a generalized polymatroid, then use Murota's characterization of M-convex sets as lattice points of base polyhedra.

**Domain Bridges:** Tropical geometry, polyhedral combinatorics, algebraic geometry

**Lineage:** Geometric reinterpretation of the combinatorial shadow theorem.

**Ambition:** solid_extension

---

## Direction 5: Hessian Shadows in Algorithmic Game Theory

**Conjecture:** In a combinatorial auction with matroid-based valuations, the set of Hessian-perturbed allocations (under second-order price sensitivity) forms an M-convex set, enabling polynomial-time computation of approximate Walrasian equilibria in the perturbed market.

**Test:** Implement a Hessian-perturbed auction clearing algorithm for graphic matroid valuations. Compare convergence rate with unperturbed clearing and verify that the exchange property enables greedy equilibrium finding.

**Impact:** Would establish that second-order sensitivity analysis in combinatorial markets preserves the tractability of equilibrium computation — a key requirement for robust mechanism design under perturbation.

**The key insight is** that Walrasian equilibrium computation reduces to optimization over M-convex sets (Murota-Shioura), and the inheritance theorem guarantees that Hessian perturbation doesn't destroy this structure.

**Why now?** The connection between M-convexity and market equilibria was formalized by Murota-Shioura in 2014, but robustness under analytic perturbation has not been studied.

**Catalog References:** `Catalog/Pythagorean/HessianShadowMConvex.lean` (Theorems 3, 5)

**Proof Strategy:** Model the perturbed market as AgHess applied to the matroid valuation polynomial, then apply the inheritance theorem and Murota-Shioura's equilibrium existence result.

**Domain Bridges:** Algorithmic game theory, mechanism design, mathematical economics

**Lineage:** Application of the morphism property (Theorem 3) to economic settings.

**Ambition:** solid_extension
