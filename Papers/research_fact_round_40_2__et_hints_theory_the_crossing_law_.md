# The Crossing Law for Interval Hints: Width Can Never Substitute for Reliability

**Aristotle**

*October 2026*

---

## Abstract

We study a model of search with a fallible hint. A target lies in one of $M$ cells and has a min-law prior. An oracle names a window of $W$ cells and asserts that the target lies in it with probability $\alpha$. A searcher opens cells one at a time and pays the expected number of probes. We give closed forms for three strategies under the resulting two-valued posterior: the blind baseline, the committed (window-first) scan, and the interleaved scan. We prove a *displacement law* that gives the exact cost of every one of the $M!$ probe orders. From it we deduce that the Bayes-optimal searcher coincides with the committed one, that for a strictly favoured window the optimal orders are *exactly* the window-first orders, and that interleaving is strictly dominated by an explicit margin $(a-b)W(W-1)/2$.

Pricing the hinted search against the min-law blind cost $B_M = (M+1)(2M+1)/(6M)$ gives the priced speedup
$$S_M(W,\alpha) = \frac{(M+1)(2M+1)}{3M\big((1-\alpha)M+W+1\big)},$$
with continuum limit $S(\alpha,w) = 2/(3(1-\alpha+w))$. Our main result is the **crossing law**: speedup $s$ is attained if and only if $w \le \alpha - \alpha_{\min}(s)$, where $\alpha_{\min}(s) = 1 - 2/(3s)$. This gives a hard reliability gate that no width can bypass, and iso-speedup curves that are straight lines of slope one. A finite-$M$ gate holds at every size and converges to the continuum gate. For a measured $5.19\times$ speedup the gate is $\alpha > 0.87155$, and at $\alpha = 0.90$ the crossing width is $\mu/M \approx 0.02845$.

We also determine the exact Bayes cost of the hint posterior in every regime. It shows that, for the fully Bayes-optimal searcher, the gate is *two-sided*: an anti-reliable oracle is a reliable oracle for the complement. An explicit four-cell witness shows that the one-sided gate fails outside the trusted regime $\alpha \ge W/M$. Finally, a pairing identity between the committed scan and its block reversal proves that the stipulated pricing is *conservative*: for every posterior with window mass $\alpha$, the true Bayes speedup is at least $S_M(W,\alpha)$.

---

## 1. Introduction

Many practical searches are guided by a hint that is useful but not certain. A fault-localization tool flags a region of code. A learned index predicts a position with an error band. A clinician's heuristic narrows down a list of causes. Such a hint has two natural quality parameters:

- its **width**, meaning how much of the search space it names; and
- its **reliability**, meaning how often the target actually lies in the named region.

It is tempting to treat these as interchangeable, so that a sufficiently sharp hint could make up for a moderate error rate. This paper shows that in a natural and fully explicit model this intuition fails sharply. Reliability acts as a **gate**: reaching speedup $s$ requires $\alpha$ to exceed a threshold $\alpha_{\min}(s)$ that does not depend on the width at all. Width only spends the surplus $\alpha - \alpha_{\min}(s)$, and the exchange rate between them is exactly linear.

Two technical steps make the result rigorous. First, the hinted search must be priced correctly, which means identifying the Bayes-optimal probe order among all $M!$ orders. We do this with an exact *displacement law*. Second, the pricing model must be justified. We show that it is conservative: any posterior consistent with the hint's stated reliability can only do better than the stipulated price.

### 1.1 Summary of results

1. **Exchange lemma and position-sum bound** (Theorems 2.1, 2.2): any $k$ probe slots have index sum at least $k(k+1)/2$, plus one for each slot beyond the first $k$.
2. **Displacement law** (Theorem 3.2): under a two-valued posterior $(a,b)$, every order costs exactly $(a-b)$ times the excess of its window-slot sum over $W(W+1)/2$, beyond the committed order.
3. **Bayes = Committed** (Theorem 3.4) and its sharp form (Theorem 3.5): the optimal orders are exactly the window-first orders when $a > b$.
4. **Interleaving** (Theorem 3.7): the alternating order costs exactly $(a-b)W(W-1)/2$ more, so it is strictly dominated.
5. **The crossing law** (Theorem 4.2), the **reliability gate** and **width cannot substitute** (Corollaries 4.3, 4.4), and the **linear crossing** (Corollary 4.5).
6. **Finite-$M$ closed form and gate** (Theorems 5.1, 5.2), with convergence to the continuum (Theorem 5.3).
7. **Exact Bayes cost** and the **two-sided gate** (Theorems 6.1, 6.2), with a counterexample to the one-sided version (Proposition 6.3).
8. **Pairing identity** and **conservative pricing** (Theorems 7.1, 7.3).

