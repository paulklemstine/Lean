# The Quota Ladder of a Seed Ensemble: Order Statistics, Calibration, and the $7/8$ Median Law

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We develop the order-statistical theory of *threshold measurements repeated across random seeds*,
and apply it to a two-parameter family of empirical budget–performance thresholds. For a finite
ensemble of seeds, each reporting a threshold ("knee") $K_i$, we define the **quota ladder**
$Q(m) = \min\{b : |\{i : K_i \le b\}| \ge m\}$, the least budget satisfying at least $m$ seeds, and
prove the characterisation $Q(m) \le b \iff m \le |\mathrm{pass}(b)|$ for all feasible quotas. For
three seeds the ladder is exactly $(\min, \operatorname{med}, \max)$. We establish four groups of
results.

*(i) Robustness.* Replacing one seed moves the $m$-rung into $[Q(m-1), Q(m+1)]$ of the original
ensemble; the middle rung of $2m+1$ seeds tolerates $m$ corruptions and no more (breakdown point
$1/2$, sharp), while the top rung — the only rung that is a guarantee — has breakdown point $0$. A
quota budget is safe for every seed iff it is the full-quota budget, so safety and robustness are
in exact tension.

*(ii) Equivariance.* Order statistics commute with every monotone map; in particular grid
quantisation $\kappa \mapsto s\lceil\kappa/s\rceil$ commutes with the median, and the induced error
lies in $[0,s)$. Ratio laws read through the median are therefore not artefacts of the sweep grid.

*(iii) Calibration and amplification.* Modelling seeds as independent Bernoulli($p$) passes at a
fixed budget, the three rung distribution functions are $F_3(p)=p^3$, $F_2(p)=3p^2-2p^3$,
$F_1(p)=3p-3p^2+p^3$, ordered on $[0,1]$. At $p=1/2$ they read $1/8$, $1/2$, $7/8$: the median is
the **unique calibrated rung**, the extremes being wrong by a factor of four in opposite
directions. Moreover $F_2$ strictly amplifies majorities and attenuates minorities, has exactly the
fixed points $\{0,1/2,1\}$, and $F_2'(1/2) = 3/2 > 1$, so the calibrated point is repelling.

*(iv) The measured law.* Across two context lengths and six seeds the knee sets are
$\{96,112,128\}$ (reference $P = 128$) and $\{160,224,256\}$ (reference $P = 256$), where
$P(d,\mathrm{ctx}) = d\cdot\mathrm{ctx}/32$. The medians are $112 = \tfrac78 \cdot 128$ and
$224 = \tfrac78 \cdot 256$; $7/8$ is the unique ratio fitting both, and the two-context affine fits
of the median and the maximum are intercept-free while the low tail's is not ($\beta = 32$). This
**intercept-free dichotomy** singles out the upper half of the ladder as the carrier of context-free
ratio laws. We further show that hitting a pre-registered point prediction and preserving the
predicted distributional centre are logically independent events — all four combinations are
realised by admissible seed values — which is the precise sense in which a round can refute every
point prediction while confirming the law. Finally we give the four-seed ladder in closed form,
turning the next experiment into a single pre-registered inequality.

**Keywords.** order statistics; median; breakdown point; calibration; quota budget; threshold
estimation; monotone equivariance; ratio law.

---

## 1. Introduction

### 1.1 The measurement problem

Many empirical questions take the form: *how small can a resource budget be before performance
degrades?* One tunes a scalar budget $k$ — a number of retained memory slots, series terms, samples,
or basis vectors — measures a performance functional $c(k)$ normalised so that $c(\infty) = 1$, and
asks for the smallest $k$ at which $c(k)$ clears a fixed bar. Call that value the **knee** $k^*$.

Knees are threshold functionals, and threshold functionals are notoriously unstable. Two sources of
instability compound. First, $c$ is measured on a finite grid of budgets, so the reported knee is a
quantisation of a real number. Second, the entire training-and-evaluation pipeline depends on a
random seed, so $c$ itself is a random function and $k^*$ a random variable. Empirically these are
not small effects: at the configuration studied below, three seeds produced knees $160$, $224$ and
$256$ — a factor of $1.6$ between the extremes.

This raises a methodological question with a mathematical answer. Given an ensemble of seeds, *what
number should be reported*, and *what kind of statement about that number is falsifiable*?

### 1.2 The quota ladder

We argue that there is no single correct summary, but a canonical ladder of them, indexed by the
number of seeds one insists on satisfying. This is the **quota budget** $Q(m)$ of Definition 2.3.
For three seeds it degenerates to $(\min, \operatorname{med}, \max)$, but the general definition is
the useful one: it makes robustness, calibration, and safety statements uniform in $m$, and it
exposes exactly where the three familiar order statistics differ.

The three rungs are not interchangeable summaries of the same thing. They differ in *breakdown
point* (§3), in *calibration* (§5), and — this is the empirical discovery the theory explains — in
whether they obey a context-free scaling law at all (§6).

### 1.3 Point prediction versus centre prediction

