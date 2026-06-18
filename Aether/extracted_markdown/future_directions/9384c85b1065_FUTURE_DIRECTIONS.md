# Future Directions: Determinantal Complexity of Matroid Basis Polynomials

## Synthesis

The introduction of determinantal complexity as a matroid invariant creates a new bridge between three historically separate fields: matroid theory (combinatorics), algebraic complexity (theoretical computer science), and partition function theory (mathematical physics/probability). The central insight is that the Cauchy-Binet identity is not merely a formula but a *complexity certificate*: it shows that representable matroid basis polynomials admit compact determinantal encodings, and the minimality of such encodings becomes a structural invariant. The five directions below form a coherent research program: Direction 1 establishes the foundational lower bound theory, Direction 2 attacks the central conjecture, Direction 3 extends compositionality to richer operations, Direction 4 bridges to quantum information, and Direction 5 connects to the deepest open problems in complexity theory.

---

## Direction 1: Degree Lower Bounds and Homogeneity Analysis

**Conjecture:** For any nonzero homogeneous polynomial $p$ of degree $d$ satisfying $p = \det(A \cdot D_X \cdot A^T)$ with $A \in R^{r \times n}$, we have $d = r$. In particular, $\mathrm{dc}(p) \geq \deg(p)$ for nonzero homogeneous basis polynomials.

**The key insight is** that the Gram polynomial matrix $G_A$ has entries that are degree-1 polynomials in the $X_k$, so its determinant is homogeneous of degree exactly $r$ (by multilinearity of the determinant). Combined with the upper bound $\mathrm{dc} \leq r$ for representable matroids, this would give $\mathrm{dc} = r$ exactly.

**Why now?** The machinery for homogeneity analysis of multivariate polynomials is well-developed in Mathlib (`MvPolynomial.IsHomogeneous`), and our Gram matrix definition makes the degree structure transparent. The formal proof requires showing that the determinant of a matrix whose entries are degree-1 polynomials is homogeneous of degree equal to the matrix size — a clean lemma that should be provable via induction on the matrix size using cofactor expansion.

**Test:** Verify computationally for all $r \leq 5$ and $n \leq 8$ that $\deg(B_A) = r$ when $B_A \neq 0$. Attempt the formal proof via `Matrix.det_apply` and `MvPolynomial.IsHomogeneous.mul`.

**Impact:** Establishes the first nontrivial *lower* bound on determinantal complexity, completing the "dc = rank" equivalence for representable matroids.

**Catalog References:** `Catalog/Pythagorean/DeterminantalComplexity.lean` (definitions of `basisPolyOfMatrix`, `gramPolyMatrix`)

**Proof Strategy:** Induction on $r$. For $r = 0$, the polynomial is 1 (degree 0). For $r + 1$, expand the determinant along the first row using cofactors. Each cofactor is a degree-$r$ polynomial (by inductive hypothesis) multiplied by a degree-1 entry, giving degree $r+1$.

**Domain Bridges:** Algebraic complexity ↔ matroid theory (invariant characterization)

**Lineage:** Extends Theorems 3.1 and 3.2 from `DeterminantalComplexity.lean`

**Ambition:** ★★☆ (Solid extension)

---

## Direction 2: The Representability Conjecture — Full Resolution for Small Matroids

**Conjecture:** $\mathrm{dc}_{\mathbb{R}}(B_M) = \mathrm{rk}(M)$ if and only if $M$ is representable over $\mathbb{R}$.

**The key insight is** that non-representable matroids have basis supports that cannot be realized as the nonvanishing pattern of maximal minors of any matrix, so their basis polynomials cannot be written as $\det(A D_X A^T)$ with $A$ of rank-sized dimensions.

**Why now?** Complete catalogs of matroids on $\leq 9$ elements exist [Mayhew-Royle], and efficient algorithms for testing representability are available. Combined with our representation search algorithm, a systematic computational attack is feasible.

**Test:** Enumerate all simple matroids on $\leq 8$ elements. For each, test (a) representability via known characterizations, (b) existence of rank-sized determinantal representation via numerical search, (c) whether (a) ⟺ (b).

**Impact:** If confirmed computationally for all small matroids, this would constitute strong evidence for a major structural conjecture. A proof would unify matroid representability with algebraic complexity.

**Catalog References:** `Catalog/Pythagorean/DeterminantalComplexity.lean` (all main theorems), `Catalog/Pythagorean/FermionicPlucker.lean` (Cauchy-Binet identity)

**Proof Strategy:** For the forward direction, use the fact that nonzero $(det A_S)^2$ coefficients must satisfy the Grassmann-Plücker relations. If these relations are violated by the target polynomial, no representation exists. For the reverse direction, invoke Theorem 3.1.

**Domain Bridges:** Matroid theory ↔ algebraic geometry (Grassmannian, Plücker relations)

**Lineage:** Direct extension of the conjecture stated in Section 5 of the research paper

**Ambition:** ★★★ (Grand challenge)

---

## Direction 3: Tensor Products and Matroid Operations

**Conjecture:** The determinantal complexity satisfies $\mathrm{dc}(B_{M \otimes N}) \leq \mathrm{dc}(B_M) \cdot \mathrm{dc}(B_N)$ for matroid tensor products (if well-defined), and more generally, there exist composition laws for $\mathrm{dc}$ under truncation, elongation, contraction, and deletion.

**The key insight is** that matroid operations correspond to polynomial operations on basis polynomials, and these polynomial operations should interact predictably with the Gram determinantal structure.

