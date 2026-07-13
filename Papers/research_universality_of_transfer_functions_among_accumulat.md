# Universality of Transfer Functions Among the Accumulation Points of $k$-adic Level Sets

## Abstract

We study a countable family of subsets of the real line, the *level-$\ell$
base-$k$ sets*
$$
\Pi^k_\ell \;=\; \ell\cdot\mathbb{Z}[1/k] \;=\; \left\{\, \frac{\ell\,a}{k^m} : a\in\mathbb{Z},\ m\in\mathbb{N} \,\right\},
$$
and the family of *transfer functions* — translations $x\mapsto x+c$ by elements
$c\in\Pi^k_\ell$. We prove that for every base $k\ge 2$ and level $\ell\ge 1$ the
set $\Pi^k_\ell$ is a dense additive subgroup of $\mathbb{R}$ that is perfect:
every real number, and in particular every element of $\Pi^k_\ell$, is an
accumulation point of $\Pi^k_\ell$. Hence the accumulation points lying in
$\Pi^k_\ell$ are exactly its elements. The transfer functions form a monoid
under composition, preserve $\Pi^k_\ell$, and are continuous. Our main theorem
is a *universality* (transitivity) statement: for any $k\ge 3$, any
$1\le\ell<k$, and any two elements $\alpha,\beta\in\Pi^k_\ell$, there is a
transfer function $f$ with $f(\alpha)=\beta$. A companion *rigidity* theorem
shows this $f$ is unique — transfer functions agreeing at a single point are
identical — so the translation action is simply transitive on $\Pi^k_\ell$. We
give the full arguments, an algorithmic view of the constructions, numerical
illustrations, and a discussion of generalizations to arbitrary dense additive
groups and to combinatorial density sets.

**Keywords.** $k$-adic rationals; dense additive subgroup; perfect set;
accumulation point; translation action; simple transitivity; homogeneity;
self-similarity.

---

## 1. Introduction

A subset $S$ of a metric space is *perfect* if it is closed and every point of
$S$ is an accumulation point of $S$. A slightly weaker and often more useful
notion is *dense-in-itself*: every point of $S$ is an accumulation point of $S$
(no isolated points), without requiring closedness. Perfect and
dense-in-itself sets are central objects in analysis and topology: Cantor sets,
the rationals, and the reals themselves are all dense-in-itself, and their
homogeneity underlies much of their utility.

This paper isolates an elementary but instructive instance in which a *discrete*
looking, countable, measure-zero subset of $\mathbb{R}$ is nonetheless
dense-in-itself, and in which a very simple family of self-maps acts on it with
maximal reach. Concretely, we fix integers $k\ge 2$ (the *base*) and $\ell\ge 1$
(the *level*) and study
$$
\Pi^k_\ell \;=\; \ell\cdot\mathbb{Z}[1/k]
           \;=\; \left\{\, \frac{\ell\,a}{k^m} : a\in\mathbb{Z},\ m\in\mathbb{N} \,\right\} \subseteq \mathbb{R}.
$$
We call $\Pi^k_\ell$ the *level-$\ell$ base-$k$ set*. It is the image of the ring
of $k$-adic rationals $\mathbb{Z}[1/k]$ under multiplication by $\ell$.

We introduce **transfer functions**: the translations $x\mapsto x+c$ with
$c\in\Pi^k_\ell$. These are the natural symmetries of $\Pi^k_\ell$ inside its
own additive structure. Our results establish two complementary facts:

1. **Universality (transitivity).** Any element of $\Pi^k_\ell$ can be carried to
   any other by a transfer function.
2. **Rigidity (simple transitivity).** The transfer function achieving a given
   assignment is unique.

Together they say that $\Pi^k_\ell$ is a *homogeneous* set for its translation
symmetries: the group of transfer functions acts freely and transitively on it,
so all points are equivalent and the "connecting motion" between two points is
uniquely determined.

While the statements are elementary, they package a template that recurs widely:
a dense additive subgroup of a space with no isolated points is automatically
perfect, and its translations act simply transitively on it. The $k$-adic level
sets are the most concrete and computable representatives of this template, with
the additional feature of a scaling self-similarity $x\mapsto kx$.

### 1.1 Notation and conventions

