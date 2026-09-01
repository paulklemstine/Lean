# Contraction Is the Identifying Hypothesis: Floors, Extinction, and Non-Identifiability for Fading Correlation Ladders

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We study *fading ladders*: finite or infinite sequences $\rho_0, \rho_1, \rho_2, \ldots$ of measured association strengths recorded on a regular grid of a complexity parameter. The motivating instance is the Spearman rank correlation between the trailing-zero statistic $T(x) = \nu_2(x)$ of a uniformly drawn $b$-bit integer and a downstream response ("rate"), measured on the four-bit grid $b = 96, 100, \ldots, 120$, with pooled reading $\rho(104) = 0.500$, confidence interval $[0.456, 0.545]$, and per-seed values $0.493 / 0.499 / 0.509$.

The scientific question is whether such a ladder possesses a positive floor or is extinguished at finite $b$. We prove four things.

1. **An exact dichotomy.** Every fade with nonnegative decrements either admits a uniform lower bound or reaches $0$ at a finite rung, with no third behaviour; the discriminating property is the *summability* of the decrements, not their decay.
2. **Vanishing decrements are not evidence.** The harmonic fade with the recorded start $0.5739$ and recorded first step $0.0303$ has strictly decreasing decrements tending to $0$, remains above $0.33$ throughout its first $128$ four-bit steps (a span of $512$ bits, four times the entire recorded sweep), and is nevertheless extinguished by its $2^{36}$-th step.
3. **Non-identifiability.** For any observed ladder $g_0,\ldots,g_N$ with $g_N > 0$ there exist two continuations that reproduce all observations exactly and are both antitone thereafter, one bounded below by $g_N/2 > 0$ for ever and the other equal to $0$ at rung $N+10$. Instantiated on the seven recorded rungs: a floor at $0.21818$ and extinction at $b = 160$ are both consistent with all data.
4. **Contraction is exactly the missing hypothesis — and the data violate it.** A $q$-contractive ladder ($|d_{k+1}| \le q|d_k|$, $0 \le q < 1$) satisfies the tail bound $|\rho_{n+m} - \rho_n| \le |d_n|/(1-q)$ for all $m$, hence has the explicit floor $\rho_n - |d_n|/(1-q)$ and is never extinguished once that floor is positive. The recorded ladder admits no contraction factor below $2$: the rebound decrement $-0.0226$ at $b=116$ is retraced at $b=120$ by a step of $+0.04834$, forcing $q \ge 2.138\ldots$

We also record a curvature obstruction: exact second-difference identities show that every convex fade law of hyperbolic or geometric type decelerates, whereas the recorded decrements accelerate across $b = 96,100,104$; and the full seven-rung ladder contains both a strictly convex and a strictly concave grid triple, so no law of fixed curvature sign reproduces it. We give algorithms for auditing contraction, certifying floors, and computing the envelope of admissible continuations, and we specify a discriminating measurement at $b = 156$ at which the two extremal continuations differ by more than $0.17$.

**Keywords:** fading ladder, contraction factor, tail bound, non-identifiability, 2-adic valuation, Spearman correlation, feature degradation, extrapolation.

---

## 1. Introduction

### 1.1 The empirical setting

Let $x$ be drawn uniformly from the $b$-bit integers and let $T(x) = \nu_2(x)$ denote the number of trailing zeros in the binary expansion of $x$ — equivalently the $2$-adic valuation. In the pipeline under study, $T$ is used as a predictive feature for a downstream scalar response, and the quality of that feature is summarised by the Spearman rank correlation

$$\rho(b) \;=\; \operatorname{corr}_{\mathrm{rank}}\bigl(T,\ \mathrm{rate}\bigr)$$

estimated from a large uniform sample at bit-length $b$. As $b$ increases the correlation decays; the phenomenon is referred to as *the fade*.

The current cycle records $b = 104$ across three seeds:

| seed | $\rho(104)$ |
|---|---|
| 20261210 | $0.493$ |
| 20261211 | $0.499$ |
| 20261212 | $0.509$ |
| **pooled** | $\mathbf{0.500}$, CI $[0.456, 0.545]$ |

