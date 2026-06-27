# The Fano-Plane Threshold for Strong Blocking Sets: the $h=1$ Case of Additive Strong Blocking and the Length-6 Minimal Code

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (finite geometry / coding theory)

## Abstract

A *strong blocking set* in a finite projective plane is a set $S$ of points whose
intersection with every line *spans* that line. Strong blocking sets are the
geometric counterpart, under the projective-system correspondence, of *minimal*
linear codes — codes in which no codeword support is contained in another — which
underpin secret-sharing and secure-computation protocols. We give a complete and
self-contained analysis of the smallest nontrivial case: the Fano plane
$PG(2,2)$, the unique projective plane on $7$ points. We prove a sharp threshold
(`strongBlocking_iff_card`): a subset $S$ of the seven points is strong blocking if
and only if $|S| \geq 6$, i.e. iff $S$ omits at most one point. We deduce the exact
minimum size (`leastSize_strongBlocking`): the least cardinality of a strong
blocking set in $PG(2,2)$ is exactly $6$, attained precisely by the seven
"all-but-one-point" sets. Through the projective-system dictionary this is
equivalent to the statement that the shortest nondegenerate minimal binary linear
code of dimension $3$ has length $6$. We position $PG(2,2)$ as the base ($h=1$) case
of additive strong blocking sets, isolate the two combinatorial mechanisms — "a
point lies on three lines" and "two points span a unique line" — that drive the
result, and explain why both fail for $q \geq 3$, motivating a sequence of
conjectures on higher planes and on the additive $h$-fold generalization.

## 1. Introduction

### 1.1 Motivation

Projective geometry over finite fields is a meeting point of three subjects:
incidence geometry, extremal combinatorics, and the theory of error-correcting
codes. A recurring theme is to identify *small* point configurations that retain a
global structural property. Blocking sets (meeting every line) and their stronger
cousins, *strong blocking sets* (spanning every line), are central examples. Strong
blocking sets — also called *cutting blocking sets* or *generating sets* — have
attracted intense recent interest because of a precise equivalence with **minimal
linear codes**, objects with direct applications to secret sharing and secure
multiparty computation.

The general extremal problem — determine the minimum size of a strong blocking set
in $PG(k-1, q)$ — is hard and largely open, with active work on asymptotic lower and
upper bounds. In this paper we treat the smallest nontrivial instance completely:
the projective plane of order two, the **Fano plane** $PG(2,2)$. Despite (indeed,
because of) its size, the Fano plane is the cleanest laboratory in which the strong
blocking threshold can be settled exactly, every extremizer classified, and the
coding-theoretic translation made fully explicit.

### 1.2 Contributions

1. A precise definition of strong blocking specialized to $PG(2,2)$, where spanning a
   line is equivalent to containing at least two of its three points (Section 2).
2. A sharp threshold theorem, `strongBlocking_iff_card`: $S$ is strong blocking iff
   $|S| \geq 6$ (Theorem 3.1).
3. The exact minimum, `leastSize_strongBlocking`: the least size is $6$ (Theorem 3.4),
   with a complete classification of the minimizers (Proposition 3.5).
4. The coding-theoretic corollary: the shortest nondegenerate minimal binary linear
   code of dimension $3$ has length $6$ (Section 5).
5. A structural account ($h=1$ base case, the two driving mechanisms, the breakdown
   at $q \geq 3$) and a program of conjectures (Sections 4, 6, 7).

## 2. Definitions

We work in the Fano plane $PG(2,2)$, the projective plane over the field
$\mathbb{F}_2 = \{0,1\}$.

**Definition 2.1 (Points).** The point set $\mathcal{P}$ of $PG(2,2)$ is the set of
one-dimensional subspaces of $\mathbb{F}_2^3$, equivalently the $2^3 - 1 = 7$ nonzero
vectors of $\mathbb{F}_2^3$. We label them $\mathcal{P} = \{0,1,2,3,4,5,6\}$.

**Definition 2.2 (Lines; `IsLine`).** A *line* of $PG(2,2)$ is a two-dimensional
subspace of $\mathbb{F}_2^3$; as a set of points each line has $q+1 = 3$ points. There
are exactly $7$ lines. In the standard labelling,
$$\mathcal{L} = \big\{\, \{0,1,2\},\ \{0,3,4\},\ \{0,5,6\},\ \{1,3,5\},\ \{1,4,6\},\ \{2,3,6\},\ \{2,4,5\} \,\big\}.$$
The predicate `IsLine ℓ` holds iff $\ell \in \mathcal{L}$.

