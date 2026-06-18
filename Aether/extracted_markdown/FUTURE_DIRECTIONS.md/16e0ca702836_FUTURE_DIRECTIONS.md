# Future Directions: Certified Discrete Optimization on M-Convex Sets

## Synthesis

The formal verification of the local-to-global theorem for M-convex sets opens a systematic program for certified discrete convex optimization. The five directions below form a coherent arc: Direction 1 sharpens the complexity bounds within the existing framework; Direction 2 extends the theory from linear to nonlinear objectives; Direction 3 connects M-convexity to tropical geometry, potentially unlocking entirely new proof techniques; Direction 4 bridges to auction theory and mechanism design; Direction 5 pursues a grand challenge linking discrete and continuous convexity through a unified exchange framework. Each direction is testable, falsifiable, and builds on the certified theorems in `Pythagorean/MConvexOptimization.lean`.

---

## Direction 1: Tight Complexity via Exchange Diameter

**Conjecture:** For any M-convex set S, linear objective c, and starting point x₀ ∈ S, steepest exchange descent terminates in at most exchangeDist(S, x₀, x*) steps, where x* is the nearest optimum in the exchange graph. In particular, descent length ≤ exchangeDiameter(S).

**Test:** Enumerate all M-convex subsets of Δ_{n,d} for n ≤ 6, d ≤ 5. For each (S, c, x₀), compute steepest descent length and exchange distance to the optimum. Check if steps ≤ exchangeDist(x₀, x*) universally.

**Impact:** Would upgrade the complexity bound from |S| (our current Theorem `descent_length_le_card`) to a geometric quantity, opening connections to graph metric theory and enabling practical performance predictions.

**Catalog References:** `Pythagorean/MConvexOptimization.lean` — `descent_length_le_card`, `exchange_local_min_implies_global_min`, `ExchangeReachableIn`, `exchangeDist`.

**Proof Strategy:** Define a monotone geodesic from x₀ to x* (a shortest path where each step is also objective-improving). Use the double-application technique from `exchange_local_min_implies_global_min` to show that such geodesics exist. The key lemma would be: "if x has an improving exchange and x* is optimal, some improving exchange also decreases exchange distance to x*."

**Domain Bridges:** Graph metric theory, geodesic convexity, network distance optimization.

**Lineage:** Extends `descent_length_le_card` and `exchange_local_min_implies_global_min`.

**Ambition:** ★★★☆☆ (Solid extension — computationally validated, proof likely within reach.)

---

## Direction 2: Local-to-Global for M-Convex Functions

**Conjecture:** The local-to-global principle extends from linear objectives over M-convex sets to minimization of M-convex *functions*: f : ℤ^ι → ℤ ∪ {+∞} satisfying the exchange inequality f(x) + f(y) ≥ f(x − eᵢ + eⱼ) + f(y + eᵢ − eⱼ) for appropriate i, j. A local minimum (no improving exchange in dom(f)) is a global minimum.

**Test:** Implement M-convex functions as oracle-defined functions on simplex layers. Verify the local-to-global property for random M-convex functions on Δ_{n,d} for n ≤ 5, d ≤ 4 by exhaustive comparison.

**Impact:** Would unify the theory of M-convex set optimization with M-convex function optimization, subsuming quadratic and separable convex objectives. Directly applicable to auction theory (Walrasian equilibria), scheduling, and inventory management.

**Catalog References:** `Pythagorean/MConvexOptimization.lean` — `exchange_local_min_implies_global_min` (the linear case), `IsMConvexSet`.

**Proof Strategy:** Generalize the induction argument. The objective-change formula becomes an inequality rather than equality. The argmax selection and double M-convexity application should still work, with the exchange inequality playing the role of the linear formula.

**Domain Bridges:** Auction theory (Walrasian equilibria), inventory management, network flow with convex costs.

**Lineage:** Direct generalization of `exchange_local_min_implies_global_min`.

**Ambition:** ★★★★☆ (Substantial extension — the proof technique should generalize but with significant additional complexity.)

---

## Direction 3: Tropical Metric Structure of M-Convex Sets

**Conjecture (Grand Challenge):** The exchange graph of an M-convex set S embeds isometrically into a tropical linear space, and the exchange diameter equals the diameter of the corresponding tropical polytope. Moreover, M-convex exchange descent is a shadow of tropical gradient descent in the ambient tropical space.