Every seed lies below $0.55$ for the first time. The two preceding four-bit steps are $-0.030$ and $-0.043$: the fade is monotone and near-linear over that window, and if anything *accelerating*. A companion baseline statistic (a bit-count feature) is degrading faster, so the advantage of $T$ over the baseline has **widened** through $+0.070$, $+0.073$, $+0.126$.

The seven rungs available on the four-bit grid, indexed by $k$ with $b = 96 + 4k$, are

$$\rho_0,\ldots,\rho_6 \;=\; 0.5739,\ 0.5436,\ 0.5005,\ 0.4880,\ 0.4621,\ 0.4847,\ 0.43636 .$$

Of these, only $\rho_2 = 0.5005$ (rounded to $0.500$) and its three seeds are *recorded numbers of the present experiment*; $\rho_0$ and $\rho_1$ are reconstructed from the reported step sizes $-0.030$ and $-0.043$, and are used below only through those steps. Rungs $\rho_3,\ldots,\rho_6$ are later recorded readings used for out-of-sample scoring. Every statement below that depends on a reconstructed value says so.

### 1.2 The dispute

Two incompatible readings of these seven numbers exist. A *plateau* reading localises the limit in the band $[0.4362, 0.488]$, recovering a floor near $0.474$ by Aitken $\Delta^2$ extrapolation and by assuming a decrement contraction factor $r \le 1/2$. An *extinction* reading extrapolates secants and forecasts the dial reading $0$ near $b = 230$.

The present paper does not adjudicate between them on the merits. It determines what a finite ladder can decide at all, isolates the exact hypothesis that would decide it, and audits that hypothesis against the data.

### 1.3 Contributions

- §3: the fade dichotomy — floor or finite extinction, and summability as the sole criterion.
- §4: the harmonic counterexample — vanishing decrements are compatible with certain, unobservable death.
- §5: non-identifiability — two continuations, same past, opposite futures.
- §6: contraction theory — geometric decay of decrements, the tail bound, the explicit floor, non-extinction.
- §7: the audit — the recorded ladder forces $q \ge 2$.
- §8: curvature obstructions — no convex law, and in fact no fixed-curvature-sign law, fits.
- §9: algorithms. §10: discussion, applications, limitations. §11: future directions.

---

## 2. Ladders, decrements, and terminology

**Definition 2.1 (Ladder and decrement).** A *ladder* is a sequence $\rho : \mathbb{N} \to \mathbb{Q}$; rung $k$ corresponds to bit-length $96 + 4k$ in the empirical instance. Its *decrement at rung $k$* is
$$d_k \;=\; \rho_k - \rho_{k+1}.$$
A positive $d_k$ is a fade step; a negative $d_k$ is a *rebound*.

**Definition 2.2 (Generated ladder).** Given a start value $\rho_0$ and a decrement sequence $(d_k)$, the *generated ladder* is
$$\rho_n \;=\; \rho_0 - \sum_{k<n} d_k, \qquad \text{so that} \qquad \rho_{n+1} = \rho_n - d_n .$$
The two definitions are mutually inverse. If $d_k \ge 0$ for all $k$ the ladder is antitone.

**Definition 2.3 (Floor, extinction).** A ladder *has a floor* if there is $L \in \mathbb{Q}$ with $L \le \rho_n$ for all $n$; the floor is *positive* if $L > 0$ can be chosen. A ladder is *extinguished* if $\rho_n \le 0$ for some finite $n$.

**Definition 2.4 ($q$-contractive ladder).** For $q \ge 0$, a ladder is *$q$-contractive* if
$$|d_{k+1}| \;\le\; q\,|d_k| \qquad \text{for all } k .$$
The *empirical contraction factor* of a finite ladder with decrements $d_0,\ldots,d_{m}$ is the least $q$ for which the finitely many inequalities hold, i.e. $q^\star = \max_{k<m} |d_{k+1}|/|d_k|$ when all $d_k \ne 0$.

---

## 3. The fade dichotomy

The first result relocates the entire debate from *rate of decay* to *summability*.

**Theorem 3.1 (Bounded decrement budget gives a floor).** *Let $\rho$ be the ladder generated by $\rho_0$ and $(d_k)$, and suppose $\sum_{k<n} d_k \le S$ for every $n$. Then $\rho_n \ge \rho_0 - S$ for every $n$.*

