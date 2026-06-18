# Future Directions: The M-Convex Bridge

## Synthesis

The M-convex bridge establishes a formally verified connection between discrete exchange axioms, polyhedral geometry, and submodular optimization. Our work proves that M-convex sets are exchange-connected (Theorem 6.4), yielding generalized permutohedra, and that submodular functions generate these structures (Theorems 4.1–4.4). The Pythagorean connection (Theorem 5.1) reveals that even the oldest equation in mathematics exhibits M-convex-compatible structure.

These results open five concrete research directions, ranging from grand challenges that would unify algebraic and combinatorial geometry, to immediate extensions that directly leverage the proven infrastructure.

---

## Direction 1: Lorentzian Polynomial Support is M-Convex (Grand Challenge)

**Conjecture:** Every polynomial $f$ with the Lorentzian property (Hessian negative semidefinite on the positive orthant) has M-convex support. Formally: `IsLorentzian f → IsMConvexExchange (newtonSupport f)`.

**Test:** For $n = 3$ variables and degree $d \leq 4$, enumerate all homogeneous polynomials with support in the simplex $\Delta_{3,d}$ and coefficients in $\{0, 1, 2\}$. Check the Lorentzian condition (all $2 \times 2$ minors of the Hessian are non-positive on the positive orthant) and verify that the support is M-convex. A single Lorentzian polynomial with non-M-convex support would falsify the conjecture.

**Impact:** This would complete the formal verification of the Brändén–Huh theorem, one of the landmark results of 21st-century combinatorics. It would also provide the first machine-verified proof of a deep connection between algebraic positivity and discrete convexity.

**Catalog References:** `Pythagorean/MConvexBridge.lean` (IsMConvexExchange, MConvexSet), `Catalog/FINAL/Pythagorean/TropicalMarkov.lean` (tropical memoryless property).

**Proof Strategy:** 
1. Define `IsLorentzian` for multivariate polynomials via the Hessian condition.
2. Prove that degree-2 Lorentzian polynomials have M-convex support (reduces to negative semidefiniteness of a matrix).
3. Use the polarization/reduction trick: reducing a degree-$d$ Lorentzian polynomial by specializing one variable gives a degree-$(d-1)$ Lorentzian polynomial, and the support projects to an M-convex set.
4. Induction on degree using the reduction.

**Domain Bridges:** Algebraic geometry (Hodge theory) ↔ Combinatorics (matroids) ↔ Optimization (submodularity).

**Lineage:** Extends `mconvex_implies_exchange_connected` (Theorem 6.4) and `indicator_submodular` (Theorem 4.1).

**Ambition:** Grand challenge — requires substantial new infrastructure for multivariate polynomial analysis.

---

## Direction 2: M-Convex Cardinality Bound

**Conjecture:** For any M-convex subset $S \subseteq \{x \in \mathbb{N}^n : \sum x_i = d\}$:
$$|S| \leq \binom{n+d-1}{d}$$

**Test:** For $n \leq 5$ and $d \leq 4$, enumerate all M-convex subsets of the simplex and verify the bound. The full simplex achieves the bound (Theorem 7.1 verifies it is M-convex). Any M-convex subset exceeding $\binom{n+d-1}{d}$ would falsify the conjecture.

**Impact:** Would establish an optimal cardinality bound for discrete convex sets with the exchange property, with applications to coding theory and combinatorial optimization.

**Catalog References:** `Pythagorean/MConvexBridge.lean` (mconvex_cardinality_conjecture, full_simplex_is_mconvex_nat).

**Proof Strategy:**
1. Show that any M-convex subset of the simplex $\Delta_{n,d}$ is an "ideal" in a natural partial order on compositions.
2. Use the exchange property to show that if $\alpha \in S$ and $\beta \leq \alpha$ coordinate-wise with $\sum \beta_k = d$, then $\beta \in S$ (this is the "Bruhat order" characterization).
3. Conclude $S = \Delta_{n,d}$, giving $|S| = \binom{n+d-1}{d}$.

Note: Step 2 requires careful analysis — not all M-convex sets are order ideals, so the proof may need a more subtle argument involving the exchange graph diameter.

**Domain Bridges:** Enumerative combinatorics ↔ Discrete convex analysis ↔ Matroid theory.

**Lineage:** Directly extends `full_simplex_is_mconvex_nat` and `mconvex_cardinality_conjecture`.

**Ambition:** Solid extension — likely provable with careful combinatorial arguments.

---

## Direction 3: Tropical Pythagorean M-Convexity (Grand Challenge)

**Conjecture:** The tropical image of Pythagorean triples under any prime $p$ valuation forms a "tropical M-convex set" satisfying a min-plus exchange axiom: for tropical vectors $v, w$ with $v_i > w_i$, there exists $j$ with $v_j < w_j$ such that the tropical exchange $v \oplus_j e_i$ lies in the tropical image.