**Test:** For small M-convex sets (n ≤ 5, d ≤ 4), compute the exchange graph metric and the tropical polytope metric. Check isometric embedding and diameter equality.

**Impact:** Would establish a deep structural connection between discrete convex optimization and tropical geometry, potentially enabling tropical proof techniques for combinatorial optimization problems. Could lead to a "tropical simplex method" with certified complexity.

**Catalog References:** `Pythagorean/MConvexOptimization.lean` — `ExchangeReachableIn`, `exchangeDist`; `Catalog/FINAL/Pythagorean/TropicalMConvexity.lean`.

**Proof Strategy:** Use the valuated matroid representation of M-convex sets (Dress-Wenzel). The tropical linear space is the Bergman fan of the underlying matroid. Show that exchange steps correspond to tropical line segments and that the exchange metric agrees with the tropical metric.

**Domain Bridges:** Tropical geometry, valuated matroids, Bergman fans, tropical convexity, algebraic combinatorics.

**Lineage:** Builds on exchange distance definitions and connects to `TropicalMConvexity.lean`.

**Ambition:** ★★★★★ (Grand challenge — would open a new field of tropical certified optimization.)

---

## Direction 4: M-Convex Optimization in Auction Theory

**Conjecture:** For M-convex feasible allocation sets, the Vickrey–Clarke–Groves (VCG) mechanism can be implemented via exchange descent, and the resulting price vector is the unique competitive equilibrium price. The local-to-global theorem implies that tatonnement (iterative price adjustment) converges to equilibrium.

**Test:** Implement a combinatorial auction simulator with M-convex feasibility constraints. Verify that exchange descent on the welfare function produces VCG outcomes. Check convergence of tatonnement processes.

**Impact:** Would provide certified welfare theorems for combinatorial auctions with substitutable goods, connecting M-convexity to mechanism design and market equilibrium theory.

**Catalog References:** `Pythagorean/MConvexOptimization.lean` — `exchange_local_min_implies_global_min`, `CertifiedArgmin`.

**Proof Strategy:** Model an auction as optimization over an M-convex set of allocations. The welfare function is linear (sum of valuations times allocations). Apply the local-to-global theorem to certify that tatonnement converges. Derive VCG payments from the certified optimum.

**Domain Bridges:** Mechanism design, market equilibrium, substitutable goods, gross substitutes condition, competitive equilibrium from equal incomes.

**Lineage:** Application of `exchange_local_min_implies_global_min` and `CertifiedArgmin`.

**Ambition:** ★★★☆☆ (Solid extension — well-studied connection in economics, novel formalization angle.)

---

## Direction 5: Universal Exchange Framework

**Conjecture (Grand Challenge):** There exists a unified "exchange convexity" framework encompassing both continuous convexity (gradient descent) and discrete M-convexity (exchange descent) as special cases, with a single local-to-global theorem parameterized by the exchange structure. Continuous convexity corresponds to infinitesimal exchanges; M-convexity to unit exchanges; and intermediate cases (e.g., L♮-convexity, multimodular functions) to other exchange granularities.

**Test:** Define a parameterized exchange structure indexed by step size ε. Show that as ε → 0, the discrete exchange axiom converges to the convexity condition. Verify that the local-to-global theorem specializes correctly at both extremes.

**Impact:** Would unify discrete and continuous optimization theory under a single geometric framework, potentially resolving longstanding questions about the boundary between "easy" and "hard" optimization.

**Catalog References:** `Pythagorean/MConvexOptimization.lean` — all main theorems; `Catalog/FINAL/Pythagorean/MConvexBridge.lean` — `mconvex_implies_exchange_connected`.

**Proof Strategy:** Define generalized exchange structures as metric spaces with a local improvement property. Prove an abstract local-to-global theorem parameterized by the exchange radius. Show that M-convex sets and convex sets are instances. The key challenge is identifying the right abstraction that captures both continuous and discrete cases.

**Domain Bridges:** Convex analysis, metric geometry, variational analysis, gradient flow theory, dynamical systems, tropical geometry.

**Lineage:** Grand synthesis of all results in the M-convex optimization catalog.

**Ambition:** ★★★★★ (Paradigm-shifting — would establish a new field of "exchange convexity theory.")
