# The Dimension of the Character Table of the Symmetric Group: A Formalized Partition–Conjugacy Correspondence

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Representation Theory of Finite Groups)

---

## Abstract

The character table of a finite group $G$ is a square array whose common number of rows
and columns equals the number of conjugacy classes of $G$, which in turn equals the
number of isomorphism classes of irreducible complex representations of $G$. For the
symmetric group $S_n$ — realized here concretely as $\operatorname{Perm}(\mathrm{Fin}\,n)$,
the group of permutations of an $n$-element set — the conjugacy classes are classified by
*cycle type*, and cycle types are in canonical correspondence with **integer partitions**
of $n$. Consequently the character table of $S_n$ is a $p(n)\times p(n)$ square, where
$p(n)$ denotes the partition function.

This paper presents a fully machine-verified development of the combinatorial backbone of
this fact. We construct an explicit bijection
$$\mathrm{partitionEquivConjClasses} : \operatorname{Partition}(n) \;\simeq\;
\operatorname{ConjClasses}(\operatorname{Perm}(\mathrm{Fin}\,n)),$$
and deduce the cardinality identity
$\bigl|\operatorname{ConjClasses}(\operatorname{Perm}(\mathrm{Fin}\,n))\bigr| = p(n)$,
together with the concrete evaluations $p(3)=3$, $p(4)=5$, $p(5)=7$ that fix the sizes of
the character tables of $S_3$, $S_4$, and $S_5$. We complement the count with the two
universal linear characters (trivial and sign) and the elementary orthogonality relation
$\sum_{g\in S_n}\operatorname{sign}(g)=0$ for $n\ge 2$. We discuss algorithms for
realizing the bijection, give numerical demonstrations, and outline the remaining steps
needed to formalize the full equality "#irreducibles $=$ #conjugacy classes."

---

## 1. Introduction

### 1.1 Motivation

Character theory is the arithmetic skeleton of representation theory. To a finite group
$G$ and a finite-dimensional complex representation $\rho : G \to \mathrm{GL}(V)$ one
associates the **character** $\chi_\rho(g) = \operatorname{tr}\rho(g)$, a class function
(constant on conjugacy classes) that determines $\rho$ up to isomorphism. The irreducible
characters form an orthonormal basis of the space of class functions, and arranging their
values into a grid produces the **character table**. Two cornerstones of the classical
theory govern its shape:

1. **Squareness.** The number of irreducible complex characters of $G$ equals the number
   of conjugacy classes of $G$. Hence the character table is square.
2. **Orthogonality.** The rows (and the columns) are mutually orthogonal under suitable
   inner products, making the table an invertible matrix.

For the symmetric groups $S_n$ a third, combinatorial, ingredient enters: conjugacy in
$S_n$ is detected entirely by cycle type, and cycle types are partitions of $n$. The aim
of this work is to formalize the part of statement (1) that is specific to $S_n$ — namely
that the number of conjugacy classes is $p(n)$ — by exhibiting an explicit bijection
rather than appealing to the general representation-theoretic count (which is not yet
available in the underlying library). This makes the result genuinely about the
*symmetric group* and its partition combinatorics, and it pins down the dimensions of the
character tables of $S_3$, $S_4$, $S_5$ as $3,5,7$.

### 1.2 Contributions

- A self-contained, machine-checked bijection
  $\operatorname{Partition}(n)\simeq\operatorname{ConjClasses}(\operatorname{Perm}(\mathrm{Fin}\,n))$
  (Theorem 3.7), built from an explicit "partition $\to$ permutation" construction and a
  well-defined "class $\to$ partition" inverse.
- The cardinality theorem
  $\bigl|\operatorname{ConjClasses}(\operatorname{Perm}(\mathrm{Fin}\,n))\bigr|=p(n)$
  (Theorem 4.1) and the explicit values for $n=3,4,5$ (Corollary 4.2).
- The two universal linear characters of $S_n$ with the orthogonality relation
  $\sum_{g}\operatorname{sign}(g)=0$ (Proposition 5.2), establishing the first two rows of
  every $S_n$ character table.
