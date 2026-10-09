# External Hints Are Priced Linearly in Bits: A Master Law, a Which-Factor Ceiling, and a Strategy-Free Guessing Bound

**Author:** Aristotle

**Date:** 2026-10-09

---

## Abstract

We study how much a *filter*, meaning a prediction of where a hidden object lies, can accelerate an exhaustive search. A hit costs a fraction $\theta$ of the full work and a miss costs the full work. On an arbitrary finite probability space, the speedup obeys the **master law** $\mathrm{Speedup} = 1/(1-(1-\theta)P_{\mathrm{hit}})$, so every filter acts only through its hit probability. On product spaces whose hidden label is uniform on the fibres of the observable coordinate, we locate the **symmetry break** between internal and external information. Every reading generated from the observable coordinate has $P_{\mathrm{hit}} = 1/K$, which at $K=2$, $\theta = 1/2$ is exactly the known $4/3$ cap. An external hint whose likelihood lives on the label coordinate survives that step verbatim. For a hint that speaks about one of two factors without naming it, we prove the **which-factor ceiling** $2K^2/(K^2+1) < 2$ for every dial size $K$ and every likelihood, sharp, with the canonical binary-dial specialization $8/(7-2\alpha)$. We extend this to $r$ factors: the fine-dial limit is $r/(r-1)$, the ceiling overshoots that limit for $r \ge 3$, and for $r \ge 7$ the binary dial is globally optimal with value $4r/(3r-1) \to 4/3$. We give exact analyses of a certain-hint ladder (exactly two bits lost asymptotically), of trace hints (a bounded recovery divisor leaves the rate at one bit per bit), and of a noise break-even surface (external hints tolerate strictly more noise than internal filters at every $\theta$). Finally we prove a **strategy-free guessing bound**: for a uniform target among $M$ candidates and any hint with $|B|$ values, every strategy satisfies $\mathbb E[\text{guesses}] \ge \tfrac12(M/|B| + 1)$. Hence a $t$-bit hint buys at most a factor $2^t$, the bound is sharp, joint hints show no synergy, and isolating one candidate needs exactly $\lceil\log_2 M\rceil$ yes/no queries. Together these results complete a three-row barrier map: residues are capped at $4/3$, positional information has been measured at about $5.19\times$, and external information is priced linearly in bits.

---

## 1. Introduction

Many search problems have the following shape. A hidden object (a key, a password, a prime factor) lies somewhere among a large set of candidates. An exhaustive search costs one unit of work. Before searching we may consult a **filter**, a prediction of which part of the candidate space holds the object. If the prediction is right we search only that part, at cost $\theta < 1$. If it is wrong we have to search everything.

The motivating instance is integer factorization. To factor $N = pq$ we may sort candidate primes into $K$ classes, for instance by a residue, and call this partition a *dial*. Knowing the class of $p$ would cut the search to a fraction $\theta = 1/K$. Predictions of the class come in two kinds:

* **Internal readings** are computed from public data, ultimately from $N$ itself.
* **External hints** come from outside: side channels, leaked bits, oracles.

Earlier work in this line established that residue-based internal filters cannot beat a speedup of $4/3$ at the binary dial, and companion experiments measured positional (structural) information at about $5.19\times$. This paper completes the picture with the third row, external information, and explains why the three rows look the way they do.

**Contributions.**

1. *Master law* (Theorem 2.2). On any finite probability space the speedup is $1/(1-(1-\theta)P_{\mathrm{hit}})$. Two filters with equal hit probability have equal speedup, the law is strictly increasing in $P_{\mathrm{hit}}$, and its ceiling $1/\theta$ is attained exactly at a certain hit.
2. *Symmetry break* (Theorems 3.2 and 3.3). Fibre uniformity forces $P_{\mathrm{hit}} = 1/K$ for internal readings, while a label-side likelihood keeps its full accuracy. The $4/3$ cap is the uninformative point of the master law.
3. *Which-factor ceiling* (Theorem 4.3). For an unnamed hint about one of two factors, the speedup at per-dial cost $1/K$ is at most $2K^2/(K^2+1) < 2$. This is sharp, and its binary-dial form is the partition law $8/(7-2\alpha)$.
4. *Many factors* (Theorems 5.2–5.5). The fine-dial limit is $r/(r-1)$, there is an overshoot for $r\ge3$, the binary dial is optimal for $r\ge 7$, and the ceiling collapses onto $4/3$.
5. *Ladder, trace hints and noise* (Sections 6–8). We prove exactly two lost bits, rate one under bounded recovery divisors, and an explicit break-even surface.
6. *Strategy-free $t$-bit guessing bound* (Section 9). A $t$-bit hint buys at most $2^t$. The bound is sharp, there is no synergy, and isolation costs $\lceil \log_2 M\rceil$ queries.

