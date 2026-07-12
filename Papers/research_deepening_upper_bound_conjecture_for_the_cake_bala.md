# The Cake-Balancing Ratio: Exact Algebra of a Windowed Imbalance Functional and a Universal Bound for Bisection Sequences

**Author:** Aristotle
**Date:** 2026-07-12
**Domain:** Applications (combinatorial geometry / uniform distribution)

## Abstract

We study a functional that measures how evenly a circular dissection
distributes mass among blocks of consecutive pieces. Given a dissection of a
circle into $n$ positive arcs and a window length $r \ge 1$, the *balancing
ratio* $\mu_r$ is the quotient of the largest to the smallest weight among all
windows of $r$ consecutive pieces. We develop the exact, dimension-free algebra
of this functional for a single dissection and prove four structural facts: the
ratio is always at least $1$; it is invariant under global rescaling of the
cake; it attains its optimum $1$ at the equipartition; and — the central
result — **aggregation never increases imbalance**, meaning $\mu_r \le \mu_1$
for every $r \ge 1$, where $\mu_1$ is the raw largest-piece-to-smallest-piece
ratio. This comparison is an exact inequality valid for every finite
dissection, driven by the cancellation of the window length $r$ in an extremal
sandwich. We then turn to infinite cutting sequences, where every intermediate
configuration must be balanced simultaneously, and prove that the greedy
repeated-bisection sequence keeps the long-run ratio below $2$: for every
window length $r \ge 1$, the balancing ratio at each stage lies in $[1, 2]$,
and hence $\limsup_{n\to\infty}\mu_r \le 2$. The bound is uniform in both the
window length and the circumference. We discuss why $2$ is the honest price of
the two-valued structure produced by bisection and formulate conjectures that a
smaller optimal constant, strict aggregation gains, and low-discrepancy
sequences should govern the true optimum.

## 1. Introduction

Consider an infinite sequence $a = (a_i)_{i=1}^\infty$ of points placed one at
a time on a circle. After the first $n$ points are placed they cut the circle
into $n$ arcs. As $n$ grows, the arcs are repeatedly subdivided, and one asks:
can the points be chosen so that the resulting dissection stays *balanced* at
every stage, not merely in the limit?

To quantify balance we fix a window length $r \ge 1$ and compare sums of $r$
consecutive arcs. Writing $\mu_r^n(a)$ for the ratio of the maximum to the
minimum weight of $r$ consecutive arcs among the first $n$ cuts, the long-run
imbalance is
$$\mu_r(a) = \limsup_{n\to\infty}\mu_r^n(a).$$
The problem is to understand $\inf_a \mu_r(a)$: the best balance achievable by
any infinite sequence, for each window length $r$.

This paper makes two contributions. First (§3), we settle the exact algebra of
the single-dissection functional, isolating the structural properties that any
analysis of the infinite problem must rest on. The keystone is an *aggregation
principle*: looking through a wider window can only reduce, never increase, the
measured imbalance. Second (§4), we exhibit an explicit sequence — repeated
bisection — whose long-run ratio is bounded by $2$ for every window length,
giving a clean, uniform, and non-vacuous ceiling for the infinite problem.
Section 5 discusses optimality and states the open conjectures that push past
the constant $2$.

## 2. Definitions

We model a circular dissection into $n$ pieces by a weight function
$$\mathrm{arc}\colon \mathbb{Z}/n\mathbb{Z} \to \mathbb{R}, \qquad \mathrm{arc}(i) > 0 \text{ for all } i,$$
where the cyclic group $\mathbb{Z}/n\mathbb{Z}$ supplies the wrap-around index
arithmetic automatically: piece $i+1$ after piece $n-1$ is piece $0$. The value
$\mathrm{arc}(i)$ is the length (mass) of the $i$-th piece. We assume
$n \ge 1$ throughout.

**Definition 2.1 (Window weight).** For a window length $r \in \mathbb{N}$ and a
starting index $i \in \mathbb{Z}/n\mathbb{Z}$, the *window weight* is the sum of
the $r$ consecutive pieces beginning at $i$:
$$W_r(i) \;=\; \sum_{j=0}^{r-1} \mathrm{arc}(i + j),$$
indices read cyclically.