*Proof.* Immediate from $\rho_n = \rho_0 - \sum_{k<n} d_k \ge \rho_0 - S$. $\square$

**Corollary 3.2 (Positive floor).** *If in addition $S < \rho_0$, then $\rho_n > 0$ for all $n$: the ladder survives for ever, with the explicit positive floor $\rho_0 - S$.*

**Theorem 3.3 (Unbounded budget forces extinction).** *If the partial sums $\sum_{k<n} d_k$ exceed every bound, then $\rho_n \le 0$ for some finite $n$.*

*Proof.* Choose $n$ with $\sum_{k<n} d_k \ge \rho_0$; then $\rho_n = \rho_0 - \sum_{k<n} d_k \le 0$. $\square$

**Theorem 3.4 (The Fade Dichotomy).** *For every start $\rho_0$ and every decrement sequence $(d_k)$, either the generated ladder has a floor, or it is extinguished at a finite rung.*

*Proof.* Case on whether the set of partial sums is bounded above. If a bound $S$ exists, Theorem 3.1 gives the floor $\rho_0 - S$. If not, the partial sums exceed every bound and Theorem 3.3 applies. $\square$

**Remark 3.5.** Theorem 3.4 is deliberately trivial, and that is its point. It says there is no intermediate regime — no "asymptotically approaches zero without reaching it" escape hatch for a nonnegative-decrement fade on a discrete grid. Consequently *any* argument for a floor is, whether or not it says so, an argument that $\sum_k d_k < \infty$; and any argument for extinction is an argument that $\sum_k d_k = \infty$. Statements about how fast the $d_k$ shrink are relevant only insofar as they bear on that sum.

---

## 4. Vanishing decrements certify nothing

The observation that motivated the plateau reading is that the decrement fell from $0.0431$ (at $b = 100 \to 104$) to $0.0125$ (at $b = 104 \to 108$). We now show that decrements shrinking to zero — a far stronger property than a single observed decrease — is compatible with certain extinction, and indeed with extinction that no feasible experiment could detect.

**Definition 4.1 (Harmonic fade).** For $\rho_0, c \in \mathbb{Q}$ with $c > 0$, the *harmonic fade* is the ladder with decrements $d_k = c/(k+1)$, i.e.
$$H\!f(\rho_0, c; n) \;=\; \rho_0 - c\,H_n, \qquad H_n = \sum_{k=1}^{n}\frac1k .$$

**Lemma 4.2 (Decrements vanish).** *For every $\varepsilon > 0$ there is $N$ with $c/(k+1) < \varepsilon$ for all $k \ge N$. The decrements are moreover strictly decreasing and strictly positive.*

**Theorem 4.3 (Yet the harmonic fade dies).** *For every $\rho_0$ and every $c > 0$ there is a finite $n$ with $H\!f(\rho_0,c;n) \le 0$.*

*Proof sketch.* Use the dyadic lower bound $H_{2^m} \ge 1 + m/2$. Pick a natural number $m > 2(\rho_0/c - 1)$; then $\rho_0/c \le 1 + m/2 \le H_{2^m}$, so $\rho_0 \le c\,H_{2^m}$ and the ladder is $\le 0$ at $n = 2^m$. $\square$

**Theorem 4.4 (Quantitative form at the recorded numbers).** *Take the reconstructed start $\rho_0 = 0.5739$ and the recorded first step $c = 0.0303$. Then*

1. *$H\!f(\rho_0,c;\,2^{36}) \le 0$ — the fade is extinguished by its $2^{36}$-th four-bit step;*
2. *$H\!f(\rho_0,c;\,n) > 0.33$ for every $n \le 128$ — i.e. over a span of $512$ bits, four times the entire recorded sweep.*

*Proof sketch.* For (1), $H_{2^{36}} \ge 1 + 18 = 19$ and $0.0303 \cdot 19 = 0.5757 > 0.5739$. For (2), $H_n \le H_{128} = H_{2^7} \le 1 + 7 = 8$ by the dyadic upper bound and monotonicity of $H$, and $0.5739 - 0.0303 \cdot 8 = 0.3315 > 0.33$. $\square$