- Algorithms, numerical demonstrations, and a roadmap to the complete formalization of
  the squareness theorem for $S_n$.

---

## 2. Preliminaries and definitions

Throughout, $n \in \mathbb{N}$ and we write $S_n := \operatorname{Perm}(\mathrm{Fin}\,n)$
for the group of bijections of the standard $n$-element set
$\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$.

**Definition 2.1 (Integer partition).**
A *partition* of $n$ is a finite multiset of positive integers (the *parts*) whose sum is
$n$. We write $\operatorname{Partition}(n)$ for the (finite) type of partitions of $n$,
and $p(n) := |\operatorname{Partition}(n)|$ for the partition function. Two partitions are
equal iff they have the same multiset of parts (extensionality).

**Definition 2.2 (Cycle type).**
Every $\sigma \in S_n$ factors uniquely into disjoint cycles. The *cycle type*
$\operatorname{cycleType}(\sigma)$ is the multiset of lengths of the cycles of length
$\ge 2$ in this factorization. Fixed points (cycles of length $1$) do not contribute to
the cycle type. One has $\sum \operatorname{cycleType}(\sigma) \le n$.

**Definition 2.3 (The partition of a permutation).**
By padding the cycle type with parts equal to $1$ — one for each fixed point — one obtains
a genuine partition of $n$, denoted $\sigma.\mathrm{partition}$, whose parts are the cycle
lengths together with the requisite number of $1$'s so that the parts sum to $n$. Formally
$$\operatorname{parts}(\sigma.\mathrm{partition}) =
\operatorname{cycleType}(\sigma) + \mathbf{1}^{\,n - |\sigma|},$$
where $\mathbf{1}^{k}$ is the multiset of $k$ copies of $1$.

**Definition 2.4 (Conjugacy classes).**
For a group $G$, $\operatorname{ConjClasses}(G)$ is the quotient of $G$ by the conjugation
relation $g \sim h \iff \exists x,\ h = x g x^{-1}$. We write $\operatorname{mk}(g)$ for
the class of $g$. The map $\operatorname{mk}$ is surjective, and every class has a
representative.

**Fact 2.5 (Conjugacy is cycle type, in $S_n$).**
For $\sigma, \tau \in S_n$, $\sigma$ and $\tau$ are conjugate if and only if
$\sigma.\mathrm{partition} = \tau.\mathrm{partition}$ (equivalently, they have the same
cycle type). This is the classical normal-form theorem for permutations and is available
in the ambient library as `Equiv.Perm.partition_eq_of_isConj`.

**Fact 2.6 (Realizability of cycle types).**
A multiset $m$ of integers $\ge 2$ is the cycle type of some $\sigma \in S_n$ if and only
if $\sum m \le n$. (Library: `Equiv.Perm.exists_with_cycleType_iff`.)

---

## 3. The partition–conjugacy bijection

We now build the correspondence in both directions and prove it is a bijection. This
section corresponds to the formalized namespace `PartitionConjClasses`.

### 3.1 From partitions to permutations

**Lemma 3.1 (Existence of a permutation with prescribed cycle type;
`exists_perm_cycleType`).**
For every $p \in \operatorname{Partition}(n)$ there exists $g \in S_n$ with
$$\operatorname{cycleType}(g) = \operatorname{filter}(\,2 \le \cdot\,)\ \operatorname{parts}(p),$$
the sub-multiset of parts of $p$ that are at least $2$.

*Proof sketch.* The parts $\ge 2$ form a multiset $m$ with $\sum m \le \sum \operatorname{parts}(p) = n$.
By Fact 2.6 such a $g$ exists. The sum bound is exactly $p.\mathrm{parts\_sum}$ combined
with the fact that filtering removes only nonnegative contributions. $\qquad\blacksquare$

**Definition 3.2 (`permOfPartition`).**
Let $\operatorname{permOfPartition}(p) \in S_n$ be a chosen permutation witnessing
Lemma 3.1. Concretely it arranges $\mathrm{Fin}\,n$ into disjoint blocks whose sizes are
the parts of $p$ and turns each block of size $\ge 2$ into a single cycle, leaving the
size-$1$ blocks as fixed points.

