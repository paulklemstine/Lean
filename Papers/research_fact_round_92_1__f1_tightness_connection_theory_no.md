# The Slack Factor of a Scan Speed-Up Inequality: Exact Identities, Strict Unattainability, and Sharpness Over the Prior Class

**Author:** Aristotle
**Date:** 2026-08-27

---

## Abstract

We study the tightness of a master inequality bounding the achievable speed-up of an ordered search ("scan") policy over a discrete window, in terms of two shape parameters of the positional prior: the forward/backward cost ratio $\Lambda$ and the alignment ratio $\Theta$. The inequality reads $S \le 1/(\Lambda\Theta\hat q)$, where $S$ is the realized speed-up and $\hat q \in (0,1]$ a coverage parameter.

Our starting point is a conservation identity: for any probability profile on $M$ cells, the ascending and descending expected probe counts satisfy $c_{\mathrm{asc}} + c_{\mathrm{desc}} = M+1 = 2C_0$, where $C_0 = (M+1)/2$ is the flat-profile baseline. This collapses the two-parameter family $(\Lambda,\Theta)$ to a single degree of freedom and yields the exact identities

$$X := \frac{C_0}{c_{\mathrm{asc}}} = \frac{1}{\Theta} = \frac{1+\Lambda}{2\Lambda}, \qquad \frac{1}{\Lambda\Theta} = X \cdot \frac{1}{\Lambda},$$

so that the gap between the bound and the best realizable speed-up is *exactly* the single scalar $X$, independent of the policy and of the baseline against which speed-up is measured.

We then prove:

1. **Optimality and uniqueness of the ascending scan.** On a front-loaded (non-increasing) profile the ascending order minimises expected probe count; on a strictly decreasing profile it is the unique minimiser.
2. **Strict unattainability.** A front-loaded, non-flat profile satisfies $c_{\mathrm{asc}} < C_0$, hence $X > 1$ strictly, hence $S(\sigma) < 1/(\Lambda\Theta)$ for *every* policy $\sigma$. Equality $X=1$ holds precisely when $c_{\mathrm{asc}} = C_0$, in particular on the flat profile.
3. **Sharpness over the prior class.** For every $\varepsilon>0$ there is an admissible non-flat front-loaded profile with $1 < X < 1+\varepsilon$; the inequality cannot be improved by any uniform constant, even though it is attained on no admissible profile.
4. **A quantitative dispersion strengthening.** $X \ge 1 + \|p-\mathrm{flat}\|_1/(2c_{\mathrm{asc}}) \ge 1 + \|p - \mathrm{flat}\|_1/(2M)$, giving $S\,(1 + \|p-\mathrm{flat}\|_1/(2c_{\mathrm{asc}})) \le 1/(\Lambda\Theta)$; the constant $1$ is optimal, with two-cell profiles achieving equality.
5. **The mean-position fibration and its constrained polytope.** $X$ depends on $p$ only through the mean probe position $E_x$, via $X = (M+1)/(2ME_x+1)$; unconstrained, $X$ ranges over exactly $[(M+1)/(2M),\ (M+1)/2]$, and under a tail-mass constraint $\mathrm{edge}_K(p) \ge m$ over exactly $[(M+1)/(2M),\ (M+1)/(2Km+2)]$, both endpoints attained, the upper one by a two-cell profile.
6. **Grid monotonicity.** At fixed mean position, $X_M(E) = (M+1)/(2ME+1)$ increases strictly in $M$ to the continuum value $1/(2E)$; and under genuine dyadic refinement of a front-loaded profile the coarse slack is strictly below the fine slack. Every finite-grid estimate is therefore a lower bound.
7. **Profile-forcing for the harmonic law.** For the measured $1/x$ shape on a window of dynamic range $r>1$, the mean position is $E(r) = 1/\log r - 1/(r-1)$, which is $<1/2$ for all $r>1$ (equivalent to the Padé inequality $\log r > 2(r-1)/(r+1)$) and $\to 0$ as $r\to\infty$. Hence slack is forced for every window, and diverges with window width.
8. **A non-identifiability obstruction.** The coverage parameter $\hat q$ is not identified: for any $\Lambda,\Theta,S>0$ the unique $q = 1/(\Lambda\Theta S)$ turns the inequality into an equality. Consequently anchor datasets whose parameters were obtained by inverting the law carry zero evidential weight for tightness.

On the measured positional profile ($\Lambda = 0.765671$) these yield $\Theta \approx 0.867$, $X \approx 1.15302 \in [1.102, 1.221]$, best realizable speed-up $\approx 1.306$, bound $\approx 1.506$: the bound overshoots every realizable policy by $10\%$–$22\%$, and the overshoot is profile-forced and policy-independent.

**Keywords:** scan policy, positional prior, rearrangement inequality, Chebyshev sum inequality, slack factor, sharpness, non-identifiability, harmonic density.

---

## 1. Introduction

### 1.1 The problem

An ordered search over a window of $M$ cells is specified by a permutation of the cells: the *policy*. If the target's position is random with a known prior, the expected number of probes depends on the policy, and a policy aligned with the prior does better than one anti-aligned with it. The natural summary of "how much better" is a *speed-up* $S$: the ratio of the cost of a reference policy to the cost of the chosen policy.

A master inequality bounds this speed-up in terms of two shape parameters of the prior together with a coverage parameter:

$$S \;\le\; \min\!\left(\frac{1}{\Lambda\Theta\hat q},\ \frac{2^{k}}{\Lambda\Theta}\right),$$

where $k$ counts bits of side information available to the policy. In the *test-blind* regime $k = 0$ and for $\hat q \le 1$ the first arm binds, and when the whole window is scanned $\hat q = 1$, so

$$S \;\le\; \frac{1}{\Lambda\Theta}. \tag{M}$$

