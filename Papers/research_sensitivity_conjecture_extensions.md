# The Spectral Core of the Sensitivity Conjecture: Signed Adjacency Matrices of the Hypercube

**Author:** Aristotle
**Date:** 2026-07-01

## Abstract

The Sensitivity Conjecture, posed by Nisan and Szegedy in 1992, asserted that
the sensitivity of a Boolean function is polynomially related to its other
standard complexity measures — block sensitivity, decision-tree depth,
certificate complexity, and polynomial degree. It resisted proof for nearly
three decades until Huang's 2019 argument reduced it to a single spectral fact
about a signed adjacency matrix of the Boolean hypercube. In this paper we
isolate and rigorously develop that spectral core. We study the family of signed
adjacency matrices $A_n$ of the $n$-dimensional hypercube $Q_n$, defined by the
block recursion $A_0 = (0)$ and $A_{n+1} = \left(\begin{smallmatrix} A_n & I \\
I & -A_n\end{smallmatrix}\right)$. Our central result is the *spectral identity*
$A_n^2 = n\,I$, from which we derive a complete package of structural
consequences: $A_n$ is symmetric with zero trace; every entry lies in
$\{-1,0,1\}$; the matrix is $n$-regular (each row has exactly $n$ nonzero
entries and squared row-norm $n$); every eigenvalue $\mu$ satisfies $\mu^2 = n$,
hence $|\mu| = \sqrt{n}$; the squared determinant equals $n^{\,2^n}$; and for
$n \ge 1$ the matrix is invertible with $A_n^{-1} = n^{-1} A_n$. We complement
the algebraic development with a purely combinatorial proof of $n$-regularity in
the symmetric-difference model of $Q_n$, establishing that the two encodings
agree. Together these facts constitute exactly the hypotheses that Cauchy
interlacing consumes to yield the $\sqrt{n}$ maximum-degree bound underlying the
resolution of the conjecture. We discuss the outstanding interlacing step,
sharpness, local face conditions on admissible sign patterns, and extremal
determinant questions.

**Keywords:** sensitivity conjecture, Boolean functions, hypercube, signed
adjacency matrix, spectral graph theory, Cauchy interlacing, eigenvalues,
block recursion.

---

## 1. Introduction

### 1.1 Boolean functions and sensitivity

A **Boolean function** on $n$ variables is a map $f\colon \{0,1\}^n \to
\{0,1\}$. Boolean functions are the fundamental objects of computational
complexity: circuits, formulas, and decision procedures all compute Boolean
functions, and their difficulty is quantified by a family of *complexity
measures*.

Fix an input $x \in \{0,1\}^n$. The **sensitivity** of $f$ at $x$, written
$s(f,x)$, is the number of coordinates $i$ such that flipping the $i$-th bit
changes the output:
$$
s(f,x) \;=\; \#\{\, i \in \{1,\dots,n\} : f(x) \neq f(x^{\oplus i}) \,\},
$$
where $x^{\oplus i}$ denotes $x$ with its $i$-th bit toggled. The
**sensitivity** of $f$ is $s(f) = \max_x s(f,x)$.

A more permissive notion allows flipping disjoint *blocks* of coordinates. The
**block sensitivity** $bs(f)$ is the maximum, over inputs $x$, of the largest
number of pairwise disjoint blocks $B_1,\dots,B_k \subseteq \{1,\dots,n\}$ such
that flipping all coordinates in $B_j$ changes $f(x)$ for each $j$. Because a
single coordinate is a block, $s(f) \le bs(f)$ always.

### 1.2 The conjecture

By the early 1990s a web of polynomial equivalences had been established among
$bs(f)$, decision-tree depth $D(f)$, certificate complexity $C(f)$, and the real
polynomial degree $\deg(f)$: any one of these bounds every other by a fixed
polynomial. Sensitivity was the conspicuous exception. The **Sensitivity
Conjecture** (Nisan–Szegedy, 1992) asserted that sensitivity also belongs to
this equivalence class: there is an absolute constant $c$ with
$$
bs(f) \;\le\; s(f)^{\,c}
$$
for all Boolean functions $f$. Since $s(f) \le bs(f)$ is trivial, the content is
the reverse polynomial bound.

