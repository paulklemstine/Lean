# Future Directions: Support Rigidity and Circuit Lower Bounds

## Synthesis

The results in this cycle establish a formal pipeline: **anti-cancellation → support shadow → covering bound → circuit lower bound**. This pipeline is modular, with three independent extension points: (1) the shadow system (which polynomial families and operators?), (2) the combinatorial counting (how large is the shadow?), and (3) the circuit model (what gate types and depth?). The directions below attack each extension point, with two grand challenges targeting exponential separations and two concrete extensions building directly on the current theorems. A cross-domain bridge to tropical geometry completes the picture.

---

## Direction 1: Exponential Shadow Growth via Matroid Basis Polynomials

**Ambition:** Grand Challenge

**Conjecture:** For the graphic matroid basis polynomial of the complete bipartite graph K_{n,n} (whose support consists of all perfect matchings), the iterated Hessian shadow has size at least 2^{Ω(n)}, yielding exponential monotone circuit lower bounds.

**Test:** Compute the shadow of the perfect matching polynomial for K_{n,n} up to n = 8. Measure shadow growth rate. If the shadow grows subexponentially, the conjecture fails.

**Impact:** An exponential support-rigidity lower bound would be the first Hodge-theoretic proof of exponential monotone circuit complexity, providing a fundamentally new route to monotone lower bounds distinct from Razborov's communication-complexity method.

**Catalog References:**
- `Catalog/Pythagorean/SupportRigidityCircuitBounds.lean` (shadow system framework, covering lower bound)
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (anti-cancellation principle)

**Proof Strategy:** Define the basis exchange shadow for matroid basis polynomials. The key lemma is that basis exchange produces Ω(n) new shadow elements per basis, and the exchange graph has exponential ball growth. Formalize the basis exchange graph diameter bound from matroid theory.

**Domain Bridges:** Matroid theory, algebraic combinatorics, matching theory, communication complexity.

**Lineage:** Extends Theorem 6.6 (quadratic support rigidity for e₄) to a richer polynomial family with potentially exponential shadow growth.

---

## Direction 2: Tropical Support Rigidity and Valuated Matroid Lower Bounds

**Ambition:** Grand Challenge

**Conjecture:** There exists a tropical analogue of support rigidity where the "shadow" operation is replaced by tropical second derivatives (piecewise-linear operations on valuations), and this tropical shadow is at least as large as the classical shadow. This would extend lower bounds to tropical circuits and connect to the Speyer–Sturmfels theory of tropical linear spaces.

**Test:** Implement tropical second derivatives for the degree-4 elementary symmetric polynomial over the tropical semiring. Verify that the tropical shadow equals the classical shadow for n ≤ 15.

**Impact:** Tropical support rigidity would create the first bridge from Lorentzian/Hodge structure to tropical complexity, potentially yielding lower bounds for tropical arithmetic circuits—a model closely related to linear programming and optimization.

**Catalog References:**
- `Catalog/Pythagorean/SupportRigidityCircuitBounds.lean` (abstract shadow system)
- `Catalog/Tropical/` (existing tropical infrastructure)

**Proof Strategy:** Define a `TropicalShadowSystem` extending the abstract `ShadowSystem` framework. Prove that the tropical shadow is at least as large as the classical shadow by a valuation argument. Use the tropical Hodge theory of Adiprasito–Huh–Katz as the structural backbone.

**Domain Bridges:** Tropical geometry, optimization, linear programming, valuated matroids.

**Lineage:** Extends the abstract `ShadowSystem` framework to the tropical setting, a natural generalization.

---

## Direction 3: Higher-Order Shadows and Depth-d Circuit Bounds

**Ambition:** Solid Extension

**Conjecture:** For k-th order Hessian shadows (removing k variables instead of 2), the degree-2k elementary symmetric polynomial e_{2k}(x₁,...,xₙ) has k-th shadow size exactly C(n, k), and the resulting depth-(k+1) circuit lower bound is n^k / (k! · B).

