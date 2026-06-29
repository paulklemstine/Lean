# An Exact Characterization of the Discrete Additive Uncertainty Principle via Maximum-Distance-Separable Matrices

**Author:** Aristotle

**Date:** 2026-06-20

## Abstract

We prove a complete equivalence between two a priori unrelated properties of a square matrix over an arbitrary field. On the algebraic side, a matrix $M \in F^{n\times n}$ is **Maximum Distance Separable (MDS)** when every square submatrix of $M$ — of every order $k$, for every choice of $k$ rows and $k$ columns — is invertible. On the analytic side, $M$ satisfies the **strongest additive uncertainty principle** when, for every nonzero $f \in F^n$, the supports of $f$ and of $Mf$ satisfy $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1$. Our main theorem states that these conditions are equivalent. The proof is constructive in both directions: the forward direction extracts a singular submatrix from any support-economical vector, and the converse inflates a kernel vector of a singular submatrix into an explicit bound-violating signal. We further establish that the threshold $n+1$ is tight (achieved by a unit spike whenever $M$ is invertible), that MDS implies invertibility, and that the MDS property is closed under transposition (coding-theoretic duality). The development unifies the Donoho–Stark uncertainty principle, Tao's prime-order Fourier uncertainty inequality, the Singleton bound for Reed–Solomon codes, and the elementary theory of invertible minors. All results are formalized and machine-checked with no axioms beyond the standard foundational core.

**Keywords:** MDS matrix, uncertainty principle, support, Singleton bound, Reed–Solomon codes, Donoho–Stark, Fourier uncertainty, submatrix determinant, sparsity.

## 1. Introduction

### 1.1 Motivation

Uncertainty principles assert that a nonzero object cannot be simultaneously concentrated in two conjugate representations. The continuous Heisenberg principle bounds the product of variances in position and momentum. Its discrete analogue, due to Donoho and Stark and sharpened for cyclic groups of prime order by Tao, replaces variance with the cardinality of the support and asserts an *additive* lower bound: a nonzero function on $\mathbb{Z}/p\mathbb{Z}$ and its discrete Fourier transform have supports summing to at least $p+1$.

A separate strand of mathematics, coding theory, studies **MDS codes** — codes meeting the Singleton bound, whose paradigmatic instance is the family of Reed–Solomon codes. The defining algebraic feature of an MDS generator/parity matrix is that all of its square submatrices are nonsingular.

This paper proves that the discrete additive uncertainty principle, in its *sharpest* form, is not merely *implied by* an MDS-type structure but is *logically equivalent* to it. The Fourier uncertainty inequality and the Singleton bound thereby become two instances of a single matrix-theoretic equivalence.

### 1.2 Contributions

1. A definition of MDS for square matrices over an arbitrary field via nonvanishing of all submatrix determinants (`IsMDS`), and a parametrized uncertainty predicate (`SatisfiesUncertainty`).
2. A pivotal *localization lemma* (`submatrix_mulVec_of_support`) relating a submatrix–vector product to a slice of the full matrix–vector product.
3. The forward implication (`mds_implies_uncertainty`): MDS $\Rightarrow$ the $n+1$ uncertainty bound.
4. The converse (`not_mds_implies_violator`): non-MDS $\Rightarrow$ an explicit vector violating the bound.
5. The main equivalence (`mds_iff_uncertainty`): MDS $\iff$ uncertainty at threshold $n+1$.
6. Tightness (`singleton_bound`), invertibility (`mds_invertible`), and transpose-closure (`mds_transpose`).

All statements are formalized over a generic field `[Field F] [DecidableEq F]` and verified to be free of `sorry`.

## 2. Definitions

Throughout, $F$ is a field and $n,k \in \mathbb{N}$. Vectors are functions $\mathrm{Fin}\,n \to F$ and matrices are functions $\mathrm{Fin}\,n \to \mathrm{Fin}\,n \to F$. For a matrix $M$ and injections (embeddings) $r : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$ (rows) and $c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$ (columns), the **submatrix** $M[r,c]$ is the $k\times k$ matrix $(i,j) \mapsto M(r\,i)(c\,j)$. We write $M \cdot f$ (or $Mf$) for the matrix–vector product $(M\cdot f)_i = \sum_j M_{ij} f_j$.

**Definition 2.1 (Support and zero set).** For $v : \mathrm{Fin}\,n \to F$,
$$\mathrm{supp}(v) = \{\, i : v_i \neq 0 \,\}, \qquad \mathrm{zeros}(v) = \{\, i : v_i = 0 \,\},$$
both regarded as finite subsets of $\mathrm{Fin}\,n$. Their cardinalities partition the index set:
$$|\mathrm{supp}(v)| + |\mathrm{zeros}(v)| = n. \tag{2.1}$$
(This identity is `vecSupport_card_add_vecZeros_card`.)

