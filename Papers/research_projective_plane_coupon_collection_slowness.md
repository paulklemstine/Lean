# Projective-Plane Coupon Collection is Slower than Uniform: A Convexity Engine

## Abstract

We study coverage time for two block-sampling coupon-collection mechanisms on
the point set of a finite projective plane of order $q$. The ground set has
$n = q^2 + q + 1$ points; both mechanisms draw blocks of size $q+1$. The **plane
mechanism** samples a uniformly random line of the plane (a structured
$(q+1)$-subset of points), while the **uniform mechanism** samples a uniformly
random $(q+1)$-subset. Using the inclusion–exclusion formula for expected
coverage time, $E = \sum_{\varnothing \ne A} (-1)^{|A|+1}/(1-p_A)$ where $p_A$ is
the single-draw probability of avoiding $A$, we prove that the two mechanisms are
statistically indistinguishable on all size-averaged marginals (a binomial
mean-matching identity) and that they coincide *exactly* at orders one and two.
The first divergence occurs at order three, where the plane's triples split into
collinear and generic types with two distinct avoid-probabilities sharing the
uniform mean. Strict convexity of the harmonic weight $x \mapsto 1/(1-x)$, via a
two-point Jensen inequality, makes the plane's order-three contribution strictly
larger. Assembling orders one through three with their inclusion–exclusion signs,
we prove that for **every** prime power $q \ge 2$ the order-three truncation of
$E$ is strictly larger for the plane mechanism. This refines the disproof of the
Grünbaum–Yaakobi conjecture (the $q=2$, Fano-plane case) and identifies
incidence variance, not mean, as the order parameter governing coverage slowness.
A full all-orders proof is verified computationally for $q = 2, 3, 4, 5$ and
remains open in general; the obstruction is precisely control of the alternating
tail of orders $\ge 4$.

## 1. Introduction

### 1.1 The classical coupon collector and its block variants

The coupon collector's problem asks for the expected number of independent
uniform draws from a set of $n$ coupons needed to see each coupon at least once;
the answer is $n H_n \sim n \log n$, where $H_n$ is the $n$-th harmonic number. A
natural and practically important generalization replaces single coupons by
**blocks**: each draw reveals a whole subset of coupons. Block coupon collection
models many real situations — packets of trading cards, batch acquisition of
network resources, covering codes, and the coverage analysis of randomized
combinatorial designs.

When all blocks have a fixed size $k$, a fundamental comparison arises. Among all
block families on $n$ points with block size $k$, which families cover *fastest*,
and which cover *slowest*? The widespread intuition — formalized in design
theory, lottery-wheel construction, and covering-code engineering — is that
*structured, balanced* designs cover efficiently. The projective plane, the most
balanced incidence structure of its size, is the natural test case.

### 1.2 The Grünbaum–Yaakobi question

Grünbaum and Yaakobi asked whether the line family of a finite projective plane
covers its point set faster than uniform random $(q+1)$-subsets. The line family
is a balanced design: every point lies on $q+1$ lines, every pair of points
determines a unique line, and the blocks tile incidences with maximal regularity.
If structure helped, the plane would win.

It does not. The conjecture fails already for the Fano plane ($q = 2$), where the
plane mechanism is strictly slower. This paper isolates the structural mechanism
behind that failure, proves it holds at the level of the third-order truncation
for *every* prime power $q$, and articulates the resulting general principle.

### 1.3 Contributions

1. **Mean-matching identity.** Averaged over all $k$-element targets, the plane
   mechanism's avoid-probability equals the uniform mechanism's, for every $k$
   (Theorem 4.1). The two mechanisms are indistinguishable in all marginals.
2. **Exact agreement at orders one and two.** Every singleton and every pair is
   geometrically homogeneous in a projective plane, so the avoid-probabilities
   coincide *pointwise*, and the orders-one and -two contributions to $E$ are
   identical (Theorems 5.1, 5.2).
3. **Order-three divergence via convexity.** Triples split into collinear and
   generic types with distinct avoid-probabilities sharing the uniform mean;
   strict two-point Jensen makes the plane's order-three contribution strictly
   larger (Theorems 6.1, 6.3).
4. **Truncated slowness for all $q$.** Assembling orders one through three with
   inclusion–exclusion signs, the plane's third-order truncation of $E$ strictly
   exceeds the uniform's, for every prime power $q \ge 2$ (Theorem 7.1).
5. **A variance principle.** The per-order gap is the convex-weighted variance of
   incidence counts among same-size targets; this reframes coverage slowness as a
   spread phenomenon and points to balanced designs as the extremal slowest
   families.

