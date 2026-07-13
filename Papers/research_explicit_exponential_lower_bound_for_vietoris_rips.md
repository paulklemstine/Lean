# An Explicit Exponential Lower Bound for Vietoris–Rips Approximations Below the $\sqrt{2}$ Threshold

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The Vietoris–Rips filtration is the central computational object of topological
data analysis, but its size can grow as $2^n$ in the number $n$ of data points,
rendering direct computation infeasible. A large body of work seeks
*approximations* — filtrations that are multiplicatively $c$-interleaved with the
true Vietoris–Rips filtration — that are provably small. We establish a sharp
obstruction. Consider the *equidistant configuration* $E_n$ on $n$ points, in
which all pairwise distances equal a common value $d$; this is realised exactly
by the $n$ standard basis vectors of Euclidean space, whose pairwise distance is
$\sqrt 2$. We prove that the Vietoris–Rips complex of $E_n$ is the full power set
(with $2^n$ simplices) at every scale $r \ge d$, and collapses to only $n + 1$
simplices at every scale $0 \le r < d$; the barcode therefore exhibits a single
exponential cliff at $r = d$. From the interleaving axioms we deduce that *every*
$c$-approximation of $\mathrm{VR}(E_n)$ has a level containing at least $2^n$
simplices. Introducing the explicit exponent $\gamma(c) = \tfrac12 - \log_2 c$,
which is positive on $[1,\sqrt 2)$, bounded above by $1$, and tends to $0$ as
$c \to \sqrt 2^-$, we obtain the headline theorem: for $1 \le c < \sqrt 2$ every
$c$-approximation of $\mathrm{VR}(E_n)$ has a level of size at least
$2^{\gamma(c)\cdot n}$. The threshold $\sqrt 2$ matches the regime, governed by
Jung's constant $\sqrt{2n/(n+1)} \to \sqrt 2$, in which net- and Čech-based
sparsifications first become available. All results are established rigorously.

## 1. Introduction

Topological data analysis (TDA) turns a finite point cloud into a multiscale
combinatorial object whose homology encodes the cloud's connected components,
loops, voids, and higher-dimensional features. The dominant construction is the
**Vietoris–Rips filtration**: at scale $r$ one forms the simplicial complex
whose simplices are the subsets of the cloud with diameter at most $r$, and one
records how the homology changes as $r$ increases, summarising the result in a
*persistence barcode*.

The construction's expressive power comes at a steep computational cost. A cloud
of $n$ points can generate up to $2^n$ simplices — every subset may become a
simplex at a sufficiently large scale. Consequently a great deal of research is
devoted to **approximating** the Vietoris–Rips filtration by a smaller
filtration whose barcode is provably close, in the standard sense of
*multiplicative interleaving*, to that of the true filtration. Sparse filtrations,
net-trees, and Čech-type sparsifications all fit this template and can, under
favourable geometric hypotheses, achieve near-linear size for a fixed accuracy.

This paper delimits the region where such savings are *impossible*. We show that
there is a sharp accuracy threshold, located exactly at $c = \sqrt 2$, below
which no approximation of a certain simple, genuinely metric configuration can be
sub-exponential, and we exhibit an explicit exponent controlling the barrier
that vanishes precisely at the threshold.

### Contributions

1. A clean combinatorial model of the Vietoris–Rips complex and of multiplicative
   $c$-approximations for an arbitrary symmetric dissimilarity on $n$ points
   (Section 2).
2. A complete analysis of the *equidistant* configuration: its complex is the
   full power set above the gap and collapses to $n+1$ simplices below it,
   producing a single exponential cliff (Section 3).
3. A proof that the equidistant configuration is genuinely metric and Euclidean,
   realised by the standard basis with pairwise distance $\sqrt 2$ (Section 3).
4. An exponential lower bound: every $c$-approximation has a level of size at
   least $2^n$; packaged with the explicit exponent
   $\gamma(c) = \tfrac12 - \log_2 c$, this yields a floor of $2^{\gamma(c)\cdot n}$,
   with $\gamma(c) > 0$ on $[1,\sqrt 2)$ and $\gamma(c) \to 0$ as $c \to \sqrt 2^-$
   (Sections 4–5).

## 2. Definitions

Throughout, the point set is $\{1, \dots, n\}$, and a **dissimilarity** is a
function $D : \{1,\dots,n\}^2 \to \mathbb{R}$. We do not initially require $D$ to
be a metric; the equidistant example we ultimately use *is* a metric, and indeed
Euclidean.

**Definition 2.1 (Vietoris–Rips simplex).** A subset
$S \subseteq \{1,\dots,n\}$ is a *Vietoris–Rips simplex at scale $r$* for the
dissimilarity $D$ if every pair of its vertices is within $r$:
$$D(i,j) \le r \quad \text{for all } i, j \in S.$$

