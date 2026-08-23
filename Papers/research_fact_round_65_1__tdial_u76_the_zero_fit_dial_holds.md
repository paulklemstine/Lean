# Tie Geometry, Effective Bases, and Corruption Budgets for Rank-Correlation Dials

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study the attainable ceiling of Spearman's rank correlation against a
statistic with a prescribed tie structure, motivated by a measurement in which
the correlation between the trailing-zero count $T$ of a uniform $76$-bit
integer and a downstream *rate* was recorded as $\rho = 0.593, 0.618, 0.612$
across three independent runs, pooling to $\rho = 0.608$ with interval
$[0.588, 0.631]$, and reported flat within noise relative to bit-width $72$.

We prove a closed-form **$p$-adic ceiling law**: for the base-$p$ valuation
statistic on $\{0,\dots,p^b-1\}$ the maximal attainable squared Spearman
coefficient is exactly
$$\rho^2_{\max}(p,b) = \frac{3p}{p^2+p+1}\left(1+\frac{1}{p^b(p^b+1)}\right).$$
Three consequences follow. (i) **Flatness**: the dyadic ceiling changes by less
than $10^{-43}$ between bit-widths $72$ and $76$, and the recorded drop from
$0.648$ (bit-width $64$) to $0.608$ exceeds $10^{30}$ times the total ceiling
change over that range — tie granularity cannot produce any bit-width
dependence. (ii) **Exhaustion of tie mechanisms**: in the nested model,
coarsening the *response* provably raises the ceiling; and profile-free, the
**dominant-block law** $\rho^2_{\max} \ge 1 - (M^2-1)/(n^2-1)$ shows that
realising $\rho^2 \le 0.608^2$ requires a single tie class holding more than
$79\%$ of the sample, whereas the trailing-zero statistic's largest class is
exactly $50\%$, forcing $\rho^2_{\max} \ge 3/4$ at every bit-width. (iii)
**Effective base**: inverting the ceiling law, $p = 7$ is the unique integer
base whose asymptotic ceiling lies in the observed seed window, and the
continuous inverse
$\beta(r) = \big((3-r)+\sqrt{3(1-r)(3+r)}\big)/(2r)$
satisfies $\beta(7/19) = 7$ exactly and $\beta(0.608^2) \in (6.9, 7.05)$.

Finally we quantify the surviving explanation. For rank vectors we establish a
**Lipschitz law** $|\Delta\rho| \le 6|A|(n-1)^2/(n^3-n) \le 6|A|/n$ under
re-ranking on a set $A$, whose contrapositive is a **corruption budget**: a dial
move of size $\delta$ costs at least $\delta n/6$ re-ranked observations
($n/150$ for the recorded drop). The bound is sharp: an extreme transposition
moves $\rho$ by exactly $12(n-1)/(n(n+1))$. We also record the self-duality
$\pi(x) = \pi(1/x)$ of the ceiling function $\pi(x) = 3x/(x^2+x+1)$, which
identifies an effective base near $7$ with a block ratio near $1/7$.

**Keywords:** Spearman rank correlation, tie correction, $p$-adic valuation,
trailing-zero statistic, effective base, rank perturbation, corruption budget.

---

## 1. Introduction

### 1.1 The measurement

A repeated experiment records the Spearman rank correlation between two
quantities. The predictor is a *zero-count statistic*: for a uniformly drawn
integer of bit-width $b$, let $T$ be the number of trailing binary zeros. The
response is a downstream quantity referred to as the *rate*. At bit-width $76$
three independent runs produced

| run | $\rho$ |
|---|---|
| 1 | $0.593$ |
| 2 | $0.618$ |
| 3 | $0.612$ |

with pooled estimate $\rho = 0.608$, confidence interval $[0.588, 0.631]$, all
inside a pre-registered validation band $[0.55, 0.85]$. The pooled value agrees
with the arithmetic mean of the three runs to better than $10^{-3}$
($(0.593+0.618+0.612)/3 = 0.6076\overline{6}$). The predictor $T$ outperforms a
plain count statistic by $+0.073$, interval $[0.045, 0.097]$, so the advantage
is bounded away from zero. Relative to bit-width $72$ the dial is reported flat
within noise, while at bit-width $64$ the same pipeline recorded $0.648$.

### 1.2 The question

The trailing-zero statistic is extremely coarse: on $n = 2^b$ uniform draws it
places $n/2$ observations at $T = 0$, $n/4$ at $T = 1$, and so on. Rank
correlation is degraded by ties, and this degradation is a hard, response-independent
ceiling. Before interpreting $0.608$ as a fact about the process being studied,
one must ask whether it is instead a fact about the tie structure of $T$.

This paper answers that question in the negative, in three independent ways, and
in doing so extracts a new invariant of the measurement — an *effective base* of
approximately $6.97$ — together with a quantitative budget for any surviving
mechanism.

### 1.3 Contributions

1. A closed form for the tie correction of the base-$p$ valuation profile, and
   the resulting **$p$-adic ceiling law** (Theorem 3.3).
2. Monotonicity and convergence of the ceiling in the base (Theorems 3.5, 3.6).
3. The **flatness theorem** and the exclusion of tie granularity as a source of
   bit-width dependence (Theorems 4.1, 4.2).