**Definition 2.2 (MDS matrix, `IsMDS`).** A square matrix $M \in F^{n\times n}$ is **Maximum Distance Separable** when
$$\forall k,\ \forall r : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n,\ \forall c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n, \quad \det\big(M[r,c]\big) \neq 0.$$
That is, every square submatrix of every order is invertible.

**Definition 2.3 (Uncertainty predicate, `SatisfiesUncertainty`).** For $b \in \mathbb{N}$, the matrix $M$ *satisfies the uncertainty bound* $b$ when
$$\forall f \neq 0, \quad |\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge b.$$
The maximal meaningful threshold is $b = n+1$; we call this the **strongest** additive uncertainty bound.

**Definition 2.4 (Uncertainty profile, `UncertaintyProfile`).** A certified record bundling a matrix $M$, a verified lower bound $b$, and a proof that $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge b$ for all nonzero $f$. This packages partial/quantitative uncertainty guarantees for matrices that need not be MDS; an MDS matrix admits a profile with $b = n+1$.

## 3. The Localization Lemma

The technical core relating local (submatrix) and global (full matrix) products is:

**Lemma 3.1 (Localization, `submatrix_mulVec_of_support`).** Let $M \in F^{n\times n}$, let $f : \mathrm{Fin}\,n \to F$, let $r : \mathrm{Fin}\,k \to \mathrm{Fin}\,n$ and let $c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$ be an embedding. Suppose $f$ is supported on the range of $c$, i.e. $f_j \neq 0 \Rightarrow j \in \mathrm{range}(c)$. Then for every $i$,
$$\big(M[r,c] \cdot (f\circ c)\big)_i = (M\cdot f)_{r\,i}.$$