**Test:** For primes $p \leq 7$ and hypotenuse $c \leq 100$, compute the tropical images of all Pythagorean triples and verify the tropical exchange axiom. The conjecture predicts that the tropical images form a "min-plus matroid."

**Impact:** Would establish a new connection between number theory (Pythagorean triples), tropical geometry (min-plus algebra), and discrete convexity (M-convex sets). This could lead to tropical methods for counting Pythagorean representations.

**Catalog References:** `Pythagorean/MConvexBridge.lean` (pythagoreanVectors, pythagorean_squared_sum), `Catalog/FINAL/Pythagorean/TropicalMarkov.lean` (padicValTail, IsTropicalMemoryless).

**Proof Strategy:**
1. Define "tropical M-convexity" using the min-plus exchange axiom.
2. Show that the p-adic valuation map preserves the exchange property when it preserves the Pythagorean relation.
3. Characterize when $v_p(a^2 + b^2) = v_p(c^2)$ gives a clean tropical relation (requires $p \neq 2$ and primitivity).

**Domain Bridges:** Number theory ↔ Tropical geometry ↔ Discrete convex analysis.

**Lineage:** Extends `pythagorean_squared_sum` and tropical Markov theory from the catalog.

**Ambition:** Grand challenge — requires new tropical convexity infrastructure.

---

## Direction 4: Certified Discrete Optimization on M-Convex Sets

**Conjecture:** The steepest-descent algorithm on an M-convex set terminates in at most $O(n \cdot D)$ steps, where $D$ is the exchange diameter, and produces a *certifiably optimal* solution for any linear objective.

**Test:** Run the steepest-descent algorithm on M-convex subsets of simplices $\Delta_{n,d}$ for $n \leq 6$, $d \leq 5$ with random linear objectives. Measure iteration counts and verify optimality by brute force. Any instance exceeding $O(n \cdot D)$ iterations would refine the bound.

**Impact:** Would provide formally verified optimization algorithms with certified complexity bounds, applicable to scheduling, resource allocation, and network flow problems.

**Catalog References:** `Pythagorean/MConvexBridge.lean` (mconvex_implies_exchange_connected, checkMConvex_sound).

**Proof Strategy:**
1. Define the steepest-descent algorithm in Lean as a computable function.
2. Prove termination using the exchange distance as a well-founded measure.
3. Prove correctness: local optimality implies global optimality by M-convexity.
4. Derive the complexity bound from the diameter of the exchange graph.

**Domain Bridges:** Optimization theory ↔ Discrete convex analysis ↔ Formal verification.

**Lineage:** Directly extends `mconvex_implies_exchange_connected` (provides the connectivity needed for termination).

**Ambition:** Solid extension — the algorithmic theory is well-established; the novelty is in formal verification.

---

## Direction 5: Ehrhart Theory of Lorentzian Permutohedra

**Conjecture:** The Ehrhart polynomial $L(P, t) = |tP \cap \mathbb{Z}^n|$ of a generalized permutohedron $P$ arising from a Lorentzian polynomial has non-negative coefficients and unimodal $h^*$-vector.

**Test:** For Lorentzian polynomials in 3–4 variables of degree 2–3, compute the Newton polytope, dilate it by $t = 1, 2, \ldots, 10$, count lattice points, fit the Ehrhart polynomial, and check non-negativity of coefficients and unimodality of the $h^*$-vector.

**Impact:** Would connect the Lorentzian polynomial theory to Ehrhart theory, a central topic in combinatorial number theory. The non-negativity of Ehrhart coefficients for generalized permutohedra is related to the Adiprasito–Huh–Katz resolution of the Heron–Rota–Welsh conjecture.

**Catalog References:** `Pythagorean/MConvexBridge.lean` (MConvexSet, IsGenPermutohedronLattice), `Catalog/FINAL/Pythagorean/EulerFactor.lean` (Euler factor theory).

**Proof Strategy:**
1. Define Ehrhart polynomials for lattice polytopes in Lean.
2. Prove that generalized permutohedra satisfy the integer decomposition property (IDP).
3. Use IDP to show non-negativity of $h^*$-vector coefficients.
4. Prove unimodality using the Hodge–Riemann relations (very deep — may require substantial new infrastructure).

**Domain Bridges:** Combinatorial geometry ↔ Number theory (Ehrhart theory) ↔ Algebraic geometry (Hodge theory).

**Lineage:** Extends the generalized permutohedron characterization from `mconvex_implies_exchange_connected`.

**Ambition:** Grand challenge — Ehrhart theory for generalized permutohedra is an active research area.
