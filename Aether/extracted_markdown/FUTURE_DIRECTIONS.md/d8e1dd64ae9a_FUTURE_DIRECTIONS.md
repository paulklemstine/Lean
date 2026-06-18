# Future Directions: Non-Desarguesian Geometry

## Synthesis

This research cycle established the algebraic foundations of non-Desarguesian plane theory through two complementary frameworks: **presemifields with associator defect** (measuring algebraic non-associativity) and **spread systems with geometric defect** (measuring geometric deviation from Desargues' theorem). The central discovery is the **defect-symmetry duality** — a quantitative trade-off between how non-Desarguesian a plane is and how many symmetries it can have. This connects algebra (nuclei, associators), geometry (spreads, collineation groups), and combinatorics (plane enumeration) in a single formal framework.

The most promising cross-domain connection is between the **associator defect spectrum** and **coding theory**. Presemifields of order q^n give rise to MRD (maximum rank-distance) codes, and the defect spectrum may encode coding-theoretic parameters like minimum distance and error-correction capability. This bridge could yield new constructions of optimal codes from defect-theoretic principles.

The direction with highest breakthrough potential is **Direction 2** (Ostrom-Wagner formalization), because it would provide a complete characterization of Desarguesian planes within the formal system, enabling automated classification of finite planes by their algebraic properties. The defect spectrum could serve as a machine-computable invariant for this classification.

---

### Direction 1: Tropical Associators and Non-Desarguesian Tropical Geometry

**Conjecture**: The tropical semiring (ℝ ∪ {∞}, min, +) can be extended to a "tropical presemifield" where the associator [a,b,c] = (a+b)+c − a+(b+c) is trivially zero (since + is associative), but a *deformed* tropical multiplication ⊗_f with f a non-linear convex function produces a non-trivial tropical associator. The resulting "tropical non-Desarguesian plane" has defect spectrum determined by the convexity defect of f.

**Test**: Define ⊗_f : ℝ² → ℝ by a ⊗_f b = min(a + b, f(a) + f(b)) for a convex function f. Compute the associator [a, b, c]_f = (a ⊗_f b) ⊗_f c − a ⊗_f (b ⊗_f c) for specific f (e.g., f(x) = x² or f(x) = |x|). Check whether the defect density converges to a value determined by the second derivative of f.

**Impact**: If true, this would bridge non-Desarguesian geometry with tropical geometry, providing new constructions of tropical varieties with prescribed incidence properties. It could also give combinatorial models of non-Desarguesian planes that are more amenable to computation than algebraic ones.

**Catalog References**: `Tropical/TropicalLanglandsGL1.lean`, `Tropical/PrimePowerAmplification.lean`

**Proof Strategy**: (1) Define the deformed tropical multiplication formally. (2) Compute the associator as a piecewise linear function. (3) Use the theory of piecewise linear functions to classify the defect. (4) Connect to the Spread Defect Classification via a discretization argument.

**Domain Bridges**: Tropical Geometry <-> Non-Desarguesian Planes <-> Combinatorial Optimization

**Lineage**: Builds on the presemifield formalization from this cycle and tropical semiring constructions in the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Formal Ostrom-Wagner Theorem and Automatic Plane Classification

**Conjecture**: The Ostrom-Wagner theorem — a finite projective plane is Desarguesian if and only if its collineation group acts doubly transitively on points — can be formalized in Lean 4 using the presemifield and spread system infrastructure from this cycle. Moreover, the defect spectrum provides a *computable* certificate that a given plane is non-Desarguesian, without needing to test all Desargues configurations.

**Test**: (1) State the Ostrom-Wagner theorem formally using the IncidencePlane structure. (2) Prove one direction: if the plane is Desarguesian, then its collineation group acts doubly transitively (this follows from the transitivity of PGL). (3) For the converse, prove that double transitivity forces the nucleus to equal the entire presemifield (hence associativity, hence Desarguesian).

**Impact**: This would provide the first formally verified version of one of the central theorems of finite geometry. It would also enable automated classification: given a finite incidence structure, compute its collineation group and defect spectrum, and determine whether it is Desarguesian in polynomial time.

**Catalog References**: `Geometry/NonDesarguesianPlanes/Core.lean`, `Geometry/NonDesarguesianPlanes/HallPlane.lean`

**Proof Strategy**: (1) Formalize the notion of k-transitivity for collineation groups. (2) Prove that PGL(3,q) is doubly transitive on the points of PG(2,q). (3) Use the Lenz-Barlotti classification to show that doubly transitive planes have maximal Lenz-Barlotti class. (4) Apply the Albert-Knuth theorem to conclude that maximal Lenz-Barlotti class implies Desarguesian.

**Domain Bridges**: Group Theory <-> Incidence Geometry <-> Algebra (Presemifields)

**Lineage**: Directly extends the presemifield and collineation bound results from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Defect Spectra of Knuth Semifields and the Isotopy Problem

**Conjecture**: Two finite semifields that are isotopic (related by a triple of linear bijections) have the same defect density but potentially different defect *spectra* (the multiset of associator values). Conversely, semifields with identical defect spectra are isotopic.

**Test**: (1) Construct the six Knuth derivatives of the Hall quasifield of order 9. (2) Compute the defect spectrum for each. (3) Check whether isotopic semifields have identical spectra and whether non-isotopic semifields have different spectra.

**Impact**: If the defect spectrum is a complete isotopy invariant, it would solve the classification problem for semifield planes up to isotopy — one of the major open problems in finite geometry. Even partial results would advance the understanding of semifield isotopy.

**Catalog References**: `Geometry/NonDesarguesianPlanes/Core.lean` (AssociatorDefectSpectrum)

**Proof Strategy**: (1) Formalize Knuth's six operations on the multiplication tensor. (2) Show that each operation transforms the associator in a controlled way. (3) Compute the effect on the defect spectrum. (4) Use counting arguments to distinguish non-isotopic semifields.

**Domain Bridges**: Multilinear Algebra <-> Finite Geometry <-> Combinatorics

**Lineage**: Extends the associator defect spectrum from this cycle to a classification tool.

**Ambition**: extension

---

### Direction 4: MRD Codes from Presemifield Defect Spectra

**Conjecture**: The defect density of a finite presemifield S of order q^n determines the minimum rank distance of the associated linearized polynomial code. Specifically, if S has defect density δ, then the minimum rank distance d satisfies d = n − ⌊(1−δ) · n⌋.

**Test**: (1) Construct the linearized polynomial code associated to the Hall quasifield of order q² (i.e., n = 2). (2) Compute its minimum rank distance. (3) Compare with the prediction d = 2 − ⌊(1−δ)·2⌋ where δ ≈ 0.296 for q = 3, giving d = 2 − 1 = 1... This needs refinement. Try: d = n·δ rounded appropriately.

**Impact**: Connecting presemifield invariants to coding theory parameters would provide new constructions of optimal MRD codes (used in network coding and space-time coding) and new proofs of known code properties.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean`, `Geometry/NonDesarguesianPlanes/Core.lean`

**Proof Strategy**: (1) Formalize the connection between presemifields and linearized polynomials. (2) Express the rank distance in terms of the kernel of the difference of two linearized polynomials. (3) Relate kernel dimensions to associator vanishing. (4) Derive the rank distance formula.

**Domain Bridges**: Coding Theory <-> Finite Geometry <-> Algebra

**Lineage**: Extends the presemifield theory to applications in error-correcting codes.

**Ambition**: extension

---

### Direction 5: Computational Enumeration of Non-Desarguesian Planes of Order 16

**Conjecture**: There exist at least 15 non-isomorphic non-Desarguesian planes of order 16, each with a distinct defect spectrum (when coordinatized by their associated presemifield/quasifield). The defect spectra form a partially ordered set under refinement.

**Test**: (1) Enumerate all known quasifields of order 16. (2) Compute the defect spectrum for each. (3) Check distinctness and partial ordering. (4) Compare with the known classification (there are exactly 22 translation planes of order 16, of which 21 are non-Desarguesian).

**Impact**: This would demonstrate the defect spectrum as a practical computational tool for plane classification, and potentially discover new invariant relationships between the known planes of order 16.

**Catalog References**: `Geometry/NonDesarguesianPlanes/HallPlane.lean` (SpreadSystem)

**Proof Strategy**: (1) Implement the quasifield constructions computationally. (2) Use the algorithms from algorithms.py to compute defect spectra. (3) Verify key results formally in Lean 4. (4) Present the classification as a table with proved invariant relationships.

**Domain Bridges**: Computational Mathematics <-> Finite Geometry <-> Classification Theory

**Lineage**: Extends the spread defect classification from this cycle to a concrete enumeration problem.

**Ambition**: extension
