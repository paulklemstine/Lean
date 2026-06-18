# Future Directions

## Synthesis

The universal support-Tutte invariant theory established in this work reveals a fundamental tension: the deletion–contraction grammar for supports is *universal* (uniquely determining any invariant satisfying the recurrence) but *degenerates* under uniform coefficients to a trivial power law. This tension points toward three interconnected research programs:

1. **Breaking the degeneracy** through weighted or multiplicity-sensitive coefficients that exploit the full structure of support vectors.
2. **Structural enrichment** through Hopf-algebraic and tropical-geometric frameworks that give the invariant theory a richer algebraic home.
3. **Algorithmic exploitation** of the product formula for efficient computation and optimization on M-convex support families.

Each direction builds directly on the formalized infrastructure (GroundSupport, deletion, contraction, and the Uniqueness Theorem), and each is specific enough to fail against computational tests.

---

## Direction 1: Weighted Deletion–Contraction with Multiplicity Coefficients

**Conjecture.** *For M-convex supports, there exists a polynomial-valued invariant T_S ∈ ℤ[x₁,...,xₙ] (one variable per possible multiplicity value) such that the recursion uses coefficients depending on the full histogram of coordinate values, not just the loop/coloop/ordinary trichotomy. This invariant is strictly finer than the 4-parameter T₄ and separates supports that T₄ identifies.*

**The key insight is** that the current framework discards multiplicity information at the classification step (loop vs coloop vs ordinary), while the actual value distribution at each coordinate carries additional invariant data — for instance, the gap between minimum and maximum values, or the number of distinct values. A weighted version would assign different factors to coordinates with min-max gap 1 vs gap 5, capturing arithmetic degree data.

**Why now?** The Power Law theorem provides the precise baseline against which richer invariants must be measured, and the Uniqueness Theorem guarantees that any well-defined recurrence yields at most one invariant. This eliminates the foundational risk of the program — the only remaining question is *which* weighting produces genuinely new information.

**Test.** Compute the weighted invariant for the degree-d simplex Δ(n,d) across d = 1,...,5. If the invariant depends non-trivially on d (unlike T₄), the conjecture is supported. If Δ(3,2) and Δ(3,5) yield the same polynomial, the conjecture fails.

**Impact.** Would establish the first polynomial invariant that "sees inside" the Newton polytope, distinguishing supports with the same combinatorial type but different integer-point distributions. Directly applicable to tropical geometry (discriminating tropical hypersurfaces) and algebraic complexity (certifying polynomial identity testing).

**Catalog References.** `Catalog/Pythagorean/SupportMinorTheory.lean` (SupportExchange, minor_step_card_le); `Pythagorean/SupportTutteUniversal.lean` (supportTutteEval, supportTutte_unique, supportTutteEval_eq_pow).

**Proof Strategy.** Define coefficients as functions of the value histogram; prove termination using the same ground-size measure; prove uniqueness by extending the current induction. The Power Law breaks because coefficients vary.

**Domain Bridges.** Tropical geometry (Newton polytope discrimination), algebraic complexity theory (polynomial identity testing), optimization (M-convex function evaluation).

**Lineage.** Extends the Uniqueness Theorem of this work and the exchange-preservation theorems of SupportMinorTheory.

**Ambition.** Grand challenge — requires defining the right coefficient system and proving it captures meaningful structure.

---

## Direction 2: Combinatorial Hopf Algebra of Supports

**Conjecture.** *The collection of finite M-convex supports, equipped with deletion–contraction as coproduct and direct sum as product, forms a graded connected Hopf algebra H. The support-Tutte evaluation is the universal character of H, and the Power Law corresponds to the cocommutative projection.*

**The key insight is** that the deletion–contraction operations decompose supports into pairs (deletion, contraction), which is precisely the structure of a coproduct in a combinatorial Hopf algebra. The direct sum of supports on disjoint ground sets provides the product. Together, these should satisfy the bialgebra axioms.

**Why now?** The combinatorial Hopf algebra framework has been established for graphs (Schmitt), matroids (Crapo–Schmitt), and posets, but not for M-convex supports. Our formalized deletion and contraction operations, with their certified termination and exchange preservation, provide the exact infrastructure needed.

**Test.** Verify the bialgebra axioms (coassociativity of Δ, compatibility of Δ with product) computationally on all M-convex supports with |ground| ≤ 4. Any counterexample falsifies the conjecture.

**Impact.** Would place support theory alongside matroids and graphs in the Hopf algebra ecosystem, unlocking Hopf-algebraic tools (antipode formulas, character theory, Möbius inversion) for support invariants.

**Catalog References.** `Pythagorean/SupportTutteUniversal.lean` (directSum, supportTutteEval); `Catalog/Pythagorean/SupportMinorTheory.lean` (SupportMinor, exchange_of_minor).

**Proof Strategy.** Define the graded vector space, verify (co)associativity and compatibility formally. The Uniqueness Theorem provides the character-universality half automatically.

**Domain Bridges.** Algebraic combinatorics (renormalization, generating functions), representation theory (characters of combinatorial groups), quantum field theory (Connes–Kreimer).

**Lineage.** Builds on the direct sum definition and universality theorem from this work.

