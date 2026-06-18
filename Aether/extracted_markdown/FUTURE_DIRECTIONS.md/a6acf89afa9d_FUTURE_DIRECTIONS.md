# Future Directions: Multi-Degree Persistence and Arithmetic Filtrations

## Synthesis

This research cycle established the theory of multi-degree persistence for filtered chain complexes with d² = 0, proving three core results: (1) the d² = 0 condition forces pairwise cancellation in differential compositions, constraining which persistence profiles are algebraically realizable; (2) the filtration-weighted differential density is a strictly finer invariant than the chain-complex-level data alone; and (3) prime factorization length provides a canonical multiplicative filtration homomorphism bridging persistent homology and number theory.

The most promising cross-domain connection is the **arithmetic filtration bridge** between persistent homology and prime factorization. The fact that Ω (prime factorization length) is simultaneously a completely additive arithmetic function and a filtration-level function means that every chain complex labeled by integers inherits persistent structure from the prime number distribution. This connects the Catalog's extensive Pythagorean work on Berggren trees (which encode Pythagorean triples as integer 3-vectors) to TDA invariants, potentially enabling number-theoretic analysis through persistent homology.

The direction with highest breakthrough potential is **Direction 1 (Stability of the density invariant)**, because stability theorems are the foundation for practical applications — without stability, the invariant is too sensitive to be useful on noisy data. Direction 3 (Barcode realizability) offers the best falsifiable conjecture with clear computational tests. Directions 4 and 5 offer the most ambitious cross-domain bridges, connecting to tropical geometry and physics respectively.

---

### Direction 1: Stability of the Filtration-Weighted Density

