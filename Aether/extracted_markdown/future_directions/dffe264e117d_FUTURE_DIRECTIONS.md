# Future Research Directions: Tropical Cryptography and Beyond

## Synthesis

This cycle established that the Tropical Discrete Logarithm Problem (TDLP) has five formally verified structural weaknesses: walk concatenation subadditivity, eigenvalue linearity, graph-matrix duality, orbit periodicity, and Kleene star convergence. Together, these show that the min-plus semiring provides too much algebraic structure for cryptographic hardness — the very properties that make tropical algebra useful for optimization (shortest paths, dynamic programming) simultaneously provide polynomial-time attacks on the TDLP.

The most promising cross-domain connection is the **walk concatenation ↔ subadditivity ↔ Fekete's lemma** chain. This connects graph theory (path decomposition), number theory (subadditive sequences), and analysis (convergence of normalized sequences) to cryptanalysis. The subadditivity theorem `trop_power_diag_subadditive` is not specific to tropical matrices — it holds in any idempotent semiring with a matrix algebra, suggesting a general "semiring cryptanalysis" framework.

The highest breakthrough potential lies in Direction 1 (Tropical Polynomial Cryptography), which attempts to *fix* the weaknesses we identified by moving from linear to polynomial tropical operations. If the eigenvalue attack can be shown to fail for tropical polynomial systems, this could rescue tropical cryptography as a post-quantum candidate.

---

### Direction 1: Tropical Polynomial Cryptography — Beyond Matrix Powers

**Conjecture**: The tropical polynomial evaluation problem (TPEP) — given a tropical polynomial f(x₁, ..., x_n) = ⊕_α (c_α ⊗ x₁^{a₁} ⊗ ... ⊗ x_n^{a_n}) and a target value y, find x such that f(x) = y — is NP-hard for polynomials of degree ≥ 3, even when the evaluation direction f → y is polynomial-time.

**Test**: Formalize tropical polynomials in Lean 4 as finite sums of tropical monomials. Prove that tropical polynomial evaluation is polynomial-time. Then attempt to prove (or find a polynomial-time algorithm for) inversion. If a reduction from 3-SAT or SUBSET-SUM to TPEP can be constructed, formalizing the reduction would establish hardness.

**Impact**: If true, this would provide a new one-way function candidate that avoids all five weaknesses of the matrix-power TDLP: (1) polynomial evaluation is non-commutative in a stronger sense, (2) there are no clean eigenvalue invariants, (3) the graph interpretation breaks down for degree > 1, (4) the "orbit" is not a monoid, and (5) there is no Kleene star analog.

**Catalog References**: `Cryptography/TropicalPostQuantum.lean` (tropical matrix algebra), `Tropical/FormulaDefinability.lean` (tropical formula theory)

**Proof Strategy**: Define tropical polynomial rings formally. Prove evaluation is polynomial. For hardness, try reducing SHORTEST-PATH-WITH-FORBIDDEN-PATTERNS (known NP-hard) to tropical polynomial inversion — the forbidden patterns correspond to monomial constraints.

**Domain Bridges**: Tropical geometry (Newton polytopes) ↔ Optimization (piecewise-linear functions) ↔ Cryptography (one-way functions)

**Lineage**: Builds on `trop_diag_attack_recovers_k` (this cycle) which shows linear tropical functions are invertible. The question is whether nonlinear tropical functions escape this.

**Ambition**: grand_challenge

---

### Direction 2: Subadditive Cryptanalysis Framework — General Semiring Attacks

**Conjecture**: For any idempotent semiring (S, ⊕, ⊗) with a matrix algebra, the diagonal entries of matrix powers satisfy subadditivity: (A^{m+k})_{ii} ≤ (A^m)_{ii} ⊗ (A^k)_{ii}. This provides a universal attack template: any cryptosystem based on matrix powers in an idempotent semiring leaks the exponent through diagonal invariants.

**Test**: Formalize the subadditivity theorem for arbitrary `CommSemiring` with `Tropical`-like addition (idempotent, where ⊕ is the lattice meet). Prove it for the max-plus semiring, the Boolean semiring (AND/OR), and the (min,max) semiring. Then check whether the attack extends to non-idempotent semirings like the nonnegative reals.

**Impact**: A general subadditive cryptanalysis theorem would provide a systematic way to evaluate ANY algebraic cryptographic proposal based on semiring matrix powers. It would unify the known attacks on tropical DLP, max-plus DLP, and similar problems into a single algebraic framework.

**Catalog References**: `Bridges/MinPlusVerificationCore.lean` (min-plus verification), `Tropical/TropicalSemiring.lean` (tropical semiring axioms)

**Proof Strategy**: Abstract the proof of `trop_power_diag_subadditive` to work over any `OrderedSemiring` where addition is idempotent. The key step (`Finset.inf_le`) generalizes to any finset infimum over a lattice.

**Domain Bridges**: Universal algebra (variety theory) ↔ Cryptanalysis (structural attacks) ↔ Order theory (lattice semirings)

**Lineage**: Directly extends `trop_power_diag_subadditive` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Spectral Theory — Eigenvalue Multiplicity and Jordan Forms

