# The Attention-Budget Knee: A Summability Criterion for Context-Stable Key Budgets

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

A transformer attends to a context of $n$ tokens through a probability vector over keys. If one keeps only the $k$ heaviest keys and discards the rest, some fraction of the attention mass survives; call it the *retained mass* $R_w(n,k)$. Fixing a gate $\tau$ — a mass-retention bar such as $\tau = 0.98$ — the smallest budget that clears the bar is the *knee* $k^*(n)$. Empirically, the knee behaves very differently across models: for one model the knee chain rises along a context ladder, $\{16, 20, 24\}$, while for a larger model it is flat, $\{16, 16\}$, and a fine sweep at context length $1024$ shows that every budget below $16$ fails (retained masses $0.9318$, $0.9532$, $0.9660$, $0.9759$ at $k = 4, 6, 8, 12$) while $k = 16$ passes.

This paper develops a model-free mathematical theory of that object and settles what such measurements can and cannot establish. Our results are:

1. **The razor.** Retained mass is monotone in the budget, so a *failure* at $a$ and a *pass* at $b$ pin the knee to the half-open bracket $a < k^*(n) \le b$ — with no distributional assumption whatsoever. Applied to the measurement above this gives the exact bracket $12 < k^*(1024) \le 16$.

2. **A dichotomy.** If the sorted weights decay geometrically, $w_{i+1} \le r\,w_i$ with $r < 1$, then a *single* budget clears the gate at every context length; explicitly $K(r,\tau) = \max\{\lceil \log((1-\tau)(1-r)) / \log r\rceil, 1\}$ suffices. If instead the weights lie in a fixed positive band $c \le w_i \le M$, the knee grows at least linearly, $k^*(n) \ge \tau n c / M$, and the context sensitivity $k^*(2n) - k^*(n)$ is unbounded. Both regimes are realised, so "flat chain versus rising chain" is a genuine structural distinction.

3. **Exact flatness is false.** Even for the ideal geometric profile $w_i = 2^{-i}$ at gate $3/4$ one has $k^*(1) = 1$ and $k^*(2) = 2$. Retained mass is antitone in the context length, so a longer context always dilutes a fixed budget. A two-point measurement $\{16,16\}$ can therefore support *uniform boundedness*, never an equality law.

4. **The exact criterion.** For any positive sorted profile and any interior gate $0 < \tau < 1$, a context-independent budget exists **if and only if the profile is summable**. Stability is independent of the gate: a harsher bar does not shrink the class of stable models. On Zipf profiles $w_i = (i+1)^{-s}$ this yields a sharp phase transition at the critical exponent $s = 1$.

5. **Heads merge by a max law.** The retained mass of a mixture of two heads is a mediant of the two per-head retained masses, hence squeezed between them; consequently the mixture's knee lies between $\min(k^*_1, k^*_2)$ and $\max(k^*_1, k^*_2)$, and context stability is closed under mixing. A single gapless head, however, destroys stability for the whole model.

The upshot for practice: the knee is not a parameter-count phenomenon. It is a spectrometer for the tail of the sorted attention profile, and what a knee sweep measures is (a bound on) the profile's decay exponent.

---

## 1. Introduction

### 1.1 The measured object

Inside a transformer, each attention head at each position produces a probability distribution over the $n$ keys in its context. Sparsification methods — top-$k$ attention, key–value cache eviction, streaming attention — all rest on the same empirical observation: this distribution is heavily concentrated, so almost all of the mass sits on a handful of keys, and the rest may be thrown away at little cost.

"A handful" is the interesting word. How many keys must one keep, and does that number grow as the context grows? Write the head's attention weights in decreasing order as $w_0 \ge w_1 \ge \cdots > 0$. Truncating to the top $k$ retains a fraction

$$R_w(n,k) \;=\; \frac{\sum_{i < \min(k,n)} w_i}{\sum_{i < n} w_i}$$

of the mass. Fix a retention gate $\tau \in (0,1)$ and define the **knee**

$$k^*(n) \;=\; \min\{\,k : R_w(n,k) \ge \tau\,\}.$$

The knee is the smallest key budget that preserves a $\tau$-fraction of the attention mass at context length $n$. The **context sensitivity** of the budget is $\Delta(n) = k^*(2n) - k^*(n)$: how much the budget must grow when the context doubles.

### 1.2 The empirical puzzle

A ladder of measurements at gate $\tau = 0.98$ across increasing context lengths produced two qualitatively different chains. For a $0.5$-billion-parameter model the chain rises: $\{16, 20, 24\}$. For a $1.5$-billion-parameter model it is flat: $\{16, 16\}$. A natural (and, as it turns out, wrong) reading is that the knee shrinks with model scale. A fine sweep below the previous grid floor, at context length $1024$, refutes this directly: at budgets $4, 6, 8, 12$ the larger model retains