---

## 2. Model and a combinatorial exchange lemma

### 2.1 The search model

**Definition 2.1 (Cells, orders, cost).** Fix $M \ge 2$ cells, indexed $0, 1, \dots, M-1$. A *weight vector* (posterior) is a function $q:\{0,\dots,M-1\}\to\mathbb{R}$. Usually $q \ge 0$ and $\sum_j q_j = 1$. A *probe order* is a permutation $\sigma$ of the cells, with $\sigma(i)$ the cell opened in slot $i$ (slots indexed from $0$). The cost of $\sigma$ under $q$ is the expected number of probes,
$$
\mathrm{cost}_q(\sigma) \;=\; \sum_{i=0}^{M-1} (i+1)\, q_{\sigma(i)}.
$$
The *Bayes cost* is $\mathrm{opt}(q) = \min_{\sigma} \mathrm{cost}_q(\sigma)$ over all $M!$ orders.

**Definition 2.2 (Min-law blind cost).** If the target position is the minimum of two independent uniform cells and no hint is available, the optimal blind searcher scans from the front. Its expected cost is
$$
B_M \;=\; \sum_{j=1}^M \Pr[\text{position}\ge j] \;=\; \sum_{j=1}^{M} \frac{(M-j+1)^2}{M^2} \;=\; \frac{(M+1)(2M+1)}{6M}.
$$
Note that $B_M/M \to 1/3$.

**Definition 2.3 (Hint posterior).** An oracle names a window, which after relabelling is the first $W$ cells $\{0,\dots,W-1\}$ with $0<W<M$, and a reliability $\alpha\in[0,1]$. The *stipulated hint posterior* spreads mass uniformly on each side:
$$
q_j \;=\; \begin{cases} a = \alpha/W, & j < W,\\ b = (1-\alpha)/(M-W), & j \ge W.\end{cases}
$$
More generally, a *two-valued posterior* with levels $(a,b)$ assigns $a$ to window cells and $b$ to all others. The *window slots* of an order $\sigma$ are $\mathcal{W}(\sigma) = \{i : \sigma(i) < W\}$, a set of exactly $W$ slots. The *committed* order is the identity, which scans the window first.

### 2.2 Exchange lemma

**Theorem 2.1 (Exchange lemma).** Let $T, R$ be finite sets of the same size and $f$ a nonnegative integer weight. Suppose every element of $T\setminus R$ has weight at least $c$ and every element of $R\setminus T$ has weight at most $c-1$. Then
$$
\sum_{x\in R} f(x) + |T\setminus R| \;\le\; \sum_{x\in T} f(x).
$$

*Proof.* Since $|T|=|R|$, we have $|T\setminus R| = |R\setminus T| =: k$. Both sums share the part over $T\cap R$. On the remaining parts, $\sum_{R\setminus T}(f+1) \le kc \le \sum_{T\setminus R} f$, and $\sum_{R\setminus T}(f+1) = \sum_{R\setminus T} f + k$. $\square$

**Theorem 2.2 (Position-sum lower bound).** Let $0\le k\le M$ and let $U$ be any set of $k$ slots. Then
$$
\frac{k(k+1)}{2} \;+\; \#\{i\in U : i \ge k\} \;\le\; \sum_{i\in U}(i+1).
$$

*Proof.* Apply Theorem 2.1 with $T = U$, $R = \{0,\dots,k-1\}$, $f(i) = i$ and $c = k$. Elements of $U\setminus R$ are at least $k$, and elements of $R\setminus U$ are at most $k-1$. Hence $\sum_{i<k} i + \#(U\setminus R) \le \sum_{U} i$. Adding $k$ to both sides converts indices into slot numbers $i+1$, and $\sum_{i<k}(i+1) = k(k+1)/2$. $\square$

In words, every slot pushed past the first $k$ raises the sum by at least one.

---

