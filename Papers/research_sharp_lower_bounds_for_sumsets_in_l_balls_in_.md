# Sharp Lower Bounds for Sumsets in $L_1$ Balls in $\mathbb{Z}^d$

**Author:** Aristotle

**Date:** 2026-07-13

## Abstract

We study lower bounds for the cardinality of iterated sumsets
$A_1 + \cdots + A_n$ where each $A_j$ is a finite nonempty subset of the discrete
$L_1$ ball (cross-polytope) $B_d(m) = \{x \in \mathbb{Z}^d : \sum_i |x_i| \le m\}$.
We establish three interlocking lower bounds and one containment bound, and we
identify the sharp exponent that governs the extremal case. Our additive engine
is an iterated Cauchy–Davenport inequality valid in any torsion-free abelian
group: $\sum_j |A_j| + 1 \le |A_1 + \cdots + A_n| + n$. From it we derive the
multiplicative form $\prod_j |A_j| \le |A_1 + \cdots + A_n|^n$ and its
geometric-mean consequence $(\prod_j |A_j|)^{1/n} \le |A_1 + \cdots + A_n|$.
On the geometric side, the $L_1$ triangle inequality yields
$A_1 + \cdots + A_n \subseteq B_d(nm)$. We introduce the transcendental exponent
$p = n \log(m+1)/\log(nm+1)$, prove that $1 \le p \le n$, and prove the defining
identity $(m+1)^{n/p} = nm + 1$. We then show that in dimension one the extremal
configuration $A_j = \{0, 1, \ldots, m\}$ attains equality simultaneously in the
additive bound and in the geometric bound with exponent $p$, so that $p$ cannot be
replaced by any smaller value. These results form a bridge connecting additive
combinatorics, discrete convex geometry, and the analysis of a single sharp
transcendental constant.

## 1. Introduction

A recurring theme in additive combinatorics is that the sumset of two sets is
never much smaller than its constituents. The classical Cauchy–Davenport theorem
quantifies this for $\mathbb{Z}/p\mathbb{Z}$; in a torsion-free abelian group the
analogous statement $|A + B| \ge |A| + |B| - 1$ holds for nonempty finite sets,
with equality precisely for arithmetic progressions of a common difference.

This paper concerns a quantitative refinement in a geometric setting. Fix a
dimension $d \ge 1$ and a radius $m \ge 0$. The *discrete $L_1$ ball* (or lattice
cross-polytope) of radius $m$ is
$$B_d(m) = \Bigl\{x \in \mathbb{Z}^d : \sum_{i=1}^d |x_i| \le m\Bigr\}.$$
Given $n$ finite nonempty sets $A_1, \ldots, A_n \subseteq B_d(m)$, we ask how
small the iterated sumset
$$A_1 + \cdots + A_n = \{a_1 + \cdots + a_n : a_j \in A_j\}$$
can be, as a function of the cardinalities $|A_1|, \ldots, |A_n|$, the radius $m$,
and the number of summands $n$. The target, in the spirit of recent work on sharp
sumset inequalities, is a bound of the form
$$|A_1 + \cdots + A_n| \ge \bigl(|A_1| \cdots |A_n|\bigr)^{1/p}$$
for an exponent $p$ as small as possible. Smaller $p$ means a stronger
conclusion.

Our contributions are as follows.

1. An **iterated Cauchy–Davenport bound** in any torsion-free abelian group
   (Theorem 3.1), the additive engine of the paper.
2. A **multiplicative form** $\prod_j |A_j| \le |\text{sumset}|^n$ (Theorem 4.2)
   and its **geometric-mean corollary** (Theorem 5.2), which is the
   unconditional $p = n$ instance of the target.
3. A **containment bound** $A_1 + \cdots + A_n \subseteq B_d(nm)$ from the $L_1$
   triangle inequality (Theorem 6.4).
4. The **sharp exponent** $p = n\log(m+1)/\log(nm+1)$, with range $1 \le p \le n$
   (Theorems 7.2, 7.3) and defining identity $(m+1)^{n/p} = nm+1$ (Theorem 7.1).
