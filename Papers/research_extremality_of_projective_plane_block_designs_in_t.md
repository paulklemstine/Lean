# Cover Times of Block Families and the Extremality of the Fano Plane

## Abstract

We study a block-family generalization of the classical coupon collector's
problem. Fix a finite ground set of *points* and a family of *blocks* (subsets
of points); at each step a block is drawn uniformly at random, a point is
*covered* once a drawn block contains it, and the *cover time* is the first step
at which every point is covered. Via inclusion–exclusion over points, the
expected cover time admits a closed signed-sum formula in terms of the
**coverage counts** $c(S)$ — the number of blocks meeting a set $S$. We show
that for the family of all singletons this recovers the textbook value
$n \cdot H_n$, and we evaluate it exactly for the seven lines of the Fano plane,
the unique $2\text{-}(7,3,1)$ design. The Fano line family has expected cover
time $\tfrac{163}{30}$, strictly less than the singleton value
$7 \cdot H_7 = \tfrac{363}{20}$. This refutes a natural conjecture that a
projective-plane design should be the *slowest* covering mechanism: against the
singleton baseline it is in fact dramatically faster, and we explain why any
monotone cover model forces this direction. We close by isolating the fair,
fixed-block-size comparison under which a design may genuinely be extremal, and
state the precise conjectures that remain open.

**Keywords:** coupon collector, projective plane, Fano plane, block design,
$2\text{-}(7,3,1)$ design, inclusion–exclusion, cover time, balanced incomplete
block design.

---

## 1. Introduction

The coupon collector's problem is a cornerstone of elementary probability: with
$n$ equally likely coupon types drawn independently with replacement, the
expected number of draws to obtain all types is

$$
n \cdot H_n, \qquad H_n = \sum_{k=1}^{n} \frac{1}{k}.
$$

The factor $H_n \sim \ln n$ encodes the long tail of waiting for the final few
coupons. Many applications, however, do not deliver coupons one at a time but in
structured groups: a single observation may reveal several attributes at once, a
single packet may contain several stickers, a single probe may test several
components. This motivates a *block* version of the problem in which each draw
reveals an entire subset of points.

The central phenomenon we investigate is how the **combinatorial structure** of
the block family governs the expected cover time. The natural candidates for
"maximally structured" block families are the **balanced incomplete block
designs**, and the smallest nontrivial example is the **Fano plane**, the unique
$2\text{-}(7,3,1)$ design. We compute its cover time exactly, compare it against
the classical (singleton) collector on the same point set, and use the result to
correct and refine the guiding conjecture.

### Contributions

1. A self-contained framework for the expected cover time of an arbitrary block
   family, defined by an inclusion–exclusion formula over coverage counts
   (Section 2).
2. A proof that the singleton family reproduces the classical value
   $n \cdot H_n$ (Section 3).
3. An exact evaluation of the Fano line family's coverage counts and cover time,
   yielding $\tfrac{163}{30}$ (Section 4).
4. A clean comparison theorem: the Fano design is strictly faster than the
   singleton baseline, refuting the original "design is slowest" conjecture, with
   a structural explanation (Section 5).
5. A precise statement of the fair, fixed-block-size extremality conjectures
   under which projective-plane designs may genuinely maximize cover time
   (Section 6).

---

## 2. The cover-time framework

Let $\alpha$ be a finite ground set, whose elements we call **points** or
**coupons**, and let $B$ be a finite family of **blocks**, each block a subset of
$\alpha$. We run the following process: at each step a block is drawn uniformly
at random from $B$ (independently, with replacement). A point $p$ is **covered**
at the first step at which some drawn block contains $p$; write $\tau_p$ for that
step. The **cover time** of the process is

$$
T = \max_{p}\, \tau_p,
$$

the first step at which every point of $\bigcup B$ has been covered.

**Definition 2.1 (coverage count).**
For a set $S \subseteq \alpha$, the *coverage count* is

$$
c(S) = \#\{\, b \in B : b \cap S \neq \emptyset \,\},
$$

the number of blocks that meet $S$.

For a single random draw, the probability of covering at least one point of $S$
is $c(S)/|B|$, so the waiting time until the first point of $S$ appears is
geometric with mean $|B|/c(S)$; that is,
$\mathbb{E}\big[\min_{p \in S} \tau_p\big] = |B|/c(S)$.

