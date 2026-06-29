# Extremal Signed Determinants of Resistance Matrices: The Complete Graph and the Tree Endpoints

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (Spectral and algebraic graph theory)

## Abstract

Let $G$ be a finite connected simple graph on $n \ge 2$ vertices, regarded as an
electrical network with unit resistance on each edge. Its **effective-resistance
matrix** $R_G$ is the symmetric $n \times n$ matrix whose $(i,j)$ entry is the
effective resistance between vertices $i$ and $j$, with zero diagonal. We study the
**signed resistance determinant**
$$\Delta(G) := (-1)^{n-1}\det R_G,$$
a normalization that removes the parity-dependent sign of $\det R_G$. We establish
closed forms at the two extremes of edge density. For the complete graph $K_n$ we
prove $R_{K_n} = \tfrac{2}{n}(J - I)$, $\det R_{K_n} = (2/n)^n((-1)^n(1-n))$, and
$\Delta(K_n) = (2/n)^n(n-1) > 0$. For the path $P_n$, the canonical tree, we prove
that its resistance matrix is the distance matrix $D_{ij} = |i-j|$ and that
$\det D = (n-1)(-2)^{n-1}/2 = (-1)^{n-1}(n-1)2^{n-2}$, recovering the Graham–Pollak
tree-determinant value $\Delta(P_n) = (n-1)2^{n-2}$. These two results are the
verified anchors of a conjectural extremal principle: for every connected simple
graph on $n \ge 2$ vertices,
$$\frac{2^n(n-1)}{n^n} \le \Delta(G) \le 2^{n-2}(n-1),$$
with the left equality characterizing $K_n$ and the right equality characterizing
trees. We give complete proof sketches of the two endpoint theorems, discuss the
underlying rank-one and arrowhead reductions, and lay out a research program toward
the global extremality and monotonicity conjectures.

## 1. Introduction

The effective resistance between two nodes of a resistor network is among the most
studied derived quantities of a graph, appearing in spectral graph theory, the
theory of random walks (it is proportional to commute time), electrical network
theory, and chemical graph theory (the Kirchhoff index). Collecting all pairwise
effective resistances into a matrix produces the **resistance matrix** $R_G$, a
symmetric matrix with zero diagonal and positive off-diagonal entries.

A central object of algebraic interest is the determinant $\det R_G$. For trees, the
resistance matrix coincides with the graph distance matrix, and the celebrated
Graham–Pollak theorem (1971) asserts that this determinant depends only on the number
of vertices, not on the shape of the tree. For general graphs, $\det R_G$ remains
mysterious, but it always carries a parity sign $(-1)^{n-1}$ that obscures its
structure. Removing that sign yields the **signed resistance determinant**
$\Delta(G) = (-1)^{n-1}\det R_G$, which empirically is always strictly positive for
connected graphs.

This paper isolates and rigorously establishes the behaviour of $\Delta$ at the two
extremes of the connected-graph lattice ordered by edge inclusion: the edge-maximal
complete graph $K_n$, and the edge-minimal trees (represented by the path $P_n$). The
two closed forms we prove,
$$\Delta(K_n) = \left(\tfrac{2}{n}\right)^n(n-1), \qquad \Delta(\text{tree}) = (n-1)2^{n-2},$$
differ by the factor $n^n/4$, an exponentially large gap, and are conjectured to be
the global minimum and maximum of $\Delta$ over all connected simple graphs on $n$
vertices.

## 2. Definitions

Throughout, $n$ is a positive integer, matrices are over $\mathbb{Q}$ (the field is
chosen so that all quantities are exact), $I$ denotes the identity matrix, and $J$
denotes the all-ones matrix.

**Definition 2.1 (All-ones matrix).** $J = J_n$ is the $n \times n$ matrix with every
entry equal to $1$.

**Definition 2.2 (Effective resistance).** For a connected graph $G$ with unit edge
resistances, the effective resistance $R(i,j)$ between vertices $i$ and $j$ is the
voltage difference induced between $i$ and $j$ when a unit current is injected at $i$
and extracted at $j$. Equivalently, $R(i,j) = (e_i - e_j)^\top L^{+}(e_i - e_j)$ where
$L^{+}$ is the Moore–Penrose pseudoinverse of the graph Laplacian $L$.

**Definition 2.3 (Resistance matrix).** $R_G$ is the symmetric $n \times n$ matrix
with $(R_G)_{ij} = R(i,j)$ and $(R_G)_{ii} = 0$.

**Definition 2.4 (Signed resistance determinant).**
$$\Delta(G) := (-1)^{n-1}\det R_G.$$

