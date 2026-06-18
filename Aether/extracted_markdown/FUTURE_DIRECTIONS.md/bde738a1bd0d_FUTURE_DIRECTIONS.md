# Future Directions: Universal Support-Tutte Polynomial

## Synthesis

The universality theorem for M-convex supports establishes that deletion–contraction invariant theory extends cleanly from matroids to the richer world of discrete convex supports. This opens a branching tree of research directions: *inward* toward deeper structural theorems about the invariant itself (activity expansions, positivity), *outward* toward connections with tropical geometry and statistical mechanics, and *upward* toward the algebraic infrastructure (Hopf algebras, categorical universality) that would place support-Tutte theory in its natural mathematical habitat. The five directions below are ordered from most immediately actionable to most ambitious, but each is independently falsifiable and could yield results within a single research cycle.

---

## Direction 1: Activity Expansion and Order-Independence

**Conjecture:** For every finite M-convex support S and every total order σ on the coordinates, the support-Tutte polynomial admits an explicit expansion
```
T_S(a) = Σ_{A ∈ Activities(S, σ)} a^{loops(A)}
```
where Activities(S, σ) is a finite set of "activity data" determined by σ, and this expansion is independent of σ.

**Test:** Enumerate all M-convex subsets of Δ(4, d) for d ≤ 4. For each, compute the activity expansion under all 24 permutations of 4 coordinates. Any disagreement falsifies the conjecture.

**Impact:** This would give a direct combinatorial formula for each coefficient of T_S(a), eliminating the need for recursion. It would also provide a constructive proof of order-independence, complementing the indirect proof via universality.

**Catalog References:**
- `Pythagorean/UniversalSupportTutte.lean`: `support_classification`, `activity_partition`, `dc_invariant_unique`

**Proof Strategy:** Define support activities relative to a linear order σ by tracking which coordinates are "internally active" (loops at the time of processing) vs. "externally active." Prove the expansion equals the deletion-contraction recursion by induction on the order. Use the classification theorem to handle the base cases.

**Domain Bridges:** Classical matroid activity theory (Tutte 1954, Crapo 1969), Bernardi's embedding-based activities (graphs → matroids → supports?).

**Lineage:** Extends the activity partition theorem (`activity_partition`) from counting to polynomial expansion.

**Ambition:** Medium — within reach given the existing infrastructure, but requires careful new definitions.

---

## Direction 2: Multivariate Universality with Full Parameter Space

**Conjecture:** There exists a universal polynomial `T_S(L, U, V) ∈ ℤ[L, U, V]` such that any function `F : Support → R` satisfying:
- `F(S) = L · F(tutteContract(S, i))` for loops,
- `F(S) = U · F(supportDelete(S, i)) + V · F(tutteContract(S, i))` for ordinary coordinates,

is uniquely of the form `F(S) = φ(T_S)` for a ring homomorphism `φ : ℤ[L, U, V] → R`.

**Test:** Verify the conjecture computationally for all M-convex subsets of Δ(3, 3) by checking that the multivariate polynomial is the same regardless of coordinate ordering.

**Impact:** This captures the full generality of the universal invariant, with the 1-parameter version as the specialization U = V = 1. It would also clarify the relationship with the classical 2-variable Tutte polynomial of matroids.

**Catalog References:**
- `Pythagorean/UniversalSupportTutte.lean`: `dc_invariant_unique` (current 1-parameter version)

**Proof Strategy:** Generalize `dc_invariant_unique` by replacing `a * f(...)` with `L * f(...)` and `f(del) + f(con)` with `U * f(del) + V * f(con)`. The same well-founded induction applies; only the algebra changes.

**Domain Bridges:** Classical Tutte polynomial `T_M(x, y)`, Bollobás–Riordan polynomial (ribbon graphs), Potts model partition function.

**Lineage:** Direct generalization of Theorem 5.1 in the current work.

**Ambition:** Low-medium — the proof structure is identical to the existing one, requiring primarily algebraic bookkeeping.

---

## Direction 3: Combinatorial Hopf Algebra of M-Convex Supports

**Conjecture:** The collection of M-convex supports, equipped with:
- **Product:** Direct sum on disjoint coordinate sets,
- **Coproduct:** Sum over all deletion-contraction splittings,

forms a graded connected Hopf algebra whose character theory is controlled by the support-Tutte polynomial.

**Test:** Verify the bialgebra axioms (coassociativity, compatibility) computationally on all M-convex supports up to total degree 4.