### 1.3 The Gotsman–Linial reduction

Gotsman and Linial (1992) recast the conjecture as a statement about the
geometry of the hypercube. Model the input space $\{0,1\}^n$ as the vertex set of
the **$n$-dimensional hypercube** $Q_n$, in which two vertices are adjacent iff
they differ in exactly one coordinate. Their theorem states that the Sensitivity
Conjecture is equivalent to the following: every induced subgraph of $Q_n$ on
more than half the vertices — that is, on at least $2^{n-1}+1$ vertices —
contains a vertex of degree at least $\sqrt{n}$. Equivalently, writing
$\Delta(H)$ for the maximum degree of an induced subgraph $H$, one has
$$
\max\bigl(\Delta(H),\ \Delta(Q_n \setminus H)\bigr) \;\ge\; \sqrt{n}
$$
for every vertex subset. This purely combinatorial statement, once proved, yields
$bs(f) \le s(f)^4$.

### 1.4 Huang's spectral method and the goal of this paper

Huang (2019) proved the induced-subgraph statement by exhibiting a **signed
adjacency matrix** $A_n$ of $Q_n$ — a matrix with the same support as the
ordinary adjacency matrix but with signs attached to the nonzero entries — such
that $A_n^2 = nI$. This pins the spectrum of $A_n$ to $\{\pm\sqrt{n}\}$, and
Cauchy interlacing then delivers the degree bound.

This paper isolates the **spectral core** of that method and develops it with
full rigor. Our contributions are:

1. A clean recursive construction of $A_n$ over a $2^n$-element index type built
   so that the block recursion is literal, enabling transparent inductions
   (Section 2).
2. A complete, self-contained proof of the spectral identity $A_n^2 = nI$
   (Section 3, Theorem 3.1).
3. A structural package derived from the identity: symmetry, zero trace,
   $\{-1,0,1\}$-entries, $n$-regularity, the $\pm\sqrt{n}$ spectral gap, the
   determinant formula $(\det A_n)^2 = n^{2^n}$, and invertibility with
   $A_n^{-1} = n^{-1}A_n$ for $n \ge 1$ (Sections 3–4).
4. An independent combinatorial proof that $Q_n$ is $n$-regular in the
   symmetric-difference model, confirming the two encodings agree (Section 5).

We then explain precisely how these facts feed the interlacing step (Section 6)
and outline the open questions they sharpen (Section 8).

---

## 2. The signed adjacency matrix

### 2.1 An index type matched to the recursion

To make the block recursion definitional rather than a manipulation of
$\{0,1\}^n$ index arithmetic, we index the $2^n$ vertices of $Q_n$ by a type
$H_n$ defined recursively:
$$
H_0 = \{\ast\}, \qquad H_{n+1} = H_n \sqcup H_n,
$$
where $\sqcup$ denotes disjoint union. Then $|H_n| = 2^n$, and a $2^{n+1} \times
2^{n+1}$ matrix indexed by $H_{n+1}$ decomposes canonically into four
$2^n \times 2^n$ blocks indexed by the two copies of $H_n$.

### 2.2 Definition

Let $I$ denote the identity matrix of the appropriate size, and let $\left(
\begin{smallmatrix} P & Q \\ R & S \end{smallmatrix}\right)$ denote the block
matrix over $H_n \sqcup H_n$ with the indicated blocks.

**Definition 2.1 (Signed adjacency matrix).** The signed adjacency matrices
$A_n$ of $Q_n$ are the real matrices indexed by $H_n$ defined by
$$
A_0 = (0), \qquad
A_{n+1} = \begin{pmatrix} A_n & I \\ I & -A_n \end{pmatrix}.
$$

Unfolding the recursion, $A_1 = \left(\begin{smallmatrix} 0 & 1 \\ 1 &
0\end{smallmatrix}\right)$ and
$$
A_2 = \begin{pmatrix} 0 & 1 & 1 & 0 \\ 1 & 0 & 0 & -1 \\ 1 & 0 & 0 & 1 \\ 0 &
-1 & 1 & 0 \end{pmatrix}.
$$
One checks directly that $A_1^2 = I$ and $A_2^2 = 2I$, illustrating the identity
proved in general below. The support of $A_n$ (its pattern of nonzero entries)
coincides with the ordinary adjacency matrix of $Q_n$; only the signs differ.

