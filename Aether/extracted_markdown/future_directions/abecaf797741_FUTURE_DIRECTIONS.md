# Future Directions: Tropical Matroid Theory

## Synthesis

This research cycle established the foundational connection between matroid combinatorics and tropical geometry through machine-verified proofs. The central result — that the Bergman fan of a matroid equals its tropical linear space — was proved, along with the conical structure (translation invariance, positive scaling), the double minimum principle, tropical closure under coordinate-wise minimum, and the circuit-flat complement theorem.

A key discovery was that tropical closure (the Bergman fan being closed under coordinate-wise minimum) holds for ALL matroids, not just nested ones. This universality was not part of the original research direction and represents genuine mathematical insight: the Bergman fan is always a tropical prevariety. This connects to tropical convexity theory and suggests that many properties assumed to require the nested hypothesis can be generalized.

The most promising cross-domain connection is between the circuit-flat complement theorem and the Catalog's existing work on matroid quantum certificates (`Bridges/MatroidQuantumCertificates.lean`). The complement theorem constrains how quantum certificates can be structured relative to flat partitions, potentially yielding tighter quantum query bounds for matroid recognition problems. The tropical intersection conjecture also bridges to the Catalog's computational complexity work, as tropical matroid intersection could provide new lower bound techniques.

---

### Direction 1: Tropical Bergman Fan Decomposition Theorem

**Conjecture**: The Bergman fan B(M) of a rank-r matroid M on [n] decomposes as a union of cones B(M) = ⋃_{σ} cone(σ), where σ ranges over maximal chains of proper flats ∅ ⊊ F₁ ⊊ F₂ ⊊ ... ⊊ F_{r-1} ⊊ E, and cone(σ) = {w ∈ ℝⁿ : w constant on F_{k}\F_{k-1} for each k, with w|_{F_{k}\F_{k-1}} ≥ w|_{F_{k+1}\F_k}}. Moreover, this decomposition is a balanced polyhedral fan of pure dimension r-1 (in ℝⁿ/ℝ·1).

**Test**: Construct the uniform matroid U_{2,4} on 4 elements. Its maximal chains of flats are: ∅ ⊂ {i} ⊂ {0,1,2,3} for each i. Verify that B(U_{2,4}) is the union of these 4 cones and has dimension 1. Verify the balancing condition at each codimension-1 face.

**Impact**: This decomposition is the foundation for computing Bergman fans algorithmically and for connecting them to phylogenetic tree spaces. It would also enable computation of the f-vector of B(M), relating to the beta invariant of the matroid.