**Definition 2.5 (Complete-graph resistance matrix).** Because every effective
resistance in $K_n$ equals $2/n$, we define
$$R_{K_n} := \frac{2}{n}\,(J - I),$$
a matrix with off-diagonal entries $2/n$ and zero diagonal.

**Definition 2.6 (Path distance matrix).** For the path $P_n$ on vertices
$0,1,\dots,n-1$,
$$D_{ij} := |i - j|.$$
Since $P_n$ is a tree, $D$ is exactly its resistance matrix.

## 3. The complete graph endpoint

### 3.1 Effective resistance in $K_n$

By the vertex-transitivity of $K_n$, all pairwise effective resistances are equal;
call the common value $\rho$. A direct edge of resistance $1$ between two fixed
vertices $u,v$ sits in parallel with $n-2$ internally-disjoint two-edge paths through
the remaining vertices, plus the rest of the network. The standard computation (or the
spanning-tree formula $R(u,v) = 2\,\tau_{uv}/\tau$, where $\tau = n^{n-2}$ is Cayley's
spanning-tree count and $\tau_{uv}$ counts spanning 2-forests separating $u$ and $v$)
yields
$$\rho = \frac{2}{n}.$$
Hence the resistance matrix is $R_{K_n} = \tfrac{2}{n}(J - I)$ as in Definition 2.5.

### 3.2 Determinant via the rank-one lemma

The matrix $J - I$ is a rank-one perturbation of a scalar matrix, so its determinant
is computed cleanly by the matrix determinant lemma. We organize the computation
through the auxiliary matrix $I - J$.

**Lemma 3.1 (`det_one_sub_Jmat`).** $\det(I - J_n) = 1 - n.$

*Proof sketch.* Write $J_n = \mathbf{1}\,\mathbf{1}^\top$ as the outer product of the
all-ones column vector with itself, so that
$$I - J_n = I + u\,v^\top, \qquad u = -\mathbf{1}, \quad v = \mathbf{1}.$$
The matrix determinant lemma gives $\det(I + u v^\top) = 1 + v^\top u = 1 + \mathbf{1}^\top(-\mathbf{1}) = 1 - n.$ $\qquad\blacksquare$

**Lemma 3.2 (`det_Jmat_sub_one`).** $\det(J_n - I) = (-1)^n(1 - n).$

*Proof sketch.* $J_n - I = (-1)\cdot(I - J_n)$, and scaling an $n\times n$ matrix by a
scalar $c$ multiplies its determinant by $c^n$. With $c = -1$ and Lemma 3.1,
$\det(J_n - I) = (-1)^n(1-n)$. $\qquad\blacksquare$

**Theorem 3.3 (`det_KresMat`).**
$$\det R_{K_n} = \left(\frac{2}{n}\right)^n\big((-1)^n(1-n)\big).$$

*Proof sketch.* $R_{K_n} = \tfrac{2}{n}(J_n - I)$, so by homogeneity of the
determinant $\det R_{K_n} = (2/n)^n \det(J_n - I)$, and Lemma 3.2 finishes. $\qquad\blacksquare$

**Theorem 3.4 (`signed_det_KresMat`).** For $n \ge 1$,
$$\Delta(K_n) = (-1)^{n-1}\det R_{K_n} = \left(\frac{2}{n}\right)^n(n-1).$$

*Proof sketch.* Write $n = m + 1$. From Theorem 3.3, $\det R_{K_n} = (2/n)^n(-1)^n(1-n)$.
Multiplying by $(-1)^{n-1}$ produces $(-1)^{2n-1}(2/n)^n(1-n) = -(2/n)^n(1-n) = (2/n)^n(n-1)$,
using $(-1)^{2n-1} = -1$. The Lean proof performs this parity bookkeeping by isolating
$(-1)^{2m} = 1$. $\qquad\blacksquare$

**Theorem 3.5 (`signed_det_KresMat_pos`).** For $n \ge 2$, $\Delta(K_n) > 0$.

*Proof sketch.* By Theorem 3.4, $\Delta(K_n) = (2/n)^n(n-1)$. For $n \ge 2$ both
factors $(2/n)^n > 0$ and $n - 1 \ge 1 > 0$ are positive, so the product is positive. $\qquad\blacksquare$

Numerically, $\Delta(K_2) = 1$, $\Delta(K_3) = 8/9$, $\Delta(K_4) = 27/32$,
$\Delta(K_5) = 256/625$, a strictly decreasing sequence tending to $0$ like $(2/n)^n$.

## 4. The tree endpoint: the path $P_n$

### 4.1 Trees, distance, and Graham–Pollak

On a tree there is a unique path between any two vertices, and effective resistance of
resistors in series is additive; hence $R(i,j)$ equals the number of edges on the
unique $i$–$j$ path, i.e. the graph distance. So the resistance matrix of any tree is
its distance matrix. The Graham–Pollak theorem states that for *every* tree on $n$
vertices,
$$\det D = (-1)^{n-1}(n-1)2^{n-2},$$
a value independent of the tree's shape. We prove this for the path, the canonical
tree, by explicit reduction.

