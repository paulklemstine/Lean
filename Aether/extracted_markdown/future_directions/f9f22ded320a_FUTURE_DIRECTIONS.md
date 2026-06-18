# Future Directions: Universal Support-Tutte Polynomial

## Synthesis

The Universal Factorization Theorem establishes that M-convex support sets possess a universal deletion–contraction invariant, opening a new interface between discrete convex analysis, combinatorial algebra, tropical geometry, and statistical mechanics. The five directions below explore this interface systematically. Direction 1 (two-variable extension) and Direction 2 (order independence) are foundational improvements to the core theory. Directions 3–5 are cross-domain bridges that leverage the universality theorem to create new tools in seemingly unrelated fields. Together, they form a research program aimed at embedding M-convex supports into the same universal algebraic framework — combinatorial Hopf algebras — that unifies graphs, matroids, posets, and permutations.

---

## Direction 1: Two-Variable Support-Tutte Polynomial with Coloop Weight

**Conjecture:** There exists a two-variable polynomial T(S) ∈ ℕ[X, Y] satisfying:
- T(S) = Y · T(S \ i) for coloop coordinates (all elements have the same i-value)
- T(S) = X · T(S / i) for loop coordinates
- T(S) = T(S \ i) + T(S / i) for ordinary coordinates
and satisfying a universal factorization theorem with parameters (a, b, u, v).

**Test:** Enumerate all M-convex supports in the degree-≤5 simplex with 3 variables. Compute the two-variable polynomial under at least two orderings. Verify agreement for M-convex sets and disagreement for non-M-convex sets.

**Impact:** This would give the full analogue of the classical Tutte polynomial T_M(x, y) for supports. The coloop weight captures information that our current one-variable polynomial misses: the distinction between coordinates that are "frozen" (coloops) and coordinates that are absent (trivial).

**Catalog References:** `Catalog/Pythagorean/SupportMinorTheory.lean` (IsSupportColoop definition), `Catalog/Pythagorean/UniversalSupportTutte.lean` (dc_invariant_unique with loop weight).

**Proof Strategy:** Extend the well-founded recursion to include a coloop case. The measure descent for coloops requires showing that deleting a coloop strictly reduces the support. The universality proof extends by adding a coloop case to the induction.

**Domain Bridges:** Matroid theory (two-variable Tutte polynomial), statistical mechanics (Potts model with external field).

**Lineage:** Directly extends Theorem C of the current work. Builds on the coloop characterization in SupportMinorTheory.lean.

**Ambition:** Solid extension — high probability of success with moderate effort.

---

## Direction 2: Order Independence and Activity Expansion

**Conjecture:** For every finite M-convex support S and every total order on coordinates, the support-Tutte polynomial T(S) admits an activity expansion:
$$T(S) = \sum_{\sigma} X^{\text{loop-activities}(\sigma)}$$
where the sum is over all "support trees" (minimal recursive decomposition sequences) and the activity counts are independent of the chosen order.

**Test:** Enumerate all M-convex supports in the degree-≤5 simplex with 4 variables. For each, compute T(S) under all 24 coordinate orderings. Any disagreement falsifies order-independence. Then compute the activity expansion and verify it equals T(S) for at least 3 orderings.

**Impact:** This would be the support analogue of the Crapo–Tutte activity theorem, one of the deepest results in matroid theory. It would provide a combinatorial formula for T(S) without recursion, enabling faster computation and deeper structural analysis.

**Catalog References:** `Pythagorean/SupportTuttePolynomial.lean` (supportTuttePoly definition), `Catalog/Pythagorean/UniversalSupportTutte.lean` (activity_partition theorem).

**Proof Strategy:** Strategy A: Prove commutativity of deletion and contraction operations for M-convex supports, then derive order-independence. Strategy B: Use the exchange property to construct canonical activities and prove the expansion directly. Strategy C: Use the universality theorem applied to the polynomial ring itself (T as both the invariant and the target).

**Domain Bridges:** Matroid theory (Crapo activities), combinatorial Hopf algebras (character theory), algebraic topology (Morse theory on support complexes).

**Lineage:** Extends the factorization theorem by strengthening it from "factors through T for a specific coordinate choice" to "T is independent of all choices."

**Ambition:** Grand challenge — this is the hardest open problem in the theory and would be a major contribution if solved.

---

## Direction 3: Support-Tutte Polynomial as Tropical Invariant

