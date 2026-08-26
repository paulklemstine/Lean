# Harmonic Bulk × Steeper Edge: Window Laws, Identifiability and Saturation Rates for Discrete Power-Law Kernels

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

A recurrent difficulty in the empirical study of decaying discrete distributions is that
different *head windows* of the same dataset imply different power-law exponents: a global
fit may report a near-harmonic exponent (say $1.10$) while the leftmost cells report
something visibly steeper. We show that this discrepancy is not a fitting pathology but a
structural signature with a complete mathematical theory.

Working with the discrete kernel $p_a(k) = k^{-a}$ on $\{1,\dots,n\}$ and the head-mass
statistic $M_a(n,m) = H_a(m)/H_a(n)$, where $H_a(m) = \sum_{k \le m} k^{-a}$, we prove:
(i) a *rigidity* theorem — $a \mapsto M_a(n,m)$ is continuous and strictly increasing, so a
single head window determines the exponent uniquely, and two windows implying different
exponents refute every single power law; (ii) a **strict antitone window law** — for any
two-component mixture $q(k) = (1-w)k^{-a} + wk^{-b}$ with $0<w<1$ and $a<b$, the
window-implied exponent is *strictly decreasing in the window width*, so narrower windows
necessarily report steeper exponents; (iii) a **generalization to arbitrary exponent
heterogeneity** — the same strict law holds for any finite positive combination
$\sum_i w_i k^{-e_i}$ with at least two distinct exponents, so the phenomenon is a signature
of heterogeneity as such and not of a two-parameter model; (iv) a **falsifiability
criterion** — two distinct nested windows reporting an *equal* implied exponent certify that
the kernel is not such a mixture; (v) **weight identifiability** — with the component
exponents fixed, one head window determines the mixture weight uniquely and well-posedly;
and (vi) **saturation rates** — the head dial saturates iff $a>1$, decays like
$H(m)/\log n$ at $a=1$ (so that *squaring* the truncation only halves it), and like
$(1-a)H_a(m)\, n^{a-1}$ for $0 \le a < 1$ (so that *doubling* the truncation multiplies it
asymptotically by $2^{a-1}$).

As a quantitative instance we show that no power law with exponent at most $1.104$ can
produce an observed peak-to-second-cell ratio of $2.54$, while the explicit harmonic-bulk /
quadratic-edge mixture with $a=1$, $b=2$, $w=54/127$ reproduces it exactly, has all local
exponents strictly inside $(1,2)$, and an edge share decaying to zero.

**Keywords:** power-law kernel, head mass, monotone likelihood ratio, first-order stochastic
dominance, single crossing, log-convexity, mixture identifiability, harmonic saturation.

---

## 1. Introduction

### 1.1 The measurement problem

Consider a nonnegative weight sequence on the indices $1,2,\dots,n$ that is believed to
decay like a power of the index. Two standard summaries are in tension in practice:

* a **bulk exponent**, obtained by fitting the whole observed range; and
* an **edge-implied exponent**, obtained by asking what exponent would reproduce a head
  statistic — the mass of the first cell, the mass of the first decile, or the ratio of the
  first cell to the last.

In the motivating dataset, the bulk fit returned an exponent near $1.104$, essentially the
harmonic value, while several independent head statistics (an edge fraction, a first-decile
mass, and a peak-to-end ratio of $2.54$) each pointed to something appreciably steeper. The
practitioner's dilemma is real: the two summaries cannot both come from one power law, and
there is no principled averaging of them.

This paper resolves the dilemma structurally. We prove that the discrepancy is exactly the
observable consequence of *exponent heterogeneity*, that its direction is forced (narrow
windows must be steeper), that its magnitude is partially decodable, and that the resulting
explanation is falsifiable.

### 1.2 Contributions

1. **Rigidity of the single power law** (Section 3). The head-mass map is strictly
   increasing and continuous in the exponent, so implied exponents are well posed and a
   single power law cannot serve two windows with distinct implied exponents.
2. **Local structure of two-component kernels** (Section 4). Every local exponent of a
   bulk × edge mixture lies strictly between the component exponents; the steep component's
   share is strictly decreasing with limit $0$; and the local exponent converges to the
   bulk exponent at rate $O(k^{-(b-a)})$ with an explicit constant.
3. **The strict antitone window law** (Section 5). Narrower head windows report strictly
   steeper implied exponents, via strict log-convexity and a single-crossing argument.
4. **Universality in the number of components** (Section 6). The same law holds for any
   finite positive combination of power laws with at least two distinct exponents.
5. **Identifiability of the mixture weight** (Section 7).
6. **Saturation dichotomy and exact rates** (Section 8), with truncation-calibration
   corollaries.
7. **A quantitative instance and its exact resolution** (Section 9).

---

## 2. Setting and definitions

Throughout, $n$ denotes a *truncation* (the observed index range) and $m$ a *head window
width* with $1 \le m < n$.

> **Definition 2.1 (Power-law kernel).** For $a \in \mathbb{R}$ and $k \ge 1$ put
> $$p_a(k) = k^{-a}.$$
> The case $a=1$ is the *harmonic kernel* $k \mapsto 1/k$; $a=0$ is *equal-weight counting*.

