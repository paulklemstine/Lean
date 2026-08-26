# Resolution Floors for Cluster-Structured Pythagorean Search, and the Rejection of a Twice-Gated Drift Anomaly

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

We report the rejection, by directional disagreement between independent random seeds, of a candidate few-percent deviation from randomness in a large clustered Pythagorean-type search, and we develop the analysis-side mathematics that makes this outcome structurally predictable rather than merely empirical.

The experiment compares a candidate hit count against a control hit count across $m$ disjoint clusters (indexed by modulus, equivalently by hypotenuse), reports the pooled ratio $r = \sum_i x_i / \sum_i y_i$, and attaches a nonparametric cluster-bootstrap confidence interval. Three earlier legs, all descending from a single random stream, reported $r < 1$ (deficits of $1$–$5\%$) with intervals excluding $1$ from below. An arbiter run on a fresh, uncontaminated seed — band-9, $96$-bit moduli, $128$ clusters, $6\times10^5$ pairs per cluster, $7.68\times10^7$ pairs total — reports $r = 2598/2252 = 1.1536$ with interval $[1.0540,\,1.2611]$ at the primary cut and $r = 40617/38594 = 1.0524$ with $[1.0051,\,1.1016]$ at the looser cut: a **surplus**, excluding $1$ from *above*.

We prove four groups of results. (1) A **coverage-incompatibility theorem**: two events that are disjoint cannot each have probability $\ge 1-\alpha$ unless $\alpha \ge 1/2$; with $s$ pairwise-incompatible runs, $s(1-\alpha)\le 1$. Applied to the recorded intervals, at least one nominal $95\%$ coverage claim is false, or the seed families do not share an estimand. (2) An **exact cluster-bootstrap variance identity**: for a centred cluster vector $d$ and $n$ draws with replacement from $m$ clusters, $m\sum_f(\sum_k d_{f(k)})^2 = n\,m^n \sum_i d_i^2$; specialising to $n=m$ shows the bootstrap variance of the resampled total is exactly $\sum_i (x_i-\bar x)^2$, so the relative dispersion functional we use *is* the bootstrap's relative standard error. (3) A **resolution floor**: $x_j/S - 1/m \le \mathrm{rsd}(x)$ for every cluster $j$, instantiating at the recorded profile ($m=128$, top cluster $600$, total $40617$) to a nonzero floor exceeding $0.0069$, against which the reported half-width $0.048$ is consistent. (4) **Unbounded hypotenuse multiplicity**: for every $k$ there is a hypotenuse whose set of ordered positive leg pairs has at least $k$ elements, via $C_k = \prod_{v<k}((v+2)^2+1)$; combined with (3) this yields genuine two-cluster Pythagorean families whose one-run relative resolution floor is arbitrarily close to $1/2$.

We also record a **mediant envelope** for pooled ratios, an **inverse-variance pooling** certificate for the round's named follow-up condition ($\ge 3$ distinct seeds reach a joint standard error below $0.02$), and a formal statement of the display-truncation artefact that triggered one of the audit alarms. The verdict is *randomness-extended, gate rejected*: the randomness line extends through the next scale band with a measured $\pm5$–$15\%$ single-run fluctuation envelope, and neither the deficit nor the surplus is banked.

**Keywords:** Pythagorean triples, hypotenuse multiplicity, cluster bootstrap, overdispersion, resolution floor, mediant inequality, inverse-variance pooling, confidence-interval coverage.

---

## 1. Introduction

### 1.1 The experimental setting

Consider a search over Pythagorean-type configurations at a fixed scale band. For each of $m$ moduli $N_1,\dots,N_m$ (the *clusters*), the search samples a large number of pairs and records how many are *hits* — configurations satisfying the relation under test. Two streams run in parallel:

* a **candidate** stream, drawn from the structured arithmetic family whose behaviour is in question, producing counts $x_1,\dots,x_m$;
* a **control** stream, deliberately structureless, producing counts $y_1,\dots,y_m$.

The reported summary statistic is the pooled ratio

$$r \;=\; \frac{\sum_{i=1}^m x_i}{\sum_{i=1}^m y_i},$$

with a nonparametric **cluster bootstrap** confidence interval: the $m$ clusters are resampled i.i.d. uniformly with replacement, their counts re-added, and the empirical quantiles of the resampled ratio taken as the interval. Under the null hypothesis that the candidate family is arithmetically indistinguishable from the control at this scale, $r$ should concentrate at $1$.

### 1.2 The anomaly and its death

Three successive rounds of this experiment reported $r$ below $1$: point estimates $0.9468$ (pilot), $0.988$ (gate leg G1), $0.9623$ (leg B), all at the looser cut. Each attached an interval excluding $1$. The apparent evidence for a *deficit* — a suppression of candidate hits relative to control, i.e. a genuine deviation from randomness — was accumulating across what looked like independent legs.

An independence audit revealed that all three legs descended from the same random stream (seed family $20260824$). An arbiter run was commissioned on a fresh seed ($20260825$), the only leg uncontaminated by the shared stream. Its parameters: band-9, $96$-bit moduli, $m = 128$ clusters, $6\times 10^5$ sampled pairs per cluster, total $7.68\times 10^7$ pairs, wall-clock $5296.9$ s.