**Why now?** The block-diagonal composition theorem (Theorem 3.5) establishes the first compositionality law. Extending to richer operations requires understanding how operations on the representation matrix $A$ (row/column operations, Schur complements) translate to operations on $B_A$.

**Test:** For graphic matroids of small graphs, compute $\mathrm{dc}$ of the matroid obtained by contracting/deleting edges. Check whether contraction preserves or decreases $\mathrm{dc}$, and whether deletion can increase it.

**Impact:** A complete theory of $\mathrm{dc}$ under matroid operations would make determinantal complexity a practical tool for matroid classification, analogous to how Tutte polynomial evaluations classify matroids.

**Catalog References:** `Catalog/Pythagorean/DeterminantalComplexity.lean` (`basisPolyOfMatrix_blockDiag`, `isDeterminantalBasisPolynomial_mul_disjoint`)

**Proof Strategy:** For contraction: if $M/e$ has representation $A'$ obtained by pivoting on the column for $e$, then $B_{M/e}$ should relate to $B_M$ via a specialization $x_e \to 1$. For deletion: $M \setminus e$ corresponds to $x_e \to 0$. Formalize these as corollaries of the evaluation theorem.

**Domain Bridges:** Combinatorics ↔ algebraic complexity (circuit composition)

**Lineage:** Extends the compositionality theorem from `DeterminantalComplexity.lean`

**Ambition:** ★★☆ (Solid extension)

---

## Direction 4: Fermionic Gaussian States and Quantum Information

**Conjecture:** The determinantal complexity of a matroid basis polynomial equals the minimum number of fermionic modes needed to prepare a Gaussian state whose occupation-number measurement probabilities reproduce the matroid's basis distribution.

**The key insight is** that the Gram determinant $\det(A D_w A^T)$ is exactly the partition function of a free-fermion system with $r$ modes coupled to $n$ sites with hopping amplitudes $A_{ik}$ and chemical potentials $\log w_k$. Determinantal complexity thus measures the minimum quantum resources for simulating the matroid as a free-fermion model.

**Why now?** The connection between DPPs and free-fermion systems is well-established in mathematical physics [Lyons05], and the formalized nonnegativity theorem (Theorem 3.3) already provides the probabilistic interpretation. Recent progress in quantum state certification [HHJ+17] makes it possible to verify such representations experimentally.

**Test:** For graphic matroids of small graphs, compute the fermionic Hamiltonian corresponding to the representation matrix $A$ and verify that its ground state statistics match the basis distribution.

**Impact:** Would create a dictionary between matroid invariants and quantum information quantities (entanglement entropy, magic state distance, etc.), potentially enabling quantum speedups for matroid optimization problems.

**Catalog References:** `Catalog/Pythagorean/FermionicPlucker.lean` (Slater basis distribution, Born rule), `Catalog/Pythagorean/DeterminantalComplexity.lean` (nonnegativity theorem)

**Proof Strategy:** Express the Slater determinant state $|\psi_A\rangle = \sum_S \det(A_S) |S\rangle$ in second quantization. Show that $\langle \psi_A | n_{S_1} \cdots n_{S_r} | \psi_A \rangle = (\det A_S)^2 / \det(AA^T)$, recovering the basis probabilities.

**Domain Bridges:** Matroid theory ↔ quantum information ↔ condensed matter physics

**Lineage:** Extends `FermionicPlucker.lean` Slater distribution to complexity theory

**Ambition:** ★★★ (Grand challenge, paradigm-shifting)

---

## Direction 5: VP vs VNP via Matroid Basis Polynomials

**Conjecture:** There exists an explicit family of matroids $\{M_n\}$ whose basis polynomials $B_{M_n}$ require super-polynomial general determinantal complexity, providing a separation between VP and VNP-like classes restricted to Gram determinants.

**The key insight is** that matroid basis polynomials are a rich source of explicit polynomials with combinatorial structure. If non-representable matroids have provably high determinantal complexity, this yields concrete algebraic complexity lower bounds. Even proving $\mathrm{dc} > \mathrm{rank}$ for a single explicit non-representable matroid would be a breakthrough.

**Why now?** The Fano matroid provides a candidate: its basis polynomial over $\mathbb{R}$ should have $\mathrm{dc} > 3 = \mathrm{rank}$. If the representability conjecture holds, this is guaranteed. Even without the full conjecture, a direct lower bound proof using support constraints or algebraic independence arguments might be within reach.

**Test:** Attempt to prove $\mathrm{dc}_{\mathbb{R}}(B_{F_7}) > 3$ via Plücker relation analysis. If the coefficients of $B_{F_7}$ violate the Grassmann-Plücker relations for all $3 \times 7$ matrices, this certifies the lower bound.

**Impact:** Would be the first explicit lower bound for Gram determinantal complexity, with implications for VP vs VNP and for the computational hardness of matroid optimization.

**Catalog References:** `Catalog/Pythagorean/DeterminantalComplexity.lean` (all theorems), `Catalog/Pythagorean/FermionicPlucker.lean` (Plücker coordinates)

**Proof Strategy:** Step 1: Formalize the Grassmann-Plücker relations for $r \times n$ matrices. Step 2: Show that the basis support of $F_7$ violates these relations over $\mathbb{R}$. Step 3: Conclude $\mathrm{dc}_{\mathbb{R}}(B_{F_7}) > 3$. Step 4: Generalize to infinite families using matroid minors.

**Domain Bridges:** Algebraic complexity ↔ matroid theory ↔ algebraic geometry (Grassmannian)

**Lineage:** Ultimate goal of the determinantal complexity program

**Ambition:** ★★★ (Grand challenge)