**Test:** Compute k-th order shadows for k = 2, 3, 4 and n up to 12. Verify that shadow size = C(n, k).

**Impact:** This directly extends the main theorem to deeper circuits, showing that support rigidity provides a unified mechanism for lower bounds at every depth level.

**Catalog References:**
- `Catalog/Pythagorean/SupportRigidityCircuitBounds.lean` (degree-4 shadow system, Theorem 7.1)

**Proof Strategy:** Generalize `Quad4` to `Tuple_2k` (ordered 2k-tuples), define the k-th shadow as all k-subsets of each 2k-subset, and prove the analogue of Theorem 6.5 by the same pigeonhole argument. The covering lower bound (Theorem 4.1) applies unchanged.

**Domain Bridges:** Higher-order differential operators, jet spaces in algebraic geometry, depth hierarchy in circuit complexity.

**Lineage:** Direct generalization of the degree-4 shadow system and quadratic support rigidity theorem.

---

## Direction 4: Entropy Concentration and Log-Concavity Lower Bounds

**Ambition:** Solid Extension

**Conjecture:** For polynomial families whose support satisfies the stronger property of log-concavity of the shadow size sequence (|shadow_k| is log-concave in k), the entropy monotonicity theorem (Theorem 8.2) can be strengthened to give polynomial lower bounds on circuit cost that are tight up to constant factors.

**Test:** Verify log-concavity of the sequence (|shadow_k(e_d)|)_{k=0}^{d} for d = 4, 6, 8 and n up to 20. Check whether the entropy gap H(support) − H(shadow) is monotonically related to the circuit cost.

**Impact:** Would connect the deep theory of ultra-log-concavity (Mason's conjecture, proved by Brändén–Huh) to explicit circuit lower bounds, creating a quantitative link between Hodge theory and complexity.

**Catalog References:**
- `Catalog/Pythagorean/SupportRigidityCircuitBounds.lean` (combEntropy, entropy monotonicity)
- `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (positivity structure)

**Proof Strategy:** Define a sequence of shadow entropies H_k = log|shadow_k(S)|. Use the Alexandrov–Fenchel inequality (or its discrete analogue) to prove log-concavity. Then use the log-concavity to lower-bound the total entropy drop across all levels, giving a tighter circuit cost estimate.

**Domain Bridges:** Information theory, convex geometry (Alexandrov–Fenchel inequality), statistical mechanics (entropy concentration).

**Lineage:** Extends the entropy monotonicity theorem (Theorem 8.2) to a full entropy concentration result.

---

## Direction 5: Newton Polytope Hardness and Geometric Support Measures

**Ambition:** Solid Extension with Cross-Domain Bridge

**Conjecture:** The Newton polytope of the degree-4 elementary symmetric polynomial has edge neighborhood of size Ω(n²), and this geometric invariant gives an alternative proof of support rigidity that generalizes to non-multilinear polynomials.

**Test:** Compute the Newton polytope of e₄ for n = 4,...,12 using polymake or SageMath. Measure the edge neighborhood size and verify the Ω(n²) bound.

**Impact:** Would create a geometric proof of support rigidity independent of the combinatorial argument, opening the door to lower bounds for non-multilinear polynomials via mixed-volume arguments.

**Catalog References:**
- `Catalog/Pythagorean/SupportRigidityCircuitBounds.lean` (support rigidity framework)
- `Catalog/Geometry/` (potential geometric infrastructure)

**Proof Strategy:** Show that the shadow of the support set equals the edge neighborhood of the Newton polytope (when the polytope has integral vertices). Then bound the edge neighborhood using the polytope's f-vector, which for the symmetric polynomial polytope (the hypersimplex Δ(4,n)) is well-understood.

**Domain Bridges:** Polyhedral combinatorics, discrete convex geometry, mixed volumes, hypersimplex theory.

**Lineage:** Provides a geometric reinterpretation of Theorem 6.6, connecting to the broader Newton polytope approach to polynomial complexity.