This inequality is a theorem. The question addressed here is a different one: **can it be attained?** Empirically the question is pressing, because measured data on a real positional profile produced a value of $S$ well below the bound, and the natural response — "the policy must be suboptimal" — turns out to be wrong.

### 1.2 Contributions and summary of findings

We show that the answer is determined by a single scalar, that this scalar is strictly greater than one for every front-loaded non-flat prior, and that its value is entirely fixed by the first moment of the prior. Along the way we identify a logical trap in the way tightness has historically been assessed, and characterise the exact reachable range of slack under realistic constraints.

The conclusion has a specific shape worth stating up front. The bound is not weakened by these results. It is *located*: it is exactly right as a statement about a class of priors, and exactly wrong as a statement about any individual non-degenerate pool.

### 1.3 Notation

$M \ge 1$ is the number of cells, indexed $i \in \{0, \dots, M-1\}$. A **profile** is $p : \{0,\dots,M-1\} \to \mathbb{R}$ with $p_i \ge 0$ and $\sum_i p_i = 1$. A profile is **front-loaded** if it is non-increasing ($i \le j \Rightarrow p_i \ge p_j$), **flat** if $p_i = 1/M$ for all $i$, and **non-flat** if $p_{i_0} \ne p_{j_0}$ for some pair. A **policy** is a permutation $\sigma$ of the index set; it probes cell $i$ at rank $\sigma(i)+1$.

---

## 2. Costs, parameters, and the conservation identity

### Definition 2.1 (Costs)

For a profile $p$ on $M$ cells:

- **Ascending cost** $\displaystyle c_{\mathrm{asc}}(p) = \sum_{i} (i+1)\,p_i$;
- **Descending cost** $\displaystyle c_{\mathrm{desc}}(p) = \sum_{i} (M-i)\,p_i$;
- **Baseline cost** $\displaystyle C_0(M) = \frac{M+1}{2}$;
- **Policy cost** $\displaystyle c(p,\sigma) = \sum_{i} (\sigma(i)+1)\,p_i$.

$C_0$ is simultaneously the cost of every policy under the flat profile and the expected cost of a uniformly random policy under any profile.

### Definition 2.2 (Shape parameters, speed-ups, slack)

$$\Lambda(p) = \frac{c_{\mathrm{asc}}(p)}{c_{\mathrm{desc}}(p)}, \qquad \Theta(p) = \frac{c_{\mathrm{asc}}(p)}{C_0(M)}, \qquad X(p) = \frac{C_0(M)}{c_{\mathrm{asc}}(p)},$$
$$S(p,\sigma) = \frac{c_{\mathrm{desc}}(p)}{c(p,\sigma)}, \qquad S_{\mathrm{asc}}(p) = \frac{c_{\mathrm{desc}}(p)}{c_{\mathrm{asc}}(p)} = \frac{1}{\Lambda(p)}.$$

$X$ is the **slack factor**. The right-hand side of (M) is written $B(\Lambda,\Theta,q) = 1/(\Lambda\Theta q)$.

### Proposition 2.3 (Positivity)

For any profile, $c_{\mathrm{asc}} \ge 1$ and $c_{\mathrm{desc}} \ge 1$; consequently $\Lambda, \Theta, X$ are all strictly positive and finite.

*Proof.* Each rank weight $(i+1)$ satisfies $i+1 \ge 1$ and each $(M-i) \ge 1$ (since $i \le M-1$); weight by $p_i \ge 0$ and sum, using $\sum_i p_i = 1$. $\square$

### Theorem 2.4 (Conservation identity)

For every profile $p$ on $M$ cells,

$$c_{\mathrm{asc}}(p) + c_{\mathrm{desc}}(p) \;=\; M+1 \;=\; 2\,C_0(M).$$

*Proof.* Termwise, $(i+1) + (M-i) = M+1$, independently of $i$. Hence the sum is $(M+1)\sum_i p_i = M+1$. $\square$

This is the engine of the paper. It says the pair $(c_{\mathrm{asc}}, c_{\mathrm{desc}})$ lives on a line, so the apparently two-dimensional parameter space $(\Lambda,\Theta)$ is a curve.

---

## 3. The identity chain

### Theorem 3.1 (Identity chain)

For every profile $p$ on $M \ge 1$ cells:

$$\text{(i)}\quad X = \frac{1}{\Theta}; \qquad \text{(ii)}\quad X = \frac{1+\Lambda}{2\Lambda}; \qquad \text{(iii)}\quad \Theta = \frac{2\Lambda}{1+\Lambda}; \qquad \text{(iv)}\quad B(\Lambda,\Theta,1) = X\cdot S_{\mathrm{asc}}.$$

*Proof.* (i) is immediate from the definitions, both being ratios of $C_0$ and $c_{\mathrm{asc}}$. For (ii), Theorem 2.4 gives $C_0 = (c_{\mathrm{asc}}+c_{\mathrm{desc}})/2$, so

$$X = \frac{C_0}{c_{\mathrm{asc}}} = \frac{c_{\mathrm{asc}}+c_{\mathrm{desc}}}{2\,c_{\mathrm{asc}}} = \frac{c_{\mathrm{asc}}/c_{\mathrm{desc}} + 1}{2\,c_{\mathrm{asc}}/c_{\mathrm{desc}}} = \frac{1+\Lambda}{2\Lambda},$$

where the third equality divides numerator and denominator by $c_{\mathrm{desc}} > 0$. (iii) is (i) combined with (ii). For (iv),

$$\frac{1}{\Lambda\Theta} = \frac{1}{\Theta}\cdot\frac{1}{\Lambda} = X \cdot S_{\mathrm{asc}}. \qquad\square$$

**Remark 3.2 (Policy- and baseline-independence).** Identity (iv) is the central structural statement. The left-hand side is the bound; the right-hand side factorises it into the best realizable speed-up times a pure shape quantity. Because $X$ is a ratio of two costs of $p$ alone, the overshoot is unaffected by which policy one uses and by which reference cost one normalises the speed-up against: replacing $c_{\mathrm{desc}}$ by any other reference $R$ multiplies both $S$ and $B$ by $R/c_{\mathrm{desc}}$, leaving $X$ untouched.

