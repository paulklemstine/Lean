# The Hedging Hump and Placement-Structured Ceilings for Interval Hints in Ordered Search

**Aristotle**

*October 2026*

---

## Abstract

We study a searcher who probes the cells $1, \dots, n$ one at a time, in an order of their choosing, looking for a hidden target $J$ with a known prior. The searcher pays the number of probes. An oracle supplies an *interval hint*, "the target lies in the window $S$," and the searcher trusts it at a level $\alpha\in[0,1]$. We prove three groups of results.

**(I) The hedging hump.** Let $E_{\mathrm{opt}}(\alpha)$ be the Bayes-optimal expected cost at trust level $\alpha$. It is concave and piecewise linear: it is the lower envelope of $n!$ affine functions. For *every* strictly decreasing prior and every window whose conditional mean position differs from that of its complement, some intermediate trust $\alpha\in(0,1)$ makes the optimal search strictly more expensive than ignoring the hint. For the *min-law* prior of $J=\min(U_1,U_2)$, with $U_1, U_2$ independent and uniform on $\{1,\dots,M\}$, and a right-placed window of width $W\le M/3$, partial trust is strictly worse than no hint, than full distrust and than full trust. No hump exceeds the uniform level $(n+1)/2$.

**(II) Placement-structured ceilings.** With perfect trust, a window of width $W$ whose start lies $d$ cells from the right end costs exactly $(W+1)(6d-4W+1)/\big(6(2d-W)\big)$ probes. Cost strictly decreases as the window moves right. Every placement has speedup at most $M/W=1/x$. Asymptotically the speedup is $k(2m-1)/(3m-2)$ for $M=kW$ and $d=mW$. This gives $1/x$ for right windows, about $2/(3x)$ for left and centered windows, and a right-to-left ratio tending to $3/2$. A right window is self-similar: conditioned on it, the target is again a min-law on $W$ cells.

**(III) The calibration gate.** For a calibrated (truthful) signal, the expected saving is at most $r(n-1)$, where $r$ is the firing rate. A hint that is uniform on its window when it fires satisfies $r\alpha\le W\min_{j\in S}p_j$. Under the min-law with a right window this gives $r\alpha\le W/M^2$ and $\alpha\cdot(\text{saving})<x$. Uniform-given-hit hints of this kind can never produce gains on the scale of the blind cost $\approx M/3$.

All numerical claims are reproduced exactly in rational arithmetic and checked against brute-force enumeration and Monte Carlo simulation.

---

## 1. Introduction

### 1.1 Ordered search with a prior

Let $J$ be a random target in $\{1,\dots,n\}$ with prior $p=(p_1,\dots,p_n)$. A *search order* is a permutation $\sigma$ of the cells. The searcher probes $\sigma(1),\sigma(2),\dots$ until the target is found. If the target is in cell $\sigma(i)$, the cost is $i$. For a nonnegative weight vector $q$ we define

$$
\mathrm{cost}(q,\sigma)=\sum_{i=1}^{n} i\,q_{\sigma(i)},\qquad
\mathrm{opt}(q)=\min_{\sigma}\mathrm{cost}(q,\sigma).
$$

By the rearrangement inequality, the minimum is attained by any order that lists cells in non-increasing weight. When $p$ is non-increasing, the ascending scan $1,2,\dots,n$ is optimal.

### 1.2 The two-number model

The guiding example is the search for the smaller of two hidden numbers. Let $U_1, U_2$ be independent and uniform on $\{1,\dots,M\}$, and let $J=\min(U_1,U_2)$. Counting pairs gives the **min-law**

$$
\Pr(J=i)=\frac{2(M-i)+1}{M^2},\qquad i=1,\dots,M. \tag{1.1}
$$

It is strictly decreasing and sums to $1$. Its mean is

$$
B(M)=\sum_{i=1}^M i\Pr(J=i)=\frac{(M+1)(2M+1)}{6M}\approx\frac M3, \tag{1.2}
$$

and since the law is decreasing, $B(M)$ is also the optimal blind cost. For $M=512$, $B=171.17$; for $M=256$, $B=85.83$.

This model abstracts the search for the smaller factor of a product of two numbers. Trial division searches "from the left," at small candidates first. Fermat's method, "start at $\sqrt N$," commits to the extreme right of the candidate range. In this language, a search heuristic is an order, and a heuristic's implicit belief about where the answer lies is an interval hint.

### 1.3 Interval hints and trust