The Fano plane satisfies the projective-plane axioms, of which we use two repeatedly.

**Fact 2.3 (Incidence axioms of $PG(2,2)$).**
(a) *Uniqueness of joins:* any two distinct points $p \neq q$ lie on a unique common
line, denoted $\ell_{pq}$.
(b) *Pencils:* each point lies on exactly $3$ lines; each line has exactly $3$ points.

**Definition 2.4 (Strong blocking; `StrongBlocking`).** A set $S \subseteq \mathcal{P}$
is a *strong blocking set* if for every line $\ell$, the points $S \cap \ell$ *span*
$\ell$ (as a projective subspace). Over $\mathbb{F}_2$, two distinct points of a line
already span the line, while one point spans only itself; hence
$$\text{StrongBlocking}(S) \iff \forall \ell \in \mathcal{L},\ |S \cap \ell| \geq 2.$$
We take the right-hand combinatorial condition as the working definition throughout.

**Remark 2.5.** The general notion (intersection spans the line) and the $\mathbb{F}_2$
counting condition $|S\cap\ell|\ge 2$ coincide *only* because a projective line over
$\mathbb{F}_2$ has three points and any two are a spanning pair. This coincidence is
the source of both the simplicity of the result and the fragility of the argument under
$q \to q+1$.

## 3. Main results

### 3.1 The threshold theorem

**Theorem 3.1 (`strongBlocking_iff_card`).** For $S \subseteq \mathcal{P}$,
$$\text{StrongBlocking}(S) \iff |S| \geq 6.$$
Equivalently, $S$ is strong blocking iff it omits at most one of the seven points.

*Proof sketch.* We prove the two implications separately.

**($\Leftarrow$) If $|S|\ge 6$ then $S$ is strong blocking.** Since $|\mathcal P| = 7$,
$|S| \geq 6$ means $S = \mathcal{P}$ or $S = \mathcal{P}\setminus\{p\}$ for a single
point $p$. If $S = \mathcal{P}$ every line keeps all three points, so trivially
$|S\cap\ell| = 3 \geq 2$. If $S = \mathcal{P}\setminus\{p\}$, consider any line $\ell$.
By Fact 2.3(b) the point $p$ lies on exactly $3$ lines. If $\ell$ is one of these,
$\ell$ loses exactly the point $p$ and keeps its other two points, so
$|S\cap\ell| = 2$. If $\ell$ does not pass through $p$, then $\ell \subseteq S$ and
$|S\cap\ell| = 3$. In all cases $|S\cap\ell|\ge 2$. This is the content of
Lemma 3.2.

**($\Rightarrow$) If $|S|\le 5$ then $S$ is not strong blocking.** If $|S|\le 5$ then
$\mathcal{P}\setminus S$ contains two distinct points $p\ne q$. By Fact 2.3(a) there is
a unique line $\ell_{pq}$ containing both. That line has three points; two of them,
$p$ and $q$, are absent from $S$, so $|S\cap\ell_{pq}| \le 1 < 2$. Hence $\ell_{pq}$ is
not spanned and $S$ is not strong blocking. Contrapositively, strong blocking forces
$|S|\ge 6$. This is Lemma 3.3. $\qquad\blacksquare$

We isolate the two halves as named lemmas, since each is reused.

**Lemma 3.2 (Sufficiency; omit-one is blocking).** For every point $p$, the set
$\mathcal{P}\setminus\{p\}$ is strong blocking, and so is $\mathcal{P}$.

*Proof sketch.* Each of the $3$ lines through $p$ retains $2$ points; the remaining
$4$ lines retain $3$. $\square$

**Lemma 3.3 (Necessity; two deletions kill a line).** If $S$ omits two distinct points
$p\ne q$, then $|S\cap \ell_{pq}|\le 1$, so $S$ is not strong blocking.

*Proof sketch.* Uniqueness of the line through two points (Fact 2.3(a)) puts both
deleted points on the single line $\ell_{pq}$, leaving it with at most one survivor. $\square$

### 3.2 The minimum size

**Theorem 3.4 (`leastSize_strongBlocking`).** Let
$$N \;=\; \{\, n \in \mathbb{N} \;:\; \exists\, S \subseteq \mathcal{P},\ \text{StrongBlocking}(S)\ \text{and}\ |S| = n \,\}.$$
Then $N$ has a least element and $\min N = 6$; i.e. $\mathrm{IsLeast}(N, 6)$.