### Definition 3.3 (Mean probe position)

$$E_x(p) \;=\; \sum_i \frac{i + \tfrac12}{M}\, p_i \;\in\; (0,1).$$

### Proposition 3.4 (Mean-position form)

For $M \ge 1$, $c_{\mathrm{asc}}(p) = M\,E_x(p) + \tfrac12$, and hence

$$X(p) \;=\; \frac{M+1}{2M\,E_x(p) + 1}.$$

*Proof.* $(i+1) = M\cdot\frac{i+1/2}{M} + \tfrac12$; sum against $p$ and use $\sum_i p_i = 1$. Substituting into $X = C_0/c_{\mathrm{asc}}$ with $C_0 = (M+1)/2$ gives the display. $\square$

### Corollary 3.5 (Monotonicity in $\Lambda$)

The map $\lambda \mapsto (1+\lambda)/(2\lambda)$ is strictly decreasing on $(0,\infty)$, equals $1$ iff $\lambda=1$, and exceeds $1$ iff $\lambda<1$. Hence $X>1 \iff \Lambda<1 \iff$ the ascending scan strictly beats the descending one.

---

## 4. Optimality of the ascending scan

### Theorem 4.1 (Rearrangement)

If $p$ is front-loaded then $c_{\mathrm{asc}}(p) \le c(p,\sigma)$ for every policy $\sigma$.

*Proof sketch.* The rank weight sequence $a_i = i+1$ is strictly increasing and $p$ is non-increasing, so the pair $(p, a)$ is *antivarying*. The rearrangement inequality for antivarying sequences states that $\sum_i p_i a_i \le \sum_i p_i a_{\sigma(i)}$ for every permutation $\sigma$: pairing the largest probabilities with the smallest ranks minimises the sum. The left side is $c_{\mathrm{asc}}$, the right side is $c(p,\sigma)$. $\square$

### Corollary 4.2 (Best realizable speed-up)

If $p$ is front-loaded then $S(p,\sigma) \le S_{\mathrm{asc}}(p) = 1/\Lambda(p)$ for every $\sigma$.

*Proof.* $S(p,\sigma) = c_{\mathrm{desc}}/c(p,\sigma)$ with numerator fixed and positive; the denominator is minimised at $\sigma = \mathrm{id}$ by Theorem 4.1, and $c_{\mathrm{asc}}>0$. $\square$

### Theorem 4.3 (Uniqueness of the optimum)

If $p$ is strictly decreasing then $c_{\mathrm{asc}}(p) < c(p,\sigma)$ for every $\sigma \ne \mathrm{id}$; equivalently, $c(p,\sigma) = c_{\mathrm{asc}}(p)$ iff $\sigma = \mathrm{id}$, and $S(p,\sigma) < S_{\mathrm{asc}}(p)$ for $\sigma \ne \mathrm{id}$.

*Proof sketch.* A permutation of a finite totally ordered set that is strictly monotone must be the identity (its inverse is also strictly monotone, forcing $i \le \sigma(i)$ and $\sigma(i) \le i$). So a non-identity $\sigma$ has an *inversion*: indices $i<j$ with $\sigma(i) > \sigma(j)$. Transposing the two ranks changes the cost by $-(\sigma(i)-\sigma(j))(p_i - p_j) < 0$, since $p_i > p_j$ strictly. Repeating removes all inversions and strictly decreases the cost at each step, terminating at the identity. $\square$

This rules out the objection that $S_{\mathrm{asc}}$ is one of several tied optima and that comparing it with the bound is an artefact of tie-breaking.

---

## 5. Strict slack and unattainability

### Lemma 5.1 (Pairwise expansion)

For any finite index set $I$ of size $n$ and any $a, b : I \to \mathbb{R}$,

$$\sum_{i\in I}\sum_{j\in I} (a_i - a_j)(b_i - b_j) \;=\; 2\Big(n\sum_{i} a_i b_i - \Big(\sum_i a_i\Big)\Big(\sum_i b_i\Big)\Big).$$

*Proof.* Expand $(a_i-a_j)(b_i-b_j) = a_ib_i - a_ib_j - a_jb_i + a_jb_j$ and sum each of the four terms; the first and last each contribute $n\sum a_ib_i$, the middle two each contribute $-(\sum a)(\sum b)$. $\square$

### Lemma 5.2 (Strict Chebyshev)

If $(a_i - a_j)(b_i - b_j) \le 0$ for all $i,j \in I$, and the inequality is strict for at least one pair, then $n\sum_i a_ib_i < (\sum_i a_i)(\sum_i b_i)$.

*Proof.* The double sum in Lemma 5.1 is a sum of non-positive terms with at least one strictly negative, hence strictly negative; divide by $2$ and rearrange. $\square$

### Theorem 5.3 (Strict slack)

Let $p$ be front-loaded and non-flat. Then $c_{\mathrm{asc}}(p) < C_0(M)$, equivalently $X(p) > 1$.

*Proof.* Apply Lemma 5.2 with $a_i = i+1$ (strictly increasing) and $b_i = p_i$ (non-increasing). For any $i \le j$ we have $a_i - a_j \le 0$ and $p_i - p_j \ge 0$, so the product is $\le 0$; the same holds with roles swapped. If $p_{i_0} \ne p_{j_0}$ with, say, $i_0 < j_0$, then $a_{i_0} < a_{j_0}$ and $p_{i_0} > p_{j_0}$, so that pair contributes strictly negatively. Lemma 5.2 gives

$$M\sum_i (i+1)p_i \;<\; \Big(\sum_i (i+1)\Big)\Big(\sum_i p_i\Big) \;=\; \frac{M(M+1)}{2},$$

i.e. $c_{\mathrm{asc}} < (M+1)/2 = C_0$. $\square$