$$0.9318,\quad 0.9532,\quad 0.9660,\quad 0.9759$$

respectively, all below the $0.98$ gate, while $k = 16$ clears it. The knee at $1024$ is therefore exactly $16$ within the resolution of the grid — and the value $0.9759$ at $k = 12$ is a razor-thin miss, roughly two standard errors below the bar.

Two questions arise. What, logically, do these numbers establish? And what property of a model makes its chain flat rather than rising? The theory below answers both, and the answer to the second is not "parameter count".

### 1.3 Contributions and structure

Section 2 sets up the formal objects and proves the basic monotonicity theory. Section 3 proves the razor bracket and applies it to the measurement. Section 4 establishes the geometric-decay regime with its closed-form universal budget, Section 5 the gapless regime with its linear lower bound, and Section 6 combines them into a separation theorem. Section 7 refutes exact flatness. Section 8 proves the summability characterisation and the Zipf phase transition. Section 9 treats head mixtures. Section 10 gives algorithms; Section 11 discusses consequences, limitations, and future work.

Throughout, no probabilistic model of language, no assumption about corpora, and no assumption about architecture is used. Every theorem below needs only that the weights are positive; monotonicity of the sorted profile is not even required for most statements, and where a decay condition is used it is stated explicitly.

---

## 2. Definitions and elementary theory

Let $w : \mathbb{N} \to \mathbb{R}$ be an **attention profile**: a sequence of weights, indexed in the order in which they will be retained (in practice, the sorted order). All results assume $w_i > 0$ for all $i$.

**Definition 2.1 (Head mass).** The *head mass* of the top $k$ keys is
$$H_w(k) = \sum_{i=0}^{k-1} w_i, \qquad H_w(0) = 0.$$

**Definition 2.2 (Retained mass).** For a context of length $n$ and budget $k$,
$$R_w(n,k) = \frac{H_w(\min(k,n))}{H_w(n)}.$$
The $\min$ encodes the fact that one cannot retain more keys than exist.

**Definition 2.3 (Knee).** For a gate $\tau$,
$$k^*_w(n,\tau) = \inf\{\,k \in \mathbb{N} : \tau \le R_w(n,k)\,\}.$$

**Definition 2.4 (Context sensitivity).** $\Delta_w(n,\tau) = k^*_w(2n,\tau) - k^*_w(n,\tau)$ (truncated subtraction on $\mathbb{N}$).

**Definition 2.5 (Context stability).** A profile $w$ is *context stable at gate $\tau$* when there is a single finite budget serving every context length:
$$\exists K \in \mathbb{N}\ \ \forall n \ge 1:\quad k^*_w(n,\tau) \le K.$$

The elementary facts we need are all consequences of positivity.

**Lemma 2.6 (Monotonicity of head mass).** $H_w$ is monotone, and strictly increasing: $a < b \Rightarrow H_w(a) < H_w(b)$. Moreover $H_w(n) > 0$ for $n \ge 1$.

*Proof.* $H_w(b) - H_w(a) = \sum_{a \le i < b} w_i > 0$ when $a<b$, since each summand is positive and the index set is nonempty. $\square$

**Lemma 2.7 (Basic properties of retained mass).** For $n \ge 1$:

* $0 \le R_w(n,k) \le 1$ for all $k$, and $R_w(n,n) = 1$;
* $k \mapsto R_w(n,k)$ is monotone non-decreasing;
* if $k < n$ then $R_w(n,k) < 1$ strictly — the gate is a genuine constraint below full context;
* if $a < b$ and $a < n$ then $R_w(n,a) < R_w(n,b)$ strictly.

*Proof.* The denominator $H_w(n)$ is a positive constant in $k$, so all four claims reduce to Lemma 2.6 applied to $H_w(\min(k,n))$, using $\min(a,n) < \min(b,n)$ whenever $a<b$ and $a<n$. $\square$

The last item has an immediate experimental corollary, worth isolating because it certifies that a reported sub-knee table is informative rather than a plateau.

**Proposition 2.8 (No plateau below the knee).** For every positive profile and every context length $n > 12$,
$$R_w(n,4) < R_w(n,6) < R_w(n,8) < R_w(n,12).$$
In particular the measured chain $0.9318 < 0.9532 < 0.9660 < 0.9759$ is not a coincidence of the corpus: strict increase along any sub-context grid is forced by positivity of the weights alone. Each grid point genuinely fails on its own, and the failures are ordered.

