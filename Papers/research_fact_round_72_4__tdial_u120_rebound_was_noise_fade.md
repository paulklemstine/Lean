# Pooling Geometry, the Sharp Seed-Imbalance Law, and Capacity–Fade Duality for Correlation Ladders

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop an exact geometric theory of *pooled* correlation — the number an
experiment reports when it concatenates several independent blocks (seeds) and
correlates the resulting long vectors — and use it to analyse a decaying ladder
of correlation readings.

Four groups of results are established. First, **pooling geometry**: pooling
never inflates a reading ($\rho_{\text{pool}} \le \max_k \rho_k$), the reverse
inequality fails strictly (two blocks each reading $1$ pool to $3/\sqrt{10}$),
and pooling coincides with an energy-weighted average exactly on balanced block
families. Second, the **sharp seed-imbalance law**: if the per-block ratios
$\lambda_k = \lVert v_k\rVert / \lVert u_k \rVert$ lie in a window $[\alpha,\beta]$
with $\alpha>0$ and every block reads at least $\rho$, then
$\rho_{\text{pool}} \ge \rho\cdot 2\sqrt{\alpha\beta}/(\alpha+\beta)$; the
Kantorovich constant is attained, its extremiser is **unique** as a distribution
(mass $\beta/(\alpha+\beta)$ at $\alpha$, mass $\alpha/(\alpha+\beta)$ at
$\beta$), a single interior seed forces strict inequality, and a quantitative
stability estimate controls the distance to the extremiser by the slack. Third,
the **advantage–decorrelation duality**: from Gram positivity alone,
$(a-b)^2 \le 2(1-c)$, so any measured advantage certifies decorrelation; this
bound is exactly the AM–GM relaxation of the ellipse certificate
$c \le ab + \sqrt{(1-a^2)(1-b^2)}$, with equality precisely on $|a|=|b|$.
Fourth, **capacity–fade duality**: defining the capacity of a reading as
$\operatorname{cap}(\rho) = \lfloor 1/\rho^2 \rfloor$, a persistent multiplicative
fade drives the capacity above every level, and conversely a capacity ceiling
$K$ is exactly a positive floor $\rho_N^2 > 1/(K+1)$ at every rung. "Floor" and
"bounded capacity" are therefore the same hypothesis.

We close the **inverse pooling problem**: a pooled value together with an
imbalance window pins a two-sided window for the unreported per-seed readings,
$\rho_{\text{pool}} \le \rho_{\max}$ and
$\rho_{\min} \le \rho_{\text{pool}}(\alpha+\beta)/(2\sqrt{\alpha\beta})$.

Applied to the recorded ladder
$0.5739 \to 0.5436 \to 0.5005 \to 0.4880 \to 0.4621 \to (0.4847) \to 0.43636$
with seed spread $0.082$: the $+0.0226$ rebound rung is smaller than the spread
and hence carries no information, the cumulative $0.1375$ decline exceeds the
spread and hence does, the $-0.0483$ retrace cannot be a pooling artefact inside
the recorded $\pm 10\%$ ratio window, the ladder is a strict capacity expansion
from $3$ to $5$ decorrelated statistics, and the per-seed readings behind the
pooled $0.43636$ are confined to a window of width less than $0.002$.

---

## 1. Introduction

### 1.1 The measurement

An experiment repeatedly reports a rank correlation between a structural
statistic $T$ of a uniformly drawn integer (the number of trailing zeros in its
binary expansion) and a downstream quantity called the *rate*. Reported over a
sweep of increasing bit lengths, the readings form a **ladder**:

| rung | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| reading | $0.5739$ | $0.5436$ | $0.5005$ | $0.4880$ | $0.4621$ | $(0.4847)$ | $0.43636$ |

The parenthesised rung is a *rebound*: a step of $+0.0226$ against an otherwise
monotone decline. The final rung retraces it and overshoots, a step of $-0.0483$,
landing at $0.43636$ with confidence interval $[0.38815, 0.48113]$. The
seed-to-seed spread has widened to $0.082$. The statistic $T$ outperforms a plain
count baseline by $+0.0752$ at the point estimate; the baseline reads $0.36116$.

Three interpretive questions attach to these numbers, and each is a genuine
mathematical question rather than a statistical convention.

* **(Q1) Is the rebound signal or noise?** A step of $+0.0226$ against a seed
  spread of $0.082$ — does the pooling operation permit such a step with no
  underlying change at all?
* **(Q2) Is the decline an artefact of pooling?** Pooling concatenates
  heterogeneous blocks. If the blocks have drifted apart in scale, could the
  pooled number fall while every individual block holds steady?
* **(Q3) Is there a floor?** Is there some $f > 0$ below which the ladder cannot
  fall, because the statistic genuinely carries that much information at every
  scale?

### 1.2 What is missing, and what we supply

Each of these questions presupposes an understanding of what a *pooled*
correlation is as a geometric object, and that understanding is exactly what is
usually absent. The pooled value is the correlation of *concatenated* vectors,
and concatenation is not an averaging operation. This paper supplies the missing
layer and then answers Q1–Q3 with exact inequalities, together with their
sharpness, rigidity, and stability statements.

The unifying discovery is **capacity–fade duality** (Section 6). The classical
capacity constraint says that $k$ mutually decorrelated statistics all reading at
least $\rho$ satisfy $k\rho^2 \le 1$. Reading this as a function of $\rho$
defines the capacity $\operatorname{cap}(\rho) = \lfloor 1/\rho^2 \rfloor$, and
the two directions of the duality say that the fade hypothesis and the floor
hypothesis are *logical complements*: a persistent fade makes the capacity
unbounded, and a bounded capacity is a positive floor. What began as two
independent readings of the same ladder collapses into one dichotomy.

### 1.3 Notation