An oracle names a window $S\subseteq\{1,\dots,n\}$. We write $P(S)=\sum_{j\in S}p_j$ and assume $0<P(S)<1$. A searcher who trusts the hint at level $\alpha$ moves total mass $\alpha$ onto $S$ and $1-\alpha$ onto its complement $S^c$, and keeps the prior's relative odds inside each part:

**Definition 1.1 (trust posterior).**
$$
q_\alpha(j)=\begin{cases}\dfrac{\alpha}{P(S)}\,p_j,& j\in S,\\[2mm]\dfrac{1-\alpha}{1-P(S)}\,p_j,& j\notin S.\end{cases}
$$
The **trust cost** is $E_{\mathrm{opt}}(\alpha)=\mathrm{opt}(q_\alpha)$.

Three basic facts follow from the definition. First, $q_\alpha$ is a probability vector for every $\alpha$, with total mass $\alpha+(1-\alpha)=1$. Second, it is affine in $\alpha$:
$$
q_{t\alpha+(1-t)\beta}=t\,q_\alpha+(1-t)\,q_\beta .
$$
Third, at the **calibrated trust** $\alpha=P(S)$ the posterior *equals* the prior. So $E_{\mathrm{opt}}(P(S))$ is the blind cost: calibrated trust is "no news."

We also use the **conditional mean positions**
$$
\mu_{\mathrm{in}}=\frac{\sum_{j\in S} j\,p_j}{P(S)},\qquad
\mu_{\mathrm{out}}=\frac{\sum_{j\notin S} j\,p_j}{1-P(S)} .
$$

### 1.4 Windows and placements

For the min-law on $M$ cells, a *window* of width $W$ is a block of consecutive cells, and $x=W/M$ is its *fraction*. A **right** window is $\{M-W+1,\dots,M\}$, a **left** window is $\{1,\dots,W\}$, and a **centered** window starts at about $(M-W)/2+1$. In general we parametrize a window by its distance $d$ from the right end: it occupies the cells $M-d+1,\dots,M-d+W$, with $W\le d\le M$. The *speedup* of a strategy is $B(M)$ divided by its expected cost.

### 1.5 Summary of contributions

1. **Shape of the trust curve** (Theorem 2.1). $E_{\mathrm{opt}}$ is concave and piecewise linear.
2. **Uniform ceiling** (Theorem 2.3). $E_{\mathrm{opt}}(\alpha)\le(n+1)/2$, with equality for the uniform vector.
3. **Universal hedging hump** (Theorem 3.2). For every strictly decreasing prior, partial trust somewhere in $(0,1)$ is strictly costlier than having no hint.
4. **Min-law right hump** (Theorem 3.3). Partial trust is worse than all three reference strategies.
5. **Placement law** (Theorem 4.1) together with monotonicity, self-similarity, the exact ceiling $1/x$ and the asymptotic law $k(2m-1)/(3m-2)$.
6. **Trust crossings** for the $5.19\times$ target (Theorem 4.7).
7. **Calibration gate** (Theorems 5.2–5.5).

---

## 2. The shape of the trust curve

**Theorem 2.1 (concave piecewise-linear shape).** For every prior $p$ and window $S$, the function $\alpha\mapsto E_{\mathrm{opt}}(\alpha)$ is concave on $\mathbb R$. Moreover,
$$
E_{\mathrm{opt}}(\alpha)=\min_{\sigma}\Big[\alpha\,\mathrm{cost}(q_1,\sigma)+(1-\alpha)\,\mathrm{cost}(q_0,\sigma)\Big],
$$
a minimum of $n!$ affine functions of $\alpha$.

*Proof.* The cost of a fixed order is linear in the weight vector, so
$\mathrm{cost}(t a+(1-t)b,\sigma)=t\,\mathrm{cost}(a,\sigma)+(1-t)\,\mathrm{cost}(b,\sigma)$. Taking the minimum over $\sigma$ shows that $\mathrm{opt}$ is concave on weight vectors. Composing with the affine map $\alpha\mapsto q_\alpha$ preserves concavity. The displayed formula follows from $q_\alpha=\alpha q_1+(1-\alpha)q_0$. $\square$

**Consequence.** Every local maximum of $E_{\mathrm{opt}}$ on $[0,1]$ is the global maximum, and the curve consists of finitely many linear segments, with breakpoints where two cells swap rank in $q_\alpha$.