4. **Response-granularity monotonicity** in the nested model: coarse responses
   raise the ceiling (Theorem 5.1).
5. The profile-free **dominant-block law** and its corollaries, including the
   $79\%$ concentration requirement and the $3/4$ floor for balanced statistics
   (Theorems 6.2–6.5).
6. The **effective base**: discrete uniqueness of $p = 7$ (Theorem 7.1) and the
   continuous inverse $\beta$ with its exact specification, its value at $7/19$,
   its numerical bracket at the pooled dial, and the reciprocal self-duality
   (Theorems 7.3–7.7).
7. The **rank-perturbation Lipschitz law**, the **corruption budget**, and the
   exact transposition increment establishing sharpness (Theorems 8.2–8.6).

---

## 2. Setup: tie profiles and the attainable ceiling

Throughout, $n$ denotes the sample size and all quantities are exact rationals
unless stated otherwise.

**Definition 2.1 (Tie profile).** A *tie profile* is a finite list
$L = (m_1,\dots,m_k)$ of positive integers with $\sum_j m_j = n$. It records the
sizes of the level sets of a statistic on a sample of size $n$: two observations
are tied precisely when they lie in the same block.

**Definition 2.2 (Kendall tie correction).** For a profile $L$,
$$\mathcal{T}(L) \;=\; \frac{1}{12}\sum_{j=1}^{k}\bigl(m_j^3 - m_j\bigr).$$

The normalisation is chosen so that $\mathcal{T}$ is measured in the same units
as the total rank variance $V(n) = (n^3-n)/12$ of an untied ranking of $n$
items. Note $\mathcal{T}(L) \ge 0$, with equality iff all blocks are singletons,
and $\mathcal{T}$ is additive over blocks.

**Definition 2.3 (Attainable ceiling).** For a profile $L$ with $n = \sum_j m_j
\ge 2$,
$$\sigma^2(L) \;=\; 1 - \frac{12\,\mathcal{T}(L)}{n^3-n} \;=\; 1 - \frac{\sum_j (m_j^3-m_j)}{n^3-n}.$$

The interpretation is standard: $\sigma^2(L)$ is the largest value of
$\rho^2$ attainable by *any* response ranking against a statistic with tie
profile $L$; the maximum is attained by a response that refines the profile,
i.e. that breaks every tie in a way consistent with the block ordering. The
quantity is a ratio of explained to total rank variance: tying $m$ observations
removes exactly $(m^3-m)/12$ from the available variance. In particular
$\sigma^2$ is monotone: refining a profile can only increase it.

**Lemma 2.4 (Basic bounds).** For $n \ge 2$ we have $0 \le \sigma^2(L) \le 1$,
with $\sigma^2(L) = 1$ iff $L$ consists of singletons and $\sigma^2(L) = 0$ iff
$L = (n)$.

*Proof sketch.* $\sum_j (m_j^3 - m_j) \le n^3 - n$ by superadditivity of $x
\mapsto x^3 - x$ on positive integers with fixed sum, with equality only for the
single-block profile; nonnegativity of each term gives the other bound. $\square$

We will use the identity $n^3 - n = n(n-1)(n+1) > 0$ for $n \ge 2$ repeatedly.

---

## 3. The $p$-adic ceiling law

### 3.1 The valuation profile

**Definition 3.1.** For $p \ge 2$, the *base-$p$ valuation profile* on
$\{0,1,\dots,p^b-1\}$ is
$$\Lambda(p,b) \;=\; \bigl((p-1)p^{b-1},\; (p-1)p^{b-2},\; \dots,\; (p-1)p,\; (p-1),\; 1\bigr),$$
defined recursively by $\Lambda(p,0) = (1)$ and $\Lambda(p,b+1) = \bigl((p-1)p^b\bigr)
\frown \Lambda(p,b)$.

The block $(p-1)p^{b-1-k}$ consists of the residues whose base-$p$ expansion ends
in exactly $k$ zeros; the trailing singleton is the residue $0$, whose valuation
is conventionally maximal (or infinite) and which forms a class of its own.

**Lemma 3.2 (Completeness).** $\sum \Lambda(p,b) = p^b$ for all $p \ge 1$, $b \ge 0$.

*Proof sketch.* Induction on $b$, using $(p-1)p^b + p^b = p^{b+1}$. $\square$

For $p = 2$ the profile is $(2^{b-1}, 2^{b-2}, \dots, 2, 1, 1)$, the *dyadic
profile* of the trailing-zero statistic.

### 3.2 Closed form for the tie correction

**Lemma 3.3 (Tie correction of the valuation profile).** For $p \ge 1$ and all
$b \ge 0$, writing $q = p$ and $Y = p^b$,
$$12\,(q^3-1)\,\mathcal{T}\bigl(\Lambda(p,b)\bigr) \;=\; (q-1)^3\bigl(Y^3-1\bigr) - (q^3-1)(Y-1).$$

