# Censored Steepness and Uniform Kernel Detection: An Identifiability Analysis of Flat-Bulk-Plus-Edge-Spike Mixtures

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

We analyse the identifiability structure of a two-component profile on the unit
interval consisting of a uniform *bulk* and a left-edge *spike* given by an
exponential law of rate $b$ truncated to $[0,1]$, observed only through binned
counts. We prove a sharp dichotomy. On the one hand, the steepness parameter $b$
is *censored*: the mass that the spike deposits in a leftmost bin $[0,t]$ is
strictly increasing in $b$ but bounded, and approaches its ceiling at rate
$e^{-bt}$; consequently, whenever the empirical edge fraction meets or exceeds
that ceiling, the binned log-likelihood is strictly increasing in $b$, the
unconstrained maximum-likelihood estimate fails to exist, every box-constrained
optimum sits exactly on its upper bound, and all log-likelihood available above a
cap $B$ is bounded by $C\,e^{-Bt}$. The identified set for $b$ at tolerance
$\varepsilon$ contains a ray $[B_0,\infty)$, so no finite upper confidence limit
exists; lower bounds, however, remain valid, and at the population level the map
$b \mapsto$ (edge mass) is injective, so the correct notion is *tolerance
identifiability* rather than outright non-identifiability. On the other hand,
*existence* of the spike is identified uniformly in $b$. Using the three-term
log-convexity defect $D(x,y,z) = xz - y^2$ on consecutive bin probabilities, we
show $D$ vanishes identically on the entire single-truncated-exponential family,
while for the mixture with spike weight $\rho$ on $k$ equal bins
$D = \frac{\rho(1-\rho)}{k}\,q_j(1-r)^2$ with $r=e^{-b/k}$, bounded below by
$\rho(1-\rho)/(8k)$ once $r \le 1/2$. Since $D$ is $4$-Lipschitz in the sup-norm,
the mixture is separated from *every* single law by at least
$\rho(1-\rho)/(32k)$ in sup-norm, uniformly in the steepness. We also record an
exact non-identifiability direction — the component role swap — and quantify the
"steepness valley": all bin vectors with $b \ge B$ lie within $4\rho e^{-B/3}$ of
one another. The results explain, and correct, an empirical analysis in which a
fitted steepness rode successive optimiser caps ($40.000$ at cap $40$, $40.46$ at
cap $80$, bootstrap interval $[15.25, 80.0]$) while the evidence for the second
component stayed essentially constant across all caps.

**Keywords:** identifiability; censored parameter; truncated exponential;
mixture models; log-convexity defect; boundary maximum-likelihood estimates;
binned likelihood; model selection.

---

## 1. Introduction

### 1.1 The empirical situation

A pooled positional dataset of $n = 9594$ observations, aggregated over $128$
independent trials and rescaled to the unit interval, exhibits a histogram that
is close to flat over the bulk of $[0,1]$ but shows a pronounced excess in the
leftmost bins. The natural model is a two-component profile:

$$f(x) \;=\; (1-\rho)\cdot 1 \;+\; \rho\cdot \frac{b\,e^{-bx}}{1-e^{-b}},
\qquad x \in [0,1],$$

a uniform bulk carrying weight $1-\rho$ plus a left-edge spike carrying weight
$\rho$, the spike being an exponential of rate $b$ conditioned to $[0,1]$.

Fitting this profile to the binned data produced two very different experiences
for the two parameters.

* The **spike weight** $\rho$ was stable, landing near $0.475$–$0.545$ across all
  fitting configurations.
* The **spike steepness** $b$ was not. Constraining the optimiser to $b \le 40$
  returned $\hat b = 40.000$ — the constraint, active. Relaxing to $b \le 80$
  returned $\hat b = 40.46$. A nonparametric bootstrap with $300$ replicates at
  the higher cap gave the interval $[15.25,\ 80.0]$, whose upper endpoint is
  again the cap; $26.7\%$ of replicates terminated exactly at $80$, and at the
  lower cap $60\%$ terminated exactly at $40$.

Meanwhile the *evidence for the two-component model over a single truncated
exponential* was overwhelming and stable: a corrected model-selection difference
of $-99.57,\ -99.57,\ -101.28,\ -101.33$ at caps $10, 20, 40, 80$ respectively
(negative favouring the two-component model), with a goodness-of-fit statistic
dropping from $158.2$ to $52$–$54$. The best single-law fit gave rate $1.1596$.
A control dataset run through the identical pipeline reversed the sign of the
model-selection difference to $+4.85$ at every cap, with spike weight collapsing
to $8.3\times 10^{-7}$ and single-law rate $0.084$, i.e. effectively uniform.

The empirical verdict was therefore: *the kernel exists beyond doubt; its
steepness is a lower bound only*. This paper proves that this verdict is a
theorem about the model class, not a diagnosis of an optimiser.

### 1.2 Contributions

We establish, for the model above observed through bins:

1. **Strict monotonicity** of the edge-bin mass in $b$ (Theorem 3.4), via the
   strict convexity of $\exp$.
2. **A censoring bound** $1 - F(b,t) \le 2e^{-bt}$ (Theorem 4.1) and the limit
   $F(b,t)\to 1$ (Corollary 4.2).
3. **Forced cap-riding** (Theorem 5.3): if the empirical edge fraction is at
   least the model's $b\to\infty$ ceiling, the binned log-likelihood is strictly
   increasing in $b$; hence every box-constrained optimum is a boundary point.
