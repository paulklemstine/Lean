# Future Directions: Tropical Proof Complexity

## Synthesis

The tropical clause space framework established in this work creates a new dictionary between proof complexity and tropical geometry. The central theorem — `tropicalDim = maxClauseLoad` under separation and saturation — opens multiple research directions, from immediate extensions (richer tropical embeddings, dynamic dimension tracking) to grand challenges (tropical convexity lower bounds, matroid-theoretic proof complexity). The key leverage point is that tropical geometry provides *geometric* tools (dimension, rank, convexity) for problems that have historically been attacked with purely combinatorial methods. Each direction below builds on the formally verified theorems in `Catalog/Pythagorean/TropicalClauseSpace.lean` and the computational infrastructure in `algorithms.py`.

---

## Direction 1: Tropical Rank Lower Bound Conjecture

**Conjecture:** For any resolution refutation of a CNF formula F with clause space s, the tropical rank of the configuration-by-clause incidence matrix is at most s. Consequently, tropical rank provides a lower bound on clause space.

**Test:** Compute the tropical rank (via the Barvinok–Develin–Yu definition) of the incidence matrices for known formula families (PHP, Tseitin, random k-CNF) and compare with known clause space values. A single family where tropical rank exceeds the known clause space lower bound would validate the conjecture's power; a family where it falls short identifies the gap.

**Impact:** This would give the first *geometric* lower bound technique for clause space, potentially breaking barriers that combinatorial methods have not crossed. Resolution clause space lower bounds are notoriously difficult; a tropical rank approach would import machinery from tropical linear algebra.

**Catalog References:** `Catalog/Pythagorean/TropicalClauseSpace.lean` (Theorem 3: `tropicalDim_eq_maxClauseLoad`), `Catalog/Pythagorean/ForbiddenMinor/Defs.lean` (clause space definition).

**Proof Strategy:** Define the tropical rank of an m×n matrix M over (ℕ, min, +) as the minimum k such that M = A ⊙ B for m×k and k×n matrices. Show that the configuration-by-clause incidence matrix has tropical rank ≤ s by constructing an explicit factorization from the refutation sequence. The key insight: each step of the refutation modifies at most one clause, so the factorization has rank bounded by the maximum simultaneous clause count.

**Domain Bridges:** Tropical linear algebra ↔ proof complexity ↔ combinatorial optimization.

**Lineage:** Extends Theorem 3 (dimension–load equality) to a rank-based framework.

**Ambition:** ★★★★★ Grand challenge — would create a new lower bound technique for a central problem in proof complexity.

---

## Direction 2: Support-Separation Sufficiency Conjecture

**Conjecture:** For every finite monotone clause family F and every finite configuration set Configs, if SupportSeparated(F, Configs) holds, then `tropicalDim(configurationImage(F, Configs)) = maxClauseLoad(F, Configs)` *if and only if* LoadSaturated(F, Configs) also holds.

**Test:** Exhaustively compute both invariants and both conditions on all clause families of size ≤ 6 over ≤ 4 variables. For each family, enumerate all possible configuration sets up to size 10. Record (tropDim, maxLoad, separated, saturated) tuples. The conjecture is falsified if any instance with separation but without saturation achieves equality non-accidentally (i.e., for structural rather than coincidental reasons).

**Impact:** Would establish that our two conditions are not only sufficient but *characterize* when the equality holds, making the theorem sharp.

**Catalog References:** `Catalog/Pythagorean/TropicalClauseSpace.lean` (definitions of `SupportSeparated`, `LoadSaturated`).

**Proof Strategy:** For the forward direction, we already have the proof. For the reverse (necessity of saturation), construct explicit counterexamples showing that without saturation, tropicalDim can strictly exceed maxClauseLoad. The key construction: distributed activation where each clause appears individually but never simultaneously.

**Domain Bridges:** Combinatorics ↔ tropical geometry ↔ proof complexity.

**Lineage:** Direct extension of Theorem 3.

**Ambition:** ★★★ Solid extension — sharpens the main theorem.

---

## Direction 3: Tropical Convexity for Clause Space Lower Bounds

**Conjecture:** The tropical convex hull of the configuration image of a k-clause-space-hard formula family has tropical dimension ≥ k. Moreover, any "proof path" (sequence of adjacent configurations from empty to containing the empty clause) must pass through the interior of this tropical convex hull, giving geometric lower bounds on the path complexity.

