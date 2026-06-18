# Future Research Directions

## Synthesis

This cycle established a formal theory of non-Desarguesian projective planes through quasifield coordinatization. The central achievement is the kernel characterization theorem: a quasifield's kernel equals the whole structure if and only if multiplication is associative and right-distributive, and failure of right distributivity forces a proper kernel — the algebraic signature of non-Desarguesian behavior. Combined with the duality principle (every projective plane has a dual) and collineation group structure (identity, composition, inverse), this provides a complete algebraic-geometric framework.

The most promising cross-domain connection from this cycle is the link between quasifield kernels and the Berggren matrix formalism already present in the Catalog (`Algebra/Berggren.lean`, `Cryptography/BerggrenDiophantineLattice.lean`). The Berggren matrices act on Pythagorean triples via a group that is essentially PGL(2, ℤ) — a collineation group of the projective line. Non-Desarguesian analogs could yield "twisted" Berggren-like recursions that generate non-standard Pythagorean-like structures. The kernel theory developed here provides the algebraic machinery to classify such twists.

The highest breakthrough potential lies in Direction 1 (Quasifield Berggren Matrices), which could connect non-Desarguesian geometry directly to Pythagorean triple theory, creating a novel bridge between incidence geometry and number theory.

---

### Direction 1: Quasifield Berggren Matrices and Twisted Pythagorean Trees

**Conjecture**: There exist quasifield-valued analogs of the Berggren matrices that generate tree structures on "quasi-Pythagorean triples" (elements of a quasifield satisfying a² + b² = c² with quasifield arithmetic). When the quasifield is non-associative, the resulting tree has strictly fewer symmetries than the classical Berggren tree, analogous to how non-Desarguesian planes have smaller collineation groups.

**Test**: Construct the Hall quasifield of order 9 (using GF(3²) with twisted multiplication). Enumerate all solutions to a² + b² = c² in this quasifield. Define 3×3 matrices over the quasifield analogous to Berggren's A, B, C matrices. Verify that matrix "multiplication" (using quasifield operations) generates a tree of solutions, and compute whether the tree is proper (i.e., not all solutions are reached, unlike the classical case).

**Impact**: If true, this would establish that non-associativity creates "gaps" in the Pythagorean tree structure — certain triples become unreachable. This would provide a new family of combinatorial designs with number-theoretic significance. If false, it suggests that the Berggren tree structure is more robust than expected, surviving even loss of associativity.