**Conjecture**: Every n×n tropical matrix has a unique tropical eigenvalue λ (the minimum mean cycle weight), and the tropical Jordan normal form has at most n Jordan blocks. The "tropical Jordan decomposition" A = U ⊗ J ⊗ U^{(-1)} (where J is the tropical Jordan form and U^{(-1)} is the tropical matrix inverse when it exists) provides a complete description of the power orbit: A^k is determined by J^k, which has a simple closed form.

**Test**: Formalize the tropical eigenvalue as λ(A) = min_{k=1}^n tr(A^k)/k. Prove this minimum is achieved at some k ≤ n. Then show λ(A^m) = m · λ(A) for all m, formalizing the eigenvalue scaling that underlies the TDLP attack. For the Jordan form, start with 2×2 matrices where the classification is tractable.

**Impact**: A complete tropical spectral theory would precisely characterize which matrices have hard TDLPs (those with degenerate eigenvalues) versus easy TDLPs (generic matrices). It would also connect to the Perron-Frobenius theory for nonnegative matrices via the "Maslov dequantization" correspondence.

**Catalog References**: `Tropical/PerronFrobenius.lean` (tropical Perron-Frobenius), `Tropical/SpectralTheory.lean` (tropical spectral theory)

**Proof Strategy**: Prove the min-mean cycle weight characterization using the subadditivity of diagonal entries (from this cycle). The convergence lim tr(A^k)/k = inf tr(A^k)/k follows from Fekete's lemma, which needs formalization. For the Jordan form, use the tropical rank (minimum number of tropical monomials to represent each entry).

**Domain Bridges**: Linear algebra (Jordan theory) ↔ Graph theory (critical graphs) ↔ Dynamical systems (Lyapunov exponents) ↔ Cryptography (eigenvalue attacks)

**Lineage**: Builds on `trop_power_diag_subadditive` and `trop_diag_power_entry` from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Matrix Factorization Hardness — NP-Completeness Landscape

**Conjecture**: While the TDLP (recover k from A, A^k) is polynomial-time solvable, the tropical matrix *factorization* problem (recover A and B from C = A ⊗ B, with constraints on the entries of A and B) is NP-hard. The hardness boundary is precisely at the transition from "structured" products (powers of a single matrix) to "unstructured" products (arbitrary factors).

**Test**: Prove a polynomial-time reduction from 3-PARTITION to tropical matrix factorization with entry bounds. The reduction should map each 3-PARTITION instance to a tropical matrix C such that C = A ⊗ B (with bounded entries) iff the 3-PARTITION instance has a solution.

**Impact**: This would establish a precise hardness landscape for tropical linear algebra problems, showing that cryptographic hardness IS available in tropical algebra — just not in the form originally proposed. It would suggest new tropical cryptographic primitives based on factorization rather than discrete logarithm.

**Catalog References**: `Cryptography/TropicalPostQuantum.lean` (NP-hardness claims), `Tropical/MatrixFactorizationHardnessTransfer.lean` (existing hardness results)

**Proof Strategy**: Use the known NP-hardness of the minimum-weight perfect matching problem in bipartite graphs with integer weights. A tropical matrix factorization C = A ⊗ B encodes a weighted bipartite graph matching problem via the entries of A and B.

**Domain Bridges**: Computational complexity (NP-hardness) ↔ Tropical algebra (matrix factorization) ↔ Combinatorics (matching theory) ↔ Cryptography (one-way functions)

**Lineage**: Builds on `TropicalNPHardness` from the Catalog (existing hardness barriers).

**Ambition**: extension

---

### Direction 5: Tropical Cryptography and Quantum Resistance — Grover Lower Bounds

**Conjecture**: Even with Grover's quantum speedup (quadratic speedup for unstructured search), the tropical matrix factorization problem remains super-polynomial for matrices of size n ≥ 20 with entries bounded by B = 2^{128}. Specifically, the quantum query complexity of tropical matrix factorization is Ω(B^{n/4}), which exceeds 2^{128} for these parameters.

**Test**: Formalize the quantum query complexity lower bound using the polynomial method (Beals et al.). Show that any quantum algorithm solving tropical matrix factorization requires Ω(√(B^{n²/2})) queries (by reduction to unstructured search over the space of factor matrices). For n = 20, B = 2^8: query complexity ≥ 2^{80}, which is post-quantum secure at NIST Level 1.

**Impact**: If verified, this would establish tropical matrix factorization (NOT tropical DLP) as a genuinely post-quantum hard problem, rescuing the original motivation of tropical cryptography while replacing the broken TDLP primitive with a harder one.

**Catalog References**: `Cryptography/TropicalPostQuantum.lean` (post-quantum security parameters), `Cryptography/LeftoverHash.lean` (information-theoretic security)

**Proof Strategy**: Formalize the quantum query complexity model. Prove the polynomial method lower bound for search over tropical matrix spaces. The key technical step is bounding the degree of any Boolean function that detects a valid factorization.

**Domain Bridges**: Quantum computing (query complexity) ↔ Tropical algebra (factorization) ↔ Cryptography (post-quantum security)

**Lineage**: Builds on `security_128bit_params` and `tropical_key_space_lower_bound` from `Cryptography/TropicalPostQuantum.lean`.

**Ambition**: extension