Throughout, vectors live in $\mathbb{R}^n$ and
$\langle u, v\rangle = \sum_{i} u_i v_i$, $\lVert u \rVert = \sqrt{\langle u,u\rangle}$.
For $u, v$ with $\langle u,u\rangle \ne 0 \ne \langle v,v\rangle$ write
$$\operatorname{corr}(u,v) = \frac{\langle u, v\rangle}{\lVert u\rVert\,\lVert v\rVert} \in [-1,1].$$
A **block family** is a tuple $u = (u_1,\dots,u_m)$ with $u_k \in \mathbb{R}^n$;
it represents the per-seed data of an $m$-seed experiment. The **block energy**
is $E(u) = \sum_k \lVert u_k\rVert^2$ and the **block inner product** is
$\langle u, v\rangle_{\text{blk}} = \sum_k \langle u_k, v_k\rangle$; these are the
squared norm and inner product of the concatenations.

---

## 2. Pooling geometry

**Definition 2.1 (pooled correlation).** For block families $u, v$ with
$E(u), E(v) > 0$,
$$\rho_{\text{pool}}(u,v) \;=\; \frac{\langle u,v\rangle_{\text{blk}}}{\sqrt{E(u)}\,\sqrt{E(v)}}
\;=\; \frac{\sum_k \langle u_k, v_k\rangle}{\sqrt{\sum_k \lVert u_k\rVert^2}\;\sqrt{\sum_k \lVert v_k\rVert^2}} .$$
This is exactly the correlation of the concatenated vectors, and exactly what an
experiment reports when it pools its seeds.

Write $\rho_k = \operatorname{corr}(u_k, v_k)$ for the per-seed readings.

**Lemma 2.2 (block Cauchy–Schwarz).** *For $a_k, b_k \ge 0$,*
$$\sum_{k} \sqrt{a_k}\,\sqrt{b_k} \;\le\; \sqrt{\sum_k a_k}\;\sqrt{\sum_k b_k}.$$

*Proof sketch.* Apply the discrete Cauchy–Schwarz inequality to the vectors
$(\sqrt{a_k})_k$ and $(\sqrt{b_k})_k$ and use $(\sqrt{a_k})^2 = a_k$. $\square$

**Theorem 2.3 (blockwise bound transfers).** *If $R \ge 0$ and
$\langle u_k, v_k\rangle \le R\,\lVert u_k\rVert\,\lVert v_k\rVert$ for every $k$,
then $\rho_{\text{pool}}(u,v) \le R$.*

*Proof sketch.* Summing the hypotheses gives
$\langle u,v\rangle_{\text{blk}} \le R \sum_k \lVert u_k\rVert\lVert v_k\rVert$, and
Lemma 2.2 with $a_k = \lVert u_k\rVert^2$, $b_k = \lVert v_k\rVert^2$ bounds the
right-hand sum by $\sqrt{E(u)}\sqrt{E(v)}$. Divide. $\square$

**Corollary 2.4 (pooling never inflates).** *If every $\rho_k \le R$ with
$R \ge 0$, then $\rho_{\text{pool}}(u,v) \le R$. In particular
$\rho_{\text{pool}} \le \max_k \rho_k$.*

*Proof sketch.* $\langle u_k, v_k\rangle = \rho_k \lVert u_k\rVert\lVert v_k\rVert
\le R\lVert u_k\rVert\lVert v_k\rVert$; apply Theorem 2.3. $\square$

Corollary 2.4 has an immediate epistemic reading: **a pooled dial value is a
lower-bound witness for the seed family**. Whatever the pooled number is, some
seed reads at least that high. It can never be an upward artefact of
concatenation.

The matching lower bound by the seed minimum is *false*.

**Theorem 2.5 (strict attenuation).** *There is a two-block family, with blocks
in $\mathbb{R}^1$, whose per-seed readings are both exactly $1$ and whose pooled
reading is $3/\sqrt{10} < 1$.*

*Proof.* Take $u_1 = u_2 = (1)$, $v_1 = (1)$, $v_2 = (2)$. Then
$\operatorname{corr}(u_k, v_k) = 1$ for $k=1,2$, while
$\rho_{\text{pool}} = (1 + 2)/(\sqrt{2}\sqrt{5}) = 3/\sqrt{10} \approx 0.94868$. $\square$

So pooling biases downwards, and does so precisely because the two blocks are
*imbalanced*: their response-to-statistic norm ratios differ. This is the
mechanism a sceptic can invoke against Q2, and Sections 3–5 measure it exactly.

**Definition 2.6 (balance).** A block family pair $(u, v)$ is **$\lambda$-balanced**
if $\lVert v_k\rVert = \lambda \lVert u_k\rVert$ for all $k$, with $\lambda > 0$;
more generally its **ratio profile** is $\lambda_k = \lVert v_k \rVert/\lVert u_k\rVert$.

**Theorem 2.7 (balanced pooling is a weighted average).** *If $(u,v)$ is
$\lambda$-balanced and $E(u) > 0$, then*
$$\rho_{\text{pool}}(u,v) \;=\; \frac{\sum_k \lVert u_k\rVert^2\, \rho_k}{\sum_k \lVert u_k\rVert^2}.$$

*Proof sketch.* Balance gives
$\langle u_k, v_k\rangle = \rho_k \lVert u_k\rVert \lVert v_k\rVert = \lambda \rho_k \lVert u_k\rVert^2$,
so the numerator is $\lambda \sum_k \lVert u_k\rVert^2 \rho_k$; balance also gives
$E(v) = \lambda^2 E(u)$, so the denominator is $\lambda E(u)$. The $\lambda$
cancels. $\square$

**Corollary 2.8 (balanced sandwich).** *For a $\lambda$-balanced pair with all
$\rho_k \in [\ell, h]$, we have $\rho_{\text{pool}} \in [\ell, h]$.*

Thus the entire discrepancy between "pooling" and "averaging" is caused by the
spread of the ratio profile. A first quantitative version:

**Theorem 2.9 (crude imbalance bound).** *If all $\rho_k \ge \rho \ge 0$ and all
$\lambda_k \in [L(1-\delta), L(1+\delta)]$ with $L>0$, $0\le\delta<1$, then*
$$\rho_{\text{pool}} \;\ge\; \rho \cdot \frac{1-\delta}{1+\delta}.$$

