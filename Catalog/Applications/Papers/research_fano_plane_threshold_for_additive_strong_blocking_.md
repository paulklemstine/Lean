# The Fano-Plane Threshold for Strong Blocking Sets: Saturation of the $(k-1)(q+1)$ Bound in the $h=1$ Case

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Combinatorial geometry / coding theory (Novelty)

---

## Abstract

A *strong blocking set* (also called a *cutting blocking set*) of a finite projective
space $\mathrm{PG}(N, q)$ is a set of points that meets every hyperplane in a spanning
subset of that hyperplane. Strong blocking sets are exactly the geometric duals of
*minimal linear codes* under the projective-system correspondence, and the *additive*
variant over $\mathrm{GF}(q^h)$ specialises, in the $h=1$ case, to ordinary
$\mathrm{GF}(q)$-linear strong blocking sets. We give a complete and elementary analysis of
the smallest non-degenerate projective plane, the Fano plane $\mathrm{PG}(2,2)$. We prove
that a set of points is a strong blocking set of $\mathrm{PG}(2,2)$ if and only if it meets
every line in at least two points (a *double blocking set*), that the minimum size of such a
set is exactly $6$, that the extremal sets are precisely the seven point-complements
$\mathrm{univ}\setminus\{p\}$, and that this threshold realises with equality the general
strong-blocking-set lower bound $(k-1)(q+1)$ for the parameters $k=3$, $q=2$. Equivalently,
the shortest nondegenerate minimal binary linear code of dimension $3$ has length $6$. All
results are verified by exhaustive checking over the $2^7 = 128$ subsets of the point set,
and the lower bound additionally admits a clean conceptual proof from the projective-plane
incidence axiom. We discuss why the Fano plane *saturates* the general bound while larger
planes $\mathrm{PG}(2,q)$ ($q>2$) generically do not, and we outline a research program on
binary towers $\mathrm{PG}(N,2)$ and the additive $h>1$ lift.

---

## 1. Introduction

### 1.1 Motivation

Minimal linear codes are a class of error-correcting codes in which no nonzero codeword has
its support contained in the support of another nonzero codeword. They are foundational to
secret-sharing schemes (where the minimal codewords determine the minimal qualified sets of
shareholders) and admit particularly clean decoding structure. A central optimization
problem is: *for a fixed dimension $k$ and alphabet size $q$, what is the shortest possible
minimal code?*

Through the *projective-system correspondence*, this question becomes purely geometric.
Nondegenerate $[n,k]_q$ linear codes correspond to multisets of $n$ points in
$\mathrm{PG}(k-1,q)$ that span the space, the code is minimal precisely when the point set is
a *strong blocking set*, and the code length equals the number of points. Hence finding the
shortest minimal code is equivalent to finding the smallest strong blocking set.

A general lower bound, established by Alfarano–Borello–Neri and independently by
Davydov–Giulietti–Marcugini–Pambianco, states that every strong blocking set of
$\mathrm{PG}(k-1,q)$ has at least $(k-1)(q+1)$ points. Whether and when this bound is tight
is a delicate question. This paper resolves it completely in the smallest non-degenerate
planar case, $k=3$, $q=2$, the Fano plane, and exhibits it as the first witness of exact
saturation.

### 1.1.1 Why the planar case is special

In a projective space of dimension $N \ge 2$, hyperplanes are $(N-1)$-dimensional subspaces;
asking that a set $S$ meet each hyperplane in a *spanning* subset is, in general, a strong
requirement involving the affine-independence of the points of $S$ inside each hyperplane.
The planar case $N = 2$ is the one where this requirement collapses to a clean combinatorial
statement: a line is one-dimensional and is spanned by *any two* of its distinct points, so
"$S$ spans every line it meets non-trivially" becomes simply "$S$ contains at least two
points of every line." This is precisely the classical notion of a *double blocking set*,
and it is what makes the Fano plane fully analysable by elementary means while still being a
faithful instance of the general strong-blocking-set theory. The reduction is not an
approximation: it is an exact equivalence in dimension two, which is why the planar
threshold can be read directly against the universal bound $(k-1)(q+1)$.