**Theorem 4.5 (Vanishing steps do not certify a floor).** *There exists a fade whose decrements are positive and tend to $0$, which reads above $0.33$ throughout the observable range of bit-lengths, and which is nevertheless extinguished at a finite bit-length.*

Theorem 4.5 disposes of the inference "the step shrank at $b = 108$, therefore there is a plateau." A ladder can decelerate monotonically, look convergent for four times the length of the experiment that produced it, and still be on a trajectory to zero. The observable window simply does not contain the information.

---

## 5. Non-identifiability of the limit

Theorem 4.5 shows one particular inference is invalid. The next result shows that *no* inference from finitely many rungs can work.

**Definition 5.1 (Two continuations).** Given an observed ladder $g_0,\ldots,g_N$ (extended arbitrarily), define for all $k$:

$$\mathrm{Floor}_N(k) = \begin{cases} g_k, & k \le N,\\[2pt] \dfrac{g_N}{2}\Bigl(1 + \bigl(\tfrac12\bigr)^{\,k-N}\Bigr), & k > N,\end{cases} \qquad \mathrm{Death}_N(k) = \begin{cases} g_k, & k \le N,\\[2pt] g_N - (k-N)\dfrac{g_N}{10}, & k > N.\end{cases}$$

**Theorem 5.2 (Non-identifiability).** *Let $g_N > 0$. Then*

1. *$\mathrm{Floor}_N(k) = g_k$ and $\mathrm{Death}_N(k) = g_k$ for every $k \le N$ — both reproduce the data exactly;*
2. *both are antitone for $k \ge N$ — neither behaves pathologically after the data end;*
3. *$\mathrm{Floor}_N(k) \ge g_N/2 > 0$ for every $k \ge N$ — the first has a positive floor;*
4. *$\mathrm{Death}_N(N+10) = 0$ — the second is extinguished ten rungs later.*

*Proof sketch.* (1) is by definition. For (3), $\tfrac{g_N}{2}(1 + 2^{-(k-N)}) \ge \tfrac{g_N}{2}$ since the bracket exceeds $1$. For (2), the floor continuation decreases because $2^{-(k-N)}$ does, with the boundary case $k = N$ handled separately ($\tfrac{g_N}{2}(1+\tfrac12) = \tfrac34 g_N \le g_N$); the death continuation decreases because it is affine in $k$ with negative slope $-g_N/10$, again with the boundary case checked directly. For (4), substitute $k - N = 10$. $\square$

**Corollary 5.3 (Both readings survive every recorded rung).** *Applied to the seven recorded rungs with $N = 6$ and $g_6 = 0.43636$: there is a continuation agreeing with all seven measurements that never falls below $0.21818$, and another agreeing with all seven measurements that equals $0$ at rung $16$, i.e. at bit-length $160$.*

**Corollary 5.4 (Discriminating measurement).** *At rung $15$ — bit-length $156$ — the two continuations satisfy $\mathrm{Floor}_6(15) > 0.21$, $\mathrm{Death}_6(15) < 0.05$, and their gap exceeds $0.17$. A reading above $0.21$ there refutes this extinction continuation; a reading below $0.05$ refutes the plateau one.*

The moral: the dispute between the two readings is not a dispute about statistical significance. It is formally undecided by the recorded data, and can be settled only by a new measurement or by an additional structural hypothesis.

---

## 6. Contraction: the identifying hypothesis

We now isolate the structural hypothesis that does the work, and show precisely what it buys.

**Theorem 6.1 (Geometric decay of decrements).** *Let $q \ge 0$ and let $\rho$ be $q$-contractive. Then for all $n, j$,*
$$|d_{n+j}| \;\le\; q^{\,j}\,|d_n| .$$

*Proof.* Induction on $j$. For $j = 0$ this is equality. For the step, $|d_{n+j+1}| \le q|d_{n+j}| \le q\bigl(q^j |d_n|\bigr) = q^{j+1}|d_n|$, the middle inequality using $q \ge 0$ and the inductive hypothesis. $\square$

**Lemma 6.2 (Geometric partial sums).** *For $0 \le q < 1$ and every $m$, $\displaystyle\sum_{j<m} q^{\,j} = \frac{1 - q^m}{1-q} \le \frac{1}{1-q}$.*