Throughout, $k,\ell$ are natural numbers with $k\ge 2$ and $\ell\ge 1$ unless a
stronger hypothesis is stated; the main theorem uses the requested range
$k\ge 3$, $1\le\ell<k$. We write $\mathbb{Z}[1/k]=\{a/k^m: a\in\mathbb{Z},
m\in\mathbb{N}\}$. For $x\in\mathbb{R}$, $\lfloor x\rfloor$ is the greatest
integer not exceeding $x$. An *accumulation point* (or cluster point) of a set
$S$ is a point $x$ such that every neighbourhood of $x$ contains a point of
$S\setminus\{x\}$.

---

## 2. The level-$\ell$ base-$k$ set

### 2.1 Definition

**Definition 2.1 (Level set).** For $k,\ell\in\mathbb{N}$ define
$$
\Pi^k_\ell = \left\{ x\in\mathbb{R} : \exists\, a\in\mathbb{Z},\ m\in\mathbb{N},\ x = \frac{\ell\,a}{k^m} \right\}.
$$

The level $\ell$ is not a mere scaling artifact: for distinct $\ell$ the sets
$\Pi^k_\ell$ are genuinely different additive subgroups of $\mathbb{R}$. For
instance, with $k=3$, the value $1=\tfrac{3^m}{3^m}$ lies in $\Pi^3_1$, whereas
$\Pi^3_2 = 2\mathbb{Z}[1/3]$ consists of the numbers $2a/3^m$; the two families
of representable numbers are distinct. Retaining $\ell$ as an explicit index is
therefore meaningful.

### 2.2 Algebraic structure

**Lemma 2.2 ($0\in\Pi^k_\ell$).** $0\in\Pi^k_\ell$.

*Proof.* Take $a=0$, $m=0$: $\ell\cdot 0/k^0 = 0$. $\qquad\blacksquare$

**Lemma 2.3 (Closure under subtraction).** If $k\neq 0$ and $x,y\in\Pi^k_\ell$
then $x-y\in\Pi^k_\ell$.

*Proof.* Write $x=\ell a/k^m$ and $y=\ell b/k^n$ with $a,b\in\mathbb{Z}$,
$m,n\in\mathbb{N}$. Over the common denominator $k^{m+n}$,
$$
x-y = \frac{\ell a}{k^m} - \frac{\ell b}{k^n}
    = \frac{\ell\,(a\,k^n - b\,k^m)}{k^{m+n}},
$$
which is of the required form with integer numerator $a k^n - b k^m$ and
exponent $m+n$. $\qquad\blacksquare$

**Lemma 2.4 (Closure under addition).** If $k\neq 0$ and $x,y\in\Pi^k_\ell$ then
$x+y\in\Pi^k_\ell$.

*Proof.* As above, $x+y = \ell(a k^n + b k^m)/k^{m+n}$. $\qquad\blacksquare$

**Corollary 2.5.** $(\Pi^k_\ell,+)$ is an additive subgroup of $(\mathbb{R},+)$.

*Proof.* It contains $0$ (Lemma 2.2), is closed under addition (Lemma 2.4), and
closed under negation since $-y = 0 - y \in \Pi^k_\ell$ (Lemma 2.3). $\qquad\blacksquare$

**Lemma 2.6 (Scaling self-similarity).** If $x\in\Pi^k_\ell$ then
$kx\in\Pi^k_\ell$.

*Proof.* If $x=\ell a/k^m$ then $kx = \ell(ak)/k^m$, again of the required form.
$\qquad\blacksquare$

Lemma 2.6 records that $\Pi^k_\ell$ is invariant under the expanding map
$x\mapsto kx$; the set is self-similar under multiplication by the base. (It is
also invariant under $x\mapsto x/k$ only up to level, i.e. $\Pi^k_\ell/k
\subseteq \Pi^k_\ell$ as well, since dividing shifts the exponent $m\mapsto m+1$.)

### 2.3 Density

**Lemma 2.7 (Density).** If $k\ge 2$ and $\ell\ge 1$ then $\Pi^k_\ell$ is dense
in $\mathbb{R}$.

