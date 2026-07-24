# Mutually Orthogonal Latin Squares, Reticulations, and Cooperative Systems: A Sharp Bound via Corner Tagging

**Author:** Aristotle

**Date:** 2026-07-24

## Abstract

We study combinatorial structures that generalize $(k,n)$-nets, orthogonal
arrays, and sets of mutually orthogonal Latin squares (MOLS), organizing them
around a single quantitative question: how many pairwise-orthogonal Latin squares
can share a common $n \times n$ grid? We give a fully self-contained, elementary
proof of the classical sharp upper bound — a set of MOLS of order $n \ge 2$
contains at most $n - 1$ squares — using a *corner-tagging* argument that requires
no field structure and no prior normalization of the family. The proof isolates a
single cell of the grid and reduces the entire theorem to two applications of the
pigeonhole principle: one enforcing that a tag is nonzero (via the column-Latin
property) and one enforcing that tags are distinct (via orthogonality). We record
the two structural symmetries that underpin the theory — invariance of the Latin
and orthogonality conditions under independent relabeling of symbols — and we prove
existence and sharpness by exhibiting the cyclic Latin square in every positive
order and a complete pair of MOLS of order $3$ realizing the bound. We close by
placing these results in the broader landscape of *reticulations* and *cooperative
systems*, geometric generalizations in which the two Latin conditions are
unbundled, and we formulate a bipartite refinement of the bound as a natural next
target.

**Keywords:** mutually orthogonal Latin squares, MOLS, nets, transversal designs,
orthogonal arrays, cooperative systems, reticulations, combinatorial designs,
pigeonhole principle.

---

## 1. Introduction

A *Latin square* of order $n$ is an $n \times n$ array over an $n$-element symbol
alphabet in which each symbol occurs exactly once in every row and exactly once in
every column. Two Latin squares $L$ and $M$ of the same order are *orthogonal* when
the $n^2$ ordered pairs $(L_{ij}, M_{ij})$ obtained by superimposing them are all
distinct; equivalently, every ordered pair of symbols occurs in exactly one cell.
A family of Latin squares that are pairwise orthogonal is a set of *mutually
orthogonal Latin squares* (MOLS).

Orthogonal Latin squares originate with Euler's 1782 "Thirty-Six Officers Problem"
and have since become a cornerstone of design theory, with applications to the
statistical design of experiments, error-correcting codes, finite geometry, and
combinatorial scheduling. The single most important quantitative fact about them is
a ceiling on the size of a MOLS family:

> A set of MOLS of order $n \ge 2$ has at most $n - 1$ members.

This bound is classical, but the standard textbook proof proceeds by first
*normalizing* a family — relabeling each square so its first row is the identity
sequence $0, 1, \dots, n-1$ — and then reading a repeated symbol off a fixed cell.
The purpose of this paper is to present a streamlined, self-contained treatment in
which normalization is never performed. Instead we tag each square directly by
inverting its first row, reducing the entire argument to two short pigeonhole
steps. The subtraction of a single unit in "$n - 1$" is pinned to one concrete,
identifiable phenomenon: a designated *corner cell* cannot match the top-left cell
without violating the column-Latin property.

We also develop the two symmetry principles the theory relies on — relabeling
invariance of both the Latin condition and orthogonality — and we establish
existence and sharpness. Finally, we connect the results to *reticulations* and
*cooperative systems*, the incidence-geometric generalizations that motivate the
subject, and we outline how the corner-tag mechanism extends to them.

### Contributions

1. A complete, normalization-free proof of the sharp MOLS bound $k \le n - 1$
   (Section 4), organized around the corner-tag map.
2. Clean predicate-level definitions of the Latin and orthogonality conditions
   matching the "row-Latin $\perp$ column-Latin" viewpoint of cooperative systems
   (Section 2), together with the two relabeling-symmetry theorems (Section 3).
3. Existence in every positive order via the cyclic Latin square, and sharpness at
   order $3$ via an explicit complete pair of MOLS (Section 5).