> **Definition 2.2 (Head sum and head mass).** For $m \ge 0$,
> $$H_a(m) = \sum_{k=1}^{m} p_a(k), \qquad M_a(n,m) = \frac{H_a(m)}{H_a(n)} .$$
> $M_a(n,m)$ is the *head mass*: the fraction of the observed total weight carried by the
> window $\{1,\dots,m\}$. All head statistics used in practice — top-cell mass, first-decile
> mass, edge fraction — are instances or simple functions of $M_a(n,m)$.

> **Definition 2.3 (Implied exponent).** Given a truncation $n$, a window $m$ and an
> observed value $v$, an *implied exponent* is any $c$ with $M_c(n,m) = v$. Theorem 3.4
> shows it exists and is unique under mild conditions, so "the" implied exponent is
> legitimate.

> **Definition 2.4 (Local exponent).** For a positive sequence $f$ and $k \ge 1$,
> $$E_f(k) = \frac{\log\big(f(k)/f(k+1)\big)}{\log\big((k+1)/k\big)} ,$$
> the log–log slope of the chord between consecutive indices. Note $E_{p_a} \equiv a$.

> **Definition 2.5 (Bulk × edge mixture).** For $0 < w < 1$ and $a < b$,
> $$q_{w,a,b}(k) = (1-w)\,p_a(k) + w\,p_b(k) = (1-w)k^{-a} + w\,k^{-b} .$$
> Its head sum and head mass are written $\widetilde{H}(m)$ and $\widetilde{M}(n,m)$; note
> $\widetilde{H}(m) = (1-w)H_a(m) + wH_b(m)$.

> **Definition 2.6 (General heterogeneous kernel).** For a finite index set $S$, weights
> $w_i > 0$ and exponents $e_i$,
> $$G(k) = \sum_{i \in S} w_i\,k^{-e_i},$$
> with head sum and head mass defined analogously. The kernel is *heterogeneous* if
> $e_p \ne e_q$ for some $p,q \in S$.

---

## 3. Rigidity of the single power law

The backbone of everything below is a discrete monotone-likelihood-ratio (MLR) inequality.

> **Lemma 3.1 (MLR cross inequality).** Let $1 \le k \le j$ and $a \le b$. Then
> $$p_a(k)\,p_b(j) \le p_b(k)\,p_a(j),$$
> with strict inequality when $k < j$ and $a < b$.

*Proof sketch.* Write $p_a(k) = p_b(k)\,k^{\,b-a}$ and likewise for $j$. The claim reduces
to $k^{\,b-a} \le j^{\,b-a}$, which holds since $b-a \ge 0$ and $k \le j$, strictly when both
inequalities are strict; multiply by the positive factor $p_b(k)p_b(j)$. $\square$

> **Lemma 3.2 (Cross-product of head sums).** If $a \le b$ and $m \le n$ then
> $$H_a(m)\,H_b(n) \le H_b(m)\,H_a(n),$$
> strictly when $a < b$ and $1 \le m < n$. Equivalently, the *MLR determinant*
> $$D = H_b(m)H_a(n) - H_a(m)H_b(n)$$
> is nonnegative, and strictly positive for $a<b$, $1 \le m < n$.

*Proof sketch.* Split $H(n) = H(m) + T$ where $T = \sum_{k=m+1}^n p(k)$. After cancelling the
common term $H_a(m)H_b(m)$, the claim reduces to
$H_a(m)T_b \le H_b(m)T_a$, which is Lemma 3.1 summed over $k \in \{1,\dots,m\}$ and
$j \in \{m+1,\dots,n\}$. Every summand is strict when $a<b$, giving the strict version.
$\square$

> **Theorem 3.3 (MLR $\Rightarrow$ FOSD for head windows).** If $a \le b$ and
> $1 \le m \le n$ then $M_a(n,m) \le M_b(n,m)$; if $a < b$ and $1 \le m < n$ then
> $M_a(n,m) < M_b(n,m)$.

*Proof sketch.* Both head sums at $n$ are positive; clear denominators and apply
Lemma 3.2. $\square$

> **Theorem 3.4 (Rigidity and well-posedness).** Fix $1 \le m < n$.
> (a) If $M_a(n,m) = M_b(n,m)$ then $a=b$.
> (b) The map $a \mapsto M_a(n,m)$ is continuous. Consequently, for $a_0 \le a_1$ every value
> $v$ strictly between $M_{a_0}(n,m)$ and $M_{a_1}(n,m)$ is attained by exactly one exponent.

*Proof sketch.* (a) is trichotomy plus Theorem 3.3. For (b), $a \mapsto k^{-a} =
\exp(-a\log k)$ is continuous for $k \ge 1$, hence so is each finite head sum, and the
denominator never vanishes; existence follows from the intermediate value theorem and
uniqueness from (a). $\square$