*Proof.* Fix $x\in\mathbb{R}$ and $\varepsilon>0$. Because $k\ge 2$ we have
$k^m\to\infty$, so there is $m\in\mathbb{N}$ with $\ell/k^m<\varepsilon$. Set
$$
p = \frac{\ell\,\lfloor x k^m/\ell\rfloor}{k^m} \in \Pi^k_\ell.
$$
Writing $t = xk^m/\ell$, the definition of the floor gives $t-1 < \lfloor
t\rfloor \le t$, hence $0 \le x - p = \frac{\ell}{k^m}(t-\lfloor t\rfloor) <
\frac{\ell}{k^m} < \varepsilon$. Thus every neighbourhood of $x$ meets
$\Pi^k_\ell$. $\qquad\blacksquare$

### 2.4 Perfectness

**Theorem 2.8 (Perfectness).** If $k\ge 2$ and $\ell\ge 1$ then every real
number is an accumulation point of $\Pi^k_\ell$. In particular every point of
$\Pi^k_\ell$ is an accumulation point of $\Pi^k_\ell$; equivalently, the
accumulation points that lie in $\Pi^k_\ell$ are exactly the elements of
$\Pi^k_\ell$.

*Proof.* Fix $x\in\mathbb{R}$. By density (Lemma 2.7), $x$ lies in the closure of
$\Pi^k_\ell$. Since $\Pi^k_\ell$ is dense, it is also dense after removing the
single point $x$: the set $\Pi^k_\ell\setminus\{x\}$ is still dense, because
deleting one point from a dense subset of a space with no isolated points leaves
a dense subset. Therefore $x$ is in the closure of $\Pi^k_\ell\setminus\{x\}$,
which is precisely the statement that $x$ is an accumulation point of
$\Pi^k_\ell$. Restricting to $x\in\Pi^k_\ell$ gives the "in particular" clause,
and the reverse inclusion is trivial since accumulation points in $\Pi^k_\ell$
are elements of $\Pi^k_\ell$. $\qquad\blacksquare$

Theorem 2.8 shows $\Pi^k_\ell$ is dense-in-itself; as a subgroup of $\mathbb{R}$
it has no isolated points anywhere. (Its topological closure is all of
$\mathbb{R}$, so $\Pi^k_\ell$ itself is not closed; it is a countable,
measure-zero, dense-in-itself set.)

---

## 3. Transfer functions

**Definition 3.1 (Transfer function).** A function $f:\mathbb{R}\to\mathbb{R}$ is
a *transfer function* for $\Pi^k_\ell$ if there exists $c\in\Pi^k_\ell$ with
$f(x)=x+c$ for all $x$.

**Lemma 3.2 (Invariance).** If $k\neq 0$ and $f$ is a transfer function for
$\Pi^k_\ell$, then $f$ maps $\Pi^k_\ell$ into itself: $f(\Pi^k_\ell)\subseteq
\Pi^k_\ell$.

*Proof.* Write $f(x)=x+c$ with $c\in\Pi^k_\ell$. For $x\in\Pi^k_\ell$, Lemma 2.4
gives $x+c\in\Pi^k_\ell$. $\qquad\blacksquare$

**Lemma 3.3 (Identity).** The identity $x\mapsto x$ is a transfer function
(take $c=0$, using Lemma 2.2).

**Lemma 3.4 (Composition).** If $k\neq 0$ and $f,g$ are transfer functions for
$\Pi^k_\ell$, then so is $f\circ g$.

*Proof.* If $f(x)=x+c$ and $g(x)=x+d$ with $c,d\in\Pi^k_\ell$, then
$(f\circ g)(x)=x+(d+c)$, and $d+c\in\Pi^k_\ell$ by Lemma 2.4. $\qquad\blacksquare$

**Corollary 3.5 (Monoid; group).** The transfer functions form a commutative
monoid under composition, with identity the map of Lemma 3.3. Since each
$x\mapsto x+c$ has inverse $x\mapsto x-c$ with $-c\in\Pi^k_\ell$, they form an
abelian group isomorphic to $(\Pi^k_\ell,+)$ via $c \mapsto (x\mapsto x+c)$.

**Lemma 3.6 (Continuity).** Every transfer function is continuous.

*Proof.* $x\mapsto x+c$ is the sum of the identity and a constant, both
continuous. $\qquad\blacksquare$

---

## 4. Main results