4. A structural discussion of reticulations and cooperative systems and a bipartite
   conjecture generalizing the bound (Sections 6–7).

---

## 2. Definitions

Throughout, we identify both the index set (rows/columns) and the symbol alphabet
with the set $\{0, 1, \dots, n-1\}$, which we denote $[n]$. A map
$L : [n] \times [n] \to [n]$ is written $L_{ij} := L(i, j)$ and viewed as an array
whose cell in row $i$ and column $j$ holds symbol $L_{ij}$.

**Definition 2.1 (Latin square).** An array $L : [n] \times [n] \to [n]$ is a
*Latin square* of order $n$ if

- (row condition) for every fixed row $i$, the map $j \mapsto L_{ij}$ is a
  bijection of $[n]$; and
- (column condition) for every fixed column $j$, the map $i \mapsto L_{ij}$ is a
  bijection of $[n]$.

Because $[n]$ is finite, "bijection" may equivalently be read as "injection" or as
"surjection"; each row and each column is a permutation of the alphabet.

**Definition 2.2 (Orthogonality).** Two arrays $L, M : [n] \times [n] \to [n]$ are
*orthogonal*, written $L \perp M$, if the *pairing map*
$$
\Phi_{L,M} : [n] \times [n] \to [n] \times [n], \qquad
\Phi_{L,M}(i, j) = (L_{ij}, M_{ij})
$$
is a bijection. Since domain and codomain are finite sets of the same cardinality
$n^2$, this is equivalent to injectivity of $\Phi_{L,M}$: no two distinct cells
yield the same ordered pair of symbols.

**Definition 2.3 (MOLS).** A set of *mutually orthogonal Latin squares* of order
$n$ and size $k$ is an indexed family $(L^{(s)})_{s \in [k]}$ such that

- each $L^{(s)}$ is a Latin square of order $n$; and
- for all $s \ne t$, the squares $L^{(s)}$ and $L^{(t)}$ are orthogonal.

We refer to the members as the *squares* of the family and to $k$ as its *size*.

**Remark 2.4 (The cooperative-system viewpoint).** The two clauses of Definition
2.1 are logically independent: an array may satisfy the row condition without the
column condition and vice versa. Calling an array *row-Latin* if every row is a
permutation and *column-Latin* if every column is a permutation, a Latin square is
exactly an array that is both. A *cooperative system* relaxes MOLS to a collection
of row-Latin matrices together with a collection of column-Latin matrices in which
each row-Latin matrix is orthogonal to each column-Latin matrix (see Section 6).
Our definitions are stated at the predicate level precisely so that this
unbundling is transparent.

---

## 3. Relabeling symmetry

The theory is invariant under renaming the symbol alphabet. This is what allows one
to standardize a family "for free," and it is the source of the flexibility
exploited by the corner-tag proof.

**Theorem 3.1 (Latin relabeling).** Let $L$ be a Latin square of order $n$ and let
$\sigma : [n] \to [n]$ be a bijection. Then the array $(i, j) \mapsto \sigma(L_{ij})$
is again a Latin square.

*Proof.* For each fixed row $i$, the map $j \mapsto \sigma(L_{ij})$ is the
composition $\sigma \circ (j \mapsto L_{ij})$ of two bijections, hence a bijection;
likewise for each column. $\qquad\blacksquare$

**Theorem 3.2 (Orthogonality relabeling).** Let $L \perp M$ be orthogonal arrays of
order $n$, and let $\sigma, \tau : [n] \to [n]$ be bijections. Then
$(i, j) \mapsto \sigma(L_{ij})$ and $(i, j) \mapsto \tau(M_{ij})$ are orthogonal.

*Proof.* The pairing map of the relabeled arrays is
$(\sigma \times \tau) \circ \Phi_{L,M}$, where $\sigma \times \tau$ denotes the
product map $(x, y) \mapsto (\sigma(x), \tau(y))$. A product of two bijections is a
bijection, and the composition of bijections is a bijection, so the new pairing map
is a bijection. $\qquad\blacksquare$