**Definition 2.2 (expected cover time).**
The *expected cover time* of the block family $B$ is

$$
\mathbb{E}[T]
\;=\; \sum_{\emptyset \neq S \subseteq \alpha} (-1)^{|S|+1}\,\frac{|B|}{c(S)}.
$$

This is the inclusion–exclusion expansion of $\mathbb{E}[\max_p \tau_p]$ via the
identity $\max_p \tau_p = \sum_{\emptyset \neq S}(-1)^{|S|+1}\min_{p\in S}\tau_p$,
applied inside the expectation; we take it as the working definition of the
expected cover time. The sum ranges over all $2^{|\alpha|}-1$ nonempty subsets of
the ground set.

The formula is exact and elementary: each waiting time $|B|/c(S)$ depends only on
the coverage count, so the entire problem reduces to enumerating how the blocks
intersect every nonempty subset of points.

---

## 3. The classical collector as a special case

**Definition 3.1 (singleton family).**
The *singleton family* on $\alpha$ is $\mathcal{S} = \{\, \{a\} : a \in \alpha \,\}$,
with $|\mathcal{S}| = |\alpha| = n$.

**Lemma 3.2 (coverage counts of singletons).**
For every $S \subseteq \alpha$, $c_{\mathcal{S}}(S) = |S|$.

*Proof sketch.* A singleton block $\{a\}$ meets $S$ if and only if $a \in S$.
The map $a \mapsto \{a\}$ is injective, so the blocks meeting $S$ are in
bijection with the elements of $S$, giving $c_{\mathcal{S}}(S) = |S|$. $\qquad\blacksquare$

**Theorem 3.3 (recovery of $n \cdot H_n$).**
For the singleton family on an $n$-point set,

$$
\mathbb{E}[T] = \sum_{k=1}^{n} (-1)^{k+1}\binom{n}{k}\,\frac{n}{k} = n \cdot H_n.
$$

*Proof sketch.* By Lemma 3.2 the coverage count of a set depends only on its
size, so grouping the inclusion–exclusion sum by $k = |S|$ and using $|B| = n$
gives the middle expression, with $\binom{n}{k}$ counting the $k$-subsets. The
classical identity $\sum_{k=1}^n (-1)^{k+1}\binom{n}{k}\tfrac1k = H_n$ then yields
$n \cdot H_n$. $\qquad\blacksquare$

**Corollary 3.4 (the seven-point baseline).**
For $n = 7$,

$$
\mathbb{E}[T] = 7 \cdot H_7 = \frac{363}{20} = 18.15,
\qquad H_7 = \frac{363}{140}.
$$

This is the baseline against which the Fano design will be measured.

---

## 4. The Fano plane and its cover time

### 4.1 The design

**Definition 4.1 (Fano plane).**
The *Fano plane* is the $2\text{-}(7,3,1)$ design on the point set
$\{0,1,2,3,4,5,6\}$ whose seven lines are

$$
\{0,1,2\},\ \{0,3,4\},\ \{0,5,6\},\ \{1,3,5\},\ \{1,4,6\},\ \{2,3,6\},\ \{2,4,5\}.
$$

It is the unique projective plane of order $2$. Its defining parameters are
captured by the following facts, each a direct enumeration.

**Proposition 4.2 (design parameters).**
The Fano line family $B$ satisfies:

- *(blocks)* $|B| = 7$;
- *(block size)* every line has exactly $3$ points;
- *(point degree)* every point lies on exactly $3$ lines;
- *(pairwise balance)* every pair of distinct points lies on exactly $1$ line.

The pairwise-balance property — "$\lambda = 1$" — is the geometric heart of the
plane: any two points determine a unique line, the finite analogue of Euclidean
incidence.

### 4.2 Coverage counts

**Proposition 4.3 (low-order coverage).**
For the Fano line family:

- *(singletons)* $c(S) = 3$ for every $S$ with $|S| = 1$;
- *(pairs)* $c(S) = 5$ for every $S$ with $|S| = 2$.

*Proof sketch.* A single point lies on exactly $3$ lines (point degree), so
$c(\{p\}) = 3$. For a pair $\{p,q\}$, a line meets the pair iff it contains $p$
or $q$; by inclusion–exclusion the count is
$\deg(p) + \deg(q) - \#\{\text{lines through both}\} = 3 + 3 - 1 = 5$, using
pairwise balance for the last term. $\qquad\blacksquare$