**Conjecture**: For any two filtered chain complexes C, C' with identical differentials and filtration functions differing by at most ε at each basis element (i.e., |filt₁(i) - filt₁'(i)| ≤ ε for all i), the filtration-weighted densities satisfy |ρ(C) - ρ(C')| ≤ ε · nnz(d₁), where nnz(d₁) is the number of nonzero entries in d₁.

**Test**: Prove this bound formally. Then construct specific perturbation sequences with ε → 0 and verify convergence of densities.

**Impact**: If true, this establishes that the density invariant is Lipschitz-continuous with respect to filtration perturbations, making it usable for noisy data in TDA applications. If false, it reveals that the density is fragile and needs regularization — pointing toward averaged or smoothed variants.

**Catalog References**: `Pythagorean/MultiDegreePersistence.lean` (filtrationWeightedDensity, weighted_density_nonneg_of_compatible)

**Proof Strategy**: Fix differentials d₁, d₀. For each nonzero entry d₁(i,j), the contribution changes by at most |filt₁(i) - filt₁'(i)| ≤ ε. Sum over all nnz entries. This should follow from triangle inequality and Finset.sum_le_sum.

**Domain Bridges**: Topology <-> Data Science

**Lineage**: Builds on multi_degree_strictly_finer and weighted_density_nonneg_of_compatible.

**Ambition**: extension

---

### Direction 2: d² = 0 Forbidden Barcode Patterns

**Conjecture**: For 3-term filtered chain complexes with d² = 0, there exist specific barcode configurations (birth-death interval arrangements) that are unrealizable. Specifically, if d₁ and d₀ are both nonzero, then the persistence barcodes in degrees 0 and 1 cannot be independently prescribed — the d² = 0 condition creates "forbidden" joint distributions.

**Test**: Enumerate all 3-term chain complexes over F₂ with dimensions ≤ 4 in each degree. For each d² = 0 complex, compute the multi-degree persistence barcode. Identify pairs of degree-0 and degree-1 barcodes that never co-occur.

**Impact**: If forbidden patterns exist, this proves that multi-degree persistence carries strictly more information than the collection of single-degree barcodes — the holy grail of multi-parameter persistence theory. If no forbidden patterns exist in small examples, it suggests the conjecture may be false, and the refinement operates at a subtler level.

**Catalog References**: `Pythagorean/MultiDegreePersistence.lean` (FilteredChainComplex3, d_sq_forces_cancellation, diagonal_d_sq_support_disjoint)

**Proof Strategy**: Use d_sq_forces_cancellation to show that nonzero differential entries must come in canceling pairs. This constrains the rank of d₁ and d₀ relative to the middle dimension. Translate rank constraints into barcode constraints via the rank-nullity theorem.

**Domain Bridges**: Algebra <-> Topology

**Lineage**: Builds on d_sq_forces_cancellation and diagonal_d_sq_support_disjoint.

**Ambition**: grand_challenge

---

### Direction 3: Barcode Realizability Bound

**Conjecture**: For any 3-term filtered chain complex with d² = 0 and n₁ middle basis elements, the total number of persistence pairs across all three homological degrees is at most 2 · n₁.

**Test**: Enumerate all 3-term complexes over F₂ with n₂ = n₁ = n₀ = 3. For each d² = 0 complex, compute persistence pairs. Check if any complex exceeds 6 total pairs.

**Impact**: If true, establishes a fundamental information-theoretic bound on persistent content of chain complexes. Would connect to coding theory bounds (capacity of a channel = middle dimension). If false, the counterexample reveals unexpected richness of persistence in chain complexes.

**Catalog References**: `Pythagorean/MultiDegreePersistence.lean` (barcodeRealizabilityBound, FilteredChainComplex3)

**Proof Strategy**: The key observation is that each persistence pair in degree k corresponds to a basis vector that participates in a differential. In degree 1, pairs come from ker(d₀)/im(d₁). The d² = 0 condition constrains dim(im(d₁)) + dim(im(d₀)) ≤ n₁ (since im(d₁) ⊆ ker(d₀)). Combined with dim(ker(d₀)) + rank(d₀) = n₁, this should yield the bound.

**Domain Bridges**: Algebra <-> Information Theory

**Lineage**: Builds on FilteredChainComplex3 and diagonal_d_sq_support_disjoint.

**Ambition**: extension

---

### Direction 4: Berggren Arithmetic Persistence

**Conjecture**: The Berggren tree of primitive Pythagorean triples, with the arithmetic filtration Ω applied to the hypotenuse, exhibits a persistence barcode whose intervals encode the prime factorization structure of the triples' hypotenuses. Specifically, the number of persistence pairs born at filtration level k equals the number of Berggren tree nodes at depth ≤ some function of k whose hypotenuse has exactly k prime factors.

**Test**: Compute the Berggren tree to depth 8 (3⁸ = 6561 nodes). For each triple (a,b,c), compute Ω(c). Build a Rips complex on the triples using Euclidean distance, filtered by Ω(c). Compute the persistence barcode and check the conjecture.

**Impact**: Would establish the first direct connection between the Berggren tree structure (number theory) and persistent homology (topology), potentially revealing arithmetic patterns invisible to both pure number theory and pure TDA.

**Catalog References**: `Pythagorean/BerggrenHolographicDuality.lean` (ternaryBallVolume, ternary_boundary_from_leaves), `Pythagorean/MultiDegreePersistence.lean` (arithmeticFiltration, arithmetic_filtration_multiplicative)

**Proof Strategy**: Use arithmetic_filtration_multiplicative to decompose the filtration along the Berggren tree. At each tree node (a,b,c), the hypotenuse c factors as c = c₁·c₂·...·cₖ. The filtration level Ω(c) = k. Use the exponential growth of the Berggren tree (3ⁿ nodes at depth n) from ternary_boundary_from_leaves to estimate the distribution of Ω values.

**Domain Bridges**: Number Theory <-> Topology <-> Pythagorean

**Lineage**: Builds on arithmetic_filtration_multiplicative (this cycle) and ternary_boundary_from_leaves (BerggrenHolographicDuality).

**Ambition**: grand_challenge

---

### Direction 5: Tropical Persistence and Newton Polytopes

**Conjecture**: For a polynomial system f₁, ..., fₖ ∈ ℤ[x₁,...,xₙ], the tropical filtration on the Koszul complex (induced by the min-plus valuation on coefficients) produces a persistence barcode that detects the Newton polytope structure of the system. Specifically, distinct Newton polytopes yield distinct tropical persistence barcodes.

**Test**: Take two polynomial systems with different Newton polytopes but the same degrees (e.g., x² + xy + y² vs x² + y², both degree 2 in two variables). Build the Koszul complex, apply the tropical filtration using the min-plus valuation on coefficients, and compute the persistence barcode. Verify the barcodes differ.

**Impact**: Would establish a computable bridge between algebraic geometry (Newton polytopes) and topological data analysis (persistence barcodes) through tropical geometry. This could enable TDA-based algorithms for solving polynomial systems.

**Catalog References**: `Pythagorean/MultiDegreePersistence.lean` (TropicalValuation, tropicalFilteredComplex, tropical_shift_invariance)

**Proof Strategy**: The tropical valuation assigns filtration levels based on coefficient valuations. By tropical_shift_invariance, uniform coefficient scaling doesn't change the persistence profile. The key step is showing that the tropical persistence barcode encodes the face lattice of the Newton polytope — this requires formalizing the relationship between the Koszul complex differential and the polytope's combinatorial structure.

**Domain Bridges**: Tropical Geometry <-> Algebraic Geometry <-> Topology

**Lineage**: Builds on TropicalValuation and tropicalFilteredComplex (this cycle).

**Ambition**: grand_challenge