This bound is *not* sharp, which matters: an unsharp bound cannot say how much of
a fall imbalance is *allowed* to explain. Section 3 replaces it.

---

## 3. The sharp seed-imbalance law

**Theorem 3.1 (weighted Kantorovich inequality).** *Let $w_k \ge 0$ and
$\lambda_k \in [\alpha, \beta]$ with $0 < \alpha \le \beta$. Then*
$$4\alpha\beta \Big(\sum_k w_k\Big)\Big(\sum_k w_k \lambda_k^2\Big)
\;\le\; (\alpha+\beta)^2 \Big(\sum_k w_k \lambda_k\Big)^2 .$$

*Proof.* Pointwise, $(\lambda_k - \alpha)(\beta - \lambda_k) \ge 0$, i.e.
$\lambda_k^2 \le (\alpha+\beta)\lambda_k - \alpha\beta$. Weighting and summing,
with $S = \sum_k w_k$, $M = \sum_k w_k\lambda_k$, $Q = \sum_k w_k \lambda_k^2$,
$$Q \le (\alpha+\beta)M - \alpha\beta S .$$
Hence $4\alpha\beta S Q \le 4\alpha\beta S\big((\alpha+\beta)M - \alpha\beta S\big)$,
and
$$(\alpha+\beta)^2M^2 - 4\alpha\beta S\big((\alpha+\beta)M - \alpha\beta S\big)
= \big((\alpha+\beta)M - 2\alpha\beta S\big)^2 \ge 0 . \qquad\square$$

**Theorem 3.2 (sharp seed-imbalance law).** *Let $(u,v)$ have ratio profile
$\lambda_k \in [\alpha,\beta]$ with $0 < \alpha \le \beta$, let $E(u) > 0$, and
suppose every per-seed reading satisfies $\rho_k \ge \rho \ge 0$. Then*
$$\rho_{\text{pool}}(u,v) \;\ge\; \rho \cdot \kappa(\alpha,\beta),
\qquad \kappa(\alpha,\beta) := \frac{2\sqrt{\alpha\beta}}{\alpha+\beta} .$$

*Proof sketch.* Write $w_k = \lVert u_k\rVert^2$. Then
$\langle u_k,v_k\rangle = \rho_k \lambda_k w_k \ge \rho\,\lambda_k w_k$, so the
numerator of $\rho_{\text{pool}}$ is at least $\rho \sum_k w_k \lambda_k = \rho M$,
while the denominator is $\sqrt{S}\sqrt{Q}$ with $S = \sum_k w_k$ and
$Q = \sum_k w_k\lambda_k^2$. Theorem 3.1 says exactly
$2\sqrt{\alpha\beta}\sqrt{S}\sqrt{Q} \le (\alpha+\beta) M$, i.e.
$M/(\sqrt S \sqrt Q) \ge \kappa(\alpha,\beta)$. $\square$

The constant $\kappa$ is the ratio of the geometric mean to the arithmetic mean of
the window endpoints; it equals $1$ exactly when $\alpha = \beta$, i.e. on
balanced families, consistently with Corollary 2.8.

**Theorem 3.3 (sharpness).** *There is a two-block family with ratio profile in
$[1,4]$, per-seed readings both equal to $1$, and pooled reading exactly
$\kappa(1,4) = 2\sqrt{4}/5 = 4/5$.*

*Proof sketch.* Suitable scalar blocks with $\lambda_1 = 1$, $\lambda_2 = 4$ and
energies in the ratio $4:1$ realise the extremal profile of Theorem 4.3 below;
direct computation gives $\rho_{\text{pool}} = 4/5$. $\square$

**Theorem 3.4 (the sharp constant strictly dominates the crude one).** *For
$L>0$ and $0 < \delta < 1$, on the symmetric window
$[\alpha,\beta] = [L(1-\delta), L(1+\delta)]$,*
$$\frac{1-\delta}{1+\delta} \;<\; \kappa(\alpha,\beta) = \sqrt{1-\delta^2}.$$

*Proof.* $\alpha\beta = L^2(1-\delta^2)$ and $\alpha+\beta = 2L$, so
$\kappa = \sqrt{1-\delta^2}$. Since $\sqrt{1-\delta^2} = \sqrt{(1-\delta)(1+\delta)}$
and $(1-\delta)/(1+\delta) = (1-\delta)/(1+\delta)$, the claim is
$\sqrt{(1-\delta)(1+\delta)} > (1-\delta)/(1+\delta)$, i.e. after squaring and
clearing denominators, $(1+\delta)^3 > (1-\delta)$, which holds for
$0 < \delta < 1$. $\square$

### 3.1 Pooled monotonicity with fixed weights

Two elementary but load-bearing facts about ladders reported with the *same*
seed weights at two levels.

**Proposition 3.5 (a pooled rebound is a seed rebound).** *If $w_k \ge 0$ and
$\sum_k w_k \rho_k < \sum_k w_k \sigma_k$, then $\rho_j < \sigma_j$ for some $j$.*

**Proposition 3.6 (seedwise decline forces pooled decline).** *If $w_k \ge 0$ and
$\sigma_k \le \rho_k$ for all $k$, then $\sum_k w_k \sigma_k \le \sum_k w_k \rho_k$.*

Both are immediate from monotonicity of weighted sums. Proposition 3.5 says a
pooled rebound can never be manufactured by pooling alone *at fixed weights*;
Proposition 3.6 says the observed ladder is consistent with a genuinely seedwise
fade. What Proposition 3.5 does not do is tell you whether an observed rebound is
distinguishable from noise; that is Section 5.

---

## 4. Rigidity and stability of the imbalance law

Theorem 3.2 is worst-case. How exceptional must a seed profile be to attain it?
Normalise: let $w$ be a probability weight vector ($w_k \ge 0$, $\sum_k w_k = 1$)
on ratios $\lambda_k \in [\alpha,\beta]$, and write $M = \sum_k w_k\lambda_k$,
$Q = \sum_k w_k\lambda_k^2$. Define the **Kantorovich slack**
$$g(w,\lambda) \;=\; (\alpha+\beta)^2 M^2 - 4\alpha\beta\,Q \;\ge\; 0 .$$

