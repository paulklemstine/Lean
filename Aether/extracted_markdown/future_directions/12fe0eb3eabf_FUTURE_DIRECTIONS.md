# Future Directions: Non-Desarguesian Geometry Research

## Synthesis

This research cycle established the algebraic foundations for studying non-Desarguesian projective planes through formal verification. The key insight is the precise algebraic-geometric correspondence: non-associativity of the coordinatizing quasifield is equivalent to failure of the Desargues property. We formalized this chain for the smallest non-trivial case — the Hall plane of order 9 — proving right distributivity, non-associativity, and the failure of division ring structure, alongside abstract projective plane theorems (perspectivity, point/line counting).

The most promising cross-domain connection emerging from this cycle is between **non-associative algebra** and **finite geometry**: every proper quasifield yields a non-Desarguesian plane, and the algebraic properties of the quasifield directly determine the geometric properties of the plane. This connects to coding theory (planes yield optimal codes), group theory (collineation groups are constrained by algebraic structure), and even physics (non-associative structures appear in octonion geometry and string theory).

The highest breakthrough potential lies in Direction 1 (Artin-Zorn Formalization), as it would establish the complete algebraic-geometric dictionary, enabling automated classification of projective planes by their algebraic invariants.

---

### Direction 1: Formal Artin-Zorn Theorem — Complete Algebraic-Geometric Dictionary

**Conjecture**: A projective plane π satisfies the Desargues property if and only if π can be coordinatized by a division ring (skew field). In particular, every non-Desarguesian translation plane is coordinatized by a proper quasifield.

**Test**: Formalize the coordinatization procedure: given a projective plane π with a designated "line at infinity" and "origin," construct a quasifield (Q, +, ○) from the incidence structure. Verify that the Desargues property for π is equivalent to associativity + left distributivity of (Q, ○). A computational test: construct the coordinate quasifield of the Fano plane (order 2) and verify it is GF(2); construct coordinates for the Hall plane (order 9) and verify non-associativity.

**Impact**: This would be the first formal verification of Hilbert's fundamental theorem connecting synthetic and analytic geometry. It would enable automated verification of whether a given incidence structure is Desarguesian by checking algebraic properties of its coordinate system.

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (ProjectivePlane, Quasifield definitions), `Geometry/NonDesarguesian/Theorems.lean` (proper_quasifield_not_division_ring)

**Proof Strategy**: 
1. Define the coordinatization procedure: choose four points O, I, X, Y in general position; define addition and multiplication of "slope" and "intercept" using geometric constructions (parallel class, perspectivities).
2. Prove the resulting structure satisfies quasifield axioms.
3. Prove that the Desargues axiom (restricted to appropriate configurations) implies associativity.
4. Conversely, prove that associativity of the quasifield implies the Desargues property in the coordinate plane.

**Domain Bridges**: Algebra (division rings, quasifields) <-> Geometry (Desargues property, incidence structures) <-> Logic (decidability of geometric properties via algebraic computation)

**Lineage**: Builds on the Quasifield and ProjectivePlane definitions from this cycle. Extends proper_quasifield_not_division_ring to the full equivalence.

**Ambition**: grand_challenge

---

### Direction 2: Generalized Hall Construction and Classification at Order 16

**Conjecture**: For every prime power q > 2, the Hall quasifield H(q²) over GF(q²) is a proper quasifield (non-associative), and the number of non-isomorphic non-Desarguesian planes of order q² grows at least linearly with q.

**Test**: Implement the general Hall construction for q = 4 (order 16) and q = 5 (order 25). For each, computationally verify: (a) non-associativity by finding a witness triple, (b) the quasifield axioms hold, (c) the resulting planes are non-isomorphic to each other and to the Desarguesian plane. At order 16, compare with the known count of non-Desarguesian planes (at least 22 known types).

**Impact**: Would establish a parameterized family of non-Desarguesian planes and begin the systematic classification problem. The growth rate of non-isomorphic planes as a function of order is a major open question.

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (hallMul, frobenius3), `Geometry/NonDesarguesian/Theorems.lean` (hall_mul_not_assoc, hall_right_distrib)

**Proof Strategy**: 
1. Define GF(q²) as a degree-2 extension of GF(q) for general prime power q.
2. Define the Frobenius automorphism x ↦ x^q on GF(q²).
3. Define generalized Hall multiplication using the Frobenius twist.
4. Prove non-associativity for q > 2 by constructing explicit witnesses (the element α and 1+α should work universally).
5. For classification, define isomorphism of quasifields and use computational search.

**Domain Bridges**: Algebra (finite fields, field extensions) <-> Geometry (plane classification) <-> Computation (exhaustive search, isomorphism testing)

**Lineage**: Direct extension of the GF(9) Hall quasifield construction from this cycle.

**Ambition**: extension

---

### Direction 3: Collineation Group Bounds for Non-Desarguesian Planes

**Conjecture**: The collineation group of the Hall plane of order q² has order dividing q²(q²-1)²·2 · (degree of Frobenius), which is strictly less than |PGL(3, q²)| = q^6·(q^6-1)·(q^4-1)·(q^2-1) / (q^2-1) for all q > 2.