4. **Non-existence of a finite maximiser** (Corollary 5.4).
5. **An explicit exponential bound on cap gains** (Theorem 5.5).
6. **The identified set is a ray** (Theorem 6.1), with existence of the threshold
   (Proposition 6.2), while **lower bounds survive** (Theorem 6.3), and
   **population identification holds** (Theorem 6.4) — so the correct notion is
   tolerance identifiability.
7. **Vanishing of the log-convexity defect on the entire single-law family**
   (Theorem 7.2) and its **closed form and cap-uniform lower bound on the
   mixture** (Theorems 7.3, 7.5).
8. **A cap-uniform sup-norm separation** of the mixture from every single law
   (Theorem 7.7), extended to $k$ bins (Theorem 8.5) with margin
   $\rho(1-\rho)/(32k)$.
9. **The steepness valley** (Theorem 9.1) and the **exact role-swap symmetry**
   (Theorem 10.1).

### 1.3 Reading guide

Sections 2–6 concern what the data *cannot* see; Sections 7–10 concern what they
*can*. Section 11 assembles the two halves into a single geometric picture,
Section 12 gives the corrected reporting standard, and Section 13 lists open
problems.

---

## 2. Setup and definitions

Throughout, $\rho \in (0,1)$ is the spike weight, $t \in (0,1)$ is the width of
the leftmost bin, and $b > 0$ is the spike steepness.

**Definition 2.1 (Truncated exponential CDF).** For $b>0$ and $t \in (0,1)$ set

$$F(b,t) \;=\; \frac{1 - e^{-bt}}{1 - e^{-b}}.$$

This is the probability that an exponential random variable of rate $b$,
conditioned to lie in $[0,1]$, falls in $[0,t]$; equivalently, the mass a spike
of steepness $b$ deposits in the edge bin.

**Definition 2.2 (Edge probability of the two-component profile).**

$$p(\rho,t,b) \;=\; (1-\rho)\,t \;+\; \rho\,F(b,t).$$

We write $p(b)$ when $\rho, t$ are fixed.

**Definition 2.3 (Ceiling).**

$$P_\infty(\rho,t) \;=\; (1-\rho)\,t + \rho .$$

This is the $b \to \infty$ limit of $p(b)$: the spike degenerates to a point mass
at $0$ and all of its weight enters the edge bin, while the bulk contributes
its uniform share $(1-\rho)t$.

**Definition 2.4 (Two-cell binned log-likelihood).** For an observed edge
fraction $h \in (0,1)$ and a model edge probability $p \in (0,1)$,

$$\ell(h,p) \;=\; h\log p + (1-h)\log(1-p).$$

This is the per-observation log-likelihood of the collapsed two-cell table
(edge bin versus its complement). Collapsing is a deliberate simplification: it
is the coarsest observable that still sees the spike, and the negative results
proved for it are *a fortiori* informative, since any richer binning that we
consider (Sections 7–9) is shown to inherit the same exponential insensitivity.

**Elementary facts.** For $b>0$ we have $e^{-b}<1$, so $1-e^{-b}>0$ and
$F(b,t)$ is well defined; for $0<t<1$ one has $e^{-b} < e^{-bt}$, hence
$0 < F(b,t) < 1$, and consequently $0 < p(b) < P_\infty$.

---

## 3. Strict monotonicity of the edge mass

**Lemma 3.1 (Strict chord inequality).** For $b>0$ and $0 < t < 1$,

$$e^{bt} - 1 \;<\; t\,(e^{b} - 1).$$

*Proof sketch.* Apply strict convexity of $x \mapsto e^x$ to the pair of points
$b$ and $0$ with weights $t$ and $1-t$: since $b \ne 0$, $t>0$, $1-t>0$ and
$t + (1-t)=1$, strict convexity gives $e^{tb} < t e^{b} + (1-t)e^{0} = te^b +
1 - t$. Rearranging gives the claim. $\square$

**Lemma 3.2 (Differentiability).** For $b>0$ the map $x \mapsto F(x,t)$ is
differentiable at $b$ with

$$\frac{\partial F}{\partial b}(b,t) \;=\;
\frac{t\,e^{-bt}\,(1-e^{-b}) - (1-e^{-bt})\,e^{-b}}{(1-e^{-b})^2}.$$

*Proof sketch.* Quotient rule; the numerator $1 - e^{-xt}$ has derivative
$te^{-bt}$ and the denominator $1-e^{-x}$ has derivative $e^{-b}$, and the
denominator is nonzero for $b>0$. $\square$

**Lemma 3.3 (Positive numerator).** For $b>0$, $0<t<1$,

$$t\,e^{-bt}(1-e^{-b}) - (1-e^{-bt})e^{-b} \;>\; 0.$$

*Proof sketch.* Substituting $e^{-bt} = (e^{bt})^{-1}$, $e^{-b}=(e^{b})^{-1}$ and
clearing denominators, the left-hand side equals

$$\frac{t\,(e^{b}-1) - (e^{bt}-1)}{e^{bt}\,e^{b}},$$

whose denominator is positive and whose numerator is positive by Lemma 3.1.
$\square$

**Theorem 3.4 (Strict monotonicity).** For $0<t<1$, the map
$b \mapsto F(b,t)$ is strictly increasing on $(0,\infty)$. Consequently, for
$\rho>0$, so is $b \mapsto p(b)$.

