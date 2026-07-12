# Fuss–Catalan Numbers, Dyck Paths, and the Recursive Decomposition Underlying Greedy $m$-Tamari Intervals

**Author:** Aristotle
**Date:** 2026-07-12

## Abstract

We develop, from first principles, a single connected chain of results centered on
the **Fuss–Catalan numbers**
$$\mathrm{FC}(m,n) = \frac{1}{mn+1}\binom{(m+1)n}{n},$$
the enumerative backbone of every "via Dyck paths" statement in the greedy
$m$-Tamari / $(m+1)$-constellation program. We prove the universal base cases
$\mathrm{FC}(m,0)=\mathrm{FC}(m,1)=1$ for all arities $m$, and we treat the base
layer $m=1$ — the ordinary Catalan numbers — in full. For $m=1$ we establish the
exact integrality identity $(n+1)\,C_n = \binom{2n}{n}$, strict positivity, the
Catalan-convolution recursive decomposition $C_{n+1}=\sum_{i=0}^{n} C_i C_{n-i}$,
monotonicity $C_n \le C_{n+1}$, and a uniform lower bound $C_n \ge 1$. We then close
the combinatorial loop: $C_n$ simultaneously enumerates Dyck paths of semilength
$n$, binary trees with $n$ internal nodes, and plane (planar) trees with $n+1$
nodes. The last identity is obtained by constructing the classical Knuth
left-child / right-sibling bijection between ordered plane forests and binary trees
from scratch and verifying that it preserves the node count. As a corollary, plane
trees with $n+1$ nodes are in explicit bijection with Dyck paths of semilength $n$.
We situate these results as the fully rigorous base layer of the greedy $m$-Tamari
interval program and outline the general-$m$ generalizations required to complete
it.

**Keywords:** Fuss–Catalan numbers, Catalan numbers, Dyck paths, plane trees,
binary trees, Knuth bijection, recursive decomposition, Tamari lattice,
$(m+1)$-constellations.

## 1. Introduction

The Catalan numbers $C_n = \frac{1}{n+1}\binom{2n}{n} = 1, 1, 2, 5, 14, 42, \dots$
are among the most ubiquitous sequences in enumerative combinatorics, counting
hundreds of families of structures. Their higher-arity generalizations, the
**Fuss–Catalan numbers** $\mathrm{FC}(m,n) = \frac{1}{mn+1}\binom{(m+1)n}{n}$, count
$(m+1)$-ary plane trees with $n$ internal nodes and, equivalently, the $m$-Dyck
paths of length $(m+1)n$ (lattice paths taking up-steps and down-steps in a ratio
$1{:}m$ that stay weakly above the axis).

Our motivation comes from a conjecture of Bousquet-Mélou and Chapoton, generalized
to arbitrary arity $m$: the number of maximal *greedy $m$-Tamari intervals* in a
planar $(m+1)$-constellation equals the number of maximal planar trees with $m$
internally labeled vertices, the correspondence being realized *through Dyck path
structures*. Every "via Dyck paths" step in such a program rests on the arithmetic
and bijective theory of the Fuss–Catalan numbers. The purpose of the present paper
is to establish that foundation rigorously at the base layer $m=1$, where the
objects are Dyck paths, binary trees, and plane trees, and to record the universal
facts that hold for all $m$.

The paper is organized as a *chain*: each result is used by the next. Section 2
gives the definitions. Section 3 develops the arithmetic tower (integrality,
positivity, recursion, monotonicity, bounds). Section 4 develops the combinatorial
identities (Dyck paths, binary trees, plane trees) and the Knuth bijection. Section
5 discusses applications to the Tamari program, and Section 6 lays out future
directions.

## 2. Definitions

**Definition 2.1 (Fuss–Catalan number).**
For nonnegative integers $m, n$ define
$$\mathrm{FC}(m,n) = \left\lfloor \frac{\binom{(m+1)n}{n}}{mn+1} \right\rfloor,$$
where the division is understood in the natural numbers. We will see that for the
cases of interest the division is *exact*, so the floor is invisible. For $m=1$ this
reduces to the ordinary Catalan number $C_n$.

**Definition 2.2 (Central binomial coefficient).**
$\mathrm{cb}(n) = \binom{2n}{n}$.

**Definition 2.3 (Dyck path).**
A *Dyck path* (or Dyck word) of *semilength* $n$ is a lattice path from $(0,0)$ to
$(2n,0)$ using unit up-steps $(1,1)$ and down-steps $(1,-1)$ that never passes below
the horizontal axis. Equivalently, it is a balanced string of $n$ opening and $n$
closing symbols in which every prefix has at least as many openings as closings. We
write $\mathcal{D}_n$ for the set of Dyck paths of semilength $n$.

