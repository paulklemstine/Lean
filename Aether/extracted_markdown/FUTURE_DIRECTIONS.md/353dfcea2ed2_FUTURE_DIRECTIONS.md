# Future Directions

## Synthesis

This research cycle established the complete algebraic foundations of Baker-Norine theory on finite graphs in formal mathematics: divisors, chip-firing, the Laplacian, linear equivalence, the canonical divisor, the genus, q-reduced divisors, and divisor rank. Seventeen theorems were formalized, including the Riemann-Roch degree identity deg(K_G) = 2g − 2, the conservation of degree under chip-firing, the uniqueness of q-reduced representatives, the genus formula g(K_n) = (n−1)(n−2)/2 for complete graphs, and the non-negativity of rank for effective divisors. The full Baker-Norine Riemann-Roch theorem r(D) − r(K_G − D) = deg(D) − g + 1 was stated as a formal conjecture.

The most promising cross-domain connection is between chip-firing theory and tropical geometry. The divisor theory on graphs is the discrete skeleton of tropical curve theory, and our formalized Laplacian/linear-equivalence framework provides the exact foundation needed for tropical intersection theory. The existing Catalog work on tropical semirings (`Tropical/`) and the CDPR Brill-Noether formalization (`Tropical/BrillNoether/Core.lean`) can be directly connected to our chip-firing infrastructure. Additionally, the Laplacian lattice connects to lattice-based cryptography (`Cryptography/BerggrenDiophantineLattice.lean`) and the matrix-tree theorem to spectral graph theory.

The highest breakthrough potential lies in Direction 1 (full Riemann-Roch), which would be among the first complete formalizations of the Baker-Norine theorem. Direction 3 has the most unexpected cross-domain potential, linking graph theory to number theory through the Smith normal form of the Laplacian.

---

### Direction 1: Full Baker-Norine Riemann-Roch via Dhar's Algorithm

**Conjecture**: For any divisor D on a connected graph G with genus g, the rank r(D) satisfies r(D) − r(K_G − D) = deg(D) + 1 − g, where r(D) is defined as the maximum k such that D − E is linearly equivalent to an effective divisor for every effective E with deg(E) = k.

**Test**: Verify computationally for all divisors on K₄ (genus 3) and the cycle graph C₅ (genus 1) that the identity holds. Implement Dhar's burning algorithm and verify it computes the correct q-reduced representative for random divisors on graphs up to 10 vertices.

**Impact**: This would be one of the first complete formalizations of the Baker-Norine Riemann-Roch theorem. It would unlock a cascade of applications: Clifford's theorem for graphs, the Riemann inequality, and the complete characterization of divisor ranks on specific graph families.