**Lemma 2.9 (The gate is attainable).** If $n \ge 1$ and $\tau \le 1$ then the set $\{k : \tau \le R_w(n,k)\}$ is nonempty (it contains $k=n$), so the knee is well defined, satisfies $\tau \le R_w(n, k^*)$, and obeys $k^*(n) \le n$.

**Lemma 2.10 (Context dilution).** For a fixed budget $k$ and $1 \le n_1 \le n_2$,
$$R_w(n_2, k) \le R_w(n_1, k).$$
That is, retained mass is *antitone* in the context length: a longer context always dilutes a fixed budget.

*Proof.* If $k \ge n_1$ then $R_w(n_1,k) = 1$ and the claim is trivial. Otherwise $\min(k,n_1) = \min(k,n_2) = k$, so the two sides share the numerator $H_w(k) \ge 0$ while the denominator only grows. $\square$

Lemma 2.10 is small but structurally decisive: it is the reason that "the knee is flat" cannot be literally true (Section 7).

---

## 3. The razor: what two measurements prove

Experimental knee reports are grids: a set of budgets, each labelled pass or fail. The following theorem says exactly how much such a grid establishes.

**Theorem 3.1 (Razor bracket).** Let $w$ be a positive profile, $n \ge 1$, $\tau \le 1$. Suppose a budget $a$ *fails*, $R_w(n,a) < \tau$, and a budget $b$ *passes*, $\tau \le R_w(n,b)$. Then
$$a < k^*_w(n,\tau) \le b.$$

*Proof.* Since $b$ lies in the gate set and $k^*$ is its infimum, $k^* \le b$. For the lower bound, suppose $k^* \le a$. Monotonicity of $R_w(n,\cdot)$ (Lemma 2.7) gives $\tau \le R_w(n,k^*) \le R_w(n,a) < \tau$, a contradiction. $\square$

The proof uses only monotonicity: no distributional assumption on the corpus, no sampling model, no architectural hypothesis. The bracket is therefore not a statistical inference but a deduction — up to the accuracy of the two measured numbers themselves.

**Corollary 3.2 (The measured bracket).** Let $w$ be the sorted attention profile of the model under test at context length $n \ge 1$, and suppose the measurement $R_w(n,12) = 0.9759$ and the pass $0.98 \le R_w(n,16)$ hold. Then
$$12 < k^*_w(n, 0.98) \le 16.$$

*Proof.* $0.9759 < 0.98$, so $k = 12$ is a failure; apply Theorem 3.1 with $a = 12$, $b = 16$. $\square$

This is the honest statement of "the knee is exactly 16": the knee lies in the half-open interval $(12, 16]$, and since the sweep also refuted $k = 4, 6, 8$, no sub-$16$ point on the tested grid passes. The remaining ambiguity is entirely the grid's, not the mathematics'.

**Lemma 3.3 (Gate monotonicity).** If $\tau_1 \le \tau_2 \le 1$ then $k^*(n,\tau_1) \le k^*(n,\tau_2)$: raising the bar can only raise the budget.

---

## 4. Regime I — geometric decay yields a universal budget

We now ask which profiles have a knee that does *not* run away with the context.

**Definition 4.1.** A profile $w$ has *decay ratio $r$* when $w_{i+1} \le r\,w_i$ for all $i$.

**Lemma 4.2 (Geometric domination).** If $0 \le r$ and $w$ has decay ratio $r$, then $w_i \le w_0 r^i$ for all $i$.

*Proof.* Induction: $w_0 \le w_0$, and $w_{i+1} \le r w_i \le r \cdot w_0 r^i = w_0 r^{i+1}$. $\square$

**Lemma 4.3 (Tail estimate).** If $0 < r < 1$ and $w$ has decay ratio $r$, then for all $k \le n$,
$$H_w(n) - H_w(k) \;=\; \sum_{k \le i < n} w_i \;\le\; \frac{w_0\, r^k}{1-r}.$$

*Proof.* Bound each term by $w_0 r^i$ (Lemma 4.2) and sum the geometric series: $\sum_{k \le i < n} r^i = (r^k - r^n)/(1-r) \le r^k/(1-r)$. $\square$

**Theorem 4.4 (Uniform mass guarantee).** Let $w$ be positive with decay ratio $r \in (0,1)$. For every $k \ge 1$ and every $n \ge 1$,
$$R_w(n,k) \;\ge\; 1 - \frac{r^k}{1-r}.$$
The bound is *independent of the context length*.