**Lemma 2.2 (forward plus backward).** For any weight vector $q$ on $n$ cells, the ascending scan and the descending scan together cost
$$
\mathrm{cost}(q,\mathrm{id})+\mathrm{cost}(q,\mathrm{rev})=(n+1)\sum_j q_j .
$$

*Proof.* Cell $j$ is reached at step $j$ in one scan and at step $n+1-j$ in the other. $\square$

**Theorem 2.3 (uniform ceiling).** For every weight vector $q$, $\mathrm{opt}(q)\le\frac{n+1}{2}\sum_j q_j$. In particular,
$$
E_{\mathrm{opt}}(\alpha)\le\frac{n+1}{2}\qquad\text{for every prior, window and trust level}.
$$
The uniform vector $q_j=1/n$ attains this bound, so $(n+1)/2$ is the global maximum of the Bayes cost over probability vectors.

*Proof.* The minimum of two numbers is at most their average; apply Lemma 2.2. For the uniform vector every order costs $\sum_i i/n=(n+1)/2$. $\square$

**Proposition 2.4 (uniform-given-hit hints reach the ceiling).** Consider the alternative hint model in which a trusted window receives *uniform* mass: $q(j)=\alpha/W$ for $j$ in a window of width $W$ and $q(j)=(1-\alpha)/(M-W)$ otherwise, with $0<W<M$. At $\alpha=W/M$ this posterior is exactly uniform, so $\mathrm{opt}=(M+1)/2$, and no trust level exceeds this value.

*Proof.* Substitute $\alpha = W/M$: then $\alpha/W=1/M=(1-\alpha)/(M-W)$. Apply Theorem 2.3. $\square$

So in the uniform-given-hit model the hump reaches the absolute ceiling. In the prior-proportional model it rises above the blind cost but stays below the ceiling.

---

## 3. The hedging hump

### 3.1 Rigidity of the greedy order

**Lemma 3.1 (local rigidity).** Let $p$ be strictly decreasing and $0<P(S)<1$. There is a neighbourhood $N$ of the calibrated trust $P(S)$ such that for every $\alpha\in N$ the posterior $q_\alpha$ is non-increasing in $j$. Hence the ascending scan is Bayes-optimal for $q_\alpha$.

*Proof.* At $\alpha=P(S)$ both scaling factors $\alpha/P(S)$ and $(1-\alpha)/(1-P(S))$ equal $1$. For every pair $i<j$, all four inequalities
$$
\tfrac{1-\alpha}{1-P(S)}p_j<\tfrac{\alpha}{P(S)}p_i,\qquad \tfrac{\alpha}{P(S)}p_j<\tfrac{1-\alpha}{1-P(S)}p_i
$$
(and the trivial same-side ones) hold strictly at $\alpha=P(S)$, because $p_j<p_i$. The two sides depend continuously on $\alpha$, and there are finitely many pairs, so all inequalities persist on a neighbourhood. On that neighbourhood $q_\alpha(j)\le q_\alpha(i)$ for every $i<j$, whichever sides of $S$ the cells $i$ and $j$ lie on. $\square$

### 3.2 The committed cost is linear

The ascending scan has cost
$$
\mathrm{cost}(q_\alpha,\mathrm{id})=\alpha\,\mu_{\mathrm{in}}+(1-\alpha)\,\mu_{\mathrm{out}}, \tag{3.1}
$$
which is linear in $\alpha$ with slope $\mu_{\mathrm{in}}-\mu_{\mathrm{out}}$. At $\alpha=P(S)$ it equals the blind cost.

### 3.3 The universal hump

**Theorem 3.2 (Hedging Hump Theorem).** Let $p$ be strictly decreasing, let $0<P(S)<1$, and suppose $\mu_{\mathrm{in}}\ne\mu_{\mathrm{out}}$. Then there exists $\alpha\in(0,1)$ with
$$
E_{\mathrm{opt}}(\alpha)>E_{\mathrm{opt}}(P(S))=\mathrm{opt}(p).
$$
That is, some intermediate trust level makes the optimal search strictly more expensive than searching without the hint.

*Proof.* By Lemma 3.1 there is a neighbourhood $N\subseteq(0,1)$ of $P(S)$ on which $E_{\mathrm{opt}}(\alpha)=\alpha\mu_{\mathrm{in}}+(1-\alpha)\mu_{\mathrm{out}}$. Since $\mathrm{opt}(p)$ is the same expression at $\alpha=P(S)$,
$$
E_{\mathrm{opt}}(\alpha)-\mathrm{opt}(p)=(\alpha-P(S))(\mu_{\mathrm{in}}-\mu_{\mathrm{out}}).
$$
If $\mu_{\mathrm{in}}>\mu_{\mathrm{out}}$, pick $\alpha\in N$ slightly above $P(S)$; if $\mu_{\mathrm{in}}<\mu_{\mathrm{out}}$, pick it slightly below. $\square$