---

## 2. The master law

**Definition 2.1 (Filtered search).** Let $\Omega$ be a finite set with a probability mass function $\mu$, so $\mu(\omega) \ge 0$ and $\sum_\omega \mu(\omega) = 1$. Let $\mathrm{hit} \subseteq \Omega$ be the event on which the filter is right, and let $\theta \in \mathbb R$ be the cost of a hit relative to a full search. Define

$$P_{\mathrm{hit}} = \sum_{\omega \in \mathrm{hit}} \mu(\omega), \qquad \mathrm{Work} = \sum_{\omega} \mu(\omega)\,c(\omega),\quad c(\omega) = \begin{cases}\theta & \omega \in \mathrm{hit},\\ 1 & \omega \notin \mathrm{hit},\end{cases}$$

and $\mathrm{Speedup} = 1/\mathrm{Work}$. The unfiltered search has work $1$.

**Theorem 2.2 (Master law).** For every finite probability space, every hit event, and every $\theta$,

$$\mathrm{Work} = 1 - (1-\theta)\,P_{\mathrm{hit}}, \qquad \mathrm{Speedup} = \frac{1}{1-(1-\theta)\,P_{\mathrm{hit}}}.$$

*Proof.* Pointwise, $\mu(\omega)c(\omega) = \mu(\omega) - (1-\theta)\mu(\omega)\mathbf 1[\omega\in\mathrm{hit}]$. Summing and using $\sum\mu = 1$ gives the work formula, and taking reciprocals gives the speedup. $\square$

Write $S_\theta(P) = 1/(1-(1-\theta)P)$.

**Corollary 2.3 (One scalar prices everything).** Two filters, possibly on different probability spaces, with the same hit probability have the same speedup.

**Proposition 2.4 (Shape of the law).** Let $0<\theta<1$.
(a) $P_{\mathrm{hit}} \in [0,1]$.
(b) $S_\theta$ is strictly increasing on $[0,1]$.
(c) $S_\theta(P) \le 1/\theta$ whenever $P \le 1$ (and this holds also for $\theta = 1$).
(d) $S_\theta(P) = 1/\theta$ if and only if $P = 1$.

*Proof sketch.* (a) holds because $P_{\mathrm{hit}}$ is a partial sum of a probability vector. For (b), the denominator $1-(1-\theta)P$ is positive and strictly decreasing in $P$. For (c), $1-(1-\theta)P \ge \theta$ iff $(1-\theta)(1-P) \ge 0$. For (d), equality in (c) forces $(1-\theta)(1-P) = 0$. $\square$

Everything that follows computes, or bounds, a single scalar $P_{\mathrm{hit}}$ and feeds it to $S_\theta$.

---

## 3. The symmetry break

**Definition 3.1 (Fibre-uniform product model).** Let $C$ be a finite set of observable values with probability vector $\nu$, and let $K\ge 1$ be the dial size. A reading is produced by a kernel $R(c,b,h) \ge 0$ with $\sum_h R(c,b,h) = 1$, where $b \in \{0,\dots,K-1\}$ is the hidden label and $h$ the reading. The joint law on $C \times [K] \times [K]$ is

$$\mathbb P(c,b,h) = \frac{\nu(c)}{K}\,R(c,b,h).$$

So the label is uniform on every fibre of the observable coordinate $c$. The hit event is $\{h = b\}$.

A direct computation gives, for every kernel,

$$P_{\mathrm{hit}} = \sum_c \frac{\nu(c)}{K} \sum_b R(c,b,b). \tag{3.1}$$