The independence of $\sigma$ and $\tau$ in Theorem 3.2 is essential: each square in
a MOLS family may be relabeled by its own permutation without disturbing pairwise
orthogonality. This is exactly the freedom used, in classical treatments, to
normalize each first row to the identity — and it is why the proof in Section 4 may
invert first rows individually without loss of generality.

---

## 4. The sharp bound

We now prove the central theorem. Fix $n \ge 2$ and a MOLS family
$(L^{(s)})_{s \in [k]}$ of order $n$. Because $n \ge 2$, the row indices $0$ and $1$
and the column index $0$ all exist; we single out the **corner cell** $(1, 0)$
(second row, first column).

**Definition 4.1 (Corner tag).** For each square index $s$, the first row
$j \mapsto L^{(s)}_{0j}$ is a bijection of $[n]$ (row condition), so it has an
inverse. Define the *corner tag* of $s$ to be the unique column
$$
c(s) := \bigl(j \mapsto L^{(s)}_{0j}\bigr)^{-1}\!\bigl(L^{(s)}_{1 0}\bigr) \in [n];
$$
that is, $c(s)$ is the column of the first row whose symbol equals the corner-cell
symbol $L^{(s)}_{10}$. By construction it satisfies the defining identity
$$
L^{(s)}_{0,\,c(s)} = L^{(s)}_{1 0}. \tag{$\ast$}
$$

**Lemma 4.2 (Tags avoid column $0$).** For every $s$, we have $c(s) \ne 0$.

*Proof.* Suppose $c(s) = 0$. Substituting into $(\ast)$ gives
$L^{(s)}_{0 0} = L^{(s)}_{1 0}$: the symbol in the top-left cell equals the symbol in
the corner cell. But these two cells lie in the *same column* (column $0$), and the
column condition says $i \mapsto L^{(s)}_{i 0}$ is injective. Injectivity forces the
row indices to coincide, i.e. $0 = 1$, contradicting $n \ge 2$. Hence
$c(s) \ne 0$. $\qquad\blacksquare$

**Lemma 4.3 (Tags are distinct).** The map $s \mapsto c(s)$ is injective.

*Proof.* Suppose $c(s) = c(t) =: c$ for two indices $s \ne t$. Applying the defining
identity $(\ast)$ to both squares at the column $c$ gives
$$
L^{(s)}_{0 c} = L^{(s)}_{1 0}
\qquad\text{and}\qquad
L^{(t)}_{0 c} = L^{(t)}_{1 0}.
$$
Reading these two equations coordinatewise, the ordered pair of symbols produced by
the superposition of $L^{(s)}$ and $L^{(t)}$ at cell $(0, c)$ equals the pair
produced at cell $(1, 0)$:
$$
\bigl(L^{(s)}_{0 c},\, L^{(t)}_{0 c}\bigr) = \bigl(L^{(s)}_{1 0},\, L^{(t)}_{1 0}\bigr).
$$
Since $s \ne t$, the squares $L^{(s)}$ and $L^{(t)}$ are orthogonal, so their pairing
map $\Phi$ is injective. Injectivity forces the two cells to coincide:
$(0, c) = (1, 0)$. In particular the row indices agree, $0 = 1$, contradicting
$n \ge 2$. Hence $c$ is injective. $\qquad\blacksquare$

**Theorem 4.4 (MOLS bound).** A set of mutually orthogonal Latin squares of order
$n \ge 2$ has at most $n - 1$ members; that is, $k \le n - 1$.

*Proof.* By Lemma 4.2 the corner tag $c$ maps $[k]$ into the set
$[n] \setminus \{0\}$ of nonzero columns, which has exactly $n - 1$ elements. By
Lemma 4.3 the map $c$ is injective. An injection from a set of size $k$ into a set
of size $n - 1$ forces $k \le n - 1$. $\qquad\blacksquare$