> **Theorem 3.5 (No single power law fits two windows).** Let $1 \le m_1 < n$,
> $1 \le m_2 < n$, and suppose the two windows report implied exponents $a_1 \ne a_2$. Then
> there is no $a$ with $M_a(n,m_1) = M_{a_1}(n,m_1)$ and $M_a(n,m_2) = M_{a_2}(n,m_2)$.

*Proof sketch.* Such an $a$ would equal $a_1$ and $a_2$ by Theorem 3.4(a). $\square$

Theorem 3.5 is the exact logical shape of the recorded tension: the disagreement between the
bulk and edge readings is a *proof* that the underlying kernel is not a single power law.

We record one further consequence, which governs comparisons between weighting conventions.

> **Proposition 3.6 (Strict head bias of decaying weights).** For $a > 0$ and
> $1 \le m < n$,
> $$\frac{m}{n} < M_a(n,m).$$
> Since equal-weight counting is the degenerate exponent $a = 0$, for which $M_0(n,m) = m/n$
> exactly, an equal-weight dial and a decaying-weight dial are never directly comparable.

*Proof sketch.* The kernel is strictly decreasing, so the $m$ head terms each dominate
$p_a(m)$ and the $n-m$ tail terms are each dominated by $p_a(m)$; comparing
$H_a(m) \ge m\,p_a(m)$ with $H_a(n) - H_a(m) \le (n-m)p_a(m)$, with at least one inequality
strict, gives $H_a(m)/H_a(n) > m/n$. $\square$

---

## 4. Two-component kernels: local structure

Fix $0<w<1$, $a<b$, and write $q = q_{w,a,b}$.

> **Lemma 4.1 (Ratio bracketing).** For every $k \ge 1$,
> $$\left(\frac{k+1}{k}\right)^{a} < \frac{q(k)}{q(k+1)} < \left(\frac{k+1}{k}\right)^{b}.$$

*Proof sketch.* Both $q(k)$ and $q(k+1)$ are positive convex combinations of the two pure
kernels, and the ratio of a sum lies strictly between the ratios of the summands (a strict
mediant inequality: if $x/y < z/t$ with $y,t>0$ then $x/y < (x+z)/(y+t) < z/t$). The two
pure ratios are exactly $((k+1)/k)^a$ and $((k+1)/k)^b$, and they differ because
$a<b$. $\square$

> **Theorem 4.2 (Local exponents are strictly between the components).** For every
> $k \ge 1$,
> $$a < E_q(k) < b.$$
> In particular a bulk × edge mixture is strictly steeper than its bulk at *every* scale.

*Proof sketch.* Take logarithms in Lemma 4.1 and divide by the positive quantity
$\log((k+1)/k)$. $\square$

> **Definition/Theorem 4.3 (The steep share is an edge phenomenon).** Let
> $$s(k) = \frac{w\,p_b(k)}{q(k)}.$$
> Then for $k \ge 1$
> $$s(k) = \frac{w}{(1-w)\,k^{\,b-a} + w},$$
> which is strictly decreasing in $k$ and tends to $0$ as $k \to \infty$.

*Proof sketch.* The closed form follows from $p_a(k) = p_b(k)k^{b-a}$. Since $b>a$, the
denominator is strictly increasing and tends to $+\infty$. $\square$

> **Theorem 4.4 (Bulk recovery with rate).** For every $k \ge 1$,
> $$a < E_q(k) \le a + \frac{w}{1-w}\,(b-a)\,k^{-(b-a)} ,$$
> and hence $E_q(k) \to a$.

*Proof sketch.* Write $q(k) = p_a(k)F(k)$ with $F(k) = (1-w) + w\,k^{-(b-a)}$. Then
$$E_q(k) = a + \frac{\log\big(F(k)/F(k+1)\big)}{\log((k+1)/k)} .$$
Since $F$ is decreasing, $F(k)/F(k+1) \le 1 + \frac{w}{1-w}\big(k^{-d} - (k+1)^{-d}\big)$
with $d = b-a$; using $\log(1+x) \le x$ and the elementary bound
$k^{-d} - (k+1)^{-d} \le d\,k^{-d}\log((k+1)/k)$ (convexity of $u \mapsto u^{-d}$, or
equivalently $1 - u^{-d} \le d\log u$ for $u \ge 1$ applied to $u = (k+1)/k$) yields the
stated bound. The limit follows by squeezing with Theorem 4.2. $\square$

> **Theorem 4.5 (Head mass is a strict mediant).** For $1 \le m < n$,
> $$M_a(n,m) < \widetilde{M}(n,m) < M_b(n,m).$$
> Consequently, by Theorem 3.4, there exists $c \in (a,b)$ with $M_c(n,m) =
> \widetilde{M}(n,m)$: *every* window of a mixture reports an implied exponent strictly
> between the component exponents.

*Proof sketch.* $\widetilde{H}(m) = (1-w)H_a(m) + wH_b(m)$ and likewise at $n$, so
$\widetilde{M}$ is the mediant of $\frac{(1-w)H_a(m)}{(1-w)H_a(n)} = M_a(n,m)$ and
$\frac{wH_b(m)}{wH_b(n)} = M_b(n,m)$; these are distinct by Theorem 3.3, so the strict
mediant inequality applies. Existence of $c$ is the intermediate value theorem. $\square$