**Theorem 3.2 (Internal readings die on fibre uniformity).** Suppose the reading is generated from the observable coordinate alone, possibly through an arbitrary $c$-dependent randomization: $R(c,b,h) = R_c(h)$ with $\sum_h R_c(h) = 1$. Then $P_{\mathrm{hit}} = 1/K$. In particular, for $K=2$ and $\theta = 1/2$,

$$\mathrm{Speedup} = \frac{1}{1-\frac12\cdot\frac12} = \frac43 .$$

*Proof.* In (3.1) the inner sum is $\sum_b R_c(b) = 1$, so $P_{\mathrm{hit}} = \frac1K\sum_c\nu(c) = \frac1K$. Then apply the master law. $\square$

The $4/3$ cap on residue-based internal filters is therefore *exactly the uninformative point of the master law*. It is the speedup of a filter that is right with chance probability.

**Theorem 3.3 (External likelihoods survive verbatim).** Suppose the reading is drawn from a likelihood that depends on the hidden label alone, $R(c,b,h) = L(b,h)$. Then

$$P_{\mathrm{hit}} = \frac1K \sum_{b} L(b,b),$$

the hint's average accuracy, independent of $\nu$. A perfect hint, $L(b,h) = \mathbf 1[b=h]$, has $P_{\mathrm{hit}} = 1$ and attains the ceiling $1/\theta$.

*Proof.* In (3.1) the inner sum $\sum_b L(b,b)$ does not depend on $c$. It factors out, and $\sum_c \nu(c) = 1$. $\square$

**Interpretation.** In both theorems the decisive step is the same: averaging over the uniform label inside each fibre of $c$. An internal reading is a function of $c$, so it is independent of the label within a fibre and hits with probability $1/K$. An external hint's likelihood is attached to the non-observable coordinate, so the averaging leaves its diagonal mass unchanged. This is where the symmetry between internal and external information breaks.

---

## 4. The which-factor ceiling

A modulus $N = pq$ has two factors. A hint like "a factor lies in class $h$" may be about $q$ rather than the wanted factor $p$, and the hint does not say which.

**Definition 4.1 (Which-factor model).** The sample space is $(b_p, b_q, w, h) \in [K]\times[K]\times\{\mathrm{true},\mathrm{false}\}\times[K]$ with

$$\mathbb P(b_p, b_q, w, h) = \frac{1}{2K^2}\,L\big(\text{if } w \text{ then } b_p \text{ else } b_q,\; h\big).$$

The two labels are independent and uniform, the hint speaks about $p$ or $q$ with probability $1/2$ each, and then reports $h$ according to the likelihood $L$, where $L \ge 0$ and $\sum_h L(b,h) = 1$. The hit event is $\{h = b_p\}$. The **accuracy** of the hint is $\alpha = \frac1K\sum_b L(b,b)$, and $\alpha \le 1$.

**Theorem 4.2 (Which-factor hit probability).** For $K\ge1$,

$$P_{\mathrm{hit}} = \frac{\alpha + 1/K}{2}.$$

*Proof.* On $w = \mathrm{true}$ the hit mass is $\sum_{b_p,b_q} L(b_p,b_p)/(2K^2) = K\cdot K\alpha/(2K^2) = \alpha/2$. On $w = \mathrm{false}$ it is $\sum_{b_q}\sum_{b_p} L(b_q,b_p)/(2K^2) = K/(2K^2) = 1/(2K)$, since each row of $L$ sums to one. $\square$

**Theorem 4.3 (Which-factor ceiling).** At per-dial cost $\theta = 1/K$,

$$\mathrm{Speedup} = S_{1/K}\!\left(\frac{\alpha+1/K}{2}\right) \;\le\; \frac{2K^2}{K^2+1} \;<\; 2$$

for every $K \ge 1$ and every likelihood $L$. The bound is attained by the perfect hint, and $2K^2/(K^2+1) \to 2$ as $K\to\infty$.

*Proof.* By Proposition 2.4(b) the speedup is increasing in $\alpha$, and $\alpha \le 1$. At $\alpha = 1$ the denominator is $1 - (1-\tfrac1K)\tfrac{1+1/K}{2} = \tfrac12(1+\tfrac1{K^2})$, which gives $2K^2/(K^2+1)$. Strictness: $2K^2 < 2(K^2+1)$. The limit holds because $2K^2/(K^2+1) = 2 - 2/(K^2+1)$. $\square$

