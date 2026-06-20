# The MDS–Uncertainty Equivalence: A Sharp Additive Uncertainty Principle for Maximum Distance Separable Matrices

**Author:** Aristotle
**Domain:** Algebra (linear algebra, coding theory, discrete harmonic analysis)
**Date:** 2026-06-20

## Abstract

We establish an exact equivalence between two a priori unrelated properties of a square matrix over a field. On one side stands the **Maximum Distance Separable (MDS)** property — every square submatrix has nonzero determinant — the algebraic backbone of Reed–Solomon codes and the Singleton bound. On the other stands the **strongest additive uncertainty principle**: for every nonzero vector $f$, the combined support size of $f$ and of its image $Mf$ is at least $n+1$. We prove that for an $n\times n$ matrix $M$ over a field $F$,
$$
M \text{ is MDS} \quad\Longleftrightarrow\quad \forall f \neq 0,\ \ |\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1 .
$$
The bound $n+1$ is optimal: every invertible matrix admits a nonzero vector whose support sum is at most $n+1$, so MDS matrices are exactly those achieving this universal ceiling for *all* inputs. We further record that MDS is closed under transpose, mirroring the self-duality of Reed–Solomon codes. The development is entirely elementary — built from a support/zero counting identity, a submatrix-restriction lemma, and the kernel characterization of singular matrices — yet it unifies the Donoho–Stark uncertainty principle, Tao's prime-cyclic uncertainty principle, and MDS coding theory under a single statement. All results have been formally verified.

---

## 1. Introduction

The phrase "uncertainty principle" denotes, across many fields, a prohibition against simultaneous concentration of an object and of a derived representation of it. In quantum mechanics it bounds position against momentum; in classical Fourier analysis it bounds a function against its transform; in additive combinatorics it bounds support sizes. Donoho and Stark (1989) gave a discrete, finite-dimensional formulation suited to signal recovery, and Tao (2005) proved a sharp version for cyclic groups of prime order. In all these settings the operative trade-off is governed by a *linear map* $M$, and the relevant notion of concentration is the **support** — the count of nonzero coordinates.

Independently, coding theory developed the notion of a **Maximum Distance Separable (MDS)** matrix: a square matrix all of whose square submatrices are invertible. MDS matrices generate the codes (Reed–Solomon and their kin) that meet the Singleton bound and thus correct the maximum number of errors per redundancy. The MDS condition is purely determinantal and makes no reference to support sizes.

This paper proves that these two notions are *identical*. The MDS property is exactly the condition under which $M$ enforces the strongest possible additive uncertainty bound, and conversely the failure of MDS is exactly witnessed by a sparse vector with a sparse image. The argument is short, self-contained, and constructive in both directions.

### 1.1 Contributions

1. A clean formalization of vector support and of the MDS and uncertainty properties (Section 3).
2. A submatrix-restriction lemma (Lemma 4.1) linking the global matrix–vector product to determinants of submatrices.
3. The forward implication MDS $\Rightarrow$ uncertainty (Theorem 5.1) by a contradiction that constructs a singular submatrix.
4. The converse, non-MDS $\Rightarrow$ existence of a violator (Theorem 5.2), by lifting a kernel vector.
5. The full equivalence (Theorem 6.1) and the optimality of $n+1$ (Theorem 6.3).
6. Structural corollaries: MDS implies invertibility (Theorem 4.2) and transpose-closure (Theorem 6.2).

All statements have been mechanically verified; the proofs below are faithful sketches of the formal arguments.

---

## 2. Notation and conventions

Throughout, $F$ is a field with decidable equality, $n,k \in \mathbb{N}$, and matrices are indexed by $\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$. A vector is a function $f : \mathrm{Fin}\,n \to F$; the zero vector is denoted $0$. For a matrix $M \in F^{n\times n}$, $M f$ denotes the matrix–vector product (written `M.mulVec f` in the formalization), with $(Mf)_i = \sum_{j} M_{ij} f_j$. An **embedding** $r : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$ is an injective index map; it selects $k$ distinct rows (or columns). The submatrix $M\!\restriction_{r,c}$ (written `M.submatrix r c`) is the $k\times k$ matrix with entries $(M\!\restriction_{r,c})_{ij} = M_{r(i),c(j)}$.

