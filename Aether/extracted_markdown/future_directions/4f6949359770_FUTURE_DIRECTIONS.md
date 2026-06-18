# Future Directions: Tropical Stereographic Projection

## Synthesis

This research cycle established the foundational theory of tropical Möbius transformations as piecewise-linear functions encoded by max-plus 2×2 matrices. The central discovery is the **representation theorem**: tropical matrix multiplication faithfully represents composition of tropical Möbius transformations, exactly paralleling the classical GL(2) representation but in the max-plus semiring. This structural result, combined with the **boundedness theorem** (every tropical Möbius evaluation lies in a computable interval) and the **super-multiplicativity inequality** for the tropical determinant, provides a complete picture of the 1-dimensional theory.

The most promising cross-domain connection is between **tropical Möbius transformations and ReLU neural networks**. Both are piecewise-linear functions with bounded numbers of breakpoints, and composition in both settings increases the number of linear pieces. The max-plus matrix multiplication that governs tropical Möbius composition is structurally identical to the forward pass of a single-layer max-pooling network. This suggests that the tropical representation theorem could provide new tools for analyzing neural network expressivity and depth separation.

The highest breakthrough potential lies in **Direction 1 (Higher-Dimensional Tropical Möbius Theory)**, because extending the representation theorem to n×n tropical matrices would connect to the rich theory of tropical linear algebra (tropical eigenvalues, tropical rank, the Hungarian algorithm) and could yield new results in computational geometry and optimization. Direction 3 (Neural Network Connection) has the highest potential for cross-domain impact.

---

### Direction 1: Higher-Dimensional Tropical Möbius Theory

**Conjecture**: The representation theorem for tropical 2×2 matrices extends to n×n tropical matrices: the homogeneous action of a tropical n×n matrix on (ℝ ∪ {−∞})ⁿ respects tropical matrix multiplication, and the tropical determinant (permanent) satisfies the super-multiplicativity inequality det⊕(M⊗N) ≥ det⊕(M) + det⊕(N) for all n×n tropical matrices.

**Test**: (a) Implement tropical n×n matrix multiplication and verify the representation theorem computationally for n = 3, 4, 5 with random matrices. (b) Construct explicit 3×3 counterexamples to det⊕ multiplicativity (equality) and verify the inequality direction. (c) Formalize the n = 3 case in Lean 4.

**Impact**: If true, this gives a complete tropical analog of the GL(n) representation theory and connects to the theory of tropical convexity, tropical polytopes, and the assignment problem in combinatorial optimization. The super-multiplicativity inequality would generalize a well-known result about the tropical permanent.

**Catalog References**: `Tropical/StereographicProjection.lean` (actHom_mul, mul_assoc, tropDet_mul_le)

**Proof Strategy**: The representation theorem for general n follows from the same distributivity argument (a + max(b,c) = max(a+b, a+c)) used in the 2×2 case. The key challenge is the tropical determinant super-multiplicativity, which requires showing that every term in det⊕(M) + det⊕(N) (a max over n!² pairs of permutations) appears among the terms of det⊕(M⊗N) (a max over n! permutations of the product). This reduces to showing that for any permutations σ, τ, there exists a permutation ρ such that ∑ᵢ M_{i,σ(i)} + ∑ⱼ N_{j,τ(j)} ≤ ∑ᵢ (M⊗N)_{i,ρ(i)}.

**Domain Bridges**: Tropical geometry <-> combinatorial optimization (assignment problem), Tropical matrices <-> shortest-path algorithms

**Lineage**: Builds on the 2×2 representation theorem and super-multiplicativity inequality established in this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Conformal Invariants

**Conjecture**: There exists a unique (up to scaling) functional J on tropical Möbius transformations that is (a) invariant under tropical PGL(2) conjugation (i.e., J(A⁻¹MA) = J(M) for invertible tropical A), and (b) equals the tropical width for diagonal matrices. This functional is J(M) = |det⊕(M) − tr⊕(M)| where tr⊕(M) = max(a, d) is the tropical trace.

**Test**: (a) Verify computationally that J is conjugation-invariant for 1000 random pairs (M, A). (b) Check whether J = tropical width for stereographic projections S_p. (c) If the conjecture holds, formalize J and its invariance in Lean 4. If false, characterize the obstruction.

**Impact**: A tropical conformal invariant would be the tropical analog of the cross-ratio, which is the fundamental invariant of classical Möbius geometry. It would provide a classification of tropical Möbius transformations up to conjugacy — a tropical Jordan normal form theory for 2×2 matrices.

**Catalog References**: `Tropical/StereographicProjection.lean` (tropDet, tropWidth, stereo_width)

**Proof Strategy**: Compute J explicitly for general 2×2 tropical matrices and verify conjugation invariance by direct calculation. The key obstacle is defining "tropical PGL(2) conjugation" — since tropical matrices don't have a standard inverse, one must use the notion of tropical adjugate or residuation. An alternative approach is to define conjugation via the homogeneous action: M ∼ N if they have the same action on TP¹.

**Domain Bridges**: Tropical geometry <-> conformal geometry, Max-plus algebra <-> spectral theory