Theorems 4.2–4.5 already reconcile "steeper than the bulk" with "the bulk is harmonic": the
mixture is steeper than $a$ at every finite scale, but the excess is an edge effect that
decays at the power rate $k^{-(b-a)}$.

---

## 5. The strict antitone window law

We now explain not merely that windows report steeper exponents, but why the *narrower*
window is the steeper one. The key object is the ratio of the mixture to a pure power law.

> **Definition 5.1.** For $c \in \mathbb{R}$ set
> $$R_c(k) = \frac{q(k)}{p_c(k)} = (1-w)\,k^{\,c-a} + w\,k^{\,c-b} .$$

> **Lemma 5.2 (Strict log-convexity).** For $0<w<1$ and $a<b$, the function
> $t \mapsto R_c(e^{t})$ is strictly convex on $\mathbb{R}$. Concretely, if
> $1 \le i < j < l$ and $\log j$ is the corresponding convex combination
> $\lambda \log i + (1-\lambda)\log l$ with $\lambda \in (0,1)$, then
> $$R_c(j) < \lambda R_c(i) + (1-\lambda) R_c(l).$$

*Proof sketch.* In the variable $t = \log k$,
$R_c(e^t) = (1-w)e^{(c-a)t} + w\,e^{(c-b)t}$. Each summand is convex ($\exp$ is convex) and
strictly convex when its exponent is nonzero. Since $a<b$, the exponents $c-a$ and $c-b$
cannot both vanish, so at least one summand is strictly convex and the positive combination
is strictly convex. $\square$

> **Lemma 5.3 (Strict no-return past a crossing).** Let $\theta \in \mathbb{R}$ and suppose
> $1 \le k_1 < k_0$ satisfy $R_c(k_1) \le \theta$ and $R_c(k_0) \ge \theta$. Then
> $R_c(k) > \theta$ for every $k > k_0$.

*Proof sketch.* Suppose $R_c(k) \le \theta$ for some $k > k_0$. Then $k_0$ lies strictly
between $k_1$ and $k$ in the logarithmic variable, so strict convexity (Lemma 5.2) gives
$R_c(k_0) < \max\{R_c(k_1), R_c(k)\} \le \theta$, contradicting $R_c(k_0) \ge \theta$.
$\square$

Thus $R_c$ has a *single crossing* structure: the set where $R_c \le \theta$ is an initial
segment of indices (possibly empty), and beyond it $R_c$ stays strictly above $\theta$.

> **Theorem 5.4 (Strict single-crossing window law).** Let $0<w<1$, $a<b$, and let
> $1 \le m_1 < m_2 < n$. Suppose the pure power law with exponent $c$ matches the mixture on
> the wide window:
> $$M_c(n,m_2) = \widetilde{M}(n,m_2).$$
> Then on every narrower window it reports strictly less head mass:
> $$M_c(n,m_1) < \widetilde{M}(n,m_1).$$

*Proof sketch.* Put $\theta = \widetilde{H}(n)/H_c(n) > 0$ and define the signed discrepancy
$$d(k) = q(k) - \theta\,p_c(k) = p_c(k)\big(R_c(k) - \theta\big), \qquad k \ge 1 ,$$
and its partial sums $S(m) = \sum_{k \le m} d(k) = \widetilde{H}(m) - \theta H_c(m)$. Two
normalizations hold by construction: $S(n) = 0$ (definition of $\theta$) and $S(m_2)=0$,
the latter because matching at $m_2$ means $\widetilde{H}(m_2)/\widetilde{H}(n) =
H_c(m_2)/H_c(n)$. Subtracting, the tail sum over $\{m_2+1,\dots,n\}$ also vanishes.

By strict convexity (Lemma 5.2) the sublevel set $\{k : R_c(k) \le \theta\}$ is a *discrete
interval* $\{u, u+1, \dots, v\}$ (possibly empty), and $R_c(k) = \theta$ for at most two
indices. Hence the sign pattern of $d$ along $k = 1,2,\dots$ is: strictly positive before
$u$, nonpositive on $\{u,\dots,v\}$, strictly positive after $v$.

First, $m_2 < v$. Indeed if $m_2 \ge v$ then $d(k) > 0$ for every $k$ in the nonempty tail
$\{m_2+1,\dots,n\}$, making the tail sum strictly positive, contradicting its vanishing.

Now let $m_1 < m_2$. If $m_1 < u$ then $S(m_1)$ is a sum of strictly positive terms, so
$S(m_1) > 0$. Otherwise $\{m_1+1,\dots,m_2\} \subseteq \{u,\dots,v\}$, where $d \le 0$ with
equality only at $u$ or $v$; since $m_2 < v$, not every term in that range can vanish unless
the single index $u$ is involved, and in that case $m_1 = u-1$ falls under the previous
case. Therefore $S(m_1) \ge S(m_2) = 0$ with strict inequality, i.e. $S(m_1) > 0$.

