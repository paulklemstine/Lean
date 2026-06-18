# Future Directions: Non-Desarguesian Geometry

## Synthesis

This research cycle established the foundational algebraic theory of
non-Desarguesian projective planes through quasifields. The key discovery is the
precise algebraic characterization: the left nucleus of a quasifield is closed
under multiplication (always) and under addition/negation (when right
distributivity holds), and the nucleus being the full quasifield is equivalent
to associativity. Combined with the counting theorems (n² + n + 1 points/lines)
and the dilation obstruction theorem, this provides a complete chain from
algebraic non-associativity to geometric non-Desarguesian behavior.

The most promising cross-domain connection is between quasifield nuclei and
tropical algebra. The nucleus structure — elements that "behave like a field"
within a non-associative context — parallels the role of the "tropical
backbone" in tropical geometry, where min-plus operations create analogous
asymmetries. The existing catalog results on tropical Langlands
(`Tropical/TropicalLanglandsGL1.lean`) and tropical Satake transforms
(`Tropical/Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃.lean`) provide
a foundation for exploring this bridge. The highest breakthrough potential lies
in Direction 1 (Tropical Non-Desarguesian Planes), which could establish that
non-associativity phenomena in projective geometry have tropical analogues.

The finite plane counting results connect naturally to the combinatorial
methods in `Tropical/AdditiveCombinatorics/Core.lean`, and the collineation
group analysis could benefit from the group-theoretic machinery used in
`Cryptography/BerggrenGroupoidOrbit.lean`.

---

### Direction 1: Tropical Non-Desarguesian Planes

**Conjecture**: There exists a natural "tropical quasifield" — a min-plus
algebra with modified multiplication — that coordinatizes a tropical projective
plane where a tropicalized Desargues property fails. Specifically, define
tropical multiplication ⊗ on ℝ ∪ {∞} by modifying the standard tropical
product (a ⊗ b = a + b) with a nonlinear correction term φ(a,b), and show that
the resulting ternary ring coordinatizes a plane where tropical collinearity
of perspective triangle intersections can fail.

**Test**: Compute the tropical associator [a,b,c] = (a ⊗ b) ⊗ c − a ⊗ (b ⊗ c)
for the modified tropical multiplication on a finite grid of values. If the
associator is identically zero, the conjecture fails. If nonzero associators
exist, construct the explicit Desargues-failing configuration.

**Impact**: If true, this opens a new field of "tropical non-Desarguesian
geometry" connecting non-associative algebra, tropical geometry, and
combinatorial optimization. If false, it reveals that tropical algebra is
inherently more rigid than classical algebra, which itself is an interesting
structural result.

**Catalog References**: `FINAL/Tropical/TropicalLanglandsGL1.lean`,
`FINAL/Tropical/Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃.lean`,
`Geometry/NonDesarguesian/Defs.lean`, `Geometry/NonDesarguesian/Theorems.lean`

**Proof Strategy**: (1) Define tropical quasifield axioms as modifications of
the standard quasifield axioms with min/max replacing addition. (2) Verify the
slope bijectivity condition in the tropical setting. (3) Construct the tropical
Desargues configuration explicitly. (4) Use the tropical associator to identify
the failing configuration. Key lemma: show tropical slope_bijective holds iff
the correction function φ satisfies certain convexity conditions.

**Domain Bridges**: Non-Desarguesian Geometry ↔ Tropical Algebra ↔
Combinatorial Optimization

**Lineage**: Builds on this cycle's quasifield theory and the existing tropical
Langlands infrastructure.

**Ambition**: grand_challenge

---

### Direction 2: Explicit Hall Quasifield Construction and Verification

**Conjecture**: The Hall quasifield over GF(q²) for q = 3 (order 9) has left
nucleus isomorphic to GF(3) and full nucleus also GF(3), with exactly 6
non-identity collineations in its translation complement, compared to
|PGL(3,9)| = 9³(9³-1)(9²-1) = 42456960 for the Desarguesian plane of the
same order. The ratio |Coll(Hall)|/|PGL(3,9)| < 1/1000.

**Test**: Construct the Hall quasifield multiplication table for GF(9) = GF(3²)
by choosing an irreducible polynomial t² + 1 over GF(3) and defining the
modified multiplication. Verify: (1) the multiplication is non-associative by
finding an explicit triple (a,b,c) with nonzero associator; (2) the left
nucleus has exactly 3 elements; (3) the collineation count.

**Impact**: This would provide the first machine-verified explicit
non-Desarguesian plane, with verified algebraic invariants. The nucleus
computation would confirm that the Hall plane is "maximally non-associative"
in a precise sense.

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (Quasifield,
leftNucleus, fullNucleus), `Geometry/NonDesarguesian/Theorems.lean`
(leftNucleus_mul_closed, nucleus_proper_of_nonassoc)

**Proof Strategy**: (1) Define GF(9) as ZMod 3 × ZMod 3 with polynomial
arithmetic. (2) Define Hall multiplication using the irreducible polynomial.
(3) Verify quasifield axioms by exhaustive computation (small enough for
native_decide on 9 elements). (4) Compute nucleus by checking all 81 triples.
(5) Count collineations by enumerating incidence-preserving bijections.