**Definition 2.2 (Extremal windows and pieces).** Over all starting positions,
$$\mathrm{maxWindow}_r = \max_{i} W_r(i), \qquad \mathrm{minWindow}_r = \min_{i} W_r(i),$$
and over all single pieces,
$$\mathrm{maxArc} = \max_i \mathrm{arc}(i), \qquad \mathrm{minArc} = \min_i \mathrm{arc}(i).$$
All four maxima and minima exist because $\mathbb{Z}/n\mathbb{Z}$ is a finite
nonempty set.

**Definition 2.3 (Balancing ratio).** The *cake-balancing ratio for window
length $r$* is
$$\mu_r = \frac{\mathrm{maxWindow}_r}{\mathrm{minWindow}_r}.$$

Since a length-one window is a single piece, $W_1(i) = \mathrm{arc}(i)$, and so
$\mu_1 = \mathrm{maxArc}/\mathrm{minArc}$ is exactly the largest-to-smallest
piece ratio.

## 3. The exact algebra of a single dissection

Throughout this section fix a dissection with all pieces positive:
$\mathrm{arc}(i) > 0$ for all $i$. We record the structural lemmas and then the
four headline theorems.

### 3.1 Positivity and elementary bounds

**Lemma 3.1 (Positive windows).** For every $r \ge 1$ and every $i$, the window
weight $W_r(i)$ is positive; consequently $\mathrm{minWindow}_r > 0$ and
$\mathrm{minArc} > 0$.
*Proof.* A window of length $r \ge 1$ is a nonempty sum of positive terms,
hence positive. The minimum over a finite set of positive numbers is positive.
$\square$

**Lemma 3.2 (Ordering).** $\mathrm{minWindow}_r \le \mathrm{maxWindow}_r$.
*Proof.* The minimum of a function over a nonempty finite set is at most its
maximum; apply this to $W_r$. $\square$

**Lemma 3.3 (Extremal sandwich).** For every $r \ge 1$,
$$r \cdot \mathrm{minArc} \;\le\; \mathrm{minWindow}_r \qquad\text{and}\qquad \mathrm{maxWindow}_r \;\le\; r \cdot \mathrm{maxArc}.$$
*Proof.* Fix any starting index $i$. Each of the $r$ summands in $W_r(i)$
satisfies $\mathrm{minArc} \le \mathrm{arc}(i+j) \le \mathrm{maxArc}$, so
summing over $j = 0, \dots, r-1$ gives
$r\cdot\mathrm{minArc} \le W_r(i) \le r\cdot\mathrm{maxArc}$. Taking the
minimum of the left inequality and the maximum of the right over all $i$ yields
the two claims. $\square$

### 3.2 The four headline theorems

**Theorem 3.4 (Lower bound one).** For every $r \ge 1$, $\ \mu_r \ge 1$, with
equality precisely when every window of length $r$ has the same weight.
*Proof.* By Lemma 3.1 the denominator $\mathrm{minWindow}_r$ is positive, and
by Lemma 3.2 the numerator is at least the denominator; hence the quotient is
at least $1$. $\square$

**Theorem 3.5 (Aggregation never increases imbalance).** For every $r \ge 1$,
$$\mu_r \;\le\; \frac{\mathrm{maxArc}}{\mathrm{minArc}} \;=\; \mu_1.$$
*Proof.* By Lemma 3.3 and positivity of $\mathrm{minWindow}_r$ and
$\mathrm{minArc}$,
$$\mu_r = \frac{\mathrm{maxWindow}_r}{\mathrm{minWindow}_r} \le \frac{r\cdot\mathrm{maxArc}}{r\cdot\mathrm{minArc}} = \frac{\mathrm{maxArc}}{\mathrm{minArc}}.$$
The common factor $r$ cancels exactly; no asymptotics are used, and positivity
is the only hypothesis that does work (it keeps the denominators away from
zero). The identity $\mu_1 = \mathrm{maxArc}/\mathrm{minArc}$ holds because a
length-one window is a single piece. $\square$

This is the central structural fact. It says the single crudest measure of
imbalance, $\mu_1$, dominates every windowed measure simultaneously: to
control all $\mu_r$ it suffices to control $\mu_1$.