Rewriting $S(m_1) > 0$ as $\widetilde{H}(m_1) > \theta H_c(m_1)$ and substituting $\theta$
gives $\widetilde{H}(m_1)H_c(n) > H_c(m_1)\widetilde{H}(n)$, i.e.
$M_c(n,m_1) < \widetilde{M}(n,m_1)$. $\square$

> **Theorem 5.5 (Implied exponents are strictly antitone in window width).** Let $0<w<1$,
> $a<b$, $1 \le m_1 < m_2 < n$, and let $c_1, c_2$ satisfy
> $$M_{c_1}(n,m_1) = \widetilde{M}(n,m_1), \qquad M_{c_2}(n,m_2) = \widetilde{M}(n,m_2).$$
> Then $c_2 < c_1$.

*Proof sketch.* Suppose $c_1 \le c_2$. By Theorem 3.3 (monotonicity in the exponent),
$M_{c_1}(n,m_1) \le M_{c_2}(n,m_1)$. By Theorem 5.4 applied to $c_2$,
$M_{c_2}(n,m_1) < \widetilde{M}(n,m_1) = M_{c_1}(n,m_1)$, a contradiction. $\square$

This is the promised structural mechanism: *a narrower head window necessarily reports a
steeper exponent*. A recorded bulk exponent of $1.10$ coexisting with steeper edge readings
is therefore not a contradiction but the fingerprint of a second component.

> **Corollary 5.6 (Falsifiability).** For a genuine mixture ($0<w<1$, $a<b$) and
> $1 \le m_1 < m_2 < n$, it is impossible that a single exponent $c$ satisfies
> $M_c(n,m_1) = \widetilde{M}(n,m_1)$ *and* $M_c(n,m_2) = \widetilde{M}(n,m_2)$. Two distinct
> windows reporting equal implied exponents certify that the kernel is **not** a bulk × edge
> mixture of power laws.

*Proof sketch.* Theorem 5.5 with $c_1 = c_2 = c$ would give $c<c$. $\square$

---

## 6. Universality: heterogeneity, not two-ness

Nothing in Section 5 used the number two. Let $G(k) = \sum_{i \in S} w_i k^{-e_i}$ with all
$w_i > 0$, and let $\widetilde{M}_G(n,m)$ be its head mass.

> **Lemma 6.1 (Strict log-convexity of the general ratio).** If $e_p \ne e_q$ for some
> $p,q \in S$, then $t \mapsto G(e^t)/p_c(e^t) = \sum_i w_i e^{(c-e_i)t}$ is strictly convex.

*Proof sketch.* Each summand is convex, and at least one exponent $c - e_i$ is nonzero
because the $e_i$ are not all equal; a sum of convex functions with one strictly convex
summand and positive weights is strictly convex. $\square$

> **Theorem 6.2 (Universal antitone window law).** Let $G$ be a finite positive combination
> of power laws with at least two distinct exponents, and let $1 \le m_1 < m_2 < n$. If
> $M_{c_1}(n,m_1) = \widetilde{M}_G(n,m_1)$ and $M_{c_2}(n,m_2) = \widetilde{M}_G(n,m_2)$,
> then $c_2 < c_1$.

*Proof sketch.* Lemma 6.1 replaces Lemma 5.2; the no-return lemma, the single-crossing
argument on the discrepancy $d(k) = G(k) - \theta p_c(k)$, and the monotonicity contradiction
are verbatim as in Theorems 5.4–5.5. $\square$

> **Proposition 6.3 (Faithfulness).** With $S = \{0,1\}$, weights $(1-w, w)$ and exponents
> $(a,b)$, the general kernel is exactly $q_{w,a,b}$, and Theorem 6.2 specializes to
> Theorem 5.5.

The conclusion is conceptual: the steeper-than-bulk left edge is a signature of *exponent
heterogeneity as such*. The number of mechanisms, their weights, and the size of the gaps
between their exponents affect the magnitude of the effect but never its direction.

---

## 7. Identifiability of the mixture weight

Suppose the two component exponents are pinned by external considerations (a harmonic bulk
$a$, an edge exponent $b$). How much of the mixture can be read off a single recorded head
statistic?

> **Theorem 7.1 (Strict monotonicity in the weight).** Fix $a<b$ and $1 \le m < n$. For
> $0 \le w_1 < w_2 \le 1$,
> $$\widetilde{M}_{w_1}(n,m) < \widetilde{M}_{w_2}(n,m).$$

*Proof sketch.* Write $\widetilde{M}_w(n,m) = \frac{(1-w)H_a(m)+wH_b(m)}{(1-w)H_a(n)+wH_b(n)}$.
Both denominators are positive on $[0,1]$. Clearing denominators, the difference reduces to
$(w_2 - w_1)\,D$ with $D = H_b(m)H_a(n) - H_a(m)H_b(n) > 0$ the MLR determinant of Lemma 3.2.
$\square$

> **Corollary 7.2 (Identifiability).** For $w_1,w_2 \in [0,1]$, equality of head masses on a
> single window forces $w_1 = w_2$.

