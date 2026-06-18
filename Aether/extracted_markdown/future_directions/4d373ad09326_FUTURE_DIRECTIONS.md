# Future Research Directions: Tropical Min-Plus Cryptography

## Synthesis

This research cycle established three structural results about tropical cryptography that collectively reveal the landscape of TDLP security: power stagnation constrains the effective key space from above, diagonal vulnerability shows that large classes of matrices are insecure, and conjugation invariance proves that naive "scrambling" cannot mask structural weaknesses. These results bridge tropical algebra to order theory (via the lattice meet interpretation of tropical addition), graph theory (via shortest-path duality), and combinatorics (via orbit pigeonhole).

The most promising cross-domain connection is the **tropical algebra ↔ order theory bridge**. The stagnation theorem is essentially a descending chain condition in a product lattice, and the Kleene star is a lattice fixpoint computation. This suggests that Knaster-Tarski-style fixpoint theorems and well-quasi-ordering theory could provide sharp bounds on stagnation indices — connecting tropical cryptography to a completely different area of mathematics (well-quasi-order theory, Higman's lemma, Kruskal's tree theorem).

The direction with highest breakthrough potential is **Direction 1 (Tropical Jordan Normal Form)**, because resolving it would either collapse all TDLP to the diagonal case (ruling out tropical crypto entirely) or identify a precise class of "genuinely hard" matrices (enabling secure parameter selection). This is analogous to how the theory of elliptic curves over finite fields enabled ECC parameter selection.

---

### Direction 1: Tropical Jordan Normal Form and TDLP Reducibility

**Conjecture**: Every n×n tropical matrix A over ℤ ∪ {⊤} is conjugate (via a tropical invertible matrix P) to a matrix in tropical Jordan normal form — a block-diagonal matrix where each block has the form of a tropical "elementary Jordan block" determined by the critical graph of A. Furthermore, the TDLP for A reduces to the TDLP for its tropical Jordan form in polynomial time.

**Test**: Formalize the tropical eigenvalue theory for 3×3 matrices. Compute the critical graph (the subgraph of edges achieving the optimal assignment weight). Verify that 3×3 tropical TDLP can be solved whenever the critical graph has a specific structure (e.g., all strongly connected components have size 1).

**Impact**: If true, this would show that TDLP security depends entirely on the structure of the critical graph. Matrices with simple critical graphs are insecure; matrices with complex critical graphs may be secure. This would provide a precise criterion for secure parameter selection — or prove that tropical crypto is fundamentally insecure.

**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (trop_diagonal_power_entry, trop_conjugation_power_commute), `Cryptography/TropicalPostQuantumPrimitives.lean` (tropicalDet_attained, tropicalSpectralRadius_eq)

**Proof Strategy**: 
1. Define tropical eigenvalues as λ where A ⊗ v = λ ⊗ v for some v ≠ ⊤.
2. Prove that the tropical spectral radius equals the minimum average cycle weight.
3. Define the critical graph as the union of cycles achieving this minimum.
4. Construct the tropical Jordan form from the critical graph structure.
5. Show that conjugation by the basis change matrix reduces TDLP to the Jordan form case.

**Domain Bridges**: Tropical algebra ↔ graph theory (critical graphs), optimization ↔ cryptography (assignment problem determines eigenvalues)

**Lineage**: Extends trop_diagonal_power_entry and trop_conjugation_power_commute from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Stagnation Index Sharp Bounds via Well-Quasi-Ordering

**Conjecture**: For an n×n tropical matrix A with entries in {0, 1, ..., B} ∪ {⊤}, the stagnation index k₀ (the smallest k with A^k = A^(k+1)) satisfies k₀ ≤ n · B. Moreover, this bound is tight: there exist matrices achieving k₀ = n · B.

**Test**: Compute stagnation indices for all 3×3 matrices over {0, 1, 2, ⊤} (3⁹ = 19683 matrices, feasible). Plot the distribution of k₀ values and check whether the maximum equals 3 · 2 = 6. Formalize the upper bound k₀ ≤ nB using the observation that each power decreases some entry by at least 1 until stagnation.

**Impact**: A tight bound on k₀ would give an exact security parameter: for 128-bit security, we need n · B ≥ 2^128, so e.g. n = 16, B = 2^124 or n = 128, B = 2^121. If the bound is not tight, the actual security may be much lower than expected.

**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (trop_power_stagnation, tropKleenePrefix_antitone), `Tropical/Matrix/Algebra.lean`

**Proof Strategy**: 
1. Show that each entry A^k_{ij} is non-increasing in k (monotone convergence from Kleene prefix theory).
2. Show that if A^k ≠ A^(k+1), at least one entry strictly decreases.
3. Each entry can decrease at most B times before reaching 0 or ⊤.
4. There are n² entries, so k₀ ≤ n² · B — or with more care, k₀ ≤ n · B by considering only entries along shortest paths.
5. Construct tight examples using long chain graphs: i → i+1 with weight B.

**Domain Bridges**: Tropical algebra ↔ combinatorics (descending chains in products of bounded linear orders), optimization ↔ security parameter selection

**Lineage**: Directly extends trop_power_stagnation and tropKleenePrefix_antitone from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Fourier Analysis and Quantum Attack Resistance