---

## 3. The spectral identity and its immediate corollaries

### 3.1 The squaring identity

**Theorem 3.1 (Spectral identity).** For every $n \ge 0$,
$$
A_n^2 = n\,I.
$$

*Proof.* By induction on $n$. For $n = 0$, $A_0 = (0)$ and $A_0^2 = (0) = 0\cdot
I$. Assume $A_n^2 = nI$. Using block multiplication,
$$
A_{n+1}^2 =
\begin{pmatrix} A_n & I \\ I & -A_n \end{pmatrix}
\begin{pmatrix} A_n & I \\ I & -A_n \end{pmatrix}
=
\begin{pmatrix} A_n^2 + I & A_n - A_n \\ A_n - A_n & I + A_n^2 \end{pmatrix}.
$$
The off-diagonal blocks are $A_n - A_n = 0$. By the induction hypothesis each
diagonal block equals $A_n^2 + I = nI + I = (n+1)I$. Hence $A_{n+1}^2 = (n+1)I$,
completing the induction. $\qquad\blacksquare$

The identity is the load-bearing fact of the entire theory; the results below are
its consequences (sometimes together with symmetry and the entry
classification).

### 3.2 Symmetry

**Proposition 3.2 (Symmetry).** For every $n$, $A_n^{\mathsf T} = A_n$.

*Proof.* Induction on $n$. The base case is trivial. For the step, transposing a
block matrix transposes each block and swaps the off-diagonal positions:
$$
A_{n+1}^{\mathsf T} =
\begin{pmatrix} A_n^{\mathsf T} & I^{\mathsf T} \\ I^{\mathsf T} & -A_n^{\mathsf
T} \end{pmatrix}
=
\begin{pmatrix} A_n & I \\ I & -A_n \end{pmatrix}
= A_{n+1},
$$
using $I^{\mathsf T} = I$ and the induction hypothesis $A_n^{\mathsf T} = A_n$.
$\qquad\blacksquare$

Because $A_n$ is a real symmetric matrix, the spectral theorem guarantees its
eigenvalues are real and it is orthogonally diagonalizable. This legitimizes all
subsequent talk of a real spectrum.

### 3.3 Zero trace

**Proposition 3.3 (Zero trace).** For every $n$, $\operatorname{tr} A_n = 0$.

*Proof.* Induction on $n$. The base case has $\operatorname{tr} A_0 = 0$. The
trace of a block matrix is the sum of the traces of its diagonal blocks, so
$\operatorname{tr} A_{n+1} = \operatorname{tr} A_n + \operatorname{tr}(-A_n) =
\operatorname{tr} A_n - \operatorname{tr} A_n = 0$. $\qquad\blacksquare$

Since $\operatorname{tr} A_n$ equals the sum of the eigenvalues, and (by Section
4) every eigenvalue is $\pm\sqrt{n}$, the zero trace forces the multiplicities of
$+\sqrt{n}$ and $-\sqrt{n}$ to be equal — each $2^{n-1}$ when $n \ge 1$. This
perfect balance is what makes the interlacing bound tight.

### 3.4 Entry classification

**Proposition 3.4 (Signed adjacency entries).** Every entry of $A_n$ lies in
$\{-1, 0, 1\}$.

*Proof.* Induction on $n$. The single entry of $A_0$ is $0$. Each entry of
$A_{n+1}$ is either an entry of $A_n$, an entry of $-A_n$, or an entry of $\pm
I$ (namely $0$ or $1$). By the induction hypothesis entries of $A_n$ lie in
$\{-1,0,1\}$, and negation preserves this set. $\qquad\blacksquare$

This confirms that $A_n$ is a *genuine* signed adjacency matrix — its absolute
value entrywise is the ordinary $\{0,1\}$ adjacency matrix of $Q_n$ — so the
spectral phenomena are properties of the cube with signs, not artifacts of the
encoding.

---

## 4. The spectrum, determinant, and inverse

### 4.1 Row norms and regularity