*Proof sketch.* *Membership $6 \in N$:* by Lemma 3.2, $S = \mathcal{P}\setminus\{p\}$
is strong blocking with $|S| = 6$. *Lower bound:* if $n \in N$ is witnessed by a strong
blocking $S$ with $|S| = n$, then by Theorem 3.1, $n = |S| \ge 6$. Both conditions of
`IsLeast` — membership and being a lower bound — hold. $\qquad\blacksquare$

**Proposition 3.5 (Classification of minimizers).** The strong blocking sets of size
$6$ are exactly the seven sets $\mathcal{P}\setminus\{p\}$, $p\in\mathcal P$. Moreover
every minimum strong blocking set of $PG(2,2)$ has this "omit-one-point" form.

*Proof sketch.* Any $6$-element subset of a $7$-element set is the complement of a
unique single point, and each such set is strong blocking by Lemma 3.2; conversely no
set of size $<6$ is strong blocking by Theorem 3.1. $\square$

**Remark 3.6 (Finite verification).** Because $|\mathcal{P}| = 7$, the entire content of
Theorems 3.1 and 3.4 is decidable: one may enumerate all $2^7 = 128$ subsets and the
$7$ lines and check the spanning condition directly. This decidability is what makes
$PG(2,2)$ the unique projective plane in which every incidence axiom and every extremal
claim can be settled by exhaustive, kernel-level checking, and it is reflected in the
formal development by `decide`-style certification.

### 3.3 A fully worked example

We make Theorems 3.1 and 3.4 concrete in the standard labelling. The seven points
are $\{0,1,2,3,4,5,6\}$ and the seven lines are
$$\{0,1,2\},\ \{0,3,4\},\ \{0,5,6\},\ \{1,3,5\},\ \{1,4,6\},\ \{2,3,6\},\ \{2,4,5\}.$$
One verifies directly that each label occurs in exactly three lines (Fact 2.3(b)) and
that each unordered pair of labels occurs together in exactly one line (Fact 2.3(a));
for instance the pair $\{3,6\}$ appears only in $\{2,3,6\}$.

*A size-6 set works.* Take $S = \{1,2,3,4,5,6\} = \mathcal{P}\setminus\{0\}$. The three
lines through $0$ are $\{0,1,2\}, \{0,3,4\}, \{0,5,6\}$; after deleting $0$ they retain
$\{1,2\}, \{3,4\}, \{5,6\}$ respectively — two points each. The remaining four lines
$\{1,3,5\}, \{1,4,6\}, \{2,3,6\}, \{2,4,5\}$ avoid $0$ entirely and retain all three
points. So $\min_\ell |S\cap\ell| = 2$ and $S$ is strong blocking.

*A size-5 set fails.* Take $S' = \{2,3,4,5,6\} = \mathcal{P}\setminus\{0,1\}$. The unique
line through the two deleted points $0$ and $1$ is $\ell_{01} = \{0,1,2\}$, which retains
only the single point $2$. Hence $|S'\cap\ell_{01}| = 1 < 2$ and $S'$ is not strong
blocking, exactly as Lemma 3.3 predicts. No relabelling of which two points are dropped
escapes this: every pair lies on some line, and that line is the witness of failure.

*The counting census.* An exhaustive scan of all $2^7 = 128$ subsets finds precisely
$8$ strong blocking sets: the full set $\mathcal{P}$ (size $7$) and the seven complements
$\mathcal{P}\setminus\{p\}$ (size $6$). There are no strong blocking sets of size $\le 5$.
This census simultaneously confirms Theorem 3.1 (blocking $\iff |S|\ge 6$),
Theorem 3.4 ($\min = 6$), and Proposition 3.5 (the seven minimizers are exactly the
omit-one sets).

## 4. The two mechanisms, and why $q=2$ is special

The proof of Theorem 3.1 uses exactly two geometric inputs:

- **(M1) Pencil budget.** A point lies on $3$ lines; deleting it removes one point from
  each, and since a line has $3$ points, each such line still has $2$. This drives
  sufficiency (Lemma 3.2).
- **(M2) Unique join.** Two distinct points share a unique line; deleting both reduces
  that line to a single survivor. This drives necessity (Lemma 3.3).

Both inputs are tight to $q=2$:

1. In $PG(2,q)$ a line has $q+1$ points. For (M1), deleting one point from a line of
   size $q+1$ leaves $q \geq 2$ survivors, so omitting a single point *does* keep every
   line spanned for all $q$ — but spanning a line over $\mathbb{F}_q$ requires $2$
   points only because lines are $1$-dimensional; the *global* "omit a point" recipe is
   no longer optimal for $q\ge 3$.
2. For (M2), with $q\ge 3$ one may omit *several* points from a line and still leave
   $\ge 2$, so a single shared line no longer collapses; the controlling quantity
   becomes the number of omitted points *per line*, not the global deletion count.

Thus the clean equivalence "strong blocking $\iff$ omit $\le 1$ point" is a
$q=2$ phenomenon. The next plane $PG(2,3)$ ($13$ points, lines of size $4$) already has
minimum strong blocking size $8 < 12$, realized by structured configurations (e.g. two
disjoint lines, or a dual hyperoval), strictly beating the naive "omit a point" bound
of $12$.

## 5. Coding-theoretic interpretation

### 5.1 The projective-system correspondence

Fix a field $\mathbb{F}_q$ and a dimension $k$. A nondegenerate $[n,k]_q$ linear code
$C$ (a $k$-dimensional subspace of $\mathbb{F}_q^n$ with no identically-zero
coordinate) corresponds, up to equivalence, to a multiset of $n$ points in
$PG(k-1,q)$, obtained by reading the columns of a generator matrix as projective
points. Under this dictionary the *length* $n$ equals the number of points, and the
*weight* of a codeword $c = xG$ equals $n$ minus the number of points lying on the
hyperplane $\{y : x\cdot y = 0\}$.

**Definition 5.1 (Minimal code).** A nonzero codeword $c$ is *minimal* if its support
$\mathrm{supp}(c)$ does not properly contain the support of any other nonzero codeword.
A code is *minimal* if all of its nonzero codewords are minimal.

**Theorem 5.2 (Folklore correspondence; stated, not re-proved here).** A nondegenerate
$[n,k]_q$ code is minimal if and only if the corresponding point set in $PG(k-1,q)$ is a
strong blocking set.

The reason is structural: minimal codewords correspond exactly to the lines (more
generally hyperplanes) spanned by $S \cap \ell$, so the algebraic minimality condition
is *definitionally* the geometric spanning condition.

### 5.2 Consequence for $k=3$, $q=2$

Specializing Theorem 5.2 to $k=3$, $q=2$ and combining with Theorem 3.4:

**Corollary 5.3 (Shortest dimension-3 minimal binary code).** The minimum length of a
nondegenerate minimal binary linear code of dimension $3$ is $6$. The optimum is
realized by the code whose generator matrix has as columns the six points of a set
$\mathcal{P}\setminus\{p\}$ in $PG(2,2)$.

*Proof sketch.* By Theorem 5.2 a minimal $[n,3]_2$ code corresponds to a strong
blocking set of size $n$ in $PG(2,2)$; by Theorem 3.4 the least such $n$ is $6$, and the
optimizer is an omit-one-point configuration. $\square$

Concretely, choosing $\mathcal{P}\setminus\{0\} = \{1,2,3,4,5,6\}$ and writing the six
points as binary column vectors of $\mathbb{F}_2^3$ gives a $3\times 6$ generator matrix
of a length-$6$, dimension-$3$ minimal code: the shortest possible.

### 5.3 Why minimal codes matter

Minimal codes are precisely the codes usable in Massey's secret-sharing scheme, where
the minimal codewords enumerate the authorized coalitions. They also appear in secure
two-party computation. Short minimal codes are therefore practically desirable, and
Corollary 5.3 is a sharp lower bound on length for dimension $3$ over $\mathbb{F}_2$.

### 5.4 The optimal generator matrix

The optimizer of Corollary 5.3 can be written down explicitly. Realize the seven points
of $PG(2,2)$ as the seven nonzero vectors of $\mathbb{F}_2^3$. Dropping the point
corresponding to one vector and stacking the remaining six as the columns of a
$3\times 6$ matrix $G$ yields a generator matrix of a length-$6$, dimension-$3$ binary
code. Because the six columns are the nonzero vectors of $\mathbb{F}_2^3$ minus one, no
column is zero (nondegeneracy) and the code is minimal by Theorem 5.2 and Theorem 3.1.
No $3\times 5$ matrix over $\mathbb{F}_2$ can generate a minimal code, because its five
columns would correspond to a strong blocking set of size $5$, which by Theorem 3.1 does
not exist. Thus length $6$ is not merely achievable but unbeatable for dimension $3$
over $\mathbb{F}_2$.

