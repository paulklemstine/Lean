# Future Directions: Non-Desarguesian Geometry and Beyond

## Synthesis

This research cycle established a complete formalized algebraic theory of quasifield nuclei and their connection to the failure of Desargues' theorem. The key insight is that the nucleus — the subset of elements that associate with all others — provides a quantitative bridge between algebra and geometry: its size controls how many symmetries a projective plane has, and whether Desargues' theorem holds. We proved nucleus closure (the left nucleus is a sub-division-ring), the associativity characterization (three equivalent conditions for Desargues), and a quantitative collineation group bound showing that symmetry loss scales as q⁴ for Hall planes.

The most promising cross-domain connection is between **quasifield defect theory** and **coding theory**. The defect δ(Q) = |Q| - |N_ℓ(Q)| controls both the geometric failure of Desargues and the algebraic distance from a field structure. This same "distance from linearity" appears in the theory of MDS codes, where codes constructed from non-Desarguesian planes have different minimum distance properties. The Catalog's `Cryptography/BerggrenDiophantineLattice.lean` formalization of lattice structures could potentially be extended to capture the lattice of subplanes in a non-Desarguesian plane, where the nucleus chain N_ℓ ⊂ Q provides a natural filtration.

The direction with highest breakthrough potential is **Direction 1** (Artin-Zorn formalization), because proving that prime-order quasifields must be fields would close a major gap in the formal theory and connect directly to Wedderburn's little theorem on finite division rings.

---

### Direction 1: Formalized Artin-Zorn Theorem for Prime-Order Quasifields

**Conjecture**: Every quasifield of prime order p is a field. Equivalently, if Q is a finite quasifield with |Q| = p for p prime, then Q is associative and commutative.

**Test**: Attempt to prove in Lean that for a Quasifield Q with Fintype.card Q = p (p prime), every element is in the left nucleus. The key step is showing that the left nucleus, being a sub-division-ring, has order dividing |Q| = p, so |N_ℓ| ∈ {1, p}. Since |N_ℓ| ≥ 2 (contains 0 and 1 when p ≥ 2), we get |N_ℓ| = p, hence N_ℓ = Q.

**Impact**: This would formally verify one of the deepest results in finite geometry: that no non-Desarguesian plane of prime order exists. It would also connect to Wedderburn's theorem (every finite division ring is a field) and the classification of finite simple groups.

**Catalog References**: `MachineLearning/NonDesarguesian/Core.lean` (assoc_iff_leftNuc_univ, nucleus_has_two_elements, leftNuc_is_subring)

**Proof Strategy**: 
1. Prove that |N_ℓ(Q)| divides |Q| using the fact that N_ℓ is a subgroup of the additive group (closed under addition, contains 0, needs closure under negation).
2. For |Q| = p prime, conclude |N_ℓ| ∈ {1, p}.
3. Since N_ℓ contains both 0 and 1, and 0 ≠ 1 when p ≥ 2, |N_ℓ| ≥ 2, so |N_ℓ| = p.
4. Apply assoc_iff_leftNuc_univ.

Key missing lemma: closure of N_ℓ under negation (needs (-a)(bc) = ((-a)b)c, derivable from right distributivity and neg_mul_right).

