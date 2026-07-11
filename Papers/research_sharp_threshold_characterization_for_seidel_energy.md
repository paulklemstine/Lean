# A Sharp Threshold for the Seidel-Energy Increase of Complete Bipartite Graphs Under Edge Deletion

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

The Seidel matrix of a simple graph $G$ on $v$ vertices is the symmetric $\pm 1$
matrix $S = J - I - 2A$, where $A$ is the adjacency matrix, $I$ the identity, and
$J$ the all-ones matrix; its entries are $0$ on the diagonal, $-1$ across adjacent
pairs, and $+1$ across non-adjacent pairs. The Seidel energy of $G$ is
$\mathcal{E}(G) = \sum_i |\lambda_i|$, the sum of the absolute values of the
eigenvalues of $S$. We give exact closed-form spectra and Seidel energies for the
complete bipartite graph $K_{m,n}$ and for the graph obtained by deleting a single
edge from it. Using the rank-one identity $S = w w^{\top} - I$ for a $\pm 1$ weight
vector $w$, we show $\mathcal{E}(K_{m,n}) = 2(m+n-1)$. Modeling a single edge
deletion as a rank-three perturbation of $-I$, we show that the deleted graph has
characteristic polynomial $(X+1)^{m+n-3}(X-1)(X^2-(m+n-4)X-(3(m+n)-7))$ and energy
$\mathcal{E}(K_{m,n}-e) = (m+n-2) + \sqrt{(m+n-2)(m+n+6)}$. Comparing the two
formulas yields a sharp criterion: the Seidel energy strictly increases under a
single edge deletion **if and only if $m+n \ge 4$**. This refutes a published
conjecture that the correct threshold is "both parts of size at least $3$": the
graph $K_{2,2}$ already exhibits a strict increase, from $6$ to $2+2\sqrt5$, with
both parts of size $2$.

**Keywords:** Seidel matrix, Seidel energy, complete bipartite graph, edge
deletion, rank-one perturbation, matrix determinant lemma, characteristic
polynomial, sharp threshold.

## 1. Introduction

Graph energies compress the spectral content of a graph into a single scalar. The
oldest and best known, the *graph energy* $\sum_i|\mu_i|$ of the adjacency matrix,
was introduced by Gutman as a mathematical proxy for the total $\pi$-electron
energy of conjugated hydrocarbons. Many variants have since been studied by
replacing the adjacency matrix with a different graph matrix. The **Seidel energy**
$\mathcal{E}(G)$ uses the Seidel matrix $S = J - I - 2A$, a matrix that is central
to the theory of two-graphs, regular two-graphs, equiangular lines, and switching
classes, precisely because it is (up to a controlled transformation) invariant
under Seidel switching and behaves symmetrically under graph complementation.

A natural line of inquiry asks how a graph energy responds to *local* modifications
such as adding or deleting a single edge. For the adjacency energy, edge addition
does not always increase the energy, and delicate monotonicity questions arise. The
Seidel energy poses analogous questions. In particular, a published conjecture
concerning complete bipartite graphs $K_{m,n}$ proposed that $\mathcal{E}(K_{m,n})$
strictly increases under any single edge deletion *if and only if* both parts have
size at least $3$, motivated by sufficient conditions verified for pairs such as
$(3,6)$, $(6,3)$, $(2,15)$, $(15,2)$, and $(4,4)$.

In this paper we compute both relevant Seidel energies in closed form and settle
the question exactly. The complete bipartite Seidel matrix has an exceptionally
simple rank-one structure, and a single edge deletion perturbs it by rank three;
in both cases the spectrum, and hence the energy, is completely determined by a
core problem of size at most $3\times 3$. The upshot is a clean, sharp threshold
that depends only on the total number of vertices $m+n$, and a concrete refutation
of the "both parts $\ge 3$" conjecture.

### Contributions