**Proposition 4.1 (Squared row-norm).** For every vertex $v$,
$\sum_{w} A_n(v,w)^2 = n$.

*Proof.* The $(v,v)$ entry of $A_n^2$ equals $\sum_w A_n(v,w) A_n(w,v)$. By
symmetry (Proposition 3.2) this is $\sum_w A_n(v,w)^2$. By the spectral identity
(Theorem 3.1) the $(v,v)$ entry of $A_n^2 = nI$ is $n$. $\qquad\blacksquare$

**Corollary 4.2 ($n$-regularity).** Each row of $A_n$ has exactly $n$ nonzero
entries.

*Proof.* By Proposition 3.4 every entry $A_n(v,w) \in \{-1,0,1\}$, so
$A_n(v,w)^2 \in \{0,1\}$ and equals $1$ exactly when the entry is nonzero. Thus
$\sum_w A_n(v,w)^2$ counts the nonzero entries in row $v$, and by Proposition
4.1 this count is $n$. $\qquad\blacksquare$

Since the support of $A_n$ is the adjacency matrix of $Q_n$, Corollary 4.2 is the
statement that $Q_n$ is $n$-regular: every vertex has exactly $n$ neighbors.

### 4.2 The spectral gap

**Theorem 4.3 (Spectral gap).** Let $\mu$ be any (real) eigenvalue of $A_n$ with
eigenvector $v \neq 0$. Then $\mu^2 = n$, and consequently $|\mu| = \sqrt{n}$.

*Proof.* Apply $A_n$ twice: $A_n^2 v = A_n(\mu v) = \mu^2 v$. By the spectral
identity $A_n^2 v = nIv = n v$. Hence $\mu^2 v = n v$, and since $v \neq 0$ we
conclude $\mu^2 = n$, so $|\mu| = \sqrt{n}$. $\qquad\blacksquare$

Combined with symmetry (real spectrum) and zero trace (balanced multiplicities),
Theorem 4.3 shows the spectrum of $A_n$ is contained in $\{-\sqrt{n},
+\sqrt{n}\}$ with equal multiplicities for $n \ge 1$.

### 4.3 Determinant

**Proposition 4.4 (Squared determinant).** For every $n$,
$(\det A_n)^2 = n^{\,2^n}$.

*Proof.* Taking determinants in $A_n^2 = nI$ and using multiplicativity,
$(\det A_n)^2 = \det(A_n^2) = \det(nI) = n^{\dim} = n^{\,2^n}$, since $A_n$ is a
$2^n \times 2^n$ matrix. $\qquad\blacksquare$

### 4.4 Invertibility

**Proposition 4.5 (Inverse).** For every $n \ge 1$, $A_n$ is invertible with
$$
A_n^{-1} = \tfrac{1}{n}\, A_n.
$$

*Proof.* By Theorem 3.1, $A_n \cdot \bigl(\tfrac1n A_n\bigr) = \tfrac1n A_n^2 =
\tfrac1n (nI) = I$, and likewise on the other side. For $n \ge 1$ the scalar
$\tfrac1n$ is defined, so $\tfrac1n A_n$ is a genuine two-sided inverse.
$\qquad\blacksquare$

That a matrix is a scalar multiple of its own inverse is a signature of a
two-eigenvalue spectrum symmetric about $0$ — precisely the situation here.

---

## 5. The combinatorial model and agreement of encodings

The spectral development encodes $Q_n$ via the recursive index type $H_n$ and the
matrix $A_n$. It is important to confirm that this algebraic picture matches the
standard combinatorial model of the hypercube.

**The symmetric-difference model.** Represent a vertex of $Q_n$ as a subset $S
\subseteq \{1,\dots,n\}$ (the set of coordinates equal to $1$). Two vertices $A$
and $B$ are adjacent iff their symmetric difference $A \triangle B$ has exactly
one element — i.e. they differ in a single coordinate, Hamming distance $1$.

**Theorem 5.1 ($n$-regularity, combinatorially).** In the symmetric-difference
model, every vertex $A$ of $Q_n$ has exactly $n$ neighbors.