A round of the underlying experimental programme pre-registered four point predictions for the knee
at a particular configuration: $192$, $224$, $240$, $256$. The measurement returned $160$. Every one
of the four pre-registered values *clears the bar* at the measured curve, so none of them is the
knee: all four point predictions are refuted. Simultaneously, the same round completed a three-seed
ensemble whose median is exactly $\tfrac78$ of a reference scale, replicating the same ratio at a
different context length.

Section 7 makes precise the sense in which these two verdicts are compatible: the events "the third
seed hits a pre-registered point" and "the third seed preserves the predicted median" are logically
independent, all four combinations being realised by admissible values. Section 5 explains why the
second kind of prediction is the one worth making.

---

## 2. Definitions

Throughout, budgets are natural numbers and performance values are real.

**Definition 2.1 (Knee).** Let $G \subset \mathbb{N}$ be a finite grid of budgets, $\mathrm{bar}
\in \mathbb{R}$ a threshold, and $c : \mathbb{N} \to \mathbb{R}$ a non-decreasing *retained
performance* curve. A budget $k$ is a **knee** of $(G, \mathrm{bar}, c)$ if

1. $k \in G$,
2. $\mathrm{bar} \le c(k)$, and
3. $c(j) < \mathrm{bar}$ for every $j \in G$ with $j < k$.

The knee is unique when it exists; we write $k^*$.

**Definition 2.2 (Pass set).** For a finite index set $\iota$ of seeds and knees $K : \iota \to
\mathbb{N}$, the **pass set** at budget $b$ is
$$\mathrm{pass}(b) \;=\; \{\, i \in \iota \;:\; K_i \le b \,\}.$$
It is monotone: $b \le b'$ implies $\mathrm{pass}(b) \subseteq \mathrm{pass}(b')$.

**Definition 2.3 (Quota budget).** For a quota $m \in \mathbb{N}$,
$$Q(m) \;=\; \min\{\, b \in \mathbb{N} \;:\; |\mathrm{pass}(b)| \ge m \,\},$$
the least budget at which at least $m$ seeds clear the bar. (The set is non-empty whenever
$m \le |\iota|$, since $b = \max_i K_i$ works.)

**Definition 2.4 (Median of three).** $\operatorname{med}(a,b,c) = \max(\min(a,b), \min(\max(a,b),
c))$, the middle value of the multiset $\{a,b,c\}$ in any linear order.

**Definition 2.5 (Product point).** For depth $d$ and context length $\mathrm{ctx}$,
$$P(d, \mathrm{ctx}) \;=\; \frac{d \cdot \mathrm{ctx}}{32}.$$
This is the reference scale against which knees are expressed; $P(4,1024) = 128$ and
$P(4,2048) = 256$.

**Definition 2.6 (Speedup).** A budget $k$ against context $\mathrm{ctx}$ realises
$\mathrm{speedup}(\mathrm{ctx}, k) = \mathrm{ctx}/k$.

**Definition 2.7 (Grid quantisation).** For step $s > 0$, $\mathrm{gq}_s(\kappa) = s\lceil \kappa /
s\rceil$, the reported budget when a true knee $\kappa$ is measured on a grid of step $s$.

---

## 3. The ladder and its rungs

### 3.1 The characterisation theorem

Everything downstream rests on the following equivalence, which converts an order statistic into a
counting event.

> **Theorem 3.1 (Rung Characterisation).** Let $K : \iota \to \mathbb{N}$ be an ensemble on a
> finite index set and let $m \le |\iota|$. Then for every budget $b$,
> $$Q(m) \le b \quad\Longleftrightarrow\quad m \le |\mathrm{pass}(b)|.$$

*Proof sketch.* ($\Leftarrow$) is immediate from the definition of $Q$ as an infimum. For
($\Rightarrow$), one first shows that the infimum is attained in the sense that
$m \le |\mathrm{pass}(Q(m))|$ whenever $m \le |\iota|$: the defining set is non-empty (it contains
$\max_i K_i$, at which every seed passes), so its least element $Q(m)$ lies in it. Then
$Q(m) \le b$ gives $\mathrm{pass}(Q(m)) \subseteq \mathrm{pass}(b)$ by monotonicity of the pass set,
whence $m \le |\mathrm{pass}(Q(m))| \le |\mathrm{pass}(b)|$. $\square$

Two immediate corollaries: $Q$ is non-decreasing in $m$ (for feasible quotas), and $Q(|\iota|) =
\max_i K_i$, the *certified* or all-seeds-safe budget. Also, each $Q(m)$ with $1 \le m \le |\iota|$
is *attained by some seed*: $Q(m) = K_i$ for some $i$. The ladder consists of sampled values, not
interpolations — a fact that matters when the sample lives on a grid.

### 3.2 Three seeds

> **Theorem 3.2 (Three-seed ladder).** For $K : \{1,2,3\} \to \mathbb{N}$,
> $$Q(1) = \min(K_1,K_2,K_3), \qquad Q(2) = \operatorname{med}(K_1,K_2,K_3), \qquad
> Q(3) = \max(K_1,K_2,K_3),$$
> and $Q(1) \le Q(2) \le Q(3)$.