**Domain Bridges**: Quasifield theory ↔ Finite group theory (Lagrange's theorem), Non-Desarguesian geometry ↔ Number theory (prime classification)

**Lineage**: Builds on leftNuc_add_closed, leftNuc_mul_closed, nucleus_has_two_elements from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Explicit Hall Plane Construction and Verification

**Conjecture**: The Hall quasifield of order 9 (constructed over GF(3)) is a valid quasifield that is NOT associative. Its left nucleus has exactly 3 elements.

**Test**: Explicitly construct the 9-element Hall quasifield as Fin 9 with multiplication table, verify all quasifield axioms by computation, and exhibit three specific elements a, b, c where a(bc) ≠ (ab)c.

**Impact**: This would provide the first fully formalized non-Desarguesian projective plane, connecting abstract theory to concrete computation. It would also serve as a test case for automated verification of finite algebraic structures.

**Catalog References**: `MachineLearning/NonDesarguesian/Core.lean` (Quasifield class, HallConfig, leftNuc)

**Proof Strategy**:
1. Define GF(3) = Fin 3 with standard field operations.
2. Define Hall(9) = Fin 3 × Fin 3 with twisted multiplication using the nonsquare α = 2 (since x² ∈ {0, 1} in GF(3), so 2 is a nonsquare).
3. Verify quasifield axioms by `native_decide` on the finite structure.
4. Exhibit the non-associative triple: e.g., (0,1) · ((1,0) · (0,1)) vs ((0,1) · (1,0)) · (0,1).
5. Compute the left nucleus explicitly and show it equals {(a, 0) | a ∈ GF(3)}.

**Domain Bridges**: Finite algebra ↔ Computational verification, Hall systems ↔ Coding theory

**Lineage**: Extends HallConfig definition and hall_plane_order_bound from this cycle.

**Ambition**: extension

---

### Direction 3: Semifield Classification and the Knuth Orbit

**Conjecture**: Every finite semifield of order p² (p odd prime) is isotopic to a field. For order p³, there exist non-isotopic semifields (Knuth semifields) whose isotopy classes correspond to orbits under a group of order 6 (the Knuth operations: transpose, dual, and their compositions).

**Test**: Construct the Knuth semifield of order 8 (= 2³) explicitly and verify it is a valid semifield that is not isotopic to GF(8). Compute its nucleus chain N_ℓ ⊂ N_m ⊂ N_r and show the three nuclei have different sizes.

**Impact**: Knuth's 1965 discovery that six planes can be derived from each semifield via transpose and duality operations was a breakthrough in finite geometry. Formalizing this would connect to the Catalog's algebraic machinery and provide a foundation for semifield classification.

**Catalog References**: `MachineLearning/NonDesarguesian/Core.lean` (Quasifield.IsSemifield, midNuc, rightNuc, fullNuc)

**Proof Strategy**:
1. Define semifield isotopy: two semifields S₁, S₂ are isotopic if there exist bijections F, G, H such that F(x · y) = G(x) ∘ H(y).
2. Formalize the Knuth operations: transpose (swap left and right nuclei), dual (swap middle and a combination).
3. Prove that the six Knuth operations form a group isomorphic to S₃.
4. For order p², show that the only semifield is the field (using nucleus divisibility arguments similar to Artin-Zorn).

**Domain Bridges**: Semifield theory ↔ Group actions (S₃), Non-associative algebra ↔ Coding theory (MRD codes)

**Lineage**: Extends semifield_left_mul_additive and semifield_midNuc_contains_identity from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Collineation Group Structure for Translation Planes

**Conjecture**: For a translation plane of order q² coordinatized by a quasifield Q with |N_ℓ(Q)| = q, the collineation group has a normal subgroup of order q⁴ (the translation group) and the quotient has order dividing q² · (q²-1) · (q-1) · gcd(q²-1, 2).

**Test**: Verify this bound for the Hall plane of order 9 (q = 3): translation group of order 81, quotient of order dividing 9 · 8 · 2 · 2 = 288. The actual collineation group of the Hall plane of order 9 has order 29,160, with translation group of order 81 and quotient of order 360.

**Impact**: Understanding the collineation group structure would refine our symmetry_loss_growth theorem and provide tighter bounds on the relationship between algebraic and geometric symmetry.

**Catalog References**: `MachineLearning/NonDesarguesian/Core.lean` (hall_collineation_lt_pgl, symmetry_loss_growth, ProjCollineation)

**Proof Strategy**:
1. Formalize translation groups: collineations fixing a line pointwise.
2. Prove the translation group is elementary abelian of order q² for a translation plane of order q².
3. Analyze the stabilizer of the translation line and show it is controlled by the nucleus.
4. Use the orbit-stabilizer theorem to bound the full collineation group.

**Domain Bridges**: Geometric symmetry ↔ Group theory, Translation planes ↔ Spread theory (vector space partitions)

**Lineage**: Extends hall_collineation_lt_pgl and symmetry_loss_growth from this cycle.

**Ambition**: extension

---

### Direction 5: Non-Desarguesian Planes and Error-Correcting Codes

**Conjecture**: The incidence matrix of a non-Desarguesian plane of order q generates a binary linear code with minimum distance at least q + 1, identical to the Desarguesian case, but with a different weight distribution at higher weights.

**Test**: Compute the weight enumerator of the code from the Hall plane of order 9 and compare with the weight enumerator of the code from PG(2, 9). The minimum distances should be equal (10), but the number of codewords of weight 10, 11, etc. should differ.

**Impact**: If non-Desarguesian planes yield codes with better weight distributions at certain weights, this could have practical implications for communication systems. The connection between quasifield defect and code parameters would also provide a new algebraic handle on coding-theoretic questions.

**Catalog References**: `MachineLearning/NonDesarguesian/Core.lean` (qfDefect, defect_zero_iff_assoc), `Cryptography/BerggrenDiophantineLattice.lean` (lattice structure)

**Proof Strategy**:
1. Formalize the incidence matrix of a projective plane as a (0,1)-matrix.
2. Prove that each row has exactly q + 1 ones and each pair of rows shares exactly one column.
3. Show this implies the code has minimum distance ≥ q + 1 (by Singleton-type bound).
4. For the weight distribution comparison, use computational verification on the order-9 case.

**Domain Bridges**: Finite geometry ↔ Coding theory, Quasifield nuclei ↔ Code automorphism groups

**Lineage**: Extends defect_zero_iff_assoc and the quasifield framework from this cycle.

**Ambition**: extension