## 3. The displacement law and optimal search

### 3.1 Exact cost of every order

**Lemma 3.1 (Cost under a two-valued posterior).** For every order $\sigma$,
$$
\mathrm{cost}(\sigma) \;=\; b\,\frac{M(M+1)}{2} \;+\; (a-b)\sum_{i\in\mathcal{W}(\sigma)}(i+1).
$$

*Proof.* Write $q_{\sigma(i)} = b + (a-b)\mathbf{1}[i\in\mathcal{W}(\sigma)]$ and sum against $i+1$. $\square$

**Theorem 3.2 (Displacement law).** For every two-valued posterior $(a,b)$, every $0\le W\le M$, and every one of the $M!$ orders $\sigma$,
$$
\mathrm{cost}(\sigma) - \mathrm{cost}(\mathrm{committed}) \;=\; (a-b)\Big(\sum_{i\in\mathcal{W}(\sigma)}(i+1) \;-\; \frac{W(W+1)}{2}\Big).
$$

*Proof.* Subtract Lemma 3.1 for $\sigma$ and for the identity, whose window slots are $\{0,\dots,W-1\}$ with slot sum $W(W+1)/2$. $\square$

The law reduces the comparison of $M!$ strategies to a single scalar per strategy, the *displacement* of the window slots.

**Definition 3.3.** The number of *misplaced* window cells of $\sigma$ is $m(\sigma) = \#\{i\in\mathcal{W}(\sigma): i\ge W\}$, the window cells opened after slot $W$.

**Theorem 3.4 (Misplacement cost; Bayes = Committed).** If $a\ge b$, then for every order $\sigma$
$$
\mathrm{cost}(\mathrm{committed}) + (a-b)\,m(\sigma) \;\le\; \mathrm{cost}(\sigma).
$$
In particular $\mathrm{opt} = \mathrm{cost}(\mathrm{committed})$: the Bayes-optimal searcher is the committed searcher.

*Proof.* Theorem 2.2 with $U = \mathcal{W}(\sigma)$ and $k = W$ gives slot-sum excess at least $m(\sigma)$. Multiply by $a-b\ge 0$ and use Theorem 3.2. $\square$

**Theorem 3.5 (Characterization of Bayes orders).** If $a > b$, an order $\sigma$ is Bayes-optimal if and only if it is window-first, that is, $\sigma(i) < W \Rightarrow i < W$.

*Proof.* If $\sigma$ is window-first, then $\mathcal{W}(\sigma) = \{0,\dots,W-1\}$ and the displacement is zero. Conversely, if some window cell is opened at slot $\ge W$, then $m(\sigma)\ge 1$ and Theorem 3.4 gives cost at least $\mathrm{opt} + (a-b) > \mathrm{opt}$. $\square$

So there are exactly $W!\,(M-W)!$ optimal orders. For example, with $M=6$, $W=2$ and $\alpha = 0.7$, exhaustive enumeration finds exactly $2!\cdot 4! = 48$ optimal orders, all window-first.

### 3.2 Interleaving is strictly dominated

**Lemma 3.6 (Realizability).** For every set $T$ of $W$ slots there is an order $\sigma$ with $\mathcal{W}(\sigma) = T$.

*Proof.* Biject $T$ onto the window cells and its complement onto the outside cells. $\square$

**Theorem 3.7 (Interleaved closed form).** Let $2W\le M$ and let the *interleaved* slot set be the even slots $\{0, 2, \dots, 2W-2\}$. Such an order exists, and every order with these window slots satisfies
$$
\mathrm{cost}(\sigma) \;=\; \mathrm{cost}(\mathrm{committed}) + (a-b)\,\frac{W(W-1)}{2}.
$$
If moreover $W\ge 2$ and $a>b$, then $\mathrm{opt} < \mathrm{cost}(\sigma)$: interleaving is strictly dominated.

*Proof.* Existence follows from Lemma 3.6. The slot numbers are $1,3,\dots,2W-1$, with sum $W^2$, and $W^2 - W(W+1)/2 = W(W-1)/2$. Apply Theorem 3.2, then Theorem 3.4. $\square$

*Example.* $M = 8$, $W=3$, $a = 1/5$, $b = 1/25$: the interleaved excess is $(4/25)\cdot 3 = 12/25$, and direct evaluation agrees exactly.