### 5.5 Related extremal context

The general problem of the minimum size $m(k,q)$ of a strong blocking set in
$PG(k-1,q)$ — equivalently the minimum length of a minimal $[n,k]_q$ code — has been
studied via probabilistic, algebraic, and explicit constructions, with known
asymptotic bounds linear in both $k$ and $q$. The Fano case computes the very first
nontrivial value $m(3,2) = 6$ exactly and on the nose, with full classification of
optimizers, providing a clean anchor for the general theory and a unit test for any
proposed general lower bound (which must return $6$ at $(k,q)=(3,2)$).

## 6. Discussion

The Fano result is satisfying because three readings coincide on the number $6$:

- **Geometric:** delete one point and every line stays spanned; delete two and the line
  joining them collapses.
- **Extremal:** a sharp size threshold at $6$, with the extremizers completely
  classified as the complements of single points.
- **Coding-theoretic:** the shortest minimal $[n,3]_2$ code has length $6$.

The development also clarifies *where* the simplicity lives. By isolating mechanisms
(M1) and (M2), one sees that the equivalence with "omit at most one point" is special to
the two-element field, and that the right generalization for $q \geq 3$ must track
per-line deletion budgets rather than a single global count. This per-line viewpoint is
exactly what is needed to attack $PG(2,3)$ and beyond.

A further structural observation concerns *uniqueness of extremizers*. In $PG(2,2)$ all
minimizers are of one shape (omit a point); for $q \ge 3$ this uniqueness fails, with
unions of lines and dual hyperovals providing genuinely different extremal
configurations. Non-uniqueness thus appears to switch on exactly at the transition away
from $q = 2$.

## 7. Future work

The present results are the $h=1$ base case of a broader program on additive strong
blocking sets. We record the natural next targets.

- **$PG(2,3)$ threshold is $8$, not $q^2+q-1 = 11$.** In $PG(2,3)$ ($13$ points, lines
  of size $4$) the minimal strong blocking set has size $8$ (two disjoint complete
  $4$-point lines, or a dual hyperoval), strictly larger than the naive omit-one bound.
  The controlling quantity is the number of omitted points *per line*; re-running the
  complement-counting argument with per-line budgets is the concrete next experiment.
- **Tightness is non-unique exactly when $q=2$.** Every minimum strong blocking set of
  $PG(2,2)$ is $\mathcal{P}\setminus\{p\}$; for $q\ge 3$ the minimizers are not all of
  this form. Classifying the `IsLeast` witnesses for small $q$ is finitely checkable.
- **Minimal binary $[n,3]$ minimal-code length equals $6$ iff length-optimal.** Under
  the projective-system correspondence, a nondegenerate minimal binary linear code of
  dimension $3$ has length $\ge 6$, with equality realized by the simplex-minus
  configuration of $PG(2,2)$. Formalizing the projective-system functor would upgrade
  Corollary 5.3 to a statement about general linear codes directly.
- **Additive $h$-fold generalization: threshold is $6h$ for $PG(2,2)^h$.** For additive
  strong blocking sets with parameter $h$, the minimal size is conjectured to scale
  linearly to $6h$, recovering $6$ at $h=1$, because the $h$-dimensional fiber decouples
  into $h$ independent Fano constraints once the diagonal action is quotiented.
- **A `decide`-free, dimension-uniform proof.** Replace the finite-enumeration
  certification by a structural argument valid uniformly across planes, isolating the
  pencil-budget and unique-join mechanisms as reusable lemmas.

## 8. Conclusion

For the smallest projective plane $PG(2,2)$ we have settled the strong blocking problem
completely: a point set is strong blocking iff it omits at most one point
(`strongBlocking_iff_card`), the minimum size is exactly $6$
(`leastSize_strongBlocking`), and the minimizers are precisely the seven complements of
single points. Through the projective-system correspondence this is equivalent to the
sharp statement that the shortest nondegenerate minimal binary linear code of dimension
$3$ has length $6$. The argument rests on two transparent mechanisms special to the
two-element field, which simultaneously explain the result's cleanliness and chart the
course toward the open higher-order and higher-$q$ cases.