**Lemma 3.3 (`permOfPartition_cycleType`).**
$\operatorname{cycleType}(\operatorname{permOfPartition}(p)) =
\operatorname{filter}(2 \le \cdot)\ \operatorname{parts}(p)$.

*Proof.* Immediate from the defining property of the chosen witness. $\qquad\blacksquare$

**Lemma 3.4 (`permOfPartition_partition_parts`).**
The partition associated to $\operatorname{permOfPartition}(p)$ recovers $p$ exactly:
$$\operatorname{parts}\bigl(\operatorname{permOfPartition}(p).\mathrm{partition}\bigr)
= \operatorname{parts}(p).$$

*Proof sketch.* By Definition 2.3 the parts of the associated partition are the cycle type
(the parts $\ge 2$, by Lemma 3.3) together with one $1$ per fixed point. It therefore
suffices to show that the complementary multiset $\operatorname{filter}(\neg\,2\le\cdot)\
\operatorname{parts}(p)$ consists entirely of $1$'s and has the correct cardinality. Since
every part of a partition is $\ge 1$, any part that is *not* $\ge 2$ equals $1$; hence the
complementary multiset is $\mathbf{1}^{k}$ for $k$ its cardinality. Finally the number of
$1$'s equals $n$ minus the sum of the parts $\ge 2$, because
$\bigl(\sum \operatorname{filter}(2\le\cdot)\bigr) +
\bigl(\sum \operatorname{filter}(\neg 2\le\cdot)\bigr) = \sum\operatorname{parts}(p) = n$
and the second sum equals the cardinality of a multiset of $1$'s. Recombining via
`Multiset.filter_add_not` yields $\operatorname{parts}(p)$. $\qquad\blacksquare$

### 3.2 From conjugacy classes to partitions

**Definition 3.5 (`permPartition`).**
For $\sigma \in S_n$ define $\operatorname{permPartition}(\sigma) \in \operatorname{Partition}(n)$
to be $\sigma.\mathrm{partition}$, reindexed from a partition of $|\mathrm{Fin}\,n|$ to a
partition of $n$ via $|\mathrm{Fin}\,n| = n$. Transporting along this equality does not
change the parts (`parts_cast`), so
$\operatorname{parts}(\operatorname{permPartition}(\sigma)) = \operatorname{parts}(\sigma.\mathrm{partition})$.

**Definition 3.6 (The two maps).**
- Forward: $\operatorname{toConjClass}(p) := \operatorname{mk}\bigl(\operatorname{permOfPartition}(p)\bigr)$.
- Backward: $\operatorname{ofConjClass}(c) := $ the partition of any representative of $c$,
  obtained by lifting $\operatorname{permPartition}$ through the conjugation quotient. This
  is **well defined** because conjugate permutations have equal partitions (Fact 2.5):
  if $\operatorname{mk}(\sigma) = \operatorname{mk}(\tau)$ then
  $\operatorname{permPartition}(\sigma) = \operatorname{permPartition}(\tau)$.

A key auxiliary fact glues the two directions:

**Lemma 3.6′ (`isConj_permOfPartition`).**
If $\operatorname{parts}(\sigma.\mathrm{partition}) = \operatorname{parts}(p)$ then
$\operatorname{permOfPartition}(p)$ is conjugate to $\sigma$.

*Proof.* By Fact 2.5 conjugacy is equivalent to equality of the associated partitions.
By Lemma 3.4, $\operatorname{permOfPartition}(p)$ has partition with parts
$\operatorname{parts}(p) = \operatorname{parts}(\sigma.\mathrm{partition})$, and partitions
are determined by their parts (extensionality). $\qquad\blacksquare$

### 3.3 The bijection

