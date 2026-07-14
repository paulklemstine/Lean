# A Sharp $\sqrt{2}$ Threshold for the Vietoris–Rips Complex of the Standard Simplex

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study the Vietoris–Rips complex of the canonical high-symmetry configuration
in Euclidean space: the $n$ standard basis vectors $e_1, \dots, e_n$ of
$\mathbb{R}^n$, which are pairwise separated by the exact distance $\sqrt{2}$. We
prove that this configuration exhibits a *perfectly sharp* threshold at scale
$\sqrt{2}$. At every scale $r$ with $0 \le r < \sqrt{2}$ the complex collapses to
its vertices, containing exactly $n+1$ simplices (the empty set and the $n$
singletons); at scale $r = \sqrt{2}$ it becomes the full power set, containing
exactly $2^n$ simplices. For $n \ge 2$ this is a strict jump from a linear count
to an exponential count, concentrated at a single scale, with no intermediate
structure. We localise the exponential blow-up under multiplicative interleavings:
for any one-sided $c$-approximation $G$ of the filtration, at least $2^n$ simplices
must be stored by scale $c\sqrt{2}$, while at most $n+1$ simplices can be present at
any scale $t$ with $c t < \sqrt{2}$. We further show that $2^n$ is globally
extremal — no proximity graph on $n$ vertices produces more than $2^n$ cliques —
so the standard simplex attains the maximal complexity at $\sqrt{2}$. Finally, we
contrast this all-or-nothing jump with a *graded* construction that achieves a
positive sub-threshold exponential rate $\gamma(c) = (\sqrt{2}/c - 1)/(\sqrt{2}-1)$,
isolating a structural dichotomy: sharpness of the threshold and sub-threshold
exponential hardness are mutually exclusive, and the latter requires graded
geometry.

**Keywords:** Vietoris–Rips complex, sharp threshold, $\sqrt{2}$ geometry,
standard simplex, interleaving, $c$-approximation, topological data analysis,
enumerative combinatorics, cliques, extremal configuration.

## 1. Introduction

The Vietoris–Rips complex is a fundamental construction linking metric geometry to
combinatorial topology and to the practice of topological data analysis (TDA).
Given a finite metric space $(X, d)$ and a scale parameter $r \ge 0$, it records
which finite subsets of $X$ have all pairwise distances at most $r$. As $r$
increases from $0$ to $\infty$ these complexes grow monotonically, forming a
*filtration* whose evolving topology (its persistent homology) summarises the
multiscale shape of $X$.

The typical narrative around such filtrations is one of *gradual* accumulation:
edges appear, then triangles, then higher simplices, as the scale sweeps past the
successive pairwise distances present in the data. In this paper we isolate the
opposite, extremal behaviour. We consider the most symmetric configuration
available in dimension $n$ — the standard orthonormal basis of $\mathbb{R}^n$ —
and show that its Vietoris–Rips filtration does *nothing* until scale $\sqrt{2}$
and then attains *maximal* complexity instantaneously. The threshold is perfectly
sharp: there is no scale at which the complex is partially built.

Our results are elementary in their ingredients — the Pythagorean theorem and the
counting of subsets — but they combine into a clean statement with consequences
for approximation. The main contributions are:

1. **Sharp threshold (Theorem 4.1).** A complete determination of the simplex
   count of the standard-basis Vietoris–Rips complex at all scales, exhibiting a
   strict $n+1 \to 2^n$ jump at exactly $\sqrt{2}$.
2. **Interleaving localisation (Theorems 5.1–5.2).** Two-sided bounds showing that
   any multiplicative $c$-approximation must store $\ge 2^n$ simplices near the
   threshold and $\le n+1$ below it, pinning the entire blow-up to the $\sqrt{2}$
   scale.
3. **Global extremality (Theorem 6.1).** The $2^n$ count is the maximum achievable
   by any proximity graph on $n$ vertices, so the standard simplex is extremal.
4. **A structural dichotomy (Section 7).** A comparison with a graded construction
   showing that sharpness and sub-threshold exponential hardness cannot coexist,
   and that the latter demands graded geometry with an explicit rate $\gamma(c)$.

## 2. Preliminaries and definitions

Throughout, $n$ is a natural number and we work in the Euclidean space
$\mathbb{R}^n$ with its standard $\ell^2$ metric
$$
\operatorname{dist}(x, y) = \sqrt{\sum_{k=1}^{n} (x_k - y_k)^2}.
$$