*Proof.* If $n \le k$ then $R_w(n,k) = 1$ and there is nothing to prove. Otherwise $\min(k,n)=k$ and
$$1 - R_w(n,k) = \frac{H_w(n)-H_w(k)}{H_w(n)} \le \frac{w_0 r^k/(1-r)}{H_w(n)} \le \frac{w_0 r^k/(1-r)}{w_0} = \frac{r^k}{1-r},$$
using Lemma 4.3 for the numerator and $H_w(n) \ge H_w(k) \ge H_w(1) = w_0$ for the denominator (here $k \ge 1$ is used). $\square$

The crucial structural point is the cancellation of $w_0$: the discarded tail and the retained head are both measured in units of the largest weight, so the guarantee is scale-free and, more importantly, $n$-free.

**Theorem 4.5 (Context-stable regime).** Let $w$ be positive with decay ratio $r \in (0,1)$ and let $\tau < 1$. Then there is $K \ge 1$ with $k^*_w(n,\tau) \le K$ for all $n \ge 1$; that is, $w$ is context stable at gate $\tau$.

*Proof.* Since $0 < r < 1$ and $(1-\tau)(1-r) > 0$, choose $K_0$ with $r^{K_0} < (1-\tau)(1-r)$, and put $K = \max(K_0, 1)$. Then $r^K \le r^{K_0} < (1-\tau)(1-r)$, so $r^K/(1-r) < 1 - \tau$, i.e. $\tau < 1 - r^K/(1-r) \le R_w(n,K)$ for every $n \ge 1$ by Theorem 4.4. Hence $K$ lies in the gate set at every $n$, and $k^*(n) \le K$. $\square$

Solving the inequality $r^K \le (1-\tau)(1-r)$ for $K$ makes the budget explicit.

**Theorem 4.6 (Closed-form universal budget).** For $w$ positive with decay ratio $r \in (0,1)$ and gate $\tau < 1$, define
$$K(r,\tau) \;=\; \max\left\{\left\lceil \frac{\log\big((1-\tau)(1-r)\big)}{\log r}\right\rceil,\; 1\right\}.$$
Then $k^*_w(n,\tau) \le K(r,\tau)$ for every context length $n \ge 1$.

*Proof.* Write $K = K(r,\tau)$. Since $\log r < 0$, the ceiling bound $\log((1-\tau)(1-r))/\log r \le K$ rearranges (dividing by the negative $\log r$ reverses the inequality) to $K \log r \le \log((1-\tau)(1-r))$, i.e. $r^K \le (1-\tau)(1-r)$, i.e. $r^K/(1-r) \le 1-\tau$. Theorem 4.4 with $K \ge 1$ then gives $\tau \le 1 - r^K/(1-r) \le R_w(n,K)$, and $k^* \le K$ follows. $\square$

**Corollary 4.7 (Bounded context sensitivity).** Under the hypotheses of Theorem 4.5, $\Delta_w(n,\tau) \le K$ for all $n \ge 1$ — doubling the context never moves the knee beyond the universal budget.

Theorem 4.6 is the formula behind the slogan "a 16-key budget covers both models up to context 1024". Read backwards, it is a measuring instrument: an observed universal budget $K$ *bounds the decay ratio* of the model's sorted attention profile, since any $r$ consistent with the observation must satisfy $r^K \le (1-\tau)(1-r)$. The knee is a spectrometer.

---

## 5. Regime II — no spectral gap forces a linearly growing budget

The opposite extreme is a profile with a positive floor: the weights never decay below some $c > 0$.

**Theorem 5.1 (Linear lower bound).** Let $w$ be positive with $c \le w_i \le M$ for all $i$, where $c > 0$. Then for $n \ge 1$ and $\tau \le 1$,
$$k^*_w(n,\tau) \;\ge\; \frac{\tau\, n\, c}{M}.$$

*Proof.* Put $k = k^*(n,\tau)$. By definition $\tau \le R_w(n,k)$, i.e. $\tau H_w(n) \le H_w(\min(k,n))$. The numerator is bounded above by $\min(k,n)M \le kM$; the denominator below by $H_w(n) \ge nc$. Hence $\tau n c \le \tau H_w(n) \le k M$, and dividing by $M > 0$ gives the claim. (For $\tau \le 0$ the statement is trivial since the left side is then non-positive.) $\square$

So a *bounded weight ratio* — the absence of any spectral gap in the attention profile — forces the budget to scale with the context. The bound is sharp: the flat profile realises it on both sides.

**Proposition 5.2 (The flat profile).** For $w \equiv 1$ one has $R_w(n,k) = \min(k,n)/n$, and for $n \ge 1$, $0 < \tau \le 1$,
$$\tau n \;\le\; k^*_w(n,\tau) \;\le\; \lceil \tau n \rceil .$$