1. An exact Seidel spectrum and energy of $K_{m,n}$:
   $\mathcal{E}(K_{m,n}) = 2(m+n-1)$ (Theorem 4.2).
2. An exact characteristic polynomial and Seidel energy of $K_{m,n}$ with one edge
   deleted: $\mathcal{E}(K_{m,n}-e) = (m+n-2)+\sqrt{(m+n-2)(m+n+6)}$
   (Theorems 5.4 and 5.6).
3. A sharp threshold: the Seidel energy strictly increases under a single edge
   deletion if and only if $m+n \ge 4$ (Theorem 6.1).
4. A refutation of the "both parts $\ge 3$" conjecture, witnessed explicitly by
   $K_{2,2}$ with $\mathcal{E}=6 \to 2+2\sqrt5$ (Theorem 6.3).

## 2. Preliminaries and definitions

Throughout, all matrices are real and symmetric, and "graph" means a finite simple
graph.

**Definition 2.1 (Seidel matrix).** Let $G$ be a simple graph on vertex set $V$
with adjacency matrix $A$. The *Seidel matrix* of $G$ is the symmetric matrix $S$
with
$$S_{ij} = \begin{cases} 0 & i = j, \\ -1 & i \ne j \text{ and } i \sim j, \\ +1 & i \ne j \text{ and } i \not\sim j. \end{cases}$$
Equivalently $S = J - I - 2A$, with $J$ the all-ones matrix and $I$ the identity.

**Definition 2.2 (Seidel energy).** For a symmetric matrix $M$ with real
eigenvalues $\lambda_1,\dots,\lambda_v$, its *energy* is $\sum_i |\lambda_i|$. The
*Seidel energy* of $G$ is $\mathcal{E}(G) = \sum_i |\lambda_i|$ where the
$\lambda_i$ are the eigenvalues of the Seidel matrix of $G$.

**Definition 2.3 (Complete bipartite graph).** For $m,n \ge 0$, the complete
bipartite graph $K_{m,n}$ has vertex set $L \sqcup R$ with $|L|=m$, $|R|=n$, and an
edge between $x$ and $y$ if and only if $x$ and $y$ lie in different parts. We index
the vertices by $\{1,\dots,m\}\sqcup\{1,\dots,n\}$.

We will use two standard facts from linear algebra, stated here for reference.

**Lemma 2.4 (Energy via the characteristic polynomial).** Let $M$ be a real
symmetric $v\times v$ matrix with characteristic polynomial $p(X)=\det(XI-M)$. Then
$p$ splits over $\mathbb{R}$ with its multiset of roots equal to the multiset of
eigenvalues of $M$, and consequently
$$\sum_i |\lambda_i| = \sum_{r\,\in\,\mathrm{roots}(p)} |r|.$$

*Proof sketch.* $M$ is orthogonally diagonalizable with real eigenvalues, so
$p(X)=\prod_i (X-\lambda_i)$ and the root multiset (with multiplicity) coincides
with the eigenvalue multiset. Summing $|\cdot|$ over the two identical multisets
gives the claim. $\qquad\blacksquare$

Lemma 2.4 is the crucial *bridge*: it converts an analytic quantity (a sum over
eigenvalues) into an algebraic one (a sum over roots of a determinantal
polynomial), which is what makes the low-rank determinant computations below
directly usable for computing energy.

**Lemma 2.5 (Characteristic polynomial of a low-rank product).** Let $U$ be
$v\times k$ and $W$ be $k\times v$ with $k \le v$. Then
$$\det(XI_v - UW) = X^{\,v-k}\det(XI_k - WU).$$
In particular, for any scalar $c$, $\det\bigl(XI_v - (cI_v + UW)\bigr)$ can be
reduced, after the substitution $X \mapsto X-c$, to a determinant of size $k\times
k$. This is the matrix-determinant (Weinstein–Aronszajn) identity in
characteristic-polynomial form.