*Interpretation.* Around the calibrated point, the optimal searcher does not change order. It keeps scanning upward, but redistributes probability so that the cells it scans first become less likely. Moving trust toward a window that lies "late" in the order raises the conditional probability of finding the target late, and so raises the cost. For a window sitting high in the range ($\mu_{\mathrm{in}}>\mu_{\mathrm{out}}$), the hump lies *above* the calibrated trust. For a left window it lies *below*. The theorem does not depend on any special feature of the min-law: the hump is universal for strictly decreasing priors.

### 3.4 The min-law, right window: partial trust is the most expensive regime

**Theorem 3.3 (Right-Window Hump Theorem).** Let $p$ be the min-law (1.1) on $M$ cells and $S$ the right window of width $W$ with $0<W$ and $3W\le M$. Then there exists $\alpha\in(0,1)$ such that
$$
E_{\mathrm{opt}}(\alpha)>\max\big\{\,\mathrm{opt}(p),\;E_{\mathrm{opt}}(0),\;E_{\mathrm{opt}}(1)\,\big\}.
$$

*Proof.* Every position in $S$ is at least $M-W+1$ and every position outside is at most $M-W$. So $\mu_{\mathrm{in}}\ge M-W+1>M-W\ge\mu_{\mathrm{out}}$. Theorem 3.2 gives $\alpha\in(0,1)$ with $E_{\mathrm{opt}}(\alpha)>\mathrm{opt}(p)$. It remains to show that both endpoint values lie below the blind cost.

*Full distrust.* The ascending scan is admissible, so $E_{\mathrm{opt}}(0)\le\mu_{\mathrm{out}}$. The blind cost is the mixture $P(S)\mu_{\mathrm{in}}+(1-P(S))\mu_{\mathrm{out}}$ with $\mu_{\mathrm{in}}>\mu_{\mathrm{out}}$ and $P(S)>0$, so $\mu_{\mathrm{out}}<\mathrm{opt}(p)$.

*Full trust.* $q_1$ is supported on $S$. The descending scan reaches every cell of $S$ within $W$ probes, so $E_{\mathrm{opt}}(1)\le W$. Finally, $W<B(M)=(M+1)(2M+1)/(6M)$ whenever $3W\le M$: indeed $6MW\le 2M^2<(M+1)(2M+1)$. $\square$

### 3.5 Numerical profile

We computed exact values on an $\alpha$-grid of step $1/200$, at $M=512$ with $B=171.17$ and ceiling $(M+1)/2=256.5$:

| window | $P(S)$ | $E(0)$ | $E(1)$ | peak $E$ | at $\alpha$ |
|---|---|---|---|---|---|
| right, $x=1/4$ | $0.0625$ | $154.10$ | $43.17$ | $196.50$ | $0.220$ |
| right, $x=1/2$ | $0.2500$ | $114.28$ | $85.83$ | $197.84$ | $0.435$ |
| left, $x=1/4$ | $0.4375$ | $128.50$ | $61.45$ | $186.37$ | $0.310$ |
| centered, $x=1/4$ | $0.2500$ | $120.50$ | $59.17$ | $176.97$ | $0.335$ |
| right, $x=1/64$ | $0.0002$ | $171.08$ | $3.19$ | $173.76$ | $0.015$ |

Every placement shows a hump above the blind cost, including the cases ($x=1/2$; left and centered windows) not covered by Theorem 3.3. For the right $x=1/4$ window the peak of about $196.5$ (about $196$ on coarser grids) exceeds the blind cost by about $15\%$ and covers about $29\%$ of the distance from the blind cost to the uniform ceiling. For the left window the peak sits below the calibrated trust $0.4375$, as the interpretation of Theorem 3.2 predicts.

---

## 4. Placement-structured ceilings

Throughout this section $\alpha=1$. The searcher knows that $J\in S$ and scans $S$ in ascending order. This is Bayes-optimal, because the min-law conditioned on $S$ is still decreasing.

### 4.1 The placement law

