# Interval Hints Are Priced by Coverage and Width: An Exact Additive Law for Hinted Sequential Search

**Aristotle**

*October 2026*

---

## Abstract

An oracle announces a window of $W$ out of $M$ candidate cells and claims that the hidden target lies in the window with probability $\alpha$. We study the value of such *interval hints* for sequential search, in which cells are probed one at a time and the cost is the expected number of probes. Under a uniform prior and truthful conditioning we prove that the committed procedure (scan the window first, then the rest) has expected cost exactly $\tfrac12\big(W+1+(1-\alpha)M\big)$, hence speedup

$$S(M,W,\alpha)=\frac{M+1}{(1-\alpha)M+W+1}$$

over blind search, with continuum limit $S=1/(1-\alpha+w)$ where $w=W/M$. The two parameters — coverage and width — therefore enter **additively**, through the residual fraction $1-\alpha+w$, not multiplicatively; equal-value hints trade one cell of width for exactly $1/M$ of coverage, and the speedup is bounded by a coverage ceiling $1/(1-\alpha)$ and a width ceiling $(M+1)/(W+1)$. We show that the committed procedure is Bayes-optimal among all $M!$ probe orders **if and only if** $\alpha\ge w$, with an explicit improving transposition when $\alpha<w$. We apply the law to calibrate an observed $5.19\times$ search gain: for windows of relative width $2$–$5\%$ it corresponds to coverage strictly between $0.82$ and $0.86$, so a $90\%$-reliability reading overprices it. For the min-law prior $P(J=j)=(2(M-j)+1)/M^2$ of the minimum of two independent uniform draws we derive the optimal blind cost $(M+1)(2M+1)/(6M)$ and the exact perfect-coverage block-hint speedup $(M+1)(2M+1)/\big((W+1)(3M-W+1)\big)\to 2/(w(3-w))$. Finally we prove concavity of the Bayes search cost (honest information never hurts) and an exact regret $(\alpha-\beta)M/2$ for misspecified coverage.

---

## 1. Introduction

Sequential search with side information is ubiquitous: debugging guided by fault-localization heuristics, key search guided by leaked partial information, scheduling of diagnostic tests guided by a classifier, sky surveys guided by a prior. A common form of side information is an **interval hint**: a contiguous (or, more generally, designated) set of candidates together with a reliability. Practitioners routinely describe such hints informally — "it's in the first few percent, about nine times out of ten" — and then attempt to compare hints or to explain an observed speedup by an equivalent hint.

This paper gives an exact dictionary between hints and speedups. The motivating question came from a structured search problem in which ordering candidates by magnitude produced an observed gain of about $5.19\times$, and in which the target was distributed as the minimum of two independent uniform draws. An informal reading equated that gain to an oracle knowing the target's position within a $2$–$5\%$-wide window at roughly $90\%$ reliability, and an empirical table of speedups (by window width and coverage) was reported. Our goal is to replace the informal reading by theorems: to identify exactly how coverage and width combine, when the natural "window-first" procedure is optimal, and what can be proved exactly about the tilted min-law prior.

**Summary of contributions.**

1. *Greedy optimality* (Theorem 1): probing in non-increasing posterior order is Bayes-optimal among all orders.
2. *The exact two-number law* (Theorem 2): $S=(M+1)/((1-\alpha)M+W+1)$, with continuum limit $1/(1-\alpha+w)$ (Theorem 6).
3. *Sharp optimality boundary* (Theorems 3 and 4): window-first is Bayes-optimal iff $\alpha\ge w$.
4. *Ceilings and exchange rate* (Theorem 5).
5. *Calibration of the $5.19\times$ crossing* (Theorem 7).
6. *Min-law results* (Theorems 8–10): counting identity, optimal blind cost, exact block-hint speedup.
7. *Value of information and misspecification* (Theorems 11–13).

---

## 2. Model and definitions

Throughout, the cells are indexed $0,1,\dots,M-1$ (equivalently, $1,\dots,M$), and a hidden target $J$ occupies exactly one cell.

**Definition 1 (Probe order and probe cost).** A *probe order* is a permutation $\sigma$ of the cells; probe number $i$ (counting from $1$) inspects cell $\sigma(i)$. Given nonnegative weights $q=(q_0,\dots,q_{M-1})$ (typically a probability vector), the *probe cost* of $\sigma$ is