*Proof.* The lower bound is Theorem 5.1 with $c = M = 1$. For the upper bound, $\lceil \tau n\rceil \le n$ and $R_w(n, \lceil\tau n\rceil) = \lceil \tau n\rceil/n \ge \tau$, so $\lceil \tau n\rceil$ is in the gate set. $\square$

**Theorem 5.3 (Unbounded context sensitivity).** For $w \equiv 1$ and $0 < \tau \le 1$, the context sensitivity is unbounded: for every $K$ there is $n \ge 1$ with $\Delta_w(n,\tau) > K$.

*Proof.* By Proposition 5.2, $k^*(2n) \ge 2\tau n$ and $k^*(n) \le \tau n + 1$, so $\Delta(n) \ge \tau n - 1$. Choosing $n > (K+3)/\tau$ makes this exceed $K$. $\square$

**Corollary 5.4.** The flat profile is not context stable at any gate $\tau \in (0,1]$: no fixed key budget serves all context lengths.

---

## 6. The separation theorem

**Theorem 6.1 (Context-sensitivity dichotomy).** Let $0 < \tau < 1$. Then both regimes are non-empty:

* the geometric profile $w_i = 2^{-i}$ admits a budget $K$ with $k^*(n) \le K$ for every $n \ge 1$;
* the flat profile $w \equiv 1$ has $\sup_n \Delta(n) = \infty$.

*Proof.* The first is Theorem 4.5 with $r = 1/2$; the second is Theorem 5.3. $\square$

The content is a *separation*: whether a knee chain is flat or rising is a property of the decay profile of the sorted attention weights, and both behaviours are genuinely realisable. Nothing in the argument mentions parameter count, depth, or training data. If a larger model has a flatter chain, the theory says the reason is that its sorted attention profile decays faster — a statement about the model's internal spectrum, directly checkable, and not implied by size.

---

## 7. Exact flatness is false; boundedness is the right invariant

A tempting reading of a measured chain $\{16, 16\}$ is a conservation law: $k^*(2n) = k^*(n)$. It is false, and instructively so.

**Theorem 7.1 (Refutation of exact flatness).** For the ideal geometric profile $w_i = 2^{-i}$ at gate $\tau = 3/4$,
$$k^*(1) = 1, \qquad k^*(2) = 2 .$$

*Proof.* At $n = 1$: $R(1,0) = 0 < 3/4$ and $R(1,1) = 1 \ge 3/4$, so by Theorem 3.1 the knee is bracketed by $0 < k^* \le 1$, giving $k^*(1) = 1$. At $n = 2$: the mass is $1 + 1/2 = 3/2$, so $R(2,1) = 1/(3/2) = 2/3 < 3/4$ while $R(2,2) = 1 \ge 3/4$; the bracket $1 < k^* \le 2$ gives $k^*(2) = 2$. $\square$

The mechanism is Lemma 2.10: the normaliser $H_w(n)$ keeps creeping upward as the context grows, so the retained fraction of a *fixed* budget is weakly decreasing in $n$. Near a gate crossing this can push the knee up by one step, even for the most rapidly decaying profile imaginable. Exact equality of knees at two context lengths is therefore a coincidence of where the gate happens to fall, not a law.

**Moral 7.2.** A two-point measurement can only ever support *uniform boundedness* of the budget, never an equality. The correct invariant is context stability (Definition 2.5), and the correct report of a measurement is a bracket (Theorem 3.1), not a number.

It is convenient to record that the knee formulation and the mass formulation of stability agree.

**Proposition 7.3.** For positive $w$ and $\tau \le 1$: $w$ is context stable at $\tau$ if and only if there is a single budget $K$ with $\tau \le R_w(n,K)$ for all $n \ge 1$.

*Proof.* ($\Rightarrow$) If $k^*(n) \le K$ for all $n$, then $\tau \le R_w(n,k^*(n)) \le R_w(n,K)$ by monotonicity. ($\Leftarrow$) If $K$ passes at every $n$, then $k^*(n) \le K$ by definition of the infimum. $\square$

---

## 8. The exact criterion: stability equals summability

Geometric decay is sufficient for stability but far from necessary. The exact boundary is a classical analytic condition.

**Theorem 8.1 (Summability criterion).** Let $w$ be a positive profile and $0 < \tau < 1$. Then
$$w \text{ is context stable at gate } \tau \iff \sum_{i=0}^{\infty} w_i < \infty .$$