Its results:

| cut | candidate | control | $r$ | $95\%$ interval |
|---|---|---|---|---|
| primary ($10^{-5}$) | $2598$ | $2252$ | $\mathbf{1.1536}$ | $[1.0540,\;1.2611]$ |
| looser ($10^{-6}$) | $40617$ | $38594$ | $\mathbf{1.0524}$ | $[1.0051,\;1.1016]$ |

Both intervals exclude $1$ **from above**. The clean seed reads a $+5$ to $+15\%$ *surplus* where the contaminated family read a deficit. The disagreement is *directional*, not merely one of magnitude, and Section 3 shows that directional disagreement is a strictly stronger refutation than magnitude disagreement: it falsifies at least one nominal coverage claim outright.

The verdict recorded is **randomness-extended / gate rejected**. The candidate deviation is dead. By symmetric skepticism the surplus is *also* not banked: it is a single run, and it lies inside the fluctuation envelope that Sections 4–6 show is unavoidable.

### 1.3 Contribution

The empirical outcome is one seed disagreeing with another. Its scientific value is limited unless one can say *why* a single run of $7.7\times10^7$ pairs could not have settled the question in the first place. That is what this paper supplies. We prove:

1. **Mediant envelope** (§2): the pooled ratio is trapped between attained per-cluster ratios; a pooled surplus forces a cluster-level surplus; a dominant cluster can dictate the pooled value.
2. **Coverage incompatibility** (§3): the sign-flip audit, in the form of a two-line union bound, plus its multi-run generalisation.
3. **Exact bootstrap variance identity** (§4): the dispersion functional used in the floors is precisely the cluster bootstrap's relative standard error, not an ad-hoc proxy.
4. **Resolution floor** (§5): $\mathrm{rsd}(x) \ge x_j/S - 1/m$, instantiated at the recorded profile.
5. **Unbounded hypotenuse multiplicity** (§6): overdispersion is intrinsic to Pythagorean arithmetic; consequently there are genuine cluster families with resolution floor arbitrarily close to $1/2$.
6. **Inverse-variance pooling** (§7): the follow-up condition of $\ge 3$ distinct seeds provably reaches the declared target precision.
7. **Truncation artefact** (§8): the formatting alarm, stated precisely and dismissed.

---

## 2. The mediant envelope for pooled ratios

Throughout, $s$ is a finite nonempty index set of clusters and $x, y : s \to \mathbb{R}$ are count vectors with $y_i > 0$ for all $i \in s$.

**Definition 2.1 (Pooled ratio).** The pooled candidate/control ratio is $r(x,y) = \bigl(\sum_{i\in s} x_i\bigr)/\bigl(\sum_{i\in s} y_i\bigr)$.

**Lemma 2.2 (Mediant upper bound).** *If $x_i/y_i \le M$ for all $i \in s$, then $r(x,y) \le M$.*

*Proof.* Since $y_i > 0$, the hypothesis is equivalent to $x_i \le M y_i$ for each $i$. Summing, $\sum_i x_i \le M \sum_i y_i$. As $\sum_i y_i > 0$ (a sum of positives over a nonempty set), division gives the claim. $\square$

**Lemma 2.3 (Mediant lower bound).** *If $\mu \le x_i / y_i$ for all $i \in s$, then $\mu \le r(x,y)$.*

*Proof.* Symmetric: $\mu y_i \le x_i$ for each $i$, sum, divide by $\sum_i y_i > 0$. $\square$

**Theorem 2.4 (Mediant envelope).** *There exist clusters $\ell, u \in s$ with*
$$\frac{x_\ell}{y_\ell} \;\le\; r(x,y) \;\le\; \frac{x_u}{y_u}.$$

*Proof.* Since $s$ is finite and nonempty, the function $i \mapsto x_i/y_i$ attains a minimum at some $\ell$ and a maximum at some $u$. Apply Lemma 2.3 with $\mu = x_\ell/y_\ell$ and Lemma 2.2 with $M = x_u/y_u$. $\square$

**Corollary 2.5 (A pooled surplus is never an aggregation artefact).** *If $r(x,y) > 1$ then $y_i < x_i$ for at least one cluster $i \in s$.*

*Proof.* Suppose not; then $x_i \le y_i$, hence $x_i/y_i \le 1$, for every $i$. Lemma 2.2 with $M=1$ gives $r(x,y)\le 1$, contradicting the hypothesis. $\square$

**Discussion.** Corollary 2.5 is the "cluster structure is honest" audit statement: the arbiter's $r = 1.1536$ cannot be a pure aggregation effect, because some cluster genuinely produced more candidate than control hits. Theorem 2.4 carries the complementary warning. The pooled ratio is a *mediant*, and a mediant is dominated by its largest-denominator terms. A single cluster carrying a large share of the control mass can drag $r$ to its own ratio. This makes $r$ a weighted-median-like statistic whose sensitivity is governed by the biggest clusters — and §6 shows those can be arbitrarily big.

---

## 3. The sign-flip audit: disjoint intervals cannot both cover

