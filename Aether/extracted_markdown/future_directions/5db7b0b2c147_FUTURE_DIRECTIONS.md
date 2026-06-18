# Future Directions: Hadamard Matrix Theory

## 1. Paley Construction and Quadratic Residues

The Sylvester construction covers orders $2^k$, but the Paley construction yields Hadamard matrices of order $p+1$ for primes $p \equiv 3 \pmod{4}$, using the Jacobi symbol (quadratic residue character) as matrix entries. Formalizing this would connect Hadamard theory to algebraic number theory in Mathlib.

**The key insight is** that the quadratic residue character $\chi: \mathbb{F}_p \to \{0, \pm 1\}$ naturally produces a conference matrix $C$ satisfying $C C^\top = (p-1)I + J$, and the block construction $\begin{pmatrix} 1 & \mathbf{1}^\top \\ \mathbf{1} & C+I \end{pmatrix}$ is Hadamard.

**Why now?** Mathlib already has `legendreSym`, `ZMod.quadraticChar`, and `Finset.sum_char_sq` — the Jacobi sum infrastructure is largely in place. The gap is connecting these to the conference matrix identity, which is a concrete and bounded formalization task.

## 2. Hadamard Bound on Determinants

Any $n \times n$ matrix with entries bounded by $|a_{ij}| \leq 1$ satisfies $|\det A| \leq n^{n/2}$, with equality if and only if $A$ is a (real, normalized) Hadamard matrix. This is Hadamard's original inequality (1893). Formalizing this would establish the optimality of Hadamard matrices for combinatorial design and coding theory.

**The key insight is** that the AM-GM inequality applied to the Gram matrix eigenvalues gives $\det(A A^\top) \leq (\operatorname{tr}(A A^\top)/n)^n = n^n$, with equality forcing $A A^\top = nI$.

**Why now?** Mathlib has `Matrix.det_mul_det`, `Matrix.PosDef`, and spectral theory for Hermitian matrices. The AM-GM bound on eigenvalues via trace/determinant inequalities is the main gap, but this is a standard inequality that decomposes into provable pieces.

## 3. Equivalence Classes and the Automorphism Group

Two Hadamard matrices are *equivalent* if one can be obtained from the other by row/column permutations and sign changes. The number of equivalence classes grows rapidly: there is 1 class for $n=1,2,4$, but 5 for $n=12$, 60 for $n=16$, and the exact count for $n=32$ is unknown. Formalizing the equivalence relation and proving the uniqueness for small orders would connect to computational group theory.

**The key insight is** that the equivalence group acts as $(P_1, P_2, D_1, D_2) \cdot H = D_1 P_1 H P_2^\top D_2$ where $P_i$ are permutation matrices and $D_i$ are diagonal $\pm 1$ matrices. For $n \leq 4$, uniqueness follows from the constraints being so tight that the sign-permutation group acts transitively.

**Why now?** Mathlib has `Equiv.Perm`, `Matrix.Perm.toMatrix`, and `MonoidHom` infrastructure. The group action formalization is straightforward; the uniqueness proof for $n=4$ is finite and could potentially be verified by `decide` on a suitable quotient.

## 4. Connection to Error-Correcting Codes (First-Order Reed-Muller)

The rows of a $2^k \times 2^k$ Sylvester–Hadamard matrix (together with their negations) form the codewords of the first-order Reed-Muller code $\mathrm{RM}(1,k)$, which achieves the Plotkin bound with minimum distance $2^{k-1}$. Formalizing this connection would bridge combinatorics and coding theory.

**The key insight is** that the Walsh–Hadamard matrix entry $H(i,j) = (-1)^{\langle i,j \rangle}$ (where $\langle \cdot, \cdot \rangle$ is the $\mathbb{F}_2$-inner product of binary representations) directly encodes affine functions on $\mathbb{F}_2^k$, which are exactly the RM(1,k) codewords.

**Why now?** This direction requires formalizing $\mathbb{F}_2^k$ as a vector space (available via `ZMod 2` and `Fin k → ZMod 2`), the bitwise inner product, and the Walsh–Hadamard transform. The Sylvester construction we already have provides the matrix; the gap is proving the distance and linearity properties.

## 5. Williamson's Construction and the Hadamard Conjecture for $n \leq 668$

Williamson (1944) showed that if four symmetric $\{0, \pm 1\}$-matrices $A, B, C, D$ of order $m$ satisfy $A^2 + B^2 + C^2 + D^2 = 4mI$, then a Hadamard matrix of order $4m$ exists via a block construction. All known Hadamard matrices for orders not covered by Sylvester or Paley ultimately rely on Williamson-type or generalized constructions. The smallest order for which no Hadamard matrix is known is $n = 668$.

**The key insight is** that Williamson's construction reduces the Hadamard existence problem to finding four commuting $\pm 1$ matrices satisfying a sum-of-squares identity — a problem in the group ring $\mathbb{Z}[\mathbb{Z}/m\mathbb{Z}]$ that can be attacked computationally for specific $m$.

**Why now?** Formalizing the Williamson block construction is purely algebraic (matrix multiplication verification) and would immediately give a framework for certifying Hadamard matrices at specific orders. Combined with a verified computation for $m \leq 166$, this could formally establish the Hadamard conjecture for all $n \leq 664$, pushing the formal frontier to within 4 of the smallest open case.