> **Theorem 7.3 (Well-posed inversion).** Fix $a<b$ and $1 \le m < n$. For every
> $v \in [\,M_a(n,m),\,M_b(n,m)\,]$ there is exactly one $w \in [0,1]$ with
> $\widetilde{M}_w(n,m) = v$.

*Proof sketch.* $w \mapsto \widetilde{M}_w(n,m)$ is continuous on $[0,1]$ (positive
denominator), equals $M_a(n,m)$ at $w=0$ and $M_b(n,m)$ at $w=1$; existence is the
intermediate value theorem, uniqueness is Corollary 7.2. $\square$

Combining with Theorem 4.5, the recorded statistics become a genuine estimator: one window
fixes the weight, and the strict window law of Theorem 5.5 then *predicts* every other
window — an over-determined, testable model.

**What is not claimed.** Monotonicity in the *edge exponent* $b$ does not follow from these
arguments, and we do not assert it. Raising $b$ steepens the edge kernel but simultaneously
reduces the mass the edge component contributes; the two effects compete, and the sign of
the net effect on the head mass is not determined by the tools above. This is recorded as an
open direction rather than a result.

---

## 8. Saturation: dichotomy and exact rates

A second, independent hazard concerns *truncation*. Head statistics recorded at different
observed ranges $n$ are routinely compared as if they were the same quantity. They are not.

> **Theorem 8.1 (Saturation dichotomy).** Fix a window $m \ge 1$ and let $n \to \infty$.
> (a) If $a > 1$ then $M_a(n,m) \to H_a(m)/\sum_{k \ge 1} k^{-a} > 0$: the dial saturates at
> a strictly positive limit.
> (b) If $a \le 1$ then $M_a(n,m) \to 0$: the dial does not saturate.

*Proof sketch.* (a) For $a>1$ the series converges with strictly positive sum, and
$H_a(n) \to \sum_k k^{-a}$; divide. (b) For $a \le 1$ we have $k^{-a} \ge 1/k$ for $k\ge1$,
so $H_a(n)$ dominates the harmonic numbers and diverges, while the numerator is fixed.
$\square$

So *saturation is a strictly super-harmonic phenomenon*. But the dichotomy is silent about
rates, and rates are where the practical error lives.

> **Theorem 8.2 (Logarithmic rate at the harmonic threshold).** For any fixed $m$,
> $$M_1(n,m)\cdot \log n \;\longrightarrow\; H(m) := \sum_{k=1}^{m}\frac1k \qquad (n \to \infty),$$
> and non-asymptotically, for every $n \ge 1$,
> $$\frac{H(m)}{1+\log n} \;\le\; M_1(n,m).$$

*Proof sketch.* At $a=1$ the head sum is the harmonic number, and
$\log(n+1) \le H(n) \le 1 + \log n$, whence $\log n / H(n) \to 1$. Then
$M_1(n,m)\log n = H(m)\cdot \frac{\log n}{H(n)}$. The lower bound is the upper harmonic
bound rearranged. $\square$

> **Corollary 8.3 (Squaring only halves the harmonic dial).** For $m \ge 1$,
> $$\frac{M_1(n^2,m)}{M_1(n,m)} \;\longrightarrow\; \frac12 .$$

*Proof sketch.* Factor the ratio as
$\frac{H(n)}{\log n}\cdot\frac{\log n}{\log n^2}\cdot\frac{\log n^2}{H(n^2)}$; the outer
factors tend to $1$ and the middle one is identically $1/2$ for $n \ge 2$. $\square$

Corollary 8.3 is the interpretive payload: a dial that must have its truncation *squared*
before it falls by a factor of two is, over any bounded experimental range, numerically
indistinguishable from a saturating dial — while in truth having limit $0$. An observed
"saturation by $n = 400$" of a $1/k$-weighted statistic is therefore quantitatively
consistent with a non-saturating harmonic dial and cannot be used to infer $a>1$.

Below the harmonic threshold the collapse is polynomial, with an exact constant.

> **Theorem 8.4 (Sum–integral sandwich).** For $0 \le a < 1$ and $n \ge 1$,
> $$\frac{(n+1)^{1-a}-1}{1-a} \;\le\; H_a(n) \;\le\; 1 + \frac{n^{1-a}-1}{1-a}.$$

*Proof sketch.* The map $x \mapsto x^{-a}$ is antitone on $[1,\infty)$; compare the sum with
$\int_1^{n+1} x^{-a}\,dx$ from below and, after removing the first term, with
$\int_1^{n} x^{-a}\,dx$ from above. $\square$

> **Corollary 8.5.** For $0 \le a < 1$, $\;H_a(n)/n^{1-a} \to 1/(1-a)$.

> **Theorem 8.6 (Sub-harmonic saturation rate).** For $0 \le a < 1$ and fixed $m$,
> $$M_a(n,m)\cdot n^{1-a} \;\longrightarrow\; (1-a)\,H_a(m).$$

*Proof sketch.* $M_a(n,m)n^{1-a} = H_a(m) \big/ \big(H_a(n)/n^{1-a}\big)$; apply
Corollary 8.5. $\square$