**Domain Bridges**: Finite Algebra ↔ Computational Verification ↔ Projective
Geometry

**Lineage**: Direct extension of this cycle's quasifield theory.

**Ambition**: extension

---

### Direction 3: Nucleus Growth Rate and the Wedderburn Spectrum

**Conjecture**: For Hall quasifields over GF(p^(2k)) with p prime and k ≥ 1,
the left nucleus has order exactly p^k, and the full nucleus has order p^k if
p > 2 and order 2^(k+1) if p = 2. This gives a "nucleus growth rate" of
|N_ℓ|/|Q| = p^(-k), which decreases exponentially with k, meaning larger Hall
quasifields are "more non-associative."

**Test**: Compute nucleus sizes for Hall quasifields of orders 9, 16, 25, 27,
49, 64 (i.e., p^(2k) for small p, k) and fit the growth rate. If any computed
nucleus size deviates from p^k, the conjecture is falsified.

**Impact**: If true, this establishes a quantitative measure of
"non-Desarguesian-ness" that could be used to classify planes by their
algebraic deficiency. The exponential decay suggests that large Hall planes
are "far" from Desarguesian in a metric sense, which could have implications
for coding theory (distance properties of associated codes).

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (leftNucleus,
fullNucleus, qfCenter), `Geometry/NonDesarguesian/Theorems.lean`
(leftNucleus_mul_closed, assoc_of_nucleus_full)

**Proof Strategy**: (1) Characterize the nucleus of a Hall quasifield
algebraically: show n ∈ N_ℓ iff n lies in the base field GF(p^k) ⊂ GF(p^(2k)).
(2) This reduces to showing (n·a)·b = n·(a·b) iff n commutes with the Frobenius
automorphism x ↦ x^(p^k). (3) Use the explicit Hall multiplication formula
to verify this characterization. (4) Count elements fixed by Frobenius using
standard Galois theory.

**Domain Bridges**: Finite Fields ↔ Galois Theory ↔ Projective Geometry ↔
Coding Theory

**Lineage**: Extends Direction 2 from a single example to a parametric family.

**Ambition**: extension

---

### Direction 4: Non-Desarguesian Planes and Error-Correcting Codes

**Conjecture**: The incidence matrix of a non-Desarguesian plane of order q
generates a linear code with minimum distance d satisfying d ≥ q - √q + 1,
strictly greater than the minimum distance of codes from Desarguesian planes
of the same order for certain specific q values (e.g., q = 9).

**Test**: Compute the incidence matrices for the Desarguesian plane PG(2,9) and
the Hall plane of order 9. Compute minimum distances of their row-span codes
over GF(3). Compare.

**Impact**: If true, non-Desarguesian planes would provide a systematic source
of "better" error-correcting codes, with immediate applications to
communication theory. If false, the equality of distances would suggest a
deep invariance theorem connecting Desarguesian and non-Desarguesian planes
at the code-theoretic level.

**Catalog References**: `Geometry/NonDesarguesian/Theorems.lean`
(finite_plane_point_count, finite_plane_line_count),
`Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**: (1) Construct incidence matrices explicitly using the
quasifield plane construction. (2) Compute the p-rank (rank over GF(p)) using
standard linear algebra. (3) Apply the BCH-like bound for plane codes. (4)
Compare with known results for Desarguesian planes. Key insight: the p-rank of
a plane's incidence matrix is determined by its geometric properties, and
non-Desarguesian planes often have different p-ranks.

**Domain Bridges**: Projective Geometry ↔ Coding Theory ↔ Cryptography

**Lineage**: Builds on this cycle's finite plane theory and the existing
cryptography infrastructure.

**Ambition**: grand_challenge

---

### Direction 5: Automated Classification of Small Non-Desarguesian Planes

**Conjecture**: At order 16 (= 2⁴), there are exactly 22 non-isomorphic
translation planes, including the Desarguesian plane, and they can be
distinguished by a computable invariant triple (|N_ℓ|, |N_μ|, |N_ρ|) of
nucleus sizes in all but 3 cases (where finer invariants are needed).

**Test**: Enumerate all quasifields of order 16 up to isotopism by systematic
search (feasible since 16⁴ = 65536 multiplication tables to check). Compute
nucleus sizes for each. Verify the count of 22 agrees with the known
classification.

**Impact**: Machine-verified classification of planes at order 16 would be a
significant computational mathematics result. The nucleus triple as a near-
complete invariant would provide a practical tool for plane identification.

**Catalog References**: `Geometry/NonDesarguesian/Defs.lean` (leftNucleus,
middleNucleus, rightNucleus), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: (1) Implement quasifield axiom verification as a decidable
predicate. (2) Use symmetry reduction (isotopism classes) to reduce the search
space. (3) For each valid quasifield, compute the three nucleus sizes. (4)
Group by invariant triple and verify isomorphism/non-isomorphism within groups.
(5) Cross-reference with Dembowski's classification and the Handbook of
Combinatorial Designs.

**Domain Bridges**: Computational Algebra ↔ Combinatorial Enumeration ↔
Projective Geometry

**Lineage**: Extends Direction 2 from a single family to systematic
classification.

**Ambition**: extension
