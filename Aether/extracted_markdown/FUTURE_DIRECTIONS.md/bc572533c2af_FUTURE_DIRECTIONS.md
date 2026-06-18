# Future Directions: Tropical Shadow Duality

## Synthesis

The Shadow Duality Principle — that Newton polytopes of Hessian entries are exactly the convex hulls of combinatorial quadratic leaf shadows — opens a systematic program for translating tropical/combinatorial data into certified algebraic-geometric invariants. The five directions below form a coherent progression: from strengthening the duality within its current domain (Directions 1–2), to extending it to new derivative orders and algebraic structures (Direction 3), to exploiting it for computational lower bounds (Direction 4), to pursuing the deepest conjecture connecting normal fans to tropical geometry (Direction 5). Together, they chart a path from a support-level identity to a full tropical complexity theory for polynomial differentiation.

---

## Direction 1: Mixed Volume Shadow Duality and Sparse Root Counts

**Conjecture:** For a family of polynomials $p_1, \ldots, p_m$ over $\mathbb{Q}$ with the non-cancellation property, the mixed volume of the Hessian Newton polytopes $\operatorname{Newt}(\partial_i \partial_j p_k)$ equals the mixed volume of the corresponding shadow polytopes $\operatorname{ShadowPolytope}(\operatorname{supp}(p_k), i, j)$.

**Test:** Implement mixed volume computation (e.g., via the Cayley trick or MixedVol algorithm) and compare mixed volumes of Hessian Newton polytopes versus shadow polytopes for random sparse polynomial families in 3–5 variables. A single discrepancy falsifies the conjecture.

**Impact:** Would provide certified root counts for Hessian systems (via BKK theorem) from support data alone, bypassing symbolic Hessian computation entirely. This would be transformative for sparse polynomial system solving.

**Catalog References:**
- `Pythagorean/TropicalShadowDuality.lean` — `newtonPolytope_hessianEntry_eq_shadowPolytope`, `newtonPoly_hessian_add_subset`
- `Catalog/Pythagorean/NonCancellationCertificate.lean` — `hessian_support_eq_quadLeafSet`

**Proof Strategy:** Since Theorem 1 establishes polytope equality for individual polynomials, mixed volume equality follows by congruence — the mixed volume is a function of the polytopes, and equal polytopes give equal mixed volumes. The challenge is formalizing the mixed volume definition in Lean and connecting it to the existing convex hull infrastructure.

**Domain Bridges:** Sparse algebraic geometry (BKK theory), enumerative geometry, computational algebra.

**Lineage:** Direct extension of Theorem 1 to families; builds on Theorem 4 (sum containment).

**Ambition:** Grand challenge — would connect shadow duality to intersection theory.

**The key insight is** that polytope equality implies all polynomial invariants of the polytope (including mixed volumes) are shadow-determined, converting an algebraic counting problem into a combinatorial one.

**Why now?** The polytope equality (Theorem 1) is established; what's needed is the mixed volume formalization infrastructure and the congruence argument.

---

## Direction 2: Shadow Duality for Higher-Order Derivatives

**Conjecture:** For $k$-th order partial derivatives $\partial_{i_1} \cdots \partial_{i_k} p$ over $\mathbb{Q}$, the Newton polytope equals the convex hull of the $k$-th order shadow:
$$\operatorname{quadLeafFinset}^{(k)}(S, i_1, \ldots, i_k) = \{\beta : \beta + e_{i_1} + \cdots + e_{i_k} \in S\}$$

**Test:** Compute $k$-th order shadows and $k$-th order derivative supports for random polynomials with $k = 3, 4, 5$. Verify support equality and convex hull equality.

**Impact:** Would extend the shadow duality principle from Hessians to all derivative orders, creating a complete dictionary between support combinatorics and derivative geometry.

**Catalog References:**
- `Pythagorean/TropicalShadowDuality.lean` — `coeff_pderiv_formula`, `coeff_hessian_ne_zero_iff`
- `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` — `coeff_pderiv_single`

**Proof Strategy:** The coefficient formula generalizes by induction on $k$: $\operatorname{coeff}_\beta(\partial_{i_1} \cdots \partial_{i_k} p) = c \cdot \operatorname{coeff}_{\beta + e_{i_1} + \cdots + e_{i_k}}(p)$ where $c$ is a product of positive integers. The non-cancellation property and Newton polytope transport follow by the same argument as in Theorems 1–3.

**Domain Bridges:** Jet spaces, differential algebra, higher-order optimization (tensor methods).

**Lineage:** Natural generalization of the $k=2$ case (Theorem 1).

**Ambition:** Solid extension — the proof strategy is clear, but formalization may require substantial infrastructure.

**The key insight is** that the non-cancellation property is not special to second derivatives; it holds for any order, because each coefficient is always a nonzero integer multiple of one ancestor coefficient.

**Why now?** The $k=2$ case is fully verified; the inductive step follows the same pattern and can reuse the existing coefficient formula infrastructure.

---

## Direction 3: Tropical Circuit Complexity Lower Bounds from Shadow Invariants

**Conjecture:** The number of vertices of $\operatorname{ShadowPolytope}(\operatorname{supp}(p), i, j)$ provides a lower bound on the tropical rank (and hence the multiplicative complexity) of the Hessian entry $\partial_i \partial_j p$ as a sparse polynomial.