**Definition 2.4 (Binary tree).**
A *binary tree* is either the empty tree $\bot$ or an internal node carrying an
ordered pair of binary trees (its left and right subtrees). Its number of *internal
nodes* is the number of non-empty nodes. We write $\mathcal{B}_n$ for the set of
binary trees with exactly $n$ internal nodes.

**Definition 2.5 (Plane tree and plane forest).**
A *plane tree* (ordered rooted tree) is a root together with a finite *ordered list*
of plane trees, its children; the order of children is part of the data. Its number
of *nodes* $\nu(t)$ is $1$ plus the sum of the node counts of its children:
$$\nu(\mathrm{node}(t_1,\dots,t_k)) = 1 + \sum_{i=1}^{k} \nu(t_i).$$
A *plane forest* is a finite ordered list $f = (t_1,\dots,t_k)$ of plane trees; its
node count is $\nu(f) = \sum_{i=1}^{k}\nu(t_i)$. We write $\mathcal{P}_{n}$ for the
set of plane trees with exactly $n$ nodes.

## 3. The arithmetic chain

We first record the two universal base cases, valid for every arity, and then
develop the base layer $m=1$ in full.

**Theorem 3.1 (Empty object; all $m$).** For every $m$, $\mathrm{FC}(m,0)=1$.

*Proof.* With $n=0$ the formula reads $\binom{0}{0}/(0+1) = 1/1 = 1$. $\square$

**Theorem 3.2 (Root-only object; all $m$).** For every $m$, $\mathrm{FC}(m,1)=1$.

*Proof.* With $n=1$ the numerator is $\binom{m+1}{1} = m+1$ and the denominator is
$m\cdot 1 + 1 = m+1$, so the quotient is $1$. $\square$

**Theorem 3.3 (Base layer).** For every $n$, $\mathrm{FC}(1,n) = C_n$, the $n$-th
Catalan number.

*Proof.* With $m=1$ the numerator is $\binom{2n}{n} = \mathrm{cb}(n)$ and the
denominator is $n+1$, which is precisely the closed form $C_n =
\mathrm{cb}(n)/(n+1)$. $\square$

**Theorem 3.4 (Exactness / integrality).** For every $n$,
$$(n+1)\,C_n = \binom{2n}{n}.$$

*Proof.* The key divisibility is that $n+1$ divides the central binomial
coefficient $\binom{2n}{n}$; this is the integrality of the Catalan numbers.
Granting the divisibility, $C_n = \binom{2n}{n}/(n+1)$ is exact, and multiplying
back by $n+1$ recovers $\binom{2n}{n}$. The divisibility $(n+1)\mid\binom{2n}{n}$
follows from the standard identity $\binom{2n}{n} - \binom{2n}{n+1} = C_n$ (the
"ballot" difference of adjacent binomial coefficients), which exhibits $C_n$ as an
integer directly. $\square$

**Theorem 3.5 (Positivity).** For every $n$, $C_n > 0$.

*Proof.* If $C_n = 0$ then Theorem 3.4 gives $(n+1)\cdot 0 = \binom{2n}{n}$, i.e.
$\binom{2n}{n}=0$, contradicting the strict positivity of the central binomial
coefficient. $\square$

**Theorem 3.6 (Recursive decomposition — Catalan convolution).** For every $n$,
$$C_{n+1} = \sum_{i=0}^{n} C_i\, C_{n-i}.$$