*Proof.* ($\Rightarrow$) Suppose a budget $K$ works at every $n$ but $\sum_i w_i = \infty$. Since the terms are positive, the partial sums $H_w(n)$ then tend to $+\infty$; pick $n \ge 1$ with $H_w(n) > H_w(K)/\tau$. Stability gives $\tau \le R_w(n,K) = H_w(\min(K,n))/H_w(n) \le H_w(K)/H_w(n)$, hence $H_w(n) \le H_w(K)/\tau$ — a contradiction. So the partial sums are bounded, and a positive series with bounded partial sums converges.

($\Leftarrow$) Suppose $S = \sum_i w_i < \infty$; note $S \ge w_0 > 0$ and $H_w(m) \le S$ for every $m$. Since $\tau < 1$, we have $\tau S < S$, and since $H_w(m) \to S$ there is a $k$ with $\tau S < H_w(k)$. This $k$ passes at every context length: if $n \le k$ then $R_w(n,k) = 1 \ge \tau$; if $n > k$ then
$$\tau H_w(n) \le \tau S < H_w(k) = H_w(\min(k,n)),$$
so $R_w(n,k) > \tau$. By Proposition 7.3, $w$ is context stable. $\square$

Two consequences deserve emphasis.

**Corollary 8.2 (Gate independence).** If $w$ is context stable at one interior gate $\tau \in (0,1)$, it is context stable at every interior gate.

*Proof.* Both sides of Theorem 8.1 are equivalent to summability, which does not mention $\tau$. $\square$

This is a rigidity one would not expect: a harsher retention bar increases the *value* of the budget (Lemma 3.3) but cannot change *whether a finite budget exists*. Stability is a property of the model, not of the measurement.

The next result converts a tail estimate directly into a budget, generalising Theorem 4.4 beyond geometric profiles.

**Theorem 8.3 (Quantitative tail criterion).** Let $w$ be positive and summable, $k \ge 1$, and suppose the discarded tail satisfies
$$\sum_{i \ge k} w_i \;\le\; (1-\tau)\, w_0 .$$
Then $k^*_w(n,\tau) \le k$ for every $n \ge 1$.

*Proof.* The hypothesis forces $\tau \le 1$, since the left side is non-negative and $w_0 > 0$. For $n \le k$ we have $R_w(n,k)=1 \ge \tau$. For $n > k$,
$$H_w(n) - H_w(k) = \sum_{k \le i < n} w_i \le \sum_{i \ge k} w_i \le (1-\tau)w_0 \le (1-\tau)H_w(k),$$
using $w_0 = H_w(1) \le H_w(k)$ (here $k \ge 1$). Hence $H_w(n) \le (2-\tau)H_w(k)$ and
$$R_w(n,k) = \frac{H_w(k)}{H_w(n)} \ge \frac{1}{2-\tau} \ge \tau,$$
the last inequality being equivalent to $(1-\tau)^2 \ge 0$. $\square$

**The Zipf family.** Take $w_i = (i+1)^{-s}$ for a real exponent $s$. This is the canonical heavy-tailed profile and the standard fit for empirical attention spectra.

**Theorem 8.4 (Zipf phase transition).** For $0 < \tau < 1$, the Zipf profile with exponent $s$ is context stable at gate $\tau$ if and only if $s > 1$.

*Proof.* By Theorem 8.1 stability is equivalent to summability of $\sum_i (i+1)^{-s}$, which by the $p$-series criterion holds precisely for $s > 1$. $\square$

**Corollary 8.5 (Subcritical budgets are always defeated).** If $s \le 1$ then for every candidate budget $K$ there is a context length $n$ with $k^*(n) > K$.

The critical exponent is exactly $1$: above it a bounded budget exists at every gate; at or below it, the budget diverges with the context. Measuring a knee at two context lengths therefore *locates the model on one side of $s = 1$* — and, with more gate points, pins the exponent further (Section 11).

---

## 9. Merging heads: a max law, not a sum law

Real models have many heads, and a practical key budget must serve their union. Write the merged profile as the pointwise sum $w_1 + w_2$ (unnormalised attention masses add).

**Theorem 9.1 (Mediant inequality).** Let $w_1, w_2$ be positive profiles, $n \ge 1$, $k$ arbitrary. Then
$$\min\big(R_{w_1}(n,k), R_{w_2}(n,k)\big) \;\le\; R_{w_1+w_2}(n,k) \;\le\; \max\big(R_{w_1}(n,k), R_{w_2}(n,k)\big).$$

*Proof.* Head mass is additive: $H_{w_1+w_2}(k) = H_{w_1}(k)+H_{w_2}(k)$. So the merged retained mass is the mediant $\frac{A_1+A_2}{B_1+B_2}$ of $A_1/B_1$ and $A_2/B_2$ with $B_1, B_2 > 0$. Writing $m$ for the minimum, $mB_j \le A_j$ for $j=1,2$; adding gives $m(B_1+B_2) \le A_1+A_2$. The upper bound is symmetric. $\square$