**Catalog References**: `Shared/BakerNorine.lean` (this cycle's output), `Tropical/DivisorTheory.lean` (tree case), `Tropical/BrillNoether/Core.lean` (CDPR allocation)

**Proof Strategy**:
1. Formalize Dhar's burning algorithm as a well-founded recursion on the number of unburned vertices.
2. Prove that Dhar's algorithm terminates and outputs a q-reduced divisor linearly equivalent to the input.
3. Prove the key lemma: r(D) = D₀(q) where D₀ is the q-reduced representative of D.
4. Use q-reduced duality: the q-reduced form of K_G − D is related to the complement of D's q-reduced form.
5. Combine to get the Riemann-Roch identity.

The critical step is step 4, which requires a careful analysis of how firing sets for D relate to firing sets for K_G − D.

**Domain Bridges**: Chip-firing theory ↔ Tropical geometry (divisors on graphs = tropical divisors) ↔ Algebraic geometry (Riemann-Roch)

**Lineage**: Builds on `Shared/BakerNorine.lean` (q-reduced uniqueness, canonical degree identity, chip-firing conservation)

**Ambition**: grand_challenge

---

### Direction 2: Kirchhoff's Matrix-Tree Theorem and the Jacobian Group

**Conjecture**: For a connected graph G on n vertices, the order of the Jacobian group Jac(G) = ℤ^{n-1} / Im(L̃) (where L̃ is the reduced Laplacian) equals the number of spanning trees of G. Equivalently, |Jac(G)| = det(L̃) where L̃ is any (n-1) × (n-1) minor of the Laplacian matrix.

**Test**: Verify computationally that det(L̃) equals the number of spanning trees for all connected graphs on ≤ 7 vertices. The Cayley formula gives n^{n-2} spanning trees for K_n; verify |Jac(K_n)| = n^{n-2} for n ≤ 8.

**Impact**: This connects the chip-firing theory to the matrix-tree theorem, linking algebraic graph theory to enumerative combinatorics. The Jacobian group is the central algebraic object in sandpile theory.

**Catalog References**: `Shared/BakerNorine.lean` (Laplacian lattice), `Tropical/DivisorTheory.lean`

**Proof Strategy**:
1. Define the Laplacian matrix L as a matrix over ℤ, with L(v,w) = -1 if v ~ w, L(v,v) = deg(v).
2. Define the reduced Laplacian L̃ by deleting one row and column.
3. Prove that the Laplacian lattice Im(L̃) has finite index in ℤ^{n-1}.
4. Use the Smith normal form to compute |ℤ^{n-1}/Im(L̃)| = |det(L̃)|.
5. Prove the matrix-tree theorem: det(L̃) = number of spanning trees.

Step 5 is the hardest and can be approached via the Cauchy-Binet formula or via a direct combinatorial argument.

**Domain Bridges**: Graph Laplacian ↔ Linear algebra (Smith normal form) ↔ Enumerative combinatorics (spanning trees) ↔ Lattice theory (Cryptography)

**Lineage**: Builds on `Shared/BakerNorine.lean` (laplacianLattice, Laplacian lattice closure properties)

**Ambition**: grand_challenge

---

### Direction 3: Tropical Abel-Jacobi Theory and the Torelli Theorem

**Conjecture**: The Abel-Jacobi map φ : Div⁰(G) → Jac(G) (sending degree-zero divisors to their class modulo principal divisors) is a surjective group homomorphism whose kernel is exactly the principal divisors. Moreover, for simple graphs, the Abel-Jacobi map determines the graph up to 2-isomorphism (tropical Torelli theorem).

**Test**: Compute Jac(G) for all graphs on ≤ 6 vertices and verify that non-isomorphic 3-connected graphs have non-isomorphic Jacobians. Find the smallest counterexample to the general Torelli statement (which fails for non-3-connected graphs).

**Impact**: The tropical Torelli theorem is a deep result connecting the algebraic structure of the Jacobian to the combinatorial structure of the graph. Formalizing it would establish a bridge between algebraic and combinatorial graph theory.

**Catalog References**: `Shared/BakerNorine.lean`, `Tropical/BrillNoether/Core.lean`

**Proof Strategy**:
1. Define the Abel-Jacobi map as the natural quotient map.
2. Prove surjectivity using the connected components of the graph.
3. For the Torelli direction: prove that Jac(G) with its "theta divisor" (the set of effective divisor classes of degree g-1) determines G up to 2-isomorphism.

**Domain Bridges**: Graph Jacobian ↔ Abelian group theory ↔ Tropical geometry ↔ Algebraic geometry (classical Torelli)

**Lineage**: Builds on `Shared/BakerNorine.lean` (linear equivalence, Laplacian lattice)

**Ambition**: extension

---

### Direction 4: Gonality and Treewidth

**Conjecture**: The gonality of a graph G (the minimum degree of a divisor of rank ≥ 1) is bounded below by the treewidth of G plus 1: gon(G) ≥ tw(G) + 1. This conjecture (due to Baker and others) is known to hold for many graph families.

**Test**: Compute gonality and treewidth for all connected graphs on ≤ 8 vertices. Verify the bound for all such graphs. Search for graph families where the bound is tight.

**Impact**: This connects divisor theory to structural graph theory (treewidth), which has major applications in algorithms and complexity theory. A formal proof would bridge combinatorial optimization and algebraic graph theory.

**Catalog References**: `Shared/BakerNorine.lean` (divisor rank), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**:
1. Define treewidth via tree decompositions.
2. Define gonality as the minimum degree of a divisor of rank ≥ 1.
3. Show that if tw(G) = k, then for any divisor D of degree k, there exists an effective E with deg(E) = 1 such that D - E is not equivalent to an effective divisor.
4. Use the structure of tree decompositions to construct the witness E.

**Domain Bridges**: Divisor theory ↔ Structural graph theory (treewidth) ↔ Algorithms (tree decomposition)

**Lineage**: Builds on `Shared/BakerNorine.lean` (divisor rank, effective rank)

**Ambition**: extension

---

### Direction 5: Harmonic Morphisms and Functoriality of Chip-Firing

**Conjecture**: If φ : G → H is a harmonic morphism of graphs (preserving the local degree at each vertex), then φ induces a group homomorphism φ* : Jac(G) → Jac(H) that commutes with the Abel-Jacobi map. The degree of φ satisfies the Hurwitz formula: 2g(G) − 2 = deg(φ)(2g(H) − 2) + ∑_v (e_v − 1), where e_v is the ramification index at v.

**Test**: Construct explicit harmonic morphisms between small graphs (e.g., the cube graph → K₄) and verify the Hurwitz formula. Check that the induced map on Jacobians is well-defined.

**Impact**: Harmonic morphisms are the correct notion of "morphism" in the category of graphs-with-chip-firing. Formalizing the Hurwitz formula would establish the functorial framework needed for a full tropical Riemann-Hurwitz theory.

**Catalog References**: `Shared/BakerNorine.lean` (canonical divisor, genus), `Tropical/DivisorTheory.lean`

**Proof Strategy**:
1. Define harmonic morphisms: a graph map φ : V(G) → V(H) such that for each v ∈ V(G) and each w ∈ N(φ(v)), the number of neighbors u of v with φ(u) = w is constant.
2. Define the pushforward and pullback of divisors.
3. Prove that the pushforward preserves principal divisors, hence induces a map on Jacobians.
4. Derive the Hurwitz formula from deg(K_G) = 2g−2 and the ramification data.

**Domain Bridges**: Graph morphisms ↔ Algebraic geometry (Hurwitz formula) ↔ Category theory (functoriality)

**Lineage**: Builds on `Shared/BakerNorine.lean` (canonical divisor, canonical_degree theorem)

**Ambition**: extension
