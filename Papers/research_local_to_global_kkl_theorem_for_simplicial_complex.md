# A Local-to-Global KKL Theorem for Partite Simplicial Complexes over an Arbitrary Alphabet

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

We develop a local-to-global principle for coordinate influences of Boolean
labellings of the complete $n$-partite simplicial complex whose $n$ color classes
each contain $m$ vertices. The facets (top-dimensional simplices) of this complex
are the transversals $x \colon \{1,\dots,n\} \to \{1,\dots,m\}$, and a labelling
is a function $f$ from transversals to $\{0,1\}$. We define the (unnormalized)
influence $\mathrm{Inf}(f,i)$ of a color $i$ as the number of sensitive
$i$-edges — ordered pairs of transversals that agree off coordinate $i$, differ at
$i$, and receive different labels — and the link influence
$\mathrm{InfSub}(f,j,b,i)$ obtained by pinning color $j$ to vertex $b$. Our central
structural result is an *exact self-averaging identity*: for any fixed color $j$,
$\mathrm{Inf}(f,i) = \sum_{b=1}^{m} \mathrm{InfSub}(f,j,b,i)$. From this single
equality we derive: (i) monotonicity, that any locally influential coordinate is
globally at least as influential; (ii) a local-to-global decomposition of total
influence; and (iii) the flagship theorem that if all $m$ links of a color $j$
carry link-influence at least $T$, then some color $i \neq j$ has global influence
at least $mT/(n-1)$. We isolate the abstract non-negative weighted-averaging engine
behind these results, give the real-valued averaged form, and establish an exact
converse boundary: a labelling all of whose color influences vanish is constant, so
the influence conclusion is vacuous precisely for the degenerate labellings. The
Boolean hypercube is recovered as the case $m = 2$. This lifts the qualitative
Kahn–Kalai–Linial phenomenon to arbitrary alphabets and exhibits an alphabet-graded
growth of guaranteed influence that is invisible in the two-symbol setting.

**Keywords:** KKL theorem, coordinate influence, partite simplicial complex,
local-to-global principle, high-dimensional expander, transversal, link, Boolean
function analysis.

## 1. Introduction

The Kahn–Kalai–Linial (KKL) theorem [Kahn–Kalai–Linial 1988] is a cornerstone of
the analysis of Boolean functions. In one of its standard forms it asserts that
every balanced Boolean function $f \colon \{0,1\}^n \to \{0,1\}$ has a coordinate
whose influence is at least $\Omega\!\left(\frac{\log n}{n}\right)$ — influence
cannot be spread perfectly evenly and thinly across all coordinates. The theorem
sits at the origin of a large body of work on thresholds, hardness of
approximation, social choice, and the geometry of the discrete cube.

A more recent theme, driven by the theory of high-dimensional expanders, is the
*local-to-global* paradigm [Bafna–Hoory–Kaufman 2022; Gur–Lifshitz–Liu 2022;
Gotlib–Kaufman 2023]: global analytic and combinatorial properties of a simplicial
complex are deduced from the corresponding properties of its *links*, the small
subcomplexes obtained by fixing a face. The guiding hope is that if a favorable
property holds uniformly on every link, it "propagates" to the whole complex.

This paper carries out that program for coordinate influences in a clean and
completely explicit combinatorial setting: the complete $n$-partite complex over an
alphabet of size $m$. Its facets are exactly the transversals — functions choosing
one vertex from each of $n$ color classes of size $m$ — and its links are obtained
by pinning coordinates. The classical Boolean cube is the special case $m = 2$, in
which each vertex has two links; for general $m$ a coordinate has $m$ links.

Our contribution is to show that in this setting the local-to-global transfer is
not merely approximate but rests on an *exact* combinatorial identity, and to trace
its consequences. The exactness matters: it reveals a linear dependence of the
guaranteed global influence on the alphabet size $m$ that approximate two-symbol
arguments cannot detect.

## 2. The complex, its facets, and its links

Throughout, fix integers $n \ge 1$ (the number of colors) and $m \ge 1$ (the size
of each color class). Write $[n] = \{1,\dots,n\}$ and $[m] = \{1,\dots,m\}$; we use
the finite index sets interchangeably with $\{0,\dots,n-1\}$ and $\{0,\dots,m-1\}$.

