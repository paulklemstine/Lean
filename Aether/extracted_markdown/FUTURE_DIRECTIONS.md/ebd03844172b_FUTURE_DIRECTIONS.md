# Future Directions: Tropical Satake Isomorphism

## Synthesis

This research cycle established the algebraic foundations of the tropical Satake isomorphism for GL_n. The central discovery is that the tropical Hecke convolution—a min-plus analogue of the spherical Hecke algebra convolution—collapses to the pointwise tropical product on Weyl-invariant functions (Theorem `tropHeckeConv_eq_pointwise`). This collapse is the mechanism underlying the tropical Satake isomorphism: the convolution algebra is secretly commutative and isomorphic to the much simpler pointwise algebra. Combined with the super-additivity of tropical Schur polynomials (`tropSchur_product_superadd`) and the generalization to arbitrary finite group actions (`generalTropSchur_invariant`, `genTropSchur_weight_orbit`), this provides a complete rank-uniform framework.

The most promising cross-domain connection is between the tropical Demazure operators introduced here and the theory of crystal bases in representation theory. The Demazure idempotency at dominant points (`tropDemazure_at_dominant`) suggests that tropical Demazure operators generate the tropical Schur polynomial from a monomial via a sequence of min operations, paralleling how crystal operators generate Demazure modules. Formalizing this connection would bridge tropical combinatorics with Kashiwara's crystal base theory.

The highest breakthrough potential lies in Direction 1 (Tropical Littlewood-Richardson), which would provide an explicit decomposition formula for products of tropical Schur polynomials—the tropical analogue of one of the most important formulas in algebraic combinatorics. If successful, this would also connect to the theory of Hives (Knutson-Tao) and provide a purely combinatorial proof of the saturation conjecture in the tropical setting.

---

### Direction 1: Tropical Littlewood-Richardson Rule

**Conjecture**: For dominant weights λ and μ of GL_n, the function tropSchur(λ, ·) + tropSchur(μ, ·) (pointwise tropical product) can be expressed as a tropical linear combination (min over shifts) of tropical Schur polynomials tropSchur(ν, ·), where ν ranges over the Littlewood-Richardson cone {ν : c^ν_{λμ} > 0}. Concretely:

  tropSchur(λ, x) + tropSchur(μ, x) = min_{ν} (tropSchur(ν, x) + correction(λ, μ, ν))

where the correction terms are determined by the tropical LR coefficients.

**Test**: For GL₃, compute tropSchur((2,1,0)) + tropSchur((1,1,0)) at a grid of test points and verify it matches min over {(3,2,0), (3,1,1), (2,2,1)} with appropriate corrections. Use `#eval` in Lean to compute these values for small examples.

**Impact**: If true, this would provide the first explicit tropical Littlewood-Richardson rule, connecting tropical Satake theory to Knutson-Tao's honeycomb model and the Hive polytope. If false at the level of individual terms, the failure would indicate that tropical LR coefficients carry richer structure than classical ones.

**Catalog References**: `Catalog/Tropical/SatakeGLn.lean` (tropSchur_injective), `Catalog/Tropical/GL3TropicalSatake.lean` (GL₃ test family)

**Proof Strategy**: Define tropical LR coefficients via the Hive polytope (tropical analogue of the honeycomb model). Prove the decomposition using the convex geometry of the permutohedron. Key lemma: the tropical Schur polynomials form a basis for the space of piecewise-linear Weyl-invariant functions with integral slopes.

**Domain Bridges**: Tropical Geometry ↔ Algebraic Combinatorics (via Littlewood-Richardson), Optimization ↔ Representation Theory (via Knutson-Tao saturation)

**Lineage**: Builds on tropSchur_product_superadd (this cycle), tropSchur_injective (Catalog), and the Hecke basis identity heckeBasis_eq_tropSchur (this cycle).

**Ambition**: grand_challenge

---

### Direction 2: Tropical Demazure Character Formula

**Conjecture**: For any dominant weight λ of GL_n, applying the sequence of tropical Demazure operators D_{s_{i_1}} ∘ D_{s_{i_2}} ∘ ... ∘ D_{s_{i_N}} to the monomial tropMonomial(λ) (where s_{i_1} ... s_{i_N} is a reduced decomposition of the longest element w₀ ∈ Sₙ) produces exactly tropSchur(λ):

  D_{w₀}(tropMonomial(λ)) = tropSchur(λ)

where the tropical Demazure operator Dᵢ(f)(x) = min(f(x), f(sᵢ·x) + xᵢ - x_{i+1}).

**Test**: For GL₃, the longest element w₀ = s₁s₂s₁. Verify computationally that D₁(D₂(D₁(mono_{(a,b,c)})))(x) = tropSchur((a,b,c), x) for all dominant (a,b,c) with 0 ≤ c ≤ b ≤ a ≤ 5 and a grid of test points x.

**Impact**: If true, this gives a constructive algorithm for computing tropical Schur polynomials in O(n² · n) time instead of O(n! · n), and connects tropical geometry to the Bott-Samelson resolution in algebraic geometry. If false, it reveals a fundamental difference between tropical and classical Demazure theory.

**Catalog References**: `Tropical/TropicalSatakeAlgebra.lean` (tropDemazure_at_dominant), `Catalog/Tropical/SatakeGLn.lean` (tropSchur_wInvariant)