**Conjecture:** If two M-convex supports S₁ and S₂ have isomorphic mixed subdivisions of their Newton polytopes, then there exists a change of variables relating T(S₁) and T(S₂).

**Test:** Compute the mixed subdivisions of Newton polytopes for all M-convex supports in the degree-≤4 simplex with 3 variables. Group by subdivision type. Within each group, check whether T(S) is invariant up to polynomial substitution.

**Impact:** This would establish the support-Tutte polynomial as a tropical invariant, connecting deletion–contraction theory to the rapidly developing field of tropical geometry. It could provide new tools for studying tropical varieties through their support structure.

**Catalog References:** `Catalog/Pythagorean/TropicalMConvexity.lean`, `Catalog/Pythagorean/TropicalLorentzianShadows.lean`.

**Proof Strategy:** Use the connection between M-convexity and regular subdivisions (Murota). Show that tropical modifications that preserve the subdivision type commute with deletion and contraction. Derive the invariance from universality.

**Domain Bridges:** Tropical geometry, algebraic geometry (Newton polytopes), optimization (linear programming duality).

**Lineage:** Builds on the tropical M-convexity infrastructure in the Catalog and extends the support-Tutte polynomial into geometric territory.

**Ambition:** Grand challenge — requires deep integration of combinatorial and geometric ideas.

---

## Direction 4: Partition Function and Phase Transitions

**Conjecture:** For M-convex supports arising as energy-level configurations of discrete systems, the specialization Z(β) = T(S)|_{X=e^{-β}} exhibits a phase transition at a critical inverse temperature β_c computable from the polynomial's roots.

**Test:** For the M-convex support of the degree-d simplex in n variables (which models n identical particles with total energy d), compute T(S) and find its real roots. Verify that the largest real root r satisfies β_c = -log(r) and that the free energy F = -log(Z) has a non-analyticity at β_c for d, n → ∞.

**Impact:** This would provide a rigorous discrete analogue of the Lee–Yang theory of phase transitions, connecting the support-Tutte polynomial to statistical mechanics. It could yield new exactly-solvable models where classical Tutte theory doesn't apply.

**Catalog References:** `Pythagorean/SupportTuttePolynomial.lean` (supportTutte_factorization), `Catalog/Pythagorean/LargeDeviationPressure.lean`.

**Proof Strategy:** Use the universality theorem to express Z(β) as an evaluation of T(S). Analyze the polynomial's roots using techniques from analytic combinatorics. The M-convexity (Lorentzian polynomial connection) may force the roots to be real and negative, yielding exactly one phase transition.

**Domain Bridges:** Statistical mechanics (Lee–Yang theorem), analytic combinatorics (singularity analysis), Lorentzian polynomials (log-concavity).

**Lineage:** Extends the cardinality specialization (Theorem D) from X=1 to general complex X, leveraging the Brändén–Huh theory.

**Ambition:** Solid extension with grand challenge elements.

---

## Direction 5: Combinatorial Hopf Algebra of M-Convex Supports

**Conjecture:** The pair (deletion, direct sum) defines a bialgebra structure on the vector space spanned by (isomorphism classes of) M-convex supports, and the support-Tutte polynomial is the universal character of this bialgebra.

**Test:** Verify the bialgebra axioms (coassociativity, compatibility of product and coproduct) for all M-convex supports of size ≤ 5 in 3 variables. Compute the character map and verify it equals T(S) on all test cases.

**Impact:** This would place M-convex supports alongside matroids, graphs, and posets in the ecosystem of combinatorial Hopf algebras. It would unlock the machinery of Hopf-algebraic renormalization, antipode computations, and character theory for support invariants.

**Catalog References:** `Catalog/Algebra/AntipodeUniqueness.lean`, `Catalog/Algebra/BerggrenHopfCore.lean`, `Pythagorean/SupportTuttePolynomial.lean`.

**Proof Strategy:** Define the product as disjoint-coordinate direct sum. Define the coproduct via all ways to partition coordinates into two groups, restricting the support to each group. Verify the compatibility axiom using the exchange property. Show that the support-Tutte polynomial is a character by verifying it is multiplicative on direct sums (which follows from the universality theorem applied to the product of polynomials).

**Domain Bridges:** Algebraic combinatorics (Hopf algebras), quantum field theory (renormalization), representation theory (character theory).

**Lineage:** This is the natural algebraic completion of the universality theorem. The universality says "T is the unique evaluation," and the Hopf algebra says "T is the unique character."

**Ambition:** Grand challenge — would open an entirely new chapter in algebraic combinatorics.