### 3.3 Committed cost

For the stipulated posterior, Lemma 3.1 at the identity gives
$$
C_M(W,\alpha) \;=\; \alpha\cdot\frac{W+1}{2} + (1-\alpha)\cdot\frac{M+W+1}{2} \;=\; \frac{W+1+(1-\alpha)M}{2}.
$$
We call this the *two-number cost* of the hinted search: it depends on the hint only through $(W,\alpha)$.

---

## 4. The crossing law

**Definition 4.1 (Priced continuum speedup and gate).** For $\alpha, w$ with $1-\alpha+w>0$ and $s>0$, define
$$
S(\alpha,w) \;=\; \frac{2}{3(1-\alpha+w)}, \qquad \alpha_{\min}(s) \;=\; 1 - \frac{2}{3s}.
$$
Here $S$ is the limit of $B_M/C_M$ when $W/M\to w$ (Theorem 5.3): the blind cost $\sim M/3$ against the hinted cost $\sim (1-\alpha+w)M/2$.

**Theorem 4.2 (The crossing law).** For $s>0$ and $1-\alpha+w>0$,
$$
s \le S(\alpha,w) \quad\Longleftrightarrow\quad w \le \alpha - \alpha_{\min}(s).
$$

*Proof.* Since the denominator is positive, $s\le 2/(3(1-\alpha+w))$ is equivalent to $3s(1-\alpha+w) \le 2$, that is, to $1-\alpha+w\le 2/(3s)$. That rearranges to $w \le \alpha - (1 - 2/(3s))$. $\square$

**Corollary 4.3 (Reliability gate).** If $w>0$ and $s \le S(\alpha,w)$, then $\alpha > \alpha_{\min}(s)$.

**Corollary 4.4 (Width cannot substitute for reliability).** If $\alpha\le\alpha_{\min}(s)$, then $S(\alpha,w) < s$ for *every* $w > 0$.

*Proof.* Now $1-\alpha+w \ge 2/(3s) + w > 2/(3s) > 0$, so $S(\alpha, w) < s$. $\square$

At $\alpha = \alpha_{\min}(5)$, widths $w = 10^{-1}, 10^{-3}, 10^{-6}$ give $S = 2.857$, $4.963$ and $4.99996$: the speedup approaches the target but never reaches it.

**Corollary 4.5 (Iso-speedup lines and linear crossing).** $S(\alpha,w) = s$ if and only if $w = \alpha - \alpha_{\min}(s)$. Consequently, for $\alpha>\alpha_{\min}(s)$ the *crossing width* $w^\star = \alpha - \alpha_{\min}(s)$ is positive and attains $S(\alpha,w^\star) = s$ exactly. In the $(w,\alpha)$ plane, the level sets of $S$ are parallel lines of slope one, and each is the boundary of the region where $S \ge s$.

### 4.1 Calibration: a measured $5.19\times$ speedup

**Proposition 4.6.** $0.87154 < \alpha_{\min}(5.19) < 0.87155$. At $\alpha = 0.90$, the crossing width satisfies $0.02845 < 0.90 - \alpha_{\min}(5.19) < 0.02846$, and $S(0.90,\,0.90-\alpha_{\min}(5.19)) = 5.19$ exactly.

*Proof.* $\alpha_{\min}(5.19) = 1 - 2/15.57 = 0.8715478\ldots$ The rest is Corollary 4.5. $\square$

A measured magnitude gain of $5.19\times$ therefore corresponds to an *effective interval quality*. The hints must be correct more than $87.15\%$ of the time, whatever their width. If they are correct $90\%$ of the time, the windows must cover at most about $2.85\%$ of the space. This matches an independent numerical estimate ($\alpha\approx 0.90$, $\mu/M\approx 0.028$).

---

## 5. Finite-$M$ theory

**Theorem 5.1 (Closed form for the priced speedup).** For $0<W<M$,
$$
S_M(W,\alpha) \;:=\; \frac{B_M}{C_M(W,\alpha)} \;=\; \frac{(M+1)(2M+1)}{3M\big((1-\alpha)M+W+1\big)}.
$$

*Proof.* Divide Definition 2.2 by §3.3. $\square$

This closed form equals the brute-force sum exactly. For instance, at $M=300$, $W=9$, $\alpha=0.9$ both give $S = 5.02503\ldots$ with relative gap $0$.