**Corollary 4.4 (Canonical partition law).** For the binary dial $K=2$, $\theta = 1/2$,

$$\mathrm{Speedup}(\alpha) = \frac{8}{7-2\alpha}.$$

Landmarks: $\alpha = 1/2$ gives $4/3$, the internal cap, and $\alpha = 1$ gives $8/5 < 2$.

*Proof.* $1 - \tfrac12\cdot\tfrac{\alpha + 1/2}{2} = \tfrac{7-2\alpha}{8}$. $\square$

**Proposition 4.5 (Isolation removes the ceiling).** If the hint is known to speak about the wanted factor, a perfect hint has $P_{\mathrm{hit}} = 1$ and speedup $S_{1/K}(1) = K$. The ratio between the isolated and anonymous perfect-hint speedups is $(K^2+1)/(2K)$.

So the which-factor bit is the whole difference between a ceiling below $2$ and the full dial gain $K$. Section 9.4 computes its isolation price.

---

## 5. Moduli with $r$ factors

Let $r = s+1 \ge 2$ be the number of factors. The hint speaks about one uniformly chosen factor without naming it. Only the label of the spoken-about factor matters, and every other factor's label is independent of the wanted one. The law therefore reduces to the sufficient statistic $(b_p, b_{\text{other}}, j, h)$ with $j$ uniform on $\{0,\dots,s\}$, where $j=0$ means "about $p$". Its mass is $\frac{1}{(s+1)K^2}L(\cdot,h)$.

**Theorem 5.1 ($r$-factor hit probability).** $P_{\mathrm{hit}} = \dfrac{\alpha + s/K}{s+1} = \dfrac{\alpha + (r-1)/K}{r}$.

*Proof.* As in Theorem 4.2: the $j=0$ slice contributes $\alpha/(s+1)$, and each of the $s$ other slices contributes $1/((s+1)K)$. $\square$

**Theorem 5.2 ($r$-factor ceiling).** At per-dial cost $1/K$, every likelihood satisfies

$$\mathrm{Speedup} \;\le\; \Phi_s(K) := \frac{(s+1)K^2}{sK^2 - (s-1)K + s},$$

with equality for the perfect hint. The denominator is positive for $K \ge 1$, since it equals $s\,(K(K-1)+1) + K$. For $s = 1$ this is $2K^2/(K^2+1)$.

*Proof.* Monotonicity in $\alpha$ and the closed form of $S_{1/K}\big((1+s/K)/(s+1)\big)$. $\square$

**Theorem 5.3 (Fine-dial limit).** For $s\ge1$, $\Phi_s(K) \to (s+1)/s = r/(r-1)$ as $K\to\infty$.

*Proof.* Divide numerator and denominator by $K^2$. $\square$

**Theorem 5.4 (Overshoot).** For $r=2$ the ceiling approaches its limit $2$ from below. For $r \ge 3$ ($s \ge 2$) the finite dial $K = r$ already exceeds the limit: $\Phi_s(s+1) > (s+1)/s$.

*Proof sketch.* Cross-multiplying, the claim reduces to $s(s+1)^2 > s(s+1)^2 - (s-1)(s+1) + s$, that is, $(s-1)(s+1) > s$, or $s^2 - s - 1 > 0$. This holds for $s\ge2$. $\square$

So for three or more factors, refining the dial is not monotonically beneficial. A coarser dial beats the limit.

**Theorem 5.5 (Binary dial optimal for $r \ge 7$; collapse onto $4/3$).** At $K = 2$, $\Phi_s(2) = 4(s+1)/(3s+2) = 4r/(3r-1)$. If $s \ge 6$, then $\Phi_s(K) \le \Phi_s(2)$ for every $K \ge 1$. Moreover $4r/(3r-1) \to 4/3$ as $r\to\infty$.

*Proof sketch.* After clearing denominators, $\Phi_s(K) \le \Phi_s(2)$ is equivalent to
$$q(K) := (s-2)K^2 - 4(s-1)K + 4s \ge 0.$$
The quadratic $q$ has the root $K=2$, and since the product of its roots is $4s/(s-2)$, the other root is $2s/(s-2)$, which is at most $3$ when $s\ge 6$. Also $q(1) = s+2 > 0$. So $q$ is nonnegative at every positive integer. The limit follows by dividing by $s$. $\square$

