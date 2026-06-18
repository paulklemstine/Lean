# Future Directions: Memory Compression Algebra

## Synthesis

This research cycle established a rigorous algebraic framework connecting three mathematical domains through the lens of information compression in finite-state systems. The central construction — treating memory as a monoid homomorphism φ : FreeMonoid(α) →* S and measuring its information content via the tropical capacity v(φ) = log|image(φ)| — yielded four verified theorems of genuine mathematical content: idempotent stabilization in finite monoids, tropical capacity subadditivity for product systems, congruence-capacity monotonicity, and the factoring-capacity theorem.

The most promising cross-domain connection discovered is between the **tropical capacity valuation** and the **congruence lattice** of a finite monoid. The congruence-capacity monotonicity theorem shows that the tropical capacity is a monotone function on the lattice of equivalence relations, while the product bound gives tropical subadditivity. Together, these suggest that the capacity function is a *valuation* on the partition lattice in the sense of Rota's lattice-theoretic Möbius inversion. This connects automata theory (through the Myhill-Nerode equivalence) to tropical geometry (through the capacity metric) via universal algebra (through the congruence lattice). The existing Catalog infrastructure in `Bridges/TropicalUltrametricDuality.lean` (tropical triangle inequality) and `Bridges/EntropyBounds.lean` (image bounds from matrix factorizations) provides natural extension points.

The direction with highest breakthrough potential is **Direction 1** (Tropical Krohn-Rhodes Capacity Theory), because the Krohn-Rhodes decomposition theorem provides a *canonical* decomposition of any finite semigroup into "atoms" of computation, and our capacity framework should yield sharp bounds on how information distributes across these atoms. This would provide the first quantitative information-theoretic interpretation of semigroup complexity, connecting a central object of algebraic automata theory to tropical geometry.

---

### Direction 1: Tropical Krohn-Rhodes Capacity Theory

**Conjecture**: For a finite semigroup S with Krohn-Rhodes complexity c(S) and a surjective monoid homomorphism φ : FreeMonoid(α) →* S, the tropical capacity satisfies:

v(φ) ≤ c(S) · max{log|G| : G is a simple group divisor of S} + (c(S) + 1) · log 3

where the second term accounts for aperiodic (reset/identity) levels, each contributing at most log|U₃| = log 3 to the capacity. In other words, the information content of a memory system is bounded by its algebraic complexity times the maximum group-level contribution.

**Test**: Compute v(φ) and c(S) for all semigroups of order ≤ 8 (there are finitely many, enumerated in the GAP semigroup library). For each, verify the conjectured inequality. A counterexample would refute the bound; consistent satisfaction with tight examples would support it.

**Impact**: If true, this provides a quantitative decomposition of information capacity into "reversible" (group) and "irreversible" (aperiodic) components, giving the first information-theoretic interpretation of Krohn-Rhodes complexity. This would bridge automata theory and information theory at the algebraic level.

**Catalog References**: `Bridges/MemoryCompressionAlgebra.lean` (idempotent stabilization, capacity subadditivity), `Bridges/TropicalUltrametricDuality.lean` (tropical triangle inequality)

**Proof Strategy**: (1) Formalize the wreath product of finite semigroups in Lean. (2) Prove that v(A ≀ B) ≤ v(A) + |B| · v(A), refining the cascade_state_bound. (3) Use induction on the Krohn-Rhodes decomposition depth. (4) The aperiodic levels contribute at most log 3 each (since the aperiodic kernel of any finite semigroup divides an iterated wreath product of copies of U₃). (5) The group levels contribute at most log|G| each.

**Domain Bridges**: Tropical geometry (capacity as tropical valuation) ↔ Automata theory (Krohn-Rhodes decomposition) ↔ Information theory (capacity bounds)