$$C(q,\sigma)=\sum_{i=1}^{M} i\cdot q_{\sigma(i)} .$$

When $q$ is the law of $J$, $C(q,\sigma)$ is the expected number of probes until the target is found.

**Definition 2 (Bayes cost).** The *Bayes-optimal cost* is $\mathrm{opt}(q)=\min_{\sigma} C(q,\sigma)$, the minimum over all $M!$ orders. An order attaining it is *Bayes-optimal*.

**Definition 3 (Blind cost).** Under the uniform prior $q_j=1/M$, every order has cost $\mathrm{blind}(M)=\sum_{i=1}^M i/M=(M+1)/2$.

**Definition 4 (Interval hint and truthful posterior).** An *interval hint* of width $W$ ($0<W<M$) and coverage $\alpha\in[0,1]$ designates a window, which after relabelling is $\{0,\dots,W-1\}$, and asserts $P(J\in\text{window})=\alpha$. Starting from the uniform prior and conditioning truthfully, the posterior is

$$h_j=\begin{cases}\alpha/W, & j<W,\\ (1-\alpha)/(M-W), & j\ge W.\end{cases}$$

This is a probability vector: $\sum_j h_j=\alpha+(1-\alpha)=1$. We write $w=W/M$ for the *relative width*.

**Definition 5 (Committed procedure and speedup).** The *committed procedure* probes the window first and then the complement, each in increasing index order; its cost is $\mathrm{hint}(M,W,\alpha)=C(h,\mathrm{id})$. The *speedup* is $S(M,W,\alpha)=\mathrm{blind}(M)/\mathrm{hint}(M,W,\alpha)$.

**Definition 6 (Min-law).** If $p,q$ are independent and uniform on $\{1,\dots,M\}$, the law of $J=\min(p,q)$ is the *min-law*

$$\mu_M(j)=P(J=j)=\frac{2(M-j)+1}{M^2},\qquad j=1,\dots,M.$$

---

## 3. Greedy order is Bayes-optimal

**Theorem 1 (Greedy optimality).** Let $q$ be any weight vector and $\tau$ an order such that $i\mapsto q_{\tau(i)}$ is non-increasing. Then $C(q,\tau)\le C(q,\sigma)$ for every order $\sigma$. Consequently $\mathrm{opt}(q)=C(q,\tau)$.

*Proof sketch.* The sequence of positions $1,2,\dots,M$ is increasing and the sequence $q_{\tau(1)}\ge q_{\tau(2)}\ge\cdots$ is non-increasing, so the two sequences are oppositely ordered. By the rearrangement inequality, the sum $\sum_i i\,q_{\tau(i)}$ is the smallest among all sums $\sum_i i\,q_{\tau(\pi(i))}$ obtained by permuting the second sequence. Any order $\sigma$ is of the form $\tau\circ\pi$ for $\pi=\tau^{-1}\circ\sigma$, which gives the claim. $\square$

---

## 4. The exact two-number law

We need two elementary sums: $\sum_{i=0}^{W-1}(i+1)=W(W+1)/2$, and for a two-level weight profile ($a$ on the first $W$ positions and $b$ on the remaining $M-W$),

$$\sum_{i=0}^{M-1}(i+1)\,\big[a\ \text{if}\ i<W\ \text{else}\ b\big] \;=\; a\,\frac{W(W+1)}{2}+b\,\frac{(M-W)(M+W+1)}{2}. \tag{4.1}$$

Identity (4.1) follows by induction on $M\ge W$.

**Theorem 2 (Exact hinted cost and speedup).** For $0<W<M$ and any real $\alpha$,

$$\mathrm{hint}(M,W,\alpha)=\frac{W+1+(1-\alpha)M}{2},\qquad S(M,W,\alpha)=\frac{M+1}{(1-\alpha)M+W+1}.$$

*Proof sketch.* Apply (4.1) with $a=\alpha/W$ and $b=(1-\alpha)/(M-W)$:

$$\mathrm{hint}=\frac{\alpha(W+1)}{2}+\frac{(1-\alpha)(M+W+1)}{2}=\frac{W+1+(1-\alpha)M}{2}.$$

