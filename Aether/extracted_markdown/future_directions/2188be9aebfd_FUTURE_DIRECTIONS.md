# Future Research Directions

## Synthesis

This research cycle established the precise algebraic equivalence between the MDS (Maximum Distance Separable) property of matrices and the strongest form of the discrete uncertainty principle. We formally proved, with machine-verified Lean 4 proofs, that a square matrix $M$ over a field satisfies $|\text{supp}(f)| + |\text{supp}(Mf)| \geq n + 1$ for every nonzero $f$ if and only if every square submatrix of $M$ has nonzero determinant. We also proved Vandermonde nonsingularity for injective evaluation points and introduced the CriticalSubmatrix certificate as a constructive witness of MDS failure.

The most promising cross-domain connection is the chain from the polynomial root bound (formalized in `Algebra/RootBound.lean`) through Vandermonde MDS to the uncertainty principle (formalized in `Algebra/MDSUncertainty/Theorems.lean`), and further to the existing Fourier uncertainty principle (`Algebra/FourierAnalysis/Theorems.lean`). The Catalog now has formally verified links between polynomial root bounds, Vandermonde determinants, and the MDS–Uncertainty equivalence. The missing link — proving that Vandermonde matrices with distinct nonzero evaluation points are MDS over characteristic 0 fields — would complete the entire chain.

Computational experiments revealed that Vandermonde matrices with consecutive integer evaluation points fail to be MDS over most finite fields even of moderate size, with the failure pattern being non-monotone in the field characteristic. This connects to the deep MDS conjecture from finite geometry and suggests that the structure of Schur polynomials modulo primes is a rich and under-explored area.

---

### Direction 1: Schur Polynomial Positivity and Vandermonde MDS

**Conjecture**: Over any ordered field $F$ (e.g., $\mathbb{Q}$ or $\mathbb{R}$), the Vandermonde matrix $V(v)$ with distinct positive evaluation points $v_0 < v_1 < \cdots < v_{n-1}$ is MDS. That is, every square submatrix of $V(v)$ has nonzero determinant.

**Test**: (a) Verify computationally for $n \leq 8$ over $\mathbb{Q}$ with points $1, 2, \ldots, n$: enumerate all square submatrices and check determinants symbolically. (b) Attempt to formalize the alternant determinant formula: $\det(v_{i_l}^{j_m}) = \prod_{l<m}(v_{i_m} - v_{i_l}) \cdot s_\lambda(v_{i_1}, \ldots, v_{i_k})$ where $s_\lambda$ is a Schur polynomial and $\lambda = (j_k - (k-1), \ldots, j_1 - 0)$. (c) Prove that Schur polynomials are strictly positive at strictly positive arguments.

**Impact**: If proved, this completes the chain: polynomial root bound → Vandermonde MDS → uncertainty principle → Fourier uncertainty. It would give the first fully machine-verified proof that Reed-Solomon codes over the rationals achieve the Singleton bound, unifying three major results in a single verified pipeline.

**Catalog References**: `Algebra/MDSUncertainty/Theorems.lean` (MDS–Uncertainty equivalence), `Algebra/RootBound.lean` (polynomial root count bound), `Algebra/FourierAnalysis/Theorems.lean` (Fourier uncertainty).

**Proof Strategy**: 
1. Define Schur polynomials $s_\lambda$ as a ratio of alternating polynomials or via the combinatorial (semistandard Young tableaux) formula.
2. Prove the alternant determinant factorization formula.
3. Prove Schur polynomial positivity at positive arguments (either via the tableaux formula — which gives $s_\lambda$ as a sum of monomials with positive coefficients — or via the ratio formula).
4. Combine with the MDS–Uncertainty equivalence.

Key Mathlib dependencies needed: `Polynomial.eval`, `Matrix.det_vandermonde` (already available), `Finset.prod_pos` (for positivity).

**Domain Bridges**: Algebraic combinatorics (Schur polynomials, Young tableaux) ↔ Coding theory (MDS codes) ↔ Harmonic analysis (uncertainty principles)

**Lineage**: Builds directly on `mds_iff_uncertainty` and `vandermonde_det_ne_zero` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Quantitative Uncertainty Defect and MDS Order

**Conjecture**: For an $n \times n$ matrix $M$ over a field, define the *MDS order* $\mu(M)$ as the largest $k$ such that every $k \times k$ submatrix of $M$ has nonzero determinant (set $\mu(M) = 0$ if some $1 \times 1$ submatrix is zero). Define the *minimum uncertainty* $U(M) = \min_{f \neq 0} (|\text{supp}(f)| + |\text{supp}(Mf)|)$. Then $U(M) = \mu(M) + 1$.