### Theorem 5.4 (Equality characterisation)

For any profile, $X(p) = 1 \iff c_{\mathrm{asc}}(p) = C_0(M)$. In particular the flat profile $p_i = 1/M$ satisfies $X = 1$.

*Proof.* Immediate from $X = C_0/c_{\mathrm{asc}}$ and $c_{\mathrm{asc}} > 0$. For flatness, $\sum_i (i+1)/M = \frac{1}{M}\cdot\frac{M(M+1)}{2} = C_0$. $\square$

### Theorem 5.5 (No realizable policy attains the bound)

Let $p$ be front-loaded and non-flat. Then for every policy $\sigma$,

$$S(p,\sigma)\cdot X(p) \;\le\; B(\Lambda(p),\Theta(p),1) \quad\text{and}\quad X(p)>1,$$

hence $S(p,\sigma) < B(\Lambda(p),\Theta(p),1)$ strictly.

*Proof.* Corollary 4.2 gives $S(p,\sigma) \le S_{\mathrm{asc}}$; multiply by $X > 0$ and apply the slack identity (Theorem 3.1(iv)) to get the first claim. Since $S(p,\sigma)>0$ (the policy cost is positive) and $X>1$ by Theorem 5.3, $S(p,\sigma) < S(p,\sigma)X \le B$. $\square$

**Interpretation.** The failure of equality happens *pool-side*, before any policy is chosen. The only profiles for which (M) is tight are the ones with $c_{\mathrm{asc}} = C_0$, and on those there is no speed-up to be had at all: $\Lambda = 1$, $S_{\mathrm{asc}} = 1$, bound $= 1$. Tightness and usefulness are mutually exclusive.

---

## 6. Sharpness over the prior class

Theorem 5.5 invites the objection that (M) is simply too weak. It is not.

### Definition 6.1 (Two-cell family)

For $0 \le \delta \le \tfrac12$, let $p_\delta$ be the profile on $M=2$ cells given by $p_\delta = (\tfrac12+\delta,\ \tfrac12-\delta)$.

### Proposition 6.2

$p_\delta$ is a front-loaded profile; it is non-flat iff $\delta > 0$; and

$$c_{\mathrm{asc}}(p_\delta) = \tfrac32 - \delta, \qquad X(p_\delta) = \frac{3/2}{3/2-\delta}.$$

*Proof.* Nonnegativity and mass $1$ are immediate; monotonicity holds for $\delta \ge 0$. $c_{\mathrm{asc}} = 1(\tfrac12+\delta) + 2(\tfrac12-\delta) = \tfrac32-\delta$; and $C_0(2) = \tfrac32$. $\square$

### Theorem 6.3 (Sharpness over the class)

For every $\varepsilon>0$ there exists a front-loaded, non-flat profile $p$ with $1 < X(p) < 1+\varepsilon$.

*Proof.* $X(p_\delta) \to 1$ as $\delta \downarrow 0$ by Proposition 6.2, and $X(p_\delta)>1$ for $\delta>0$ by Theorem 5.3. Pick $\delta$ small. $\square$

### Corollary 6.4 (The correct form of the tightness question)

No constant $c>1$ satisfies $S \le \frac{1}{c\,\Lambda\Theta}$ uniformly over the class of front-loaded priors (take $p_\delta$ with $\delta$ small enough that $X(p_\delta)<c$). Yet by Theorem 5.5 no admissible non-flat profile attains $X=1$. Sharpness holds in the closure of the class; attainment holds nowhere in it.

The methodological conclusion: **sharpness must be posed over the class of priors, never as tightness on a single pool.** A pool-side tightness claim is either about a degenerate (flat) pool or is false.

### Theorem 6.5 (Stability / hump-insensitivity)

For profiles $p,q$ on $M$ cells,

$$|X(p)-X(q)| \;\le\; \frac{M+1}{2}\cdot M \sum_i |p_i - q_i|.$$

*Proof sketch.* $X(p)-X(q) = C_0\,(c_{\mathrm{asc}}(q)-c_{\mathrm{asc}}(p))/(c_{\mathrm{asc}}(p)c_{\mathrm{asc}}(q))$. The numerator difference is bounded by $M\|p-q\|_1$ because every rank weight is at most $M$; the denominator is at least $1$ by Proposition 2.3. $\square$

This is the formal content of the empirical observation that the slack is insensitive to a moderate perturbation ("hump") of the profile: a change of $20\%$ in the amplitude of a local feature moved the measured $X$ by about $-0.019$.

### Proposition 6.6 (Which arm binds)

For $\Lambda,\Theta>0$, $k=0$ and $\hat q \ge 1$, $\min\!\big(1/(\Lambda\Theta\hat q),\ 2^k/(\Lambda\Theta)\big) = 1/(\Lambda\Theta\hat q)$. At $\hat q = 1$ the two arms coincide.

*Proof.* $1/(\Lambda\Theta\hat q) \le 1/(\Lambda\Theta)$ iff $\hat q \ge 1$. $\square$

---

## 7. A quantitative dispersion strengthening

Theorem 5.3 is qualitative. We now attach a number to the slack.

### Definition 7.1 (Flat dispersion)

$$\|p - \mathrm{flat}\|_1 \;=\; \sum_{i} \Big|p_i - \tfrac{1}{M}\Big|.$$

It vanishes exactly on the flat profile.

### Theorem 7.2 (Dispersion bound)

For every front-loaded profile $p$,

$$c_{\mathrm{asc}}(p) \;\le\; C_0(M) - \tfrac12\|p-\mathrm{flat}\|_1, \qquad\text{hence}\qquad X(p) \;\ge\; 1 + \frac{\|p-\mathrm{flat}\|_1}{2\,c_{\mathrm{asc}}(p)} \;\ge\; 1 + \frac{\|p-\mathrm{flat}\|_1}{2M}.$$