*Proof sketch.* Expand the left side as $\sum_{j \in \mathrm{Fin}\,k} M_{(r\,i)(c\,j)} f_{c\,j}$. Reindex the sum over the image $c(\mathrm{Fin}\,k) \subseteq \mathrm{Fin}\,n$ using injectivity of $c$. Extend the summation to all of $\mathrm{Fin}\,n$: the added terms have index $j' \notin \mathrm{range}(c)$, where the support hypothesis forces $f_{j'} = 0$, so $M_{(r\,i)\,j'}\,f_{j'} = 0$. The extended sum is exactly $\sum_{j'} M_{(r\,i)\,j'} f_{j'} = (M\cdot f)_{r\,i}$. $\square$

This lemma is the single hinge used in *both* directions of the main theorem. It says: restricting attention to the columns where $f$ lives and the rows we care about reproduces a faithful slice of the global product.

## 4. Forward Direction: MDS Implies Uncertainty

**Theorem 4.1 (`mds_implies_uncertainty`).** If $M \in F^{n\times n}$ is MDS and $f \neq 0$, then
$$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1.$$

*Proof.* Assume for contradiction $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n$. Set $s = |\mathrm{supp}(f)|$. By (2.1) applied to $Mf$,
$$|\mathrm{zeros}(Mf)| = n - |\mathrm{supp}(Mf)| \ge n - (n - s) = s.$$
Hence there is a subset $T \subseteq \mathrm{zeros}(Mf)$ with $|T| = s$ (existence of a subset of prescribed cardinality). Choose:

- an embedding $r : \mathrm{Fin}\,s \hookrightarrow \mathrm{Fin}\,n$ with $\mathrm{range}(r) \subseteq T$ (so every $r\,i$ is a zero coordinate of $Mf$), and
- the order embedding $c : \mathrm{Fin}\,s \hookrightarrow \mathrm{Fin}\,n$ with $\mathrm{range}(c) = \mathrm{supp}(f)$ (the support has exactly $s$ elements).

Because $\mathrm{range}(c) = \mathrm{supp}(f)$, the vector $f$ vanishes outside $\mathrm{range}(c)$, so Lemma 3.1 applies: for all $i$,
$$\big(M[r,c]\cdot(f\circ c)\big)_i = (M\cdot f)_{r\,i} = 0,$$
the last equality because $r\,i \in T \subseteq \mathrm{zeros}(Mf)$. Thus $M[r,c]\cdot(f\circ c) = 0$. Since $M$ is MDS, $\det(M[r,c]) \neq 0$, so $M[r,c]$ is injective on vectors, forcing $f\circ c = 0$. But $\mathrm{range}(c) = \mathrm{supp}(f)$ means $f$ is nonzero precisely on $\mathrm{range}(c)$; $f\circ c = 0$ then forces $f = 0$, contradicting $f \neq 0$. $\square$

The crucial counting step is the inequality $|\mathrm{zeros}(Mf)| \ge s$, which converts a support-economy assumption into "enough zero rows to build a square block matching the support columns."

## 5. Converse Direction: Non-MDS Yields a Violator

**Theorem 5.1 (`not_mds_implies_violator`).** If $M \in F^{n\times n}$ is not MDS, then there exists $f \neq 0$ with
$$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n.$$

*Proof.* Non-MDS gives $k$, embeddings $r, c : \mathrm{Fin}\,k \hookrightarrow \mathrm{Fin}\,n$, and $\det(M[r,c]) = 0$. A square matrix of zero determinant has a nontrivial kernel, so there is $v \neq 0$ with $M[r,c]\cdot v = 0$. Define the inflation
$$f_i = \begin{cases} v_{c^{-1}(i)} & i \in \mathrm{range}(c), \\ 0 & \text{otherwise.}\end{cases}$$
Then $f \neq 0$ (since $v \neq 0$ and $c$ is injective), and $\mathrm{supp}(f) \subseteq \mathrm{range}(c)$, so
$$|\mathrm{supp}(f)| \le |\mathrm{range}(c)| = k. \tag{5.1}$$
Moreover $f$ vanishes outside $\mathrm{range}(c)$, so Lemma 3.1 gives, for every $i$,
$$(M\cdot f)_{r\,i} = \big(M[r,c]\cdot(f\circ c)\big)_i = \big(M[r,c]\cdot v\big)_i = 0,$$
using $f\circ c = v$. Hence $\mathrm{range}(r) \subseteq \mathrm{zeros}(Mf)$, and since $r$ is injective,
$$|\mathrm{zeros}(Mf)| \ge k \;\Longrightarrow\; |\mathrm{supp}(Mf)| = n - |\mathrm{zeros}(Mf)| \le n - k. \tag{5.2}$$
Adding (5.1) and (5.2): $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le k + (n-k) = n$. $\square$

## 6. The Main Equivalence

**Theorem 6.1 (MDS–Uncertainty Theorem, `mds_iff_uncertainty`).** For any $M \in F^{n\times n}$,
$$M \text{ is MDS} \iff M \text{ satisfies the uncertainty bound } n+1.$$

*Proof.* ($\Rightarrow$) Immediate from Theorem 4.1. ($\Leftarrow$) Contrapositive: if $M$ is not MDS, Theorem 5.1 produces $f \neq 0$ with support sum $\le n < n+1$, so the $n+1$ bound fails. $\square$

This is the paper's central result: the strongest additive uncertainty principle is a *complete invariant* of the MDS property, neither weaker nor stronger.

## 7. Tightness and Structural Corollaries

**Theorem 7.1 (Invertibility, `mds_invertible`).** If $M$ is MDS then $\det M \neq 0$.

*Proof.* Apply the MDS condition with $k = n$ and $r = c = \mathrm{id}$; then $M[r,c] = M$, so $\det M \neq 0$. $\square$

**Theorem 7.2 (Tightness / Singleton bound for uncertainty, `singleton_bound`).** If $n \ge 1$ and $\det M \neq 0$, there exists $f \neq 0$ with
$$|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \le n+1.$$

*Proof.* Take $f = e_0$, the unit spike at coordinate $0$: $|\mathrm{supp}(f)| = 1$. Then $Mf$ is the $0$-th column of $M$, with at most $n$ nonzero entries, so $|\mathrm{supp}(Mf)| \le n$. The sum is at most $1 + n = n+1$. $\square$

Together, Theorems 6.1 and 7.2 show the threshold $n+1$ is sharp: MDS matrices force every nonzero vector up to the value $n+1$ (Theorem 4.1), and the unit spike attains it (Theorem 7.2). No larger universal threshold is possible.

**Theorem 7.3 (Transpose closure, `mds_transpose`).** If $M$ is MDS then $M^{\mathsf T}$ is MDS.

*Proof.* A square submatrix $M^{\mathsf T}[r,c]$ equals $\big(M[c,r]\big)^{\mathsf T}$, and $\det(A^{\mathsf T}) = \det(A)$. Hence $\det\big(M^{\mathsf T}[r,c]\big) = \det\big(M[c,r]\big) \neq 0$ by MDS-ness of $M$. $\square$

Theorem 7.3 is the matrix expression of the coding-theoretic fact that the *dual* of an MDS code is again MDS.

## 8. Algorithms

The theory is constructive and yields directly implementable procedures.

### 8.1 MDS verification

To certify (or refute) MDS-ness of $M \in F^{n\times n}$, iterate over all orders $k = 1,\dots,n$, all $k$-subsets of rows, and all $k$-subsets of columns, computing each submatrix determinant. $M$ is MDS iff none vanish. The cost is $\sum_{k=1}^n \binom{n}{k}^2$ determinant evaluations — combinatorially expensive but exact; for structured families (Vandermonde, Cauchy) the determinants admit closed forms, collapsing the check to a non-collision condition on the defining nodes.

### 8.2 Violator construction

Given a *non*-MDS matrix, the proof of Theorem 5.1 is an algorithm: locate any singular submatrix $M[r,c]$, compute a kernel vector $v$ via Gaussian elimination, and inflate $v$ to a full vector by zero-padding outside $\mathrm{range}(c)$. The result is a certificate vector violating the $n+1$ bound. This converts the abstract converse into an explicit counterexample generator.

### 8.3 Profile certification

For an arbitrary matrix, the largest $b$ such that $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge b$ for all nonzero $f$ can be found (over a finite field) by minimizing the support sum across all nonzero vectors, or, more cheaply, by finding the smallest singular submatrix. The minimal value of $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)|$ equals $n+1$ minus the *uncertainty defect*, which is $0$ exactly for MDS matrices.