**Test**: (a) Verify computationally for random matrices of size $n \leq 6$ over $\mathbb{Q}$. (b) Check boundary cases: identity matrix ($\mu = 0$, $U = ?$), permutation matrices, diagonal matrices. (c) Attempt formal proof: the forward direction ($U \geq \mu + 1$) uses the same submatrix extraction argument as MDS → UP, stopping at size $\mu$. The reverse ($U \leq \mu + 1$) uses the critical submatrix at size $\mu + 1$.

**Impact**: This would give a complete quantitative refinement of the MDS–Uncertainty equivalence, relating the "MDS defect" to the precise gap in the uncertainty bound. It would provide finer information about how far a matrix is from being MDS.

**Catalog References**: `Algebra/MDSUncertainty/Defs.lean` (IsMDS, SatisfiesUP, CriticalSubmatrix), `Algebra/MDSUncertainty/Theorems.lean` (equivalence).

**Proof Strategy**:
1. Define MDSOrder formally as $\mu(M) = \max\{k : \text{every } k \times k \text{ submatrix is nonsingular}\}$.
2. Prove $U(M) \geq \mu(M) + 1$ by adapting the MDS → UP proof to stop at the MDS order.
3. Prove $U(M) \leq \mu(M) + 1$ by constructing a vector achieving equality using a singular $(\mu+1) \times (\mu+1)$ submatrix.

**Domain Bridges**: Linear algebra (matrix rank theory) ↔ Coding theory (Singleton-type bounds) ↔ Optimization (sparse recovery thresholds)

**Lineage**: Direct extension of `mds_iff_uncertainty` from this cycle.

**Ambition**: extension

---

### Direction 3: DFT Matrices and Prime-Order Uncertainty

**Conjecture**: The $p \times p$ DFT (Discrete Fourier Transform) matrix over $\mathbb{C}$ with entries $\omega^{ij}$ (where $\omega = e^{2\pi i/p}$ and $p$ is prime) is MDS. Equivalently, $|\text{supp}(f)| + |\text{supp}(\hat{f})| \geq p + 1$ for every nonzero $f \in \mathbb{C}^p$.

**Test**: (a) Verify computationally for $p = 2, 3, 5, 7, 11, 13$ by checking all square submatrix determinants. (b) This is equivalent to Tao's uncertainty principle for cyclic groups of prime order, so the proof strategy is known: it uses Chebotarëv's theorem on the non-vanishing of minors of the DFT matrix, which in turn uses the irreducibility of cyclotomic polynomials over $\mathbb{Q}$.

**Impact**: This would connect the MDS–Uncertainty equivalence to the Fourier analysis pipeline already in the Catalog, creating a complete formal verification of the prime-order Fourier uncertainty principle via the MDS route. It would demonstrate that the algebraic (MDS) and analytic (Fourier) approaches to uncertainty are formally equivalent.

**Catalog References**: `Algebra/FourierAnalysis/Theorems.lean` (parseval, plancherel, uncertainty), `Algebra/MDSUncertainty/Theorems.lean` (MDS–UP equivalence).

**Proof Strategy**:
1. Define the DFT matrix $F_p$ with entries $\omega^{ij}$.
2. Show that $F_p$ is a Vandermonde matrix with evaluation points $1, \omega, \omega^2, \ldots, \omega^{p-1}$.
3. Use Chebotarëv's theorem (1926): every minor of $F_p$ is nonzero. This requires showing that the minimal polynomial of $\omega$ over $\mathbb{Q}$ divides no minor of $F_p$ unless the minor is trivially zero.
4. Alternatively, use the fact that the $p$-th roots of unity are algebraically conjugate over $\mathbb{Q}$ (since $p$ is prime, the cyclotomic polynomial $\Phi_p$ is irreducible) to show that Schur polynomials evaluated at roots of unity are nonzero.
5. Apply `mds_iff_uncertainty` to conclude.