### 4.1 Universality

**Theorem 4.1 (Universality / transitivity).** Let $k\ge 3$ and
$1\le\ell<k$. For any two points $\alpha,\beta\in\Pi^k_\ell$:

1. both $\alpha$ and $\beta$ are accumulation points of $\Pi^k_\ell$;
2. there exists a transfer function $f$ for $\Pi^k_\ell$ with $f(\alpha)=\beta$;
3. this $f$ maps $\Pi^k_\ell$ into itself.

*Proof.* Since $k\ge 3\ge 2$ and $\ell\ge 1$, part (1) is Theorem 2.8 applied to
$\alpha$ and $\beta$. For (2), set $c=\beta-\alpha$. By Lemma 2.3 (closure under
subtraction), $c\in\Pi^k_\ell$, so $f(x)=x+c$ is a transfer function; and
$f(\alpha)=\alpha+(\beta-\alpha)=\beta$. Part (3) is Lemma 3.2. $\qquad\blacksquare$

**Remark 4.2 (On the hypotheses).** The analytic content — density, perfectness,
and closure — requires only $k\ge 2$ and $\ell\ge 1$. The strict bound $\ell<k$
is not used in the proof; it is retained solely to match the range in which the
problem was posed. Likewise $k\ge 3$ can be relaxed to $k\ge 2$ without changing
the conclusion.

### 4.2 Rigidity

**Theorem 4.3 (Simple transitivity / uniqueness).** If $f,g$ are transfer
functions for $\Pi^k_\ell$ and $f(x_0)=g(x_0)$ for some single point $x_0$, then
$f=g$. Consequently the transfer function carrying a given $\alpha$ to a given
$\beta$ is unique.

*Proof.* Write $f(x)=x+c$ and $g(x)=x+d$. From $f(x_0)=g(x_0)$ we get
$x_0+c=x_0+d$, so $c=d$ and hence $f=g$ identically. For the uniqueness clause,
any $f$ with $f(\alpha)=\beta$ has shift $c=\beta-\alpha$, which is forced.
$\qquad\blacksquare$

**Corollary 4.4 (Homogeneity).** The group of transfer functions acts freely and
transitively on $\Pi^k_\ell$. Equivalently, $\Pi^k_\ell$ is a principal
homogeneous space (torsor) for the abelian group $(\Pi^k_\ell,+)$: the unique
element carrying $\alpha$ to $\beta$ corresponds to $\beta-\alpha$.

*Proof.* Transitivity is Theorem 4.1(2); freeness (equivalently, uniqueness of
the moving element) is Theorem 4.3. The correspondence $\beta-\alpha$ realizes
the torsor structure. $\qquad\blacksquare$

---

## 5. Algorithmic view

The proofs are constructive and translate directly into algorithms.

**Algorithm A (Transfer between two points).** Given $\alpha,\beta\in\Pi^k_\ell$,
represented as pairs $(a,m)$ with value $\ell a/k^m$, output the shift
$c=\beta-\alpha$ as a normalized pair $(c\text{-num},c\text{-exp})$. Using
Lemma 2.3, place both over exponent $\max(m_\alpha,m_\beta)$ (or $m_\alpha+
m_\beta$) and subtract numerators; then reduce common factors of $k$. The
resulting transfer function is $x\mapsto x+ \ell\cdot c\text{-num}/k^{c\text{-exp}}$.

**Algorithm B (Dense approximation).** Given a real target $x$ and tolerance
$\varepsilon>0$, choose the least $m$ with $\ell/k^m<\varepsilon$, and return
$p=\ell\lfloor xk^m/\ell\rfloor/k^m$. By Lemma 2.7, $0\le x-p<\varepsilon$. This
witnesses density and, run at two distinct scales, exhibits accumulation:
distinct $m$ give distinct nearby members clustering at $x$.

**Algorithm C (Cluster witness).** Given $x\in\Pi^k_\ell$ and $n\in\mathbb{N}$,
output $n$ distinct members of $\Pi^k_\ell$ within $\ell/k^{m}$ of $x$ by taking
$x+\ell j/k^{m}$ for $j=1,\dots,n$ and $m$ large; all lie in $\Pi^k_\ell$ by
Lemma 2.4 and converge to $x$ as $m\to\infty$, certifying that $x$ is an
accumulation point.