**Theorem 4.1 (Placement Law).** Let the window of width $W\ge1$ occupy cells $M-d+1,\dots,M-d+W$ (so $W\le d\le M$). The expected number of probes is
$$
E(d,W)=\frac{(W+1)\,(6d-4W+1)}{6\,(2d-W)} .
$$

*Proof sketch.* Index the window cells by $r=0,\dots,W-1$. Cell $r$ has prior $\big(2d-1-2r\big)/M^2$. The window mass is
$$
Z=\frac{1}{M^2}\sum_{r=0}^{W-1}(2d-1-2r)=\frac{W(2d-W)}{M^2},
$$
and the positional sum is
$$
N=\frac{1}{M^2}\sum_{r=0}^{W-1}(r+1)(2d-1-2r)=\frac{1}{M^2}\Big[(2d-1)\frac{W(W+1)}{2}-\frac{2(W-1)W(W+1)}{3}\Big]=\frac{W(W+1)(6d-4W+1)}{6M^2}.
$$
The conditional expected position is $N/Z$. $\square$

The formula does not depend on $M$, only on the distance $d$ from the right end. This reflects the translation structure of the min-law, whose density is affine in the distance to the right end.

**Theorem 4.2 (right is cheapest).** For $W\ge2$ and $d'<d$ (window moved right), $E(d',W)<E(d,W)$. For $W=1$ the cost is $1$ at every placement.