**Catalog References**: `Tropical/BergmanFan.lean` (this cycle's work), `Bridges/MatroidQuantumCertificates.lean`

**Proof Strategy**: 
1. Define maximal chains of flats formally (build on the `FlatChain` structure from this cycle).
2. Prove that each cone is contained in B(M) using the circuit-flat complement theorem.
3. Prove the reverse containment: for w ∈ B(M), construct a compatible chain by "sorting" the weight values and identifying the corresponding flats via M.closure.
4. Prove purity and balancing using the matroid axioms.

**Domain Bridges**: Tropical Geometry <-> Matroid Theory <-> Phylogenetics (tree spaces)

**Lineage**: Builds on `bergman_eq_tropical`, `circuit_flat_complement_card`, and `bergmanCone`/`bergmanOrderedCone` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Matroid Intersection Lower Bounds

**Conjecture**: For two matroids M₁, M₂ on [n] with maximum common independent set of size k, the intersection B(M₁) ∩ B(M₂) is a polyhedral complex of dimension exactly k-1 (in ℝⁿ/ℝ·1). In particular, dim(B(M₁) ∩ B(M₂)) encodes the matroid intersection number.

**Test**: Construct the graphic matroid of K₄ and the uniform matroid U_{3,6} on the same 6-element ground set. Compute B(M₁) ∩ B(M₂) using linear programming over the cone decomposition. Verify that the dimension matches the maximum common independent set size minus 1.

**Impact**: If true, this provides a tropical certificate for matroid intersection — a geometric object whose dimension alone certifies the answer. This could lead to new tropical algorithms for matroid intersection and potentially to lower bounds for algebraic computation models via the tropical complexity framework in the Catalog.

**Catalog References**: `Computation/TropicalComplexity/Defs.lean`, `Bridges/MatroidQuantumCertificates.lean`, `Tropical/BergmanFan.lean`

**Proof Strategy**:
1. Prove the dimension lower bound: the tropical convex hull of B(M₁) ∩ B(M₂) contains a (k-1)-dimensional linear space by constructing weight vectors from a maximum common independent set.
2. Prove the dimension upper bound by showing that any (k)-dimensional face of the intersection would yield a common independent set of size > k.
3. Use the valuated matroid framework to handle the algebraic aspects.

**Domain Bridges**: Tropical Geometry <-> Combinatorial Optimization <-> Computational Complexity

**Lineage**: Builds on `bergman_intersection_nonempty` and `TropicalIntersectionConj` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Log-Concavity via Bergman Fans

**Conjecture**: The coefficients of the reduced characteristic polynomial of a matroid M satisfy the ultra-log-concavity inequality a_k² ≥ a_{k-1} · a_{k+1} · ((k+1)(r-k+1))/(k(r-k)), where a_k counts the number of flats of rank k and r is the matroid rank. This can be proved by establishing that the mixed volumes of certain tropical polytopes derived from B(M) satisfy the Alexandrov-Fenchel inequality tropically.

**Test**: Verify the inequality computationally for all matroids on ≤ 8 elements from the matroid database. Check that the tropical Alexandrov-Fenchel inequality holds for the Bergman fan of the Fano matroid F₇.

**Impact**: A tropical proof of log-concavity would be more elementary than the Hodge-theoretic proof of Adiprasito-Huh-Katz and could extend to settings where Hodge theory doesn't apply (e.g., matroids over partial fields).

**Catalog References**: `Tropical/BergmanFan.lean`, `Tropical/HodgeShadow/TropicalCycleCorrespondence.lean`

**Proof Strategy**:
1. Define the tropical characteristic polynomial of a matroid via the Bergman fan's f-vector.
2. Prove a tropical Alexandrov-Fenchel inequality for Bergman fans using the fan decomposition.
3. Derive log-concavity from the tropical AF inequality via standard convexity arguments.

**Domain Bridges**: Tropical Geometry <-> Algebraic Geometry (Hodge Theory) <-> Combinatorics

**Lineage**: Builds on the Bergman fan formalization from this cycle and the tropical Hodge shadow work in the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Valuated Matroids and Tropical Plücker Relations

**Conjecture**: Every point in the tropical Grassmannian Gr(r,n) (the set of valuated matroids of rank r on [n]) satisfies the three-term tropical Plücker relations, and conversely, every point satisfying these relations is a valuated matroid. The Dressian Dr(r,n) (defined by the three-term relations) equals Gr(r,n) for r ≤ 2 but strictly contains it for r ≥ 3 and n ≥ 7.

**Test**: Verify computationally that Dr(2,n) = Gr(2,n) for n ≤ 8. Construct an explicit point in Dr(3,7) \ Gr(3,7).

**Impact**: Formalizing the distinction between Dressians and tropical Grassmannians would provide the foundation for studying realizability of tropical linear spaces, a central open problem in tropical geometry.

**Catalog References**: `Tropical/BergmanFan.lean` (ValuatedMatroid definition), `Algebra/RotaBasisConjecture.lean`

**Proof Strategy**:
1. Formalize the tropical Plücker relations as polynomial constraints on basis valuations.
2. Prove that valuated matroid exchange implies the three-term relations.
3. For rank 2, prove the reverse by constructing the matroid from the Plücker vector.
4. For the separation result, construct the Herrmann-Jensen-Joswig-Sturmfels counterexample.

**Domain Bridges**: Tropical Geometry <-> Algebraic Geometry (Grassmannians) <-> Matroid Theory

**Lineage**: Builds on the `ValuatedMatroid` structure from this cycle.

**Ambition**: extension

---

### Direction 5: Bergman Fan Connectivity and Matroid Connectivity

**Conjecture**: A matroid M on [n] is connected (i.e., not a direct sum of two smaller matroids) if and only if its Bergman fan B(M) is connected through codimension 1 (i.e., any two maximal cones can be connected by a path through cones sharing codimension-1 faces).

**Test**: Verify for the cycle matroid of K₄ (which is connected) that the Bergman fan is codimension-1 connected. Verify for the direct sum of U_{1,2} ⊕ U_{1,2} (which is disconnected) that the Bergman fan has two codimension-1 connected components.

**Impact**: This would provide a complete topological characterization of matroid connectivity via the Bergman fan, extending the circuit-connectivity results formalized in this cycle.

**Catalog References**: `Tropical/BergmanFan.lean`, `Novelty/Basic.lean` (MatroidConnected)

**Proof Strategy**:
1. Use the cone decomposition (Direction 1) to define the dual graph of B(M).
2. Prove that matroid connectivity implies the dual graph is connected using the circuit exchange axiom.
3. Prove the reverse by showing that disconnected fans yield a direct sum decomposition.
4. The key lemma: two maximal cones sharing a codimension-1 face correspond to adjacent maximal chains of flats, which differ by a single flat.

**Domain Bridges**: Tropical Geometry <-> Graph Theory (Dual Graphs) <-> Matroid Connectivity

**Lineage**: Builds on `CircuitConnected`, `IsStronglyConnected`, and `bergman_double_min` from this cycle.

**Ambition**: extension
