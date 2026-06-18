# Future Directions: Character-Theoretic Rigidity for Symmetric Groups

## Synthesis

The formal verification of character-theoretic rigidity for S₃ — establishing that the character table is uniquely forced by orthogonality, integrality, and degree constraints — opens a systematic path toward machine-verified representation theory for all symmetric groups. The key insight is that the trace–fixed-point identity (Theorem 1) provides a computational bridge between combinatorics and algebra, while the spectral cross-domain theorem connects to graph theory and random walks. The five directions below extend this foundation in complementary ways: Direction 1 generalizes the irreducibility certificate from S₃ to all S_n; Direction 2 connects to combinatorics through Young tableaux; Direction 3 bridges to number theory via modular representations; Direction 4 tackles Burnside's theorem as a capstone application; Direction 5 pushes the spectral connection toward certified algorithms for expander graphs.

---

## Direction 1: Standard Character Irreducibility for All S_n

**Conjecture:** For all n ≥ 3, the standard character χ_std of S_n satisfies ⟨χ_std, χ_std⟩ = 1, certifying irreducibility without case-by-case enumeration.

**Test:** Compute ⟨χ_std, χ_std⟩ = (1/n!) Σ_{σ ∈ S_n} (fix(σ) - 1)² for n = 3, 4, ..., 10 using the cycle index polynomial. The sum Σ (fix(σ) - 1)² = Σ fix(σ)² - 2·Σ fix(σ) + n! = (2·n! - 2·n! + n!) = n! by known identities for moments of the fixed-point distribution (Σ fix² = 2·n! for n ≥ 2). A mismatch for any n ≤ 10 would disprove the conjecture. A computational verification for n ≤ 10 would strongly support it.

**Impact:** This would provide a uniform irreducibility certificate for the standard representation, the most fundamental non-trivial representation of S_n, without relying on Young tableau machinery.

**Catalog References:** `Algebra/RepresentationTheory/Symmetric/PermutationRep.lean` (char_perm_rep_eq_fixedPoints), `Algebra/RepresentationTheory/Symmetric/S3Rigidity.lean` (s3_standard_inner_self).

**Proof Strategy:** Use the identity Σ_{σ ∈ S_n} fix(σ)^k = Σ_{j=0}^{k} S(k,j) · n! where S(k,j) are Stirling numbers of the second kind. For k=2, this gives Σ fix² = S(2,0)·n! + S(2,1)·n! + S(2,2)·n! = 0 + n! + n! = 2n! for n ≥ 2. Then ⟨χ_std, χ_std⟩ = (1/n!)(2n! - 2n! + n!) = 1.

**Domain Bridges:** Combinatorics (Stirling numbers, cycle index), probability (fixed-point distribution).

**Lineage:** Extends s3_standard_inner_self to all n. Foundation for Direction 4.

**Ambition:** ★★★☆☆ — The combinatorial identity is well-known; the challenge is formalizing Stirling number machinery in Lean.

---

## Direction 2: Hook Length Formula and Young Tableau Correspondence

**Conjecture:** The number of standard Young tableaux of shape λ ⊢ n, computed by the hook length formula dim(λ) = n! / Π_{(i,j) ∈ λ} h(i,j), gives the degree of the corresponding irreducible representation of S_n. For n ≤ 8, every irreducible character degree matches this formula exactly.