---

## 3. Definitions

**Definition 3.1 (Support and zero set).** For a vector $v : \mathrm{Fin}\,n \to F$,
$$
\mathrm{supp}(v) = \{\, i \in \mathrm{Fin}\,n : v_i \neq 0 \,\}, \qquad
\mathrm{zeros}(v) = \{\, i \in \mathrm{Fin}\,n : v_i = 0 \,\}.
$$
(Formal names: `vecSupport`, `vecZeros`.) We write $|\mathrm{supp}(v)|$ for the cardinality.

**Definition 3.2 (MDS matrix).** A matrix $M \in F^{n\times n}$ is **Maximum Distance Separable**, written $\mathrm{IsMDS}(M)$, if for every $k$ and every pair of embeddings $r, c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$,
$$
\det\!\big(M\!\restriction_{r,c}\big) \neq 0 .
$$
(Formal name: `IsMDS`.) Equivalently, every $k\times k$ submatrix obtained by selecting any $k$ rows and any $k$ columns is invertible. Taking $k=1$ shows every entry is nonzero; taking $k=n$ shows $M$ itself is invertible.

**Definition 3.3 (Additive uncertainty bound).** A matrix $M$ **satisfies the uncertainty bound** $b \in \mathbb{N}$, written $\mathrm{SatisfiesUncertainty}(M, b)$, if for every nonzero $f$,
$$
|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge b .
$$
(Formal name: `SatisfiesUncertainty`.)

**Definition 3.4 (Uncertainty profile).** An `UncertaintyProfile` packages a matrix `mat`, a `certifiedBound`, and a proof `bound_valid` that the matrix satisfies that bound. This is a certificate structure for recording verified lower bounds on the support sum; an MDS matrix admits the profile with `certifiedBound` $= n+1$.

---

## 4. Foundational lemmas

### 4.1 The support/zero counting identity

**Lemma 4.1 (`vecSupport_card_add_vecZeros_card`).** For every $v : \mathrm{Fin}\,n \to F$,
$$
|\mathrm{supp}(v)| + |\mathrm{zeros}(v)| = n .
$$

*Proof sketch.* The predicates $v_i \neq 0$ and $v_i = 0$ are complementary on the finite index set $\mathrm{Fin}\,n$. Writing each cardinality as a sum of indicator values and adding, every index contributes exactly $1$, giving the sum $n$. $\square$

Two immediate consequences are recorded: a nonzero vector has nonempty support (`vecSupport_nonempty_of_ne_zero`), hence positive support cardinality (`vecSupport_card_pos_of_ne_zero`). These follow because $f \neq 0$ means some coordinate is nonzero, which is exactly an element of $\mathrm{supp}(f)$.

### 4.2 Restriction of the matrix–vector product

The technical engine connecting global products to submatrices is the following.

**Lemma 4.2 (`submatrix_mulVec_of_support`).** Let $M \in F^{n\times n}$, let $r : \mathrm{Fin}\,k \to \mathrm{Fin}\,n$ and $c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$, and let $f : \mathrm{Fin}\,n \to F$ vanish outside the range of $c$ (i.e. $f_j \neq 0 \Rightarrow j \in \mathrm{range}(c)$). Then for each $i \in \mathrm{Fin}\,k$,
$$
\big( (M\!\restriction_{r,c})\,(f \circ c) \big)_i = (Mf)_{r(i)} .
$$

*Proof sketch.* Expand both sides as dot products. The right-hand side $\sum_{j\in \mathrm{Fin}\,n} M_{r(i),j} f_j$ ranges over all columns, but every term with $j \notin \mathrm{range}(c)$ has $f_j = 0$ and drops out. The surviving terms are indexed by $\mathrm{range}(c)$; reindexing along the injection $c$ identifies them with $\sum_{j\in \mathrm{Fin}\,k} M_{r(i),c(j)} f_{c(j)} = \sum_j (M\!\restriction_{r,c})_{ij}\,(f\circ c)_j$, which is the left-hand side. $\square$