**Proof Strategy**: Induction on the length of the reduced decomposition. Base case: D₁(mono_λ) = min(mono_λ, mono_{s₁·λ}) for dominant λ with λ₁ > λ₂. Inductive step: show that applying Dᵢ extends the orbit-min from a parabolic subgroup to a larger one. Key lemma: the Demazure operators satisfy the braid relations tropically.

**Domain Bridges**: Tropical Geometry ↔ Algebraic Geometry (Bott-Samelson), Combinatorics ↔ Representation Theory (Crystal bases)

**Lineage**: Builds on tropDemazure_at_dominant (this cycle) and tropSchur_weylInvariant (this cycle).

**Ambition**: grand_challenge

---

### Direction 3: Tropical Satake for Non-Type-A Root Systems

**Conjecture**: The generalized tropical Satake framework (TropSatakeData) specialized to the Weyl groups of types B₂ (dihedral group of order 8), G₂ (dihedral group of order 12), and B₃ produces orbit-min polynomials that are injective on the dominant chamber, generalizing the GL_n result.

**Test**: Implement the Weyl group of B₂ as an 8-element subgroup of GL₂(ℤ) and compute genTropSchur for all dominant weights with entries in [-5, 5]. Verify injectivity computationally.

**Impact**: If true, this extends the tropical Satake isomorphism beyond type A to all classical root systems, potentially leading to a uniform tropical Langlands correspondence. If injectivity fails for some root systems, identifying which ones and why would reveal structural differences between root systems at the tropical level.

**Catalog References**: `Tropical/TropicalSatakeAlgebra.lean` (generalTropSchur_invariant, genTropSchur_weight_orbit)

**Proof Strategy**: Use the classification of finite reflection groups. For each type, construct the equivariant pairing explicitly and verify the injectivity using test vectors adapted to the root system (analogues of the testVec construction from SatakeGLn.lean). The key challenge is constructing the right test vectors for non-type-A root systems.

**Domain Bridges**: Tropical Geometry ↔ Lie Theory (Root systems), Combinatorics ↔ Geometry (Coxeter groups)

**Lineage**: Builds on generalTropSchur_invariant and genTropSchur_weight_orbit (this cycle).

**Ambition**: extension

---

### Direction 4: Tropical Newton Polytope and Permutohedron Connection

**Conjecture**: The "tropical Newton polytope" of tropSchur(λ, ·)—defined as the set of linear pieces (the domains of linearity of this piecewise-linear function)—is combinatorially equivalent to the permutohedron Π(λ), the convex hull of the Sₙ-orbit of λ.

**Test**: For GL₃ and λ = (3, 1, 0), compute the regions of linearity of tropSchur(λ, ·) : ℝ³ → ℝ and verify that the dual complex matches the face lattice of the permutohedron conv{(3,1,0), (3,0,1), (1,3,0), (0,3,1), (1,0,3), (0,1,3)}.

**Impact**: If true, this establishes a precise dictionary between tropical Satake theory and polytope combinatorics, connecting to the theory of generalized permutohedra (Postnikov). The face lattice of the permutohedron encodes the weak Bruhat order, providing a geometric interpretation of the Hecke algebra structure.

**Catalog References**: `Tropical/TropicalSatakeAlgebra.lean` (tropSchur_eq_orbit_inf from prior work in Catalog), `Catalog/Tropical/SatakeGLn.lean`

**Proof Strategy**: Use the theory of tropical hypersurfaces. The tropical Schur polynomial is a tropical polynomial (min of affine functions), and its tropical hypersurface is a polyhedral complex. Show this complex is normally equivalent to the permutohedron using the fan-polytope duality. Key lemma: the normal fan of the permutohedron Π(λ) equals the chamber decomposition of the tropical Schur polynomial.

**Domain Bridges**: Tropical Geometry ↔ Polytope Combinatorics (Permutohedra), Optimization ↔ Algebraic Geometry (Normal fans)

**Lineage**: Builds on tropSchur_weylInvariant and tropSchur_identity_bound (this cycle).

**Ambition**: extension

---

### Direction 5: Computational Complexity of Tropical Satake

**Conjecture**: Evaluating tropSchur(w, x) for dominant weight w ∈ ℤⁿ and point x ∈ ℤⁿ can be done in O(n² log n) time, matching the complexity of sorting.

**Test**: Implement and benchmark an algorithm based on the assignment problem (Hungarian algorithm, O(n³)) and compare with a sorting-based algorithm for the special case of test vectors. Determine whether the O(n²) barrier can be broken.

**Impact**: If achievable, this makes tropical Satake theory computationally practical for large n (e.g., neural network weight analysis, large-scale optimization). The connection to the assignment problem links tropical Satake to operations research. If O(n² log n) is impossible, proving a lower bound would be a contribution to computational complexity.

**Catalog References**: `Tropical/TropicalSatakeAlgebra.lean` (tropSchur definition)

**Proof Strategy**: Reduce tropSchur evaluation to a min-cost assignment problem. Use the Birkhoff polytope (convex hull of permutation matrices) to reformulate the problem as a linear program over the Birkhoff polytope. Apply the Hungarian algorithm or auction algorithm. For the conjectured O(n² log n) bound, explore whether the structure of the inner product ∑ w(σ(i)) · x(i) allows faster evaluation than generic assignment.

**Domain Bridges**: Tropical Geometry ↔ Computational Complexity, Optimization ↔ Algorithms (Assignment problem)

**Lineage**: Builds on the orbit-min definition of tropSchur (this cycle and Catalog).

**Ambition**: extension