**Theorem 6.3 (Tail Bound).** *Let $0 \le q < 1$ and let $\rho$ be $q$-contractive. Then for all $n$ and all $m$,*
$$\bigl|\rho_{n+m} - \rho_n\bigr| \;\le\; \frac{|d_n|}{1-q} .$$

*Proof sketch.* Show first, by induction on $m$, the partial-sum form
$$|\rho_{n+m} - \rho_n| \;\le\; |d_n| \sum_{j<m} q^{\,j}.$$
The base case is trivial. For the step, insert the intermediate rung and use the triangle inequality
$$|\rho_{n+m+1} - \rho_n| \le |\rho_{n+m+1} - \rho_{n+m}| + |\rho_{n+m} - \rho_n|,$$
observe $\rho_{n+m+1} - \rho_{n+m} = -d_{n+m}$ so the first term equals $|d_{n+m}| \le q^m |d_n|$ by Theorem 6.1, and add the inductive bound. Finally apply Lemma 6.2 and $|d_n| \ge 0$. $\square$

**Theorem 6.4 (Contraction gives an explicit floor).** *Under the hypotheses of Theorem 6.3, for every $n$ and $m$,*
$$\rho_{n+m} \;\ge\; \rho_n - \frac{|d_n|}{1-q} .$$

*Proof.* The lower half of $|\rho_{n+m} - \rho_n| \le |d_n|/(1-q)$. $\square$

**Theorem 6.5 (Non-extinction).** *Under the hypotheses of Theorem 6.3, if at some rung $n$ the current step is small relative to the current reading, in the precise sense*
$$\frac{|d_n|}{1-q} \;<\; \rho_n ,$$
*then $\rho_{n+m} > 0$ for every $m$: the ladder is never extinguished.*

*Proof.* Combine Theorem 6.4 with the hypothesis. $\square$

**Remark 6.6 (Interpretation).** Theorem 6.3 is the reason contraction is the natural identifying hypothesis: it converts a *single* measured decrement into a certificate about the entire infinite future. Nothing weaker will do. Decay of $d_k$ to zero is insufficient (Theorem 4.5); agreement with finitely many rungs is insufficient (Theorem 5.2). Contraction is sufficient, and it is exactly what the plateau arguments assume: one of them posits a contraction factor $r \le 1/2$ outright, and the other applies Aitken $\Delta^2$ extrapolation, which is exact precisely for geometrically contracting sequences.

**Remark 6.7 (Sharpness of the constant).** The bound $|d_n|/(1-q)$ is attained in the limit by the exactly geometric ladder $\rho_{n+m} = \rho_n - |d_n|\sum_{j<m} q^j$, whose total remaining fade tends to $|d_n|/(1-q)$. So no smaller constant depending only on $|d_n|$ and $q$ is possible.

---

## 7. The audit: the recorded ladder is not contractive

**Definition 7.1 (Recorded decrements).** With the seven rungs of §1.1, the six four-bit decrements $d_k = \rho_k - \rho_{k+1}$ are exactly

$$d_0 = 0.0303,\quad d_1 = 0.0431,\quad d_2 = 0.0125,\quad d_3 = 0.0259,\quad d_4 = -0.0226,\quad d_5 = 0.04834 .$$

(As rationals: $\tfrac{303}{10000}$, $\tfrac{431}{10000}$, $\tfrac{125}{10000}$, $\tfrac{259}{10000}$, $-\tfrac{226}{10000}$, $\tfrac{4834}{100000}$.)

**Theorem 7.2 (The first pair already fails).** *$|d_0| < |d_1|$, i.e. $0.0303 < 0.0431$. Hence no $q \le 1$ satisfies even the first contraction inequality.*

**Theorem 7.3 (No contraction factor below two).** *If $q$ satisfies $|d_{k+1}| \le q\,|d_k|$ for all $k < 6$, then $q \ge 2$.*

*Proof.* Take $k = 4$. Then $|d_5| \le q|d_4|$, i.e. $\tfrac{4834}{100000} \le q \cdot \tfrac{226}{10000}$, whence
$$q \;\ge\; \frac{4834}{2260} \;=\; 2.13893\ldots \;>\; 2. \qquad \square$$

**Corollary 7.4 (No uniform contraction).** *There is no $q < 1$ with $|d_{k+1}| \le q\,|d_k|$ for all $k < 6$.*