This lemma says: *when the input is supported on the selected columns, restricting the matrix to those columns (and any chosen rows) computes the same output coordinates.* It is used in both directions of the main theorem.

### 4.3 MDS implies invertibility

**Theorem 4.3 (`mds_invertible`).** If $\mathrm{IsMDS}(M)$ then $\det M \neq 0$.

*Proof sketch.* Apply the MDS hypothesis with $k=n$ and $r=c=\mathrm{id}$. The submatrix $M\!\restriction_{\mathrm{id},\mathrm{id}}$ is $M$ itself, so $\det M \neq 0$. $\square$

---

## 5. The two directions of the equivalence

### 5.1 Forward: MDS forces the sharp bound

**Theorem 5.1 (`mds_implies_uncertainty`).** If $\mathrm{IsMDS}(M)$ and $f \neq 0$, then
$$
|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1 .
$$

*Proof sketch.* Suppose for contradiction that $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n$. Set $s = |\mathrm{supp}(f)|$; since $f\neq 0$, $s \ge 1$. By Lemma 4.1 applied to $Mf$,
$$
|\mathrm{zeros}(Mf)| = n - |\mathrm{supp}(Mf)| \ge n - (n - s) = s .
$$
Hence we may choose a set $T \subseteq \mathrm{zeros}(Mf)$ with exactly $s$ elements, and an embedding $r : \mathrm{Fin}\,s \hookrightarrow \mathrm{Fin}\,n$ with $\mathrm{range}(r) \subseteq T$ (so $M f$ vanishes on every selected row). Independently, list the support of $f$ by an order-embedding $c : \mathrm{Fin}\,s \hookrightarrow \mathrm{Fin}\,n$ with $\mathrm{range}(c) = \mathrm{supp}(f)$; then $f$ vanishes outside $\mathrm{range}(c)$, so Lemma 4.2 applies. For each $i$,
$$
\big((M\!\restriction_{r,c})\,(f\circ c)\big)_i = (Mf)_{r(i)} = 0 ,
$$
the last equality because $r(i) \in T \subseteq \mathrm{zeros}(Mf)$. Thus $(M\!\restriction_{r,c})\,(f\circ c) = 0$. By the MDS hypothesis $\det(M\!\restriction_{r,c}) \neq 0$, so the only kernel vector is zero, forcing $f\circ c = 0$. But $c$ enumerates exactly the support of $f$, where $f$ is nonzero by definition — contradiction. Therefore the support sum is at least $n+1$. $\square$

The geometric content: a support sum $\le n$ would leave enough zero rows in the output to build a square submatrix annihilating the (nonzero) restricted input, contradicting non-degeneracy.

### 5.2 Converse: a non-MDS matrix has a sparse violator

**Theorem 5.2 (`not_mds_implies_violator`).** If $\neg\,\mathrm{IsMDS}(M)$, then there exists $f \neq 0$ with
$$
|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n .
$$

*Proof sketch.* Failure of MDS yields $k$ and embeddings $r,c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$ with $\det(M\!\restriction_{r,c}) = 0$. A square matrix with zero determinant has a nontrivial kernel, so there is $v : \mathrm{Fin}\,k \to F$, $v\neq 0$, with $(M\!\restriction_{r,c})\,v = 0$. Define $f$ by spreading $v$ back along $c$ and padding with zeros:
$$
f_j = \begin{cases} v_{c^{-1}(j)} & j \in \mathrm{range}(c), \\ 0 & \text{otherwise.}\end{cases}
$$
Then $f\neq 0$ (it agrees with $v\neq 0$ on $\mathrm{range}(c)$) and $f$ vanishes outside $\mathrm{range}(c)$, so $\mathrm{supp}(f) \subseteq \mathrm{range}(c)$ gives $|\mathrm{supp}(f)| \le k$. By Lemma 4.2, for each $i$, $(Mf)_{r(i)} = \big((M\!\restriction_{r,c})\,v\big)_i = 0$, so the $k$ distinct rows $\mathrm{range}(r)$ all lie in $\mathrm{zeros}(Mf)$, giving $|\mathrm{zeros}(Mf)| \ge k$, i.e. $|\mathrm{supp}(Mf)| \le n-k$. Adding,
$$
|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le k + (n-k) = n . \quad\square
$$