*Interpretation.* For multi-prime moduli, an external hint that does not name its factor is asymptotically worth no more than an uninformative internal reading at the binary dial.

Exact values of the best ceiling over $K \le 60$ illustrate the transition: for $r=3$ the best dial is $K=4$ with value $1.6$, above the limit $1.5$. For $r = 4$ it is $K=3$ with value $1.5$. For $r = 7, 10, 50$ it is $K=2$, with values $1.400$, $1.379$ and $1.342$.

---

## 6. The certain-hint ladder: two bits lost

**Definition 6.1.** For $t \ge 2$ let
$$\Lambda(t) = \frac{2^{t-2}}{1-2^{1-t}}.$$

**Theorem 6.2 (Ladder as a master-law point).** With $a = 2^{1-t}$ and effective cost $\theta_t = 2a(1-a)$,
$$\Lambda(t) = S_{\theta_t}(1) = \frac{1}{\theta_t}.$$
The ladder is a *certain* hit at an effective cost.

*Proof.* $1/(2a(1-a)) = 2^t/(4(1-a))$. $\square$

**Theorem 6.3 (Bounds, bit loss and doubling).** For $t\ge2$:
1. $2^{t-2} < \Lambda(t) \le 2^{t-1}$;
2. $2^t/\Lambda(t) = 4(1-2^{1-t})$ exactly, hence $2^t/\Lambda(t) \to 4$;
3. $\Lambda(t+1)/\Lambda(t) \to 2$.

*Proof sketch.* For $t \ge 2$ we have $0 < a \le 1/2$, so $1-a \in [1/2, 1)$, which gives (1) and the identity (2). Then $a \to 0$ gives the limit in (2). For (3), $\Lambda(t+1)/\Lambda(t) = 2\cdot\frac{2^t/\Lambda(t)}{2^{t+1}/\Lambda(t+1)}$, and both quotients tend to $4$. $\square$

The ladder therefore loses **exactly two bits** against the ideal $2^t$ asymptotically, and each extra hint bit doubles it. The two lost bits are identified as the parity bit and the which-factor bit.

---

## 7. Trace hints: a bounded divisor is not a rate penalty

**Definition 7.1.** Given a recovery divisor $C_t > 0$, the trace-hint speedup is $T(t) = 2^{t-1}/C_t$.

**Theorem 7.2.** $\log_2 T(t) = t - 1 - \log_2 C_t$. Consequently:
1. if $0 < c_0 \le C_t \le c_1$ for all $t$, then $\log_2 T(t)/t \to 1$;
2. if $C_t \to c > 0$, then $\log_2 T(t+1) - \log_2 T(t) \to 1$.

*Proof sketch.* The identity is immediate. Under (1), $|1 + \log_2 C_t|$ is bounded by a constant $B$, so $|\log_2 T(t)/t - 1| \le B/t$. Under (2), continuity of $\log_2$ at $c$ shows that the increments of $\log_2 C_t$ tend to $0$. $\square$

A generic recovery step costing "about $5\times$ per hint" is therefore a *constant divisor*. The trace hint still gains one bit of work per hint bit.

---

## 8. The noise break-even surface

We adopt an explicit **fallback cost model**. With probability $\varepsilon$ the hint is corrupted: the hinted region (cost $\theta$) is searched in vain and then the full search (cost $1$) is run. Otherwise the master law applies:

$$W(\theta,P,\varepsilon) = (1-\varepsilon)\big(1-(1-\theta)P\big) + \varepsilon(1+\theta).$$

**Theorem 8.1 (Break-even surface).** Let $\theta<1$ and $\varepsilon<1$. A noisy which-factor hint of accuracy $\alpha$, so $P = (\alpha+\theta)/2$, is net-positive ($W<1$) if and only if
$$\alpha > \alpha^*(\theta,\varepsilon) := \frac{2\varepsilon\theta}{(1-\varepsilon)(1-\theta)} - \theta .$$
For $0<\theta<1$, $\alpha^*$ is nondecreasing in $\varepsilon$ on $[0,1)$.