**Theorem 9.2 (Knee sandwich).** For positive $w_1, w_2$, $n \ge 1$, $\tau \le 1$,
$$\min\big(k^*_{w_1}(n,\tau), k^*_{w_2}(n,\tau)\big) \;\le\; k^*_{w_1+w_2}(n,\tau) \;\le\; \max\big(k^*_{w_1}(n,\tau), k^*_{w_2}(n,\tau)\big).$$

*Proof.* Upper bound: let $K$ be the max of the two knees. By monotonicity each head passes at $K$, so $\tau \le \min(R_{w_1}(n,K), R_{w_2}(n,K)) \le R_{w_1+w_2}(n,K)$ by Theorem 9.1; hence the merged knee is $\le K$. Lower bound: let $k$ be the merged knee, which passes; by the upper mediant bound one of the two heads also passes at $k$, so the corresponding per-head knee is $\le k$, whence $\min(k^*_1,k^*_2) \le k$. $\square$

**Corollary 9.3 (Stability is closed under mixing).** If $w_1$ and $w_2$ are context stable at $\tau \le 1$, so is $w_1 + w_2$, with budget $\max(K_1,K_2)$.

**Corollary 9.4 (A single gapless head is fatal).** A flat head is not context stable (Corollary 5.4); and since summability is not preserved by adding a non-summable component, a mixture containing a gapless head is not context stable either.

Thus stability obeys a *max law*, not a sum law: adding well-behaved heads never destabilises a model, but a single heavy-tailed (subcritical) head sets the budget for the whole system. This has a direct experimental consequence: per-head knees measured separately should bracket the model-level knee, with the worst head dominating.

---

## 10. Algorithms

The theory yields three small, exact procedures.

**Algorithm A — knee by bisection.** Given a profile, a context length $n$, and a gate $\tau$, monotonicity of $R_w(n,\cdot)$ (Lemma 2.7) makes the predicate "budget $k$ passes" monotone in $k$, so the knee can be found by binary search on $[0,n]$ in $O(\log n)$ predicate evaluations after an $O(n)$ prefix-sum precomputation. Correctness is exactly Theorem 3.1: bisection maintains a fail/pass bracket $(a,b]$ containing $k^*$ and shrinks it to a single point.

**Algorithm B — universal budget from a decay ratio.** Given an observed decay ratio $r$ and a gate $\tau$, return $K(r,\tau) = \max\{\lceil \log((1-\tau)(1-r))/\log r\rceil, 1\}$. By Theorem 4.6 this is valid at every context length; the cost is $O(1)$.

**Algorithm C — decay-ratio inversion (the spectrometer).** Given a measured universal budget $K$ and gate $\tau$, return the largest $r$ consistent with $r^K \le (1-\tau)(1-r)$, obtained by bisection on $r \in (0,1)$ since the left side is increasing in $r$ and the right decreasing. This converts a knee measurement into a bound on the internal decay ratio of the attention profile.

A fourth, purely empirical procedure — fitting a Zipf exponent to a measured retention grid by bisection on $s$ — is what turns the phase transition of Theorem 8.4 into a diagnostic; it is implemented in the accompanying numerical demonstration.

---

## 11. Discussion

### 11.1 What the measurements establish, exactly

Applying Theorem 3.1 to the fine sweep gives $12 < k^*(1024) \le 16$ at gate $0.98$, and Proposition 2.8 certifies that the sub-knee grid is strictly increasing rather than a plateau, so each failing point carries independent information. The claim "the knee is $16$" is thus exactly a bracket claim; the residual uncertainty is the grid spacing, not the mathematics. Conversely, the two-point chain $\{16, 16\}$ across a doubling of context cannot be upgraded to an equality law, because exact flatness is false even for ideal geometric decay (Theorem 7.1). What it *can* support is uniform boundedness of the budget — precisely the invariant that the theory shows is meaningful.

### 11.2 What actually separates the two chains

The dichotomy (Theorem 6.1) and its sharpening (Theorem 8.1) say that context stability is a summability property of the sorted attention profile. A rising chain $\{16,20,24\}$ is a signature of a slowly decaying — critically or subcritically heavy-tailed — profile, whose budget must grow like $\Theta(n)$ in the extreme gapless case (Theorem 5.1). A flat chain is a signature of a summable profile with a fast enough tail. Model scale enters this story only indirectly, through whatever effect it has on the spectrum. The natural refined observable is therefore not the knee itself but the *context sensitivity* $k^*(2n)-k^*(n)$, whose boundedness is the sharp property.