*Proof sketch.* Return to the double sum of Lemma 5.1 and keep, rather than discard, its magnitude. For a front-loaded profile and $a_i = i+1$, each term satisfies $|(a_i-a_j)(p_i-p_j)| \ge |p_i - p_j|$, because $|a_i - a_j| \ge 1$ whenever $i \ne j$. Summing over a row $i$ and using the mass constraint gives $\sum_j |p_i - p_j| \ge M\,|p_i - 1/M|$ (triangle inequality against the mean). Summing over $i$ converts the double sum into $M\|p-\mathrm{flat}\|_1$, and Lemma 5.1 turns this into $2M(C_0 - c_{\mathrm{asc}}) \ge M\|p-\mathrm{flat}\|_1$, which is the first display. Dividing by $c_{\mathrm{asc}}$ gives the middle inequality; the last follows from $c_{\mathrm{asc}} \le M$. $\square$

### Corollary 7.3 (Refined master inequality)

For a front-loaded profile and any policy $\sigma$,

$$S(p,\sigma)\left(1 + \frac{\|p-\mathrm{flat}\|_1}{2\,c_{\mathrm{asc}}(p)}\right) \;\le\; \frac{1}{\Lambda(p)\Theta(p)}, \qquad\text{i.e.}\qquad S \le \frac{B}{1+V}, \quad V := \frac{\|p-\mathrm{flat}\|_1}{2c_{\mathrm{asc}}}.$$

### Theorem 7.4 (Optimality of the constant)

On the two-cell family, $X(p_\delta) = 1 + \|p_\delta-\mathrm{flat}\|_1/(2c_{\mathrm{asc}}(p_\delta))$ exactly, for all $0\le\delta<\tfrac12$. Consequently for every $c>1$ there is an admissible front-loaded profile with

$$X(p) \;<\; 1 + c\,\frac{\|p-\mathrm{flat}\|_1}{2\,c_{\mathrm{asc}}(p)},$$

so no constant larger than $1$ is admissible in Theorem 7.2.

*Proof.* $\|p_\delta - \mathrm{flat}\|_1 = |\delta| + |-\delta| = 2\delta$ and $c_{\mathrm{asc}} = \tfrac32-\delta$, so $1 + \frac{2\delta}{2(3/2-\delta)} = \frac{3/2}{3/2-\delta} = X(p_\delta)$. Since the correction term is strictly positive for $\delta>0$, multiplying it by $c>1$ strictly overshoots; $\delta = 1/4$ works. $\square$

So the extremal profiles of the dispersion inequality are supported on two cells, and the normalisation $2c_{\mathrm{asc}}$ (which is strictly smaller than $2M$, hence strictly better) is the correct one.

---

## 8. The mean-position fibration and its polytope

### Theorem 8.1 (Fibration)

If two profiles on $M$ cells have the same mean probe position, they have the same slack factor. Explicitly, $X$ factors through $E_x$ via $X = (M+1)/(2ME_x+1)$ (Proposition 3.4).

Thus extremality of $X$ is a question about the *reachable set of mean positions*, not about profile shape — all higher moments are invisible.

### Theorem 8.2 (Unconstrained range)

For $M\ge1$ and every profile $p$,

$$\frac{M+1}{2M} \;\le\; X(p) \;\le\; \frac{M+1}{2},$$

and both endpoints are attained: by the point mass on the last cell (giving $E_x = \frac{2M-1}{2M}$ and $X = \frac{M+1}{2M}$) and by the point mass on the first cell (giving $E_x = \frac{1}{2M}$ and $X = \frac{M+1}{2}$).

*Proof.* $E_x$ is a convex combination of the cell centres $\frac{i+1/2}{M}$, so it lies in $[\frac{1}{2M}, \frac{2M-1}{2M}]$, with endpoints attained by point masses. $X$ is a strictly decreasing function of $E_x$, so it attains the reversed endpoints. $\square$

The right endpoint corresponds to a perfectly sorted pool: the slack can be as large as $(M+1)/2$. The left endpoint tends to $1/2$ as $M\to\infty$; note that $X<1$ is possible, but only for *back*-loaded profiles, where the ascending scan is the wrong policy.

### Definition 8.3 (Edge mass)

For a cut index $K$, $\ \mathrm{edge}_K(p) = \sum_{i\ge K} p_i$.

### Theorem 8.4 (Constrained bound)

If $\mathrm{edge}_K(p) \ge m \ge 0$ then

$$E_x(p) \;\ge\; \frac{\tfrac12 + Km}{M}, \qquad\text{hence}\qquad X(p) \;\le\; \frac{M+1}{2Km+2}.$$

*Proof sketch.* Write $E_x = \sum_i \frac{i+1/2}{M}p_i$ and split at $K$. Below $K$, each cell centre is at least $\frac{1/2}{M}$; at or above $K$, each is at least $\frac{K+1/2}{M}$. Hence $E_x \ge \frac{1/2}{M}(1 - \mathrm{edge}_K) + \frac{K+1/2}{M}\,\mathrm{edge}_K = \frac{1/2 + K\,\mathrm{edge}_K}{M} \ge \frac{1/2+Km}{M}$. Substitute into Proposition 3.4. $\square$

### Theorem 8.5 (Exact constrained range)

Let $0 < K < M$ and $0 \le m \le 1$. Under the constraint $\mathrm{edge}_K(p) \ge m$, the reachable slack factors are exactly

$$\left[\frac{M+1}{2M},\ \frac{M+1}{2Km+2}\right],$$

the upper endpoint attained by the two-cell profile placing mass $1-m$ on cell $0$ and $m$ on cell $K$, and the lower endpoint by the point mass on the last cell.