**Discussion.** The entire theorem rests on the single cell $(1, 0)$. It is the
unique cell used outside row $0$, and the witness cell $(0, c(s))$ it produces
always lies in row $0$; the mismatch of these rows ($1 \ne 0$) is what both lemmas
ultimately exploit. The "$-1$" — the difference between the true bound $n - 1$ and
the naive counting bound $n$ — is exactly Lemma 4.2: without it one only concludes
$k \le n$. No field structure, prime-power hypothesis, or normalization is used; the
proof is valid for arbitrary order $n \ge 2$.

---

## 5. Existence and sharpness

An upper bound is only meaningful once existence is established, and it is *sharp*
only if the bound is attained.

### 5.1 Existence in every order

**Theorem 5.1 (Cyclic Latin square).** For every $n \ge 1$, the addition table of
the cyclic group $\mathbb{Z}/n\mathbb{Z}$,
$$
L_{ij} = i + j \pmod n,
$$
is a Latin square of order $n$.

*Proof.* For each fixed $i$, the map $j \mapsto i + j$ is translation by $i$, a
bijection of $\mathbb{Z}/n\mathbb{Z}$ with inverse $j \mapsto j - i$; this is the row
condition. Symmetrically, for each fixed $j$ the map $i \mapsto i + j$ is a
bijection, giving the column condition. $\qquad\blacksquare$

Thus Latin squares exist in every positive order, and the MOLS bound is never
vacuous: the family of size $k = 1$ always exists.

### 5.2 Attainment: complete MOLS from affine maps