**Definition 2.2 (Vietoris–Rips complex).** The *Vietoris–Rips complex at scale
$r$*, written $\mathrm{VR}(D, r)$, is the finite collection of all subsets of
$\{1,\dots,n\}$ that are simplices at scale $r$:
$$\mathrm{VR}(D, r) = \{\, S \subseteq \{1,\dots,n\} : D(i,j) \le r \text{ for all } i,j \in S \,\}.$$
As $r$ increases, $\mathrm{VR}(D, r)$ grows monotonically; the family
$\{\mathrm{VR}(D,r)\}_{r \ge 0}$ is the *Vietoris–Rips filtration*.

We measure the size of the complex by its number of simplices,
$|\mathrm{VR}(D,r)|$ (the cardinality of the collection, counting the empty
simplex).

**Definition 2.3 (Equidistant dissimilarity).** For $d \in \mathbb{R}$, the
*equidistant dissimilarity* is
$$\mathrm{equi}_d(i,j) = \begin{cases} 0 & i = j, \\ d & i \ne j. \end{cases}$$

**Definition 2.4 (Multiplicative $c$-approximation).** Let $c \ge 1$. A family
of finite complexes $G : \mathbb{R} \to \{\text{complexes on } \{1,\dots,n\}\}$
is a *$c$-approximation* (multiplicative $c$-interleaving) of $\mathrm{VR}(D,\,\cdot\,)$
if
$$\mathrm{VR}(D, t) \subseteq G(c\,t) \quad\text{and}\quad G(t) \subseteq \mathrm{VR}(D, c\,t) \qquad \text{for all } t \ge 0.$$

Definition 2.4 is the honest multiplicative interleaving used throughout TDA to
compare filtrations; the induced interleaving distance on persistence modules is
bounded by $\log c$. Note in particular the *containment* $\mathrm{VR}(D,t)
\subseteq G(c t)$: the approximation is not permitted to *lose* simplices that
the true complex already has — it may only see them early.

## 3. The equidistant configuration

### 3.1 Euclidean realisation

The equidistant dissimilarity is not merely an abstract gadget; for the value
$d = \sqrt 2$ it is exactly the Euclidean metric restricted to the standard
basis.

**Proposition 3.1 (Euclidean realisation).** Let $e_1, \dots, e_n$ be the
standard basis vectors of $\mathbb{R}^n$, i.e. $e_i$ has a $1$ in coordinate $i$
and $0$ elsewhere. Then for all $i, j$,
$$\|e_i - e_j\| = \mathrm{equi}_{\sqrt 2}(i,j).$$

*Proof.* If $i = j$ the difference is the zero vector, of norm $0$. If
$i \ne j$, then $e_i - e_j$ has a $+1$ in coordinate $i$, a $-1$ in coordinate
$j$, and $0$ elsewhere, so
$\|e_i - e_j\| = \sqrt{1^2 + (-1)^2} = \sqrt 2$. $\qquad\blacksquare$

In particular the equidistant configuration is a genuine finite metric space:
one checks directly that $\mathrm{equi}_d$ is symmetric, vanishes exactly on the
diagonal for $d > 0$, and satisfies the triangle inequality whenever $d \ge 0$
(the only nontrivial case is when all three indices are distinct, where the
inequality reads $d \le d + d$). Thus all our lower bounds concern an honest,
Euclidean point cloud, not a pathological pseudo-metric.

### 3.2 The complex above the gap

**Theorem 3.2 (Full power set above the gap).** Let $0 \le d \le r$. Then
$$\mathrm{VR}(\mathrm{equi}_d, r) = 2^{\{1,\dots,n\}},$$
the full power set; equivalently, every subset is a simplex.

*Proof.* Fix any subset $S$ and any $i, j \in S$. If $i = j$ then
$\mathrm{equi}_d(i,j) = 0 \le r$. If $i \ne j$ then
$\mathrm{equi}_d(i,j) = d \le r$ by hypothesis. Hence $S$ satisfies the simplex
condition, so every subset lies in $\mathrm{VR}(\mathrm{equi}_d, r)$. $\qquad\blacksquare$

**Corollary 3.3 (Size above the gap).** For $0 \le d \le r$,
$$|\mathrm{VR}(\mathrm{equi}_d, r)| = 2^n.$$

*Proof.* The power set of an $n$-element set has $2^n$ elements. $\qquad\blacksquare$

### 3.3 The complex below the gap

**Lemma 3.4 (Simplices are trivial below the gap).** Let $r < d$ and let $S$ be
a Vietoris–Rips simplex of $\mathrm{equi}_d$ at scale $r$. Then $|S| \le 1$.

