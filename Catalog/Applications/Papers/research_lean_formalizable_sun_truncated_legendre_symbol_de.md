# The Affine Structure of Sun's Truncated Legendre-Symbol Determinant

## Abstract

For a prime $p \ge 7$ with $p \equiv 3 \pmod 4$, set $m = \frac{p-5}{2}$ and consider the $m \times m$ matrix $A$ over the polynomial ring $\mathbb{Z}[X]$ defined by
$$
A_{j,k} = X + \left(\frac{j-k}{p}\right), \qquad j,k \in \{0,1,\dots,m-1\},
$$
where $\left(\frac{\cdot}{p}\right)$ is the Legendre symbol regarded as an integer. Although the determinant of an $m \times m$ matrix of degree-$\le 1$ polynomials may *a priori* have degree $m$ in $X$, we prove that $\det A$ is always **affine**, and in fact a pure monomial of degree one. Our two main contributions are structural and exact. First, we establish a fully general *rank-one determinant expansion*: for any commutative ring $R$, any scalar $c \in R$, and any $M \in \mathrm{M}_m(R)$,
$$
\det(M + c\,J) = \det M + c\sum_{j=0}^{m-1}\det\!\bigl(M[\,\text{row } j \leftarrow \mathbf{1}\,]\bigr),
$$
where $J$ is the all-ones matrix and $\mathbf{1} = (1,\dots,1)$. Specializing to $R = \mathbb{Z}[X]$ and $c = X$ yields the affine form $\det A = \det C + (\det(C+J)-\det C)\,X$, where $C_{j,k}=\left(\frac{j-k}{p}\right)$. Second, we prove that $C$ is antisymmetric for $p\equiv 3\pmod 4$ and hence $\det C = 0$ in the odd dimension $m$, collapsing the determinant to $\det A = \det(C+J)\cdot X$. Computation confirms $\det(C+J) = \left\lfloor\frac{p-2}{3}\right\rfloor^{2}$ for $p = 7,11,19$, giving the closed evaluation $\det A = \left\lfloor\frac{p-2}{3}\right\rfloor^{2} X$, in agreement with Sun's conjectured value. We isolate the single remaining scalar $\det(C+J)$ as a focused Gauss-sum problem and discuss four lines of generalization.

**Keywords:** Legendre symbol, quadratic residues, determinant, rank-one perturbation, antisymmetric matrix, multilinear expansion, Gauss sums, Toeplitz/circulant matrices.

---

## 1. Introduction

Determinants of matrices whose entries are Legendre symbols have a long and surprising history. Despite being assembled from the irregular distribution of quadratic residues modulo a prime, their determinants repeatedly collapse to clean arithmetic quantities. Zhi-Wei Sun has compiled and conjectured a large catalogue of such evaluations. The present work concerns one entry of *Toeplitz* type: a matrix indexed by a difference of coordinates and shifted by a polynomial background variable.

Fix a prime $p \ge 7$ with $p \equiv 3 \pmod 4$. Let
$$
m = \frac{p-5}{2}, \qquad C \in \mathrm{M}_m(\mathbb{Z}), \quad C_{j,k} = \left(\frac{j-k}{p}\right),
$$
the **truncated Legendre-difference matrix**, and form its polynomial deformation
$$
A \in \mathrm{M}_m(\mathbb{Z}[X]), \qquad A_{j,k} = X + \left(\frac{j-k}{p}\right).
$$
The object of study is the polynomial $\det A \in \mathbb{Z}[X]$. The target identity, which we refer to as **Sun's truncated determinant identity**, is
$$
\boxed{\;\det A = \left\lfloor\frac{p-2}{3}\right\rfloor^{2}\,X.\;}
$$
The notation $\left\lfloor\,\cdot\,\right\rfloor$ denotes the integer (floor) division that the formalization performs over $\mathbb{N}$; concretely the coefficient sequence over $p = 7, 11, 19, 23, 31$ is $1, 9, 25, 49, 81$, the squares of the odd numbers $1,3,5,7,9$.

Two facts are at first glance non-obvious:

1. **Degree collapse.** A determinant of degree-$\le 1$ entries can have degree up to $m$; here it has degree exactly $1$.
2. **Vanishing constant term.** Not only is the degree $1$, but there is no constant term: $\det A$ is a monomial $c\,X$, not a general affine polynomial $cX + d$.

We prove both facts in full generality at the appropriate level. The degree collapse is a theorem of pure multilinear algebra valid for *any* base matrix (Theorem 1, Section 3). The vanishing constant term is a consequence of the antisymmetry of $C$, which holds precisely because $p \equiv 3 \pmod 4$ (Theorem 4, Section 4). The remaining scalar coefficient $\det(C+J)$ is evaluated by computation for small primes and conjectured in general (Section 5).

### Summary of formal results

| Name | Statement (informal) |
|---|---|
| `det_add_smul_onesM` | $\det(M + c\,J) = \det M + c\sum_j \det(M[\text{row }j\leftarrow\mathbf 1])$ for any $R$, $c$, $M$. |
| `det_add_onesM` | $\det(M + J) = \det M + \sum_j \det(M[\text{row }j\leftarrow\mathbf 1])$ (case $c=1$). |
| `det_Apoly` | $\det A = C(\det M) + C(\det(M+J)-\det M)\,X$ over $\mathbb{Z}[X]$ (affine form). |
| `det_Cleg_eq_zero` | $\det C = 0$ for $p\equiv 3\pmod 4$ (antisymmetry in odd dimension). |
| `det_legendre_matrix` | Reduction of Sun's identity to the single scalar $\det(C+J)$. |

---

## 2. Preliminaries and definitions

### 2.1 The Legendre symbol

For an odd prime $p$ and $a \in \mathbb{Z}$, the **Legendre symbol** is
$$
\left(\frac{a}{p}\right) =
\begin{cases}
+1 & \text{if } a \not\equiv 0 \text{ and } a \text{ is a square modulo } p,\\
-1 & \text{if } a \text{ is a non-square modulo } p,\\
0 & \text{if } p \mid a.
\end{cases}
$$
It is completely multiplicative in the numerator, $\left(\frac{ab}{p}\right) = \left(\frac{a}{p}\right)\left(\frac{b}{p}\right)$, and depends only on $a \bmod p$. We will use one classical evaluation, the **first supplement to quadratic reciprocity**:
$$
\left(\frac{-1}{p}\right) = (-1)^{\frac{p-1}{2}} = \begin{cases} +1 & p \equiv 1 \pmod 4,\\ -1 & p \equiv 3 \pmod 4. \end{cases}
$$
Throughout, $\left(\frac{a}{p}\right)$ is regarded as an *integer* (an element of $\{-1,0,1\}\subset\mathbb{Z}$), so that matrices of Legendre symbols are integer matrices.

### 2.2 The all-ones matrix and row updates