When $n$ is prime (more generally, a prime power, using the finite field of order
$n$), the alphabet carries a field structure, and one obtains a *complete* family
attaining the bound. Label rows, columns, and symbols by field elements and, for
each nonzero *slope* $a$, define
$$
L^{(a)}_{ij} = a \cdot i + j.
$$
Each $L^{(a)}$ is a Latin square (rows are translations; columns are
$i \mapsto a i + j$, a bijection because $a \ne 0$). For distinct nonzero slopes
$a \ne a'$, the squares $L^{(a)}$ and $L^{(a')}$ are orthogonal: given a target pair
$(u, v)$, the system $a i + j = u$, $a' i + j = v$ has the unique solution
$i = (u - v)/(a - a')$, $j = u - a i$, so the pairing map is a bijection. There are
exactly $n - 1$ nonzero slopes, yielding $n - 1$ mutually orthogonal squares.

### 5.3 The smallest sharp case

**Theorem 5.2 (Sharpness at order $3$).** The maximum size of a set of MOLS of order
$3$ is exactly $2$.

*Proof.* Theorem 4.4 gives the upper bound $k \le 3 - 1 = 2$. For attainment, take
the two affine tables over $\mathbb{Z}/3\mathbb{Z}$ with slopes $1$ and $2$:
$$
A_{ij} = i + j, \qquad B_{ij} = 2 i + j.
$$
Explicitly,
$$
A = \begin{pmatrix} 0 & 1 & 2 \\ 1 & 2 & 0 \\ 2 & 0 & 1 \end{pmatrix},
\qquad
B = \begin{pmatrix} 0 & 1 & 2 \\ 2 & 0 & 1 \\ 1 & 2 & 0 \end{pmatrix}.
$$
Both are Latin (Theorem 5.1 and the fact that $2$ is a unit modulo $3$). Their
superposition
$$
(A_{ij}, B_{ij}) =
\begin{pmatrix} (0,0) & (1,1) & (2,2) \\ (1,2) & (2,0) & (0,1) \\ (2,1) & (0,2) & (1,0) \end{pmatrix}
$$
lists all nine ordered pairs exactly once, so $A \perp B$. Hence a MOLS family of
size $2$ exists, matching the upper bound. $\qquad\blacksquare$

This is the smallest nontrivial confirmation that the "$-1$" is essential rather
than an artifact of the counting.

---

## 6. Reticulations and cooperative systems

The MOLS bound is the arithmetic shadow of an incidence-geometric object.

**Nets.** A $(k, n)$-*net* consists of $n^2$ points together with $k + 1$ *parallel
classes* of lines, where each class partitions the points into $n$ lines of $n$
points each, and any two lines from *different* classes meet in exactly one point.
Two of the classes may be taken as the "rows" and "columns" of an $n \times n$ grid;
each of the remaining $k - 1$ classes then corresponds to a Latin square, and the
mutual orthogonality of these squares is exactly the requirement that lines from
different classes meet once. Thus a set of $k - 1$ MOLS of order $n$ is equivalent
to a $(k, n)$-net. Theorem 4.4 says a net has at most $n + 1$ parallel classes.

**Reticulations.** More generally, one may consider a point set equipped with *two
types* of families of lines, subject to:

- lines of *different* types meet in exactly one point;
- each family (of either type) partitions the point set;
- the number of points on a line depends only on its type, and every point lies on
  the same number of lines of a given type.

We call such a structure a *reticulation*. Selecting one family of each type
coordinatizes the points on a rectangular grid, and recording, for each point, the
line of a third family through it produces an array. When the two types are treated
asymmetrically, the arrays split into *row-Latin* matrices (from one type) and
*column-Latin* matrices (from the other).

**Cooperative systems.** The array-level shadow of a reticulation is a *cooperative
system*: a collection of column-Latin matrices together with a collection of
row-Latin matrices such that every column-Latin matrix is orthogonal to every
row-Latin matrix. A cooperative system unbundles the two halves of the Latin
condition that a MOLS family fuses together, and it is the natural setting in which
to ask for a *two-sided* version of the bound (Section 7). Definitions 2.1–2.3,
being stated at the predicate level, specialize immediately to this setting: the row
condition and column condition are independent predicates, and orthogonality is the
same bijective pairing map.

---

## 7. Discussion and future work

The corner-tag proof is deliberately one-sided: it tags each square by the column
of its first *row* matching the corner symbol. But the argument has an unused *dual*
direction — tagging by the row of the first *column* — and combining the two is the
natural route to a bound for cooperative systems.

**A bipartite bound (conjecture).** In a cooperative system with $a$ row-Latin
matrices and $b$ column-Latin matrices of order $n$, in which every row-Latin matrix
is orthogonal to every column-Latin matrix, the product $a \cdot b$ is bounded by
$(n - 1)^2$, with equality forcing both families to be complete sets of MOLS
coordinatizing the same net. The heuristic: a row-Latin matrix is tagged by the
column of its first row matching the $(1,0)$-entry, while a column-Latin matrix is
tagged dually by the row of its first column; cross-orthogonality forces the two tag
families to inject into disjoint nonzero index sets, and the multiplicative bound
follows by combining the two one-sided injections.

**Reticulations as bipartite transversal designs (conjecture).** Reticulations with
two line-types of degrees $(r, s)$ should be in explicit, degree-preserving
bijection with a bipartite refinement of transversal designs $TD(k, n)$, under which
the partition axiom corresponds to resolvability and the "different types meet once"
axiom corresponds to the transversal property. With coordinatization formalized as
the passage from lines to arrays, the incidence axioms become statements about
injective pairing maps of exactly the kind handled here.

**Deletion stability (conjecture).** If a set of MOLS of order $n$ attains the bound
$n - 1$, then contracting one symbol (deleting the cells containing it) should yield
a structure whose completion number is exactly $n - 2$; the bound degrades by
exactly one under contraction, and no order-$n$ family can lose two units at once.

These directions share a common theme: the elementary injection at the heart of
Theorem 4.4 is robust, using neither field structure nor normalization, and each
generalization amounts to finding the right index set for the right tag.

---

## 8. Conclusion

We have given a compact, self-contained account of the sharp MOLS bound
$k \le n - 1$ via a corner-tagging argument that reduces the theorem to two
pigeonhole steps, together with the relabeling symmetries that legitimize it and
explicit existence and sharpness results. Situated within the theory of nets,
reticulations, and cooperative systems, the argument reveals that a single stubborn
grid cell carries the whole weight of the classical bound, and it points toward
bipartite generalizations for the structures that unbundle the row and column Latin
conditions.