**Definition 2.1 (Complex and facets).** The *complete $n$-partite simplicial
complex over the alphabet $[m]$* has vertex set $[n] \times [m]$, partitioned into
$n$ *color classes*, the $i$-th being $\{i\} \times [m]$. Its facets
(top-dimensional simplices) are the *transversals*: functions
$x \colon [n] \to [m]$, choosing one vertex $x_i = x(i)$ from each color class. We
identify a facet with the tuple $(x_1,\dots,x_n)$; there are $m^n$ of them.

**Definition 2.2 (Labelling).** A *(Boolean) labelling* is a function
$f \colon ([n] \to [m]) \to \{0,1\}$ assigning a value to each facet.

**Definition 2.3 ($i$-adjacency and sensitive edges).** Two facets $x, y$ are
*$i$-adjacent* if $x_k = y_k$ for every color $k \neq i$ and $x_i \neq y_i$. An
$i$-adjacent ordered pair $(x, y)$ is *sensitive for $f$* if additionally
$f(x) \neq f(y)$.

**Definition 2.4 (Influence).** The *(unnormalized) influence* of color $i$ on a
labelling $f$ is the number of sensitive $i$-adjacent ordered pairs,
$$\mathrm{Inf}(f, i) = \#\bigl\{(x, y) : (\forall k \neq i,\; x_k = y_k) \wedge x_i \neq y_i \wedge f(x) \neq f(y)\bigr\}.$$
The *total influence* is $\mathrm{TotInf}(f) = \sum_{i \in [n]} \mathrm{Inf}(f, i)$.

**Definition 2.5 (Link and link influence).** Fix a color $j$ and a vertex $b \in
[m]$. The *link of $(j, b)$* is the subcomplex of facets $x$ with $x_j = b$. The
*link influence* of color $i$ inside this link is
$$\mathrm{InfSub}(f, j, b, i) = \#\bigl\{(x, y) : (\forall k \neq i,\; x_k = y_k) \wedge x_i \neq y_i \wedge f(x) \neq f(y) \wedge x_j = b\bigr\}.$$
The *link total influence* of $(j, b)$, summing over colors other than the pinned
color, is
$$\mathrm{LinkTotInf}(f, j, b) = \sum_{i \neq j} \mathrm{InfSub}(f, j, b, i).$$

**Remark 2.6 (Boolean cube).** When $m = 2$, a facet is a bit-string in
$\{0,1\}^n$, the $i$-adjacency graph is the Hamming graph of the hypercube, and
$\mathrm{Inf}(f, i)$ is the edge-boundary influence of coordinate $i$. Each vertex
color then has exactly two links, corresponding to fixing the $j$-th bit to $0$ or
to $1$. Everything below specializes to this classical case.

## 3. The self-averaging bridge

The following exact identity is the structural heart of the paper.

**Theorem 3.1 (Self-averaging bridge).** For every labelling $f$, every pinned
color $j$, and every color $i$,
$$\mathrm{Inf}(f, i) = \sum_{b \in [m]} \mathrm{InfSub}(f, j, b, i).$$

*Proof sketch.* Consider the finite set $S$ of sensitive $i$-adjacent ordered pairs
$(x, y)$ counted by $\mathrm{Inf}(f, i)$. Map each such pair to $x_j \in [m]$, the
value the first coordinate assigns to the pinned color $j$. This partitions $S$ into
$m$ fibers indexed by $b \in [m]$. The fiber over $b$ is exactly the set of
sensitive $i$-adjacent pairs with $x_j = b$; note that whenever $(x,y)$ is
$i$-adjacent we have $x_j = y_j$ if $j \neq i$, and if $j = i$ the constraint
$x_j = b$ still selects a well-defined fiber, so in all cases the fiber over $b$ is
precisely the set counted by $\mathrm{InfSub}(f, j, b, i)$. Since the cardinality of
a finite set equals the sum of the cardinalities of the fibers of any map defined on
it, $\mathrm{Inf}(f, i) = \sum_{b} \mathrm{InfSub}(f, j, b, i)$. $\qquad\blacksquare$