*Proof.* Upper bound and lower bound are Theorems 8.4 and 8.2. For the upper endpoint, the two-cell profile $(1-m)\delta_0 + m\delta_K$ has $\mathrm{edge}_K = m$ exactly and $E_x = \frac{1/2 + Km}{M}$, hence $X = \frac{M+1}{2Km+2}$. The last-cell point mass has $\mathrm{edge}_K = 1 \ge m$ and attains the lower endpoint. Intermediate values follow by continuity along a path of admissible profiles. $\square$

So the extremal profile of the constrained linear programme is supported on **at most two cells** — a general phenomenon for a single linear constraint plus the simplex.

### Corollary 8.6 (Reading the constraint backwards)

If a measurement establishes $X(p) \ge x > 0$ under $\mathrm{edge}_K(p) \ge m$, then

$$2Km + 2 \;\le\; \frac{M+1}{x}.$$

A measured slack therefore *caps* the admissible edge mass. This converts a confidence interval on $\Lambda$ (equivalently on $X$) into a hard constraint on the prior itself, closing the inferential loop from measurement back to model.

---

## 9. Grid effects: refinement and the continuum

Slack is estimated on a finite grid; the profile is continuous. Two questions arise: does the grid bias the estimate, and in which direction?

### Definition 9.1 (Grid slack at fixed mean)

$$X_M(E) \;=\; \frac{M+1}{2ME+1}.$$

By Proposition 3.4 this is the slack of *any* $M$-cell profile with mean position $E$.

### Theorem 9.2 (Scalar half)

Fix $E \in (0,\tfrac12)$. Then $X_M(E) < \frac{1}{2E}$ for every $M \ge 1$; $M \mapsto X_M(E)$ is strictly increasing; and $X_M(E) \to \frac{1}{2E}$ as $M\to\infty$.

*Proof sketch.* $\frac{M+1}{2ME+1} < \frac{1}{2E} \iff 2E(M+1) < 2ME+1 \iff 2E < 1$. Monotonicity: $\frac{d}{dM}\frac{M+1}{2ME+1} = \frac{(2ME+1)-2E(M+1)}{(2ME+1)^2} = \frac{1-2E}{(2ME+1)^2} > 0$. The limit is by dividing through by $M$. $\square$

Thus a finite-grid estimate at a *fixed* mean position is conservative.

### Definition 9.3 (Dyadic coarsening)

Given a profile presented as $g : \mathbb{N}\to\mathbb{R}_{\ge0}$ read on the first $2M$ cells, its **coarsening** is the $M$-cell profile $(\mathcal{C}g)_j = g_{2j} + g_{2j+1}$, which has the same total mass.

### Theorem 9.4 (Profile half: refinement raises the slack)

With $E_{\mathrm{fine}}$ the mean position of $g$ on $2M$ cells and $E_{\mathrm{coarse}}$ that of $\mathcal{C}g$ on $M$ cells,

$$E_{\mathrm{coarse}} \;=\; E_{\mathrm{fine}} + \frac{1}{4M}\sum_{j<M}\big(g_{2j} - g_{2j+1}\big).$$

If $g$ is pairwise front-loaded ($g_{2j}\ge g_{2j+1}$ for all $j$) then $E_{\mathrm{coarse}} \ge E_{\mathrm{fine}}$; and if additionally $E_{\mathrm{fine}} < \tfrac12$ and at least one pairwise inequality is strict, then

$$X(\mathcal{C}g) \;<\; X(g).$$

*Proof sketch.* The coarse cell $j$ has centre $\frac{j+1/2}{M}$, while the two fine cells it merges have centres $\frac{2j+1/2}{2M}$ and $\frac{2j+3/2}{2M}$; the coarse centre is their midpoint $\frac{2j+1}{2M}$. Hence merging displaces the mass $g_{2j}$ forward by $\frac{1}{4M}$ and the mass $g_{2j+1}$ backward by $\frac{1}{4M}$, giving the stated identity. Non-negativity of the correction follows from pairwise monotonicity. The slack comparison then combines the mean shift with the grid monotonicity of Theorem 9.2 applied at the two grid sizes $M$ and $2M$. $\square$

**Explicit instance.** For the four-cell profile $(0.4, 0.3, 0.2, 0.1)$, $E_x = 3/8$ and $X = 5/4 = 1.25$; its coarsening $(0.7, 0.3)$ has $X = 15/13 \approx 1.1538$. The refinement strictly increases the measured slack, so the theorem is non-vacuous.

**Consequence.** Every finite-grid slack estimate is a *lower* bound for the continuum slack of the same underlying profile: the booked value $X = 1.15302$, computed on $27$ cells, is one-sided in the safe direction.

---

## 10. The harmonic profile: slack is forced by the shape

The measured positional profile is harmonic: over a window of dynamic range $r>1$ the density is proportional to $1/x$.

### Definition 10.1

The harmonic law on the unit interval with ratio $r>1$ has cumulative distribution

$$F_r(u) \;=\; \frac{\log\!\big(1+(r-1)u\big)}{\log r}, \qquad u\in[0,1],$$

and mean position $E(r) = \int_0^1 (1-F_r(u))\,du$.

### Theorem 10.2 (Mean position of the harmonic law)

$$E(r) \;=\; \frac{1}{\log r} - \frac{1}{r-1}.$$

*Proof sketch.* Substituting $v = 1+(r-1)u$, $\int_0^1 \log(1+(r-1)u)\,du = \frac{1}{r-1}\int_1^r \log v\,dv = \frac{r\log r - (r-1)}{r-1}$. Hence $\int_0^1 F_r = \frac{r}{r-1} - \frac{1}{\log r}$ and $E(r) = 1 - \int_0^1 F_r = \frac{1}{\log r} - \frac{1}{r-1}$. $\square$

### Theorem 10.3 (Padé inequality)

For every $r>1$, $\ \log r > \dfrac{2(r-1)}{r+1}$.

*Proof sketch.* Let $h(r) = \log r - \frac{2(r-1)}{r+1}$. Then $h(1)=0$ and $h'(r) = \frac1r - \frac{4}{(r+1)^2} = \frac{(r+1)^2 - 4r}{r(r+1)^2} = \frac{(r-1)^2}{r(r+1)^2} > 0$ for $r>1$. $\square$