Divide $\mathrm{blind}(M)=(M+1)/2$ by this; the factors of $2$ cancel. $\square$

Note that the formula is valid for every real $\alpha$, but the interpretation as a probability requires $\alpha\in[0,1]$.

---

## 5. When is the committed procedure optimal?

**Theorem 3 (Bayes optimality for $\alpha\ge w$).** If $W\le\alpha M$, then $\mathrm{hint}(M,W,\alpha)\le C(h,\sigma)$ for every order $\sigma$, and therefore $\mathrm{opt}(h)=\mathrm{hint}(M,W,\alpha)$.

*Proof sketch.* With $0<W<M$, the inequality $(1-\alpha)/(M-W)\le\alpha/W$ is equivalent, after clearing positive denominators, to $W(1-\alpha)\le\alpha(M-W)$, i.e. $W\le\alpha M$. Hence the posterior read in the committed order is non-increasing (constant on the window, then a step down, then constant), and Theorem 1 applies. $\square$

**Theorem 4 (Sharpness).** If $\alpha M<W$, let $\sigma$ be the committed order with the last window cell $W-1$ and the first outside cell $W$ transposed. Then $C(h,\sigma)<\mathrm{hint}(M,W,\alpha)$; in particular the committed procedure is not Bayes-optimal.

*Proof sketch.* Only probes $W$ and $W+1$ change. The committed order pays $W\cdot\frac{\alpha}{W}+(W+1)\frac{1-\alpha}{M-W}$ for them; the transposed order pays $W\frac{1-\alpha}{M-W}+(W+1)\frac{\alpha}{W}$. The difference (committed minus transposed) equals $\frac{1-\alpha}{M-W}-\frac{\alpha}{W}$, which is strictly positive precisely when $\alpha M<W$. $\square$

Together, Theorems 3 and 4 say: **the committed procedure is Bayes-optimal if and only if $\alpha\ge w$.** A hint that is less reliable than it is wide points to a region whose per-cell posterior is *lower* than that of its complement.

**Example.** For $M=6$, $W=2$ (so $w=1/3$), exhaustive enumeration of all $720$ orders gives: at $\alpha=1/2$, committed cost $3$ = optimum; at $\alpha=1/3$, committed $7/2$ = optimum; at $\alpha=1/4$, committed $15/4$ but optimum $13/4$, attained by probing the four outside cells first.

---

## 6. Ceilings, exchange rate and the continuum law

**Theorem 5 (Ceilings, monotonicity, exchange rate).** Let $0<W<M$.