**Test:** For each partition λ of n (3 ≤ n ≤ 8), compute dim(λ) via the hook length formula and compare with the first column of the character table (computed by Murnaghan–Nakayama or Dixon's algorithm). Any discrepancy falsifies the conjecture (which is actually a theorem, but formalization may reveal subtleties).

**Impact:** Provides a combinatorial algorithm for computing character degrees, connecting representation theory to the theory of symmetric functions and Schur polynomials.

**Catalog References:** `Algebra/RepresentationTheory/Symmetric/StandardRep.lean` (standardCharFn_degree).

**Proof Strategy:** Formalize partitions, Young diagrams, and the hook length formula. Use the Robinson–Schensted correspondence to biject permutations with pairs of standard Young tableaux. Derive the character degree as the number of tableaux of a given shape.

**Domain Bridges:** Combinatorics (partitions, tableaux), algebraic geometry (Schur functors), probability (Plancherel measure).

**Lineage:** Extends standardCharFn_degree to all irreducible representations. Enables computation of full character tables.

**Ambition:** ★★★★☆ — Requires substantial new Lean infrastructure for partitions and tableaux, but the mathematics is classical.

---

## Direction 3: Modular Representation Theory — Decomposition Numbers for S_n in Characteristic p

**Conjecture:** For S₅ in characteristic 5, the decomposition matrix (relating ordinary and modular irreducible representations) has the specific block structure predicted by the Nakayama conjecture (now theorem): irreducible representations with partitions in the same p-core block have the same block of the decomposition matrix.

**Test:** Compute the 5-modular decomposition matrix of S₅ numerically (reduce the 7×7 character table modulo 5 and find the Brauer characters). Compare with the block structure predicted by 5-cores of partitions of 5. The partitions (5), (4,1), (3,2), (3,1,1), (2,2,1), (2,1,1,1), (1,1,1,1,1) have 5-cores that group them into blocks. Any mismatch with the Nakayama prediction falsifies the conjecture.

**Impact:** Opens the door to formalized modular representation theory, where Maschke's theorem fails and semisimplicity breaks down. This is the frontier of current research in algebra.

**Catalog References:** `Algebra/RepresentationTheory/Symmetric/PermutationRep.lean` (permLinearRep uses Field K, which could be specialized to finite fields).

**Proof Strategy:** Formalize Brauer characters, p-modular systems, and decomposition matrices. Use the formal permutation representation as a test case: reduce modulo p and study the resulting non-semisimple structure.

**Domain Bridges:** Number theory (p-adic methods), algebraic geometry (moduli spaces), coding theory (over finite fields).

**Lineage:** Grand challenge extending the characteristic-zero theory. Requires fundamentally new infrastructure.

**Ambition:** ★★★★★ — This is at the frontier of formalized algebra. Even partial results would be significant.

---

## Direction 4: Burnside's p^a q^b Theorem via Character Theory

**Conjecture:** Every finite group of order p^a · q^b (for primes p, q) is solvable. This is Burnside's theorem (1904), proved using character theory.

**Test:** Verify computationally for all groups of order p^a · q^b up to order 1000 using the GAP computer algebra system. Any non-solvable group of such order would be a counterexample (none exists — the theorem is true, but formal verification is the goal).

**Impact:** This would be a landmark in formalized mathematics: Burnside's theorem is one of the most celebrated applications of character theory, and its formal verification would demonstrate the power of the representation-theoretic approach.

**Catalog References:** `Algebra/RepresentationTheory/Symmetric/StandardRep.lean` (characterInner, trivial_standard_orthogonal — the orthogonality machinery needed for Burnside's argument).

**Proof Strategy:** The proof requires three ingredients: (a) column orthogonality of the character table, (b) the fact that a non-trivial irreducible character of a finite group cannot be identically zero on a non-trivial conjugacy class of p-power order, and (c) a transfer argument. Step (b) is the key character-theoretic input, requiring algebraic integers and divisibility arguments.

**Domain Bridges:** Number theory (p-groups, Sylow theory), abstract algebra (solvability, composition series).

**Lineage:** Grand challenge. Requires Direction 1 infrastructure plus substantial new development.

**Ambition:** ★★★★★ — Among the hardest formalization targets in finite group theory, but the mathematical argument is well-understood.

---

## Direction 5: Certified Spectral Gap Bounds for Cayley Graphs via Characters

**Conjecture:** For the Cayley graph of S_n generated by all transpositions, the spectral gap (difference between the largest and second-largest eigenvalue of the normalized adjacency matrix) is exactly 2n/(n-1) for all n ≥ 3. This spectral gap controls the mixing time of random transposition shuffles.

**Test:** For n = 3, 4, 5, 6, 7, compute the adjacency matrix of the transposition Cayley graph (size n! × n!), find its eigenvalues numerically, and compare the spectral gap with the predicted formula 2n/(n-1). For n = 3: gap = 6/2 = 3 (prediction) vs numerical computation. Any mismatch falsifies the conjecture.

**Impact:** Provides a certified bound on the mixing time of random transposition shuffles: T_mix ~ (n/2) log n, a result of Diaconis and Shahshahani [1981]. Machine-verified spectral gaps would enable certified bounds for MCMC algorithms on symmetric groups.

**Catalog References:** `Algebra/RepresentationTheory/Symmetric/PermutationRep.lean` (trace_class_sum_operator_eq_character_sum), `Algebra/RepresentationTheory/Symmetric/S3Rigidity.lean` (s3_transposition_class_sum_trace).

**Proof Strategy:** Use the character-theoretic spectral formula: on each irreducible representation V_λ, the transposition class sum acts as scalar c_λ = (C(n,2)/dim(λ)) · χ_λ(transposition). The largest eigenvalue is c_triv = C(n,2) and the second largest is c_std = C(n,2)·(n-2)/(2(n-1)) on the standard representation. The gap is c_triv - c_std = C(n,2)·n/(n-1) after normalization.

**Domain Bridges:** Probability (Markov chains, mixing times), computer science (randomized algorithms), spectral graph theory (expanders, Cheeger inequality).

**Lineage:** Directly extends the spectral cross-domain theorem. Most accessible grand challenge.

**Ambition:** ★★★★☆ — Requires formalizing the character-theoretic eigenvalue formula for normal Cayley graphs, which is a moderate extension of current infrastructure.