5. An **extremal sharpness** result (Theorem 8.3): in dimension one, the interval
   configuration attains equality in both the additive and the sharp exponent
   bounds, so $p$ is optimal.
6. A **packaged bridge theorem** (Theorem 9.1) combining (1)–(3) for subsets of
   $B_d(m)$.

Throughout, $|S|$ denotes the cardinality of a finite set $S$, and for finite
sets $A, B$ in an abelian group, $A + B = \{a + b : a \in A, b \in B\}$.

## 2. Preliminaries and notation

We work with finite subsets of a fixed abelian group $G$. A group is
*torsion-free* if $kx = 0$ with $k \ge 1$ forces $x = 0$; equivalently, no nonzero
element has finite order. The lattice $\mathbb{Z}^d$ is torsion-free, as is any
free abelian group and any $\mathbb{Q}$-vector space.

For an index set $s$ (finite) and finite sets $A_i \subseteq G$ for $i \in s$, the
iterated sumset $\sum_{i \in s} A_i$ is defined by repeatedly forming pointwise
sums; associativity and commutativity of $G$ make this well defined and
independent of order.

**Lemma 2.1 (Nonemptiness of sumsets).** *If $s$ is nonempty and each $A_i$ is
nonempty for $i \in s$, then $\sum_{i \in s} A_i$ is nonempty.*