**Definition.** $\alpha_{\min}^M(s) = 1 - \dfrac{(M+1)(2M+1)}{3M^2 s}$.

**Theorem 5.2 (Finite reliability gate).** Let $0<W<M$, $\alpha\le 1$ and $s>0$. If $s\le S_M(W,\alpha)$, then $\alpha > \alpha_{\min}^M(s)$.

*Proof.* The hypothesis gives $(1-\alpha)M + W + 1 \le (M+1)(2M+1)/(3Ms)$ (the denominator is positive because $\alpha\le 1$). Since $W+1>0$, we get $(1-\alpha)M < (M+1)(2M+1)/(3Ms)$. Dividing by $M$ gives the claim. $\square$

The gate holds at every finite size and for every width.

**Theorem 5.3 (Continuum limits).** For every $s>0$, $\alpha_{\min}^M(s)\to\alpha_{\min}(s)$ as $M\to\infty$. If $W_M/M\to w$ with $1-\alpha+w>0$, then $S_M(W_M,\alpha)\to S(\alpha,w)$.

*Proof.* Write $\alpha_{\min}^M(s) = 1 - (1+1/M)(2+1/M)/(3s)$ and $S_M = (1+1/M)(2+1/M)/\big(3((1-\alpha) + W_M/M + 1/M)\big)$, then let $1/M\to 0$. $\square$

| $M$ | $10$ | $100$ | $300$ | $10^3$ | $10^4$ | $\infty$ |
|---|---|---|---|---|---|---|
| $\alpha_{\min}^M(5.19)$ | $0.85164$ | $0.86962$ | $0.87090$ | $0.87136$ | $0.87153$ | $0.87155$ |

---

## 6. The fully Bayesian searcher: a two-sided gate

The crossing law prices the *committed* scan. When $\alpha < W/M$, the window is *less* likely per cell than the outside, so $a<b$, and the Bayes searcher behaves differently.

**Theorem 6.1 (Exact Bayes cost of the hint posterior).** For $0<W<M$ and every $\alpha$,
$$
\mathrm{opt} \;=\; \min\left(\frac{W+1+(1-\alpha)M}{2},\;\frac{M-W+1+\alpha M}{2}\right).
$$

*Proof.* By Lemma 3.1, $\mathrm{cost}(\sigma) = bM(M+1)/2 + (a-b)\Sigma(\sigma)$, where $\Sigma(\sigma)$ is the window-slot sum. Always $W(W+1)/2 \le \Sigma(\sigma) \le W(2M-W+1)/2$: the lower bound is Theorem 2.2, and the upper bound follows by the same argument applied to the reversed slot labels. If $a\ge b$, the cost is at least the committed cost (the first term). If $a<b$, it is at least the cost of the *outside-first* order, which places the window in the last $W$ slots. That cost is
$$
(1-\alpha)\frac{M-W+1}{2} + \alpha\Big(M-W+\frac{W+1}{2}\Big) = \frac{M-W+1+\alpha M}{2}.
$$
Both values are attained, so the Bayes cost is their minimum. $\square$

We checked this against all $720$ orders for $M=6$ in $55$ cells ($W = 1,\dots,5$; $\alpha = 0, 0.1,\dots,1$), and it held in $55/55$.

**Theorem 6.2 (Two-sided Bayes gate).** Let $0<W<M$, $0\le\alpha\le 1$, $s>0$. If the Bayes speedup satisfies $s \le B_M/\mathrm{opt}$, then
$$
\alpha > \alpha_{\min}^M(s) \qquad\text{or}\qquad 1-\alpha > \alpha_{\min}^M(s).
$$

*Proof.* By Theorem 6.1, $\mathrm{opt}$ equals one of the two committed costs. If it is the window-first cost, Theorem 5.2 gives $\alpha > \alpha_{\min}^M(s)$. If it is the outside-first cost, observe that
$$
\frac{M-W+1+\alpha M}{2} = \frac{(M-W) + 1 + (1-(1-\alpha))M}{2}
$$
is the committed cost of the complementary hint, with width $M-W$ and reliability $1-\alpha$. Theorem 5.2 applied to that hint gives $1-\alpha > \alpha_{\min}^M(s)$. $\square$