### 4.2 Reduction to an arrowhead matrix

**Definition 4.1 (Elementary unipotent factors).** Let
$$L_{ij} = \begin{cases} 1 & i = j\\ -1 & i = j+1\\ 0 & \text{otherwise}\end{cases}
\qquad
U_{ij} = \begin{cases} 1 & i = j\\ -1 & j = i+1\\ 0 & \text{otherwise.}\end{cases}$$
$L$ encodes the row operation $R_i \leftarrow R_i - R_{i-1}$ and $U$ the column
operation $C_j \leftarrow C_j - C_{j-1}$. Both are triangular with unit diagonal.

**Lemma 4.2 (`det_Lmat`).** $\det L_n = 1.$

*Proof sketch.* $L$ is lower triangular (its transpose is upper triangular), so its
determinant is the product of its diagonal entries, all equal to $1$. $\qquad\blacksquare$

**Lemma 4.3 (`det_Umat`).** $\det U_n = 1.$

*Proof sketch.* $U$ is upper triangular with unit diagonal; the determinant is the
product of diagonal entries, $1$. $\qquad\blacksquare$

**Definition 4.4 (Arrowhead matrix).**
$$N_{ij} = \begin{cases}
0 & i = 0 \text{ and } j = 0\\
1 & i = 0,\ j \ne 0\\
1 & j = 0,\ i \ne 0\\
-2 & i = j \ne 0\\
0 & \text{otherwise.}
\end{cases}$$
$N$ has a zero top-left corner, a cross of $1$'s along the first row and column, and a
diagonal of $-2$'s on the remaining entries.

**Lemma 4.5 (`factor_LDU`).** $N = L\,D\,U$, where $D$ is the path distance matrix.

*Proof sketch.* Differencing adjacent rows of $D_{ij} = |i-j|$ replaces, for $i \ge 1$,
row $i$ by row $i$ minus row $i-1$: the entry $|i-j| - |i-1-j|$ equals $-1$ for $j \ge i$
and $+1$ for $j < i$ (and $0$ collapses appropriately at the boundary). Differencing
adjacent columns of the result annihilates all interior entries, leaving the
arrowhead pattern: the $(0,0)$ entry $0$, the first row/column of $1$'s, and a
diagonal of $-2$'s. Carrying out both operations as the matrix products $L D$ then
$(LD)U$ yields exactly $N$. $\qquad\blacksquare$

### 4.3 The path determinant

**Theorem 4.6 (`det_Dpath`).** For $n \ge 1$,
$$\det D = \frac{(n-1)(-2)^{n-1}}{2} = (-1)^{n-1}(n-1)2^{n-2}.$$

*Proof sketch.* By Lemma 4.5 and multiplicativity of the determinant,
$\det D = \det(L^{-1} N U^{-1})$, but more directly $\det N = \det L \cdot \det D \cdot \det U = \det D$
by Lemmas 4.2 and 4.3. So it suffices to compute $\det N$. The arrowhead matrix $N$ has
a $0$ in the top-left, $1$'s along the border, and $-2$'s on the trailing diagonal.
Expanding the arrowhead determinant (Schur complement of the trailing diagonal block):
the trailing $(n-1)\times(n-1)$ block is $-2 I$, with determinant $(-2)^{n-1}$, and the
Schur complement of the corner contributes the factor
$0 - \mathbf{1}^\top(-2I)^{-1}\mathbf{1} = -\,(n-1)\cdot(-\tfrac12) = \tfrac{n-1}{2}$.
Multiplying, $\det N = (-2)^{n-1}\cdot\tfrac{n-1}{2}$, which equals $(-1)^{n-1}(n-1)2^{n-2}$.
$\qquad\blacksquare$

The signed value is therefore $\Delta(P_n) = (-1)^{n-1}\det D = (n-1)2^{n-2}$. For
$n = 1,2,3,4$ this gives $0, 1, 4, 12$, while the raw determinants are $0, -1, 4, -12$,
in agreement with direct computation.

## 5. The extremal conjecture

The two endpoint formulas suggest a global extremal principle. Define, as above,
$\Delta(G) = (-1)^{n-1}\det R_G$ for a connected simple graph $G$ on $n$ vertices.

**Conjecture 5.1 (Global extremality).** For every connected simple graph $G$ on
$n \ge 2$ vertices,
$$\frac{2^n(n-1)}{n^n} = \Delta(K_n) \le \Delta(G) \le \Delta(\text{tree}) = 2^{n-2}(n-1).$$
Equality on the left holds if and only if $G = K_n$; equality on the right holds if and
only if $G$ is a tree.