## 2. Preliminaries: finite projective planes

A **finite projective plane of order $q$** ($q \ge 2$) is a finite incidence
structure of points and lines satisfying:

- any two distinct points lie on a unique common line;
- any two distinct lines meet in a unique common point;
- there exist four points no three of which are collinear.

From these axioms one derives the standard counting facts, which we record as
definitions and used identities.

**Counting facts.** A projective plane of order $q$ has exactly
$$n := q^2 + q + 1$$
points and exactly $n$ lines. Each line contains exactly $q+1$ points, each point
lies on exactly $q+1$ lines, and
$$n - (q+1) = q^2.$$

Projective planes of order $q$ are known to exist for every prime power $q$ (from
the field $\mathbb{F}_q$, via the points and lines of the projective space
$\mathrm{PG}(2,q)$). Their existence for non-prime-power $q$ is a deep open
problem; the orders $q = 6$ and $q = 10$ are known not to admit planes. All
statements in this paper are quantified over those $q$ for which a plane exists
(in particular all prime powers).

**Lemma 2.1 (single-point avoid-count).** *In any finite projective plane of
order $q$, the number of lines that avoid a given point is exactly $q^2$.*

*Proof sketch.* A given point $p$ lies on exactly $q+1$ lines (the line count
through a point). The total number of lines is $n = q^2 + q + 1$. Hence the
number of lines missing $p$ is $n - (q+1) = q^2$. $\square$

This single incidence fact, derived from the plane axioms rather than assumed,
grounds the plane's single-point avoid-probability used below.

## 3. The two mechanisms and the coverage-time formula

Fix a projective plane of order $q$ with point set of size $n = q^2 + q + 1$.
Each mechanism produces an i.i.d. sequence of blocks; we collect points until all
$n$ have appeared in some block.

**Definition 3.1 (plane mechanism).** Each draw is a uniformly random line of the
plane: one of the $n$ lines, each a $(q+1)$-subset of points.

**Definition 3.2 (uniform mechanism).** Each draw is a uniformly random
$(q+1)$-subset of the $n$ points, chosen from all $\binom{n}{q+1}$ such subsets.

**Avoid-probabilities.** For a target set $A \subseteq \text{points}$, let $p_A$
denote the probability a single draw avoids $A$ (contains no point of $A$).

For the uniform mechanism, $p_A$ depends only on $k = |A|$:
$$u_k := \frac{\binom{n-k}{\,q+1\,}}{\binom{n}{\,q+1\,}}
       = \prod_{i=0}^{k-1} \frac{q^2 - i}{\,n - i\,},$$
the falling-factorial form obtained from $n - (q+1) = q^2$.

For the plane mechanism, $p_A$ depends on the geometry of $A$. Writing the
avoid-probability as (number of lines avoiding $A$)$/n$:

- a single point is avoided by $q^2$ lines: $p_{\text{point}} = q^2/n$;
- a pair of points is avoided by $q^2 - q$ lines: $p_{\text{pair}} =
  (q^2-q)/n$;
- a **collinear** triple (three points on a common line) is avoided by
  $q^2 - 2q$ lines: $p_{\text{coll}} = (q^2 - 2q)/n$;
- a **generic** (non-collinear) triple is avoided by $(q-1)^2 = q^2 - 2q + 1$
  lines: $p_{\text{gen}} = (q-1)^2/n$.

The pair count follows from inclusion–exclusion on the two points' line-pencils:
each point lies on $q+1$ lines and the two pencils share exactly one common line,
so $2(q+1) - 1 = 2q+1$ lines meet the pair and $n - (2q+1) = q^2 - q$ avoid it.
The triple counts follow similarly, the difference between the two triple types
being exactly one line, the line that a collinear triple shares.

**Coverage-time formula.** For a coverage process whose single-draw avoid
probability for the target set $A$ is $p_A$, the expected time to cover the entire
ground set is
$$E = \sum_{\varnothing \ne A \subseteq \text{points}} (-1)^{|A|+1}\,
      \frac{1}{1 - p_A}. \tag{3.1}$$
This is the standard inclusion–exclusion / max-of-geometrics identity: covering
everything means none of the points is permanently avoided, and the expected
maximum of the (dependent) per-set geometric waiting times unfolds into the signed
sum (3.1). Grouping by $k = |A|$ and writing $S_k = \sum_{|A|=k} 1/(1-p_A)$ gives
$$E = \sum_{k=1}^{n} (-1)^{k+1} S_k.$$