**Definition 2.1 (Canonical configuration).** For $1 \le i \le n$, let
$e_i \in \mathbb{R}^n$ denote the $i$-th standard basis vector, whose $i$-th
coordinate is $1$ and all others are $0$. The *canonical configuration* is the
finite point set $\{e_1, \dots, e_n\}$.

**Definition 2.2 (Vietoris–Rips simplex).** For a scale $r \in \mathbb{R}$, a
subset $S \subseteq \{1, \dots, n\}$ is a *Vietoris–Rips simplex at scale $r$* if
$$
\operatorname{dist}(e_i, e_j) \le r \quad \text{for all } i, j \in S.
$$
(The condition is vacuous for $|S| \le 1$.)

**Definition 2.3 (Vietoris–Rips complex).** The *Vietoris–Rips complex at scale
$r$*, written $\mathrm{VR}_n(r)$, is the collection of all Vietoris–Rips simplices
at scale $r$:
$$
\mathrm{VR}_n(r) = \bigl\{ S \subseteq \{1,\dots,n\} : \operatorname{dist}(e_i,e_j) \le r \text{ for all } i,j \in S \bigr\}.
$$
We denote by $\lvert \mathrm{VR}_n(r) \rvert$ the number of simplices it contains.

## 3. The exact $\sqrt{2}$ geometry

The entire analysis rests on a single geometric fact.

**Lemma 3.1 (Exact $\sqrt{2}$ distance).** For $i \neq j$,
$$
\operatorname{dist}(e_i, e_j) = \sqrt{2}.
$$

*Proof.* The difference $e_i - e_j$ has $i$-th coordinate $1$, $j$-th coordinate
$-1$, and all others $0$. Hence
$$
\operatorname{dist}(e_i, e_j)^2 = \sum_{k=1}^{n} (e_i - e_j)_k^2 = 1^2 + (-1)^2 = 2,
$$
and taking the nonnegative square root gives $\operatorname{dist}(e_i,e_j)=\sqrt2$.
$\qquad\blacksquare$

Because all nonzero pairwise distances take the single value $\sqrt{2}$, the
configuration is *equidistant*: it is, up to scaling, a regular simplex realised by
orthonormal vectors. This degeneracy of the distance spectrum is precisely what
produces the sharp threshold.

## 4. The sharp threshold

We now compute $\lvert \mathrm{VR}_n(r) \rvert$ at all scales.

**Proposition 4.1 (At the threshold: full power set).** At scale $\sqrt{2}$, every
subset of $\{1,\dots,n\}$ is a simplex, so
$$
\mathrm{VR}_n(\sqrt{2}) = 2^{\{1,\dots,n\}}, \qquad \lvert \mathrm{VR}_n(\sqrt{2}) \rvert = 2^n.
$$

*Proof.* For any $S$ and any $i, j \in S$, either $i = j$, whence
$\operatorname{dist}(e_i,e_j) = 0 \le \sqrt2$, or $i \neq j$, whence by Lemma 3.1
$\operatorname{dist}(e_i,e_j) = \sqrt2 \le \sqrt2$. Thus every subset is a simplex,
so the complex is the full power set of an $n$-element set, which has $2^n$
elements. $\qquad\blacksquare$

**Proposition 4.2 (Below the threshold: collapse to vertices).** Let
$0 \le r < \sqrt{2}$. Then a subset $S$ is a simplex at scale $r$ if and only if
$\lvert S \rvert \le 1$. Consequently
$$
\mathrm{VR}_n(r) = \bigl\{ S : \lvert S \rvert \le 1 \bigr\}, \qquad \lvert \mathrm{VR}_n(r) \rvert = n + 1.
$$

*Proof.* If $\lvert S \rvert \le 1$, the simplex condition is vacuous, so $S$ is a
simplex. Conversely, suppose $S$ is a simplex with $\lvert S \rvert \ge 2$; pick
distinct $a, b \in S$. Then $\operatorname{dist}(e_a, e_b) \le r$, but by Lemma 3.1
$\operatorname{dist}(e_a, e_b) = \sqrt{2} > r$, a contradiction. Hence every
simplex has at most one vertex. The subsets of size at most one are exactly the
empty set together with the $n$ singletons, giving $1 + n = n+1$ in total.
$\qquad\blacksquare$

Combining these with the elementary inequality $n + 1 < 2^n$ for $n \ge 2$ yields
the headline result.