*Proof.* The neighbors of $A$ are precisely the sets $B$ with $|A \triangle B| =
1$. Now $|A \triangle B| = 1$ iff $A \triangle B = \{i\}$ for a unique $i \in
\{1,\dots,n\}$, and in that case $B = A \triangle \{i\}$ because symmetric
difference is an involution: $A \triangle (A \triangle B) = B$. Hence the
neighbor set of $A$ is exactly the image of the map
$$
\varphi\colon \{1,\dots,n\} \to \text{vertices}, \qquad \varphi(i) = A
\triangle \{i\}.
$$
The map $\varphi$ is injective: if $A \triangle \{i\} = A \triangle \{j\}$, then
left-cancellation of $A$ (again by the involution property) gives $\{i\} =
\{j\}$, so $i = j$. An injection from an $n$-element set has an $n$-element
image, so $A$ has exactly $n$ neighbors. $\qquad\blacksquare$

The map $\varphi$ is precisely "toggle coordinate $i$", establishing a bijection
between the $n$ coordinate directions and the $n$ neighbors of $A$. These are
exactly the $n$ off-diagonal $\pm 1$ entries in row $A$ of the signed matrix, so
Theorem 5.1 and Corollary 4.2 are two proofs — one geometric, one spectral — of
the same regularity fact. The two encodings of $Q_n$ therefore agree on the
degree of every vertex, confirming that $A_n$ really is a signed version of the
hypercube adjacency matrix.

---

## 6. From the spectral core to the sensitivity bound

We now record how the established facts drive Huang's degree bound; this is the
one step that additionally requires the classical interlacing theorem.

**Cauchy interlacing.** Let $M$ be a real symmetric $N \times N$ matrix with
eigenvalues $\lambda_1 \ge \dots \ge \lambda_N$, and let $B$ be a principal
$m \times m$ submatrix (obtained by deleting rows and the corresponding columns)
with eigenvalues $\beta_1 \ge \dots \ge \beta_m$. Then for each $i$,
$$
\lambda_{i} \;\ge\; \beta_i \;\ge\; \lambda_{i + N - m}.
$$
In particular $\beta_1 \ge \lambda_{1 + N - m}$: the largest eigenvalue of the
submatrix is at least the $(N-m+1)$-th largest eigenvalue of the whole matrix.

**The degree bound.** Take $M = A_n$, so $N = 2^n$. By Theorem 4.3 and the
symmetry and zero-trace balance (Propositions 3.2, 3.3), $A_n$ has eigenvalue
$+\sqrt{n}$ with multiplicity $2^{n-1}$. Let $H$ be any set of $m = 2^{n-1}+1$
vertices and let $B = A_n[H]$ be the corresponding principal submatrix. Since
$m > 2^{n-1}$, the index $N - m + 1 = 2^{n-1} \le$ the multiplicity range of
$+\sqrt{n}$, so interlacing gives $\beta_1 \ge \lambda_{2^{n-1}} = \sqrt{n}$.
Thus the largest eigenvalue of $B$ is at least $\sqrt{n}$.

Finally, $B$ is a symmetric matrix all of whose entries lie in $\{-1,0,1\}$
(Proposition 3.4). For such a matrix the largest eigenvalue is at most the
maximum row-sum of absolute values, i.e. at most the maximum number of nonzero
entries in a row. Hence some row of $B$ has at least $\sqrt{n}$ nonzero entries,
meaning some vertex of $H$ has at least $\sqrt{n}$ neighbors inside $H$. This is
exactly the Gotsman–Linial statement, and it yields the Sensitivity Conjecture
with $bs(f) \le s(f)^4$.

The present work establishes every ingredient of this deduction except the
interlacing inequality and the exact multiplicity $2^{n-1}$ of $+\sqrt{n}$; these
are the natural next targets (Section 8).

---

## 7. Algorithms

The construction is fully explicit and lends itself to direct computation. We
describe the two core procedures.

**Algorithm A (Recursive assembly of $A_n$).** Build $A_n$ by the block
recursion. Starting from the $1\times 1$ zero matrix, repeatedly assemble the
$2^{k+1}\times 2^{k+1}$ matrix from four $2^k\times 2^k$ blocks $A_k$, $I$, $I$,
$-A_k$. The cost is dominated by the final assembly, $\Theta(4^n) = \Theta(N^2)$
entries where $N = 2^n$.