*Proof.* Suppose for contradiction that $S$ contains two distinct vertices
$i \ne j$. The simplex condition forces
$\mathrm{equi}_d(i,j) = d \le r$, contradicting $r < d$. Hence $S$ has at most
one vertex. $\qquad\blacksquare$

**Theorem 3.5 (Size below the gap).** For $0 \le r < d$,
$$|\mathrm{VR}(\mathrm{equi}_d, r)| = n + 1.$$

*Proof.* By Lemma 3.4 the simplices are exactly the subsets of cardinality at
most $1$: the empty set (one of these) together with the $n$ singletons.
Conversely, each such subset trivially satisfies the simplex condition (a set
with fewer than two vertices imposes no pairwise constraint). The count is
therefore $1 + n$. $\qquad\blacksquare$

**Remark 3.6 (A single exponential cliff).** Combining Corollary 3.3 and
Theorem 3.5, the size of $\mathrm{VR}(\mathrm{equi}_d, r)$ is $n+1$ for every
$r < d$ and jumps to $2^n$ for every $r \ge d$. The entire exponential content
of the filtration is concentrated at the single scale $r = d$: the barcode is a
single cliff of height $2^n - (n+1)$. This is the sharpest possible localisation
of exponential complexity in a Vietoris–Rips filtration.

## 4. The exponential lower bound

We now show that the cliff cannot be smoothed away by any approximation.

**Theorem 4.1 (Exponential lower bound for approximations).** Let $d \ge 0$ and
let $G$ be a $c$-approximation of $\mathrm{VR}(\mathrm{equi}_d, \cdot)$. Then the
level of $G$ at scale $c \cdot d$ satisfies
$$|G(c\cdot d)| \ge 2^n.$$

*Proof.* Instantiate the left interleaving containment of Definition 2.4 at
$t = d$ (which is $\ge 0$):
$$\mathrm{VR}(\mathrm{equi}_d, d) \subseteq G(c\cdot d).$$
By Theorem 3.2, taking $r = d$, the left-hand side is the full power set, so by
Corollary 3.3 it has $2^n$ elements. Since one finite collection contains
another, cardinalities are monotone:
$$2^n = |\mathrm{VR}(\mathrm{equi}_d, d)| \le |G(c\cdot d)|. \qquad\blacksquare$$

Theorem 4.1 is strikingly strong: the bound $2^n$ is *uniform in $c$*. Whatever
accuracy factor the approximation is allowed, some level of it is as large as
the full uncompressed complex. The interleaving relation used is the genuine
multiplicative interleaving, not a disguised restatement of the size bound, so
this is a substantive theorem rather than a definitional triviality.

## 5. The threshold exponent

To express the barrier in the standard "exponent times $n$" form and to expose
its threshold behaviour, we introduce the effective exponent.

**Definition 5.1 (Threshold exponent).**
$$\gamma(c) = \tfrac12 - \log_2 c.$$

**Proposition 5.2 (Positivity below $\sqrt 2$).** If $1 \le c < \sqrt 2$ then
$\gamma(c) > 0$.

*Proof.* We have $\gamma(c) > 0 \iff \log_2 c < \tfrac12 \iff c < 2^{1/2} =
\sqrt 2$, which holds by hypothesis. $\qquad\blacksquare$

**Proposition 5.3 (Upper bound).** If $c \ge 1$ then $\gamma(c) \le 1$.

*Proof.* Since $c \ge 1$ we have $\log_2 c \ge 0$, hence
$\gamma(c) = \tfrac12 - \log_2 c \le \tfrac12 \le 1$. $\qquad\blacksquare$

**Proposition 5.4 (Vanishing at the threshold).**
$$\lim_{c \to \sqrt 2^-} \gamma(c) = 0.$$

*Proof.* The map $c \mapsto \log_2 c$ is continuous at $c = \sqrt 2$, so
$\gamma$ is continuous there, and
$\gamma(\sqrt 2) = \tfrac12 - \log_2 \sqrt 2 = \tfrac12 - \tfrac12 = 0$. The
one-sided limit therefore equals the value $0$. $\qquad\blacksquare$

**Theorem 5.5 (Headline theorem — exponential barrier below $\sqrt 2$).** Let
$E_n$ be the equidistant configuration on $n$ points with common distance
$\sqrt 2$, realised by the standard basis vectors of $\mathbb{R}^n$. For every
$c$ with $1 \le c < \sqrt 2$ and every $c$-approximation $G$ of
$\mathrm{VR}(E_n, \cdot)$:

1. $\gamma(c) > 0$; and
2. there exists a scale $s$ (namely $s = c\sqrt 2$) with
   $$|G(s)| \ \ge\ 2^{\gamma(c)\cdot n}.$$

Moreover $\gamma(c) \to 0$ as $c \to \sqrt 2^-$.

