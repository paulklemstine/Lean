# Future Directions: M-Convex Support Shadow Compression

## Synthesis

The results in this cycle establish that degree shadows of M-convex supports are finite, contained in the active coordinate simplex, and — in the multiaffine case — bounded by the binomial coefficient C(ω, k). The critical discovery is that the binomial bound *fails* for general M-convex sets, identifying multiaffinity as the essential structural hypothesis. This creates a sharp boundary in the landscape: exchange geometry alone controls shadow *structure* (containment, finiteness, tropical stability) but not shadow *size* beyond the multiaffine case.

The directions below explore both sides of this boundary: tightening bounds for non-multiaffine M-convex sets, investigating shadow M-convexity, connecting to Lorentzian positivity, building algorithmic infrastructure, and bridging to tropical and polyhedral geometry. Together, they form a coherent program to understand when and why exchange geometry controls combinatorial complexity.

---

## Direction 1: Tight Shadow Bounds for Non-Multiaffine M-Convex Sets

**Conjecture:** For an M-convex family S of degree d on ω active coordinates with maximum coordinate value M = max_{m ∈ S, i} m(i), the degree-k shadow satisfies:

$$|\text{shadow}_k(S)| \leq \binom{\omega + \min(k, M) - 1}{\min(k, M)}$$

When M = 1 (multiaffine), this reduces to C(ω, k). When M ≥ k, this gives the stars-and-bars bound C(ω + k − 1, k). The conjecture asserts that the true bound interpolates between these extremes, controlled by the maximum coordinate value.

**Test:** Enumerate all M-convex families on n ≤ 5 coordinates with d ≤ 6, compute shadow sizes, and verify the conjectured bound. Search for families achieving equality.

**Impact:** Would provide the first non-trivial shadow bound for non-multiaffine M-convex sets, applicable to Schur polynomial supports, polymatroid bases, and Lorentzian polynomial recognition in the non-multiaffine regime.

**Catalog References:** `Pythagorean/MConvexShadowCompression.lean` (degreeShadowSet, multiaffine bound), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (IsMConvexExchangeNat)

**Proof Strategy:** Induction on M. For M = 1, apply the multiaffine bound. For general M, decompose the shadow into "multiplicity layers" and bound each layer separately using a coordinate-splitting argument.

**Domain Bridges:** Connects to Lorentzian polynomial theory (non-multiaffine Lorentzian supports), algebraic combinatorics (Schur polynomial Newton polytopes).

**Lineage:** Extends Theorem 4 (multiaffine shadow bound) beyond the 0/1 regime.

**Ambition:** Extension — directly builds on established results with a clear path to formalization.

---

## Direction 2: Shadow M-Convexity

**Conjecture:** The degree-k shadow of an M-convex family S of degree d is itself M-convex, provided k ≤ d.

**The key insight is** that if u, v ∈ shadow_k(S) with u(i) > v(i), then the dominating elements m_u, m_v ∈ S can be "aligned" via M-convex exchanges on S to produce a dominator for the exchange element u − e_i + e_j.

**Why now?** The shadow hereditary exchange definition in our formalization (ShadowHereditaryExchange) provides the exact framework for stating and proving this. The existing M-convex exchange infrastructure in Mathlib/catalog makes the inductive argument tractable.

**Test:** Computationally verify for all M-convex families on n ≤ 4 coordinates with d ≤ 5. If a counterexample exists, characterize the failure mode.

**Impact:** If true, this would be a significant structural theorem in discrete convex analysis, implying that shadows (lower sections) of M-convex sets inherit the full exchange structure. This would extend Murota's theory and have implications for polynomial optimization.