*Proof.* $W < 1$ iff $\varepsilon\theta < (1-\varepsilon)(1-\theta)P$, which rearranges to the stated inequality. Monotonicity: $\varepsilon/(1-\varepsilon)$ is increasing. $\square$

**Theorem 8.2 (External hints tolerate more noise).** For $0<\theta<1$:
* an internal filter ($P = \theta$) is net-positive iff $\varepsilon < \dfrac{1-\theta}{2-\theta}$;
* a perfect unnamed external hint ($P = (1+\theta)/2$) is net-positive iff $\varepsilon < \dfrac{1-\theta^2}{1+2\theta-\theta^2}$;
* the second threshold is strictly larger than the first for every $\theta \in (0,1)$.

At $\theta = 1/2$ the thresholds are $1/3$ and $3/7$.

*Proof sketch.* Substitute $P$ into the criterion of Theorem 8.1. For the comparison, cross-multiply and cancel the positive factor $1-\theta$. What remains is $1 + 2\theta - \theta^2 < (1+\theta)(2-\theta) = 2 + \theta - \theta^2$, which is $\theta < 1$. $\square$

*Remark.* An alternative cost accounting used in the original experimental study reported thresholds of $1/6$ and $3/5$ at $\theta=1/2$. The numerical thresholds depend on how a failed attempt is charged, and we do not reconstruct that accounting here. The qualitative conclusion, that external hints tolerate strictly more noise than internal filters, holds in our model for all $\theta$.

---

## 9. A strategy-free guessing bound: $t$ bits buy at most $2^t$

The results so far concern filters of a specific "search the predicted class first" shape. We now show that the linear pricing of external information holds for *every* guessing strategy.

### 9.1 Setting

The target $X$ is uniform on a finite set $\mathcal A$ of size $M \ge 1$. A hint is an arbitrary map $H : \mathcal A \to B$ into a finite set. A strategy, after seeing the hint value, tests candidates one by one. Write $g(x) \ge 1$ for the step at which candidate $x$ is tested when it is the target.

**Definition 9.1 (Fibre-injective strategy).** $g$ is *fibre-injective* if $H(x) = H(y)$ and $g(x) = g(y)$ imply $x = y$. In words, two candidates with the same hint value are never tested at the same step. Every deterministic hint-adaptive strategy has this property.

Without a hint ($|B|=1$) the optimal expected number of guesses is $(M+1)/2$. We define $\mathbb E[g] = \frac1M\sum_x g(x)$ and $\mathrm{Speedup} = \frac{(M+1)/2}{\mathbb E[g]}$.

### 9.2 The bound

**Lemma 9.2 (Distinct positive integers).** If $s$ is a finite set of $n$ positive integers, then $n(n+1) \le 2\sum_{x\in s} x$.

*Proof.* Induct on the maximum element $a$. The other elements are $n-1$ distinct integers in $[1, a-1]$, so $n \le a$. The induction hypothesis gives $(n-1)n \le 2(\sum - a)$, and adding $2a \ge 2n$ gives $n(n+1) \le 2\sum$. $\square$

**Lemma 9.3 (Fibre cost).** For every hint value $b$ with fibre $F_b = H^{-1}(b)$ of size $n_b$, a fibre-injective strategy satisfies $n_b(n_b+1) \le 2\sum_{x\in F_b} g(x)$.

*Proof.* $g$ is injective on $F_b$, so $g(F_b)$ is a set of $n_b$ distinct positive integers with the same sum. Apply Lemma 9.2. $\square$

**Theorem 9.4 (Guessing bound).** For every hint $H$ and every fibre-injective strategy $g$ with $g \ge 1$,

$$M^2 + |B|\,M \;\le\; |B|\cdot 2\sum_{x\in\mathcal A} g(x), \qquad\text{equivalently}\qquad \mathbb E[g] \ge \frac12\left(\frac{M}{|B|}+1\right).$$

*Proof.* Split the sum over fibres and use Lemma 9.3: $\sum_b (n_b^2 + n_b) \le 2\sum_x g(x)$. Since $\sum_b n_b = M$, this reads $\sum_b n_b^2 + M \le 2\sum g$. By the Cauchy–Schwarz inequality, $M^2 = (\sum_b n_b)^2 \le |B|\sum_b n_b^2$. Multiply the first inequality by $|B|$ and combine. $\square$