## 9. Applications

**Reed–Solomon codes and the Singleton bound.** Generator matrices of Reed–Solomon codes are Vandermonde-type and MDS. Theorem 6.1 re-expresses the Singleton bound (minimum distance $= n - k + 1$) as the additive uncertainty inequality, tying the code's error-correcting power to support arithmetic.

**Discrete Fourier uncertainty.** The DFT matrix over $\mathbb{Z}/p\mathbb{Z}$ for prime $p$ is MDS (all minors nonzero). Theorem 4.1 then yields Tao's inequality: a nonzero $f$ on $\mathbb{Z}/p\mathbb{Z}$ and its transform satisfy $|\mathrm{supp}(f)| + |\mathrm{supp}(\hat f)| \ge p+1$, the foundational fact behind exact sparse recovery and compressed sensing in the prime-cyclic setting.

**Compressed sensing and sparse recovery.** The impossibility of simultaneous sparsity guarantees uniqueness of sufficiently sparse solutions to underdetermined systems built from MDS/Fourier matrices, underpinning recovery guarantees.

**Network coding and distributed storage.** MDS matrices give the optimal redundancy–reliability trade-off; the equivalence offers a verification route through support spreading.

## 10. Discussion

The result is striking precisely because it is an *equivalence*. Many texts prove "MDS $\Rightarrow$ uncertainty" as a one-way consequence. By supplying an explicit converse via kernel inflation, we show the analytic and algebraic conditions are interchangeable. The proof is also notably elementary: a single localization lemma (Lemma 3.1), the partition identity (2.1), and the equivalence between zero determinant and nontrivial kernel suffice. No spectral theory, characters, or representation theory are required, so the statement holds over *any* field, including finite fields where Fourier-analytic methods are delicate.

A conceptual takeaway is that "every minor invertible" and "no double sparsity" are the *same* combinatorial constraint viewed through different lenses: the former counts vanishing determinants, the latter counts vanishing coordinates, and Lemma 3.1 is the exact bridge between them.

## 11. Future Work

Beyond the present development, several quantitative refinements and adjacent number-theoretic targets are natural. (The catalog's accompanying program of prime-gap conjectures — sharpened Bertrand bounds, mean-gap asymptotics, maximal-gap growth, Polignac-type infinitude, and safe-prime spacing — is recorded in the package metadata as forward-looking directions.) Within the present circle of ideas, promising extensions include:

- **Quantitative profiles.** Compute the exact uncertainty defect for structured non-MDS families and relate it to the size of the smallest singular submatrix.
- **Rectangular and partial-MDS generalizations.** Extend the equivalence to $m\times n$ generator matrices and to almost-MDS regimes (a controlled number of singular minors).
- **Field-dependence.** Characterize, for given $n$, the smallest field admitting an $n\times n$ MDS matrix (the MDS conjecture for codes), tying the uncertainty threshold to field size.
- **Robust/stable uncertainty.** Replace exact zero supports with $\varepsilon$-thresholded supports for numerical stability, yielding approximate uncertainty bounds for floating-point computation.

## 12. Conclusion

We have established that a square matrix over any field is Maximum Distance Separable if and only if it satisfies the strongest discrete additive uncertainty principle, $|\mathrm{supp}(f)| + |\mathrm{supp}(Mf)| \ge n+1$ for all nonzero $f$. The threshold is tight, MDS implies invertibility, and the property is transpose-stable. A single localization lemma drives both directions, unifying the Donoho–Stark uncertainty principle, the prime-order Fourier inequality, and the Singleton bound of coding theory under one elementary, fully verified equivalence.