**Theorem 7.5 (Identifiability needs contraction; the data supply none).** *The conjunction of two statements:*

1. *for every ladder $\rho$ and every $q$ with $0 \le q < 1$ that is $q$-contractive, and all $n, m$: $\;\rho_{n+m} \ge \rho_n - |d_n|/(1-q)$;*
2. *for every $q$ bounding the six recorded consecutive step ratios: $\;q \ge 2$.*

*Consequently the plateau reading is a hypothesis about rungs not yet measured, not a consequence of the rungs that have been.*

**Remark 7.6 (Where the failure lives).** The decisive violation is the *rebound*. At $b = 116$ the ladder went **up**: $d_4 = -0.0226 < 0$. At $b = 120$ it gave the gain back with interest: $d_5 = +0.04834$, more than $2.13$ times the size of the rebound. A contractive process cannot do this; its increments are pinned by the previous one. The plateau forecast that assumed $r \le 1/2$ was therefore applied to a ladder whose empirical contraction factor exceeds that assumption by a factor of more than four.

**Remark 7.7 (What is *not* claimed).** Theorem 7.3 does not prove that the ladder has no floor. It proves that the only currently available *sufficient* condition for a floor is falsified by the data, so the floor claim is unsupported. Theorem 3.4 remains in force: the true ladder has a floor or is extinguished, and the recorded rungs do not say which.

---

## 8. Curvature obstructions

A natural attempt to break the deadlock is to fit a parametric law. This section records why the two standard families fail structurally, not merely numerically.

**Definition 8.1.** The *hyperbolic law* is $h_{A,C}(b) = A + C/b$; the *geometric law* is $g_{A,C,q}(b) = A + C q^{b}$.

**Theorem 8.2 (Exact second differences on the four-bit grid).** *For all admissible $b$,*
$$\bigl(h(b) - h(b{+}4)\bigr) - \bigl(h(b{+}4) - h(b{+}8)\bigr) \;=\; \frac{32\,C}{b\,(b{+}4)\,(b{+}8)},$$
$$\bigl(g(b) - g(b{+}4)\bigr) - \bigl(g(b{+}4) - g(b{+}8)\bigr) \;=\; C\,q^{\,b}\,\bigl(1 - q^{4}\bigr)^{2}.$$

*Proof sketch.* Direct algebra: expand and clear denominators in the first case; factor $C q^b(1 - q^4)^2$ in the second, which is the square of the one-step operator $1 - q^4$ applied twice. $\square$

**Corollary 8.3 (Every convex fade law decelerates).** *For $C > 0$ both expressions are strictly positive, and positivity of the second difference says exactly that consecutive four-bit decrements are decreasing.*

**Theorem 8.4 (The observed fade accelerates).** *$\rho_0 - \rho_1 = 0.0303 < 0.0431 = \rho_1 - \rho_2$.*

**Corollary 8.5 (Shape-class exclusion).** *No hyperbolic law and no geometric law, for any parameter values, passes through the three readings at $b = 96, 100, 104$.* In particular the previously fitted law $\rho(b) = \tfrac{5}{14} + \tfrac{93}{5b}$, with asymptote $5/14 \approx 0.357$, is excluded as a shape class and not merely as a parameter choice; its residual changes sign across $b = 96\ldots104$ and its own four-bit step is more than five times too small.

**Theorem 8.6 (No fixed curvature sign at all).** *The full seven-rung ladder contains a strictly concave grid triple and a strictly convex one. The triple at $b = 96,100,104$ has second difference $d_0 - d_1 = 0.0303 - 0.0431 = -0.0128 < 0$ (acceleration, concave); the triple at $b = 100,104,108$ has second difference $d_1 - d_2 = 0.0431 - 0.0125 = +0.0306 > 0$ (deceleration, convex). Hence no law whose second difference has constant sign reproduces the recorded ladder.*