**Test:** For families of polynomials with known circuit complexity (e.g., elementary symmetric polynomials, determinantal polynomials), compute shadow polytope vertex counts and compare against known or computable complexity measures.

**Impact:** Would establish a purely combinatorial route to arithmetic circuit lower bounds via polyhedral geometry — a new paradigm in algebraic complexity theory.

**Catalog References:**
- `Pythagorean/TropicalShadowDuality.lean` — `ShadowPolytope`, `shadowSupportFunction_correct`
- `Catalog/Pythagorean/NonCancellationCertificate.lean` — `shadowComplexity`

**Proof Strategy:** The connection between Newton polytope complexity and circuit complexity is mediated by tropical geometry: the Newton polytope determines the tropical variety, and tropical varieties provide circuit lower bounds (via the tropicalization of algebraic circuits). The shadow duality theorem allows these bounds to be computed from support data alone.

**Domain Bridges:** Arithmetic circuit complexity, tropical geometry, combinatorial optimization, computational learning theory.

**Lineage:** Exploits Theorems 1 and 3 (support function = tropical evaluation) to connect polyhedral data to complexity measures.

**Ambition:** Grand challenge — would open a genuinely new approach to circuit lower bounds.

**The key insight is** that Newton polytope invariants (vertex count, face lattice, support function complexity) are certified lower bounds on algebraic complexity, and shadow duality makes them computable from support data in polynomial time.

**Why now?** The shadow-to-polytope correspondence is verified; what's needed is the connection from Newton polytope invariants to circuit complexity measures, which draws on existing (but not yet formalized) results in tropical algebraic geometry.

---

## Direction 4: Shadow Methods for Sparse Hessian Preconditioning

**Conjecture:** The shadow support function provides a certified preconditioner for sparse Hessian computations: evaluating $h_{\operatorname{Shadow}}(w)$ at a logarithmic number of weight vectors suffices to reconstruct the face lattice of the Hessian Newton polytope.

**Test:** Implement face lattice reconstruction from support function evaluations at $O(n \log |S|)$ random weight vectors. Compare against direct convex hull computation.

**Impact:** Would provide a polynomial-time certified algorithm for Hessian Newton polytope reconstruction, with applications to sparse numerical optimization.

**Catalog References:**
- `Pythagorean/TropicalShadowDuality.lean` — `shadowSupportFunction`, `tropicalShadowEval_eq_supportFunction`

**Proof Strategy:** By Theorem 3, support function evaluations over the shadow equal those over the Hessian. By convex geometry, the support function at sufficiently many directions determines the polytope. The key technical challenge is bounding the number of directions needed as a function of the combinatorial complexity.

**Domain Bridges:** Numerical optimization, convex geometry, computational geometry, machine learning (sparse Hessian approximation).

**Lineage:** Application of Theorem 3 (tropical-algebraic bridge) to algorithmic problems.

**Ambition:** Solid extension with practical applications.

**The key insight is** that support function queries are the "dual" of vertex enumeration, and the shadow duality principle provides a certified correspondence between the two.

**Why now?** Sparse Hessian computation is a bottleneck in large-scale optimization; the shadow approach offers a fundamentally new algorithmic paradigm based on certified polyhedral data.

---

## Direction 5: Normal Fan Shadow Duality and Tropical Discriminants

**Conjecture:** For polynomials over $\mathbb{Q}$ with generic coefficients, the normal fan of $\operatorname{Newt}(\partial_i \partial_j p)$ equals the normal fan of $\operatorname{ShadowPolytope}(\operatorname{supp}(p), i, j)$. Equivalently, all regular subdivisions and secondary polytopes of the Hessian Newton polytope are shadow-determined.

**Test:** For random sparse polynomials in 3–4 variables with 10–30 terms:
1. Compute the face lattices of both polytopes.
2. For each face of one, verify existence and dimension of the corresponding face in the other.
3. Compute normal cones at each vertex and compare.

A single mismatch in the face lattice (not just the vertex set) would falsify the conjecture.

**Impact:** Would establish the strongest form of shadow duality: not just the polytope but its entire combinatorial type is shadow-determined. This would connect to tropical discriminants and A-discriminant theory.

**Catalog References:**
- `Pythagorean/TropicalShadowDuality.lean` — `newtonPolytope_hessianEntry_eq_shadowPolytope`, `shadowArgmax_eq_hessianArgmax`

**Proof Strategy:** By Theorem 1, the polytopes are equal as sets; the normal fan conjecture is thus trivially true for polytopes that are literally equal sets (same polytope = same normal fan). The deeper question is whether this extends to perturbations and generic weight functionals, connecting to secondary polytopes and regular subdivisions.

**Domain Bridges:** Tropical geometry, toric geometry, combinatorial commutative algebra, optimization (LP sensitivity analysis).

**Lineage:** Strengthening of Theorem 2 (vertex realization) to full face lattice correspondence.

**Ambition:** Grand challenge — connects shadow duality to some of the deepest structures in tropical geometry.

**The key insight is** that polytope equality (Theorem 1) already implies normal fan equality, since the normal fan is an invariant of the polytope as a set; the deeper question is whether this equality is "natural" in a categorical sense, commuting with perturbations and deformations.

**Why now?** Theorem 1 provides the polytope equality; the normal fan structure comes for free, but making this conceptually precise requires engaging with tropical and toric geometry infrastructure.