The Grünbaum–Yaakobi question asks whether $E_{\text{plane}} > E_{\text{uniform}}$
(the plane being *slower*) or the reverse.

## 4. The mean-matching identity

**Theorem 4.1 (mean-matching).** *For every $0 \le k \le n$, the average of the
plane avoid-probability over all $k$-element target sets equals the uniform
avoid-probability $u_k$. Equivalently, with $L = n$ lines,*
$$\frac{1}{\binom{n}{k}} \sum_{|A| = k}
   \frac{\#\{\text{lines avoiding } A\}}{n} \;=\; u_k.$$

*Proof sketch.* Both sides count, in two ways, the proportion of (line, target)
incidences in which the line avoids the target. The combinatorial heart is the
**subset-of-a-subset identity**
$$\binom{n}{k}\binom{n-k}{\,q+1\,} = \binom{n}{\,q+1\,}\binom{n-(q+1)}{k},
   \qquad k + (q+1) \le n, \tag{4.1}$$
proved by clearing factorials: both sides equal $n!/(k!\,(q+1)!\,(n-k-q-1)!)$,
the number of ways to choose a disjoint $k$-set and $(q+1)$-set from $n$ points.
Summing the avoid-counts over all $k$-sets and over all lines and dividing
appropriately reduces to (4.1) with $n - (q+1) = q^2$, yielding $u_k$ on the
right. $\square$

The identity (4.1) is the formal statement that the two mechanisms share every
marginal: averaged over targets of any fixed size, structured and uniform
sampling are indistinguishable. Consequently no difference between the mechanisms
can come from means; it must come from *spread*.

## 5. Exact agreement at orders one and two

**Theorem 5.1 (order one).** *For every point, $p_{\text{point}} = q^2/n = u_1$.
Hence $S_1$ is identical for the two mechanisms and the order-one contributions to
$E$ coincide.*

*Proof sketch.* By Lemma 2.1 each point is avoided by exactly $q^2$ lines, so
$p_{\text{point}} = q^2/n$. Meanwhile $u_1 = (n-(q+1))/n = q^2/n$. Since all
singletons are geometrically equivalent, $S_1 = n/(1 - q^2/n)$ for both
mechanisms. $\square$

**Theorem 5.2 (order two).** *For every pair of points, $p_{\text{pair}} =
(q^2-q)/n = u_2$. Hence $S_2$ is identical for the two mechanisms and the
order-two contributions to $E$ coincide.*

*Proof sketch.* The pair avoid-count is $q^2 - q$ (Section 3). For the uniform
side,
$$u_2 = \frac{q^2(q^2-1)}{n(n-1)} = \frac{q^2(q-1)(q+1)}{n\cdot q(q+1)}
      = \frac{q(q-1)}{n} = \frac{q^2 - q}{n},$$
using $n - 1 = q(q+1)$. The two agree, and since all pairs are geometrically
equivalent (any two points lie on a unique line), $S_2$ is identical. $\square$

Orders one and two contribute *equally* to $E$ for both mechanisms; in the signed
truncation they cancel exactly. The comparison therefore depends entirely on
order three and above.

## 6. The order-three divergence

### 6.1 Two triple species with a matched mean

In a projective plane, triples partition into two geometric types. A triple is
**collinear** if its three points share a common line, and **generic**
otherwise. Their counts are
$$N_{\text{coll}} = n\binom{q+1}{3}, \qquad
  N_{\text{gen}} = \binom{n}{3} - n\binom{q+1}{3},$$
with the clean factorization
$$6\,N_{\text{gen}} = n\,q^3(q+1), \tag{6.1}$$
showing that generic triples dominate. Their avoid-probabilities,
$$p_{\text{coll}} = \frac{q^2 - 2q}{n}, \qquad
  p_{\text{gen}} = \frac{(q-1)^2}{n} = \frac{q^2 - 2q + 1}{n},$$
differ by exactly $1/n$ (one line), so $p_{\text{coll}} \ne p_{\text{gen}}$ for
every $q \ge 2$.

**Theorem 6.1 (order-three mean match).** *The weighted mean of the two plane
triple avoid-probabilities equals the uniform value:*
$$\frac{N_{\text{coll}}\,p_{\text{coll}} + N_{\text{gen}}\,p_{\text{gen}}}
        {\binom{n}{3}} = u_3
   = \frac{q^2(q^2-1)(q^2-2)}{n(n-1)(n-2)}.$$

*Proof sketch.* This is the $k=3$ instance of the mean-matching identity
(Theorem 4.1), here made explicit by the two-species decomposition. The total
avoid-count over all triples is $N_{\text{coll}}(q^2-2q) + N_{\text{gen}}(q-1)^2$;
dividing by $n\binom{n}{3}$ and simplifying with (6.1) returns $u_3$. $\square$

### 6.2 Strict two-point Jensen

**Theorem 6.2 (strict two-point Jensen).** *The function $f(x) = 1/(1-x)$ is
strictly convex on $(-\infty, 1)$. Consequently, for $x, y < 1$ with $x \ne y$
and any weights $\lambda \in (0,1)$,*
$$\lambda f(x) + (1-\lambda) f(y) > f(\lambda x + (1-\lambda) y).$$

*Proof sketch.* For $x, y < 1$ a direct computation gives
$$\lambda f(x) + (1-\lambda)f(y) - f(\lambda x + (1-\lambda)y)
  = \frac{\lambda(1-\lambda)(x-y)^2}{(1-x)(1-y)\,(1-\lambda x-(1-\lambda)y)} > 0,$$
since the numerator is positive when $x \ne y$ and each factor in the denominator
is positive. $\square$

### 6.3 Order three favors the plane

**Theorem 6.3 (order-three slowness).** *For every $q \ge 2$, the order-three
contribution to $E$ is strictly larger for the plane mechanism:*
$$S_3^{\text{plane}}
   = \frac{N_{\text{coll}}}{1 - p_{\text{coll}}}
   + \frac{N_{\text{gen}}}{1 - p_{\text{gen}}}
   \;>\; \frac{\binom{n}{3}}{1 - u_3}
   = S_3^{\text{uniform}}.$$

*Proof sketch.* Write $\lambda = N_{\text{coll}}/\binom{n}{3}$ and $1 - \lambda =
N_{\text{gen}}/\binom{n}{3}$. By Theorem 6.1, $u_3 = \lambda\,p_{\text{coll}} +
(1-\lambda)\,p_{\text{gen}}$. Applying Theorem 6.2 with $x = p_{\text{coll}}$,
$y = p_{\text{gen}}$ (distinct by Section 6.1) gives
$$\lambda\,f(p_{\text{coll}}) + (1-\lambda)\,f(p_{\text{gen}}) > f(u_3).$$
Multiplying through by $\binom{n}{3}$ yields the claim. $\square$

The plane has replaced one uniform value by two genuinely different values with
the same mean; strict convexity converts the spread into a strictly larger
harmonic sum, and the positive order-three sign sends that surplus into $E$ as
extra waiting time.

## 7. Truncated slowness for every $q$

**Definition 7.1 (third-order truncation).** Let
$$E^{(3)} := S_1 - S_2 + S_3$$
denote the inclusion–exclusion sum through order three.

**Theorem 7.1 (truncated slowness).** *For every prime power $q \ge 2$,*
$$E^{(3)}_{\text{plane}} > E^{(3)}_{\text{uniform}},$$
*and in fact the gap equals the order-three surplus,
$E^{(3)}_{\text{plane}} - E^{(3)}_{\text{uniform}} = S_3^{\text{plane}} -
S_3^{\text{uniform}} > 0$.*

*Proof sketch.* By Theorems 5.1 and 5.2, $S_1$ and $S_2$ are identical for the two
mechanisms, so they cancel in the difference $E^{(3)}_{\text{plane}} -
E^{(3)}_{\text{uniform}}$. The residual is exactly $S_3^{\text{plane}} -
S_3^{\text{uniform}}$, which is strictly positive by Theorem 6.3. $\square$

This is the central rigorous result valid for *all* $q$. Numerically the surplus
is robust and increasing:

| $q$ | $n = q^2+q+1$ | $E^{(3)}_{\text{plane}} - E^{(3)}_{\text{uniform}}$ |
|----:|----:|----:|
| 2  | 7   | $\approx 0.1505$ |
| 3  | 13  | $\approx 0.6693$ |
| 4  | 21  | $\approx 1.9580$ |
| 5  | 31  | $\approx 4.5606$ |
| 7  | 57  | $\approx 16.62$ |
| 8  | 73  | $\approx 27.91$ |
| 9  | 91  | $\approx 44.16$ |
| 11 | 133 | $\approx 96.86$ |
| 13 | 183 | $\approx 186.76$ |

## 8. The all-orders statement and computational evidence

A complete proof that $E_{\text{plane}} > E_{\text{uniform}}$ (summed over all
orders $k = 1, \dots, n$) requires controlling the alternating tail of orders
$\ge 4$ so that it cannot overturn the order-three surplus. Direct exact
computation over all $2^n - 1$ nonempty target sets confirms the full inequality
for the small planes:

| $q$ | $n$ | $E_{\text{plane}}$ | $E_{\text{uniform}}$ | plane slower? |
|----:|----:|----:|----:|:--:|
| 2 | 7  | $5.43333\ldots$ | $5.42005\ldots$ | yes |
| 3 | 13 | $9.44437\ldots$ | $9.42973\ldots$ | yes |

The cases $q = 4$ and $q = 5$ are likewise confirmed by computation. The full
statement for all $q$ remains open; the obstruction is precisely the tail estimate
described in Section 9.

## 9. Discussion: variance as the slowness order parameter

The analysis isolates a single principle. Because all marginals match
(Theorem 4.1), the difference between the two mechanisms at each order $k$ is
governed not by the mean of the avoid-probabilities among $k$-sets — which is
fixed at $u_k$ — but by their *spread*. Writing $f(x) = 1/(1-x)$ and expanding $f$
around $u_k$, the per-order gap $S_k^{\text{plane}} - S_k^{\text{uniform}}$ is, to
leading order,
$$\binom{n}{k}\cdot \tfrac{1}{2} f''(u_k)\cdot \operatorname{Var}_k,$$
where $\operatorname{Var}_k$ is the variance of the plane avoid-probability across
$k$-subsets. Since $f'' > 0$, every order in which the plane has positive
incidence variance contributes positively in absolute value; orders one and two
have zero variance (homogeneity), and order three is the first with positive
variance. The remaining difficulty is purely that the inclusion–exclusion signs
alternate, so one needs the variances to decay fast enough that the order-three
term dominates the signed tail.

This reframing suggests that *incidence variance*, not mean coverage, is the
order parameter governing coverage slowness, and that **balanced** designs — which
maximize low-order regularity while forcing variance into the smallest
configurations — are the extremal slowest families among all mechanisms with
matched marginals. It inverts the design-theoretic intuition: balance, prized for
efficient covering in the worst case, makes *average* covering slow.

## 10. Applications

- **Randomized covering and testing.** When blocks are chosen from a structured
  family (e.g., a resolvable design or a code), expected coverage time can exceed
  that of unstructured sampling of the same block size; the variance principle
  quantifies the penalty.
- **Design selection.** For applications that *want* slow, evenly spread coverage
  (e.g., maximizing exploration time, fairness across targets), balanced designs
  are provably advantageous; for fast coverage, deliberately *unbalanced* block
  families with low-order variance are preferable.
- **Combinatorial probability.** The mean-matching identity gives a clean
  template for comparing any two block mechanisms with equal block size by
  reducing the comparison to incidence-variance profiles.

## 11. Future work

1. **Sign-controlled tail.** Prove that for every prime power $q$ the
   order-three surplus strictly exceeds the total signed contribution of all
   higher orders, upgrading Theorem 7.1 to the full all-orders inequality. The
   key is a geometric decay estimate: high-order configurations are
   overwhelmingly generic, so their incidence counts concentrate on the uniform
   value and the alternating tail is dominated by order three.
2. **Variance is the universal order parameter.** Among all mechanisms on $n$
   points with fixed block size $k$ whose size-$j$ marginals match uniform for
   every $j$, conjecture that expected coverage time is strictly increasing in
   the incidence-variance profile $(\operatorname{Var}_j)$, with the
   projective-plane line family extremal (slowest) by maximizing low-order
   variances.
3. **Blocking–slowness duality.** Conjecture that the designs extremal for
   *strong blocking* (every low-dimensional flat is met) coincide with those
   extremal for coverage slowness, giving a quantitative duality between a
   design's blocking strength and its cover-time excess over uniform.

## 12. Conclusion

Two block mechanisms of identical block size on the points of a finite projective
plane — one structured by the plane's lines, one uniform — are indistinguishable
in every marginal and coincide exactly through order two. They first diverge at
triples, where the plane splits one avoid-probability into a collinear and a
generic value with the same mean. Strict convexity of the harmonic weight turns
that spread into a strictly larger order-three contribution, and the
inclusion–exclusion sign sends the surplus into the expected coverage time. We
proved this third-order slowness for every prime power $q$, refining the disproof
of the Grünbaum–Yaakobi conjecture and identifying incidence variance as the true
driver of coverage slowness. The full all-orders statement reduces to a single
tail estimate, sharpening a previously open universal claim into a concrete
quantitative problem.