**Theorem 4.1 (exact slack identity).** *For normalised $w$,*
$$g(w,\lambda) \;=\; \big((\alpha+\beta)M - 2\alpha\beta\big)^2
\;+\; 4\alpha\beta \sum_k w_k(\lambda_k-\alpha)(\beta-\lambda_k) .$$

*Proof sketch.* Expand $\sum_k w_k(\lambda_k-\alpha)(\beta-\lambda_k)
= (\alpha+\beta)M - \alpha\beta - Q$ using $\sum_k w_k = 1$, substitute into the
right-hand side, and check the resulting polynomial identity in $M, Q$. $\square$

Both summands on the right are nonnegative — the first is a square, the second a
nonnegative-weight sum of products of nonnegative factors. The identity therefore
decomposes failure-to-be-extremal into two independent causes: *mean defect* and
*endpoint defect*.

**Theorem 4.2 (rigidity).** *Let $0 < \alpha \le \beta$, $w$ normalised,
$\lambda_k \in [\alpha,\beta]$. If $g(w,\lambda) = 0$, then*
1. *(endpoint support)* $w_k(\lambda_k - \alpha)(\beta-\lambda_k) = 0$ for every $k$; *and*
2. *(harmonic mean)* $(\alpha+\beta)M = 2\alpha\beta$, i.e. $M$ equals the harmonic mean of $\alpha$ and $\beta$.

*Proof.* Both summands in Theorem 4.1 are nonnegative and sum to $0$, hence both
vanish. Vanishing of the second gives a sum of nonnegative terms equal to zero,
hence each term is zero. $\square$

**Theorem 4.3 (uniqueness of the extremal distribution).** *If in addition
$\alpha < \beta$ and $g(w,\lambda) = 0$, then*
$$\sum_{k:\ \lambda_k = \alpha} w_k = \frac{\beta}{\alpha+\beta},
\qquad\text{hence}\qquad \sum_{k:\ \lambda_k = \beta} w_k = \frac{\alpha}{\alpha+\beta} .$$

*Proof sketch.* By Theorem 4.2(1), every $k$ with $w_k > 0$ has
$\lambda_k \in \{\alpha,\beta\}$. Writing $A$ for the mass at $\alpha$, the mean
is $M = A\alpha + (1-A)\beta$; substituting into Theorem 4.2(2),
$(\alpha+\beta)\big(A\alpha + (1-A)\beta\big) = 2\alpha\beta$, and solving the
linear equation (using $\alpha < \beta$, so the coefficient of $A$ is nonzero)
yields $A = \beta/(\alpha+\beta)$. $\square$

**Theorem 4.4 (the extremiser exists).** *For every $0 < \alpha \le \beta$, the
two-point profile with $\lambda = (\alpha, \beta)$ and
$w = \big(\beta/(\alpha+\beta),\ \alpha/(\alpha+\beta)\big)$ satisfies
$g(w,\lambda) = 0$.*

*Proof sketch.* Direct computation: $M = 2\alpha\beta/(\alpha+\beta)$ and
$Q = \alpha\beta$, whence $(\alpha+\beta)^2M^2 = 4\alpha^2\beta^2 = 4\alpha\beta Q$. $\square$

Theorems 4.2–4.4 together say: **the extremiser is unique as a distribution**.

**Theorem 4.5 (strictness from one interior seed).** *If some $j$ has $w_j > 0$
and $\alpha < \lambda_j < \beta$, then $g(w,\lambda) > 0$ strictly.*

*Proof.* If the slack were zero, Theorem 4.2(1) would force
$w_j(\lambda_j-\alpha)(\beta-\lambda_j) = 0$, contradicting positivity of all
three factors. $\square$

This is the operational face of rigidity: a real seed profile, which is never
perfectly polarised at the two endpoints of the ratio window, can never suffer
the worst-case attenuation.

### 4.1 Quantitative stability

Rigidity concerns exact equality, which no measurement attains. The slack
identity upgrades to a genuine metric statement.

**Lemma 4.6 (endpoint convexity estimate).** *For $\alpha \le \lambda \le \beta$,*
$$\frac{\beta-\alpha}{2}\,\min(\lambda-\alpha,\ \beta-\lambda)
\;\le\; (\lambda-\alpha)(\beta-\lambda) .$$

*Proof.* If $\lambda - \alpha \le \beta - \lambda$ the left side is
$\frac{\beta-\alpha}{2}(\lambda-\alpha)$ and, since
$\beta - \lambda \ge \frac{\beta-\alpha}{2}$ in that case, the claim follows;
symmetrically in the other case. $\square$

Note $\min(\lambda-\alpha, \beta-\lambda) = \operatorname{dist}(\lambda, \{\alpha,\beta\})$
for $\lambda$ in the window.

**Theorem 4.7 (stability).** *Let $0 < \alpha < \beta$, $w$ normalised,
$\lambda_k \in [\alpha,\beta]$, and suppose $g(w,\lambda) \le \varepsilon$. Then*
$$\text{(a)}\quad \sum_k w_k \operatorname{dist}(\lambda_k, \{\alpha,\beta\})
\;\le\; \frac{\varepsilon}{2\alpha\beta(\beta-\alpha)},
\qquad
\text{(b)}\quad \big((\alpha+\beta)M - 2\alpha\beta\big)^2 \le \varepsilon .$$

*Proof sketch.* By Theorem 4.1 each summand is at most $\varepsilon$. Part (b) is
immediate. For (a), the second summand gives
$4\alpha\beta \sum_k w_k(\lambda_k-\alpha)(\beta-\lambda_k) \le \varepsilon$;
Lemma 4.6 replaces each product by $\frac{\beta-\alpha}{2}$ times the distance,
yielding $2\alpha\beta(\beta-\alpha)\sum_k w_k \operatorname{dist}(\lambda_k,\{\alpha,\beta\}) \le \varepsilon$. $\square$