**Catalog References**: `Algebra/Berggren.lean` (applyB₁, A_iter, A_closed), `Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm, IsPythagoreanVec), `Cryptography/BerggrenFingerprintRigidity.lean` (berggrenGen, evalWord)

**Proof Strategy**: 
1. Formalize the Hall quasifield of order 9 explicitly (9 elements with lookup-table multiplication).
2. Solve a² + b² = c² by exhaustive enumeration in the quasifield.
3. Define quasi-Berggren matrices and verify they map solutions to solutions.
4. Compute the reachability graph and compare to the Desarguesian case.

**Domain Bridges**: Non-Desarguesian Geometry <-> Pythagorean Triple Theory, Quasifield Algebra <-> Berggren Matrix Groups

**Lineage**: Builds on kernel characterization (this cycle) and Berggren formalism (Catalog).

**Ambition**: grand_challenge

---

### Direction 2: Wedderburn's Theorem and the Prime Order Conjecture

**Conjecture**: Every finite quasifield of prime order p is a field (i.e., its kernel is the whole structure). This is equivalent to the Prime Order Conjecture: every projective plane of prime order is Desarguesian. A formalization would require formalizing enough finite field theory to show that the only quasifield structure on a set of prime cardinality is the field GF(p).

**Test**: For p = 2, 3, 5, 7, verify computationally that every quasifield of order p is a field by exhaustive enumeration of multiplication tables satisfying the quasifield axioms. For p = 11, this becomes computationally intensive — if a non-field quasifield exists, produce it as a counterexample.

**Impact**: This is a major open conjecture in finite geometry. Even partial results (e.g., for primes p ≡ 3 mod 4) would be significant. A proof would settle one of the longest-standing problems in combinatorics.

**Catalog References**: `Geometry/NonDesarguesian.lean` (quasifieldKernel, kernel_whole_implies_assoc_distrib)

**Proof Strategy**:
1. Formalize Wedderburn's theorem: every finite division ring is a field.
2. Show that in a quasifield of prime order, the additive group is cyclic of order p.
3. Use the unique solvability axioms to constrain the multiplication table.
4. Apply character-theoretic or polynomial methods to force associativity.

**Domain Bridges**: Finite Geometry <-> Finite Field Theory, Quasifield Theory <-> Group Theory

**Lineage**: Builds on quasifield formalization (this cycle).

**Ambition**: grand_challenge

---

### Direction 3: Collineation Group Orders and the Ostrom-Wagner Theorem

**Conjecture**: For a non-Desarguesian plane of order q² (coordinatized by a Hall quasifield), the order of the collineation group divides q²(q² - 1)·2e where q = pᵉ, which is strictly less than the order of PΓL(3, q²) = q⁶(q⁶ - 1)(q⁴ - 1)·2e. Specifically, the ratio |PΓL(3,q²)| / |Aut(Hall(q²))| grows as q⁸.

**Test**: Compute |Aut(Hall(9))| explicitly. The Hall plane of order 9 has collineation group of order 2·9·(9-1)·1 = 144, while PΓL(3,9) has order 9³·(9³-1)·(9²-1)·2 = 42456960. Verify this ratio.

**Impact**: Explicit collineation group computations provide invariants for classifying non-Desarguesian planes. Two planes with different collineation group orders are necessarily non-isomorphic. This gives a practical classification tool.

**Catalog References**: `Geometry/NonDesarguesian.lean` (Collineation, Collineation.comp, Collineation.inv)

**Proof Strategy**:
1. Construct the Hall plane of order 9 explicitly (91 points, 91 lines).
2. Enumerate all collineations by checking which permutations preserve incidence.
3. Compute the group order and verify it matches the theoretical prediction.
4. Generalize to order q² for arbitrary prime powers q.

**Domain Bridges**: Finite Geometry <-> Group Theory, Collineation Groups <-> Automorphism Groups of Quasifields

**Lineage**: Builds on collineation formalization (this cycle).

**Ambition**: extension

---

### Direction 4: Translation Planes and Spread Constructions

**Conjecture**: Every spread of PG(3, q) yields a translation plane of order q², and distinct spreads yield non-isomorphic planes if and only if they are not equivalent under PΓL(4, q). The number of non-isomorphic translation planes of order p² (p prime) grows at least as fast as p^(p/4) for large p.

**Test**: For q = 3, enumerate all spreads of PG(3, 3) (a set of q² + 1 = 10 pairwise disjoint lines covering all 40 points of PG(3, 3)). Verify that exactly two non-isomorphic spreads exist (the regular spread giving PG(2, 9) and the Hall spread giving the Hall plane of order 9).

**Impact**: Spread constructions provide the most systematic method for producing non-Desarguesian planes. Understanding the spread equivalence problem for small cases would advance the classification program significantly.

**Catalog References**: `Geometry/NonDesarguesian.lean` (ProjectivePlane, FiniteProjectivePlane), `Algebra/Berggren.lean` (matrix transformations over finite structures)

**Proof Strategy**:
1. Define spreads formally as partitions of PG(2n-1, q) into (n-1)-dimensional subspaces.
2. Construct the André-Bruck-Bose correspondence: spread → translation plane.
3. For PG(3, 3), enumerate spreads computationally and check isomorphism.
4. Prove that the regular and Hall spreads are non-equivalent.

**Domain Bridges**: Incidence Geometry <-> Linear Algebra over Finite Fields, Spread Theory <-> Quasifield Theory

**Lineage**: Builds on projective plane formalization (this cycle).

**Ambition**: extension

---

### Direction 5: Tropical Quasifields and Idempotent Geometry

**Conjecture**: The tropical semiring (ℝ ∪ {-∞}, max, +) can be extended to a tropical quasifield by defining an appropriate "tropical inverse." The resulting "tropical projective plane" is non-Desarguesian, and its kernel consists only of {-∞, 0} (the tropical analog of {0, 1}).

**Test**: Define tropical addition as max and tropical multiplication as +. Check which quasifield axioms are satisfied. Verify that left distributivity (a + max(b, c) = max(a + b, a + c)) holds but unique solvability requires care (tropical division a - b is well-defined but uniqueness of x·a = x·b + c may fail).

**Impact**: This would create a bridge between tropical geometry and non-Desarguesian incidence geometry. Tropical projective planes could have applications in optimization and phylogenetics, where tropical geometry already plays a role.

**Catalog References**: `Tropical/` (existing tropical algebra infrastructure), `Geometry/NonDesarguesian.lean` (quasifield definition, kernel theory)

**Proof Strategy**:
1. Define the tropical quasifield structure on ℝ ∪ {-∞}.
2. Verify quasifield axioms (especially unique solvability).
3. Compute the kernel explicitly.
4. Determine whether the resulting incidence structure satisfies projective plane axioms.

**Domain Bridges**: Non-Desarguesian Geometry <-> Tropical Geometry, Quasifield Kernels <-> Tropical Valuations

**Lineage**: Builds on quasifield formalization (this cycle) and tropical algebra (Catalog).

**Ambition**: extension