Fix a probability space $(\Omega,\mathcal{F},\mathbb{P})$ carrying whatever randomness (sampling, seeds) the runs consume, and let $\rho$ be the estimand: the true limiting candidate/control ratio at this scale band, modelled as a random variable or a constant on $\Omega$.

**Theorem 3.1 (Coverage incompatibility).** *Let $A, B \subseteq \Omega$ be disjoint events with $\mathbb{P}(A) \ge 1-\alpha$ and $\mathbb{P}(B) \ge 1-\alpha$. Then $1 \le 2\alpha$.*

*Proof.* Disjointness gives $\mathbb{P}(A\cup B) = \mathbb{P}(A)+\mathbb{P}(B) \ge 2(1-\alpha)$. Since $A\cup B \subseteq \Omega$, monotonicity gives $\mathbb{P}(A\cup B)\le 1$. Combining, $2 - 2\alpha \le 1$. $\square$

**Corollary 3.2 (No joint $95\%$ coverage across a sign flip).** *If $A$ and $B$ are disjoint and $\mathbb{P}(A) \ge 0.95$ and $\mathbb{P}(B)\ge 0.95$, a contradiction follows.*

*Proof.* Theorem 3.1 with $\alpha = 0.05$ yields $1 \le 0.1$. $\square$

**Theorem 3.3 (Multi-run sign-partition bound).** *Let $A_1,\dots,A_s$ be pairwise disjoint measurable events with $\mathbb{P}(A_i) \ge 1-\alpha$ for each $i$. Then $s(1-\alpha) \le 1$, equivalently $\alpha \ge 1 - 1/s$.*

*Proof.* By pairwise disjointness, $\mathbb{P}(\bigcup_i A_i) = \sum_i \mathbb{P}(A_i) \ge s(1-\alpha)$, and the union is contained in $\Omega$. $\square$

**Application to the recorded data.** The arbiter's $\mathrm{cut}_{10^{-6}}$ interval is $[1.0051,\,1.1016]$, contained in $\{\rho \ge 1.0051\}$. The $20260824$ family's intervals all lie in $(0,1]$, contained in $\{\rho \le 1\}$. These two sets are disjoint subsets of $\mathbb{R}$, hence the corresponding coverage events are disjoint in $\Omega$. Corollary 3.2 therefore says: it is **impossible** that both families' nominal $95\%$ intervals cover the same $\rho$.

This is the exact ground of the rejection, and it deserves emphasis for three reasons.

1. It is *assumption-light*. No normality, no independence between the runs, no model for the sampler. Only countable additivity and $\mathbb{P}(\Omega)=1$.
2. It is *sign-based, not magnitude-based*. A gate that fails because two runs disagree on a number can sometimes be repaired by widening the intervals. A gate that fails because two runs disagree on a *direction* cannot: no widening of both intervals preserves the exclusion of $1$ that made the gate fire in the first place. Failure by sign is strictly stronger.
3. It is *symmetric*. Theorem 3.1 does not identify a guilty party. Either the deficit family, or the surplus arbiter, or both, is misreporting coverage — or the two are not estimating the same quantity, which is itself fatal to the gate.

The recorded point estimates do straddle $1$ in the strict sense: $0.9468 < 1 < 40617/38594$ and $1 < 2598/2252$. A further diagnostic: $40617/38594 < 2598/2252$, i.e. the apparent effect *shrinks* as the cut is loosened and the counts grow. A scale-stable arithmetic deviation would not behave that way; a fluctuation would.

**Symmetric skepticism.** Because Theorem 3.1 is agnostic, the correct response is to bank nothing. The arbiter's surplus is a single run whose interval lies inside the $\pm 5$–$15\%$ envelope that the remaining sections show is structurally unavoidable at this cluster profile.

---

## 4. The cluster bootstrap, exactly

The intervals above were produced by a specific resampling scheme. Any theorem intended to constrain them must be a theorem about *that* scheme, not about a convenient surrogate. This section supplies the exact identity.

**Definition 4.1 (Resample).** Let $\iota$ be a finite nonempty cluster index type with $m = |\iota|$. A *resample of length $n$* is a map $f : \{1,\dots,n\} \to \iota$, interpreted as drawing $n$ clusters i.i.d. uniformly with replacement. All $m^n$ resamples are equally likely, so expectations are sums divided by $m^n$. Given cluster counts $x : \iota \to \mathbb{R}$, the *resampled total* is $T^\ast(f) = \sum_{k=1}^n x_{f(k)}$.

**Lemma 4.2 (Centred resampled totals sum to zero).** *Let $d : \iota\to\mathbb{R}$ satisfy $\sum_i d_i = 0$. Then for every $n \ge 0$,*
$$\sum_{f : \{1,\dots,n\}\to\iota} \; \sum_{k=1}^n d_{f(k)} \;=\; 0.$$

*Proof.* Induction on $n$. For $n=0$ the outer sum has one term, the empty sum, which is $0$. For the step, decompose a resample of length $n+1$ as a pair $(a, f)$ with $a \in \iota$ the first draw and $f$ a resample of length $n$; then $\sum_k d = d_a + \sum_k d_{f(k)}$. Summing over $f$ first, the second term contributes $0$ by the inductive hypothesis, and the first contributes $m^n d_a$. Summing over $a$ gives $m^n \sum_a d_a = 0$. $\square$