**Conjecture**: The tropical discrete logarithm problem is resistant to quantum Fourier transform-based attacks because the lack of additive inverses in the tropical semiring prevents the construction of the standard quantum period-finding circuit. Specifically, no quantum algorithm for TDLP can achieve better than Grover's O(√k₀) speedup.

**Test**: Formalize the tropical analog of the quantum Fourier transform. Show that the standard Shor's algorithm step — computing f(x) = A^x and finding the period — cannot be "un-min'd" because min is not invertible. Prove that any quantum algorithm for TDLP requires Ω(k₀^(1/3)) queries (or whatever the true lower bound is).

**Impact**: If tropical TDLP has quantum resistance beyond Grover, this would establish tropical matrices as a genuinely new post-quantum hardness assumption, distinct from lattices, codes, and multivariate polynomials. This would be a major result in post-quantum cryptography.

**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (trop_no_additive_inverse, tropical_dh_master_security), `Cryptography/TropicalPostQuantumPrimitives.lean` (tropical_min_abs_identity — "piecewise-linear defeats QFT")

**Proof Strategy**: 
1. Formalize the abstract quantum query model for TDLP: oracle access to f(x) = A^x.
2. Show that the tropical structure prevents efficient quantum period-finding because:
   a. min is idempotent (min(a,a) = a), breaking the periodicity structure.
   b. No additive inverse prevents constructing interference patterns.
3. Reduce to a lower bound on quantum search in unstructured spaces (BBBV theorem).

**Domain Bridges**: Tropical algebra ↔ quantum computing (query complexity), cryptography ↔ computational complexity (oracle separations)

**Lineage**: Extends trop_no_additive_inverse and the piecewise-linear/QFT connection from the catalog.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Convex Geometry and Encryption Geometry

**Conjecture**: The image of a tropically convex set under tropical matrix multiplication is tropically convex. Furthermore, the "tropical convex hull" of the orbit {G^k · v : k = 0, 1, ..., N} forms a tropical polytope whose combinatorial type encodes the security of the TDLP instance.

**Test**: Define tropical convexity formally (S is tropically convex if for all x, y ∈ S and a, b ∈ ℤ with min(a,b) = 0: min(a + x_i, b + y_i) ∈ S). Prove that tropical matrix multiplication preserves tropical convexity. Compute the tropical polytope for small examples (2×2 matrices, orbit length 10) and characterize its vertices.

**Impact**: This would create a geometric theory of TDLP security, where "hard" instances correspond to tropically convex polytopes with many vertices (high combinatorial complexity), while "easy" instances correspond to simple polytopes (e.g., tropical segments for diagonal matrices).

**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (tropLinComb, tropLinComb_le_left), `Bridges/TropicalScatteringOneWayDuality.lean`, `Tropical/Matrix/Defs.lean`

**Proof Strategy**: 
1. Formalize tropical convexity for subsets of ℤⁿ.
2. Prove that tropical linear maps (v ↦ A ⊗ v) preserve tropical convexity using distributivity: A ⊗ min(a+x, b+y) = min(a + A⊗x, b + A⊗y).
3. Define the tropical polytope of the power orbit.
4. Show that vertex count of the orbit polytope is a lower bound on TDLP hardness.

**Domain Bridges**: Tropical algebra ↔ convex geometry (tropical polytopes), optimization ↔ cryptographic hardness (polytope complexity)

**Lineage**: Extends tropLinComb and tropical_plus_distributes_over_min_Z from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Matrix Factorization Hardness and One-Way Functions

**Conjecture**: The tropical matrix factorization problem — given C = A ⊗ B, recover A and B — is NP-hard even for n×n matrices with entries in {0, 1}. This provides a stronger one-way function candidate than tropical powering, because factorization does not have the eigenvalue attack vulnerability.

**Test**: Reduce a known NP-hard problem (e.g., minimum weight triangulation, or the assignment problem variant) to tropical matrix factorization. Alternatively, show that {0,1}-tropical matrix factorization encodes Boolean satisfiability.

**Impact**: If tropical matrix factorization is NP-hard, it provides a fundamentally different one-way function for post-quantum cryptography — one not based on discrete logarithms or lattice problems. Combined with the existing catalog result `TropicalNPHardness` (which already suggests NP-hardness for related problems), this would establish a complete complexity-theoretic foundation for tropical crypto.

**Catalog References**: `Cryptography/TropicalMinPlusEncryption.lean` (all results), `Cryptography/TropicalPostQuantum.lean` (TropicalNPHardness)

**Proof Strategy**: 
1. Encode 3-SAT clauses as tropical matrix entries.
2. Show that C = A ⊗ B encodes clause satisfaction when A and B have {0,1} entries.
3. The min in tropical multiplication corresponds to existential quantification; the + corresponds to clause weight accumulation.
4. Formalize the reduction and prove its correctness.

**Domain Bridges**: Tropical algebra ↔ computational complexity (NP-hardness), cryptography ↔ combinatorial optimization (assignment problems)

**Lineage**: Builds on TropicalNPHardness from the catalog and extends tropical_dh_master_security from this cycle.

**Ambition**: extension