**Test**: For q = 3 (order 9), compute the collineation group of the Hall plane explicitly. The known answer is |Aut(Hall(9))| = 12·9·8·2 = 1728, which is much less than |PGL(3,9)| = 42,456,960. Verify this computationally and begin formal verification.

**Impact**: Establishes a quantitative symmetry gap between Desarguesian and non-Desarguesian planes. This has implications for coding theory (automorphism groups of associated codes) and design theory (block designs from planes).

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (Collineation, collineationGroupSmaller), `Geometry/NonDesarguesian/Theorems.lean` (pgl3_gf9_order)

**Proof Strategy**: 
1. Enumerate collineations of the Hall plane by characterizing maps that preserve Hall multiplication.
2. Show every collineation must either preserve or swap the base field/extension field components.
3. Count the resulting group using the semidirect product structure.
4. Compare with PGL(3, q²) to establish the strict inequality.

**Domain Bridges**: Group theory (automorphism groups, semidirect products) <-> Geometry (collineations) <-> Algebra (quasifield automorphisms)

**Lineage**: Builds on the Hall quasifield structure and the collineation definition from this cycle.

**Ambition**: extension

---

### Direction 4: Semifields, Moufang Loops, and the Octonion Connection

**Conjecture**: The Hall quasifield is *not* a semifield (it fails left distributivity), but there exist proper semifields (both distributive laws hold, associativity fails) at every prime power order p^n with n ≥ 3. These semifields coordinatize a special class of non-Desarguesian planes where a weaker form of Desargues' theorem (the "little Desargues theorem") holds.

**Test**: Construct the Knuth semifield of order 27 (GF(3)³ with twisted multiplication) and verify: (a) both distributive laws hold, (b) multiplication is non-associative, (c) the associated plane satisfies the little Desargues theorem but not the full Desargues theorem. Compare the multiplicative loop (Q \ {0}, ○) with the Moufang loop structure of octonion units.

**Impact**: Would connect finite geometry to the exceptional structures in algebra (octonions, exceptional Lie algebras) and physics (M-theory, string theory compactifications). The Moufang loop connection is particularly deep: Moufang planes (coordinatized by alternative division algebras) are exactly the non-Desarguesian planes satisfying the little Desargues theorem, and the only finite examples come from Cayley-Dickson algebras over finite fields.

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (Quasifield, IsProperQuasifield), `Algebra/Advanced.lean`

**Proof Strategy**: 
1. Define semifields as quasifields with both distributive laws.
2. Define the Knuth construction: GF(q)³ with (a,b,c) ○ (d,e,f) = (ad + bfσ + ceσ², ae + bd + cfσ, af + be + cd) where σ is the Frobenius.
3. Verify distributivity and non-associativity.
4. Define Moufang identity: a(b(ac)) = ((ab)a)c and verify/refute for various constructions.
5. Connect to octonion multiplication tables over finite fields.

**Domain Bridges**: Algebra (octonions, Moufang loops, semifields) <-> Geometry (Moufang planes, little Desargues) <-> Physics (exceptional structures, M-theory)

**Lineage**: Extends the quasifield framework to semifields, a natural algebraic generalization.

**Ambition**: grand_challenge

---

### Direction 5: Computational Verification of the Prime Power Conjecture at Small Orders

**Conjecture** (Prime Power Conjecture): A finite projective plane of order n exists if and only if n is a prime power.

**Test**: For n = 2, 3, 4, 5, 7, 8, 9: construct explicit projective planes (Desarguesian or Hall) and verify the incidence axioms formally. For n = 6: attempt to prove non-existence using the Bruck-Ryser theorem, which states that if n ≡ 1, 2 (mod 4), then n must be the sum of two squares. Since 6 ≡ 2 (mod 4) and 6 is not a sum of two squares, no plane of order 6 exists.

**Impact**: The Bruck-Ryser theorem eliminates infinitely many orders (6, 14, 21, 22, ...) but leaves many open (10, 12, 15, 18, ...). Formalizing this theorem would be a significant contribution to combinatorics. The famous non-existence of a plane of order 10 (Lam, Thiel, Swiercz, 1989) required massive computation and has never been formally verified.

**Catalog References**: `Geometry/NonDesarguesian/Theorems.lean` (projective_plane_point_count, projective_plane_line_count)

**Proof Strategy**: 
1. State the Bruck-Ryser theorem: if a projective plane of order n exists with n ≡ 1,2 (mod 4), then n is a sum of two squares.
2. Prove using the theory of quadratic forms: the incidence matrix satisfies AA^T = nI + J, and this imposes constraints via the Hasse-Minkowski theorem.
3. Apply to n = 6: 6 mod 4 = 2, and 6 = a² + b² has no integer solution (check: 0²+6 is not a perfect square, 1²+5 is not, 2²+2 is not).
4. For constructive direction: build explicit incidence matrices for small prime power orders.

**Domain Bridges**: Number theory (sums of squares, quadratic forms) <-> Combinatorics (incidence matrices) <-> Geometry (projective planes)

**Lineage**: Builds on the counting theorems and plane axioms from this cycle.

**Ambition**: grand_challenge