*Proof sketch.* $(0,\infty)$ is convex, $F(\cdot,t)$ is continuous there and has
strictly positive derivative by Lemmas 3.2–3.3; hence it is strictly increasing.
The statement for $p$ follows since $p(b) = (1-\rho)t + \rho F(b,t)$ is an
increasing affine function of $F$. $\square$

Theorem 3.4 has an immediate and important corollary that we will need in
Section 6: $b \mapsto p(b)$ is **injective**. At the population level, nothing is
lost.

---

## 4. The censoring bound

**Theorem 4.1 (Hard censoring).** For $b \ge 1$ and $0 < t \le 1$,

$$1 - F(b,t) \;\le\; 2\,e^{-bt}.$$

*Proof sketch.* A direct computation gives the exact identity

$$1 - F(b,t) \;=\; \frac{e^{-bt} - e^{-b}}{1 - e^{-b}}.$$

The numerator is nonnegative because $t \le 1$ implies $e^{-b} \le e^{-bt}$, and
is at most $e^{-bt}$. For $b \ge 1$ the denominator satisfies
$1 - e^{-b} \ge 1 - e^{-1} > 1/2$, using $e > 2$. Dividing gives the bound.
$\square$

**Corollary 4.2 (Saturation).** For $0 < t \le 1$, $F(b,t) \to 1$ as
$b \to \infty$; hence $p(b) \to P_\infty$.

*Proof sketch.* Squeeze $1 - F(b,t)$ between $0$ (by $F \le 1$) and
$2e^{-bt} \to 0$. $\square$

**Remark 4.3 (Numerical scale).** With the geometric binning used in the
motivating analysis the leftmost bin had width of order $t \approx 0.036$. Then
$e^{-bt}$ equals $0.58$ at $b=15$, $0.24$ at $b=40$, $0.056$ at $b=80$ and
$7\times10^{-4}$ at $b=200$. Since the sampling standard error of the edge-bin
frequency at $n = 9594$ is on the order of $10^{-2}$ relative, all steepnesses
beyond roughly $b \approx 100$ are statistically indistinguishable — and, as
Section 6 makes precise, so is everything above a much lower threshold once the
tolerance is set realistically.

---

## 5. Boundary optima: cap-riding is forced

**Lemma 5.1 (Monotone likelihood in the model probability).** Let
$0 < h < 1$, $0 < p < q \le h$. Then $\ell(h,p) < \ell(h,q)$.

*Proof sketch.* Write $\Delta = \ell(h,q) - \ell(h,p) = h(\log q - \log p) +
(1-h)(\log(1-q) - \log(1-p))$. The strict inequality $\log x < x-1$ for
$x>0$, $x\ne1$ applied to $x = p/q$ gives $\log q - \log p > (q-p)/q$, and
applied to $x = (1-p)/(1-q)$ gives $\log(1-q) - \log(1-p) > -(q-p)/(1-q)$. Hence

$$\Delta \;>\; h\,\frac{q-p}{q} \;-\; (1-h)\,\frac{q-p}{1-q}.$$

Because $q \le h$ (equivalently $h(1-q) \ge (1-h)q$ after rearrangement) and
$q>p$, the right-hand side is nonnegative. $\square$

The hypothesis $q \le h$ is exactly the statement that the model still
*under-predicts* the observed edge frequency; in that regime, pushing the model
probability up always helps.

**Lemma 5.2 (Strict ceiling gap).** For $\rho>0$, $b>0$, $t<1$,
$p(b) < P_\infty$; and $p(b) > 0$ for $\rho \in (0,1)$, $t>0$.

*Proof sketch.* Immediate from $F(b,t) < 1$ and $F(b,t) > 0$. $\square$

**Theorem 5.3 (Forced cap-riding).** Let $\rho \in (0,1)$, $t \in (0,1)$, and
suppose the empirical edge fraction $h$ satisfies

$$P_\infty(\rho,t) \;\le\; h \;<\; 1 .$$

Then for all $0 < b < B$,

$$\ell\big(h, p(b)\big) \;<\; \ell\big(h, p(B)\big).$$

In particular, on any box $[b_{\min}, B]$ the constrained maximiser of the binned
log-likelihood in $b$ is exactly the upper endpoint $B$.

*Proof sketch.* By Theorem 3.4, $p(b) < p(B)$. By Lemma 5.2, $0 < p(b)$ and
$p(B) < P_\infty \le h$. Apply Lemma 5.1 with $p = p(b)$, $q = p(B)$. $\square$