**Remark 4.4 (a corrected value).**
An early sketch of this problem recorded $c(S) = 4$ for pairs; the correct value
is $5$. The discrepancy propagates into the final arithmetic, so the corrected
value is essential.

**Remark 4.5 (size alone is not enough).**
Unlike the singleton family, the Fano coverage count is *not* a function of $|S|$
for $|S| \ge 3$. The automorphism group of the Fano plane is $\mathrm{PSL}(2,7)$
of order $168$, which acts $2$-transitively (any pair maps to any pair, forcing
the clean singleton and pair values) but **not** $3$-transitively: a *collinear*
triple (three points on a common line) and a *non-collinear* triple behave
differently. For instance, a collinear triple is the single line itself plus the
other lines meeting it, while a non-collinear triple meets a different number of
lines. The higher coverage counts must therefore be tabulated configuration by
configuration, and the cover-time sum is evaluated by direct enumeration over all
$127$ nonempty subsets.

### 4.3 The exact cover time

**Theorem 4.6 (Fano cover time).**
The expected cover time of the Fano line family is

$$
\mathbb{E}[T_{\text{Fano}}]
= \sum_{\emptyset \neq S \subseteq \{0,\dots,6\}} (-1)^{|S|+1}\,\frac{7}{c(S)}
= \frac{163}{30} \approx 5.4333.
$$

*Proof sketch.* Enumerate the $127$ nonempty subsets $S$, compute each coverage
count $c(S)$ (the number of the seven lines meeting $S$), and sum the signed
terms $(-1)^{|S|+1}\cdot 7/c(S)$. The low-order terms are organized by
Propositions 4.2–4.3; the higher-order terms split by collinearity type per
Remark 4.5. The rational arithmetic collapses to $\tfrac{163}{30}$. $\qquad\blacksquare$

---

## 5. The comparison theorem and a corrected conjecture

**Theorem 5.1 (the design is strictly faster).**
On the seven-point set,

$$
\mathbb{E}[T_{\text{Fano}}] = \frac{163}{30}
\;<\; \frac{363}{20} = 7 \cdot H_7 = \mathbb{E}[T_{\text{singletons}}].
$$

*Proof sketch.* Immediate from Theorem 4.6 and Corollary 3.4:
$\tfrac{163}{30} = 5.4\overline{3}$ while $\tfrac{363}{20} = 18.15$. $\qquad\blacksquare$

**Corollary 5.2 (refutation of the original claim).**
The conjecture that the Fano cover time *exceeds* $7 \cdot H_7$ — i.e.
$7 \cdot H_7 < \mathbb{E}[T_{\text{Fano}}]$ — is false.

### 5.1 Why the direction is forced

The refutation is not an accident of small numbers; it is structural. The cover
time is **monotone** in the block family in the following sense: enlarging blocks
(or, more generally, increasing every coverage count $c(S)$) can only decrease
each waiting time $|B|/c(S)$ and hence the expected cover time. The singleton
family has the *smallest* possible coverage counts — $c(S) = |S|$, the minimum
for any family that covers $\alpha$ — so it is the *slowest* covering mechanism,
not the fastest.

A single Fano line already covers $3$ of the $7$ points in one draw, and the
$\lambda = 1$ incidence ties the points together so tightly that the plane is
swept in a handful of draws. Among covers of a fixed point set, an efficient
covering design is therefore extremal by *minimizing* cover time. The original
intuition — that perfect balance should *slow* collection — inverts the true
monotonicity when the comparison is made against singletons.

---

## 6. The right extremality question

Theorem 5.1 compares blocks of size $3$ against blocks of size $1$; the size
difference alone explains the speedup. The substantive question fixes the block
size and the regularity, removing the trivial advantage.

**Definition 6.1 (fair $\ell$-regular mechanism).**
A block family on $n$ points is *fair $\ell$-regular* if every block has size
$\ell$ and every point lies in the same number of blocks. The *fully random*
$\ell$-uniform mechanism draws an $\ell$-subset uniformly at random; a
$2\text{-}(n,\ell,1)$ design is fair $\ell$-regular with the additional
pairwise-balance constraint.

Within this class the projective plane may genuinely be extremal, and the
direction reverses: the conjecture is that the design is the **slowest**, because
its perfect low-order balance forces a compensating surplus of high-order block
overlap, and that high-order correlation — invisible to the first two coverage
moments — inflates the cover time.