**Test:** For PHP_n (pigeonhole principle on n pigeons), compute the tropical convex hull of all reachable configurations at space bound s for small n (n = 3, 4, 5). Compare the tropical dimension of the hull with the known clause space lower bound Ω(n). If the hull's dimension matches or exceeds the known bound, the technique is validated.

**Impact:** Would import the full power of tropical convexity theory into proof complexity, potentially yielding lower bounds via volume arguments, Carathéodory-type theorems, or tropical Helly theorems.

**Catalog References:** `Catalog/Pythagorean/TropicalClauseSpace.lean` (tropical embedding), `Catalog/Pythagorean/ForbiddenMinor/Defs.lean` (PHP formula, clause space).

**Proof Strategy:** Define the tropical convex hull as the set of all tropical linear combinations (min-plus combinations) of configuration images. Show that the hull inherits dimension from the point set. Use tropical Carathéodory (every point in the hull is a tropical combination of ≤ d+1 generators) to bound the hull's complexity. Connect path length through the hull to clause space via adjacency constraints.

**Domain Bridges:** Tropical convexity ↔ proof complexity ↔ combinatorial topology.

**Lineage:** Builds on Theorem 2 (dimension ≤ load bound) and the PHP formula definition.

**Ambition:** ★★★★★ Grand challenge — could yield fundamentally new lower bound techniques.

---

## Direction 4: Poset Width Equivalence for Active-Clause Systems

**Conjecture:** For monotone support systems where clauses are ordered by variable inclusion, the tropical dimension equals the width (maximum antichain size) of the active-clause poset under the induced containment order.

**Test:** Generate random monotone clause families of size n ≤ 10 with variable sets of size ≤ 6. Compute the containment poset on the active clauses, find its width by Dilworth's theorem (min chain partition), and compare with tropical dimension. Run 1000 random instances and report agreement/disagreement statistics.

**Impact:** Would connect tropical clause space to order theory and matroid theory, opening a path to Dilworth-based and Greene-Kleitman-based proof complexity results.

**Catalog References:** `Catalog/Pythagorean/TropicalClauseSpace.lean` (`tropicalDim_eq_supportWidth`).

**Proof Strategy:** Define the poset on clauses ordered by literal inclusion. Show that antichains in this poset correspond to tropically independent coordinate sets. Use Dilworth's theorem to connect width to chain partitions, which correspond to nested clause families. The key lemma: two clauses in the same chain (one contains the other) cannot both vary independently.

**Domain Bridges:** Order theory ↔ tropical geometry ↔ proof complexity ↔ matroid theory.

**Lineage:** Extends the cross-domain theorem (`tropicalDim_eq_supportWidth`).

**Ambition:** ★★★ Solid extension — connects to classical combinatorics.

---

## Direction 5: Asymptotic Tropical Geometry of Random Formulas

**Conjecture:** For random k-CNF formulas F(n, m) with n variables and m = Δn clauses, the normalized tropical dimension `tropicalDim / m` converges to a deterministic function of Δ as n → ∞, and this function has a phase transition at the satisfiability threshold.

**Test:** Generate random 3-CNF formulas for n = 50, 100, 200, 500 at clause-to-variable ratios Δ = 1, 2, 3, 4, 4.27, 5, 6, 7, 8. For each formula, compute tropicalDim using random configuration sampling (sample 1000 configs uniformly at random). Plot `tropicalDim / m` vs Δ and fit scaling laws. The conjecture is falsified if no convergence or no phase transition is observed.

**Impact:** Would connect tropical proof complexity to the rich theory of random constraint satisfaction, potentially explaining why proofs become hard near the satisfiability threshold in geometric terms.

**Catalog References:** `Catalog/Pythagorean/TropicalClauseSpace.lean` (all definitions), `algorithms.py` (computational tools).

**Proof Strategy:** Use the second moment method on the indicator variables for varying clauses. Show that concentration occurs by proving that pairwise correlations between clause variation events decay with clause distance. The phase transition should emerge from the connectivity threshold of the clause-variable bipartite graph.

**Domain Bridges:** Random combinatorics ↔ tropical geometry ↔ statistical physics ↔ proof complexity.

**Lineage:** Applies the full framework to the random setting.

**Ambition:** ★★★★ High ambition — connects to one of the deepest questions in random CSP theory.