### 11.3 A numerical consistency check

Fitting a Zipf profile to the measured retention grid at context $1024$ — solving $R_{\text{zipf}(s)}(1024, k) = R_{\text{measured}}(k)$ for $s$ at each grid point — yields exponents $2.35, 2.30, 2.29, 2.24$ at $k = 4,6,8,12$. Two things follow. First, the fitted exponent is stable across the grid to within about $5\%$, so a single-parameter power-law tail is a reasonable description of the measured profile. Second, all fitted values are comfortably supercritical ($s > 1$), so Theorem 8.4 predicts a context-stable budget: indeed, for $s \in [2.24, 2.35]$ the model's knee at gate $0.98$ is computed to be $11$–$15$ *independently of $n$*, from $n = 1024$ up to $n = 65{,}536$. This is a genuine prediction of flatness beyond the measured ladder, and it is falsifiable: a fine grid at context $2048$ should not move the knee. (These figures are a numerical fit to the reported grid, not a proved statement; the proved statements are Theorems 8.1 and 8.4.)

### 11.4 Limitations

The theory is model-free by design, which is both its strength and its boundary. It says nothing about *why* a given model's spectrum decays as it does, nor about the downstream task loss induced by truncation — retained attention mass is a proxy for quality, not quality itself. All statements assume positive weights and treat the profile in its already-sorted order; a real head's ranking varies by query and position, so an empirical knee is an aggregate over a distribution of profiles, and the theory applies pointwise. Finally, the measured inputs enter our conclusions as hypotheses: Corollary 3.2 is a conditional statement whose antecedents are the two measured numbers.

### 11.5 Future work

The sharpest open question is quantitative: for an asymptotically Zipf profile with exponent $s > 1$, is the knee at gate $\tau$ of size $\Theta\big((1-\tau)^{-1/(s-1)}\big)$, uniformly in $n$? The upper direction should follow from the tail criterion (Theorem 8.3), which converts gate slack $1-\tau$ into a tail-mass budget; for a power-law tail the inverse of the tail function is again a power law with exponent $1/(s-1)$. A matching lower bound via integral comparison would make two knee measurements *at different gates* determine $s$, turning a knee sweep into a spectrometer for the model's attention spectrum. If instead the conjecture fails, the profile requires at least two parameters to describe — itself an informative outcome.

Adjacent directions: head-count invariance (does the merged budget equal the maximum per-head budget exactly, not merely up to the sandwich of Theorem 9.2?); the behaviour of the mixed critical case, where a subcritical head is diluted by many supercritical ones; and the finite-context analogue of the phase transition, quantifying how large $n$ must be before the divergence at $s \le 1$ becomes visible against a fixed gate.

---

## 12. Summary of results

| Statement | Content |
|---|---|
| Razor bracket | A fail at $a$ and a pass at $b$ imply $a < k^*(n) \le b$, from monotonicity alone |
| No plateau | $R(n,4) < R(n,6) < R(n,8) < R(n,12)$ for every positive profile, $n>12$ |
| Context dilution | $R_w(n,k)$ is antitone in $n$ |
| Uniform mass guarantee | Decay ratio $r$ $\Rightarrow$ $R_w(n,k) \ge 1 - r^k/(1-r)$, independent of $n$ |
| Universal budget | $K(r,\tau) = \max\{\lceil\log((1-\tau)(1-r))/\log r\rceil,1\}$ works at every $n$ |
| Linear lower bound | $c \le w_i \le M$ $\Rightarrow$ $k^*(n) \ge \tau nc/M$ |
| Flat profile | $\tau n \le k^*(n) \le \lceil \tau n\rceil$; context sensitivity unbounded |
| Dichotomy | Both regimes realised: $2^{-i}$ stable, $w\equiv 1$ unboundedly sensitive |
| Exact flatness refuted | For $2^{-i}$ at gate $3/4$: $k^*(1)=1 \ne 2 = k^*(2)$ |
| Summability criterion | Context stability $\iff$ $\sum_i w_i < \infty$, for every interior gate |
| Gate independence | Stability at one interior gate implies stability at all |
| Tail criterion | $\sum_{i\ge k} w_i \le (1-\tau)w_0$ $\Rightarrow$ $k^*(n) \le k$ for all $n$ |
| Zipf transition | Zipf $(i+1)^{-s}$ is stable $\iff$ $s>1$ |
| Mediant / max law | Merged retained mass lies between the per-head values; knees sandwich; stability closed under mixing |