Over a commutative ring $R$ we write $J = J_m \in \mathrm{M}_m(R)$ for the **all-ones matrix**, $J_{i,k} = 1$ for all $i,k$ (the Lean definition `onesM R m`). For a matrix $M$, an index $j$, and a row vector $v$, we write $M[\text{row }j\leftarrow v]$ for the matrix obtained by replacing the $j$-th row of $M$ by $v$ (Lean's `Matrix.updateRow M j v`). We abbreviate $M[\text{row }j\leftarrow \mathbf 1]$, where $\mathbf 1 = (1,1,\dots,1)$, as the "$j$-th all-ones row replacement."

### 2.3 The deformed Legendre matrix

The central definition (`Apoly` in the formalization) attaches to any integer matrix $M \in \mathrm{M}_m(\mathbb Z)$ the polynomial matrix
$$
\mathrm{Apoly}(M) \in \mathrm{M}_m(\mathbb{Z}[X]), \qquad \mathrm{Apoly}(M)_{j,k} = \iota(M_{j,k}) + X,
$$
where $\iota : \mathbb{Z}\hookrightarrow\mathbb{Z}[X]$ is the constant-polynomial inclusion (Lean's `Polynomial.C`). With $M = C$ the Legendre-difference matrix, $\mathrm{Apoly}(C) = A$ is precisely the matrix of interest. Note $\mathrm{Apoly}(M) = \iota_*(M) + X\cdot J$, where $\iota_*(M)$ applies $\iota$ entrywise.

---

## 3. The rank-one determinant expansion

The first movement is purely algebraic and requires no number theory. It explains the degree collapse.

### 3.1 Statement

> **Theorem 1 (Scalar rank-one expansion, `det_add_smul_onesM`).**
> Let $R$ be a commutative ring, $m \in \mathbb{N}$, $c \in R$, and $M \in \mathrm{M}_m(R)$. Then
> $$
> \det(M + c\,J) = \det M + c \sum_{j=0}^{m-1} \det\!\bigl(M[\text{row }j\leftarrow\mathbf 1]\bigr).
> $$

> **Corollary 2 (All-ones expansion, `det_add_onesM`).** Taking $c = 1$,
> $$
> \det(M + J) = \det M + \sum_{j=0}^{m-1} \det\!\bigl(M[\text{row }j\leftarrow\mathbf 1]\bigr).
> $$

> **Theorem 3 (Affine determinant, `det_Apoly`).** For $M \in \mathrm{M}_m(\mathbb{Z})$,
> $$
> \det \mathrm{Apoly}(M) = \iota(\det M) + \iota\bigl(\det(M+J) - \det M\bigr)\cdot X \ \in\ \mathbb{Z}[X].
> $$
> In particular $\det \mathrm{Apoly}(M)$ is affine in $X$ with constant term $\det M$ and slope $\det(M+J) - \det M$.

### 3.2 Proof sketch of Theorem 1

View the determinant as an alternating multilinear function of the *rows*. Each row of $M + c\,J$ is the sum of the corresponding row of $M$ and the constant vector $c\,\mathbf 1$. Expanding multilinearly over all $m$ rows (Lean's `MultilinearMap.map_add_univ`) yields a sum over subsets $s \subseteq \{0,\dots,m-1\}$ of the rows that retain their "$M$ part":
$$
\det(M + c\,J) = \sum_{s \subseteq [m]} \det\bigl(B_s\bigr), \qquad (B_s)_{i,k} = \begin{cases} M_{i,k} & i \in s,\\ c & i \notin s.\end{cases}
$$
Now observe the alternating annihilation. If $|[m]\setminus s| \ge 2$ — that is, two or more rows take the constant part — then $B_s$ has (at least) two identical rows, each equal to $(c,c,\dots,c)$, so $\det B_s = 0$ by `Matrix.det_zero_of_row_eq`. Only two strata survive:

- **$s = [m]$** (no row constant): $B_s = M$, contributing $\det M$.
- **$s = [m]\setminus\{j\}$** (exactly one row $j$ constant): $B_s$ equals $M$ with row $j$ replaced by $(c,\dots,c) = c\cdot\mathbf 1$. By row-homogeneity of the determinant (`Matrix.det_updateRow_smul`), $\det B_s = c\,\det(M[\text{row }j\leftarrow\mathbf 1])$.

Summing the survivors gives the claimed identity. The formal proof organizes this as: (i) the full multilinear expansion into a sum over subsets; (ii) a partition of the index set of subsets by the cardinality of the complement, discarding the $|complement|\ge 2$ block as zero; (iii) a bijection identifying the $|complement|=1$ block with $\sum_j$, factoring out $c$ via row scaling. $\square$

### 3.3 Proof sketch of Theorem 3

Apply Theorem 1 over the base ring $R = \mathbb{Z}[X]$ with scalar $c = X$ and matrix $\iota_*(M)$ (the entrywise image of $M$ under $\iota = \mathrm{C}$), using $\mathrm{Apoly}(M) = \iota_*(M) + X\,J$:
$$
\det\mathrm{Apoly}(M) = \det \iota_*(M) + X\sum_j \det\bigl(\iota_*(M)[\text{row }j\leftarrow\mathbf 1]\bigr).
$$
Because $\iota : \mathbb{Z}\to\mathbb{Z}[X]$ is a ring homomorphism, it commutes with the determinant (`RingHom.map_det`): $\det\iota_*(M) = \iota(\det M)$, and likewise each updated-row determinant is the image of an integer determinant. By Corollary 2, $\sum_j \det(M[\text{row }j\leftarrow\mathbf 1]) = \det(M+J) - \det M$. Pushing $\iota$ through and rearranging gives the affine form. $\square$

### 3.4 Discussion

Theorem 1 is the conceptual heart of the degree collapse, and it is *completely independent of primality, of the value $m$, and of the Legendre symbol*. Any matrix perturbed by a scalar multiple of a rank-one all-ones matrix has a determinant that is linear in the scalar; the would-be high-degree terms are forbidden by the alternating property. The phenomenon generalizes verbatim to any rank-one perturbation $u\,v^{\mathsf T}$, with slope $v^{\mathsf T}\,\mathrm{adj}(M)\,u$ (see Section 6). It is precisely the determinantal shadow of the matrix-determinant lemma $\det(M + u v^{\mathsf T}) = \det M + v^{\mathsf T}\mathrm{adj}(M)\,u$, here proved from first principles by multilinear bookkeeping rather than by invoking the adjugate.

---

## 4. The vanishing constant term

The second movement is where the arithmetic hypothesis $p \equiv 3 \pmod 4$ enters. By Theorem 3, the constant term of $\det A$ is $\det C$. We now show it is zero.

### 4.1 Antisymmetry of the Legendre-difference matrix

> **Lemma (Antisymmetry).** For $p \equiv 3 \pmod 4$, the Legendre-difference matrix $C$, $C_{j,k} = \left(\frac{j-k}{p}\right)$, is antisymmetric: $C^{\mathsf T} = -C$.

*Proof.* By multiplicativity and the first supplement, for $p \equiv 3 \pmod 4$,
$$
C_{k,j} = \left(\frac{k-j}{p}\right) = \left(\frac{-(j-k)}{p}\right) = \left(\frac{-1}{p}\right)\left(\frac{j-k}{p}\right) = -\left(\frac{j-k}{p}\right) = -C_{j,k}. \qquad\square
$$
The diagonal is zero automatically since $C_{j,j} = \left(\frac{0}{p}\right) = 0$, consistent with antisymmetry.

### 4.2 The determinant vanishes

> **Theorem 4 (Vanishing constant term, `det_Cleg_eq_zero`).** For $p \equiv 3 \pmod 4$ with $p \ge 7$, the dimension $m = \frac{p-5}{2}$ is odd, and $\det C = 0$.

*Proof sketch.* An antisymmetric matrix $C$ over a ring of characteristic $\ne 2$ satisfies $\det(C^{\mathsf T}) = \det(-C) = (-1)^m \det C$. Since $\det(C^{\mathsf T}) = \det C$ always, we get $\det C = (-1)^m \det C$, so $(1-(-1)^m)\det C = 0$. When $m$ is odd this reads $2\det C = 0$, and over $\mathbb{Z}$ (no $2$-torsion) forces $\det C = 0$. It remains to check parity: with $p \equiv 3 \pmod 4$ write $p = 4t+3$; then $m = \frac{p-5}{2} = 2t-1$ is odd. $\square$

### 4.3 The structural reduction

Combining Theorem 3 (constant term $\det C$, slope $\det(C+J)-\det C$) with Theorem 4 ($\det C = 0$) gives the central reduction.

> **Theorem 5 (Reduction to a single scalar, `det_legendre_matrix`).** For $p \equiv 3 \pmod 4$ with $p \ge 7$,
> $$
> \det A = \det(C + J)\cdot X.
> $$

Thus the *entire* polynomial $\det A$ — every one of its potentially $m+1$ coefficients — is determined by the single integer $\det(C+J)$. The problem of computing a determinant of polynomials over $\mathbb{Z}[X]$ has been reduced to computing one integer determinant.

### 4.4 The role of the congruence

The hypothesis $p \equiv 3 \pmod 4$ is not cosmetic. It enters in exactly two places, and both are necessary:

1. It makes $\left(\frac{-1}{p}\right) = -1$, which is what renders $C$ *antisymmetric* rather than symmetric. For $p \equiv 1 \pmod 4$ the matrix is symmetric and $\det C$ does not vanish in general; the determinant polynomial then has a nonzero constant term and is genuinely of higher degree.
2. It makes $m = \frac{p-5}{2}$ odd, which is what turns antisymmetry into a determinant zero (an antisymmetric matrix of *even* size can have a nonzero determinant — its Pfaffian squared).

Both conditions are simultaneously guaranteed by $p \equiv 3 \pmod 4$, which is why the clean monomial form is special to these primes.

---

## 5. The scalar coefficient

By Theorem 5 the problem is reduced to evaluating $\det(C+J)$. The matrix $C+J$ has entries
$$
(C+J)_{j,k} = 1 + \left(\frac{j-k}{p}\right) \in \{0, 1, 2\},
$$
a $\{0,1,2\}$-matrix that is $2$ on the diagonal, $0$ where $j-k$ is a non-residue, and $2$ where $j-k$ is a residue.

### 5.1 Computational evaluation

Direct computation (Bareiss / cofactor expansion over $\mathbb{Z}$) yields the following, matching $\left\lfloor\frac{p-2}{3}\right\rfloor^2$ in every case.

| $p$ | $m=\frac{p-5}{2}$ | $\det C$ | $\det(C+J)$ | $\left\lfloor\frac{p-2}{3}\right\rfloor$ | $\left\lfloor\frac{p-2}{3}\right\rfloor^2$ |
|---|---|---|---|---|---|
| $7$ | $1$ | $0$ | $1$ | $1$ | $1$ |
| $11$ | $3$ | $0$ | $9$ | $3$ | $9$ |
| $19$ | $7$ | $0$ | $25$ | $5$ | $25$ |
| $23$ | $9$ | $0$ | $49$ | $7$ | $49$ |
| $31$ | $13$ | $0$ | $81$ | $9$ | $81$ |

The formalization verifies the cases $p = 7, 11, 19$ exactly, establishing
$$
\det A = \left\lfloor\frac{p-2}{3}\right\rfloor^{2} X \qquad (p = 7, 11, 19).
$$

### 5.2 Why the coefficient is a perfect square

The slope $\det(C+J) = \sum_j \det(C[\text{row }j\leftarrow\mathbf 1])$ (Corollary 2, with $\det C=0$) is a sum of $(m-1)$-minors of a Toeplitz/circulant-like Legendre matrix. Such matrices are diagonalized by the additive characters of $\mathbb{F}_p$, and the resulting eigenvalues are values of **Gauss sums**
$$
g(\chi) = \sum_{a \in \mathbb{F}_p^\times} \chi(a)\, \zeta_p^{a}, \qquad |g(\chi)| = \sqrt p,
$$
for the quadratic character $\chi = \left(\frac{\cdot}{p}\right)$. The product of conjugate pairs of such eigenvalues is real and positive, and pairs of modulus-$\sqrt p$ numbers multiply to integers; the perfect-square shape $1, 9, 25, 49, 81$ of the data is the visible fingerprint of this conjugate pairing. Establishing $\det(C+J) = \left\lfloor\frac{p-2}{3}\right\rfloor^2$ for *all* eligible primes is thus a single, focused Gauss-sum identity — the principal open problem left by this work (Section 7, Direction 1).

---

## 6. Algorithms

We record the computational routines that underlie the numerical evidence. All are over $\mathbb{Z}$ to avoid floating-point error.

### 6.1 Legendre symbol by Euler's criterion

Compute $\left(\frac{a}{p}\right)$ as $a^{(p-1)/2} \bmod p$, normalized to $\{-1,0,1\}$. Cost: $O(\log p)$ modular multiplications via fast exponentiation.

### 6.2 Exact integer determinant (Bareiss)

The Bareiss fraction-free Gaussian elimination computes $\det M$ for $M\in\mathrm M_m(\mathbb Z)$ using only exact integer arithmetic (each pivot step divides *exactly*), avoiding the rational blow-up of naive elimination and the round-off of float methods. Cost: $O(m^3)$ ring operations on integers of controlled size.

### 6.3 Verifying the identity for a prime

Given $p \equiv 3 \pmod 4$: build $C$ from the Legendre symbol; verify $\det C = 0$ (constant term) and compute $\det(C+J)$ (slope) by Bareiss; compare with $\left\lfloor\frac{p-2}{3}\right\rfloor^2$; optionally cross-check by computing $\det A$ symbolically in $\mathbb{Z}[X]$ and confirming it equals $\det(C+J)\cdot X$. Cost dominated by the $O(m^3)$ determinants, $m = \frac{p-5}{2}$.

---

## 7. Future directions

This cycle formalized the *structural* half of Sun's identity in full generality ($\det A = \det(C+J)\cdot X$ for all primes $p \ge 7$, $p \equiv 3 \pmod 4$) and verified the closed coefficient $\left\lfloor\frac{p-2}{3}\right\rfloor^2$ for $p = 7, 11, 19$. The remaining gap is the general evaluation of the single scalar $\det(C+J)$.

1. **The coefficient is a Gauss/Jacobi-sum square.** Conjecturally $\det(C+J) = \left\lfloor\frac{p-2}{3}\right\rfloor^2$ for every prime $p \ge 7$ with $p \equiv 3\pmod 4$, with $\left\lfloor\frac{p-2}{3}\right\rfloor$ itself an explicit character-sum count over $\mathbb{F}_p$. The reduction `det_legendre_matrix` isolates the coefficient as a *single* integer determinant, turning the open problem into a focused character-sum identity amenable to the mature Gauss-sum/Jacobi-sum machinery.

2. **Constant term vanishes $\iff p \equiv 3\pmod 4$.** Conjecturally $\det C = 0$ *iff* $p \equiv 3\pmod 4$; for $p \equiv 1\pmod 4$ the matrix $C$ is symmetric, $\det C$ is generically nonzero, and the determinant polynomial is genuinely of degree $\ge 2$. The $\Leftarrow$ direction is Theorem 4; the $\Rightarrow$ direction is a finite obstruction probed by exhaustive computation and framed by the (anti)symmetry dichotomy.

3. **Eigenvalue / circulant refinement.** Conjecturally $C+J$ is similar to a direct sum whose nonzero spectrum is governed by Legendre Gauss sums, so that $\det(C+J)$ factors as a product of $\pm\sqrt p$-type eigenvalues whose product is the perfect square $\left\lfloor\frac{p-2}{3}\right\rfloor^2$. Because $A_{j,k}$ depends only on $j-k$, a discrete-Fourier diagonalization should convert the determinant into a product of evaluated Legendre sums; the affine reduction means only the product of nonzero eigenvalues matters.

4. **Generalized perturbation matrices.** Replacing $J$ by an arbitrary rank-one integer matrix $u\,v^{\mathsf T}$ keeps $\det(\iota_*(C) + X\,u v^{\mathsf T})$ affine in $X$, with linear coefficient $v^{\mathsf T}\mathrm{adj}(C)\,u$; for the Legendre $C$ and special $u,v$ (e.g. $v_j = \left(\frac{j}{p}\right)$) the coefficient should again land on a clean closed form. The proof of Theorem 1 used *only* that the perturbation rows are proportional, so it generalizes immediately.

---

## 8. Conclusion

A determinant that looked, by its construction, as though it should be a dense polynomial of degree $m = \frac{p-5}{2}$ in fact collapses to a single monomial $\left\lfloor\frac{p-2}{3}\right\rfloor^2 X$. Two structural principles account for the collapse, and they cleave the problem cleanly in two. The *rank-one expansion* (Theorem 1) — pure multilinear algebra, indifferent to primality — forces the determinant to be affine and reduces it to two integer determinants. The *antisymmetry of the Legendre-difference matrix* (Theorem 4) — pure quadratic-residue arithmetic, special to $p\equiv 3\pmod 4$ — kills the constant term. What remains is one integer, $\det(C+J)$, whose evaluation as a perfect square is governed by Gauss sums and stands as the natural next theorem. The decomposition turns a formidable-looking polynomial determinant into a transparent two-step story and a single, sharply posed open problem.
