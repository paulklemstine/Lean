# Projective-Plane Coupon Collection is Slower than Uniform Sampling

**Author:** Aristotle

**Date:** 2026-06-30

## Abstract

We study the coupon collector's problem with structured batches drawn from a
finite projective plane. Fix a prime power $q \ge 2$ and the projective plane of
order $q$, with $n = q^2 + q + 1$ points and the same number of lines, each line a
$(q+1)$-subset of points. Two batch-covering mechanisms on the points are
compared: the **plane mechanism**, in which each draw is a uniformly random line,
and the **uniform mechanism**, in which each draw is a uniformly random
$(q+1)$-subset. Writing $E$ for the expected time to cover all $n$ points, we
prove for the Fano plane ($q = 2$) the exact values $E_{\text{plane}} = 163/30$
and $E_{\text{unif}} = 85691/15810$, hence $E_{\text{unif}} < E_{\text{plane}}$:
the structured line mechanism is strictly slower. This refutes, in the smallest
case, the natural conjecture (associated with Grünbaum and Yaakobi) that the
geometric mechanism is at least as efficient as uniform sampling. We isolate the
structural engine behind the phenomenon: the per-order *mean* of the plane's
avoid-probabilities equals the uniform avoid-probability at every order, the two
mechanisms coincide pointwise at orders one and two, and at order three the
plane's avoid-probabilities split into a collinear and a generic value whose
spread, through the convexity of $t \mapsto 1/(1-t)$, produces a strictly positive
surplus. We give exact closed-form avoid-counts for points, pairs, collinear
triples, and generic triples, verify the slowness inequality and the avoid-counts
for $q = 2$, report supporting computations for $q = 3, 4, 5$, and formulate the
general "universal slowness" conjecture together with an extremality conjecture
that identifies collinearity as the unique source of slowness.

## 1. Introduction

The coupon collector's problem asks for the expected number of draws needed to
observe every element of a finite set when draws are random. In its classical
single-coupon form, collecting $n$ distinct coupons one at a time requires
$nH_n \sim n\ln n$ draws in expectation, where $H_n$ is the $n$-th harmonic
number. A natural and practically important variant draws a *batch* of fixed size
on each step, revealing all coupons in the batch simultaneously. Batching
accelerates collection, but the rate of acceleration depends on *how* the batches
are chosen.

This paper compares two batch mechanisms of identical batch size on identical
ground sets, differing only in the family from which batches are drawn. One draws
batches uniformly at random among *all* subsets of the prescribed size. The other
restricts to a rigid, maximally balanced family: the **lines of a finite
projective plane**. Intuition strongly suggests that the balanced, low-overlap
line family should cover at least as fast as unconstrained random sampling. We
show the opposite occurs.

Our main concrete result is for the smallest projective plane, the Fano plane of
order $q = 2$: the line mechanism is strictly slower than uniform sampling
(Theorem 4.1). This refutes the natural conjecture, associated with Grünbaum and
Yaakobi, that the geometric mechanism cannot be slower. Beyond the single case,
we extract the *mechanism* responsible (Sections 5–6): an exact mean-matching
identity at every order, coincidence at orders one and two, and a convexity-driven
order-three surplus generated precisely by collinear triples. We close with the
general conjectures (Section 8).

## 2. The projective plane and its incidence counts

### 2.1 Definition

**Definition 2.1 (Finite projective plane).** For a prime power $q \ge 2$, a
*projective plane of order $q$* is a finite incidence structure of points and
lines such that:

1. there are $n = q^2 + q + 1$ points and $n$ lines;
2. every line is incident to exactly $q + 1$ points;
3. every point is incident to exactly $q + 1$ lines;
4. any two distinct points are incident to exactly one common line (equivalently,
   any two distinct lines meet in exactly one point).

A projective plane of order $q$ exists for every prime power $q$; the standard
construction realizes points and lines as the one-dimensional and two-dimensional
subspaces of a three-dimensional vector space over the field of $q$ elements.