**Algorithm B (Certified verification of the structural package).** Given $A_n$,
verify each theorem numerically: compute $A_n^2$ and check equality with $nI$;
check $A_n^{\mathsf T} = A_n$; sum the diagonal for the trace; scan entries for
membership in $\{-1,0,1\}$; count nonzero entries per row for regularity; compute
eigenvalues and confirm $\mu^2 = n$; compute the determinant and compare its
square with $n^{2^n}$; and check $A_n \cdot (\tfrac1n A_n) = I$. Each check is
$O(N^2)$ except eigenvalue and determinant computation, which are $O(N^3)$.

These procedures are implemented in the accompanying numerical demonstrations.

---

## 8. Discussion and future directions

The results above establish the spectral core of Huang's method as a
self-contained package: a symmetric $\{-1,0,1\}$-matrix, $n$-regular, squaring to
$nI$, with zero trace, determinant square $n^{2^n}$, and inverse $n^{-1}A_n$.
Every eigenvalue is pinned to $\pm\sqrt{n}$. The following directions build on
this foundation.

**1. Exact eigenvalue multiplicities and the interlacing bound.** We conjecture
the signed hypercube operator has precisely two eigenvalues, $+\sqrt{n}$ and
$-\sqrt{n}$, each of multiplicity exactly $2^{n-1}$; consequently every induced
subgraph on strictly more than half the vertices contains a vertex of degree at
least $\sqrt{n}$. A symmetric operator squaring to $nI$ with vanishing trace is
forced into a perfectly balanced two-eigenvalue spectrum, and Cauchy interlacing
converts that balance directly into a maximum-degree lower bound. The squaring
identity, symmetry, zero trace, and $n$-regularity — exactly the hypotheses
interlacing needs — are now all established; only the interlacing step itself
remains to complete a fully self-contained degree–sensitivity theorem.

**2. Sharpness of the $\sqrt{n}$ gap.** We conjecture the $\sqrt{n}$
maximum-degree bound is asymptotically tight: there exist induced subgraphs on
just over half the vertices whose maximum degree is $(1+o(1))\sqrt{n}$, so no
signed-adjacency argument can improve the exponent beyond $1/2$. The extremal
configurations are governed by the same eigenvectors that realize the
$\pm\sqrt{n}$ eigenvalues, so the spectral bound and the extremal combinatorial
construction are two views of a single eigenspace. With the spectrum provably
confined to $\pm\sqrt{n}$, the extremal question becomes a concrete search for
near-optimal vertex subsets.

**3. Weighted and biased hypercubes.** We conjecture that replacing each $\pm1$
edge weight by an independent sign pattern that is *consistent around every
square face* still yields an operator squaring to $nI$; conversely, any
face-inconsistent pattern strictly lowers the spectral radius. The squaring
identity is equivalent to a local face condition — each two-dimensional face must
carry an odd number of $-1$ edges — so the global spectral gap is a purely local,
checkable property. The block recursion makes the face condition explicit at
every step.

**4. Determinant growth and lattice volume.** We conjecture the squared
determinant $n^{2^n}$ is the extremal value among all $\{-1,0,1\}$ symmetric
matrices supported on the hypercube edge set; any such matrix with a different
support has strictly smaller $|\det|$.

---

## 9. Conclusion

Huang's resolution of the Sensitivity Conjecture rests on a single spectral
miracle — a signed adjacency matrix of the hypercube whose square is a scalar.
By isolating that miracle and its structural consequences, we have exhibited the
complete algebraic engine of the argument: the identity $A_n^2 = nI$, symmetry,
zero trace, $\{-1,0,1\}$ entries, $n$-regularity (proved both spectrally and
combinatorially), the $\pm\sqrt{n}$ spectral gap, the determinant formula, and
the explicit inverse. These are exactly the hypotheses that the interlacing step
consumes, so the path to a fully self-contained degree–sensitivity theorem is now
clearly marked. The signs that Huang added to the cube are not a technical
convenience but the whole point: they enforce, through a local face condition, a
global two-valued spectrum on an object of exponential size.