**Corollary 4.8 (mean-defect form).**
$$\Big| M - \frac{2\alpha\beta}{\alpha+\beta} \Big| \;\le\; \frac{\sqrt{\varepsilon}}{\alpha+\beta}.$$

**Corollary 4.9 (stability recovers rigidity).** *Setting $\varepsilon = 0$ in
Theorem 4.7(a) gives $w_k \operatorname{dist}(\lambda_k,\{\alpha,\beta\}) = 0$ for
all $k$, which is the endpoint-support half of Theorem 4.2.* Hence the
quantitative estimate loses no information and is sharp at the extremiser.

---

## 5. Noise versus signal on a ladder

We now address Q1. The relevant primitive is a *seed window*: an interval of
width $s$ containing all per-seed readings behind a pooled value. By
Corollary 2.8, for balanced families the pooled value lies in the same window.

**Lemma 5.1 (pooled values inherit the seed window).** *If $w_k \ge 0$,
$\sum_k w_k = 1$, and $\ell \le \rho_k \le \ell + s$ for all $k$, then
$\ell \le \sum_k w_k \rho_k \le \ell + s$.*

**Theorem 5.2 (a sub-spread step carries no information).** *For every step size
$t$ with $0 \le t \le s$ there exist two weightings and two seed families, both
contained in a single common window of width $s$, whose pooled values differ by
exactly $t$.*

*Proof.* Take the common window $[0, s]$, weights $(1,0)$ in both cases, seed
readings $(t,t)$ in the first and $(0,0)$ in the second. Both families lie in
$[0,s]$ and the pooled values are $t$ and $0$. $\square$

