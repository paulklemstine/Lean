# Future Directions: Closure–Secret-Sharing Duality

## 1. Monotone Span Program Equivalence Theorem

**Target Theorem:** Every closure-exact access structure over a finite field admits a realization as a monotone span program (MSP), and conversely every MSP induces a closure-exact access structure. The minimal MSP size equals the rank of the canonical dependency presentation.

**New Objects:** Monotone span programs over finite fields formalized as matrices with a target vector; MSP-rank as an invariant of access structures; an explicit functor from `PointedDependencySystem` to MSP data.

**Why This Opens a Field:** Monotone span programs are the algebraic engine behind linear secret-sharing schemes. Connecting them to closure geometry via our duality would unify Beimel–Ishai complexity bounds with matroid-theoretic obstruction theory. This would give a geometric interpretation of MSP width (as closure dimension) and enable new lower bound techniques via flat enumeration. The formalization would be the first machine-verified treatment of MSP theory.

---

## 2. Information-Theoretic Invariant of Closure-Exact Access Structures

**Target Theorem:** Define the *closure entropy* of an access structure as the logarithm of the number of maximal unauthorized flats. Prove that (a) closure entropy is an isomorphism invariant of closure-exact access structures, (b) it bounds the information rate of any secret-sharing scheme realizing the structure, and (c) it equals the rank of the canonical compressed presentation for matroidal access structures.

**New Objects:** Closure entropy functional; information rate lower bounds derived from flat counts; a lattice-theoretic characterization of flat enumeration complexity.

**Why This Opens a Field:** Current information-theoretic bounds on secret-sharing (Capocelli–De Santis–Gargano–Vaccaro) use ad hoc entropy arguments. A closure-geometric invariant would provide a structural explanation for why certain access structures require large shares, connecting combinatorial geometry to Shannon theory. This could resolve open questions about the gap between linear and non-linear secret-sharing complexity.

---

## 3. Categorical Duality Between Finite Closure-Exact Access Structures and Pointed Idempotent Algebras

**Target Theorem:** Construct a contravariant equivalence of categories between:
- **ClosAcc**: finite closure-exact access structures with authorization-preserving morphisms,
- **PtDepAlg**: pointed finitely generated idempotent closure algebras with span-preserving homomorphisms.

The functors are the canonical constructions `dependencyFromClosure` and `closureFromDependency`, extended to morphisms. Prove that the unit and counit are natural isomorphisms on authorization predicates.

**New Objects:** Category of access structures; category of pointed closure algebras; natural transformations witnessing the equivalence; derived invariants (automorphism groups, Morita equivalence classes).

**Why This Opens a Field:** This would be the first categorical duality theorem in secret-sharing theory, analogous to Stone duality for Boolean algebras or Pontryagin duality for abelian groups. It would enable transfer of categorical techniques (limits, colimits, adjunctions) to cryptographic protocol design, and connect access structure classification to universal algebra.

---

## 4. Tropical Linear Secret-Sharing Semantics

**Target Theorem:** Define tropical (min-plus) secret-sharing: replace field operations with the tropical semiring (ℝ ∪ {∞}, min, +). Prove that tropical secret-sharing schemes correspond to *convex closure operators* on participant configurations, and that the authorized sets of a tropical scheme form a closure-exact access structure whose circuits are the minimal tropical dependencies.

**New Objects:** Tropical span operator; tropical pointed dependency systems; tropical rank as access-structure complexity measure; tropical secret-circuit characterization.

**Why This Opens a Field:** Tropical geometry has revolutionized algebraic geometry and optimization but has not been applied to cryptography. Tropical secret-sharing would connect threshold cryptography to tropical convexity, potentially yielding schemes with better computational properties (min-plus operations are cheaper than field arithmetic). The circuit characterization would link tropical Grassmannians to access structure classification, opening a bridge between geometric combinatorics and applied cryptography.

---

## 5. Complexity Classification of Canonical Compression and Minimal Authorization Extraction

**Target Theorem:** Prove that:
- Computing the set of minimal authorized sets from a closure oracle is in `FP^NP` and is `FP^NP`-complete under polynomial-time Turing reductions.
- Determining whether a given access structure is closure-exact is coNP-complete.
- The canonical compressed presentation can be computed in time polynomial in the number of minimal authorized sets.

Formalize the complexity classes and reductions, and provide certified polynomial-time algorithms for the tractable cases.

**New Objects:** Complexity classes for access-structure problems; oracle Turing machines for closure queries; reduction from SAT to non-closure-exactness; polynomial-time canonical compression algorithm with correctness proof.

**Why This Opens a Field:** Complexity classification of cryptographic primitives is essential for practical deployment. Understanding which access-structure operations are tractable enables efficient policy compilation in attribute-based encryption. The hardness results would explain why general secret-sharing scheme optimization is intractable, while the tractable cases (matroidal, threshold) have polynomial algorithms. This connects computational complexity to closure geometry in a new way.