**Proposition 6.3 (The one-sided gate fails for Bayes search).** For $M=4$, $W=2$, $\alpha=0$, the Bayes speedup is at least $5/4$, while $\alpha_{\min}^4(5/4) = 1/4 > 0 = \alpha$.

*Proof.* $B_4 = 5\cdot 9/24 = 15/8$. By Theorem 6.1, $\mathrm{opt} = \min(7/2, 3/2) = 3/2$, so $B_4/\mathrm{opt} = 5/4$. Also $\alpha_{\min}^4(5/4) = 1 - 45/60 = 1/4$. $\square$

An oracle that is always wrong is a perfect oracle for the complement. The one-sided gate is restored in the *trusted regime*:

**Corollary 6.4 (Trusted regime).** If $W\le \alpha M$ and $\alpha\le 1$, then $\mathrm{opt} = C_M(W,\alpha)$, and $s\le B_M/\mathrm{opt}$ implies $\alpha>\alpha_{\min}^M(s)$.

*Proof.* $W \le \alpha M$ is equivalent to $a\ge b$, so Theorem 3.4 applies, and then Theorem 5.2. $\square$

---

## 7. The stipulated pricing is conservative

The model above spreads the hint's mass uniformly on each side of the window. Real posteriors need not do so. We show this choice can only *understate* the value of a hint.

**Definition 7.0 (Block reversal).** The *block reversal* $\rho$ opens the window in reverse ($W-1, W-2, \dots, 0$) and then the outside in reverse ($M-1, \dots, W$). It is an involution of the cells.

**Theorem 7.1 (Pairing identity).** For *any* weight vector $q$ with window mass $\sum_{j<W} q_j = \alpha$ and total mass $1$,
$$
\mathrm{cost}_q(\mathrm{committed}) + \mathrm{cost}_q(\rho) \;=\; W + 1 + (1-\alpha)M.
$$

*Proof.* A window cell $j$ is opened in slot $j+1$ by the committed order and slot $W-j$ by $\rho$, for a total of $W+1$. An outside cell $j$ is opened in slots $j+1$ and $M+W-j$, for a total of $M+W+1$. Summing against $q$ gives $(W+1)\alpha + (M+W+1)(1-\alpha) = W+1+(1-\alpha)M$. $\square$

**Corollary 7.2.** $\mathrm{opt}(q) \le \dfrac{W+1+(1-\alpha)M}{2} = C_M(W,\alpha)$ for every such $q$.

*Proof.* The minimum of the two costs is at most their average, and $\mathrm{opt}$ is at most either. $\square$

**Theorem 7.3 (Conservative pricing).** Let $0<W<M$ and let $q\ge 0$ have total mass $1$ and window mass $\alpha$. Then
$$
S_M(W,\alpha) \;\le\; \frac{B_M}{\mathrm{opt}(q)}.
$$

*Proof.* Because $q\ge 0$ sums to $1$ and slot numbers are at least $1$, $\mathrm{opt}(q)\ge 1>0$. Corollary 7.2 then lets us compare the reciprocals. $\square$

So every posterior consistent with a hint of window mass $\alpha$ achieves at least the stipulated speedup. In $300$ random posteriors on $M=6$ cells, the ratio $\mathrm{opt}(q)/C_M$ never exceeded $1$; its maximum was about $0.96$. Empirically, conditioning in a way that follows the shape of the prior inside the window raised an estimated speedup from $5.56\times$ to $7.62\times$. Consequently, the crossing law is a *benchmark* for the value of reliable hints: it is the price they guarantee, not a universal necessary condition for arbitrary hint semantics.

---

## 8. Algorithms

**Algorithm A (Exact pricing of a hint).** Input: $M$, $W$, $\alpha$. Output: $B_M$, $C_M$, $S_M$, Bayes cost, Bayes speedup.

1. $B \leftarrow (M+1)(2M+1)/(6M)$.
2. $C_{\mathrm{in}} \leftarrow (W+1+(1-\alpha)M)/2$ and $C_{\mathrm{out}} \leftarrow (M-W+1+\alpha M)/2$.
3. Return $S_M = B/C_{\mathrm{in}}$ and the Bayes speedup $B/\min(C_{\mathrm{in}},C_{\mathrm{out}})$.

This takes $O(1)$ arithmetic operations, compared with $O(M\cdot M!)$ for brute force or $O(M\log M)$ for sorting.