*Proof sketch.* Expand $|\mathrm{pass}(b)| = [K_1 \le b] + [K_2 \le b] + [K_3 \le b]$ and apply
Theorem 3.1 in both directions for each $m \in \{1,2,3\}$; each case is a finite case-split on the
three indicators. Monotonicity in $m$ is the corollary above. $\square$

We call $Q(1)$ the **best-case rung**, $Q(2)$ the **centre**, $Q(3)$ the **guarantee rung**.

---

## 4. Robustness: breakdown behaviour of the rungs

### 4.1 One seed moves a rung by at most one rung

> **Theorem 4.1 (One-seed breakdown).** Let $K : \iota \to \mathbb{N}$, let $i_0 \in \iota$, let
> $x \in \mathbb{N}$, and let $K' = K[i_0 \mapsto x]$ be the ensemble with seed $i_0$ replaced by
> $x$. Then for every $m$ with $m + 1 \le |\iota|$,
> $$Q_K(m) \;\le\; Q_{K'}(m+1) \qquad\text{and}\qquad Q_{K'}(m) \;\le\; Q_K(m+1).$$

*Proof sketch.* The key counting inequality is $|\mathrm{pass}_{K'}(b)| \le |\mathrm{pass}_K(b)| +
1$, valid because $\mathrm{pass}_{K'}(b) \subseteq \mathrm{pass}_K(b) \cup \{i_0\}$ (any index other
than $i_0$ has the same knee in both ensembles). Combine with Theorem 3.1 at $b = Q_{K'}(m+1)$:
there $m+1 \le |\mathrm{pass}_{K'}(b)| \le |\mathrm{pass}_K(b)| + 1$, so $m \le
|\mathrm{pass}_K(b)|$, so $Q_K(m) \le b$. The second inequality is the same argument with the roles
of $K$ and $K'$ exchanged. $\square$

Thus a single seed can shift the $m$-rung only into the *original* ensemble's bracket
$[Q(m-1), Q(m+1)]$. For three seeds and $m = 2$ this specialises to the classical statement

> **Corollary 4.2 (Median bracket).** $\min(b,c) \le \operatorname{med}(x,b,c) \le \max(b,c)$ for
> every $x$.

and it also exhibits the fragility of the top rung: the bracket for $m = |\iota|$ has no upper
member, and indeed

> **Theorem 4.3 (The guarantee has breakdown point zero).** For all $b, c, B \in \mathbb{N}$ there
> exists $x$ with $\max(x, b, c) > B$; namely $x = B+1$.

### 4.2 The general breakdown point is $1/2$, and it is sharp

> **Theorem 4.4 (Breakdown of the centre).** Let $K, K' : \{1,\dots,2m+1\} \to \mathbb{N}$ agree
> outside a set $S$ of corrupted seeds with $|S| \le m$. Then
> $$Q_K(1) \;\le\; Q_{K'}(m+1) \;\le\; Q_K(2m+1),$$
> i.e. the middle rung of the corrupted ensemble stays inside the clean ensemble's range.

*Proof sketch.* Generalise the counting inequality of Theorem 4.1 to
$|\mathrm{pass}_{K'}(b)| \le |\mathrm{pass}_K(b)| + |S|$, using
$\mathrm{pass}_{K'}(b) \subseteq \mathrm{pass}_K(b) \cup S$; then
$Q_K(m_0) \le Q_{K'}(m_0 + |S|)$ whenever $m_0 + |S| \le |\iota|$, by Theorem 3.1. Apply with
$m_0 = 1$ and $|S| \le m$, and symmetrically for the upper bound. $\square$

> **Theorem 4.5 (Sharpness at three seeds).** For every ensemble $K$ of three seeds and every
> target $B$ there is an ensemble $K'$ differing from $K$ in exactly two coordinates with
> $\operatorname{med}(K'_1, K'_2, K'_3) = B$.

*Proof sketch.* Set two of the three coordinates to $B$. $\square$

So $m$ corruptions out of $2m+1$ are tolerated and $m+1$ are not: the breakdown point of the centre
is exactly $1/2$, the maximum attainable by any equivariant location functional.

### 4.3 Safety and robustness are in tension

> **Theorem 4.6 (Safe iff full).** For a non-empty ensemble and $m \le |\iota|$,
> $$\bigl(\forall i,\; K_i \le Q(m)\bigr) \quad\Longleftrightarrow\quad Q(m) = Q(|\iota|).$$

*Proof sketch.* If every seed passes at $Q(m)$ then $|\mathrm{pass}(Q(m))| = |\iota|$, so
$Q(|\iota|) \le Q(m)$ by Theorem 3.1, and the reverse inequality is monotonicity in $m$.
Conversely $Q(|\iota|) = \max_i K_i$ dominates every $K_i$. $\square$

The practical reading is stark. Only the top rung is a promise. Every lower rung, the median
included, is a *description*: at the median budget, each seed whose knee exceeds it demonstrably
fails the bar, by the very definition of a knee (if $k^*$ is the knee and $m < k^*$ lies on the
grid, then $c(m) < \mathrm{bar}$). Robustness is bought with guarantee, exactly and unavoidably.

---

## 5. Equivariance: the law is not a grid artefact

> **Theorem 5.1 (Monotone equivariance).** Let $\alpha, \beta$ be linear orders and $f : \alpha \to
> \beta$ monotone. Then for all $a,b,c$,
> $$\operatorname{med}(f(a), f(b), f(c)) \;=\; f\bigl(\operatorname{med}(a,b,c)\bigr).$$

*Proof sketch.* A monotone map on a linear order commutes with binary $\min$ and $\max$; the median
is a composite of two $\min$s and two $\max$s. $\square$

> **Corollary 5.2 (Quantisation commutes with the centre).** For step $s>0$ the grid map
> $\mathrm{gq}_s$ is monotone, hence
> $$\operatorname{med}\bigl(\mathrm{gq}_s(a), \mathrm{gq}_s(b), \mathrm{gq}_s(c)\bigr)
> \;=\; \mathrm{gq}_s\bigl(\operatorname{med}(a,b,c)\bigr).$$

> **Theorem 5.3 (Quantisation error of the centre).** For $s>0$ and non-negative true knees,
> $$0 \;\le\; \operatorname{med}\bigl(\mathrm{gq}_s(a),\mathrm{gq}_s(b),\mathrm{gq}_s(c)\bigr)
> - \operatorname{med}(a,b,c) \;<\; s.$$

*Proof sketch.* By Corollary 5.2 the difference equals $\mathrm{gq}_s(\mu) - \mu$ with
$\mu = \operatorname{med}(a,b,c)$, and $0 \le s\lceil \mu/s\rceil - \mu < s$ by the defining property
of the ceiling. $\square$

The methodological consequence: a coarse sweep grid can displace a measured median by strictly less
than one grid step, uniformly. It cannot manufacture a ratio law, and it cannot hide one that is
present at scale larger than $s$. The same is true of any monotone reparametrisation of the budget
axis — logarithmic, root, or otherwise — so a law read through the centre is a property of the
sample and not of the reporting scale.

---

## 6. Calibration and amplification: the probabilistic ladder

We now randomise the seeds. Fix a budget $b$ and suppose each of three independent seeds has
probability $p$ of passing, i.e. of having knee $\le b$. By Theorem 3.1, the event
$\{Q(m) \le b\}$ is exactly the event that at least $m$ seeds pass, so the *rung distribution
function* is a polynomial in $p$.

**Definition 6.1.** With Bernoulli weight $w(p, \text{pass}) = p$, $w(p, \text{fail}) = 1-p$, and
$N(x)$ the number of passes in an outcome $x \in \{\text{pass},\text{fail}\}^3$,
$$F_m(p) \;=\; \sum_{x} \mathbf{1}[\,m \le N(x)\,]\; w(p,x_1)\,w(p,x_2)\,w(p,x_3).$$

> **Theorem 6.2 (The three rung polynomials).**
> $$F_3(p) = p^3, \qquad F_2(p) = 3p^2 - 2p^3, \qquad F_1(p) = 3p - 3p^2 + p^3.$$

*Proof sketch.* Direct evaluation over the eight-point sample space, followed by expansion. For
$m=3$ only the all-pass outcome contributes; for $m=2$ the three two-pass outcomes and the all-pass
outcome contribute $3p^2(1-p) + p^3$; for $m=1$ one may equivalently compute $1 - (1-p)^3$.
$\square$

> **Theorem 6.3 (Probabilistic ladder).** For $0 \le p \le 1$, $F_3(p) \le F_2(p) \le F_1(p)$.

*Proof sketch.* $F_2 - F_3 = 3p^2(1-p) \ge 0$ and $F_1 - F_2 = 3p(1-p)^2 \ge 0$. $\square$

The combinatorial ordering $Q(1) \le Q(2) \le Q(3)$ and the probabilistic ordering
$F_3 \le F_2 \le F_1$ are the same statement seen from two sides: the higher the rung, the harder to
meet.

### 6.1 The median is the unique calibrated rung

> **Theorem 6.4 (Calibration).** $F_2(1/2) = 1/2$, whereas $F_3(1/2) = 1/8$ and $F_1(1/2) = 7/8$;
> in particular neither extreme rung is calibrated.

*Proof sketch.* Substitute $p = 1/2$ into Theorem 6.2. $\square$

Read this as a statement about *reporting*. If the underlying per-seed event is a fair coin, an
observer who reports the all-seeds-safe budget will conclude the budget suffices only $1/8$ of the
time — pessimistic by a factor of four. An observer who reports the best case concludes $7/8$ —
optimistic by the mirror factor. Only the observer who reports the centre reproduces the per-seed
frequency. The median is the unique rung of a three-seed ladder that is an unbiased *summary of the
population* in this sense.

### 6.2 The centre amplifies majorities

> **Theorem 6.5 (Amplification and attenuation).**
> If $1/2 < p < 1$ then $p < F_2(p)$. If $0 < p < 1/2$ then $F_2(p) < p$.

*Proof sketch.* $F_2(p) - p = p(2p-1)(1-p)$, whose sign is that of $2p-1$ on $(0,1)$. $\square$

> **Theorem 6.6 (Exactly three fixed points).** $F_2(p) = p \iff p \in \{0, 1/2, 1\}$.

*Proof sketch.* The factorisation $F_2(p) - p = p(2p-1)(1-p)$ again, together with the
zero-product property. $\square$

> **Theorem 6.7 (The calibrated point is repelling).** $F_2'(1/2) = 3/2 > 1$.

*Proof sketch.* $F_2'(p) = 6p - 6p^2$; evaluate at $p=1/2$. $\square$

This trio is the quantitative content of the slogan "the centre of three seeds is the robust
reading". It is not merely that the median is insensitive to one outlier (Corollary 4.2, a
worst-case statement); it is that in the average case the median *sharpens* a tendency present in
the per-seed law. The map $p \mapsto 3p^2 - 2p^3$ is the classical majority-amplification map, and
$3/2 > 1$ at the symmetric point is exactly the statement that the symmetric point is unstable —
the mechanism by which repeated sampling turns a weak per-seed bias into a strong ensemble
regularity.

> **Corollary 6.8 (Quantitative reading for the recorded data).** Take the observed frequency as the
> per-seed probability: four of the six recorded seeds (two of three at each context) have knee at
> or below the $7/8$ budget, giving $p = 2/3$. Then
> $$F_2(2/3) = \frac{20}{27} \approx 0.741 \;>\; \frac{2}{3}, \qquad
> F_3(2/3) = \frac{8}{27} \approx 0.296 \;<\; \frac{2}{3}.$$

The three-seed median lands at or below the $7/8$ budget with probability $20/27$, while the
guarantee rung does so with probability only $8/27$. The gap $20/27 - 8/27 = 12/27 \approx 0.44$ is
what "reading the centre" buys, in this data, over "reading the guarantee".

---

## 7. The measured law

### 7.1 Data

The empirical object is the retained-accuracy curve of a causal language model under data-free
top-$k$ attention truncation, evaluated on a held-out split against a bar of $0.98$ of full-model
accuracy, at depth $d = 4$ and two context lengths. At $\mathrm{ctx} = 2048$, seed $3$, the measured
curve on the grid $\{96, 128, 160, 192, 224, 240, 256, 288, 384, 512, 768, 1024\}$ is

| $k$ | 96 | 128 | **160** | 192 | 224 | 240 | 256 | 288 | 384 | 512 | 768 | 1024 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| retained | 0.963 | 0.973 | **0.981** | 0.984 | 0.986 | 0.987 | 0.990 | 0.993 | 0.999 | 1.000 | 1.003 | 1.003 |

with full accuracy $0.1546$ and bar $0.1516$, i.e. a retained bar of $0.98$.

> **Proposition 7.1 (Knee and refutations).** For any monotone curve agreeing with the table above:
> the knee is $k^* = 160$; the four pre-registered values $192, 224, 240, 256$ all clear the bar and
> therefore none of them is the knee; and $160 \le 256$, so the product point remains a safe budget.

*Proof sketch.* $c(160) = 0.981 \ge 0.98$ while $c(96) = 0.963$ and $c(128) = 0.973$ are below the
bar, and these are the only grid points below $160$; hence $160$ is the knee. Uniqueness of the knee
refutes each of the four alternatives. $\square$

The knee margin is $0.001$, the narrowest of the recorded cells; the reading is genuinely razor-thin
and should be treated as locating the true (off-grid) knee somewhere in $[150,160]$.

Across three seeds at each context, the knee sets are

| context | knee set | as multiples of $P$ | spread | median |
|---|---|---|---|---|
| $\mathrm{ctx}=1024$, $P=128$ | $\{96, 112, 128\}$ | $\{0.750, 0.875, 1.000\}$ | $0.250$ | $112$ |
| $\mathrm{ctx}=2048$, $P=256$ | $\{160, 224, 256\}$ | $\{0.625, 0.875, 1.000\}$ | $0.375$ | $224$ |

### 7.2 The median law

> **Theorem 7.2 (The $7/8$ median law).** With $P(d,\mathrm{ctx}) = d\cdot\mathrm{ctx}/32$,
> $$\operatorname{med}(256, 224, 160) = 224 = \tfrac78 \cdot P(4, 2048), \qquad
> \operatorname{med}(128, 112, 96) = 112 = \tfrac78 \cdot P(4, 1024).$$
> Equivalently, in ladder language, $Q(2) = \tfrac78 P$ at both contexts, while $Q(3) = P$ at both.

> **Theorem 7.3 (Uniqueness of the ratio).** $\alpha \cdot 128 = 112$ and $\alpha \cdot 256 = 224$
> hold simultaneously iff $\alpha = 7/8$. Likewise $\alpha \cdot 128 = 128$ and
> $\alpha \cdot 256 = 256$ hold iff $\alpha = 1$.

> **Theorem 7.4 (The low tail admits no ratio law).** There is no $\alpha$ with
> $\alpha \cdot 128 = 96$ and $\alpha \cdot 256 = 160$; the two ratios are $3/4$ and $5/8$.

*Proof sketch of 7.3–7.4.* Each is a two-equation linear system in one unknown; the first two are
consistent, the third forces $\alpha = 3/4$ from the first equation and then fails the second
($3/4 \cdot 256 = 192 \ne 160$). $\square$

### 7.3 The intercept-free dichotomy

Fit each rung with the two-parameter affine law $L_{\alpha,\beta}(\mathrm{ctx}) = \alpha\,
\mathrm{ctx} + \beta$ through the two measured contexts.

> **Theorem 7.5 (Intercept-free dichotomy).**
> - Median: $L(1024) = 112$, $L(2048) = 224$ force $\alpha = 7/64$, $\beta = 0$.
> - Maximum: $L(1024) = 128$, $L(2048) = 256$ force $\alpha = 1/8$, $\beta = 0$.
> - Minimum: $L(1024) = 96$, $L(2048) = 160$ force $\alpha = 1/16$, $\beta = 32 \ne 0$.
>
> Thus exactly the upper two rungs of the three-seed ladder admit context-free ratio laws.

*Proof sketch.* Each is a $2\times 2$ linear system with determinant $1024 \ne 0$, hence uniquely
solvable; subtracting the equations gives $\alpha$ and back-substitution gives $\beta$. $\square$

**Interpretation.** A non-zero intercept is the signature of a *floor*: a fixed budget that must be
paid before any context-proportional benefit accrues. Only the optimistic rung, which is dominated
by whichever seed happened to concentrate its attention most tightly, is positioned to see that
floor; the centre and the guarantee average over seeds and the floor disappears into the slope.

### 7.4 Spread

> **Theorem 7.6 (The spread widens, and is bounded below).** The normalised spreads are
> $(128-96)/128 = 1/4$ and $(256-160)/256 = 3/8$, so the spread grows. Moreover, if the upper edge
> is pinned at ratio $1$ and the median sits at ratio $7/8$, then for any low-tail ratio
> $\ell \le 7/8$ the spread satisfies $1 - \ell \ge 1/8$, with equality iff $\ell = 7/8$.

Since the upper edge is pinned at $1$ and the centre at $7/8$, all of the widening is carried by the
low tail: $0.750 \to 0.625$. The low tail is the context-growing quantity.

### 7.5 Deployment: speedups

> **Theorem 7.7 (Context-freeness of the upper rungs' speedups).** For $d, \mathrm{ctx} > 0$,
> $$\mathrm{speedup}\bigl(\mathrm{ctx}, P\bigr) = \frac{32}{d}, \qquad
> \mathrm{speedup}\bigl(\mathrm{ctx}, \tfrac78 P\bigr) = \frac{256}{7d}.$$
> Both are independent of $\mathrm{ctx}$; at $d = 4$ they are $8$ and $64/7 \approx 9.14$.

*Proof sketch.* $\mathrm{ctx} / (d\,\mathrm{ctx}/32) = 32/d$ and
$\mathrm{ctx} / (\tfrac78 \cdot d\,\mathrm{ctx}/32) = 256/(7d)$; the $\mathrm{ctx}$ cancels.
$\square$

> **Theorem 7.8 (The best case is not context-free, but is bounded).** The measured best-case
> speedups are $1024/96 = 32/3 \approx 10.67$ and $2048/160 = 12.8$, which differ. Under the affine
> low-tail law $k = \mathrm{ctx}/16 + 32$,
> $$\mathrm{speedup}\Bigl(\mathrm{ctx}, \frac{\mathrm{ctx}}{16} + 32\Bigr)
> = \frac{16\,\mathrm{ctx}}{\mathrm{ctx} + 512} \;<\; 16,$$
> strictly increasing in $\mathrm{ctx}$ and reproducing $32/3$ and $12.8$ at the two measured
> contexts.

*Proof sketch.* Algebra for the identity; the bound follows from
$16\mathrm{ctx} < 16\mathrm{ctx} + 8192$; monotonicity from
$\frac{d}{d\mathrm{ctx}}\frac{16\mathrm{ctx}}{\mathrm{ctx}+512} = \frac{8192}{(\mathrm{ctx}+512)^2}
> 0$. $\square$

So the deployment reading at $(d,\mathrm{ctx}) = (4, 2048)$ is a *distribution of speedups*
$\{8.0\times,\ 9.1\times,\ 12.8\times\}$: guaranteed, typical, best. The guarantee end is
six-seed-verified across both contexts; the best-case end saturates below $16\times$ under the
affine reading.

---

## 8. Point prediction and centre prediction are independent

Let the recorded seeds be $224$ and $256$ and let $x$ denote a third seed.

> **Theorem 8.1 (Exact stability family).** For $b < c$, $\operatorname{med}(x,b,c) = b \iff x \le
> b$. In particular $\operatorname{med}(x, 224, 256) = 224$ iff $x \le 224$; the tested grid values
> $160, 192, 224$ all preserve the median, and $240$ does not.

*Proof sketch.* If $x \le b$ then $x$ is the smallest of the three and $b$ the middle; if $x > b$
then the middle value is $\min(x,c) > b$. $\square$

> **Theorem 8.2 (Logical independence).** Let $H = \{192, 224, 240, 256\}$ be the set of
> pre-registered point predictions. All four combinations of the two events "$x \in H$" and
> "$\operatorname{med}(x, 224, 256) = 224$" are realised:
>
> | | preserves centre | breaks centre |
> |---|---|---|
> | $x \in H$ | $x = 224$ | $x = 240$ |
> | $x \notin H$ | $x = 160$ | $x = 288$ |

Hence no logical relation holds between the two, in either direction: point accuracy neither implies
nor is implied by centre accuracy. The measured round realises the bottom-left cell — $0$ of $4$
point predictions and $1$ of $1$ law.

> **Corollary 8.3 (Asymmetry of refutability).** For any $x \notin H$ with $x \le 224$, the round
> simultaneously refutes every point prediction and confirms the centre.

It is worth stating explicitly what would have refuted the law: any $x \ge 240$. Such values were
available and indeed occupied by the two other seeds, so the centre prediction was a genuine risk,
not a tautology.

---

## 9. The pre-registered four-seed test

Adjoin a fourth seed $x$ to the recorded ensemble $\{256, 224, 160\}$ at $\mathrm{ctx} = 2048$.

> **Theorem 9.1 (The four-seed ladder in closed form).** For $K = (256, 224, 160, x)$,
> $$Q(2) = \min\bigl(224, \max(160, x)\bigr), \qquad
> Q(3) = \max\bigl(224, \min(256, x)\bigr), \qquad
> Q(4) = \max(256, x).$$
> In particular $Q(3) = 224$ **iff** $x \le 224$.

*Proof sketch.* Expand $|\mathrm{pass}(b)| = [256 \le b] + [224 \le b] + [160 \le b] + [x \le b]$
and apply Theorem 3.1 in both directions; each rung is a finite case analysis on the four
indicators. $\square$

This converts the next experiment into a single pre-registered inequality. Two hypotheses about the
$7/8$ centre are on the table.

- **$H_{\text{const}}$:** the centre sits at $7/8$ of the product point for every ensemble size.
  Then the four-seed upper median should remain $224$, i.e. $x \le 224$.
- **$H_{\text{order}}$:** the observed $7/8$ is the $n = 3$ instance of $1 - 2^{-n}$, the median of
  the maximum of $n$ exchangeable draws from a uniform law, the product point playing the role of
  the supremum. Then a fourth seed should push the centre toward $15/16 \cdot 256 = 240$, i.e.
  $x \in (224, 256]$.

The rung polynomials $p^3$, $3p^2 - 2p^3$, $3p - 3p^2 + p^3$ of §6 are exactly the $n = 3$ instance
of the order-statistic computation underlying $H_{\text{order}}$, so the two hypotheses are
commensurable and differ by one grid step. One run of the existing harness decides between them.

Similarly at $\mathrm{ctx} = 4096$: the two low-tail families separate by
$$\tfrac{5}{64}\mathrm{ctx} - \bigl(\tfrac{1}{16}\mathrm{ctx} + 32\bigr) = \frac{\mathrm{ctx}}{64}
- 32,$$
which is $0$ at $\mathrm{ctx} = 2048$ (where both were fitted) and exactly one grid step $32$ at
$\mathrm{ctx} = 4096$: constant-ratio predicts $320$, affine predicts $288$. Note also that the
constant-ratio family fails backwards — it gives $80$ at $\mathrm{ctx} = 1024$ where $96$ was
measured, whereas the affine family reproduces $96$ exactly. The median law predicts
$\tfrac{7}{64}\cdot 4096 = 448 = \tfrac78 \cdot 512$.

---

## 10. Algorithms

Three procedures are implicit in the development; we state them explicitly, with complexity.

**Algorithm A (Knee extraction).** Given a grid $G$ of size $g$ sorted increasingly, a bar, and
retained values $c$, return the first $k \in G$ with $c(k) \ge \mathrm{bar}$. Linear scan:
$O(g)$ time, $O(1)$ space. If $c$ is known to be monotone, binary search gives $O(\log g)$, but
measured curves are only approximately monotone, and the linear scan matches the definition of a
knee exactly.

**Algorithm B (Quota ladder).** Given $n$ knees, return $Q(1), \dots, Q(n)$. Sort the knees; then
$Q(m)$ is the $m$-th order statistic. $O(n \log n)$ time. Correctness is Theorem 3.1: at the $m$-th
smallest knee exactly $m$ seeds (at least) have passed, and no smaller budget achieves that.

**Algorithm C (Rung distribution functions).** Given $n$ and $p$, return
$F_m(p) = \sum_{j \ge m} \binom{n}{j} p^j (1-p)^{n-j}$ for each $m$. $O(n^2)$ time by Pascal's
triangle, or $O(n)$ with a running binomial. For $n = 3$ this reproduces Theorem 6.2 symbolically.

**Algorithm D (Two-context affine fit and dichotomy test).** Given two contexts $c_1 \ne c_2$ and
rung values $v_1, v_2$, solve $\alpha = (v_2 - v_1)/(c_2 - c_1)$, $\beta = v_1 - \alpha c_1$, and
report the rung as *ratio-lawful* iff $\beta = 0$. $O(1)$. Applied to the three rungs it produces
the dichotomy of Theorem 7.5.

---

## 11. Discussion

### 11.1 What kind of law is a median law?

A point law asserts a value; a centre law asserts a functional of a distribution. The latter is
weaker at any single draw and stronger across draws — and, crucially, it is the kind of law a noisy
threshold can actually satisfy. Sections 4 and 6 give two independent justifications for choosing
the median as that functional: it has the maximal breakdown point ($1/2$, Theorems 4.4–4.5), and it
is the unique calibrated rung (Theorem 6.4) with a repelling calibrated point (Theorem 6.7). No
other order statistic of three has both properties, and no non-order statistic (e.g. the mean) has
the equivariance of Theorem 5.1, which is what protects the law from the reporting grid.

### 11.2 Honest limitations

- The seed-3 knee reading has margin $0.001$ at the bar; with a binomial standard error of about
  $0.11\%$ in accuracy (roughly $0.007$ in retained units) this single reading is not resolved
  beyond noise, and the true off-grid knee is best located in $[150, 160]$. The knee-set *median*,
  however, is insensitive to this: any third-seed value $\le 224$ leaves it at $224$ (Theorem 8.1).
- The $0.625$ low tail rests on one seed of three. A fourth seed is needed to distinguish a stable
  low-tail feature from a seed-specific one.
- The median law is verified at two contexts and six seeds. Two points determine a ratio; the third
  context is the real test, and §9 pre-registers what it should show.
- No bounded working set was observed: the effective attention support (about $498$ at the studied
  seed, against $526$ and $472$ at the others, an $11\%$ spread) does not sort with the knee across
  the three seeds — the highest-support seed has the highest knee, the lowest-support seed has the
  middle knee, and the middle-support seed the lowest. Concentration statistics therefore do not
  explain the knee at this scale.
- Selection matters and its importance is strongly seed-dependent: at the studied seed, retaining a
  random subset of the same size scores $0.926$ against $0.973$ for the top-$k$ subset at
  $k = 128$, and $0.956$ against $0.990$ at $k = 256$ — gaps of $+4.7$ and $+3.4$ points. Across
  the three seeds the $k = 128$ gap ranges over $\{1.7, 4.4, 4.7\}$, a threefold spread.

### 11.3 Relation to classical statistics

Every ingredient here is classical in isolation: the median's $1/2$ breakdown point is standard
robust-statistics material; $3p^2 - 2p^3$ is the majority-vote amplification polynomial familiar
from reliability theory and from the analysis of Boolean functions; monotone equivariance of order
statistics is elementary. What is new is the *combination as a methodology for threshold
measurement*: the quota ladder as the object reported, the Rung Characterisation as the bridge
between combinatorial and probabilistic statements about it, and the intercept-free dichotomy as an
empirical criterion for which rungs can carry scaling laws at all.

### 11.4 Applications beyond the measured system

The theory assumes only: a monotone performance functional of a scalar budget, a bar, a grid, and a
seed ensemble. That covers a great deal — truncation thresholds in numerical linear algebra,
sample-size thresholds in Monte Carlo pipelines, sparsity thresholds in compressed sensing,
early-stopping budgets in optimisation. In each case the recommendations are the same: report the
whole ladder, quote the top rung as the guarantee, fit scaling laws through the centre, and treat a
non-zero intercept in a rung's fit as evidence of a fixed floor visible only to the optimistic tail.

---

## 12. Future work

1. **Rung-indexed scaling exponents.** Conjecture: for fixed depth, the $m$-th rung of an $n$-seed
   ladder obeys $Q_m(\mathrm{ctx}) = \alpha_m P(\mathrm{ctx}) + \beta_m$ with $\beta_m = 0$ exactly
   for the upper half $m > n/2$. Verified instance: $\beta = 0$ for the median ($\alpha = 7/8$) and
   the maximum ($\alpha = 1$), $\beta = 32$ for the minimum.
2. **Is $7/8$ really $1 - 2^{-n}$?** The competing readings of §9 differ by one grid step at the
   next seed and are decided by the single inequality $x \le 224$.
3. **General-$n$ calibration.** For $n$ seeds the middle rung's distribution function is the
   regularised incomplete beta function $I_p(\lceil n/2 \rceil, \lfloor n/2 \rfloor + 1)$; the
   analogue of Theorem 6.7 is that its derivative at $p = 1/2$ grows like $\sqrt{n}$, so the
   sharpening effect of the centre strengthens with ensemble size at a computable rate. Making this
   precise, with explicit constants, is the natural generalisation of §6.
4. **Rung-Lipschitz stability as an empirical law.** Theorem 4.1 bounds the movement of a rung under
   one seed replacement by one rung. Is the *typical* movement much smaller — and is there a
   quantitative Lipschitz constant relating rung displacement to per-seed variance?
5. **Extrapolation.** At $\mathrm{ctx} = 4096$ the low-tail families split by exactly one grid step
   ($320$ versus $288$), and the median law predicts $448$. A single run tests three predictions at
   once.