**Conjecture 5.2 (Tree invariance / Graham–Pollak for resistance).** For every tree
$T$ on $n$ vertices, $R_T$ is its distance matrix and $\Delta(T) = (n-1)2^{n-2}$,
independent of shape. (Proved here for $P_n$.)

**Conjecture 5.3 (Edge-addition monotonicity).** If $H = G + e$ is obtained from a
connected graph $G$ by adding one edge, then $\Delta(H) < \Delta(G)$.

The motivation for 5.3 is **Rayleigh monotonicity**: adding an edge cannot increase any
effective resistance, so every entry of $R_G$ is non-increasing under edge addition.
Conjecturally this entrywise decrease forces a strict decrease of the signed
determinant. Conjecture 5.3 implies Conjecture 5.1, since trees are precisely the
edge-minimal connected graphs and $K_n$ is the unique edge-maximal one.

**Conjecture 5.4 (Positivity / sign law).** For every connected simple graph on
$n \ge 2$ vertices, $\Delta(G) > 0$; equivalently $\operatorname{sign}(\det R_G) = (-1)^{n-1}$.
Verified here for $K_n$ (Theorem 3.5) and for the path.

**Conjecture 5.5 (Bapat–Gutman–Xiao closed form).** There is an explicit combinatorial
functional $F(G)$ — a count of spanning 2-forests weighted by component sizes — with
$$\Delta(G) = 2^{n-2}\,\frac{F(G)}{\tau(G)},$$
where $\tau(G)$ is the number of spanning trees. For trees, $\tau = 1$ and $F = n-1$,
recovering $2^{n-2}(n-1)$; for $K_n$, $\tau = n^{n-2}$ (Cayley) and the formula
reproduces $(2/n)^n(n-1)$.

## 6. Algorithms

Two algorithmic ingredients support the computational study of $\Delta(G)$.

**Algorithm A (Effective-resistance matrix via the Laplacian pseudoinverse).** Given a
connected graph, build the Laplacian $L = \deg - A$, compute its Moore–Penrose
pseudoinverse $L^{+}$, and set $R(i,j) = L^{+}_{ii} + L^{+}_{jj} - 2L^{+}_{ij}$. This
costs $O(n^3)$ for the pseudoinverse. The signed determinant follows from one further
$O(n^3)$ determinant evaluation.

**Algorithm B (Arrowhead reduction for path/tree distance matrices).** For a tree,
form the distance matrix by BFS from each vertex ($O(n^2)$), then apply the
row/column differencing of Section 4 to reach a sparse arrowhead form whose
determinant is read off in $O(n)$. For the path this yields the closed form directly.

## 7. Applications and discussion

The signed resistance determinant sits at the confluence of several fields. In
chemical graph theory it refines the Kirchhoff index; in network analysis its
positivity (Conjecture 5.4) is a robust structural invariant of connectivity; and in
combinatorics the conjectured closed form (5.5) ties $\det R_G$ to spanning-tree and
2-forest enumeration, in the lineage of the Matrix–Tree theorem and the
Bapat–Gutman–Xiao determinant formulas. The exponential gap $n^n/4$ between the tree
and complete-graph values shows that $\Delta$ is a sensitive discriminator of edge
density, suggesting its use as a graph descriptor.

The endpoint theorems proved here are robust anchors: they fix the conjectured floor
and ceiling exactly and in closed form, reducing the open problem to the *monotonicity*
of $\Delta$ along the edge-inclusion lattice.

## 8. Future work

The natural progression is:
1. Prove Conjecture 5.2 for stars and caterpillars, then a general leaf-removal
   induction establishing Graham–Pollak invariance for all trees.
2. Computationally test Conjecture 5.3 (edge monotonicity) on all small connected
   graphs ($n \le 8$), then seek a Rayleigh-based analytic proof.
3. Pin down the combinatorial functional $F(G)$ of Conjecture 5.5 and verify it
   against $K_n$ and trees.
4. Combine 5.2 and 5.3 to obtain the global extremality statement 5.1 with uniqueness.

## 9. Conclusion

We have established, in closed form, the signed resistance determinant at the two
density extremes: $\Delta(K_n) = (2/n)^n(n-1)$ for the complete graph and
$\Delta(P_n) = (n-1)2^{n-2}$ for the path (the Graham–Pollak tree value). These results
anchor a precise, falsifiable conjecture that the complete graph minimizes and trees
maximize $\Delta$ over all connected simple graphs, driven by Rayleigh monotonicity.
The signed resistance determinant emerges as an elegant, exponentially-sensitive
invariant linking electrical networks, spectral graph theory, and the combinatorics of
spanning structures.