**Ambition.** Solid extension — the algebraic framework is well-established; the challenge is verifying the axioms for the specific operations.

---

## Direction 3: Tropical Support Invariants and Subdivision Sensitivity

**Conjecture.** *For two M-convex supports S₁, S₂ ⊆ ℕ^n whose Newton polytopes have non-isomorphic regular subdivisions, there exists a specialization of the weighted support-Tutte polynomial (Direction 1) that distinguishes them.*

**The key insight is** that regular subdivisions of Newton polytopes encode tropical intersection theory, and support minors (deletion/contraction) correspond to facet projections of the subdivision complex. An invariant sensitive to this structure would bridge support-Tutte theory with tropical geometry.

**Why now?** The connection between supports and tropical geometry is well-established conceptually but lacks a formal invariant-theoretic bridge. The deletion–contraction framework provides a natural one, since tropical modification corresponds to support contraction.

**Test.** Compute the weighted invariant for supports of several polytopes with known subdivision structure (e.g., the three-dimensional associahedron vs cube). If the invariant separates polytopes with non-isomorphic subdivisions, the conjecture is supported.

**Impact.** Would provide a new algebraic tool for tropical geometry, complementing existing approaches via tropical Grassmannians and Gröbner fan theory.

**Catalog References.** `Pythagorean/SupportTutteUniversal.lean` (delete, contract, supportTutteEval); `Catalog/Pythagorean/SupportMinorTheory.lean` (supportContract, exchange_of_contraction).

**Proof Strategy.** Show that subdivision data is reflected in the multiplicity histograms seen during the deletion–contraction recursion.

**Domain Bridges.** Tropical geometry, algebraic geometry (Newton polytopes), polyhedral combinatorics.

**Lineage.** Extends Direction 1; depends on the formalized contraction operation.

**Ambition.** Grand challenge — requires new mathematical connections between subdivision theory and deletion–contraction.

---

## Direction 4: Efficient Algorithms for M-Convex Support Classification

**Conjecture.** *The activity data (l, c, o) of a ground support under the canonical ordering can be computed in O(|ground| · |supp|) time, and supports with the same activity data up to permutation are "T₄-equivalent" — they give the same T₄ value for all parameter choices.*

**The key insight is** that the product formula T₄ = x^c · y^l · (u+v)^o reduces the classification problem to computing activity data, which is a linear scan through the ground set. The canonical ordering removes ambiguity, making the algorithm deterministic.

**Why now?** The product formula was discovered computationally during this work. Proving it formally and characterizing T₄-equivalence classes would make the support-Tutte invariant computationally practical for large-scale applications.

**Test.** Enumerate all M-convex subsets of the degree-≤5 simplex on 4 variables. Compute activity data and verify that T₄-equivalence classes are exactly the activity-data equivalence classes.

**Impact.** Practical: fast algorithms for support classification in optimization, tropical geometry, and algebraic statistics.

**Catalog References.** `Pythagorean/SupportTutteUniversal.lean` (SupportActivityData, supportTutteEval_eq_pow).

**Proof Strategy.** Formalize the product formula in Lean, then prove that the activity data uniquely determines T₄.

**Domain Bridges.** Algorithms, discrete optimization, computational algebraic geometry.

**Lineage.** Direct consequence of the Power Law theorem and T₄ recursion analysis.

**Ambition.** Solid extension — the product formula is computationally verified; the formal proof is a focused Lean effort.

---

## Direction 5: Partition Function Universality for Discrete Convex Models

**Conjecture.** *Every "support partition function" Z(S; β) = Σ_σ exp(-β · H(σ, S)) for a Hamiltonian H respecting the deletion–contraction structure factors through the weighted support-Tutte polynomial, generalizing the Fortuin–Kasteleyn representation of the Potts model.*

**The key insight is** that the Tutte polynomial of a graph, under specific specializations, equals the partition function of the Potts model (Fortuin–Kasteleyn) and the reliability polynomial (network reliability). Our support-Tutte evaluation should play the same role for "discrete convex" statistical mechanics models where the configuration space has M-convex structure.

**Why now?** The Uniqueness Theorem guarantees that any invariant satisfying the deletion–contraction recurrence is determined by the universal one. Any partition function respecting deletion–contraction therefore factors through our invariant automatically — the question is whether natural physical models satisfy this property.

**Test.** Define a lattice model on an M-convex support (e.g., dimer configurations on a weighted lattice) and verify that its partition function satisfies deletion–contraction.

**Impact.** Would open discrete convex analysis to methods from statistical mechanics, and vice versa. Could provide new exact-solution techniques for combinatorial optimization problems with M-convex structure.

**Catalog References.** `Pythagorean/SupportTutteUniversal.lean` (SupportTutteInvSpec, supportTutte_unique).

**Proof Strategy.** Verify the deletion–contraction axioms for specific physical models; apply the Uniqueness Theorem.

**Domain Bridges.** Statistical mechanics (partition functions), combinatorial optimization (dimer models), mathematical physics (exactly solvable models).

**Lineage.** Extends the Uniqueness Theorem; inspired by the Fortuin–Kasteleyn representation.

**Ambition.** Grand challenge — requires identifying the right physical models with deletion–contraction structure.