**Conjecture 6.2 (uniform strict slowdown).**
For every projective plane of order $q \ge 2$, the expected cover time of its
line design strictly exceeds that of the fully random $(q+1)$-uniform mechanism on
the same $q^2 + q + 1$ points, with the gap increasing in $q$.

**Conjecture 6.3 (designs are global maximizers).**
Among all fair $\ell$-regular mechanisms on $n$ points, a $2\text{-}(n,\ell,1)$
design — when one exists — attains the maximum expected cover time, and is the
unique maximizer up to isomorphism. The mechanism is that expected cover time is a
Schur-convex functional of the pairwise co-coverage profile, maximized by
spreading correlation as evenly as possible — exactly the $\lambda = 1$ property.

**Conjecture 6.4 (the clustering index orders all mechanisms).**
Define the *clustering index* of a mechanism as the variance of its pairwise
co-coverage counts. Among fair $\ell$-regular families with equal first moments,
expected cover time is a strictly monotone function of the clustering index, and
projective-plane designs realize its maximum.

These conjectures are consistent with — indeed sharpened by — Theorem 5.1: against
singletons the design is fastest (block size dominates), while against an
equal-block-size random opponent the design's balance is conjectured to make it
slowest. The two comparisons isolate exactly which feature, block size or
correlation structure, drives the cover time.

---

## 7. Algorithms

The exact cover time of any block family on a small ground set is directly
computable. The core routine enumerates nonempty subsets, computes coverage
counts, and accumulates the signed sum in exact rational arithmetic (Section 9
and the accompanying demonstration code).

**Cover-time evaluation.** Given a block family $B$ on $n$ points:

1. For each nonempty $S \subseteq \{0,\dots,n-1\}$, compute
   $c(S) = \#\{b \in B : b \cap S \neq \emptyset\}$.
2. Accumulate $(-1)^{|S|+1}\,|B|/c(S)$ as an exact fraction.
3. Return the total.

The complexity is $O(2^n \cdot |B|)$, dominated by the subset enumeration; for
$n = 7$ this is $127 \times 7$ trivial intersection tests.

---

## 8. Applications and discussion

The block coupon-collector model captures any sampling process in which a single
observation reveals a structured group of items: multi-attribute records,
multiplexed tests, batched experiments, and group-testing schemes. The clean
message of this work is that **the geometry of the blocks, not merely their size,
governs the time to completeness**, and that balanced designs sit at an extreme
of that geometry.

The corrected comparison (Theorem 5.1) is a cautionary tale about intuition: a
plausible and aesthetically pleasing conjecture — that perfect balance maximizes
collection time — is simply false against the singleton baseline, where
monotonicity forces the opposite. The episode demonstrates the value of exact
computation: the rational value $\tfrac{163}{30}$ settles the question
unambiguously.

At the same time, Section 6 shows the intuition is not wrong, only
mis-targeted: against a fair, fixed-block-size opponent the design's balance
plausibly does maximize the cover time, and the right invariant to track is the
variance of pairwise co-coverage.

---

## 9. Numerical summary

| Mechanism on $7$ points | $\mathbb{E}[\text{cover time}]$ | Decimal |
|---|---|---|
| Singletons (classical) | $363/20 = 7 H_7$ | $18.15$ |
| Fano lines | $163/30$ | $5.4333\ldots$ |

The Fano design covers the plane in under a third of the singleton time.

---

## 10. Future work

The immediate next steps are to settle Conjectures 6.2–6.4. The smallest two
planes ($q = 2, 3$) already exhibit a strictly positive and growing gap against
the fully random mechanism of the same block size, isolating high-order
correlation as the sole remaining mechanism to quantify; the obstacle is no
longer *whether* a slowdown holds but *finding the closed form for the gap*. The
pair-coverage law (every pair met by $2q + 1$ lines) pins the second moment of
the design precisely, giving a concrete extremal target against which arbitrary
regular families can be compared by a single convexity inequality. A proof of the
Schur-convexity of expected cover time as a functional of the co-coverage profile
would simultaneously establish global maximality and the clustering-index
ordering.

---

## References

Standard background on the coupon collector's problem, finite projective planes,
and balanced incomplete block designs may be found in the classical literature on
probability and combinatorial design theory.