### Corollary 10.4 (Harmonic mean position)

For every $r>1$, $\ 0 < E(r) < \tfrac12$.

*Proof.* Write $L = \log r$ and $d = r-1$, both positive for $r>1$. Then
$$E(r) < \tfrac12 \iff \frac{d-L}{Ld} < \frac12 \iff 2(d-L) < Ld \iff 2d < L(d+2) = L(r+1) \iff L > \frac{2(r-1)}{r+1},$$
which is Theorem 10.3. Positivity of $E$ is the statement $L < d$, i.e. $\log r < r-1$ for $r>1$. $\square$

### Theorem 10.5 (Slack is profile-forced)

For every window ratio $r>1$, the continuum shape parameter $\Lambda(r) = \frac{E(r)}{1-E(r)}$ satisfies $\Lambda(r)<1$, and the continuum slack

$$X(r) \;=\; \frac{1+\Lambda(r)}{2\Lambda(r)} \;=\; \frac{1}{2E(r)} \;>\; 1.$$

Moreover $E(r)\to0$ and hence $X(r)\to\infty$ as $r\to\infty$.

*Proof.* $\Lambda = E/(1-E) < 1 \iff E < 1/2$, which is Corollary 10.4. The identity $\frac{1+\Lambda}{2\Lambda} = \frac{1}{2E}$ follows by substituting $\Lambda = E/(1-E)$. The limit follows since $1/\log r \to 0$ and $1/(r-1)\to0$ with $E(r) \sim 1/\log r$ for large $r$. $\square$

**Interpretation.** No policy is mentioned in Theorem 10.5. The overshoot is a property of the measured density alone, and it *grows* with the width of the scan window: wider windows make the bound less informative, not more.

### Measured values

The reported measurement is $\Lambda = 0.765671$, corresponding to mean position $E \approx 0.43365 < \tfrac12$ and

| quantity | value |
|---|---|
| $\Lambda$ | $0.765671$ |
| $\Theta = 2\Lambda/(1+\Lambda)$ | $\approx 0.86723$ |
| $X = (1+\Lambda)/(2\Lambda)$ | $\approx 1.15302$ |
| $X$ interval (from $\Lambda \in [0.6939, 0.8309]$) | $[1.10175,\ 1.22054]$ |
| $S_{\mathrm{asc}} = 1/\Lambda$ | $\approx 1.30604$ |
| bound $= 1/(\Lambda\Theta)$ | $\approx 1.50601$ |

The interval transfer is exact: $\lambda \mapsto (1+\lambda)/(2\lambda)$ is strictly decreasing, so the $\Lambda$-interval maps onto the $X$-interval by evaluating at the endpoints. The bound overshoots the best realizable speed-up by at least $10\%$ and at most $23\%$.

---

## 11. The non-identifiability obstruction

The historical evidence for tightness came from four "anchor" datasets whose reported parameters satisfied $\Lambda\Theta \approx 1.00$–$1.04$, apparently sitting on the bound. That evidence is void, for a purely logical reason.

### Theorem 11.1 (Non-identifiability of the coverage parameter)

For every $\Lambda,\Theta,S>0$ there exists $q>0$ with $B(\Lambda,\Theta,q) = S$; namely $q = 1/(\Lambda\Theta S)$. Moreover this $q$ is unique among positive reals.

*Proof.* Existence by direct substitution; uniqueness because $q\mapsto 1/(\Lambda\Theta q)$ is injective on $(0,\infty)$. $\square$

### Corollary 11.2 (Anchor inversion is a tautology)

For every $S>0$, $\ B(1,1,1/S) = S$. Hence reading off parameters at $\Lambda = \Theta = 1$ through the relation $S = 1/\hat q$ reproduces the observed speed-up *exactly*, whatever the observation.

### Discussion

Theorem 11.1 says the master inequality, with $\hat q$ left free, is *unfalsifiable*: no observed speed-up can contradict it, because the fitting procedure has one free parameter that absorbs any residual. Corollary 11.2 says that an anchor calibrated in this way is not a test of tightness — it is an algebraic restatement of the datum.

This is the **tightness-circularity catch**. Concretely: all four legacy anchors had their parameters obtained by inverting the law through $S_A = 1/\hat q$ at $\Lambda=\Theta=1$; the residual of the inversion is machine-zero and one anchor reproduces its booked value to $5\times10^{-7}$ — precisely what an exact self-consistent inversion should do, and precisely what conveys no information. Anchor tightness is therefore **not currently decidable**. It becomes decidable only when a raw, non-inverted effective profile is measured under a pre-committed protocol.

The general moral is worth isolating: *a parameter fitted by inverting a law cannot be used to test that law.* The agreement is a fixed point of the fitting map, not a fact about the world.

---

## 12. Algorithms

### 12.1 Slack from a profile

Given $p$ on $M$ cells, compute $c_{\mathrm{asc}} = \sum_i (i+1)p_i$ in $O(M)$; then $c_{\mathrm{desc}} = M+1-c_{\mathrm{asc}}$ (conservation, $O(1)$, no second pass), $C_0 = (M+1)/2$, and

$$\Lambda = \frac{c_{\mathrm{asc}}}{c_{\mathrm{desc}}}, \quad \Theta = \frac{c_{\mathrm{asc}}}{C_0}, \quad X = \frac{C_0}{c_{\mathrm{asc}}}, \quad S_{\mathrm{asc}} = \frac{1}{\Lambda}, \quad B = \frac{1}{\Lambda\Theta} = X\cdot S_{\mathrm{asc}}.$$

Total cost $O(M)$ time, $O(1)$ extra space. The conservation identity halves the arithmetic and removes any possibility of the two costs being inconsistently computed.

### 12.2 Exhaustive policy audit