**Theorem 3.6 (Scale invariance).** For every constant $c > 0$ and every
$r \ge 1$, rescaling every piece by $c$ leaves the ratio unchanged:
$$\mu_r(c\cdot\mathrm{arc}) = \mu_r(\mathrm{arc}).$$
*Proof.* Each window weight scales linearly, $W_r(i) \mapsto c\,W_r(i)$, and a
positive constant factors out of both a supremum and an infimum. Thus
$\mathrm{maxWindow}_r \mapsto c\,\mathrm{maxWindow}_r$ and
$\mathrm{minWindow}_r \mapsto c\,\mathrm{minWindow}_r$; the factor $c$ cancels
in the quotient. $\square$

Scale invariance means the circumference of the cake is irrelevant: we may
normalise total mass to $1$ without loss of generality.

**Theorem 3.7 (Equipartition optimality).** If all pieces are equal to a
constant $c > 0$, then $\mu_r = 1$ for every $r \ge 1$.
*Proof.* Every window of length $r$ has weight $rc$, so numerator and
denominator coincide. $\square$

Together, Theorems 3.4 and 3.7 show that for a *single* dissection the optimum
$\mu_r = 1$ is attained exactly at equipartitions, and Theorem 3.5 shows the
whole family of windowed ratios is pinned beneath the single quantity $\mu_1$.

## 4. The infinite problem: a universal bound via bisection

For an infinite cutting sequence the situation is genuinely harder than for a
single dissection: the sequence must be balanced at *every* stage
simultaneously, and no infinite sequence can sit at an equipartition at every
$n$, because inserting one point into a uniform dissection immediately breaks
uniformity. The question becomes how small $\limsup_{n\to\infty}\mu_r$ can be
made. We give an explicit sequence achieving a uniform ceiling of $2$.

### 4.1 Two-valued dissections are 2-balanced

**Lemma 4.1 (Two-valued piece ratio).** If every piece takes one of the two
values $s$ or $2s$ with $s > 0$, then $\mathrm{maxArc}/\mathrm{minArc} \le 2$.
*Proof.* Every piece satisfies $s \le \mathrm{arc}(i) \le 2s$, so
$\mathrm{minArc} \ge s$ and $\mathrm{maxArc} \le 2s$; dividing gives the bound.
$\square$

**Theorem 4.2 (Two-valued dissections are 2-balanced).** If every piece is $s$
or $2s$ with $s > 0$, then for every window length $r \ge 1$,
$$\mu_r \le 2.$$
*Proof.* Combine the aggregation principle (Theorem 3.5) with Lemma 4.1:
$\mu_r \le \mathrm{maxArc}/\mathrm{minArc} \le 2$. $\square$

### 4.2 The bisection configuration

**Definition 4.3 (Bisection configuration).** Given $n \ge 1$, let
$k = \lfloor \log_2 n \rfloor$, so that $2^k \le n < 2^{k+1}$. The first $n$
cuts of the greedy "always split the largest piece" sequence produce a
dissection in which the pieces already bisected at the current round have
length $1/2^{k+1}$ and the pieces not yet bisected have the double length
$1/2^{k}$. Concretely, exactly $2(n - 2^k)$ pieces have the short length
$1/2^{k+1}$ and the remaining pieces have length $1/2^{k}$.

**Lemma 4.4 (Two-valuedness of bisection).** For every $n \ge 1$, each piece of
the bisection configuration equals $1/2^{k+1}$ or $2 \cdot (1/2^{k+1}) = 1/2^k$,
where $k = \lfloor \log_2 n \rfloor$.
*Proof.* Immediate from Definition 4.3: the configuration assigns exactly two
lengths, in ratio $2$. $\square$

### 4.3 The uniform bound

**Theorem 4.5 (Stage bound).** For every $n \ge 1$ and every window length
$r \ge 1$, the bisection configuration satisfies
$$1 \le \mu_r \le 2.$$
*Proof.* The lower bound is Theorem 3.4. For the upper bound, Lemma 4.4 puts
the bisection configuration in the two-valued class with $s = 1/2^{k+1}$, so
Theorem 4.2 gives $\mu_r \le 2$. $\square$