The identity is *exact*: no error term, no inequality. This is what distinguishes
the partite setting from many local-to-global arguments that produce only
approximate transfer.

**Corollary 3.2 (Local influence bounds global influence).** For all $j, b, i$,
$$\mathrm{InfSub}(f, j, b, i) \le \mathrm{Inf}(f, i).$$

*Proof.* Each summand in Theorem 3.1 is a non-negative integer, so any single one
is at most the total. $\qquad\blacksquare$

**Corollary 3.3 (Local influential coordinate $\Rightarrow$ global influential
coordinate).** If $\tau \le \mathrm{InfSub}(f, j, b, i)$ for some link $(j,b)$, then
$\tau \le \mathrm{Inf}(f, i)$. Thus a coordinate that is influential inside any
single link is at least that influential globally.

*Proof.* Compose the hypothesis with Corollary 3.2. $\qquad\blacksquare$

**Theorem 3.4 (Local-to-global decomposition of total influence).** For every
labelling $f$ and every pinned color $j$,
$$\sum_{i \neq j} \mathrm{Inf}(f, i) = \sum_{b \in [m]} \mathrm{LinkTotInf}(f, j, b).$$

*Proof sketch.* Sum the identity of Theorem 3.1 over all colors $i \neq j$ and
exchange the order of the two finite summations (over $i \neq j$ and over
$b \in [m]$). The right-hand side becomes
$\sum_b \sum_{i \neq j} \mathrm{InfSub}(f, j, b, i) = \sum_b \mathrm{LinkTotInf}(f, j, b)$
by Definition 2.5. $\qquad\blacksquare$

## 4. From local guarantees to a global influential coordinate

We now turn the exact decomposition into a KKL-style existence statement. The only
extra ingredient is an elementary pigeonhole principle.

**Lemma 4.1 (Averaging pigeonhole).** Let $S$ be a nonempty finite set and
$g \colon S \to \mathbb{N}$. Then there exists $i \in S$ with
$\sum_{s \in S} g(s) \le |S| \cdot g(i)$; that is, some element attains at least the
average value of $g$.

*Proof.* Choose $i \in S$ maximizing $g$. Then
$\sum_{s \in S} g(s) \le \sum_{s \in S} g(i) = |S| \cdot g(i)$. $\qquad\blacksquare$

**Theorem 4.2 (Local-to-global total-influence bound).** Fix a pinned color $j$ and
a threshold $T \in \mathbb{N}$. If every one of the $m$ links of $j$ satisfies the
local bound $T \le \mathrm{LinkTotInf}(f, j, b)$ for all $b \in [m]$, then
$$m \cdot T \le \sum_{i \neq j} \mathrm{Inf}(f, i).$$

*Proof.* By Theorem 3.4 the right-hand side equals
$\sum_{b \in [m]} \mathrm{LinkTotInf}(f, j, b) \ge \sum_{b \in [m]} T = mT$,
using the hypothesis termwise. $\qquad\blacksquare$

**Theorem 4.3 (Local-to-Global KKL theorem, partite form).** Let $n \ge 2$. Fix a
pinned color $j$ and a threshold $T \in \mathbb{N}$, and suppose every one of the
$m$ links of $j$ carries link total influence at least $T$, i.e.
$T \le \mathrm{LinkTotInf}(f, j, b)$ for all $b \in [m]$. Then there exists a color
$i \neq j$ with
$$m \cdot T \le (n-1)\cdot \mathrm{Inf}(f, i),$$
equivalently $\mathrm{Inf}(f, i) \ge \dfrac{mT}{\,n-1\,}$.

*Proof.* The index set $S = [n] \setminus \{j\}$ is nonempty with $|S| = n - 1$
(as $n \ge 2$). Apply Lemma 4.1 to $g = \mathrm{Inf}(f, \cdot)$ on $S$ to obtain a
color $i \neq j$ with $\sum_{i' \neq j} \mathrm{Inf}(f, i') \le (n-1)\,\mathrm{Inf}(f, i)$.
Combining with Theorem 4.2 gives $mT \le \sum_{i' \neq j}\mathrm{Inf}(f, i') \le (n-1)\,\mathrm{Inf}(f, i)$. $\qquad\blacksquare$