**Theorem 4.3 (Cluster bootstrap second-moment identity).** *Let $d : \iota\to\mathbb{R}$ with $\sum_i d_i = 0$, and let $n\ge 0$. Then*
$$m \sum_{f:\{1,\dots,n\}\to\iota}\Bigl(\sum_{k=1}^n d_{f(k)}\Bigr)^2 \;=\; n\, m^{\,n} \sum_{i\in\iota} d_i^2 .$$

*Proof.* Write $D = \sum_i d_i^2$ and $Q_n = \sum_{f}\bigl(\sum_k d_{f(k)}\bigr)^2$, the sum ranging over resamples of length $n$; the claim is $mQ_n = n m^n D$. Induct on $n$. The base case $n=0$ reads $0=0$. For the step, use the first-draw decomposition $f \leftrightarrow (a, f')$ with $a\in\iota$ and $f'$ of length $n$, and expand
$$\Bigl(d_a + \sum_k d_{f'(k)}\Bigr)^2 = d_a^2 + 2 d_a \sum_k d_{f'(k)} + \Bigl(\sum_k d_{f'(k)}\Bigr)^2 .$$
Sum over all $(a,f')$. The first term contributes $m^n D$ (there are $m^n$ choices of $f'$). The **cross term vanishes**: for each fixed $a$, summing over $f'$ gives $2 d_a \cdot 0$ by Lemma 4.2. The third term does not depend on $a$, so it contributes $m\,Q_n$. Hence
$$Q_{n+1} \;=\; m^n D + m\,Q_n .$$
Multiplying by $m$ and applying the inductive hypothesis $mQ_n = n m^n D$,
$$m\,Q_{n+1} \;=\; m^{n+1} D + m\,(n m^n D) \;=\; (n+1)\,m^{\,n+1} D,$$
which is the claim at $n+1$. $\square$

Dividing Theorem 4.3 by $m\cdot m^n$ gives the interpretation: the resampled total of a centred vector has variance $n \cdot \bigl(\sum_i d_i^2\bigr)/m$, i.e. $n$ times the population variance — the textbook formula for a sum of $n$ i.i.d. draws, here derived combinatorially with no appeal to independence machinery.

**Theorem 4.4 (Bootstrap variance of the resampled total).** *Let $x : \iota\to\mathbb{R}$, $S = \sum_i x_i$, $\bar x = S/m$, and $m \ge 1$. Then*
$$\sum_{f:\{1,\dots,m\}\to\iota}\bigl(T^\ast(f) - S\bigr)^2 \;=\; m^{\,m}\sum_{i\in\iota}\bigl(x_i - \bar x\bigr)^2 .$$
*Equivalently, the bootstrap variance of the resampled total is exactly $\sum_i (x_i-\bar x)^2$.*

*Proof.* Put $d_i = x_i - \bar x$; then $\sum_i d_i = S - m\bar x = 0$. For any resample $f$ of length $m$,
$$\sum_{k=1}^m d_{f(k)} = \sum_{k=1}^m x_{f(k)} - m\bar x = T^\ast(f) - S .$$
Apply Theorem 4.3 with $n = m$: $m\sum_f (T^\ast(f)-S)^2 = m\cdot m^m \sum_i d_i^2$, and cancel the factor $m > 0$. $\square$

**Definition 4.5 (Relative cluster dispersion).**
$$\mathrm{rsd}(x) \;=\; \frac{\sqrt{\sum_{i}\bigl(x_i - \bar x\bigr)^2}}{S}, \qquad \bar x = \frac{S}{m},\quad S = \sum_i x_i .$$

**Corollary 4.6 ($\mathrm{rsd}$ is the relative bootstrap standard error).** *With $m\ge 1$,*
$$\mathrm{rsd}(x) \;=\; \frac{1}{S}\sqrt{\;\frac{1}{m^{m}}\sum_{f:\{1,\dots,m\}\to\iota}\bigl(T^\ast(f)-S\bigr)^2\;} .$$

*Proof.* Immediate from Theorem 4.4: divide both sides by $m^m$ inside the square root. $\square$

The point of Corollary 4.6 is methodological. Without it, the floor of §5 would be a bound on an ad-hoc dispersion functional, and one could reasonably object that the actual reported intervals need not obey it. With it, the floor is a statement about the very quantity the round's resampling scheme estimates.

---

## 5. The resolution floor

**Theorem 5.1 (Resolution floor).** *Let $x : s \to \mathbb{R}$ with $S = \sum_{i\in s} x_i > 0$ and $m = |s|$. Then for every cluster $j \in s$,*
$$\frac{x_j}{S} - \frac{1}{m} \;\le\; \mathrm{rsd}(x).$$

*Proof.* Write $\bar x = S/m$. The single term $(x_j - \bar x)^2$ is one of the nonnegative summands of $\sum_i (x_i-\bar x)^2$, hence
$$(x_j-\bar x)^2 \;\le\; \sum_i (x_i-\bar x)^2 .$$
Taking square roots and using $t \le |t| = \sqrt{t^2}$,
$$x_j - \bar x \;\le\; \sqrt{(x_j-\bar x)^2} \;\le\; \sqrt{\textstyle\sum_i (x_i-\bar x)^2}.$$
Dividing by $S>0$ and observing $(x_j - S/m)/S = x_j/S - 1/m$ gives the claim. $\square$

**Interpretation.** If a single cluster carries a share $f = x_j/S$ of the hits, then the one-run relative bootstrap standard error is at least $f - 1/m$. Since the bootstrap resamples clusters, *no amount of additional sampling within clusters reduces this quantity*: increasing pairs per $N$ makes each $x_i$ larger but leaves the shares — and hence the floor — essentially unchanged.

**Corollary 5.2 (Dominant cluster).** *If some cluster carries at least a $1-\delta$ share, $x_j \ge (1-\delta)S$, then $\mathrm{rsd}(x) \ge 1 - \delta - 1/m$.*

*Proof.* $x_j/S \ge 1-\delta$ by division; combine with Theorem 5.1. $\square$

**The recorded profile.** The arbiter's cluster profile at the looser cut had $m = 128$ clusters, a maximum cluster of $600$ hits (with $561$ and $540$ next, against a control maximum of $359$), and a grand total of $40617$. Idealise the profile as
$$x_0 = 600, \qquad x_i = \frac{40017}{127}\;\;(1\le i\le 127), \qquad \textstyle\sum_i x_i = 40617 .$$

**Proposition 5.3 (The recorded run against its own floor).**
$$\mathrm{rsd}(x) \;\ge\; \frac{600}{40617} - \frac{1}{128} \;>\; 0.0069, \qquad\text{and}\qquad 2\times 0.0069 \;\le\; \frac{1.1016-1.0051}{2}\approx 0.048 .$$

*Proof.* The first inequality is Theorem 5.1 at $j = 0$ together with the arithmetic $600/40617 \approx 0.014772$ and $1/128 = 0.0078125$, whose difference is $\approx 0.006960$. The second is direct arithmetic. $\square$

Proposition 5.3 discharges the third audit item. The concern was that the reported interval might be *narrower* than the cluster structure permits — i.e. that overdispersion had been silently ignored. It has not: the reported half-width comfortably exceeds twice the structural floor, so the interval is consistent with, indeed conservative relative to, the observed lumpiness. The corollary for design is blunt: with a $\pm 5$–$15\%$ envelope, no single run of $\sim 7.7\times 10^7$ pairs at this profile can resolve a few-percent deviation.

---

## 6. Overdispersion is intrinsic to Pythagorean arithmetic

An adversary could still argue that the lumpy cluster profile is a sampler artefact — bad luck in choosing the $N$'s, curable by a better design. This section closes that door by proving that the underlying arithmetic object has unbounded cluster sizes.

**Definition 6.1 (Hypotenuse cluster).** For $c \in \mathbb{N}$, let
$$H(c) \;=\; \bigl\{(a,b) \in \mathbb{N}^2 \;:\; 1\le a\le c,\; 1\le b \le c,\; a^2+b^2 = c^2 \bigr\},$$
the set of *ordered* pairs of positive legs with hypotenuse $c$. Its cardinality $|H(c)|$ is the *hypotenuse multiplicity* of $c$.

Every element of $H(c)$ is a Pythagorean triple in the usual sense. As a sanity anchor, $H(5) = \{(3,4),(4,3)\}$, so $|H(5)| = 2$.

**Theorem 6.2 (Unbounded hypotenuse multiplicity).** *For every $k \in \mathbb{N}$ there exists $c > 0$ with $|H(c)| \ge k$.*

*Proof.* Recall the classical one-parameter family: for any integer $\mu \ge 2$,
$$(\mu^2-1)^2 + (2\mu)^2 = (\mu^2+1)^2 .$$
Reindex with $\mu = v+2$, and write, avoiding truncated subtraction,
$$L(v) = v^2+4v+3 \;(=\mu^2-1), \qquad h(v) = v^2+4v+5 \;(=\mu^2+1),$$
so that $L(v)^2 + (2(v+2))^2 = h(v)^2$ identically, and note $h(v) = L(v) + 2$.

The map $v \mapsto h(v)$ is injective on $\mathbb{N}$: if $h(a)=h(b)$ then $a^2+4a = b^2+4b$, so $(a-b)(a+b+4)=0$ over $\mathbb{Z}$; the second factor is strictly positive, forcing $a=b$.

Now set
$$C \;=\; C_k \;=\; \prod_{v=0}^{k-1} h(v) \;=\; \prod_{v=0}^{k-1}\bigl((v+2)^2+1\bigr) \;>\; 0 .$$
Each $h(v)$ divides $C$, so $t_v := C/h(v)$ is a positive integer with $h(v)\,t_v = C$. Define
$$\Phi(v) \;=\; \bigl(L(v)\,t_v,\;\; 2(v+2)\,t_v\bigr) .$$

*$\Phi(v) \in H(C)$.* Both coordinates are positive (products of positive integers). Both are $\le C$: $L(v)\le h(v)$ and $2(v+2)\le h(v)$ (the latter because $(v+2)^2+1 - 2(v+2) = (v+1)^2 \ge 0$), so multiplying by $t_v$ and using $h(v)t_v = C$ gives the bounds. And
$$\bigl(L(v)t_v\bigr)^2 + \bigl(2(v+2)t_v\bigr)^2 = \bigl(L(v)^2 + (2(v+2))^2\bigr)t_v^2 = h(v)^2 t_v^2 = \bigl(h(v)t_v\bigr)^2 = C^2 .$$

*$\Phi$ is injective on $\{0,\dots,k-1\}$.* Suppose $\Phi(a) = \Phi(b)$ with $a \ne b$, and let $A = L(a)t_a = L(b)t_b$ be the common first coordinate. Multiplying by the respective hypotenuses,
$$A\,h(a) = L(a)\,h(a)\,t_a = L(a)\,C, \qquad A\,h(b) = L(b)\,h(b)\,t_b = L(b)\,C .$$
Subtracting, and using $h(v) = L(v)+2$ to eliminate $L$,
$$A\bigl(h(a)-h(b)\bigr) = C\bigl(L(a)-L(b)\bigr) = C\bigl(h(a)-h(b)\bigr),$$
so $(A - C)\bigl(h(a)-h(b)\bigr) = 0$ in $\mathbb{Z}$. By injectivity of $h$ and $a\ne b$, the second factor is nonzero, whence $A = C$. But $L(a) < h(a)$ strictly, so $A = L(a)t_a < h(a)t_a = C$ — a contradiction.

Therefore $|H(C)| \ge k$. $\square$

**Corollary 6.3.** *The function $c \mapsto |H(c)|$ is unbounded: there is no $B$ with $|H(c)|\le B$ for all $c$.*

*Proof.* Apply Theorem 6.2 with $k = B+1$. $\square$

**Remark 6.4 (The bound is far from sharp).** The construction certifies $k$ hits at $C_k$ but typically delivers many more. For $k=3$, $C_3 = 5\cdot 10\cdot 17 = 850$ and $|H(850)| = 14$, not $3$. The reason is arithmetic: the number of representations of $c^2$ as an ordered sum of two positive squares is multiplicative in the primes $\equiv 1 \pmod 4$ dividing $c$, while the scaled family sees only one primitive triple per factor. The gap between the proved bound and the truth is itself a clean divisor-type arithmetic function — see §10.1.

**Theorem 6.5 (Near-half resolution floor from genuine Pythagorean clusters).** *For every $\varepsilon > 0$ there exist distinct hypotenuses $c_1 \ne c_2$ such that the two-cluster count vector $x = \bigl(|H(c_1)|,\;|H(c_2)|\bigr)$ satisfies*
$$\mathrm{rsd}(x) \;\ge\; \tfrac12 - \varepsilon .$$

*Proof.* Choose an integer $K > 2/\varepsilon$ and, by Theorem 6.2, a hypotenuse $c$ with $h := |H(c)| \ge K+3$. Take $c_1 = c$ and $c_2 = 5$, so $|H(c_2)| = 2$; since $h \ge 3 > 2$, we have $c \ne 5$. With $m=2$ and $S = h+2$, Theorem 5.1 at the first cluster gives
$$\mathrm{rsd}(x) \;\ge\; \frac{h}{h+2} - \frac12 \;=\; \frac12 - \frac{2}{h+2}.$$
Since $h \ge K > 2/\varepsilon$ we have $\varepsilon h > 2$, hence $2/(h+2) < 2/h < \varepsilon$, giving $\mathrm{rsd}(x) \ge 1/2 - \varepsilon$. $\square$

**Discussion.** Theorem 6.5 is the strongest structural statement of the round. Overdispersion in clustered Pythagorean search is not a nuisance parameter that vanishes as the number of sampled pairs grows: there is **no universal averaging bound**. Any claim of the form "with enough pairs the relative one-run resolution drops below $\delta$" is false as a uniform statement over cluster profiles, because profiles exist — built from real hypotenuse clusters, not hypothetical ones — with floor arbitrarily close to $1/2$. The $\pm 5$–$15\%$ envelope measured in the arbiter run is a mild instance of a phenomenon whose worst case is far worse.

---

## 7. Escaping the floor: inverse-variance pooling across seeds

If one run cannot resolve the question, several might. Independent runs combine by precision weighting.

**Definition 7.1 (Inverse-variance pooled variance).** For independent runs indexed by $s$ with variances $v_i > 0$,
$$V(s,v) \;=\; \Bigl(\sum_{i\in s} v_i^{-1}\Bigr)^{-1}.$$

**Theorem 7.2 (Pooling never hurts).** *For every $j \in s$, $V(s,v) \le v_j$.*

*Proof.* All $v_i^{-1}$ are positive, so $v_j^{-1} \le \sum_i v_i^{-1}$. Inverting reverses the inequality on positives: $\bigl(\sum_i v_i^{-1}\bigr)^{-1} \le v_j$. $\square$

**Theorem 7.3 (Equal variances).** *If $v_i = \sigma^2 > 0$ for all $i \in s$ and $s$ is nonempty, then $V(s,v) = \sigma^2/|s|$.*

*Proof.* $\sum_{i\in s} \sigma^{-2} = |s|\,\sigma^{-2}$, and inverting gives $\sigma^2/|s|$. $\square$

**Corollary 7.4 (The named follow-up condition is achievable).** *Three independent runs each with one-run standard error $0.025$ pool to a joint standard error $\sqrt{0.025^2/3} \approx 0.01443 < 0.02$.*

*Proof.* Theorem 7.3 with $|s|=3$, $\sigma = 0.025$, then $0.025^2/3 < 0.02^2$ and monotonicity of the square root. $\square$

The value $0.025$ is the recorded $\mathrm{cut}_{10^{-6}}$ half-width divided by $1.96$: $(1.1016-1.0051)/2 \approx 0.0483$, and $0.0483/1.96 \approx 0.0246$. So $\sigma_{\text{joint}} \approx 0.02$ is achievable with three genuinely distinct seeds, which is the resolution the round declared necessary before the gate could be revisited.

But Theorem 3.3 adds a burden that no amount of pooling discharges. If the three new seeds again disagree in sign, pooling their point estimates is not merely uninformative — it is *illegitimate*, because pairwise-incompatible intervals falsify the coverage assumption that inverse-variance weighting rests on. Any reopening of the gate must therefore *explain* the sign flip between seed families, not merely out-vote it.

---

## 8. Audit item: display truncation is not evidence

One alarm during the round arose from a terminal display. A quantity equal to $3.38\times 10^{-5}$ was printed with five-decimal fixed formatting as `0.00003`, which appeared to lie outside its confidence interval — manufacturing the appearance of an inconsistency. Recomputation from the persisted raw counts reproduced the value exactly; the discrepancy was purely a rendering effect.

The underlying phenomenon is trivial but worth stating so that it cannot recur as an argument.

**Definition 8.1.** Five-decimal truncation is $\mathrm{tr}_5(x) = \lfloor 10^5 x\rfloor / 10^5$.

**Proposition 8.2 (Truncation can leave an interval).** *There exist reals $lo < x < hi$ with $\mathrm{tr}_5(x) < lo$.*

*Proof.* Take $lo = 0.000031$, $x = 0.0000338$, $hi = 0.000035$. Then $10^5 x = 3.38$, so $\lfloor 10^5 x\rfloor = 3$ and $\mathrm{tr}_5(x) = 0.00003 < 0.000031 = lo$. $\square$

Hence "the displayed value lies outside the interval" carries **no** information about whether the underlying value does. The correct audit response — recomputing from raw counts — was taken, and the alarm resolved.

The second alarm concerned reproducibility of the interval itself. An independent $4000$-replicate rebootstrap from the persisted raw counts returned $[1.0540,\,1.2611]$ against the in-run stored $[1.0541,\,1.2686]$: agreement to three decimals on the lower limit and within Monte-Carlo error on the upper. The interval is reproducible.

---

## 9. Algorithms

We record the three computational procedures that the analysis rests on.

### 9.1 Pooled ratio with cluster bootstrap interval

**Input:** candidate counts $x_1,\dots,x_m$, control counts $y_1,\dots,y_m$, replicate count $B$, level $\alpha$.
**Output:** point estimate $r$ and interval $[q_{\alpha/2},\,q_{1-\alpha/2}]$.

1. $r \leftarrow (\sum_i x_i)/(\sum_i y_i)$.
2. For $b = 1,\dots,B$: draw indices $f(1),\dots,f(m)$ i.i.d. uniform from $\{1,\dots,m\}$; set $r_b^\ast \leftarrow \bigl(\sum_k x_{f(k)}\bigr)/\bigl(\sum_k y_{f(k)}\bigr)$.
3. Return $r$ and the empirical $\alpha/2$ and $1-\alpha/2$ quantiles of $\{r_b^\ast\}$.

Cost $O(B m)$. Note that step 2 resamples *clusters*, which is exactly why the floor of §5 binds: within-cluster refinement never enters.

### 9.2 Exact relative cluster dispersion and floor

**Input:** counts $x_1,\dots,x_m$.
**Output:** $\mathrm{rsd}(x)$ and the certified floor $\max_j x_j/S - 1/m$.

1. $S \leftarrow \sum_i x_i$, $\bar x \leftarrow S/m$.
2. $\mathrm{rsd} \leftarrow \sqrt{\sum_i (x_i-\bar x)^2}\,/\,S$.
3. floor $\leftarrow \max_j x_j / S - 1/m$.
4. Assert floor $\le \mathrm{rsd}$ (Theorem 5.1).

Cost $O(m)$. By Corollary 4.6 the value in step 2 is exactly the relative bootstrap standard error, so step 4 is a check on the reported interval, not on a proxy.

### 9.3 Hypotenuse-multiplicity witness

**Input:** $k$.
**Output:** a hypotenuse $C_k$ with $|H(C_k)| \ge k$, together with the $k$ certified leg pairs.

1. $C \leftarrow \prod_{v=0}^{k-1}\bigl((v+2)^2+1\bigr)$.
2. For $v = 0,\dots,k-1$: $h \leftarrow (v+2)^2+1$, $t \leftarrow C/h$, emit $\bigl((v+2)^2-1)\,t,\; 2(v+2)\,t\bigr)$.
3. Optionally, count $|H(C)|$ exactly by factoring $C$ and multiplying the representation counts of its primes $\equiv 1\pmod 4$.

Step 2 costs $O(k)$ big-integer multiplications; step 3 costs a factorisation. $C_k$ grows superexponentially ($\log C_k \sim 2k\log k$), so exhaustive verification is feasible only for small $k$.

---

## 10. Discussion and future directions

The round's outcome is a null, and nulls are often treated as non-results. Here the null is accompanied by structure, and the structure is the contribution.

### 10.1 Sharp multiplicity growth for the scaling construction

The construction $C_k = \prod_{v<k}((v+2)^2+1)$ provably delivers $k$ hits but measurably delivers far more ($C_3 = 850$ carries $14$). The key insight is that the scaled family only sees one primitive triple per factor, while the true count is multiplicative in the primes $\equiv 1 \pmod 4$ dividing $C_k$, so the gap between the proved and the true bound is itself a clean arithmetic function. This is tractable now because the existence result gives a skeleton into which a Gaussian-integer factorisation count can be dropped without redoing the distinctness argument.

### 10.2 Distributional floor, not just worst-case floor

Theorem 5.1 is a deterministic bound at a fixed profile. What a future gate needs is the *typical* floor when clusters are drawn from the hypotenuse distribution. The key insight is that the max/mean ratio of hypotenuse cluster sizes grows like a divisor-type function, so the design effect should grow like a power of $\log$, not stay bounded. This is phrasable now because the exact bootstrap variance identity (Theorem 4.4) reduces any distributional statement to a statement about $\sum_i (x_i - \bar x)^2$ alone.

### 10.3 Sign flip as a formal falsification rule

Theorem 3.1 shows disjoint intervals cannot both cover, and Theorem 3.3 gives the linear degradation $s(1-\alpha)\le 1$. The natural strengthening is quantitative and partial: with $s$ runs whose intervals disagree in sign only in part, a union bound over sign-partitioned events should convert "how many runs flipped" directly into "how wrong the nominal coverage is", with intermediate rates between the fully-disjoint and fully-nested extremes. The named $\ge 3$-seed follow-up will produce exactly the multi-run data such a rule consumes.

### 10.4 Mediant rigidity for candidate/control designs

Theorem 2.4 says the pooled ratio is trapped between attained cluster ratios. The key insight is that this makes the pooled ratio a weighted median-like statistic whose sensitivity is governed entirely by the largest-control clusters, which suggests a trimmed or winsorised pooled estimator with a provably smaller floor: discard the top few clusters, pay a small bias, and buy a large reduction in $\max_j x_j / S$. Quantifying that trade-off against Theorem 5.1 is a well-posed optimisation.

### 10.5 The barrier framing

The relevant frontier is *scale smoothness* in the band $u \ge 6$–$14$. This round adds no breach, no new method, and shaves no constant. What it adds is a null with quantified resolution floors — a strengthening of the map rather than a step across it. The honesty arc is now complete and closed: bank, downgrade, letter-of-rule null with independence audit, and finally a clean rejection by sign flip. A pipeline that can kill its own candidate anomaly on the evidence of a single uncontaminated seed is, in the long run, the only kind whose positive claims are worth reading.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Mediant envelope | The pooled ratio lies between the smallest and largest per-cluster ratios; a pooled surplus forces a cluster-level surplus. |
| Coverage incompatibility | Disjoint events cannot both have probability $\ge 1-\alpha$ unless $\alpha\ge 1/2$; $s$ pairwise-disjoint coverage events force $s(1-\alpha)\le 1$. |
| Bootstrap variance identity | For centred $d$ and $n$ draws from $m$ clusters, $m\sum_f(\sum_k d_{f(k)})^2 = n m^n\sum_i d_i^2$; at $n=m$, the bootstrap variance of the total is exactly $\sum_i(x_i-\bar x)^2$. |
| Resolution floor | $x_j/S - 1/m \le \mathrm{rsd}(x)$ for every cluster $j$; at the recorded profile, floor $> 0.0069$ against half-width $\approx 0.048$. |
| Unbounded multiplicity | For every $k$ there is a hypotenuse with at least $k$ ordered positive leg pairs, via $C_k=\prod_{v<k}((v+2)^2+1)$. |
| Near-half floor | Genuine two-hypotenuse cluster families exist with one-run relative resolution floor $\ge 1/2 - \varepsilon$. |
| Inverse-variance pooling | $\bigl(\sum_i v_i^{-1}\bigr)^{-1}\le \min_i v_i$, with equality-case $\sigma^2/k$; three seeds at $\sigma=0.025$ reach joint $\sigma < 0.02$. |
| Truncation artefact | Five-decimal truncation can move an in-interval value outside the interval; displayed exclusions are not evidence. |

**Verdict.** Randomness-extended, gate rejected. The randomness line extends through the next scale band with a measured $\pm 5$–$15\%$ single-run fluctuation envelope. Neither the deficit nor the surplus is banked.