**Impact:** This would place M-convex supports alongside graphs, matroids, posets, and symmetric functions in the taxonomy of combinatorial Hopf algebras. The antipode would yield inclusion-exclusion formulas, and the character group would parametrize all multiplicative invariants — subsuming universality as a consequence.

**Catalog References:**
- `Pythagorean/UniversalSupportTutte.lean`: `dc_invariant_unique`, activity counting infrastructure
- `Catalog/Algebra/AntipodeUniqueness.lean`: Hopf algebra antipode machinery

**Proof Strategy:** 
1. Define the graded vector space spanned by isomorphism classes of M-convex supports.
2. Define the product as direct sum (needs: direct sum preserves M-convexity).
3. Define the coproduct via all ways to partition the coordinate set into deletion/contraction sets.
4. Verify bialgebra axioms. Show connectedness and invoke Milnor–Moore for Hopf structure.

**Domain Bridges:** Aguiar–Bergeron–Sottile (matroid Hopf algebra), Schmitt (graph Hopf algebra), Connes–Kreimer (renormalization Hopf algebra), tropical Hopf algebras.

**Lineage:** The key insight is that universality is the shadow of a Hopf algebra character theory.

**Ambition:** Grand challenge — requires substantial new algebraic infrastructure but would be paradigm-shifting.

---

## Direction 4: Tropical Geometry and Newton Polytope Invariants

**Conjecture:** The support-Tutte polynomial T_S is invariant under support equivalences that preserve the regular subdivision structure of the Newton polytope conv(S). Specifically, if two M-convex supports S and S' have combinatorially equivalent regular subdivisions, then T_S = T_S' after appropriate normalization.

**Test:** Compute T_S for all M-convex supports in Δ(3, d) for d ≤ 5. Group by regular subdivision type (using the secondary polytope). Check whether T_S is constant within each group.

**Impact:** This would establish the support-Tutte polynomial as a tropical invariant, linking discrete convex analysis to algebraic geometry via the theory of Newton polytopes and tropical varieties. It would also connect to Lorentzian polynomials (Brändén–Huh 2020), whose supports are precisely the M-convex sets.

**Catalog References:**
- `Pythagorean/UniversalSupportTutte.lean`: full infrastructure
- `Catalog/Pythagorean/SupportMinorTheory.lean`: original minor theory

**Proof Strategy:** Show that support minors correspond to face operations on Newton polytopes. Deletion restricts to a facet; contraction projects along an edge direction. The support-Tutte polynomial then computes a version of the "f-vector" of the regular subdivision.

**Domain Bridges:** Tropical geometry (Maclagan–Sturmfels), Newton polytopes (Gelfand–Kapranov–Zelevinsky), Lorentzian polynomials (Brändén–Huh), valuated matroids.

**Lineage:** The key insight is that M-convexity is the tropical analogue of convexity, and support-Tutte theory is the tropical analogue of Tutte theory.

**Ambition:** Grand challenge — connects to deep open problems in tropical geometry.

---

## Direction 5: Coefficient Positivity and Log-Concavity

**Conjecture:** For every M-convex support S, the coefficients of T_S(a) are nonneg when expressed in the basis {a^k}. Moreover, the sequence of coefficients is log-concave.

**Test:** Compute T_S for all M-convex subsets of Δ(n, d) with n ≤ 5, d ≤ 5. Check nonnegativity and log-concavity of the coefficient sequence.

**Impact:** Positivity and log-concavity are hallmarks of deep combinatorial structure, often connected to Hodge theory and algebraic geometry (cf. Huh's resolution of the Rota–Welsh conjecture). Establishing these properties for the support-Tutte polynomial would suggest a geometric underpinning analogous to the Kazhdan–Lusztig theory for matroids.

**Catalog References:**
- `Pythagorean/UniversalSupportTutte.lean`: `supportTuttePoly_empty`, `supportTuttePoly_singleton_zero`, `dc_invariant_unique`

**Proof Strategy:** For nonnegativity: show that the deletion-contraction recursion preserves nonnegativity (loops multiply by `a`, ordinary steps add nonneg terms). For log-concavity: attempt to construct an injection proving the Cauchy-Schwarz inequality c_k² ≤ c_{k-1} · c_{k+1} at the level of activity data.

**Domain Bridges:** Hodge theory for matroids (Adiprasito–Huh–Katz), Lorentzian polynomial theory (Brändén–Huh), real stable polynomials, total positivity.

**Lineage:** The key insight is that log-concavity may follow from the exchange property itself, since M-convexity is closely related to the theory of Lorentzian polynomials.

**Ambition:** High — log-concavity proofs are historically very difficult, but the connection to Lorentzian polynomials provides a plausible attack route.