## 3. The Seidel matrix of $K_{m,n}$ as a rank-one perturbation

Assign to each vertex a weight: $+1$ to the vertices of $L$ and $-1$ to those of
$R$, and collect these into the vector $w \in \{\pm1\}^{m+n}$.

**Proposition 3.1.** The Seidel matrix of $K_{m,n}$ is
$$S = w\,w^{\top} - I.$$

*Proof.* For $i \ne j$, the $(i,j)$ entry of $w w^{\top}$ is $w_i w_j$, which is
$+1$ when $i,j$ lie in the same part (non-adjacent in $K_{m,n}$) and $-1$ when they
lie in different parts (adjacent). This matches the off-diagonal Seidel entries. On
the diagonal $w_i w_i = 1$, and subtracting $I$ gives $0$, matching the diagonal.
$\qquad\blacksquare$

Since $w$ has $m+n$ entries each equal to $\pm1$, we record the elementary but
essential fact
$$w \cdot w = m+n. \tag{3.1}$$

## 4. Spectrum and energy of $K_{m,n}$

**Theorem 4.1 (Characteristic polynomial of $K_{m,n}$).** For $m+n\ge 1$,
$$\det(XI - S) = (X+1)^{\,m+n-1}\bigl(X-(m+n-1)\bigr).$$

*Proof.* Write $S = ww^{\top} - I$. By Lemma 2.5 applied with $U = w$ (a
$v\times 1$ matrix) and $W = w^{\top}$,
$$\det\bigl(XI - ww^{\top}\bigr) = X^{\,v-1}\bigl(X - w\cdot w\bigr) = X^{\,v-1}(X-(m+n)),$$
using $(3.1)$ and $v = m+n$. Shifting by the scalar $-I$ replaces $X$ by $X+1$:
$$\det(XI - S) = \det\bigl((X+1)I - ww^{\top}\bigr) = (X+1)^{\,m+n-1}\bigl((X+1)-(m+n)\bigr),$$
which equals $(X+1)^{\,m+n-1}(X-(m+n-1))$. $\qquad\blacksquare$

Thus the Seidel spectrum of $K_{m,n}$ is $\{\,m+n-1\,\}$ together with $-1$ of
multiplicity $m+n-1$.

**Theorem 4.2 (Seidel energy of $K_{m,n}$).** For $m+n\ge 1$,
$$\mathcal{E}(K_{m,n}) = 2(m+n-1).$$

*Proof.* By Lemma 2.4 and Theorem 4.1, the energy is the sum of $|\cdot|$ over the
roots: the root $m+n-1 \ge 0$ contributes $m+n-1$, and the root $-1$ with
multiplicity $m+n-1$ contributes $(m+n-1)\cdot 1$. The total is $2(m+n-1)$.
$\qquad\blacksquare$

## 5. Deleting a single edge

Fix an edge of $K_{m,n}$: since all edges are cross-edges, take the pair $\{a,b\}$
with $a\in L$ and $b\in R$. Deleting it flips the two Seidel entries at positions
$(a,b)$ and $(b,a)$ from $-1$ to $+1$; that is,
$$S' = S + 2\bigl(E_{ab} + E_{ba}\bigr), \tag{5.1}$$
where $E_{xy}$ is the matrix with a single $1$ in position $(x,y)$.

### 5.1 A rank-three factorization

Let $e_a, e_b$ be the standard indicator vectors of the vertices $a$ and $b$.
Assemble the $v\times 3$ matrix $U = [\,w \mid e_a \mid e_b\,]$ and the fixed
$3\times 3$ core
$$K = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 0 & 2 \\ 0 & 2 & 0 \end{pmatrix}.$$

**Proposition 5.1.** $\;S' + I = U\,K\,U^{\top}.$