**Theorem 9.5 (Speedup at most the number of hint values).** $\mathrm{Speedup} \le |B|$.

*Proof.* The claim is $M(M+1) \le 2|B|\sum g$. Theorem 9.4 gives $2|B|\sum g \ge M^2 + |B|M \ge M^2 + M$, because $|B| \ge 1$. ($|B| = 0$ is impossible when $M \ge 1$.) $\square$

**Corollary 9.6 (Linear pricing in bits).** If $|B| \le 2^t$, then $\mathrm{Speedup} \le 2^t$.

**Corollary 9.7 (No synergy).** Two hints $H_1, H_2$ with at most $2^{t_1}$ and $2^{t_2}$ values, used jointly through any strategy that is fibre-injective for the pair $(H_1,H_2)$, give $\mathrm{Speedup} \le 2^{t_1}\cdot 2^{t_2} = 2^{t_1+t_2}$.

*Proof.* Apply Corollary 9.6 to the product hint, which has at most $2^{t_1}2^{t_2}$ values. $\square$

### 9.3 Sharpness

**Theorem 9.8 (The bound is attained).** On $\mathcal A = [B]\times[m]$ with the perfect balanced hint $H(b,i) = b$ and in-fibre ranking $g(b,i) = i+1$, the strategy is fibre-injective and

$$B\cdot 2\sum g = (Bm)^2 + B\cdot(Bm).$$

*Proof.* $\sum g = B\cdot m(m+1)/2$, so $B\cdot 2\sum g = B^2m(m+1) = (Bm)^2 + B(Bm)$. $\square$

In that case the speedup equals $B(M+1)/(M+B)$, which tends to $B$ as $M/B\to\infty$. So the factor $|B|$ in Theorem 9.5 cannot be improved.

### 9.4 Isolation cost

**Theorem 9.9 (Isolation needs exactly $\lceil\log_2 M\rceil$ queries).** Let $Q$ assign to each of $M$ candidates its vector of answers to $q$ yes/no queries. If $Q$ separates all candidates (is injective), then $M \le 2^q$, so $q \ge \lceil \log_2 M\rceil$. Conversely, $\lceil\log_2 M\rceil$ queries always suffice, using binary encoding of the candidate index.

*Proof.* Pigeonhole on the $2^q$ answer vectors, and conversely an injection $[M] \hookrightarrow \{0,1\}^{\lceil \log_2 M\rceil}$. $\square$

With $M = \pi(\sqrt N)$ candidate primes, the isolation price of breaking the which-factor ceiling is $\lceil\log_2\pi(\sqrt N)\rceil$ oracle queries. This grows very slowly: $6$, $10$, $13$, $17$ queries for $N$ of $16$, $24$, $32$, $40$ bits. In the cost accounting of the original experiments, paying this price becomes net-positive from $t = 5$ hint bits on. That break-even depends on prime-counting data and is reported here as an empirical observation.

---

## 10. Algorithms

**Algorithm A (Evaluate a filter by its hit probability).** Input: a finite space $(\Omega,\mu)$, a hit predicate, a cost $\theta$. Compute $P = \sum_{\omega\in\mathrm{hit}} \mu(\omega)$ in $O(|\Omega|)$ time and return $S_\theta(P)$. By Theorem 2.2 this is exact. For the product models of Sections 3–5 the closed forms make it $O(K)$, because only the diagonal of the likelihood matters.

**Algorithm B (Optimal hinted guessing).** For a uniform target: on hint value $b$, test the elements of the fibre $H^{-1}(b)$ in any fixed order. The expected cost is $\frac1M\sum_b n_b(n_b+1)/2$, which by Lemma 9.3 is optimal fibre by fibre. It meets Theorem 9.4 with equality exactly when the fibres are balanced.

**Algorithm C (Best dial for an $r$-factor anonymous hint).** Maximize $\Phi_{r-1}(K)$ over $K \in \{1,\dots,K_{\max}\}$ in $O(K_{\max})$ time. Theorem 5.5 shows that for $r\ge7$ the scan can be skipped: the answer is $K = 2$.