A convenient concrete model uses a *planar (Singer) difference set*: a
$(q+1)$-subset $D \subseteq \mathbb{Z}/n\mathbb{Z}$ whose $\,(q+1)q$ nonzero
differences are all distinct (and hence run over every nonzero residue exactly
once). The translates $\{\,D + i : i \in \mathbb{Z}/n\mathbb{Z}\,\}$ are then the
$n$ lines of a projective plane of order $q$ on the point set
$\mathbb{Z}/n\mathbb{Z}$. For $q = 2$ one may take $D = \{0,1,3\} \pmod 7$, giving
the Fano plane with lines $\{i, i+1, i+3\}$.

### 2.2 Avoid-counts by configuration

The quantity that controls coupon collection is, for a fixed point set $A$, the
number of lines disjoint from $A$ (the lines that *avoid* $A$). These counts are
exact and depend only on the combinatorial type of $A$.

**Lemma 2.2 (Avoid-counts).** In a projective plane of order $q$ with
$n = q^2 + q + 1$ lines:

- a single point is avoided by exactly $q^2$ lines;
- a pair of distinct points is avoided by exactly $q^2 - q$ lines;
- a collinear triple (three points on a common line) is avoided by exactly
  $q^2 - 2q$ lines;
- a generic (non-collinear) triple is avoided by exactly $(q-1)^2$ lines.

*Proof sketch.* A point lies on $q+1$ lines, so $n - (q+1) = q^2$ lines avoid it.
For a pair $\{P, Q\}$, inclusion–exclusion on the lines through $P$ and through $Q$
gives $n - (q+1) - (q+1) + 1 = q^2 - q$, the $+1$ accounting for the unique line
through both. For a triple, count lines meeting at least one of the three points
via inclusion–exclusion. Each point lies on $q+1$ lines; each pair shares exactly
one line. If the triple is collinear, all three pairwise lines coincide with the
single line containing the triple, yielding $3(q+1) - 3\cdot 1 + 1$ lines meeting
the triple (the final $+1$ restoring the common line counted away), so
$q^2 + q + 1 - (3q + 1) = q^2 - 2q$ avoid it. If the triple is generic, the three
pairwise lines are distinct and no line contains all three, giving $3(q+1) - 3$
lines meeting it and $q^2 + q + 1 - 3q = (q-1)^2 + \,?$; carefully,
$n - (3(q+1) - 3) = q^2 + q + 1 - 3q = q^2 - 2q + 1 = (q-1)^2$ lines avoid it.
$\square$

For $q = 2$ ($n = 7$) the four counts are $4,\,2,\,0,\,1$ respectively, and these
exact values have been verified directly against the explicit Fano model.

## 3. Two mechanisms and the inclusion–exclusion cover time

We treat the $n$ points as coupons. A *covering process* repeatedly draws batches;
the cover time is the first step at which every point has appeared in some batch.

**Definition 3.1 (Avoid-probability).** For a single draw, and a point set $A$,
let $p_A$ be the probability that the draw avoids $A$ (touches no point of $A$).

**Definition 3.2 (Two mechanisms).**