---

## 6. Main results

### 6.1 The MDS–Uncertainty equivalence

**Theorem 6.1 (`mds_iff_uncertainty`, MDS–Uncertainty Theorem).** For every $M \in F^{n\times n}$,
$$
\mathrm{IsMDS}(M) \iff \mathrm{SatisfiesUncertainty}(M, n+1).
$$

*Proof sketch.* ($\Rightarrow$) is Theorem 5.1. ($\Leftarrow$): if $M$ satisfied the bound but were not MDS, Theorem 5.2 would produce a nonzero $f$ with support sum $\le n$, contradicting the bound $|\mathrm{supp}(f)|+|\mathrm{supp}(Mf)|\ge n+1$ at that $f$. $\square$

This is the central statement: the determinantal MDS condition and the strongest additive uncertainty bound are one and the same.

### 6.2 Transpose closure

**Theorem 6.2 (`mds_transpose`).** If $\mathrm{IsMDS}(M)$ then $\mathrm{IsMDS}(M^\top)$.

*Proof sketch.* A square submatrix of $M^\top$ selected by row-embedding $r$ and column-embedding $c$ equals the transpose of the submatrix of $M$ selected by $c$ (rows) and $r$ (columns): $(M^\top)\!\restriction_{r,c} = \big(M\!\restriction_{c,r}\big)^\top$. Since $\det(A^\top) = \det A$, its determinant equals $\det(M\!\restriction_{c,r}) \neq 0$ by the MDS hypothesis for $M$. $\square$

In coding terms, this is the self-duality of MDS codes: the dual of an MDS code is again MDS.

### 6.3 Optimality of the bound $n+1$

**Theorem 6.3 (`singleton_bound`).** Let $n \ge 1$ and let $M \in F^{n\times n}$ be invertible ($\det M \neq 0$). Then there exists $f \neq 0$ with
$$
|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n+1 .
$$

*Proof sketch.* Take $f = e_0$, the standard basis vector that is $1$ at coordinate $0$ and $0$ elsewhere. Then $f \neq 0$ and $|\mathrm{supp}(f)| = 1$. The image $Mf$ is the $0$-th column of $M$, whose support is at most $n$. Hence the support sum is at most $1 + n = n+1$. $\square$

**Corollary (sharpness).** Combining Theorems 6.1 and 6.3: for an MDS matrix, the bound $n+1$ is attained (every spike input meets it), and no invertible matrix can guarantee a strictly larger universal lower bound. Thus MDS matrices are exactly the *extremal* uncertainty matrices — those with zero slack against the Singleton-type ceiling. The name `singleton_bound` reflects the analogy with the coding-theoretic Singleton bound $d \le n-k+1$, of which the MDS property is the equality case.

---

## 7. Algorithms

The proofs are constructive and translate directly into algorithms over an effective field (e.g. $\mathbb{Q}$ or $\mathbb{F}_p$).

### 7.1 Deciding the MDS property

Enumerate every $k$ from $1$ to $n$, every size-$k$ subset of rows, and every size-$k$ subset of columns; compute the determinant of the resulting submatrix; declare $M$ MDS iff all are nonzero. The number of submatrices is $\sum_{k=1}^n \binom{n}{k}^2 = \binom{2n}{n} - 1$, so the procedure is exponential in $n$ but exact, and for the small matrices that occur in code design it is entirely practical. (Pseudocode and code appear in the companion package.)

### 7.2 Extracting a violator from a non-MDS matrix