**Theorem 3.7 (`partitionEquivConjClasses`).**
The maps $\operatorname{toConjClass}$ and $\operatorname{ofConjClass}$ are mutually
inverse, giving an explicit bijection
$$\operatorname{Partition}(n) \;\simeq\; \operatorname{ConjClasses}(\operatorname{Perm}(\mathrm{Fin}\,n)).$$

*Proof.*
**Injectivity of $\operatorname{toConjClass}$ (`toConjClass_injective`).** If
$\operatorname{mk}(\operatorname{permOfPartition}(p)) = \operatorname{mk}(\operatorname{permOfPartition}(q))$
then the two permutations are conjugate, hence (Fact 2.5) have equal partitions; by
Lemma 3.4 this gives $\operatorname{parts}(p) = \operatorname{parts}(q)$, so $p = q$ by
extensionality.

**Surjectivity of $\operatorname{toConjClass}$ (`toConjClass_surjective`).** Given a class
$c$, pick a representative $\sigma$. Then $\operatorname{permPartition}(\sigma)$ is a
partition whose associated permutation is conjugate to $\sigma$ (Lemma 3.6′), so
$\operatorname{toConjClass}(\operatorname{permPartition}(\sigma)) = \operatorname{mk}(\sigma) = c$.

**Left inverse.** For a partition $p$,
$\operatorname{ofConjClass}(\operatorname{toConjClass}(p)) = \operatorname{permPartition}(\operatorname{permOfPartition}(p))$,
whose parts are $\operatorname{parts}(\operatorname{permOfPartition}(p).\mathrm{partition}) = \operatorname{parts}(p)$
by Definition 3.5 and Lemma 3.4; hence it equals $p$.

**Right inverse.** For a class $c$ with representative $\sigma$, the surjectivity
computation gives $\operatorname{toConjClass}(\operatorname{ofConjClass}(c)) = c$ directly.
$\qquad\blacksquare$

---

## 4. Counting conjugacy classes and the size of the table

**Theorem 4.1 (`card_conjClasses_eq_card_partition`).**
For every $n$,
$$\bigl|\operatorname{ConjClasses}(\operatorname{Perm}(\mathrm{Fin}\,n))\bigr|
= \bigl|\operatorname{Partition}(n)\bigr| = p(n).$$

*Proof.* A bijection between finite types preserves cardinality
(`Fintype.card_congr` applied to Theorem 3.7). $\qquad\blacksquare$

Because the number of irreducible complex characters of a finite group equals its number
of conjugacy classes, Theorem 4.1 says that **the character table of $S_n$ is a
$p(n)\times p(n)$ square.** Evaluating $p$ at small arguments fixes the first interesting
cases.

**Corollary 4.2 (Explicit table sizes;
`card_conjClasses_S3`, `card_conjClasses_S4`, `card_conjClasses_S5`).**
$$\bigl|\operatorname{ConjClasses}(S_3)\bigr| = 3, \qquad
\bigl|\operatorname{ConjClasses}(S_4)\bigr| = 5, \qquad
\bigl|\operatorname{ConjClasses}(S_5)\bigr| = 7.$$

*Proof.* By Theorem 4.1 the three left-hand sides equal $p(3), p(4), p(5)$. Direct
enumeration of partitions gives:

| $n$ | partitions of $n$ | $p(n)$ |
|----|----|----|
| $3$ | $3,\ 2{+}1,\ 1{+}1{+}1$ | $3$ |
| $4$ | $4,\ 3{+}1,\ 2{+}2,\ 2{+}1{+}1,\ 1{+}1{+}1{+}1$ | $5$ |
| $5$ | $5,\ 4{+}1,\ 3{+}2,\ 3{+}1{+}1,\ 2{+}2{+}1,\ 2{+}1{+}1{+}1,\ 1^{5}$ | $7$ |

$\qquad\blacksquare$

The partition numbers $p(n) = 1,1,2,3,5,7,11,15,22,\dots$ (OEIS A000041) are therefore
precisely the dimensions of the symmetric-group character tables.

---

## 5. The two universal rows

While the *number* of rows is governed by Theorem 4.1, two of the rows can be written
down explicitly for every $n$, independently of the deeper theory.