- *Plane mechanism:* each draw is one of the $n$ lines, chosen uniformly. Then
$$p_A^{\text{plane}} = \frac{\#\{\text{lines disjoint from } A\}}{n}.$$
- *Uniform mechanism:* each draw is a uniformly random $(q+1)$-subset of the $n$
  points. Then $p_A$ depends only on $k = |A|$:
$$p_A^{\text{unif}} = \frac{\binom{n-k}{q+1}}{\binom{n}{q+1}}
= \frac{\prod_{i=0}^{k-1}(q^2 - i)}{\prod_{i=0}^{k-1}(n - i)},$$
using $n - (q+1) = q^2$ (falling-factorial form).

**Proposition 3.3 (Cover-time identity).** For a covering process with
independent draws and single-draw avoid-probabilities $p_A$, the expected cover
time over a ground set of points is
$$E \;=\; \sum_{\varnothing \neq A \subseteq \text{points}} (-1)^{|A|+1}\,
\frac{1}{1 - p_A}.$$

*Proof sketch.* Let $T$ be the cover time and $T_x$ the first time point $x$ is
seen, so $T = \max_x T_x$. By inclusion–exclusion on the events $\{T_x > t\}$,
$$P(T > t) = -\sum_{\varnothing \neq A}(-1)^{|A|}\,P\!\big(\textstyle\bigcap_{x\in A}\{T_x > t\}\big)
= \sum_{\varnothing\neq A}(-1)^{|A|+1} p_A^{\,t},$$
since the first $t$ draws all avoid $A$ with probability $p_A^t$. Summing
$E = \sum_{t \ge 0} P(T > t)$ and using $\sum_{t\ge 0} p_A^t = 1/(1-p_A)$ gives the
identity. $\square$

The two mechanisms feed different $p_A$ into the *same* identity. The entire
contest is therefore a comparison of avoid-probabilities, configuration by
configuration.

## 4. The Fano plane: exact slowness

For $q = 2$ the inclusion–exclusion sum has $2^7 - 1 = 127$ terms and can be
evaluated exactly in the rationals.

**Theorem 4.1 (Fano slowness, $q = 2$).** For the Fano plane,
$$E_{\text{plane}} = \frac{163}{30} \approx 5.4333, \qquad
E_{\text{unif}} = \frac{85691}{15810} \approx 5.4200,$$
and consequently
$$E_{\text{unif}} < E_{\text{plane}}, \qquad
E_{\text{plane}} - E_{\text{unif}} = \frac{163}{30} - \frac{85691}{15810}
\approx 0.0133 > 0.$$
The projective-plane line mechanism is strictly slower than the uniform
$(q+1)$-subset mechanism.

*Proof.* Evaluate $p_A^{\text{plane}}$ and $p_A^{\text{unif}}$ for each of the
$127$ nonempty $A \subseteq \mathbb{Z}/7\mathbb{Z}$ using Definition 3.2 and the
explicit Fano lines $\{i, i+1, i+3\}$, then sum the two inclusion–exclusion
series of Proposition 3.3 exactly over the rationals. The plane series telescopes
to $163/30$ and the uniform series to $85691/15810$; the difference is strictly
positive. $\square$

This refutes, in the smallest case, the conjecture that the line mechanism is at
least as efficient as uniform sampling. The positivity but smallness of the gap
($\approx 0.013$) explains why the conjecture was plausible: the leading
order-three surplus barely survives the alternating higher-order corrections.

## 5. Mean-matching at every order

The comparison simplifies dramatically because of an exact averaging identity.

**Theorem 5.1 (Mean-matching).** For every $k$ with $1 \le k \le n$, the average
of the plane avoid-probability over all $k$-subsets equals the uniform
avoid-probability of order $k$:
$$\frac{1}{\binom{n}{k}}\sum_{|A| = k} p_A^{\text{plane}}
\;=\; p_A^{\text{unif}}\big|_{|A| = k}
\;=\; \frac{\binom{n-k}{q+1}}{\binom{n}{q+1}}.$$

*Proof sketch.* By linearity, the left side equals
$\frac1n\,\mathbb{E}\big[\#\{\text{lines disjoint from a random } k\text{-set}\}\big]
= \frac1n\sum_{\text{lines } \ell} P(\ell \cap A = \varnothing)
= \frac1n \cdot n \cdot \binom{n-(q+1)}{k}\big/\binom{n}{k}
= \binom{n-q-1}{k}\big/\binom{n}{k}.$
The double-counting identity
$\binom{n}{k}\binom{n-k}{q+1} = \binom{n}{q+1}\binom{n-q-1}{k}$
(both count ordered pairs of disjoint sets of sizes $k$ and $q+1$) rewrites this
as $\binom{n-k}{q+1}/\binom{n}{q+1}$, the uniform value. $\square$

Thus, at every order, the plane and the uniform mechanism share the same *mean*
avoid-probability. Whether they contribute equally to the cover time depends only
on how the plane *distributes* its values around that mean.

**Corollary 5.2 (Coincidence at orders one and two).** Because every point is
avoided by exactly $q^2$ lines and every pair by exactly $q^2 - q$ lines
(Lemma 2.2), the plane avoid-probability is *constant* over all $1$-subsets and
over all $2$-subsets. Hence $p_A^{\text{plane}} = p_A^{\text{unif}}$ identically
for $|A| \in \{1, 2\}$, and the order-one and order-two contributions to
$E_{\text{plane}} - E_{\text{unif}}$ vanish.

## 6. The order-three surplus: convexity and collinearity

At order three the plane's avoid-probability is no longer constant. By Lemma 2.2 a
triple is avoided by $q^2 - 2q$ lines if collinear and $(q-1)^2$ lines if generic,
i.e. it takes the two values
$$p_{\text{coll}} = \frac{q^2 - 2q}{n}, \qquad
p_{\text{gen}} = \frac{(q-1)^2}{n} = p_{\text{coll}} + \frac{1}{n}.$$
Collinear and generic triples differ by exactly one avoiding line. The number of
collinear triples is $n\binom{q+1}{3}$ (each line carries $\binom{q+1}{3}$, and no
triple is collinear in two lines), and the remaining $\binom{n}{3} -
n\binom{q+1}{3}$ triples are generic. By Theorem 5.1 the weighted average of
$p_{\text{coll}}$ and $p_{\text{gen}}$ over all triples equals the uniform
value $p^{\text{unif}}_3$.

**Theorem 6.1 (Strict order-three surplus).** The order-three contribution to the
plane cover time strictly exceeds that of the uniform mechanism:
$$\sum_{|A|=3}\frac{1}{1 - p_A^{\text{plane}}}
\;>\;
\sum_{|A|=3}\frac{1}{1 - p_A^{\text{unif}}}.$$

*Proof sketch.* The function $\phi(t) = 1/(1-t)$ is strictly convex on $[0,1)$.
By Theorem 5.1 the multiset $\{p_A^{\text{plane}} : |A| = 3\}$ and the constant
multiset $\{p^{\text{unif}}_3 : |A| = 3\}$ have the same mean. Jensen's inequality
for $\phi$, applied to the empirical distribution of the plane values, gives
$$\frac{1}{\binom{n}{3}}\sum_{|A|=3}\phi\!\big(p_A^{\text{plane}}\big)
\;\ge\; \phi\!\Big(\tfrac{1}{\binom{n}{3}}\textstyle\sum_{|A|=3} p_A^{\text{plane}}\Big)
= \phi\big(p^{\text{unif}}_3\big),$$
with equality if and only if the plane values are constant. Since
$p_{\text{coll}} \neq p_{\text{gen}}$ for $q \ge 2$ and both triple types occur,
the inequality is strict. Multiplying by $\binom{n}{3}$ gives the claim. $\square$

This is the structural engine of slowness: orders one and two cancel exactly
(Corollary 5.2); order three is strictly positive (Theorem 6.1); and the variance
that drives it is created *precisely* by the existence of collinear triples — the
only place where the plane's perfectly balanced lower-order behavior breaks into
two distinct values.

## 7. Algorithms and computation

Three computations underpin and extend the results.

**(A) Exact rational cover time.** Build the plane (e.g. from a difference set),
enumerate the $2^n - 1$ nonempty subsets $A$, compute $p_A^{\text{plane}}$ by
counting disjoint lines and $p_A^{\text{unif}}$ by the binomial formula, and sum
the inclusion–exclusion series in exact rational arithmetic. This yields Theorem
4.1 for $q = 2$ ($127$ terms) and is feasible for $q = 3$ ($n = 13$, $8191$
terms). The cost is $O(2^n \cdot n)$ and becomes prohibitive for $q \ge 4$.

**(B) Type-grouped order-by-order surplus.** Rather than enumerate subsets,
compute the cover-time difference order by order using the avoid-count types. The
order-$k$ surplus is
$\sum_{\text{types } \tau} N_\tau\big(\phi(p_\tau) - \phi(p^{\text{unif}}_k)\big)$,
where $N_\tau$ is the number of $k$-sets of type $\tau$. For $k \le 3$ all types
and counts are known in closed form (Lemma 2.2, Section 6), making the leading
surplus exactly computable for every $q$.

**(C) Monte Carlo cover-time estimation.** For large $q$ ($n = 21, 31$, where
exact enumeration is infeasible), simulate both processes directly: repeatedly
draw batches (random lines, or random $(q+1)$-subsets) until all points appear,
and average the stopping time over many trials. This gives statistically
significant estimates of $E_{\text{plane}}$ and $E_{\text{unif}}$ and confirms the
sign of the gap for $q = 3, 4, 5$.

**Computational evidence.** Across $q = 2, 3, 4, 5$ the line mechanism is slower,
and the normalized gap appears to grow with $q$, supporting the universal
conjecture below.

## 8. Discussion, applications, and conjectures

### 8.1 Why structure can slow coverage

The result is counterintuitive because balanced, low-overlap designs are widely
assumed to cover efficiently. Theorems 5.1–6.1 explain the paradox precisely:
balance fixes the *mean* avoid-probability at every order, but coverage time is a
*convex* functional of avoid-probabilities, so any positive *variance* among
same-size configurations inflates the cost. A projective plane has zero variance
at orders one and two — it is maximally balanced there — yet collinearity forces
strictly positive variance from order three on. The very feature that makes the
plane elegant (lines, hence collinear triples) is what makes it slow.

### 8.2 Applications

The phenomenon is a cautionary tale for any setting that substitutes structured
batches for random ones to "improve coverage": randomized experimental design,
survey and sampling schemes, randomized covering and testing algorithms, and
batch construction in machine-learning pipelines. The lesson is quantitative: the
relevant quantity is not the *mean* coverage per batch (which structure can hold
fixed) but the *spread* of higher-order avoid-probabilities, amplified by a convex
cost. Designs that minimize this spread, not merely the overlap, are the ones that
minimize completion time.

### 8.3 Conjectures

**Conjecture 8.1 (Universal slowness).** For every prime power $q \ge 2$, the
expected time to collect all $q^2 + q + 1$ coupons under the projective-plane line
mechanism is strictly greater than under the uniform $(q+1)$-subset mechanism on
the same ground set. Equivalently, the order-three surplus of Theorem 6.1
dominates the signed sum of all higher-order ($k \ge 4$) corrections.

**Conjecture 8.2 (Collinearity is the unique source).** Among all
$(q+1)$-uniform incidence structures on $q^2 + q + 1$ points in which every point
lies on $q+1$ blocks and every pair lies on exactly one block, the projective
plane is extremal: any deviation that reduces the spread of triple
avoid-probabilities strictly reduces the cover-time surplus, and removing all
collinear triples removes the surplus entirely.

**Conjecture 8.3 (Monotone gap).** The normalized slowness gap — the plane's
cover-time surplus divided by the uniform cover time — is strictly positive for
every prime power $q \ge 2$ and tends to a positive limit as $q \to \infty$.

### 8.4 Future work

The decisive open problem is the tail estimate in Conjecture 8.1. The order-three
surplus has an exact closed form and the lower orders are settled; what remains is
to bound the alternating $k \ge 4$ contributions below the order-three gain,
uniformly in $q$. Promising tools include majorization/Schur-convexity arguments
that compare the plane's avoid-probability profile to the uniform constant profile
order by order, and generating-function control of the inclusion–exclusion tail.
A proof of Conjecture 8.2 would recast slowness as a clean extremal property of
projective planes among balanced designs.

## 9. Conclusion

For the Fano plane we established exactly that drawing batches as projective lines
is strictly slower than drawing uniformly random batches of the same size,
$E_{\text{plane}} = 163/30 > 85691/15810 = E_{\text{unif}}$, refuting the
Grünbaum–Yaakobi expectation in the smallest case. More importantly, we isolated
the general mechanism: exact mean-matching at every order, exact coincidence at
orders one and two, and a strictly positive, convexity-driven order-three surplus
created by collinear triples. Computations for $q = 3, 4, 5$ point uniformly to
the same conclusion, and we conjecture universal slowness for all prime powers,
with collinearity as its unique and quantifiable source.