*Proof sketch.* Induct on $s$. For a singleton the claim is immediate. For the
inductive step, $A_a + \sum_{i \in s'} A_i$ is a pointwise sum of two nonempty
sets, hence nonempty. $\square$

## 3. The additive engine: iterated Cauchy–Davenport

The single-step bound in a torsion-free abelian group states that for nonempty
finite $A, B \subseteq G$,
$$|A + B| \ge |A| + |B| - 1. \tag{CD}$$
The intuition: order the elements of $A$ and $B$ compatibly with a group
embedding into an ordered group (possible in the torsion-free case). The sums
$a_1 + b_1 < a_1 + b_2 < \cdots < a_1 + b_{|B|} < a_2 + b_{|B|} < \cdots$ produce
$|A| + |B| - 1$ strictly increasing, hence distinct, values.

**Theorem 3.1 (Iterated Cauchy–Davenport).** *Let $G$ be a torsion-free abelian
group, $s$ a nonempty finite index set, and $A_i \subseteq G$ nonempty finite for
$i \in s$. Then*
$$\sum_{i \in s} |A_i| + 1 \;\le\; \Bigl|\sum_{i \in s} A_i\Bigr| + |s|,$$
*equivalently $\bigl|\sum_{i \in s} A_i\bigr| \ge \sum_{i \in s} |A_i| - (|s| - 1)$.*

*Proof sketch.* Induct on the finite set $s$. The base case $|s| = 1$ is the
identity $|A_a| + 1 = |A_a| + 1$. For the inductive step, write
$s = \{a\} \cup s'$ with $a \notin s'$ and let $S' = \sum_{i \in s'} A_i$, which is
nonempty by Lemma 2.1. Apply (CD) to $A_a$ and $S'$:
$$\Bigl|\sum_{i \in s} A_i\Bigr| = |A_a + S'| \ge |A_a| + |S'| - 1.$$
By the inductive hypothesis, $|S'| \ge \sum_{i \in s'} |A_i| - (|s'| - 1)$.
Combining and using $|s| = |s'| + 1$ and
$\sum_{i \in s} |A_i| = |A_a| + \sum_{i \in s'} |A_i|$ gives the claim after
elementary arithmetic. $\square$

This is the foundation on which everything else rests: it says an $n$-fold sumset
can lose at most $n - 1$ from the naive sum of cardinalities.

## 4. The multiplicative form

**Lemma 4.1 (Each factor embeds).** *Under the hypotheses of Theorem 3.1, for
every $j \in s$,*
$$|A_j| \le \Bigl|\sum_{i \in s} A_i\Bigr|.$$

*Proof sketch.* Split off the $j$-th summand:
$\sum_{i \in s} A_i = A_j + \sum_{i \in s \setminus \{j\}} A_i$. If the remaining
index set is empty this is $A_j$ itself. Otherwise the remaining sumset is
nonempty (Lemma 2.1), and adding a nonempty set can only enlarge cardinality,
because translating $A_j$ by any fixed element is injective. $\square$

**Theorem 4.2 (Multiplicative bound).** *Under the hypotheses of Theorem 3.1,*
$$\prod_{i \in s} |A_i| \;\le\; \Bigl|\sum_{i \in s} A_i\Bigr|^{\,|s|}.$$

*Proof sketch.* By Lemma 4.1 each factor $|A_i|$ is at most
$C := |\sum_{i \in s} A_i|$. Multiplying the $|s|$ inequalities termwise gives
$\prod_{i \in s} |A_i| \le \prod_{i \in s} C = C^{|s|}$. $\square$

## 5. The geometric-mean form

**Lemma 5.1 (Root monotonicity).** *For natural numbers $P, C$ and $n \ge 1$, if
$P \le C^n$ then $P^{1/n} \le C$ (real-valued roots).*

*Proof sketch.* Write $C = (C^n)^{1/n}$ using $\left(C^n\right)^{1/n} = C$ for
$C \ge 0$, then apply monotonicity of $t \mapsto t^{1/n}$ on $[0, \infty)$ to
$P \le C^n$. $\square$

**Theorem 5.2 (Geometric-mean bound; the $p = n$ case).** *Let $G$ be a
torsion-free abelian group, $s$ nonempty finite, and $A_i$ nonempty finite for
$i \in s$, with $n = |s|$. Then*
$$\Bigl(\prod_{i \in s} |A_i|\Bigr)^{1/n} \;\le\; \Bigl|\sum_{i \in s} A_i\Bigr|.$$

*Proof.* Combine Theorem 4.2 with Lemma 5.1, taking
$P = \prod_i |A_i|$, $C = |\sum_i A_i|$. $\square$

This is the target inequality with exponent $p = n$, valid for *arbitrary* finite
nonempty sets in any torsion-free abelian group — no confinement to a ball is
required. Sections 7–8 show that inside the $L_1$ ball the exponent can, in the
extremal case, be lowered all the way to $p = n\log(m+1)/\log(nm+1) \le n$.

## 5b. Worked examples

To make the bounds concrete, consider a few small instances.

**Example 5.3 (Two intervals on the line).** Let $A = \{0, 1, 2\}$ and
$B = \{0, 10, 20\}$ in $\mathbb{Z}$. Then $A + B$ has all nine sums distinct, so
$|A + B| = 9 = |A| \cdot |B|$, far above the Cauchy–Davenport floor
$|A| + |B| - 1 = 5$. By contrast, $A + A = \{0, 1, 2, 3, 4\}$ has
$|A + A| = 5 = |A| + |A| - 1$: the additive bound is tight exactly when the set
is an arithmetic progression, which foreshadows the extremal analysis of
Section 8.

**Example 5.4 (Confinement helps).** Take $n = 3$, $m = 5$, so the geometric-mean
exponent is $p = n = 3$ while the sharp exponent is
$p(3, 5) = 3\log 6 / \log 16 \approx 1.938$. For the extremal interval
$A_j = \{0, \ldots, 5\}$ we have $\prod_j |A_j| = 6^3 = 216$ and
$|\sum_j A_j| = 16$. The geometric-mean bound only asserts
$216^{1/3} = 6 \le 16$, which is far from tight; the sharp bound asserts
$216^{1/1.938} = 16 \le 16$, an equality. The gap between the exponents $3$ and
$1.938$ is precisely the quantitative gain from knowing the sets live inside the
ball.

**Example 5.5 (Planar sumset).** In $d = 2$, $m = 2$, the ball $B_2(2)$ has $13$
points. Taking $A = B = B_2(2)$ gives $A + B \subseteq B_2(4)$, which has $41$
points; direct enumeration shows $|A + B| = 41$, so the containment is exactly
saturated by the full ball. Meanwhile the multiplicative bound reads
$13^2 = 169 \le 41^2 = 1681$, comfortably satisfied.

## 6. Discrete geometry: $L_1$ balls in $\mathbb{Z}^d$

**Definition 6.1 ($L_1$ norm).** For $x \in \mathbb{Z}^d$, set
$\|x\|_1 = \sum_{i=1}^d |x_i|$.

**Lemma 6.2 (Triangle inequality).** *For $x, y \in \mathbb{Z}^d$,
$\|x + y\|_1 \le \|x\|_1 + \|y\|_1$.*

*Proof sketch.* Sum the coordinatewise inequalities
$|x_i + y_i| \le |x_i| + |y_i|$. $\square$

**Definition 6.3 ($L_1$ ball).**
$B_d(m) = \{x \in \mathbb{Z}^d : \|x\|_1 \le m\}$. A point lies in $B_d(m)$ iff
its $L_1$ norm is at most $m$; in particular each coordinate satisfies
$|x_i| \le m$, so $B_d(m)$ is finite.

**Theorem 6.4 (Containment / geometry bridge).** *If $A_1, \ldots, A_n \subseteq
B_d(m)$ (equivalently, for an index set $s$, each $A_i \subseteq B_d(m)$), then*
$$\sum_{i \in s} A_i \;\subseteq\; B_d(|s| \cdot m).$$

*Proof sketch.* Induct on $s$, using the additive step: if
$B \subseteq B_d(p)$ and $C \subseteq B_d(q)$ then $B + C \subseteq B_d(p + q)$,
which follows from Lemma 6.2 since any $b + c$ has
$\|b + c\|_1 \le \|b\|_1 + \|c\|_1 \le p + q$. The empty sumset is $\{0\} \subseteq
B_d(0)$. Accumulating radii over $|s|$ summands of radius $m$ gives radius
$|s| \cdot m$. $\square$

Combined with the lower bounds of Sections 3–5, this pens the sumset between an
explicit lower bound on its cardinality and an explicit geometric cage, which is
what makes a sharp analysis possible.

## 7. The sharp transcendental exponent

**Definition 7.1 (Sharp exponent).** For integers $n, m \ge 1$, define
$$p = p(n, m) = \frac{n \, \log(m+1)}{\log(nm + 1)}.$$

**Theorem 7.1 (Defining identity).** *For $n, m \ge 1$,*
$$(m+1)^{\,n/p} = nm + 1.$$

*Proof sketch.* Since $m \ge 1$, $\log(m+1) > 0$ and $\log(nm+1) > 0$, so
$$\frac{n}{p} = \frac{\log(nm+1)}{\log(m+1)}.$$
Then $(m+1)^{n/p} = \exp\!\bigl(\tfrac{n}{p}\log(m+1)\bigr)
= \exp\bigl(\log(nm+1)\bigr) = nm + 1$. $\square$

The significance: if $|A_j| = m+1$ for all $j$ and $|\sum_j A_j| = nm+1$ (the
extremal interval, Section 8), then
$(\prod_j |A_j|)^{1/p} = (m+1)^{n/p} = nm+1 = |\sum_j A_j|$, i.e. equality in the
target bound with exponent $p$.

**Theorem 7.2 (Upper range $p \le n$).** *For $n, m \ge 1$, $p(n,m) \le n$.*

*Proof sketch.* Equivalent to $\log(m+1) \le \log(nm+1)$, which holds since
$m + 1 \le nm + 1$ and $\log$ is increasing (and $\log(nm+1) > 0$). $\square$

Because $p \le n$, the sharp bound $(\prod|A_j|)^{1/p} \le |\text{sumset}|$ (when
it holds) is *at least as strong* as the geometric-mean bound with exponent $n$.

**Theorem 7.3 (Lower range $1 \le p$).** *For $n, m \ge 1$, $1 \le p(n,m)$.*

*Proof sketch.* Equivalent to $\log(nm+1) \le n\log(m+1) = \log((m+1)^n)$, i.e.
$nm + 1 \le (m+1)^n$. This follows from the Bernoulli-type inequality
$(1 + m)^n \ge 1 + nm$ for $m \ge 0$, $n \ge 1$. $\square$

Thus $1 \le p \le n$: the confinement to the ball can only help (drives $p$ below
$n$), but never past the trivial floor $p = 1$ forced by $|A_j| \le |\text{sumset}|$.

## 8. Extremal sharpness in dimension one

We now show that $p$ cannot be improved, by exhibiting a configuration that
attains equality. Work in $d = 1$, where $B_1(m) = \{-m, \ldots, m\}$.

**Lemma 8.1 (Sum of intervals).** *For integers $a \le b$ and $c \le d$,*
$$\{a, \ldots, b\} + \{c, \ldots, d\} = \{a + c, \ldots, b + d\}.$$

*Proof sketch.* The forward inclusion is immediate. For the reverse, given
$x$ with $a + c \le x \le b + d$, choose the first summand as
$\max(a, x - d)$, which lies in $\{a, \ldots, b\}$, and the second as the
remainder, which then lies in $\{c, \ldots, d\}$. $\square$

**Lemma 8.2 ($n$-fold interval).** *For $m \ge 0$ and $n \ge 0$,*
$$\underbrace{\{0, \ldots, m\} + \cdots + \{0, \ldots, m\}}_{n} = \{0, \ldots, nm\},$$
*with cardinality $nm + 1$.*

*Proof sketch.* Induct on $n$ using Lemma 8.1:
$\{0,\ldots,km\} + \{0,\ldots,m\} = \{0,\ldots,(k+1)m\}$. The cardinality of
$\{0, \ldots, N\}$ is $N + 1$. $\square$

**Theorem 8.3 (Extremal sharpness).** *Fix $n, m \ge 1$ and take
$A_1 = \cdots = A_n = \{0, 1, \ldots, m\} \subseteq B_1(m)$. Then:*

1. *(Additive equality)* $\sum_j |A_j| + 1 = |\sum_j A_j| + n$.
2. *(Sharp exponent equality)*
   $\bigl(\prod_j |A_j|\bigr)^{1/p} = |\sum_j A_j|$, with $p = p(n, m)$.

*Consequently, the exponent $p$ is optimal: no exponent smaller than $p$ satisfies
the bound $\bigl(\prod_j |A_j|\bigr)^{1/p} \le |\sum_j A_j|$ for all admissible
configurations.*

*Proof sketch.* Each $|A_j| = m + 1$, so $\sum_j |A_j| = n(m+1)$ and
$\prod_j |A_j| = (m+1)^n$. By Lemma 8.2, $\sum_j A_j = \{0, \ldots, nm\}$, so
$|\sum_j A_j| = nm + 1$.

For (1): $n(m+1) + 1 = nm + n + 1 = (nm + 1) + n$. Equality holds.

For (2): $\bigl((m+1)^n\bigr)^{1/p} = (m+1)^{n/p} = nm + 1$ by the defining
identity Theorem 7.1, and $nm + 1 = |\sum_j A_j|$. Equality holds.

Optimality: since equality is attained at exponent $p$, any exponent $p' < p$
would give $(\prod_j |A_j|)^{1/p'} = (m+1)^{n/p'} > (m+1)^{n/p} = nm + 1 =
|\sum_j A_j|$ (as $m + 1 > 1$ and $n/p' > n/p$), violating the bound. $\square$

## 9. The bridge theorem

We collect the lower bounds and the containment into a single statement for the
$L_1$-ball setting.

**Theorem 9.1 ($L_1$-ball sumset bridge).** *Let $d \ge 1$, $m \ge 0$, and let
$A_i \subseteq B_d(m)$ be nonempty finite sets for $i$ in a nonempty finite index
set $s$, with $n = |s|$. Then all of the following hold simultaneously:*

1. *(Additive)* $\displaystyle \sum_{i \in s} |A_i| + 1 \le \Bigl|\sum_{i \in s} A_i\Bigr| + n$;
2. *(Multiplicative)* $\displaystyle \prod_{i \in s} |A_i| \le \Bigl|\sum_{i \in s} A_i\Bigr|^{\,n}$;
3. *(Geometric mean)* $\displaystyle \Bigl(\prod_{i \in s} |A_i|\Bigr)^{1/n} \le \Bigl|\sum_{i \in s} A_i\Bigr|$;
4. *(Geometry)* $\displaystyle \sum_{i \in s} A_i \subseteq B_d(nm)$.

*Proof.* Items (1)–(3) are Theorems 3.1, 4.2, 5.2; item (4) is Theorem 6.4. All
apply since $\mathbb{Z}^d$ is torsion-free and each $A_i$ is nonempty and
contained in $B_d(m)$. $\square$

Together with Theorem 8.3, this is the connector: the additive and multiplicative
combinatorics, the discrete convex geometry of the cross-polytope, and the
transcendental exponent $p$ all meet in one place, with the extremal interval
certifying that $p$ is the sharp exponent in dimension one.

## 10. Applications and computational aspects

**Counting lattice points in the cross-polytope.** The cardinality of $B_d(m)$ is
$$|B_d(m)| = \sum_{k \ge 0} 2^k \binom{d}{k} \binom{m}{k},$$
the central Delannoy-type count of lattice points in the discrete cross-polytope
(choosing $k$ nonzero coordinates, their signs, and a composition of the budget).
These numbers control the "ambient room" available to the sets $A_j$ and enter any
$d$-dependent refinement of the exponent.

**Sparse recovery and coding.** The $L_1$ ball is the canonical sparsity model.
Lower bounds on confined sumsets translate into guarantees on how many distinct
superpositions a bounded-weight code can realize, and into packing/covering
estimates for lattice codes.

**Algorithmic verification.** For fixed small $n, m, d$ the bounds and the
extremal equalities are directly checkable by enumeration: build $B_d(m)$, form
sumsets, and compare cardinalities against $\sum_j |A_j| - (n-1)$,
$(\prod_j |A_j|)^{1/n}$, and $(\prod_j |A_j|)^{1/p}$. The accompanying numerical
suite performs exactly these checks and confirms the extremal interval saturates
the sharp exponent.

## 11. Discussion and future work

The results here settle the unconditional $p = n$ form of the sumset lower bound
in torsion-free groups and pin down the sharp exponent
$p = n\log(m+1)/\log(nm+1)$ via the one-dimensional extremal interval. The gap
that remains is to prove the sharp bound $|A_1 + \cdots + A_n| \ge
(\prod_j |A_j|)^{1/p}$ with this optimal $p$ for *arbitrary* subsets of $B_d(m)$
in *every* dimension. The following directions are natural.

1. **The full sharp inequality.** Prove
   $|A_1 + \cdots + A_n| \ge (\prod_j |A_j|)^{1/p}$ with the sharp $p \le n$ for
   arbitrary subsets of $B_d(m)$ and all $d$. The $p = n$ version here is a first
   unconditional step; a promising route is a discrete Prékopa–Leindler /
   Brunn–Minkowski inequality on $\mathbb{Z}^d$, tensorizing the one-dimensional
   interval case where $p$ is exact.

2. **Compression / tensorization.** Formalize a downward compression reducing
   arbitrary $A_j \subseteq B_d(m)$ to down-sets, then to intervals, so that the
   exact one-dimensional computation transfers dimension by dimension, upgrading
   the geometric-mean bound from exponent $n$ to exponent $p$.

3. **Refined $d$-dependent exponent.** Investigate whether the volume ratio
   $p_d = n \log |B_d(m)| / \log |B_d(nm)|$ is the correct sharp exponent, using
   $|B_d(m)| = \sum_k 2^k \binom{d}{k}\binom{m}{k}$.

4. **Equality characterization.** Prove that equality in the iterated
   Cauchy–Davenport bound forces each $A_j$ to be an arithmetic progression with a
   common difference (Vosper/Freiman-type rigidity), generalizing the extremal
   interval.

5. **Beyond $\mathbb{Z}^d$.** The additive engine works in any torsion-free
   abelian group. Explore analogues in $\mathbb{R}^d$ (Lebesgue measure,
   Brunn–Minkowski) and in $(\mathbb{Z}/N\mathbb{Z})^d$, where genuine
   Cauchy–Davenport phenomena change the exponent.

## References

The single-step lower bound $|A + B| \ge |A| + |B| - 1$ in torsion-free abelian
groups is the classical Cauchy–Davenport phenomenon; the Bernoulli inequality
$(1+m)^n \ge 1 + nm$ underlies the range $1 \le p$. The sharp-exponent framing
follows the line of recent work on sumset inequalities in cross-polytopes.