**Remark 8.7 (Out-of-sample scoring, honestly reported).** The acceleration hypothesis that would have followed from $b \le 104$ alone did *not* persist: the next decrement was $0.0125$ against a preceding $0.0431$, and the ladder rose at $b = 116$. Any extinction forecast resting on persistent acceleration is therefore void. A local secant law $\rho(b) = 1.449 - 0.009125\,b$ reproduces $b = 96$ and $b = 104$ exactly and $b = 100$ to within $0.0065$, wins the next two rungs against the hyperbolic law, and loses the two after that; both models are off by more than $7\%$ at $b = 120$. Two independent secants — one through $b = 52,104$ and one through $b = 104,120$ — agree in placing extinction between $b = 228$ and $b = 231$. This is a forecast under an explicitly linear hypothesis, not a theorem.

---

## 9. Algorithms

### 9.1 Contraction audit

**Input.** Rungs $\rho_0,\ldots,\rho_N$.
**Output.** The empirical contraction factor $q^\star = \max_{k<N-1} |d_{k+1}|/|d_k|$, and a verdict.

Compute the decrements, then the consecutive absolute ratios, then their maximum. If $q^\star < 1$, the tail bound of Theorem 6.3 applies with $q = q^\star$ and yields a certified floor; if $q^\star \ge 1$, no contraction certificate exists and the ladder's limit is unidentified. Complexity $O(N)$ arithmetic operations; exact in rational arithmetic. On the recorded data the algorithm returns $q^\star = 4834/2260 = 2.1389\ldots$ with verdict *not contractive*.

### 9.2 Certified floor from one step

**Input.** A rung index $n$, the value $\rho_n$, the decrement $d_n$, and a contraction factor $q \in [0,1)$ *assumed* to hold from rung $n$ onward.
**Output.** The certified floor $L = \rho_n - |d_n|/(1-q)$, and the verdict "never extinguished" if $L > 0$.

By Theorems 6.4–6.5 this is valid for every later rung. The algorithm is $O(1)$; its entire content is the honesty of $q$. Applied to the last recorded rung with the assumed factor $q = 1/2$: $L = 0.43636 - 2\cdot 0.04834 = 0.33968$ — but the hypothesis $q = 1/2$ is false for this ladder (Theorem 7.3), so the certificate is void. This is precisely the failure mode the audit of §9.1 is designed to catch *before* the certificate is issued.

### 9.3 Admissible-continuation envelope

**Input.** Rungs $\rho_0,\ldots,\rho_N$ and a horizon $M$.
**Output.** For each $k \in [N, N+M]$, the pair $\bigl(\mathrm{Death}_N(k), \mathrm{Floor}_N(k)\bigr)$ and their gap.

This exhibits, at every future rung, two data-consistent antitone continuations bracketing radically different futures; the gap is the *identification gap* at that horizon. It reaches $0.17$ at $k = 15$ ($b = 156$), which is the recommended discriminating measurement. Complexity $O(M)$.

### 9.4 Harmonic-trap simulator

**Input.** Start $\rho_0$, first step $c$, horizon $n$.
**Output.** $\rho_0 - c H_n$, together with the dyadic bracket $1 + m/2 \le H_{2^m} \le 1+m$ used to locate the extinction rung.

This makes the content of Theorem 4.4 concrete: the ladder is above $0.33$ at $n = 128$ and provably $\le 0$ by $n = 2^{36}$. Complexity $O(n)$ for direct summation, $O(1)$ for the dyadic bracket.

---

## 10. Discussion

### 10.1 What the result means for the empirical thread

The reading at $b = 104$ is $\rho = 0.500$ with CI $[0.456, 0.545]$, and the advantage over the count baseline has widened to $+0.126$ because the baseline degrades faster. The fade is real and monotone over the window $96 \to 112$, and the *rate* of fading through that window is well described locally by a linear law. What cannot be extracted from the data is the limit. Every floor estimate advanced so far rests on a contraction assumption that the data refute.

The constructive consequence is a concrete experimental recommendation: measure the rung at $b = 156$. Corollary 5.4 shows the two extremal data-consistent continuations are separated by more than $0.17$ there, which is far larger than the width of the current confidence interval ($0.089$). One measurement, at a specified bit-length, converts a formally undecided question into an empirically resolvable one.

### 10.2 Methodological transfer

The pattern generalises well beyond this feature. Whenever a practitioner watches a quality metric degrade along a complexity axis — accuracy versus sequence length, signal versus dimension, calibration versus horizon — the same three traps appear:

1. **Reading deceleration as convergence.** Theorem 4.5 is the counterexample to keep in mind: a metric can decelerate monotonically, remain visibly above a threshold for four times the length of the observed run, and still reach zero.
2. **Reading a good fit as identification.** Theorem 5.2 says that agreement with all observed data is worth nothing as evidence about the limit, because both extremal hypotheses agree with all observed data.
3. **Using an extrapolation whose validity condition is unchecked.** Aitken's $\Delta^2$, Richardson extrapolation, and geometric plateau bands are all exact under geometric contraction and heuristic otherwise. The contraction audit of §9.1 is a three-line check that should precede any of them.

The positive lesson is equally transferable: if the audit *passes*, the tail bound is very strong. A single measured step plus a verified $q < 1$ certifies the entire remaining trajectory to within $|d_n|/(1-q)$, with no further experiments.

### 10.3 Limitations

The results are stated for exact rational ladders and ignore sampling error in the rungs; the measured rungs carry confidence intervals of width roughly $0.09$. A noise-aware version of Theorem 7.3 would ask for the smallest $q$ compatible with *some* selection of values within the intervals, and one expects the conclusion to soften from "$q \ge 2$" to "$q \ge$ something still exceeding $1$", since the rebound at $b = 116$ and its retracement at $b = 120$ together span roughly $0.07$ against interval widths of $0.09$ — a genuinely borderline case that deserves separate treatment. Two rungs of the seven ($b = 96, 100$) are reconstructed from reported step sizes rather than recorded directly; every theorem above that touches them is stated in terms of those steps.

---

## 11. Future directions

**Noise-tolerant contraction.** Replace exact rungs by intervals and characterise the set of contraction factors compatible with an interval-valued ladder. The natural statement is a minimax: $q^\star_{\text{robust}} = \min_{\tilde\rho \in \prod_k I_k} \max_k |\tilde d_{k+1}|/|\tilde d_k|$. Determining whether $q^\star_{\text{robust}} < 1$ for the recorded intervals is the sharpest open question raised here.

**Eventual contraction.** Contraction from *some* rung onwards, rather than from the start, still yields a floor by Theorem 6.4 applied at that rung. Formalising "the ladder is $q$-contractive for $k \ge n_0$" and estimating $n_0$ from data would rescue the plateau reading if the early irregularity is a transient.

**Summability tests.** By Theorem 3.4 the question is summability of $(d_k)$. Classical convergence tests (ratio, root, Raabe) applied to observed increments, with error bars, would give a family of finite-sample summability diagnostics stronger than a raw contraction check and weaker than a shape assumption.

**Multi-regime laws.** Theorem 8.6 shows no fixed-curvature-sign law fits. A piecewise model with a change point — a convex early regime, a near-linear intermediate asymptotic, and an unknown late regime — is the minimal shape class consistent with the recorded ladder, and its identifiability is worth analysing.

**The discriminating experiment.** Measure $b = 156$. Also worth measuring: the rung where the count baseline itself is forecast to expire ($b \approx 179$ under the secant law), since the *advantage* $\rho_T - \rho_{\text{count}}$ may have a floor even if neither term does.

---

## 12. Conclusion

A finite ladder of fading correlations cannot, by itself, say whether the fade has a floor or ends in extinction: two antitone continuations reproduce all seven recorded rungs while one stays above $0.21818$ for ever and the other reaches zero at bit-length $160$. Nor do shrinking steps help — the harmonic fade shrinks its steps to zero, stays above $0.33$ over a span of $512$ bits, and dies anyway.

What *would* settle it is contraction. A $q$-contractive ladder with $q < 1$ obeys the tail bound $|\rho_{n+m} - \rho_n| \le |d_n|/(1-q)$, so one measured step certifies the entire future and yields the explicit floor $\rho_n - |d_n|/(1-q)$, with no extinction once that floor is positive. This is precisely the assumption under which every plateau estimate in the thread was made.

And the recorded ladder is not contractive: the rebound of $-0.0226$ at bit-length $116$ is retraced at bit-length $120$ by a step of $+0.04834$, forcing any uniform factor to be at least $2.138$ — more than four times the $r \le 1/2$ that the plateau forecast assumed. The plateau reading is a hypothesis about rungs not yet measured, not a consequence of the rungs that have been.