### 1.2 Contributions

We prove the following, each statement corresponding to a machine-verified theorem.

1. **Line structure** (`fanoLine_card`): every line of the cyclic model of $\mathrm{PG}(2,2)$
   has exactly $3$ points.
2. **Incidence axiom** (`two_points_collinear`): any two distinct points lie on a common
   line.
3. **Upper bound** (`sb6_isStrongBlocking`): the $6$-point set $\mathrm{univ}\setminus\{0\}$
   is a strong blocking set.
4. **Lower bound** (`strongBlocking_card_ge_six`): every strong blocking set has at least $6$
   points.
5. **Exact threshold** (`fano_threshold_isLeast`): the minimum size of a strong blocking set
   of $\mathrm{PG}(2,2)$ is exactly $6$.
6. **Extremal structure** (`minimum_strongBlocking_iff`): a strong blocking set attains size
   $6$ if and only if it is the complement of a single point.
7. **Extremal count** (`minimum_strongBlocking_count`): there are exactly $7$ minimum strong
   blocking sets.
8. **Tightness** (`fano_threshold_eq_formula`): $6 = (k-1)(q+1)$ for $k=3$, $q=2$, so the
   Fano plane saturates the general bound.

---

## 2. Preliminaries and definitions

### 2.1 The Fano plane

The **Fano plane** is the projective plane $\mathrm{PG}(2,2)$ of order $2$. It has
$q^2+q+1 = 7$ points and $7$ lines; each line contains $q+1 = 3$ points, each point lies on
$3$ lines, any two distinct points determine a unique line, and any two distinct lines meet
in a unique point. It is the smallest non-degenerate projective plane.

### 2.2 The cyclic (Singer) model

We model the points of the Fano plane by the cyclic group $\mathbb{Z}/7\mathbb{Z}$, written
$\mathrm{ZMod}\,7$.