**Lineage**: Extends the cascade_state_bound and finite_monoid_has_idempotent_power from this cycle. Builds on the tropical triangle inequality from `Bridges/TropicalUltrametricDuality.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Eigenvalues and Stabilization Rate

**Conjecture**: For an element a of a finite monoid M with |M| = m, the smallest idempotent power n(a) satisfies n(a) ≤ m · (m-1)/2, and this bound is achieved by a monoid with a single maximal cyclic subgroup. Moreover, the idempotent power function n : M → ℕ is related to the tropical spectral radius of the right-multiplication matrix R_a : M → M (defined by R_a(s) = s · a) via:

n(a) ≤ (tropical spectral radius of R_a)⁻¹ · m

where the tropical spectral radius is the maximum cycle mean of the directed graph of R_a with edge weights given by tropical capacity.

**Test**: For each monoid M of order ≤ 10, compute n(a) for all elements and compare with the tropical spectral radius bound. Tight examples would validate the connection; loose bounds would suggest a different relationship.

**Impact**: This would connect the stabilization rate of memory systems to tropical spectral theory, importing results on max-plus eigenvalues (Cuninghame-Green, Gaubert) into automata theory. It could provide practical bounds on "convergence time" for finite-state systems.

**Catalog References**: `Bridges/MemoryCompressionAlgebra.lean` (finite_monoid_has_idempotent_power), `Bridges/HyperbolicNumberTheory.lean` (spectral_radius_power_decay)

**Proof Strategy**: (1) Define the transition graph of right multiplication by a. (2) Compute cycle lengths using the tropical permanent or max-plus determinant. (3) Relate the idempotent power to the lcm of cycle lengths. (4) Use the bound lcm(1, 2, ..., k) ≤ e^k (Landau's function) to get the overall bound.

**Domain Bridges**: Tropical linear algebra (max-plus eigenvalues) ↔ Semigroup theory (idempotent powers) ↔ Graph theory (cycle structure of multiplication)

**Lineage**: Direct extension of idempotent stabilization theorem from this cycle.

**Ambition**: extension

---

### Direction 3: Capacity Defect and the Modularity Gap

**Conjecture**: For the partition lattice Part(n) on n elements, define the *modularity defect* of the capacity function v(r) = log|n/r| as:

δ(r₁, r₂) = v(r₁) + v(r₂) - v(r₁ ∨ r₂) - v(r₁ ∧ r₂)

Then δ ≥ 0 for all pairs (r₁, r₂) — i.e., v is *submodular* on Part(n) — and the maximum defect over all pairs satisfies:

max δ(r₁, r₂) = Θ(n · log n)

**Test**: Compute δ(r₁, r₂) for all pairs of partitions of {1, ..., n} for n = 3, 4, 5, 6. Verify submodularity (δ ≥ 0). If any δ < 0, the conjecture is false; compute the maximum defect and check growth rate.

**Impact**: If v is submodular, it would make the capacity function amenable to submodular optimization algorithms (Lovász extension, greedy algorithms), enabling efficient computation of optimal memory system designs. The growth rate of the maximum defect would quantify how far the capacity is from being modular.

**Catalog References**: `Bridges/MemoryCompressionAlgebra.lean` (quotientCard_mono, imageCard_prod_le)

**Proof Strategy**: (1) Express v in terms of Stirling numbers of the second kind. (2) Use the log-concavity of Stirling numbers (established by Canfield). (3) Relate log-concavity to submodularity via the lattice structure. (4) For the growth rate, construct explicit extremal partition pairs achieving maximum defect.

**Domain Bridges**: Lattice theory (modular functions) ↔ Combinatorics (Stirling numbers) ↔ Optimization (submodular functions)

**Lineage**: Direct follow-up to the modularity conjecture stated in this cycle. Refines the conjecture based on the expected counterexample.

**Ambition**: extension

---

### Direction 4: Memory Systems as Objects of a Tropical Category

**Conjecture**: Define the category **MemSys** whose objects are memory systems (φ : FreeMonoid(α) →* S) and whose morphisms are monoid homomorphisms ψ : S₁ → S₂ making the obvious triangle commute. The tropical capacity v defines a *functor* from **MemSys** to the tropical semiring (ℝ ∪ {-∞}, max, +), viewed as a one-object category:

- v maps objects to their capacity log|image(φ)|
- v maps morphisms to 0 (since surjective morphisms preserve capacity and non-surjective ones decrease it)

More precisely, v is a *lax functor* to the ordered set (ℝ, ≤): for any morphism ψ : M₁ → M₂, v(M₂) ≤ v(M₁) (by the factoring-capacity theorem).

**Test**: Construct the category **MemSys** for alphabets of size 2 and monoids of order ≤ 6. Verify that v is monotone on morphisms and that the image of the functor captures the essential structure of the category.

**Impact**: A categorical formulation would enable the import of categorical tools (limits, colimits, adjunctions) into the study of memory systems. In particular, the "optimal memory system" for a given task could be characterized as a universal object in an appropriate comma category.

**Catalog References**: `Bridges/MemoryCompressionAlgebra.lean` (imageCard_le_of_factors, image_comp_subset), `Bridges/CategoricalTropicalUltrametric.lean`

**Proof Strategy**: (1) Define the category in Lean using Mathlib's category theory library. (2) Prove functoriality of v. (3) Characterize limits and colimits in **MemSys**. (4) Show that the product in **MemSys** corresponds to the cascade product, connecting to Krohn-Rhodes theory.

**Domain Bridges**: Category theory (functors, limits) ↔ Tropical geometry (tropical semiring as a category) ↔ Automata theory (memory system morphisms)

**Lineage**: Builds on the factoring-capacity theorem and image monotonicity results from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Entropy-Capacity Gap and Rate-Distortion Connection

**Conjecture**: For a memory system φ : FreeMonoid(α) →* S with |α| = k and a uniform distribution on α, the *entropy-capacity gap*:

Δ(φ) = v(φ) - H(φ(X))

where H denotes Shannon entropy and X is uniformly distributed on FreeMonoid(α), satisfies:

0 ≤ Δ(φ) ≤ log(|image(φ)|) - log(|image(φ)| - 1 + 1/|image(φ)|)

with the upper bound achieved when one state has probability 1/2 and the remaining states share the other half uniformly.

**Test**: For random memory systems (random monoid homomorphisms from FreeMonoid({0,1}) to monoids of order 10–50), compute Δ(φ) and compare with the conjectured bounds. Plot the distribution of Δ(φ)/v(φ) to check if it concentrates.

**Impact**: The entropy-capacity gap measures how much the tropical (worst-case) capacity overestimates the actual information content. Understanding this gap connects the algebraic framework to Shannon's probabilistic framework and could lead to tighter capacity bounds.

**Catalog References**: `Bridges/MemoryCompressionAlgebra.lean` (imageCard_pos, imageCard_le_card), `Bridges/EntropyBounds.lean` (finite_image_bound_of_matrix_factorization)

**Proof Strategy**: (1) Bound H(φ(X)) from below using the maximum entropy distribution on image(φ). (2) Use Jensen's inequality for log-concavity. (3) Characterize the extremal distribution achieving maximum gap.

**Domain Bridges**: Information theory (Shannon entropy) ↔ Tropical algebra (capacity valuation) ↔ Probability theory (maximum entropy distributions)

**Lineage**: Extends the tropical capacity framework from this cycle by connecting it to probabilistic information measures.

**Ambition**: extension