**Algorithm B (Gate test).** Input: target $s$, $\alpha$, $w$. Compute $\alpha_{\min} = 1-2/(3s)$. If $\alpha\le\alpha_{\min}$, report *unreachable at any width*. Otherwise report the width budget $w^\star = \alpha-\alpha_{\min}$ and *reachable* iff $w\le w^\star$. For finite $M$, replace $\alpha_{\min}$ by $\alpha_{\min}^M(s)$ as a necessary condition.

**Algorithm C (Displacement evaluation).** For any order $\sigma$ under a two-valued posterior, compute $\Sigma(\sigma) = \sum_{i:\sigma(i)<W}(i+1)$ in $O(M)$ time. The cost is then $\mathrm{cost}(\mathrm{committed}) + (a-b)(\Sigma - W(W+1)/2)$.

**Algorithm D (Inverting a measured speedup).** Given a measured speedup $s$ and an assumed reliability $\alpha$, the implied effective width fraction is $w = \alpha - \alpha_{\min}(s)$. If this is not positive, the assumed reliability is inconsistent with the measurement.

---

## 9. Discussion

**Gate versus budget.** The continuum denominator $1-\alpha+w$ makes unreliability and width additive costs. Additivity has a geometric consequence: once $w$ is at its floor of zero, unreliability alone caps the speedup at $2/(3(1-\alpha))$. Equivalently, $\alpha$ must exceed $1-2/(3s)$. Reliability opens the gate, and width only spends what lies beyond it.

**Why the optimum is easy.** The displacement law shows that under a two-valued posterior the cost landscape over $M!$ orders is a function of one integer, the window-slot sum. Every apparently clever hedging strategy can be scored exactly, and none beats committing.

**Scope.** The crossing law concerns the stipulated pricing. Section 7 shows that real posteriors can only do better. So the gate is a guaranteed benchmark, but outside this model it is not a necessary condition for every possible hint semantics. Section 6 shows that for a fully Bayesian searcher the gate must be stated two-sidedly, since an anti-reliable hint carries information.

**Ledger of corrections.** Several initial formulations were wrong and had to be fixed. The most instructive was a computation of the "Bayes" searcher that *marginalized* over the hint instead of *conditioning* on it. That collapses to the hint-blind baseline and badly understates hint value. The conjecture that the one-sided gate survives Bayes search was also false (Proposition 6.3).

---

## 10. Future directions

1. **Strict conservative pricing for prior-proportional hints.** For a strictly decreasing prior and its prior-proportional hint posterior with $\alpha\in(0,1)$ and $2\le W\le M-2$, the Bayes cost should be strictly below $(W+1+(1-\alpha)M)/2$, by $\Theta(M)$ under the min-law. The pairing identity turns the gap into half the cost difference between the committed scan and its block reversal, and Chebyshev's sum inequality should make it strict.
2. **Two-sided gate as a general Bayes law.** For posteriors uniform on window and complement, the set of $\alpha$ reaching speedup $s$ in the continuum should be a union of two half-lines, since the Bayes cost is a minimum of two affine functions of $\alpha$.
3. **Multi-window crossing law.** For nested windows $w_1<\dots<w_k$ with cumulative reliabilities $\alpha_1<\dots<\alpha_k$, the displacement law should extend to step posteriors and yield a polyhedral gate whose single-window case is Theorem 4.2.
4. **Misspecification.** If the oracle claims reliability $\alpha$ but the truth is $\beta$, the committed order does not depend on $\alpha$. So the realized stipulated speedup should reach $s$ iff $w\le\beta-\alpha_{\min}(s)$: the claimed reliability has no influence on the gate.

---

## 11. Conclusion

For a min-law target and an interval hint of width $w$ and reliability $\alpha$, the value of the hint is governed by one exact equivalence:
$$
s \le \frac{2}{3(1-\alpha+w)} \quad\Longleftrightarrow\quad w \le \alpha - \Big(1-\frac{2}{3s}\Big).
$$
This equivalence rests on the displacement law, which identifies the optimal search among all $M!$ orders. It has an exact finite-size analogue, needs a two-sided form for the fully Bayesian searcher, and is conservative for every posterior consistent with the hint. Its central message is that *width can never substitute for reliability*.