1. *(Coverage ceiling.)* If $0\le\alpha<1$, then $S(M,W,\alpha)\le 1/(1-\alpha)$.
2. *(Width ceiling.)* If $\alpha\le1$, then $S(M,W,\alpha)\le (M+1)/(W+1)$, with equality at $\alpha=1$.
3. *(Monotonicity.)* If $\alpha<\alpha'\le1$, then $S(M,W,\alpha)<S(M,W,\alpha')$.
4. *(Exchange rate.)* For $0<W,W'<M$ and $\alpha,\alpha'\le1$:
$$S(M,W,\alpha)=S(M,W',\alpha')\iff (1-\alpha)M+W=(1-\alpha')M+W'.$$

*Proof sketch.* All four follow from Theorem 2 by cross-multiplying positive quantities. (1) $(M+1)(1-\alpha)\le(1-\alpha)M+W+1$ reduces to $-\alpha\le W$, true since $W\ge1$ and $\alpha<1$. (2) The denominator $(1-\alpha)M+W+1$ is at least $W+1$ since $(1-\alpha)M\ge0$. (3) The denominator strictly decreases in $\alpha$. (4) Both fractions share the numerator $M+1>0$, so equality holds iff the denominators agree. $\square$

The exchange rate is the cleanest expression of additivity: **one cell of width is worth exactly $1/M$ of coverage.** For example, at $M=1000$ the hints $(\alpha,W)=(0.90,20)$ and $(0.93,50)$ both give $S=8.2727\ldots$.

**Theorem 6 (Continuum two-number law).** Fix real $\alpha,w$ with $1-\alpha+w>0$ and a sequence $W_M$ with $W_M/M\to w$. Then

$$\frac{M+1}{(1-\alpha)M+W_M+1}\;\longrightarrow\;\frac{1}{1-\alpha+w}\qquad(M\to\infty).$$

*Proof sketch.* Divide numerator and denominator by $M$: the ratio equals $(1+1/M)/\big((1-\alpha)+W_M/M+1/M\big)$; the numerator tends to $1$, the denominator to $1-\alpha+w\ne0$. $\square$

**Interpretation.** The quantity $1-\alpha+w$ is the residual fraction of the blind cost: the coverage deficit $1-\alpha$ (the probability of being misled into a full scan of the remainder) plus the width $w$ (the fraction one must scan even when the hint is right). "Coverage $\times$ width" is the wrong reading; the law is a sum.

**Table 1.** Uniform prior, exact speedup at $M=1000$.

| $w$ | $\alpha=0.5$ | $\alpha=0.75$ | $\alpha=0.9$ | $\alpha=1$ |
|---|---|---|---|---|
| $0.02$ | $1.92$ | $3.69$ | $8.27$ | $47.67$ |
| $0.05$ | $1.82$ | $3.33$ | $6.63$ | $19.63$ |
| $0.10$ | $1.67$ | $2.85$ | $4.98$ | $9.91$ |
| $0.20$ | $1.43$ | $2.22$ | $3.33$ | $4.98$ |

---

## 7. Calibrating the $5.19\times$ crossing

**Theorem 7 (Crossing calibration).** In the continuum law, if $0.02\le w\le0.05$, $1-\alpha+w>0$, and $1/(1-\alpha+w)=5.19$, then $0.82<\alpha<0.86$. Moreover, for every $w\in[0.02,0.05]$, $1/(1-0.9+w)>5.19$.

*Proof sketch.* The equation gives $\alpha=1-1/5.19+w\approx0.80732+w$, which lies in $[0.8273,0.8573]$. For the second claim, $1/(0.1+w)\ge1/0.15\approx6.67>5.19$. $\square$

Thus a $5.19\times$ gain is equivalent, under the uniform prior, to an oracle that localizes the target to a $2$–$5\%$ window with reliability between about $83\%$ and $86\%$; a $90\%$-reliable window of that width is worth $6.67\times$ to $8.33\times$, and so the "90%" description overprices the observed gain. The qualitative claim — that external positional information is a two-parameter object — is confirmed; the quantitative dictionary is corrected.

---

## 8. The min-law prior

**Theorem 8 (Counting identity).** For $1\le j\le M$, exactly $2(M-j)+1$ ordered pairs $(p,q)\in\{1,\dots,M\}^2$ satisfy $\min(p,q)=j$. Hence $\mu_M(j)=(2(M-j)+1)/M^2$, and $\sum_j\mu_M(j)=1$.

*Proof sketch.* The set of such pairs is the disjoint union of $\{j\}\times\{j,\dots,M\}$ (size $M-j+1$) and $\{j+1,\dots,M\}\times\{j\}$ (size $M-j$). Summing, $\sum_{i=0}^{N-1}(2(M-1-i)+1)=N(2M-N)$, which equals $M^2$ at $N=M$. $\square$

**Theorem 9 (Monotonicity and optimal blind cost).** $\mu_M$ is strictly decreasing in $j$; hence ascending scan is the Bayes-optimal blind order, with cost

$$\sum_{j=1}^M j\,\mu_M(j)=\frac{(M+1)(2M+1)}{6M}\;\approx\;\frac{M}{3}.$$

*Proof sketch.* Strict decrease is immediate from the formula. Optimality follows from Theorem 1. For the cost, induction on $N$ gives $\sum_{i=0}^{N-1}(i+1)(2(M-1-i)+1)=N(N+1)\big(\tfrac{2M+1}{2}-\tfrac{2N+1}{3}\big)$; set $N=M$ and divide by $M^2$. $\square$

A consequence of strict decrease: conditioning the min-law on any window of two or more cells does **not** produce a uniform distribution on that window. Models that assume "uniform given a hit" are therefore inconsistent with this target law.

**Theorem 10 (Perfect-coverage block hints under the min-law).** Let $M=kW$ with $k,W\ge1$, and suppose an oracle names (with certainty) which of the $k$ consecutive blocks of width $W$ contains $J$; the searcher scans that block in ascending order (Bayes-optimal within the block by Theorem 9). The expected cost is

$$\frac{(W+1)(3M-W+1)}{6M},$$

and the speedup over the optimal blind scan is

$$S_{\min}(M,W)=\frac{(M+1)(2M+1)}{(W+1)(3M-W+1)}\;\longrightarrow\;\frac{2}{w(3-w)}\quad(W/M\to w).$$

*Proof sketch.* Within block $b$ the target at offset $r$ costs $r+1$ probes and has probability $(2(M-1-bW-r)+1)/M^2=(A_b-2r)/M^2$ with $A_b=2M-1-2bW$. The inner sum is $\sum_{r<W}(r+1)(A_b-2r)=A_b\,\tfrac{W(W+1)}2-\tfrac23(W-1)W(W+1)$. Summing the arithmetic progression in $b$ over $k$ blocks and simplifying with $M=kW$ yields the stated cost; dividing the blind cost of Theorem 9 by it gives $S_{\min}$. The limit follows by dividing numerator and denominator by $M^2$: $(2+o(1))/(w(3-w)+o(1))$. $\square$

**Table 2.** Min-law, perfect coverage, exact closed form at $M=10^4$, and continuum limit.

| $w$ | exact $S_{\min}$ at $M=10^4$ | continuum $2/(w(3-w))$ |
|---|---|---|
| $0.02$ | $33.39$ | $33.56$ |
| $0.05$ | $13.53$ | $13.56$ |
| $0.10$ | $6.89$ | $6.90$ |
| $0.20$ | $3.57$ | $3.57$ |

In particular $2/(0.02\cdot2.98)>33$.

**Comparison with the reported empirical table.** The motivating study reported, for the min-law target, a speedup table parametrized by a relative window width (denoted there by a ratio $\mu/M$) and coverage: at relative width $0.02$, speedups $1.86, 3.50, 7.41, 29.13$ at $\alpha=0.5,0.75,0.9,1.0$; maximal speedups $13.12$, $7.11$, $3.96$ at widths $0.05$, $0.10$, $0.20$; and a Monte-Carlo value of $34.0$ against the grid value $29.13$ at width $0.02$, $\alpha=1$ (and $5.70$ against $5.59$ in another cell). Because that table's windows are parametrized differently from our aligned blocks, the comparison is indicative only. Still, the exact value $33.4$ at $w=0.02$ sits beside the Monte-Carlo $34.0$, not the grid $29.13$, which localizes the discrepancy in the grid computation. The imperfect-coverage cells of the min-law table are not covered by our theorems (see Section 15).

---

## 9. Value of information

**Theorem 11 (Concavity of the Bayes cost).** For weight vectors $q_1,q_2$ on $n$ cells and $t\in[0,1]$,

$$t\,\mathrm{opt}(q_1)+(1-t)\,\mathrm{opt}(q_2)\;\le\;\mathrm{opt}\big(t\,q_1+(1-t)\,q_2\big).$$

*Proof sketch.* For each fixed $\sigma$, $C(\cdot,\sigma)$ is linear, so $C(tq_1+(1-t)q_2,\sigma)=tC(q_1,\sigma)+(1-t)C(q_2,\sigma)\ge t\,\mathrm{opt}(q_1)+(1-t)\,\mathrm{opt}(q_2)$. Take the minimum over $\sigma$. $\square$

Interpreting a truthful hint as revealing which component of a mixture prior is active, Theorem 11 says the expected Bayes cost after the hint is never larger than before it. Combining Theorems 1 and 3: whenever $\alpha\ge w$, $\mathrm{opt}(h)=\mathrm{hint}(M,W,\alpha)$ — the committed cost *is* the Bayes cost.

---

## 10. Misspecified coverage

**Theorem 12 (Misspecified-coverage regret).** Suppose the oracle claims coverage $\alpha$ but the true coverage is $\beta$. The committed order does not depend on the claim, and

$$C(h^{(\beta)},\mathrm{id})-\mathrm{hint}(M,W,\alpha)=\frac{(\alpha-\beta)M}{2},\qquad \frac{\mathrm{blind}(M)}{C(h^{(\beta)},\mathrm{id})}=\frac{M+1}{(1-\beta)M+W+1},$$

where $h^{(\beta)}$ is the true posterior.

*Proof sketch.* Apply Theorem 2 at $\beta$ and at $\alpha$ and subtract. $\square$

**Theorem 13 (Strict suboptimality under over-trust).** If the true coverage satisfies $\beta M<W$, then $\mathrm{opt}(h^{(\beta)})<C(h^{(\beta)},\mathrm{id})$, whatever coverage was claimed.

*Proof sketch.* $\mathrm{opt}$ is at most the cost of the transposed order of Theorem 4, which is strictly below the committed cost. $\square$

Each percentage point of overstated coverage costs $M/200$ probes in expectation; at $M=1000$, $W=30$, claiming $0.9$ when the truth is $0.7$ costs exactly $100$ extra probes.

---

## 11. Algorithms

**Algorithm A (Bayes-optimal hinted search).** Input: prior $\pi$ on $M$ cells, window $S$, coverage $\alpha$. (1) Form the truthful posterior $h_j=\alpha\pi_j/\pi(S)$ for $j\in S$ and $h_j=(1-\alpha)\pi_j/\pi(S^c)$ otherwise. (2) Sort cells by non-increasing $h_j$ (ties by index). (3) Probe in that order. Cost: $O(M\log M)$ preprocessing; optimality by Theorem 1. Under the uniform prior and $\alpha\ge w$ the sorting step is unnecessary: the window-first order is already greedy (Theorem 3), giving an $O(M)$ procedure; for $\alpha<w$ the optimal order is complement-first.

**Algorithm B (Hint pricing and calibration).** Given $(M,W,\alpha)$ return $S=(M+1)/((1-\alpha)M+W+1)$. Given an observed speedup $S^\ast$ and width $w$, return the equivalent coverage $\alpha^\ast=1-1/S^\ast+w$ (continuum law), valid when $\alpha^\ast\in[w,1]$; given $(S^\ast,\alpha)$ return the equivalent width $w^\ast=1/S^\ast-(1-\alpha)$. Cost $O(1)$.

**Algorithm C (Exhaustive verification).** For small $M$, enumerate all $M!$ orders, compute $C(h,\sigma)$ in exact rational arithmetic, and compare the minimum with the committed cost. Cost $O(M!\cdot M)$; used to confirm the example of Section 5.

---

## 12. Numerical illustrations

We record several exact computations (rational arithmetic) that illustrate the theorems.

*Convergence to the continuum law.* At $w=0.05$, $\alpha=0.9$ the exact speedups are $5.500$ ($M=10$), $6.3125$ ($M=100$), $6.6291$ ($M=1000$) and $6.66629$ ($M=10^5$), approaching $1/(0.1+0.05)=6.6667$. The convergence is from below, at rate $O(1/M)$, because the exact denominator carries the extra $+1$ of the discrete scan.

*Ceilings in action.* At $M=1000$ and $\alpha=0.9$, shrinking the window from $W=20$ to $W=1$ raises the speedup only from $8.27$ to $9.81$, against the coverage ceiling $10$. Conversely, at $W=200$ raising coverage to $0.99$ yields $4.74$, against the width ceiling $(1001)/(201)=4.98$. Whichever term dominates the residual $1-\alpha+w$ is the binding constraint.

*Misspecification.* At $M=1000$, $W=30$, a claimed coverage of $0.9$ advertises an expected cost of $65.5$ probes. If the truth is $0.7$, the realized cost is $165.5$ (exactly $100$ more) and the realized speedup is $3.02$ rather than $7.64$. If the truth is $0.02<w=0.03$, the realized cost is $505.5$ while the Bayes-optimal search under the true posterior costs $495.5$: the committed procedure is now strictly worse than the optimum, and in fact slower than the blind scan ($500.5$).

*Monte-Carlo agreement.* Simulating $2\times10^5$ searches at $M=200$, $W=10$, $\alpha=0.9$ gives a mean of $15.40$ probes against the exact $15.5$, i.e. speedups $6.53$ versus $6.48$. Discrepancies of this size are sampling error; discrepancies such as $29.1$ versus $34.0$ in the min-law table are not, and indicate a modelling or computational inconsistency.

*Concavity.* For random nonnegative weight vectors on five cells and random mixing weights $t$, exhaustive computation of $\mathrm{opt}$ confirms $t\,\mathrm{opt}(q_1)+(1-t)\,\mathrm{opt}(q_2)\le\mathrm{opt}(tq_1+(1-t)q_2)$, with equality at $t\in\{0,1\}$ and typically a strict gap otherwise; the gap is the expected saving produced by learning which component is active.

## 13. Relation to classical search theory

The problem studied here is a discrete instance of optimal search for a stationary target with perfect detection, where the classical answer — probe in order of decreasing posterior probability — is Theorem 1. What is new is the explicit treatment of a *parametric family of side information*, the interval hint, and the resulting closed forms. The concavity statement (Theorem 11) is the search-theoretic face of the general principle that the Bayes risk of a decision problem is concave in the prior, which underlies the comparison of experiments; Section 15 proposes to push this to a full information ordering of hints. The min-law prior is the distribution of the smaller of two independent uniform draws, a natural model whenever one seeks the smaller of two unknown quantities (for instance the smaller of two hidden factors).

## 14. Discussion

**Additivity is the main lesson.** Positional side information is a two-parameter object, but the parameters combine through the residual $1-\alpha+w$. This has three practical implications: (i) comparing hints reduces to comparing $(1-\alpha)M+W$; (ii) improving a hint along one axis yields diminishing returns once that axis is no longer the dominant term of the residual; (iii) any observed speedup $S^\ast$ corresponds to a whole line of equivalent hints $\alpha-w=1-1/S^\ast$, not to a point — so a statement like "equivalent to a $2$–$5\%$ window at $90\%$" must be checked against the line, and in the motivating case it fails.

**Optimality is not automatic.** Natural procedures that "trust the hint" are optimal only above the threshold $\alpha=w$. Below it, the hint is anti-informative per cell.

**Methodological ledger.** Two earlier models in the motivating study were rejected because exact computation and simulation disagreed: a simulation that ignored the coverage parameter, and a model assuming the target is uniform within the window given a hit — an assumption contradicted by the strict monotonicity of the min-law (Theorem 9). The exact formulas here make such disagreements diagnosable.

**Limitations.** Our exact imperfect-coverage results are for the uniform prior; our min-law results are for perfect coverage with aligned blocks. The reported min-law table with $\alpha<1$ remains unexplained by closed forms.

## 15. Future work

1. **Additive law for monotone priors.** Conjecture: for any non-increasing prior and truthful window hints of relative width $w$ and coverage $\alpha\ge w$, the continuum speedup has the form $1/\big((1-\alpha)c_0+w\,c_1\big)$ with constants depending only on the prior's shape. Both proved endpoints (uniform prior with any $\alpha$; min-law with $\alpha=1$) are consistent with this form.
2. **Sharp threshold for general priors.** Conjecture: window-first is Bayes-optimal iff $\alpha\min_{S}\pi/\pi(S)\ge(1-\alpha)\max_{S^c}\pi/\pi(S^c)$, reducing to $\alpha\ge w$ for the uniform prior; optimality is decided by the two edge posteriors, as in the single transposition of Theorem 4.
3. **Min-law with imperfect coverage.** Conjecture: the Bayes-optimal continuum speedup $S(\alpha,w)$ is an explicit rational function reducing to $2/(w(3-w))$ at $\alpha=1$, with a block-dependent optimality threshold for the committed procedure.
4. **Information ordering of hints.** Conjecture: hint $A$ dominates hint $B$ for every prior iff $A$'s posterior partition refines $B$'s in the sense of Blackwell; concavity of the Bayes cost (Theorem 11) gives one direction.

## 16. Conclusion

An interval hint is worth exactly two numbers, and under a uniform prior its speedup is $(M+1)/((1-\alpha)M+W+1)\to1/(1-\alpha+w)$. Coverage and width trade at a fixed exchange rate, each imposes its own ceiling, and trusting the window first is optimal exactly when coverage exceeds width. These facts recalibrate an observed $5.19\times$ gain to $82$–$86\%$ coverage and, under the tilted min-law prior, yield the exact perfect-coverage speedup $2/(w(3-w))$.