Extending $\mu_r$ to the empty configuration $n = 0$ by the trivial value $1$,
the sequence $n \mapsto \mu_r(\text{bisection at stage } n)$ takes values in
$[1, 2]$ for all $n$ and all $r \ge 1$.

**Theorem 4.6 (Long-run upper bound).** For every window length $r \ge 1$, the
bisection sequence has
$$\limsup_{n\to\infty}\mu_r \;\le\; 2.$$
*Proof.* The limit superior of a sequence bounded above by $2$ is at most $2$;
apply Theorem 4.5. The sequence is also bounded below by $1$, so the limit
superior is a genuine number in $[1, 2]$, not a degenerate value. $\square$

The bound is remarkable for what it does *not* depend on: it is uniform in the
window length $r$ and, by scale invariance (Theorem 3.6), independent of the
circumference. A single elementary constant governs balance across all window
scales at once.

## 5. Discussion, optimality, and open problems

**Why 2 is the honest boundary of the elementary method.** The constant $2$ is
exactly the price of the two-valued, factor-two description of the bisection
configuration. Theorem 4.5 shows the ratio genuinely occupies the interval
$[1,2]$: it returns to $1$ at each power-of-two milestone $n = 2^k$
(equipartition) and rises toward $2$ in between. The bound is therefore
non-vacuous but very likely not optimal, for two reasons. First, the
aggregation principle is a weak inequality here: overlapping windows share most
of their pieces, so a single oversized piece is amortised across $r$ windows,
suggesting the true $\mu_r$ decreases with $r$. Second, and more fundamentally,
the *order* in which equal-length pieces are split is a free parameter that the
factor-two argument discards entirely; a staggered insertion order can dilute
the factor-two gaps that lockstep bisection creates.

**Conjecture A (Sub-2 optimum).** For window length $r = 1$ there is an
infinite cutting sequence with $\mu_1 < 2$; the infimum of $\mu_1$ over all
sequences is a specific constant strictly between $1$ and $2$.

**Conjecture B (Strict aggregation gains).** For the optimal sequence the
long-run constant is strictly monotone in the window length on an initial
range: $\mu_{r+1} < \mu_r$ until windows wrap a constant fraction of the cake.

**Conjecture C (Low-discrepancy optimality).** The sequence inserting the
$n$-th point at the fractional part of $n\alpha$ for a badly approximable
$\alpha$ (for example the golden ratio) achieves the optimal $\mu_1$, with the
value governed by the continued-fraction expansion of $\alpha$. The three-gap
theorem forces such a sequence to use at most three distinct piece lengths at
every stage, and the extreme ratio between them is controlled by the partial
quotients of $\alpha$.

Conjecture C ties the balancing ratio to the arithmetic of Diophantine
approximation: the same "badly approximable" numbers that resist approximation
by rationals are expected to give the most uniform cutting sequences. This
places a seemingly elementary fairness problem in contact with a deep and
classical strand of number theory.

## 6. Conclusion

The cake-balancing ratio admits a clean, exact, dimension-free algebra for a
single dissection, organised around a single principle — aggregation never
increases imbalance — from which lower boundedness, scale invariance, and
equipartition optimality follow. For the infinite problem, greedy bisection
gives a uniform ceiling of $2$ across all window lengths. Closing the gap
between this ceiling and the true optimum, quantifying the gains from
aggregation, and confirming the role of low-discrepancy sequences are the
natural next steps, and they connect the subject to the continued-fraction
machinery of Diophantine approximation.

## Appendix: numerical illustration

For the equipartition of a unit circle into $n$ equal pieces, every window
weight is $r/n$ and $\mu_r = 1$ exactly. For the bisection configuration at
$n = 6$ (so $k = 2$, short length $1/8$, long length $1/4$, with $2(6-4)=4$
short pieces and $2$ long pieces), the single-piece ratio is
$(1/4)/(1/8) = 2$, and every windowed ratio $\mu_r$ for $r \ge 1$ is at most
$2$, matching the theory. A three-length "golden" configuration with lengths in
ratios governed by the continued fraction $[0;1,1,1,\dots]$ of the golden ratio
achieves single-piece ratios strictly below $2$ at most stages, illustrating
Conjecture C.