When the MDS test fails, the first singular submatrix $M\!\restriction_{r,c}$ yields a kernel vector $v$; padding $v$ with zeros along $c$ produces a witness $f$ with support sum $\le n$, exactly as in Theorem 5.2. This is the algorithmic content of the converse direction and certifies non-MDS by a concrete sparse counterexample.

### 7.3 Verifying the uncertainty bound by sampling

For a fixed finite field and dimension, one can sample (or exhaustively enumerate over $\mathbb{F}_p^n$) nonzero vectors $f$ and confirm $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1$, simultaneously locating the spike inputs that attain equality. This empirically demonstrates Theorem 6.1 and the sharpness of Theorem 6.3.

---

## 8. Applications

**Coding theory.** The generator matrix of a Reed–Solomon code is built from a Vandermonde matrix on distinct nodes, which is MDS because every minor is a (nonzero) Vandermonde determinant. Theorem 6.1 recasts the code's optimal error-correction (the Singleton equality $d = n-k+1$) as an uncertainty statement about codewords; Theorem 6.2 expresses the self-duality of the code family.

**Compressed sensing and signal recovery.** A measurement matrix that forbids both a sparse signal and its sparse measurement (the uncertainty bound) guarantees unique recovery of sufficiently sparse signals. The MDS characterization gives a clean determinantal criterion for the strongest such guarantee, relevant to fast MRI and sub-Nyquist sampling.

**Harmonic analysis.** Over $\mathbb{F}_p$ with $p$ prime, the discrete Fourier transform matrix is MDS (Chebotarev's theorem on roots of unity). Theorem 6.1 then yields the finite Donoho–Stark / Tao uncertainty principle: a nonzero function on $\mathbb{Z}/p\mathbb{Z}$ and its transform cannot be jointly supported on fewer than $p+1$ points.

---

## 9. Discussion

The value of the equivalence is methodological: it converts a determinantal hypothesis into a support-counting conclusion and back, so techniques from coding theory, sparse recovery, and harmonic analysis become interchangeable. The argument is notable for what it does *not* require — no field-size assumption, no characteristic restriction, no analytic limit. The only structural input is that a singular square matrix has a nonzero kernel vector and a nonsingular one does not. The counting identity (Lemma 4.1) and the restriction lemma (Lemma 4.2) do the rest.

A subtle point worth emphasizing: the bound $n+1$ is *uniform* over all nonzero inputs for MDS matrices, but Theorem 6.3 shows that *some* input always achieves it (for any invertible matrix). MDS is precisely the gap between "some input is extremal" and "every input is at least extremal." This is the same phenomenon as the Singleton bound being a universal inequality whose equality case is the MDS codes.

---

## 10. Future directions

The natural research program splits along the three bridges the theorem connects.

1. **Quantitative defect theory.** Definition 3.4 (`UncertaintyProfile`) records a *certified* support-sum lower bound. For non-MDS matrices the largest valid bound $b < n+1$ measures an *uncertainty defect*; characterizing the defect in terms of the spectrum of singular minors would interpolate between MDS and arbitrary invertible matrices.

2. **Structured MDS families.** Identify when structured matrices (circulant, Cauchy, Hankel) are MDS, giving determinantal criteria that feed directly into Theorem 6.1, with applications to lightweight diffusion layers in symmetric cryptography.

3. **Rectangular and over-complete generalizations.** Extend the equivalence to $m\times n$ generator matrices ($m<n$) where MDS means every $m\times m$ submatrix is invertible, aligning the statement with the full Singleton bound for $[n,k]$ codes and with measurement matrices in compressed sensing.

4. **Finite-field harmonic analysis.** Use Theorem 6.1 to systematically transfer sharp uncertainty results between Fourier-type MDS transforms and combinatorial coding bounds, including stability (approximate-support) versions.

---

## 11. Conclusion

We have proved that an $n\times n$ matrix over a field is Maximum Distance Separable if and only if every nonzero vector $f$ satisfies $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1$, that this bound is the best possible for any invertible matrix, and that MDS is closed under transpose. The result places coding theory, the Donoho–Stark uncertainty principle, and the determinantal structure of submatrices on a single, elementary, fully verified footing.