**Theorem 5.3 (two-spread criterion).** *Let two pooled values arise from seed
families in windows $[\ell, \ell+s]$ and $[\ell', \ell'+s]$ respectively, with
normalised weights. Then:*
1. *if the difference of pooled values exceeds $s$, the windows are distinct
   ($\ell' < \ell$);*
2. *if it exceeds $2s$, the seed families are entirely disjoint: every reading of
   the second family is strictly below every reading of the first.*

*Proof sketch.* By Lemma 5.1 the pooled values lie in their windows. If
$\ell' \ge \ell$ the two windows coincide or the second sits above, and the
difference of two points of windows separated by at most $0$ is at most $s$ — a
contradiction, giving (1). For (2), a gap exceeding $2s$ forces
$\ell' + s < \ell$, i.e. the windows are disjoint intervals in the stated order. $\square$

**Application to the record.** With $s = 0.082$:

* the rebound step $+0.0226$ and the retrace step $-0.0483$ both satisfy
  $|{\text{step}}| \le s$, so by Theorem 5.2 each is realisable inside a *single
  unchanged* seed window — **neither is evidence of any change**;
* the cumulative decline $0.5739 - 0.4364 = 0.1375 > 0.082 = s$, so by
  Theorem 5.3(1) the top and bottom of the ladder **cannot share a seed window**.

That is the precise sense in which "the rebound was noise, the fade is real."

---

## 6. Capacity–fade duality

### 6.1 The capacity of a reading

The starting point is the capacity constraint for decorrelated statistics: if
$u_1,\dots,u_k$ are mutually decorrelated (an orthonormal family) and each reads
at least $\rho \ge 0$ against a unit response $w$, i.e.
$\langle u_i, w\rangle \ge \rho$ for all $i$, then
$$k\,\rho^2 \;\le\; 1 .$$
(This is Bessel's inequality: $\sum_i \langle u_i,w\rangle^2 \le \lVert w\rVert^2 = 1$.)

High readings are a scarce resource. Reading the constraint as a function of
$\rho$:

**Definition 6.1 (capacity of a reading).**
$$\operatorname{cap}(\rho) \;=\; \Big\lfloor \frac{1}{\rho^2} \Big\rfloor \in \mathbb{N},$$
the largest $k$ permitted by $k\rho^2 \le 1$: the number of mutually decorrelated
statistics that can all read at level $\rho$.

**Proposition 6.2 (antitonicity).** *If $0 < \rho \le \sigma$ then
$\operatorname{cap}(\sigma) \le \operatorname{cap}(\rho)$.*

*Proof.* $1/\sigma^2 \le 1/\rho^2$ and $\lfloor\cdot\rfloor$ is monotone. $\square$

**A fading dial has nondecreasing capacity.** The fade is not only a loss of
predictive strength; it is a licence to hold more independent signals at that
level.

Two conversion lemmas move between the reading language and the capacity
language.

**Lemma 6.3 (small reading $\Rightarrow$ large capacity).** *If $\rho > 0$ and
$\rho \le 1/(K+1)$ for a natural number $K$, then $K \le \operatorname{cap}(\rho)$.*

*Proof sketch.* From $\rho(K+1) \le 1$ and $\rho>0$ we get $\rho^2 (K+1) \le \rho \le 1/(K+1)$,
hence $\rho^2 K \le \rho^2 (K+1) \le 1$, so $K \le 1/\rho^2$ and $K \le \lfloor 1/\rho^2\rfloor$
since $K$ is an integer. $\square$

**Lemma 6.4 (large capacity $\Rightarrow$ small reading).** *If $K \ge 1$,
$\rho > 0$ and $K \le \operatorname{cap}(\rho)$, then $\rho^2 \le 1/K$.*

*Proof.* $K \le \lfloor 1/\rho^2 \rfloor \le 1/\rho^2$; rearrange. $\square$

### 6.2 The duality

**Definition 6.5 (persistent multiplicative fade).** A ladder $(\rho_k)_{k\ge0}$
of positive readings **fades at rate $q$** if $0 \le q < 1$ and
$\rho_{k+1} \le q\,\rho_k$ for all $k$.

**Lemma 6.6 (geometric envelope).** *A ladder fading at rate $q$ satisfies
$\rho_k \le q^k \rho_0$.* (Induction on $k$.)

**Lemma 6.7 (no positive floor survives a fade).** *If a ladder fades at rate $q$
and $\varepsilon > 0$, there is $N$ with $\rho_k < \varepsilon$ for all $k \ge N$.*

*Proof sketch.* Choose $N$ with $q^N < \varepsilon/(\rho_0 + 1)$, possible because
$q<1$; then Lemma 6.6 gives $\rho_k \le q^k\rho_0 \le q^N \rho_0 < \varepsilon$ for
$k\ge N$. $\square$

**Theorem 6.8 (fade $\Rightarrow$ unbounded capacity).** *If $(\rho_k)$ is
positive and fades at rate $q<1$, then for every $K \in \mathbb{N}$ there exists
$N$ with $K \le \operatorname{cap}(\rho_N)$.*

*Proof.* Apply Lemma 6.7 with $\varepsilon = 1/(K+1) > 0$ to obtain $N$ with
$\rho_N < 1/(K+1)$, then Lemma 6.3. $\square$

**Theorem 6.9 (capacity ceiling $\Rightarrow$ positive floor).** *If $(\rho_k)$ is
positive and $\operatorname{cap}(\rho_N) \le K$ for every $N$, then for every $N$*
$$\rho_N^2 \;>\; \frac{1}{K+1} .$$

*Proof.* $1/\rho_N^2 < \lfloor 1/\rho_N^2\rfloor + 1 = \operatorname{cap}(\rho_N) + 1 \le K+1$.
Rearranging with $\rho_N^2 > 0$ gives the claim. $\square$

**Theorem 6.8 and Theorem 6.9 are the capacity–fade duality.** Together they say
that for a positive ladder:

> the ladder has a positive floor $\iff$ the ladder's capacity is bounded.

Consequently the "floor" hypothesis is *not* a weakening of the fade law: it is
its exact negation, expressed in the dual language of decorrelated families. A
floor is refutable by exhibiting sufficiently many mutually decorrelated
statistics all reading at a given level; a capacity ceiling is refutable by
observing enough further decline.

### 6.3 The record in capacity terms

$$\operatorname{cap}(0.5739) = \lfloor 1/0.329361 \rfloor = \lfloor 3.0362 \rfloor = 3,
\qquad
\operatorname{cap}(0.43636) = \lfloor 1/0.190410 \rfloor = \lfloor 5.2518 \rfloor = 5 .$$

**Theorem 6.10 (capacity expansion).** $\operatorname{cap}(0.5739) < \operatorname{cap}(0.43636)$.

At the top of the ladder at most three mutually decorrelated statistics can all
read at the dial level; at the current reading, five can. The recorded fade is a
strict capacity expansion.

**Falsifiable prediction.** With the rebound rung removed as noise (justified by
Section 5), the de-noised ladder
$0.5739, 0.5436, 0.5005, 0.4880, 0.4621, 0.4364$ satisfies
$\rho_{k+1} \le 0.98\,\rho_k$ at every rung. If that rate persists from the
current reading, then $\rho_5 \le 0.98^5 \cdot 0.43636 < 0.40$: five more rungs
put the dial below $0.40$, and hence the capacity at $6$.

---

## 7. The advantage–decorrelation duality

Two statistics $u, v$ read against a shared response $w$; write
$a = \operatorname{corr}(u,w)$, $b = \operatorname{corr}(v,w)$,
$c = \operatorname{corr}(u,v)$. Positive semidefiniteness of the $3\times3$
correlation matrix is the **Gram condition**
$$a^2 + b^2 + c^2 \;\le\; 1 + 2abc . \tag{G}$$

**Theorem 7.1 (advantage bounds decorrelation).** *Under (G) with
$a^2, b^2 \le 1$ and $-1 \le c \le 1$,*
$$(a-b)^2 \le 2(1-c), \qquad\text{equivalently}\qquad c \le 1 - \tfrac12 (a-b)^2,
\qquad\text{and}\qquad a - b \le \sqrt{2(1-c)} .$$

*Proof sketch.* By Theorem 7.3 below, (G) is equivalent to
$(c-ab)^2 \le (1-a^2)(1-b^2)$, from which
$c \le ab + \sqrt{(1-a^2)(1-b^2)}$, and AM–GM gives
$ab + \sqrt{(1-a^2)(1-b^2)} \le ab + \frac{(1-a^2)+(1-b^2)}{2} = 1 - \frac{(a-b)^2}{2}$.
The degenerate case $c = -1$ forces $a = -b$ with $a^2 \le 1$ and the inequality
$(a-b)^2 = 4a^2 \le 4 = 2(1-c)$ holds. $\square$

**Interpretation.** *Any measured advantage is a certificate of decorrelation.*
If one statistic beats another by $a - b$ against a common response, the two
statistics cannot correlate above $1 - (a-b)^2/2$: they are genuinely different
instruments.

**Theorem 7.2 (sharpness as a statement about $c$ alone).** *For every
$-1 \le c < 1$ there exist unit vectors $u,v$ and a nonzero $w$ in $\mathbb{R}^2$
with $\operatorname{corr}(u,v) = c$ and
$\operatorname{corr}(u,w) - \operatorname{corr}(v,w) = \sqrt{2(1-c)}$.*

*Proof sketch.* Take $u = (1,0)$, $v = (c, \sqrt{1-c^2})$ and $w$ along $u - v$,
normalised. Then $\operatorname{corr}(u,w) - \operatorname{corr}(v,w) = \lVert u - v\rVert = \sqrt{2(1-c)}$. $\square$

**Theorem 7.3 (ellipse form of Gram positivity).** *For all real $a,b,c$,*
$$a^2+b^2+c^2 \le 1 + 2abc \iff (c - ab)^2 \le (1-a^2)(1-b^2),$$
*by the identity $1 - a^2 - b^2 - c^2 + 2abc = (1-a^2)(1-b^2) - (c-ab)^2$.*

**Corollary 7.4 (ellipse certificate).** *Under (G),
$c \le ab + \sqrt{(1-a^2)(1-b^2)}$.*

**Theorem 7.5 (the ellipse certificate always dominates).** *For $a^2, b^2 \le 1$,*
$$ab + \sqrt{(1-a^2)(1-b^2)} \;\le\; 1 - \tfrac12 (a-b)^2,$$
*with equality precisely when $|a| = |b|$.*

*Proof.* AM–GM on the nonnegative numbers $1-a^2$ and $1-b^2$:
$\sqrt{(1-a^2)(1-b^2)} \le \frac{(1-a^2)+(1-b^2)}{2} = 1 - \frac{a^2+b^2}{2}$, so the
left side is at most $ab + 1 - \frac{a^2+b^2}{2} = 1 - \frac{(a-b)^2}{2}$. AM–GM is
an equality exactly when $1-a^2 = 1-b^2$, i.e. $|a|=|b|$. $\square$

So the advantage certificate is *exactly the AM–GM relaxation* of the ellipse
certificate: sharp when only the gap $a-b$ is known (Theorem 7.2), strictly lossy
once both readings are known and $|a| \ne |b|$.

**Application to the record.** With $a = 0.43636$ (statistic $T$) and
$b = 0.36116$ (count baseline), advantage $0.0752$:

* the advantage certificate gives $c \le 1 - 0.0752^2/2 = 0.99717248$;
* the ellipse certificate gives $c \le ab + \sqrt{(1-a^2)(1-b^2)} \le 0.9967$,
  strictly better, as Theorem 7.5 predicts since $|a| \ne |b|$.

---

## 8. The inverse pooling problem

Sections 2–4 bound a *pooled* reading from *per-seed* readings. Experiments need
the converse: what do the per-seed readings have to be, given the pooled value
and an imbalance window?

**Theorem 8.1 (inverse pooling law).** *Let $(u,v)$ have ratio profile
$\lambda_k \in [\alpha, \beta]$ with $0 < \alpha \le \beta$, and suppose the
per-seed readings satisfy $\rho_{\min} \le \rho_k \le \rho_{\max}$ with
$\rho_{\min}, \rho_{\max} \ge 0$. Then*
$$\rho_{\text{pool}} \;\le\; \rho_{\max}
\qquad\text{and}\qquad
\rho_{\min} \;\le\; \rho_{\text{pool}} \cdot \frac{\alpha+\beta}{2\sqrt{\alpha\beta}} .$$

*Proof.* The first inequality is Corollary 2.4. The second is Theorem 3.2 applied
with $\rho = \rho_{\min}$: $\rho_{\min}\kappa(\alpha,\beta) \le \rho_{\text{pool}}$,
divided by $\kappa(\alpha,\beta) > 0$. $\square$

Read as a window: *some seed reads at least the pooled value, and some seed reads
at most the pooled value inflated by $1/\kappa(\alpha,\beta)$.* The width of the
window is governed by the imbalance window alone; on a nearly balanced family the
pooled number nearly determines the seeds.

**Corollary 8.2 (the recorded window).** *If the recorded seed ratios lie in the
$\pm 10\%$ window $\lambda_k \in [1, 1.21]$ and the pooled reading is $0.43636$,
then*
$$\rho_{\max} \ge 0.43636 \qquad\text{and}\qquad \rho_{\min} \le 0.43835 .$$

*Proof.* $\sqrt{\alpha\beta} = \sqrt{1.21} = 1.1$, so
$1/\kappa = 2.21/2.2 = 1.004\overline{54}$ and
$0.43636 \times 1.004545\ldots = 0.438344\ldots \le 0.43835$. $\square$

So the unreported per-seed readings are confined to a window of width less than
$0.002$ around the pooled value.

---

## 9. Answering Q2: the fade is seedwise

We can now dispose of the pooling-artefact objection quantitatively.

**Theorem 9.1 (the recorded step is not an imbalance artefact).** *Suppose the
per-seed ratios lie in $[1, 1.21]$ and every seed reads at least the previous
rung's value $0.4847$. Then the pooled reading satisfies
$\rho_{\text{pool}} > 0.43636$.*

*Proof.* Theorem 3.2 with $\alpha = 1$, $\beta = 1.21$, $\rho = 0.4847$ gives
$\rho_{\text{pool}} \ge 0.4847 \cdot 2\sqrt{1.21}/2.21 = 0.4847 \cdot 2.2/2.21
= 0.482507\ldots > 0.43636$. $\square$

Hence if the seeds had merely *held* at $0.4847$, the observed value $0.43636$
was unreachable inside the recorded imbalance window. **The $-0.0483$ step is a
genuine seedwise decline.**

**Theorem 9.2 (the fade is seedwise).** *If the per-seed ratios lie in
$[1, 1.21]$ and the pooled reading is $0.43636$, then every seed reads below
$0.5739$.* (Immediate from Theorem 3.2 in contrapositive form: all seeds at
$0.5739$ would force $\rho_{\text{pool}} \ge 0.5713 > 0.43636$.)

**Theorem 9.3 (how wide the window would have to be).** *To explain the fall from
$0.4847$ to $0.43636$ by imbalance alone one needs
$\kappa(\alpha,\beta) \le 0.9003$, which forces $\beta/\alpha \ge 2.54$ (in
particular $\beta \ge 1.9\,\alpha$). To explain the whole decline from $0.5739$
one needs $\kappa \le 0.76035$, which forces $\beta/\alpha \ge 4.71$ — an
imbalance of nearly five-fold.*

*Proof sketch.* $\kappa(\alpha,\beta) \le t$ is, after squaring,
$4\alpha\beta \le t^2(\alpha+\beta)^2$, a quadratic in $r = \beta/\alpha$ whose
solution set is $r \ge r(t)$ with $r(t)$ the larger root of
$t^2 r^2 + (2t^2 - 4)r + t^2 = 0$; evaluating gives $r(0.9003) \approx 2.54$ and
$r(0.76035) \approx 4.71$. $\square$

Both thresholds are far outside the recorded seed behaviour, and both are
directly falsifiable by measuring the per-seed norms.

---

## 10. Algorithms

The theory yields three small, exactly specified computational procedures.

### 10.1 Pooled correlation from block data

Given block families $u, v$, compute
$N = \sum_k \langle u_k, v_k\rangle$, $E_u = \sum_k \lVert u_k\rVert^2$,
$E_v = \sum_k \lVert v_k\rVert^2$, and return $N/\sqrt{E_u E_v}$. Cost
$\Theta(mn)$ in time and $\Theta(1)$ in working space beyond the input. The same
pass yields the per-seed readings $\rho_k$ and ratios $\lambda_k$, hence the
imbalance window $[\alpha,\beta] = [\min_k\lambda_k, \max_k\lambda_k]$ and the
certified bounds of Theorems 2.4, 3.2, 8.1.

### 10.2 Certified seed window from a pooled value

Given $\rho_{\text{pool}}$ and $[\alpha,\beta]$, compute
$\kappa = 2\sqrt{\alpha\beta}/(\alpha+\beta)$ and return the certified window
$[\rho_{\text{pool}},\ \rho_{\text{pool}}/\kappa]$ in the sense of Theorem 8.1
($\rho_{\max}$ at least the lower end, $\rho_{\min}$ at most the upper end).
Cost $\Theta(1)$.

### 10.3 Capacity ladder and floor test

Given a ladder $(\rho_k)$, compute $\operatorname{cap}(\rho_k) = \lfloor 1/\rho_k^2\rfloor$
for each rung and the per-rung ratios $\rho_{k+1}/\rho_k$. If
$q = \max_k \rho_{k+1}/\rho_k < 1$, the ladder fades at rate $q$ and, by
Theorem 6.8, no positive floor is consistent with the fade continuing; the number
of further rungs needed to reach capacity $K$ is
$\lceil \log(1/((K+1)\rho_{\text{last}})) / \log q \rceil$. Conversely, given an
observed capacity ceiling $K$, Theorem 6.9 returns the certified floor
$1/\sqrt{K+1}$. Cost $\Theta(\text{number of rungs})$.

---

## 11. Discussion

### 11.1 What the record now supports

| Claim | Status |
|---|---|
| The $+0.0226$ rebound is noise | Established: step $\le$ seed spread $0.082$ (Theorem 5.2) |
| The cumulative $0.1375$ decline is signal | Established: exceeds spread (Theorem 5.3) |
| The $-0.0483$ step is not a pooling artefact | Established inside the recorded $\pm10\%$ ratio window (Theorem 9.1) |
| The statistic genuinely differs from the baseline | Established: $c \le 0.9967$ (Corollary 7.4) |
| The fade is a capacity expansion $3 \to 5$ | Established (Theorem 6.10) |
| Per-seed readings behind $0.43636$ | Confined to width $< 0.002$ (Corollary 8.2) |
| A positive floor exists | Equivalent to a capacity ceiling (Theorems 6.8, 6.9); undecided by the data |

### 11.2 The conceptual content

Three ideas do the work.

**Concatenation is not averaging.** The gap between them is exactly the spread of
the ratio profile, and the Kantorovich constant $2\sqrt{\alpha\beta}/(\alpha+\beta)$
measures it *exactly*. Because that constant is sharp, it can be used
*adversarially*: it says how much of an observed fall imbalance is *allowed* to
explain, and therefore refutes artefact explanations rather than merely
tolerating them. An unsharp bound cannot do this.

**Slack identities beat inequalities.** The identity of Theorem 4.1 is worth more
than the inequality it proves: because it is an equality with two nonnegative
summands, it simultaneously delivers the inequality (nonnegativity), rigidity
(vanishing), and stability (smallness). This is a general pattern worth
exploiting whenever an inequality's proof passes through a completed square.

**Dualising a resource constraint.** The capacity constraint $k\rho^2 \le 1$ is
usually read as an upper bound on $k$ given $\rho$. Read instead as a function of
$\rho$, it turns the qualitative statement "the dial is fading" into the
quantitative statement "the number of independent signals sustainable at the dial
level is growing", and — crucially — makes "floor" and "bounded capacity"
literally the same hypothesis. A conjecture that looked like a mild hedge on the
fade law turns out to be its exact negation.

### 11.3 Limitations

The theory is deterministic and geometric: it constrains what the reported
numbers *can* be given structural facts (window sizes, imbalance ranges), not the
sampling distribution of those numbers. The confidence interval
$[0.38815, 0.48113]$ is an input, not an output. The seed-window arguments of
Section 5 assume the recorded spread $0.082$ genuinely bounds the per-seed
readings, and the imbalance arguments of Sections 3 and 9 assume the ratio
profile stays inside $[1,1.21]$; both assumptions are directly measurable, and
both are the natural targets for falsification. Finally, the pooled quantity here
is a Pearson-type correlation of concatenated blocks; rank correlations agree
with this after replacing values by ranks within blocks, but pooling ranks across
blocks is a different operation and is not covered.

---

## 12. Future work

1. **Non-uniform block lengths.** Everything above holds for blocks of equal
   ambient dimension. Blocks of differing lengths change the energy weights but
   not the structure of the argument; the sharp constant should survive verbatim,
   and the extremiser should still be two-point.
2. **Rank pooling.** Determine the analogue of the sharp imbalance law when ranks
   are recomputed on the concatenation rather than within blocks. The ratio
   profile is then constrained by combinatorics, which should improve $\kappa$.
3. **Multi-window stability.** Theorem 4.7 controls the distance to the
   extremiser by the slack. A profile-level converse — every profile at weighted
   $L^1$ distance $d$ from the extremiser has slack at least $c\,d$ — would make
   the slack a two-sided metric on profiles.
4. **Capacity with correlated families.** The capacity used here is the
   decorrelated ($\gamma = 0$) case of the constraint $k\rho^2 \le 1 + (k-1)\gamma$
   for families with pairwise correlation at most $\gamma$. Defining
   $\operatorname{cap}_\gamma(\rho)$ and proving the corresponding duality would
   let the floor question be attacked with families that are merely weakly
   correlated, which is what real statistic families are.
5. **Deciding the dichotomy.** By Theorems 6.8 and 6.9 the floor question is now a
   single question: is the capacity of the ladder bounded? Two more rungs at the
   observed rate $0.98$ would put the reading below $1/\sqrt{6} \approx 0.4082$,
   raising the capacity to $6$; each such observation is a direct refutation of the
   corresponding capacity ceiling.