**Definition 2.1 (Lines).** The set $D = \{0,1,3\}$ is a *perfect difference set* modulo $7$:
the multiset of nonzero differences $\{\, d-d' : d,d'\in D,\ d\neq d'\,\}$ equals
$\{1,2,3,4,5,6\}$, each residue occurring exactly once. For each $i \in \mathbb{Z}/7\mathbb{Z}$
define the **$i$-th line** as the translate
$$
\ell_i \;=\; \{\, i,\; i+1,\; i+3 \,\} \pmod 7 .
$$
The seven lines are the seven translates $\ell_0,\dots,\ell_6$:
$$
\{0,1,3\},\ \{1,2,4\},\ \{2,3,5\},\ \{3,4,6\},\ \{4,5,0\},\ \{5,6,1\},\ \{6,0,2\}.
$$

Because $D$ is a perfect difference set, $(\mathbb{Z}/7\mathbb{Z}, \{\ell_i\})$ is a
projective plane of order $2$: every pair of points lies in exactly one line, and the
incidence axioms hold. This is the Singer cyclic representation.

**Worked verification of the difference-set property.** Listing the ordered nonzero
differences of $D = \{0,1,3\}$ modulo $7$:
$$
1-0=1,\quad 3-0=3,\quad 0-1=6,\quad 3-1=2,\quad 0-3=4,\quad 1-3=5.
$$
These are $\{1,2,3,4,5,6\}$, each nonzero residue appearing exactly once; $D$ is therefore a
*planar* (perfect) difference set with parameters $(v,k,\lambda)=(7,3,1)$. The single
occurrence of each difference ($\lambda=1$) is exactly the statement that two distinct points
determine a *unique* line, the dual face of which is that two distinct lines meet in a unique
point. The cyclic group acts regularly on both points and lines, exhibiting the full
$7$-fold rotational symmetry of the configuration.

### 2.3 Strong blocking sets in a plane

In a projective plane, every hyperplane is a line, i.e. a $1$-dimensional projective subspace,
which is spanned by any two of its distinct points. Therefore "the chosen points meet a line
in a spanning subset" reduces to "the chosen points include at least two points of that
line." This motivates the working definition.

**Definition 2.2 (Strong blocking set).** A finite set $S \subseteq \mathbb{Z}/7\mathbb{Z}$
of points is a **strong blocking set** of the Fano plane if it meets every line in at least
two points:
$$
\mathrm{IsStrongBlocking}(S) \quad :\Longleftrightarrow \quad
\forall\, i \in \mathbb{Z}/7\mathbb{Z},\ \ |\ell_i \cap S| \,\ge\, 2 .
$$
Equivalently, $S$ is a *double blocking set*: every line is hit at least twice.

### 2.4 The projective-system / minimal-code dictionary

Under the projective-system correspondence, a nondegenerate $[n,k]_q$ linear code corresponds
to a spanning multiset of $n$ points in $\mathrm{PG}(k-1,q)$; the code is **minimal** iff the
point set is a strong blocking set, and $n$ equals the number of points. For $q=2$, $k=3$ this
specialises to: minimal binary $[n,3]$ codes $\leftrightarrow$ strong blocking sets of the
Fano plane. The *additive* generalisation works over $\mathrm{GF}(q^h)$; the case $h=1$
treated here is exactly the $\mathrm{GF}(q)$-linear case.

---

## 3. Main results

### 3.1 Line cardinality

**Theorem 3.1 (`fanoLine_card`).** Every line has exactly three points:
for all $i$, $\ |\ell_i| = 3$.

*Proof sketch.* The three offsets $0,1,3$ are pairwise distinct modulo $7$, so the three
elements $i, i+1, i+3$ are distinct for every $i$. A finite exhaustive check over the seven
values of $i$ confirms $|\{i, i+1, i+3\}| = 3$ in each case. $\qquad\blacksquare$

### 3.2 Incidence axiom

**Theorem 3.2 (`two_points_collinear`).** For any two distinct points $a \neq b$ there is a
line $\ell_i$ with $a \in \ell_i$ and $b \in \ell_i$.

*Proof sketch.* Since $D=\{0,1,3\}$ is a perfect difference set, every nonzero residue $r$
can be written as a difference $d - d'$ with $d, d' \in D$. Given $a \neq b$, set
$r = b - a \neq 0$ and choose $d, d' \in D$ with $d - d' = r$. Taking $i = a - d'$ yields
$a = i + d' \in \ell_i$ and $b = a + r = i + d' + (d-d') = i + d \in \ell_i$. A finite
exhaustive check over all ordered pairs $(a,b)$ with $a \neq b$ confirms the claim. This is
the planar incidence axiom in the cyclic model. $\qquad\blacksquare$

### 3.3 Upper bound: six points suffice

**Definition 3.3.** Let $S_6 = \mathrm{univ} \setminus \{0\}$, the set of the six nonzero
points.

**Lemma 3.4 (`sb6_card`).** $|S_6| = 6$.

**Theorem 3.5 (`sb6_isStrongBlocking`).** $S_6$ is a strong blocking set:
$\mathrm{IsStrongBlocking}(S_6)$.

*Proof sketch.* Each line $\ell_i$ has three points (Theorem 3.1). Removing the single point
$0$ from the universe deletes at most one point from any given line, since $0$ lies on at most
one... in fact $0$ lies on exactly three lines, but on each such line it removes only the one
point $0$. Hence $|\ell_i \cap S_6| \ge 3 - 1 = 2$ for every $i$. A finite check over the
seven lines confirms $|\ell_i \cap S_6| \ge 2$ throughout. $\qquad\blacksquare$

### 3.4 Lower bound: five points never suffice

**Theorem 3.6 (`strongBlocking_card_ge_six`).** Every strong blocking set $S$ satisfies
$|S| \ge 6$.

*Conceptual proof.* Let $T = \mathrm{univ} \setminus S$ be the complement. The condition
$|\ell_i \cap S| \ge 2$ on a $3$-point line is equivalent to $|\ell_i \cap T| \le 1$: $S$
meeting a line in at least two of its three points means $T$ meets that line in at most one.
Thus the strong blocking condition says **$T$ contains at most one point of every line.**

Suppose for contradiction that $T$ contains two distinct points $a \neq b$. By the incidence
axiom (Theorem 3.2) there is a line $\ell_i$ containing both $a$ and $b$, so
$|\ell_i \cap T| \ge 2$, contradicting the previous paragraph. Therefore $T$ contains at most
one point, $|T| \le 1$, and consequently
$$
|S| \;=\; 7 - |T| \;\ge\; 7 - 1 \;=\; 6 .
$$
$\qquad\blacksquare$

The mechanised proof discharges this via exhaustive enumeration of all $2^7 = 128$ subsets,
but the conceptual argument above is the mathematical content and generalises in spirit to
the duality used for larger planes.

**Remark (the complement duality).** The pivot of the lower bound is the equivalence, valid
on any line of exactly three points,
$$
|\ell_i \cap S| \ge 2 \quad \Longleftrightarrow \quad |\ell_i \cap T| \le 1,
\qquad T = \mathrm{univ}\setminus S,
$$
which holds because $|\ell_i \cap S| + |\ell_i \cap T| = |\ell_i| = 3$. Thus "$S$ is a double
blocking set" is *exactly dual* to "$T$ is a set of points no two of which are collinear,"
i.e. $T$ is an arc-like independent set with at most one point per line. In the Fano plane,
where every pair of points is collinear, such a $T$ can have at most one element. For larger
planes $\mathrm{PG}(2,q)$ the same duality holds with the threshold $q-1$ in place of $1$ (a
line has $q+1$ points), and the gap between the minimum double blocking set and the bound
$2(q+1)$ is governed by how large a $(q-1)$-bounded set the complement may be. The Fano case
is the degenerate-but-exact endpoint $q=2$ of this family.

### 3.5 Exact threshold

**Theorem 3.7 (`fano_threshold_isLeast`).** The value $6$ is the least element of the set of
achievable strong-blocking-set sizes:
$$
6 = \min\{\, n \in \mathbb{N} : \exists S,\ \mathrm{IsStrongBlocking}(S) \wedge |S| = n \,\}.
$$

*Proof sketch.* Membership: $S_6$ witnesses $6$ in the set (Lemma 3.4, Theorem 3.5). Lower
bound: every member $n$ of the set has $n = |S| \ge 6$ by Theorem 3.6. Hence $6$ is the least
element. $\qquad\blacksquare$

### 3.6 Structure and count of extremal sets

**Theorem 3.8 (`minimum_strongBlocking_iff`).** A set $S$ satisfies
$\mathrm{IsStrongBlocking}(S) \wedge |S| = 6$ if and only if $S = \mathrm{univ}\setminus\{p\}$
for some point $p$.

*Proof sketch.* If $|S| = 6$ then $|T| = 1$, say $T = \{p\}$, giving
$S = \mathrm{univ}\setminus\{p\}$; the lower-bound argument shows any such complement of a
single point is indeed strong blocking (deleting one point removes at most one point per
line). Conversely each $\mathrm{univ}\setminus\{p\}$ has $6$ points and is strong blocking by
the same count. A finite exhaustive check confirms the equivalence over all subsets.
$\qquad\blacksquare$

**Theorem 3.9 (`minimum_strongBlocking_count`).** There are exactly $7$ strong blocking sets
of size $6$ — one complement-of-a-point for each of the $7$ points:
$$
\bigl|\{\, S : \mathrm{IsStrongBlocking}(S) \wedge |S| = 6 \,\}\bigr| = 7 .
$$

*Proof sketch.* Immediate from Theorem 3.8: the map $p \mapsto \mathrm{univ}\setminus\{p\}$ is
a bijection from the $7$ points onto the minimum strong blocking sets. Verified by direct
enumeration. $\qquad\blacksquare$

### 3.7 Saturation of the general bound

**Theorem 3.10 (`fano_threshold_eq_formula`).** With code dimension $k=3$ (so
$\mathrm{PG}(k-1,q) = \mathrm{PG}(2,q)$) and alphabet size $q=2$,
$$
(k-1)(q+1) \;=\; (3-1)(2+1) \;=\; 6 .
$$
Hence the Fano-plane threshold $6$ equals the general lower bound $(k-1)(q+1)$: the Fano plane
**saturates** the bound.

*Proof sketch.* Direct arithmetic. The significance is that combining this identity with
Theorem 3.7 shows the universal lower bound is attained with equality at the smallest plane.
$\qquad\blacksquare$

---

## 4. Algorithms

The results are finite and decidable. We describe the two algorithmic primitives used to
verify them, both running over the $128$ subsets of a $7$-element point set.

### 4.1 Strong-blocking verification

Given a subset $S$, check for each of the seven lines $\ell_i = \{i,i+1,i+3\}$ whether
$|\ell_i \cap S| \ge 2$. This is $O(7 \cdot 3)$ per subset.

### 4.2 Exhaustive threshold search

Enumerate all $2^7$ subsets, retain those that are strong blocking, and take the minimum
cardinality. The same enumeration, filtered by cardinality $= 6$, yields the extremal sets and
their count. Total cost $O(2^7 \cdot 7 \cdot 3)$, trivially feasible.

---

## 5. Applications

**Minimal binary codes.** By the projective-system correspondence, Theorem 3.7 states that the
shortest nondegenerate minimal binary linear code of dimension $3$ has length $6$. The seven
extremal strong blocking sets correspond to the optimal such codes, useful in secret sharing
where minimal codewords encode minimal qualified coalitions.

**Covering and guarding.** Double blocking sets model robust covering problems: choosing six of
the seven Fano points guarantees every line is straddled at two points, providing fault
tolerance (any single chosen point may fail and each line is still met).

**Benchmark for extremal theory.** The Fano plane is the canonical first example where the
$(k-1)(q+1)$ bound is provably tight, anchoring conjectures about when saturation occurs.

---

## 6. Discussion

The proof economy is notable: the lower bound rests entirely on the planar incidence axiom
"any two points are collinear" together with the complement reformulation "$S$ double-blocks
iff its complement meets every line at most once." These two dual observations force the
minimum to be exactly $6$, and pin the extremal sets to the complements of single points.

The saturation in Theorem 3.10 is the conceptual headline. For $\mathrm{PG}(2,q)$ with $q>2$
the minimum double blocking set generically *exceeds* the general bound $2(q+1)$ (often growing
like $3q$), so the equality at $q=2$ is exceptional. This positions the Fano plane as a unique
small-case extremal object rather than a representative of a uniform phenomenon across planes.

**On the role of mechanised verification.** Each headline cardinality ($3$ for line size, $6$
for the threshold, $7$ for the extremal count) is a finite statement, and the formal
development discharges them by exhaustive decision procedures over the $7$ lines and the
$2^7$ subsets. This is more than a convenience: it eliminates any gap between the informal
counting argument and the verified fact, and it certifies the *complete* extremal
classification (Theorem 3.8) rather than only the optimum value. The load-bearing conceptual
input, isolated cleanly, is the incidence axiom (Theorem 3.2) together with the tightness
identity (Theorem 3.10); everything else is bookkeeping that the decision procedure performs
exactly. This separation — a small conceptual core plus exhaustively-checked combinatorics —
is a template for attacking the larger-$q$ and higher-dimensional conjectures below, where the
conceptual core (the complement duality) is expected to persist while the finite checks grow.

**Interpretation in coding terms.** Restating the results through the projective-system
dictionary: minimal binary linear codes of dimension $3$ correspond to strong blocking sets of
the Fano plane; the shortest such code has length $6$; and up to the natural symmetry there is
essentially one optimal configuration, the seven point-complements forming a single orbit
under the cyclic (indeed the full collineation) group. The saturation identity
$6=(k-1)(q+1)$ then says the Griesmer-type minimal-code length bound is met with equality at
the smallest binary plane, making it a sharp benchmark for the construction of short minimal
codes used in secret-sharing.

---

## 7. Future work

The following directions, ordered roughly by ambition, were identified as testable conjectures.

**Conjecture 1 (planes over $\mathbb{F}_q$, small $q$).** For $\mathrm{PG}(2,q)$ with
$q \in \{3,4,5\}$, the minimum size of a strong (double) blocking set is strictly greater than
the general bound $2(q+1)$; test whether the minimum equals $3q$ for prime $q$, making the Fano
saturation $2(q+1)$ at $q=2$ exceptional. Verifiable by exhaustive search over a cyclic
difference-set model for each fixed $q$.

**Conjecture 2 (extremal-set count).** For $\mathrm{PG}(2,q)$, the number of minimum strong
blocking sets is a polynomial in $q$; for $q=2$ it is $7 = q^2+q+1$ (the point count).
Conjecture: the count is structured by $\mathrm{PGL}(3,q)$-orbit sizes and equals the point
count for $q=2$. Test by enumeration for $q=3$.

**Conjecture 3 (binary towers $\mathrm{PG}(N,2)$).** For $\mathrm{PG}(N,2)$ the minimum strong
blocking set has size exactly $N(q+1) = 3N$ (the bound $(k-1)(q+1)$ with $k=N+1$, $q=2$); i.e.
binary projective spaces always saturate. The $N=2$ case ($=6$) is proved here; test $N=3$
($\mathrm{PG}(3,2)$, $15$ points, predicted threshold $9$) over the $2^{15}$ subsets or via a
complement argument.

**Conjecture 4 (complement / independence reformulation).** In any $\mathrm{PG}(2,q)$, $S$ is a
strong blocking set iff its complement meets every line in $\le q-1$ points. Conjecture: the
maximum such complement has size $q^2+q+1-2(q+1) = q^2-q-1$ only when the bound is saturated,
and the gap $2(q+1) - \mathrm{minSB}$ measures non-saturation. Formalise the complement duality
as a general lemma (not just $q=2$).

**Conjecture 5 (additive $h>1$ lift).** The $h=1$ results are the linear shadow of additive
strong blocking sets over $\mathbb{F}_{q^h}$. Conjecture: for $h=2$, $q=2$ (additive codes over
$\mathbb{F}_4$), the minimum additive strong blocking set of the $\mathbb{F}_2$-linear Fano
configuration has threshold $<6$, exhibiting a strict additive-vs-linear separation. Build the
$\mathbb{F}_4$-additive incidence model and test by enumeration.

---

## 8. Conclusion

We have completely characterised strong blocking sets of the Fano plane $\mathrm{PG}(2,2)$:
they are exactly the double blocking sets, their minimum size is $6$, the extremal sets are the
seven point-complements, and $6 = (k-1)(q+1)$ exhibits the smallest projective plane as a tight
witness of the universal minimal-code lower bound. The argument is elementary yet conceptually
complete, and it opens a concrete program toward larger planes, binary towers, and the additive
lift.

---

## References (background, not required to follow the paper)

The general lower bound $(k-1)(q+1)$ for strong blocking sets / minimal codes is due to
Alfarano, Borello and Neri, and independently Davydov, Giulietti, Marcugini and Pambianco. The
cyclic (Singer) model of the Fano plane via the perfect difference set $\{0,1,3\} \pmod 7$ is
classical. All statements in this paper are self-contained and proved above.