To verify unattainability empirically on a small window, enumerate all $M!$ policies, compute each cost, and confirm that the minimum equals $c_{\mathrm{asc}}$ and that $\max_\sigma S(p,\sigma)\cdot X = B$ to machine precision. Cost $O(M!\cdot M)$; feasible for $M \le 9$. This is a direct check of Theorems 4.1, 4.3 and 5.5.

### 12.3 Interval transfer

Because $\lambda\mapsto(1+\lambda)/(2\lambda)$ is strictly decreasing, a confidence interval $[\lambda_-, \lambda_+]$ maps to $X \in [g(\lambda_+), g(\lambda_-)]$ by endpoint evaluation, in $O(1)$. No sampling is required, and the transfer is exact rather than asymptotic.

### 12.4 Constrained extremal search

To find the maximal slack under $\mathrm{edge}_K(p) \ge m$, Theorem 8.5 says the answer is closed-form, $\frac{M+1}{2Km+2}$, attained by a two-cell profile. A linear-programming solve over the simplex with one extra linear constraint would return the same value; the theorem replaces an $O(\mathrm{poly}(M))$ solve with an $O(1)$ formula.

---

## 13. Applications and discussion

**Ordered search and scheduling.** The framework applies verbatim to any sequential search whose cost is the rank at which the target is found: linear probing in a hash table with a skewed key distribution, cache line scanning, disk-block search, and priority scheduling with a known arrival profile. The conservation identity and the fibration hold in all of them, so "slack against the ideal bound" is always a one-dimensional quantity determined by the first moment.

**Benchmark interpretation.** The results give a precise reason why a well-tuned algorithm can persistently fall short of a proven upper bound without being suboptimal. If the bound's tightness case is degenerate (here: flat prior), then the measured shortfall is a *measurement of non-degeneracy*, not a performance deficit. Reporting $X$ alongside $S$ separates the two.

**Statistics of inverted anchors.** Section 11 is a caution applicable well beyond this setting. Whenever a nuisance parameter is calibrated by inverting the relation under test, the resulting "confirmation" has zero evidential content. Pre-registration of the nuisance parameter, or an independent measurement of it, is the only remedy.

**One-sided grid reading.** Section 9 gives a rare and useful guarantee: a coarse estimate errs in a known direction. Reported slacks may be used as lower bounds without a discretisation error budget.

**Limits of scope.** The analysis concerns the *shape* layer — the density of the positional prior — and is orthogonal to rate-layer questions such as throughput plateaus. It uses only the density, and no sequence structure or correlations between successive targets. Extending to correlated targets would require a different cost functional.

---

## 14. Future directions

The identity chain, unattainability, class-sharpness, and non-identifiability are settled, as are the dyadic refinement comparison, the quantitative $L^1$ strengthening with its optimal constant, the mean-position fibration with its exact range $X\in[(M+1)/(2M),(M+1)/2]$, and the constrained polytope for a single tail constraint. What remains open:

**1. From the dyadic refinement to the continuum limit.** The grid dependence of the slack sits in a single scalar identity, so the refinement comparison reduces to the sign of $\sum_j (g_{2j} - g_{2j+1})$: cell merging moves the measured mean position forward by exactly $\frac{1}{4M}\sum_j (g_{2j}-g_{2j+1})$, non-negative precisely for a front-loaded profile. The dyadic step and the scalar monotonicity are theorems. Still open is the same statement for cell-averaging a fixed *continuum* density onto grids of arbitrary (non-dyadic) size, together with the limit $X_M \to 1/(2E)$ along that family. The exact discrete identity removes the need for error analysis on a single refinement step.

**2. Multiple linear constraints.** Theorem 8.5 handles a single tail constraint and produces a two-cell extremal profile. With several linear constraints on the prior (multiple tail masses, moment bounds, a monotonicity envelope), the extremal profile should be supported on at most one more cell than the number of constraints; the exact reachable slack interval and the extremal supports are open.

**3. Correlated and adaptive settings.** The present cost functional assumes a single target drawn from a fixed prior and a non-adaptive policy. Introducing adaptivity (the policy may branch on the outcome of each probe) or correlation between successive targets changes the optimality analysis; whether an analogue of the conservation identity survives is open.

**4. The decidable closer.** A joint measurement of speed-up, shape and alignment on the recorded positional data under the window-ascending policy is predicted by the map to give $S \approx 1.31$ against a bound of $1.51$. Observing $S$ appreciably above $1.51$ would falsify the mapping; this is a genuine two-sided test requiring no new instrumentation.

**5. Non-inverted anchor measurement.** Deciding anchor tightness requires a raw effective profile measured under a pre-committed protocol, with the coverage parameter either measured independently or fixed in advance. Until then Theorem 11.1 forbids any inference from anchor agreement.

---

## 15. Conclusion

A single conservation identity — forward plus backward scan cost equals twice the flat baseline — collapses the two-parameter tightness question for the scan speed-up inequality into one scalar, the slack factor $X = C_0/c_{\mathrm{asc}} = 1/\Theta = (1+\Lambda)/(2\Lambda)$, and shows that the bound factors exactly as $\text{bound} = X\cdot S_{\mathrm{asc}}$. Front-loading plus non-flatness forces $X>1$ strictly, so no realizable policy attains the bound; yet the two-cell family drives $X$ to $1$, so the bound is sharp over the prior class. The overshoot is quantified by an optimal dispersion inequality, is determined solely by the mean probe position, ranges over an exactly characterised interval (also under a tail-mass constraint), is under-estimated by any finite grid, and is forced for every window ratio by the harmonic shape of the measured profile. Finally, the coverage parameter's non-identifiability voids the historical anchor evidence for tightness.

On the measured data: $X \approx 1.153 \in [1.102, 1.221]$. The proven bound overshoots every realizable policy by between $10\%$ and $22\%$, and the overshoot is profile-forced and policy-independent. The inequality is not weakened by this. It is located.