*Proof sketch.* Induction on $b$. The base case $b = 0$ is $0 = 0$. For the
inductive step, prepending the block $(p-1)p^b$ adds $\bigl((q-1)q^b\bigr)^3 -
(q-1)q^b$ to $12\,\mathcal{T}$; multiplying by $q^3-1$ and substituting the
inductive hypothesis reduces the claim to the polynomial identity
$$(q-1)^3\bigl((qY)^3 - 1\bigr) - (q^3-1)(qY-1) = (q^3-1)\Bigl[(q-1)^3Y^3 - (q-1)Y\Bigr] + (q-1)^3(Y^3-1) - (q^3-1)(Y-1),$$
which is verified by expansion. Non-inductively, the same result is the sum of
two geometric series: $\sum_{k=0}^{b-1} \bigl((q-1)q^k\bigr)^3 = (q-1)^3
(q^{3b}-1)/(q^3-1)$ and $\sum_{k=0}^{b-1}(q-1)q^k = q^b - 1$. $\square$

### 3.3 The law

**Theorem 3.4 ($p$-adic ceiling law).** For $p \ge 2$ and $b \ge 1$,
$$\sigma^2\bigl(\Lambda(p,b)\bigr) \;=\; \pi(p)\left(1 + \frac{1}{p^b\,(p^b+1)}\right),
\qquad \pi(p) := \frac{3p}{p^2+p+1}.$$

*Proof sketch.* Write $q = p$, $Y = p^b \ge 2$. By Definition 2.3 and Lemma 3.3,
$$\sigma^2 = 1 - \frac{\bigl[(q-1)^3(Y^3-1) - (q^3-1)(Y-1)\bigr]/(q^3-1)}{Y^3-Y}.$$
Since $q^3 - 1 = (q-1)(q^2+q+1) > 0$ and $Y^3 - Y = Y(Y-1)(Y+1) \ne 0$, clearing
denominators reduces the claim to the identity
$$\bigl(Y^3-Y\bigr)(q^3-1) - (q-1)^3(Y^3-1) + (q^3-1)(Y-1)
= \frac{3q}{q^2+q+1}\Bigl(1+\frac{1}{Y(Y+1)}\Bigr)(q^3-1)(Y^3-Y),$$
which is a polynomial identity in $q$ and $Y$ after multiplying through by
$(q^2+q+1)Y(Y+1)$. The key cancellation is
$(q^3-1) - (q-1)^3 = 3q(q-1)$, which produces the factor $3q/(q^2+q+1)$. $\square$

At $p = 2$ this reads
$$\sigma^2\bigl(\Lambda(2,b)\bigr) = \frac{6}{7}\left(1+\frac{1}{2^b(2^b+1)}\right),$$
recovering the dyadic ceiling; sanity check at $b=1$: $(6/7)(1+1/6) = 1$, correct,
since $\Lambda(2,1) = (1,1)$ has no ties.

**Theorem 3.5 (Strict antitonicity in the base).** If $1 \le p < r$ then
$\pi(r) < \pi(p)$.

*Proof sketch.* $\pi(p) - \pi(r) = 3(p-r)(1 - pr)/\bigl((p^2+p+1)(r^2+r+1)\bigr)$;
for $1 \le p < r$ we have $p - r < 0$ and $1 - pr < 0$ (strictly, once $pr > 1$),
so the quotient is positive. $\square$

Thus coarser valuations attenuate more. Values of interest:
$$\pi(2) = \tfrac{6}{7} \approx 0.8571,\quad
\pi(3) = \tfrac{9}{13} \approx 0.6923,\quad
\pi(6) = \tfrac{18}{43} \approx 0.4186,\quad
\pi(7) = \tfrac{7}{19} \approx 0.3684,\quad
\pi(8) = \tfrac{24}{73} \approx 0.3288.$$

**Theorem 3.6 (Approach from above, with rate).** For $p \ge 2$, $b \ge 1$,
$$\pi(p) < \sigma^2\bigl(\Lambda(p,b)\bigr) < \pi(p) + p^{-2b}.$$

*Proof sketch.* The correction factor $1 + 1/(p^b(p^b+1))$ exceeds $1$, giving
the lower bound since $\pi(p) > 0$. For the upper bound, $\pi(p) \le 1$ and
$p^b(p^b+1) > p^{2b}$, so the excess $\pi(p)/(p^b(p^b+1))$ is below $p^{-2b}$. $\square$

The finite-size correction is therefore utterly negligible at the bit-widths of
interest: at $p=2$, $b=76$ it is below $2^{-152} \approx 1.75\times10^{-46}$.

---

## 4. Flatness: tie geometry cannot produce bit-width dependence

**Theorem 4.1 (Flatness theorem).** 
$$0 \;<\; \sigma^2\bigl(\Lambda(2,72)\bigr) - \sigma^2\bigl(\Lambda(2,76)\bigr) \;<\; 10^{-43}.$$

*Proof sketch.* By Theorem 3.4 the difference equals
$\tfrac{6}{7}\left[\tfrac{1}{2^{72}(2^{72}+1)} - \tfrac{1}{2^{76}(2^{76}+1)}\right]$,
which is positive because $x \mapsto 1/(x(x+1))$ is strictly decreasing on
$x > 0$, and is bounded above by $\tfrac{6}{7}\cdot 2^{-144} < 10^{-43}$. $\square$