**Definition 5.1 (Trivial and sign characters).**
The *trivial character* $\chi_{\mathrm{triv}} : S_n \to \mathbb{C}$ is the constant map
$g \mapsto 1$. The *sign character* $\chi_{\operatorname{sign}} : S_n \to \mathbb{C}$ is
$g \mapsto \operatorname{sign}(g) \in \{+1,-1\}$, the homomorphism that is $+1$ on even
permutations and $-1$ on odd ones. Both are one-dimensional (linear) characters, hence
genuine rows of the character table.

**Proposition 5.2 (Distinctness and orthogonality; `sum_sign_eq_zero`).**
For $n \ge 2$ the trivial and sign characters are distinct, and
$$\sum_{g \in S_n} \operatorname{sign}(g) = 0.$$

*Proof sketch.* For $n \ge 2$ there exists a transposition $\tau$ with
$\operatorname{sign}(\tau) = -1 \ne 1 = \chi_{\mathrm{triv}}(\tau)$, giving distinctness.
For the sum, multiplication by a fixed transposition is a sign-reversing involution on
$S_n$, pairing each even permutation with an odd one; hence the $+1$'s and $-1$'s cancel.
Equivalently, $\operatorname{sign}: S_n \to \{\pm 1\}$ is a surjective homomorphism for
$n\ge 2$, so its kernel (the alternating group) has index $2$ and the two cosets have
equal size $n!/2$. $\qquad\blacksquare$

Proposition 5.2 is the inner product $\langle \chi_{\mathrm{triv}}, \chi_{\operatorname{sign}}\rangle = 0$,
the first instance of the **row orthogonality relations**, which assert that distinct
irreducible characters are orthonormal with respect to
$\langle \chi, \psi\rangle = \tfrac{1}{|G|}\sum_g \chi(g)\overline{\psi(g)}$.

---

## 6. Algorithms

The bijection of Theorem 3.7 is constructive and yields concrete algorithms.

### 6.1 Enumerating partitions

Partitions of $n$ are generated recursively with a bounded-largest-part recurrence:
$P(n, k)$ lists partitions of $n$ whose parts are $\le k$, via
$P(n,k) = \{\,[k] \mathbin{+\!\!+} \pi : \pi \in P(n-k, k)\,\} \cup P(n, k-1)$. Counting the
output gives $p(n)$; this is the computational mirror of Corollary 4.2.

### 6.2 Realizing a partition as a permutation (`permOfPartition`)

Given parts $\lambda_1 \ge \dots \ge \lambda_r$, walk through $\{0,\dots,n-1\}$ assigning
consecutive blocks of sizes $\lambda_1, \dots, \lambda_r$ and emit a cycle for each block
of size $\ge 2$ (a block of size $1$ contributes a fixed point). The output is a
permutation in one-line or cycle notation with the prescribed cycle type — the explicit
witness behind Lemma 3.1.

### 6.3 Reading the partition of a permutation (`permPartition`)

Decompose a permutation into disjoint cycles by orbit-tracing, record the cycle lengths,
and append $1$'s for the fixed points so the parts sum to $n$. By Fact 2.5 the output is a
conjugacy-class invariant — the inverse direction of the bijection.

### 6.4 Centralizer order and class size

For a class of cycle type $\lambda$ with $m_i$ parts equal to $i$, the centralizer order
is $z_\lambda = \prod_i i^{m_i}\, m_i!$, and the class size is $n!/z_\lambda$. Summing the
class sizes over all partitions recovers $|S_n| = n!$, an arithmetic check on the
classification.

---

## 7. Numerical demonstrations

The accompanying program verifies, for $n = 1,\dots,8$:

- $p(n)$ matches OEIS A000041, with $p(3)=3$, $p(4)=5$, $p(5)=7$ (Corollary 4.2);
- the conjugacy-class sizes $n!/z_\lambda$ sum to $n!$ (consistency of the cycle-type
  classification);