> **Corollary 8.7 (Doubling calibration).** For $0 \le a < 1$ and $m \ge 1$,
> $$\frac{M_a(2n,m)}{M_a(n,m)} \;\longrightarrow\; 2^{\,a-1} < 1 .$$
> At $a = 1$ doubling is asymptotically neutral (by Theorem 8.2, the ratio tends to $1$),
> and a positive limit under repeated doubling forces $a > 1$.

Together, Theorems 8.2–8.6 fix the truncation artifact for every $a \le 1$: the recorded
level scales like $n^{a-1}$ below harmonic, like $1/\log n$ at harmonic, and stabilizes only
above harmonic. Dials taken at different truncations become comparable once rescaled
accordingly.

Finally, recall Proposition 3.6: an equal-weight dial ($a=0$) reads exactly $m/n$, and any
decaying weight reads strictly more. Movement of a head window attributed to a change in the
phenomenon can therefore be manufactured purely by switching between equal-weight counting
and $1/k$-weighted counting.

---

## 9. A quantitative instance and its exact resolution

We close the loop on the motivating numbers.

> **Proposition 9.1 (The tension is arithmetic).** For a pure power law the peak-to-second
> cell ratio is $p_a(1)/p_a(2) = 2^{a}$. If $a \le 1.104$, then
> $$\frac{p_a(1)}{p_a(2)} < 2.54 .$$

*Proof sketch.* Monotonicity of $a \mapsto 2^a$ gives $2^a \le 2^{1.104} \le 2^{9/8} =
2\cdot 2^{1/8}$, and $2^{1/8} < 1.27$ because $1.27^8 > 2$. Hence $2^a < 2.54$. $\square$

So no power law respecting the fitted bulk exponent reproduces the recorded peak/end ratio
$2.54$ — the tension between the bulk fit and the edge statistic is genuine, not a
consequence of estimator choice.

> **Proposition 9.2 (Exact resolution by a harmonic-bulk / quadratic-edge kernel).** Let
> $a=1$, $b=2$, $w = 54/127$. Then
> $$\frac{q(1)}{q(2)} = 2.54 \quad\text{exactly}.$$

*Proof sketch.* $q(1) = (1-w)\cdot 1 + w \cdot 1 = 1$ and
$q(2) = \frac{73}{127}\cdot\frac12 + \frac{54}{127}\cdot\frac14 = \frac{146+54}{508} =
\frac{50}{127}$, so the ratio is $127/50 = 2.54$. $\square$

> **Proposition 9.3 (The resolving kernel is genuinely two-component).** For $a=1$, $b=2$,
> $w=54/127$: every local exponent satisfies $1 < E_q(k) < 2$; the steep share $s(k)$ is
> strictly decreasing with $s(k) \to 0$; every head window reports an implied exponent
> strictly inside $(1,2)$; and for nested windows $m_1 < m_2 < n$ the implied exponents
> satisfy $c_2 < c_1$ strictly.

*Proof sketch.* Instantiate Theorems 4.2, 4.3, 4.5 and 5.5. $\square$

Thus the harmonic bulk survives intact — it is the $k \to \infty$ limit of the local
exponent and governs the body of the kernel — while the recorded edge statistics are
reproduced exactly by an edge component whose influence decays like $k^{-1}$ in this
instance.

---

## 10. Algorithms

The theory yields four immediately implementable procedures.

**A. Implied-exponent inversion.** Given $n$, $m$, and an observed head mass $v$, solve
$M_c(n,m) = v$ for $c$. Because $c \mapsto M_c(n,m)$ is continuous and strictly increasing
(Theorems 3.3–3.4), bisection on a bracketing interval converges monotonically and the root
is unique. Cost: $O(n)$ per evaluation, $O(n\log(1/\varepsilon))$ overall.

**B. Heterogeneity test.** Compute implied exponents $c_1, c_2$ for two nested windows
$m_1 < m_2$. If $c_1 = c_2$ (within tolerance), no heterogeneous kernel of the class above
explains the data (Corollary 5.6). If $c_1 > c_2$, the sign is consistent with heterogeneity
(Theorem 5.5). If $c_1 < c_2$, mixture explanations are refuted in that direction.

**C. Weight recovery.** With component exponents $a<b$ fixed and one head statistic $v \in
[M_a(n,m), M_b(n,m)]$, bisect $w \mapsto \widetilde{M}_w(n,m)$ on $[0,1]$; the solution
exists and is unique (Theorem 7.3). The remaining windows then serve as out-of-sample
predictions.

**D. Truncation calibration.** Given a dial recorded at truncation $n$ and an exponent
regime, rescale: multiply by $\log n$ at $a=1$ (Theorem 8.2), by $n^{1-a}$ for $0 \le a < 1$
(Theorem 8.6), and leave unchanged for $a > 1$. Equivalently, use the doubling ratio
$2^{a-1}$ (Corollary 8.7) as a diagnostic for which regime the dial is in.

---

## 11. Applications and discussion