Two readings of this. First, the *reported* flatness of the dial between
bit-widths $72$ and $76$ carries no information about the process: tie geometry
predicts flatness to forty-three decimal places regardless. Second, and more
usefully, any *observed* bit-width dependence is definitely not a tie effect.

**Theorem 4.2 (Exclusion of tie mechanisms, 64 to 76).**
$$10^{30}\Bigl(\sigma^2\bigl(\Lambda(2,64)\bigr) - \sigma^2\bigl(\Lambda(2,76)\bigr)\Bigr) \;<\; 0.648 - 0.608 .$$

*Proof sketch.* The left-hand bracket equals $\tfrac{6}{7}\bigl[1/(2^{64}(2^{64}+1))
- 1/(2^{76}(2^{76}+1))\bigr] < \tfrac{6}{7}\cdot 2^{-128} < 3\times10^{-39}$, so
the left side is below $3\times10^{-9}$, while the right side is $0.04$. $\square$

Note also that all recorded values lie strictly below the tie ceiling — as they
must — with room to spare: $0.618^2 = 0.3819 < 6/7$, indeed
$2 \cdot 0.618^2 < 6/7$, so the dyadic ceiling is more than a factor of two above
the observed $\rho^2$ in the *squared* scale.

---

## 5. Response granularity raises the ceiling

A natural alternative hypothesis is that the *response* is the coarse variable.
The correct model is nested: each block of the predictor's profile is further
partitioned by the response.

