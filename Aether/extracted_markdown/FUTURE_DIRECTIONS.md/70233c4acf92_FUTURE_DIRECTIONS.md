# Future Directions: EML Integration in Finite Terms

## Synthesis

This research cycle established the **Differential EML Extension** (`DiffEMLField`) as a novel algebraic structure that unifies the exponential and logarithmic cases of the Risch algorithm. The key discovery is that the EML function `eml(x,y) = exp(x) - log(y)` is the canonical "mixed" element in a differential field extension tower — its derivative naturally decomposes into the two parts processed separately by the Risch algorithm. This structural insight connects three domains: **differential algebra** (the Risch algorithm's theoretical foundation), **convex analysis** (via the Fenchel-Young inequality), and **computational complexity** (via the polynomial-time bounds of Hermite reduction).

The most productive cross-domain connection from this cycle is the link between EML's non-closure under integration and the catalog's `eml_beats_poly_for_towers` result: the reason EML representations outperform polynomials is precisely because integration creates expressions (like `x·log(x)`) that escape polynomial representation but remain within the EML-augmented universe. This suggests that the differential-algebraic properties of EML directly explain its approximation-theoretic advantages.

The highest breakthrough potential lies in Direction 1 (Risch decidability for the full EML class), which would be the first complete formalization of a non-trivial fragment of the Risch algorithm. Direction 3 (EML tower height and expressiveness) offers the most surprising potential results, connecting integration theory to neural network depth separation.

---

### Direction 1: Risch Decidability for Rational EML Integrands

**Conjecture**: For EML integrands of the form `eml(f(x), g(x))` where f, g are rational functions of degree ≤ n, the question of whether an elementary antiderivative exists is decidable in O(n⁴) arithmetic operations.

**Test**: Implement the full Risch algorithm specialized to EML integrands (exponential part from `exp(f)`, logarithmic part from `-log(g)`). Run on 1000 random rational functions of degrees 1 through 20. Measure: (1) the fraction that have elementary antiderivatives, (2) the operation count, (3) whether the count scales as n⁴.

**Impact**: If true, this would be the first formally verified polynomial-time bound for a non-trivial fragment of the Risch algorithm. If the exponent is lower (e.g., O(n³)), it would reveal that the exponential and logarithmic subroutines interact more efficiently than expected.

**Catalog References**: `EML/RischEML/HermiteReduction.lean`, `Computation/OrdinalPRS.lean` (termination in energy steps)

**Proof Strategy**: 
1. Formalize the extended Euclidean algorithm for polynomials over ℝ[X]
2. Implement Hermite reduction as a computable function with a fuel parameter
3. Implement Rothstein-Trager as a separate function
4. Combine both with the exponential case (solving the Risch differential equation D(y) + f·y = g)
5. Prove the step-count bound by induction on the degree

**Domain Bridges**: Computation (polynomial-time algorithms) <-> EML (integration) <-> Algebra (polynomial GCD)

**Lineage**: Extends this cycle's Hermite reduction formalization and degree bounds.

**Ambition**: grand_challenge

---

### Direction 2: EML Convex Duality and Information Geometry

**Conjecture**: The Fisher information metric on the exponential family {p_x(s) = exp(x·s - A(x))} equals the second derivative of the EML Fenchel-Young gap function, i.e., g_F(x) = ∂²/∂x² [exp(x) + s·log(s) - s - x·s]|_{s=exp(x)} = exp(x).

**Test**: Compute the Fisher information for the EML-parameterized exponential family and verify that it coincides with exp(x). Check whether the geodesic equation on this information manifold has closed-form solutions in terms of EML functions.

**Impact**: If true, this would establish EML as the natural coordinate system for the information geometry of exponential families, providing a deep structural reason for its approximation-theoretic properties. If false, it would reveal that EML's information geometry is fundamentally different from the standard exponential family geometry.

**Catalog References**: `EML/RischEML/Integration.lean` (fenchel_young_eml), `Shared/EMLInformationGeometry` (Fisher information of exp)

**Proof Strategy**:
1. Define the EML-parameterized exponential family as a formal structure
2. Compute the Fisher metric using Mathlib's `HasDerivAt` machinery
3. Show the metric equals exp(x) using the Fenchel-Young connection
4. Study the geodesic equation and its relation to EML compositions

**Domain Bridges**: EML (function theory) <-> Shared (information geometry) <-> MachineLearning (statistical learning theory)

**Lineage**: Builds on this cycle's Fenchel-Young inequality proof and connects to the existing `EML Information Geometry` research thread (Q=0.36).

**Ambition**: extension

---

### Direction 3: EML Tower Height and Depth Separation

**Conjecture**: Define the **EML tower height** of a function f as the minimum number of nested exp/log operations needed to express f. The antiderivative of an EML function of tower height h has tower height exactly h+1 (not h, not h+2). More precisely: if `eml(f,g)` has tower height h, then `∫ eml(f,g) dx` has tower height h+1 when the antiderivative exists.

**Test**: Compute tower heights for concrete EML functions and their antiderivatives:
- `eml(x, 1) = exp(x)`: tower height 1, antiderivative `exp(x)`: tower height 1 (boundary case, not h+1)
- `eml(x, x) = exp(x) - log(x)`: tower height 1, antiderivative `exp(x) - x·log(x) + x`: tower height 2
- `eml(exp(x), exp(x))`: tower height 2, check antiderivative tower height
Verify the conjecture for all tower heights 1 through 4.

**Impact**: If true, this would provide the first rigorous "depth separation" theorem for integration: integration inherently increases the complexity of expressions. This would connect to neural network depth separation via the catalog's `eml_beats_poly_for_towers` result — depth separation in EML networks would reflect the algebraic necessity of deeper towers for antiderivatives.

**Catalog References**: `EML/UniversalApproxComplexity.lean` (eml_beats_poly_for_towers), `MachineLearning/EMLDepthSeparation/`

**Proof Strategy**:
1. Define EML tower height as an inductive measure on the syntax of EML expressions
2. Prove that differentiation preserves or decreases tower height (using the chain rule decomposition)
3. Prove that integration of height-h functions requires height h+1 by showing the antiderivative formula introduces new log compositions
4. Identify the boundary cases (like exp(x)) where height is preserved

**Domain Bridges**: EML (tower height) <-> MachineLearning (depth separation) <-> Algebra (differential field extension towers)

**Lineage**: Extends this cycle's non-closure theorem (EML diagonal antiderivative has higher complexity than the integrand).

**Ambition**: grand_challenge

---

### Direction 4: Tropical Risch Algorithm

**Conjecture**: There exists a "tropical Risch algorithm" that decides whether the tropical integral (infimal convolution) of a tropical EML function (defined as `eml_trop(x,y) = min(x, -y)`) has a tropical elementary antiderivative. The tropical algorithm has complexity O(n²) — one degree lower than the classical Risch algorithm — because tropical polynomial GCD is linear.

**Test**: Implement the tropical Risch algorithm and compare its decisions with the classical Risch algorithm on the "tropicalization" of 100 rational function integrands. Check whether every classically integrable function tropicalizes to a tropically integrable function (this would fail if the tropicalization loses essential algebraic structure).

**Impact**: If true, the tropical Risch algorithm would be a fast "pre-filter" for the classical algorithm: if the tropical version says "no," the classical version also says "no" (but not vice versa). This could speed up symbolic integration in practice.

**Catalog References**: `Tropical/`, `EML/EMLTropicalSemiring.lean`, `Bridges/EMLTropicalSemiring.lean`

**Proof Strategy**:
1. Define tropical differential fields as semirings with a "tropicalization" of the derivation
2. Formalize tropical Hermite reduction using tropical polynomial GCD (which is piecewise-linear)
3. Prove the O(n²) complexity bound
4. Establish the "surjection" from classical to tropical integrability

**Domain Bridges**: Tropical (semiring) <-> EML (integration) <-> Computation (algorithm complexity)

**Lineage**: New direction inspired by the Tropical and EML catalog entries.

**Ambition**: extension

---

### Direction 5: Automated Risch Decision Procedure as a Lean Tactic

**Conjecture**: A Lean 4 tactic `risch_decide` can be implemented that, given a goal of the form `∃ F, ∀ x, HasDerivAt F (f x) x` where `f` is a closed-form EML expression, either produces the antiderivative and proves the goal, or proves that no elementary antiderivative exists.

**Test**: Apply the tactic to 50 benchmark integration problems from standard calculus textbooks. Measure: (1) success rate, (2) time per problem, (3) whether the tactic correctly identifies non-integrable cases.

**Impact**: This would be the first verified symbolic integrator inside a proof assistant, capable of both finding antiderivatives AND certifying non-integrability. Current proof assistants can verify given antiderivatives but cannot discover them or prove their non-existence.

**Catalog References**: `EML/RischEML/Integration.lean`, `EML/RischEML/HermiteReduction.lean`

**Proof Strategy**:
1. Implement polynomial arithmetic as computable functions in Lean 4
2. Implement Hermite reduction and Rothstein-Trager as computable functions
3. Prove soundness: if the tactic produces F, then `HasDerivAt F f x`
4. Prove completeness for rational functions: if no antiderivative exists, the tactic correctly reports this
5. Package as a `macro` or `tactic` in Lean 4

**Domain Bridges**: Logic (decision procedures) <-> EML (integration) <-> Computation (computable algebra)

**Lineage**: Grand challenge building on all results from this cycle.

**Ambition**: grand_challenge