**Catalog References:** `Pythagorean/MConvexShadowCompression.lean` (ShadowHereditaryExchange), `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (IsMConvexExchangeNat)

**Proof Strategy:** Fix u, v in shadow_k with u(i) > v(i). Take dominators m_u ≥ u, m_v ≥ v in S. Apply M-convex exchange to m_u, m_v at coordinate i to get m_u − e_i + e_j ∈ S. Show that u − e_i + e_j ≤ m_u − e_i + e_j (this needs j to be chosen carefully — may need to choose j where u(j) < v(j) AND m_u(j) < m_v(j), which is not guaranteed).

**Domain Bridges:** Connects to polyhedral combinatorics (face structure of base polytopes), discrete optimization (feasible set operations).

**Lineage:** Motivated by the gap between ShadowHereditaryExchange (defined) and its proof (open).

**Ambition:** Grand challenge — if true, this is a genuinely new theorem in discrete convex analysis with broad implications.

---

## Direction 3: Lorentzian Positivity and Shadow Tightening

**Conjecture:** For Lorentzian polynomial supports (M-convex families arising from polynomials with the Lorentzian sign pattern), the shadow bound is tighter than for general M-convex sets. Specifically:

$$|\text{shadow}_{d-2}(S)| \leq \binom{\omega}{d-2}$$

even when S is not multiaffine, provided S is the Newton support of a Lorentzian polynomial.

**The key insight is** that Lorentzian polynomials satisfy positivity constraints (nonneg coefficients, PSD Hessians after reduction) that M-convex sets alone do not. These constraints may force the shadow to be "close to multiaffine" in a quantifiable sense.

**Why now?** The catalog already has the Lorentzian quadratic infrastructure (`IsLorentzianQuadratic` in `LorentzianMConvex.lean`) and the connection between M-convexity and Lorentzian supports. The counterexample (full simplex) is M-convex but may not be the support of a Lorentzian polynomial — checking this would be the first test.

**Test:** (1) Determine whether the full degree-4 simplex on 3 variables is the Newton support of a Lorentzian polynomial. If not, the conjecture survives. (2) Check degree-3 and degree-4 Schur polynomial supports (which ARE Lorentzian) against the binomial bound.

**Impact:** Would establish that Lorentzian positivity provides combinatorial structure beyond M-convexity, with implications for polynomial optimization and algebraic geometry.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (IsLorentzianQuadratic, NewtonSupport), `Pythagorean/MConvexShadowCompression.lean` (degreeShadowSet)

**Proof Strategy:** Use the Lorentzian condition (one positive eigenvalue for Hessian) to show that support elements cannot be too "concentrated" on single coordinates, forcing the shadow toward multiaffinity.

**Domain Bridges:** Bridges discrete convex analysis with combinatorial Hodge theory and log-concavity theory.

**Lineage:** Extends the Brändén–Huh M-convexity result by asking what additional structure Lorentzian positivity provides.

**Ambition:** Grand challenge — would establish a new layer in the hierarchy: matroid ⊂ Lorentzian ⊂ M-convex, each with distinct shadow bounds.

---

## Direction 4: Sublinear Shadow Certification

**Conjecture:** For multiaffine M-convex supports of degree d and active width ω, shadow membership can be certified in O(ω · log d) time given a precomputed exchange tree of size O(ω · d).

**The key insight is** that the domination witnesses in our shadow certificate can be organized into a binary search tree indexed by the exchange graph structure, enabling membership queries without scanning all support elements.

**Why now?** The shadow certificate construction and exchange graph algorithms in our Python code provide the computational infrastructure. The formal bound C(ω, k) from Theorem 4 gives the theoretical ceiling.

**Test:** Implement the certificate data structure for uniform matroids U_{r,n} with n up to 20 and measure query times. Compare against naive O(|S| · n) scanning.

**Impact:** Would make Lorentzian polynomial recognition practical for large instances by reducing Hessian analysis to sublinear certificate lookups.

**Catalog References:** `Pythagorean/MConvexShadowCompression.lean` (degreeShadowSet_finite, degreeShadow_card_le_of_multiaffine), `Catalog/Bridges/Catalog/Pythagorean/SupportCertificateCompression.lean` (countNonzeroQuadraticLeavesFromSupport)

**Proof Strategy:** Construct a balanced binary search tree over the exchange graph of S. At each node, store a partial assignment of coordinates that determines whether a query vector is dominated. The depth of the tree is O(log |S|) ≤ O(ω log d).

**Domain Bridges:** Connects to computational complexity theory (sublinear algorithms), optimization (fast feasibility checking).

**Lineage:** Algorithmic extension of the shadow bound from Theorem 4.

**Ambition:** Extension — builds directly on established results with a clear implementation path.

---

## Direction 5: Tropical M-Convexity and Regular Subdivision Compatibility

**Conjecture:** For any M-convex family S and any weight vector w with at most r distinct values (r < ω), the initial support init_w(S) satisfies M-convex exchange on the contracted coordinate space where equal-weight coordinates are identified.

**The key insight is** that our tropical exchange stability theorem (Theorem 5) shows exchange preservation within equal-weight classes. The conjecture extends this to full M-convexity of the initial support after coordinate contraction.

**Why now?** The tropical stability theorem provides the foundation. Coordinate contraction for M-convex sets is studied in Murota's theory but the connection to tropical initial forms has not been formalized.

**Test:** For Schur polynomial supports with 4–5 variables, compute initial supports under all weight vectors with 2 distinct values. Check M-convexity of the contracted supports.

**Impact:** Would establish that the tropical variety of a polynomial with M-convex support has a *combinatorial* face structure controlled by exchange geometry. This is a fundamental connection between tropical geometry and discrete convex analysis.

**Catalog References:** `Pythagorean/MConvexShadowCompression.lean` (tropicalDot, initialSupportSet, tropical_exchange_equal_weight)

**Proof Strategy:** For α, β in init_w(S), apply M-convex exchange on S to get γ = α − e_i + e_j ∈ S. By tropical stability (Theorem 5), if w(i) = w(j), then tropDot(w, γ) = tropDot(w, α), so γ ∈ init_w(S). For w(i) ≠ w(j), use the minimality of α to bound tropDot(w, γ).

**Domain Bridges:** Bridges discrete convex analysis with tropical geometry and polyhedral combinatorics (regular subdivisions, secondary polytopes).

**Lineage:** Direct extension of the tropical exchange stability theorem.

**Ambition:** Extension — achievable with existing tools, high potential for cross-domain impact.