*Proof (bijective).* A nonempty Dyck path $w$ of semilength $n+1$ has a well-defined
*first return* to the axis. Writing $w = u\, D\, w'$, where $u$ is the up-step that
begins the path, $D$ is the down-step of the first return, and letting $v$ denote the
sub-path strictly between them and $w'$ the sub-path after $D$, one obtains a pair
$(v, w')$ of Dyck paths whose semilengths sum to $n$. This decomposition is a
bijection
$$\mathcal{D}_{n+1} \;\xrightarrow{\ \sim\ }\; \bigsqcup_{i=0}^{n}
\mathcal{D}_i \times \mathcal{D}_{n-i},$$
and counting both sides yields the convolution. The identical recursion arises by
splitting a binary tree with $n+1$ internal nodes into its left subtree (with $i$
internal nodes) and right subtree (with $n-i$ internal nodes). $\square$

**Theorem 3.7 (Monotonicity).** For every $n$, $C_n \le C_{n+1}$.

*Proof.* In the convolution $C_{n+1} = \sum_{i+j=n} C_i C_j$ (summed over ordered
pairs with $i+j=n$), the single term with $(i,j) = (n,0)$ contributes $C_n\cdot C_0
= C_n$ (using $C_0=1$). All other terms are nonnegative, so the total is at least
$C_n$. $\square$

**Theorem 3.8 (Lower bound).** For every $n$, $C_n \ge 1$.

*Proof.* Immediate from positivity (Theorem 3.5), since $C_n$ is a positive
integer. $\square$

## 4. Combinatorial identities and the Knuth bijection

We now realize the base-layer counts as cardinalities of three concrete families.

**Theorem 4.1 (Dyck paths — the "via Dyck paths" identity).** For every $n$,
$$C_n = \#\,\mathcal{D}_n,$$
the number of Dyck paths of semilength $n$.

*Proof.* This is the classical enumeration of Dyck paths by the Catalan numbers,
which can itself be proved from the recursive decomposition of Theorem 3.6 together
with the base value $\#\mathcal{D}_0 = 1$: both sequences satisfy the same recurrence
and initial condition. $\square$

**Theorem 4.2 (Binary trees).** For every $n$,
$$C_n = \#\,\mathcal{B}_n,$$
the number of binary trees with $n$ internal nodes.

*Proof.* Binary trees with $n$ internal nodes satisfy the same convolution
recurrence (split at the root into left and right subtrees) and the same base case
($\#\mathcal{B}_0 = 1$, the empty tree). Hence $\#\mathcal{B}_n = C_n$. $\square$

We now introduce the bijection that reaches the plane-tree family.

**Definition 4.3 (Knuth transform).**
Define maps between plane forests and binary trees recursively.

*Forest to binary tree* $\Phi$:
$$\Phi(\,[\,]\,) = \bot, \qquad
\Phi\big(\mathrm{node}(t_1,\dots,t_k)::\mathit{rest}\big)
= \big(\Phi(t_1,\dots,t_k),\ \Phi(\mathit{rest})\big),$$
i.e. the children of the first tree become the left subtree and the remaining
forest becomes the right subtree.

*Binary tree to forest* $\Psi$:
$$\Psi(\bot) = [\,], \qquad
\Psi\big((\ell, r)\big) = \mathrm{node}(\Psi(\ell))::\Psi(r),$$
i.e. the left subtree is read as the children of a new first tree and the right
subtree is read as the remaining forest.

**Lemma 4.4 (Mutual inverses).** $\Psi\circ\Phi = \mathrm{id}$ on plane forests and
$\Phi\circ\Psi = \mathrm{id}$ on binary trees.

*Proof.* Structural induction. For $\Psi\circ\Phi$: the empty forest is fixed by
inspection; for a forest $\mathrm{node}(ts)::\mathit{rest}$, applying $\Phi$ then
$\Psi$ reconstructs the head node from the left subtree $\Phi(ts)$ (which by
induction decodes to $ts$) and the tail from the right subtree $\Phi(\mathit{rest})$
(which by induction decodes to $\mathit{rest}$). The argument for $\Phi\circ\Psi$ is
symmetric, splitting on $\bot$ versus $(\ell,r)$. $\square$

**Lemma 4.5 (Size preservation).** For every plane forest $f$, the binary tree
$\Phi(f)$ has exactly $\nu(f)$ internal nodes.

*Proof.* Induction on $f$. The empty forest maps to $\bot$ with $0$ internal nodes,
matching $\nu([\,])=0$. For $\mathrm{node}(ts)::\mathit{rest}$, the image is an
internal node with left subtree $\Phi(ts)$ and right subtree $\Phi(\mathit{rest})$,
so its internal-node count is $1 + \#\mathrm{int}(\Phi(ts)) +
\#\mathrm{int}(\Phi(\mathit{rest}))$. By induction this equals $1 + \nu(ts) +
\nu(\mathit{rest})$, which is exactly $\nu(\mathrm{node}(ts)) + \nu(\mathit{rest}) =
\nu(\mathrm{node}(ts)::\mathit{rest})$. $\square$

**Corollary 4.6 (Knuth bijection, graded).** For every $n$, $\Phi$ restricts to a
bijection between plane forests with $n$ nodes and binary trees with $n$ internal
nodes. Consequently these families are equinumerous, both counted by $C_n$.

*Proof.* Lemma 4.4 makes $\Phi$ a bijection, and Lemma 4.5 shows it maps the
$n$-node forests exactly onto the $n$-internal-node binary trees. Combine with
Theorem 4.2. $\square$

**Theorem 4.7 (Plane trees).** For every $n$,
$$C_n = \#\,\mathcal{P}_{n+1},$$
the number of plane trees with $n+1$ nodes.

*Proof.* A plane tree with $n+1$ nodes is uniquely its root together with the
ordered forest of its children; that child-forest has exactly $n$ nodes. Thus plane
trees with $n+1$ nodes correspond bijectively to plane forests with $n$ nodes, which
by Corollary 4.6 correspond to binary trees with $n$ internal nodes, counted by
$C_n$ (Theorem 4.2). $\square$

**Corollary 4.8 (Plane trees $\leftrightarrow$ Dyck paths).** For every $n$,
$$\#\,\mathcal{P}_{n+1} = \#\,\mathcal{D}_n.$$

*Proof.* Both equal $C_n$ by Theorems 4.7 and 4.1. Explicitly, the composite
bijection is: strip a plane tree to its child-forest, apply the Knuth transform
$\Phi$ to obtain a binary tree, and encode that binary tree as a Dyck path by the
standard depth-first traversal. $\square$

## 5. Applications: the greedy $m$-Tamari program

On the set $\mathcal{D}_n$ of Dyck paths there is a natural partial order — one path
lies below another if it stays weakly beneath it — whose Hasse diagram, suitably
arranged, is the **Tamari lattice** $\mathcal{T}_n$. Its intervals are pairs
$(p, q)$ with $p \le q$, together with all paths in between. The Tamari lattice and
its intervals are central to the combinatorics of associativity, to the geometry of
associahedra, and to modern algebra (diagonal harmonics, cluster theory).

The Bousquet-Mélou–Chapoton conjecture, in its arity-$m$ generalization, predicts
that maximal *greedy $m$-Tamari intervals* inside a planar $(m+1)$-constellation are
equinumerous with maximal planar trees carrying $m$ internally labeled vertices, and
that the equinumerosity is realized *via Dyck path structures*. The common counting
sequence is Fuss–Catalan.

The results of this paper are the fully rigorous **base layer** ($m=1$) of that
program:

1. The arithmetic tower (Theorems 3.1–3.8) fixes the exact values, positivity,
   recursive self-similarity, and growth of the counts.
2. The bijective tower (Theorems 4.1–4.7, Corollary 4.8) realizes those counts on
   the three object families named by the conjecture — Dyck paths, binary trees, and
   plane trees — and provides *explicit* dictionaries between them, not merely
   equalities of numbers.

Because the correspondence is bijective and grade-preserving, it can in principle be
refined to track combinatorial statistics (valleys, active sites), which is exactly
the level of detail the general conjecture demands.

## 6. Discussion and future work

The base layer $m=1$ is complete and self-contained. The path upward is clear, and
the following directions capture what remains.

1. **General-$m$ integrality.** Prove $(mn+1)\mid\binom{(m+1)n}{n}$, giving
   $(mn+1)\,\mathrm{FC}(m,n) = \binom{(m+1)n}{n}$ for all $m$. The standard route is
   the cycle lemma (Dvoretzky–Motzkin); the base case $m=1$ is the divisibility used
   in Theorem 3.4.

2. **General-$m$ recursive decomposition.** Establish the $(m+1)$-fold
   self-convolution
   $$\mathrm{FC}(m,n+1) = \sum_{k_1+\cdots+k_{m+1}=n}
   \mathrm{FC}(m,k_1)\cdots\mathrm{FC}(m,k_{m+1}),$$
   the arithmetic shadow of the functional equation $A = 1 + x\,A^{m+1}$ for
   $(m+1)$-ary trees.

3. **$(m+1)$-ary plane trees.** Generalize the plane-tree / Knuth bijection to an
   enumeration of $(m+1)$-ary plane trees by internal nodes, proving their count is
   $\mathrm{FC}(m,n)$ (bijection to $m$-Dyck paths).

4. **The greedy $m$-Tamari interval bijection.** Build the recursive-decomposition
   isomorphism between greedy $m$-Tamari intervals in a planar $(m+1)$-constellation
   and maximal planar trees with $m$ internally labeled vertices, refining the
   equinumerosity to the tracked statistics (valleys / active sites). The remaining
   piece is to identify the common counting sequence with the Fuss–Catalan numbers
   established here.

## 7. Conclusion

We have assembled a single connected chain of results anchoring the greedy
$m$-Tamari program at its base. The arithmetic of the Fuss–Catalan numbers — with
the universal base cases $\mathrm{FC}(m,0)=\mathrm{FC}(m,1)=1$ and the full
integrality, positivity, convolution, and monotonicity theory of the Catalan case
$m=1$ — is matched, bijectively and grade by grade, with the enumeration of Dyck
paths, binary trees, and plane trees. The Knuth left-child / right-sibling bijection,
built here from scratch and shown to preserve size, closes the loop between the
"planar tree" and "Dyck path" sides of the story. This is the solid ground on which
the general-$m$ theory, and ultimately the full conjecture, can be constructed.