**Lineage**: Builds on the tropical determinant and width calculations from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Möbius Transformations and ReLU Networks

**Conjecture**: A composition of k tropical Möbius transformations (i.e., the affine evaluation of a product of k tropical 2×2 matrices) is a continuous piecewise-linear function with at most 2k breakpoints. Moreover, this bound is tight: there exist sequences of matrices achieving exactly 2k breakpoints.

**Test**: (a) Implement iterated tropical matrix multiplication and count breakpoints of the resulting affine evaluation for k = 1, ..., 20. (b) Search for tight examples (matrices achieving 2k breakpoints). (c) Compare the breakpoint growth rate with the "linear region" counting for ReLU networks.

**Impact**: If the 2k bound is tight, it establishes a precise "depth-width tradeoff" for tropical Möbius composition, analogous to the exponential expressivity results for deep ReLU networks. This would connect tropical geometry to deep learning theory via a clean algebraic framework. If the growth is sublinear, it would suggest fundamental limits on tropical computation.

**Catalog References**: `Tropical/StereographicProjection.lean` (eval_below_leftBreak, eval_above_rightBreak, tropWidth), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: Upper bound: each matrix multiplication introduces at most 2 new breakpoints (the breakpoints of the new matrix, transformed through the composition). Prove by induction on k using the piecewise-linear structure theorem. Tightness: construct matrices whose breakpoints interlace optimally — e.g., matrices with breakpoints at {2i−1, 2i} for i = 1, ..., k.

**Domain Bridges**: Tropical geometry <-> deep learning theory, Max-plus algebra <-> piecewise-linear approximation

**Lineage**: Builds on the breakpoint theory and piecewise-linear structure from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Stereographic Projection in Higher Dimensions

**Conjecture**: The tropical stereographic projection S_p on TP^n (defined as the tropical (n+1)×(n+1) matrix with 0 on the diagonal except the last entry which is p, and 0 in all off-diagonal positions) has tropical width |p| in each coordinate direction and its "active region" is the tropical simplex {x ∈ ℝⁿ : 0 ≤ xᵢ ≤ p for all i, ∑xᵢ ≤ p}.

**Test**: (a) Implement the n-dimensional tropical stereographic projection for n = 2, 3 and visualize its level sets. (b) Verify the active region characterization computationally. (c) Determine whether the projection is injective on its active region (tropical analog of the bijection property of classical stereographic projection).

**Impact**: If the active region is a tropical simplex, this gives a concrete realization of the tropical analog of the conformal ball model. It would connect tropical stereographic projection to the theory of tropical polytopes and could provide new coordinate systems for tropical varieties.

**Catalog References**: `Tropical/StereographicProjection.lean` (stereo, stereo_linear, stereo_width), `Geometry/UnifiedTheory.lean` (pole_map_fixed_point_equation)

**Proof Strategy**: Reduce the n-dimensional case to n copies of the 1-dimensional case via coordinate projections. The key challenge is understanding how the coordinate-wise stereographic projections interact — this requires analyzing the joint behavior of multiple max-plus operations.

**Domain Bridges**: Tropical geometry <-> discrete geometry (polytopes), Stereographic projection <-> hyperbolic geometry

**Lineage**: Direct extension of the 1-dimensional stereographic results from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Determinant Gap and Information Theory

**Conjecture**: The "tropical interaction energy" Δ(M, N) = det⊕(M⊗N) − det⊕(M) − det⊕(N) satisfies Δ(M, N) = max(0, γ(M, N)) where γ(M, N) is an explicitly computable function of the entries. For 2×2 matrices, γ(M, N) = max over certain "cross terms" minus the diagonal terms. The gap Δ is zero if and only if M and N are "tropically compatible" (a condition related to the optimal assignment in the product).

**Test**: (a) Compute Δ(M, N) for 10,000 random 2×2 matrix pairs and characterize the zero-gap set. (b) Determine whether Δ has an information-theoretic interpretation (e.g., as a tropical mutual information). (c) Verify the explicit formula for γ.

**Impact**: Understanding when det⊕ is multiplicative (Δ = 0) would characterize the "lossless" compositions in tropical algebra. This connects to the theory of optimal transport (the assignment problem) and could provide new bounds for combinatorial optimization. An information-theoretic interpretation would bridge tropical algebra and coding theory.

**Catalog References**: `Tropical/StereographicProjection.lean` (tropDet_mul_le), `Bridges/TropicalArithmeticCoding.lean` (tropical_and_bound)

**Proof Strategy**: For 2×2 matrices, expand Δ(M, N) explicitly as max of 8 terms minus max of 4 terms. Characterize the zero set by analyzing which of the 8 terms can dominate over all 4 terms. The connection to optimal assignment: the terms that "win" in det⊕(M⊗N) correspond to optimal assignments in the product, while det⊕(M) and det⊕(N) correspond to optimal assignments in the factors.

**Domain Bridges**: Tropical algebra <-> information theory, Combinatorial optimization <-> coding theory

**Lineage**: Builds on the super-multiplicativity inequality tropDet_mul_le from this cycle.

**Ambition**: extension