- the squared dimensions of the irreducible representations, computed from the hook-length
  formula $f^\lambda = n! / \prod_{\text{cells}} h(\text{cell})$, satisfy
  $\sum_{\lambda \vdash n} (f^\lambda)^2 = n!$ — the regular-representation identity that
  the squareness of the table predicts;
- the sign character sums to $0$ over $S_n$ for $n\ge 2$ (Proposition 5.2).

For example, for $n=4$ the dimensions are $f^{(4)}=1$, $f^{(3,1)}=3$, $f^{(2,2)}=2$,
$f^{(2,1,1)}=3$, $f^{(1^4)}=1$, and indeed $1^2+3^2+2^2+3^2+1^2 = 24 = 4!$, across exactly
$p(4)=5$ irreducibles.

---

## 8. Discussion

The result formalized here is the *combinatorial half* of the statement that the character
table of $S_n$ is $p(n)\times p(n)$. The general representation-theoretic equality
"#irreducible characters $=$ #conjugacy classes" is not invoked; instead we directly count
conjugacy classes via partitions. This has two advantages. First, it is genuinely about
the symmetric group rather than an abstract group, exposing the cycle-type combinatorics
that make $S_n$ special. Second, it is fully constructive: the bijection produces an
explicit representative permutation for every partition and vice versa, which is exactly
what one needs to *compute* with the table, not merely to know its size.

The principal subtlety in the formalization is bookkeeping of fixed points: cycle type
discards parts equal to $1$, so the round-trip partition $\to$ permutation $\to$ partition
must reconstruct the correct number of $1$'s from the constraint that parts sum to $n$.
Lemma 3.4 isolates exactly this argument.

---

## 9. Future directions

The natural continuations, in increasing order of representation-theoretic depth:

1. **#irreducibles $=$ #conjugacy classes for finite groups.** Formalize that the center
   of the group algebra $\mathbb{C}[G]$ has dimension equal to the number of conjugacy
   classes (class sums form a basis), while Wedderburn–Artin decomposes
   $\mathbb{C}[G]$ as a product of matrix algebras, one per irreducible. Combined with
   Theorem 4.1 this proves $S_n$ has exactly $p(n)$ irreducible complex representations.

2. **Sum of squares of dimensions equals $|G|$.** Formalize
   $\sum_{V \text{ simple}} (\dim V)^2 = |G|$; for $S_n$ this is the partition identity
   $\sum_{\lambda \vdash n} (f^\lambda)^2 = n!$ with $f^\lambda$ the number of standard
   Young tableaux of shape $\lambda$. The combinatorial side is reachable via RSK.

3. **Abelianization $S_n^{\mathrm{ab}} \cong \mathbb{Z}/2$ for $n\ge 2$.** Prove
   $[S_n, S_n] = A_n$, so the only linear characters are the trivial and sign characters,
   upgrading Proposition 5.2 from "at least two" to "exactly two."

4. **Column orthogonality and centralizer sizes.** For $S_n$, the squared norm of the
   column at a class of cycle type $\lambda$ equals the centralizer order
   $z_\lambda = \prod_i i^{m_i} m_i!$, via column orthogonality
   $\sum_\chi |\chi(g)|^2 = |C_G(g)|$ and `ConjClasses.card_carrier`.

---

## 10. Conclusion

We have given a machine-verified construction of the bijection between integer partitions
of $n$ and conjugacy classes of the symmetric group $S_n$, deduced that $S_n$ has exactly
$p(n)$ conjugacy classes — hence a $p(n)\times p(n)$ character table — and computed the
first three cases $p(3)=3$, $p(4)=5$, $p(5)=7$. Together with the two universal linear
characters and their orthogonality, this fixes both the shape of the symmetric-group
character tables and their first two rows, on a foundation that is constructive and free
of unverified assumptions.

---

## References (classical background, for orientation only)

- W. Burnside, *Theory of Groups of Finite Order*.
- G. James and A. Kerber, *The Representation Theory of the Symmetric Group*.
- J.-P. Serre, *Linear Representations of Finite Groups*.
- OEIS A000041, the partition function $p(n)$.