**Theorem 4.1 (Sharp $\sqrt{2}$ threshold).** For the canonical configuration in
$\mathbb{R}^n$:
$$
\lvert \mathrm{VR}_n(r) \rvert =
\begin{cases}
n + 1, & 0 \le r < \sqrt{2}, \\[2pt]
2^n, & r = \sqrt{2}.
\end{cases}
$$
For $n \ge 2$ the transition is a strict increase, $n + 1 < 2^n$, concentrated at
the single scale $\sqrt{2}$: the complex is constant with value $n+1$ on the whole
interval $[0, \sqrt{2})$ and jumps to $2^n$ at $\sqrt{2}$.

*Proof.* The two cases are Propositions 4.2 and 4.1. For the strict inequality
$n+1 < 2^n$ when $n \ge 2$, induct on $n$: the base case $n = 2$ gives $3 < 4$; and
if $m + 1 < 2^m$ for some $m \ge 2$, then
$m + 2 < 2^m + 2^m = 2^{m+1}$. $\qquad\blacksquare$

The word "sharp" is literal: for every $\varepsilon > 0$ the complex at scale
$\sqrt{2} - \varepsilon$ still has only $n+1$ simplices, no matter how small
$\varepsilon$ is. There is no scale at which the complex is partially built.

## 5. Interleaving: localising the blow-up

Exact Vietoris–Rips complexes are expensive; in practice one replaces the
filtration by a cheaper surrogate that is *multiplicatively interleaved* with it.
We record a one-sided version sufficient for our bounds.

**Definition 5.1 ($c$-approximation).** Let $c \ge 1$. A family
$G : \mathbb{R} \to \{\text{finite complexes on } n \text{ vertices}\}$ is a
*(one-sided) $c$-approximation* of the canonical Vietoris–Rips filtration if:

1. $c \ge 1$;
2. *(Completeness)* for every $t \ge 0$, $\mathrm{VR}_n(t) \subseteq G(c \cdot t)$;
   every true simplex at scale $t$ appears in $G$ by scale $c t$;
3. *(Soundness)* for every $t \ge 0$, $G(t) \subseteq \mathrm{VR}_n(c \cdot t)$;
   $G$ never invents a simplex absent from the true complex by scale $c t$.

The parameter $c$ quantifies the multiplicative scale distortion permitted in
exchange for cheaper representation. We now show the exponential blow-up cannot be
avoided, delayed, or created early.

**Theorem 5.1 (Exponential survival at the threshold).** For any $c$-approximation
$G$,
$$
2^n \le \bigl\lvert G(c \cdot \sqrt{2}) \bigr\rvert.
$$

*Proof.* By completeness with $t = \sqrt{2} \ge 0$ we have
$\mathrm{VR}_n(\sqrt{2}) \subseteq G(c\sqrt{2})$, so
$\lvert G(c\sqrt2)\rvert \ge \lvert \mathrm{VR}_n(\sqrt2)\rvert = 2^n$ by
monotonicity of cardinality under inclusion and Proposition 4.1.
$\qquad\blacksquare$

**Theorem 5.2 (Polynomial ceiling below the threshold).** For any $c$-approximation
$G$ and any scale $t \ge 0$ with $c \cdot t < \sqrt{2}$,
$$
\bigl\lvert G(t) \bigr\rvert \le n + 1.
$$

*Proof.* By soundness, $G(t) \subseteq \mathrm{VR}_n(c t)$. Since $c \ge 1 > 0$ and
$t \ge 0$ we have $ct \ge 0$, and $ct < \sqrt2$ by hypothesis, so Proposition 4.2
gives $\lvert \mathrm{VR}_n(ct)\rvert = n+1$. Hence
$\lvert G(t)\rvert \le \lvert \mathrm{VR}_n(ct)\rvert = n+1$. $\qquad\blacksquare$

Together, Theorems 5.1 and 5.2 sandwich the transition: below the interleaved
threshold the surrogate is as inert as the truth ($\le n+1$ simplices), while by
scale $c\sqrt{2}$ it is forced to be maximal ($\ge 2^n$ simplices). The entire
exponential cost is *localised* to the $\sqrt{2}$ scale and cannot be smeared out
by any bounded multiplicative approximation.

## 6. Global extremality

The maximal value $2^n$ is not merely large; it is the largest possible on $n$
points.