Complexities are dominated by big-integer arithmetic: Algorithm A is
$O(M(D))$ for numerators of $D$ digits (with $M$ the multiplication cost);
Algorithm B is $O(\log_k(1/\varepsilon))$ scaling steps plus one floor.

---

## 6. Numerical illustrations

The accompanying computational examples (see the demonstration script)
implement exact rational arithmetic to:

- verify closure under addition, subtraction, and multiplication by $k$;
- construct, for randomly sampled $\alpha,\beta\in\Pi^k_\ell$, the unique
  transfer shift $c=\beta-\alpha$ and confirm $\alpha+c=\beta$ and
  $c\in\Pi^k_\ell$;
- exhibit, for a chosen point, sequences of set members converging to it,
  numerically certifying it as an accumulation point;
- confirm rigidity by checking that two transfer functions agreeing at one point
  agree everywhere sampled.

All checks use exact fractions, so the confirmations are exact rather than
floating-point approximate.

---

## 7. Discussion and related structure

**Homogeneity from density.** The results exhibit a general mechanism: a dense
additive subgroup $G$ of a metric group without isolated points is
dense-in-itself, and its translations act simply transitively on it. Nothing in
the arguments of Sections 2–4 uses more than (i) the group law, and (ii)
density. The $k$-adic level sets are the concrete, computable instances of this
mechanism, distinguished additionally by the scaling self-similarity of
Lemma 2.6.

**Measure and category.** Each $\Pi^k_\ell$ is countable, hence Lebesgue-null
and meagre, yet topologically large (dense) and dense-in-itself. This is a clean
separation of measure/category "size" from topological homogeneity.

**Torsor structure.** Corollary 4.4 identifies $\Pi^k_\ell$ with a principal
homogeneous space for its own additive group. Choosing a basepoint (e.g. $0$)
trivializes the torsor and recovers the group; without a basepoint, all points
are on equal footing, which is the precise meaning of universality here.

---

## 8. Future directions

1. **Richer transfer semigroup.** Since $\Pi^k_\ell$ is invariant under
   $x\mapsto kx$ (Lemma 2.6), one may enlarge the transfer family to affine maps
   $x\mapsto k^j x + c$ with $j\in\mathbb{Z}$, $c\in\Pi^k_\ell$, verify they
   preserve $\Pi^k_\ell$, and study the resulting solvable group and its orbits,
   including its action on non-members.

2. **Group isomorphism packaging.** Theorem 4.3 shows the translation action is
   simply transitive. This can be packaged formally as a group isomorphism
   between the composition group of transfer functions and $(\Pi^k_\ell,+)$
   (Corollary 3.5), making the torsor structure explicit.

3. **Topological invariants.** Characterize the closure, order type, and
   measure-zero structure of $\Pi^k_\ell$ in detail, and relate the
   $\ell$-indexed family by inclusions and index computations among the
   subgroups.

4. **Toward combinatorial density sets.** In extremal combinatorics, families of
   achievable hypergraph Turán densities form sets whose accumulation ("jump")
   structure is of central interest. A long-term goal is to model such density
   sets and their accumulation structure precisely, and to identify the
   density-preserving operations that play the role of transfer functions there.

5. **General perfect subgroups.** Abstract the argument: any dense additive
   subgroup $G$ of a metric group without isolated points is dense-in-itself, and
   its translations act simply transitively on $G$. This generalizes the present
   results beyond $\mathbb{Z}[1/k]$.

---

## 9. Conclusion

For every base $k\ge 2$ and level $\ell\ge 1$, the level set
$\Pi^k_\ell=\ell\cdot\mathbb{Z}[1/k]$ is a dense, dense-in-itself additive
subgroup of $\mathbb{R}$ whose accumulation points contained in the set are
precisely its own elements. The translations by set members — the transfer
functions — preserve the set, are continuous, and form a group isomorphic to
$(\Pi^k_\ell,+)$. This group acts simply transitively: any point can be moved to
any other (universality), and by a unique transfer function (rigidity). The
level set is thus a discrete, measure-zero, yet fully homogeneous space for its
natural symmetries — a compact prototype of how density alone can force complete
uniformity among the points of an arithmetic set.