**Reconciling conflicting exponent fits.** The immediate application is diagnostic. Where
practice offers "average the two numbers" or "discard the edge", the theory offers a third
option: treat the discrepancy as a measurement of heterogeneity, check its *direction* (the
narrow window must be steeper), and — with the component scales fixed — invert one window for
the weight and use the rest as tests.

**Where the results apply.** Nothing in the development is specific to the motivating
dataset. The hypotheses are that the weights on $\{1,\dots,n\}$ are a finite positive
combination of power laws with at least two distinct exponents. This covers, among others,
rank-size data with two generating mechanisms, hitting-time statistics with a fast and a slow
channel, and any smooth kernel well approximated on the observed range by such a combination.

**Methodological consequences.**
1. *Two windows are strictly more informative than one.* One window gives an exponent;
   two give an exponent plus a falsifiable heterogeneity verdict.
2. *Never compare dials taken at different truncations without rescaling.* Section 8 makes
   the required rescaling explicit and exact.
3. *Never compare equal-weight and decaying-weight dials.* Proposition 3.6 shows they differ
   systematically for reasons unrelated to the phenomenon studied.
4. *Apparent saturation is weak evidence.* Only a positive limit under repeated *squaring*
   (not doubling) is evidence for a super-harmonic exponent.

**Limitations.** The window law is a statement about exact head masses of a deterministic
kernel; sampling noise is not modelled here, so in practice the strict inequality $c_2 < c_1$
must be assessed against an uncertainty estimate. The monotonicity of the head mass in the
edge exponent $b$ is genuinely open (Section 7). Finally, the class treated is finite
positive combinations of pure powers; continuous mixtures over an exponent measure are not
covered by the finite-sum argument, though the strict log-convexity input plainly persists.

---

## 12. Future directions

* **Continuous exponent mixtures.** Replace $\sum_i w_i k^{-e_i}$ by $\int k^{-e}\,d\mu(e)$
  for a finite positive measure $\mu$ with non-degenerate support. Strict log-convexity of
  $t \mapsto \int e^{(c-e)t}d\mu(e)$ should hold whenever $\mu$ is not a point mass,
  suggesting that the antitone window law is a property of *any* non-degenerate exponent
  spectrum.
* **Monotonicity in the edge exponent.** Determine the sign of
  $\partial_b \widetilde{M}_{w,a,b}(n,m)$, or produce a counterexample; this is the missing
  coordinate for full identifiability of the pair $(w,b)$.
* **Quantitative window law.** Theorem 5.5 gives a strict inequality; a lower bound on
  $c_1 - c_2$ in terms of $w$, $b-a$ and $m_2/m_1$ would turn the qualitative diagnostic into
  a calibrated estimator of the gap.
* **Noise model.** Combine the deterministic window law with a sampling model to obtain a
  hypothesis test with controlled error rates for "the kernel is heterogeneous".
* **Rates at and above the harmonic threshold.** Section 8 supplies exact rates for
  $a \le 1$; the corresponding second-order expansion of $M_a(n,m)$ for $a>1$ (the rate at
  which the saturating dial approaches its limit) would complete the calibration table.

---

## 13. Summary of results

| Result | Statement |
|---|---|
| Monotonicity (Thm 3.3) | $a<b \Rightarrow M_a(n,m) < M_b(n,m)$ for $1 \le m<n$ |
| Rigidity (Thm 3.4) | One window determines the exponent; inversion is well posed |
| No-fit (Thm 3.5) | Two windows with distinct implied exponents refute every single power law |
| Head bias (Prop 3.6) | $M_a(n,m) > m/n$ for $a>0$; equal weighting gives exactly $m/n$ |
| Local bracketing (Thm 4.2) | $a < E_q(k) < b$ for every $k$ |
| Edge decay (Thm 4.3, 4.4) | $s(k)\downarrow 0$; $E_q(k) \le a + \frac{w}{1-w}(b-a)k^{-(b-a)} \to a$ |
| Mediant (Thm 4.5) | $M_a(n,m) < \widetilde M(n,m) < M_b(n,m)$; implied exponent in $(a,b)$ |
| **Window law (Thm 5.5)** | Nested windows $m_1<m_2$ give implied exponents $c_2 < c_1$ strictly |
| Falsifiability (Cor 5.6) | Equal implied exponents on two windows refute the mixture class |
| Universality (Thm 6.2) | Same law for any finite positive combination with $\ge 2$ distinct exponents |
| Identifiability (Thm 7.1–7.3) | Head mass is strictly increasing in $w$; unique $w$ per achievable value |
| Dichotomy (Thm 8.1) | Dial saturates iff $a>1$ |
| Harmonic rate (Thm 8.2, Cor 8.3) | $M_1(n,m)\log n \to H(m)$; squaring $n$ halves the dial |
| Sub-harmonic rate (Thm 8.6, Cor 8.7) | $M_a(n,m)n^{1-a} \to (1-a)H_a(m)$; doubling scales by $2^{a-1}$ |
| Instance (Prop 9.1–9.3) | No $a \le 1.104$ gives peak/end $2.54$; $(a,b,w)=(1,2,54/127)$ gives it exactly |