**Corollary 5.4 (No finite maximiser).** Under the hypotheses of Theorem 5.3,
for every $b>0$ there exists $b' > b$ with
$\ell(h,p(b)) < \ell(h,p(b'))$. Hence the unconstrained maximum-likelihood
estimator of $b$ does not exist in $(0,\infty)$, and no cap raise can ever yield
an interior optimum — only a new boundary solution.

*Proof sketch.* Take $b' = b+1$ in Theorem 5.3. $\square$

**Theorem 5.5 (Exponentially small cap gains).** Let $\rho \in (0,1)$,
$t \in (0,1)$, $h \in [0,1]$, $b \ge 1$, and write $P = P_\infty(\rho,t)$. Then

$$\ell(h, P) - \ell\big(h, p(b)\big) \;\le\;
\frac{2\rho}{\min\{(1-\rho)t,\ 1-P\}}\; e^{-bt}.$$

*Proof sketch.* Put $m = \min\{(1-\rho)t,\ 1-P\} > 0$. Three ingredients.
(i) *Lower bound on $p$*: $p(b) \ge (1-\rho)t \ge m$, since $F>0$.
(ii) *Gap bound*: by Theorem 4.1, $P - p(b) = \rho(1 - F(b,t)) \le
2\rho e^{-bt}$.
(iii) *Logarithmic Lipschitz estimates*: from $\log x \le x-1$ applied to $P/p$,
$\log P - \log p \le (P-p)/p \le (P-p)/m$; and since $P > p$ implies
$\log(1-P) \le \log(1-p)$, the second increment is at most $(P-p)/m$ as well
(indeed at most $0$). Combining with the convex weights $h$ and $1-h$,
$\ell(h,P) - \ell(h,p) \le (P-p)/m \le 2\rho e^{-bt}/m$. $\square$

**Remark 5.6.** Theorem 5.5 quantifies exactly the observed phenomenon that
doubling the cap from $40$ to $80$ improved the corrected model-selection
statistic by $0.05$, against a total margin exceeding $100$ in favour of the
two-component model. The available gain above a cap is exponentially small in
$Bt$; the *evidence for the kernel*, by contrast, is $O(1)$ (Section 7). No cap
ladder can resolve the steepness, because there is nothing left above the cap to
resolve it with.

---

## 6. Tolerance identifiability: the identified set is a ray

Theorem 5.3 says the estimator misbehaves. The following results say something
stronger and cleaner: the *inferential target itself* is a half-line.

**Theorem 6.1 (Identified set contains a ray).** Let $\rho \in (0,1)$,
$t \in (0,1)$, $P = P_\infty(\rho,t)$. Suppose the observed edge mass $v$
satisfies

$$P - \varepsilon \;\le\; v \;\le\; P,$$

and let $B_0 \ge 1$ satisfy $2\rho\,e^{-B_0 t} \le \varepsilon$. Then for every
$b \ge B_0$,

$$\big|\,p(b) - v\,\big| \;\le\; \varepsilon.$$

*Proof sketch.* Upper side: $p(b) < P$ and $v \ge P - \varepsilon$ give
$p(b) - v < \varepsilon$. Lower side: by Theorem 4.1,
$P - p(b) = \rho(1-F(b,t)) \le 2\rho e^{-bt} \le 2\rho e^{-B_0 t} \le
\varepsilon$, and $v \le P$, so $v - p(b) \le \varepsilon$. $\square$

**Proposition 6.2 (Such thresholds exist).** For any $t>0$ and $\varepsilon>0$
there exists $B_0 \ge 1$ with $2\rho\,e^{-B_0 t} \le \varepsilon$.

*Proof sketch.* $b \mapsto 2\rho e^{-bt} \to 0$ as $b\to\infty$, so the
inequality holds eventually; intersect with $[1,\infty)$. $\square$

Thus the set $\{b : |p(b) - v| \le \varepsilon\}$ contains $[B_0,\infty)$: the
identified set is unbounded above and **no finite upper confidence limit exists**
at any positive tolerance, no matter how small, provided only that the observed
edge mass sits within that tolerance of the ceiling.

**Theorem 6.3 (Lower bounds survive).** Let $\rho > 0$, $t \in (0,1)$,
$\varepsilon \ge 0$, and suppose some $b_1 > 0$ undershoots the observation:

$$p(b_1) + \varepsilon \;<\; v.$$

Then for every $0 < b \le b_1$, $\;\varepsilon < |p(b) - v|$; i.e. $b$ is
excluded at tolerance $\varepsilon$.

*Proof sketch.* By Theorem 3.4 (monotonicity), $p(b) \le p(b_1)$, so
$p(b) + \varepsilon < v$, whence $v - p(b) > \varepsilon > 0$ and
$|p(b)-v| = v - p(b)$. $\square$

Theorems 6.1 and 6.3 together characterise the identified set as
$[b_1^\ast, \infty)$ for a data-determined threshold: **a lower bound with no
upper limit**.

**Theorem 6.4 (Population identification does hold).** Let $\rho>0$,
$t \in (0,1)$, $0 < b_0 \le b_1$, and suppose $p(b_0) \le v \le p(b_1)$. Then
there exists a *unique* $b \in [b_0,b_1]$ with $p(b) = v$.

*Proof sketch.* Existence: $b \mapsto p(b)$ is continuous on $[b_0,b_1]$ (from
differentiability, Lemma 3.2) and $v$ is bracketed, so the intermediate value
theorem applies. Uniqueness: strict monotonicity (Theorem 3.4) gives injectivity
on $(0,\infty)$. $\square$

**Remark 6.5 (The right definition).** Theorem 6.4 shows that the phrase "the
steepness is unidentifiable" is, taken literally, **false**: the population map
is injective, and with an exactly known observable one recovers $b$ uniquely.
The correct concept is *tolerance identifiability*: for a tolerance
$\varepsilon>0$, the pre-image $p^{-1}\big([v-\varepsilon, v+\varepsilon]\big)$
contains a ray as soon as $v$ lies within $\varepsilon$ of the ceiling. This is
precisely the amendment that a registered analysis must make. The failure is not
a failure of the model to determine $b$; it is a failure of the *observable* to
separate distinct $b$'s at any achievable resolution.

---

## 7. What is identified: the log-convexity defect

We now turn to the complementary question, and show that the *existence* of the
spike is identified with a margin that is uniform in the unidentified parameter.

Partition $[0,1]$ into three equal bins.

**Definition 7.1.** For $r \in [0,1)$ and $j \in \{0,1,2\}$ set

$$g_j(r) \;=\; \frac{r^j}{1 + r + r^2},\qquad
m_j(\rho,r) \;=\; \frac{1-\rho}{3} + \rho\, g_j(r),$$

the three-bin probabilities of the single truncated exponential and of the
flat-bulk-plus-spike mixture respectively. Here $r = e^{-b/3}$. The
*log-convexity defect* of a triple is

$$D(x,y,z) \;=\; x z - y^2 .$$

The parametrisation is faithful: for $b>0$ the binned truncated exponential mass
in bin $j$ is exactly $\big(e^{-bj/3} - e^{-b(j+1)/3}\big)/(1-e^{-b})$, which
equals $g_j(e^{-b/3})$ because $r^3 = e^{-b}$ and
$1-r^3 = (1-r)(1+r+r^2)$. Both $(g_j)$ and $(m_j)$ are probability vectors:
$\sum_j g_j = 1$, hence $\sum_j m_j = (1-\rho) + \rho = 1$.

**Theorem 7.2 (The single-law family is a zero set of $D$).** For every
$r \ge 0$,

$$D\big(g_0(r),\, g_1(r),\, g_2(r)\big) \;=\; 0 .$$

*Proof sketch.* $g_0 g_2 = \dfrac{r^2}{(1+r+r^2)^2} = g_1^2$. The bin weights are
a geometric progression, and a geometric progression is exactly a zero of the
second log-difference. $\square$

This is the structural heart of the section: an entire one-parameter family of
alternatives — every possible single steepness — collapses onto the single
algebraic surface $\{D = 0\}$.

**Theorem 7.3 (Closed form on the mixture).** For $r \ge 0$ and any $\rho$,

$$D\big(m_0, m_1, m_2\big) \;=\; \frac{\rho(1-\rho)}{3}\cdot
\frac{(1-r)^2}{1+r+r^2}.$$

*Proof sketch.* Expand $m_j = \frac{1-\rho}{3} + \rho g_j$. The pure-$\rho^2$
terms reproduce $\rho^2 D(g_0,g_1,g_2) = 0$; the constant terms cancel because
$\big(\frac{1-\rho}{3}\big)^2 - \big(\frac{1-\rho}{3}\big)^2 = 0$; and the cross
terms leave $\frac{(1-\rho)\rho}{3}(g_0 + g_2 - 2g_1)$, which equals
$\frac{\rho(1-\rho)}{3}\cdot\frac{(1-r)^2}{1+r+r^2}$ since
$1 + r^2 - 2r = (1-r)^2$. $\square$

**Corollary 7.4 (Strict positivity).** For $\rho \in (0,1)$ and $0 \le r < 1$,
$D(m_0,m_1,m_2) > 0$. In particular no single truncated exponential reproduces
the mixture's three-bin vector, whatever its rate.

**Theorem 7.5 (Cap-uniform lower bound).** For $\rho \in (0,1)$ and
$0 \le r \le 1/2$ — equivalently $b \ge 3\log 2 \approx 2.079$ —

$$D(m_0,m_1,m_2) \;\ge\; \frac{\rho(1-\rho)}{21}.$$

*Proof sketch.* On $r \in [0,1/2]$ we have $(1-r)^2 \ge 1/4$ and
$1 + r + r^2 \le 7/4$, hence $(1-r)^2/(1+r+r^2) \ge 1/7$. Multiply by
$\rho(1-\rho)/3$. $\square$

The bound is **independent of $b$**. However far the steepness runs, the
mixture's departure from log-linearity stays at the same size.

**Theorem 7.6 (Lipschitz stability of $D$).** If $x,y,z,x',y',z' \in [0,1]$ and
$|x-x'|, |y-y'|, |z-z'| \le e$, then

$$\big|D(x,y,z) - D(x',y',z')\big| \;\le\; 4e .$$

*Proof sketch.* $xz - x'z' = x(z-z') + z'(x-x')$ has modulus at most $2e$; and
$y^2 - y'^2 = (y+y')(y-y')$ has modulus at most $2e$. $\square$

**Theorem 7.7 (Uniform single-law exclusion).** Let $\rho \in (0,1)$,
$0 \le r \le 1/2$ and let $r' \in [0,1]$ be *any* single-law parameter. Then

$$\max_{j \in \{0,1,2\}} \big|\, m_j(\rho,r) - g_j(r')\,\big|
\;\ge\; \frac{\rho(1-\rho)}{84}.$$

*Proof sketch.* Let $e$ be the left-hand maximum. By Theorem 7.6 and
Theorem 7.2,

$$\frac{\rho(1-\rho)}{21} \;\le\; D(m_0,m_1,m_2)
\;=\; \big|D(m) - D(g(r'))\big| \;\le\; 4e .$$

Divide by $4$. $\square$

**Remark 7.8 (Numerical scale).** With $\rho \approx 0.48$ the guaranteed
sup-norm separation is $0.48\cdot0.52/84 \approx 3.0 \times 10^{-3}$. On
$n=9594$ observations distributed over three bins, the standard error of a bin
frequency is about $5\times10^{-3}/\sqrt{\,\cdot\,} \approx 5\times 10^{-3}$ at
worst — and the actual $28$-bin analysis, which resolves the spike far better
than three bins do, produced a model-selection margin above $100$ units. The
theorem's virtue is not its constant but its **uniformity**: the same margin
holds for every $b \ge 3\log 2$, including $b = \infty$.

---

## 8. Arbitrary bin counts

The three-bin computation is not special.

**Definition 8.1.** For $k \ge 1$, $r \in [0,1)$, $j \ge 0$:

$$G_j^{(k)}(r) \;=\; \frac{r^j(1-r)}{1-r^k},
\qquad M_j^{(k)}(\rho,r) \;=\; \frac{1-\rho}{k} + \rho\,G_j^{(k)}(r),$$

the bin probabilities on $k$ equal cells with $r = e^{-b/k}$.

**Lemma 8.2 (Probability vector).** For $0 \le r < 1$ and $k \ge 1$,
$\sum_{j=0}^{k-1} G_j^{(k)}(r) = 1$, hence also $\sum_j M_j^{(k)} = 1$.

*Proof sketch.* $\sum_{j<k} r^j = (1-r^k)/(1-r)$. $\square$

**Theorem 8.3 (Vanishing defect for every $k$ and every index).** For $k\ge1$,
$0 \le r < 1$ and every $j \ge 0$,

$$D\Big(G_j^{(k)},\, G_{j+1}^{(k)},\, G_{j+2}^{(k)}\Big) \;=\; 0 .$$

*Proof sketch.* $G_j G_{j+2} = \left(\frac{1-r}{1-r^k}\right)^2 r^{2j+2}
= G_{j+1}^2$. $\square$

**Theorem 8.4 (Closed form and cap-uniform bound for $k$ bins).** For $k \ge 1$,
$0 \le r < 1$, and every $j$,

$$D\Big(M_j^{(k)},\, M_{j+1}^{(k)},\, M_{j+2}^{(k)}\Big)
\;=\; \frac{\rho(1-\rho)}{k}\; G_j^{(k)}(r)\,(1-r)^2 .$$

Moreover, for $\rho\in(0,1)$ and $0 \le r \le 1/2$, taking $j=0$,

$$D\Big(M_0^{(k)}, M_1^{(k)}, M_2^{(k)}\Big) \;\ge\; \frac{\rho(1-\rho)}{8k}.$$

*Proof sketch.* The closed form is the same cross-term computation as
Theorem 7.3, using $G_j - 2G_{j+1} + G_{j+2} = G_j(1-r)^2$. For the bound,
$G_0^{(k)}(r) = (1-r)/(1-r^k) \ge 1/2$ when $r \le 1/2$ (indeed
$(1-r) \ge 1/2 \ge (1-r^k)/2$), and $(1-r)^2 \ge 1/4$, so the product is at
least $1/8$. $\square$

**Theorem 8.5 ($k$-bin single-law exclusion).** For $k \ge 1$, $\rho \in (0,1)$,
$0 \le r \le 1/2$ and any $r' \in [0,1)$,

$$\max_{j \in \{0,1,2\}}\Big|\,M_j^{(k)}(\rho,r) - G_j^{(k)}(r')\,\Big|
\;\ge\; \frac{\rho(1-\rho)}{32\,k}.$$

*Proof sketch.* As in Theorem 7.7: Lipschitz stability (Theorem 7.6) plus
$D(G^{(k)}(r')) = 0$ (Theorem 8.3) plus the lower bound of Theorem 8.4 give
$\rho(1-\rho)/(8k) \le 4e$. $\square$

**Corollary 8.6.** The detectability margin for the second component degrades
only **linearly in the number of bins**, and not at all in the steepness. Finer
binning costs detection power at rate $1/k$; it buys no steepness resolution
whatsoever (Theorem 9.1).

---

## 9. The steepness valley

**Lemma 9.1a.** For $0 \le r \le 1$ and $j \ge 1$, $g_j(r) \le r$; and
$|g_0(r) - 1| \le 2r$.

*Proof sketch.* For $j \ge 1$, $r^j \le r$ and $1 + r + r^2 \ge 1$. For $j=0$,
$g_0 - 1 = -\frac{r+r^2}{1+r+r^2}$, of modulus at most $r + r^2 \le 2r$.
$\square$

**Theorem 9.1 (The steepness valley).** Let $\rho \ge 0$, $B \ge 0$, and
$b, b' \ge B$. Then for every bin index $j$,

$$\Big|\, m_j\big(\rho, e^{-b/3}\big) - m_j\big(\rho, e^{-b'/3}\big)\,\Big|
\;\le\; 4\rho\, e^{-B/3}.$$

*Proof sketch.* Set $e_B = e^{-B/3}$. For any $c \ge B$, Lemma 9.1a gives
$\big|g_j(e^{-c/3}) - \mathbf{1}[j=0]\big| \le 2 e_B$ (the case $j=0$ from the
second estimate, the case $j\ge1$ from the first, both using
$e^{-c/3} \le e_B$). Triangle inequality through the common reference point
$\mathbf{1}[j=0]$ — the degenerate point-mass bin vector — gives
$|g_j(e^{-b/3}) - g_j(e^{-b'/3})| \le 4e_B$. Finally
$m_j(\rho,\cdot)$ differs from $g_j$ by the affine map $x \mapsto
\frac{1-\rho}{3} + \rho x$, which scales differences by $\rho$. $\square$

Theorem 9.1 is the exact complement of Theorem 7.7. In the space of bin vectors,
the whole tail $\{b \ge B\}$ of the model family is squeezed into a ball of
radius $4\rho e^{-B/3}$ — an exponentially shrinking blob — while that entire
blob sits at distance at least $\rho(1-\rho)/84$ from the single-law surface.
Detection: easy and uniform. Localisation within the blob: impossible.

---

## 10. An exact non-identifiability: the role swap

The censoring of Sections 4–6 is asymptotic. There is a second, exact,
non-identifiability that was also observed empirically: at the two lowest caps
($10$ and $20$) the fit produced a *role-swapped* optimum, with the parameter
nominally describing the bulk riding its own upper bound near $30$ and thereby
acting as the spike, while the parameter nominally describing the spike settled
near $0.83$ and absorbed the smooth part. The two solutions differed by about
two units of the model-selection statistic.

**Definition 10.1.** For steepnesses $b_1,b_2$ and weight $\rho$ on the first,
the genuine two-component mixture has bin probabilities

$$T_j(\rho,b_1,b_2) \;=\; \rho\,g_j\big(e^{-b_1/3}\big) +
(1-\rho)\,g_j\big(e^{-b_2/3}\big).$$

**Theorem 10.2 (Exact role swap).** For all $\rho, b_1, b_2$ and all $j$,

$$T_j(\rho, b_1, b_2) \;=\; T_j(1-\rho,\, b_2,\, b_1).$$

*Proof sketch.* Both sides expand to the same sum. $\square$

**Corollary 10.3 (Non-unique optima of any bin-based criterion).** Let $F$ be
*any* functional of the bin-probability vector. If $b_1 \ne b_2$, then
$(\rho,b_1,b_2)$ and $(1-\rho,b_2,b_1)$ are distinct parameter points with
$F\big(T(\rho,b_1,b_2)\big) = F\big(T(1-\rho,b_2,b_1)\big)$.

*Proof sketch.* Distinctness from $b_1 \ne b_2$ in the second coordinate;
equality of criterion values because the arguments are the same function of $j$
by Theorem 10.2. $\square$

Corollary 10.3 is the familiar label-switching symmetry of mixtures, but it
matters here for a specific reason: it means that **interiority of an optimum is
not evidence of identification**. At caps $10$ and $20$ the reported steepness
$0.833$ sat strictly inside the box, which naively looks like a healthy fit; in
fact it was the swapped branch, with the *other* parameter pinned to its bound.
Any diagnostic that checks only "is the optimum interior?" will pass this case
and be wrong.

---

## 11. Synthesis: a decay rate against a transverse margin

The two halves of this paper are governed by one object: the **saturation map**

$$b \;\longmapsto\; \big(\text{bin probabilities of the mixture at steepness } b\big).$$

Its image is a curve in the probability simplex. Two quantities control
everything.

* **Tangential motion** — how fast the curve moves as $b$ varies — dies like
  $e^{-bt}$ (Theorems 4.1, 9.1). This is the *unidentified* direction.
* **Transverse distance** — how far the curve sits from the single-law surface
  $\{D=0\}$ — stays bounded below by $\rho(1-\rho)/(32k)$ (Theorems 7.7, 8.5).
  This is the *identified* direction.

Identifiability questions in this setting therefore reduce to comparing a decay
rate with a transverse margin. The estimand "does a second component exist?" is
a transverse question and is answered uniformly. The estimand "how steep is it?"
is a tangential question and is answered only up to the resolution at which the
tangential motion exceeds noise — which, past a threshold, is never.

A useful reformulation: what we have exhibited is a **polynomial invariant that
vanishes identically on the null family and is bounded below on the
alternative**. Once such an invariant is in hand, model selection reduces to a
Lipschitz distance estimate with no likelihood theory at all. That is a
methodological point of independent interest, and Section 13 pursues it.

---

## 12. Consequences for reporting

The results above prescribe a specific reporting standard for any analysis of
this model class.

1. **Do not report a point estimate of the steepness** if the fitted value is at
   or near a bound, or if the bootstrap distribution has appreciable mass at a
   bound. Theorem 5.3 says the point estimate is a property of the box, not of
   the data. In the motivating analysis the estimates $40.000$ (cap $40$) and
   $40.46$ (cap $80$) differ by the cap and nothing else, and a separate
   post-hoc pipeline on related data produced $22.5$ — estimator-dependent
   absolutes under one invariant diagnosis.
2. **Report a lower bound.** Theorem 6.3 guarantees lower bounds are valid; the
   bootstrap lower endpoint $15.25$ is meaningful in a way its upper endpoint
   $80.0$ is not. The correct canonical description of the fitted profile is:
   *flat bulk plus a left-edge spike with steepness $\gtrsim 15$ — lower bound
   only, exact steepness unidentified at this sample size.*
3. **Report the cap-hit fraction.** The fraction of bootstrap replicates
   terminating at the bound ($26.7\%$ at cap $80$; $60\%$ at cap $40$) is the
   direct empirical signature of Corollary 5.4 and should be published alongside
   any interval.
4. **Do not treat interiority as identification.** Corollary 10.3 shows the
   role-swapped branch can be interior in the parameter of interest while the
   *other* parameter rides its bound.
5. **Separate the two claims.** Kernel existence and kernel shape have different
   epistemic statuses here: the first is established with a margin uniform in
   everything unknown (Theorem 8.5), the second is censored (Theorem 6.1). A
   report that conflates them overstates one and understates the other.
6. **A cap raise is not a remedy.** Theorem 5.5 bounds the total likelihood
   available above a cap by $C e^{-Bt}$. Resolving the steepness requires either
   substantially more data, a finer left-edge binning (larger effective $bt$
   sensitivity — note this is a change of *design*, not of optimiser), or a
   parametric commitment that makes the tail of the family compact.

**Sensitivity caveats, stated plainly.** Two properties of the analysis are worth
flagging because they interact with the theorems. First, the mass attributed to
the edge component is *binning-dependent*: a $28$-bin geometric grid and a
coarser pipeline attributed $\approx 48\%$ and $\approx 8.6\%$ respectively. This
is consistent with theory — Theorem 8.4 shows the defect scales as
$\rho(1-\rho)/k$, so the estimated $\rho$ is entangled with the grid — but it
means $\rho$ should be reported with its grid. Second, non-primary confidence
intervals in the motivating analysis were computed with $100$ rather than $300$
bootstrap replicates; that affects their precision, not the structural
conclusions, which are deterministic consequences of the theorems above.

---

## 13. Open problems and future directions

### 13.1 Defect-margin identifiability principle

The key insight is that a polynomial invariant vanishing identically on the null
family and bounded below on the alternative converts model selection into a
Lipschitz distance estimate, with no likelihood theory at all. The leading term
of this programme is proved above: for every $k \ge 1$, the defects
$D_j = p_j p_{j+2} - p_{j+1}^2$ vanish on the single-law family, equal
$\frac{\rho(1-\rho)}{k} q_j (1-r)^2$ on the mixture, and give the separation
$\rho(1-\rho)/(32k)$.

**Conjecture.** The *summed* invariant satisfies $\sum_j D_j \ge
c\,\rho(1-\rho)/k$ with $c$ absolute and with no restriction $r \le 1/2$; and the
constant $1/(8k)$ in Theorem 8.4 is sharp up to a factor $2$, attained at
$r = 1/2$.

The per-index case is settled with explicit constants; what remains is
uniformity in $r$ near $1$ (the shallow-spike regime, where the mixture
degenerates to uniform and the defect must vanish — so the conjecture requires
the correct $r$-dependent normalisation) and the summation over $j$.

### 13.2 Fisher-information collapse rate

The censoring bound $1 - F(b,t) \le 2e^{-bt}$ suggests the binned Fisher
information for $b$ decays like $e^{-2bt}$, so that the Cramér–Rao lower bound on
the standard error grows like $e^{bt}$. Making this precise — including the
multi-bin case and the profile information after eliminating $\rho$ — would turn
the qualitative statement "no finite upper limit" into a rate:
the largest resolvable steepness should scale like $\log n / t$. A companion
question is whether the observed threshold $b \gtrsim 15$ at $n = 9594$ matches
$\log n / t$ with the audited geometry.

### 13.3 Reparametrisation to a compact family

Because the pathology is the non-compactness of $(0,\infty)$ in the direction
where the observable saturates, a natural fix is to reparametrise by the *edge
mass itself*, $\pi = F(b,t) \in (0,1)$, which is a bounded, well-identified
quantity with an interior optimum whenever the data are not exactly at the
ceiling. The open question is how to do this coherently for $k$ bins at once —
i.e. which finite-dimensional compactification of the saturation curve preserves
the geometry of Section 11.

### 13.4 Design questions

Given a fixed budget of $n$ observations, which binning maximises resolvable
steepness? Theorem 8.5 says detection degrades like $1/k$; the censoring bound
says resolution improves with the effective $bt$ at the leftmost cell, which
*improves* with more bins near zero. A geometric (rather than uniform) grid,
as used in the motivating analysis, is a compromise; optimising the grid against
a stated loss is an unexplored design problem.

### 13.5 Breaking the role swap

Corollary 10.3 is exact and therefore cannot be removed by any bin-based
criterion. Standard remedies (ordering constraints $b_1 < b_2$, weight
constraints $\rho \le 1/2$) do break the symmetry, but they interact with the
censoring: an ordering constraint moves the boundary that the estimate rides.
Characterising which constraint sets leave the identified set of Section 6
unchanged is open.

---

## 14. Conclusion

For the flat-bulk-plus-edge-spike profile observed through bins, we have proved a
complete dichotomy. The steepness of the spike is censored: the edge mass is
strictly increasing in the steepness but saturates at rate $e^{-bt}$; the binned
likelihood is therefore monotone, has no finite maximiser, and rides every
imposed cap; the log-likelihood available above a cap is exponentially small; and
the identified set at any tolerance is a ray, so only lower bounds are
supportable — even though the population map remains injective, making this a
phenomenon of *tolerance* identifiability rather than a genuine parametric
degeneracy. Conversely, the existence of the spike is identified with a margin
$\rho(1-\rho)/(32k)$ in sup-norm against the entire single-law family, uniform in
the steepness, because the three-term log-convexity defect vanishes identically
on that family and is bounded below on the mixture. A separate, exact role-swap
symmetry means that interiority of an optimum is not evidence of identification.

These are properties of the model class and the observation scheme. They explain
the empirical pattern that motivated the study — a stable and overwhelming
preference for the two-component model across every cap, coexisting with a
steepness estimate that moved from $0.83$ to $40.0$ to $40.46$ as the box
changed — and they prescribe the corrected report: *flat bulk plus a left-edge
spike of steepness at least about $15$, a lower bound only, with no upper limit
supported by the data*.