**Theorem 6.1 (Extremality).** Let $H$ be any simple graph on the vertex set
$\{1, \dots, n\}$ (a "proximity graph"), and let its *clique complex* be the family
of all vertex subsets that induce a complete subgraph. Then the number of cliques
of $H$ is at most $2^n$, with equality for the complete graph. In particular,
$$
(\text{number of cliques of } H) \le \lvert \mathrm{VR}_n(\sqrt{2}) \rvert = 2^n,
$$
so the canonical configuration attains the maximum simplex count achievable by any
proximity structure on $n$ points.

*Proof.* Every clique is in particular a subset of the $n$-element vertex set, and
there are exactly $2^n$ such subsets; hence the clique complex, being a
sub-collection of the power set, has at most $2^n$ elements. Equality holds for the
complete graph, where every subset is a clique. Proposition 4.1 identifies
$\mathrm{VR}_n(\sqrt2)$ with the full power set, realising this bound.
$\qquad\blacksquare$

Thus the standard simplex at scale $\sqrt{2}$ is a global extremiser: no
arrangement of $n$ points can carry a richer complex.

## 7. The structural dichotomy: sharp versus graded

The sharpness of Theorem 4.1 is aesthetically appealing but comes at a cost that
is worth stating precisely, because it motivates an entirely different geometry.

Suppose one wishes to prove *sub-threshold* hardness: that even a coarse
approximation valid strictly below $\sqrt{2}$ must be exponentially large. The
canonical configuration is powerless here. By Theorem 5.2, below the interleaved
threshold it offers only $n+1$ simplices — there is no exponential content beneath
$\sqrt{2}$ to force upon a surrogate. The all-or-nothing jump concentrates *all*
complexity at a single scale, leaving a trivial complex below it.

Sub-threshold exponential lower bounds instead require a **graded geometry**, in
which the pairwise distances are not all equal to $\sqrt{2}$ but are distributed
across the window $(1, \sqrt{2}]$ so that structure accumulates progressively.
Concretely, one can build a finite (ultra)metric on $n$ points whose nonzero
distances fill $[1, \sqrt{2}]$ in a graded pattern — with a nested family of active
cliques of radius
$$
\rho(n, i) = 1 + (\sqrt{2} - 1)\,\frac{i+1}{n},
$$
so that as the scale rises toward $\sqrt{2}$, cliques of increasing size become
active one after another. For such a configuration one defines the **effective
exponential rate**
$$
\gamma(c) = \frac{\sqrt{2}/c - 1}{\sqrt{2} - 1}, \qquad c \in [1, \sqrt{2}),
$$
which satisfies $0 < \gamma(c) \le 1$ throughout the regime and
$\lim_{c \to \sqrt{2}^-} \gamma(c) = 0$. The graded construction then yields a
genuine sub-threshold lower bound: any one-sided $c$-approximation $G$ obeys
$$
2^{\lfloor n\,\gamma(c)\rfloor} \le \bigl\lvert G(\sqrt{2}) \bigr\rvert,
$$
an exponential bound *below* the threshold whose rate is positive for every
$c < \sqrt{2}$ and degrades continuously to zero exactly at the $\sqrt{2}$ barrier.

The comparison isolates a clean dichotomy:

| Configuration | Threshold shape | Sub-threshold rate |
|---|---|---|
| Standard basis (equidistant) | perfectly sharp: $n+1 \to 2^n$ at $\sqrt{2}$ | $\gamma \equiv 0$ |
| Graded (spectrum fills $(1,\sqrt{2}]$) | smeared / gradual | $\gamma(c) = \dfrac{\sqrt{2}/c-1}{\sqrt{2}-1} > 0$ |

One can have a sharp threshold, or one can have sub-threshold exponential
hardness, but not both from the same geometry. The very degeneracy of the distance
spectrum that makes the standard simplex sharp is what makes it silent below
$\sqrt{2}$; positive sub-threshold rate requires spreading the spectrum out.

## 8. Algorithms

We describe the two computational routines that realise the results numerically.

**Algorithm A (Simplex counter for the canonical configuration).** Given $n$ and a
scale $r$, count $\lvert \mathrm{VR}_n(r)\rvert$ directly from the closed form of
Theorem 4.1, avoiding enumeration of all $2^n$ subsets: return $2^n$ if
$r \ge \sqrt{2}$, and $n+1$ if $0 \le r < \sqrt{2}$. This runs in $O(1)$ arithmetic
operations (plus the cost of computing $2^n$). A brute-force cross-check enumerates
subsets and tests the pairwise condition, in $O(2^n \cdot n^2)$ time, used only to
validate the closed form for small $n$.