*Proof.* Expanding $U K U^{\top}$ gives
$w w^{\top} + 2\,e_a e_b^{\top} + 2\,e_b e_a^{\top}$: the top-left $1$ of $K$
reproduces $w w^{\top}$, and the off-diagonal $2$'s produce
$2(e_a e_b^{\top} + e_b e_a^{\top}) = 2(E_{ab}+E_{ba})$. By $(5.1)$ and
Proposition 3.1, this equals $S + 2(E_{ab}+E_{ba}) + I = S' + I$. $\qquad\blacksquare$

**Proposition 5.2 (Gram matrix of the columns).**
$$U^{\top}U = \begin{pmatrix} m+n & 1 & -1 \\ 1 & 1 & 0 \\ -1 & 0 & 1 \end{pmatrix}.$$

*Proof.* Direct computation: $w\cdot w = m+n$ by $(3.1)$; $w\cdot e_a = w_a = +1$
(since $a\in L$); $w\cdot e_b = w_b = -1$ (since $b\in R$); $e_a\cdot e_a = e_b\cdot
e_b = 1$; and $e_a\cdot e_b = 0$ since $a\ne b$. $\qquad\blacksquare$

### 5.2 Characteristic polynomial of the deleted graph

**Lemma 5.3.** Writing $N=m+n$, the $3\times 3$ matrix
$$P = K\,(U^{\top}U) = \begin{pmatrix} N & 1 & -1 \\ -2 & 0 & 2 \\ 2 & 2 & 0 \end{pmatrix}$$
has characteristic polynomial
$$\det(XI_3 - P) = X^3 - N X^2 + (4N - 8).$$

*Proof.* Multiply $K$ by the Gram matrix of Proposition 5.2 to obtain $P$, then
expand the $3\times 3$ determinant $\det(XI_3-P)$ and collect terms. $\qquad\blacksquare$