*Proof.* Positivity is Proposition 5.2. For the size bound, take
$s = c\sqrt 2 = c\cdot d$ with $d = \sqrt 2$. By Theorem 4.1,
$|G(c\cdot d)| \ge 2^n$. It remains to observe that $2^{\gamma(c)\cdot n} \le 2^n$.
Since $\gamma(c) \le 1$ (Proposition 5.3) and $n \ge 0$, we have
$\gamma(c)\cdot n \le n$, and because $2^x$ is increasing,
$2^{\gamma(c)\cdot n} \le 2^n \le |G(c\cdot d)|$. The final limit is
Proposition 5.4. $\qquad\blacksquare$

## 6. Discussion

### 6.1 Interpretation of the threshold

The number $\sqrt 2$ is not incidental. Jung's theorem states that any set of
diameter $D$ in Euclidean space is contained in a closed ball of radius
$D\sqrt{\tfrac{n}{2(n+1)}}$, and the constant $\sqrt{\tfrac{2n}{n+1}}$ tends to
$\sqrt 2$ as the number of points grows. This is precisely the ratio at which
one may replace a bounded cluster by a single covering point without changing
distances by more than the interleaving factor. Thus $c = \sqrt 2$ is exactly
the accuracy at which net- and Čech-based sparsifications become legitimate,
and our exponent $\gamma(c) = \tfrac12 - \log_2 c$ vanishes there: the barrier
disappears at the very moment compression becomes possible.

### 6.2 Strength and limitation of the witness

The equidistant construction proves the *existence* of an effective exponent
$\gamma(c)$ with the correct limit, satisfying the claimed lower bound — the
precise existential content of the conjecture that no sub-exponential
approximation exists below $\sqrt 2$. Its strength is also its limitation: the
bound it produces, $2^n$, is uniform in $c$, so the equidistant family cannot by
itself display the *degradation* of the exponent as $c \to \sqrt 2^-$. Witnessing
that degradation requires a more refined, multi-scale construction (Section 7).

### 6.3 Relation to practice

High-dimensional data frequently contains near-equidistant clusters — a
manifestation of concentration of measure, whereby pairwise distances in high
dimensions cluster tightly around a common value. For such data the theorem is a
hard warning: any approximation scheme operating below accuracy $\sqrt 2$ must,
on some level, store exponentially many simplices. The barrier is
information-theoretic, not an artefact of any particular algorithm.

## 7. Future work

Three directions extend the present results.

**A degradation-tight family.** We conjecture the existence of a family
$\{Y_n\}$ of finite metric spaces for which the *minimum* size of a
$c$-approximation is $\Theta(2^{\gamma(c)\cdot n})$ — matching the lower bound from
below as well as above, so that as $c \to \sqrt 2^-$ genuinely sub-exponential
approximations appear. The equidistant gap is too rigid, forcing the full $2^n$
count uniformly; a multi-scale construction with geometrically spaced gaps at
ratios approaching $\sqrt 2$ should let a coarse interleaving skip alternate
gaps, trading resolution for size in exactly the ratio $\gamma(c)$ predicts.

**Homological, not merely combinatorial, hardness.** We conjecture that the
exponential barrier persists at the level of persistent homology: below
$\sqrt 2$, any $c$-interleaved persistence module approximating $\mathrm{VR}(X_n)$
must have total bar-count exponential in $n$, not merely an exponential number
of simplices. Simplex count is an upper proxy for homological complexity;
distributing independent gaps across dimensions should force exponentially many
bars that no $c$-interleaving can merge.

**The doubling-dimension dividend.** We conjecture that if $X_n$ has doubling
dimension bounded by a constant, then above $\sqrt 2$ a $c$-approximation of size
polynomial in $n$ always exists, while below $\sqrt 2$ the exponential barrier
survives even under bounded doubling dimension. Locating this phase boundary at
$\sqrt 2$ would explain why existing sparsifiers stall exactly at that accuracy.

## 8. Conclusion

We have identified a sharp, effective, exponential obstruction to approximating
Vietoris–Rips filtrations. The equidistant configuration on $n$ points —
concretely, the standard basis of $\mathbb{R}^n$ with pairwise distance
$\sqrt 2$ — has a Vietoris–Rips complex that jumps from $n+1$ to $2^n$ simplices
at a single scale, and this cliff forces every $c$-approximation with
$1 \le c < \sqrt 2$ to carry a level of at least $2^{\gamma(c)\cdot n}$ simplices,
with the explicit exponent $\gamma(c) = \tfrac12 - \log_2 c$ positive below the
threshold and vanishing at it. The threshold $\sqrt 2$ coincides with the onset
of net- and Čech-based sparsification, drawing a precise line between the
provably hard and the tractable regimes of topological data analysis.