**Domain Bridges**: Number theory (cyclotomic fields, Chebotarëv's theorem) ↔ Harmonic analysis (Fourier uncertainty) ↔ Coding theory (Reed-Solomon over roots of unity)

**Lineage**: Bridges the Fourier analysis file (`Algebra/FourierAnalysis/Theorems.lean`) with the MDS file (`Algebra/MDSUncertainty/Theorems.lean`).

**Ambition**: grand_challenge

---

### Direction 4: MDS Matrices in AES and Cryptographic Diffusion

**Conjecture**: The $4 \times 4$ MixColumns matrix used in AES (Advanced Encryption Standard), viewed over $\text{GF}(2^8)$, is MDS. Therefore, the AES diffusion layer satisfies the optimal uncertainty bound: for any nonzero difference vector $\Delta$, $|\text{supp}(\Delta)| + |\text{supp}(M \cdot \Delta)| \geq 5$.

**Test**: (a) Verify the MDS property of the AES MixColumns matrix by checking all $\binom{4}{k}^2$ submatrices for $k = 1, 2, 3, 4$ over $\text{GF}(2^8)$. There are only 70 + 36 + 16 + 1 = 123 submatrices to check. (b) Formalize $\text{GF}(2^8)$ in Lean using `ZMod` and irreducible polynomial $x^8 + x^4 + x^3 + x + 1$. (c) Check each submatrix determinant is nonzero.

**Impact**: This would provide the first formally verified proof of the key cryptographic property of AES's diffusion layer — that it achieves optimal branch number. Combined with the MDS–Uncertainty equivalence, it would give a formal proof that the AES uncertainty principle holds, strengthening the theoretical foundation of the most widely deployed encryption algorithm.

**Catalog References**: `Algebra/MDSUncertainty/Theorems.lean`, `Cryptography/BerggrenDiophantineLattice.lean` (for existing crypto formalization patterns).

**Proof Strategy**:
1. Define $\text{GF}(2^8)$ as the quotient $\mathbb{F}_2[x]/(x^8 + x^4 + x^3 + x + 1)$.
2. Define the AES MixColumns matrix: $\begin{pmatrix} 2 & 3 & 1 & 1 \\ 1 & 2 & 3 & 1 \\ 1 & 1 & 2 & 3 \\ 3 & 1 & 1 & 2 \end{pmatrix}$ where multiplication is in $\text{GF}(2^8)$.
3. Check each of the 123 square submatrix determinants is nonzero. Since this is a finite computation, it could be verified by `native_decide` after appropriate setup, but a more mathematical proof using the circulant structure is preferred.
4. Apply `mds_iff_uncertainty` to conclude.

**Domain Bridges**: Cryptography (AES, block cipher design) ↔ Coding theory (MDS codes) ↔ Harmonic analysis (uncertainty-based security analysis)

**Lineage**: Application of `mds_iff_uncertainty` to a concrete cryptographic setting.

**Ambition**: extension

---

### Direction 5: Tensor Products of MDS Matrices

**Conjecture**: If $A \in F^{m \times m}$ and $B \in F^{n \times n}$ are both MDS matrices, then their tensor (Kronecker) product $A \otimes B \in F^{mn \times mn}$ is NOT MDS in general, but satisfies a weaker uncertainty bound: $|\text{supp}(f)| + |\text{supp}((A \otimes B)f)| \geq m + n$ for every nonzero $f \in F^{mn}$.

**Test**: (a) Verify computationally for $A = V(1,2)$ ($2 \times 2$ MDS) and $B = V(1,2,3)$ ($3 \times 3$ MDS). Check whether $A \otimes B$ is MDS ($6 \times 6$). (b) Find the minimum uncertainty of $A \otimes B$ by enumeration. (c) Test the conjectured bound $m + n$ vs the MDS bound $mn + 1$.

**Impact**: Understanding how MDS properties compose under tensor products would have implications for product codes, concatenated coding schemes, and multi-dimensional signal processing. A positive result would provide a systematic way to construct uncertainty-optimal transformations in high dimensions from lower-dimensional building blocks.

**Catalog References**: `Algebra/MDSUncertainty/Theorems.lean` (MDS–UP equivalence).

**Proof Strategy**:
1. Verify the conjecture computationally for small cases.
2. If the bound $m + n$ holds, prove it by decomposing vectors in $F^{mn}$ as matrices in $F^{m \times n}$ and analyzing the support of $(A \otimes B)f$ in terms of the row and column supports.
3. If the conjecture is false, find the correct bound and prove it.

**Domain Bridges**: Coding theory (product codes) ↔ Multilinear algebra (tensor products) ↔ Signal processing (multi-dimensional transforms)

**Lineage**: Extension of `mds_iff_uncertainty` to structured matrix compositions.

**Ambition**: extension