**Definition 5.1 (Nested profile).** A *nested profile* is a list of lists
$\mathcal{L} = (L_1, \dots, L_k)$ of positive integers. Its *coarse profile* is
$c(\mathcal{L}) = (\Sigma L_1, \dots, \Sigma L_k)$ (the predictor's tie classes)
and its *fine profile* is the concatenation $f(\mathcal{L}) = L_1 \frown \cdots
\frown L_k$ (the joint classes on which neither variable can discriminate). With
$n = \Sigma f(\mathcal{L})$ and $V = (n^3-n)/12$, the *nested coefficient* is
$$\sigma^2_{\mathrm{nest}}(\mathcal{L}) \;=\; \frac{V - \mathcal{T}\bigl(c(\mathcal{L})\bigr)}{V - \mathcal{T}\bigl(f(\mathcal{L})\bigr)}.$$

The denominator is the rank variance still available after the response's own
ties are removed; the numerator is the part of it that the predictor can explain.
When the response is a perfect refinement ($f = c$ split into singletons),
$\mathcal{T}(f) = 0$ and the definition reduces to Definition 2.3.

**Theorem 5.2 (Response-granularity monotonicity).** For every nested profile
$\mathcal{L}$ with $n \ge 2$,
$$\sigma^2\bigl(c(\mathcal{L})\bigr) \;\le\; \sigma^2_{\mathrm{nest}}(\mathcal{L}).$$

*Proof sketch.* Both sides share the numerator $A := V - \mathcal{T}(c)$, which
is nonnegative: it is exactly the residual sum of squares of the coarse profile
against the grand mean rank, hence a sum of squares. The denominators are $V$ on
the left and $B := V - \mathcal{T}(f)$ on the right. Because $f$ refines $c$ into
smaller blocks and $\mathcal{T}$ is monotone under refinement, $\mathcal{T}(f) \le
\mathcal{T}(c)$; and $\mathcal{T}(f) \ge 0$, so $0 \le B \le V$. If $B > 0$ the
claim is $A/V \le A/B$, immediate from $A \ge 0$. If $B = 0$ then
$\mathcal{T}(f) = V$, hence $\mathcal{T}(c) \ge V$ and $A \le 0$, so $A = 0$ and
both sides vanish. $\square$

The content is that response ties shrink the denominator at least as fast as they
shrink the numerator. Coarsening the response therefore cannot explain an
*attenuated* correlation; it inflates the attainable value.

**Corollary 5.3 (Response ties excluded at bit-width 76).** If the predictor's
coarse profile is the dyadic profile $\Lambda(2,76)$, then for every nested
refinement $\mathcal{L}$,
$$0.608^2 \;<\; \tfrac{6}{7} \;<\; \sigma^2_{\mathrm{nest}}(\mathcal{L}).$$

*Proof sketch.* Combine Theorem 5.2 with Theorems 3.4 and 3.6 at $p = 2$,
$b = 76$, and $0.608^2 = 0.369664 < 6/7$. $\square$

---

## 6. The dominant-block law

We now discard the specific profile altogether and bound the ceiling by one
scalar: the largest tie class.

**Lemma 6.1 (Uniform tie bound).** Let $c \ge 0$ and let $L$ be a profile with
$m^2 - 1 \le c$ for every block $m \in L$. Then $12\,\mathcal{T}(L) \le c \cdot n$
where $n = \Sigma L$.

*Proof sketch.* Induction on the list. For a single block, $m^3 - m = m(m^2-1)
\le cm$. Summing over blocks gives $\sum_j (m_j^3-m_j) \le c\sum_j m_j = cn$. $\square$

**Theorem 6.2 (Dominant-block law).** Let $L$ be a profile with $n = \Sigma L
\ge 2$ and every block at most $M \ge 1$. Then
$$\sigma^2(L) \;\ge\; 1 - \frac{M^2-1}{n^2-1}.$$

*Proof sketch.* Apply Lemma 6.1 with $c = M^2-1$: $12\,\mathcal{T}(L) \le
(M^2-1)n$. Then
$$\frac{12\mathcal{T}(L)}{n^3-n} \;\le\; \frac{(M^2-1)n}{n(n^2-1)} \;=\; \frac{M^2-1}{n^2-1},$$
and subtract from $1$. $\square$

**Corollary 6.3 (Fractional form).** If additionally $M \le n$, then
$\sigma^2(L) \ge 1 - (M/n)^2$.

*Proof sketch.* $(M^2-1)/(n^2-1) \le M^2/n^2$ is equivalent to
$n^2M^2 - n^2 \le M^2 n^2 - M^2$, i.e. $M^2 \le n^2$. $\square$

**Theorem 6.4 (Balanced statistics cannot attenuate).** If no block holds more
than half the sample ($2m \le n$ for all $m \in L$) and $n \ge 2$, then
$$\sigma^2(L) \;\ge\; \tfrac34, \qquad\text{i.e.}\qquad \rho_{\max} \ge 0.866.$$

*Proof sketch.* $2m \le n$ gives $4m^2 \le n^2$, hence $m^2 - 1 \le (n^2-1)/4$
(as $4m^2 - 4 \le n^2 - 4 \le n^2 - 1$). Apply Lemma 6.1 with $c = (n^2-1)/4$:
$12\mathcal{T}(L)/(n^3-n) \le \tfrac14$. $\square$

**Theorem 6.5 (Concentration requirement for the recorded dial).** Let $L$ be a
profile with $n \ge 2$, largest block $M \le n$, and $\sigma^2(L) \le 0.608^2$.
Then
$$M \;>\; 0.79\,n.$$

*Proof sketch.* By Corollary 6.3, $1 - (M/n)^2 \le 0.369664$, so $(M/n)^2 \ge
0.630336$ and $M/n \ge 0.79394 > 0.79$. $\square$

**Theorem 6.6 (The trailing-zero statistic is excluded at every bit-width).**
For every $b \ge 1$, each block of the dyadic profile $\Lambda(2,b)$ has size at
most $2^{b-1} = n/2$, hence
$$0.608^2 \;<\; \tfrac34 \;\le\; \sigma^2\bigl(\Lambda(2,b)\bigr).$$

*Proof sketch.* The largest block of $\Lambda(2,b)$ is the leading $2^{b-1}$,
exactly half of $n = 2^b$; by induction every other block is smaller. Apply
Theorem 6.4. Numerically $0.608^2 = 0.369664 < 0.75$. $\square$

Note that Theorem 6.6 is far weaker than the exact value $6/7 \approx 0.857$ from
Theorem 3.4, but it is *robust*: it uses no arithmetic structure at all, only
the $50\%$ balance of the largest class, and it therefore covers every variant of
the statistic, every bit-width, and every finite-sample realisation whose largest
class does not exceed half the sample.

Together, Corollary 5.3 (response side), Theorem 6.6 (predictor side, robust
form), and Theorem 4.2 (bit-width dependence) exhaust the tie-theoretic
explanations of the measurement.

---

## 7. The effective base

If the observed value is not the trailing-zero statistic's own ceiling, it is
nevertheless *some* profile's ceiling — and the ceiling law provides a
one-parameter family in which to place it.

### 7.1 Discrete inversion

**Theorem 7.1 (Effective base is exactly 7).** Let $W = [0.593^2, 0.618^2] =
[0.351649, 0.381924]$ be the squared seed window. Then $\pi(7) = 7/19 \in W$,
and for every integer $p \ge 2$ with $p \ne 7$, $\pi(p) \notin W$.

*Proof sketch.* $7/19 = 0.36842\ldots \in W$. By Theorem 3.5, $\pi$ is strictly
decreasing on integers $\ge 1$, so for $2 \le p \le 6$ we have
$\pi(p) \ge \pi(6) = 18/43 = 0.41860\ldots > 0.381924 = \sup W$, and for
$p \ge 8$ we have $\pi(p) \le \pi(8) = 24/73 = 0.32877\ldots < 0.351649 = \inf W$. $\square$

**Theorem 7.2 (The finite base-7 ceiling is also in the window).**
$\sigma^2\bigl(\Lambda(7,76)\bigr) \in W$.

*Proof sketch.* By Theorem 3.6 the value lies in $\bigl(\pi(7), \pi(7)+7^{-152}\bigr)$,
and $7^{-152} < 10^{-2}$ while $\pi(7) + 0.01 < \sup W$. $\square$

Equivalently, $\sqrt{\pi(7)} = \sqrt{7/19} = 0.60698\ldots$, against the recorded
pooled $\rho = 0.608$.

So the recorded attenuation is quantitatively what a *$7$-adic* valuation
profile would produce, and quantitatively not what a $2$-adic one produces: by
Theorem 3.4, $\sigma^2(\Lambda(2,76)) > 6/7 > 2\cdot 0.618^2$.

### 7.2 Continuous inversion

**Definition 7.3 (Effective base).** For $r \in (0,1)$,
$$\beta(r) \;=\; \frac{(3-r) + \sqrt{3(1-r)(3+r)}}{2r}.$$

This is the larger root of the quadratic $r x^2 - (3-r)x + r = 0$, whose
discriminant is $(3-r)^2 - 4r^2 = 9 - 6r - 3r^2 = 3(1-r)(3+r) \ge 0$ for
$0 < r \le 1$.

**Theorem 7.4 (Exact inversion).** For $0 < r < 1$, $\beta(r) > 1$ and
$$\pi\bigl(\beta(r)\bigr) \;=\; \frac{3\beta(r)}{\beta(r)^2 + \beta(r) + 1} \;=\; r.$$

*Proof sketch.* Positivity of the discriminant gives $\sqrt{3(1-r)(3+r)} >
\sqrt{3(1-r)\cdot 3} > 3(1-r) \ge 3 - 3r$ for $r<1$; hence the numerator exceeds
$(3-r)+(3-3r) > 2r$ (indeed $6-4r > 2r \iff r < 1$), so $\beta(r) > 1$.
Squaring the surd shows $\beta$ satisfies $r\beta^2 - (3-r)\beta + r = 0$, i.e.
$r(\beta^2+\beta+1) = 3\beta$; dividing by $\beta^2+\beta+1 > 0$ gives the claim. $\square$

**Theorem 7.5 (Calibration).** $\beta(7/19) = 7$.

*Proof sketch.* At $r = 7/19$ the discriminant is $3\cdot\frac{12}{19}\cdot
\frac{64}{19} = \bigl(\frac{48}{19}\bigr)^2$, so
$\beta = \bigl(\frac{50}{19} + \frac{48}{19}\bigr)/\frac{14}{19} = \frac{98}{14} = 7$. $\square$

**Theorem 7.6 (The pooled dial pins the base near 7).**
$$6.9 \;<\; \beta\bigl(0.608^2\bigr) \;<\; 7.05 .$$
Moreover the extreme seeds give $\beta(0.593^2), \beta(0.618^2) \in (6.6, 7.4)$.

*Proof sketch.* With $r = 0.369664$ one has $3(1-r)(3+r) = 6.37196\ldots$, so
$2.52 < \sqrt{3(1-r)(3+r)} < 2.53$; substituting into Definition 7.3 with
$2r = 0.739328$ gives $\beta \in (6.96, 6.99) \subset (6.9, 7.05)$. The seed
brackets follow the same computation with $\sqrt{\cdot} \in (2.553, 2.554)$ at
$r = 0.593^2$ (giving $\beta \approx 7.396$) and $\sqrt{\cdot} \in (2.504, 2.505)$
at $r = 0.618^2$ (giving $\beta \approx 6.706$). $\square$

Thus the discrete answer $p = 7$ of Theorem 7.1 is not an artefact of restricting
to integers: the continuous inverse sits at $\beta \approx 6.97$, within $0.5\%$
of $7$, and the full seed spread pins it to $7 \pm 0.4$.

### 7.3 Self-duality

**Theorem 7.7 (Reciprocal invariance).** For every $x > 0$,
$$\pi(x) \;=\; \pi(1/x).$$
Consequently, the two roots of $\pi(x) = r$ multiply to $1$: with $\beta(r)$ as
above and $\beta^-(r) = \bigl((3-r) - \sqrt{3(1-r)(3+r)}\bigr)/(2r)$,
$$\beta(r)\cdot\beta^-(r) \;=\; 1 .$$

*Proof sketch.* $\pi(1/x) = \frac{3/x}{1/x^2 + 1/x + 1} = \frac{3x}{1 + x + x^2}
= \pi(x)$ after multiplying numerator and denominator by $x^2$. The product of
roots of $rx^2 - (3-r)x + r = 0$ is $r/r = 1$. $\square$

This is the structural reason the inversion is quadratic, and it has an
interpretive payoff: an effective base near $7$ is *the same statement* as a
block ratio near $1/7 \approx 0.1435$. A mechanism that produces geometric tie
classes shrinking by a factor $7$ and one that produces classes growing by a
factor $7$ are indistinguishable at the level of the ceiling.

---

## 8. The corruption budget: pricing a rank-level mechanism

Sections 4–6 leave exactly one class of explanations standing: a mechanism that
acts on ranks. This section prices it.

**Definition 8.1.** For rank vectors $R, S \in \mathbb{Q}^n$,
$$D(R,S) \;=\; \sum_{i=1}^{n} (R_i - S_i)^2, \qquad
\rho(R,S) \;=\; 1 - \frac{6\,D(R,S)}{n^3-n}.$$
Call $R$ a *rank vector* if $1 \le R_i \le n$ for every $i$.

**Lemma 8.2 (Localisation).** If $S$ and $S'$ agree outside a set $A \subseteq
\{1,\dots,n\}$, then
$$D(R,S) - D(R,S') \;=\; \sum_{i \in A}\Bigl[(R_i - S_i)^2 - (R_i - S'_i)^2\Bigr].$$

