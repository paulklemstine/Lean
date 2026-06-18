# Future Directions: M-Convexity Closure Under Differentiation

## Synthesis

The proof that partial differentiation preserves the exchange property (M-convexity) of polynomial supports creates a bridge between algebraic calculus and discrete convex combinatorics. This bridge is bidirectional: algebraic operations (differentiation, polarization, specialization) can now be interpreted as combinatorial operations (contraction, deletion, restriction) with guaranteed structural preservation, and conversely, matroid-theoretic constructions can be lifted to polynomial algebra with certified support properties.

The five directions below form a coherent program: Directions 1–2 complete the matroid-theoretic picture (contraction + deletion), Direction 3 extends to the tropical/geometric setting, Direction 4 explores algorithmic consequences, and Direction 5 aims at the deepest structural connection — Hodge-theoretic positivity. Each builds on the contraction-preserves-exchange theorem as its foundation.

---

## Direction 1: Support Deletion and the Full Matroid Minor Calculus

**Conjecture:** If $S \subseteq \mathbb{N}^n$ satisfies the symmetric exchange axiom, then the *deletion* $S \setminus i := \{\alpha \in S : \alpha_i = 0\}$ also satisfies the symmetric exchange axiom, and more generally, every minor $S / A \setminus B$ (for disjoint $A, B \subseteq \{1, \ldots, n\}$) satisfies exchange.

**Test:** Implement deletion and minor computation in the existing Python pipeline. Exhaustively test all M-convex supports with $n \leq 5$, $d \leq 6$. A single failure disproves the conjecture.

**Impact:** Combined with our contraction theorem, this would give a complete M-convex minor calculus, enabling formal matroid-theoretic reasoning through polynomial operations. It would mean that *every* polynomial obtained by setting variables to zero or differentiating — the two most basic operations — preserves the exchange skeleton.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` — `SetSatisfiesExchange.contraction`, `SupportContraction`

**Proof Strategy:** Direct: elements of $S \setminus i$ are a subset of $S$, so exchange witnesses in $S$ that don't involve coordinate $i$ transfer directly. The non-trivial case is when the exchange witness in $S$ uses coordinate $i$, requiring a secondary exchange.

**Domain Bridges:** Matroid theory ↔ polynomial algebra ↔ discrete optimization

**Lineage:** Extends `SetSatisfiesExchange.contraction` from contraction to arbitrary minors.

**Ambition:** Solid extension — this is classical in matroid theory but not yet formalized in the polynomial-algebraic setting.

**The key insight is** that deletion is the *dual* of contraction, and together they generate the full minor calculus. **Why now?** The contraction theorem provides the harder half; deletion should follow with similar techniques, and the formalization infrastructure is already in place.

---

## Direction 2: Coefficient Log-Concavity Through the Derivative Tower

**Conjecture:** If $p$ is a homogeneous polynomial with non-negative coefficients and M-convex support, then for any direction $v \in \mathbb{N}^n$, the univariate polynomial $t \mapsto p(tv)$ has a log-concave coefficient sequence. More strongly, the sequence of coefficients along any line through the support polytope is ultra-log-concave.

**Test:** For degree-$d$ polynomials in $n \leq 4$ variables with random non-negative coefficients on M-convex supports, compute the univariate restriction and test log-concavity. This tests the stronger claim that M-convex support + non-negativity implies coefficient log-concavity.

**Impact:** This would establish that support M-convexity alone (without full Lorentzianity) implies strong coefficient inequalities. If true, it significantly broadens the applicability of Lorentzian-type results.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` — `SupportSatisfiesExchange`, `coeff_pderiv`; `Catalog/FINAL/Pythagorean/LorentzianRecognitionComplete.lean` — `IsBrandenHuhLorentzian`

**Proof Strategy:** Use the derivative tower: at each level, the support remains M-convex (by our theorem). The coefficient at level $k$ relates to the value of the $(d-k)$-th derivative at the origin, and log-concavity might follow from the exchange structure constraining these values.

**Domain Bridges:** Discrete convex analysis ↔ algebraic combinatorics ↔ probability (log-concave distributions)

**Lineage:** Connects `SupportSatisfiesExchange.mixedPDeriv` to the Brändén–Huh log-concavity framework.

**Ambition:** Grand challenge — this would be a significant strengthening of the Brändén–Huh results if true, or an important negative result if false.

**The key insight is** that the derivative tower creates a sequence of polynomials with progressively simpler M-convex supports, and the coefficient values along this tower should satisfy concavity constraints dictated by the exchange geometry. **Why now?** The formal derivative tower is now available, and computational testing is straightforward with the existing infrastructure.

---

## Direction 3: Tropical Support Contraction and Newton Polytope Geometry

**Conjecture:** Support contraction $S / i$ corresponds to a specific face operation on the Newton polytope $\text{Newt}(S) = \text{conv}(S)$: it is the image of the positive-$i$ face under the coordinate projection $\alpha \mapsto \alpha - e_i$. Moreover, if $\text{Newt}(S)$ is a generalized permutohedron (equivalently, $S$ is M-convex), then $\text{Newt}(S/i)$ is also a generalized permutohedron.

**Test:** For M-convex supports in $n \leq 4$, $d \leq 6$, compute both the support contraction and the Newton polytope face operation independently and verify they agree. Test the generalized permutohedron property using the submodularity characterization.