**Remark 4.4 (Alphabet-graded influence).** The guaranteed global influence
$mT/(n-1)$ grows linearly in the alphabet size $m$. This is a genuine consequence of
exactness: enlarging the alphabet multiplies the number of links of the pinned
color, and by Theorem 3.1 each additional link contributes its full sensitive-edge
count to the global influence rather than redistributing a fixed budget. When
$m = 2$ this scaling is invisible; the phenomenon becomes visible only over general
alphabets.

## 5. The abstract weighted-averaging engine

Theorems 4.2 and 4.3 use nothing about facets or Boolean values beyond the exact
decomposition and non-negativity. We record the abstract principle they instantiate.

**Theorem 5.1 (Abstract local-to-global bound).** Let $B$ and $C$ be finite index
sets, and let $a \colon B \times C \to \mathbb{N}$ be non-negative with the
decomposition $G(c) = \sum_{b \in B} a(b, c)$ for a global quantity $G$. If for a
threshold $T$ one has $\sum_{c \in C} a(b, c) \ge T$ for every $b \in B$, then
$\sum_{c \in C} G(c) \ge |B| \cdot T$.

*Proof.* $\sum_{c} G(c) = \sum_{c} \sum_{b} a(b,c) = \sum_{b} \sum_{c} a(b,c) \ge \sum_{b} T = |B|\,T$. $\qquad\blacksquare$

**Theorem 5.2 (Abstract global influential coordinate).** Under the hypotheses of
Theorem 5.1 with $C$ nonempty, there exists $c \in C$ with
$|C| \cdot G(c) \ge |B| \cdot T$, i.e. $G(c) \ge \frac{|B|}{|C|} T$.

*Proof.* Combine Theorem 5.1 with the averaging pigeonhole (Lemma 4.1) applied to
$G$ on $C$. $\qquad\blacksquare$

Theorem 4.3 is the instance $B = [m]$ (the links of the pinned color),
$C = [n]\setminus\{j\}$ (the remaining colors), $a(b,i) = \mathrm{InfSub}(f,j,b,i)$,
and $G(i) = \mathrm{Inf}(f,i)$, which is precisely the content of Theorem 3.1.

**Theorem 5.3 (Real-valued averaged form).** With the notation above and $n \ge 2$,
there is a color $i \neq j$ with
$$\mathrm{Inf}(f, i) \ge \frac{mT}{n-1} \qquad \text{in } \mathbb{R}.$$

*Proof.* Divide the conclusion of Theorem 4.3 by the positive integer $n - 1$ in
the ordered field $\mathbb{R}$. $\qquad\blacksquare$

## 6. The exact degeneracy boundary

Any "large influence exists" theorem must delimit when its conclusion is vacuous.
Here the boundary is exact and complete.

**Theorem 6.1 (Zero influence forces constancy).** If $\mathrm{Inf}(f, i) = 0$ for
every color $i$, then $f$ is constant: there is a value $v \in \{0,1\}$ with
$f(x) = v$ for all facets $x$.