*Proof.* Cross-multiplying the two fractions, the sign of the difference is that of
$$
(6d'-4W+1)(2d-W)-(6d-4W+1)(2d'-W)=-2(d-d')(W-1)<0 . \qquad\square
$$

**Theorem 4.3 (self-similarity).** The min-law on $M$ cells, conditioned on the right window of width $W$, is exactly the min-law on $W$ cells:
$$
\frac{\Pr(J=M-W+r)}{W^2/M^2}=\frac{2(W-r)+1}{W^2},\qquad r=1,\dots,W .
$$
The right window has prior mass $W^2/M^2=x^2$, and the right window costs
$$
E(W,W)=\frac{(W+1)(2W+1)}{6W}=B(W).
$$

*Proof.* Direct substitution into (1.1); the mass is $Z$ with $d=W$. $\square$

In words: if both numbers exceed $M-W$, then shifting by $M-W$ makes them independent and uniform on $\{1,\dots,W\}$. The minimum of two uniforms, truncated to its upper tail, is again the minimum of two uniforms. A right-window search is a scaled copy of the blind search, and costs a third of its width.

### 4.2 The exact ceiling

**Theorem 4.4 (universal ceiling).** For every placement, the perfect-trust speedup satisfies
$$
\frac{B(M)}{E(d,W)}\le\frac{M}{W}=\frac1x .
$$

*Proof.* By Theorem 4.2 it suffices to treat $d=W$. Then
$$
\frac{B(M)}{B(W)}=\frac{(M+1)(2M+1)W}{M(W+1)(2W+1)}\le\frac MW
\iff (M+1)(2M+1)W^2\le M^2(W+1)(2W+1).
$$
Expanding, this is $3MW(W-M)+(W^2-M^2)\le0$, which holds for $W\le M$. $\square$

The bound holds exactly at every finite $M$. It is a ceiling, not just a limit.

### 4.3 The asymptotic placement law

**Theorem 4.5 (asymptotic placement law).** Fix integers $1\le m\le k$. Let $M=kW$ and $d=mW$. As $W\to\infty$,
$$
\frac{B(kW)}{E(mW,W)}\longrightarrow\frac{k\,(2m-1)}{3m-2}.
$$

*Proof sketch.* Dividing numerator and denominator by $W^2$,
$$
\frac{B(kW)}{E(mW,W)}=\frac{(k+\tfrac1W)(2k+\tfrac1W)(2m-1)}{k(1+\tfrac1W)\big((6m-4)+\tfrac1W\big)}\to\frac{2k^2(2m-1)}{k(6m-4)} . \qquad\square
$$

**Corollary 4.6 (the three placements).** With $k=1/x$:
* *right* ($m=1$): limit $k=1/x$, the full ceiling;
* *left* ($m=k$): limit $\dfrac{k(2k-1)}{3k-2}=\dfrac{2-x}{x(3-2x)}\to\dfrac{2}{3x}$ as $x \to 0$;
* *centered* ($m\approx k/2$): limit $\approx 2/(3x)$.

For every $m\ge2$ the limit is strictly below $k$, since $k(2m-1)<k(3m-2)$. The right-to-left ratio of limits is $(3k-2)/(2k-1)=(3-2x)/(2-x)$, which tends to $3/2$ as $x\to0$. So placement multiplies what a given width buys by up to $3/2$, from about $2/(3x)$ to $1/x$.

**Table 4.1.** Perfect-trust speedups at $M=256$.

| $x$ | left | centered | right | $1/x$ | $2/(3x)$ |
|---|---|---|---|---|---|
| $1/64$ | $34.40$ | $34.47$ | $45.78$ | $64$ | $42.67$ |
| $1/32$ | $19.16$ | $19.25$ | $26.93$ | $32$ | $21.33$ |
| $1/16$ | $10.20$ | $10.30$ | $14.69$ | $16$ | $10.67$ |
| $1/8$ | $5.32$ | $5.42$ | $7.68$ | $8$ | $5.33$ |
| $1/4$ | $2.77$ | $2.88$ | $3.93$ | $4$ | $2.67$ |

**Best cell.** At $M=256$ with a right window of width $16$ ($x=1/16$), the speedup is
$$
\frac{B(256)}{B(16)}=\frac{131841/1536}{561/96}=\frac{43947}{2992}\approx14.688\in(14.68,\,14.69).
$$

### 4.4 Partial trust in a left window: the $5.19\times$ crossing

For a left window of width $W$, the committed (ascending, window-first) scan has exact cost
$$
C(\alpha)=\alpha\,\frac{N_W}{P_W}+(1-\alpha)\,\frac{B(M)-N_W}{1-P_W}, \tag{4.1}
$$
where
$$
P_W=\frac{W(2M-W)}{M^2},\qquad N_W=\frac{W(W+1)}{M^2}\Big(\frac{2M+1}{2}-\frac{2W+1}{3}\Big).
$$
These are the window mass and the window positional sum. Formula (4.1) is (3.1) specialized to the min-law.

**Theorem 4.7 (trust crossings).** Let $M=256$ and let $\mathrm{sp}(\alpha)=B(M)/C(\alpha)$.
* For $x=1/8$ ($W=32$): $\mathrm{sp}(0.995)<5.19<\mathrm{sp}(0.996)$, and $C$ is strictly decreasing in $\alpha$, so the crossing $\alpha^*$ is unique and lies in $(0.995,0.996)$.
* For $x=1/64$ ($W=4$): $\mathrm{sp}(0.836)<5.19<\mathrm{sp}(0.837)$.

*Proof.* Evaluate (4.1) in exact rational arithmetic. The cost is affine in $\alpha$ with negative slope $N_W/P_W-(B-N_W)/(1-P_W)$. $\square$

As $M$ grows, the crossings drift: for $x=1/64$, $\alpha^*=0.8367,0.8344,0.8332$ at $M=256,512,1024$; for $x=1/8$, $\alpha^*=0.9957,0.9935,0.9923$. The continuum value for $x=1/64$ is about $0.832$. The right window with $x=1/64$ already crosses at $0.8332$ at $M=256$. The useful regime is **narrow and near-certain**: a wide window must be trusted almost completely, and even a narrow one needs trust above $0.83$.

---

## 5. The calibration gate

The trust level $\alpha$ has so far been a free parameter. A hint produced by an honest mechanism must be **calibrated**: averaged over the hint's randomness, the posteriors must return the prior.

**Definition 5.1 (calibrated binary signal).** A signal fires with probability $r\in[0,1]$. When it fires the posterior is $q$; otherwise it is $q'$. Both are nonnegative, $q$ sums to $1$, and
$$
p_j=r\,q_j+(1-r)\,q'_j\qquad\text{for all } j. \tag{5.1}
$$
The **expected saving** of the signal is $\mathrm{opt}(p)-\big[r\,\mathrm{opt}(q)+(1-r)\,\mathrm{opt}(q')\big]$.

**Theorem 5.2 (uniform hits are capped by the lightest cell).** Suppose $r\le1$, $q'\ge0$, (5.1) holds, and $q_j=\alpha/W$ for every $j$ in a set $S$ of size $W$. Then
$$
\frac{r\alpha}{W}\le p_j\quad\text{for every } j\in S,\qquad\text{i.e.}\qquad r\alpha\le W\min_{j\in S}p_j .
$$

*Proof.* $p_j=r\alpha/W+(1-r)q'_j\ge r\alpha/W$. $\square$

**Theorem 5.3 (value of information is linear in the firing rate).** For any calibrated signal on $n$ cells with $r\ge0$,
$$
\mathrm{opt}(p)-\big[r\,\mathrm{opt}(q)+(1-r)\,\mathrm{opt}(q')\big]\le r\,(n-1).
$$

*Proof.* Let $\sigma$ be optimal for $q'$. By linearity of cost in the weights,
$$
\mathrm{opt}(p)\le\mathrm{cost}(p,\sigma)=r\,\mathrm{cost}(q,\sigma)+(1-r)\,\mathrm{opt}(q').
$$
Every order costs at most $n$ on a probability vector, so $\mathrm{cost}(q,\sigma)\le n$. Every order costs at least $1$, so $\mathrm{opt}(q)\ge1$. Subtracting, the saving is at most $r(n-\mathrm{opt}(q))\le r(n-1)$. $\square$

**Theorem 5.4 (the calibration gate, min-law, right window).** Let $p$ be the min-law on $M$ cells and $S$ the right window of width $1\le W\le M$. Suppose a calibrated signal ($0\le r\le1$, $\alpha\ge0$, $q,q'$ as above) is uniform-given-hit on $S$. Then
$$
r\alpha\le\frac{W}{M^2}\qquad\text{and}\qquad \alpha\cdot(\text{expected saving})<\frac WM=x .
$$

*Proof.* The lightest cell of $S$ is cell $M$, with prior $1/M^2$. Theorem 5.2 gives the first inequality. Theorem 5.3 then gives
$$
\alpha\cdot\text{saving}\le\alpha r(M-1)\le\frac{W(M-1)}{M^2}<\frac WM. \qquad\square
$$

**Theorem 5.5 (calibrated capacity of the rightmost commitment).** The right window has prior mass exactly $W^2/M^2=x^2$. Hence the calibrated trust of a "start at the right end" commitment is $x^2$, which vanishes quadratically in the window fraction.

*Interpretation.* A uniform-given-hit right hint at full strength ($\alpha=1$) saves fewer than $x$ probes on average, against a blind cost of about $M/3$. For $M=512$ and $x=1/16$: $r\alpha\le 32/512^2\approx1.22\times10^{-4}$, and the saving is below $1/16$ of a probe against $171.17$. An explicit extremal signal, firing at the maximal admissible rate, saves $0.0586$ probes, within the bound $r(M-1)=0.0624$. Uniform-given-hit hints can therefore never reach gains on the scale of magnitude ordering.

The gate is a property of the **lightest** window cell, so it is specific to right placement under a decreasing prior. For the left window with $x=1/16$ at $M=512$, the lightest window cell has mass $(2\cdot480+1)/512^2\approx3.67\times10^{-3}$ and the cap is $r\alpha\le0.117$. That is limited (about $2x(1-x)$ in the continuum) but not negligible.

---

## 6. Algorithms

**Algorithm 6.1 (Bayes-optimal ordered search).** Given weights $q$, sort the cells by non-increasing weight and probe in that order. Cost: $O(n\log n)$. Expected probes: $\sum_i i\,q_{(i)}$, where $q_{(1)}\ge q_{(2)}\ge\cdots$.

**Algorithm 6.2 (trust curve).** For a grid of $\alpha$ values, form $q_\alpha$ and apply Algorithm 6.1. This costs $O(Gn\log n)$ for $G$ grid points. Because $E_{\mathrm{opt}}$ is concave and piecewise linear, the exact curve can also be traced through its breakpoints. These are the values of $\alpha$ where an inside cell and an outside cell tie, $\frac{\alpha}{P(S)}p_i=\frac{1-\alpha}{1-P(S)}p_j$, and there are at most $|S|\cdot|S^c|$ of them.

**Algorithm 6.3 (placement evaluation).** Evaluate $E(d,W)$ from Theorem 4.1 in $O(1)$. The speedup is $B(M)/E(d,W)$.

**Algorithm 6.4 (calibration-gate test).** Given a prior, a window $S$ and a desired $(r,\alpha)$, the uniform-given-hit signal exists iff $r\alpha\le W\min_{j\in S}p_j$. In that case set $q'_j=(p_j-rq_j)/(1-r)$.

---

## 7. Numerical verification

* **Optimality of sorting.** For $M=5,6,7,8$, every left and right window, and a random trust level per window, brute force over all $M!$ orders agrees with Algorithm 6.1. The worst gap is at the level of floating-point round-off (about $10^{-16}$), and zero in exact arithmetic.
* **Placement law.** Formula 4.1 agrees exactly with direct summation for all $1\le W\le M<40$ and all placements.
* **Monte Carlo.** Simulated searchers drawing the target from the stated posteriors reproduce the exact expected costs. Across 40 configurations the largest standardized deviation was $|z|=2.34$, consistent with chance.
* **A caught error.** In an early version of the computation the complement mass was normalized incorrectly. The analytic value looked plausible, but a simulated mean landed at $z=-72$. Exact formulas and simulation catch different kinds of errors, and both are needed.

---

## 8. Discussion

**Hedging is the expensive regime.** Theorems 2.1 and 3.2 together say that the trust curve is a concave tent that, for decreasing priors, always rises above the blind level on one side of the calibrated point. Practically, a searcher who is unsure of a hint should not "partially" act on it. The two endpoints, ignoring the hint or committing to it, bracket the sensible strategies, and for narrow right windows both endpoints beat the blind cost (Theorem 3.3).

**Placement beats width.** Theorem 4.4 caps every window at $1/x$, and the right window comes asymptotically close to the cap. Left and centered windows of the same width only reach about $2/(3x)$. The structural reason is self-similarity (Theorem 4.3). A right window is a scaled copy of the whole problem, so it inherits the factor $1/3$ in "cost $\approx$ width$/3$." A left window covers the region where the prior is nearly flat, and so pays about half its width.

**But honesty closes the right door.** The calibration gate (Theorem 5.4) shows that the placement where a trusted hint helps most is the placement where a calibrated uniform hint can say least. Its capacity is governed by the lightest cell, $1/M^2$, and its calibrated trust is $x^2$. A "start at the right end" heuristic, such as beginning a factor search at $\sqrt N$, is in this language a rightmost-interval commitment whose honestly calibrated capacity tends to $0$.

**Location versus identity.** In the two-number model one can also ask *which* of $U_1,U_2$ is the minimum. An interval hint about the value of $J$ is symmetric in $U_1$ and $U_2$, so it carries zero mutual information about which number is the smaller. Yet it changes the optimal order through its direct correlation with $J$. Ceilings on what "which-number" information can buy therefore do not constrain interval hints. The two kinds of information are priced by orthogonal functionals of the posterior.

---

## 9. Future directions

1. **Exact hump height.** For the min-law and a right window of fraction $x$, determine the continuum peak $\max_\alpha E_{\mathrm{opt}}(\alpha)/M$. We conjecture it equals $\tfrac13+c\,x(1-x)^2+O(x^2)$ for an explicit $c$, with the maximum near $x=1/2$. Writing $E_{\mathrm{opt}}=\int\lambda(s)^2/2\,ds$ in terms of level-set measures, the hump should be exactly the cross term $\int\lambda_{\mathrm{in}}\lambda_{\mathrm{out}}$.
2. **Rigidity radius.** With $\rho=\min_i p_i/p_{i+1}$, we conjecture that the ascending order stays optimal exactly on $\{\alpha:\max(\lambda_{\mathrm{in}}/\lambda_{\mathrm{out}},\lambda_{\mathrm{out}}/\lambda_{\mathrm{in}})\le\rho\}$, where $\lambda_{\mathrm{in}}$ and $\lambda_{\mathrm{out}}$ are the two scaling factors. This would make Lemma 3.1 quantitative and give a computable lower bound on the hump height.
3. **Polynomial priors.** For $J=\min(U_1,\dots,U_d)$, self-similarity of the tail should give the right-window ceiling $1/x$ for every $d$, with right/left ratio tending to $(d+1)/d$ (proved here for $d=2$).
4. **Multi-signal hints.** Extend Theorem 5.3 to signals with $K$ outcomes. The natural bound is $\sum_k r_k\,(n-\mathrm{opt}(q_k))$ against a common reference order, giving $O(\sum_k W_k\,p_{\min}(S_k)\,n)$ for uniform-given-hit alphabets such as block partitions.

---

## 10. Conclusion

A single small model, the search for the smaller of two random numbers, already shows three general phenomena of hinted search. The cost of acting on a hint is concave in trust and, for any decreasing prior, peaks above the no-hint cost at partial trust. The value of a perfectly trusted window is set by its placement as much as by its width: the exact ceiling $1/x$ is reached by right windows and missed by a factor approaching $2/3$ elsewhere. Calibration ties a uniform hint's strength to the lightest cell it covers, which closes off the most valuable placement to honest uniform hints.
