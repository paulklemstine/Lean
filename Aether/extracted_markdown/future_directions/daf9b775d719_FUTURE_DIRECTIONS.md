# Future Directions: Non-Desarguesian Geometry

## Synthesis

This research cycle established the algebraic foundations of non-Desarguesian projective planes through verified proofs of the nucleus sub-ring theorem, the Hall quasifield non-associativity, and the symmetry loss bounds. The central insight is that the **left nucleus** — the set of elements satisfying the associative law — is both algebraically robust (forming a sub-ring) and geometrically decisive (its equality with the full quasifield is equivalent to Desargues' theorem). This creates a quantitative bridge: the "defect" (complement size of the nucleus) measures both algebraic non-associativity and geometric non-Desarguesian-ness.

The most promising cross-domain connection is between **nucleus theory** and **coding theory**. The nucleus of a quasifield determines the automorphism group of the associated translation plane, which in turn controls the weight distribution of codes derived from the plane's incidence matrix. Hall planes (with small nuclei and large defects) give codes with different distance profiles than Desarguesian planes — potentially useful for specific communication channels.

The highest breakthrough potential lies in **Direction 1 (Knuth Semifield Classification)**, because semifields (quasifields with both distributive laws) occupy a rich middle ground between fields and general quasifields. Their classification connects to tensor theory and the algebraic geometry of Segre varieties, with known connections to maximum rank-distance codes (MRD codes) used in network coding.

---

### Direction 1: Knuth Semifield Classification via Nuclei

**Conjecture**: For every finite semifield S of order p^n (p prime, n ≥ 3), the triple (|N_ℓ|, |N_m|, |N_r|) of nucleus sizes satisfies |N_ℓ| · |N_m| · |N_r| ≤ |S|, with equality iff S is a field. Furthermore, the Knuth orbit (the set of semifields obtained by applying the six Knuth operations to S) has size dividing 6, and the orbit size correlates with the irregularity of the nucleus triple.

**Test**: Enumerate all semifields of order 16, 32, 64 (computationally tractable). For each, compute the nucleus triple and verify the product bound. Count Knuth orbit sizes and check correlation with nucleus asymmetry (|max nucleus / min nucleus|).

**Impact**: If true, this gives a computable invariant for semifield classification that could dramatically reduce the search space for new semifields. The product bound would connect nucleus theory to the tensor rank of the multiplication table, bridging algebra and combinatorics. If false, the counterexample would reveal new semifield phenomena beyond current theory.

**Catalog References**: `Catalog/MachineLearning/NonDesarguesian/Core.lean` (nucleus definitions), `Catalog/Geometry/NonDesarguesian/Defs.lean` (quasifield structure)

**Proof Strategy**: 
1. Formalize the six Knuth operations (transpose, dual, etc.) on the multiplication tensor of a semifield.
2. Prove that Knuth operations permute the three nuclei.
3. Establish the product bound by relating nucleus sizes to subspace dimensions of the multiplication tensor.
4. For the computational test, implement semifield enumeration in Python and verify with Lean for small cases.

**Domain Bridges**: Algebra (non-associative algebra, tensor rank) <-> Coding Theory (MRD codes, linearized polynomials) <-> Combinatorics (Latin squares, orthogonal arrays)

**Lineage**: Builds on nucleus sub-ring theorem and nucleus size theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Desargues Failure Counting

**Conjecture**: In the Hall plane of order q², the number of Desargues configurations where the theorem fails is exactly q²(q² - 1)²(q² - q)³ / 6 — i.e., it equals the number of perspective-from-a-point triangle pairs where the center of perspectivity is an affine point and at least one triangle vertex maps to a non-nuclear coordinate under the standard coordinatization.

**Test**: For q = 3 (Hall plane of order 9), enumerate all Desargues configurations (computationally feasible with 91 points). Count failures and compare to the formula: 9 · 80 · 54³ / 6 = predicted value. Cross-check with the known result that the Hall plane of order 9 has a specific number of Desargues failures.

**Impact**: If true, this gives the first closed-form count of Desargues failures, directly connecting the algebraic defect (q² - q non-nuclear elements) to the geometric failure count. This would quantify "how non-Desarguesian" a plane is. If false, the discrepancy would reveal that Desargues failures have a more complex distribution than expected.

**Catalog References**: `Catalog/Geometry/NonDesarguesian/Defs.lean` (DesarguesConfig definition), `Geometry/NonDesarguesianPlanes.lean` (Hall multiplication, nucleus characterization)

**Proof Strategy**:
1. Define a "Desargues failure" predicate in the coordinatized plane.
2. Show that failures require at least one associator computation involving non-nuclear elements.
3. Count the number of valid triangle pairs and the fraction that fail.
4. Verify computationally for q = 3 before attempting the general proof.

**Domain Bridges**: Finite Geometry (Desargues configurations) <-> Combinatorics (configuration counting) <-> Algebra (associator distribution)

**Lineage**: Builds on hall_nonassociative, hall_nucleus_card, and associator_zero_iff from this cycle.

**Ambition**: extension

---

### Direction 3: Spread Regularity and André Theory

**Conjecture**: A translation plane of order q² is a Hall plane if and only if its spread (a partition of a 4-dimensional vector space over GF(q) into 2-dimensional subspaces) contains exactly one regulus — a family of q + 1 mutually disjoint subspaces that can be completed to a regular spread in exactly one way. Translation planes with k reguli in their spread (0 ≤ k ≤ q + 1) form a hierarchy with k = q + 1 being Desarguesian and k = 1 being Hall.

**Test**: For q = 3, classify all spreads of GF(3)⁴ into 2-dimensional subspaces. Count the number of reguli in each spread and verify the correspondence: k = 4 → Desarguesian, k = 1 → Hall, k = 0 → neither.

**Impact**: If true, this gives a geometric characterization of Hall planes that avoids the algebraic definition entirely — useful for recognizing Hall planes from their combinatorial data. The hierarchy by regulus count would provide a natural "distance from Desarguesian" measure that refines the nucleus defect.

**Catalog References**: `Geometry/NonDesarguesianPlanes.lean` (Spread structure definition)

**Proof Strategy**:
1. Formalize reguli in Lean: a regulus is a set of q + 1 pairwise disjoint subspaces such that any transversal line meets each subspace.
2. Prove that the Desarguesian spread has q + 1 reguli (one for each "direction").
3. Show that the Hall spread modification (replacing one regulus with its opposite regulus) reduces the count by exactly 1 when applied once.
4. Verify computationally for small q.

**Domain Bridges**: Linear Algebra (subspace partitions) <-> Algebraic Geometry (Grassmannians, Segre varieties) <-> Combinatorics (Latin squares, transversal designs)

**Lineage**: Builds on the spread definition and Hall quasifield verification from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Automorphism Bounds for General Quasifields

**Conjecture**: For any finite right quasifield Q of order q² with left nucleus of size q, the automorphism group Aut(Q) has order dividing q(q-1)² · gcd(2, q-1). In particular, |Aut(Q)| ≤ 2q(q-1)², with equality achieved by Hall quasifields.

**Test**: For q = 3, 4, 5, 7, enumerate all known quasifields of order q² and compute their automorphism group orders. Verify divisibility and the bound. Check whether non-Hall quasifields with |N_ℓ| = q achieve the bound.

**Impact**: If true, this bound would give a practical criterion for distinguishing quasifield types: Hall quasifields would be characterized as those with maximal automorphism groups among quasifields with a given nucleus size. This connects to the classification problem for translation planes.

**Catalog References**: `Geometry/NonDesarguesianPlanes.lean` (rqLeftNuc, nucleus theory), `Catalog/MachineLearning/NonDesarguesian/Core.lean` (Quasifield class)

**Proof Strategy**:
1. Show that every automorphism of Q restricts to an automorphism of the nucleus.
2. Prove that the kernel of this restriction (automorphisms fixing the nucleus pointwise) has order dividing q(q-1).
3. Bound the image in Aut(N_ℓ) using the fact that N_ℓ ≅ GF(q).
4. Combine using the exact sequence 1 → Ker → Aut(Q) → Aut(N_ℓ).

**Domain Bridges**: Group Theory (automorphism groups) <-> Algebra (quasifield theory) <-> Finite Geometry (collineation groups)

**Lineage**: Builds on rqLeftNuc_is_subring, hall_collineation_lt_pgl, and symmetry_ratio_growth from this cycle.

**Ambition**: extension

---

### Direction 5: Computational Non-Associative Division Algebra Zoo

**Conjecture**: The number of non-isomorphic quasifields of order p² (p prime) grows at least as Ω(p^{p/4}) — superexponentially in p. This far exceeds the number of semifields (which grows polynomially in p for fixed dimension).

**Test**: Implement an exhaustive search for quasifields of order p² for p = 3, 5, 7, 11. Count non-isomorphic examples and fit the growth rate. Compare with the known semifield counts.

**Impact**: If true, this shows that the landscape of non-associative coordinate systems is vastly richer than the semifield sub-landscape. Each new quasifield gives a new projective plane, so superexponential growth in quasifields implies superexponential growth in planes — answering a long-standing question in finite geometry.

**Catalog References**: `Geometry/NonDesarguesianPlanes.lean` (Hall construction as base example), `Catalog/Computation/ResearchQuestions.lean` (computational methods)

**Proof Strategy**:
1. Develop a canonical form for quasifields of order p² (e.g., fixing addition and varying multiplication).
2. Implement isomorphism testing via canonical labeling of the multiplication table.
3. Use constraint propagation to enumerate valid multiplication tables satisfying the quasifield axioms.
4. Apply Burnside's lemma to count isomorphism classes.

**Domain Bridges**: Combinatorics (enumeration, isomorphism testing) <-> Algebra (non-associative structures) <-> Computation (constraint satisfaction, canonical forms)

**Lineage**: Builds on gf9_card, hall_nonassociative, and the spectrum discussion from this cycle.

**Ambition**: extension