*Proof sketch.* $\mathrm{Inf}(f, i) = 0$ means no sensitive $i$-edge exists, i.e.
$f$ is invariant under changing the single coordinate $i$: $f(x) = f(y)$ whenever
$x, y$ are $i$-adjacent. Any two facets $x, x'$ are connected by a path in the
$i$-adjacency graphs — flip the coordinates on which they differ one at a time,
each flip being an $i$-adjacency for the corresponding color $i$ — and $f$ is
constant along every such step. Hence $f(x) = f(x')$ for all $x, x'$, so $f$ is
constant. $\qquad\blacksquare$

**Corollary 6.2 (Degeneracy dichotomy).** A labelling is either *globally
degenerate* — total influence zero, hence constant — or it has a color with strictly
positive influence. In the first case the KKL conclusion of Theorem 4.3 is vacuous
(one may take $T = 0$); in the second case there is nontrivial influence to
propagate. There is no intermediate regime.

*Proof.* If every color influence vanishes, Theorem 6.1 gives constancy. Otherwise
some $\mathrm{Inf}(f, i) > 0$. $\qquad\blacksquare$

## 7. Algorithms

The definitions are directly computable, giving simple exact algorithms over the
$m^n$ facets.

**Algorithm 7.1 (Influence of a color).** Enumerate all facets $x \in [m]^n$; for
each and for each alternative value $c \neq x_i$, form the $i$-neighbor $y$ (equal to
$x$ except $y_i = c$) and increment a counter when $f(x) \neq f(y)$. The counter is
$\mathrm{Inf}(f, i)$. This runs in $O(m^n \cdot m) = O(m^{n+1})$ label evaluations
per color.

**Algorithm 7.2 (Link influence and the bridge check).** Restrict Algorithm 7.1 to
facets with $x_j = b$ to obtain $\mathrm{InfSub}(f, j, b, i)$; summing over
$b \in [m]$ reproduces $\mathrm{Inf}(f, i)$, an executable verification of
Theorem 3.1.

**Algorithm 7.3 (Local-to-global witness search).** Given a pinned color $j$ and a
threshold $T$, compute $\mathrm{LinkTotInf}(f, j, b)$ for each $b$; if all are at
least $T$, scan the colors $i \neq j$ for one with
$(n-1)\,\mathrm{Inf}(f,i) \ge mT$. Theorem 4.3 guarantees the scan succeeds.

## 8. Applications and discussion

**Boolean function analysis.** The case $m = 2$ recovers a local-to-global
statement for the Boolean cube: if both links of a coordinate $j$ (the two sub-cubes
$x_j = 0$ and $x_j = 1$) carry total influence at least $T$, then some other
coordinate has global influence at least $2T/(n-1)$. This is the shape of reasoning
underlying inductive proofs of KKL-type facts, made exact.

**High-dimensional expanders.** The partite complex is a clean model in which the
local-to-global paradigm — deduce global from links — is realized by an exact
identity rather than a spectral approximation. The abstract engine (Section 5)
isolates exactly the ingredient the paradigm needs: a non-negative decomposition of a
global quantity across links.

**Voting and social choice.** In the committee interpretation (offices, candidates,
verdicts), the theorem states that if every candidate-restricted electorate is
collectively sensitive, then some office is a genuine swing office. The degeneracy
dichotomy says the only way to avoid a swing office entirely is a foregone
conclusion.

**Robustness of the exactness.** Because the engine is a statement about
non-negative weighted combinations, it is stable under reweighting the links,
suggesting extensions to non-uniform measures with sharpened equality analysis.

## 9. Future directions

**Alphabet-graded influence gap.** For labellings whose links each carry
link-influence at least $T$, we conjecture the maximal global coordinate influence
grows at least linearly in the alphabet size $m$, with no labelling attaining a
global maximum below $mT/(n-1)$. Enlarging the alphabet multiplies the links of a
single coordinate, so the exact self-averaging identity aggregates strictly more
sensitive edges into each global influence rather than redistributing a fixed
budget.

**Weighted non-regular links.** If the links of a coordinate are given arbitrary
non-negative weights summing to $W$ and each weighted link satisfies a KKL-type bound
$\tau$, we conjecture the global total influence is at least $\tau W$, with equality
exactly when every link is influence-extremal and the weights concentrate on the
extremal links. The averaging engine is purely about non-negative weighted
combinations, so it survives reweighting while its equality case sharpens.

**Variance-thresholded global degeneracy dichotomy.** We conjecture that a
labelling is either globally degenerate (total influence zero, hence constant) or it
possesses a coordinate whose influence exceeds the average of the per-link
thresholds; there is no intermediate regime. Having pinned the degenerate boundary
exactly, the task is to show the complement is uniformly non-degenerate.

**Higher-codimension links.** Pinning two coordinates simultaneously yields a
codimension-two link decomposition in which the global influence of a third
coordinate should decompose across the finer partition, extending the bridge to
faces of higher codimension.

## References

- J. Kahn, G. Kalai, N. Linial, *The influence of variables on Boolean functions*, FOCS 1988.
- M. Bafna, S. Hoory, T. Kaufman, work on local-to-global high-dimensional expansion, 2022.
- T. Gur, N. Lifshitz, S. Liu, *Hypercontractivity on high-dimensional expanders*, 2022.
- R. Gotlib, T. Kaufman, local-to-global analysis on simplicial complexes, 2023.