**Impact:** This would establish a geometric interpretation of derivative contraction, connecting polynomial differentiation to tropical geometry and polytope theory. It could yield new proofs of polytope-theoretic results via polynomial methods.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` — `SupportContraction`, `support_pderiv_eq_supportContraction`

**Proof Strategy:** The key step is showing that the lattice point image of a face of a generalized permutohedron under coordinate projection is again a generalized permutohedron. This should follow from the submodularity characterization: $f(A \cup B) + f(A \cap B) \leq f(A) + f(B)$ for the support function.

**Domain Bridges:** Discrete convex analysis ↔ tropical geometry ↔ polytope theory ↔ algebraic geometry

**Lineage:** Builds on `SupportContraction` and connects to the Ardila–Klivans–Williams theory of generalized permutohedra.

**Ambition:** Solid extension with high payoff — the polytope perspective would make the results accessible to a broader geometric audience.

**The key insight is** that M-convex sets are precisely the lattice point sets of generalized permutohedra (Murota's theorem), so support contraction should be interpretable as a polytope operation. **Why now?** The formal support contraction definition and its correspondence with differentiation are now machine-verified, providing a solid foundation for the geometric extension.

---

## Direction 4: Algorithmic Consequences — Optimization via Derivative Descent

**Conjecture:** For a polynomial $p$ with M-convex support and non-negative coefficients, the contraction hierarchy $\text{supp}(p) \supseteq \text{supp}(\partial_i p) \supseteq \text{supp}(\partial_i \partial_j p) \supseteq \cdots$ provides a polynomial-time algorithm for optimizing linear functions over $\text{supp}(p)$, with complexity $O(n \cdot d \cdot |S|)$ where $d$ is the maximum degree.

**Test:** Implement the "derivative descent" algorithm: at each step, choose the variable $i$ that maximizes the objective on the contracted support, differentiate, and recurse. Compare with brute-force optimization on random M-convex supports up to $|S| = 1000$.

**Impact:** This would yield a new polynomial-time algorithm for a broad class of combinatorial optimization problems, complementing existing algorithms based on matroid intersection and submodular function minimization.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` — `SupportSatisfiesExchange.pderiv`, `exchangeWidth_pderiv_le`, `exchangeDepth_pderiv_le`

**Proof Strategy:** At each contraction step, the exchange property guarantees that local optima are global optima (the greedy property). The derivative tower provides a natural decomposition where each level has strictly smaller depth. Correctness follows from M-convexity at each level; efficiency from the depth bound $d(S/i) \leq d(S) - 1$.

**Domain Bridges:** Discrete convex analysis ↔ combinatorial optimization ↔ algorithm design

**Lineage:** Extends `exchangeDepth_pderiv_le` to an algorithmic framework.

**Ambition:** Solid extension — the algorithmic framework is natural, but proving optimality of the greedy strategy requires careful analysis.

**The key insight is** that the monotonicity of exchange depth under differentiation bounds the length of any contraction sequence, making derivative descent a terminating algorithm with a natural complexity bound. **Why now?** The depth monotonicity is now formally verified, providing the termination guarantee needed for algorithmic correctness.

---

## Direction 5: Hodge-Riemann Relations from Support Exchange Towers

**Conjecture (Grand Challenge):** The iterated derivative tower of a polynomial with M-convex support satisfies Hodge-Riemann-type bilinear relations: for the degree-2 Hessian at any level, the signature is $(1, n-1)$ (at most one positive eigenvalue) whenever the polynomial is additionally Lorentzian.

More precisely: if $p$ is Lorentzian of degree $d$ and $\alpha$ is a multi-index with $|\alpha| = d - 2$, then the Hessian matrix $H_{ij} = \text{coeff}_{e_i + e_j}(\partial^\alpha p)$ has at most one positive eigenvalue. This is exactly the Brändén–Huh characterization, but proved via the support exchange tower rather than the analytic route.

**Test:** For Lorentzian polynomials with $n \leq 4$, $d \leq 6$ (constructed as products of linear forms), verify the Hessian signature at all derivative levels. Compare with the exchange property at each level.

**Impact:** This would provide an alternative, more combinatorial proof of the Brändén–Huh characterization theorem, potentially extending to settings where the analytic techniques break down. It would connect the exchange tower directly to Hodge theory.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` — `SupportSatisfiesExchange.mixedPDeriv`; `Catalog/FINAL/Pythagorean/LorentzianRecognitionComplete.lean` — `IsBrandenHuhLorentzian`, `HasAtMostOnePositiveEigenvalue`, `recursivelyLorentzian_iff_brandenHuh`

**Proof Strategy:** Use the fact that the exchange property at every level of the derivative tower constrains the coefficient ratios. At the degree-2 level, these constraints should force the Hessian to have Lorentzian signature. The key technical step would be showing that M-convex quadratic forms have at most one positive eigenvalue.

**Domain Bridges:** Discrete convex analysis ↔ Hodge theory ↔ algebraic geometry ↔ spectral theory

**Lineage:** Connects the full derivative tower (`SupportSatisfiesExchange.mixedPDeriv`) to the Lorentzian recognition complete framework (`recursivelyLorentzian_iff_brandenHuh`).

**Ambition:** Grand challenge / paradigm-shifting — a combinatorial proof of Hodge-Riemann relations would be a major breakthrough in algebraic combinatorics.

**The key insight is** that the exchange property at every derivative level is a discrete shadow of the Hodge-Riemann bilinear relations, and making this shadow precise could provide a new route to these deep inequalities. **Why now?** The full derivative tower is now formally verified, creating the infrastructure needed to systematically study the interplay between exchange and curvature at every level.