*Proof sketch.* Terms outside $A$ cancel identically. $\square$

**Lemma 8.3 (Per-coordinate bound).** If $a, s, s' \in [1,n]$ then
$\bigl|(a-s)^2 - (a-s')^2\bigr| \le (n-1)^2$.

*Proof sketch.* For $a, s \in [1,n]$ we have $|a - s| \le n-1$, so each of
$(a-s)^2$ and $(a-s')^2$ lies in $[0, (n-1)^2]$; the difference of two numbers in
an interval of length $(n-1)^2$ has absolute value at most $(n-1)^2$. $\square$

**Theorem 8.4 (Rank-perturbation Lipschitz law).** Let $n \ge 2$ and let
$R, S, S'$ be rank vectors with $S = S'$ outside $A$. Then
$$\bigl|\rho(R,S) - \rho(R,S')\bigr| \;\le\; \frac{6\,|A|\,(n-1)^2}{n^3-n} \;\le\; \frac{6|A|}{n}.$$

*Proof sketch.* $\rho(R,S) - \rho(R,S') = 6\bigl(D(R,S') - D(R,S)\bigr)/(n^3-n)$;
apply Lemmas 8.2 and 8.3 and the triangle inequality to get the first bound. For
the second, $(n-1)^2/(n^3-n) = (n-1)/(n(n+1)) \le 1/n$. $\square$

**Theorem 8.5 (Corruption budget).** Under the hypotheses of Theorem 8.4, if
$\bigl|\rho(R,S) - \rho(R,S')\bigr| \ge \delta$ then
$$|A| \;\ge\; \frac{\delta\,n}{6}.$$

*Proof sketch.* Contrapositive of the second inequality in Theorem 8.4. $\square$

**Corollary 8.6 (Applied budget).** Any rank-level mechanism producing the
recorded drop $\delta = 0.648 - 0.608 = 0.04$ must re-rank at least $n/150$ of
the sample — about $0.67\%$ — a fixed positive fraction independent of $n$.

### 8.1 Sharpness

**Theorem 8.7 (Exact transposition increment).** If $S'$ is obtained from $S$ by
transposing the values at $i \ne j$, then
$$D(R,S) - D(R,S') \;=\; -2\,(R_i - R_j)(S_i - S_j).$$

*Proof sketch.* By Lemma 8.2 with $A = \{i,j\}$, the difference is
$(R_i-S_i)^2 + (R_j-S_j)^2 - (R_i-S_j)^2 - (R_j-S_i)^2$, which expands to
$-2(R_i-R_j)(S_i-S_j)$. $\square$

**Corollary 8.8 (Extremal swap).** If $R_i = S_i = 1$ and $R_j = S_j = n$, the
transposition changes $D$ by exactly $+2(n-1)^2$ and hence
$$\rho(R,S) - \rho(R,S') \;=\; \frac{12(n-1)}{n(n+1)} \;=\; \Theta(1/n).$$

*Proof sketch.* Theorem 8.7 gives $D(R,S') - D(R,S) = 2(n-1)^2$; divide by
$(n^3-n)/6 = n(n+1)(n-1)/6$. $\square$

So a single transposition already moves $\rho$ at the rate $12/n$, matching the
Lipschitz constant $6|A|/n = 12/n$ for $|A| = 2$ exactly. The budget law is
therefore not merely valid but *tight*, with the correct constant.

---

## 9. Algorithms

The results above are all effectively computable in exact arithmetic. Three
routines cover everything.

**(A) Exact ceiling from a tie profile.** Given $L = (m_1,\dots,m_k)$, compute
$n = \sum m_j$ and return $1 - \sum (m_j^3-m_j)/(n^3-n)$ as an exact rational.
Cost: $O(k)$ big-integer operations. Applied to $\Lambda(p,b)$ this validates the
closed form of Theorem 3.4 for arbitrary $p, b$ — for $b$ up to a few hundred
the numbers have thousands of digits but remain instantaneous.

**(B) Effective-base inversion.** Given an observed $\rho$, set $r = \rho^2$ and
return $\beta(r)$ by Definition 7.3, optionally rounding to the nearest integer
base and reporting the residual $|\pi(\text{round}(\beta)) - r|$. Cost: $O(1)$.
The discrete uniqueness search of Theorem 7.1 is a two-sided scan of $\pi$ over
integers, terminating after $O(1/\sqrt{r})$ steps by antitonicity — in practice
after checking the two neighbours of $\text{round}(\beta)$.

**(C) Corruption-budget certificate.** Given $n$ and a target dial move $\delta$,
return $\lceil \delta n/6 \rceil$, the minimum number of observations that must
be re-ranked. Optionally realise the move constructively by repeatedly applying
extremal transpositions, each worth $12(n-1)/(n(n+1))$ by Corollary 8.8, giving
a matching upper bound of $O(\delta n)$ transpositions.

---

## 10. Discussion

### 10.1 What has been settled

The tie-theoretic account of the bit-width-76 measurement is complete and
negative:

* the ceiling of the trailing-zero statistic is $\tfrac67\bigl(1+2^{-b}(2^b+1)^{-1}\bigr)$,
  i.e. $\rho_{\max} \ge 0.926$ at every bit-width;
* that ceiling is flat to $10^{-43}$ across the measured range, so it cannot be
  the source of the recorded $0.648 \to 0.608$ drop, which it under-predicts by
  a factor exceeding $10^{30}$;
* coarsening the response *raises* the ceiling, so response granularity is not
  merely insufficient — it has the wrong sign;
* any tie profile capable of producing $\rho^2 = 0.608^2$ needs a class holding
  $> 79\%$ of the sample, and the statistic's largest class is exactly $50\%$.

What remains is a rank-level channel, now equipped with two quantitative
fingerprints: a corruption budget of $\ge n/150$ re-ranked observations, and an
effective base of $\beta \approx 6.97$ (equivalently, by self-duality, a block
ratio $\approx 1/6.97$).

### 10.2 Interpretation of the effective base

The effective base should be read as a *summary statistic of attenuation*, not
as a claim that the underlying arithmetic is base 7. The map $\pi$ is a bijection
from $(1,\infty)$ onto $(0,1)$, so every observed $\rho^2$ has a unique effective
base; its usefulness is that it converts a dimensionless correlation into a
quantity with a mechanical interpretation — "how many equivalence classes deep is
the geometric ladder that would explain this?" — and that this quantity turned
out to be a clean $7$ rather than, say, $6.13$. The stability across seeds
($7.40$, $6.71$, and pooled $6.97$) is a genuine constraint on any candidate
mechanism.

### 10.3 Methodological remark

There is a general lesson in Theorem 4.1. A measurement's *agreement* with a
prediction is informative only when the prediction could have failed. Here the
tie model predicts flatness to $43$ decimal places; the observed flatness between
bit-widths $72$ and $76$ therefore confirms nothing. The same model's prediction
about the $64 \to 76$ change, by contrast, is falsifiable, and it is falsified by
thirty orders of magnitude. Reporting the ceiling alongside the measurement makes
the difference visible.

### 10.4 Limitations

We bound ceilings; we do not derive the observed value from a generative model.
An exact distributional model of the response would be needed to predict $0.608$
rather than merely to exclude alternatives. Second, the corruption budget is
stated for deterministic re-ranking on a fixed set; a stochastic channel requires
a concentration argument to convert the per-realisation bound into a statement
about expectations. Third, the seed window used in Theorem 7.1 is the raw spread
of three runs, not a calibrated interval; using the reported confidence interval
$[0.588, 0.631]$ instead widens the admissible base range to roughly
$(6.38, 7.55)$, which still contains no integer other than $7$.

---

## 11. Future directions

**1. Attenuation-channel realisability of the effective base.** The self-duality
$\pi(x) = \pi(1/x)$ means an effective base near $7$ is equivalent to a block
ratio near $1/7$. A Bernoulli($\theta$) rank-corruption channel applied to a
$2$-adic statistic should produce an effective base $p(\theta)$ interpolating
continuously from $2$ at $\theta = 0$. Conjecture: $p(\theta) = 2/(1-\theta)^2$
to first order, so $\theta \approx 0.47$ reproduces the observed $6.97$. The
exact one-transposition increment of Corollary 8.8 is the natural starting point;
summing independent transpositions is the next step.

**2. Sharpness of the dominant-block law for two-block profiles.** The bound
$\sigma^2 \ge 1 - (M^2-1)/(n^2-1)$ is attained exactly when the profile is
$(M,1,1,\dots,1)$. Conjecture: for every $n$ and $M$, the minimiser of $\sigma^2$
over profiles with maximal block $M$ is $(M,1,\dots,1)$, with value
$1 - (M^3-M)/(n^3-n)$. The inequality is proved; what remains is the
extremal characterisation.

**3. Generative model for the response.** Bounding ceilings is not the same as
predicting the dial. A distributional model of the rate, conditioned on the
valuation, would turn the effective base from a descriptive invariant into a
prediction.

**4. Stochastic corruption budgets.** Extend Theorem 8.5 from a fixed corrupted
set to a random one, obtaining a high-probability lower bound on the corruption
rate required for a dial move of size $\delta$.

**5. Non-geometric tie ladders.** The ceiling law covers geometric profiles. What
is the analogous closed form for polynomial or heavy-tailed class-size ladders,
and does the effective-base inversion remain well-conditioned there?

---

## 12. Conclusion

A recorded rank correlation of $0.608$ between a trailing-zero statistic and a
downstream rate at bit-width $76$ admits, we have shown, no explanation in terms
of tie geometry. The exact ceiling of the statistic is $6/7$ in $\rho^2$, flat to
$10^{-43}$ across the measured bit-widths; response coarsening moves the ceiling
upward; and no tie profile short of $79\%$ concentration can reach the observed
value, whereas the statistic tops out at $50\%$. The measurement's attenuation
instead corresponds precisely to a base-$7$ valuation ladder — uniquely so among
integers, and to within $0.5\%$ under the continuous inversion
$\beta(r) = ((3-r)+\sqrt{3(1-r)(3+r)})/(2r)$, which returns $\beta(0.608^2)
\approx 6.97$ and exactly $7$ at $r = 7/19$. Any mechanism responsible must act
at the level of ranks, and must pay a budget of at least $n/150$ re-ranked
observations to produce the recorded $0.04$ drop — a bound that a single extreme
transposition, worth exactly $12(n-1)/(n(n+1))$, shows to be tight.