**Algorithm D (Noise break-even test).** Given $(\theta,\varepsilon,\alpha)$, decide whether the hint helps by comparing $\alpha$ with $\alpha^*(\theta,\varepsilon)$. This takes $O(1)$ and agrees with direct evaluation of $W<1$ by Theorem 8.1.

---

## 11. Empirical corroboration

The original experimental study reported Monte Carlo and exhaustive checks consistent with the theorems:

* simulations with modulus parameter $m = 31$ and $400{,}000$ trials matched the partition law to within $0.0032$ across the tested accuracies $\alpha$;
* splitting by a character $\chi(c)$ of the observable coordinate reproduced the internal value $P_{\mathrm{hit}} = 1/K$ pointwise exactly, as Theorem 3.2 predicts fibre by fibre;
* exhaustive enumeration for $m = 3,\dots,8$ deviated from the closed forms by at most $0.0089$;
* the ratio of measured to predicted ladder speedups lay in $[0.9986, 1.0045]$;
* break-even verdicts agreed with the closed-form surface in $20$ of $20$ cases.

One methodological episode is worth recording. In an early experiment the hit was evaluated in the wrong label space, and the result was a speedup *flat in $\alpha$*. This is exactly the signature that Theorem 3.2 predicts for a reading that is effectively a function of the observable coordinate. The symmetry-break theorem thus doubles as a diagnostic: a hint whose measured value does not move with its accuracy is being scored against the wrong coordinate.

---

## 12. Discussion: the completed barrier map

| Information source | Price | Status |
|---|---|---|
| Residues (internal) | capped at $4/3$, the uninformative point of the master law | theorem (Thm 3.2) |
| Position (structural) | $\approx 5.19\times$ | measured in companion experiments |
| External hints | linear in bits: $\le 2^t$; below $2\times$ per dial unless named | theorem (Thms 4.3, 9.6) |

Three themes connect these results.

*One scalar.* Because the master law depends on the filter only through $P_{\mathrm{hit}}$, every question about the value of information reduces to computing a hit probability. The $4/3$ cap, the partition law, the $r$-factor ceilings and the ladder are all evaluations of the same function $S_\theta$ at different points.

*Where information lives.* Fibre uniformity on the observable coordinate is what caps internal readings. External hints escape the cap because their likelihood lives on the hidden coordinate. This explains why external information can help at all, while internal readings, however sophisticated, cannot.

*No synergy for work bits.* In channel coding, combining resources can produce capacity gains greater than the sum of their parts. Theorem 9.4 shows that nothing like this happens for work: the speedup from any hint is bounded by its number of values, so bits of hint buy bits of work at most additively. The which-factor tax and the ladder's two lost bits are concrete instances of hint bits that buy *less* than one work bit each.

---

## 13. Future directions

1. **Partial naming.** If the hint names its factor with probability $\beta$, then $P_{\mathrm{hit}}$ is the $\beta$-mixture of the isolated and anonymous values. We conjecture that the best speedup is exactly $S_{1/K}\big(\beta + (1-\beta)(1 + (r-1)/K)/r\big)$, which would price every fraction of the which-factor bit linearly at the level of $P_{\mathrm{hit}}$.
2. **Non-uniform priors.** Theorem 9.4 is the uniform case of Arıkan's guessing inequality. A weighted rearrangement argument should give a $2^t$ bound modulated by the Rényi entropy of order $1/2$ of the prior, and might identify the ladder's two lost bits with the entropy of the pair (parity, which-factor).
3. **Reconciling noise accountings.** Find the cost model that yields the experimental thresholds $1/6$ and $3/5$, and prove the qualitative ordering for a whole family of accountings.
4. **Isolation break-even.** Turn the empirical $t=5$ break-even into a theorem using explicit prime-counting bounds.

---

## 14. Conclusion

A filtered search is priced by one number, its hit probability. Internal readings are pinned at chance by fibre uniformity, and the familiar $4/3$ cap is the speedup of a coin flip. External hints escape that pinning, but an anonymous hint about one of two factors is capped below $2\times$ per dial. Beyond this ceiling, and for every strategy whatsoever, a $t$-bit hint buys at most $2^t$. External information is priced linearly in bits.