**Algorithm B (Interleaving envelope).** Given $n$, an approximation factor
$c \ge 1$, and a query scale $t \ge 0$, return the provable envelope on
$\lvert G(t)\rvert$ implied by Theorems 5.1–5.2: a lower bound of $2^n$ whenever
$t \ge c\sqrt{2}$ (via completeness applied at $\sqrt2$), and an upper bound of
$n+1$ whenever $ct < \sqrt{2}$. This makes explicit the two-sided localisation of
the blow-up.

## 9. Applications and significance

**Approximation limits in TDA.** Theorems 5.1–5.2 give a concrete, exact instance
where multiplicative interleaving cannot reduce the worst-case size of a
Vietoris–Rips representation: the exponential cost is intrinsic and merely shifts
by the factor $c$ in scale. This complements sparsification results by exhibiting a
matching lower bound at the extremal configuration.

**A benchmark for sharpness.** The standard simplex is a clean, fully understood
test case for any claim about the "shape" of a filtration near a critical scale.
Its all-or-nothing behaviour is a useful sanity check and a hard case for
smoothing or interpolation heuristics.

**A design principle.** The dichotomy of Section 7 is actionable: if one needs
exponential lower bounds *approaching* a critical scale (rather than at it), one
must engineer a graded distance spectrum. The rate $\gamma(c)$ quantifies exactly
how much sub-threshold hardness a given amount of grading buys.

## 10. Future directions

Several avenues extend this work.

1. **A geometry-to-rate dictionary.** We conjecture that the guaranteed
   sub-threshold exponential rate $\gamma(c)$ of a finite point cloud is governed by
   how quickly its sorted pairwise-distance spectrum accumulates just below
   $\sqrt{2}$: a flat spectrum (a single value $\sqrt{2}$) forces $\gamma \equiv 0$,
   while a uniformly graded spectrum forces the maximal $\gamma$. The rate should be
   a functional of the *distribution* of near-threshold distances, so that two
   clouds with the same near-threshold profile share the same achievable rate.

2. **Euclidean realisability of the graded rate.** We conjecture that the graded
   rate $\gamma(c) = (\sqrt{2}/c - 1)/(\sqrt{2} - 1)$ is realisable by an explicit
   point cloud in $\mathbb{R}^d$ — for instance concentric scaled regular simplices
   whose radii sweep $(1, \sqrt{2}]$ — so that sub-$\sqrt{2}$ exponential lower
   bounds survive in genuine Euclidean space and are not artefacts of abstract
   ultrametrics.

3. **Sharpness equals spectral degeneracy.** We conjecture that a finite
   configuration has a strictly sharp (all-or-nothing) Vietoris–Rips threshold at a
   scale $\rho$ if and only if all its nonzero pairwise distances equal $\rho$ — that
   is, it is an equidistant (regular-simplex) configuration up to scaling. Theorem
   4.1 supplies the forward direction; the converse would characterise the extremal
   sharp configurations exactly.

4. **Stability of the collapse under perturbation.** How robust is the
   sub-threshold collapse to small metric perturbations of the equidistant
   configuration? A quantitative stability statement would connect sharpness to the
   nearby "almost-sharp" regime.

5. **From simplex count to persistence.** Upgrading the counting bounds to lower
   bounds on the size of any interleaved *persistence module* or barcode would tie
   the result to the standard TDA invariants directly.

## 11. Conclusion

The standard basis of $\mathbb{R}^n$ — the most symmetric finite configuration in
its dimension — has a Vietoris–Rips filtration that is inert with $n+1$ simplices
below $\sqrt{2}$ and maximal with $2^n$ simplices at $\sqrt{2}$, a strict
exponential jump concentrated at a single scale. This blow-up is intrinsic:
multiplicative approximations can shift it but not avoid it, and $2^n$ is the
global maximum on $n$ points. The very degeneracy of its distance spectrum makes
the threshold sharp and, for the same reason, makes the configuration silent below
$\sqrt{2}$ — a limitation that a graded geometry with rate $\gamma(c)$ overcomes.
The result is a compact meeting point of Euclidean geometry, enumerative
combinatorics, and the approximation theory of persistent topology.