**Theorem 5.4 (Characteristic polynomial of $K_{m,n}-e$).** For $m+n\ge 3$,
$$\det(XI - S') = (X+1)^{\,m+n-3}\,(X-1)\,\bigl(X^2-(m+n-4)X-(3(m+n)-7)\bigr).$$

*Proof.* Write $S' = (S'+I) - I$. By Proposition 5.1, $S'+I = U(K U^{\top})$, a
product of a $v\times 3$ and a $3\times v$ matrix. Applying Lemma 2.5 with the
shift by $-I$ (i.e. $X\mapsto X+1$),
$$\det(XI - S') = \det\bigl((X+1)I - U(KU^{\top})\bigr)
= (X+1)^{\,v-3}\,\det\bigl((X+1)I_3 - K U^{\top}U\bigr),$$
where we used $\det(YI_v - U(KU^\top)) = Y^{v-3}\det(YI_3 - (KU^\top)U)$ and
$(KU^\top)U = K(U^\top U)$. By Lemma 5.3 the $3\times 3$ determinant equals the
polynomial $X^3 - NX^2 + (4N-8)$ evaluated at $X\mapsto X+1$. A direct expansion of
$(X+1)^3 - N(X+1)^2 + (4N-8)$ factors as
$$(X-1)\bigl(X^2 - (N-4)X - (3N-7)\bigr),$$
which, together with the $(X+1)^{v-3} = (X+1)^{m+n-3}$ factor, gives the claim.
$\qquad\blacksquare$

The spectrum of $K_{m,n}-e$ is therefore: $-1$ with multiplicity $m+n-3$; the
simple eigenvalue $+1$; and the two roots of the quadratic
$q(X) = X^2 - (N-4)X - (3N-7)$.

### 5.3 The energy of the deleted graph

**Lemma 5.5 (Roots of the quadratic factor).** With $N=m+n\ge 3$, the discriminant
of $q(X) = X^2-(N-4)X-(3N-7)$ is
$$(N-4)^2 + 4(3N-7) = N^2 + 4N - 12 = (N-2)(N+6) \ge 0,$$
so $q$ has real roots $\dfrac{(N-4)\pm\sqrt{(N-2)(N+6)}}{2}$. Moreover, for
$N\ge 3$ the larger root is nonnegative and the smaller root is nonpositive, and
the sum of their absolute values is exactly $\sqrt{(N-2)(N+6)}$.

*Proof.* The discriminant identity is a direct expansion. Since $N\ge 3$ we have
$3N-7 \ge 2 > 0$, so the product of the roots, $-(3N-7)$, is negative; hence one
root is positive and one is negative. If $r_+ \ge 0 \ge r_-$, then
$|r_+| + |r_-| = r_+ - r_- = \sqrt{(N-2)(N+6)}$, the difference of the two roots.
$\qquad\blacksquare$

**Theorem 5.6 (Seidel energy of $K_{m,n}-e$).** For $m+n\ge 3$,
$$\mathcal{E}(K_{m,n}-e) = (m+n-2) + \sqrt{(m+n-2)(m+n+6)}.$$

*Proof.* By Lemma 2.4 and Theorem 5.4, sum $|\cdot|$ over the roots. The eigenvalue
$-1$ of multiplicity $m+n-3$ contributes $m+n-3$; the eigenvalue $+1$ contributes
$1$; and by Lemma 5.5 the two quadratic roots contribute
$\sqrt{(m+n-2)(m+n+6)}$. The total is
$(m+n-3) + 1 + \sqrt{(m+n-2)(m+n+6)} = (m+n-2) + \sqrt{(m+n-2)(m+n+6)}$.
$\qquad\blacksquare$

## 6. The sharp threshold and the refutation

**Theorem 6.1 (Sharp threshold).** Let $m+n\ge 3$. Deleting a single edge from
$K_{m,n}$ strictly increases the Seidel energy if and only if $m+n\ge 4$:
$$\mathcal{E}(K_{m,n}) < \mathcal{E}(K_{m,n}-e) \iff m+n \ge 4.$$

*Proof.* Put $N=m+n$. By Theorems 4.2 and 5.6, the strict-increase inequality reads
$$2(N-1) < (N-2) + \sqrt{(N-2)(N+6)},$$
which is equivalent to $N < \sqrt{(N-2)(N+6)}$. Since both sides are nonnegative for
$N\ge 3$, squaring preserves the inequality: $N^2 < (N-2)(N+6) = N^2 + 4N - 12$,
i.e. $4N > 12$, i.e. $N > 3$. As $N$ is an integer $\ge 3$, this is exactly
$N \ge 4$. $\qquad\blacksquare$

**Remark 6.2.** The criterion depends only on the total number of vertices $m+n$,
not on the balance between the two parts. Every previously verified sufficient case
— $(3,6)$, $(6,3)$, $(2,15)$, $(15,2)$, $(4,4)$ — has $m+n\ge 4$ and is therefore
consistent with Theorem 6.1, but none of these is the actual boundary.

We now state and refute the conjecture.

**Conjecture (published form).** For every complete bipartite graph $K_{m,n}$ with
$m+n\ge 3$ and every single edge deletion,
$$\mathcal{E}(K_{m,n}) < \mathcal{E}(K_{m,n}-e) \iff (m\ge 3 \text{ and } n\ge 3).$$

**Theorem 6.3 (The conjecture is false).** The conjecture fails. Explicitly,
$K_{2,2}$ has both parts of size $2$, yet
$$\mathcal{E}(K_{2,2}) = 6 \quad < \quad 2 + 2\sqrt5 = \mathcal{E}(K_{2,2}-e).$$

*Proof.* By Theorem 4.2, $\mathcal{E}(K_{2,2}) = 2(2+2-1) = 6$. By Theorem 5.6 with
$m=n=2$ (so $N=4$),
$$\mathcal{E}(K_{2,2}-e) = (4-2) + \sqrt{(4-2)(4+6)} = 2 + \sqrt{20} = 2 + 2\sqrt5 \approx 6.472.$$
Since $6 < 2+2\sqrt5$, the energy strictly increases although neither part has size
$\ge 3$. Thus the biconditional in the conjecture fails for $(m,n)=(2,2)$. By
Theorem 6.1 the correct threshold is $m+n\ge 4$. $\qquad\blacksquare$

## 7. Algorithmic summary

The results yield a constant-time exact evaluator for both energies, requiring only
the sizes $m,n$:

1. **Base energy.** Return $2(m+n-1)$.
2. **Deleted energy.** Return $(m+n-2) + \sqrt{(m+n-2)(m+n+6)}$.
3. **Threshold test.** Return "increase" iff $m+n\ge 4$.

The spectra themselves are equally cheap: for $K_{m,n}$ the eigenvalues are
$m+n-1$ (once) and $-1$ (multiplicity $m+n-1$); for $K_{m,n}-e$ they are $-1$
(multiplicity $m+n-3$), $+1$, and the two roots of $X^2-(m+n-4)X-(3(m+n)-7)$. Both
can be validated against a direct numerical eigenvalue solver for small $m,n$.

## 8. Applications

Exact, local-edit-sensitive spectral invariants are valuable in several settings.
Graph energies serve as molecular descriptors in mathematical chemistry, as
robustness and complexity measures for networks, and as invariants in the study of
strongly regular graphs, two-graphs, and equiangular line systems, where the Seidel
matrix is the natural object. Knowing the *exact* effect of removing one edge — and
that this effect is governed by a clean threshold in the total order — provides
tight quantitative control that approximate bounds cannot. The rank-one and
rank-three reductions also illustrate a general and reusable computational
principle: energies of highly structured graphs are frequently governed by a
constant-size core problem.

## 9. Discussion and future work

The engine behind every result is the reduction of a spectral question to a
constant-size determinant. The intact Seidel matrix is a rank-one perturbation of
$-I$; a single edge deletion makes it rank three; and Lemma 2.5 collapses each to a
core of matching size. The energy, an analytic sum of $|\lambda_i|$, is pinned down
purely algebraically through the roots of the characteristic polynomial via Lemma
2.4. This bridge between the analytic and algebraic descriptions of energy is what
makes the low-rank determinant machinery applicable.

Several directions extend the method:

1. **Arbitrary edge sets.** Deleting $k$ pairwise-disjoint cross edges is a
   rank-$(2k+1)$ perturbation of $-I$, so the same reduction yields a
   $(2k+1)\times(2k+1)$ core determinant and, presumably, a closed threshold in
   $(m,n,k)$.
2. **Complete multipartite graphs.** The Seidel matrix of $K_{n_1,\dots,n_t}$ is a
   rank-$t$ perturbation of $-I$, so its energy and edge-deletion behaviour should
   follow from a $t\times t$ core.
3. **General monotonicity.** Formalizing McClelland- and Koolen–Moulton-type
   bounds and characterizing which graph families are Seidel-energy monotone under
   edge deletion.
4. **A reusable toolkit.** Extracting the identity "energy $=$ sum of $|\cdot|$ over
   the roots of the characteristic polynomial," together with the rank-one and
   rank-$r$ determinant recipes, into a standalone graph-energy library.

## 10. Conclusion

For complete bipartite graphs, both the Seidel energy $\mathcal{E}(K_{m,n}) =
2(m+n-1)$ and the single-edge-deleted energy $\mathcal{E}(K_{m,n}-e) = (m+n-2) +
\sqrt{(m+n-2)(m+n+6)}$ admit exact closed forms. Comparing them reveals a sharp
threshold: the Seidel energy strictly increases under a single edge deletion if and
only if $m+n\ge 4$. This depends only on the total number of vertices, and it
refutes the conjectured "both parts $\ge 3$" criterion, with $K_{2,2}$ providing an
explicit counterexample ($6 \to 2+2\sqrt5$).
